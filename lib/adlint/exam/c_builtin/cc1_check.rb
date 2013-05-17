# Code checkings (cc1-phase) of adlint-exam-c_builtin package.
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
require "adlint/token"
require "adlint/traits"
require "adlint/monitor"
require "adlint/cc1/phase"
require "adlint/cc1/syntax"
require "adlint/cc1/type"
require "adlint/cc1/format"
require "adlint/cc1/option"
require "adlint/cc1/conv"
require "adlint/cc1/util"
require "adlint/cpp/syntax"

module AdLint #:nodoc:
module Exam #:nodoc:
module CBuiltin #:nodoc:

  class W0001_Cc1 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_grouped_expression += T(:enter_grouped_expression)
      visitor.leave_grouped_expression += T(:leave_grouped_expression)
      @group_depth = 0
    end

    private
    def enter_grouped_expression(node)
      @group_depth += 1
      W(node.location) if @group_depth == 33
    end

    def leave_grouped_expression(node)
      @group_depth -= 1
    end
  end

  class W0002 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_kandr_function_definition += T(:check)
    end

    private
    def check(node)
      W(node.location, node.identifier.value)
    end
  end

  class W0003 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_switch_statement += T(:check)
    end

    private
    def check(node)
      if node.statement.kind_of?(Cc1::CompoundStatement)
        unless have_default_statement?(node.statement)
          W(node.location)
        end
      end
    end

    def have_default_statement?(compound_stmt)
      compound_stmt.block_items.any? do |item|
        case item
        when Cc1::GenericLabeledStatement, Cc1::CaseLabeledStatement
          item = item.statement
          redo
        when Cc1::DefaultLabeledStatement
          true
        else
          false
        end
      end
    end
  end

  class W0007 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_switch_statement += T(:enter_switch_statement)
    end

    private
    def enter_switch_statement(node)
      prv_item = nil
      node.statement.block_items.each do |item|
        if prv_item
          case item
          when Cc1::CaseLabeledStatement, Cc1::DefaultLabeledStatement
            case prv_item
            when Cc1::CompoundStatement
              unless end_with_break_or_return_statement?(item)
                W(item.location)
                warn_inner_case_labeled_statement(item)
              end
            when Cc1::BreakStatement, Cc1::ReturnStatement
              ;
            else
              W(item.location)
              warn_inner_case_labeled_statement(item)
            end
          end
        end

        item = item.statement while item.kind_of?(Cc1::LabeledStatement)
        prv_item = item
      end
    end

    def warn_inner_case_labeled_statement(node)
      child = node
      loop do
        child = child.statement
        break unless child.kind_of?(Cc1::CaseLabeledStatement)
        W(child.location)
      end
    end

    def end_with_break_or_return_statement?(stmt)
      case stmt
      when Cc1::CompoundStatement
        end_with_break_or_return_statement?(stmt.block_Items.last)
      when Cc1::BreakStatement
        true
      when Cc1::ReturnStatement
        true
      end
    end
  end

  class W0010 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_conditional_expression += T(:check)
    end

    private
    def check(node)
      if node.then_expression.have_side_effect? ||
          node.else_expression.have_side_effect?
        W(node.location)
      end
    end
  end

  class W0013 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_continue_statement += T(:check)
    end

    private
    def check(node)
      W(node.location)
    end
  end

  class W0016 < PassiveCodeCheck
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
      if fun.named? && fun.name =~ /\A.*printf\z/
        fmt = create_format(funcall_expr, format_str_index_of(funcall_expr),
                            arg_vars, @environ)
        if fmt
          css = fmt.conversion_specifiers
          if css.any? { |cs| cs.field_width_value > 509 }
            W(fmt.location)
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
          args = arg_vars[(fmt_str_idx + 1)..-1] || []
          return Cc1::PrintfFormat.new($1, fmt_str.location, args, env)
        end
      end
      nil
    end
  end

  class W0017 < PassiveCodeCheck
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
        if fmt
          conv_specs = fmt.conversion_specifiers
          if conv_specs.any? { |cs| cs.field_width_value > 509 }
            W(fmt.location)
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
          args = arg_vars[(fmt_str_idx + 1)..-1] || []
          return Cc1::ScanfFormat.new($1, fmt_str.location, args, env)
        end
      end
      nil
    end
  end

  class W0018 < PassiveCodeCheck
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
      if fun.named? && fun.name =~ /\A.*printf\z/
        fmt = create_format(funcall_expr, format_str_index_of(funcall_expr),
                            arg_vars, @environ)
        if fmt
          conv_specs = fmt.conversion_specifiers
          if conv_specs.any? { |cs| cs.precision_value > 509 }
            W(fmt.location)
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
          args = arg_vars[(fmt_str_idx + 1)..-1] || []
          return Cc1::PrintfFormat.new($1, fmt_str.location, args, env)
        end
      end
      nil
    end
  end

  class W0019 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_explicit_conv_performed += T(:check_explicit_conversion)
    end

    private
    def check_explicit_conversion(expr, org_var, res_var)
      org_type = org_var.type
      res_type = res_var.type

      if org_type.pointer? && org_type.unqualify.base_type.const? &&
          res_type.pointer? && !res_type.unqualify.base_type.const?
        W(expr.location)
      end
    end
  end

  class W0021 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_explicit_conv_performed += T(:check_explicit_conversion)
    end

    private
    def check_explicit_conversion(expr, org_var, res_var)
      org_type = org_var.type
      res_type = res_var.type

      if org_type.pointer? && org_type.unqualify.base_type.volatile? &&
          res_type.pointer? && !res_type.unqualify.base_type.volatile?
        W(expr.location)
      end
    end
  end

  class W0023 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_additive_expr_evaled       += T(:check_binary)
      @interp.on_multiplicative_expr_evaled += T(:check_binary)
    end

    private
    def check_binary(binary_expr, lhs_var, rhs_var, *)
      case
      when lhs_var.type.pointer? && rhs_var.type.scalar?
        if rhs_var.value.scalar? &&
            !rhs_var.value.must_be_equal_to?(@interp.scalar_value_of(1))
          W(binary_expr.location)
        end
      when rhs_var.type.pointer? && lhs_var.type.scalar?
        if lhs_var.value.scalar? &&
            !lhs_var.value.must_be_equal_to?(@interp.scalar_value_of(1))
          W(binary_expr.location)
        end
      end
    end
  end

  class W0024 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_additive_expr_evaled          += T(:check_binary)
      @interp.on_prefix_increment_expr_evaled  += T(:check_unary_prefix)
      @interp.on_postfix_increment_expr_evaled += T(:check_unary_postfix)
      @interp.on_prefix_decrement_expr_evaled  += T(:check_unary_prefix)
      @interp.on_postfix_decrement_expr_evaled += T(:check_unary_postfix)
    end

    private
    def check_binary(binary_expr, lhs_var, rhs_var, *)
      case
      when lhs_var.type.pointer? && rhs_var.type.scalar?
        if rhs_var.value.scalar? &&
            rhs_var.value.must_be_equal_to?(@interp.scalar_value_of(1))
          W(binary_expr.location)
        end
      when rhs_var.type.pointer? && lhs_var.type.scalar?
        if lhs_var.value.scalar? &&
            lhs_var.value.must_be_equal_to?(@interp.scalar_value_of(1))
          W(binary_expr.location)
        end
      end
    end

    def check_unary_prefix(unary_expr, ope_var, *)
      if ope_var.type.pointer?
        W(unary_expr.location)
      end
    end

    def check_unary_postfix(postfix_expr, ope_var, *)
      if ope_var.type.pointer?
        W(postfix_expr.location)
      end
    end
  end

  class W0027 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_relational_expr_evaled += T(:check_comparison)
      interp.on_equality_expr_evaled   += T(:check_comparison)
    end

    private
    def check_comparison(expr, lhs_var, rhs_var, *)
      return if expr.lhs_operand.kind_of?(Cc1::NullConstantSpecifier)
      return if expr.rhs_operand.kind_of?(Cc1::NullConstantSpecifier)

      if lhs_var.type.pointer? || rhs_var.type.pointer?
        W(expr.location)
      end
    end
  end

  class W0028 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_indirection_expr_evaled     += T(:check_indirection)
      @interp.on_member_access_expr_evaled   += T(:check_member_access)
      @interp.on_array_subscript_expr_evaled += T(:check_array_subscript)
    end

    private
    def check_indirection(expr, var, *)
      if @interp.constant_expression?(expr.operand)
        if var.value.scalar? &&
            var.value.must_be_equal_to?(@interp.scalar_value_of(0))
          W(expr.location)
        end
      end
    end

    def check_member_access(expr, outer_var, *)
      return unless outer_var.type.pointer?
      if @interp.constant_expression?(expr.expression)
        if outer_var.value.scalar? &&
            outer_var.value.must_be_equal_to?(@interp.scalar_value_of(0))
          W(expr.location)
        end
      end
    end

    def check_array_subscript(expr, ptr_var, *)
      return unless ptr_var.type.pointer?
      if @interp.constant_expression?(expr.expression)
        if ptr_var.value.scalar? &&
            ptr_var.value.must_be_equal_to?(@interp.scalar_value_of(0))
          W(expr.location)
        end
      end
    end
  end

  class W0030 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_multiplicative_expr_evaled    += T(:check_binary)
      @interp.on_additive_expr_evaled          += T(:check_binary)
      @interp.on_shift_expr_evaled             += T(:check_binary)
      @interp.on_and_expr_evaled               += T(:check_binary)
      @interp.on_exclusive_or_expr_evaled      += T(:check_binary)
      @interp.on_inclusive_or_expr_evaled      += T(:check_binary)
      @interp.on_prefix_increment_expr_evaled  += T(:check_unary_prefix)
      @interp.on_postfix_increment_expr_evaled += T(:check_unary_postfix)
      @interp.on_prefix_decrement_expr_evaled  += T(:check_unary_prefix)
      @interp.on_postfix_decrement_expr_evaled += T(:check_unary_postfix)
    end

    private
    def check_binary(expr, lhs_var, rhs_var, *)
      lhs_type, lhs_val = lhs_var.type, lhs_var.value
      rhs_type, rhs_val = rhs_var.type, rhs_var.value

      if @interp.constant_expression?(expr.lhs_operand) && lhs_type.pointer? &&
          lhs_val.must_be_equal_to?(@interp.scalar_value_of(0))
        W(expr.lhs_operand.location)
      end

      if @interp.constant_expression?(expr.rhs_operand) && rhs_type.pointer? &&
          rhs_val.must_be_equal_to?(@interp.scalar_value_of(0))
        W(expr.rhs_operand.location)
      end
    end

    def check_unary_prefix(expr, ope_var, org_val)
      type, val = ope_var.type, org_val

      if @interp.constant_expression?(expr.operand) && type.pointer? &&
          val.must_be_equal_to?(@interp.scalar_value_of(0))
        W(expr.operand.location)
      end
    end

    def check_unary_postfix(expr, ope_var, *)
      type, val = ope_var.type, ope_var.value

      if @interp.constant_expression?(expr.operand) && type.pointer? &&
          val.must_be_equal_to?(@interp.scalar_value_of(0))
        W(expr.operand.location)
      end
    end
  end

  class W0031 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_function_started        += T(:start_function)
      interp.on_parameter_defined       += T(:add_parameter)
      interp.on_variable_referred       += T(:use_parameter)
      interp.on_variable_value_referred += T(:use_parameter)
      interp.on_function_ended          += T(:check_unused_parameter)
      @parameters = nil
    end

    private
    def start_function(*)
      @parameters = {}
    end

    def add_parameter(param_def, var)
      if @parameters && var.named?
        @parameters[var.name] = [param_def, false]
      end
    end

    def use_parameter(*, var)
      if @parameters && var.named?
        if param_def = @parameters[var.name]
          @parameters[var.name] = [param_def, true]
        end
      end
    end

    def check_unused_parameter(*)
      if @parameters
        @parameters.each do |name, param|
          W(param[0].location, name) unless param[1]
        end
        @parameters = nil
      end
    end
  end

  class W0033 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_function_started += T(:collect_labels)
      interp.on_goto_stmt_evaled += T(:use_label)
      interp.on_function_ended   += T(:check_unused_label)
      @labels = nil
    end

    private
    def collect_labels(fun_def, *)
      @labels = LabelCollector.new.tap { |col|
        fun_def.function_body.accept(col)
      }.labels
    end

    def end_function(*)
      @labels = nil
    end

    def use_label(*, label_name)
      if @labels and label = @labels[label_name]
        @labels[label_name] = [label, true]
      end
    end

    def check_unused_label(*)
      if @labels
        @labels.each do |name, label|
          W(label[0].location, name) unless label[1]
        end
        @labels = nil
      end
    end

    class LabelCollector < Cc1::SyntaxTreeVisitor
      def initialize
        @labels = {}
      end

      attr_reader :labels

      def visit_generic_labeled_statement(node)
        @labels[node.label.value] = [node.label, false]
      end
    end
    private_constant :LabelCollector
  end

  class W0035 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_logical_or_expr_evaled  += T(:check_logical)
      interp.on_logical_and_expr_evaled += T(:check_logical)
      interp.on_conditional_expr_evaled += T(:check_conditional)
    end

    private
    def check_logical(expr, lhs_var, rhs_var, *)
      unless rhs_var.type.scalar?
        W(expr.location)
      end
    end

    def check_conditional(expr, ctrl_var, *)
      unless ctrl_var.type.scalar?
        W(expr.location)
      end
    end
  end

  class W0036 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_init_declarator           += T(:check_init_decl)
      visitor.enter_struct_declarator         += T(:check_struct_decl)
      visitor.enter_parameter_declaration     += T(:check_parameter_decl)
      visitor.enter_kandr_function_definition += T(:check_kandr_fundef)
      visitor.enter_ansi_function_definition  += T(:check_ansi_fundef)
      visitor.enter_type_name                 += T(:check_type_name)
    end

    private
    def check_init_decl(init_dcr)
      dcr_num = DeclaratorCounter.new.tap { |cnt|
        init_dcr.declarator.accept(cnt)
      }.result

      W(init_dcr.location) if dcr_num > 12
    end

    def check_struct_decl(struct_dcr)
      if dcr = struct_dcr.declarator
        dcr_num = DeclaratorCounter.new.tap { |cnt| dcr.accept(cnt) }.result
        W(struct_dcr.location) if dcr_num > 12
      end
    end

    def check_parameter_decl(param_dcl)
      if dcr = param_dcl.declarator
        dcr_num = DeclaratorCounter.new.tap { |cnt| dcr.accept(cnt) }.result
        W(param_dcl.location) if dcr_num > 12
      end
    end

    def check_kandr_fundef(fun_def)
      dcr_num = DeclaratorCounter.new.tap { |cnt|
        fun_def.declarator.accept(cnt)
      }.result

      W(fun_def.location) if dcr_num > 12
    end

    def check_ansi_fundef(fun_def)
      dcr_num = DeclaratorCounter.new.tap { |cnt|
        fun_def.declarator.accept(cnt)
      }.result

      W(fun_def.location) if dcr_num > 12
    end

    def check_type_name(type_name)
      if dcr = type_name.abstract_declarator
        dcr_num = DeclaratorCounter.new.tap { |cnt| dcr.accept(cnt) }.result
        W(type_name.location) if dcr_num > 12
      end
    end

    class DeclaratorCounter < Cc1::SyntaxTreeVisitor
      def initialize
        @result = 0
      end

      attr_reader :result

      def visit_identifier_declarator(node)
        super
        if ptr = node.pointer
          @result += ptr.count { |tok| tok.type == "*" }
        end
      end

      def visit_array_declarator(node)
        super
        @result += 1
        if ptr = node.pointer
          @result += ptr.count { |tok| tok.type == "*" }
        end
      end

      def visit_ansi_function_declarator(node)
        node.base.accept(self)
        @result += 1
        if ptr = node.pointer
          @result += ptr.count { |tok| tok.type == "*" }
        end
      end

      def visit_kandr_function_declarator(node)
        super
        @result += 1
        if ptr = node.pointer
          @result += ptr.count { |tok| tok.type == "*" }
        end
      end

      def visit_abbreviated_function_declarator(node)
        super
        @result += 1
        if ptr = node.pointer
          @result += ptr.count { |tok| tok.type == "*" }
        end
      end

      def visit_pointer_abstract_declarator(node)
        super
        @result += node.pointer.count { |tok| tok.type == "*" }
      end

      def visit_array_abstract_declarator(node)
        super
        @result += 1
      end

      def visit_function_abstract_declarator(node)
        node.base.accept(self) if node.base
        @result += 1
      end
    end
    private_constant :DeclaratorCounter
  end

  class W0037 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_struct_specifier += T(:enter_struct_specifier)
      visitor.leave_struct_specifier += T(:leave_struct_specifier)
      visitor.enter_union_specifier  += T(:enter_union_specifier)
      visitor.leave_union_specifier  += T(:leave_union_specifier)
      @nest_level = 0
    end

    private
    def enter_struct_specifier(node)
      @nest_level += 1
      W(node.location) if @nest_level == 16
    end

    def leave_struct_specifier(node)
      @nest_level -= 1
    end

    def enter_union_specifier(node)
      @nest_level += 1
      W(node.location) if @nest_level == 16
    end

    def leave_union_specifier(node)
      @nest_level -= 1
    end
  end

  class W0038 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_variable_definition += T(:check)
    end

    private
    def check(node)
      if node.type.aligned_byte_size > 32767
        W(node.location, node.identifier.value)
      end
    end
  end

  class W0039 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_compound_statement   += T(:enter_block)
      visitor.leave_compound_statement   += T(:leave_block)
      visitor.enter_variable_definition  += T(:add_identifier)
      visitor.enter_variable_declaration += T(:add_identifier)
      visitor.enter_typedef_declaration  += T(:add_identifier)
      @block_stack = [0]
    end

    private
    def enter_block(node)
      @block_stack.push(0)
    end

    def leave_block(node)
      @block_stack.pop
    end

    def add_identifier(node)
      @block_stack[-1] += 1
      W(node.location) if @block_stack.last == 128
    end
  end

  class W0040 < PassiveCodeCheck
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
      node.struct_declarations.each do |struct_dcl|
        struct_dcl.items.each do |memb_decl|
          memb_type = memb_decl.type
          next unless memb_type.scalar? && memb_type.integer?
          if memb_type.bitfield? && !memb_type.explicitly_signed?
            W(node.location)
            return
          end
        end
      end
    end
  end

  class W0041 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_struct_type_declaration += T(:check_struct)
      visitor.enter_union_type_declaration  += T(:check_union)
    end

    private
    def check_struct(node)
      memb_num = node.struct_declarations.map { |dcl|
        dcl.items.size
      }.reduce(0) { |sum, num| sum + num }

      W(node.location) if memb_num > 127
    end

    def check_union(node)
      memb_num = node.struct_declarations.map { |dcl|
        dcl.items.size
      }.reduce(0) { |sum, num| sum + num }

      W(node.location) if memb_num > 127
    end
  end

  class W0042 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_enum_type_declaration += T(:check)
    end

    private
    def check(node)
      if node.enum_specifier.enumerators.size > 127
        W(node.location)
      end
    end
  end

  class W0043 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_variable_definition += T(:enter_variable_definition)
    end

    private
    def enter_variable_definition(node)
      return unless node.initializer
      return unless node.type.array?

      if inits = node.initializer.initializers
        if initializer_depth(node.initializer) == type_depth(node.type)
          check_well_balanced(node.type, inits, node.initializer)
        else
          check_flattened(node.type, inits, node.initializer)
        end
      end
    end

    def check_well_balanced(ary_type, inits, parent_init)
      return unless ary_type.length

      if !inits.empty? && inits.size < ary_type.length
        if inits.size == 1 and expr = inits.first.expression
          unless expr.kind_of?(Cc1::ConstantSpecifier) &&
              expr.constant.value == "0"
            warn(expr, parent_init)
          end
        else
          warn(inits.first, parent_init)
        end
      end

      if ary_type.base_type.array?
        inits.each do |init|
          if init.initializers
            check_well_balanced(ary_type.base_type, init.initializers, init)
          end
        end
      end
    end

    def check_flattened(ary_type, inits, parent_init)
      unless total_length = total_length(ary_type)
        # NOTE: Cannot check the incomplete array.
        return
      end

      flattener = lambda { |init|
        init.expression || init.initializers.map(&flattener)
      }
      exprs = inits.map { |init| flattener.call(init) }.flatten.compact

      if !exprs.empty? && exprs.size < total_length
        if exprs.size == 1 and fst = exprs.first
          if fst.kind_of?(Cc1::ObjectSpecifier) && fst.constant.value != "0"
            warn(fst, parent_init)
          end
        else
          warn(exprs.first, parent_init)
        end
      end
    end

    def warn(node, parant_init)
      if parant_init
        W(parant_init.location)
      else
        W(node.location)
      end
    end

    def initializer_depth(init)
      if inits = init.initializers
        1 + inits.map { |i| initializer_depth(i) }.max
      else
        0
      end
    end

    def type_depth(type)
      case
      when type.array?
        1 + type_depth(type.base_type)
      when type.composite?
        type.members.empty? ?
          1 : 1 + type.members.map { |memb| type_depth(memb.type) }.max
      else
        0
      end
    end

    def total_length(ary_type)
      result = 1
      type = ary_type
      while type.array?
        if type.length
          result *= type.length
          type = type.base_type
        else
          return nil
        end
      end
      result
    end
  end

  class W0049 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_if_statement      += T(:enter_if_statement)
      visitor.leave_if_statement      += T(:leave_if_statement)
      visitor.enter_switch_statement  += T(:enter_switch_statement)
      visitor.leave_switch_statement  += T(:leave_switch_statement)
      visitor.enter_while_statement   += T(:enter_while_statement)
      visitor.leave_while_statement   += T(:leave_while_statement)
      visitor.enter_do_statement      += T(:enter_do_statement)
      visitor.leave_do_statement      += T(:leave_do_statement)
      visitor.enter_for_statement     += T(:enter_for_statement)
      visitor.leave_for_statement     += T(:leave_for_statement)
      visitor.enter_c99_for_statement += T(:enter_c99_for_statement)
      visitor.leave_c99_for_statement += T(:leave_c99_for_statement)
      @ctrl_stmt_level = 0
    end

    private
    def enter_if_statement(node)
      @ctrl_stmt_level += 1
      W(node.location) if @ctrl_stmt_level == 16
    end

    def leave_if_statement(node)
      @ctrl_stmt_level -= 1
    end

    def enter_switch_statement(node)
      @ctrl_stmt_level += 1
      W(node.location) if @ctrl_stmt_level == 16
    end

    def leave_switch_statement(node)
      @ctrl_stmt_level -= 1
    end

    def enter_while_statement(node)
      @ctrl_stmt_level += 1
      W(node.location) if @ctrl_stmt_level == 16
    end

    def leave_while_statement(node)
      @ctrl_stmt_level -= 1
    end

    def enter_do_statement(node)
      @ctrl_stmt_level += 1
      W(node.location) if @ctrl_stmt_level == 16
    end

    def leave_do_statement(node)
      @ctrl_stmt_level -= 1
    end

    def enter_for_statement(node)
      @ctrl_stmt_level += 1
      W(node.location) if @ctrl_stmt_level == 16
    end

    def leave_for_statement(node)
      @ctrl_stmt_level -= 1
    end

    def enter_c99_for_statement(node)
      @ctrl_stmt_level += 1
      W(node.location) if @ctrl_stmt_level == 16
    end

    def leave_c99_for_statement(node)
      @ctrl_stmt_level -= 1
    end
  end

  class W0050 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_switch_statement       += T(:enter_switch_statement)
      visitor.leave_switch_statement       += T(:leave_switch_statement)
      visitor.enter_case_labeled_statement += T(:check)
      @label_num_stack = []
    end

    private
    def enter_switch_statement(node)
      @label_num_stack.push(0)
    end

    def leave_switch_statement(node)
      @label_num_stack.pop
    end

    def check(node)
      unless @label_num_stack.empty?
        @label_num_stack[-1] += 1
        W(node.location) if @label_num_stack[-1] == 258
      end
    end
  end

  class W0051 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_variable_declared          += T(:add_variable)
      interp.on_variable_defined           += T(:add_variable)
      interp.on_explicit_function_declared += T(:add_function)
      interp.on_explicit_function_defined  += T(:add_function)
      interp.on_translation_unit_ended     += M(:check)
      @obj_dcls = Hash.new { |hash, key| hash[key] = [] }
    end

    private
    def add_variable(dcl_or_def, var)
      if var.named? && var.declared_as_extern?
        @obj_dcls[mangle(var.name)].push(dcl_or_def)
      end
    end

    def add_function(dcl_or_def, fun)
      if fun.named? && fun.declared_as_extern?
        @obj_dcls[mangle(fun.name)].push(dcl_or_def)
      end
    end

    def check(*)
      @obj_dcls.each_value do |dcls|
        similar_dcls = dcls.uniq { |dcl| dcl.identifier.value }
        next unless similar_dcls.size > 1

        similar_dcls.each do |dcl|
          W(dcl.location, dcl.identifier.value, *similar_dcls.map { |pair_dcl|
            next if pair_dcl == dcl
            C(:C0001, pair_dcl.location, pair_dcl.identifier.value)
          }.compact)
        end
      end
    end

    def mangle(name)
      truncated = name.slice(0...@phase_ctxt.traits.of_linker.identifier_max)
      if @phase_ctxt.traits.of_linker.identifier_ignore_case
        truncated.upcase
      else
        truncated
      end
    end
  end

  class W0052 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_variable_declared          += T(:declare_object)
      interp.on_variable_defined           += T(:declare_object)
      interp.on_explicit_function_declared += T(:declare_object)
      interp.on_explicit_function_defined  += T(:declare_object)
      interp.on_block_started              += T(:enter_scope)
      interp.on_block_ended                += T(:leave_scope)
      @dcl_names = [Hash.new { |hash, key| hash[key] = [] }]
    end

    private
    def declare_object(dcl_or_def, *)
      dcl_name = dcl_or_def.identifier

      pair_names = @dcl_names.map { |name_hash|
        name_hash[mangle(dcl_name.value)]
      }.reduce([]) { |all_names, similar_names|
        all_names + similar_names
      }.uniq { |id| id.value }.reject { |id| id.value == dcl_name.value }

      unless pair_names.empty?
        W(dcl_or_def.location, dcl_name.value,
          *pair_names.map { |pair| C(:C0001, pair.location, pair.value) })
      end

      @dcl_names.last[mangle(dcl_name.value)].push(dcl_name)
    end

    def enter_scope(*)
      @dcl_names.push(Hash.new { |hash, key| hash[key] = [] })
    end

    def leave_scope(*)
      @dcl_names.pop
    end

    def mangle(name)
      name.slice(0...@phase_ctxt.traits.of_compiler.identifier_max)
    end
  end

  class W0058 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_string_literal_specifier += T(:check)
    end

    private
    def check(node)
      if node.literal.value.length - 2 > 509
        W(node.location)
      end
    end
  end

  class W0062 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_typeof_type_specifier += T(:check)
    end

    private
    def check(node)
      W(node.location)
    end
  end

  class W0063 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_alignof_expression      += T(:check)
      visitor.enter_alignof_type_expression += T(:check)
    end

    private
    def check(node)
      W(node.location)
    end
  end

  class W0064 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_constant_referred += T(:check)
    end

    private
    def check(const_spec, *)
      W(const_spec.location) if const_spec.constant.value =~ /\A0b/
    end
  end

  class W0065 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_simple_assignment_expression += T(:check)
    end

    private
    def check(node)
      if node.lhs_operand.kind_of?(Cc1::CastExpression)
        W(node.location)
      end
    end
  end

  class W0066 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_ansi_function_definition  += T(:check_ansi_function)
      visitor.enter_kandr_function_definition += T(:check_kandr_function)
      @interp = phase_ctxt[:cc1_interpreter]
    end

    private
    def check_ansi_function(node)
      check(node) if node.identifier.value == "main"
    end

    def check_kandr_function(node)
      check(node) if node.identifier.value == "main"
    end

    def check(node)
      unless node.type.return_type == @interp.int_t
        W(node.location)
        return
      end

      if node.type.parameter_types.size == 1 &&
          node.type.parameter_types[0] == @interp.void_t
        return
      end

      if node.type.parameter_types.size == 2 &&
          node.type.parameter_types[0] == argc_type &&
          node.type.parameter_types[1] == argv_type
        return
      end

      W(node.location)
    end

    def argc_type
      @interp.int_t
    end

    def argv_type
      @interp.array_type(@interp.pointer_type(@interp.char_t))
    end
  end

  class W0067 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_member_access_expr_evaled += T(:check_member_access)
    end

    private
    def check_member_access(expr, outer_var, inner_var)
      type = outer_var.type
      unqual_type = type.unqualify

      if type.pointer? && unqual_type.base_type.incomplete? or
          type.composite? && type.incomplete?
        return
      end

      W(expr.location) unless inner_var
    end
  end

  class W0068 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_bit_access_by_value_expression   += T(:check)
      visitor.enter_bit_access_by_pointer_expression += T(:check)
    end

    private
    def check(node)
      W(node.location)
    end
  end

  class W0070 < CodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def do_prepare(phase_ctxt) end

    def do_execute(phase_ctxt)
      sys_headers = phase_ctxt[:sources].select { |src| src.system_header? }
      sys_headers.each do |src|
        if src.included_at.in_analysis_target?(traits)
          syms = phase_ctxt[:symbol_table].symbols_appeared_in(src)
          if syms.all? { |sym| sym.useless? }
            W(src.included_at, src.fpath)
          end
        end
      end
    end
  end

  class W0071 < CodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def do_prepare(phase_ctxt) end

    def do_execute(phase_ctxt)
      usr_headers = phase_ctxt[:sources].select { |src| src.user_header? }
      usr_headers.each do |src|
        if src.included_at.in_analysis_target?(traits)
          syms = phase_ctxt[:symbol_table].symbols_appeared_in(src)
          if syms.all? { |sym| sym.useless? }
            W(src.included_at, src.fpath)
          end
        end
      end
    end
  end

  class W0076 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_constant_referred += T(:check)
    end

    private
    def check(const_spec, *)
      if const_spec.constant.value =~ /\A0x[0-9A-F]+\z/i
        W(const_spec.location)
      end
    end
  end

  class W0077 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_constant_referred += T(:check)
    end

    private
    def check(const_spec, *)
      case const_spec.constant.value
      when /\A(?:[0-9]*\.[0-9]*[Ee][+-]?[0-9]+|[0-9]+\.?[Ee][+-]?[0-9]+).*l\z/,
           /\A(?:[0-9]*\.[0-9]+|[0-9]+\.).*l\z/,
           /\A(?:0x[0-9A-Fa-f]+|0b[01]+|[0-9]+)l\z/
        W(const_spec.location)
      end
    end
  end

  class W0078 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_function_declaration += T(:check)
    end

    private
    def check(node)
      W(node.location) if node.type.parameter_types.empty?
    end
  end

  class W0079 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_variable_definition += T(:check)
      @interp = phase_ctxt[:cc1_interpreter]
    end

    private
    def check(node)
      return unless node.initializer && node.initializer.expression

      if node.type.array? && node.type.base_type.same_as?(@interp.char_t)
        if len = node.type.length
          visitor = StringLiteralSpecifierFinder.new
          node.initializer.expression.accept(visitor)
          if str_lit = visitor.result
            str = unquote_string_literal(str_lit)
            W(node.location) if len <= str.length
          end
        end
      end
    end

    def unquote_string_literal(str_lit)
      str_lit.literal.value.sub(/\AL?"(.*)"\z/, "\\1")
    end

    class StringLiteralSpecifierFinder < Cc1::SyntaxTreeVisitor
      def initialize
        @result = nil
      end

      attr_reader :result

      def visit_string_literal_specifier(node)
        @result = node
      end
    end
    private_constant :StringLiteralSpecifierFinder
  end

  class W0080 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_variable_defined += T(:check)
      interp.on_block_started    += T(:enter_block)
      interp.on_block_ended      += T(:leave_block)
      @block_level = 0
    end

    private
    def check(var_def, var)
      if @block_level == 0
        if var.declared_as_extern? || var.declared_as_static?
          if var.type.const? && var_def.initializer.nil?
            W(var_def.location)
          end
        end
      end
    end

    def enter_block(*)
      @block_level += 1
    end

    def leave_block(*)
      @block_level -= 1
    end
  end

  class W0081 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_unary_arithmetic_expr_evaled += T(:check)
    end

    private
    def check(expr, ope_var, *)
      if expr.operator.type == "-"
        if ope_var.type.same_as?(@interp.unsigned_int_t) ||
            ope_var.type.same_as?(@interp.unsigned_long_t) ||
            ope_var.type.same_as?(@interp.unsigned_long_long_t)
          W(expr.location)
        end
      end
    end
  end

  class W0082 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_unary_arithmetic_expr_evaled += T(:check)
    end

    private
    def check(expr, ope_var, *)
      if expr.operator.type == "-"
        if unsigned_underlying_type?(ope_var.type)
          W(expr.location, ope_var.type.brief_image)
        end
      end
    end

    def unsigned_underlying_type?(type)
      type.same_as?(@interp.unsigned_char_t) ||
        type.same_as?(@interp.unsigned_short_t) || type.bitfield?
    end
  end

  class W0084 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_comma_separated_expression += T(:check)
    end

    private
    def check(node)
      if node.expressions.size > 1
        node.expressions[0..-2].each do |expr|
          W(expr.location) unless expr.have_side_effect?
        end
      end
    end
  end

  class W0085 < CodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def do_prepare(phase_ctxt) end

    def do_execute(phase_ctxt)
      phase_ctxt[:cc1_syntax_tree].accept(Visitor.new(phase_ctxt))
    end

    class Visitor < Cc1::SyntaxTreeVisitor
      include ReportUtil

      def initialize(phase_ctxt)
        @phase_ctxt = phase_ctxt
      end

      def visit_expression_statement(node)
        if node.analysis_target?(traits)
          unless node.expression && node.expression.have_side_effect?
            W(node.location)
          end
        end
      end

      def visit_for_statement(node)
        node.body_statement.accept(self) if node.analysis_target?(traits)
      end

      def visit_c99_for_statement(node)
        node.body_statement.accept(self) if node.analysis_target?(traits)
      end

      private
      extend Forwardable

      def_delegator :@phase_ctxt, :traits
      private :traits

      def_delegator :@phase_ctxt, :report
      private :report

      def_delegator :@phase_ctxt, :message_catalog
      private :message_catalog

      def suppressors
        @phase_ctxt[:suppressors]
      end
    end
    private_constant :Visitor
  end

  class W0086 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_conditional_expression += T(:check)
    end

    private
    def check(node)
      then_expr = node.then_expression
      else_expr = node.else_expression

      if then_expr.have_side_effect? != else_expr.have_side_effect?
        W(node.location)
      end
    end
  end

  class W0087 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_simple_assignment_expression   += T(:enter_assignment)
      visitor.leave_simple_assignment_expression   += T(:leave_assignment)
      visitor.enter_compound_assignment_expression += T(:enter_assignment)
      visitor.leave_compound_assignment_expression += T(:leave_assignment)
      visitor.enter_function_call_expression       += T(:enter_assignment)
      visitor.leave_function_call_expression       += T(:leave_assignment)
      visitor.enter_comma_separated_expression     += T(:check)
      @assignment_depth = 0
    end

    private
    def enter_assignment(*)
      @assignment_depth += 1
    end

    def leave_assignment(*)
      @assignment_depth -= 1
    end

    def check(node)
      if !node.expressions.last.have_side_effect? && @assignment_depth == 0
        W(node.location)
      end
    end
  end

  class W0088 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_expression_stmt_started += T(:enter_expression_statement)
      interp.on_expression_stmt_ended   += T(:leave_expression_statement)
      interp.on_logical_and_expr_evaled += T(:check)
      interp.on_logical_or_expr_evaled  += T(:check)
      @cur_expr_stmt = nil
    end

    private
    def enter_expression_statement(expr_stmt)
      case expr_stmt.expression
      when Cc1::SimpleAssignmentExpression, Cc1::CompoundAssignmentExpression,
           Cc1::FunctionCallExpression
        @cur_expr_stmt = nil
      else
        @cur_expr_stmt = expr_stmt
      end
    end

    def leave_expression_statement(*)
      @cur_expr_stmt = nil
    end

    def check(expr, *)
      if @cur_expr_stmt
        unless expr.rhs_operand.have_side_effect?
          W(expr.operator.location)
        end
      end
    end
  end

  class W0093 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_multiplicative_expr_evaled += T(:check)
    end

    private
    def check(expr, lhs_var, rhs_var, *)
      return if expr.operator.type == "*"
      return if @interp.constant_expression?(expr.rhs_operand)

      return unless rhs_var.type.scalar? && rhs_var.value.scalar?
      return if rhs_var.value.must_be_equal_to?(@interp.scalar_value_of(0))

      if rhs_var.value.may_be_equal_to?(@interp.scalar_value_of(0))
        W(expr.location)
      end
    end
  end

  class W0096 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_multiplicative_expr_evaled += T(:check)
    end

    private
    def check(expr, lhs_var, rhs_var, *)
      return if expr.operator.type == "*"
      return unless @interp.constant_expression?(expr.rhs_operand)

      return unless rhs_var.type.scalar? && rhs_var.value.scalar?

      if rhs_var.value.must_be_equal_to?(@interp.scalar_value_of(0))
        W(expr.location)
      end
    end
  end

  class W0097 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_multiplicative_expr_evaled += T(:check)
    end

    private
    def check(expr, lhs_var, rhs_var, *)
      return if expr.operator.type == "*"
      return if @interp.constant_expression?(expr.rhs_operand)

      return unless rhs_var.type.scalar? && rhs_var.value.scalar?

      if rhs_var.value.must_be_equal_to?(@interp.scalar_value_of(0))
        W(expr.location)
      end
    end
  end

  class W0100 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_variable_defined       += T(:define_variable)
      interp.on_variable_initialized   += T(:init_variable)
      interp.on_variable_value_updated += T(:write_variable)
      interp.on_block_started          += T(:enter_block)
      interp.on_block_ended            += T(:leave_block)
      interp.on_while_stmt_started     += T(:enter_iteration)
      interp.on_while_stmt_ended       += T(:leave_iteration)
      interp.on_do_stmt_started        += T(:enter_iteration)
      interp.on_do_stmt_ended          += T(:leave_iteration)
      interp.on_for_stmt_started       += T(:enter_iteration)
      interp.on_for_stmt_ended         += T(:leave_iteration)
      interp.on_c99_for_stmt_started   += T(:enter_iteration)
      interp.on_c99_for_stmt_ended     += T(:leave_iteration)
      @var_stack = [{}]
      @iter_stmt_stack = []
    end

    private
    def enter_block(*)
      @var_stack.push({})
    end

    def leave_block(*)
      check_constant_variables(@var_stack.last)
      @var_stack.pop
    end

    def define_variable(var_def, var)
      if var.named?
        @var_stack.last[var] = [var_def.location, 0]
      end
    end

    def init_variable(var_def, var, *)
      if rec = @var_stack.last[var]
        rec[1] += 1
      end
    end

    def write_variable(*, var)
      var = var.owner while var.inner?
      return unless var.named?

      @var_stack.reverse_each do |vars|
        if rec = vars[var]
          if @iter_stmt_stack.empty?
            rec[1] += 1
          else
            # NOTE: Update twice in order not to over-warn about this variable,
            #       because an iteration is treated as a normal selection by
            #       the abstract interpreter.
            rec[1] += 2
          end
        end
      end
    end

    def enter_iteration(iter_stmt)
      @iter_stmt_stack.push(iter_stmt)
    end

    def leave_iteration(*)
      @iter_stmt_stack.pop
    end

    def check_constant_variables(vars)
      vars.each do |var, (loc, assign_cnt)|
        case
        when var.type.pointer? && var.type.unqualify.base_type.function?
          next
        when var.type.array?
          if assign_cnt <= 1
            base_type = var.type.base_type
            while base_type.array? || base_type.pointer?
              base_type = base_type.base_type
            end
            W(loc, var.name) unless base_type.const?
          end
        when !var.type.const?
          W(loc, var.name) if assign_cnt <= 1
        end
      end
    end
  end

  class W0101 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_assignment_expr_evaled += T(:check)
    end

    private
    def check(expr, lhs_var, rhs_var)
      return unless lhs_var.type.pointer? && rhs_var.type.pointer?

      if rhs_pointee = @interp.pointee_of(rhs_var)
        if rhs_pointee.variable? && rhs_pointee.named?
          return unless rhs_pointee.binding.memory.dynamic?
          # NOTE: An array typed parameter can be considered as an alias of the
          #       corresponding argument.  So, it is safe to return an address
          #       of the argument.
          return if rhs_pointee.type.parameter? && rhs_pointee.type.array?

          case
          when lhs_var.binding.memory.static?
            W(expr.location)
          when lhs_var.scope.depth < rhs_pointee.scope.depth
            W(expr.location)
          end
        end
      end
    end
  end

  class W0102 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_function_started        += T(:start_function)
      @interp.on_function_ended          += T(:end_function)
      @interp.on_parameter_defined       += T(:add_parameter)
      @interp.on_indirection_expr_evaled += T(:relate_pointer)
      @interp.on_assignment_expr_evaled  += T(:check_assignment)
      @params = nil
      @ptr_relationship = nil
    end

    private
    def start_function(*)
      @params = Set.new
      @ptr_relationship = {}
    end

    def end_function(*)
      @params = nil
      @ptr_relationship = nil
    end

    def add_parameter(*, var)
      if @params && var.named?
        @params.add(var.name)
      end
    end

    def relate_pointer(*, var, derefed_var)
      if @ptr_relationship
        @ptr_relationship[derefed_var] = var
      end
    end

    def check_assignment(expr, lhs_var, rhs_var)
      return unless @params && @ptr_relationship
      return unless lhs_var.type.pointer? && rhs_var.type.pointer?

      if ptr = @ptr_relationship[lhs_var]
        return unless ptr.named? && @params.include?(ptr.name)
      else
        return
      end

      if rhs_pointee = @interp.pointee_of(rhs_var)
        if rhs_pointee.variable? && rhs_pointee.named?
          return unless rhs_pointee.binding.memory.dynamic?
          # NOTE: An array typed parameter can be considered as an alias of the
          #       corresponding argument.  So, it is safe to return an address
          #       of the argument.
          return if rhs_pointee.type.parameter? && rhs_pointee.type.array?
          W(expr.location)
        end
      end
    end
  end

  class W0103 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_function_started   += T(:start_function)
      @interp.on_function_ended     += T(:end_function)
      @interp.on_variable_defined   += T(:add_local_variable)
      @interp.on_parameter_defined  += T(:add_local_variable)
      @interp.on_return_stmt_evaled += T(:check_return_statement)
      @lvars = nil
    end

    private
    def start_function(*)
      @lvars = Set.new
    end

    def end_function(*)
      @lvars = nil
    end

    def add_local_variable(*, var)
      return unless var.binding.memory.dynamic?

      if @lvars && var.named?
        @lvars.add(var.name)
      end
    end

    def check_return_statement(retn_stmt, retn_var)
      return unless @lvars
      return unless retn_var && retn_var.type.pointer?

      if pointee = @interp.pointee_of(retn_var)
        if pointee.variable? && pointee.named?
          # NOTE: An array typed parameter can be considered as an alias of the
          #       corresponding argument.  So, it is safe to return an address
          #       of the argument.
          return if pointee.type.parameter? && pointee.type.array?
          if @lvars.include?(pointee.name)
            W(retn_stmt.location)
          end
        end
      end
    end
  end

  class W0104 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_function_started       += T(:start_function)
      interp.on_function_ended         += T(:check_constant_parameters)
      interp.on_parameter_defined      += T(:add_parameter)
      interp.on_variable_value_updated += T(:write_parameter)
      @params = nil
    end

    private
    def start_function(*)
      @params = {}
    end

    def add_parameter(param_def, var)
      if @params && var.named?
        @params[var.name] = [false, var, param_def.location]
      end
    end

    def write_parameter(*, var)
      if @params && var.named? && @params.include?(var.name)
        @params[var.name][0] = true
      end
    end

    def check_constant_parameters(*)
      return unless @params

      @params.each do |name, (written, var, loc)|
        next if var.type.const?
        next if var.type.array? && var.type.base_type.const?

        W(loc, name) unless written
      end

      @params = nil
    end
  end

  class W0105 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_function_started            += T(:start_function)
      interp.on_function_ended              += T(:check_constant_parameters)
      interp.on_parameter_defined           += T(:add_parameter)
      interp.on_variable_value_updated      += T(:write_parameter)
      interp.on_indirection_expr_evaled     += T(:handle_indirection)
      interp.on_array_subscript_expr_evaled += T(:handle_array_subscript)
      @var_relationship = nil
      @params = nil
    end

    private
    def start_function(*)
      @var_relationship = {}
      @params = {}
    end

    def add_parameter(param_def, var)
      if @params && var.type.pointer? && var.named?
        @params[var] = [param_def.location, false]
      end
    end

    def write_parameter(*, var)
      return unless @var_relationship && @params

      if ptr = @var_relationship[var]
        if @params.include?(ptr)
          @params[ptr][1] = true
        end
      end
    end

    def handle_indirection(*, var, derefed_var)
      if @var_relationship
        @var_relationship[derefed_var] = var
      end
    end

    def handle_array_subscript(expr, ary_or_ptr, *, res_var)
      if @var_relationship && ary_or_ptr.type.pointer?
        @var_relationship[res_var] = ary_or_ptr
      end
    end

    def check_constant_parameters(*)
      return unless @params

      @params.each do |ptr, (loc, written)|
        base_type = ptr.type.unqualify.base_type
        unless base_type.function?
          unless written || base_type.const?
            W(loc, ptr.name)
          end
        end
      end

      @var_relationship = nil
      @params = nil
    end
  end

  class W0107 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_assignment_expr_evaled += T(:check_assignment)
    end

    private
    def check_assignment(expr, lhs_var, rhs_var)
      return unless lhs_var.type.pointer? && rhs_var.type.pointer?

      if rhs_pointee = @interp.pointee_of(rhs_var)
        if rhs_pointee.variable? && rhs_pointee.named?
          return unless rhs_pointee.binding.memory.dynamic?
          # NOTE: An array typed parameter can be considered as an alias of the
          #       corresponding argument.  So, it is safe to return an address
          #       of the argument.
          return if rhs_pointee.type.parameter? && rhs_pointee.type.array?

          if lhs_var.scope.local? && lhs_var.binding.memory.static?
            W(expr.location)
          end
        end
      end
    end
  end

  class W0108 < CodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def do_prepare(phase_ctxt) end

    def do_execute(phase_ctxt)
      phase_ctxt[:cc1_syntax_tree].accept(Visitor.new(phase_ctxt))
    end

    class Visitor < Cc1::SyntaxTreeVisitor
      include ReportUtil

      def initialize(phase_ctxt)
        @phase_ctxt = phase_ctxt
      end

      def visit_if_statement(node)
        super if node.analysis_target?(traits)
        warn(node.expression)
      end

      def visit_if_else_statement(node)
        super if node.analysis_target?(traits)
        warn(node.expression)
      end

      def visit_while_statement(node)
        super if node.analysis_target?(traits)
        warn(node.expression)
      end

      def visit_do_statement(node)
        super if node.analysis_target?(traits)
        warn(node.expression)
      end

      def visit_for_statement(node)
        super if node.analysis_target?(traits)
        warn(node.condition_statement.expression)
      end

      def visit_c99_for_statement(node)
        super if node.analysis_target?(traits)
        warn(node.condition_statement.expression)
      end

      def visit_relational_expression(node)
        super if node.analysis_target?(traits)
        warn(node.lhs_operand)
        warn(node.rhs_operand)
      end

      def visit_equality_expression(node)
        super if node.analysis_target?(traits)
        warn(node.lhs_operand)
        warn(node.rhs_operand)
      end

      def visit_unary_arithmetic_expression(node)
        super if node.analysis_target?(traits)
        warn(node.operand) if node.operator.type == "!"
      end

      def visit_logical_and_expression(node)
        super if node.analysis_target?(traits)
        warn(node.lhs_operand)
        warn(node.rhs_operand)
      end

      def visit_logical_or_expression(node)
        super if node.analysis_target?(traits)
        warn(node.lhs_operand)
        warn(node.rhs_operand)
      end

      def visit_conditional_expression(node)
        super if node.analysis_target?(traits)
        warn(node.condition)
      end

      private
      def warn(node)
        node = node.expression while node.kind_of?(Cc1::GroupedExpression)
        if node && node.analysis_target?(traits)
          case node
          when Cc1::SimpleAssignmentExpression,
               Cc1::CompoundAssignmentExpression
            W(node.location)
          end
        end
      end

      extend Forwardable

      def_delegator :@phase_ctxt, :traits
      private :traits

      def_delegator :@phase_ctxt, :report
      private :report

      def_delegator :@phase_ctxt, :message_catalog
      private :message_catalog

      def suppressors
        @phase_ctxt[:suppressors]
      end
    end
    private_constant :Visitor
  end

  class W0109 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_implicit_function_declared += T(:check)
    end

    private
    def check(obj_spec, fun)
      W(obj_spec.location, fun.name) if fun.named?
    end
  end

  class W0110 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_for_stmt_started     += T(:handle_for_statement)
      @interp.on_c99_for_stmt_started += T(:handle_for_statement)
    end

    private
    def handle_for_statement(stmt)
      stmt.accept(ForStatementAnalyzer.new(@phase_ctxt, @interp))
    end

    class ForStatementAnalyzer < Cc1::SyntaxTreeVisitor
      include ReportUtil

      def initialize(phase_ctxt, interp)
        @phase_ctxt = phase_ctxt
        @interp     = interp
        @reported   = false
      end

      def visit_for_statement(node)
        node.condition_statement.accept(self)
        node.expression.accept(self) if node.expression
      end

      def visit_c99_for_statement(node)
        node.condition_statement.accept(self)
        node.expression.accept(self) if node.expression
      end

      def visit_object_specifier(node)
        return if @reported

        if var = @interp.variable_named(node.identifier.value)
          if var.type.scalar? && var.type.floating?
            W(node.location)
            @reported = true
          end
        end
      end

      private
      extend Forwardable

      def_delegator :@phase_ctxt, :report
      private :report

      def_delegator :@phase_ctxt, :message_catalog
      private :message_catalog

      def suppressors
        @phase_ctxt[:suppressors]
      end
    end
    private_constant :ForStatementAnalyzer
  end

  class W0112 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_equality_expr_evaled += T(:check_equality)
    end

    private
    def check_equality(expr, lhs_var, rhs_var, *)
      if lhs_var.type.scalar? && lhs_var.type.floating? and
          rhs_var.type.scalar? && rhs_var.type.floating?
        W(expr.location)
      end
    end
  end

  class W0114 < CodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def do_prepare(phase_ctxt) end

    def do_execute(phase_ctxt)
      phase_ctxt[:cc1_syntax_tree].accept(Visitor.new(phase_ctxt))
    end

    class Visitor < Cc1::SyntaxTreeVisitor
      include ReportUtil

      def initialize(phase_ctxt)
        @phase_ctxt = phase_ctxt
        @logical_op_num = 0
      end

      def visit_if_statement(node)
        if node.analysis_target?(traits)
          @logical_op_num = 0
          node.expression.accept(self)
          check_logical_operation(node.location)
          node.statement.accept(self)
        end
      end

      def visit_if_else_statement(node)
        if node.analysis_target?(traits)
          @logical_op_num = 0
          node.expression.accept(self)
          check_logical_operation(node.location)
          node.then_statement.accept(self)
          node.else_statement.accept(self)
        end
      end

      def visit_while_statement(node)
        if node.analysis_target?(traits)
          @logical_op_num = 0
          node.expression.accept(self)
          check_logical_operation(node.location)
          node.statement.accept(self)
        end
      end

      def visit_do_statement(node)
        if node.analysis_target?(traits)
          node.statement.accept(self)
          @logical_op_num = 0
          node.expression.accept(self)
          check_logical_operation(node.location)
        end
      end

      def visit_for_statement(node)
        if node.analysis_target?(traits)
          @logical_op_num = 0
          node.condition_statement.accept(self)
          check_logical_operation(node.location)
          node.body_statement.accept(self)
        end
      end

      def visit_c99_for_statement(node)
        if node.analysis_target?(traits)
          @logical_op_num = 0
          node.condition_statement.accept(self)
          check_logical_operation(node.location)
          node.body_statement.accept(self)
        end
      end

      def visit_unary_arithmetic_expression(node)
        if node.analysis_target?(traits)
          if node.operator.type == "!"
            @logical_op_num += 1
          end
          super
        end
      end

      def visit_relational_expression(node)
        if node.analysis_target?(traits)
          @logical_op_num += 1
          super
        end
      end

      def visit_equality_expression(node)
        if node.analysis_target?(traits)
          @logical_op_num += 1
          super
        end
      end

      def visit_logical_and_expression(node)
        if node.analysis_target?(traits)
          @logical_op_num += 1
          super
        end
      end

      def visit_logical_or_expression(node)
        if node.analysis_target?(traits)
          @logical_op_num += 1
          super
        end
      end

      def visit_conditional_expression(node)
        if node.analysis_target?(traits)
          @logical_op_num = 0
          node.condition.accept(self)
          check_logical_operation(node.condition.location)
          node.then_expression.accept(self)
          node.else_expression.accept(self)
        end
      end

      private
      def check_logical_operation(loc)
        W(loc) if @logical_op_num == 0
      end

      extend Forwardable

      def_delegator :@phase_ctxt, :traits
      private :traits

      def_delegator :@phase_ctxt, :report
      private :report

      def_delegator :@phase_ctxt, :message_catalog
      private :message_catalog

      def suppressors
        @phase_ctxt[:suppressors]
      end
    end
    private_constant :Visitor
  end

  class W0115 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_shift_expr_evaled += T(:check)
    end

    private
    def check(shift_expr, lhs_var, rhs_var, *)
      op = shift_expr.operator.type
      return unless op == "<<" || op == "<<="

      return if lhs_var.type.signed?

      if must_overflow?(lhs_var, rhs_var)
        W(shift_expr.location)
      end
    end

    def must_overflow?(lhs_var, rhs_var)
      comp_val = lhs_var.value << rhs_var.value
      comp_val.must_be_greater_than?(@interp.scalar_value_of(lhs_var.type.max))
    end
  end

  class W0116 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_shift_expr_evaled += T(:check)
    end

    private
    def check(shift_expr, lhs_var, rhs_var, *)
      operator = shift_expr.operator.type
      return unless operator == "<<" || operator == "<<="

      return if lhs_var.type.signed?

      if !must_overflow?(lhs_var, rhs_var) && may_overflow?(lhs_var, rhs_var)
        W(shift_expr.location)
      end
    end

    def must_overflow?(lhs_var, rhs_var)
      comp_val = lhs_var.value << rhs_var.value
      comp_val.must_be_greater_than?(@interp.scalar_value_of(lhs_var.type.max))
    end

    def may_overflow?(lhs_var, rhs_var)
      comp_val = lhs_var.value << rhs_var.value
      comp_val.may_be_greater_than?(@interp.scalar_value_of(lhs_var.type.max))
    end
  end

  class W0117 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_explicit_function_declared += M(:declare_function)
      interp.on_variable_declared          += M(:declare_variable)
      interp.on_explicit_function_defined  += T(:check_function)
      interp.on_variable_defined           += T(:check_variable)
      @target_fpath  = phase_ctxt[:sources].first.fpath
      @external_syms = Set.new
    end

    private
    def declare_function(*, fun)
      if fun.named? && fun.declared_as_extern?
        @external_syms.add(fun.name)
      end
    end

    def declare_variable(*, var)
      if var.named? && var.declared_as_extern?
        @external_syms.add(var.name)
      end
    end

    def check_function(fun_def, fun)
      if fun.named? && fun.declared_as_extern?
        return if fun.name == "main"

        unless @external_syms.include?(fun.name)
          if fun_def.location.fpath == @target_fpath
            W(fun_def.location, fun.name)
          end
        end
      end
    end

    def check_variable(var_def, var)
      if var.named? && var.declared_as_extern?
        unless @external_syms.include?(var.name)
          if var_def.location.fpath == @target_fpath
            W(var_def.location, var.name)
          end
        end
      end
    end
  end

  class W0118 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      fst_src = phase_ctxt[:sources].first
      if fst_src && fst_src.analysis_target?(traits)
        interp.on_explicit_function_declared += M(:check_function)
        interp.on_variable_declared          += M(:check_variable)
        @target_fpath  = fst_src.fpath
        @external_syms = Set.new
      end
    end

    private
    def check_function(fun_dcl, fun)
      if fun.named? && fun.declared_as_extern?
        unless @external_syms.include?(fun.name)
          if fun_dcl.location.fpath.identical?(@target_fpath)
            W(fun_dcl.location, fun.name)
          else
            @external_syms.add(fun.name)
          end
        end
      end
    end

    def check_variable(var_dcl, var)
      if var.named? && var.declared_as_extern?
        unless @external_syms.include?(var.name)
          if var_dcl.location.fpath.identical?(@target_fpath)
            W(var_dcl.location, var.name)
          else
            @external_syms.add(var.name)
          end
        end
      end
    end
  end

  class W0119 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_implicit_conv_performed += T(:check)
    end

    private
    def check(init_or_expr, from_var, to_var)
      if match?(from_var, to_var)
        W(init_or_expr.location)
      end
    end

    def from_type
      @interp.char_t
    end

    def to_type
      @interp.signed_char_t
    end

    def match?(from_var, to_var)
      unless from_var.type.same_as?(from_type) && to_var.type.same_as?(to_type)
        return false
      end

      if char_type_family?(from_type) &&
          from_var.type.explicitly_signed? != from_type.explicitly_signed?
        return false
      end
      if char_type_family?(to_type) &&
          to_var.type.explicitly_signed? != to_type.explicitly_signed?
        return false
      end

      true
    end

    def char_type_family?(type)
      type == @interp.char_t ||
        type == @interp.signed_char_t || type == @interp.unsigned_char_t
    end
  end

  class W0120 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.char_t
    end

    def to_type
      @interp.unsigned_char_t
    end
  end

  class W0121 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.char_t
    end

    def to_type
      @interp.signed_short_t
    end
  end

  class W0122 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.char_t
    end

    def to_type
      @interp.unsigned_short_t
    end
  end

  class W0123 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.char_t
    end

    def to_type
      @interp.signed_int_t
    end
  end

  class W0124 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.char_t
    end

    def to_type
      @interp.unsigned_int_t
    end
  end

  class W0125 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.char_t
    end

    def to_type
      @interp.signed_long_t
    end
  end

  class W0126 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.char_t
    end

    def to_type
      @interp.unsigned_long_t
    end
  end

  class W0127 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.char_t
    end

    def to_type
      @interp.float_t
    end
  end

  class W0128 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.char_t
    end

    def to_type
      @interp.double_t
    end
  end

  class W0129 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.char_t
    end

    def to_type
      @interp.long_double_t
    end
  end

  class W0130 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.char_t
    end

    def to_type
      @interp.signed_long_long_t
    end
  end

  class W0131 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.char_t
    end

    def to_type
      @interp.unsigned_long_long_t
    end
  end

  class W0132 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_char_t
    end

    def to_type
      @interp.char_t
    end
  end

  class W0133 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_char_t
    end

    def to_type
      @interp.char_t
    end
  end

  class W0134 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_short_t
    end

    def to_type
      @interp.char_t
    end
  end

  class W0135 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_short_t
    end

    def to_type
      @interp.char_t
    end
  end

  class W0136 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_int_t
    end

    def to_type
      @interp.char_t
    end
  end

  class W0137 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_int_t
    end

    def to_type
      @interp.char_t
    end
  end

  class W0138 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_long_t
    end

    def to_type
      @interp.char_t
    end
  end

  class W0139 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_long_t
    end

    def to_type
      @interp.char_t
    end
  end

  class W0140 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_long_long_t
    end

    def to_type
      @interp.char_t
    end
  end

  class W0141 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_long_long_t
    end

    def to_type
      @interp.char_t
    end
  end

  class W0142 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_char_t
    end

    def to_type
      @interp.signed_char_t
    end
  end

  class W0143 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_short_t
    end

    def to_type
      @interp.signed_char_t
    end
  end

  class W0144 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_short_t
    end

    def to_type
      @interp.signed_short_t
    end
  end

  class W0145 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_int_t
    end

    def to_type
      @interp.signed_char_t
    end
  end

  class W0146 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_int_t
    end

    def to_type
      @interp.signed_short_t
    end
  end

  class W0147 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_int_t
    end

    def to_type
      @interp.signed_int_t
    end
  end

  class W0148 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_long_t
    end

    def to_type
      @interp.signed_char_t
    end
  end

  class W0149 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_long_t
    end

    def to_type
      @interp.signed_short_t
    end
  end

  class W0150 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_long_t
    end

    def to_type
      @interp.signed_int_t
    end
  end

  class W0151 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_long_t
    end

    def to_type
      @interp.signed_long_t
    end
  end

  class W0152 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_long_long_t
    end

    def to_type
      @interp.signed_char_t
    end
  end

  class W0153 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_long_long_t
    end

    def to_type
      @interp.signed_short_t
    end
  end

  class W0154 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_long_long_t
    end

    def to_type
      @interp.signed_int_t
    end
  end

  class W0155 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_long_long_t
    end

    def to_type
      @interp.signed_long_t
    end
  end

  class W0156 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_long_long_t
    end

    def to_type
      @interp.signed_long_long_t
    end
  end

  class W0157 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_char_t
    end

    def to_type
      @interp.unsigned_char_t
    end
  end

  class W0158 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_char_t
    end

    def to_type
      @interp.unsigned_short_t
    end
  end

  class W0159 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_char_t
    end

    def to_type
      @interp.unsigned_int_t
    end
  end

  class W0160 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_char_t
    end

    def to_type
      @interp.unsigned_long_t
    end
  end

  class W0161 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_short_t
    end

    def to_type
      @interp.unsigned_char_t
    end
  end

  class W0162 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_short_t
    end

    def to_type
      @interp.unsigned_short_t
    end
  end

  class W0163 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_short_t
    end

    def to_type
      @interp.unsigned_int_t
    end
  end

  class W0164 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_short_t
    end

    def to_type
      @interp.unsigned_long_t
    end
  end

  class W0165 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_int_t
    end

    def to_type
      @interp.unsigned_char_t
    end
  end

  class W0166 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_int_t
    end

    def to_type
      @interp.unsigned_short_t
    end
  end

  class W0167 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_int_t
    end

    def to_type
      @interp.unsigned_int_t
    end
  end

  class W0168 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_int_t
    end

    def to_type
      @interp.unsigned_long_t
    end
  end

  class W0169 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_long_t
    end

    def to_type
      @interp.unsigned_char_t
    end
  end

  class W0170 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_long_t
    end

    def to_type
      @interp.unsigned_short_t
    end
  end

  class W0171 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_long_t
    end

    def to_type
      @interp.unsigned_int_t
    end
  end

  class W0172 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_long_t
    end

    def to_type
      @interp.unsigned_long_t
    end
  end

  class W0173 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_char_t
    end

    def to_type
      @interp.unsigned_long_long_t
    end
  end

  class W0174 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_short_t
    end

    def to_type
      @interp.unsigned_long_long_t
    end
  end

  class W0175 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_int_t
    end

    def to_type
      @interp.unsigned_long_long_t
    end
  end

  class W0176 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_long_t
    end

    def to_type
      @interp.unsigned_long_long_t
    end
  end

  class W0177 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_long_long_t
    end

    def to_type
      @interp.unsigned_char_t
    end
  end

  class W0178 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_long_long_t
    end

    def to_type
      @interp.unsigned_short_t
    end
  end

  class W0179 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_long_long_t
    end

    def to_type
      @interp.unsigned_int_t
    end
  end

  class W0180 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_long_long_t
    end

    def to_type
      @interp.unsigned_long_t
    end
  end

  class W0181 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_long_long_t
    end

    def to_type
      @interp.unsigned_long_long_t
    end
  end

  class W0182 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_char_t
    end

    def to_type
      @interp.float_t
    end
  end

  class W0183 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_char_t
    end

    def to_type
      @interp.double_t
    end
  end

  class W0184 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_char_t
    end

    def to_type
      @interp.long_double_t
    end
  end

  class W0185 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_char_t
    end

    def to_type
      @interp.float_t
    end
  end

  class W0186 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_char_t
    end

    def to_type
      @interp.double_t
    end
  end

  class W0187 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_char_t
    end

    def to_type
      @interp.long_double_t
    end
  end

  class W0188 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_short_t
    end

    def to_type
      @interp.float_t
    end
  end

  class W0189 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_short_t
    end

    def to_type
      @interp.double_t
    end
  end

  class W0190 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_short_t
    end

    def to_type
      @interp.long_double_t
    end
  end

  class W0191 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_short_t
    end

    def to_type
      @interp.float_t
    end
  end

  class W0192 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_short_t
    end

    def to_type
      @interp.double_t
    end
  end

  class W0193 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_short_t
    end

    def to_type
      @interp.long_double_t
    end
  end

  class W0194 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_int_t
    end

    def to_type
      @interp.float_t
    end
  end

  class W0195 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_int_t
    end

    def to_type
      @interp.double_t
    end
  end

  class W0196 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_int_t
    end

    def to_type
      @interp.long_double_t
    end
  end

  class W0197 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_int_t
    end

    def to_type
      @interp.float_t
    end
  end

  class W0198 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_int_t
    end

    def to_type
      @interp.double_t
    end
  end

  class W0199 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_int_t
    end

    def to_type
      @interp.long_double_t
    end
  end

  class W0200 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_long_t
    end

    def to_type
      @interp.float_t
    end
  end

  class W0201 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_long_t
    end

    def to_type
      @interp.double_t
    end
  end

  class W0202 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_long_t
    end

    def to_type
      @interp.long_double_t
    end
  end

  class W0203 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_long_t
    end

    def to_type
      @interp.float_t
    end
  end

  class W0204 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_long_t
    end

    def to_type
      @interp.double_t
    end
  end

  class W0205 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_long_t
    end

    def to_type
      @interp.long_double_t
    end
  end

  class W0206 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_long_long_t
    end

    def to_type
      @interp.float_t
    end
  end

  class W0207 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_long_long_t
    end

    def to_type
      @interp.double_t
    end
  end

  class W0208 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_long_long_t
    end

    def to_type
      @interp.long_double_t
    end
  end

  class W0209 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_long_long_t
    end

    def to_type
      @interp.float_t
    end
  end

  class W0210 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_long_long_t
    end

    def to_type
      @interp.double_t
    end
  end

  class W0211 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_long_long_t
    end

    def to_type
      @interp.long_double_t
    end
  end

  class W0212 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.float_t
    end

    def to_type
      @interp.char_t
    end
  end

  class W0213 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.float_t
    end

    def to_type
      @interp.signed_char_t
    end
  end

  class W0214 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.float_t
    end

    def to_type
      @interp.unsigned_char_t
    end
  end

  class W0215 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.float_t
    end

    def to_type
      @interp.signed_short_t
    end
  end

  class W0216 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.float_t
    end

    def to_type
      @interp.unsigned_short_t
    end
  end

  class W0217 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.float_t
    end

    def to_type
      @interp.signed_int_t
    end
  end

  class W0218 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.float_t
    end

    def to_type
      @interp.unsigned_int_t
    end
  end

  class W0219 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.float_t
    end

    def to_type
      @interp.signed_long_t
    end
  end

  class W0220 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.float_t
    end

    def to_type
      @interp.unsigned_long_t
    end
  end

  class W0221 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.double_t
    end

    def to_type
      @interp.char_t
    end
  end

  class W0222 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.double_t
    end

    def to_type
      @interp.signed_char_t
    end
  end

  class W0223 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.double_t
    end

    def to_type
      @interp.unsigned_char_t
    end
  end

  class W0224 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.double_t
    end

    def to_type
      @interp.signed_short_t
    end
  end

  class W0225 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.double_t
    end

    def to_type
      @interp.unsigned_short_t
    end
  end

  class W0226 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.double_t
    end

    def to_type
      @interp.signed_int_t
    end
  end

  class W0227 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.double_t
    end

    def to_type
      @interp.unsigned_int_t
    end
  end

  class W0228 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.double_t
    end

    def to_type
      @interp.signed_long_t
    end
  end

  class W0229 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.double_t
    end

    def to_type
      @interp.unsigned_long_t
    end
  end

  class W0230 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.long_double_t
    end

    def to_type
      @interp.char_t
    end
  end

  class W0231 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.long_double_t
    end

    def to_type
      @interp.signed_char_t
    end
  end

  class W0232 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.long_double_t
    end

    def to_type
      @interp.unsigned_char_t
    end
  end

  class W0233 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.long_double_t
    end

    def to_type
      @interp.signed_short_t
    end
  end

  class W0234 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.long_double_t
    end

    def to_type
      @interp.unsigned_short_t
    end
  end

  class W0235 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.long_double_t
    end

    def to_type
      @interp.signed_int_t
    end
  end

  class W0236 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.long_double_t
    end

    def to_type
      @interp.unsigned_int_t
    end
  end

  class W0237 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.long_double_t
    end

    def to_type
      @interp.signed_long_t
    end
  end

  class W0238 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.long_double_t
    end

    def to_type
      @interp.unsigned_long_t
    end
  end

  class W0239 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.float_t
    end

    def to_type
      @interp.signed_long_long_t
    end
  end

  class W0240 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.float_t
    end

    def to_type
      @interp.unsigned_long_long_t
    end
  end

  class W0241 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.double_t
    end

    def to_type
      @interp.signed_long_long_t
    end
  end

  class W0242 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.double_t
    end

    def to_type
      @interp.unsigned_long_long_t
    end
  end

  class W0243 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.long_double_t
    end

    def to_type
      @interp.signed_long_long_t
    end
  end

  class W0244 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.long_double_t
    end

    def to_type
      @interp.unsigned_long_long_t
    end
  end

  class W0245 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_char_t
    end

    def to_type
      @interp.signed_short_t
    end
  end

  class W0246 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_char_t
    end

    def to_type
      @interp.signed_int_t
    end
  end

  class W0247 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_char_t
    end

    def to_type
      @interp.signed_long_t
    end
  end

  class W0248 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_short_t
    end

    def to_type
      @interp.signed_int_t
    end
  end

  class W0249 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_short_t
    end

    def to_type
      @interp.signed_long_t
    end
  end

  class W0250 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_int_t
    end

    def to_type
      @interp.signed_long_t
    end
  end

  class W0251 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_char_t
    end

    def to_type
      @interp.signed_long_long_t
    end
  end

  class W0252 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_short_t
    end

    def to_type
      @interp.signed_long_long_t
    end
  end

  class W0253 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_int_t
    end

    def to_type
      @interp.signed_long_long_t
    end
  end

  class W0254 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_long_t
    end

    def to_type
      @interp.signed_long_long_t
    end
  end

  class W0255 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_function_started   += T(:enter_function)
      @interp.on_function_ended     += T(:leave_function)
      @interp.on_return_stmt_evaled += T(:check)
      @cur_fun = nil
    end

    private
    def enter_function(fun_def, fun)
      @cur_fun = fun
    end

    def leave_function(fun_def, fun)
      @cur_fun = nil
    end

    def check(retn_stmt, retn_var)
      if @cur_fun && retn_var
        if match?(retn_var.type, @cur_fun.type.return_type)
          W(retn_stmt.location, @cur_fun.name)
        end
      end
    end

    def from_type
      @interp.char_t
    end

    def to_type
      @interp.signed_char_t
    end

    def match?(expr_type, fun_type)
      unless expr_type.same_as?(from_type) && fun_type.same_as?(to_type)
        return false
      end

      if char_type_family?(expr_type) &&
          expr_type.explicitly_signed? != from_type.explicitly_signed?
        return false
      end
      if char_type_family?(fun_type) &&
          fun_type.explicitly_signed? != to_type.explicitly_signed?
        return false
      end

      true
    end

    def char_type_family?(type)
      type == @interp.char_t ||
        type == @interp.signed_char_t || type == @interp.unsigned_char_t
    end
  end

  class W0256 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.char_t
    end

    def to_type
      @interp.unsigned_char_t
    end
  end

  class W0257 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.char_t
    end

    def to_type
      @interp.signed_short_t
    end
  end

  class W0258 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.char_t
    end

    def to_type
      @interp.unsigned_short_t
    end
  end

  class W0259 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.char_t
    end

    def to_type
      @interp.signed_int_t
    end
  end

  class W0260 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.char_t
    end

    def to_type
      @interp.unsigned_int_t
    end
  end

  class W0261 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.char_t
    end

    def to_type
      @interp.signed_long_t
    end
  end

  class W0262 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.char_t
    end

    def to_type
      @interp.unsigned_long_t
    end
  end

  class W0263 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.char_t
    end

    def to_type
      @interp.float_t
    end
  end

  class W0264 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.char_t
    end

    def to_type
      @interp.double_t
    end
  end

  class W0265 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.char_t
    end

    def to_type
      @interp.long_double_t
    end
  end

  class W0266 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.char_t
    end

    def to_type
      @interp.signed_long_long_t
    end
  end

  class W0267 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.char_t
    end

    def to_type
      @interp.unsigned_long_long_t
    end
  end

  class W0268 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_char_t
    end

    def to_type
      @interp.char_t
    end
  end

  class W0269 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_char_t
    end

    def to_type
      @interp.char_t
    end
  end

  class W0270 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_short_t
    end

    def to_type
      @interp.char_t
    end
  end

  class W0271 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_short_t
    end

    def to_type
      @interp.char_t
    end
  end

  class W0272 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_int_t
    end

    def to_type
      @interp.char_t
    end
  end

  class W0273 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_int_t
    end

    def to_type
      @interp.char_t
    end
  end

  class W0274 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_long_t
    end

    def to_type
      @interp.char_t
    end
  end

  class W0275 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_long_t
    end

    def to_type
      @interp.char_t
    end
  end

  class W0276 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_long_long_t
    end

    def to_type
      @interp.char_t
    end
  end

  class W0277 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_long_long_t
    end

    def to_type
      @interp.char_t
    end
  end

  class W0278 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_char_t
    end

    def to_type
      @interp.signed_char_t
    end
  end

  class W0279 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_short_t
    end

    def to_type
      @interp.signed_char_t
    end
  end

  class W0280 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_short_t
    end

    def to_type
      @interp.signed_short_t
    end
  end

  class W0281 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_int_t
    end

    def to_type
      @interp.signed_char_t
    end
  end

  class W0282 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_int_t
    end

    def to_type
      @interp.signed_short_t
    end
  end

  class W0283 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_int_t
    end

    def to_type
      @interp.signed_int_t
    end
  end

  class W0284 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_long_t
    end

    def to_type
      @interp.signed_char_t
    end
  end

  class W0285 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_long_t
    end

    def to_type
      @interp.signed_short_t
    end
  end

  class W0286 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_long_t
    end

    def to_type
      @interp.signed_int_t
    end
  end

  class W0287 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_long_t
    end

    def to_type
      @interp.signed_long_t
    end
  end

  class W0288 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_long_long_t
    end

    def to_type
      @interp.signed_char_t
    end
  end

  class W0289 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_long_long_t
    end

    def to_type
      @interp.signed_short_t
    end
  end

  class W0290 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_long_long_t
    end

    def to_type
      @interp.signed_int_t
    end
  end

  class W0291 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_long_long_t
    end

    def to_type
      @interp.signed_long_t
    end
  end

  class W0292 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_long_long_t
    end

    def to_type
      @interp.signed_long_long_t
    end
  end

  class W0293 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_char_t
    end

    def to_type
      @interp.unsigned_char_t
    end
  end

  class W0294 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_char_t
    end

    def to_type
      @interp.unsigned_short_t
    end
  end

  class W0295 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_char_t
    end

    def to_type
      @interp.unsigned_int_t
    end
  end

  class W0296 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_char_t
    end

    def to_type
      @interp.unsigned_long_t
    end
  end

  class W0297 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_short_t
    end

    def to_type
      @interp.unsigned_char_t
    end
  end

  class W0298 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_short_t
    end

    def to_type
      @interp.unsigned_short_t
    end
  end

  class W0299 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_short_t
    end

    def to_type
      @interp.unsigned_int_t
    end
  end

  class W0300 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_short_t
    end

    def to_type
      @interp.unsigned_long_t
    end
  end

  class W0301 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_int_t
    end

    def to_type
      @interp.unsigned_char_t
    end
  end

  class W0302 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_int_t
    end

    def to_type
      @interp.unsigned_short_t
    end
  end

  class W0303 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_int_t
    end

    def to_type
      @interp.unsigned_int_t
    end
  end

  class W0304 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_int_t
    end

    def to_type
      @interp.unsigned_long_t
    end
  end

  class W0305 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_long_t
    end

    def to_type
      @interp.unsigned_char_t
    end
  end

  class W0306 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_long_t
    end

    def to_type
      @interp.unsigned_short_t
    end
  end

  class W0307 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_long_t
    end

    def to_type
      @interp.unsigned_int_t
    end
  end

  class W0308 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_long_t
    end

    def to_type
      @interp.unsigned_long_t
    end
  end

  class W0309 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_char_t
    end

    def to_type
      @interp.unsigned_long_long_t
    end
  end

  class W0310 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_short_t
    end

    def to_type
      @interp.unsigned_long_long_t
    end
  end

  class W0311 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_int_t
    end

    def to_type
      @interp.unsigned_long_long_t
    end
  end

  class W0312 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_long_t
    end

    def to_type
      @interp.unsigned_long_long_t
    end
  end

  class W0313 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_long_long_t
    end

    def to_type
      @interp.unsigned_char_t
    end
  end

  class W0314 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_long_long_t
    end

    def to_type
      @interp.unsigned_short_t
    end
  end

  class W0315 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_long_long_t
    end

    def to_type
      @interp.unsigned_int_t
    end
  end

  class W0316 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_long_long_t
    end

    def to_type
      @interp.unsigned_long_t
    end
  end

  class W0317 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_long_long_t
    end

    def to_type
      @interp.unsigned_long_long_t
    end
  end

  class W0318 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_char_t
    end

    def to_type
      @interp.float_t
    end
  end

  class W0319 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_char_t
    end

    def to_type
      @interp.double_t
    end
  end

  class W0320 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_char_t
    end

    def to_type
      @interp.long_double_t
    end
  end

  class W0321 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_char_t
    end

    def to_type
      @interp.float_t
    end
  end

  class W0322 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_char_t
    end

    def to_type
      @interp.double_t
    end
  end

  class W0323 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_char_t
    end

    def to_type
      @interp.long_double_t
    end
  end

  class W0324 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_short_t
    end

    def to_type
      @interp.float_t
    end
  end

  class W0325 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_short_t
    end

    def to_type
      @interp.double_t
    end
  end

  class W0326 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_short_t
    end

    def to_type
      @interp.long_double_t
    end
  end

  class W0327 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_short_t
    end

    def to_type
      @interp.float_t
    end
  end

  class W0328 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_short_t
    end

    def to_type
      @interp.double_t
    end
  end

  class W0329 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_short_t
    end

    def to_type
      @interp.long_double_t
    end
  end

  class W0330 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_int_t
    end

    def to_type
      @interp.float_t
    end
  end

  class W0331 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_int_t
    end

    def to_type
      @interp.double_t
    end
  end

  class W0332 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_int_t
    end

    def to_type
      @interp.long_double_t
    end
  end

  class W0333 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_int_t
    end

    def to_type
      @interp.float_t
    end
  end

  class W0334 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_int_t
    end

    def to_type
      @interp.double_t
    end
  end

  class W0335 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_int_t
    end

    def to_type
      @interp.long_double_t
    end
  end

  class W0336 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_long_t
    end

    def to_type
      @interp.float_t
    end
  end

  class W0337 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_long_t
    end

    def to_type
      @interp.double_t
    end
  end

  class W0338 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_long_t
    end

    def to_type
      @interp.long_double_t
    end
  end

  class W0339 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_long_t
    end

    def to_type
      @interp.float_t
    end
  end

  class W0340 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_long_t
    end

    def to_type
      @interp.double_t
    end
  end

  class W0341 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_long_t
    end

    def to_type
      @interp.long_double_t
    end
  end

  class W0342 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_long_long_t
    end

    def to_type
      @interp.float_t
    end
  end

  class W0343 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_long_long_t
    end

    def to_type
      @interp.double_t
    end
  end

  class W0344 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_long_long_t
    end

    def to_type
      @interp.long_double_t
    end
  end

  class W0345 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_long_long_t
    end

    def to_type
      @interp.float_t
    end
  end

  class W0346 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_long_long_t
    end

    def to_type
      @interp.double_t
    end
  end

  class W0347 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_long_long_t
    end

    def to_type
      @interp.long_double_t
    end
  end

  class W0348 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.float_t
    end

    def to_type
      @interp.char_t
    end
  end

  class W0349 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.float_t
    end

    def to_type
      @interp.signed_char_t
    end
  end

  class W0350 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.float_t
    end

    def to_type
      @interp.unsigned_char_t
    end
  end

  class W0351 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.float_t
    end

    def to_type
      @interp.signed_short_t
    end
  end

  class W0352 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.float_t
    end

    def to_type
      @interp.unsigned_short_t
    end
  end

  class W0353 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.float_t
    end

    def to_type
      @interp.signed_int_t
    end
  end

  class W0354 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.float_t
    end

    def to_type
      @interp.unsigned_int_t
    end
  end

  class W0355 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.float_t
    end

    def to_type
      @interp.signed_long_t
    end
  end

  class W0356 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.float_t
    end

    def to_type
      @interp.unsigned_long_t
    end
  end

  class W0357 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.double_t
    end

    def to_type
      @interp.char_t
    end
  end

  class W0358 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.double_t
    end

    def to_type
      @interp.signed_char_t
    end
  end

  class W0359 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.double_t
    end

    def to_type
      @interp.unsigned_char_t
    end
  end

  class W0360 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.double_t
    end

    def to_type
      @interp.signed_short_t
    end
  end

  class W0361 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.double_t
    end

    def to_type
      @interp.unsigned_short_t
    end
  end

  class W0362 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.double_t
    end

    def to_type
      @interp.signed_int_t
    end
  end

  class W0363 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.double_t
    end

    def to_type
      @interp.unsigned_int_t
    end
  end

  class W0364 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.double_t
    end

    def to_type
      @interp.signed_long_t
    end
  end

  class W0365 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.double_t
    end

    def to_type
      @interp.unsigned_long_t
    end
  end

  class W0366 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.long_double_t
    end

    def to_type
      @interp.char_t
    end
  end

  class W0367 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.long_double_t
    end

    def to_type
      @interp.signed_char_t
    end
  end

  class W0368 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.long_double_t
    end

    def to_type
      @interp.unsigned_char_t
    end
  end

  class W0369 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.long_double_t
    end

    def to_type
      @interp.signed_short_t
    end
  end

  class W0370 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.long_double_t
    end

    def to_type
      @interp.unsigned_short_t
    end
  end

  class W0371 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.long_double_t
    end

    def to_type
      @interp.signed_int_t
    end
  end

  class W0372 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.long_double_t
    end

    def to_type
      @interp.unsigned_int_t
    end
  end

  class W0373 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.long_double_t
    end

    def to_type
      @interp.signed_long_t
    end
  end

  class W0374 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.long_double_t
    end

    def to_type
      @interp.unsigned_long_t
    end
  end

  class W0375 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.float_t
    end

    def to_type
      @interp.signed_long_long_t
    end
  end

  class W0376 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.float_t
    end

    def to_type
      @interp.unsigned_long_long_t
    end
  end

  class W0377 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.double_t
    end

    def to_type
      @interp.signed_long_long_t
    end
  end

  class W0378 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.double_t
    end

    def to_type
      @interp.unsigned_long_long_t
    end
  end

  class W0379 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.long_double_t
    end

    def to_type
      @interp.signed_long_long_t
    end
  end

  class W0380 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.long_double_t
    end

    def to_type
      @interp.unsigned_long_long_t
    end
  end

  class W0381 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_short_t
    end

    def to_type
      @interp.signed_char_t
    end
  end

  class W0382 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_short_t
    end

    def to_type
      @interp.unsigned_char_t
    end
  end

  class W0383 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_int_t
    end

    def to_type
      @interp.signed_char_t
    end
  end

  class W0384 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_int_t
    end

    def to_type
      @interp.signed_short_t
    end
  end

  class W0385 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_int_t
    end

    def to_type
      @interp.unsigned_char_t
    end
  end

  class W0386 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_int_t
    end

    def to_type
      @interp.unsigned_short_t
    end
  end

  class W0387 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_long_t
    end

    def to_type
      @interp.signed_char_t
    end
  end

  class W0388 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_long_t
    end

    def to_type
      @interp.signed_short_t
    end
  end

  class W0389 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_long_t
    end

    def to_type
      @interp.signed_int_t
    end
  end

  class W0390 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_long_t
    end

    def to_type
      @interp.unsigned_char_t
    end
  end

  class W0391 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_long_t
    end

    def to_type
      @interp.unsigned_short_t
    end
  end

  class W0392 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_long_t
    end

    def to_type
      @interp.unsigned_int_t
    end
  end

  class W0393 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_long_long_t
    end

    def to_type
      @interp.signed_char_t
    end
  end

  class W0394 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_long_long_t
    end

    def to_type
      @interp.signed_short_t
    end
  end

  class W0395 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_long_long_t
    end

    def to_type
      @interp.signed_int_t
    end
  end

  class W0396 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_long_long_t
    end

    def to_type
      @interp.signed_long_t
    end
  end

  class W0397 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_long_long_t
    end

    def to_type
      @interp.unsigned_char_t
    end
  end

  class W0398 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_long_long_t
    end

    def to_type
      @interp.unsigned_short_t
    end
  end

  class W0399 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_long_long_t
    end

    def to_type
      @interp.unsigned_int_t
    end
  end

  class W0400 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_long_long_t
    end

    def to_type
      @interp.unsigned_long_t
    end
  end

  class W0401 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_char_t
    end

    def to_type
      @interp.signed_short_t
    end
  end

  class W0402 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_char_t
    end

    def to_type
      @interp.signed_int_t
    end
  end

  class W0403 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_char_t
    end

    def to_type
      @interp.signed_long_t
    end
  end

  class W0404 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_short_t
    end

    def to_type
      @interp.signed_int_t
    end
  end

  class W0405 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_short_t
    end

    def to_type
      @interp.signed_long_t
    end
  end

  class W0406 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_int_t
    end

    def to_type
      @interp.signed_long_t
    end
  end

  class W0407 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_char_t
    end

    def to_type
      @interp.signed_long_long_t
    end
  end

  class W0408 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_short_t
    end

    def to_type
      @interp.signed_long_long_t
    end
  end

  class W0409 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_int_t
    end

    def to_type
      @interp.signed_long_long_t
    end
  end

  class W0410 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_long_t
    end

    def to_type
      @interp.signed_long_long_t
    end
  end

  class W0411 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_enum_type_declaration += T(:check)
    end

    private
    def check(node)
      if enums = node.enum_specifier.enumerators
        exprs = enums.map { |enum| enum.expression }
        return if exprs.all? { |expr| expr.nil? }
        return if exprs.first && exprs[1..-1].all? { |expr| expr.nil? }
        return if exprs.all? { |expr| !expr.nil? }
        W(node.location)
      end
    end
  end

  class W0413 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_if_statement      += T(:check_if_statement)
      visitor.enter_if_else_statement += T(:check_if_else_statement)
      visitor.enter_while_statement   += T(:check_while_statement)
      visitor.enter_do_statement      += T(:check_do_statement)
      visitor.enter_for_statement     += T(:check_for_statement)
      visitor.enter_c99_for_statement += T(:check_for_statement)
    end

    private
    def check_if_statement(node)
      unless node.header_terminator.location.line_no ==
          node.statement.head_location.line_no
        unless node.statement.kind_of?(Cc1::CompoundStatement)
          W(node.statement.location)
        end
      end
    end

    def check_if_else_statement(node)
      unless node.then_header_terminator.location.line_no ==
          node.then_statement.head_location.line_no
        unless node.then_statement.kind_of?(Cc1::CompoundStatement)
          W(node.then_statement.location)
        end
      end

      unless node.else_header_terminator.location.line_no ==
          node.else_statement.head_location.line_no
        case node.else_statement
        when Cc1::CompoundStatement, Cc1::IfStatement, Cc1::IfElseStatement
        else
          W(node.else_statement.location)
        end
      end
    end

    def check_while_statement(node)
      unless node.header_terminator.location.line_no ==
          node.statement.head_location.line_no
        unless node.statement.kind_of?(Cc1::CompoundStatement)
          W(node.statement.location)
        end
      end
    end

    def check_do_statement(node)
      unless node.header_terminator.location.line_no ==
          node.statement.head_location.line_no
        unless node.statement.kind_of?(Cc1::CompoundStatement)
          W(node.statement.location)
        end
      end
    end

    def check_for_statement(node)
      unless node.header_terminator.location.line_no ==
          node.body_statement.head_location.line_no
        unless node.body_statement.kind_of?(Cc1::CompoundStatement)
          W(node.body_statement.location)
        end
      end
    end
  end

  class W0414 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_if_statement      += T(:check_if_statement)
      visitor.enter_if_else_statement += T(:check_if_else_statement)
      visitor.enter_while_statement   += T(:check_while_statement)
      visitor.enter_do_statement      += T(:check_do_statement)
      visitor.enter_for_statement     += T(:check_for_statement)
      visitor.enter_c99_for_statement += T(:check_for_statement)
    end

    private
    def check_if_statement(node)
      if node.header_terminator.location.line_no ==
          node.statement.head_location.line_no
        unless node.statement.kind_of?(Cc1::CompoundStatement)
          W(node.statement.location)
        end
      end
    end

    def check_if_else_statement(node)
      if node.then_header_terminator.location.line_no ==
          node.then_statement.head_location.line_no
        unless node.then_statement.kind_of?(Cc1::CompoundStatement)
          W(node.then_statement.location)
        end
      end

      if node.else_header_terminator.location.line_no ==
          node.else_statement.head_location.line_no
        case node.else_statement
        when Cc1::CompoundStatement, Cc1::IfStatement, Cc1::IfElseStatement
        else
          W(node.else_statement.location)
        end
      end
    end

    def check_while_statement(node)
      if node.header_terminator.location.line_no ==
          node.statement.head_location.line_no
        unless node.statement.kind_of?(Cc1::CompoundStatement)
          W(node.statement.location)
        end
      end
    end

    def check_do_statement(node)
      if node.header_terminator.location.line_no ==
          node.statement.head_location.line_no
        unless node.statement.kind_of?(Cc1::CompoundStatement)
          W(node.statement.location)
        end
      end
    end

    def check_for_statement(node)
      if node.header_terminator.location.line_no ==
          node.body_statement.head_location.line_no
        unless node.body_statement.kind_of?(Cc1::CompoundStatement)
          W(node.body_statement.location)
        end
      end
    end
  end

  class W0421 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_indirection_expr_evaled     += T(:check_indirection)
      @interp.on_member_access_expr_evaled   += T(:check_member_access)
      @interp.on_array_subscript_expr_evaled += T(:check_array_subscript)
    end

    private
    def check_indirection(expr, ptr_var, *)
      unless @interp.constant_expression?(expr.operand)
        if ptr_var.value.scalar? &&
            ptr_var.value.must_be_equal_to?(@interp.scalar_value_of(0))
          W(expr.location)
        end
      end
    end

    def check_member_access(expr, outer_var, *)
      return unless outer_var.type.pointer?
      unless @interp.constant_expression?(expr.expression)
        if outer_var.value.scalar? &&
            outer_var.value.must_be_equal_to?(@interp.scalar_value_of(0))
          W(expr.location)
        end
      end
    end

    def check_array_subscript(expr, ary_or_ptr, *)
      return unless ary_or_ptr.type.pointer?
      unless @interp.constant_expression?(expr.expression)
        if ary_or_ptr.value.scalar? &&
            ary_or_ptr.value.must_be_equal_to?(@interp.scalar_value_of(0))
          W(expr.location)
        end
      end
    end
  end

  class W0422 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_indirection_expr_evaled     += T(:check_indirection)
      @interp.on_member_access_expr_evaled   += T(:check_member_access)
      @interp.on_array_subscript_expr_evaled += T(:check_array_subscript)
    end

    private
    def check_indirection(expr, ptr_var, *)
      return if @interp.constant_expression?(expr.operand)
      return unless ptr_var.value.scalar?

      if !ptr_var.value.must_be_equal_to?(@interp.scalar_value_of(0)) &&
          ptr_var.value.may_be_equal_to?(@interp.scalar_value_of(0))
        W(expr.location)
      end
    end

    def check_member_access(expr, outer_var, *)
      return unless outer_var.type.pointer?
      return if @interp.constant_expression?(expr.expression)
      return unless outer_var.value.scalar?

      if !outer_var.value.must_be_equal_to?(@interp.scalar_value_of(0)) &&
          outer_var.value.may_be_equal_to?(@interp.scalar_value_of(0))
        W(expr.location)
      end
    end

    def check_array_subscript(expr, ary_or_ptr, *)
      return unless ary_or_ptr.type.pointer?
      return if @interp.constant_expression?(expr.expression)
      return unless ary_or_ptr.value.scalar?

      if !ary_or_ptr.value.must_be_equal_to?(@interp.scalar_value_of(0)) &&
          ary_or_ptr.value.may_be_equal_to?(@interp.scalar_value_of(0))
        W(expr.location)
      end
    end
  end

  class W0423 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_multiplicative_expr_evaled    += T(:check_binary)
      @interp.on_additive_expr_evaled          += T(:check_binary)
      @interp.on_shift_expr_evaled             += T(:check_binary)
      @interp.on_and_expr_evaled               += T(:check_binary)
      @interp.on_exclusive_or_expr_evaled      += T(:check_binary)
      @interp.on_inclusive_or_expr_evaled      += T(:check_binary)
      @interp.on_prefix_increment_expr_evaled  += T(:check_unary_prefix)
      @interp.on_postfix_increment_expr_evaled += T(:check_unary_postfix)
      @interp.on_prefix_decrement_expr_evaled  += T(:check_unary_prefix)
      @interp.on_postfix_decrement_expr_evaled += T(:check_unary_postfix)
    end

    private
    def check_binary(expr, lhs_var, rhs_var, *)
      lhs_type, lhs_val = lhs_var.type, lhs_var.value
      rhs_type, rhs_val = rhs_var.type, rhs_var.value

      if lhs_type.pointer? &&
          lhs_val.must_be_equal_to?(@interp.scalar_value_of(0))
        W(expr.lhs_operand.location)
      end

      if rhs_type.pointer? &&
          rhs_val.must_be_equal_to?(@interp.scalar_value_of(0))
        W(expr.rhs_operand.location)
      end
    end

    def check_unary_prefix(expr, ope_var, org_val)
      type, val = ope_var.type, org_val

      if type.pointer? && val.must_be_equal_to?(@interp.scalar_value_of(0))
        W(expr.operand.location)
      end
    end

    def check_unary_postfix(expr, ope_var, *)
      type, val = ope_var.type, ope_var.value

      if type.pointer? && val.must_be_equal_to?(@interp.scalar_value_of(0))
        W(expr.operand.location)
      end
    end
  end

  class W0424 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_multiplicative_expr_evaled    += T(:check_binary)
      @interp.on_additive_expr_evaled          += T(:check_binary)
      @interp.on_shift_expr_evaled             += T(:check_binary)
      @interp.on_and_expr_evaled               += T(:check_binary)
      @interp.on_exclusive_or_expr_evaled      += T(:check_binary)
      @interp.on_inclusive_or_expr_evaled      += T(:check_binary)
      @interp.on_prefix_increment_expr_evaled  += T(:check_unary_prefix)
      @interp.on_postfix_increment_expr_evaled += T(:check_unary_postfix)
      @interp.on_prefix_decrement_expr_evaled  += T(:check_unary_prefix)
      @interp.on_postfix_decrement_expr_evaled += T(:check_unary_postfix)
    end

    private
    def check_binary(expr, lhs_var, rhs_var, *)
      lhs_type, lhs_val = lhs_var.type, lhs_var.value
      rhs_type, rhs_val = rhs_var.type, rhs_var.value

      if lhs_type.pointer? &&
          !lhs_val.must_be_equal_to?(@interp.scalar_value_of(0)) &&
           lhs_val.may_be_equal_to?(@interp.scalar_value_of(0))
        W(expr.lhs_operand.location)
      end

      if rhs_type.pointer? &&
          !rhs_val.must_be_equal_to?(@interp.scalar_value_of(0)) &&
           rhs_val.may_be_equal_to?(@interp.scalar_value_of(0))
        W(expr.rhs_operand.location)
      end
    end

    def check_unary_prefix(expr, ope_var, org_val)
      type, val = ope_var.type, org_val

      if type.pointer? &&
          !val.must_be_equal_to?(@interp.scalar_value_of(0)) &&
           val.may_be_equal_to?(@interp.scalar_value_of(0))
        W(expr.operand.location)
      end
    end

    def check_unary_postfix(expr, ope_var, *)
      type, val = ope_var.type, ope_var.value

      if type.pointer? and
          !val.must_be_equal_to?(@interp.scalar_value_of(0)) &&
           val.may_be_equal_to?(@interp.scalar_value_of(0))
        W(expr.operand.location)
      end
    end
  end

  class W0425 < CodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def do_prepare(phase_ctxt) end

    def do_execute(phase_ctxt)
      phase_ctxt[:cc1_syntax_tree].accept(Visitor.new(phase_ctxt))
    end

    class Visitor < Cc1::SyntaxTreeVisitor
      include ReportUtil

      def initialize(phase_ctxt)
        @phase_ctxt = phase_ctxt
        @lst_dcl_or_stmt_loc = Location.new
        @lst_memb_dcl_loc    = Location.new
      end

      def visit_function_declaration(node)
        if node.analysis_target?(traits)
          check_dcl_or_stmt(node)
          @lst_dcl_or_stmt_loc = node.location
        end
      end

      def visit_variable_declaration(node)
        if node.analysis_target?(traits)
          check_dcl_or_stmt(node)
          @lst_dcl_or_stmt_loc = node.location
        end
      end

      def visit_variable_definition(node)
        if node.analysis_target?(traits)
          check_dcl_or_stmt(node)
          @lst_dcl_or_stmt_loc = node.location
        end
      end

      def visit_typedef_declaration(node)
        if node.analysis_target?(traits)
          check_dcl_or_stmt(node)
          @lst_dcl_or_stmt_loc = node.location
        end
      end

      def visit_member_declaration(node)
        if node.analysis_target?(traits)
          check_member_decl(node)
          @lst_memb_dcl_loc = node.location
        end
      end

      def visit_generic_labeled_statement(node)
        if node.analysis_target?(traits)
          check_dcl_or_stmt(node)
          @lst_dcl_or_stmt_loc = node.location
        end
      end

      def visit_case_labeled_statement(node)
        if node.analysis_target?(traits)
          check_dcl_or_stmt(node)
          @lst_dcl_or_stmt_loc = node.location
        end
      end

      def visit_default_labeled_statement(node)
        if node.analysis_target?(traits)
          check_dcl_or_stmt(node)
          @lst_dcl_or_stmt_loc = node.location
        end
      end

      def visit_expression_statement(node)
        if node.analysis_target?(traits)
          check_dcl_or_stmt(node)
          @lst_dcl_or_stmt_loc = node.location
        end
      end

      def visit_if_statement(node)
        if node.analysis_target?(traits)
          check_dcl_or_stmt(node)
          node.statement.accept(self)
          @lst_dcl_or_stmt_loc = node.location
        end
      end

      def visit_if_else_statement(node)
        if node.analysis_target?(traits)
          check_dcl_or_stmt(node)
          org_loc = @lst_dcl_or_stmt_loc
          node.then_statement.accept(self)
          @lst_dcl_or_stmt_loc = org_loc
          node.else_statement.accept(self)
          @lst_dcl_or_stmt_loc = node.location
        end
      end

      def visit_switch_statement(node)
        if node.analysis_target?(traits)
          check_dcl_or_stmt(node)
          node.statement.accept(self)
          @lst_dcl_or_stmt_loc = node.location
        end
      end

      def visit_while_statement(node)
        if node.analysis_target?(traits)
          check_dcl_or_stmt(node)
          node.statement.accept(self)
          @lst_dcl_or_stmt_loc = node.location
        end
      end

      def visit_do_statement(node)
        if node.analysis_target?(traits)
          check_dcl_or_stmt(node)
          node.statement.accept(self)
          @lst_dcl_or_stmt_loc = node.location
        end
      end

      def visit_for_statement(node)
        if node.analysis_target?(traits)
          check_dcl_or_stmt(node)
          node.body_statement.accept(self)
          @lst_dcl_or_stmt_loc = node.location
        end
      end

      def visit_c99_for_statement(node)
        if node.analysis_target?(traits)
          check_dcl_or_stmt(node)
          node.body_statement.accept(self)
          @lst_dcl_or_stmt_loc = node.location
        end
      end

      def visit_goto_statement(node)
        if node.analysis_target?(traits)
          check_dcl_or_stmt(node)
          @lst_dcl_or_stmt_loc = node.location
        end
      end

      def visit_continue_statement(node)
        if node.analysis_target?(traits)
          check_dcl_or_stmt(node)
          @lst_dcl_or_stmt_loc = node.location
        end
      end

      def visit_break_statement(node)
        if node.analysis_target?(traits)
          check_dcl_or_stmt(node)
          @lst_dcl_or_stmt_loc = node.location
        end
      end

      def visit_return_statement(node)
        if node.analysis_target?(traits)
          check_dcl_or_stmt(node)
          @lst_dcl_or_stmt_loc = node.location
        end
      end

      private
      def check_dcl_or_stmt(node)
        if @lst_dcl_or_stmt_loc.fpath == node.location.fpath &&
            @lst_dcl_or_stmt_loc.line_no == node.location.line_no
          W(node.location)
        end
      end

      def check_member_decl(node)
        if @lst_memb_dcl_loc.fpath == node.location.fpath &&
            @lst_memb_dcl_loc.line_no == node.location.line_no
          W(node.location)
        end
      end

      extend Forwardable

      def_delegator :@phase_ctxt, :traits
      private :traits

      def_delegator :@phase_ctxt, :report
      private :report

      def_delegator :@phase_ctxt, :message_catalog
      private :message_catalog

      def suppressors
        @phase_ctxt[:suppressors]
      end
    end
    private_constant :Visitor
  end

  class W0431 < CodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    include CodingStyleAccessor
    include MonitorUtil

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def do_prepare(phase_ctxt)
      fpath = phase_ctxt[:sources].first.fpath
      tok_ary = phase_ctxt[:cc1_token_array]
      @tokens = tok_ary.select { |tok| tok.location.fpath == fpath }
      @index = 0
      @indent_level = 0
      @indent_widths = Hash.new(0)
      @paren_depth = 0
      @last_token = nil
    end

    def last_line_no
      @last_token ? @last_token.location.line_no : 0
    end

    def do_execute(phase_ctxt)
      while tok = next_token
        case tok.type
        when "{"
          on_left_brace(tok)
        when "}"
          on_right_brace(tok)
        when "("
          on_left_paren(tok)
        when ")"
          on_right_paren(tok)
        end

        case tok.type
        when :IF, :FOR, :WHILE
          if last_line_no < tok.location.line_no
            on_beginning_of_line(tok)
          end
          skip_controlling_part
          unless tok = peek_token and tok.type == "{"
            skip_simple_substatement
          end
        when :ELSE
          if last_line_no < tok.location.line_no
            on_beginning_of_line(tok)
          end
          unless tok = peek_token and tok.type == :IF || tok.type == "{"
            skip_simple_substatement
          end
        when :DO
          if last_line_no < tok.location.line_no
            on_beginning_of_line(tok)
          end
          unless tok = peek_token and tok.type == "{"
            skip_simple_substatement
          end
        else
          if last_line_no < tok.location.line_no
            on_beginning_of_line(tok)
          end
        end
      end
    end

    def skip_controlling_part
      paren_depth = 0
      while tok = next_token
        case tok.type
        when "("
          paren_depth += 1
        when ")"
          paren_depth -= 1
          break if paren_depth == 0
        end
      end
    end

    def skip_simple_substatement
      paren_depth = 0
      while tok = next_token
        case tok.type
        when "("
          paren_depth += 1
        when ")"
          paren_depth -= 1
        end

        case tok.type
        when :IF, :FOR, :WHILE
          skip_controlling_part
          unless tok = peek_token and tok.type == "{"
            skip_simple_substatement
            break
          end
        when :ELSE
          unless tok = peek_token and tok.type == :IF || tok.type == "{"
            skip_simple_substatement
            break
          end
        when :DO
          unless tok = peek_token and tok.type == "{"
            skip_simple_substatement
            skip_simple_substatement
            break
          end
        when ";"
          break if paren_depth == 0
        end
      end
    end

    def next_token
      return nil unless tok = peek_token
      @index += 1

      case tok.type
      when :CASE
        while tok = peek_token
          @index += 1
          break if tok.type == ":"
        end
      when :IDENTIFIER, :DEFAULT
        if nxt_tok = @tokens[@index] and nxt_tok.type == ":"
          tok = peek_token
          @index += 1
        end
      end

      tok
    end

    def peek_token
      if tok = @tokens[@index]
        @last_token = @tokens[[0, @index - 1].max]
        checkpoint(tok.location)
      end
      tok
    end

    def on_left_brace(tok)
      if indent_style == INDENT_STYLE_GNU && @indent_level > 0
        @indent_level += 2
      else
        @indent_level += 1
      end
    end

    def on_right_brace(tok)
      if indent_style == INDENT_STYLE_GNU
        @indent_level -= 2
        @indent_level = 0 if @indent_level < 0
      else
        @indent_level -= 1
      end
    end

    def on_left_paren(tok)
      @paren_depth += 1
    end

    def on_right_paren(tok)
      @paren_depth -= 1
    end

    def on_beginning_of_line(tok)
      return if @paren_depth > 0 || @last_token.replaced?

      case tok.type
      when "{"
        if @indent_level == 0
          widths_idx = @indent_level
        else
          widths_idx = @indent_level - 1
        end
      when "}"
        if indent_style == INDENT_STYLE_GNU && @indent_level > 0
          widths_idx = @indent_level + 1
        else
          widths_idx = @indent_level
        end
      else
        widths_idx = @indent_level
      end

      expected_column_no = @indent_widths[widths_idx]
      if tok.location.appearance_column_no < expected_column_no
        W(tok.location) if tok.analysis_target?(traits)
      end

      @indent_widths[widths_idx] = tok.location.appearance_column_no
    end

    def monitor
      @phase_ctxt.monitor
    end
  end

  class W0432 < CodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    include CodingStyleAccessor
    include MonitorUtil

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def do_prepare(phase_ctxt)
      fpath = phase_ctxt[:sources].first.fpath
      tok_ary = phase_ctxt[:cc1_token_array]
      @tokens = tok_ary.select { |tok| tok.location.fpath == fpath }
      @index  = 0
      @indent_level = 0
      @indent_width = indent_width
      @paren_depth  = 0
      @last_token   = nil
    end

    def last_line_no
      @last_token ? @last_token.location.line_no : 0
    end

    def do_execute(phase_ctxt)
      while tok = next_token
        case tok.type
        when "{"
          on_left_brace(tok)
        when "}"
          on_right_brace(tok)
        when "("
          on_left_paren(tok)
        when ")"
          on_right_paren(tok)
        end

        case tok.type
        when :IF, :FOR, :WHILE
          if last_line_no < tok.location.line_no
            on_beginning_of_line(tok)
          end
          skip_controlling_part
          unless tok = peek_token and tok.type == "{"
            process_simple_substatement
          end
        when :ELSE
          if last_line_no < tok.location.line_no
            on_beginning_of_line(tok)
          end
          unless tok = peek_token and tok.type == :IF || tok.type == "{"
            process_simple_substatement
          end
        when :DO
          if last_line_no < tok.location.line_no
            on_beginning_of_line(tok)
          end
          unless tok = peek_token and tok.type == "{"
            process_simple_substatement
          end
        else
          if last_line_no < tok.location.line_no
            on_beginning_of_line(tok)
          end
        end
      end
    end

    def skip_controlling_part
      paren_depth = 0
      while tok = next_token
        case tok.type
        when "("
          paren_depth += 1
        when ")"
          paren_depth -= 1
          break if paren_depth == 0
        end
      end
    end

    def process_simple_substatement
      @indent_level += 1
      while tok = next_token
        case tok.type
        when "{"
          on_left_brace(tok)
        when "}"
          on_right_brace(tok)
        when "("
          on_left_paren(tok)
        when ")"
          on_right_paren(tok)
        end

        case tok.type
        when :IF, :FOR, :WHILE
          if last_line_no < tok.location.line_no
            on_beginning_of_line(tok)
          end
          skip_controlling_part
          unless tok = peek_token and tok.type == "{"
            process_simple_substatement
            break
          end
        when :ELSE
          if last_line_no < tok.location.line_no
            on_beginning_of_line(tok)
          end
          unless tok = peek_token and tok.type == :IF || tok.type == "{"
            process_simple_substatement
            break
          end
        when :DO
          if last_line_no < tok.location.line_no
            on_beginning_of_line(tok)
          end
          unless tok = peek_token and tok.type == "{"
            process_simple_substatement
            process_simple_substatement
            break
          end
        else
          if last_line_no < tok.location.line_no
            on_beginning_of_line(tok)
          end
          break if tok.type == ";"
        end
      end
      @indent_level -= 1
    end

    def next_token
      return nil unless tok = peek_token
      @index += 1

      case tok.type
      when :CASE
        while tok = peek_token
          @index += 1
          break if tok.type == ":"
        end
      when :IDENTIFIER, :DEFAULT
        if nxt_tok = @tokens[@index] and nxt_tok.type == ":"
          tok = peek_token
          @index += 1
        end
      end

      tok
    end

    def peek_token
      if tok = @tokens[@index]
        @last_token = @tokens[[0, @index - 1].max]
        checkpoint(tok.location)
      end
      tok
    end

    def on_left_brace(tok)
      if indent_style == INDENT_STYLE_GNU && @indent_level > 0
        @indent_level += 2
      else
        @indent_level += 1
      end
    end

    def on_right_brace(tok)
      if indent_style == INDENT_STYLE_GNU
        @indent_level -= 2
        @indent_level = 0 if @indent_level < 0
      else
        @indent_level -= 1
      end
    end

    def on_left_paren(tok)
      @paren_depth += 1
    end

    def on_right_paren(tok)
      @paren_depth -= 1
    end

    def on_beginning_of_line(tok)
      return if @paren_depth > 0 || @last_token.replaced?

      case tok.type
      when "{"
        if @indent_level == 0
          expected_column_no = expected_indent_width(tok)
        else
          expected_column_no = expected_indent_width(tok, -1)
        end
      when "}"
        if indent_style == INDENT_STYLE_GNU && @indent_level > 0
          expected_column_no = expected_indent_width(tok, +1)
        else
          expected_column_no = expected_indent_width(tok)
        end
      else
        expected_column_no = expected_indent_width(tok)
      end

      unless tok.location.appearance_column_no == expected_column_no
        W(tok.location) if tok.analysis_target?(traits)
      end
    end

    def expected_indent_width(tok, delta_level = 0)
      if @indent_width == 0 && @indent_level > 0
        @indent_width = (tok.location.appearance_column_no - 1) / @indent_level
      end

      if @indent_width > 0
        @indent_width * @indent_level + @indent_width * delta_level + 1
      else
        tok.location.appearance_column_no
      end
    end

    def monitor
      @phase_ctxt.monitor
    end
  end

  class W0440 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    include CodingStyleAccessor

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_compound_statement += T(:check)
    end

    private
    def check(node)
      return if indent_style == INDENT_STYLE_K_AND_R

      unless node.head_location.appearance_column_no ==
          node.tail_location.appearance_column_no
        W(node.tail_location)
      end
    end
  end

  class W0441 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_constant_referred += T(:check)
    end

    private
    def check(const_spec, var)
      return unless var.type.scalar? && var.type.integer?
      return if const_spec.character?

      if const_spec.suffix.nil? && var.type != @interp.int_t
        W(const_spec.location)
      end
    end
  end

  class W0446 < CodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def do_prepare(phase_ctxt) end

    def do_execute(phase_ctxt)
      phase_ctxt[:cc1_syntax_tree].accept(Visitor.new(phase_ctxt))
    end

    class Visitor < Cc1::SyntaxTreeVisitor
      include ReportUtil

      def initialize(phase_ctxt)
        @phase_ctxt = phase_ctxt
      end

      def visit_simple_assignment_expression(node)
        if node.analysis_target?(traits)
          super
          warn(node.lhs_operand)
          warn(node.rhs_operand)
        end
      end

      def visit_compound_assignment_expression(node)
        if node.analysis_target?(traits)
          super
          warn(node.lhs_operand)
          warn(node.rhs_operand)
        end
      end

      def visit_function_call_expression(node)
        if node.analysis_target?(traits)
          super
          node.argument_expressions.each { |expr| warn(expr) }
        end
      end

      def visit_unary_arithmetic_expression(node)
        if node.analysis_target?(traits)
          super
          if node.operator.type == "+" || node.operator.type == "-"
            warn(node.operand)
          end
        end
      end

      def visit_multiplicative_expression(node)
        if node.analysis_target?(traits)
          super
          warn(node.lhs_operand)
          warn(node.rhs_operand)
        end
      end

      def visit_additive_expression(node)
        if node.analysis_target?(traits)
          super
          warn(node.lhs_operand)
          warn(node.rhs_operand)
        end
      end

      def visit_return_statement(node)
        if node.analysis_target?(traits)
          super
          warn(node.expression) if node.expression
        end
      end

      private
      def warn(node)
        node = node.expression while node.kind_of?(Cc1::GroupedExpression)
        if node && node.analysis_target?(traits)
          case node
          when Cc1::SimpleAssignmentExpression,
               Cc1::CompoundAssignmentExpression
            W(node.location)
          end
        end
      end

      extend Forwardable

      def_delegator :@phase_ctxt, :traits
      private :traits

      def_delegator :@phase_ctxt, :report
      private :report

      def_delegator :@phase_ctxt, :message_catalog
      private :message_catalog

      def suppressors
        @phase_ctxt[:suppressors]
      end
    end
    private_constant :Visitor
  end

  class W0447 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_comma_separated_expression += T(:check)
      visitor.enter_for_statement              += T(:enter_for_statement)
      visitor.leave_for_statement              += T(:leave_for_statement)
      visitor.enter_c99_for_statement          += T(:enter_for_statement)
      visitor.leave_c99_for_statement          += T(:leave_for_statement)
      @in_for_stmt = false
    end

    private
    def check(node)
      W(node.location) unless @in_for_stmt
    end

    def enter_for_statement(node)
      @in_for_stmt = true
    end

    def leave_for_statement(node)
      @in_for_stmt = false
    end
  end

  class W0456 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_variable_defined          += T(:check_variable)
      interp.on_explicit_function_defined += T(:check_function)
      @target_fpath = phase_ctxt[:sources].first.fpath
    end

    private
    def check_variable(var_def, var)
      if var.declared_as_extern?
        unless var_def.location.fpath == @target_fpath
          W(var_def.location, var.name)
        end
      end
    end

    def check_function(fun_def, fun)
      if fun.declared_as_extern?
        unless fun_def.location.fpath == @target_fpath
          W(fun_def.location, fun.name)
        end
      end
    end
  end

  class W0457 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_function_declaration      += T(:check_function)
      visitor.enter_ansi_function_definition  += T(:check_function)
      visitor.enter_kandr_function_definition += T(:check_function)
    end

    private
    def check_function(node)
      W(node.location) if node.implicitly_typed?
    end
  end

  class W0458 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_variable_declaration += T(:check_variable)
      visitor.enter_variable_definition  += T(:check_variable)
      visitor.enter_parameter_definition += T(:check_variable)
    end

    private
    def check_variable(node)
      W(node.location) if node.implicitly_typed?
    end
  end

  class W0459 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_variable_value_referred += T(:check)
    end

    private
    def check(expr, var)
      return if var.scope.global? || var.binding.memory.static?

      if var.named? && var.value.must_be_undefined?
        var = var.owner while var.inner?
        W(expr.location, var.name)
      end
    end
  end

  class W0460 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_variable_value_referred += T(:check)
    end

    private
    def check(expr, var)
      return if var.scope.global? || var.binding.memory.static?
      return if var.value.must_be_undefined?

      if var.named? && var.value.may_be_undefined?
        var = var.owner while var.inner?
        W(expr.location, var.name)
      end
    end
  end

  class W0461 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_function_call_expr_evaled += T(:check)
    end

    private
    def check(funcall_expr, fun, arg_vars, *)
      args = arg_vars.zip(fun.type.parameter_types)
      args.each_with_index do |(arg, type), idx|
        next unless arg.variable? && arg.value.scalar?
        next unless type && type.pointer?

        base_type = type.unqualify.base_type
        next unless !base_type.function? && base_type.const?

        if pointee = @interp.pointee_of(arg) and pointee.variable?
          if !pointee.temporary? && pointee.value.must_be_undefined?
            W(funcall_expr.argument_expressions[idx].location)
          end
        end
      end
    end
  end

  class W0462 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_function_call_expr_evaled += T(:check)
    end

    private
    def check(funcall_expr, fun, arg_vars, *)
      args = arg_vars.zip(fun.type.parameter_types)
      args.each_with_index do |(arg, type), idx|
        next unless arg.variable? && arg.value.scalar?
        next unless type && type.pointer?
        next unless type.unqualify.base_type.const?

        if pointee = @interp.pointee_of(arg) and pointee.variable?
          next if pointee.value.must_be_undefined?
          if !pointee.temporary? && pointee.value.may_be_undefined?
            W(funcall_expr.argument_expressions[idx].location)
          end
        end
      end
    end
  end

  class W0488 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: W0488 may be duplicative when problematic operators appear thrice
    #       or more in an expression.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_initializer          += T(:check_initializer)
      visitor.enter_expression_statement += T(:check_expr_statement)
      visitor.enter_if_statement         += T(:check_selection_statement)
      visitor.enter_if_else_statement    += T(:check_selection_statement)
      visitor.enter_switch_statement     += T(:check_selection_statement)
      visitor.enter_while_statement      += T(:check_iteration_statement)
      visitor.enter_do_statement         += T(:check_iteration_statement)
      visitor.enter_for_statement        += T(:check_iteration_statement)
      visitor.enter_c99_for_statement    += T(:check_iteration_statement)
      visitor.enter_return_statement     += T(:check_return_statement)
    end

    private
    def check_initializer(node)
      Cc1::ExpressionExtractor.new.tap { |extr|
        node.accept(extr)
      }.expressions.each do |expr|
        AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
      end
    end

    def check_expr_statement(node)
      return unless node.expression

      Cc1::ExpressionExtractor.new.tap { |extr|
        node.expression.accept(extr)
      }.expressions.each do |expr|
        AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
      end
    end

    def check_selection_statement(node)
      Cc1::ExpressionExtractor.new.tap { |extr|
        node.expression.accept(extr)
      }.expressions.each do |expr|
        AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
      end
    end

    def check_iteration_statement(node)
      return unless node.expression

      Cc1::ExpressionExtractor.new.tap { |extr|
        node.expression.accept(extr)
      }.expressions.each do |expr|
        AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
      end
    end

    def check_return_statement(node)
      return unless node.expression

      Cc1::ExpressionExtractor.new.tap { |extr|
        node.expression.accept(extr)
      }.expressions.each do |expr|
        AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
      end
    end

    class AmbiguousExpressionDetector < Cc1::SyntaxTreeVisitor
      include ReportUtil

      def initialize(phase_ctxt, expr)
        @phase_ctxt      = phase_ctxt
        @target_expr     = expr
        @enclusure_exprs = [expr]
        @ary_subs_exprs  = Hash.new(0)
        @funcall_exprs   = Hash.new(0)
        @memb_exprs      = Hash.new(0)
      end

      def execute
        @target_expr.accept(self)
      end

      def visit_grouped_expression(node)
        @enclusure_exprs.push(node)
        super
        @enclusure_exprs.pop
      end

      def visit_array_subscript_expression(node)
        node.expression.accept(self)
        @ary_subs_exprs[current_encl_expr] += 1
        AmbiguousExpressionDetector.new(@phase_ctxt,
                                        node.array_subscript).execute
      end

      def visit_function_call_expression(node)
        node.expression.accept(self)
        @funcall_exprs[current_encl_expr] += 1
        node.argument_expressions.each do |expr|
          AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
        end
      end

      def visit_member_access_by_value_expression(node)
        super
        @memb_exprs[current_encl_expr] += 1
      end

      def visit_member_access_by_pointer_expression(node)
        super
        @memb_exprs[current_encl_expr] += 1
      end

      def visit_bit_access_by_value_expression(node)
        super
        @memb_exprs[current_encl_expr] += 1
      end

      def visit_bit_access_by_pointer_expression(node)
        super
        @memb_exprs[current_encl_expr] += 1
      end

      def visit_logical_and_expression(node)
        super
        if include_ambiguous_expr?
          W(current_encl_expr.head_location)
        end
      end

      def visit_logical_or_expression(node)
        super
        if include_ambiguous_expr?
          W(current_encl_expr.head_location)
        end
      end

      def visit_conditional_expression(node)
        cond_expr = node.condition
        then_expr = node.then_expression
        else_expr = node.else_expression
        AmbiguousExpressionDetector.new(@phase_ctxt, cond_expr).execute
        AmbiguousExpressionDetector.new(@phase_ctxt, then_expr).execute
        AmbiguousExpressionDetector.new(@phase_ctxt, else_expr).execute
      end

      private
      def include_ambiguous_expr?
        @ary_subs_exprs[current_encl_expr] > 0  ||
          @funcall_exprs[current_encl_expr] > 0 ||
          @memb_exprs[current_encl_expr] > 0
      end

      def current_encl_expr
        @enclusure_exprs.last
      end

      extend Forwardable

      def_delegator :@phase_ctxt, :report
      private :report

      def_delegator :@phase_ctxt, :message_catalog
      private :message_catalog

      def suppressors
        @phase_ctxt[:suppressors]
      end
    end
    private_constant :AmbiguousExpressionDetector
  end

  class W0489 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: W0489 may be duplicative when operators of the same priority are
    #       used thrice or more.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_initializer          += T(:check_initializer)
      visitor.enter_expression_statement += T(:check_expr_statement)
      visitor.enter_if_statement         += T(:check_selection_statement)
      visitor.enter_if_else_statement    += T(:check_selection_statement)
      visitor.enter_switch_statement     += T(:check_selection_statement)
      visitor.enter_while_statement      += T(:check_iteration_statement)
      visitor.enter_do_statement         += T(:check_iteration_statement)
      visitor.enter_for_statement        += T(:check_iteration_statement)
      visitor.enter_c99_for_statement    += T(:check_iteration_statement)
      visitor.enter_return_statement     += T(:check_return_statement)
    end

    private
    def check_initializer(node)
      Cc1::ExpressionExtractor.new.tap { |extr|
        node.accept(extr)
      }.expressions.each do |expr|
        AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
      end
    end

    def check_expr_statement(node)
      return unless node.expression

      Cc1::ExpressionExtractor.new.tap { |extr|
        node.expression.accept(extr)
      }.expressions.each do |expr|
        AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
      end
    end

    def check_selection_statement(node)
      Cc1::ExpressionExtractor.new.tap { |extr|
        node.expression.accept(extr)
      }.expressions.each do |expr|
        AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
      end
    end

    def check_iteration_statement(node)
      return unless node.expression

      Cc1::ExpressionExtractor.new.tap { |extr|
        node.expression.accept(extr)
      }.expressions.each do |expr|
        AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
      end
    end

    def check_return_statement(node)
      return unless node.expression

      Cc1::ExpressionExtractor.new.tap { |extr|
        node.expression.accept(extr)
      }.expressions.each do |expr|
        AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
      end
    end

    class AmbiguousExpressionDetector < Cc1::SyntaxTreeVisitor
      include ReportUtil

      def initialize(phase_ctxt, expr)
        @phase_ctxt      = phase_ctxt
        @target_expr     = expr
        @encl_expr_stack = [expr]
        @unary_exprs     = Hash.new(0)
      end

      def execute
        @target_expr.accept(self)
      end

      def visit_grouped_expression(node)
        @encl_expr_stack.push(node)
        super
        @encl_expr_stack.pop
      end

      def visit_postfix_increment_expression(node)
        super
        @unary_exprs[current_encl_expr] += 1
      end

      def visit_postfix_decrement_expression(node)
        super
        @unary_exprs[current_encl_expr] += 1
      end

      def visit_prefix_increment_expression(node)
        super
        @unary_exprs[current_encl_expr] += 1
      end

      def visit_prefix_decrement_expression(node)
        super
        @unary_exprs[current_encl_expr] += 1
      end

      def visit_address_expression(node)
        super
        @unary_exprs[current_encl_expr] += 1
      end

      def visit_indirection_expression(node)
        super
        @unary_exprs[current_encl_expr] += 1
      end

      def visit_unary_arithmetic_expression(node)
        super
        @unary_exprs[current_encl_expr] += 1
      end

      def visit_sizeof_expression(node)
        super
        @unary_exprs[current_encl_expr] += 1
      end

      def visit_alignof_expression(node)
        super
        @unary_exprs[current_encl_expr] += 1
      end

      def visit_cast_expression(node)
        node.operand.accept(self)
        @unary_exprs[current_encl_expr] += 1
      end

      def visit_logical_and_expression(node)
        super
        if include_ambiguous_expr?
          W(current_encl_expr.head_location)
        end
      end

      def visit_logical_or_expression(node)
        super
        if include_ambiguous_expr?
          W(current_encl_expr.head_location)
        end
      end

      def visit_conditional_expression(node)
        cond_expr = node.condition
        then_expr = node.then_expression
        else_expr = node.else_expression
        AmbiguousExpressionDetector.new(@phase_ctxt, cond_expr).execute
        AmbiguousExpressionDetector.new(@phase_ctxt, then_expr).execute
        AmbiguousExpressionDetector.new(@phase_ctxt, else_expr).execute
      end

      private
      def include_ambiguous_expr?
        @unary_exprs[current_encl_expr] > 0
      end

      def current_encl_expr
        @encl_expr_stack.last
      end

      extend Forwardable

      def_delegator :@phase_ctxt, :report
      private :report

      def_delegator :@phase_ctxt, :message_catalog
      private :message_catalog

      def suppressors
        @phase_ctxt[:suppressors]
      end
    end
    private_constant :AmbiguousExpressionDetector
  end

  class W0490 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: W0490 may be duplicative when problematic operators appear thrice
    #       or more in an expression.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_initializer          += T(:check_initializer)
      visitor.enter_expression_statement += T(:check_expr_statement)
      visitor.enter_if_statement         += T(:check_selection_statement)
      visitor.enter_if_else_statement    += T(:check_selection_statement)
      visitor.enter_switch_statement     += T(:check_selection_statement)
      visitor.enter_while_statement      += T(:check_iteration_statement)
      visitor.enter_do_statement         += T(:check_iteration_statement)
      visitor.enter_for_statement        += T(:check_iteration_statement)
      visitor.enter_c99_for_statement    += T(:check_iteration_statement)
      visitor.enter_return_statement     += T(:check_return_statement)
    end

    private
    def check_initializer(node)
      Cc1::ExpressionExtractor.new.tap { |extr|
        node.accept(extr)
      }.expressions.each do |expr|
        AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
      end
    end

    def check_expr_statement(node)
      return unless node.expression

      Cc1::ExpressionExtractor.new.tap { |extr|
        node.expression.accept(extr)
      }.expressions.each do |expr|
        AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
      end
    end

    def check_selection_statement(node)
      Cc1::ExpressionExtractor.new.tap { |extr|
        node.expression.accept(extr)
      }.expressions.each do |expr|
        AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
      end
    end

    def check_iteration_statement(node)
      return unless node.expression

      Cc1::ExpressionExtractor.new.tap { |extr|
        node.expression.accept(extr)
      }.expressions.each do |expr|
        AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
      end
    end

    def check_return_statement(node)
      return unless node.expression

      Cc1::ExpressionExtractor.new.tap { |extr|
        node.expression.accept(extr)
      }.expressions.each do |expr|
        AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
      end
    end

    class AmbiguousExpressionDetector < Cc1::SyntaxTreeVisitor
      include ReportUtil

      def initialize(phase_ctxt, expr)
        @phase_ctxt        = phase_ctxt
        @target_expr       = expr
        @encl_expr_stack   = [expr]
        @highprec_exprs    = Hash.new(0)
        @logical_and_exprs = Hash.new(0)
      end

      def execute
        @target_expr.accept(self)
      end

      def visit_grouped_expression(node)
        @encl_expr_stack.push(node)
        super
        @encl_expr_stack.pop
      end

      def visit_array_subscript_expression(node)
        node.expression.accept(self)
        AmbiguousExpressionDetector.new(@phase_ctxt,
                                        node.array_subscript).execute
      end

      def visit_function_call_expression(node)
        node.expression.accept(self)
        node.argument_expressions.each do |expr|
          AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
        end
      end

      def visit_multiplicative_expression(node)
        super
        @highprec_exprs[current_encl_expr] += 1
      end

      def visit_additive_expression(node)
        super
        @highprec_exprs[current_encl_expr] += 1
      end

      def visit_shift_expression(node)
        super
        @highprec_exprs[current_encl_expr] += 1
      end

      def visit_relational_expression(node)
        super
        @highprec_exprs[current_encl_expr] += 1
      end

      def visit_equality_expression(node)
        super
        @highprec_exprs[current_encl_expr] += 1
      end

      def visit_and_expression(node)
        super
        @highprec_exprs[current_encl_expr] += 1
      end

      def visit_exclusive_or_expression(node)
        super
        @highprec_exprs[current_encl_expr] += 1
      end

      def visit_inclusive_or_expression(node)
        super
        @highprec_exprs[current_encl_expr] += 1
      end

      def visit_logical_and_expression(node)
        super
        cur_encl = current_encl_expr
        @logical_and_exprs[cur_encl] += 1
        if @highprec_exprs[cur_encl] > 0
          W(cur_encl.head_location)
        end
      end

      def visit_logical_or_expression(node)
        super
        cur_encl = current_encl_expr
        if @highprec_exprs[cur_encl] + @logical_and_exprs[cur_encl] > 0
          W(cur_encl.head_location)
        end
      end

      def visit_conditional_expression(node)
        cond_expr = node.condition
        then_expr = node.then_expression
        else_expr = node.else_expression
        AmbiguousExpressionDetector.new(@phase_ctxt, cond_expr).execute
        AmbiguousExpressionDetector.new(@phase_ctxt, then_expr).execute
        AmbiguousExpressionDetector.new(@phase_ctxt, else_expr).execute
      end

      private
      def current_encl_expr
        @encl_expr_stack.last
      end

      extend Forwardable

      def_delegator :@phase_ctxt, :report
      private :report

      def_delegator :@phase_ctxt, :message_catalog
      private :message_catalog

      def suppressors
        @phase_ctxt[:suppressors]
      end
    end
    private_constant :AmbiguousExpressionDetector
  end

  class W0491 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_variable_defined  += T(:define_variable)
      interp.on_variable_declared += T(:declare_variable)
      interp.on_struct_declared   += T(:declare_struct)
      interp.on_union_declared    += T(:declare_union)
      interp.on_enum_declared     += T(:declare_enum)
      interp.on_typedef_declared  += T(:declare_typedef)
      interp.on_parameter_defined += T(:define_parameter)
      interp.on_label_defined     += T(:define_label)
      interp.on_block_started     += T(:enter_scope)
      interp.on_block_ended       += T(:leave_scope)
      @dcl_names   = [[]]
      @tag_names   = [[]]
      @label_names = [[]]
    end

    private
    def define_variable(var_def, *)
      dcl_name = var_def.identifier

      pair_names = (@tag_names + @label_names).flatten.select { |id|
        id.value == dcl_name.value
      }

      unless pair_names.empty?
        W(var_def.location, dcl_name.value,
          *pair_names.map { |pair| C(:C0001, pair.location, pair.value) })
      end

      @dcl_names.last.push(dcl_name)
    end

    def declare_variable(var_dcl, *)
      dcl_name = var_dcl.identifier

      pair_names = (@tag_names + @label_names).flatten.select { |id|
        id.value == dcl_name.value
      }

      unless pair_names.empty?
        W(var_dcl.location, dcl_name.value,
          *pair_names.map { |pair| C(:C0001, pair.location, pair.value) })
      end

      @dcl_names.last.push(dcl_name)
    end

    def declare_struct(struct_dcl)
      tag_name = struct_dcl.identifier
      return unless tag_name

      pair_names = (@dcl_names + @label_names).flatten.select { |id|
        id.value == tag_name.value
      }

      unless pair_names.empty?
        W(struct_dcl.location, tag_name.value,
          *pair_names.map { |pair| C(:C0001, pair.location, pair.value) })
      end

      @tag_names.last.push(tag_name)
    end

    def declare_union(union_dcl)
      tag_name = union_dcl.identifier
      return unless tag_name

      pair_names = (@dcl_names + @label_names).flatten.select { |id|
        id.value == tag_name.value
      }

      unless pair_names.empty?
        W(union_dcl.location, tag_name.value,
          *pair_names.map { |pair| C(:C0001, pair.location, pair.value) })
      end

      @tag_names.last.push(tag_name)
    end

    def declare_enum(enum_dcl)
      tag_name = enum_dcl.identifier
      return unless tag_name

      pair_names = (@dcl_names + @label_names).flatten.select { |id|
        id.value == tag_name.value
      }

      unless pair_names.empty?
        W(enum_dcl.location, tag_name.value,
          *pair_names.map { |pair| C(:C0001, pair.location, pair.value) })
      end

      @tag_names.last.push(tag_name)
    end

    def declare_typedef(typedef_dcl)
      dcl_name = typedef_dcl.identifier

      pair_names = (@tag_names + @label_names).flatten.select { |id|
        id.value == dcl_name.value
      }

      unless pair_names.empty?
        W(typedef_dcl.location, dcl_name.value,
          *pair_names.map { |pair| C(:C0001, pair.location, pair.value) })
      end

      @dcl_names.last.push(dcl_name)
    end

    def define_parameter(param_def, *)
      dcl_name = param_def.identifier
      return unless dcl_name

      pair_names = (@tag_names + @label_names).flatten.select { |id|
        id.value == dcl_name.value
      }

      unless pair_names.empty?
        W(param_def.location, dcl_name.value,
          *pair_names.map { |pair| C(:C0001, pair.location, pair.value) })
      end

      @dcl_names.last.push(dcl_name)
    end

    def define_label(labeled_stmt)
      label_name = labeled_stmt.label

      pair_names = (@dcl_names + @tag_names).flatten.select { |id|
        id.value == label_name.value
      }

      unless pair_names.empty?
        W(labeled_stmt.location, label_name.value,
          *pair_names.map { |pair| C(:C0001, pair.location, pair.value) })
      end

      @label_names.last.push(label_name)
    end

    def enter_scope(*)
      @dcl_names.push([])
      @tag_names.push([])
      @label_names.push([])
    end

    def leave_scope(*)
      @dcl_names.pop
      @tag_names.pop
      @label_names.pop
    end
  end

  class W0492 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_variable_defined  += T(:define_variable)
      interp.on_variable_declared += T(:declare_variable)
      interp.on_struct_declared   += T(:declare_struct_or_union)
      interp.on_union_declared    += T(:declare_struct_or_union)
      interp.on_enum_declared     += T(:declare_enum)
      interp.on_typedef_declared  += T(:declare_typedef)
      interp.on_parameter_defined += T(:define_parameter)
      interp.on_label_defined     += T(:define_label)
      interp.on_block_started     += T(:enter_scope)
      interp.on_block_ended       += T(:leave_scope)
      @dcl_names   = [[]]
      @tag_names   = [[]]
      @label_names = [[]]
      @memb_names  = [[]]
    end

    private
    def define_variable(var_def, *)
      dcl_name = var_def.identifier

      pair_names = @memb_names.flatten.select { |id|
        id.value == dcl_name.value
      }

      unless pair_names.empty?
        W(var_def.location, dcl_name.value,
          *pair_names.map { |pair| C(:C0001, pair.location, pair.value) })
      end

      @dcl_names.last.push(dcl_name)
    end

    def declare_variable(var_dcl, *)
      dcl_name = var_dcl.identifier

      pair_names = @memb_names.flatten.select { |id|
        id.value == dcl_name.value
      }

      unless pair_names.empty?
        W(var_dcl.location, dcl_name.value,
          *pair_names.map { |pair| C(:C0001, pair.location, pair.value) })
      end

      @dcl_names.last.push(dcl_name)
    end

    def declare_struct_or_union(struct_or_union_dcl)
      tag_name = struct_or_union_dcl.identifier
      return unless tag_name

      pair_names = @memb_names.flatten.select { |id|
        id.value == tag_name.value
      }

      unless pair_names.empty?
        W(struct_or_union_dcl.location, tag_name.value,
          *pair_names.map { |pair| C(:C0001, pair.location, pair.value) })
      end

      @tag_names.last.push(tag_name)

      declare_members(struct_or_union_dcl)
    end

    def declare_members(struct_or_union_dcl)
      memb_dcls = MemberExtractor.new.tap { |extr|
        struct_or_union_dcl.accept(extr)
      }.result

      memb_dcls.each do |memb_dcl|
        pair_names =
          (@dcl_names + @tag_names + @label_names).flatten.select { |id|
            id.value == memb_dcl.identifier.value
          }
        unless pair_names.empty?
          W(memb_dcl.location, memb_dcl.identifier.value,
            *pair_names.map { |pair| C(:C0001, pair.location, pair.value) })
        end

        @memb_names.last.push(memb_dcl.identifier)
      end
    end

    def declare_enum(enum_dcl)
      tag_name = enum_dcl.identifier
      return unless tag_name

      pair_names = @memb_names.flatten.select { |id|
        id.value == tag_name.value
      }

      unless pair_names.empty?
        W(enum_dcl.location, tag_name.value,
          *pair_names.map { |pair| C(:C0001, pair.location, pair.value) })
      end

      @tag_names.last.push(tag_name)
    end

    def declare_typedef(typedef_dcl)
      dcl_name = typedef_dcl.identifier

      pair_names = @memb_names.flatten.select { |id|
        id.value == dcl_name.value
      }

      unless pair_names.empty?
        W(typedef_dcl.location, dcl_name.value,
          *pair_names.map { |pair| C(:C0001, pair.location, pair.value) })
      end

      @dcl_names.last.push(dcl_name)
    end

    def define_parameter(param_def, *)
      dcl_name = param_def.identifier
      return unless dcl_name

      pair_names = @memb_names.flatten.select { |id|
        id.value == dcl_name.value
      }

      unless pair_names.empty?
        W(param_def.location, dcl_name.value,
          *pair_names.map { |pair| C(:C0001, pair.location, pair.value) })
      end

      @dcl_names.last.push(dcl_name)
    end

    def define_label(labeled_stmt)
      label_name = labeled_stmt.label

      pair_names = @memb_names.flatten.select { |id|
        id.value == label_name.value
      }

      unless pair_names.empty?
        W(labeled_stmt.location, label_name.value,
          *pair_names.map { |pair| C(:C0001, pair.location, pair.value) })
      end

      @label_names.last.push(label_name)
    end

    def enter_scope(*)
      @dcl_names.push([])
      @tag_names.push([])
      @label_names.push([])
      @memb_names.push([])
    end

    def leave_scope(*)
      @dcl_names.pop
      @tag_names.pop
      @label_names.pop
      @memb_names.pop
    end

    class MemberExtractor < Cc1::SyntaxTreeVisitor
      def initialize
        @result = []
      end

      attr_reader :result

      def visit_struct_type_declaration(node)
        if node.struct_declarations
          node.struct_declarations.each do |struct_dcl|
            struct_dcl.accept(self)
          end
        end
      end

      def visit_union_type_declaration(node)
        if node.struct_declarations
          node.struct_declarations.each do |struct_dcl|
            struct_dcl.accept(self)
          end
        end
      end

      def visit_struct_declaration(node)
        node.items.each { |item| item.accept(self) }
      end

      def visit_member_declaration(node)
        @result.push(node)
      end
    end
    private_constant :MemberExtractor
  end

  class W0493 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_function_call_expr_evaled += T(:check)
    end

    private
    def check(funcall_expr, fun, arg_vars, *)
      if arg_vars.any? { |arg| arg.type.composite? }
        W(funcall_expr.location)
      end
    end
  end

  class W0495 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: W0495 may be duplicative when problematic operators appear thrice
    #       or more in an expression.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_initializer          += T(:check_initializer)
      visitor.enter_expression_statement += T(:check_expr_statement)
      visitor.enter_if_statement         += T(:check_selection_statement)
      visitor.enter_if_else_statement    += T(:check_selection_statement)
      visitor.enter_switch_statement     += T(:check_selection_statement)
      visitor.enter_while_statement      += T(:check_iteration_statement)
      visitor.enter_do_statement         += T(:check_iteration_statement)
      visitor.enter_for_statement        += T(:check_iteration_statement)
      visitor.enter_c99_for_statement    += T(:check_iteration_statement)
      visitor.enter_return_statement     += T(:check_return_statement)
    end

    private
    def check_initializer(node)
      Cc1::ExpressionExtractor.new.tap { |extr|
        node.accept(extr)
      }.expressions.each do |expr|
        AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
      end
    end

    def check_expr_statement(node)
      return unless node.expression

      Cc1::ExpressionExtractor.new.tap { |extr|
        node.expression.accept(extr)
      }.expressions.each do |expr|
        AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
      end
    end

    def check_selection_statement(node)
      Cc1::ExpressionExtractor.new.tap { |extr|
        node.expression.accept(extr)
      }.expressions.each do |expr|
        AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
      end
    end

    def check_iteration_statement(node)
      return unless node.expression

      Cc1::ExpressionExtractor.new.tap { |extr|
        node.expression.accept(extr)
      }.expressions.each do |expr|
        AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
      end
    end

    def check_return_statement(node)
      return unless node.expression

      Cc1::ExpressionExtractor.new.tap { |extr|
        node.expression.accept(extr)
      }.expressions.each do |expr|
        AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
      end
    end

    class AmbiguousExpressionDetector < Cc1::SyntaxTreeVisitor
      include ReportUtil

      def initialize(phase_ctxt, expr)
        @phase_ctxt      = phase_ctxt
        @target_expr     = expr
        @encl_expr_stack = [expr]
        @add_exprs       = Hash.new(0)
        @sub_exprs       = Hash.new(0)
        @mul_exprs       = Hash.new(0)
        @div_exprs       = Hash.new(0)
        @mod_exprs       = Hash.new(0)
      end

      def execute
        @target_expr.accept(self)
      end

      def visit_grouped_expression(node)
        @encl_expr_stack.push(node)
        super
        @encl_expr_stack.pop
      end

      def visit_array_subscript_expression(node)
        AmbiguousExpressionDetector.new(@phase_ctxt,
                                        node.array_subscript).execute
      end

      def visit_function_call_expression(node)
        node.argument_expressions.each do |expr|
          AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
        end
      end

      def visit_additive_expression(node)
        cur_encl = current_encl_expr
        case node.operator.type
        when "+"
          @add_exprs[cur_encl] += 1
          W(cur_encl.head_location) if include_ambiguous_expr?
        when "-"
          @sub_exprs[cur_encl] += 1
          W(cur_encl.head_location) if include_ambiguous_expr?
        end
        super
      end

      def visit_multiplicative_expression(node)
        cur_encl = current_encl_expr
        case node.operator.type
        when "*"
          @mul_exprs[cur_encl] += 1
          W(cur_encl.head_location) if include_ambiguous_expr?
        when "/"
          @div_exprs[cur_encl] += 1
          W(cur_encl.head_location) if include_ambiguous_expr?
        when "%"
          @mod_exprs[cur_encl] += 1
          W(cur_encl.head_location) if include_ambiguous_expr?
        end
        super
      end

      def visit_conditional_expression(node)
        cond_expr = node.condition
        then_expr = node.then_expression
        else_expr = node.else_expression
        AmbiguousExpressionDetector.new(@phase_ctxt, cond_expr).execute
        AmbiguousExpressionDetector.new(@phase_ctxt, then_expr).execute
        AmbiguousExpressionDetector.new(@phase_ctxt, else_expr).execute
      end

      private
      def include_ambiguous_expr?
        cur_encl = current_encl_expr
        return false if @mod_exprs[cur_encl] == 0

        additive_exprs =
          @add_exprs[cur_encl] + @sub_exprs[cur_encl]
        multiplicative_exprs =
          @mul_exprs[cur_encl] + @div_exprs[cur_encl] + @mod_exprs[cur_encl]

        additive_exprs > 0 && multiplicative_exprs > 0 or
        multiplicative_exprs > 1
      end

      def current_encl_expr
        @encl_expr_stack.last
      end

      extend Forwardable

      def_delegator :@phase_ctxt, :report
      private :report

      def_delegator :@phase_ctxt, :message_catalog
      private :message_catalog

      def suppressors
        @phase_ctxt[:suppressors]
      end
    end
    private_constant :AmbiguousExpressionDetector
  end

  class W0496 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: W0496 may be duplicative when problematic operators appear thrice
    #       or more in an expression.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_initializer          += T(:check_initializer)
      visitor.enter_expression_statement += T(:check_expr_statement)
      visitor.enter_if_statement         += T(:check_selection_statement)
      visitor.enter_if_else_statement    += T(:check_selection_statement)
      visitor.enter_switch_statement     += T(:check_selection_statement)
      visitor.enter_while_statement      += T(:check_iteration_statement)
      visitor.enter_do_statement         += T(:check_iteration_statement)
      visitor.enter_for_statement        += T(:check_iteration_statement)
      visitor.enter_c99_for_statement    += T(:check_iteration_statement)
      visitor.enter_return_statement     += T(:check_return_statement)
    end

    private
    def check_initializer(node)
      Cc1::ConditionalExpressionExtractor.new.tap { |extr|
        node.accept(extr)
      }.expressions.each do |expr|
        AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
      end
    end

    def check_expr_statement(node)
      return unless node.expression

      Cc1::ConditionalExpressionExtractor.new.tap { |extr|
        node.expression.accept(extr)
      }.expressions.each do |expr|
        AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
      end
    end

    def check_selection_statement(node)
      Cc1::ConditionalExpressionExtractor.new.tap { |extr|
        node.expression.accept(extr)
      }.expressions.each do |expr|
        AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
      end
    end

    def check_iteration_statement(node)
      return unless node.expression

      Cc1::ConditionalExpressionExtractor.new.tap { |extr|
        node.expression.accept(extr)
      }.expressions.each do |expr|
        AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
      end
    end

    def check_return_statement(node)
      return unless node.expression

      Cc1::ConditionalExpressionExtractor.new.tap { |extr|
        node.expression.accept(extr)
      }.expressions.each do |expr|
        AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
      end
    end

    class AmbiguousExpressionDetector < Cc1::SyntaxTreeVisitor
      include ReportUtil

      def initialize(phase_ctxt, expr)
        @phase_ctxt      = phase_ctxt
        @target_expr     = expr
        @encl_expr_stack = [expr]
        @cond_exprs      = Hash.new(0)
      end

      def execute
        @target_expr.accept(self)
      end

      def visit_grouped_expression(node)
        @encl_expr_stack.push(node)
        super
        @encl_expr_stack.pop
      end

      def visit_conditional_expression(node)
        super
        cur_encl = current_encl_expr
        if @cond_exprs[cur_encl] > 0
          W(cur_encl.head_location)
        end
        @cond_exprs[cur_encl] += 1
      end

      private
      def current_encl_expr
        @encl_expr_stack.last
      end

      extend Forwardable

      def_delegator :@phase_ctxt, :report
      private :report

      def_delegator :@phase_ctxt, :message_catalog
      private :message_catalog

      def suppressors
        @phase_ctxt[:suppressors]
      end
    end
    private_constant :AmbiguousExpressionDetector
  end

  class W0497 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: W0497 may be duplicative when problematic operators appear thrice
    #       or more in an expression.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_initializer          += T(:check_initializer)
      visitor.enter_expression_statement += T(:check_expr_statement)
      visitor.enter_if_statement         += T(:check_selection_statement)
      visitor.enter_if_else_statement    += T(:check_selection_statement)
      visitor.enter_switch_statement     += T(:check_selection_statement)
      visitor.enter_while_statement      += T(:check_iteration_statement)
      visitor.enter_do_statement         += T(:check_iteration_statement)
      visitor.enter_for_statement        += T(:check_iteration_statement)
      visitor.enter_c99_for_statement    += T(:check_iteration_statement)
      visitor.enter_return_statement     += T(:check_return_statement)
    end

    private
    def check_initializer(node)
      Cc1::ExpressionExtractor.new.tap { |extr|
        node.accept(extr)
      }.expressions.each do |expr|
        AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
      end
    end

    def check_expr_statement(node)
      return unless node.expression

      Cc1::ExpressionExtractor.new.tap { |extr|
        node.expression.accept(extr)
      }.expressions.each do |expr|
        AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
      end
    end

    def check_selection_statement(node)
      Cc1::ExpressionExtractor.new.tap { |extr|
        node.expression.accept(extr)
      }.expressions.each do |expr|
        AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
      end
    end

    def check_iteration_statement(node)
      return unless node.expression

      Cc1::ExpressionExtractor.new.tap { |extr|
        node.expression.accept(extr)
      }.expressions.each do |expr|
        AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
      end
    end

    def check_return_statement(node)
      return unless node.expression

      Cc1::ExpressionExtractor.new.tap { |extr|
        node.expression.accept(extr)
      }.expressions.each do |expr|
        AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
      end
    end

    class AmbiguousExpressionDetector < Cc1::SyntaxTreeVisitor
      include ReportUtil

      def initialize(phase_ctxt, expr)
        @phase_ctxt      = phase_ctxt
        @target_expr     = expr
        @encl_expr_stack = [expr]
        @shr_exprs       = Hash.new(0)
        @shl_exprs       = Hash.new(0)
        @lt_exprs        = Hash.new(0)
        @gt_exprs        = Hash.new(0)
        @le_exprs        = Hash.new(0)
        @ge_exprs        = Hash.new(0)
        @eq_exprs        = Hash.new(0)
        @ne_exprs        = Hash.new(0)
      end

      def execute
        @target_expr.accept(self)
      end

      def visit_grouped_expression(node)
        @encl_expr_stack.push(node)
        super
        @encl_expr_stack.pop
      end

      def visit_array_subscript_expression(node)
        AmbiguousExpressionDetector.new(@phase_ctxt,
                                        node.array_subscript).execute
      end

      def visit_function_call_expression(node)
        node.argument_expressions.each do |expr|
          AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
        end
      end

      def visit_shift_expression(node)
        cur_encl = current_encl_expr
        case node.operator.type
        when "<<"
          @shl_exprs[cur_encl] += 1
          W(cur_encl.head_location) if include_ambiguous_expr?
        when ">>"
          @shr_exprs[cur_encl] += 1
          W(cur_encl.head_location) if include_ambiguous_expr?
        end
        super
      end

      def visit_relational_expression(node)
        cur_encl = current_encl_expr
        case node.operator.type
        when "<"
          @lt_exprs[cur_encl] += 1
          W(cur_encl.head_location) if include_ambiguous_expr?
        when ">"
          @gt_exprs[cur_encl] += 1
          W(cur_encl.head_location) if include_ambiguous_expr?
        when "<="
          @le_exprs[cur_encl] += 1
          W(cur_encl.head_location) if include_ambiguous_expr?
        when ">="
          @ge_exprs[cur_encl] += 1
          W(cur_encl.head_location) if include_ambiguous_expr?
        end
        super
      end

      def visit_equality_expression(node)
        cur_encl = current_encl_expr
        case node.operator.type
        when "=="
          @eq_exprs[cur_encl] += 1
          W(cur_encl.head_location) if include_ambiguous_expr?
        when "!="
          @ne_exprs[cur_encl] += 1
          W(cur_encl.head_location) if include_ambiguous_expr?
        end
        super
      end

      def visit_conditional_expression(node)
        cond_expr = node.condition
        then_expr = node.then_expression
        else_expr = node.else_expression
        AmbiguousExpressionDetector.new(@phase_ctxt, cond_expr).execute
        AmbiguousExpressionDetector.new(@phase_ctxt, then_expr).execute
        AmbiguousExpressionDetector.new(@phase_ctxt, else_expr).execute
      end

      private
      def include_ambiguous_expr?
        cur_encl = current_encl_expr
        @shl_exprs[cur_encl] > 1 || @shr_exprs[cur_encl] > 1 ||
          @lt_exprs[cur_encl] > 1 || @gt_exprs[cur_encl] > 1 ||
          @le_exprs[cur_encl] > 1 || @ge_exprs[cur_encl] > 1 ||
          @eq_exprs[cur_encl] > 1 || @ne_exprs[cur_encl] > 1
      end

      def current_encl_expr
        @encl_expr_stack.last
      end

      extend Forwardable

      def_delegator :@phase_ctxt, :report
      private :report

      def_delegator :@phase_ctxt, :message_catalog
      private :message_catalog

      def suppressors
        @phase_ctxt[:suppressors]
      end
    end
    private_constant :AmbiguousExpressionDetector
  end

  class W0498 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: W0498 may be duplicative when operators of the same priority are
    #       used thrice or more.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_initializer          += T(:check_initializer)
      visitor.enter_expression_statement += T(:check_expr_statement)
      visitor.enter_if_statement         += T(:check_selection_statement)
      visitor.enter_if_else_statement    += T(:check_selection_statement)
      visitor.enter_switch_statement     += T(:check_selection_statement)
      visitor.enter_while_statement      += T(:check_iteration_statement)
      visitor.enter_do_statement         += T(:check_iteration_statement)
      visitor.enter_for_statement        += T(:check_iteration_statement)
      visitor.enter_c99_for_statement    += T(:check_iteration_statement)
      visitor.enter_return_statement     += T(:check_return_statement)
    end

    private
    def check_initializer(node)
      Cc1::ExpressionExtractor.new.tap { |extr|
        node.accept(extr)
      }.expressions.each do |expr|
        AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
      end
    end

    def check_expr_statement(node)
      return unless node.expression

      Cc1::ExpressionExtractor.new.tap { |extr|
        node.expression.accept(extr)
      }.expressions.each do |expr|
        AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
      end
    end

    def check_selection_statement(node)
      Cc1::ExpressionExtractor.new.tap { |extr|
        node.expression.accept(extr)
      }.expressions.each do |expr|
        AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
      end
    end

    def check_iteration_statement(node)
      return unless node.expression

      Cc1::ExpressionExtractor.new.tap { |extr|
        node.expression.accept(extr)
      }.expressions.each do |expr|
        AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
      end
    end

    def check_return_statement(node)
      return unless node.expression

      Cc1::ExpressionExtractor.new.tap { |extr|
        node.expression.accept(extr)
      }.expressions.each do |expr|
        AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
      end
    end

    class AmbiguousExpressionDetector < Cc1::SyntaxTreeVisitor
      include ReportUtil

      def initialize(phase_ctxt, expr)
        @phase_ctxt      = phase_ctxt
        @target_expr     = expr
        @encl_expr_stack = [expr]
        @add_exprs       = Hash.new(0)
        @sub_exprs       = Hash.new(0)
        @mul_exprs       = Hash.new(0)
        @div_exprs       = Hash.new(0)
      end

      def execute
        @target_expr.accept(self)
      end

      def visit_grouped_expression(node)
        @encl_expr_stack.push(node)
        super
        @encl_expr_stack.pop
      end

      def visit_array_subscript_expression(node)
        AmbiguousExpressionDetector.new(@phase_ctxt,
                                        node.array_subscript).execute
      end

      def visit_function_call_expression(node)
        node.argument_expressions.each do |expr|
          AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
        end
      end

      def visit_additive_expression(node)
        cur_encl = current_encl_expr
        case node.operator.type
        when "+"
          @add_exprs[cur_encl] += 1
          W(cur_encl.head_location) if include_ambiguous_expr?
        when "-"
          @sub_exprs[cur_encl] += 1
          W(cur_encl.head_location) if include_ambiguous_expr?
        end
        super
      end

      def visit_multiplicative_expression(node)
        cur_encl = current_encl_expr
        case node.operator.type
        when "*"
          @mul_exprs[cur_encl] += 1
          W(cur_encl.head_location) if include_ambiguous_expr?
        when "/"
          @div_exprs[cur_encl] += 1
          W(cur_encl.head_location) if include_ambiguous_expr?
        end
        super
      end

      def visit_conditional_expression(node)
        cond_expr = node.condition
        then_expr = node.then_expression
        else_expr = node.else_expression
        AmbiguousExpressionDetector.new(@phase_ctxt, cond_expr).execute
        AmbiguousExpressionDetector.new(@phase_ctxt, then_expr).execute
        AmbiguousExpressionDetector.new(@phase_ctxt, else_expr).execute
      end

      private
      def include_ambiguous_expr?
        cur_encl = current_encl_expr
        @add_exprs[cur_encl] > 0 && @sub_exprs[cur_encl] > 0 or
        @mul_exprs[cur_encl] > 0 && @div_exprs[cur_encl] > 0
      end

      def current_encl_expr
        @encl_expr_stack.last
      end

      extend Forwardable

      def_delegator :@phase_ctxt, :report
      private :report

      def_delegator :@phase_ctxt, :message_catalog
      private :message_catalog

      def suppressors
        @phase_ctxt[:suppressors]
      end
    end
    private_constant :AmbiguousExpressionDetector
  end

  class W0499 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: W0499 may be duplicative when operators of the same priority are
    #       used thrice or more.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_initializer          += T(:check_initializer)
      visitor.enter_expression_statement += T(:check_expr_statement)
      visitor.enter_if_statement         += T(:check_selection_statement)
      visitor.enter_if_else_statement    += T(:check_selection_statement)
      visitor.enter_switch_statement     += T(:check_selection_statement)
      visitor.enter_while_statement      += T(:check_iteration_statement)
      visitor.enter_do_statement         += T(:check_iteration_statement)
      visitor.enter_for_statement        += T(:check_iteration_statement)
      visitor.enter_c99_for_statement    += T(:check_iteration_statement)
      visitor.enter_return_statement     += T(:check_return_statement)
    end

    private
    def check_initializer(node)
      Cc1::ExpressionExtractor.new.tap { |extr|
        node.accept(extr)
      }.expressions.each do |expr|
        AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
      end
    end

    def check_expr_statement(node)
      return unless node.expression

      Cc1::ExpressionExtractor.new.tap { |extr|
        node.expression.accept(extr)
      }.expressions.each do |expr|
        AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
      end
    end

    def check_selection_statement(node)
      Cc1::ExpressionExtractor.new.tap { |extr|
        node.expression.accept(extr)
      }.expressions.each do |expr|
        AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
      end
    end

    def check_iteration_statement(node)
      return unless node.expression

      Cc1::ExpressionExtractor.new.tap { |extr|
        node.expression.accept(extr)
      }.expressions.each do |expr|
        AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
      end
    end

    def check_return_statement(node)
      return unless node.expression

      Cc1::ExpressionExtractor.new.tap { |extr|
        node.expression.accept(extr)
      }.expressions.each do |expr|
        AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
      end
    end

    class AmbiguousExpressionDetector < Cc1::SyntaxTreeVisitor
      include ReportUtil

      def initialize(phase_ctxt, expr)
        @phase_ctxt      = phase_ctxt
        @target_expr     = expr
        @encl_expr_stack = [expr]
        @shr_exprs       = Hash.new(0)
        @shl_exprs       = Hash.new(0)
        @lt_exprs        = Hash.new(0)
        @gt_exprs        = Hash.new(0)
        @le_exprs        = Hash.new(0)
        @ge_exprs        = Hash.new(0)
        @eq_exprs        = Hash.new(0)
        @ne_exprs        = Hash.new(0)
      end

      def execute
        @target_expr.accept(self)
      end

      def visit_grouped_expression(node)
        @encl_expr_stack.push(node)
        super
        @encl_expr_stack.pop
      end

      def visit_array_subscript_expression(node)
        AmbiguousExpressionDetector.new(@phase_ctxt,
                                        node.array_subscript).execute
      end

      def visit_function_call_expression(node)
        node.argument_expressions.each do |expr|
          AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
        end
      end

      def visit_shift_expression(node)
        cur_encl = current_encl_expr
        case node.operator.type
        when "<<"
          @shl_exprs[cur_encl] += 1
          W(cur_encl.head_location) if include_ambiguous_expr?
        when ">>"
          @shr_exprs[cur_encl] += 1
          W(cur_encl.head_location) if include_ambiguous_expr?
        end
        super
      end

      def visit_relational_expression(node)
        cur_encl = current_encl_expr
        case node.operator.type
        when "<"
          @lt_exprs[cur_encl] += 1
          W(cur_encl.head_location) if include_ambiguous_expr?
        when ">"
          @gt_exprs[cur_encl] += 1
          W(cur_encl.head_location) if include_ambiguous_expr?
        when "<="
          @le_exprs[cur_encl] += 1
          W(cur_encl.head_location) if include_ambiguous_expr?
        when ">="
          @ge_exprs[cur_encl] += 1
          W(cur_encl.head_location) if include_ambiguous_expr?
        end
        super
      end

      def visit_equality_expression(node)
        cur_encl = current_encl_expr
        case node.operator.type
        when "=="
          @eq_exprs[cur_encl] += 1
          W(cur_encl.head_location) if include_ambiguous_expr?
        when "!="
          @ne_exprs[cur_encl] += 1
          W(cur_encl.head_location) if include_ambiguous_expr?
        end
        super
      end

      def visit_conditional_expression(node)
        cond_expr = node.condition
        then_expr = node.then_expression
        else_expr = node.else_expression
        AmbiguousExpressionDetector.new(@phase_ctxt, cond_expr).execute
        AmbiguousExpressionDetector.new(@phase_ctxt, then_expr).execute
        AmbiguousExpressionDetector.new(@phase_ctxt, else_expr).execute
      end

      private
      def include_ambiguous_expr?
        cur_encl = current_encl_expr

        shl_expr_num = @shl_exprs[cur_encl]
        shr_expr_num = @shr_exprs[cur_encl]
        lt_expr_num  = @lt_exprs[cur_encl]
        gt_expr_num  = @gt_exprs[cur_encl]
        le_expr_num  = @le_exprs[cur_encl]
        ge_expr_num  = @ge_exprs[cur_encl]
        eq_expr_num  = @eq_exprs[cur_encl]
        ne_expr_num  = @ne_exprs[cur_encl]

        shl_expr_num > 0 && shr_expr_num > 0 or
        lt_expr_num > 0 && (gt_expr_num + le_expr_num + ge_expr_num) > 0 or
        gt_expr_num > 0 && (lt_expr_num + le_expr_num + ge_expr_num) > 0 or
        le_expr_num > 0 && (lt_expr_num + gt_expr_num + ge_expr_num) > 0 or
        ge_expr_num > 0 && (lt_expr_num + gt_expr_num + le_expr_num) > 0 or
        eq_expr_num > 0 && ne_expr_num > 0
      end

      def current_encl_expr
        @encl_expr_stack.last
      end

      extend Forwardable

      def_delegator :@phase_ctxt, :report
      private :report

      def_delegator :@phase_ctxt, :message_catalog
      private :message_catalog

      def suppressors
        @phase_ctxt[:suppressors]
      end
    end
    private_constant :AmbiguousExpressionDetector
  end

  class W0500 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: W0500 may be duplicative when operators of the different priority
    #       are used thrice or more.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_initializer          += T(:check_initializer)
      visitor.enter_expression_statement += T(:check_expr_statement)
      visitor.enter_if_statement         += T(:check_selection_statement)
      visitor.enter_if_else_statement    += T(:check_selection_statement)
      visitor.enter_switch_statement     += T(:check_selection_statement)
      visitor.enter_while_statement      += T(:check_iteration_statement)
      visitor.enter_do_statement         += T(:check_iteration_statement)
      visitor.enter_for_statement        += T(:check_iteration_statement)
      visitor.enter_c99_for_statement    += T(:check_iteration_statement)
      visitor.enter_return_statement     += T(:check_return_statement)
    end

    private
    def check_initializer(node)
      Cc1::ExpressionExtractor.new.tap { |extr|
        node.accept(extr)
      }.expressions.each do |expr|
        AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
      end
    end

    def check_expr_statement(node)
      return unless node.expression

      Cc1::ExpressionExtractor.new.tap { |extr|
        node.expression.accept(extr)
      }.expressions.each do |expr|
        AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
      end
    end

    def check_selection_statement(node)
      Cc1::ExpressionExtractor.new.tap { |extr|
        node.expression.accept(extr)
      }.expressions.each do |expr|
        AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
      end
    end

    def check_iteration_statement(node)
      return unless node.expression

      Cc1::ExpressionExtractor.new.tap { |extr|
        node.expression.accept(extr)
      }.expressions.each do |expr|
        AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
      end
    end

    def check_return_statement(node)
      return unless node.expression

      Cc1::ExpressionExtractor.new.tap { |extr|
        node.expression.accept(extr)
      }.expressions.each do |expr|
        AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
      end
    end

    class AmbiguousExpressionDetector < Cc1::SyntaxTreeVisitor
      include ReportUtil

      def initialize(phase_ctxt, expr)
        @phase_ctxt      = phase_ctxt
        @target_expr     = expr
        @encl_expr_stack = [expr]
        @add_exprs       = Hash.new(0)
        @sub_exprs       = Hash.new(0)
        @mul_exprs       = Hash.new(0)
        @div_exprs       = Hash.new(0)
      end

      def execute
        @target_expr.accept(self)
      end

      def visit_grouped_expression(node)
        @encl_expr_stack.push(node)
        super
        @encl_expr_stack.pop
      end

      def visit_array_subscript_expression(node)
        AmbiguousExpressionDetector.new(@phase_ctxt,
                                        node.array_subscript).execute
      end

      def visit_function_call_expression(node)
        node.argument_expressions.each do |expr|
          AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
        end
      end

      def visit_multiplicative_expression(node)
        cur_encl = current_encl_expr
        case node.operator.type
        when "*"
          @mul_exprs[cur_encl] += 1
          W(cur_encl.head_location) if include_ambiguous_expr?
        when "/"
          @div_exprs[cur_encl] += 1
          W(cur_encl.head_location) if include_ambiguous_expr?
        end
        super
      end

      def visit_additive_expression(node)
        cur_encl = current_encl_expr
        case node.operator.type
        when "+"
          @add_exprs[cur_encl] += 1
          W(cur_encl.head_location) if include_ambiguous_expr?
        when "-"
          @sub_exprs[cur_encl] += 1
          W(cur_encl.head_location) if include_ambiguous_expr?
        end
        super
      end

      def visit_conditional_expression(node)
        cond_expr = node.condition
        then_expr = node.then_expression
        else_expr = node.else_expression
        AmbiguousExpressionDetector.new(@phase_ctxt, cond_expr).execute
        AmbiguousExpressionDetector.new(@phase_ctxt, then_expr).execute
        AmbiguousExpressionDetector.new(@phase_ctxt, else_expr).execute
      end

      private
      def include_ambiguous_expr?
        cur_encl = current_encl_expr
        (@add_exprs[cur_encl] + @sub_exprs[cur_encl]) > 0 &&
          (@mul_exprs[cur_encl] + @div_exprs[cur_encl]) > 0
      end

      def current_encl_expr
        @encl_expr_stack.last
      end

      extend Forwardable

      def_delegator :@phase_ctxt, :report
      private :report

      def_delegator :@phase_ctxt, :message_catalog
      private :message_catalog

      def suppressors
        @phase_ctxt[:suppressors]
      end
    end
    private_constant :AmbiguousExpressionDetector
  end

  class W0501 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: W0501 may be duplicative when problematic operators appear thrice
    #       or more in an expression.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_initializer          += T(:check_initializer)
      visitor.enter_expression_statement += T(:check_expr_statement)
      visitor.enter_if_statement         += T(:check_selection_statement)
      visitor.enter_if_else_statement    += T(:check_selection_statement)
      visitor.enter_switch_statement     += T(:check_selection_statement)
      visitor.enter_while_statement      += T(:check_iteration_statement)
      visitor.enter_do_statement         += T(:check_iteration_statement)
      visitor.enter_for_statement        += T(:check_iteration_statement)
      visitor.enter_c99_for_statement    += T(:check_iteration_statement)
      visitor.enter_return_statement     += T(:check_return_statement)
    end

    private
    def check_initializer(node)
      Cc1::ConditionalExpressionExtractor.new.tap { |extr|
        node.accept(extr)
      }.expressions.each do |expr|
        AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
      end
    end

    def check_expr_statement(node)
      return unless node.expression

      Cc1::ConditionalExpressionExtractor.new.tap { |extr|
        node.expression.accept(extr)
      }.expressions.each do |expr|
        AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
      end
    end

    def check_selection_statement(node)
      Cc1::ConditionalExpressionExtractor.new.tap { |extr|
        node.expression.accept(extr)
      }.expressions.each do |expr|
        AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
      end
    end

    def check_iteration_statement(node)
      return unless node.expression

      Cc1::ConditionalExpressionExtractor.new.tap { |extr|
        node.expression.accept(extr)
      }.expressions.each do |expr|
        AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
      end
    end

    def check_return_statement(node)
      return unless node.expression

      Cc1::ConditionalExpressionExtractor.new.tap { |extr|
        node.expression.accept(extr)
      }.expressions.each do |expr|
        AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
      end
    end

    class AmbiguousExpressionDetector < Cc1::SyntaxTreeVisitor
      include ReportUtil

      def initialize(phase_ctxt, expr)
        @phase_ctxt     = phase_ctxt
        @target_expr    = expr
        @group_depth    = 0
        @ungrouped_expr = 0
      end

      def execute
        @target_expr.accept(self)
      end

      def visit_grouped_expression(node)
        @group_depth += 1
        super
        @group_depth -= 1
      end

      def visit_multiplicative_expression(node)
        check_binary_expression
        super
      end

      def visit_additive_expression(node)
        check_binary_expression
        super
      end

      def visit_shift_expression(node)
        check_binary_expression
        super
      end

      def visit_relational_expression(node)
        check_binary_expression
        super
      end

      def visit_equality_expression(node)
        check_binary_expression
        super
      end

      def visit_and_expression(node)
        check_binary_expression
        super
      end

      def visit_exclusive_or_expression(node)
        check_binary_expression
        super
      end

      def visit_inclusive_or_expression(node)
        check_binary_expression
        super
      end

      def visit_logical_and_expression(node)
        check_binary_expression
        super
      end

      def visit_logical_or_expression(node)
        check_binary_expression
        super
      end

      def visit_simple_assignment_expression(node)
        check_binary_expression
        super
      end

      def visit_compound_assignment_expression(node)
        check_binary_expression
        super
      end

      private
      def check_binary_expression
        @ungrouped_expr += 1 if @group_depth == 0
        W(@target_expr.location) if include_ambiguous_expr?
      end

      def include_ambiguous_expr?
        @ungrouped_expr > 0
      end

      extend Forwardable

      def_delegator :@phase_ctxt, :report
      private :report

      def_delegator :@phase_ctxt, :message_catalog
      private :message_catalog

      def suppressors
        @phase_ctxt[:suppressors]
      end
    end
    private_constant :AmbiguousExpressionDetector
  end

  class W0502 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: W0502 may be duplicative when operators of the different priority
    #       are used thrice or more.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_initializer          += T(:check_initializer)
      visitor.enter_expression_statement += T(:check_expr_statement)
      visitor.enter_if_statement         += T(:check_selection_statement)
      visitor.enter_if_else_statement    += T(:check_selection_statement)
      visitor.enter_switch_statement     += T(:check_selection_statement)
      visitor.enter_while_statement      += T(:check_iteration_statement)
      visitor.enter_do_statement         += T(:check_iteration_statement)
      visitor.enter_for_statement        += T(:check_iteration_statement)
      visitor.enter_c99_for_statement    += T(:check_iteration_statement)
      visitor.enter_return_statement     += T(:check_return_statement)
    end

    private
    def check_initializer(node)
      Cc1::ExpressionExtractor.new.tap { |extr|
        node.accept(extr)
      }.expressions.each do |expr|
        AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
      end
    end

    def check_expr_statement(node)
      return unless node.expression

      Cc1::ExpressionExtractor.new.tap { |extr|
        node.expression.accept(extr)
      }.expressions.each do |expr|
        AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
      end
    end

    def check_selection_statement(node)
      Cc1::ExpressionExtractor.new.tap { |extr|
        node.expression.accept(extr)
      }.expressions.each do |expr|
        AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
      end
    end

    def check_iteration_statement(node)
      return unless node.expression

      Cc1::ExpressionExtractor.new.tap { |extr|
        node.expression.accept(extr)
      }.expressions.each do |expr|
        AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
      end
    end

    def check_return_statement(node)
      return unless node.expression

      Cc1::ExpressionExtractor.new.tap { |extr|
        node.expression.accept(extr)
      }.expressions.each do |expr|
        AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
      end
    end

    class AmbiguousExpressionDetector < Cc1::SyntaxTreeVisitor
      include ReportUtil

      def initialize(phase_ctxt, expr)
        @phase_ctxt      = phase_ctxt
        @target_expr     = expr
        @encl_expr_stack = [expr]
        @arith_exprs     = Hash.new(0)
        @shift_exprs     = Hash.new(0)
        @relat_exprs     = Hash.new(0)
        @equal_exprs     = Hash.new(0)
        @and_exprs       = Hash.new(0)
        @xor_exprs       = Hash.new(0)
        @or_exprs        = Hash.new(0)
        @land_exprs      = Hash.new(0)
      end

      def execute
        @target_expr.accept(self)
      end

      def visit_grouped_expression(node)
        @encl_expr_stack.push(node)
        super
        @encl_expr_stack.pop
      end

      def visit_array_subscript_expression(node)
        AmbiguousExpressionDetector.new(@phase_ctxt,
                                        node.array_subscript).execute
      end

      def visit_function_call_expression(node)
        node.argument_expressions.each do |expr|
          AmbiguousExpressionDetector.new(@phase_ctxt, expr).execute
        end
      end

      def visit_multiplicative_expression(node)
        super
        @arith_exprs[current_encl_expr] += 1
      end

      def visit_additive_expression(node)
        super
        @arith_exprs[current_encl_expr] += 1
      end

      def visit_shift_expression(node)
        super
        @shift_exprs[current_encl_expr] += 1
        if current_arith_exprs > 0
          W(current_encl_expr.head_location)
        end
      end

      def visit_relational_expression(node)
        super
        @relat_exprs[current_encl_expr] += 1
        if current_arith_exprs + current_shift_exprs > 0
          W(current_encl_expr.head_location)
        end
      end

      def visit_equality_expression(node)
        super
        @equal_exprs[current_encl_expr] += 1
        if current_arith_exprs + current_shift_exprs + current_relat_exprs > 0
          W(current_encl_expr.head_location)
        end
      end

      def visit_and_expression(node)
        super
        @and_exprs[current_encl_expr] += 1
        if current_arith_exprs + current_shift_exprs +
            current_relat_exprs + current_equal_exprs > 0
          W(current_encl_expr.head_location)
        end
      end

      def visit_exclusive_or_expression(node)
        super
        @xor_exprs[current_encl_expr] += 1
        if current_arith_exprs + current_shift_exprs +
            current_relat_exprs + current_equal_exprs + current_and_exprs > 0
          W(current_encl_expr.head_location)
        end
      end

      def visit_inclusive_or_expression(node)
        super
        @or_exprs[current_encl_expr] += 1
        if current_arith_exprs + current_shift_exprs +
            current_relat_exprs + current_equal_exprs +
            current_and_exprs + current_xor_exprs > 0
          W(current_encl_expr.head_location)
        end
      end

      def visit_logical_and_expression(node)
        super
        @land_exprs[current_encl_expr] += 1
        if current_arith_exprs + current_shift_exprs +
            current_relat_exprs + current_equal_exprs +
            current_and_exprs + current_xor_exprs + current_or_exprs > 0
          W(current_encl_expr.head_location)
        end
      end

      def visit_logical_or_expression(node)
        super
        if current_arith_exprs + current_shift_exprs +
            current_relat_exprs + current_equal_exprs +
            current_and_exprs + current_xor_exprs + current_or_exprs +
            current_land_exprs > 0
          W(current_encl_expr.head_location)
        end
      end

      def visit_conditional_expression(node)
        cond_expr = node.condition
        then_expr = node.then_expression
        else_expr = node.else_expression
        AmbiguousExpressionDetector.new(@phase_ctxt, cond_expr).execute
        AmbiguousExpressionDetector.new(@phase_ctxt, then_expr).execute
        AmbiguousExpressionDetector.new(@phase_ctxt, else_expr).execute
      end

      private
      def current_arith_exprs
        @arith_exprs[current_encl_expr]
      end

      def current_shift_exprs
        @shift_exprs[current_encl_expr]
      end

      def current_relat_exprs
        @relat_exprs[current_encl_expr]
      end

      def current_equal_exprs
        @equal_exprs[current_encl_expr]
      end

      def current_and_exprs
        @and_exprs[current_encl_expr]
      end

      def current_xor_exprs
        @xor_exprs[current_encl_expr]
      end

      def current_or_exprs
        @or_exprs[current_encl_expr]
      end

      def current_land_exprs
        @land_exprs[current_encl_expr]
      end

      def current_encl_expr
        @encl_expr_stack.last
      end

      extend Forwardable

      def_delegator :@phase_ctxt, :report
      private :report

      def_delegator :@phase_ctxt, :message_catalog
      private :message_catalog

      def suppressors
        @phase_ctxt[:suppressors]
      end
    end
    private_constant :AmbiguousExpressionDetector
  end

  class W0508 < PassiveCodeCheck
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
    def check(node)
      W(node.location) if node.rhs_operand.have_side_effect?
    end
  end

  class W0512 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_expression_statement         += T(:enter_expr_stmt)
      visitor.leave_expression_statement         += T(:leave_expr_stmt)
      visitor.enter_postfix_increment_expression += T(:check)
      visitor.enter_postfix_decrement_expression += T(:check)
      visitor.enter_prefix_increment_expression  += T(:check)
      visitor.enter_prefix_decrement_expression  += T(:check)
      @cur_stmt = nil
    end

    private
    def enter_expr_stmt(node)
      @cur_stmt = node
    end

    def leave_expr_stmt(node)
      @cur_stmt = nil
    end

    def check(node)
      if @cur_stmt
        unless @cur_stmt.expression == node
          W(node.location)
        end
      end
    end
  end

  class W0525 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_member_declaration += T(:check)
    end

    private
    def check(node)
      return unless node.type.scalar? && node.type.integer?
      if node.type.bitfield? && node.type.signed? && node.type.bit_size == 1
        W(node.location)
      end
    end
  end

  class W0529 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_constant_specifier += T(:check)
    end

    private
    def check(node)
      if node.constant.value =~ /\A0[0-9]+[UL]*\z/i
        W(node.location)
      end
    end
  end

  class W0530 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_constant_specifier       += T(:check_constant)
      visitor.enter_string_literal_specifier += T(:check_string_literal)
    end

    private
    def check_constant(node)
      if node.constant.value =~ /\AL?'.*\\0[0-9]+.*'\z/i
        W(node.location)
      end
    end

    def check_string_literal(node)
      if node.literal.value =~ /\AL?".*\\0[0-9]+.*"\z/i
        W(node.location)
      end
    end
  end

  class W0532 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_switch_statement += T(:check_switch_statement)
    end

    private
    def check_switch_statement(node)
      return unless node.statement.kind_of?(Cc1::CompoundStatement)

      node.statement.block_items.each_with_index do |item, idx|
        effective_breaks = EffectiveBreakCollector.new.execute(item)
        unless effective_breaks.empty?
          if nxt_item = node.statement.block_items[idx + 1]
            while nxt_item.kind_of?(Cc1::GenericLabeledStatement)
              nxt_item = nxt_item.statement
            end

            case nxt_item
            when Cc1::CaseLabeledStatement, Cc1::DefaultLabeledStatement
              ;
            else
              effective_breaks.each do |effective_break|
                W(effective_break.location)
              end
            end
          end
        end
      end
    end

    class EffectiveBreakCollector < Cc1::SyntaxTreeVisitor
      def initialize
        @result = []
      end

      def execute(node)
        node.accept(self)
        @result
      end

      def visit_switch_statement(node) end

      def visit_while_statement(node) end

      def visit_do_statement(node) end

      def visit_for_statement(node) end

      def visit_c99_for_statement(node) end

      def visit_break_statement(node)
        @result.push(node)
      end
    end
    private_constant :EffectiveBreakCollector
  end

  class W0534 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    include Cc1::SyntaxNodeCollector

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_for_stmt_started     += T(:check_for_stmt)
      @interp.on_c99_for_stmt_started += T(:check_c99_for_stmt)
    end

    private
    def check_for_stmt(node)
      inited_var_names =
        collect_object_specifiers(node.initial_statement).map { |os|
          os.identifier.value
        }
      if ctrl_var_name = deduct_ctrl_variable_name(node, inited_var_names)
        unless inited_var_names.include?(ctrl_var_name)
          W(node.initial_statement.location, ctrl_var_name)
        end
      end
    end

    def check_c99_for_stmt(node)
      inited_var_names =
        collect_identifier_declarators(node.declaration).map { |id|
          id.identifier.value
        }
      if ctrl_var_name = deduct_ctrl_variable_name(node, inited_var_names)
        unless inited_var_names.include?(ctrl_var_name)
          W(node.declaration.location, ctrl_var_name)
        end
      end
    end

    def deduct_ctrl_variable_name(node, inited_var_names)
      var_names = inited_var_names + node.varying_variable_names
      histo = var_names.each_with_object({}) { |name, hash| hash[name] = 0 }

      ctrl_expr, * = node.deduct_controlling_expression
      collect_object_specifiers(ctrl_expr).map { |obj_spec|
        obj_spec.identifier.value
      }.each { |obj_name| histo.include?(obj_name) and histo[obj_name] += 1 }

      histo.to_a.sort { |a, b| b.last <=> a.last }.map(&:first).find do |name|
        var = @interp.variable_named(name) and !var.type.const?
      end
    end
  end

  class W0535 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_comma_separated_expression += T(:check)
      visitor.enter_for_statement              += T(:enter_for_statement)
      visitor.leave_for_statement              += T(:leave_for_statement)
      visitor.enter_c99_for_statement          += T(:enter_for_statement)
      visitor.leave_c99_for_statement          += T(:leave_for_statement)
      @in_for_stmt = false
    end

    private
    def check(node)
      W(node.location) if @in_for_stmt
    end

    def enter_for_statement(node)
      @in_for_stmt = true
    end

    def leave_for_statement(node)
      @in_for_stmt = false
    end
  end

  class W0538 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_switch_statement += T(:check)
    end

    private
    def check(node)
      return unless node.statement.kind_of?(Cc1::CompoundStatement)

      labeled_stmt, idx = find_default_labeled_statement(node.statement)

      if labeled_stmt
        unless final_clause?(idx, node.statement)
          W(labeled_stmt.location)
        end
      end
    end

    def find_default_labeled_statement(compound_stmt)
      compound_stmt.block_items.each_with_index do |item, idx|
        case item
        when Cc1::GenericLabeledStatement
          item = item.statement
          redo
        when Cc1::DefaultLabeledStatement
          return item, idx
        end
      end
      return nil, nil
    end

    def final_clause?(idx, compound_stmt)
      idx += 1
      while item = compound_stmt.block_items[idx]
        case item
        when Cc1::GenericLabeledStatement
          item = item.statement
          redo
        when Cc1::CaseLabeledStatement
          return false
        else
          idx += 1
        end
      end
      true
    end
  end

  class W0540 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_ansi_function_definition += T(:check)
    end

    private
    def check(node)
      if node.declarator.kind_of?(Cc1::AbbreviatedFunctionDeclarator)
        W(node.declarator.location)
      end
    end
  end

  class W0542 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_function_declaration += T(:check)
    end

    private
    def check(node)
      node.init_declarator.accept(Visitor.new(@phase_ctxt, node))
    end

    class Visitor < Cc1::SyntaxTreeVisitor
      include Cc1::SyntaxNodeCollector
      include ReportUtil

      def initialize(phase_ctxt, fun_dcl)
        @phase_ctxt   = phase_ctxt
        @function_dcl = fun_dcl
      end

      def visit_parameter_type_list(node)
        return unless node.parameters

        param_has_name = node.parameters.map { |param_dcl|
          if param_dcl.declarator
            collect_identifier_declarators(param_dcl.declarator).count > 0
          else
            false
          end
        }

        unless param_has_name.all? || param_has_name.none?
          W(@function_dcl.location)
        end
      end

      private
      extend Forwardable

      def_delegator :@phase_ctxt, :report
      private :report

      def_delegator :@phase_ctxt, :message_catalog
      private :message_catalog

      def suppressors
        @phase_ctxt[:suppressors]
      end
    end
    private_constant :Visitor
  end

  class W0543 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    include Cc1::SyntaxNodeCollector

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_ansi_function_definition += T(:check)
      @interp = phase_ctxt[:cc1_interpreter]
    end

    private
    def check(node)
      fun = @interp.function_named(node.identifier.value)
      return unless fun

      params = fun.declarations_and_definitions.map { |dcl_or_def|
        case dcl_or_def
        when Cc1::FunctionDeclaration
          extract_param_names(dcl_or_def.init_declarator)
        when Cc1::FunctionDefinition
          extract_param_names(dcl_or_def.declarator)
        end
      }

      if params.size > 1
        params.first.zip(*params[1..-1]) do |names|
          unless names.tap { |ary| ary.delete("") }.uniq.size == 1
            W(node.location)
            break
          end
        end
      end
    end

    def extract_param_names(node)
      collect_identifier_declarators(node).map { |decl| decl.identifier.value }
    end
  end

  class W0544 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_variable_initialized   += T(:check_initialization)
      @interp.on_assignment_expr_evaled += T(:check_assignment)
    end

    private
    def check_initialization(var_def, var, init_var)
      lhs_type = var.type.unqualify
      rhs_type = init_var.type.unqualify

      if lhs_type.pointer? && lhs_type.base_type.function? &&
          rhs_type.pointer? && rhs_type.base_type.function?
        check(var_def, lhs_type.base_type, rhs_type.base_type)
      end
    end

    def check_assignment(expr, lhs_var, rhs_var)
      lhs_type = lhs_var.type.unqualify
      rhs_type = rhs_var.type.unqualify

      if lhs_type.pointer? && lhs_type.base_type.function? &&
          rhs_type.pointer? && rhs_type.base_type.function?
        check(expr, lhs_type.base_type, rhs_type.base_type)
      end
    end

    def check(node, lhs_fun_type, rhs_fun_type)
      param_types =
        lhs_fun_type.parameter_types.zip(rhs_fun_type.parameter_types)
      if param_types.any? { |l, r| l && r && l.param_name != r.param_name }
        W(node.location)
      end
    end
  end

  class W0546 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_switch_statement += T(:check)
    end

    private
    def check(node)
      if node.statement.kind_of?(Cc1::CompoundStatement)
        body = node.statement
      else
        return
      end
      body.block_items.each { |item| item.accept(Visitor.new(@phase_ctxt)) }
    end

    class Visitor < Cc1::SyntaxTreeVisitor
      include ReportUtil

      def initialize(phase_ctxt)
        @phase_ctxt = phase_ctxt
        @block_level = 0
      end

      def visit_case_labeled_statement(node)
        super
        W(node.location) if @block_level > 0
      end

      def visit_default_labeled_statement(node)
        super
        W(node.location) if @block_level > 0
      end

      def visit_compound_statement(node)
        @block_level += 1
        super
        @block_level -= 1
      end

      def visit_if_statement(node)
        @block_level += 1
        node.statement.accept(self)
        @block_level -= 1
      end

      def visit_if_else_statement(node)
        @block_level += 1
        node.then_statement.accept(self)
        node.else_statement.accept(self)
        @block_level -= 1
      end

      def visit_switch_statement(node)
      end

      def visit_while_statement(node)
        @block_level += 1
        node.statement.accept(self)
        @block_level -= 1
      end

      def visit_do_statement(node)
        @block_level += 1
        node.statement.accept(self)
        @block_level -= 1
      end

      def visit_for_statement(node)
        @block_level += 1
        node.body_statement.accept(self)
        @block_level -= 1
      end

      def visit_c99_for_statement(node)
        @block_level += 1
        node.body_statement.accept(self)
        @block_level -= 1
      end

      private
      extend Forwardable

      def_delegator :@phase_ctxt, :report
      private :report

      def_delegator :@phase_ctxt, :message_catalog
      private :message_catalog

      def suppressors
        @phase_ctxt[:suppressors]
      end
    end
    private_constant :Visitor
  end

  class W0551 < PassiveCodeCheck
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
      W(node.location)
    end
  end

  class W0552 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_variable_defined += T(:check)
    end

    private
    def check(var_def, var)
      W(var_def.location) if var.type.union?
    end
  end

  class W0553 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_explicit_conv_performed += T(:check)
    end

    private
    def check(expr, org_var, res_var)
      lhs_type = org_var.type.unqualify
      rhs_type = res_var.type.unqualify

      return unless lhs_type.pointer? && lhs_type.base_type.function?
      return unless rhs_type.pointer? && rhs_type.base_type.function?

      unless lhs_type.base_type.same_as?(rhs_type.base_type)
        W(expr.location)
      end
    end
  end

  class W0556 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_function_started          += T(:enter_function)
      @interp.on_function_ended            += T(:leave_function)
      @interp.on_function_call_expr_evaled += T(:check)
      @functions = []
    end

    private
    def enter_function(*, fun)
      @functions.push(fun)
    end

    def leave_function(*)
      @functions.pop
    end

    def check(funcall_expr, fun, *)
      if cur_fun = @functions.last and fun == cur_fun
        W(funcall_expr.location)
      end
    end
  end

  class W0559 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_unary_arithmetic_expression += T(:check)
    end

    private
    def check(node)
      if node.operator.type == "!"
        if Visitor.new.tap { |v| node.operand.accept(v) }.bitwise_expr_num > 0
          W(node.location)
        end
      end
    end

    class Visitor < Cc1::SyntaxTreeVisitor
      def initialize
        @bitwise_expr_num = 0
      end

      attr_reader :bitwise_expr_num

      def visit_unary_arithmetic_expression(node)
        super unless node.operator.type == "!"
      end

      def visit_and_expression(node)
        super
        @bitwise_expr_num += 1
      end

      def visit_inclusive_or_expression(node)
        super
        @bitwise_expr_num += 1
      end
    end
    private_constant :Visitor
  end

  class W0560 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_unary_arithmetic_expression += T(:check)
    end

    private
    def check(node)
      if node.operator.type == "~"
        if Visitor.new.tap { |v| node.operand.accept(v) }.logical_expr_num > 0
          W(node.location)
        end
      end
    end

    class Visitor < Cc1::SyntaxTreeVisitor
      def initialize
        @logical_expr_num = 0
      end

      attr_reader :logical_expr_num

      def visit_unary_arithmetic_expression(node)
        super unless node.operator.type == "~"
      end

      def visit_relational_expression(node)
        super
        @logical_expr_num += 1
      end

      def visit_equality_expression(node)
        super
        @logical_expr_num += 1
      end

      def visit_logical_and_expression(node)
        super
        @logical_expr_num += 1
      end

      def visit_logical_or_expression(node)
        super
        @logical_expr_num += 1
      end
    end
    private_constant :Visitor
  end

  class W0561 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_expression_statement += T(:check)
    end

    private
    def check(node)
      case expr = node.expression
      when Cc1::IndirectionExpression
        case expr.operand
        when Cc1::PostfixIncrementExpression
          W(node.location)
        end
      end
    end
  end

  class W0562 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_variable_definition += T(:check)
    end

    private
    def check(node)
      if init = node.initializer
        if initializer_depth(init) > type_depth(node.type)
          W(init.location)
        end
      end
    end

    def initializer_depth(init)
      if inits = init.initializers
        1 + inits.map { |i| initializer_depth(i) }.max
      else
        0
      end
    end

    def type_depth(type)
      case
      when type.array?
        1 + type_depth(type.base_type)
      when type.composite?
        type.members.empty? ?
          1 : 1 + type.members.map { |memb| type_depth(memb.type) }.max
      else
        0
      end
    end
  end

  class W0563 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_compound_statement        += T(:enter_block)
      visitor.leave_compound_statement        += T(:leave_block)
      visitor.enter_generic_labeled_statement += T(:check)
      @blocks = []
    end

    private
    def check(node)
      return if node.referrers.empty?

      if @blocks.size > 1
        cur_block = @blocks.last
        anterior_goto = node.referrers.find { |goto|
          goto.location.line_no < cur_block.head_location.line_no
        }
        return unless anterior_goto

        # FIXME: Must consider that the declaration may appear at anywhere in
        #        ISO C99.
        cur_block_items = cur_block.block_items
        if cur_block_items.any? { |item| item.kind_of?(Cc1::Declaration) }
          W(node.location, node.label.value)
        end
      end
    end

    def enter_block(node)
      @blocks.push(node)
    end

    def leave_block(node)
      @blocks.pop
    end
  end

  class W0564 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_compound_statement        += T(:enter_block)
      visitor.leave_compound_statement        += T(:leave_block)
      visitor.enter_generic_labeled_statement += T(:check)
      @blocks = []
    end

    private
    def check(node)
      return if node.referrers.empty?

      if @blocks.size > 1
        cur_block = @blocks.last
        posterior_goto = node.referrers.find { |goto|
          goto.location.line_no > cur_block.tail_location.line_no
        }
        return unless posterior_goto

        # FIXME: Must consider that the declaration may appear at anywhere in
        #        ISO C99.
        cur_block_items = cur_block.block_items
        if cur_block_items.any? { |item| item.kind_of?(Cc1::Declaration) }
          W(posterior_goto.location, node.label.value)
        end
      end
    end

    def enter_block(node)
      @blocks.push(node)
    end

    def leave_block(node)
      @blocks.pop
    end
  end

  class W0565 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_explicit_conv_performed += T(:check)
    end

    private
    def check(expr, org_var, res_var)
      lhs_type = org_var.type.unqualify
      rhs_type = res_var.type.unqualify

      if lhs_type.integer? && !lhs_type.pointer? &&
          rhs_type.pointer? && rhs_type.base_type.volatile?
        W(expr.location)
        return
      end

      if rhs_type.integer? && !rhs_type.pointer? &&
          lhs_type.pointer? && lhs_type.base_type.volatile?
        W(expr.location)
        return
      end
    end
  end

  class W0566 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_explicit_conv_performed += T(:check)
    end

    private
    def check(expr, org_var, res_var)
      lhs_type = org_var.type.unqualify
      rhs_type = res_var.type.unqualify

      case
      when lhs_type.integer? && !lhs_type.pointer? &&
           rhs_type.pointer? && rhs_type.base_type.function?
        W(expr.location)
      when rhs_type.integer? && !rhs_type.pointer? &&
           lhs_type.pointer? && lhs_type.base_type.function?
        W(expr.location)
      end
    end
  end

  class W0567 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_explicit_conv_performed += T(:check)
    end

    private
    def check(expr, org_var, res_var)
      lhs_type = org_var.type.unqualify
      rhs_type = res_var.type.unqualify

      if lhs_type.integer? && !lhs_type.pointer? &&
          rhs_type.pointer? && !rhs_type.base_type.volatile?
        W(expr.location)
        return
      end

      if rhs_type.integer? && !rhs_type.pointer? &&
          lhs_type.pointer? && !lhs_type.base_type.volatile?
        W(expr.location)
        return
      end
    end
  end

  class W0568 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_shift_expr_evaled += T(:check)
    end

    private
    def check(expr, lhs_var, rhs_var, *)
      op = expr.operator.type
      return unless op == "<<" || op == "<<="

      return unless @interp.constant_expression?(expr.lhs_operand)
      return unless lhs_var.type.signed?

      if lhs_var.value.must_be_less_than?(@interp.scalar_value_of(0)) or
          lhs_var.value.must_be_greater_than?(@interp.scalar_value_of(0)) &&
          must_overflow?(lhs_var, rhs_var)
        W(expr.location)
      end
    end

    def must_overflow?(lhs_var, rhs_var)
      comp_val = lhs_var.value << rhs_var.value
      lhs_max_val = @interp.scalar_value_of(lhs_var.type.max)
      comp_val.must_be_greater_than?(lhs_max_val)
    end
  end

  class W0569 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_shift_expr_evaled += T(:check)
    end

    private
    def check(expr, lhs_var, rhs_var, *)
      op = expr.operator.type
      return unless op == "<<" || op == "<<="

      return if @interp.constant_expression?(expr.lhs_operand)
      return unless lhs_var.type.signed?

      if lhs_var.value.must_be_less_than?(@interp.scalar_value_of(0)) or
          lhs_var.value.must_be_greater_than?(@interp.scalar_value_of(0)) &&
          must_overflow?(lhs_var, rhs_var)
        W(expr.location)
      end
    end

    def must_overflow?(lhs_var, rhs_var)
      comp_val = lhs_var.value << rhs_var.value
      lhs_max_val = @interp.scalar_value_of(lhs_var.type.max)
      comp_val.must_be_greater_than?(lhs_max_val)
    end
  end

  class W0570 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_shift_expr_evaled += T(:check)
    end

    private
    def check(expr, lhs_var, rhs_var, *)
      op = expr.operator.type
      return unless op == "<<" || op == "<<="

      return if @interp.constant_expression?(expr.lhs_operand)
      return unless lhs_var.type.signed?

      if !lhs_var.value.must_be_less_than?(@interp.scalar_value_of(0)) &&
          lhs_var.value.may_be_less_than?(@interp.scalar_value_of(0)) or
         !must_overflow?(lhs_var, rhs_var) && may_overflow?(lhs_var, rhs_var)
        W(expr.location)
      end
    end

    def must_overflow?(lhs_var, rhs_var)
      comp_val = lhs_var.value << rhs_var.value
      lhs_max_val = @interp.scalar_value_of(lhs_var.type.max)
      comp_val.must_be_greater_than?(lhs_max_val)
    end

    def may_overflow?(lhs_var, rhs_var)
      comp_val = lhs_var.value << rhs_var.value
      lhs_max_val = @interp.scalar_value_of(lhs_var.type.max)
      comp_val.may_be_greater_than?(lhs_max_val)
    end
  end

  class W0571 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_shift_expr_evaled += T(:check)
    end

    private
    def check(expr, lhs_var, *)
      op = expr.operator.type
      if op == ">>" || op == ">>="
        W(expr.location) if lhs_var.type.signed?
      end
    end
  end

  class W0572 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_shift_expr_evaled            += T(:check_shift)
      interp.on_and_expr_evaled              += T(:check_binary)
      interp.on_inclusive_or_expr_evaled     += T(:check_binary)
      interp.on_exclusive_or_expr_evaled     += T(:check_binary)
      interp.on_unary_arithmetic_expr_evaled += T(:check_unary)
    end

    private
    def check_shift(expr, lhs_var, *)
      if lhs_var.type.scalar? && lhs_var.type.signed?
        W(expr.location)
      end
    end

    def check_binary(expr, lhs_var, rhs_var, *)
      if lhs_var.type.scalar? && lhs_var.type.signed?
        W(expr.location)
        return
      end

      if rhs_var.type.scalar? && rhs_var.type.signed?
        W(expr.location)
        return
      end
    end

    def check_unary(expr, var, *)
      return unless expr.operator.type == "~"
      if var.type.scalar? && var.type.signed?
        W(expr.location)
      end
    end
  end

  class W0578  < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_implicit_conv_performed      += T(:check)
      interp.on_function_started             += T(:clear_rvalues)
      interp.on_unary_arithmetic_expr_evaled += T(:handle_unary)
      interp.on_shift_expr_evaled            += T(:handle_shift)
      interp.on_additive_expr_evaled         += T(:handle_additive)
      interp.on_multiplicative_expr_evaled   += T(:handle_multiplicative)
      @rvalues = nil
    end

    private
    def check(init_or_expr, src_var, dst_var)
      return unless @rvalues

      src_type = src_var.type
      dst_type = dst_var.type
      return unless src_type.integer?

      if src_type.integer_conversion_rank < dst_type.integer_conversion_rank
        case @rvalues[src_var]
        when Cc1::UnaryArithmeticExpression, Cc1::ShiftExpression,
             Cc1::AdditiveExpression, Cc1::MultiplicativeExpression
          W(init_or_expr.location, src_type.brief_image, dst_type.brief_image)
        end
      end
    end

    def clear_rvalues(*)
      @rvalues = {}
    end

    def handle_unary(expr, *, res_var)
      if expr.operator == "~"
        memorize_rvalue_derivation(res_var, expr)
      end
    end

    def handle_shift(expr, *, res_var)
      if expr.operator.type == "<<"
        memorize_rvalue_derivation(res_var, expr)
      end
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
  end

  class W0579 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_explicit_conv_performed      += T(:check)
      interp.on_function_started             += T(:clear_rvalues)
      interp.on_unary_arithmetic_expr_evaled += T(:handle_unary)
      interp.on_shift_expr_evaled            += T(:handle_shift)
      interp.on_additive_expr_evaled         += T(:handle_additive)
      interp.on_multiplicative_expr_evaled   += T(:handle_multiplicative)
      @rvalues = nil
    end

    private
    def check(cast_expr, src_var, dst_var)
      return unless @rvalues

      src_type = src_var.type
      dst_type = dst_var.type
      return unless src_type.integer?

      if src_type.integer_conversion_rank < dst_type.integer_conversion_rank
        case @rvalues[src_var]
        when Cc1::UnaryArithmeticExpression, Cc1::ShiftExpression,
             Cc1::AdditiveExpression, Cc1::MultiplicativeExpression
          W(cast_expr.location, src_type.brief_image, dst_type.brief_image)
        end
      end
    end

    def clear_rvalues(*)
      @rvalues = {}
    end

    def handle_unary(expr, *, res_var)
      if expr.operator == "~"
        memorize_rvalue_derivation(res_var, expr)
      end
    end

    def handle_shift(expr, *, res_var)
      if expr.operator.type == "<<"
        memorize_rvalue_derivation(res_var, expr)
      end
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
  end

  class W0580 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_function_started        += T(:start_function)
      @interp.on_function_ended          += T(:end_function)
      @interp.on_parameter_defined       += T(:add_parameter)
      @interp.on_indirection_expr_evaled += T(:relate_pointer)
      @interp.on_assignment_expr_evaled  += T(:check)
      @params    = nil
      @ptr_relat = nil
    end

    private
    def start_function(*)
      @params = Set.new
      @ptr_relat = {}
    end

    def end_function(*)
      @params = nil
      @ptr_relat = nil
    end

    def add_parameter(*, var)
      if @params && var.named?
        @params.add(var.name)
      end
    end

    def relate_pointer(*, var, derefed_var)
      if @ptr_relat
        @ptr_relat[derefed_var] = var
      end
    end

    def check(assign_expr, lhs_var, rhs_var)
      return unless @params && @ptr_relat
      return unless lhs_var.type.pointer? && rhs_var.type.pointer?

      if rhs_pointee = @interp.pointee_of(rhs_var) and
          rhs_pointee.variable? && rhs_pointee.named? &&
          rhs_pointee.scope.local? && rhs_pointee.binding.memory.static?
        if lhs_var.scope.global?
          W(assign_expr.location)
        else
          if ptr = @ptr_relat[lhs_var]
            if ptr.named? && @params.include?(ptr.name)
              W(assign_expr.location)
            end
          end
        end
      end
    end
  end

  class W0581 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_function_call_expr_evaled += T(:check)
      @funcalls = Hash.new { |hash, key| hash[key] = [] }
    end

    private
    def check(funcall_expr, fun, arg_vars, *)
      return unless fun.named?
      return if prototype_declaration_of(fun)

      arg_types = arg_vars.map { |var| var.type.unqualify }

      @funcalls[fun.name].each do |prv_arg_types|
        if prv_arg_types.size == arg_types.size
          conformed = prv_arg_types.zip(arg_types).all? { |prv, lst|
            case
            when prv.array?   && lst.array?,
                 prv.array?   && lst.pointer?,
                 prv.pointer? && lst.array?
              prv.base_type == lst.base_type
            else
              prv == lst
            end
          }
        else
          conformed = false
        end

        unless conformed
          W(funcall_expr.location)
          break
        end
      end

      @funcalls[fun.name].push(arg_types)
    end

    def prototype_declaration_of(fun)
      fun.declarations_and_definitions.find do |dcl_or_def|
        dcl_or_def.kind_of?(Cc1::FunctionDeclaration)
      end
    end
  end

  class W0582 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    include Cc1::InterpreterMediator
    include Cc1::Conversion

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_function_call_expr_evaled  += T(:call_function)
      @interp.on_explicit_function_declared += T(:check)
      @funcalls = Hash.new { |hash, key| hash[key] = [] }
    end

    private
    def check(*, fun)
      return unless fun.named?
      return if fun.type.have_va_list?

      param_types = fun.type.parameter_types.reject { |type| type.void? }

      @funcalls[fun.name].each do |funcall_expr, args|
        if args.size == param_types.size
          types = args.map { |ary| ary.first }.zip(param_types)
          conformed = types.each_with_index.all? { |(atype, ptype), idx|
            arg_expr = funcall_expr.argument_expressions[idx]
            @interp.constant_expression?(arg_expr) &&
              untyped_pointer_conversion?(atype, ptype, args[idx].last) or
            atype.convertible?(ptype)
          }
        else
          conformed = false
        end

        W(funcall_expr.location) unless conformed
      end
    end

    def call_function(funcall_expr, fun, arg_vars, *)
      if fun.named?
        args = arg_vars.map { |var| [var.type, var.value.to_single_value] }
        @funcalls[fun.name].push([funcall_expr, args])
      end
    end

    def interpreter
      @interp
    end
  end

  class W0583 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    include Cc1::InterpreterMediator
    include Cc1::Conversion

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_function_call_expr_evaled += T(:call_function)
      @interp.on_explicit_function_defined += T(:check)
      @funcalls = Hash.new { |hash, key| hash[key] = [] }
    end

    private
    def check(*, fun)
      return unless fun.named?
      return if fun.type.have_va_list?

      param_types = fun.type.parameter_types.reject { |type| type.void? }

      @funcalls[fun.name].each do |funcall_expr, args|
        if args.size == param_types.size
          types = args.map { |ary| ary.first }.zip(param_types)
          conformed = types.each_with_index.all? { |(atype, ptype), idx|
            arg_expr = funcall_expr.argument_expressions[idx]
            @interp.constant_expression?(arg_expr) &&
              untyped_pointer_conversion?(atype, ptype, args[idx].last) or
            atype.convertible?(ptype)
          }
        else
          conformed = false
        end

        W(funcall_expr.location) unless conformed
      end
    end

    def call_function(funcall_expr, fun, arg_vars, *)
      if fun.named?
        args = arg_vars.map { |var| [var.type, var.value.to_single_value] }
        @funcalls[fun.name].push([funcall_expr, args])
      end
    end

    def interpreter
      @interp
    end
  end

  class W0584 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    include Cc1::InterpreterMediator
    include Cc1::Conversion

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_function_call_expr_evaled += T(:check)
    end

    private
    def check(funcall_expr, fun, arg_vars, *)
      return unless fun.named?
      return unless kandr_style_definition_of(fun)
      return if fun.type.have_va_list?

      args = arg_vars.map { |var| [var.type, var.value.to_single_value] }
      param_types = fun.type.parameter_types.reject { |type| type.void? }

      return unless args.size == param_types.size

      args.zip(param_types).each_with_index do |(arg, ptype), idx|
        arg_expr = funcall_expr.argument_expressions[idx]
        if @interp.constant_expression?(arg_expr)
          next if untyped_pointer_conversion?(arg.first, ptype, arg.last)
        end

        unless arg.first.convertible?(ptype)
          W(arg_expr.location, idx + 1)
        end
      end
    end

    def kandr_style_definition_of(fun)
      fun.declarations_and_definitions.find do |dcl_or_def|
        dcl_or_def.kind_of?(Cc1::KandRFunctionDefinition)
      end
    end

    def interpreter
      @interp
    end
  end

  class W0585 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    include Cc1::SyntaxNodeCollector

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_for_stmt_started     += T(:check_for_stmt)
      @interp.on_c99_for_stmt_started += T(:check_c99_for_stmt)
    end

    private
    def check_for_stmt(node)
      inited_var_names =
        collect_object_specifiers(node.initial_statement).map { |os|
          os.identifier.value
        }
      if ctrl_var_name = deduct_ctrl_variable_name(node, inited_var_names)
        if node.expression
          varying_var_names = collect_varying_variable_names(node.expression)
          unless varying_var_names.include?(ctrl_var_name)
            W(node.expression.location, ctrl_var_name)
          end
        end
      end
    end

    def check_c99_for_stmt(node)
      inited_var_names =
        collect_identifier_declarators(node.declaration).map { |id|
          id.identifier.value
        }
      if ctrl_var_name = deduct_ctrl_variable_name(node, inited_var_names)
        if node.expression
          varying_var_names = collect_varying_variable_names(node.expression)
          unless varying_var_names.include?(ctrl_var_name)
            W(node.expression.location, ctrl_var_name)
          end
        end
      end
    end

    def deduct_ctrl_variable_name(node, inited_var_names)
      var_names = inited_var_names + node.varying_variable_names
      histo = var_names.each_with_object({}) { |name, hash| hash[name] = 0 }

      ctrl_expr, * = node.deduct_controlling_expression
      collect_object_specifiers(ctrl_expr).map { |obj_spec|
        obj_spec.identifier.value
      }.each { |obj_name| histo.include?(obj_name) and histo[obj_name] += 1 }

      histo.to_a.sort { |a, b| b.last <=> a.last }.map(&:first).find do |name|
        var = @interp.variable_named(name) and !var.type.const?
      end
    end

    def collect_varying_variable_names(node)
      varying_var_names = []

      collect_simple_assignment_expressions(node).each do |expr|
        if expr.lhs_operand.kind_of?(Cc1::ObjectSpecifier)
          varying_var_names.push(expr.lhs_operand.identifier.value)
        end
      end

      collect_compound_assignment_expressions(node).each do |expr|
        if expr.lhs_operand.kind_of?(Cc1::ObjectSpecifier)
          varying_var_names.push(expr.lhs_operand.identifier.value)
        end
      end

      collect_prefix_increment_expressions(node).each do |expr|
        if expr.operand.kind_of?(Cc1::ObjectSpecifier)
          varying_var_names.push(expr.operand.identifier.value)
        end
      end

      collect_prefix_decrement_expressions(node).each do |expr|
        if expr.operand.kind_of?(Cc1::ObjectSpecifier)
          varying_var_names.push(expr.operand.identifier.value)
        end
      end

      collect_postfix_increment_expressions(node).each do |expr|
        if expr.operand.kind_of?(Cc1::ObjectSpecifier)
          varying_var_names.push(expr.operand.identifier.value)
        end
      end

      collect_postfix_decrement_expressions(node).each do |expr|
        if expr.operand.kind_of?(Cc1::ObjectSpecifier)
          varying_var_names.push(expr.operand.identifier.value)
        end
      end

      varying_var_names.uniq
    end
  end

  class W0597 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_sequence_point_reached += T(:commit_changes)
      interp.on_variable_value_updated += T(:update_variable)
      @update_cnt = Hash.new(0)
    end

    private
    def commit_changes(seqp)
      @update_cnt.each { |var, cnt| W(seqp.location, var.name) if cnt > 1 }
      @update_cnt = Hash.new(0)
    end

    def update_variable(*, var)
      @update_cnt[var] += 1 if var.named?
    end
  end

  class W0598 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_sequence_point_reached += T(:commit_changes)
      interp.on_variable_value_updated += T(:update_variable)
      @update_cnt = [Hash.new(0)]
    end

    private
    def commit_changes(seqp)
      if seqp.obvious?
        updated_vars = @update_cnt.map { |hash| hash.keys }.flatten.uniq
        updated_vars.each do |var|
          if @update_cnt.count { |hash| hash.include?(var) } > 1
            if @update_cnt.map { |hash| hash[var] }.max == 1
              W(seqp.location, var.name)
            end
          end
        end
        @update_cnt = [Hash.new(0)]
      else
        @update_cnt.push(Hash.new(0))
      end
    end

    def update_variable(*, var)
      @update_cnt.last[var] += 1 if var.named?
    end
  end

  class W0599 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_sequence_point_reached  += T(:commit_changes)
      interp.on_variable_value_referred += T(:refer_variable)
      interp.on_variable_value_updated  += T(:update_variable)
      @refer_cnt  = Hash.new(0)
      @update_cnt = Hash.new(0)
    end

    private
    def commit_changes(seqp)
      (@refer_cnt.keys & @update_cnt.keys).each do |var|
        if @refer_cnt[var] > 0 && @update_cnt[var] > 0
          W(seqp.location, var.name)
        end
      end
      @refer_cnt  = Hash.new(0)
      @update_cnt = Hash.new(0)
    end

    def refer_variable(*, var)
      @refer_cnt[var] += 1 if var.named?
    end

    def update_variable(expr, var)
      if var.named?
        case expr
        when Cc1::SimpleAssignmentExpression, Cc1::CompoundAssignmentExpression
          # NOTE: The expression-statement `i = i + j;' should not be warned.
          #       But the expression-statement `i = i++ + j;' should be warned.
          #       So, side-effects of the assignment-expression are given
          #       special treatment.
        else
          @update_cnt[var] += 1
        end
      end
    end
  end

  class W0600 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_sequence_point_reached  += T(:commit_changes)
      interp.on_variable_value_referred += T(:refer_variable)
      interp.on_variable_value_updated  += T(:update_variable)
      @refer_cnt  = [Hash.new(0)]
      @update_cnt = [Hash.new(0)]
    end

    private
    def commit_changes(seqp)
      if seqp.obvious?
        updated_vars = @update_cnt.map { |hash| hash.keys }.flatten.uniq
        access_count = @refer_cnt.zip(@update_cnt)

        updated_vars.each do |var|
          count = access_count.count { |rhash, uhash|
            rhash.include?(var) && !uhash.include?(var)
          }
          W(seqp.location, var.name) if count > 0
        end
        @refer_cnt  = [Hash.new(0)]
        @update_cnt = [Hash.new(0)]
      else
        @refer_cnt.push(Hash.new(0))
        @update_cnt.push(Hash.new(0))
      end
    end

    def refer_variable(*, var)
      @refer_cnt.last[var] += 1 if var.named?
    end

    def update_variable(expr, var)
      if var.named?
        case expr
        when Cc1::SimpleAssignmentExpression, Cc1::CompoundAssignmentExpression
          # NOTE: The expression-statement `i = i + j;' should not be warned.
          #       But the expression-statement `i = i++ + j;' should be warned.
          #       So, side-effects of the assignment-expression are given
          #       special treatment.
        else
          @update_cnt.last[var] += 1
        end
      end
    end
  end

  class W0605 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_break_statement   += T(:check)
      visitor.enter_switch_statement  += T(:enter_breakable_statement)
      visitor.leave_switch_statement  += T(:leave_breakable_statement)
      visitor.enter_while_statement   += T(:enter_breakable_statement)
      visitor.leave_while_statement   += T(:leave_breakable_statement)
      visitor.enter_do_statement      += T(:enter_breakable_statement)
      visitor.leave_do_statement      += T(:leave_breakable_statement)
      visitor.enter_for_statement     += T(:enter_breakable_statement)
      visitor.leave_for_statement     += T(:leave_breakable_statement)
      visitor.enter_c99_for_statement += T(:enter_breakable_statement)
      visitor.leave_c99_for_statement += T(:leave_breakable_statement)
      @breakable_stmts = []
    end

    private
    def check(break_stmt)
      @breakable_stmts.last[1] += 1

      if @breakable_stmts.last[1] > 1 &&
          @breakable_stmts.last[0].kind_of?(Cc1::IterationStatement)
        W(break_stmt.location)
      end
    end

    def enter_breakable_statement(stmt)
      @breakable_stmts.push([stmt, 0])
    end

    def leave_breakable_statement(*)
      @breakable_stmts.pop
    end
  end

  class W0607 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_explicit_conv_performed += T(:check)
    end

    private
    def check(expr, org_var, res_var)
      org_type = org_var.type
      res_type = res_var.type

      unless org_type.scalar? && org_type.integer? &&
          res_type.scalar? && res_type.integer? && res_type.unsigned?
        return
      end

      org_val = org_var.value
      return unless org_val.scalar?

      lower_test = org_val < @interp.scalar_value_of(0)

      if lower_test.must_be_true?
        W(expr.location)
      end
    end
  end

  class W0608 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_explicit_conv_performed += T(:check)
    end

    private
    def check(expr, org_var, res_var)
      org_type = org_var.type
      res_type = res_var.type

      unless org_type.scalar? && org_type.integer? &&
          res_type.scalar? && res_type.integer? && res_type.unsigned?
        return
      end

      org_val = org_var.value
      return unless org_val.scalar?

      lower_test = org_val < @interp.scalar_value_of(0)

      if !lower_test.must_be_true? && lower_test.may_be_true?
        W(expr.location)
      end
    end
  end

  class W0609 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    include Cc1::SyntaxNodeCollector

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_relational_expr_evaled  += T(:check)
      interp.on_equality_expr_evaled    += T(:check)
      interp.on_logical_and_expr_evaled += T(:check)
      interp.on_logical_or_expr_evaled  += T(:check)
      interp.on_for_stmt_started        += T(:enter_for_statement)
      interp.on_c99_for_stmt_started    += T(:enter_for_statement)
      interp.on_for_stmt_ended          += T(:leave_for_statement)
      interp.on_c99_for_stmt_ended      += T(:leave_for_statement)
      interp.on_for_ctrlexpr_evaled     += T(:memorize_for_ctrlexpr)
      interp.on_c99_for_ctrlexpr_evaled += T(:memorize_for_ctrlexpr)
      @for_ctrlexpr_stack = []
    end

    private
    def check(expr, *, res_var)
      if res_var.value.must_be_true? && !should_not_check?(expr)
        W(expr.location)
      end
    end

    def enter_for_statement(*)
      @for_ctrlexpr_stack.push(nil)
    end

    def leave_for_statement(*)
      @for_ctrlexpr_stack.pop
    end

    def memorize_for_ctrlexpr(for_stmt, *)
      if explicit_ctrlexpr = for_stmt.condition_statement.expression
        @for_ctrlexpr_stack[-1] = explicit_ctrlexpr
      end
    end

    def should_not_check?(expr)
      if ctrlexpr = @for_ctrlexpr_stack.last
        collect_relational_expressions(ctrlexpr).include?(expr)  ||
        collect_equality_expressions(ctrlexpr).include?(expr)    ||
        collect_logical_and_expressions(ctrlexpr).include?(expr) ||
        collect_logical_or_expressions(ctrlexpr).include?(expr)
      else
        false
      end
    end
  end

  class W0610 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    include Cc1::SyntaxNodeCollector

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_relational_expr_evaled  += T(:check)
      interp.on_equality_expr_evaled    += T(:check)
      interp.on_logical_and_expr_evaled += T(:check)
      interp.on_logical_or_expr_evaled  += T(:check)
      interp.on_for_stmt_started        += T(:enter_for_statement)
      interp.on_c99_for_stmt_started    += T(:enter_for_statement)
      interp.on_for_stmt_ended          += T(:leave_for_statement)
      interp.on_c99_for_stmt_ended      += T(:leave_for_statement)
      interp.on_for_ctrlexpr_evaled     += T(:memorize_for_ctrlexpr)
      interp.on_c99_for_ctrlexpr_evaled += T(:memorize_for_ctrlexpr)
      @for_ctrlexpr_stack = []
    end

    private
    def check(expr, *, res_var)
      if res_var.value.must_be_false? && !should_not_check?(expr)
        W(expr.location)
      end
    end

    def enter_for_statement(*)
      @for_ctrlexpr_stack.push(nil)
    end

    def leave_for_statement(*)
      @for_ctrlexpr_stack.pop
    end

    def memorize_for_ctrlexpr(for_stmt, *)
      if explicit_ctrlexpr = for_stmt.condition_statement.expression
        @for_ctrlexpr_stack[-1] = explicit_ctrlexpr
      end
    end

    def should_not_check?(expr)
      if ctrlexpr = @for_ctrlexpr_stack.last
        collect_relational_expressions(ctrlexpr).include?(expr)  ||
        collect_equality_expressions(ctrlexpr).include?(expr)    ||
        collect_logical_and_expressions(ctrlexpr).include?(expr) ||
        collect_logical_or_expressions(ctrlexpr).include?(expr)
      else
        false
      end
    end
  end

  class W0611 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    include Cc1::SyntaxNodeCollector

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_while_stmt_started      += T(:enter_while_stmt)
      @interp.on_do_stmt_started         += T(:enter_do_stmt)
      @interp.on_for_stmt_started        += T(:enter_for_stmt)
      @interp.on_c99_for_stmt_started    += T(:enter_c99_for_stmt)
      @interp.on_while_ctrlexpr_evaled   += T(:memorize_ctrlexpr_val)
      @interp.on_do_ctrlexpr_evaled      += T(:memorize_ctrlexpr_val)
      @interp.on_for_ctrlexpr_evaled     += T(:memorize_ctrlexpr_val)
      @interp.on_c99_for_ctrlexpr_evaled += T(:memorize_ctrlexpr_val)
      @interp.on_variable_value_updated  += T(:update_ctrl_var)
      @interp.on_while_stmt_ended        += T(:check)
      @interp.on_do_stmt_ended           += T(:check)
      @interp.on_for_stmt_ended          += T(:check)
      @interp.on_c99_for_stmt_ended      += T(:check)
      @iter_stmts = []
    end

    private
    def enter_while_stmt(node)
      enter_iteration_stmt(node.expression)
    end

    def enter_do_stmt(node)
      enter_iteration_stmt(node.expression)
    end

    def enter_for_stmt(node)
      enter_iteration_stmt(node.condition_statement.expression)
    end

    def enter_c99_for_stmt(node)
      enter_iteration_stmt(node.condition_statement.expression)
    end

    IterationStmt = Struct.new(:ctrlexpr, :ctrlexpr_val, :ctrl_vars)
    private_constant :IterationStmt

    def enter_iteration_stmt(ctrlexpr)
      if ctrlexpr
        @iter_stmts.push(IterationStmt.new(ctrlexpr, nil,
                                           deduct_ctrl_vars(ctrlexpr)))
      else
        @iter_stmts.push(IterationStmt.new(nil, nil, nil))
      end
    end

    def deduct_ctrl_vars(ctrlexpr)
      collect_object_specifiers(ctrlexpr).each_with_object({}) do |os, hash|
        if ctrl_var = @interp.variable_named(os.identifier.value)
          hash[os.identifier.value] = false unless ctrl_var.type.const?
        end
      end
    end

    def memorize_ctrlexpr_val(*, ctrlexpr_val)
      @iter_stmts.last.ctrlexpr_val = ctrlexpr_val
    end

    def update_ctrl_var(expr, var)
      if var.named?
        @iter_stmts.reverse_each do |iter_stmt|
          if iter_stmt.ctrlexpr && iter_stmt.ctrl_vars.include?(var.name)
            iter_stmt.ctrl_vars[var.name] = true
          end
        end
      end
    end

    def check(*)
      if ctrlexpr = @iter_stmts.last.ctrlexpr
        unless @interp.constant_expression?(ctrlexpr)
          ctrlexpr_val = @iter_stmts.last.ctrlexpr_val
          ctrl_vars = @iter_stmts.last.ctrl_vars
          if ctrlexpr_val && ctrlexpr_val.must_be_true? and
              ctrl_vars && ctrl_vars.values.none?
            W(ctrlexpr.location)
          end
        end
      end
      @iter_stmts.pop
    end
  end

  class W0612 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_if_ctrlexpr_evaled      += T(:check)
      @interp.on_if_else_ctrlexpr_evaled += T(:check)
    end

    private
    def check(selection_stmt, ctrlexpr_val)
      if ctrlexpr = selection_stmt.expression
        unless @interp.constant_expression?(ctrlexpr)
          W(ctrlexpr.location) if ctrlexpr_val.must_be_true?
        end
      end
    end
  end

  class W0613 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_if_ctrlexpr_evaled      += T(:check_if_stmt)
      interp.on_if_else_ctrlexpr_evaled += T(:check_if_else_stmt)
      interp.on_while_ctrlexpr_evaled   += T(:check_while_stmt)
      interp.on_for_ctrlexpr_evaled     += T(:check_for_stmt)
      interp.on_c99_for_ctrlexpr_evaled += T(:check_c99_for_stmt)
    end

    private
    def check_if_stmt(if_stmt, ctrlexpr_val)
      if ctrlexpr_val.must_be_false?
        W(if_stmt.expression.location)
      end
    end

    def check_if_else_stmt(if_else_stmt, ctrlexpr_val)
      if ctrlexpr_val.must_be_false?
        W(if_else_stmt.expression.location)
      end
    end

    def check_while_stmt(while_stmt, ctrlexpr_val)
      if ctrlexpr_val.must_be_false?
        W(while_stmt.expression.location)
      end
    end

    def check_for_stmt(for_stmt, ctrlexpr_val)
      # NOTE: This method is called only if the for-statement has a controlling
      #       expression.
      if ctrlexpr_val.must_be_false?
        W(for_stmt.condition_statement.expression.location)
      end
    end

    def check_c99_for_stmt(c99_for_stmt, ctrlexpr_val)
      # NOTE: This method is called only if the c99-for-statement has a
      #       controlling expression.
      if ctrlexpr_val.must_be_false?
        W(c99_for_stmt.condition_statement.expression.location)
      end
    end
  end

  class W0614 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_do_ctrlexpr_evaled += T(:check)
    end

    private
    def check(do_stmt, ctrlexpr_val)
      unless @interp.constant_expression?(do_stmt.expression)
        if ctrlexpr_val.must_be_false?
          W(do_stmt.expression.location)
        end
      end
    end
  end

  class W0622 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_explicit_function_declared += T(:check)
      interp.on_block_started              += T(:enter_block)
      interp.on_block_ended                += T(:leave_block)
      @block_level = 0
    end

    private
    def check(fun_dcl, fun)
      if @block_level > 0 && fun.declared_as_extern?
        W(fun_dcl.location)
      end
    end

    def enter_block(*)
      @block_level += 1
    end

    def leave_block(*)
      @block_level -= 1
    end
  end

  class W0623 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_variable_declared += T(:check)
      interp.on_block_started     += T(:enter_block)
      interp.on_block_ended       += T(:leave_block)
      @block_level = 0
    end

    private
    def check(var_dcl, var)
      if @block_level > 0 && var.declared_as_extern?
        W(var_dcl.location)
      end
    end

    def enter_block(*)
      @block_level += 1
    end

    def leave_block(*)
      @block_level -= 1
    end
  end

  class W0624 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    include Cpp::SyntaxNodeCollector

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_ansi_function_definition  += T(:check)
      visitor.enter_kandr_function_definition += T(:check)
      @dires = collect_define_lines(phase_ctxt[:cpp_syntax_tree]) +
               collect_undef_lines(phase_ctxt[:cpp_syntax_tree])
    end

    private
    def check(fun_def)
      @dires.select { |node|
        in_block?(fun_def.function_body, node)
      }.each { |node| W(node.location) }
    end

    def in_block?(outer_node, inner_node)
      outer_node.location.fpath == inner_node.location.fpath &&
        outer_node.head_token.location.line_no < inner_node.location.line_no &&
        outer_node.tail_token.location.line_no > inner_node.location.line_no
    end
  end

  class W0625 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    include Cc1::SyntaxNodeCollector

    # NOTE: W0625 may be duplicative when the same typedef is used twice or
    #       more.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @fpath = phase_ctxt[:sources].first.fpath
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_typedef_declared           += T(:declare_typedef)
      interp.on_variable_defined           += T(:check)
      interp.on_variable_declared          += T(:check)
      interp.on_explicit_function_declared += T(:check)
      interp.on_explicit_function_defined  += T(:check)
      @typedef_types = {}
    end

    private
    def declare_typedef(typedef_dcl)
      typedef_name = typedef_dcl.identifier.value

      if @fpath == typedef_dcl.location.fpath
        @typedef_types[typedef_name] = typedef_dcl
      else
        @typedef_types.delete(typedef_name)
      end
    end

    def check(dcl_or_def, obj, *)
      return unless obj.declared_as_extern?

      if dcl_specs  = dcl_or_def.declaration_specifiers
        find_bad_typedef_decls(dcl_specs).each do |dcl|
          W(dcl.location, dcl.identifier.value)
          break
        end
      end
    end

    def find_bad_typedef_decls(node)
      collect_typedef_type_specifiers(node).map { |type_spec|
        @typedef_types[type_spec.identifier.value]
      }.compact
    end
  end

  class W0626 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_constant_specifier       += T(:check_constant)
      visitor.enter_string_literal_specifier += T(:check_string_literal)
    end

    private
    def check_constant(node)
      W(node.location) if node.prefix =~ /\AL\z/i
    end

    def check_string_literal(node)
      W(node.location) if node.prefix =~ /\AL\z/i
    end
  end

  class W0627 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_compound_statement   += T(:enter_block)
      visitor.leave_compound_statement   += T(:leave_block)
      visitor.enter_expression_statement += T(:enter_expression_statement)
      visitor.enter_if_statement         += T(:update_last_statement)
      visitor.enter_if_else_statement    += T(:update_last_statement)
      visitor.enter_switch_statement     += T(:update_last_statement)
      visitor.enter_while_statement      += T(:update_last_statement)
      visitor.enter_do_statement         += T(:update_last_statement)
      visitor.enter_for_statement        += T(:enter_for_statement)
      visitor.enter_c99_for_statement    += T(:enter_for_statement)
      visitor.enter_goto_statement       += T(:update_last_statement)
      visitor.enter_continue_statement   += T(:update_last_statement)
      visitor.enter_break_statement      += T(:update_last_statement)
      visitor.enter_return_statement     += T(:update_last_statement)
      @last_stmts = []
      @expected_stmts = Set.new
    end

    private
    def enter_block(*)
      @last_stmts.push(nil)
    end

    def leave_block(*)
      @last_stmts.pop
    end

    def enter_expression_statement(node)
      return if @expected_stmts.include?(node)

      unless node.expression
        if lst_stmt = @last_stmts.last
          tail = lst_stmt.tail_location
          head = node.head_location
          if tail.fpath == head.fpath && tail.line_no == head.line_no
            W(node.location)
          end
        end
      end
      update_last_statement(node)
    end

    def enter_for_statement(node)
      @expected_stmts.add(node.condition_statement)
      update_last_statement(node)
    end

    def update_last_statement(node)
      @last_stmts[-1] = node
    end
  end

  class W0629 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_explicit_function_defined += T(:define_function)
      interp.on_function_referred         += T(:refer_function)
      interp.on_translation_unit_ended    += M(:check)
      @static_functions = {}
    end

    private
    def check(*)
      @static_functions.map { |name, (cnt, loc)|
        cnt == 0 ? [name, loc] : nil
      }.compact.each { |name, loc| W(loc, name) }
    end

    def define_function(fun_def, fun)
      if fun.declared_as_static?
        @static_functions[fun.name] ||= [0, fun_def.location]
        @static_functions[fun.name][1] ||= fun_def.location
      end
    end

    def refer_function(*, fun)
      if fun.named?
        if rec = @static_functions[fun.name]
          rec[0] += 1
        else
          @static_functions[fun.name] = [1, nil]
        end
      end
    end
  end

  class W0635 < PassiveCodeCheck
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
      if fun.named? && fun.name =~ /\A.*printf\z/
        fmt = create_format(funcall_expr, format_str_index_of(funcall_expr),
                            arg_vars, @environ)
        return unless fmt

        fmt.conversion_specifiers.each_with_index do |cs, idx|
          if cs.wellformed?
            if cs.consume_arguments? && cs.conversion_argument
              W(fmt.location, idx + 1) unless cs.acceptable?
            end
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
          args = arg_vars[(fmt_str_idx + 1)..-1] || []
          return Cc1::PrintfFormat.new($1, fmt_str.location, args, env)
        end
      end
      nil
    end
  end

  class W0636 < PassiveCodeCheck
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
      if fun.named? && fun.name =~ /\A.*printf\z/
        fmt = create_format(funcall_expr, format_str_index_of(funcall_expr),
                            arg_vars, @environ)
        return unless fmt

        fmt.conversion_specifiers.each_with_index do |cs, idx|
          if cs.wellformed?
            if cs.consume_arguments? && cs.conversion_argument.nil?
              W(fmt.location, idx + 1)
            end
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
          args = arg_vars[(fmt_str_idx + 1)..-1] || []
          return Cc1::PrintfFormat.new($1, fmt_str.location, args, env)
        end
      end
      nil
    end
  end

  class W0637 < PassiveCodeCheck
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
      if fun.named? && fun.name =~ /\A.*printf\z/
        fmt = create_format(funcall_expr, format_str_index_of(funcall_expr),
                            arg_vars, @environ)
        return unless fmt

        unless fmt.extra_arguments.empty?
          if expr = find_extra_argument_expr(funcall_expr, fmt.extra_arguments)
            W(expr.location)
          else
            W(funcall_expr.location)
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
          args = arg_vars[(fmt_str_idx + 1)..-1] || []
          return Cc1::PrintfFormat.new($1, fmt_str.location, args, env)
        end
      end
      nil
    end

    def find_extra_argument_expr(funcall_expr, extra_args)
      funcall_expr.argument_expressions[-extra_args.size]
    end
  end

  class W0638 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_function_call_expr_evaled += T(:check)
    end

    private
    def check(funcall_expr, fun, *)
      if fun.named? && fun.name =~ /\A.*printf\z/
        if funcall_expr.argument_expressions.empty?
          W(funcall_expr.location)
        end
      end
    end
  end

  class W0639 < PassiveCodeCheck
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

        fmt.conversion_specifiers.each_with_index do |cs, idx|
          if cs.wellformed?
            if cs.consume_arguments? && cs.conversion_argument
              W(fmt.location, idx + 1) unless cs.acceptable?
            end
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
          args = arg_vars[(fmt_str_idx + 1)..-1] || []
          return Cc1::ScanfFormat.new($1, fmt_str.location, args, env)
        end
      end
      nil
    end
  end

  class W0640 < PassiveCodeCheck
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

        fmt.conversion_specifiers.each do |cs|
          if arg = cs.conversion_argument and !arg.type.pointer?
            idx = arg_vars.index(arg)
            if idx and arg_expr = funcall_expr.argument_expressions[idx]
              W(arg_expr.location)
            else
              W(funcall_expr.location)
              break
            end
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
          args = arg_vars[(fmt_str_idx + 1)..-1] || []
          return Cc1::ScanfFormat.new($1, fmt_str.location, args, env)
        end
      end
      nil
    end
  end

  class W0641 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_explicit_conv_performed += T(:check)
    end

    private
    def check(expr, org_var, res_var)
      lhs_type = org_var.type.unqualify
      rhs_type = res_var.type.unqualify

      case
      when lhs_type.floating? &&
           rhs_type.pointer? && !rhs_type.base_type.function?
        W(expr.location)
      when rhs_type.floating? &&
           lhs_type.pointer? && !lhs_type.base_type.function?
        W(expr.location)
      end
    end
  end

  class W0642 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_address_derivation_performed += T(:check)
    end

    private
    def check(expr, obj, *)
      W(expr.location) if obj.declared_as_register?
    end
  end

  class W0644 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: W0644 may be duplicative when both hand side of a binary-expression
    #       refer a value of `void' expression.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_variable_value_referred += T(:check)
      interp.on_explicit_conv_performed += lambda { |expr, from, *|
        check(expr, from)
      }
    end

    private
    def check(expr, var)
      W(expr.location) if var.type.void?
    end
  end

  class W0646 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare1Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      parser = phase_ctxt[:cc1_parser]
      parser.on_string_literals_concatenated += T(:check)
    end

    private
    def check(former, latter, *)
      if former.value =~ /\A"/ && latter.value =~ /\AL"/i or
          former.value =~ /\AL"/i && latter.value =~ /\A"/
        W(latter.location)
      end
    end
  end

  class W0649 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_shift_expr_evaled += T(:check)
    end

    private
    def check(expr, lhs_var, rhs_var, *)
      if @interp.constant_expression?(expr.rhs_operand)
        if rhs_var.value.must_be_less_than?(@interp.scalar_value_of(0))
          W(expr.location)
        end
      end
    end
  end

  class W0650 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_shift_expr_evaled += T(:check)
    end

    private
    def check(expr, lhs_var, rhs_var, *)
      if @interp.constant_expression?(expr.rhs_operand)
        promoted_type = lhs_var.type.integer_promoted_type
        promoted_bit_size = @interp.scalar_value_of(promoted_type.bit_size)
        if rhs_var.value.must_be_equal_to?(promoted_bit_size) ||
            rhs_var.value.must_be_greater_than?(promoted_bit_size)
          W(expr.location, promoted_type.brief_image)
        end
      end
    end
  end

  class W0653 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_variable_initialized += T(:check)
    end

    private
    def check(var_def, var, init_var)
      if initializer = var_def.initializer
        init_depth = initializer_depth(initializer)
        case
        when init_depth == 0 && init_var.type.array?,
             init_depth == 0 && init_var.type.composite?
          return
        when init_depth == 0 && type_depth(var.type) > 0
          W(initializer.location)
        end
      end
    end

    def initializer_depth(init)
      if inits = init.initializers
        1 + inits.map { |i| initializer_depth(i) }.max
      else
        0
      end
    end

    def type_depth(type)
      case
      when type.array?
        1 + type_depth(type.base_type)
      when type.composite?
        type.members.empty? ?
          1 : 1 + type.members.map { |memb| type_depth(memb.type) }.max
      else
        0
      end
    end
  end

  class W0654 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_variable_initialized += T(:check)
    end

    private
    def check(var_def, var, init_var)
      type = var.type
      if type.struct? || type.union? and !type.same_as?(init_var.type)
        W(var_def.location)
      end
    end
  end

  class W0655 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_sizeof_expr_evaled += T(:check)
    end

    private
    def check(expr, ope_var, *)
      type = ope_var.type
      if type.scalar? && type.integer? && type.bitfield?
        W(expr.location)
      end
    end
  end

  class W0656 < PassiveCodeCheck
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
      if fun.named? && fun.name =~ /\A.*printf\z/
        fmt = create_format(funcall_expr, format_str_index_of(funcall_expr),
                            arg_vars, @environ)
        return unless fmt

        fmt.conversion_specifiers.each_with_index do |cs, idx|
          if cs.complete?
            if cs.undefined? || cs.illformed?
              W(fmt.location, idx + 1)
            end
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
          args = arg_vars[(fmt_str_idx + 1)..-1] || []
          return Cc1::PrintfFormat.new($1, fmt_str.location, args, env)
        end
      end
      nil
    end
  end

  class W0657 < PassiveCodeCheck
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
      if fun.named? && fun.name =~ /\A.*printf\z/
        fmt = create_format(funcall_expr, format_str_index_of(funcall_expr),
                            arg_vars, @environ)
        return unless fmt

        fmt.conversion_specifiers.each_with_index do |cs, idx|
          unless cs.valid_length_modifier?
            warn(fmt, cs.conversion_specifier_character, idx)
          end
        end
      end
    end

    def warn(fmt, cs_char, idx)
      if target_conversion_specifiers.include?(cs_char)
        W(fmt.location, idx + 1)
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
          args = arg_vars[(fmt_str_idx + 1)..-1] || []
          return Cc1::PrintfFormat.new($1, fmt_str.location, args, env)
        end
      end
      nil
    end

    def target_conversion_specifiers
      ["i", "d"]
    end
  end

  class W0658 < W0657
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def target_conversion_specifiers
      ["o"]
    end
  end

  class W0659 < W0657
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def target_conversion_specifiers
      ["u"]
    end
  end

  class W0660 < W0657
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def target_conversion_specifiers
      ["x"]
    end
  end

  class W0661 < W0657
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def target_conversion_specifiers
      ["X"]
    end
  end

  class W0662 < W0657
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def target_conversion_specifiers
      ["f"]
    end
  end

  class W0663 < W0657
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def target_conversion_specifiers
      ["e"]
    end
  end

  class W0664 < W0657
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def target_conversion_specifiers
      ["E"]
    end
  end

  class W0665 < W0657
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def target_conversion_specifiers
      ["g"]
    end
  end

  class W0666 < W0657
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def target_conversion_specifiers
      ["G"]
    end
  end

  class W0667 < W0657
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def target_conversion_specifiers
      ["c"]
    end
  end

  class W0668 < W0657
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def target_conversion_specifiers
      ["%"]
    end
  end

  class W0669 < W0657
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def target_conversion_specifiers
      ["s"]
    end
  end

  class W0670 < W0657
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def target_conversion_specifiers
      ["n"]
    end
  end

  class W0671 < W0657
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def target_conversion_specifiers
      ["p"]
    end
  end

  class W0672 < PassiveCodeCheck
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
      if fun.named? && fun.name =~ /\A.*printf\z/
        fmt = create_format(funcall_expr, format_str_index_of(funcall_expr),
                            arg_vars, @environ)
        return unless fmt

        fmt.conversion_specifiers.each_with_index do |cs, idx|
          W(fmt.location, idx + 1) if cs.incomplete?
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
          args = arg_vars[(fmt_str_idx + 1)..-1] || []
          return Cc1::PrintfFormat.new($1, fmt_str.location, args, env)
        end
      end
      nil
    end
  end

  class W0673 < PassiveCodeCheck
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

        fmt.conversion_specifiers.each_with_index do |cs, idx|
          if cs.complete?
            W(fmt.location, idx + 1) if cs.undefined? || cs.illformed?
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
          args = arg_vars[(fmt_str_idx + 1)..-1] || []
          return Cc1::ScanfFormat.new($1, fmt_str.location, args, env)
        end
      end
      nil
    end
  end

  class W0674 < PassiveCodeCheck
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

        fmt.conversion_specifiers.each_with_index do |cs, idx|
          unless cs.valid_length_modifier?
            warn(fmt, cs.conversion_specifier_character, idx)
          end
        end
      end
    end

    def warn(fmt, cs_char, idx)
      if target_conversion_specifiers.include?(cs_char)
        W(fmt.location, idx + 1)
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
          args = arg_vars[(fmt_str_idx + 1)..-1] || []
          return Cc1::ScanfFormat.new($1, fmt_str.location, args, env)
        end
      end
      nil
    end

    def target_conversion_specifiers
      ["d", "i", "n"]
    end
  end

  class W0675 < W0674
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def target_conversion_specifiers
      ["o"]
    end
  end

  class W0676 < W0674
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def target_conversion_specifiers
      ["u"]
    end
  end

  class W0677 < W0674
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def target_conversion_specifiers
      ["x", "X"]
    end
  end

  class W0678 < W0674
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def target_conversion_specifiers
      ["e", "E", "f", "g", "G"]
    end
  end

  class W0679 < W0674
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def target_conversion_specifiers
      ["s"]
    end
  end

  class W0680 < W0674
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def target_conversion_specifiers
      ["p"]
    end
  end

  class W0681 < W0674
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def target_conversion_specifiers
      ["%"]
    end
  end

  class W0682 < W0674
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def target_conversion_specifiers
      ["["]
    end
  end

  class W0683 < W0674
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def target_conversion_specifiers
      ["c"]
    end
  end

  class W0684 < PassiveCodeCheck
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

        fmt.conversion_specifiers.each_with_index do |cs, idx|
          W(fmt.location, idx + 1) if cs.incomplete?
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
          args = arg_vars[(fmt_str_idx + 1)..-1] || []
          return Cc1::ScanfFormat.new($1, fmt_str.location, args, env)
        end
      end
      nil
    end
  end

  class W0694 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_function_call_expr_evaled += T(:check)
    end

    private
    def check(funcall_expr, fun, *)
      W(funcall_expr.location) if fun.named? && fun.name == "assert"
    end
  end

  class W0703 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_struct_declared += T(:declare_struct)
      interp.on_union_declared  += T(:declare_union)
      interp.on_enum_declared   += T(:declare_enum)
      interp.on_block_started   += T(:enter_scope)
      interp.on_block_ended     += T(:leave_scope)
      @tag_names = [[]]
    end

    private
    def declare_struct(struct_dcl)
      tag_name = struct_dcl.identifier

      pair_names = @tag_names.flatten.select { |id|
        id.value == tag_name.value
      }

      unless pair_names.empty?
        W(struct_dcl.location, tag_name.value,
          *pair_names.map { |pair| C(:C0001, pair.location, pair.value) })
      end

      @tag_names.last.push(tag_name)
    end

    def declare_union(union_dcl)
      tag_name = union_dcl.identifier

      pair_names = @tag_names.flatten.select { |id|
        id.value == tag_name.value
      }

      unless pair_names.empty?
        W(union_dcl.location, tag_name.value,
          *pair_names.map { |pair| C(:C0001, pair.location, pair.value) })
      end

      @tag_names.last.push(tag_name)
    end

    def declare_enum(enum_dcl)
      tag_name = enum_dcl.identifier

      pair_names = @tag_names.flatten.select { |id|
        id.value == tag_name.value
      }

      unless pair_names.empty?
        W(enum_dcl.location, tag_name.value,
          *pair_names.map { |pair| C(:C0001, pair.location, pair.value) })
      end

      @tag_names.last.push(tag_name)
    end

    def enter_scope(*)
      @tag_names.push([])
    end

    def leave_scope(*)
      @tag_names.pop
    end
  end

  class W0704 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_variable_defined           += T(:define_variable)
      interp.on_explicit_function_declared += T(:declare_function)
      interp.on_variable_declared          += T(:declare_variable)
      interp.on_enum_declared              += T(:declare_enum)
      interp.on_typedef_declared           += T(:declare_typedef)
      interp.on_explicit_function_defined  += T(:define_function)
      interp.on_parameter_defined          += T(:define_parameter)
      interp.on_block_started              += T(:enter_scope)
      interp.on_block_ended                += T(:leave_scope)
      @vdcls = [[]]
      @vdefs = [[]]
      @fdcls = [[]]
      @fdefs = [[]]
      @tdefs = [[]]
      @enums = [[]]
    end

    private
    def define_variable(var_def, *)
      dcl_name = var_def.identifier

      pair_names = wider_identifiers_of_variable_definition.select { |id|
        id.value == dcl_name.value
      }

      unless pair_names.empty?
        W(var_def.location, dcl_name.value,
          *pair_names.map { |pair| C(:C0001, pair.location, pair.value) })
      end

      @vdefs.last.push(dcl_name)
    end

    def wider_identifiers_of_variable_definition
      (@vdcls[0..-2] + @vdefs[0..-2] + @fdcls[0..-2] + @fdefs[0..-2] +
       @tdefs[0..-2] + @enums[0..-2]).flatten
    end

    def declare_function(fun_dcl, *)
      dcl_name = fun_dcl.identifier

      pair_names = wider_identifiers_of_function_declaration.select { |id|
        id.value == dcl_name.value
      }

      unless pair_names.empty?
        W(fun_dcl.location, dcl_name.value,
          *pair_names.map { |pair| C(:C0001, pair.location, pair.value) })
      end

      @fdcls.last.push(dcl_name)
    end

    def wider_identifiers_of_function_declaration
      (@vdcls[0..-2] + @vdefs[0..-2] + @fdcls[0..-2] + @fdefs[0..-2] +
       @tdefs[0..-2] + @enums[0..-2]).flatten
    end

    def declare_variable(var_dcl, *)
      dcl_name = var_dcl.identifier

      pair_names = wider_identifiers_of_variable_declaration.select { |id|
        id.value == dcl_name.value
      }

      unless pair_names.empty?
        W(var_dcl.location, dcl_name.value,
          *pair_names.map { |pair| C(:C0001, pair.location, pair.value) })
      end

      @vdcls.last.push(dcl_name)
    end

    def wider_identifiers_of_variable_declaration
      (@vdefs[0..-2] + @fdcls[0..-2] + @fdefs[0..-2] + @tdefs[0..-2] +
       @enums[0..-2]).flatten
    end

    def declare_enum(enum_dcl)
      enum_dcl.enumerators.each do |enum|
        enum_name = enum.identifier

        pair_names = wider_identifiers_of_enum_declaration.select { |id|
          id.value == enum_name.value
        }

        unless pair_names.empty?
          W(enum.location, enum_name.value,
            *pair_names.map { |pair| C(:C0001, pair.location, pair.value) })
        end

        @enums.last.push(enum_name)
      end
    end

    def wider_identifiers_of_enum_declaration
      (@vdcls[0..-2] + @vdefs[0..-2] + @fdcls[0..-2] + @fdefs[0..-2] +
       @tdefs[0..-2] + @enums[0..-2]).flatten
    end

    def declare_typedef(typedef_dcl)
      dcl_name = typedef_dcl.identifier

      pair_names = wider_identifiers_of_typedef_declaration.select { |id|
        id.value == dcl_name.value
      }

      unless pair_names.empty?
        W(typedef_dcl.location, dcl_name.value,
          *pair_names.map { |pair| C(:C0001, pair.location, pair.value) })
      end

      @enums.last.push(dcl_name)
    end

    def wider_identifiers_of_typedef_declaration
      (@vdcls[0..-2] + @vdefs[0..-2] + @fdcls[0..-2] + @fdefs[0..-2] +
       @tdefs[0..-2] + @enums[0..-2]).flatten
    end

    def define_function(fun_def, *)
      dcl_name = fun_def.identifier

      pair_names = wider_identifiers_of_function_definition.select { |id|
        id.value == dcl_name.value
      }

      unless pair_names.empty?
        W(fun_def.location, dcl_name.value,
          *pair_names.map { |pair| C(:C0001, pair.location, pair.value) })
      end

      @fdefs.last.push(dcl_name)
    end

    def wider_identifiers_of_function_definition
      (@vdcls[0..-2] + @vdefs[0..-2] + @fdefs[0..-2] + @tdefs[0..-2] +
       @enums[0..-2]).flatten
    end

    def define_parameter(param_def, *)
      dcl_name = param_def.identifier

      pair_names = wider_identifiers_of_parameter_definition.select { |id|
        id.value == dcl_name.value
      }

      unless pair_names.empty?
        W(param_def.location, dcl_name.value,
          *pair_names.map { |pair| C(:C0001, pair.location, pair.value) })
      end

      @vdefs.last.push(dcl_name)
    end

    def wider_identifiers_of_parameter_definition
      (@vdcls[0..-2] + @vdefs[0..-2] + @fdcls[0..-2] + @fdefs[0..-2] +
       @tdefs[0..-2] + @enums[0..-2]).flatten
    end

    def enter_scope(*)
      @vdcls.push([])
      @vdefs.push([])
      @fdcls.push([])
      @fdefs.push([])
      @tdefs.push([])
      @enums.push([])
    end

    def leave_scope(*)
      @vdcls.pop
      @vdefs.pop
      @fdcls.pop
      @fdefs.pop
      @tdefs.pop
      @enums.pop
    end
  end

  class W0705 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    include Cc1::SyntaxNodeCollector
    include Cc1::InterpreterOptions

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_array_subscript_expr_evaled += T(:check_array_subscript)
      @interp.on_indirection_expr_evaled     += T(:check_indirection)
    end

    private
    def check_array_subscript(expr, ary_or_ptr, subs, ary, *)
      return unless ary

      unless @interp.constant_expression?(expr.array_subscript)
        warn_array_oob_access(expr.array_subscript, ary, subs)
      end
    end

    def check_indirection(expr, *)
      ary, subs_expr = extract_array_and_subscript(expr.operand)
      return unless ary

      unless @interp.constant_expression?(subs_expr)
        subs = @interp.interpret(subs_expr, QUIET_WITHOUT_SIDE_EFFECT)
        warn_array_oob_access(expr.operand, ary, subs)
      end
    end

    def warn_array_oob_access(expr, ary, subs)
      if ary_len = ary.type.length
        lower_bound = @interp.scalar_value_of(0)
        upper_bound = @interp.scalar_value_of(ary_len - 1)

        lower_test = subs.value < lower_bound
        upper_test = subs.value > upper_bound

        if !lower_test.must_be_true? && lower_test.may_be_true? or
            !upper_test.must_be_true? && upper_test.may_be_true?
          W(expr.location)
        end
      end
    end

    def extract_array_and_subscript(expr)
      ary, ary_name = extract_array(expr)
      subs_expr = create_subscript_expr(expr, ary_name)
      return ary, subs_expr
    end

    def extract_array(expr)
      collect_object_specifiers(expr).each do |os|
        if obj = @interp.variable_named(os.identifier.value)
          case
          when obj.type.array?
            return obj, os.identifier.value
          when obj.type.pointer?
            if obj = @interp.pointee_of(obj) and obj.type.array?
              return obj, os.identifier.value
            end
          end
        end
      end
      nil
    end

    def create_subscript_expr(expr, ary_name)
      expr.accept(ExpressionTransformer.new(ary_name))
    end

    class ExpressionTransformer < Cc1::SyntaxTreeVisitor
      def initialize(ary_name)
        @ary_name = ary_name
      end

      def visit_error_expression(node)
        node
      end

      def visit_object_specifier(node)
        if node.identifier.value == @ary_name
          Cc1::ConstantSpecifier.new(Token.new(:CONSTANT, "0", node.location))
        else
          node
        end
      end

      def visit_constant_specifier(node)
        node
      end

      def visit_string_literal_specifier(node)
        node
      end

      def visit_null_constant_specifier(node)
        node
      end

      def visit_grouped_expression(node)
        Cc1::GroupedExpression.new(node.expression.accept(self))
      end

      def visit_array_subscript_expression(node)
        Cc1::ArraySubscriptExpression.new(
          node.expression.accept(self), node.array_subscript.accept(self),
          node.operator)
      end

      def visit_function_call_expression(node)
        Cc1::FunctionCallExpression.new(
          node.expression.accept(self),
          node.argument_expressions.map { |expr| expr.accept(self) },
          node.operator)
      end

      def visit_member_access_by_value_expression(node)
        Cc1::MemberAccessByValueExpression.new(
          node.expression.accept(self), node.identifier, node.operator)
      end

      def visit_member_access_by_pointer_expression(node)
        Cc1::MemberAccessByPointerExpression.new(
          node.expression.accept(self), node.identifier, node.operator)
      end

      def visit_bit_access_by_value_expression(node)
        Cc1::BitAccessByValueExpression.new(
          node.expression.accept(self), node.constant, node.operator)
      end

      def visit_bit_access_by_pointer_expression(node)
        Cc1::BitAccessByPointerExpression.new(
          node.expression.accept(self), node.constant, node.operator)
      end

      def visit_postfix_increment_expression(node)
        # NOTE: The postfix-increment-expression is already evaluated with
        #       side-effect.
        #       To rollback the side-effect, create an inverted expression.
        Cc1::PrefixDecrementExpression.new(
          Token.new("--", "--", node.operator.location),
          node.operand.accept(self))
      end

      def visit_postfix_decrement_expression(node)
        # NOTE: The postfix-decrement-expression is already evaluated with
        #       side-effect.
        #       To rollback the side-effect, create an inverted expression.
        Cc1::PrefixIncrementExpression.new(
          Token.new("++", "++", node.operator.location),
          node.operand.accept(self))
      end

      def visit_compound_literal_expression(node)
        Cc1::CompoundLiteralExpression.new(
          node.type_name, node.initializers.map { |init| init.accept(self) },
          node.operator)
      end

      def visit_prefix_increment_expression(node)
        # NOTE: The prefix-increment-expression is already evaluated with
        #       side-effect.
        #       To rollback the side-effect, create an inverted expression.
        Cc1::PostfixDecrementExpression.new(
          Token.new("--", "--", node.operator.location),
          node.operand.accept(self))
      end

      def visit_prefix_decrement_expression(node)
        # NOTE: The prefix-decrement-expression is already evaluated with
        #       side-effect.
        #       To rollback the side-effect, create an inverted expression.
        Cc1::PostfixIncrementExpression.new(
          Token.new("++", "++", node.operator.location),
          node.operand.accept(self))
      end

      def visit_address_expression(node)
        Cc1::AddressExpression.new(node.operator, node.operand.accept(self))
      end

      def visit_indirection_expression(node)
        Cc1::IndirectionExpression.new(
          node.operator, node.operand.accept(self))
      end

      def visit_unary_arithmetic_expression(node)
        Cc1::UnaryArithmeticExpression.new(
          node.operator, node.operand.accept(self))
      end

      def visit_sizeof_expression(node)
        Cc1::SizeofExpression.new(node.operator, node.operand.accept(self))
      end

      def visit_sizeof_type_expression(node)
        node
      end

      def visit_alignof_expression(node)
        Cc1::AlignofExpression.new(node.operator, node.operand.accept(self))
      end

      def visit_alignof_type_expression(node)
        node
      end

      def visit_cast_expression(node)
        Cc1::CastExpression.new(node.type_name, node.operand.accept(self))
      end

      def visit_multiplicative_expression(node)
        Cc1::MultiplicativeExpression.new(node.operator,
                                          node.lhs_operand.accept(self),
                                          node.rhs_operand.accept(self))
      end

      def visit_additive_expression(node)
        Cc1::AdditiveExpression.new(node.operator,
                                    node.lhs_operand.accept(self),
                                    node.rhs_operand.accept(self))
      end

      def visit_shift_expression(node)
        Cc1::ShiftExpression.new(node.operator,
                                 node.lhs_operand.accept(self),
                                 node.rhs_operand.accept(self))
      end

      def visit_relational_expression(node)
        Cc1::RelationalExpression.new(node.operator,
                                      node.lhs_operand.accept(self),
                                      node.rhs_operand.accept(self))
      end

      def visit_equality_expression(node)
        Cc1::EqualityExpression.new(node.operator,
                                    node.lhs_operand.accept(self),
                                    node.rhs_operand.accept(self))
      end

      def visit_and_expression(node)
        Cc1::AndExpression.new(node.operator,
                               node.lhs_operand.accept(self),
                               node.rhs_operand.accept(self))
      end

      def visit_exclusive_or_expression(node)
        Cc1::ExclusiveOrExpression.new(node.operator,
                                       node.lhs_operand.accept(self),
                                       node.rhs_operand.accept(self))
      end

      def visit_inclusive_or_expression(node)
        Cc1::InclusiveOrExpression.new(node.operator,
                                       node.lhs_operand.accept(self),
                                       node.rhs_operand.accept(self))
      end

      def visit_logical_and_expression(node)
        Cc1::LogicalAndExpression.new(node.operator,
                                      node.lhs_operand.accept(self),
                                      node.rhs_operand.accept(self))
      end

      def visit_logical_or_expression(node)
        Cc1::LogicalOrExpression.new(node.operator,
                                     node.lhs_operand.accept(self),
                                     node.rhs_operand.accept(self))
      end

      def visit_conditional_expression(node)
        Cc1::ConditionalExpression.new(node.condition.accept(self),
                                       node.then_expression.accept(self),
                                       node.else_expression.accept(self),
                                       Token.new("?", "?", node.location))
      end

      def visit_simple_assignment_expression(node)
        Cc1::SimpleAssignmentExpression.new(node.operator,
                                            node.lhs_operand.accept(self),
                                            node.rhs_operand.accept(self))
      end

      def visit_compound_assignment_expression(node)
        Cc1::CompoundAssignmentExpression.new(node.operator,
                                              node.lhs_operand.accept(self),
                                              node.rhs_operand.accept(self))
      end

      def visit_comma_separated_expression(node)
        exprs = node.expressions.map { |expr| expr.accept(self) }
        transformed = Cc1::CommaSeparatedExpression.new(exprs.shift)
        exprs.each { |expr| transformed.expressions.push(expr) }
        transformed
      end

      def visit_initializer(node)
        case
        when node.expression
          Cc1::Initializer.new(node.expression.accept(self), nil)
        when node.initializers
          Cc1::Initializer.new(
            nil, node.initializers.map { |i| i.accept(self) })
        end
      end
    end
    private_constant :ExpressionTransformer
  end

  class W0707 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    include Cc1::SyntaxNodeCollector
    include Cc1::InterpreterOptions

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_array_subscript_expr_evaled += T(:check_array_subscript)
      @interp.on_indirection_expr_evaled     += T(:check_indirection)
    end

    private
    def check_array_subscript(expr, ary_or_ptr, subs, ary, *)
      return unless ary

      if @interp.constant_expression?(expr.array_subscript)
        warn_array_oob_access(expr.array_subscript, ary, subs)
      end
    end

    def check_indirection(expr, *)
      ary, subs_expr = extract_array_and_subscript(expr.operand)
      return unless ary

      if @interp.constant_expression?(subs_expr)
        # NOTE: A constant-expression has no side-effects.
        subs = @interp.interpret(subs_expr, QUIET)
        warn_array_oob_access(expr.operand, ary, subs)
      end
    end

    def warn_array_oob_access(expr, ary, subs)
      if ary_len = ary.type.length
        lower_bound = @interp.scalar_value_of(0)
        upper_bound = @interp.scalar_value_of(ary_len - 1)

        lower_test = subs.value < lower_bound
        upper_test = subs.value > upper_bound

        if lower_test.must_be_true? || upper_test.must_be_true?
          W(expr.location)
        end
      end
    end

    def extract_array_and_subscript(expr)
      ary, ary_name = extract_array(expr)
      subs_expr = create_subscript_expr(expr, ary_name)
      return ary, subs_expr
    end

    def extract_array(expr)
      collect_object_specifiers(expr).each do |os|
        if obj = @interp.variable_named(os.identifier.value)
          case
          when obj.type.array?
            return obj, os.identifier.value
          when obj.type.pointer?
            if obj = @interp.pointee_of(obj) and obj.type.array?
              return obj, os.identifier.value
            end
          end
        end
      end
      nil
    end

    def create_subscript_expr(expr, ary_name)
      expr.accept(ExpressionTransformer.new(ary_name))
    end

    class ExpressionTransformer < Cc1::SyntaxTreeVisitor
      def initialize(ary_name)
        @ary_name = ary_name
      end

      def visit_error_expression(node)
        node
      end

      def visit_object_specifier(node)
        if node.identifier.value == @ary_name
          Cc1::ConstantSpecifier.new(Token.new(:CONSTANT, "0", node.location))
        else
          node
        end
      end

      def visit_constant_specifier(node)
        node
      end

      def visit_string_literal_specifier(node)
        node
      end

      def visit_null_constant_specifier(node)
        node
      end

      def visit_grouped_expression(node)
        Cc1::GroupedExpression.new(node.expression.accept(self))
      end

      def visit_array_subscript_expression(node)
        Cc1::ArraySubscriptExpression.new(node.expression.accept(self),
                                          node.array_subscript.accept(self),
                                          node.operator)
      end

      def visit_function_call_expression(node)
        Cc1::FunctionCallExpression.new(
          node.expression.accept(self),
          node.argument_expressions.map { |expr| expr.accept(self) },
          node.operator)
      end

      def visit_member_access_by_value_expression(node)
        Cc1::MemberAccessByValueExpression.new(
          node.expression.accept(self), node.identifier, node.operator)
      end

      def visit_member_access_by_pointer_expression(node)
        Cc1::MemberAccessByPointerExpression.new(
          node.expression.accept(self), node.identifier, node.operator)
      end

      def visit_bit_access_by_value_expression(node)
        Cc1::BitAccessByValueExpression.new(
          node.expression.accept(self), node.constant, node.operator)
      end

      def visit_bit_access_by_pointer_expression(node)
        Cc1::BitAccessByPointerExpression.new(
          node.expression.accept(self), node.constant, node.operator)
      end

      def visit_postfix_increment_expression(node)
        # NOTE: The postfix-increment-expression is already evaluated with
        #       side-effect.
        #       To rollback the side-effect, create an inverted expression.
        Cc1::PrefixDecrementExpression.new(
          Token.new("--", "--", node.operator.location),
          node.operand.accept(self))
      end

      def visit_postfix_decrement_expression(node)
        # NOTE: The postfix-decrement-expression is already evaluated with
        #       side-effect.
        #       To rollback the side-effect, create an inverted expression.
        Cc1::PrefixIncrementExpression.new(
          Token.new("++", "++", node.operator.location),
          node.operand.accept(self))
      end

      def visit_compound_literal_expression(node)
        Cc1::CompoundLiteralExpression.new(
          node.type_name, node.initializers.map { |init| init.accept(self) },
          node.operator)
      end

      def visit_prefix_increment_expression(node)
        # NOTE: The prefix-increment-expression is already evaluated with
        #       side-effect.
        #       To rollback the side-effect, create an inverted expression.
        Cc1::PostfixDecrementExpression.new(
          Token.new("--", "--", node.operator.location),
          node.operand.accept(self))
      end

      def visit_prefix_decrement_expression(node)
        # NOTE: The prefix-decrement-expression is already evaluated with
        #       side-effect.
        #       To rollback the side-effect, create an inverted expression.
        Cc1::PostfixIncrementExpression.new(
          Token.new("++", "++", node.operator.location),
          node.operand.accept(self))
      end

      def visit_address_expression(node)
        Cc1::AddressExpression.new(node.operator, node.operand.accept(self))
      end

      def visit_indirection_expression(node)
        Cc1::IndirectionExpression.new(
          node.operator, node.operand.accept(self))
      end

      def visit_unary_arithmetic_expression(node)
        Cc1::UnaryArithmeticExpression.new(
          node.operator, node.operand.accept(self))
      end

      def visit_sizeof_expression(node)
        Cc1::SizeofExpression.new(node.operator, node.operand.accept(self))
      end

      def visit_sizeof_type_expression(node)
        node
      end

      def visit_alignof_expression(node)
        Cc1::AlignofExpression.new(node.operator, node.operand.accept(self))
      end

      def visit_alignof_type_expression(node)
        node
      end

      def visit_cast_expression(node)
        Cc1::CastExpression.new(node.type_name, node.operand.accept(self))
      end

      def visit_multiplicative_expression(node)
        Cc1::MultiplicativeExpression.new(node.operator,
                                          node.lhs_operand.accept(self),
                                          node.rhs_operand.accept(self))
      end

      def visit_additive_expression(node)
        Cc1::AdditiveExpression.new(node.operator,
                                    node.lhs_operand.accept(self),
                                    node.rhs_operand.accept(self))
      end

      def visit_shift_expression(node)
        Cc1::ShiftExpression.new(node.operator,
                                 node.lhs_operand.accept(self),
                                 node.rhs_operand.accept(self))
      end

      def visit_relational_expression(node)
        Cc1::RelationalExpression.new(node.operator,
                                      node.lhs_operand.accept(self),
                                      node.rhs_operand.accept(self))
      end

      def visit_equality_expression(node)
        Cc1::EqualityExpression.new(node.operator,
                                    node.lhs_operand.accept(self),
                                    node.rhs_operand.accept(self))
      end

      def visit_and_expression(node)
        Cc1::AndExpression.new(node.operator,
                               node.lhs_operand.accept(self),
                               node.rhs_operand.accept(self))
      end

      def visit_exclusive_or_expression(node)
        Cc1::ExclusiveOrExpression.new(node.operator,
                                       node.lhs_operand.accept(self),
                                       node.rhs_operand.accept(self))
      end

      def visit_inclusive_or_expression(node)
        Cc1::InclusiveOrExpression.new(node.operator,
                                       node.lhs_operand.accept(self),
                                       node.rhs_operand.accept(self))
      end

      def visit_logical_and_expression(node)
        Cc1::LogicalAndExpression.new(node.operator,
                                      node.lhs_operand.accept(self),
                                      node.rhs_operand.accept(self))
      end

      def visit_logical_or_expression(node)
        Cc1::LogicalOrExpression.new(node.operator,
                                     node.lhs_operand.accept(self),
                                     node.rhs_operand.accept(self))
      end

      def visit_conditional_expression(node)
        Cc1::ConditionalExpression.new(node.condition.accept(self),
                                       node.then_expression.accept(self),
                                       node.else_expression.accept(self),
                                       Token.new("?", "?", node.location))
      end

      def visit_simple_assignment_expression(node)
        Cc1::SimpleAssignmentExpression.new(node.operator,
                                            node.lhs_operand.accept(self),
                                            node.rhs_operand.accept(self))
      end

      def visit_compound_assignment_expression(node)
        Cc1::CompoundAssignmentExpression.new(node.operator,
                                              node.lhs_operand.accept(self),
                                              node.rhs_operand.accept(self))
      end

      def visit_comma_separated_expression(node)
        exprs = node.expressions.map { |expr| expr.accept(self) }
        transformed = Cc1::CommaSeparatedExpression.new(exprs.shift)
        exprs.each { |expr| transformed.expressions.push(expr) }
        transformed
      end

      def visit_initializer(node)
        case
        when node.expression
          Cc1::Initializer.new(node.expression.accept(self), nil)
        when node.initializers
          Cc1::Initializer.new(
            nil, node.initializers.map { |i| i.accept(self) })
        end
      end
    end
    private_constant :ExpressionTransformer
  end

  class W0708 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    include Cc1::SyntaxNodeCollector

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_for_stmt_started       += T(:enter_for_stmt)
      @interp.on_for_stmt_ended         += T(:leave_for_stmt)
      @interp.on_c99_for_stmt_started   += T(:enter_c99_for_stmt)
      @interp.on_c99_for_stmt_ended     += T(:leave_c99_for_stmt)
      @interp.on_variable_value_updated += T(:update_variable)
      @ctrl_var_stack = []
    end

    private
    def enter_for_stmt(node)
      inited_var_names =
        collect_object_specifiers(node.initial_statement).map { |os|
          os.identifier.value
        }
      if ctrl_var_name = deduct_ctrl_variable_name(node, inited_var_names)
        @ctrl_var_stack.push([ctrl_var_name, node])
      end
    end

    def leave_for_stmt(*)
      @ctrl_var_stack.pop
    end

    def enter_c99_for_stmt(node)
      inited_var_names =
        collect_identifier_declarators(node.declaration).map { |id|
          id.identifier.value
        }
      if ctrl_var_name = deduct_ctrl_variable_name(node, inited_var_names)
        @ctrl_var_stack.push([ctrl_var_name, node])
      end
    end

    def leave_c99_for_stmt(*)
      @ctrl_var_stack.pop
    end

    def update_variable(expr, var)
      if var.named? and ctrl_vars = @ctrl_var_stack.last
        if ctrl_vars.first == var.name && !in_ctrl_part(ctrl_vars.last, expr)
          W(expr.location, var.name)
        end
      end
    end

    def deduct_ctrl_variable_name(node, inited_var_names)
      var_names = inited_var_names + node.varying_variable_names
      histo = var_names.each_with_object({}) { |name, hash| hash[name] = 0 }

      ctrl_expr, * = node.deduct_controlling_expression
      collect_object_specifiers(ctrl_expr).map { |obj_spec|
        obj_spec.identifier.value
      }.each { |obj_name| histo.include?(obj_name) and histo[obj_name] += 1 }

      histo.to_a.sort { |a, b| b.last <=> a.last }.map(&:first).find do |name|
        var = @interp.variable_named(name) and !var.type.const?
      end
    end

    def in_ctrl_part(for_or_c99_for_stmt, expr)
      case for_or_c99_for_stmt
      when Cc1::ForStatement
        contain_expr?(for_or_c99_for_stmt.initial_statement, expr)     ||
          contain_expr?(for_or_c99_for_stmt.condition_statement, expr) ||
          contain_expr?(for_or_c99_for_stmt.expression, expr)
      when Cc1::C99ForStatement
        contain_expr?(for_or_c99_for_stmt.condition_statement, expr) ||
          contain_expr?(for_or_c99_for_stmt.expression, expr)
      end
    end

    def contain_expr?(node, expr)
      node ? Visitor.new(expr).tap { |v| node.accept(v) }.result : false
    end

    class Visitor < Cc1::SyntaxTreeVisitor
      def initialize(expr)
        @expr = expr
        @result = false
      end

      attr_reader :result

      def visit_address_expression(node)
        node == @expr && @result = true or super
      end

      def visit_postfix_increment_expression(node)
        node == @expr && @result = true or super
      end

      def visit_postfix_decrement_expression(node)
        node == @expr && @result = true or super
      end

      def visit_prefix_increment_expression(node)
        node == @expr && @result = true or super
      end

      def visit_prefix_decrement_expression(node)
        node == @expr && @result = true or super
      end

      def visit_simple_assignment_expression(node)
        node == @expr && @result = true or super
      end

      def visit_compound_assignment_expression(node)
        node == @expr && @result = true or super
      end

      def visit_function_call_expression(node)
        node == @expr && @result = true or super
      end
    end
    private_constant :Visitor
  end

  class W0719 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_shift_expr_evaled += T(:check)
    end

    private
    def check(expr, lhs_var, rhs_var, *)
      if @interp.constant_expression?(expr.rhs_operand)
        underlying_type     = lhs_var.type
        underlying_bit_size = @interp.scalar_value_of(underlying_type.bit_size)
        promoted_type       = lhs_var.type.integer_promoted_type
        promoted_bit_size   = @interp.scalar_value_of(promoted_type.bit_size)

        if rhs_var.value.must_be_equal_to?(underlying_bit_size) ||
            rhs_var.value.must_be_greater_than?(underlying_bit_size) and
            rhs_var.value.must_be_less_than?(promoted_bit_size)
          W(expr.location, underlying_type.brief_image)
        end
      end
    end
  end

  class W0720 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_explicit_conv_performed += T(:check)
    end

    private
    def check(expr, org_var, res_var)
      org_type = org_var.type
      res_type = res_var.type

      unless org_type.scalar? && org_type.floating? &&
          res_type.scalar? && res_type.integer?
        return
      end

      org_val = org_var.value
      return unless org_val.scalar?

      lower_test = org_val < @interp.scalar_value_of(res_type.min - 1)
      upper_test = org_val > @interp.scalar_value_of(res_type.max + 1)

      if lower_test.must_be_true? || upper_test.must_be_true?
        W(expr.location)
      end
    end
  end

  class W0721 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_explicit_conv_performed += T(:check)
    end

    private
    def check(expr, org_var, res_var)
      org_type = org_var.type
      res_type = res_var.type

      unless org_type.pointer? && res_type.scalar? && res_type.integer?
        return
      end

      if org_type.min < res_type.min || org_type.max > res_type.max
        W(expr.location)
      end
    end
  end

  class W0722 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_multiplicative_expr_evaled += T(:check)
      @interp.on_additive_expr_evaled       += T(:check)
    end

    private
    def check(expr, lhs_var, rhs_var, res_var)
      return unless lhs_var.type.scalar? && lhs_var.type.signed?
      return unless rhs_var.type.scalar? && rhs_var.type.signed?

      return unless lhs_var.value.scalar? && rhs_var.value.scalar?

      case expr.operator.type
      when "+"
        unbound_val = lhs_var.value + rhs_var.value
      when "-"
        unbound_val = lhs_var.value - rhs_var.value
      when "*"
        unbound_val = lhs_var.value * rhs_var.value
      else
        return
      end

      lower_test = unbound_val < @interp.scalar_value_of(res_var.type.min)
      upper_test = unbound_val > @interp.scalar_value_of(res_var.type.max)

      if lower_test.must_be_true? || upper_test.must_be_true?
        W(expr.location)
      end
    end
  end

  class W0723 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_multiplicative_expr_evaled += T(:check)
      @interp.on_additive_expr_evaled       += T(:check)
    end

    private
    def check(expr, lhs_var, rhs_var, res_var)
      return unless lhs_var.type.scalar? && lhs_var.type.signed?
      return unless rhs_var.type.scalar? && rhs_var.type.signed?

      return unless lhs_var.value.scalar? && rhs_var.value.scalar?

      case expr.operator.type
      when "+"
        unbound_val = lhs_var.value + rhs_var.value
      when "-"
        unbound_val = lhs_var.value - rhs_var.value
      when "*"
        unbound_val = lhs_var.value * rhs_var.value
      else
        return
      end

      lower_test = unbound_val < @interp.scalar_value_of(res_var.type.min)
      upper_test = unbound_val > @interp.scalar_value_of(res_var.type.max)

      if !lower_test.must_be_true? && lower_test.may_be_true? or
          !upper_test.must_be_true? && upper_test.may_be_true?
        W(expr.location)
      end
    end
  end

  class W0727 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_explicit_conv_performed += T(:check)
      interp.on_implicit_conv_performed += T(:check)
    end

    private
    def check(init_or_expr, org_var, res_var)
      return unless res_var.type.enum?

      val = org_var.value.unique_sample
      unless res_var.type.enumerators.any? { |enum| val == enum.value }
        W(init_or_expr.location)
      end
    end
  end

  class W0728 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_function_call_expr_evaled += T(:check)
    end

    private
    def check(expr, fun, arg_vars, *)
      args = arg_vars.zip(fun.type.parameter_types)
      args.each_with_index do |(arg_var, param_type), idx|
        next unless param_type && param_type.enum?

        arg_expr = expr.argument_expressions[idx]
        if @interp.constant_expression?(arg_expr)
          if arg_var.type.enum?
            W(arg_expr.location) unless arg_var.type.same_as?(param_type)
          end
        end
      end
    end
  end

  class W0729 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_assignment_expr_evaled += T(:check)
    end

    private
    def check(expr, lhs_var, rhs_var)
      return unless lhs_var.type.enum?
      if @interp.constant_expression?(expr.rhs_operand)
        if rhs_var.type.enum? && !lhs_var.type.same_as?(rhs_var.type)
          W(expr.location)
        end
      end
    end
  end

  class W0730 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_function_started   += T(:start_function)
      @interp.on_function_ended     += T(:end_function)
      @interp.on_return_stmt_evaled += T(:check)
      @cur_fun = nil
    end

    private
    def start_function(*, fun)
      @cur_fun = fun
    end

    def end_function(*)
      @cur_fun = nil
    end

    def check(retn_stmt, retn_var)
      return unless @cur_fun && retn_var
      return unless retn_type = @cur_fun.type.return_type
      return unless retn_type.enum?

      if @interp.constant_expression?(retn_stmt.expression)
        if retn_var.type.enum? && !retn_type.same_as?(retn_var.type)
          W(retn_stmt.expression.location)
        end
      end
    end
  end

  class W0731 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_switch_stmt_ended      += T(:end_switch_statement)
      interp.on_switch_ctrlexpr_evaled += T(:memorize_switch_ctrlexpr)
      interp.on_case_ctrlexpr_evaled   += T(:check)
      @switch_ctrlexpr_stack = []
    end

    private
    def end_switch_statement(*)
      @switch_ctrlexpr_stack.pop
    end

    def memorize_switch_ctrlexpr(*, ctrlexpr_var)
      @switch_ctrlexpr_stack.push(ctrlexpr_var)
    end

    def check(case_stmt, ctrlexpr_var)
      unless switch_ctrlexpr_var = @switch_ctrlexpr_stack.last
        return
      end

      return unless switch_ctrlexpr_var.type.enum?
      expected_type = switch_ctrlexpr_var.type

      val = ctrlexpr_var.value.unique_sample
      unless expected_type.enumerators.any? { |enum| val == enum.value }
        W(case_stmt.expression.location, case_stmt.expression.to_s)
      end
    end
  end

  class W0736 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_variable_defined       += T(:define_variable)
      interp.on_variable_referred      += T(:refer_variable)
      interp.on_function_started       += T(:enter_function)
      interp.on_function_ended         += T(:leave_function)
      interp.on_translation_unit_ended += M(:check)
      @static_vars = {}
      @functions = []
    end

    private
    def define_variable(var_def, var)
      return unless @functions.empty?
      @static_vars[var] = [var_def, Set.new] if var.declared_as_static?
    end

    def refer_variable(*, var)
      return if @functions.empty?
      @static_vars[var].last.add(@functions.last) if @static_vars.include?(var)
    end

    def enter_function(*, fun)
      @functions.push(fun)
    end

    def leave_function(*)
      @functions.pop
    end

    def check(*)
      @static_vars.each do |var, (var_def, accessors)|
        W(var_def.location, var.name) if accessors.size == 1
      end
    end
  end

  class W0737 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_variable_declared += T(:check)
      interp.on_variable_defined  += T(:check)
    end

    private
    def check(dcl_or_def, *)
      return unless dcl_or_def.type.enum?

      if dcl_or_def.type.incomplete?
        W(dcl_or_def.location, dcl_or_def.type.name)
      end
    end
  end

  class W0738 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_implicit_conv_performed += T(:check)
    end

    private
    def check(init_or_expr, org_var, res_var)
      case init_or_expr
      when Cc1::Initializer
        unless expr = init_or_expr.expression
          return
        end
      when Cc1::Expression
        expr = init_or_expr
      end

      return unless @interp.constant_expression?(expr)

      org_type = org_var.type
      res_type = res_var.type

      unless org_type.scalar? && org_type.integer? &&
          res_type.scalar? && res_type.integer? && res_type.unsigned?
        return
      end

      org_val = org_var.value
      return unless org_val.scalar?

      upper_test = org_val > @interp.scalar_value_of(res_type.max)

      W(expr.location) if upper_test.must_be_true?
    end
  end

  class W0739 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_additive_expr_evaled += T(:check)
    end

    private
    def check(expr, lhs_var, rhs_var, res_var)
      return unless expr.operator.type == "-"

      return unless @interp.constant_expression?(expr.lhs_operand)
      return unless @interp.constant_expression?(expr.rhs_operand)

      return unless lhs_var.type.scalar? && lhs_var.type.unsigned?
      return unless rhs_var.type.scalar? && rhs_var.type.unsigned?

      return unless lhs_var.value.scalar? && rhs_var.value.scalar?

      unbound_val = lhs_var.value - rhs_var.value
      lower_test = unbound_val < @interp.scalar_value_of(res_var.type.min)

      W(expr.location) if lower_test.must_be_true?
    end
  end

  class W0740 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_additive_expr_evaled += T(:check)
    end

    private
    def check(expr, lhs_var, rhs_var, res_var)
      return unless expr.operator.type == "+"

      return unless @interp.constant_expression?(expr.lhs_operand)
      return unless @interp.constant_expression?(expr.rhs_operand)

      return unless lhs_var.type.scalar? && lhs_var.type.unsigned?
      return unless rhs_var.type.scalar? && rhs_var.type.unsigned?

      return unless lhs_var.value.scalar? && rhs_var.value.scalar?

      unbound_val = lhs_var.value + rhs_var.value
      upper_test = unbound_val > @interp.scalar_value_of(res_var.type.max)

      W(expr.location) if upper_test.must_be_true?
    end
  end

  class W0741 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_multiplicative_expr_evaled += T(:check)
    end

    private
    def check(expr, lhs_var, rhs_var, res_var)
      return unless expr.operator.type == "*"

      return unless @interp.constant_expression?(expr.lhs_operand)
      return unless @interp.constant_expression?(expr.rhs_operand)

      return unless lhs_var.type.scalar? && lhs_var.type.unsigned?
      return unless rhs_var.type.scalar? && rhs_var.type.unsigned?

      return unless lhs_var.value.scalar? && rhs_var.value.scalar?

      unbound_val = lhs_var.value * rhs_var.value
      upper_test = unbound_val > @interp.scalar_value_of(res_var.type.max)

      W(expr.location) if upper_test.must_be_true?
    end
  end

  class W0742 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_implicit_conv_performed += T(:check)
    end

    private
    def check(init_or_expr, org_var, res_var)
      unless org_var.type.scalar? && res_var.type.scalar? &&
          org_var.type.signed? && res_var.type.unsigned?
        return
      end

      if init_or_expr.kind_of?(Cc1::Initializer)
        expr = init_or_expr.expression
      else
        expr = init_or_expr
      end

      if expr && @interp.constant_expression?(expr) &&
          org_var.value.must_be_less_than?(@interp.scalar_value_of(0))
        W(expr.location)
      end
    end
  end

  class W0743 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_implicit_conv_performed += T(:check)
    end

    private
    def check(init_or_expr, org_var, res_var)
      case init_or_expr
      when Cc1::Initializer
        unless expr = init_or_expr.expression
          return
        end
      when Cc1::Expression
        expr = init_or_expr
      end

      return unless @interp.constant_expression?(expr)

      org_type = org_var.type
      res_type = res_var.type

      unless org_type.scalar? && org_type.integer? &&
          res_type.scalar? && res_type.integer? && res_type.signed?
        return
      end

      org_val = org_var.value
      return unless org_val.scalar?

      lower_test = org_val < @interp.scalar_value_of(res_type.min)
      upper_test = org_val > @interp.scalar_value_of(res_type.max)

      if lower_test.must_be_true? || upper_test.must_be_true?
        W(expr.location)
      end
    end
  end

  class W0744 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_if_ctrlexpr_evaled      += T(:check_if_statement)
      @interp.on_if_else_ctrlexpr_evaled += T(:check_if_else_statement)
      @interp.on_while_ctrlexpr_evaled   += T(:check_while_statement)
      @interp.on_for_ctrlexpr_evaled     += T(:check_for_statement)
      @interp.on_c99_for_ctrlexpr_evaled += T(:check_c99_for_statement)
    end

    private
    def check_if_statement(if_stmt, ctrlexpr_val)
      ctrlexpr = if_stmt.expression
      if @interp.constant_expression?(ctrlexpr) && ctrlexpr_val.must_be_false?
        W(ctrlexpr.location)
      end
    end

    def check_if_else_statement(if_else_stmt, ctrlexpr_val)
      ctrlexpr = if_else_stmt.expression
      if @interp.constant_expression?(ctrlexpr) && ctrlexpr_val.must_be_false?
        W(ctrlexpr.location)
      end
    end

    def check_while_statement(while_stmt, ctrlexpr_val)
      ctrlexpr = while_stmt.expression
      if @interp.constant_expression?(ctrlexpr) && ctrlexpr_val.must_be_false?
        W(ctrlexpr.location)
      end
    end

    def check_for_statement(for_stmt, ctrlexpr_val)
      ctrlexpr = for_stmt.condition_statement.expression
      if @interp.constant_expression?(ctrlexpr) && ctrlexpr_val.must_be_false?
        W(ctrlexpr.location)
      end
    end

    def check_c99_for_statement(c99_for_stmt, ctrlexpr_val)
      ctrlexpr = c99_for_stmt.condition_statement.expression
      if @interp.constant_expression?(ctrlexpr) && ctrlexpr_val.must_be_false?
        W(ctrlexpr.location)
      end
    end
  end

  class W0745 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    include Cc1::SyntaxNodeCollector
    include Cc1::InterpreterOptions

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_array_subscript_expr_evaled += T(:check_array_subscript)
      @interp.on_indirection_expr_evaled     += T(:check_indirection)
    end

    private
    def check_array_subscript(expr, ary_or_ptr, subs, ary, *)
      return unless ary

      unless @interp.constant_expression?(expr.array_subscript)
        warn_array_oob_access(expr.array_subscript, ary, subs)
      end
    end

    def check_indirection(expr, *)
      ary, subs_expr = extract_array_and_subscript(expr.operand)
      return unless ary

      unless @interp.constant_expression?(subs_expr)
        subs = @interp.interpret(subs_expr, QUIET_WITHOUT_SIDE_EFFECT)
        warn_array_oob_access(expr.operand, ary, subs)
      end
    end

    def warn_array_oob_access(expr, ary, subs)
      if ary_len = ary.type.length
        lower_test = subs.value < @interp.scalar_value_of(0)
        upper_test = subs.value > @interp.scalar_value_of(ary_len - 1)

        if lower_test.must_be_true? || upper_test.must_be_true?
          W(expr.location)
        end
      end
    end

    def extract_array_and_subscript(expr)
      ary, ary_name = extract_array(expr)
      subs_expr = create_subscript_expr(expr, ary_name)
      return ary, subs_expr
    end

    def extract_array(expr)
      collect_object_specifiers(expr).each do |obj_spec|
        if obj = @interp.variable_named(obj_spec.identifier.value)
          case
          when obj.type.array?
            return obj, obj_spec.identifier.value
          when obj.type.pointer?
            if obj = @interp.pointee_of(obj) and obj.type.array?
              return obj, obj_spec.identifier.value
            end
          end
        end
      end
      nil
    end

    def create_subscript_expr(expr, ary_name)
      expr.accept(ExpressionTransformer.new(ary_name))
    end

    class ExpressionTransformer < Cc1::SyntaxTreeVisitor
      def initialize(ary_name)
        @ary_name = ary_name
      end

      def visit_error_expression(node)
        node
      end

      def visit_object_specifier(node)
        if node.identifier.value == @ary_name
          Cc1::ConstantSpecifier.new(Token.new(:CONSTANT, "0", node.location))
        else
          node
        end
      end

      def visit_constant_specifier(node)
        node
      end

      def visit_string_literal_specifier(node)
        node
      end

      def visit_null_constant_specifier(node)
        node
      end

      def visit_grouped_expression(node)
        Cc1::GroupedExpression.new(node.expression.accept(self))
      end

      def visit_array_subscript_expression(node)
        Cc1::ArraySubscriptExpression.new(node.expression.accept(self),
                                          node.array_subscript.accept(self),
                                          node.operator)
      end

      def visit_function_call_expression(node)
        Cc1::FunctionCallExpression.new(
          node.expression.accept(self),
          node.argument_expressions.map { |expr| expr.accept(self) },
          node.operator)
      end

      def visit_member_access_by_value_expression(node)
        Cc1::MemberAccessByValueExpression.new(
          node.expression.accept(self), node.identifier, node.operator)
      end

      def visit_member_access_by_pointer_expression(node)
        Cc1::MemberAccessByPointerExpression.new(
          node.expression.accept(self), node.identifier, node.operator)
      end

      def visit_bit_access_by_value_expression(node)
        Cc1::BitAccessByValueExpression.new(
          node.expression.accept(self), node.constant, node.operator)
      end

      def visit_bit_access_by_pointer_expression(node)
        Cc1::BitAccessByPointerExpression.new(
          node.expression.accept(self), node.constant, node.operator)
      end

      def visit_postfix_increment_expression(node)
        # NOTE: The postfix-increment-expression is already evaluated with
        #       side-effect.
        #       To rollback the side-effect, create an inverted expression.
        Cc1::PrefixDecrementExpression.new(
          Token.new("--", "--", node.operator.location),
          node.operand.accept(self))
      end

      def visit_postfix_decrement_expression(node)
        # NOTE: The postfix-decrement-expression is already evaluated with
        #       side-effect.
        #       To rollback the side-effect, create an inverted expression.
        Cc1::PrefixIncrementExpression.new(
          Token.new("++", "++", node.operator.location),
          node.operand.accept(self))
      end

      def visit_compound_literal_expression(node)
        Cc1::CompoundLiteralExpression.new(
          node.type_name, node.initializers.map { |init| init.accept(self) },
          node.operator)
      end

      def visit_prefix_increment_expression(node)
        # NOTE: The prefix-increment-expression is already evaluated with
        #       side-effect.
        #       To rollback the side-effect, create an inverted expression.
        Cc1::PostfixDecrementExpression.new(
          Token.new("--", "--", node.operator.location),
          node.operand.accept(self))
      end

      def visit_prefix_decrement_expression(node)
        # NOTE: The prefix-decrement-expression is already evaluated with
        #       side-effect.
        #       To rollback the side-effect, create an inverted expression.
        Cc1::PostfixIncrementExpression.new(
          Token.new("++", "++", node.operator.location),
          node.operand.accept(self))
      end

      def visit_address_expression(node)
        Cc1::AddressExpression.new(
          node.operator, node.operand.accept(self))
      end

      def visit_indirection_expression(node)
        Cc1::IndirectionExpression.new(
          node.operator, node.operand.accept(self))
      end

      def visit_unary_arithmetic_expression(node)
        Cc1::UnaryArithmeticExpression.new(
          node.operator, node.operand.accept(self))
      end

      def visit_sizeof_expression(node)
        Cc1::SizeofExpression.new(node.operator, node.operand.accept(self))
      end

      def visit_sizeof_type_expression(node)
        node
      end

      def visit_alignof_expression(node)
        Cc1::AlignofExpression.new(node.operator, node.operand.accept(self))
      end

      def visit_alignof_type_expression(node)
        node
      end

      def visit_cast_expression(node)
        Cc1::CastExpression.new(node.type_name, node.operand.accept(self))
      end

      def visit_multiplicative_expression(node)
        Cc1::MultiplicativeExpression.new(node.operator,
                                          node.lhs_operand.accept(self),
                                          node.rhs_operand.accept(self))
      end

      def visit_additive_expression(node)
        Cc1::AdditiveExpression.new(node.operator,
                                    node.lhs_operand.accept(self),
                                    node.rhs_operand.accept(self))
      end

      def visit_shift_expression(node)
        Cc1::ShiftExpression.new(node.operator,
                                 node.lhs_operand.accept(self),
                                 node.rhs_operand.accept(self))
      end

      def visit_relational_expression(node)
        Cc1::RelationalExpression.new(node.operator,
                                      node.lhs_operand.accept(self),
                                      node.rhs_operand.accept(self))
      end

      def visit_equality_expression(node)
        Cc1::EqualityExpression.new(node.operator,
                                    node.lhs_operand.accept(self),
                                    node.rhs_operand.accept(self))
      end

      def visit_and_expression(node)
        Cc1::AndExpression.new(node.operator,
                               node.lhs_operand.accept(self),
                               node.rhs_operand.accept(self))
      end

      def visit_exclusive_or_expression(node)
        Cc1::ExclusiveOrExpression.new(node.operator,
                                       node.lhs_operand.accept(self),
                                       node.rhs_operand.accept(self))
      end

      def visit_inclusive_or_expression(node)
        Cc1::InclusiveOrExpression.new(node.operator,
                                       node.lhs_operand.accept(self),
                                       node.rhs_operand.accept(self))
      end

      def visit_logical_and_expression(node)
        Cc1::LogicalAndExpression.new(node.operator,
                                      node.lhs_operand.accept(self),
                                      node.rhs_operand.accept(self))
      end

      def visit_logical_or_expression(node)
        Cc1::LogicalOrExpression.new(node.operator,
                                     node.lhs_operand.accept(self),
                                     node.rhs_operand.accept(self))
      end

      def visit_conditional_expression(node)
        Cc1::ConditionalExpression.new(node.condition.accept(self),
                                       node.then_expression.accept(self),
                                       node.else_expression.accept(self),
                                       Token.new("?", "?", node.location))
      end

      def visit_simple_assignment_expression(node)
        Cc1::SimpleAssignmentExpression.new(node.operator,
                                            node.lhs_operand.accept(self),
                                            node.rhs_operand.accept(self))
      end

      def visit_compound_assignment_expression(node)
        Cc1::CompoundAssignmentExpression.new(node.operator,
                                              node.lhs_operand.accept(self),
                                              node.rhs_operand.accept(self))
      end

      def visit_comma_separated_expression(node)
        exprs = node.expressions.map { |expr| expr.accept(self) }
        transformed = Cc1::CommaSeparatedExpression.new(exprs.shift)
        exprs.each { |expr| transformed.expressions.push(expr) }
        transformed
      end

      def visit_initializer(node)
        case
        when node.expression
          Cc1::Initializer.new(node.expression.accept(self), nil)
        when node.initializers
          Cc1::Initializer.new(
            nil, node.initializers.map { |i| i.accept(self) })
        end
      end
    end
    private_constant :ExpressionTransformer
  end

  class W0747 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_short_t
    end

    def to_type
      @interp.signed_char_t
    end
  end

  class W0748 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_short_t
    end

    def to_type
      @interp.unsigned_char_t
    end
  end

  class W0749 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_int_t
    end

    def to_type
      @interp.signed_char_t
    end
  end

  class W0750 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_int_t
    end

    def to_type
      @interp.signed_short_t
    end
  end

  class W0751 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_int_t
    end

    def to_type
      @interp.unsigned_char_t
    end
  end

  class W0752 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_int_t
    end

    def to_type
      @interp.unsigned_short_t
    end
  end

  class W0753 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_long_t
    end

    def to_type
      @interp.signed_char_t
    end
  end

  class W0754 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_long_t
    end

    def to_type
      @interp.signed_short_t
    end
  end

  class W0755 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_long_t
    end

    def to_type
      @interp.signed_int_t
    end
  end

  class W0756 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_long_t
    end

    def to_type
      @interp.unsigned_char_t
    end
  end

  class W0757 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_long_t
    end

    def to_type
      @interp.unsigned_short_t
    end
  end

  class W0758 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_long_t
    end

    def to_type
      @interp.unsigned_int_t
    end
  end

  class W0759 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_long_long_t
    end

    def to_type
      @interp.signed_char_t
    end
  end

  class W0760 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_long_long_t
    end

    def to_type
      @interp.signed_short_t
    end
  end

  class W0761 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_long_long_t
    end

    def to_type
      @interp.signed_int_t
    end
  end

  class W0762 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.signed_long_long_t
    end

    def to_type
      @interp.signed_long_t
    end
  end

  class W0763 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_long_long_t
    end

    def to_type
      @interp.unsigned_char_t
    end
  end

  class W0764 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_long_long_t
    end

    def to_type
      @interp.unsigned_short_t
    end
  end

  class W0765 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_long_long_t
    end

    def to_type
      @interp.unsigned_int_t
    end
  end

  class W0766 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.unsigned_long_long_t
    end

    def to_type
      @interp.unsigned_long_t
    end
  end

  class W0767 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.double_t
    end

    def to_type
      @interp.float_t
    end
  end

  class W0768 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.long_double_t
    end

    def to_type
      @interp.float_t
    end
  end

  class W0769 < W0119
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.long_double_t
    end

    def to_type
      @interp.double_t
    end
  end

  class W0771 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_variable_declared          += T(:declare_variable)
      interp.on_explicit_function_declared += T(:declare_function)
      interp.on_translation_unit_ended     += M(:check)
      @obj_dcls = Hash.new { |hash, key| hash[key] = [] }
    end

    private
    def declare_variable(var_dcl, var)
      if var.named? && var.declared_as_extern?
        @obj_dcls[var.name].push(var_dcl)
      end
    end

    def declare_function(fun_dcl, fun)
      if fun.named? && fun.declared_as_extern?
        @obj_dcls[fun.name].push(fun_dcl)
      end
    end

    def check(*)
      @obj_dcls.each_value do |dcls|
        similar_dcls = dcls.uniq { |dcl| dcl.location.fpath }
        next unless similar_dcls.size > 1

        similar_dcls.each do |dcl|
          W(dcl.location, dcl.identifier.value, *similar_dcls.map { |pair_dcl|
            next if pair_dcl == dcl
            C(:C0001, pair_dcl.location, pair_dcl.identifier.value)
          }.compact)
        end
      end
    end
  end

  class W0774 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.double_t
    end

    def to_type
      @interp.float_t
    end
  end

  class W0775 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.long_double_t
    end

    def to_type
      @interp.float_t
    end
  end

  class W0776 < W0255
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def from_type
      @interp.long_double_t
    end

    def to_type
      @interp.double_t
    end
  end

  class W0777 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_implicit_conv_performed    += T(:check)
      @interp.on_function_started           += T(:clear_rvalues)
      @interp.on_additive_expr_evaled       += T(:handle_additive)
      @interp.on_multiplicative_expr_evaled += T(:handle_multiplicative)
      @rvalues = nil
    end

    private
    def check(*, org_var, res_var)
      return unless @rvalues && org_var.type.floating?
      case expr = @rvalues[org_var]
      when Cc1::AdditiveExpression, Cc1::MultiplicativeExpression
        if org_var.type.same_as?(from_type) && res_var.type.same_as?(to_type)
          W(expr.location)
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

  class W0778 < W0777
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

  class W0779 < W0777
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

  class W0780 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_shift_expr_evaled += T(:check)
    end

    private
    def check(expr, lhs_var, rhs_var, *)
      op = expr.operator.type
      return unless op == "<<" || op == "<<="

      if lhs_var.type.unsigned? && @interp.constant_expression?(expr)
        if must_overflow?(lhs_var, rhs_var)
          W(expr.location)
        end
      end
    end

    def must_overflow?(lhs_var, rhs_var)
      unbound_val = lhs_var.value << rhs_var.value
      lhs_max_val = @interp.scalar_value_of(lhs_var.type.max)
      unbound_val.must_be_greater_than?(lhs_max_val)
    end
  end

  class W0783 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_explicit_conv_performed += T(:check)
    end

    private
    def check(expr, org_var, res_var)
      from_type = org_var.type.unqualify
      to_type = res_var.type.unqualify

      return unless from_type.pointer? && to_type.pointer?

      unless from_type.base_type.void? || to_type.base_type.void?
        if from_type.base_type.incomplete? || to_type.base_type.incomplete?
          W(expr.location)
        end
      end
    end
  end

  class W0785 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_struct_declared += T(:check)
      interp.on_union_declared  += T(:check)
      interp.on_enum_declared   += T(:check)
      @tag_names = Set.new
    end

    private
    def check(type_dcl)
      # NOTE: Unique autogenerated tag name is assigned to the unnamed
      #       struct/union/enum declarations in parsing phase.
      tag_name = type_dcl.identifier.value

      W(type_dcl.location, tag_name) if @tag_names.include?(tag_name)
      @tag_names.add(tag_name)
    end
  end

  class W0786 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_struct_type_declaration += T(:check)
      visitor.enter_union_type_declaration  += T(:check)
      @interp = phase_ctxt[:cc1_interpreter]
    end

    private
    def check(node)
      node.struct_declarations.each do |struct_dcl|
        struct_dcl.items.each do |memb_dcl|
          type = memb_dcl.type
          next unless type.scalar? && type.integer? && type.bitfield?

          case type.base_type
          when @interp.int_t, @interp.unsigned_int_t, @interp.signed_int_t
            next
          else
            W(node.location)
            return
          end
        end
      end
    end
  end

  class W0787 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_variable_declared          += T(:check_object_declaration)
      interp.on_variable_defined           += T(:check_object_declaration)
      interp.on_explicit_function_declared += T(:check_object_declaration)
      interp.on_explicit_function_defined  += T(:check_object_declaration)
      interp.on_typedef_declared           += T(:check_typedef_declaration)
      interp.on_enum_declared              += T(:check_enum_declaration)
      interp.on_block_started              += T(:enter_scope)
      interp.on_block_ended                += T(:leave_scope)

      @obj_dcls     = [Hash.new { |hash, key| hash[key] = [] }]
      @typedef_dcls = [Hash.new { |hash, key| hash[key] = [] }]
      @enum_names   = [Hash.new { |hash, key| hash[key] = [] }]

      @obj_dcls_in_other_scope     = Hash.new { |hash, key| hash[key] = [] }
      @typedef_dcls_in_other_scope = Hash.new { |hash, key| hash[key] = [] }
      @enum_names_in_other_scope   = Hash.new { |hash, key| hash[key] = [] }
    end

    private
    def check_object_declaration(obj_dcl, obj)
      return unless obj.declared_as_extern?

      name = obj_dcl.identifier.value
      type = obj_dcl.type

      pairs =
        @obj_dcls_in_other_scope[name].select { |dcl| dcl.type != type } +
        @typedef_dcls_in_other_scope[name] + @enum_names_in_other_scope[name]

      unless pairs.empty?
        W(obj_dcl.location, name, *pairs.map { |pair|
          C(:C0001, pair.location, pair.identifier.value)
        })
      end

      @obj_dcls.last[name].push(obj_dcl)
    end

    def check_typedef_declaration(typedef_dcl)
      name = typedef_dcl.identifier.value
      type = typedef_dcl.type

      pairs = @obj_dcls_in_other_scope[name] +
              @typedef_dcls_in_other_scope[name].select { |dcl|
                dcl.type != type
              } + @enum_names_in_other_scope[name]

      unless pairs.empty?
        W(typedef_dcl.location, name, *pairs.map { |pair|
          C(:C0001, pair.location, pair.identifier.value)
        })
      end

      @typedef_dcls.last[name].push(typedef_dcl)
    end

    def check_enum_declaration(enum_dcl)
      enum_dcl.enumerators.each { |enum| check_enumerator(enum) }
    end

    def check_enumerator(enum)
      name = enum.identifier.value

      pairs = @obj_dcls_in_other_scope[name] +
              @typedef_dcls_in_other_scope[name] +
              @enum_names_in_other_scope[name]

      unless pairs.empty?
        W(enum.location, name, *pairs.map { |pair|
          C(:C0001, pair.location, pair.identifier.value)
        })
      end

      @enum_names.last[name].push(enum)
    end

    def enter_scope(*)
      @obj_dcls.push(Hash.new { |hash, key| hash[key] = [] })
      @typedef_dcls.push(Hash.new { |hash, key| hash[key] = [] })
      @enum_names.push(Hash.new { |hash, key| hash[key] = [] })
    end

    def leave_scope(*)
      @obj_dcls.last.each do |name, dcls|
        @obj_dcls_in_other_scope[name].concat(dcls)
      end
      @obj_dcls.pop

      @typedef_dcls.last.each do |name, dcls|
        @typedef_dcls_in_other_scope[name].concat(dcls)
      end
      @typedef_dcls.pop

      @enum_names.last.each do |name, enums|
        @enum_names_in_other_scope[name].concat(enums)
      end
      @enum_names.pop
    end
  end

  class W0788 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_variable_declared          += T(:check_object_declaration)
      interp.on_variable_defined           += T(:check_object_declaration)
      interp.on_explicit_function_declared += T(:check_object_declaration)
      interp.on_explicit_function_defined  += T(:check_object_declaration)
      interp.on_typedef_declared           += T(:check_typedef_declaration)
      interp.on_enum_declared              += T(:check_enum_declaration)
      interp.on_block_started              += T(:enter_scope)
      interp.on_block_ended                += T(:leave_scope)

      @obj_dcls     = [Hash.new { |hash, key| hash[key] = [] }]
      @typedef_dcls = [Hash.new { |hash, key| hash[key] = [] }]
      @enum_names   = [Hash.new { |hash, key| hash[key] = [] }]
    end

    private
    def check_object_declaration(obj_dcl, *)
      name = obj_dcl.identifier.value
      type = obj_dcl.type

      pairs = @obj_dcls.last[name].select { |dcl| dcl.type != type } +
              @typedef_dcls.last[name] + @enum_names.last[name]

      unless pairs.empty?
        W(obj_dcl.location, name, *pairs.map { |pair|
          C(:C0001, pair.location, pair.identifier.value)
        })
      end

      @obj_dcls.last[name].push(obj_dcl)
    end

    def check_typedef_declaration(typedef_dcl)
      name = typedef_dcl.identifier.value
      type = typedef_dcl.type

      pairs = @obj_dcls.last[name] +
              @typedef_dcls.last[name].select { |dcl| dcl.type != type } +
              @enum_names.last[name]

      unless pairs.empty?
        W(typedef_dcl.location, name, *pairs.map { |pair|
          C(:C0001, pair.location, pair.identifier.value)
        })
      end

      @typedef_dcls.last[name].push(typedef_dcl)
    end

    def check_enum_declaration(enum_dcl)
      enum_dcl.enumerators.each { |enum| check_enumerator(enum) }
    end

    def check_enumerator(enum)
      name = enum.identifier.value

      pairs = @obj_dcls.last[name] + @typedef_dcls.last[name] +
              @enum_names.last[name]

      unless pairs.empty?
        W(enum.location, name, *pairs.map { |pair|
          C(:C0001, pair.location, pair.identifier.value)
        })
      end

      @enum_names.last[name].push(enum)
    end

    def enter_scope(*)
      @obj_dcls.push(Hash.new { |hash, key| hash[key] = [] })
      @typedef_dcls.push(Hash.new { |hash, key| hash[key] = [] })
      @enum_names.push(Hash.new { |hash, key| hash[key] = [] })
    end

    def leave_scope(*)
      @obj_dcls.pop
      @typedef_dcls.pop
      @enum_names.pop
    end
  end

  class W0789 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_variable_declared          += T(:check_object_declaration)
      interp.on_variable_defined           += T(:check_object_declaration)
      interp.on_explicit_function_declared += T(:check_object_declaration)
      interp.on_explicit_function_defined  += T(:check_object_declaration)
      interp.on_typedef_declared           += T(:check_typedef_declaration)
      interp.on_enum_declared              += T(:check_enum_declaration)
      interp.on_block_started              += T(:enter_scope)
      interp.on_block_ended                += T(:leave_scope)

      @obj_dcls     = [Hash.new { |hash, key| hash[key] = [] }]
      @typedef_dcls = [Hash.new { |hash, key| hash[key] = [] }]
      @enum_names   = [Hash.new { |hash, key| hash[key] = [] }]
    end

    private
    def check_object_declaration(obj_dcl, *)
      name = obj_dcl.identifier.value
      type = obj_dcl.type

      pairs =
        merge_upper_scopes(name, @obj_dcls).select { |dcl| dcl.type != type } +
        merge_upper_scopes(name, @typedef_dcls) +
        merge_upper_scopes(name, @enum_names)

      unless pairs.empty?
        W(obj_dcl.location, name, *pairs.map { |pair|
          C(:C0001, pair.location, pair.identifier.value)
        })
      end

      @obj_dcls.last[name].push(obj_dcl)
    end

    def check_typedef_declaration(typedef_dcl)
      name = typedef_dcl.identifier.value
      type = typedef_dcl.type

      pairs = merge_upper_scopes(name, @obj_dcls) +
              merge_upper_scopes(name, @typedef_dcls).select { |dcl|
                dcl.type != type
              } + merge_upper_scopes(name, @enum_names)

      unless pairs.empty?
        W(typedef_dcl.location, name, *pairs.map { |pair|
          C(:C0001, pair.location, pair.identifier.value)
        })
      end

      @typedef_dcls.last[name].push(typedef_dcl)
    end

    def check_enum_declaration(enum_dcl)
      enum_dcl.enumerators.each { |enum| check_enumerator(enum) }
    end

    def check_enumerator(enum)
      name = enum.identifier.value

      pairs = merge_upper_scopes(name, @obj_dcls) +
              merge_upper_scopes(name, @typedef_dcls) +
              merge_upper_scopes(name, @enum_names)

      unless pairs.empty?
        W(enum.location, name, *pairs.map { |pair|
          C(:C0001, pair.location, pair.identifier.value)
        })
      end

      @enum_names.last[name].push(enum)
    end

    def enter_scope(*)
      @obj_dcls.push(Hash.new { |hash, key| hash[key] = [] })
      @typedef_dcls.push(Hash.new { |hash, key| hash[key] = [] })
      @enum_names.push(Hash.new { |hash, key| hash[key] = [] })
    end

    def leave_scope(*)
      @obj_dcls.pop
      @typedef_dcls.pop
      @enum_names.pop
    end

    def merge_upper_scopes(name, scoped_hash)
      scoped_hash[0..-2].reduce([]) { |scopes, hash| scopes + hash[name] }
    end
  end

  class W0790 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_variable_defined          += T(:check)
      interp.on_explicit_function_defined += T(:check)
      @global_names = Hash.new { |hash, key| hash[key] = [] }
    end

    private
    def check(var_or_fun_def, obj)
      if obj.declared_as_extern?
        name = var_or_fun_def.identifier
        if @global_names.include?(name.value)
          W(var_or_fun_def.location, name.value,
            *@global_names[name.value].map { |pair_name|
              C(:C0001, pair_name.location, pair_name.value)
            })
        end
        @global_names[name.value].push(name)
      end
    end
  end

  class W0792 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_explicit_conv_performed += T(:check)
    end

    private
    def check(expr, org_var, res_var)
      lhs_type = org_var.type.unqualify
      rhs_type = res_var.type.unqualify

      case
      when lhs_type.floating? &&
           rhs_type.pointer? && rhs_type.base_type.function?
        W(expr.location)
      when rhs_type.floating? &&
           lhs_type.pointer? && lhs_type.base_type.function?
        W(expr.location)
      end
    end
  end

  class W0793 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_explicit_conv_performed += T(:check)
    end

    private
    def check(expr, org_var, res_var)
      lhs_type = org_var.type.unqualify
      rhs_type = res_var.type.unqualify

      if lhs_type.pointer? && rhs_type.pointer?
        case
        when lhs_type.base_type.void? || rhs_type.base_type.void?
          # NOTE: Nothing to be done with conversion between `void *' and any
          #       pointer and between `void *' and `void *'.
        when lhs_type.base_type.function? && !rhs_type.base_type.function?,
             rhs_type.base_type.function? && !lhs_type.base_type.function?
          W(expr.location)
        end
      end
    end
  end

  class W0794 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_shift_expr_evaled += T(:check)
    end

    private
    def check(expr, lhs_var, *)
      case expr.operator.type
      when "<<", "<<="
        unless @interp.constant_expression?(expr.lhs_operand)
          W(expr.location) if lhs_var.type.signed?
        end
      end
    end
  end

  class W0795 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_function_call_expr_evaled += T(:check)
    end

    private
    def check(funcall_expr, fun, arg_vars, *)
      if proto = prototype_declaration_of(fun)
        param_types = proto.type.parameter_types
        if arg_vars.size < param_types.select { |type| !type.void? }.size
          W(funcall_expr.location)
        end
      end
    end

    def prototype_declaration_of(fun)
      fun.declarations_and_definitions.find do |dcl_or_def|
        dcl_or_def.kind_of?(Cc1::FunctionDeclaration)
      end
    end
  end

  class W0796 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_function_call_expr_evaled += T(:check)
    end

    private
    def check(funcall_expr, fun, arg_vars, *)
      if proto = prototype_declaration_of(fun)
        return if proto.type.have_va_list?

        param_types = proto.type.parameter_types
        if !param_types.empty? &&
            arg_vars.size > param_types.select { |type| !type.void? }.size
          W(funcall_expr.location)
        end
      end
    end

    def prototype_declaration_of(fun)
      fun.declarations_and_definitions.find do |dcl_or_def|
        dcl_or_def.kind_of?(Cc1::FunctionDeclaration)
      end
    end
  end

  class W0797 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_function_call_expr_evaled += T(:check)
    end

    private
    def check(funcall_expr, fun, arg_vars, *)
      unless prototype_declaration_of(fun)
        if fun_def = kandr_style_definition_of(fun)
          case fun_dcr = fun_def.function_declarator
          when Cc1::KandRFunctionDeclarator
            param_num = fun_dcr.identifier_list.size
          else
            return
          end

          W(funcall_expr.location) unless arg_vars.size == param_num
        end
      end
    end

    def prototype_declaration_of(fun)
      fun.declarations_and_definitions.find do |dcl_or_def|
        dcl_or_def.kind_of?(Cc1::FunctionDeclaration)
      end
    end

    def kandr_style_definition_of(fun)
      fun.declarations_and_definitions.find do |dcl_or_def|
        dcl_or_def.kind_of?(Cc1::KandRFunctionDefinition)
      end
    end
  end

  class W0798 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_indirection_expr_evaled     += T(:check_indirection)
      interp.on_member_access_expr_evaled   += T(:check_member_access)
      interp.on_array_subscript_expr_evaled += T(:check_array_subscript)
    end

    private
    def check_indirection(expr, var, *)
      if var.type.pointer?
        base_type = var.type.unqualify.base_type
        if base_type.union? && base_type.incomplete?
          W(expr.location)
        end
      end
    end

    def check_member_access(expr, outer_var, *)
      if outer_var.type.pointer?
        base_type = outer_var.type.unqualify.base_type
        if base_type.union? && base_type.incomplete?
          W(expr.location)
        end
      end
    end

    def check_array_subscript(expr, ary_or_ptr, *)
      if ary_or_ptr.type.pointer?
        base_type = ary_or_ptr.type.unqualify.base_type
        if base_type.union? && base_type.incomplete?
          W(expr.location)
        end
      end
    end
  end

  class W0799 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_indirection_expr_evaled     += T(:check_indirection)
      interp.on_member_access_expr_evaled   += T(:check_member_access)
      interp.on_array_subscript_expr_evaled += T(:check_array_subscript)
    end

    private
    def check_indirection(expr, var, *)
      if var.type.pointer?
        base_type = var.type.unqualify.base_type
        if base_type.struct? && base_type.incomplete?
          W(expr.location)
        end
      end
    end

    def check_member_access(expr, outer_var, *)
      if outer_var.type.pointer?
        base_type = outer_var.type.unqualify.base_type
        if base_type.struct? && base_type.incomplete?
          W(expr.location)
        end
      end
    end

    def check_array_subscript(expr, ary_or_ptr, *)
      if ary_or_ptr.type.pointer?
        base_type = ary_or_ptr.type.unqualify.base_type
        if base_type.struct? && base_type.incomplete?
          W(expr.location)
        end
      end
    end
  end

  class W0800 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_variable_defined += T(:check)
    end

    private
    def check(var_def, var)
      unless var.declared_as_extern?
        W(var_def.location, var.name) if var.type.incomplete?
      end
    end
  end

  class W0810 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_if_statement      += T(:enter_outer_if_stmt)
      visitor.leave_if_statement      += T(:leave_outer_if_stmt)
      visitor.enter_if_else_statement += T(:check_inner_if_else_stmt)
      @if_stmt_stack = []
    end

    private
    def enter_outer_if_stmt(if_stmt)
      @if_stmt_stack.push(if_stmt)
    end

    def leave_outer_if_stmt(*)
      @if_stmt_stack.pop
    end

    def check_inner_if_else_stmt(*)
      if outer_if_stmt = @if_stmt_stack.last and
          !outer_if_stmt.statement.kind_of?(Cc1::CompoundStatement)
        W(outer_if_stmt.location)
      end
    end
  end

  class W0827 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_variable_definition += T(:enter_variable_definition)
    end

    private
    def enter_variable_definition(node)
      if outmost_init = node.initializer
        if inits = outmost_init.initializers
          case
          when node.type.array?
            check(node.type.base_type, inits.first)
          when node.type.struct?
            node.type.members.zip(inits).each do |memb, init|
              check(memb.type, init) if init
            end
          end
        end
      end
    end

    def check(type, init)
      return unless init

      if inits = init.initializers
        case
        when type.array?
          check(type.base_type, inits.first)
        when type.struct?
          type.members.zip(inits).each { |m, i| i and check(m.type, i) }
        end
      else
        W(init.location) if type.struct?
      end
    end
  end

  class W0828 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_variable_definition += T(:enter_variable_definition)
    end

    private
    def enter_variable_definition(node)
      if outmost_init = node.initializer
        if inits = outmost_init.initializers
          case
          when node.type.array?
            check(node.type.base_type, inits.first)
          when node.type.struct?
            node.type.members.zip(inits).each do |memb, init|
              check(memb.type, init) if init
            end
          end
        end
      end
    end

    def check(type, init)
      return unless init

      case
      when inits = init.initializers
        case
        when type.array?
          check(type.base_type, inits.first)
        when type.struct?
          type.members.zip(inits).each { |m, i| i and check(m.type, i) }
        end
      when init.expression.kind_of?(Cc1::StringLiteralSpecifier)
      else
        W(init.location) if type.array?
      end
    end
  end

  class W0830 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_enum_specifier += T(:check)
    end

    private
    def check(enum_spec)
      if extra_comma = enum_spec.trailing_comma
        W(extra_comma.location)
      end
    end
  end

  class W0833 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_constant_referred += T(:check)
    end

    private
    def check(const_spec, *)
      if const_spec.constant.value =~ /LL/i
        W(const_spec.location)
      end
    end
  end

  class W0834 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: W0834 may be duplicative on a function-definition because
    #       function-definition has both parameter-declarations and
    #       parameter-definitions.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_member_declaration        += T(:check_member_decl)
      visitor.enter_typedef_declaration       += T(:check_declspec_holder)
      visitor.enter_function_declaration      += T(:check_declspec_holder)
      visitor.enter_parameter_declaration     += T(:check_declspec_holder)
      visitor.enter_variable_declaration      += T(:check_declspec_holder)
      visitor.enter_variable_definition       += T(:check_declspec_holder)
      visitor.enter_ansi_function_definition  += T(:check_declspec_holder)
      visitor.enter_kandr_function_definition += T(:check_declspec_holder)
      visitor.enter_parameter_definition      += T(:check_declspec_holder)
      visitor.enter_type_name                 += T(:check_type_name)
    end

    private
    def check_member_decl(node)
      type_specs = node.specifier_qualifier_list.type_specifiers
      if fst_ts = type_specs.first
        node.type.accept(Visitor.new(@phase_ctxt, fst_ts.location))
      end
    end

    def check_type_name(node)
      type_specs = node.specifier_qualifier_list.type_specifiers
      if fst_ts = type_specs.first
        node.type.accept(Visitor.new(@phase_ctxt, fst_ts.location))
      end
    end

    def check_declspec_holder(dcl_spec_holder)
      type_specs = dcl_spec_holder.type_specifiers
      if fst_ts = type_specs.first
        dcl_spec_holder.type.accept(Visitor.new(@phase_ctxt, fst_ts.location))
      end
    end

    class Visitor < Cc1::TypeVisitor
      include ReportUtil

      def initialize(phase_ctxt, loc)
        @phase_ctxt = phase_ctxt
        @location = loc
      end

      def visit_long_long_type(*)
        W(@location)
      end

      def visit_signed_long_long_type(*)
        W(@location)
      end

      def visit_unsigned_long_long_type(*)
        W(@location)
      end

      def visit_long_long_int_type(*)
        W(@location)
      end

      def visit_signed_long_long_int_type(*)
        W(@location)
      end

      def visit_unsigned_long_long_int_type(*)
        W(@location)
      end

      def visit_function_type(type)
        type.return_type.accept(self)
      end

      def visit_struct_type(*)
      end

      def visit_union_type(*)
      end

      private
      extend Forwardable

      def_delegator :@phase_ctxt, :report
      private :report

      def_delegator :@phase_ctxt, :message_catalog
      private :message_catalog

      def suppressors
        @phase_ctxt[:suppressors]
      end
    end
    private_constant :Visitor
  end

  class W0947 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_string_literal_specifier += T(:check)
    end

    private
    def check(str_lit_spec)
      W(str_lit_spec.location) unless str_lit_spec.literal.replaced?
    end
  end

  class W0948 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_constant_specifier += T(:check)
    end

    private
    def check(const_spec)
      if const_spec.character? && !const_spec.constant.replaced?
        W(const_spec.location, const_spec.constant.value)
      end
    end
  end

  class W0949 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    include Cc1::InterpreterOptions

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_struct_declarator += T(:check)
      @interp = Cc1::Interpreter.new(phase_ctxt[:cc1_type_table])
    end

    private
    def check(node)
      if node.kind_of?(Cc1::StructDeclarator)
        if expr = node.expression and
            expr.kind_of?(Cc1::ConstantSpecifier) && !expr.constant.replaced?
          bitfield_width = compute_bitfield_width(expr)
          W(expr.location, expr.constant.value) if bitfield_width > 1
        end
      end
    end

    def compute_bitfield_width(expr)
      obj = @interp.execute(expr, QUIET)
      if obj.variable? && obj.value.scalar?
        obj.value.unique_sample || 0
      else
        0
      end
    end
  end

  class W0950 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    include Cc1::SyntaxNodeCollector

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_variable_definition += T(:check)
    end

    private
    def check(var_def)
      return unless var_def.type.array?

      dcr = var_def.init_declarator.declarator
      ary_dcrs = collect_array_declarators(dcr)

      ary_dcrs.each do |ary_dcr|
        if expr = ary_dcr.size_expression
          const_specs = collect_constant_specifiers(expr)
          if immediate = const_specs.find { |cs| !cs.constant.replaced? }
            W(immediate.location, immediate.to_s)
          end
        end
      end
    end
  end

  class W1026 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_function_call_expr_evaled += T(:check)
    end

    private
    def check(expr, fun, arg_vars, *)
      arg_exprs = expr.argument_expressions
      arg_exprs.zip(arg_vars).each_with_index do |(arg_expr, var), idx|
        W(arg_expr.location, idx + 1) if var.type.incomplete?
      end
    end
  end

  class W1027 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_variable_defined  += T(:check)
      interp.on_variable_declared += T(:check)
    end

    private
    def check(dcl_or_def, var)
      W(dcl_or_def.location) if var.type.array? && var.type.base_type.function?
    end
  end

  class W1028 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_variable_defined  += T(:check)
      interp.on_variable_declared += T(:check)
    end

    private
    def check(dcl_or_def, var)
      if var.type.array?
        type = var.type.base_type
        while type.array?
          if type.length
            type = type.base_type
          else
            W(dcl_or_def.location)
            break
          end
        end
      end
    end
  end

  class W1029 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_variable_defined  += T(:check)
      interp.on_variable_declared += T(:check)
    end

    private
    def check(dcl_or_def, var)
      if var.type.array?
        if var.type.base_type.composite? || var.type.base_type.void?
          W(dcl_or_def.location) if var.type.base_type.incomplete?
        end
      end
    end
  end

  class W1031 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_variable_declared          += T(:declare_variable)
      interp.on_variable_defined           += T(:define_variable)
      interp.on_explicit_function_declared += T(:declare_function)
      interp.on_explicit_function_defined  += T(:define_function)
    end

    private
    def declare_variable(var_dcl, var)
      if var.named?
        case
        when var.declared_as_extern?
          sc_spec = var_dcl.storage_class_specifier
          if sc_spec && sc_spec.type == :STATIC
            W(var_dcl.location, var.name)
          end
        when var.declared_as_static?
          sc_spec = var_dcl.storage_class_specifier
          if sc_spec && sc_spec.type == :EXTERN
            W(var_dcl.location, var.name)
          end
        end
      end
    end

    def define_variable(var_def, var)
      if var.named?
        case
        when var.declared_as_extern?
          sc_spec = var_def.storage_class_specifier
          if sc_spec && sc_spec.type == :STATIC
            W(var_def.location, var.name)
          end
        when var.declared_as_static?
          sc_spec = var_def.storage_class_specifier
          if sc_spec && sc_spec.type == :EXTERN
            W(var_def.location, var.name)
          end
        end
      end
    end

    def declare_function(fun_dcl, fun)
      if fun.named?
        case
        when fun.declared_as_extern?
          sc_spec = fun_dcl.storage_class_specifier
          if sc_spec && sc_spec.type == :STATIC
            W(fun_dcl.location, fun.name)
          end
        when fun.declared_as_static?
          sc_spec = fun_dcl.storage_class_specifier
          if sc_spec && sc_spec.type == :EXTERN
            W(fun_dcl.location, fun.name)
          end
        end
      end
    end

    def define_function(fun_def, fun)
      if fun.named?
        case
        when fun.declared_as_extern?
          sc_spec = fun_def.storage_class_specifier
          if sc_spec && sc_spec.type == :STATIC
            W(fun_def.location, fun.name)
          end
        when fun.declared_as_static?
          sc_spec = fun_def.storage_class_specifier
          if sc_spec && sc_spec.type == :EXTERN
            W(fun_def.location, fun.name)
          end
        end
      end
    end
  end

  class W1032 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_variable_defined += T(:check)
    end

    private
    def check(var_def, var)
      if var.declared_as_static? && var.type.incomplete?
        W(var_def.location, var.name)
      end
    end
  end

  class W1034 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_function_declaration += T(:check)
      visitor.enter_compound_statement   += T(:enter_block)
      visitor.leave_compound_statement   += T(:leave_block)
      @block_level = 0
    end

    private
    def check(dcl)
      if @block_level > 0
        if sc_spec = dcl.storage_class_specifier and sc_spec.type == :STATIC
          W(dcl.location, dcl.identifier.value)
        end
      end
    end

    def enter_block(*)
      @block_level += 1
    end

    def leave_block(*)
      @block_level -= 1
    end
  end

  class W1039 < PassiveCodeCheck
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
    def check(expr, fun, arg_vars, *)
      if fun.named?
        case fun.name
        when /\A.*printf\z/
          check_printf_format(expr, arg_vars)
        when /\A.*scanf\z/
          check_scanf_format(expr, arg_vars)
        end
      end
    end

    def check_printf_format(expr, arg_vars)
      if fmt = create_printf_format(expr, arg_vars)
        fmt.conversion_specifiers.each_with_index do |conv_spec, idx|
          W(fmt.location, idx + 1) if conv_spec.length_modifier == "ll"
        end
      end
    end

    def check_scanf_format(expr, arg_vars)
      if fmt = create_scanf_format(expr, arg_vars)
        fmt.conversion_specifiers.each_with_index do |conv_spec, idx|
          W(fmt.location, idx + 1) if conv_spec.length_modifier == "ll"
        end
      end
    end

    def create_printf_format(expr, arg_vars)
      if fmt_idx = format_arg_index_of(expr)
        fmt_arg = expr.argument_expressions[fmt_idx]
        if fmt_arg && fmt_arg.literal.value =~ /\AL?"(.*)"\z/i
          loc = fmt_arg.location
          args = arg_vars[(fmt_idx + 1)..-1] || []
          return Cc1::PrintfFormat.new($1, loc, args, @environ)
        end
      end
      nil
    end

    def create_scanf_format(expr, arg_vars)
      if fmt_idx = format_arg_index_of(expr)
        fmt_arg = expr.argument_expressions[fmt_idx]
        if fmt_arg && fmt_arg.literal.value =~ /\AL?"(.*)"\z/i
          loc = fmt_arg.location
          args = arg_vars[(fmt_idx + 1)..-1] || []
          return Cc1::ScanfFormat.new($1, loc, args, @environ)
        end
      end
      nil
    end

    def format_arg_index_of(funcall_expr)
      funcall_expr.argument_expressions.index do |arg_expr|
        arg_expr.kind_of?(Cc1::StringLiteralSpecifier)
      end
    end
  end

  class W1047 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    include Cc1::SyntaxNodeCollector

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_variable_initialized += T(:check)
    end

    private
    def check(var_def, *)
      type = var_def.type
      if type.struct? || type.union? || type.array?
        if init = var_def.initializer
          obj_specs = collect_object_specifiers(init)
          if obj_specs.any? { |os| !@interp.constant_expression?(os) }
            W(var_def.location)
          end
        end
      end
    end
  end

  class W1049 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_explicit_conv_performed += T(:check)
    end

    private
    def check(expr, org_var, res_var)
      org_type = org_var.type
      res_type = res_var.type

      unless org_type.scalar? && org_type.integer? &&
          res_type.scalar? && res_type.integer? && res_type.signed?
        return
      end

      org_val = org_var.value
      return unless org_val.scalar?

      lower_test = org_val < @interp.scalar_value_of(res_type.min)
      upper_test = org_val > @interp.scalar_value_of(res_type.max)

      if !lower_test.must_be_true? && lower_test.may_be_true? or
          !upper_test.must_be_true? && upper_test.may_be_true?
        W(expr.location)
      end
    end
  end

  class W1050 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_explicit_conv_performed += T(:check)
    end

    private
    def check(expr, org_var, res_var)
      org_type = org_var.type
      res_type = res_var.type

      unless org_type.scalar? && org_type.integer? &&
          res_type.scalar? && res_type.integer? && res_type.signed?
        return
      end

      org_val = org_var.value
      return unless org_val.scalar?

      lower_test = org_val < @interp.scalar_value_of(res_type.min)
      upper_test = org_val > @interp.scalar_value_of(res_type.max)

      if lower_test.must_be_true? || upper_test.must_be_true?
        W(expr.location)
      end
    end
  end

  class W1051 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_multiplicative_expr_evaled += T(:check)
      @interp.on_additive_expr_evaled       += T(:check)
    end

    private
    def check(expr, lhs_var, rhs_var, res_var)
      return unless lhs_var.type.scalar? && lhs_var.type.unsigned?
      return unless rhs_var.type.scalar? && rhs_var.type.unsigned?
      return unless lhs_var.value.scalar? && rhs_var.value.scalar?

      case expr.operator.type
      when "+"
        unbound_val = lhs_var.value + rhs_var.value
      when "-"
        unbound_val = lhs_var.value - rhs_var.value
      when "*"
        unbound_val = lhs_var.value * rhs_var.value
      else
        return
      end

      lower_test = unbound_val < @interp.scalar_value_of(res_var.type.min)
      upper_test = unbound_val > @interp.scalar_value_of(res_var.type.max)

      if lower_test.must_be_true? || upper_test.must_be_true?
        W(expr.location, res_var.type.brief_image)
      end
    end
  end

  class W1052 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_multiplicative_expr_evaled += T(:check)
      @interp.on_additive_expr_evaled       += T(:check)
    end

    private
    def check(expr, lhs_var, rhs_var, res_var)
      return unless lhs_var.type.scalar? && lhs_var.type.unsigned?
      return unless rhs_var.type.scalar? && rhs_var.type.unsigned?
      return unless lhs_var.value.scalar? && rhs_var.value.scalar?

      case expr.operator.type
      when "+"
        unbound_val = lhs_var.value + rhs_var.value
      when "-"
        unbound_val = lhs_var.value - rhs_var.value
      when "*"
        unbound_val = lhs_var.value * rhs_var.value
      else
        return
      end

      lower_test = unbound_val < @interp.scalar_value_of(res_var.type.min)
      upper_test = unbound_val > @interp.scalar_value_of(res_var.type.max)

      if !lower_test.must_be_true? && lower_test.may_be_true? or
          !upper_test.must_be_true? && upper_test.may_be_true?
        W(expr.location, res_var.type.brief_image)
      end
    end
  end

  class W1053 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_function_call_expr_evaled += T(:check)
    end

    private
    def check(expr, fun, arg_vars, *)
      args = arg_vars.zip(fun.type.parameter_types)
      args.each_with_index do |(arg_var, param_type), idx|
        next unless param_type && param_type.enum?

        arg_expr = expr.argument_expressions[idx]
        if @interp.constant_expression?(arg_expr)
          W(arg_expr.location) unless arg_var.type.enum?
        end
      end
    end
  end

  class W1054 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_assignment_expr_evaled += T(:check)
    end

    private
    def check(expr, lhs_var, rhs_var)
      W(expr.location) if lhs_var.type.enum? && !rhs_var.type.enum?
    end
  end

  class W1055 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_function_started   += T(:start_function)
      interp.on_function_ended     += T(:end_function)
      interp.on_return_stmt_evaled += T(:check)
      @cur_fun = nil
    end

    private
    def start_function(*, fun)
      @cur_fun = fun
    end

    def end_function(*)
      @cur_fun = nil
    end

    def check(retn_stmt, retn_var)
      return unless @cur_fun && retn_var

      if retn_type = @cur_fun.type.return_type and retn_type.enum?
        unless retn_var.type.enum?
          W(retn_stmt.expression.location)
        end
      end
    end
  end

  class W1056 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_function_call_expr_evaled += T(:check)
    end

    private
    def check(expr, fun, arg_vars, *)
      args = arg_vars.zip(fun.type.parameter_types)
      args.each_with_index do |(arg_var, param_type), idx|
        next unless param_type && param_type.enum?

        arg_expr = expr.argument_expressions[idx]
        unless @interp.constant_expression?(arg_expr)
          if arg_var.type.enum?
            W(arg_expr.location) unless arg_var.type.same_as?(param_type)
          end
        end
      end
    end
  end

  class W1057 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_assignment_expr_evaled += T(:check)
    end

    private
    def check(expr, lhs_var, rhs_var)
      return unless lhs_var.type.enum?

      if rhs_var.type.enum? && !@interp.constant_expression?(expr.rhs_operand)
        unless lhs_var.type.same_as?(rhs_var.type)
          W(expr.location)
        end
      end
    end
  end

  class W1058 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_function_started   += T(:start_function)
      @interp.on_function_ended     += T(:end_function)
      @interp.on_return_stmt_evaled += T(:check)
      @cur_fun  = nil
    end

    private
    def start_function(*, fun)
      @cur_fun = fun
    end

    def end_function(*)
      @cur_fun = nil
    end

    def check(retn_stmt, retn_var)
      return unless @cur_fun && retn_var
      return if @interp.constant_expression?(retn_stmt.expression)

      if retn_type = @cur_fun.type.return_type and retn_type.enum?
        if retn_var.type.enum? && !retn_type.same_as?(retn_var.type)
          W(retn_stmt.expression.location)
        end
      end
    end
  end

  class W1059 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_function_call_expr_evaled += T(:check)
    end

    private
    def check(expr, fun, arg_vars, *)
      args = arg_vars.zip(fun.type.parameter_types)
      args.each_with_index do |(arg_var, param_type), idx|
        if param_type && !param_type.enum?
          W(expr.argument_expressions[idx].location) if arg_var.type.enum?
        end
      end
    end
  end

  class W1060 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_function_started   += T(:start_function)
      interp.on_function_ended     += T(:end_function)
      interp.on_return_stmt_evaled += T(:check)
      @cur_fun  = nil
    end

    private
    def start_function(*, fun)
      @cur_fun = fun
    end

    def end_function(*)
      @cur_fun = nil
    end

    def check(retn_stmt, retn_var)
      return unless @cur_fun && retn_var

      if retn_type = @cur_fun.type.return_type and !retn_type.enum?
        W(retn_stmt.expression.location) if retn_var.type.enum?
      end
    end
  end

  class W1061 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_function_call_expr_evaled += T(:check)
    end

    private
    def check(expr, fun, arg_vars, *)
      args = arg_vars.zip(fun.type.parameter_types)
      args.each_with_index do |(arg_var, param_type), idx|
        next unless param_type && param_type.enum?

        arg_expr = expr.argument_expressions[idx]
        unless @interp.constant_expression?(arg_expr)
          unless arg_var.type.same_as?(param_type)
            W(arg_expr.location)
          end
        end
      end
    end
  end

  class W1062 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_assignment_expr_evaled += T(:check)
    end

    private
    def check(expr, lhs_var, rhs_var)
      if lhs_var.type.enum? && !@interp.constant_expression?(expr.rhs_operand)
        unless lhs_var.type.same_as?(rhs_var.type)
          W(expr.location)
        end
      end
    end
  end

  class W1063 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_function_started   += T(:start_function)
      @interp.on_function_ended     += T(:end_function)
      @interp.on_return_stmt_evaled += T(:check)
      @cur_fun  = nil
    end

    private
    def start_function(*, fun)
      @cur_fun = fun
    end

    def end_function(*)
      @cur_fun = nil
    end

    def check(retn_stmt, retn_var)
      return unless @cur_fun && retn_var

      if retn_type = @cur_fun.type.return_type and retn_type.enum?
        unless @interp.constant_expression?(retn_stmt.expression)
          unless retn_var.type.same_as?(retn_type)
            W(retn_stmt.expression.location)
          end
        end
      end
    end
  end

  class W1064 < W0731
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def check(case_stmt, ctrlexpr_var)
      unless switch_ctrlexpr_var = @switch_ctrlexpr_stack.last
        return
      end
      return unless switch_ctrlexpr_var.type.enum?

      W(case_stmt.expression.location) unless ctrlexpr_var.type.enum?
    end
  end

  class W1065 < W0731
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    private
    def check(case_stmt, ctrlexpr_var)
      unless switch_ctrlexpr_var = @switch_ctrlexpr_stack.last
        return
      end
      return unless switch_ctrlexpr_var.type.enum?

      if ctrlexpr_var.type.enum?
        expected_type = switch_ctrlexpr_var.type
        unless ctrlexpr_var.type.same_as?(expected_type)
          W(case_stmt.expression.location)
        end
      end
    end
  end

  class W1071 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_function_started       += T(:enter_function)
      interp.on_function_ended         += T(:leave_function)
      interp.on_implicit_return_evaled += M(:memorize_implicit_termination)
      interp.on_return_stmt_evaled     += T(:memorize_termination)
      @cur_fun = nil
      @term_points = 0
    end

    private
    def enter_function(fun_def, *)
      @cur_fun = fun_def
      @term_points = 0
    end

    def leave_function(*)
      if @cur_fun && @term_points > 1
        W(@cur_fun.location, @cur_fun.identifier.value)
      end
      @cur_fun = nil
    end

    def memorize_implicit_termination(loc)
      if loc.in_analysis_target?(traits)
        memorize_termination
      end
    end

    def memorize_termination(*)
      @term_points += 1 if @cur_fun
    end
  end

  class W1073 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_function_started          += T(:enter_function)
      interp.on_function_ended            += T(:leave_function)
      interp.on_function_call_expr_evaled += T(:add_return_value)
      interp.on_variable_value_referred   += T(:refer_return_value)
      @cur_fun   = nil
      @retn_vals = nil
    end

    private
    def enter_function(fun_def, *)
      @cur_fun   = fun_def
      @retn_vals = {}
    end

    def leave_function(*)
      if @cur_fun
        @retn_vals.each_value do |rec|
          unless rec[0]
            fun_name = rec[2].named? ? rec[2].name : "(anon)"
            W(rec[1].location, fun_name)
          end
        end
      end
      @cur_fun = nil
      @retn_vals = nil
    end

    def add_return_value(expr, fun, *, res_var)
      if @cur_fun
        unless fun.type.return_type.void?
          @retn_vals[res_var] = [false, expr, fun]
        end
      end
    end

    def refer_return_value(expr, var)
      if @cur_fun
        if rec = @retn_vals[var]
          rec[0] = true
        end
      end
    end
  end

  class W1074 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_sizeof_expression += T(:check)
    end

    private
    def check(expr)
      W(expr.operand.location) if expr.operand.have_side_effect?
    end
  end

  class W1075 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_variable_declared          += T(:declare_variable)
      interp.on_variable_defined           += T(:define_variable)
      interp.on_explicit_function_declared += T(:declare_function)
      interp.on_explicit_function_defined  += T(:define_function)
    end

    private
    def declare_variable(var_dcl, var)
      if var.named?
        if var.declared_as_static?
          sc_spec = var_dcl.storage_class_specifier
          unless sc_spec && sc_spec.type == :STATIC
            W(var_dcl.location, var.name)
          end
        end
      end
    end

    def define_variable(var_def, var)
      if var.named?
        if var.declared_as_static?
          sc_spec = var_def.storage_class_specifier
          unless sc_spec && sc_spec.type == :STATIC
            W(var_def.location, var.name)
          end
        end
      end
    end

    def declare_function(fun_dcl, fun)
      if fun.named?
        if fun.declared_as_static?
          sc_spec = fun_dcl.storage_class_specifier
          unless sc_spec && sc_spec.type == :STATIC
            W(fun_dcl.location, fun.name)
          end
        end
      end
    end

    def define_function(fun_def, fun)
      if fun.named?
        if fun.declared_as_static?
          sc_spec = fun_def.storage_class_specifier
          unless sc_spec && sc_spec.type == :STATIC
            W(fun_def.location, fun.name)
          end
        end
      end
    end
  end

  class W1076 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_explicit_function_defined += T(:define_function)
    end

    private
    def define_function(fun_def, fun)
      if fun.named? && fun.declared_as_static?
        anterior_dcls = fun.declarations_and_definitions.reject { |dcl|
          dcl == fun_def
        }
        if anterior_dcls.empty?
          W(fun_def.location, fun.name)
        end
      end
    end
  end

  class W1077 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_variable_declared += T(:check)
    end

    private
    def check(var_dcl, *)
      type = var_dcl.type
      begin
        if type.array?
          unless type.length
            W(var_dcl.location)
            break
          end
        else
          break
        end
      end while type = type.base_type
    end
  end

  class W9001 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @fpath = phase_ctxt[:sources].first.fpath
      visitor = phase_ctxt[:cc1_visitor]
      visitor.enter_error_statement           += T(:check)
      visitor.enter_generic_labeled_statement += T(:check)
      visitor.enter_case_labeled_statement    += T(:check)
      visitor.enter_default_labeled_statement += T(:check)
      visitor.enter_expression_statement      += T(:check)
      visitor.enter_if_statement              += T(:check)
      visitor.enter_if_else_statement         += T(:check)
      visitor.enter_switch_statement          += T(:check)
      visitor.enter_while_statement           += T(:check)
      visitor.enter_do_statement              += T(:check)
      visitor.enter_for_statement             += T(:check)
      visitor.enter_c99_for_statement         += T(:check)
      visitor.enter_goto_statement            += T(:check)
      visitor.enter_continue_statement        += T(:check)
      visitor.enter_break_statement           += T(:check)
      visitor.enter_return_statement          += T(:check)
    end

    private
    def check(node)
      if @fpath == node.location.fpath
        W(node.location) unless node.executed?
      end
    end
  end

  class W9003 < PassiveCodeCheck
    def_registrant_phase Cc1::Prepare2Phase

    include Cc1::InterpreterMediator
    include Cc1::Conversion

    # NOTE: All messages of cc1-phase code check should be unique till function
    #       step-in analysis is supported.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      @interp = phase_ctxt[:cc1_interpreter]
      @interp.on_implicit_conv_performed += T(:check)
    end

    private
    def check(init_or_expr, org_var, res_var)
      from_type = org_var.type
      to_type = res_var.type

      if from_type.undeclared? || from_type.unresolved? ||
          to_type.undeclared? || to_type.unresolved?
        return
      end

      case init_or_expr
      when Cc1::Initializer
        expr = init_or_expr.expression
        if expr && @interp.constant_expression?(expr)
          if untyped_pointer_conversion?(from_type, to_type, org_var.value)
            return
          end
        end
      when Cc1::Expression
        if @interp.constant_expression?(init_or_expr)
          if untyped_pointer_conversion?(from_type, to_type, org_var.value)
            return
          end
        end
      end

      unless from_type.standard? && to_type.standard?
        unless from_type.convertible?(to_type)
          W(init_or_expr.location, from_type.brief_image, to_type.brief_image)
        end
      end
    end

    def interpreter
      @interp
    end
  end

end
end
end
