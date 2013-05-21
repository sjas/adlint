# C preprocessor.
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

require "adlint/error"
require "adlint/source"
require "adlint/report"
require "adlint/util"
require "adlint/cpp/syntax"
require "adlint/cpp/source"
require "adlint/cpp/macro"
require "adlint/cpp/lexer"
require "adlint/cpp/constexpr"

module AdLint #:nodoc:
module Cpp #:nodoc:

  # == DESCRIPTION
  # C preprocessor language evaluator.
  #
  # Preprocessor executes recursive descent parsing and evaluation at a time.
  class Preprocessor
    include ReportUtil
    include LogUtil

    def execute(pp_ctxt, src)
      @pp_ctxt = pp_ctxt
      @pp_ctxt.push_lexer(create_lexer(@pp_ctxt, src))
      preprocessing_file(@pp_ctxt)
    end

    extend Pluggable

    def_plugin :on_user_header_included
    def_plugin :on_system_header_included
    def_plugin :on_object_like_macro_defined
    def_plugin :on_function_like_macro_defined
    def_plugin :on_va_function_like_macro_defined
    def_plugin :on_macro_undefined
    def_plugin :on_asm_section_evaled
    def_plugin :on_unknown_pragma_evaled
    def_plugin :on_pp_token_extracted
    def_plugin :on_block_comment_found
    def_plugin :on_line_comment_found
    def_plugin :on_nested_block_comment_found
    def_plugin :on_eof_newline_not_found
    def_plugin :on_unlexable_char_found
    def_plugin :on_cr_at_eol_found
    def_plugin :on_eof_mark_at_eof_found
    def_plugin :on_illformed_newline_escape_found
    def_plugin :on_illformed_defined_op_found
    def_plugin :on_undefined_macro_referred
    def_plugin :on_extra_tokens_found

    private
    def preprocessing_file(pp_ctxt)
      PreprocessingFile.new(pp_ctxt.tunit_root_fpath, group(pp_ctxt))
    end

    def group(pp_ctxt)
      if group_part = group_part(pp_ctxt)
        group = Group.new.push(group_part)
        while group_part = group_part(pp_ctxt)
          group.push(group_part)
        end
        return group
      end
      nil
    end

    def group_part(pp_ctxt)
      if top_tok = pp_ctxt.top_token
        case top_tok.type
        when :IF, :IFDEF, :IFNDEF
          return if_section(pp_ctxt)
        when :INCLUDE, :INCLUDE_NEXT, :DEFINE, :UNDEF, :LINE, :ERROR, :PRAGMA
          return control_line(pp_ctxt)
        when :ASM
          return asm_section(pp_ctxt)
        when :NULL_DIRECTIVE
          return NullDirective.new(pp_ctxt.next_token)
        when :UNKNOWN_DIRECTIVE
          return UnknownDirective.new(pp_ctxt.next_token)
        when :TEXT_LINE
          text_line = TextLine.new(pp_ctxt.next_token)
          toks = TextLineNormalizer.normalize(text_line, pp_ctxt)
          if toks
            pp_ctxt.deferred_text_lines.clear
            toks.each do |tok|
              pp_ctxt.source.add_token(tok)
              notify_pp_token_extracted(tok)
            end
          else
            pp_ctxt.deferred_text_lines.push(text_line)
          end
          return text_line
        end
      end
      nil
    end

    def if_section(pp_ctxt)
      pp_ctxt.push_branch
      if_group = if_group(pp_ctxt)

      while top_tok = pp_ctxt.top_token
        case top_tok.type
        when :ELIF
          elif_groups = elif_groups(pp_ctxt)
        when :ELSE
          else_group = else_group(pp_ctxt)
        when :ENDIF
          endif_line = endif_line(pp_ctxt)
          break
        end
      end

      E(:E0004, if_group.location) unless endif_line

      pp_ctxt.pop_branch
      IfSection.new(if_group, elif_groups, else_group, endif_line)
    end

    def if_group(pp_ctxt)
      if keyword = pp_ctxt.top_token
        case keyword.type
        when :IF
          return if_statement(pp_ctxt)
        when :IFDEF
          return ifdef_statement(pp_ctxt)
        when :IFNDEF
          return ifndef_statement(pp_ctxt)
        end
      end
      nil
    end

    def if_statement(pp_ctxt)
      keyword = pp_ctxt.next_token
      unless pp_toks = pp_tokens(pp_ctxt)
        return nil
      end
      discard_extra_tokens_until_newline(pp_ctxt)
      expr = ExpressionNormalizer.normalize(pp_toks, pp_ctxt, self)
      if expr.value == 0
        pp_ctxt.skip_group
      else
        group = group(pp_ctxt)
        pp_ctxt.branch_evaluated = true
      end
      IfStatement.new(keyword, expr, group)
    end

    def ifdef_statement(pp_ctxt)
      keyword = pp_ctxt.next_token
      unless id = pp_ctxt.next_token and id.type == :IDENTIFIER
        return nil
      end
      discard_extra_tokens_until_newline(pp_ctxt)
      if macro_defined?(pp_ctxt, id)
        group = group(pp_ctxt)
        pp_ctxt.branch_evaluated = true
      else
        pp_ctxt.skip_group
      end
      IfdefStatement.new(keyword, id, group)
    end

    def ifndef_statement(pp_ctxt)
      keyword = pp_ctxt.next_token
      unless id = pp_ctxt.next_token and id.type == :IDENTIFIER
        return nil
      end
      discard_extra_tokens_until_newline(pp_ctxt)
      if macro_defined?(pp_ctxt, id)
        pp_ctxt.skip_group
      else
        group = group(pp_ctxt)
        pp_ctxt.branch_evaluated = true
      end
      IfndefStatement.new(keyword, id, group)
    end

    def elif_groups(pp_ctxt)
      if elif_group = elif_group(pp_ctxt)
        elif_groups = ElifGroups.new.push(elif_group)
        while elif_group = elif_group(pp_ctxt)
          elif_groups.push(elif_group)
        end
        return elif_groups
      end
      nil
    end

    def elif_group(pp_ctxt)
      unless top_tok = pp_ctxt.top_token and top_tok.type == :ELIF
        return nil
      end

      if keyword = pp_ctxt.next_token
        if keyword.type == :ELIF
          unless pp_toks = pp_tokens(pp_ctxt)
            return nil
          end
          discard_extra_tokens_until_newline(pp_ctxt)
          expr = ExpressionNormalizer.normalize(pp_toks, pp_ctxt, self)
          if pp_ctxt.branch_evaluated? || expr.value == 0
            pp_ctxt.skip_group
          else
            group = group(pp_ctxt)
            pp_ctxt.branch_evaluated = true
          end
          return ElifStatement.new(keyword, expr, group)
        end
      end
      nil
    end

    def else_group(pp_ctxt)
      if keyword = pp_ctxt.next_token
        if keyword.type == :ELSE
          discard_extra_tokens_until_newline(pp_ctxt)
          if pp_ctxt.branch_evaluated?
            pp_ctxt.skip_group
          else
            group = group(pp_ctxt)
            pp_ctxt.branch_evaluated = true
          end
          return ElseStatement.new(keyword, group)
        end
      end
      nil
    end

    def endif_line(pp_ctxt)
      if keyword = pp_ctxt.next_token
        if keyword.type == :ENDIF
          discard_extra_tokens_until_newline(pp_ctxt)
          return EndifLine.new(keyword)
        end
      end
      nil
    end

    def control_line(pp_ctxt)
      if keyword = pp_ctxt.top_token
        case keyword.type
        when :INCLUDE
          return include_line(pp_ctxt)
        when :INCLUDE_NEXT
          return include_next_line(pp_ctxt)
        when :DEFINE
          return define_line(pp_ctxt)
        when :UNDEF
          return undef_line(pp_ctxt)
        when :LINE
          return line_line(pp_ctxt)
        when :ERROR
          return error_line(pp_ctxt)
        when :PRAGMA
          return pragma_line(pp_ctxt)
        end
      end
      nil
    end

    def include_line(pp_ctxt)
      keyword = pp_ctxt.next_token
      if header_name = pp_ctxt.top_token
        case header_name.type
        when :USR_HEADER_NAME
          return user_include_line(pp_ctxt, keyword)
        when :SYS_HEADER_NAME
          return system_include_line(pp_ctxt, keyword)
        else
          return macro_include_line(pp_ctxt, keyword)
        end
      end
      nil
    end

    def include_next_line(pp_ctxt)
      keyword = pp_ctxt.next_token
      if header_name = pp_ctxt.top_token
        case header_name.type
        when :USR_HEADER_NAME
          return user_include_next_line(pp_ctxt, keyword)
        when :SYS_HEADER_NAME
          return system_include_next_line(pp_ctxt, keyword)
        else
          return macro_include_next_line(pp_ctxt, keyword)
        end
      end
      nil
    end

    def user_include_line(pp_ctxt, keyword)
      header_name = pp_ctxt.next_token
      discard_extra_tokens_until_newline(pp_ctxt)
      usr_include_line =
        UserIncludeLine.new(keyword, header_name, pp_ctxt.include_depth)
      include_first_user_header(usr_include_line, pp_ctxt)
      usr_include_line
    end

    def user_include_next_line(pp_ctxt, keyword)
      header_name = pp_ctxt.next_token
      discard_extra_tokens_until_newline(pp_ctxt)
      usr_include_next_line =
        UserIncludeNextLine.new(keyword, header_name, pp_ctxt.include_depth)
      include_next_user_header(usr_include_next_line, pp_ctxt)
      usr_include_next_line
    end

    def system_include_line(pp_ctxt, keyword)
      header_name = pp_ctxt.next_token
      discard_extra_tokens_until_newline(pp_ctxt)
      sys_include_line =
        SystemIncludeLine.new(keyword, header_name, pp_ctxt.include_depth)
      include_first_system_header(sys_include_line, pp_ctxt)
      sys_include_line
    end

    def system_include_next_line(pp_ctxt, keyword)
      header_name = pp_ctxt.next_token
      discard_extra_tokens_until_newline(pp_ctxt)
      sys_include_next_line =
        SystemIncludeNextLine.new(keyword, header_name, pp_ctxt.include_depth)
      include_next_system_header(sys_include_next_line, pp_ctxt)
      sys_include_next_line
    end

    def macro_include_line(pp_ctxt, keyword)
      unless pp_toks = pp_tokens(pp_ctxt)
        return nil
      end
      discard_extra_tokens_until_newline(pp_ctxt)
      PPTokensNormalizer.normalize(pp_toks, pp_ctxt)
      unless pp_toks.tokens.empty?
        case param = pp_toks.tokens.map { |tok| tok.value }.join
        when /\A".*"\z/
          usr_include_line = UserIncludeLine.new(
            keyword, Token.new(:USR_HEADER_NAME, param,
                               pp_toks.tokens.first.location),
            pp_ctxt.include_depth)
          include_first_user_header(usr_include_line, pp_ctxt)
          return usr_include_line
        when /\A<.*>\z/
          sys_include_line = SystemIncludeLine.new(
            keyword, Token.new(:SYS_HEADER_NAME, param,
                               pp_toks.tokens.first.location),
            pp_ctxt.include_depth)
          include_first_system_header(sys_include_line, pp_ctxt)
          return sys_include_line
        end
      end
      E(:E0017, keyword.location)
      raise IllformedIncludeDirectiveError.new(
        keyword.location, pp_ctxt.msg_fpath, pp_ctxt.log_fpath)
    end

    def macro_include_next_line(pp_ctxt, keyword)
      unless pp_toks = pp_tokens(pp_ctxt)
        return nil
      end
      discard_extra_tokens_until_newline(pp_ctxt)
      PPTokensNormalizer.normalize(pp_toks, pp_ctxt)
      return nil if pp_toks.tokens.empty?
      case param = pp_toks.tokens.map { |tok| tok.value }.join
      when /\A".*"\z/
        usr_include_next_line = UserIncludeNextLine.new(
          keyword, Token.new(:USR_HEADER_NAME, param,
                             pp_toks.tokens.first.location),
          pp_ctxt.include_depth)
        include_next_user_header(usr_include_next_line, pp_ctxt)
        return usr_include_next_line
      when /\A<.*>\z/
        sys_include_next_line = SystemIncludeNextLine.new(
          keyword, Token.new(:SYS_HEADER_NAME, param,
                             pp_toks.tokens.first.location),
          pp_ctxt.include_depth)
        include_next_system_header(sys_include_next_line, pp_ctxt)
        return sys_include_next_line
      end
      nil
    end

    def define_line(pp_ctxt)
      keyword = pp_ctxt.next_token
      unless id = pp_ctxt.next_token and id.type == :IDENTIFIER
        return nil
      end
      sym = pp_ctxt.symbol_table.create_new_symbol(MacroName, id)

      if paren = pp_ctxt.top_token and paren.type == "("
        pp_ctxt.next_token
        id_list = identifier_list(pp_ctxt)
        unless paren_or_ellipsis = pp_ctxt.next_token
          return nil
        end
        case paren_or_ellipsis.type
        when "..."
          ellipsis = paren_or_ellipsis
          if paren = pp_ctxt.top_token and paren.type == ")"
            pp_ctxt.next_token
          else
            return nil
          end
        when ")"
          ellipsis = nil
        else
          return nil
        end
        repl_list = replacement_list(pp_ctxt)
        discard_extra_tokens_until_newline(pp_ctxt)
        if ellipsis
          define_line = VaFunctionLikeDefineLine.new(keyword, id, id_list,
                                                     repl_list, sym)
          macro = FunctionLikeMacro.new(define_line)
          notify_va_function_like_macro_defined(define_line, macro)
        else
          define_line = FunctionLikeDefineLine.new(keyword, id, id_list,
                                                   repl_list, sym)
          macro = FunctionLikeMacro.new(define_line)
          notify_function_like_macro_defined(define_line, macro)
        end
      else
        repl_list = replacement_list(pp_ctxt)
        discard_extra_tokens_until_newline(pp_ctxt)
        define_line = ObjectLikeDefineLine.new(keyword, id, repl_list, sym)
        macro = ObjectLikeMacro.new(define_line)
        notify_object_like_macro_defined(define_line, macro)
      end

      pp_ctxt.macro_table.define(macro)
      define_line
    end

    def undef_line(pp_ctxt)
      keyword = pp_ctxt.next_token
      unless id = pp_ctxt.next_token and id.type == :IDENTIFIER
        return nil
      end
      discard_extra_tokens_until_newline(pp_ctxt)

      undef_line = UndefLine.new(keyword, id)
      macro = pp_ctxt.macro_table.lookup(id.value)
      # NOTE: Undefining macro may be nil if not defined.
      notify_macro_undefined(undef_line, macro)

      pp_ctxt.macro_table.undef(id.value)
      undef_line
    end

    def line_line(pp_ctxt)
      keyword = pp_ctxt.next_token
      pp_toks = pp_tokens(pp_ctxt)
      discard_extra_tokens_until_newline(pp_ctxt)

      # NOTE: The ISO C99 standard says;
      #
      # 6.10.4 Line control
      #
      # Semantics
      #
      # 5 A preprocessing directive of the form
      #    # line pp-tokens new-line
      #   that does not match one of the two previous forms is permitted.  The
      #   preprocessing tokens after line on the directive are processed just
      #   as in normal text (each identifier currently defined as a macro name
      #   is replaced by its replacement list of preprocessing tokens).  The
      #   directive resulting after all replacements shall match one of the two
      #   previous forms and is then processed as appropriate.
      PPTokensNormalizer.normalize(pp_toks, pp_ctxt) if pp_toks

      LineLine.new(keyword, pp_toks)
    end

    def error_line(pp_ctxt)
      keyword = pp_ctxt.next_token
      pp_toks = pp_tokens(pp_ctxt)
      discard_extra_tokens_until_newline(pp_ctxt)
      ErrorLine.new(keyword, pp_toks)
    end

    def pragma_line(pp_ctxt)
      keyword = pp_ctxt.next_token
      pp_toks = pp_tokens(pp_ctxt)
      discard_extra_tokens_until_newline(pp_ctxt)
      pragma_line = PragmaLine.new(keyword, pp_toks)
      if pp_toks and
          pp_toks.tokens.size == 1 && pp_toks.tokens.first.value == "once"
        pp_ctxt.once_set.add(keyword.location.fpath)
      else
        notify_unknown_pragma_evaled(pragma_line)
      end
      pragma_line
    end

    def identifier_list(pp_ctxt)
      unless id = pp_ctxt.top_token and id.type == :IDENTIFIER
        return nil
      end
      id_list = IdentifierList.new
      while tok = pp_ctxt.next_token
        if tok.type == :IDENTIFIER
          id_list.push(tok)
        end
        if comma = pp_ctxt.top_token and comma.type == ","
          pp_ctxt.next_token
        else
          break
        end
        unless id = pp_ctxt.top_token and id.type == :IDENTIFIER
          break
        end
      end
      id_list
    end

    def replacement_list(pp_ctxt)
      pp_tokens(pp_ctxt)
    end

    def pp_tokens(pp_ctxt)
      unless pp_tok = pp_ctxt.top_token and pp_tok.type == :PP_TOKEN
        return nil
      end
      pp_toks = PPTokens.new
      while tok = pp_ctxt.top_token
        if tok.type == :PP_TOKEN
          pp_toks.push(pp_ctxt.next_token)
        else
          break
        end
      end
      pp_toks
    end

    def asm_section(pp_ctxt)
      asm_line = asm_line(pp_ctxt)
      pp_ctxt.skip_group
      endasm_line = endasm_line(pp_ctxt)
      asm_section = AsmSection.new(asm_line, endasm_line)
      notify_asm_section_evaled(asm_section)
      asm_section
    end

    def asm_line(pp_ctxt)
      if keyword = pp_ctxt.next_token
        if keyword.type == :ASM
          discard_extra_tokens_until_newline(pp_ctxt)
          return AsmLine.new(keyword)
        end
      end
      nil
    end

    def endasm_line(pp_ctxt)
      if keyword = pp_ctxt.next_token
        if keyword.type == :ENDASM
          discard_extra_tokens_until_newline(pp_ctxt)
          return EndasmLine.new(keyword)
        end
      end
      nil
    end

    def include_first_user_header(include_line, pp_ctxt)
      basename = include_line.header_name.value.sub(/\A"(.*)"\z/, "\\1")
      cur_dpath = include_line.location.fpath.dirname
      if fpath = resolve_first_user_header(basename, cur_dpath, pp_ctxt)
        include_user_header(fpath, include_line, pp_ctxt)
      else
        E(:E0010, include_line.location, basename)
        raise MissingUserHeaderError.new(include_line.location, basename,
                                         pp_ctxt.msg_fpath, pp_ctxt.log_fpath)
      end
    end

    def include_next_user_header(include_line, pp_ctxt)
      basename = include_line.header_name.value.sub(/\A"(.*)"\z/, "\\1")
      cur_dpath = include_line.location.fpath.dirname
      if fpath = resolve_next_user_header(basename, cur_dpath, pp_ctxt)
        include_user_header(fpath, include_line, pp_ctxt)
      else
        E(:E0010, include_line.location, basename)
        raise MissingUserHeaderError.new(include_line.location, basename,
                                         pp_ctxt.msg_fpath, pp_ctxt.log_fpath)
      end
    end

    def include_user_header(fpath, include_line, pp_ctxt)
      unless pp_ctxt.once_set.include?(fpath)
        LOG_I("including \"#{fpath}\" at #{include_line.location.to_s}")
        include_line.fpath = fpath
        usr_header =
          UserHeader.new(fpath, pp_ctxt.traits.of_project.file_encoding,
                         include_line.location)
        pp_ctxt.push_lexer(create_lexer(pp_ctxt, usr_header))
        pp_ctxt.sources.push(usr_header)
        notify_user_header_included(include_line, usr_header)
      end
    end

    def include_first_system_header(include_line, pp_ctxt)
      basename = include_line.header_name.value.sub(/\A<(.*)>\z/, "\\1")
      if fpath = resolve_first_system_header(basename, pp_ctxt)
        include_system_header(fpath, include_line, pp_ctxt)
      else
        E(:E0009, include_line.location, basename)
        raise MissingSystemHeaderError.new(include_line.location, basename,
                                           pp_ctxt.msg_fpath,
                                           pp_ctxt.log_fpath)
      end
    end

    def include_next_system_header(include_line, pp_ctxt)
      basename = include_line.header_name.value.sub(/\A<(.*)>\z/, "\\1")
      if fpath = resolve_next_system_header(basename, pp_ctxt)
        include_system_header(fpath, include_line, pp_ctxt)
      else
        E(:E0009, include_line.location, basename)
        raise MissingSystemHeaderError.new(include_line.location, basename,
                                           pp_ctxt.msg_fpath,
                                           pp_ctxt.log_fpath)
      end
    end

    def include_system_header(fpath, include_line, pp_ctxt)
      unless pp_ctxt.once_set.include?(fpath)
        LOG_I("including <#{fpath}> at #{include_line.location.to_s}")
        include_line.fpath = fpath
        # FIXME: The character encoding of system headers may not be same as
        #        one of project's source files.
        sys_header =
          SystemHeader.new(fpath, pp_ctxt.traits.of_project.file_encoding,
                           include_line.location)
        pp_ctxt.push_lexer(create_lexer(pp_ctxt, sys_header))
        pp_ctxt.sources.push(sys_header)
        notify_system_header_included(include_line, sys_header)
      end
    end

    def resolve_first_user_header(basename, cur_dpath, pp_ctxt)
      resolve_user_headers(basename, cur_dpath, 1, pp_ctxt).first
    end

    def resolve_next_user_header(basename, cur_dpath, pp_ctxt)
      resolve_user_headers(basename, cur_dpath, 2, pp_ctxt).last
    end

    def resolve_user_headers(basename, cur_dpath, max_num, pp_ctxt)
      search_paths  = [cur_dpath]
      search_paths += pp_ctxt.traits.of_project.file_search_paths
      search_paths += pp_ctxt.traits.of_compiler.file_search_paths

      base_fpath = Pathname.new(basename)
      if base_fpath.absolute? && base_fpath.readable?
        [base_fpath]
      else
        resolved = []
        search_paths.each do |dpath|
          fpath = dpath.join(base_fpath)
          fpath = Pathname.new(fpath.to_s.gsub(/\\\\|\\/, "/"))
          resolved.push(fpath) if fpath.readable?
          break if resolved.size == max_num
        end
        resolved
      end
    end

    def resolve_first_system_header(basename, pp_ctxt)
      resolve_system_headers(basename, 1, pp_ctxt).first
    end

    def resolve_next_system_header(basename, pp_ctxt)
      resolve_system_headers(basename, 2, pp_ctxt).last
    end

    def resolve_system_headers(basename, max_num, pp_ctxt)
      search_paths  = pp_ctxt.traits.of_project.file_search_paths
      search_paths += pp_ctxt.traits.of_compiler.file_search_paths

      base_fpath = Pathname.new(basename)
      if base_fpath.absolute? && base_fpath.readable?
        [base_fpath]
      else
        resolved = []
        search_paths.each do |dpath|
          fpath = dpath.join(base_fpath)
          fpath = Pathname.new(fpath.to_s.gsub(/\\\\|\\/, "/"))
          resolved.push(fpath) if fpath.readable?
          break if resolved.size == max_num
        end
        resolved
      end
    end

    def macro_defined?(pp_ctxt, id)
      if macro = pp_ctxt.macro_table.lookup(id.value)
        macro.define_line.mark_as_referred_by(id)
        true
      else
        false
      end
    end

    def discard_extra_tokens_until_newline(pp_ctxt)
      extra_toks = []
      while tok = pp_ctxt.next_token
        if tok.type == :NEW_LINE
          break
        else
          extra_toks.push(tok)
        end
      end
      notify_extra_tokens_found(extra_toks) unless extra_toks.empty?
    end

    def create_lexer(pp_ctxt, src)
      Lexer.new(src, pp_ctxt.traits).tap { |lexer| attach_lexer_plugin(lexer) }
    end

    def attach_lexer_plugin(lexer)
      lexer.on_block_comment_found +=
        lambda { |*args| on_block_comment_found.invoke(*args) }
      lexer.on_line_comment_found +=
        lambda { |*args| on_line_comment_found.invoke(*args) }
      lexer.on_nested_block_comment_found +=
        lambda { |*args| on_nested_block_comment_found.invoke(*args) }
      lexer.on_unterminated_block_comment +=
        lambda { |*args| handle_unterminated_block_comment(*args) }
      lexer.on_eof_newline_not_found +=
        lambda { |*args| on_eof_newline_not_found.invoke(*args) }
      lexer.on_unlexable_char_found +=
        lambda { |*args| on_unlexable_char_found.invoke(*args) }
      lexer.on_cr_at_eol_found +=
        lambda { |*args| on_cr_at_eol_found.invoke(*args) }
      lexer.on_eof_mark_at_eof_found +=
        lambda { |*args| on_eof_mark_at_eof_found.invoke(*args) }
      lexer.on_illformed_newline_escape_found +=
        lambda { |*args| on_illformed_newline_escape_found.invoke(*args) }
    end

    def notify_user_header_included(usr_include_line, usr_header)
      on_user_header_included.invoke(usr_include_line, usr_header)
    end

    def notify_system_header_included(sys_include_line, sys_header)
      on_system_header_included.invoke(sys_include_line, sys_header)
    end

    def notify_object_like_macro_defined(define_line, macro)
      on_object_like_macro_defined.invoke(define_line, macro)
    end

    def notify_function_like_macro_defined(define_line, macro)
      on_function_like_macro_defined.invoke(define_line, macro)
    end

    def notify_va_function_like_macro_defined(define_line, macro)
      on_va_function_like_macro_defined.invoke(define_line, macro)
    end

    def notify_macro_undefined(undef_line, macro)
      on_macro_undefined.invoke(undef_line, macro)
    end

    def notify_asm_section_evaled(asm_section)
      on_asm_section_evaled.invoke(asm_section)
    end

    def notify_unknown_pragma_evaled(pragma_line)
      on_unknown_pragma_evaled.invoke(pragma_line)
    end

    def notify_pp_token_extracted(pp_tok)
      on_pp_token_extracted.invoke(pp_tok)
    end

    def notify_illformed_defined_op_found(loc, no_args)
      on_illformed_defined_op_found.invoke(loc, no_args)
    end

    def notify_undefined_macro_referred(id)
      on_undefined_macro_referred.invoke(id)
    end

    def notify_extra_tokens_found(extra_toks)
      on_extra_tokens_found.invoke(extra_toks)
    end

    def handle_unterminated_block_comment(loc)
      E(:E0016, loc)
      raise UnterminatedCommentError.new(loc, @pp_ctxt.msg_fpath,
                                         @pp_ctxt.log_fpath)
    end

    extend Forwardable

    def_delegator :@pp_ctxt, :report
    private :report

    def_delegator :@pp_ctxt, :message_catalog
    private :message_catalog

    def_delegator :@pp_ctxt, :logger
    private :logger
  end

  class PreprocessContext
    def initialize(phase_ctxt)
      @phase_ctxt          = phase_ctxt
      @deferred_text_lines = []
      @lexer_stack         = []
      @branch_stack        = []
      @once_set            = Set.new
    end

    attr_reader :deferred_text_lines
    attr_reader :once_set

    extend Forwardable

    def_delegator :@phase_ctxt, :traits
    def_delegator :@phase_ctxt, :message_catalog
    def_delegator :@phase_ctxt, :report
    def_delegator :@phase_ctxt, :logger
    def_delegator :@phase_ctxt, :msg_fpath
    def_delegator :@phase_ctxt, :log_fpath

    def tunit_root_fpath
      @phase_ctxt[:sources].first.fpath
    end

    def source
      @phase_ctxt[:cc1_source]
    end

    def sources
      @phase_ctxt[:sources]
    end

    def symbol_table
      @phase_ctxt[:symbol_table]
    end

    def macro_table
      @phase_ctxt[:cpp_macro_table]
    end

    def push_lexer(lexer)
      @lexer_stack.push(lexer)
    end

    def top_token
      unless @lexer_stack.empty?
        unless tok = @lexer_stack.last.top_token
          @lexer_stack.pop
          top_token
        else
          tok
        end
      else
        nil
      end
    end

    def next_token
      return nil unless top_token
      @last_token = @lexer_stack.last.next_token
    end

    def skip_group
      until @lexer_stack.last.skip_group
        @lexer_stack.pop
        break if @lexer_stack.empty?
      end
    end

    def push_branch
      @branch_stack.push(false)
    end

    def pop_branch
      @branch_stack.pop
    end

    def branch_evaluated=(evaluated)
      @branch_stack[-1] = evaluated
    end

    def branch_evaluated?
      @branch_stack.last
    end

    def include_depth
      @lexer_stack.size
    end
  end

  module PPTokensNormalizer
    def normalize(pp_toks, pp_ctxt)
      pp_ctxt.macro_table.replace(pp_toks.tokens)
      pp_toks
    end
    module_function :normalize
  end

  module ExpressionNormalizer
    def normalize(pp_toks, pp_ctxt, preprocessor = nil)
      PPTokensNormalizer.normalize(pp_toks, pp_ctxt)
      const_expr = ConstantExpression.new(pp_ctxt, pp_toks.tokens)
      if preprocessor
        const_expr.on_illformed_defined_op_found +=
          preprocessor.method(:notify_illformed_defined_op_found)
        const_expr.on_undefined_macro_referred +=
          preprocessor.method(:notify_undefined_macro_referred)
      end
      const_expr.evaluate
    end
    module_function :normalize
  end

  module TextLineNormalizer
    def normalize(text_line, pp_ctxt)
      tab_width = pp_ctxt.traits.of_project.coding_style.tab_width
      pp_toks = []
      unless pp_ctxt.deferred_text_lines.empty?
        pp_ctxt.deferred_text_lines.each do |deferred_line|
          lexer = TextLineToPPTokensLexer.new(deferred_line, tab_width)
          pp_toks += lexer.execute.to_a
        end
      end

      lexer = TextLineToPPTokensLexer.new(text_line, tab_width)
      pp_toks += lexer.execute.to_a

      fun_like_macro_referred = pp_toks.any? { |tok|
        (macro = pp_ctxt.macro_table.lookup(tok.value)) ?
          macro.function_like? : false
      }

      if fun_like_macro_referred
        return nil unless complete_macro_reference?(pp_toks, pp_ctxt)
      end

      pp_ctxt.macro_table.replace(pp_toks)
      pp_toks
    end
    module_function :normalize

    def complete_macro_reference?(pp_toks, pp_ctxt)
      idx = 0
      while tok = pp_toks[idx]
        idx += 1
        macro = pp_ctxt.macro_table.lookup(tok.value)
        if macro && macro.function_like?
          next if not_calling_function_like_macro?(pp_toks, idx)
        else
          next
        end

        # NOTE: It's not completed when a new-line appears after the macro
        #       name.
        return false unless pp_toks[idx..-1].any? { |t| t.value == "(" }

        paren_cnt = 0
        while tok = pp_toks[idx]
          case tok.value
          when "("
            paren_cnt += 1
          when ")"
            paren_cnt -= 1
            break if paren_cnt == 0
          end
          idx += 1
        end

        return false if paren_cnt > 0
      end
      true
    end
    module_function :complete_macro_reference?

    def not_calling_function_like_macro?(pp_toks, idx)
      while pp_tok = pp_toks[idx]
        case
        when pp_tok.value == "("
          return false
        when pp_tok.type == :NEW_LINE
          idx += 1
        else
          return true
        end
      end
      false
    end
    module_function :not_calling_function_like_macro?
  end

end
end
