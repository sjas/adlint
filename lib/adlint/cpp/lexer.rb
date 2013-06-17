# Lexical analyzer which tokenizes C language source into pp-tokens.
#
# Author::    Yutaka Yanoh <mailto:yanoh@users.sourceforge.net>
# Copyright:: Copyright (C) 2010-2013, OGIS-RI Co.,Ltd.
# License::   GPLv3+: GNU General Public License version 3 or later
#
# Owner::     Yutaka Yanoh <mailto:yanoh@users.sourceforge.net>

#--
#     ___    ____  __    ___   _________
#    /   |  / _  |/ /   / / | / /__  __/           Source Code Static Analyzer
#   / /| | / / / / /   / /  |/ /  / /                   AdLint - Advanced Lint
#  / __  |/ /_/ / /___/ / /|  /  / /
# /_/  |_|_____/_____/_/_/ |_/  /_/   Copyright (C) 2010-2013, OGIS-RI Co.,Ltd.
#
# This file is part of AdLint.
#
# AdLint is free software: you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# AdLint is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# AdLint.  If not, see <http://www.gnu.org/licenses/>.
#
#++

require "adlint/lexer"
require "adlint/report"
require "adlint/util"

module AdLint #:nodoc:
module Cpp #:nodoc:

  class Lexer
    def initialize(src, traits)
      src.on_cr_at_eol_found += lambda { |loc|
        on_cr_at_eol_found.invoke(loc)
      }
      src.on_eof_mark_at_eof_found += lambda { |loc|
        on_eof_mark_at_eof_found.invoke(loc)
      }
      src.on_eof_newline_not_found += method(:notify_eof_newline_not_found)

      tab_width  = traits.of_project.coding_style.tab_width
      @content   = SourceContent.lazy_new(src, tab_width)
      @state     = Initial.new(self)
      @top_token = nil
    end

    attr_reader :content

    extend Pluggable

    def_plugin :on_block_comment_found
    def_plugin :on_line_comment_found
    def_plugin :on_nested_block_comment_found
    def_plugin :on_unterminated_block_comment
    def_plugin :on_eof_newline_not_found
    def_plugin :on_unlexable_char_found
    def_plugin :on_cr_at_eol_found
    def_plugin :on_eof_mark_at_eof_found
    def_plugin :on_illformed_newline_escape_found

    def next_token
      if @top_token
        tok = @top_token
        @top_token = nil
        return tok
      end
      @state.next_token
    end

    def top_token
      @top_token ? @top_token : (@top_token = self.next_token)
    end

    def skip_group
      group_depth = 1
      until @content.empty?
        scan_until_next_directive_or_comment(@content)

        case
        when @content.check(/\/\*|\/\//)
          discard_heading_comments
        when @content.check(/[ \t]*#[ \t]*(?:if|ifdef|ifndef|asm)\b/)
          group_depth += 1
          @content.scan(/.*?\n/)
        when @content.check(/[ \t]*#[ \t]*(?:else|elif)\b/)
          return true if group_depth == 1
          @content.scan(/.*?\n/)
        when @content.check(/[ \t]*#[ \t]*(?:endif|endasm)\b/)
          group_depth -= 1
          return true if group_depth == 0
          @content.scan(/.*?\n/)
        end
      end
      false
    end

    def discard_heading_comments
      case
      when @content.check(/\/\*/)
        loc = @content.location
        comment = scan_block_comment(@content)
        unless comment.empty?
          notify_block_comment_found(comment, loc)
          return true
        end
      when @content.check(/\/\//)
        loc = @content.location
        comment = scan_line_comment(@content)
        unless comment.empty?
          notify_line_comment_found(comment, loc)
          return true
        end
      end
      false
    end

    def transit(next_state)
      @state = next_state
    end

    def notify_block_comment_found(comment, loc)
      on_block_comment_found.invoke(comment, loc)
    end

    def notify_line_comment_found(comment, loc)
      on_line_comment_found.invoke(comment, loc)
    end

    def notify_nested_block_comment_found(loc)
      on_nested_block_comment_found.invoke(loc)
    end

    def notify_unterminated_block_comment(loc)
      on_unterminated_block_comment.invoke(loc)
    end

    def notify_eof_newline_not_found(loc)
      on_eof_newline_not_found.invoke(loc)
    end

    def notify_unlexable_char_found(char, loc)
      on_unlexable_char_found.invoke(char, loc)
    end

    def notify_illformed_newline_escape_found(loc)
      on_illformed_newline_escape_found.invoke(loc)
    end

    private
    GROUP_DIRECTIVE_RE =
      /^[ \t]*#[ \t]*(?:if|ifdef|ifndef|asm|else|elif|endif|endasm)\b/
    private_constant :GROUP_DIRECTIVE_RE

    def scan_until_next_directive_or_comment(cont)
      cont.scan(/.*?(?=#{GROUP_DIRECTIVE_RE}|\/\*|\/\/)/m)
    end

    def scan_block_comment(cont)
      comment = ""
      nest_depth = 0
      until cont.empty?
        loc = cont.location
        case
        when nest_depth == 0 && cont.scan(/\/\*/)
          nest_depth = 1
          comment += "/*"
        when nest_depth > 0 && cont.check(/\/\*\//)
          comment += cont.scan(/\//)
        when nest_depth > 0 && cont.check(/\/\*/)
          nest_depth += 1
          comment += cont.scan(/\/\*/)
          notify_nested_block_comment_found(loc)
        when cont.scan(/\*\//)
          comment += "*/"
          break
        when nest_depth == 0
          return nil
        else
          if scanned = cont.scan(/.*?(?=\/\*|\*\/)/m)
            comment += scanned
          else
            notify_unterminated_block_comment(loc)
          end
        end
      end
      comment
    end

    def scan_line_comment(cont)
      cont.scan(/\/\/.*?(?=\n)/)
    end
  end

  class LexerState
    def initialize(lexer)
      @lexer = lexer
    end

    def next_token
      subclass_responsibility
    end

    private
    def discard_heading_comments
      @lexer.discard_heading_comments
    end

    def scan_escaped_newline(cont)
      loc = cont.location
      case
      when escaped_nl = cont.scan(/\\\n/)
        escaped_nl
      when escaped_nl = cont.scan(/\\[ \t]+\n/)
        @lexer.notify_illformed_newline_escape_found(loc)
        escaped_nl
      else
        nil
      end
    end

    def tokenize_pp_token(cont)
      loc = cont.location
      case
      when val = Language::C.scan_keyword(cont),
           val = Language::Cpp.scan_keyword(cont)
        Token.new(:PP_TOKEN, val, loc, Language::C::KEYWORDS[val])
      when val = Language::C.scan_char_constant(cont),
           val = Language::C.scan_floating_constant(cont),
           val = Language::C.scan_integer_constant(cont)
        Token.new(:PP_TOKEN, val, loc, :CONSTANT)
      when val = Language::C.scan_string_literal(cont)
        Token.new(:PP_TOKEN, val, loc, :STRING_LITERAL)
      when val = Language::C.scan_null_constant(cont)
        Token.new(:PP_TOKEN, val, loc, :NULL)
      when val = Language::C.scan_identifier(cont)
        Token.new(:PP_TOKEN, val, loc, :IDENTIFIER)
      when val = Language::Cpp.scan_punctuator(cont)
        Token.new(:PP_TOKEN, val, loc, val)
      else
        nil
      end
    end

    def tokenize_new_line(cont)
      loc = cont.location
      if val = cont.scan(/\n/)
        return Token.new(:NEW_LINE, val, loc)
      end
      nil
    end

    def tokenize_header_name(cont)
      loc = cont.location
      if val = Language::Cpp.scan_system_header_name(cont)
        return Token.new(:SYS_HEADER_NAME, val, loc)
      elsif val = Language::Cpp.scan_user_header_name(cont)
        return Token.new(:USR_HEADER_NAME, val, loc)
      end
      nil
    end

    def tokenize_identifier(cont)
      loc = cont.location
      if val = Language::C.scan_identifier(cont)
        return Token.new(:IDENTIFIER, val, loc)
      end
      nil
    end

    def tokenize_punctuator(cont)
      loc = cont.location
      if punctuator = Language::Cpp.scan_punctuator(cont)
        return Token.new(punctuator, punctuator, loc)
      end
      nil
    end

    def tokenize_extra_token(cont)
      # NOTE: #tokenize_pp_token can tokenize almost all types of tokens.
      if tok = tokenize_pp_token(cont)
        Token.new(:EXTRA_TOKEN, tok.value, tok.location)
      else
        nil
      end
    end
  end

  class Initial < LexerState
    def next_token
      # NOTE: An escaped newline may appear at the line above a preprocessing
      #       directive line.
      loop do
        unless discard_heading_comments || scan_escaped_newline(@lexer.content)
          break
        end
      end

      case
      when @lexer.content.check(/[ \t]*#/)
        case
        when tok = tokenize_if_directive(@lexer.content)
          @lexer.transit(InIfDirective.new(@lexer))
        when tok = tokenize_ifdef_directive(@lexer.content)
          @lexer.transit(InIfdefDirective.new(@lexer))
        when tok = tokenize_ifndef_directive(@lexer.content)
          @lexer.transit(InIfndefDirective.new(@lexer))
        when tok = tokenize_elif_directive(@lexer.content)
          @lexer.transit(InElifDirective.new(@lexer))
        when tok = tokenize_else_directive(@lexer.content)
          @lexer.transit(InElseDirective.new(@lexer))
        when tok = tokenize_endif_directive(@lexer.content)
          @lexer.transit(InEndifDirective.new(@lexer))
        when tok = tokenize_include_directive(@lexer.content)
          @lexer.transit(InIncludeDirective.new(@lexer))
        when tok = tokenize_include_next_directive(@lexer.content)
          @lexer.transit(InIncludeNextDirective.new(@lexer))
        when tok = tokenize_define_directive(@lexer.content)
          @lexer.transit(InDefineDirective.new(@lexer))
        when tok = tokenize_undef_directive(@lexer.content)
          @lexer.transit(InUndefDirective.new(@lexer))
        when tok = tokenize_line_directive(@lexer.content)
          @lexer.transit(InLineDirective.new(@lexer))
        when tok = tokenize_error_directive(@lexer.content)
          @lexer.transit(InErrorDirective.new(@lexer))
        when tok = tokenize_pragma_directive(@lexer.content)
          @lexer.transit(InPragmaDirective.new(@lexer))
        when tok = tokenize_asm_directive(@lexer.content)
          @lexer.transit(InAsmDirective.new(@lexer))
        when tok = tokenize_endasm_directive(@lexer.content)
          @lexer.transit(InEndasmDirective.new(@lexer))
        else
          tok = tokenize_null_directive(@lexer.content) ||
                tokenize_unknown_directive(@lexer.content)
        end
      else
        tok = tokenize_text_line(@lexer.content)
      end

      tok
    end

    private
    def tokenize_if_directive(cont)
      loc = cont.location
      if val = cont.scan(/[ \t]*#[ \t]*if\b/)
        return Token.new(:IF, val, loc)
      end
      nil
    end

    def tokenize_ifdef_directive(cont)
      loc = cont.location
      if val = cont.scan(/[ \t]*#[ \t]*ifdef\b/)
        return Token.new(:IFDEF, val, loc)
      end
      nil
    end

    def tokenize_ifndef_directive(cont)
      loc = cont.location
      if val = cont.scan(/[ \t]*#[ \t]*ifndef\b/)
        return Token.new(:IFNDEF, val, loc)
      end
      nil
    end

    def tokenize_elif_directive(cont)
      loc = cont.location
      if val = cont.scan(/[ \t]*#[ \t]*elif\b/)
        return Token.new(:ELIF, val, loc)
      end
      nil
    end

    def tokenize_else_directive(cont)
      loc = cont.location
      if val = cont.scan(/[ \t]*#[ \t]*else\b/)
        return Token.new(:ELSE, val, loc)
      end
      nil
    end

    def tokenize_endif_directive(cont)
      loc = cont.location
      if val = cont.scan(/[ \t]*#[ \t]*endif\b/)
        return Token.new(:ENDIF, val, loc)
      end
      nil
    end

    def tokenize_include_directive(cont)
      loc = cont.location
      if val = cont.scan(/[ \t]*#[ \t]*include\b/)
        return Token.new(:INCLUDE, val, loc)
      end
      nil
    end

    def tokenize_include_next_directive(cont)
      # NOTE: #include_next directive is a GCC extension.
      loc = cont.location
      if val = cont.scan(/[ \t]*#[ \t]*include_next\b/)
        return Token.new(:INCLUDE_NEXT, val, loc)
      end
      nil
    end

    def tokenize_define_directive(cont)
      loc = cont.location
      if val = cont.scan(/[ \t]*#[ \t]*define\b/)
        return Token.new(:DEFINE, val, loc)
      end
      nil
    end

    def tokenize_undef_directive(cont)
      loc = cont.location
      if val = cont.scan(/[ \t]*#[ \t]*undef\b/)
        return Token.new(:UNDEF, val, loc)
      end
      nil
    end

    def tokenize_line_directive(cont)
      loc = cont.location
      if val = cont.scan(/[ \t]*#[ \t]*line\b/)
        return Token.new(:LINE, val, loc)
      end
      nil
    end

    def tokenize_error_directive(cont)
      loc = cont.location
      if val = cont.scan(/[ \t]*#[ \t]*error\b/)
        return Token.new(:ERROR, val, loc)
      end
      nil
    end

    def tokenize_pragma_directive(cont)
      loc = cont.location
      if val = cont.scan(/[ \t]*#[ \t]*pragma\b/)
        return Token.new(:PRAGMA, val, loc)
      end
      nil
    end

    def tokenize_asm_directive(cont)
      loc = cont.location
      if val = cont.scan(/[ \t]*#[ \t]*asm\b/)
        return Token.new(:ASM, val, loc)
      end
      nil
    end

    def tokenize_endasm_directive(cont)
      loc = cont.location
      if val = cont.scan(/[ \t]*#[ \t]*endasm\b/)
        return Token.new(:ENDASM, val, loc)
      end
      nil
    end

    def tokenize_null_directive(cont)
      loc = cont.location
      if val = cont.scan(/[ \t]*#[ \t]\n/)
        return Token.new(:NULL_DIRECTIVE, val, loc)
      end
      nil
    end

    def tokenize_unknown_directive(cont)
      loc = cont.location
      val = cont.scan(/[ \t]*#/)
      until cont.empty?
        next if discard_heading_comments || scan_escaped_newline(cont)

        case
        when str = cont.scan(/.+?(?=\/\*|\/\/|\\[ \t]*\n|L?"|L?'|\n)/i)
          val += str
        when str = cont.scan(/\n/)
          val += str
          break
        end
      end
      Token.new(:UNKNOWN_DIRECTIVE, val, loc)
    end

    def tokenize_text_line(cont)
      loc = cont.location
      val = ""

      until cont.empty?
        if tok = cont.scan(/.*?(?=\/\*|\/\/|\\[ \t]*\n|L?"|L?'|\n)/i)
          val += tok
        end

        if tok = cont.scan(/\n/)
          val += tok
          break
        end

        next if scan_escaped_newline(cont)

        case
        when cont.check(/\/\*/)
          discard_heading_comments
        when cont.check(/\/\//)
          discard_heading_comments
        when cont.check(/L?"/i)
          string_literal = Language::C.scan_string_literal(cont)
          val += string_literal
        when cont.check(/L?'/i)
          char_constant = Language::C.scan_char_constant(cont)
          val += char_constant
        end
      end

      val.empty? ? nil : Token.new(:TEXT_LINE, val, loc)
    end
  end

  class InIfDirective < LexerState
    def next_token
      until @lexer.content.empty?
        if discard_heading_comments || scan_escaped_newline(@lexer.content)
          next
        end

        tok = tokenize_pp_token(@lexer.content) ||
              tokenize_new_line(@lexer.content) ||
              tokenize_extra_token(@lexer.content)

        if tok
          break
        else
          @lexer.content.eat!
        end
      end

      unless tok
        tok = Token.new(:NEW_LINE, "\n", @lexer.content.location)
        @lexer.notify_eof_newline_not_found(tok.location)
      end

      if tok.type == :NEW_LINE
        @lexer.transit(Initial.new(@lexer))
      end

      tok
    end
  end

  class InIfdefDirective < LexerState
    def next_token
      until @lexer.content.empty?
        if discard_heading_comments || scan_escaped_newline(@lexer.content)
          next
        end

        tok = tokenize_identifier(@lexer.content) ||
              tokenize_new_line(@lexer.content)   ||
              tokenize_extra_token(@lexer.content)

        if tok
          break
        else
          @lexer.content.eat!
        end
      end

      unless tok
        tok = Token.new(:NEW_LINE, "\n", @lexer.content.location)
        @lexer.notify_eof_newline_not_found(tok.location)
      end

      if tok.type == :NEW_LINE
        @lexer.transit(Initial.new(@lexer))
      end

      tok
    end
  end

  class InIfndefDirective < InIfdefDirective; end

  class InElifDirective < InIfDirective; end

  class InElseDirective < LexerState
    def next_token
      until @lexer.content.empty?
        if discard_heading_comments || scan_escaped_newline(@lexer.content)
          next
        end

        tok = tokenize_new_line(@lexer.content) ||
              tokenize_extra_token(@lexer.content)

        if tok
          break
        else
          @lexer.content.eat!
        end
      end

      unless tok
        tok = Token.new(:NEW_LINE, "\n", @lexer.content.location)
        @lexer.notify_eof_newline_not_found(tok.location)
      end

      if tok.type == :NEW_LINE
        @lexer.transit(Initial.new(@lexer))
      end

      tok
    end
  end

  class InEndifDirective < InElseDirective; end

  class InIncludeDirective < LexerState
    def next_token
      until @lexer.content.empty?
        if discard_heading_comments || scan_escaped_newline(@lexer.content)
          next
        end

        tok = tokenize_header_name(@lexer.content) ||
              tokenize_pp_token(@lexer.content)    ||
              tokenize_new_line(@lexer.content)    ||
              tokenize_extra_token(@lexer.content)

        if tok
          break
        else
          @lexer.content.eat!
        end
      end

      unless tok
        tok = Token.new(:NEW_LINE, "\n", @lexer.content.location)
        @lexer.notify_eof_newline_not_found(tok.location)
      end

      if tok.type == :NEW_LINE
        @lexer.transit(Initial.new(@lexer))
      end

      tok
    end
  end

  class InIncludeNextDirective < InIncludeDirective; end

  class InDefineDirective < LexerState
    def initialize(lexer)
      super
      @tokens = []
    end

    def next_token
      if @tokens.empty?
        tokenize_macro_name(@lexer.content)
        tokenize_pp_tokens(@lexer.content)
      end

      tok = @tokens.shift
      @lexer.transit(Initial.new(@lexer)) if @tokens.empty?
      tok
    end

    private
    def tokenize_macro_name(cont)
      until cont.empty?
        next if discard_heading_comments || scan_escaped_newline(cont)

        if tok = tokenize_identifier(cont)
          @tokens.push(tok)
          break
        else
          cont.eat!
        end
      end

      return unless cont.check(/\(/)

      paren_depth = 0
      until cont.empty?
        next if discard_heading_comments || scan_escaped_newline(cont)

        if tok = tokenize_identifier(cont)
          @tokens.push(tok)
          next
        end

        if tok = tokenize_punctuator(cont)
          @tokens.push(tok)
          case tok.type
          when "("
            paren_depth += 1
          when ")"
            paren_depth -= 1
            break if paren_depth == 0
          end
          next
        end

        if tok = tokenize_new_line(cont)
          @tokens.push(tok)
          break
        end

        cont.eat!
      end
    end

    def tokenize_pp_tokens(cont)
      until cont.empty?
        next if discard_heading_comments || scan_escaped_newline(cont)

        tok = tokenize_pp_token(cont) || tokenize_new_line(cont)

        if tok
          @tokens.push(tok)
          if tok.type == :NEW_LINE
            break
          end
        else
          loc = cont.location
          if eaten = cont.eat! and eaten !~ /\A\s\z/
            @lexer.notify_unlexable_char_found(eaten, loc)
          end
        end
      end

      unless @tokens.last && @tokens.last.type == :NEW_LINE
        tok = Token.new(:NEW_LINE, "\n", cont.location)
        @lexer.notify_eof_newline_not_found(tok.location)
        @tokens.push(tok)
      end
    end
  end

  class InUndefDirective < InDefineDirective; end

  class InLineDirective < InIfDirective; end

  class InErrorDirective < InLineDirective; end

  class InPragmaDirective < InLineDirective; end

  class InAsmDirective < InElseDirective; end

  class InEndasmDirective < InElseDirective; end

  class StringToPPTokensLexer < StringLexer
    def initialize(str, tab_width = 8)
      super(str)
      @tab_width = tab_width
    end

    private
    def create_lexer_context(str)
      lexer_ctxt = LexerContext.new(create_content(str))

      class << lexer_ctxt
        attr_accessor :last_symbol
      end

      lexer_ctxt
    end

    def create_content(str)
      StringContent.new(str, @tab_width)
    end

    def tokenize(lexer_ctxt)
      tok_ary = TokenArray.new
      until lexer_ctxt.content.empty?
        next if tokenize_pp_token(lexer_ctxt, tok_ary)

        loc = lexer_ctxt.location
        if new_line = lexer_ctxt.content.scan(/\n/)
          tok_ary.push(Token.new(:NEW_LINE, new_line, loc))
          break
        else
          lexer_ctxt.content.eat!
        end
      end
      tok_ary
    end

    def tokenize_pp_token(lexer_ctxt, tok_ary)
      pp_tok = tokenize_keyword(lexer_ctxt)        ||
               tokenize_constant(lexer_ctxt)       ||
               tokenize_string_literal(lexer_ctxt) ||
               tokenize_null_constant(lexer_ctxt)  ||
               tokenize_identifier(lexer_ctxt)     ||
               tokenize_punctuator(lexer_ctxt)     ||
               tokenize_backslash(lexer_ctxt)

      if pp_tok
        tok_ary.push(pp_tok)
        return true
      end

      false
    end

    def tokenize_keyword(lexer_ctxt)
      loc = lexer_ctxt.location

      keyword = Language::C.scan_keyword(lexer_ctxt.content) ||
                Language::Cpp.scan_keyword(lexer_ctxt.content)

      if keyword
        lexer_ctxt.last_symbol = :KEYWORD
        Token.new(:PP_TOKEN, keyword, loc, Language::C::KEYWORDS[keyword])
      else
        nil
      end
    end

    def tokenize_constant(lexer_ctxt)
      loc = lexer_ctxt.location

      # NOTE: For extended bit-access operators.
      return nil if lexer_ctxt.last_symbol == :IDENTIFIER

      constant = Language::C.scan_char_constant(lexer_ctxt.content)     ||
                 Language::C.scan_floating_constant(lexer_ctxt.content) ||
                 Language::C.scan_integer_constant(lexer_ctxt.content)

      if constant
        lexer_ctxt.last_symbol = :CONSTANT
        return Token.new(:PP_TOKEN, constant, loc, :CONSTANT)
      end

      nil
    end

    def tokenize_string_literal(lexer_ctxt)
      loc = lexer_ctxt.location

      string_literal = Language::C.scan_string_literal(lexer_ctxt.content)

      if string_literal
        lexer_ctxt.last_symbol = :STRING_LITERAL
        return Token.new(:PP_TOKEN, string_literal, loc, :STRING_LITERAL)
      end

      nil
    end

    def tokenize_null_constant(lexer_ctxt)
      loc = lexer_ctxt.location

      null_constant = Language::C.scan_null_constant(lexer_ctxt.content)

      if null_constant
        lexer_ctxt.last_symbol = :NULL
        return Token.new(:PP_TOKEN, null_constant, loc, :NULL)
      end

      nil
    end

    def tokenize_identifier(lexer_ctxt)
      loc = lexer_ctxt.location

      identifier = Language::C.scan_identifier(lexer_ctxt.content)

      if identifier
        lexer_ctxt.last_symbol = :IDENTIFIER
        return Token.new(:PP_TOKEN, identifier, loc, :IDENTIFIER)
      end

      nil
    end

    def tokenize_punctuator(lexer_ctxt)
      loc = lexer_ctxt.location

      punctuator = Language::Cpp.scan_punctuator(lexer_ctxt.content)

      if punctuator
        lexer_ctxt.last_symbol = :PUNCTUATOR
        return Token.new(:PP_TOKEN, punctuator, loc, punctuator)
      end

      nil
    end

    def tokenize_backslash(lexer_ctxt)
      loc = lexer_ctxt.location

      backslash = lexer_ctxt.content.scan(/\\/)

      if backslash
        lexer_ctxt.last_symbol = :BACKSLASH
        return Token.new(:PP_TOKEN, backslash, loc, backslash)
      end

      nil
    end
  end

  class TextLineToPPTokensLexer < StringToPPTokensLexer
    def initialize(text_line, tab_width)
      super(text_line.token.value, tab_width)
      @text_line = text_line
    end

    private
    def create_content(str)
      StringContent.new(str, @tab_width, *@text_line.location.to_a)
    end
  end

end
end
