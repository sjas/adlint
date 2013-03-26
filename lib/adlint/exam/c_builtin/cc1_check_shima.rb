# Code checkings (cc1-phase) of adlint-exam-c_builtin package.
#
# Author::    Rie Shima <mailto:rkakuuchi@users.sourceforge.net>
# Copyright:: Copyright (C) 2010-2013, OGIS-RI Co.,Ltd.
# License::   GPLv3+: GNU General Public License version 3 or later
#
# Owner::     Rie Shima <mailto:rkakuuchi@users.sourceforge.net>

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
require "adlint/cc1/phase"
require "adlint/cc1/syntax"
require "adlint/cc1/format"

module AdLint #:nodoc:
module Exam #:nodoc:
module CBuiltin #:nodoc:

  class W0573 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_function_call_expr_evaled += T(:check)
      @environ = interp.environment
    end

    private
    def check(funcall_expr, fun, arg_vars, *)
      if fun.named? && fun.name =~ /\A.*scanf\z/
        fmt = create_format(funcall_expr, format_str_index_of(funcall_expr),
                            arg_vars, @environ)
        return unless fmt

        fmt.conversion_specifiers.each do |conv_spec|
          if conv_spec.scanset && conv_spec.scanset.include?("-")
            W(fmt.location)
            break
          end
        end
      end
    end

    def format_str_index_of(funcall_expr)
      funcall_expr.argument_expressions.index do |arg_expr|
        arg_expr.kind_of?(Cc1::StringLiteralSpecifier)
      end
    end

    def create_format(funcall_expr, fmt_str_idx, arg_vars, env)
      if fmt_str_idx
        fmt_str = funcall_expr.argument_expressions[fmt_str_idx]
        if fmt_str && fmt_str.literal.value =~ /\AL?"(.*)"\z/i
          trailing_args = arg_vars[(fmt_str_idx + 1)..-1] || []
          return Cc1::ScanfFormat.new($1, fmt_str.location, trailing_args, env)
        end
      end
      nil
    end
  end

  class W0606 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_union_type_declaration += T(:check)
    end

    private
    def check(node)
      node.struct_declarations.each do |struct_dcl|
        struct_dcl.items.each do |memb_dcl|
          if memb_dcl.type.scalar? && memb_dcl.type.floating?
            W(node.location)
            return
          end
        end
      end
    end
  end

  class W0645 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_kandr_function_definition += T(:check)
    end

    def check(node)
      if node.type.parameter_types.any? { |type| type.void? }
        W(node.location)
      end
    end
  end

  class W0685 < W0573
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def check(funcall_expr, fun, arg_vars, *)
      if fun.named? && fun.name =~ /\A.*scanf\z/
        fmt = create_format(funcall_expr, format_str_index_of(funcall_expr),
                            arg_vars, @environ)
        return unless fmt

        fmt.conversion_specifiers.each do |conv_spec|
          if conv_spec.scanset
            conv_spec.scanset.scan(/(.)-(.)/).each do |lhs, rhs|
              W(fmt.location) if lhs.ord > rhs.ord
            end
          end
        end
      end
    end
  end

  class W0686 < W0573
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def check(funcall_expr, fun, arg_vars, *)
      if fun.named? && fun.name =~ /\A.*scanf\z/
        fmt = create_format(funcall_expr, format_str_index_of(funcall_expr),
                            arg_vars, @environ)
        return unless fmt

        fmt.conversion_specifiers.each do |conv_spec|
          if conv_spec.scanset
            W(fmt.location) unless conv_spec.valid_scanset?
          end
        end
      end
    end
  end

  class W0697 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_function_started       += T(:start_function)
      interp.on_function_ended         += T(:end_function)
      interp.on_implicit_return_evaled += M(:check_implicit_return)
      @cur_fun = nil
    end

    private
    def start_function(fun_def, *)
      @cur_fun = fun_def
    end

    def end_function(*)
      @cur_fun = nil
    end

    def check_implicit_return(loc)
      if @cur_fun && loc.in_analysis_target?(traits)
        unless @cur_fun.type.return_type.void?
          W(@cur_fun.location, @cur_fun.identifier.value)
        end
      end
    end
  end

  class W0698 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_ansi_function_definition  += T(:start_function)
      visitor.enter_kandr_function_definition += T(:start_function)
      visitor.leave_ansi_function_definition  += T(:end_function)
      visitor.leave_kandr_function_definition += T(:end_function)
      visitor.enter_return_statement          += T(:check)
      @cur_fun = nil
    end

    private
    def start_function(fun_def)
      @cur_fun = fun_def
    end

    def end_function(*)
      @cur_fun = nil
    end

    def check(retn_stmt)
      return unless @cur_fun.explicitly_typed?

      if retn_type = @cur_fun.type.return_type
        if !retn_type.void? && retn_stmt.expression.nil?
          W(retn_stmt.location, @cur_fun.identifier.value)
        end
      end
    end
  end

  class W0699 < W0698
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def check(retn_stmt)
      return unless @cur_fun.implicitly_typed?

      if retn_stmt.expression.nil?
        W(retn_stmt.location, @cur_fun.identifier.value)
      end
    end
  end

  class W0700 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_function_started       += T(:start_function)
      interp.on_function_ended         += T(:end_function)
      interp.on_return_stmt_evaled     += T(:check_explicit_return)
      interp.on_implicit_return_evaled += M(:check_implicit_return)
      @cur_fun = nil
    end

    private
    def start_function(fun_def, *)
      @cur_fun = fun_def
    end

    def end_function(*)
      @cur_fun = nil
    end

    def check_explicit_return(retn_stmt, *)
      if @cur_fun
        if @cur_fun.implicitly_typed? && retn_stmt.expression.nil?
          W(@cur_fun.location, @cur_fun.identifier.value)
        end
      end
    end

    def check_implicit_return(loc)
      if @cur_fun && loc.in_analysis_target?(traits)
        if @cur_fun.implicitly_typed?
          W(@cur_fun.location, @cur_fun.identifier.value)
        end
      end
    end
  end

  class W0711 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_relational_expression += T(:check)
    end

    private
    def check(expr)
      if !expr.lhs_operand.logical? && expr.rhs_operand.logical?
        W(expr.rhs_operand.location)
      end
    end
  end

  class W0712 < W0711
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def check(expr)
      if expr.lhs_operand.logical? && !expr.rhs_operand.logical?
        W(expr.lhs_operand.location)
      end
    end
  end

  class W0713 < W0711
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def check(expr)
      if expr.lhs_operand.logical? && expr.rhs_operand.logical?
        W(expr.location)
      end
    end
  end

  class W0714 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_and_expression += T(:check)
    end

    private
    def check(expr)
      if expr.lhs_operand.logical? && expr.rhs_operand.logical?
        W(expr.location)
      end
    end
  end

  class W0715 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_inclusive_or_expression += T(:check)
    end

    private
    def check(expr)
      if expr.lhs_operand.logical? && expr.rhs_operand.logical?
        W(expr.location)
      end
    end
  end

  class W0716 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_additive_expression            += T(:check)
      visitor.enter_multiplicative_expression      += T(:check)
      visitor.enter_shift_expression               += T(:check)
      visitor.enter_and_expression                 += T(:check)
      visitor.enter_exclusive_or_expression        += T(:check)
      visitor.enter_inclusive_or_expression        += T(:check)
      visitor.enter_compound_assignment_expression += T(:check)
    end

    private
    def check(expr)
      if expr.lhs_operand.logical? && expr.rhs_operand.logical?
        W(expr.location)
      end
    end
  end

  class W0717 < W0716
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def check(expr)
      if expr.lhs_operand.logical? && !expr.rhs_operand.logical?
        W(expr.lhs_operand.location)
      end
    end
  end

  class W0718 < W0716
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def check(expr)
      if !expr.lhs_operand.logical? && expr.rhs_operand.logical?
        W(expr.rhs_operand.location)
      end
    end
  end

  class W0726 < W0698
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def check(retn_stmt)
      if retn_stmt.expression
        if retn_type = @cur_fun.type.return_type
          if retn_type.void? && (retn_type.const? || retn_type.volatile?)
            W(retn_stmt.location, @cur_fun.identifier.value)
          end
        end
      end
    end
  end

  class W0732 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_logical_and_expression += T(:check)
    end

    private
    def check(expr)
      if expr.lhs_operand.arithmetic? || expr.lhs_operand.bitwise?
        if expr.rhs_operand.arithmetic? || expr.rhs_operand.bitwise?
          W(expr.location)
        end
      end
    end
  end

  class W0733 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_logical_or_expression += T(:check)
    end

    private
    def check(expr)
      if expr.lhs_operand.arithmetic? || expr.lhs_operand.bitwise?
        if expr.rhs_operand.arithmetic? || expr.rhs_operand.bitwise?
          W(expr.location)
        end
      end
    end
  end

  class W0734 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_logical_and_expression += T(:check)
      visitor.enter_logical_or_expression  += T(:check)
    end

    private
    def check(expr)
      if expr.lhs_operand.arithmetic? || expr.lhs_operand.bitwise?
        unless expr.rhs_operand.arithmetic? || expr.rhs_operand.bitwise?
          W(expr.lhs_operand.location)
        end
      end
    end
  end

  class W0735 < W0734
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def check(expr)
      if expr.rhs_operand.arithmetic? || expr.rhs_operand.bitwise?
        unless expr.lhs_operand.arithmetic? || expr.lhs_operand.bitwise?
          W(expr.rhs_operand.location)
        end
      end
    end
  end

  class W0781 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_switch_statement          += T(:enter_switch_statement)
      visitor.leave_switch_statement          += T(:check)
      visitor.enter_case_labeled_statement    += T(:add_exec_path)
      visitor.enter_default_labeled_statement += T(:add_exec_path)
      @exec_path_nums = []
    end

    private
    def enter_switch_statement(*)
      @exec_path_nums.push(0)
    end

    def check(node)
      if exec_path_num = @exec_path_nums.last and exec_path_num < 2
        W(node.location)
      end
      @exec_path_nums.pop
    end

    def add_exec_path(node)
      @exec_path_nums[-1] += 1 if node.executed?
    end
  end

  class W0801 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_struct_type_declaration += T(:check)
      visitor.enter_union_type_declaration  += T(:check)
    end

    private
    def check(node)
      W(node.location) if node.type.members.empty?
    end
  end

  class W0809 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_function_declaration      += T(:check_function_name)
      visitor.enter_variable_declaration      += T(:check_variable_name)
      visitor.enter_variable_definition       += T(:check_variable_name)
      visitor.enter_parameter_definition      += T(:check_variable_name)
      visitor.enter_typedef_declaration       += T(:check_typedef_name)
      visitor.enter_struct_type_declaration   += T(:check_tag_name)
      visitor.enter_union_type_declaration    += T(:check_tag_name)
      visitor.enter_enum_type_declaration     += T(:check_tag_name)
      visitor.enter_enumerator                += T(:check_enumerator_name)
      visitor.enter_kandr_function_definition += T(:enter_function)
      visitor.enter_ansi_function_definition  += T(:enter_function)
      visitor.leave_kandr_function_definition += T(:leave_function)
      visitor.leave_ansi_function_definition  += T(:leave_function)
      @function_def_level = 0
    end

    private
    def check_function_name(fun_dcl)
      check_object_name(fun_dcl)
    end

    def check_variable_name(var_dcl_or_def)
      check_object_name(var_dcl_or_def)
    end

    def check_typedef_name(typedef_dcl)
      if typedef_dcl.identifier
        case name = typedef_dcl.identifier.value
        when /\A__/, /\A_[A-Z]/, /\A_/
          W(typedef_dcl.location, name)
        end
      end
    end

    def check_tag_name(type_dcl)
      if type_dcl.identifier
        case name = type_dcl.identifier.value
        when /\A__adlint/
          # NOTE: To ignore AdLint internal tag names.
        when /\A__/, /\A_[A-Z]/, /\A_/
          W(type_dcl.location, name)
        end
      end
    end

    def check_enumerator_name(enum)
      if enum.identifier
        case name = enum.identifier.value
        when /\A__/, /\A_[A-Z]/, /\A_/
          W(enum.location, name)
        end
      end
    end

    def enter_function(node)
      check_object_name(node)
      @function_def_level += 1
    end

    def leave_function(node)
      @function_def_level -= 1
    end

    def check_object_name(dcl_or_def)
      if dcl_or_def.identifier
        case name = dcl_or_def.identifier.value
        when /\A__/, /\A_[A-Z]/
          W(dcl_or_def.location, name)
        when /\A_/
          check_filelocal_object_name(name, dcl_or_def)
        end
      end
    end

    def check_filelocal_object_name(name, dcl_or_def)
      if @function_def_level == 0
        if sc_spec = dcl_or_def.storage_class_specifier
          if sc_spec.type == :STATIC
            W(dcl_or_def.location, name)
          end
        end
      end
    end
  end

  class W1030 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_generic_labeled_statement += T(:check)
      visitor.enter_ansi_function_definition  += T(:enter_function)
      visitor.leave_ansi_function_definition  += T(:leave_function)
      visitor.enter_kandr_function_definition += T(:enter_function)
      visitor.leave_kandr_function_definition += T(:leave_function)
      @labels = nil
    end

    private
    def check(labeled_stmt)
      if @labels
        if @labels.include?(labeled_stmt.label.value)
          W(labeled_stmt.label.location, labeled_stmt.label.value)
        else
          @labels.add(labeled_stmt.label.value)
        end
      end
    end

    def enter_function(*)
      @labels = Set.new
    end

    def leave_function(*)
      @labels = nil
    end
  end

  class W1033 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_ansi_function_definition  += T(:check)
      visitor.enter_kandr_function_definition += T(:check)
      visitor.enter_function_declaration      += T(:check)
    end

    private
    def check(dcl_or_def)
      if retn_type = dcl_or_def.type.return_type
        if retn_type.const? || retn_type.volatile?
          W(dcl_or_def.location)
        end
      end
    end
  end

  class W1066 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_explicit_conv_performed    += T(:check)
      @interp.on_function_started           += T(:clear_rvalues)
      @interp.on_additive_expr_evaled       += T(:handle_additive)
      @interp.on_multiplicative_expr_evaled += T(:handle_multiplicative)
      @rvalues = nil
    end

    private
    def check(*, org_var, res_var)
      if @rvalues && org_var.type.floating?
        case expr = @rvalues[org_var]
        when Cc1::AdditiveExpression, Cc1::MultiplicativeExpression
          if org_var.type.same_as?(from_type) && res_var.type.same_as?(to_type)
            W(expr.location)
          end
        end
      end
    end

    def clear_rvalues(*)
      @rvalues = {}
    end

    def handle_additive(expr, *, res_var)
      memorize_rvalue_derivation(res_var, expr)
    end

    def handle_multiplicative(expr, *, res_var)
      unless expr.operator.type == "%"
        memorize_rvalue_derivation(res_var, expr)
      end
    end

    def memorize_rvalue_derivation(rvalue_holder, expr)
      @rvalues[rvalue_holder] = expr if @rvalues
    end

    def from_type
      @interp.float_t
    end

    def to_type
      @interp.double_t
    end
  end

  class W1067 < W1066
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.float_t
    end

    def to_type
      @interp.long_double_t
    end
  end

  class W1068 < W1066
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.double_t
    end

    def to_type
      @interp.long_double_t
    end
  end

  class W1069 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_ansi_function_definition  += T(:enter_function)
      visitor.enter_kandr_function_definition += T(:enter_function)
      visitor.enter_compound_statement        += T(:enter_compound_stmt)
      visitor.leave_compound_statement        += T(:leave_compound_stmt)
      visitor.enter_if_else_statement         += T(:enter_if_else_stmt)
      visitor.leave_if_else_statement         += T(:leave_if_else_stmt)
      @if_else_stmt_chain_stack = []
    end

    private
    def enter_function(*)
      @if_else_stmt_chain_stack = []
    end

    def enter_compound_stmt(*)
      @if_else_stmt_chain_stack.push([])
    end

    def leave_compound_stmt(*)
      @if_else_stmt_chain_stack.pop
    end

    def enter_if_else_stmt(node)
      @if_else_stmt_chain_stack.last.push(node)
      if node.else_statement.kind_of?(Cc1::IfStatement)
        W(@if_else_stmt_chain_stack.last.first.location)
      end
    end

    def leave_if_else_stmt(*)
      @if_else_stmt_chain_stack.last.pop
    end
  end

  class W1070 < W0781
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def check(node)
      if exec_path_num = @exec_path_nums.last and exec_path_num == 2
        W(node.location)
      end
      @exec_path_nums.pop
    end

    def add_exec_path(*)
      @exec_path_nums[-1] += 1
    end
  end

  class W1072 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_goto_statement += T(:warn_goto)
    end

    private
    def warn_goto(node)
       W(node.location)
    end
  end

end
end
end
