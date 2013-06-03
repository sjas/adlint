# Code checkings (cpp-phase) of adlint-exam-c_builtin package.
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

require "adlint/exam"
require "adlint/report"
require "adlint/traits"
require "adlint/cpp/phase"
require "adlint/cpp/util"

module AdLint #:nodoc:
module Exam #:nodoc:
module CBuiltin #:nodoc:

  class W0001_Cpp < PassiveCodeCheck
    def_registrant_phase Cpp::Prepare2Phase

    # NOTE: W0001 may be duplicative when the same header which has the deeply
    #       grouped expression is included twice or more.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      traversal = phase_ctxt[:cpp_ast_traversal]
      traversal.enter_grouped_expression += T(:enter_grouped_expression)
      traversal.leave_grouped_expression += T(:leave_grouped_expression)
      @group_depth = 0
    end

    private
    def enter_grouped_expression(node)
      @group_depth += 1
      W(node.location) if @group_depth == 32
    end

    def leave_grouped_expression(node)
      @group_depth -= 1
    end
  end

  class W0025 < PassiveCodeCheck
    def_registrant_phase Cpp::Prepare2Phase

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cpp_interpreter]
      interp.on_user_header_included   += T(:check_user_include)
      interp.on_system_header_included += T(:check_system_include)
      @usr_header_fpaths = Set.new
      @sys_header_fpaths = Set.new
    end

    private
    def check_user_include(usr_include_line, usr_header)
      if @usr_header_fpaths.include?(usr_header.fpath)
        W(usr_include_line.location, usr_include_line.fpath)
      else
        if usr_include_line.include_depth == 1
          @usr_header_fpaths.add(usr_header.fpath)
        end
      end
    end

    def check_system_include(sys_include_line, sys_header)
      if @sys_header_fpaths.include?(sys_header.fpath)
        W(sys_include_line.location, sys_include_line.fpath)
      else
        if sys_include_line.include_depth == 1
          @sys_header_fpaths.add(sys_header.fpath)
        end
      end
    end
  end

  class W0026 < PassiveCodeCheck
    def_registrant_phase Cpp::Prepare2Phase

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cpp_interpreter]
      interp.on_user_header_included   += T(:check_user_include)
      interp.on_system_header_included += T(:check_system_include)
      @usr_header_fpaths = Set.new
      @sys_header_fpaths = Set.new
    end

    private
    def check_user_include(usr_include_line, usr_header)
      if @usr_header_fpaths.include?(usr_header.fpath)
        W(usr_include_line.location, usr_include_line.fpath)
      else
        if usr_include_line.include_depth > 1
          @usr_header_fpaths.add(usr_header.fpath)
        end
      end
    end

    def check_system_include(sys_include_line, sys_header)
      if @sys_header_fpaths.include?(sys_header.fpath)
        W(sys_include_line.location, sys_include_line.fpath)
      else
        if sys_include_line.include_depth > 1
          @sys_header_fpaths.add(sys_header.fpath)
        end
      end
    end
  end

  class W0053 < PassiveCodeCheck
    def_registrant_phase Cpp::Prepare2Phase

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cpp_interpreter]
      interp.on_user_header_included += T(:check_user_include)
    end

    private
    def check_user_include(usr_include_line, usr_header)
      if usr_include_line.include_depth == 7
        W(usr_include_line.location, usr_header.fpath)
      end
    end
  end

  class W0054 < PassiveCodeCheck
    def_registrant_phase Cpp::Prepare2Phase

    def initialize(phase_ctxt)
      super
      traversal = phase_ctxt[:cpp_ast_traversal]
      traversal.enter_if_section += T(:enter_if_section)
      traversal.leave_if_section += T(:leave_if_section)
      @if_depth = 0
    end

    private
    def enter_if_section(node)
      @if_depth += 1
      W(node.location) if @if_depth == 9
    end

    def leave_if_section(*)
      @if_depth -= 1
    end
  end

  class W0055 < PassiveCodeCheck
    def_registrant_phase Cpp::Prepare2Phase

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cpp_interpreter]
      interp.on_object_like_macro_defined      += T(:check)
      interp.on_function_like_macro_defined    += T(:check)
      interp.on_va_function_like_macro_defined += T(:check)
      @macro_num = 0
    end

    private
    def check(define_line, *)
      unless in_initial_header?(define_line)
        @macro_num += 1
        W(define_line.location) if @macro_num == 1025
      end
    end

    def in_initial_header?(node)
      node.location.fpath.identical?(pinit_fpath) ||
        node.location.fpath.identical?(cinit_fpath)
    end

    def pinit_fpath
      if fpath = traits.of_project.initial_header
        Pathname.new(fpath)
      else
        nil
      end
    end
    memoize :pinit_fpath

    def cinit_fpath
      if fpath = traits.of_compiler.initial_header
        Pathname.new(fpath)
      else
        nil
      end
    end
    memoize :cinit_fpath
  end

  class W0056 < PassiveCodeCheck
    def_registrant_phase Cpp::Prepare2Phase

    # NOTE: W0056 may be duplicative when the same header which has macro
    #       definition with too many parameters is included twice or more.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cpp_interpreter]
      interp.on_function_like_macro_defined    += T(:check)
      interp.on_va_function_like_macro_defined += T(:check)
    end

    private
    def check(define_line, macro)
      W(define_line.location) if macro.parameter_names.size > 31
    end
  end

  class W0057 < PassiveCodeCheck
    def_registrant_phase Cpp::Prepare2Phase

    # NOTE: W0057 may be duplicative when the same header which has macro call
    #       with too many arguments is included twice or more.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      macro_table = phase_ctxt[:cpp_macro_table]
      macro_table.on_function_like_macro_replacement += T(:check)
    end

    private
    def check(macro, repl_toks, *)
      W(repl_toks.first.location) if macro.parameter_names.size > 31
    end
  end

  class W0059 < PassiveCodeCheck
    def_registrant_phase Cpp::Prepare2Phase

    # NOTE: W0059 may be duplicative when the same header which has carriage
    #       return at end of lines is included twice or more.
    mark_as_unique

    # NOTE: W0059 may be detected before evaluating the annotation for message
    #       suppression.
    mark_as_deferred

    def initialize(phase_ctxt)
      super
      phase_ctxt[:cpp_interpreter].on_cr_at_eol_found += M(:check)
    end

    private
    def check(loc)
      W(loc) if loc.in_analysis_target?(traits)
    end
  end

  class W0060 < PassiveCodeCheck
    def_registrant_phase Cpp::Prepare2Phase

    # NOTE: W0060 may be duplicative when the same header which has the
    #       end-of-file mark is included twice or more.
    mark_as_unique

    # NOTE: W0060 may be detected before evaluating the annotation for message
    #       suppression.
    mark_as_deferred

    def initialize(phase_ctxt)
      super
      phase_ctxt[:cpp_interpreter].on_eof_mark_at_eof_found += M(:check)
    end

    private
    def check(loc)
      W(loc) if loc.in_analysis_target?(traits)
    end
  end

  class W0061 < PassiveCodeCheck
    def_registrant_phase Cpp::Prepare2Phase

    # NOTE: W0061 may be duplicative when the same header which has the token
    #       sequence of the compiler specific extension is included twice or
    #       more.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      phase_ctxt[:cc1_source].on_language_extension += M(:check)
    end

    private
    def check(matched_toks)
      head_loc = matched_toks.first.location
      if head_loc.in_analysis_target?(traits)
        W(head_loc, tokens_to_str(matched_toks))
      end
    end

    def tokens_to_str(toks)
      toks.map { |tok|
        tok.type == :NEW_LINE ? nil : tok.value
      }.compact.join(" ")
    end
  end

  class W0069 < PassiveCodeCheck
    def_registrant_phase Cpp::Prepare2Phase

    # NOTE: W0069 may be duplicative when the same header which has the nested
    #       block comment is included twice or more.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      phase_ctxt[:cpp_interpreter].on_nested_block_comment_found += M(:check)
    end

    private
    def check(loc)
      W(loc) if loc.in_analysis_target?(traits)
    end
  end

  class W0072 < PassiveCodeCheck
    def_registrant_phase Cpp::Prepare2Phase

    # NOTE: W0072 may be duplicative when the same header which has non
    #       basic-source-character in the #include directive is included twice
    #       or more.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      traversal = phase_ctxt[:cpp_ast_traversal]
      traversal.enter_user_include_line   += T(:check_user_include_line)
      traversal.enter_system_include_line += T(:check_system_include_line)
    end

    private
    def check_user_include_line(node)
      unless Cpp::BasicSourceCharacterSet.include?(node.header_name.value)
        W(node.header_name.location)
      end
    end

    def check_system_include_line(node)
      unless Cpp::BasicSourceCharacterSet.include?(node.header_name.value)
        W(node.header_name.location)
      end
    end
  end

  class W0073 < PassiveCodeCheck
    def_registrant_phase Cpp::Prepare2Phase

    # NOTE: W0073 may be duplicative when the same header without the
    #       include-guard is included twice or more.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      traversal = phase_ctxt[:cpp_ast_traversal]
      traversal.enter_user_include_line   += T(:enter_include_line)
      traversal.enter_system_include_line += T(:enter_include_line)
      traversal.enter_text_line           += T(:enter_text_line)
      traversal.enter_if_section          += T(:enter_if_section)
      @main_fpath = phase_ctxt[:sources].first.fpath
      @last_fpath = nil
      @enclosed_by_if_section = false
      @warned_files = Set.new
    end

    private
    def enter_include_line(node)
      unless node.location.fpath == @last_fpath
        @enclosed_by_if_section = false
        @last_fpath = node.location.fpath
      end

      return if in_initial_header?(node) || in_main_file?(node)

      unless @enclosed_by_if_section || in_warned_file?(node)
        W(node.location)
        @warned_files.add(node.location.fpath)
      end
    end

    def enter_text_line(node)
      unless node.location.fpath == @last_fpath
        @enclosed_by_if_section = false
        @last_fpath = node.location.fpath
      end

      if empty_line?(node) || in_initial_header?(node) || in_main_file?(node)
        return
      end

      unless @enclosed_by_if_section || in_warned_file?(node)
        W(node.location)
        @warned_files.add(node.location.fpath)
      end
    end

    def enter_if_section(node)
      @enclosed_by_if_section = true
      @last_fpath = node.location.fpath
    end

    def empty_line?(node)
      node.token.value.chomp.empty?
    end

    def in_main_file?(node)
      node.location.fpath == @main_fpath
    end

    def in_initial_header?(node)
      node.location.fpath.identical?(pinit_fpath) ||
        node.location.fpath.identical?(cinit_fpath)
    end

    def in_warned_file?(node)
      @warned_files.include?(node.location.fpath)
    end

    def pinit_fpath
      if fpath = traits.of_project.initial_header
        Pathname.new(fpath)
      else
        nil
      end
    end
    memoize :pinit_fpath

    def cinit_fpath
      if fpath = traits.of_compiler.initial_header
        Pathname.new(fpath)
      else
        nil
      end
    end
    memoize :cinit_fpath
  end

  class W0442 < PassiveCodeCheck
    def_registrant_phase Cpp::Prepare2Phase

    # NOTE: W0442 may be duplicative when the same header which has
    #       function-like macro definitions is included twice or more.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cpp_interpreter]
      interp.on_function_like_macro_defined    += T(:check)
      interp.on_va_function_like_macro_defined += T(:check)
    end

    private
    def check(define_line, *)
      W(define_line.location)
    end
  end

  class W0443 < PassiveCodeCheck
    def_registrant_phase Cpp::Prepare2Phase

    # NOTE: W0443 may be duplicative when the same header which has
    #       functionizable function-like macro definitions is included twice or
    #       more.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      traversal = phase_ctxt[:cpp_ast_traversal]
      traversal.enter_function_like_define_line    += T(:check)
      traversal.enter_va_function_like_define_line += T(:check)
    end

    private
    def check(node)
      return unless node.identifier_list

      if repl_lsit = node.replacement_list
        should_be_function = repl_lsit.tokens.all? { |pp_tok|
          if keyword_or_punctuator?(pp_tok)
            false
          elsif type_specifier_or_type_qualifier?(pp_tok)
            false
          else
            true
          end
        }
        W(node.location) if should_be_function
      end
    end

    KEYWORDS = [
      "sizeof", "typedef", "extern", "static", "auto", "register", "inline",
      "restrict", "char", "short", "int", "long", "signed", "unsigned",
      "float", "double", "const", "volatile", "void", "_Bool", "_Complex",
      "_Imaginary", "struct", "union", "enum", "case", "default", "if",
      "else", "switch", "while", "do", "for", "goto", "continue", "break",
      "return"
    ].to_set.freeze
    private_constant :KEYWORDS

    def keyword_or_punctuator?(pp_tok)
      pp_tok.value == "#" || pp_tok.value == "##" ||
        pp_tok.value == "{" || pp_tok.value == "}" ||
        pp_tok.value == ";" || KEYWORDS.include?(pp_tok.value)
    end

    def type_specifier_or_type_qualifier?(pp_tok)
      pp_tok.value == "const" || pp_tok.value == "volatile" ||
        pp_tok.value == "restrict" ||
        @phase_ctxt[:cc1_type_table].all_type_names.include?(pp_tok.value)
    end
  end

  class W0444 < PassiveCodeCheck
    def_registrant_phase Cpp::Prepare2Phase

    # NOTE: W0444 may be duplicative when the same header which has the
    #       function-like macro definition with `#' and `##' operators is
    #       included twice or more.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cpp_interpreter]
      interp.on_function_like_macro_defined    += T(:check)
      interp.on_va_function_like_macro_defined += T(:check)
    end

    private
    def check(define_line, macro)
      if repl_list = macro.replacement_list
        sharp_op_num = 0
        sharpsharp_op_num = 0

        repl_list.tokens.each do |pp_tok|
          case pp_tok.value
          when "#"
            sharp_op_num += 1
          when "##"
            sharpsharp_op_num += 1
          end
        end

        W(define_line.location) if sharp_op_num > 0 && sharpsharp_op_num > 0
      end
    end
  end

  class W0445 < PassiveCodeCheck
    def_registrant_phase Cpp::Prepare2Phase

    # NOTE: W0445 may be duplicative when the same header which has the
    #       function-like macro definition with two or more `##' operators is
    #       included twice or more.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cpp_interpreter]
      interp.on_function_like_macro_defined    += T(:check)
      interp.on_va_function_like_macro_defined += T(:check)
    end

    private
    def check(define_line, macro)
      if repl_list = macro.replacement_list
        sharpsharp_op_num = 0

        repl_list.tokens.each do |pp_tok|
          if pp_tok.value == "##"
            sharpsharp_op_num += 1
          end
        end

        W(define_line.location) if sharpsharp_op_num > 1
      end
    end
  end

  class W0477 < PassiveCodeCheck
    def_registrant_phase Cpp::Prepare2Phase

    # NOTE: W0477 may be duplicative when the same header which has the macro
    #       definition with unbalanced grouping tokens is included twice or
    #       more.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cpp_interpreter]
      interp.on_object_like_macro_defined      += T(:check)
      interp.on_function_like_macro_defined    += T(:check)
      interp.on_va_function_like_macro_defined += T(:check)
    end

    private
    def check(define_line, macro)
      if repl_list = macro.replacement_list
        paren_count = 0
        brace_count = 0
        bracket_count = 0
        repl_list.tokens.each do |pp_tok|
          case pp_tok.value
          when "("
            paren_count += 1
          when ")"
            paren_count -= 1
          when "{"
            brace_count += 1
          when "}"
            brace_count -= 1
          when "["
            bracket_count += 1
          when "]"
            bracket_count -= 1
          end
        end

        unless paren_count == 0 && brace_count == 0 && bracket_count == 0
          W(define_line.location)
        end
      end
    end
  end

  class W0478 < PassiveCodeCheck
    def_registrant_phase Cpp::Prepare2Phase

    # NOTE: W0478 may be duplicative when the same header which causes this
    #       warning is included twice or more.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      traversal = phase_ctxt[:cpp_ast_traversal]
      traversal.enter_object_like_define_line      += T(:check)
      traversal.enter_function_like_define_line    += T(:check)
      traversal.enter_va_function_like_define_line += T(:check)
    end

    private
    def check(node)
      if repl_list = node.replacement_list and repl_list.tokens.size > 1
        unless repl_list.may_represent_expression? ||
            repl_list.may_represent_initializer? ||
            repl_list.may_represent_block? ||
            repl_list.may_represent_do_while_zero_idiom? ||
            repl_list.may_represent_specifier_qualifier_list? ||
            repl_list.may_represent_declaration_specifiers_head?
          W(node.location)
        end
      end
    end
  end

  class W0479 < PassiveCodeCheck
    def_registrant_phase Cpp::Prepare2Phase

    # NOTE: W0479 may be duplicative when the same header which has
    #       typedef-able macro definition is included twice or more.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      traversal = phase_ctxt[:cpp_ast_traversal]
      traversal.enter_object_like_define_line += T(:check)
    end

    private
    def check(node)
      if repl_list = node.replacement_list
        if repl_list.may_represent_specifier_qualifier_list?
          W(node.location)
        end
      end
    end
  end

  class W0480 < PassiveCodeCheck
    def_registrant_phase Cpp::Prepare2Phase

    # NOTE: W0480 may be duplicative when the same header which causes this
    #       warning is included twice or more.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      traversal = phase_ctxt[:cpp_ast_traversal]
      traversal.enter_object_like_define_line      += T(:check)
      traversal.enter_function_like_define_line    += T(:check)
      traversal.enter_va_function_like_define_line += T(:check)
    end

    private
    def check(node)
      if repl_list = node.replacement_list and
          repl_list.may_represent_punctuator? ||
          repl_list.may_represent_controlling_keyword?
        W(node.location)
      end
    end
  end

  class W0481 < PassiveCodeCheck
    def_registrant_phase Cpp::Prepare2Phase

    # NOTE: W0481 may be duplicative when the same header which causes this
    #       warning is included twice or more.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      traversal = phase_ctxt[:cpp_ast_traversal]
      traversal.enter_object_like_define_line      += T(:check)
      traversal.enter_function_like_define_line    += T(:check)
      traversal.enter_va_function_like_define_line += T(:check)
    end

    private
    def check(node)
      if repl_list = node.replacement_list and repl_list.may_represent_block?
        W(node.location)
      end
    end
  end

  class W0482 < PassiveCodeCheck
    def_registrant_phase Cpp::Prepare2Phase

    # NOTE: W0482 may be duplicative when the same header which causes this
    #       warning is included twice or more.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      traversal = phase_ctxt[:cpp_ast_traversal]
      traversal.enter_object_like_define_line += T(:check)
    end

    private
    def check(node)
      if repl_list = node.replacement_list
        return unless repl_list.tokens.size == 1
        if type_specifier?(repl_list.tokens.first)
          W(node.location)
        end
      end
    end

    def type_specifier?(pp_tok)
      case pp_tok.value
      when "void", "char", "short", "int", "long", "float", "double"
        true
      when "signed", "unsigned"
        true
      when "struct", "union", "enum"
        true
      else
        false
      end
    end
  end

  class W0483 < PassiveCodeCheck
    def_registrant_phase Cpp::Prepare2Phase

    # NOTE: W0483 may be duplicative when the same header which causes this
    #       warning is included twice or more.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      traversal = phase_ctxt[:cpp_ast_traversal]
      traversal.enter_object_like_define_line += T(:check)
    end

    private
    def check(node)
      if repl_list = node.replacement_list
        if repl_list.may_represent_declaration_specifiers_head?
          W(node.location)
        end
      end
    end
  end

  class W0511 < PassiveCodeCheck
    def_registrant_phase Cpp::Prepare2Phase

    # NOTE: W0511 may be duplicative when the same header which causes this
    #       warning is included twice or more.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      phase_ctxt[:cpp_interpreter].on_line_comment_found += M(:check)
    end

    private
    def check(*, loc)
      W(loc) if loc.in_analysis_target?(traits)
    end
  end

  class W0528 < PassiveCodeCheck
    def_registrant_phase Cpp::Prepare2Phase

    # NOTE: W0528 may be duplicative when the same header which causes this
    #       warning is included twice or more.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cpp_interpreter]
      interp.on_object_like_macro_defined += T(:check)
    end

    private
    def check(*, macro)
      if repl_list = macro.replacement_list
        octal_tok = repl_list.tokens.find { |pp_tok|
          pp_tok.value =~ /\A0[0-9]+[UL]*\z/i
        }
        W(octal_tok.location) if octal_tok
      end
    end
  end

  class W0541 < PassiveCodeCheck
    def_registrant_phase Cpp::Prepare2Phase

    # NOTE: W0541 may be duplicative when the same header which causes this
    #       warning is included twice or more.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      phase_ctxt[:cc1_source].on_inline_assembly += M(:check)
    end

    private
    def check(asm_toks)
      head_loc = asm_toks.first.location
      if head_loc.in_analysis_target?(traits)
        W(head_loc) unless asm_toks.any? { |tok| tok.replaced? }
      end
    end
  end

  class W0549 < PassiveCodeCheck
    def_registrant_phase Cpp::Prepare2Phase

    # NOTE: W0549 may be duplicative when the same header which causes this
    #       warning is included twice or more.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cpp_interpreter]
      interp.on_function_like_macro_defined    += T(:check)
      interp.on_va_function_like_macro_defined += T(:check)
    end

    private
    def check(*, macro)
      return unless macro.replacement_list

      macro.parameter_names.each do |name|
        macro.replacement_list.tokens.each_with_index do |pp_tok, idx|
          next unless pp_tok.value == name

          prv_tok = macro.replacement_list.tokens[[idx - 1, 0].max]
          nxt_tok = macro.replacement_list.tokens[idx + 1]

          next if prv_tok && prv_tok.value =~ /\A##?\z/
          next if nxt_tok && nxt_tok.value == "##"

          unless prv_tok && prv_tok.value == "("
            W(pp_tok.location)
            next
          end

          unless nxt_tok && nxt_tok.value == ")"
            W(pp_tok.location)
            next
          end
        end
      end
    end
  end

  class W0554 < PassiveCodeCheck
    def_registrant_phase Cpp::Prepare2Phase

    # NOTE: W0554 may be duplicative when the same header which causes this
    #       warning is included twice or more.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cpp_interpreter]
      interp.on_unknown_pragma_evaled += T(:check)
    end

    private
    def check(pragma_line)
      W(pragma_line.location,
        pragma_line.pp_tokens ? pragma_line.pp_tokens.to_s : "")
    end
  end

  class W0574 < PassiveCodeCheck
    def_registrant_phase Cpp::Prepare2Phase

    # NOTE: W0574 may be duplicative when the same header which causes this
    #       warning is included twice or more.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cpp_interpreter]
      interp.on_pp_token_extracted             += T(:check_pp_token)
      interp.on_object_like_macro_defined      += T(:check_macro)
      interp.on_function_like_macro_defined    += T(:check_macro)
      interp.on_va_function_like_macro_defined += T(:check_macro)
    end

    private
    def check_pp_token(pp_tok)
      if pp_tok.value =~ /\AL?'(.*)'\z/
        unless Cpp::BasicSourceCharacterSet.include?($1)
          W(pp_tok.location)
        end
      end
    end

    def check_macro(*, macro)
      if repl_lsit = macro.replacement_list
        repl_lsit.tokens.each { |pp_tok| check_pp_token(pp_tok) }
      end
    end
  end

  class W0575 < PassiveCodeCheck
    def_registrant_phase Cpp::Prepare2Phase

    # NOTE: W0575 may be duplicative when the same header which causes this
    #       warning is included twice or more.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cpp_interpreter]
      interp.on_pp_token_extracted             += T(:check_pp_token)
      interp.on_object_like_macro_defined      += T(:check_macro)
      interp.on_function_like_macro_defined    += T(:check_macro)
      interp.on_va_function_like_macro_defined += T(:check_macro)
    end

    private
    def check_pp_token(pp_tok)
      if pp_tok.value =~ /\AL?"(.*)"\z/
        unless Cpp::BasicSourceCharacterSet.include?($1)
          W(pp_tok.location)
        end
      end
    end

    def check_macro(*, macro)
      if repl_list = macro.replacement_list
        repl_list.tokens.each { |pp_tok| check_pp_token(pp_tok) }
      end
    end
  end

  class W0576 < PassiveCodeCheck
    def_registrant_phase Cpp::Prepare2Phase

    # NOTE: W0576 may be duplicative when the same header which causes this
    #       warning is included twice or more.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cpp_interpreter]
      interp.on_block_comment_found += M(:check)
      interp.on_line_comment_found  += M(:check)
      @warned_chars = Set.new
    end

    private
    def check(comment, loc)
      if loc.in_analysis_target?(traits)
        not_adapted = Cpp::BasicSourceCharacterSet.select_not_adapted(comment)
        new_chars = not_adapted.to_set - @warned_chars
        unless new_chars.empty?
          W(loc, loc.fpath)
          @warned_chars.merge(new_chars)
        end
      end
    end
  end

  class W0577 < PassiveCodeCheck
    def_registrant_phase Cpp::Prepare2Phase

    # NOTE: W0577 may be duplicative when the same header which causes this
    #       warning is included twice or more.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cpp_interpreter]
      interp.on_unlexable_char_found += M(:check)
      @warned = false
    end

    private
    def check(*, loc)
      if loc.in_analysis_target?(traits)
        unless @warned
          W(loc, loc.fpath)
          @warned = true
        end
      end
    end
  end

  class W0632 < PassiveCodeCheck
    def_registrant_phase Cpp::Prepare2Phase

    # NOTE: W0632 may be duplicative when the same header which has references
    #       to the undefined macro is included twice or more.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      traversal = phase_ctxt[:cpp_ast_traversal]
      traversal.enter_system_include_line      += T(:check)
      traversal.enter_system_include_next_line += T(:check)
    end

    private
    def check(include_line)
      if include_line.header_name.value =~ /['"]/
        W(include_line.location, include_line.header_name.value)
      end
    end
  end

  class W0633 < PassiveCodeCheck
    def_registrant_phase Cpp::Prepare2Phase

    # NOTE: W0633 may be duplicative when the same header which has references
    #       to the undefined macro is included twice or more.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      traversal = phase_ctxt[:cpp_ast_traversal]
      traversal.enter_user_include_line      += T(:check)
      traversal.enter_user_include_next_line += T(:check)
    end

    private
    def check(include_line)
      if include_line.header_name.value =~ /'/
        W(include_line.location, include_line.header_name.value)
      end
    end
  end

  class W0634 < PassiveCodeCheck
    def_registrant_phase Cpp::Prepare2Phase

    # NOTE: W0634 may be duplicative when the same header which has references
    #       to the undefined macro is included twice or more.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      traversal = phase_ctxt[:cpp_ast_traversal]
      traversal.enter_user_include_line        += T(:check)
      traversal.enter_user_include_next_line   += T(:check)
      traversal.enter_system_include_line      += T(:check)
      traversal.enter_system_include_next_line += T(:check)
    end

    private
    def check(include_line)
      if include_line.header_name.value.include?("\\")
        W(include_line.location)
      end
    end
  end

  class W0643 < PassiveCodeCheck
    def_registrant_phase Cpp::Prepare2Phase

    # NOTE: W0643 may be duplicative when the same header which has references
    #       to the undefined macro is included twice or more.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      macro_table = phase_ctxt[:cpp_macro_table]
      macro_table.on_last_backslash_ignored += T(:check)
    end

    private
    def check(tok)
      W(tok.location)
    end
  end

  class W0691 < PassiveCodeCheck
    def_registrant_phase Cpp::Prepare2Phase

    # NOTE: W0691 may be duplicative when the same header which has references
    #       to the undefined macro is included twice or more.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      macro_table = phase_ctxt[:cpp_macro_table]
      macro_table.on_sharpsharp_operator_evaled += T(:check)
    end

    private
    def check(*, new_toks)
      W(new_toks.first.location) if new_toks.size > 1
    end
  end

  class W0692 < PassiveCodeCheck
    def_registrant_phase Cpp::Prepare2Phase

    # NOTE: W0692 may be duplicative when the same header which has references
    #       to the undefined macro is included twice or more.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      macro_table = phase_ctxt[:cpp_macro_table]
      macro_table.on_function_like_macro_replacement += T(:check)
    end

    private
    def check(macro, repl_toks, args, *)
      unless macro.parameter_names.empty?
        if args.any? { |arg| arg.empty? }
          W(repl_toks.first.location, macro.name.value)
        end
      end
    end
  end

  class W0696 < PassiveCodeCheck
    def_registrant_phase Cpp::Prepare2Phase

    # NOTE: W0696 may be duplicative when the same header which has references
    #       to the undefined macro is included twice or more.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cpp_interpreter]
      interp.on_undefined_macro_referred += T(:check)
    end

    private
    def check(tok)
      W(tok.location, tok.value)
    end
  end

  class W0804 < PassiveCodeCheck
    def_registrant_phase Cpp::Prepare2Phase

    # NOTE: W0804 may be duplicative when the same header which causes this
    #       warning is included twice or more.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      phase_ctxt[:cpp_interpreter].on_illformed_defined_op_found += M(:check)
    end

    private
    def check(loc, *)
      W(loc) if loc.in_analysis_target?(traits)
    end
  end

  class W0805 < W0804
    def_registrant_phase Cpp::Prepare2Phase

    # NOTE: W0805 may be duplicative when the same header which causes this
    #       warning is included twice or more.
    mark_as_unique

    private
    def check(loc, no_args)
      if loc.in_analysis_target?(traits)
        W(loc) unless no_args
      end
    end
  end

  class W0811 < PassiveCodeCheck
    def_registrant_phase Cpp::Prepare2Phase

    # NOTE: W0811 may be duplicative when the same header which causes this
    #       warning is included twice or more.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      macro_table = phase_ctxt[:cpp_macro_table]
      macro_table.on_object_like_macro_replacement   += T(:check)
      macro_table.on_function_like_macro_replacement += T(:check)
    end

    private
    def check(*, rslt_toks)
      if defined_tok = rslt_toks.find { |tok| tok.value == "defined" }
        W(defined_tok.location)
      end
    end
  end

  class W0831 < PassiveCodeCheck
    def_registrant_phase Cpp::Prepare2Phase

    # NOTE: W0831 may be duplicative when the same header which causes this
    #       warning is included twice or more.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cpp_interpreter]
      interp.on_asm_section_evaled += T(:check)
    end

    private
    def check(asm_section)
      W(asm_section.location)
    end
  end

  class W0832 < PassiveCodeCheck
    def_registrant_phase Cpp::Prepare2Phase

    # NOTE: W0832 may be duplicative when the same header which causes this
    #       warning is included twice or more.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      phase_ctxt[:cc1_source].on_inline_assembly += M(:check)
    end

    private
    def check(asm_toks)
      head_loc = asm_toks.first.location
      W(head_loc) if head_loc.in_analysis_target?(traits)
    end
  end

  class W1040 < PassiveCodeCheck
    def_registrant_phase Cpp::Prepare2Phase

    # NOTE: W1040 may be duplicative when the same header which causes this
    #       warning is included twice or more.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cpp_interpreter]
      interp.on_extra_tokens_found += M(:check)
    end

    private
    def check(extra_toks)
      head_loc = extra_toks.first.location
      W(head_loc) if head_loc.in_analysis_target?(traits)
    end
  end

  class W1041 < PassiveCodeCheck
    def_registrant_phase Cpp::Prepare2Phase

    # NOTE: W1041 may be duplicative when the same header which causes this
    #       warning is included twice or more.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      traversal = phase_ctxt[:cpp_ast_traversal]
      traversal.enter_unknown_directive += T(:check)
    end

    private
    def check(node)
      W(node.location, node.token.value.chomp.strip)
    end
  end

  class W1046 < PassiveCodeCheck
    def_registrant_phase Cpp::Prepare2Phase

    # NOTE: W1046 may be duplicative when the same header which causes this
    #       warning is included twice or more.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cpp_interpreter]
      interp.on_illformed_newline_escape_found += M(:check)
    end

    private
    def check(loc)
      W(loc) if loc.in_analysis_target?(traits)
    end
  end

  class W9002 < PassiveCodeCheck
    def_registrant_phase Cpp::Prepare2Phase

    # NOTE: W9002 may be duplicative when the same header which has no newline
    #       at end of the file is included twice or more.
    mark_as_unique

    # NOTE: W9002 may be detected before evaluating the annotation for message
    #       suppression.
    mark_as_deferred

    def initialize(phase_ctxt)
      super
      phase_ctxt[:cpp_interpreter].on_eof_newline_not_found += M(:check)
    end

    private
    def check(loc)
      W(loc) if loc.in_analysis_target?(traits)
    end
  end

end
end
end
