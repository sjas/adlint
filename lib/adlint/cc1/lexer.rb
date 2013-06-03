# Lexical analyzer which retokenizes pp-tokens into c-tokens.
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
require "adlint/util"
require "adlint/cc1/scanner"
require "adlint/cc1/scope"

module AdLint #:nodoc:
module Cc1 #:nodoc:

  class Lexer < TokensRelexer
    def initialize(pp_src)
      super(pp_src.pp_tokens)
      @lst_tok = nil
      @nxt_tok = nil
      @typedef_names = ScopedNameSet.new
      @object_names  = ScopedNameSet.new
      @identifier_translation = true
    end

    extend Pluggable

    def_plugin :on_string_literals_concatenated

    def add_typedef_name(tok)
      @typedef_names.add(tok.value)
    end

    def add_object_name(tok)
      @object_names.add(tok.value)
    end

    def enter_scope
      @typedef_names.enter_scope
      @object_names.enter_scope
    end

    def leave_scope
      @typedef_names.leave_scope
      @object_names.leave_scope
    end

    def enable_identifier_translation
      @identifier_translation = true
    end

    def disable_identifier_translation
      @identifier_translation = false
    end

    private
    def create_lexer_context(tok_ary)
      LexerContext.new(TokensContent.new(tok_ary))
    end

    def tokenize(lexer_ctxt)
      if @nxt_tok
        tok = @nxt_tok
        @nxt_tok = nil
      else
        until lexer_ctxt.content.empty?
          pp_tok = lexer_ctxt.content.next_token

          if type_hint = pp_tok.type_hint
            tok = pp_tok.class.new(type_hint, pp_tok.value, pp_tok.location)
          else
            tok = retokenize_keyword(pp_tok, lexer_ctxt)        ||
                  retokenize_constant(pp_tok, lexer_ctxt)       ||
                  retokenize_string_literal(pp_tok, lexer_ctxt) ||
                  retokenize_null_constant(pp_tok, lexer_ctxt)  ||
                  retokenize_identifier(pp_tok, lexer_ctxt)     ||
                  retokenize_punctuator(pp_tok, lexer_ctxt)
          end

          break if tok
        end
      end

      if tok
        case tok.type
        when :IDENTIFIER
          tok = translate_identifier(tok, lexer_ctxt)
        when :STRING_LITERAL
          tok = concat_contiguous_string_literals(tok, lexer_ctxt)
        end
        @lst_tok = tok
      else
        nil
      end
    end

    def translate_identifier(tok, lexer_ctxt)
      # NOTE: To translate given IDENTIFIER into TYPEDEF_NAME if needed.

      # NOTE: The ISO C99 standard says;
      #
      # 6.2.3 Name spaces of identifiers
      #
      # 1 If more than one declaration of a particular identifier is visible at
      #   any point in a translation unit, the syntactic context disambiguates
      #   uses that refer to different entities.  Thus, there are separate name
      #   spaces for various categories of identifiers, as follows:
      #   -- label names (disambiguated by the syntax of the label declaration
      #      and use);
      #   -- the tags of structures, unions, and enumerations (disambiguated by
      #      following any of the keywords struct, union, or enum);
      #   -- the members of structures or unions; each structure or union has a
      #      separate name space for its members (disambiguated by the type of
      #      the expression used to access the member via the . or ->
      #      operator);
      #   -- all other identifiers, called ordinary identifiers (declared in
      #      ordinary declarators or as enumeration constants).

      if @identifier_translation
        if tok.type == :IDENTIFIER
          return tok if @object_names.include?(tok.value)
          if @typedef_names.include?(tok.value)
            unless @lst_tok and
                @lst_tok.type == :STRUCT || @lst_tok.type == :UNION ||
                @lst_tok.type == :ENUM ||
                @lst_tok.type == "->" || @lst_tok.type == "."
              tok = tok.class.new(:TYPEDEF_NAME, tok.value, tok.location)
            end
          end
        end
      end
      tok
    end

    def concat_contiguous_string_literals(tok, lexer_ctxt)
      until lexer_ctxt.content.empty?
        nxt_tok = tokenize(lexer_ctxt)
        if nxt_tok.type == :STRING_LITERAL
          rslt_tok = tok.class.new(tok.type, tok.value.sub(/"\z/, "") +
                                   nxt_tok.value.sub(/\AL?"/, ""),
                                   tok.location)
          notify_string_literals_concatenated(tok, nxt_tok, rslt_tok)
          return rslt_tok
        else
          @nxt_tok = nxt_tok
          break
        end
      end
      tok
    end

    def retokenize_keyword(pp_tok, lexer_ctxt)
      if keyword = Scanner::KEYWORDS[pp_tok.value]
        pp_tok.class.new(keyword, pp_tok.value, pp_tok.location)
      else
        nil
      end
    end

    def retokenize_constant(pp_tok, lexer_ctxt)
      # NOTE: For extended bit-access operators.
      return nil if @lst_tok && @lst_tok.type == :IDENTIFIER

      case pp_tok.value
      when /\AL?'.*'\z/,
           /\A(?:[0-9]*\.[0-9]+|[0-9]+\.)[FL]*\z/i,
           /\A(?:[0-9]*\.[0-9]*E[+-]?[0-9]+|[0-9]+\.?E[+-]?[0-9]+)[FL]*\z/i,
           /\A(?:0x[0-9a-f]+|0b[01]+|[0-9]+)[UL]*\z/i
        pp_tok.class.new(:CONSTANT, pp_tok.value, pp_tok.location)
      else
        nil
      end
    end

    def retokenize_string_literal(pp_tok, lexer_ctxt)
      if pp_tok.value =~ /\AL?".*"\z/
        pp_tok.class.new(:STRING_LITERAL, pp_tok.value, pp_tok.location)
      else
        nil
      end
    end

    def retokenize_null_constant(pp_tok, lexer_ctxt)
      if pp_tok.value == "NULL"
        pp_tok.class.new(:NULL, pp_tok.value, pp_tok.location)
      else
        nil
      end
    end

    def retokenize_identifier(pp_tok, lexer_ctxt)
      if pp_tok.value =~ /\A[a-z_][a-z_0-9]*\z/i
        pp_tok.class.new(:IDENTIFIER, pp_tok.value, pp_tok.location)
      else
        nil
      end
    end

    def retokenize_punctuator(pp_tok, lexer_ctxt)
      case pp_tok.value
      when "{", "}", "(", ")", "[", "]", ";", ",", "::", ":", "?", "||",
           "|=", "|", "&&", "&=", "&", "^=", "^", "==", "=", "!=", "!",
           "<<=", "<=", "<<", "<", ">>=", ">=", ">>", ">", "+=", "++", "+",
           "->*", "->", "-=", "--", "-", "*=", "*", "/=", "/", "%=", "%",
           "...", ".*", ".", "~"
        pp_tok.class.new(pp_tok.value, pp_tok.value, pp_tok.location)
      else
        nil
      end
    end

    def notify_string_literals_concatenated(former, latter, rslt_tok)
      on_string_literals_concatenated.invoke(former, latter, rslt_tok)
    end
  end

  class ScopedNameSet
    def initialize
      @name_stack  = [Set.new]
      @scope_stack = [GlobalScope.new]
    end

    def enter_scope
      @name_stack.push(Set.new)
      @scope_stack.push(Scope.new(@scope_stack.size))
    end

    def leave_scope
      @name_stack.pop
      @scope_stack.pop
    end

    def add(name)
      @name_stack.last.add(name)
    end

    def include?(name)
      @name_stack.any? { |set| set.include?(name) }
    end
  end

end
end
