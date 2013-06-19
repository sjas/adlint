# Controlling expression of selection-statements and iteration-statements.
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

require "adlint/cc1/syntax"
require "adlint/cc1/object"
require "adlint/cc1/mediator"
require "adlint/cc1/expr"
require "adlint/cc1/conv"
require "adlint/cc1/operator"
require "adlint/cc1/seqp"

module AdLint #:nodoc:
module Cc1 #:nodoc:

  # == DESCRIPTION
  # === Class structure
  #  ControllingExpression
  #  |
  #  +-> ValueDomainManipulator
  #      | <-- ValueDomainNarrower
  #      | <-- ValueDomainWidener
  #      | <-- NilValueDomainNarrower
  #      | <-- NilValueDomainWidener
  #      |
  #      +-> ValueDomainNarrowing
  #            <-- ValueComparison
  #            <-- LogicalAnd
  #            <-- LogicalOr
  #            <-- StrictObjectDerivation
  #            <-- DelayedObjectDerivation
  class ControllingExpression
    include SyntaxNodeCollector

    def initialize(interp, branch, target_expr = nil)
      @interpreter  = interp
      @branch       = branch
      @target_expr  = target_expr
      @manipulators = []
    end

    def ensure_true_by_narrowing(alt_expr = nil)
      target_expr = alt_expr || @target_expr

      if target_expr
        new_manip = ValueDomainNarrower.new(@interpreter, target_expr)
        if @branch.implicit_condition?
          eval_quietly { new_manip.prepare! }
        else
          new_manip.prepare!
        end
      else
        new_manip = NilValueDomainNarrower.new(@interpreter, @branch.group)
      end

      @manipulators.push(new_manip)
      new_manip
    end

    def ensure_true_by_widening(alt_expr = nil)
      target_expr = alt_expr || @target_expr

      if target_expr
        new_manip = ValueDomainWidener.new(@interpreter, target_expr)
        if @branch.implicit_condition?
          eval_quietly { new_manip.prepare! }
        else
          new_manip.prepare!
        end
      else
        new_manip = NilValueDomainWidener.new(@interpreter, @branch.group)
      end

      @manipulators.push(new_manip)
      new_manip
    end

    def undo(path_terminated)
      @manipulators.each { |manip| manip.rollback! } if path_terminated
    end

    def affected_variables
      @manipulators.map { |manip| manip.affected_variables }.flatten.uniq
    end

    def save_affected_variables
      @manipulators.each { |manip| manip.save! }
    end

    def restore_affected_variables
      @manipulators.each { |manip| manip.restore! }
    end

    def complexly_compounded?
      # NOTE: This method determines whether the controlling expression is too
      #       complex to thin value domains of controlling variables.
      @target_expr && !collect_logical_and_expressions(@target_expr).empty?
    end

    private
    def eval_quietly(&block)
      originally_quiet = @interpreter.quiet?
      if @branch.implicit_condition? && !originally_quiet
        @interpreter._quiet = true
      end
      yield
    ensure
      if @branch.implicit_condition? && !originally_quiet
        @interpreter._quiet = false
      end
    end
  end

  class ValueDomainManipulator < SyntaxTreeVisitor
    include InterpreterMediator
    include NotifierMediator
    include Conversion
    include ExpressionEvaluator::Impl
    include MonitorUtil

    def initialize(interp, target_expr)
      @interpreter        = interp
      @target_expr        = target_expr
      @affected_variables = []
      @narrowing          = nil
      @value_memory       = nil
    end

    attr_reader :interpreter
    attr_reader :affected_variables

    def prepare!
      if @target_expr
        @narrowing = @target_expr.accept(self)
        @narrowing.execute!
      end
    end

    def commit!
      if @narrowing
        @narrowing.ensure_result_equal_to(scalar_value_of_true)
      end

      commit_changes(@narrowing)

      if @narrowing
        @affected_variables = @narrowing.narrowed_values.keys
        @narrowing = nil
      end
    end

    def rollback!
      # NOTE: Rollback narrowed version to cut out the value-domain to enter
      #       the current branch.
      @affected_variables.each { |var| var.value.rollback! }
    end

    def save!
      @value_memory = {}
      @affected_variables.each do |var|
        @value_memory[var] = var.value.to_single_value.dup
      end
    end

    def restore!
      if @value_memory
        @value_memory.each { |var, saved_val| var.assign!(saved_val) }
        @value_memory = nil
      end
    end

    def self.def_strict_object_derivation(method_name)
      class_eval <<-EOS
        define_method("#{method_name}") do |*args|
          StrictObjectDerivation.new(self, args.first)
        end
      EOS
    end
    private_class_method :def_strict_object_derivation

    def_strict_object_derivation :visit_error_expression
    def_strict_object_derivation :visit_object_specifier
    def_strict_object_derivation :visit_constant_specifier
    def_strict_object_derivation :visit_string_literal_specifier
    def_strict_object_derivation :visit_null_constant_specifier

    def visit_array_subscript_expression(node)
      checkpoint(node.location)
      obj_manip  = node.expression.accept(self)
      subs_manip = node.array_subscript.accept(self)

      DelayedObjectDerivation.new(self, node, obj_manip, subs_manip) do
        checkpoint(node.location)
        obj_manip.execute!
        subs_manip.execute!
        eval_array_subscript_expr(node, obj_manip.result, subs_manip.result)
      end
    end

    def visit_function_call_expression(node)
      checkpoint(node.location)
      obj_manip  = node.expression.accept(self)
      arg_manips = node.argument_expressions.map { |expr| expr.accept(self) }

      DelayedObjectDerivation.new(self, node, obj_manip, *arg_manips) do
        checkpoint(node.location)
        obj_manip.execute!
        args = arg_manips.map { |m| m.execute!; [m.result, m.node] }
        eval_function_call_expr(node, obj_manip.result, args)
      end
    end

    def visit_member_access_by_value_expression(node)
      checkpoint(node.location)
      obj_manip = node.expression.accept(self)

      DelayedObjectDerivation.new(self, node, obj_manip) do
        checkpoint(node.location)
        obj_manip.execute!
        eval_member_access_by_value_expr(node, obj_manip.result)
      end
    end

    def visit_member_access_by_pointer_expression(node)
      checkpoint(node.location)
      obj_manip = node.expression.accept(self)

      DelayedObjectDerivation.new(self, node, obj_manip) do
        checkpoint(node.location)
        obj_manip.execute!
        eval_member_access_by_pointer_expr(node, obj_manip.result)
      end
    end

    def_strict_object_derivation :visit_bit_access_by_value_expression
    def_strict_object_derivation :visit_bit_access_by_pointer_expression

    def visit_postfix_increment_expression(node)
      checkpoint(node.location)
      obj_manip = node.operand.accept(self)

      DelayedObjectDerivation.new(self, node, obj_manip) do
        checkpoint(node.location)
        obj_manip.execute!
        eval_postfix_increment_expr(node, obj_manip.result)
      end
    end

    def visit_postfix_decrement_expression(node)
      checkpoint(node.location)
      obj_manip = node.operand.accept(self)

      DelayedObjectDerivation.new(self, node, obj_manip) do
        checkpoint(node.location)
        obj_manip.execute!
        eval_postfix_decrement_expr(node, obj_manip.result)
      end
    end

    def_strict_object_derivation :visit_compound_literal_expression

    def visit_prefix_increment_expression(node)
      checkpoint(node.location)
      obj_manip = node.operand.accept(self)

      DelayedObjectDerivation.new(self, node, obj_manip) do
        checkpoint(node.location)
        obj_manip.execute!
        eval_prefix_increment_expr(node, obj_manip.result)
      end
    end

    def visit_prefix_decrement_expression(node)
      checkpoint(node.location)
      obj_manip = node.operand.accept(self)

      DelayedObjectDerivation.new(self, node, obj_manip) do
        checkpoint(node.location)
        obj_manip.execute!
        eval_prefix_decrement_expr(node, obj_manip.result)
      end
    end

    def_strict_object_derivation :visit_address_expression

    def visit_indirection_expression(node)
      checkpoint(node.location)
      obj_manip = node.operand.accept(self)

      DelayedObjectDerivation.new(self, node, obj_manip) do
        checkpoint(node.location)
        obj_manip.execute!
        eval_indirection_expr(node, obj_manip.result)
      end
    end

    def visit_unary_arithmetic_expression(node)
      checkpoint(node.location)
      obj_manip = node.operand.accept(self)

      DelayedObjectDerivation.new(self, node, obj_manip) do
        checkpoint(node.location)
        obj_manip.execute!
        eval_unary_arithmetic_expr(node, obj_manip.result)
      end
    end

    def_strict_object_derivation :visit_sizeof_expression
    def_strict_object_derivation :visit_sizeof_type_expression
    def_strict_object_derivation :visit_alignof_expression
    def_strict_object_derivation :visit_alignof_type_expression

    def visit_cast_expression(node)
      checkpoint(node.location)
      obj_manip = node.operand.accept(self)

      DelayedObjectDerivation.new(self, node, obj_manip) do
        checkpoint(node.location)
        obj_manip.execute!
        eval_cast_expr(node, obj_manip.result)
      end
    end

    def visit_multiplicative_expression(node)
      checkpoint(node.location)
      lhs_manip = node.lhs_operand.accept(self)
      rhs_manip = node.rhs_operand.accept(self)

      DelayedObjectDerivation.new(self, node, lhs_manip, rhs_manip) do
        checkpoint(node.location)
        lhs_manip.execute!
        rhs_manip.execute!
        eval_multiplicative_expr(node, lhs_manip.result, rhs_manip.result)
      end
    end

    def visit_additive_expression(node)
      checkpoint(node.location)
      lhs_manip = node.lhs_operand.accept(self)
      rhs_manip = node.rhs_operand.accept(self)

      DelayedObjectDerivation.new(self, node, lhs_manip, rhs_manip) do
        checkpoint(node.location)
        lhs_manip.execute!
        rhs_manip.execute!
        eval_additive_expr(node, lhs_manip.result, rhs_manip.result)
      end
    end

    def visit_shift_expression(node)
      checkpoint(node.location)
      lhs_manip = node.lhs_operand.accept(self)
      rhs_manip = node.rhs_operand.accept(self)

      DelayedObjectDerivation.new(self, node, lhs_manip, rhs_manip) do
        checkpoint(node.location)
        lhs_manip.execute!
        rhs_manip.execute!
        eval_shift_expr(node, lhs_manip.result, rhs_manip.result)
      end
    end

    def visit_relational_expression(node)
      checkpoint(node.location)
      ValueComparison.new(self, node, node.lhs_operand.accept(self),
                          node.rhs_operand.accept(self))
    end

    def visit_equality_expression(node)
      checkpoint(node.location)
      ValueComparison.new(self, node, node.lhs_operand.accept(self),
                          node.rhs_operand.accept(self))
    end

    def visit_and_expression(node)
      checkpoint(node.location)
      lhs_manip = node.lhs_operand.accept(self)
      rhs_manip = node.rhs_operand.accept(self)

      DelayedObjectDerivation.new(self, node, lhs_manip, rhs_manip) do
        checkpoint(node.location)
        lhs_manip.execute!
        rhs_manip.execute!
        eval_and_expr(node, lhs_manip.result, rhs_manip.result)
      end
    end

    def visit_exclusive_or_expression(node)
      checkpoint(node.location)
      lhs_manip = node.lhs_operand.accept(self)
      rhs_manip = node.rhs_operand.accept(self)

      DelayedObjectDerivation.new(self, node, lhs_manip, rhs_manip) do
        checkpoint(node.location)
        lhs_manip.execute!
        rhs_manip.execute!
        eval_exclusive_or_expr(node, lhs_manip.result, rhs_manip.result)
      end
    end

    def visit_inclusive_or_expression(node)
      checkpoint(node.location)
      lhs_manip = node.lhs_operand.accept(self)
      rhs_manip = node.rhs_operand.accept(self)

      DelayedObjectDerivation.new(self, node, lhs_manip, rhs_manip) do
        checkpoint(node.location)
        lhs_manip.execute!
        rhs_manip.execute!
        eval_inclusive_or_expr(node, lhs_manip.result, rhs_manip.result)
      end
    end

    def visit_logical_and_expression(node)
      checkpoint(node.location)
      LogicalAnd.new(self, node, node.lhs_operand.accept(self),
                     node.rhs_operand.accept(self))
    end

    def visit_logical_or_expression(node)
      checkpoint(node.location)
      LogicalOr.new(self, node, node.lhs_operand.accept(self),
                    node.rhs_operand.accept(self))
    end

    def_strict_object_derivation :visit_conditional_expression

    def visit_simple_assignment_expression(node)
      checkpoint(node.location)
      lhs_manip = node.lhs_operand.accept(self)
      rhs_manip = node.rhs_operand.accept(self)

      DelayedObjectDerivation.new(self, node, lhs_manip, rhs_manip) do
        checkpoint(node.location)
        lhs_manip.execute!
        rhs_manip.execute!
        eval_simple_assignment_expr(node, lhs_manip.result, rhs_manip.result)
      end
    end

    def visit_compound_assignment_expression(node)
      checkpoint(node.location)
      lhs_manip = node.lhs_operand.accept(self)
      rhs_manip = node.rhs_operand.accept(self)

      DelayedObjectDerivation.new(self, node, lhs_manip, rhs_manip) do
        checkpoint(node.location)
        lhs_manip.execute!
        rhs_manip.execute!
        eval_compound_assignment_expr(node, lhs_manip.result, rhs_manip.result)
      end
    end

    def visit_comma_separated_expression(node)
      checkpoint(node.location)
      obj_manips = node.expressions.map { |expr| expr.accept(self) }

      DelayedObjectDerivation.new(self, node, *obj_manips) do
        checkpoint(node.location)
        obj_manips.map { |manip| manip.execute!; manip.result }.last
      end
    end

    private
    def commit_changes(manip)
      subclass_responsibility
    end

    extend Forwardable

    def_delegator :@interpreter, :monitor
    private :monitor
  end

  class ValueDomainNarrower < ValueDomainManipulator
    private
    def commit_changes(manip)
      manip.narrowed_values.each do |var, val|
        var.narrow_value_domain!(Operator::EQ, val)
      end
    end
  end

  class ValueDomainWidener < ValueDomainManipulator
    private
    def commit_changes(manip)
      manip.narrowed_values.each do |var, val|
        var.widen_value_domain!(Operator::EQ, val)
      end
    end
  end

  class NilValueDomainNarrower < ValueDomainManipulator
    def initialize(interp, branch_group)
      super(interp, nil)
      @branch_group = branch_group
    end

    def prepare!
      raise TypeError, "no preparation without expression."
    end

    private
    def commit_changes(*)
      @branch_group.all_controlling_variables.each do |var|
        var.narrow_value_domain!(Operator::EQ, var.type.arbitrary_value)
      end
      true
    end
  end

  class NilValueDomainWidener < ValueDomainManipulator
    def initialize(interp, branch_group)
      super(interp, nil)
      @branch_group = branch_group
    end

    def prepare!
      raise TypeError, "no preparation without expression."
    end

    private
    def commit_changes(*)
      @branch_group.all_controlling_variables.each do |var|
        var.widen_value_domain!(Operator::EQ, var.type.arbitrary_value)
      end
      true
    end
  end

  class ValueDomainNarrowing
    include InterpreterMediator
    include NotifierMediator
    include Conversion

    def initialize(manip, node, *children)
      @manipulator     = manip
      @node            = node
      @children        = children
      @original_values = {}
      @narrowed_values = {}
      @result          = nil
    end

    attr_reader :node
    attr_reader :narrowed_values
    attr_reader :result

    def load_original_values!(manip)
      @original_values = manip.narrowed_values
      @children.each { |child| child.load_original_values!(manip) }
    end

    def execute!
      @result = do_narrowing
      @children.each do |manip|
        @narrowed_values = manip.narrowed_values.merge(@narrowed_values)
      end
    ensure
      if @result && @result.variable?
        notify_variable_value_referred(node, @result)
      end
      if seqp = node.subsequent_sequence_point
        notify_sequence_point_reached(seqp)
      end
    end

    def ensure_result_equal_to(val)
      if @result.variable? && @result.designated_by_lvalue?
        if @result.value.scalar? && val.scalar?
          ensure_relation(@result, Operator::EQ, val)
        end
      end
    end

    protected
    attr_reader :original_values

    private
    def do_narrowing
      subclass_responsibility
    end

    def do_logical_arithmetic_conversion(node, lhs_var, rhs_var)
      lhs_conved, rhs_conved = do_usual_arithmetic_conversion(lhs_var, rhs_var)

      unless lhs_conved == lhs_var
        notify_implicit_conv_performed(node.lhs_operand, lhs_var, lhs_conved)
      end

      unless rhs_conved == rhs_var
        notify_implicit_conv_performed(node.rhs_operand, rhs_var, rhs_conved)
      end

      return lhs_conved, rhs_conved
    end

    def ensure_relation(var, op, val)
      # NOTE: To avoid over-narrowing.
      if val.definite? or var.value.contain?(val) && !val.contain?(var.value)
        target_val = save_original_value(var).dup
        target_val.narrow_domain!(op, val)
        update_narrowed_value(var, target_val)
      end
    end

    def save_original_value(var)
      @original_values[var.to_named_variable] ||= var.value.dup
    end

    def original_value_of(var)
      @original_values[var.to_named_variable]
    end

    def update_narrowed_value(var, new_val)
      @narrowed_values[var.to_named_variable] = new_val
    end

    def narrowing_merge!(lhs_manip, rhs_manip)
      lhs_vals = lhs_manip.narrowed_values
      rhs_vals = rhs_manip.narrowed_values

      @narrowed_values = lhs_vals.merge(rhs_vals) { |key, lhs_val, rhs_val|
        rslt_val = lhs_val.dup
        rslt_val.narrow_domain!(Operator::EQ, rhs_val)
        rslt_val
      }
    end

    def widening_merge!(lhs_manip, rhs_manip)
      lhs_vals = lhs_manip.narrowed_values
      rhs_vals = rhs_manip.narrowed_values

      @narrowed_values = lhs_vals.merge(rhs_vals) { |key, lhs_val, rhs_val|
        rslt_val = lhs_val.dup
        rslt_val.widen_domain!(Operator::EQ, rhs_val)
        rslt_val
      }
    end

    extend Forwardable

    def_delegator :@manipulator, :interpreter
    private :interpreter

    alias :_orig_interpret :interpret
    def interpret(node)
      case node
      when ObjectSpecifier
        if safely_evaluable_object_specifier?(node)
          _orig_interpret(node)
        else
          # NOTE: Nothing to do with an undeclared object.
          create_tmpvar
        end
      else
        _orig_interpret(node)
      end
    end

    def safely_evaluable_object_specifier?(obj_spec)
      variable_named(obj_spec.identifier.value) ||
        function_named(obj_spec.identifier.value) ||
        enumerator_named(obj_spec.identifier.value)
    end
  end

  class ValueComparison < ValueDomainNarrowing
    def initialize(manip, node, lhs_manip, rhs_manip)
      super
      @operator  = ComparisonOperator.new(node.operator)
      @lhs_manip = lhs_manip
      @rhs_manip = rhs_manip
    end

    private
    def do_narrowing
      @lhs_manip.execute!
      lhs_var = object_to_variable(@lhs_manip.result, @node.lhs_operand)

      @rhs_manip.execute!
      rhs_var = object_to_variable(@rhs_manip.result, @node.rhs_operand)

      unless lhs_var.type.scalar? && rhs_var.type.scalar?
        return create_tmpvar(int_t)
      end

      unless lhs_var.value.scalar? && rhs_var.value.scalar?
        return create_tmpvar(int_t)
      end

      lhs_conved, rhs_conved =
        do_logical_arithmetic_conversion(@node, lhs_var, rhs_var)

      lhs_val = lhs_conved.value
      rhs_val = rhs_conved.value

      case @operator
      when Operator::EQ
        rslt_var = create_tmpvar(int_t, lhs_val == rhs_val)
      when Operator::NE
        rslt_var = create_tmpvar(int_t, lhs_val != rhs_val)
      when Operator::LT
        rslt_var = create_tmpvar(int_t, lhs_val <  rhs_val)
      when Operator::GT
        rslt_var = create_tmpvar(int_t, lhs_val >  rhs_val)
      when Operator::LE
        rslt_var = create_tmpvar(int_t, lhs_val <= rhs_val)
      when Operator::GE
        rslt_var = create_tmpvar(int_t, lhs_val >= rhs_val)
      else
        __NOTREACHED__
      end

      notify_variable_value_referred(@node, lhs_var)
      notify_variable_value_referred(@node, rhs_var)

      case @operator
      when Operator::EQ, Operator::NE
        notify_equality_expr_evaled(@node, lhs_conved, rhs_conved, rslt_var)
      when Operator::LT, Operator::GT, Operator::LE, Operator::GE
        notify_relational_expr_evaled(@node, lhs_conved, rhs_conved, rslt_var)
      else
        __NOTREACHED__
      end

      case
      when lhs_conved.designated_by_lvalue?
        ensure_relation(lhs_conved, @operator, rhs_val)
      when rhs_conved.designated_by_lvalue?
        ensure_relation(rhs_conved, @operator.for_commutation, lhs_val)
      else
        # NOTE: Domain of the rvalue should not be narrowed.
      end

      rslt_var
    end
  end

  class LogicalAnd < ValueDomainNarrowing
    def initialize(manip, node, lhs_manip, rhs_manip)
      super
      @lhs_manip = lhs_manip
      @rhs_manip = rhs_manip
    end

    private
    def do_narrowing
      @lhs_manip.execute!
      @lhs_manip.ensure_result_equal_to(scalar_value_of_true)
      lhs_var = object_to_variable(@lhs_manip.result, @node.lhs_operand)

      # NOTE: The ISO C99 standard says;
      #
      # 6.5.13 Logical AND operator
      #
      # Semantics
      #
      # 4 Unlike the bitwise binary & operator, the && operator guarantees
      #   left-to-right evaluation; there is a sequence point after the
      #   evaluation of the first operand.  If the first operand compares equal
      #   to 0, the second operand is not evaluated.
      notify_sequence_point_reached(SequencePoint.new(@node.lhs_operand))

      # TODO: Must look about the short-circuit evaluation.
      @rhs_manip.load_original_values!(@lhs_manip)
      @rhs_manip.execute!
      @rhs_manip.ensure_result_equal_to(scalar_value_of_true)
      rhs_var = object_to_variable(@rhs_manip.result, @node.rhs_operand)

      notify_sequence_point_reached(SequencePoint.new(@node.rhs_operand))

      narrowing_merge!(@lhs_manip, @rhs_manip)
      notify_variable_value_referred(@node, lhs_var)
      notify_variable_value_referred(@node, rhs_var)

      unless lhs_var.type.scalar? && rhs_var.type.scalar?
        return create_tmpvar(int_t)
      end

      unless lhs_var.value.scalar? && rhs_var.value.scalar?
        return create_tmpvar(int_t)
      end

      lhs_conved, rhs_conved =
        do_logical_arithmetic_conversion(@node, lhs_var, rhs_var)

      lhs_val = lhs_conved.value
      rhs_val = rhs_conved.value

      rslt_var = create_tmpvar(int_t, lhs_val.logical_and(rhs_val))
      notify_logical_and_expr_evaled(@node, lhs_conved, rhs_conved, rslt_var)
      rslt_var
    end
  end

  class LogicalOr < ValueDomainNarrowing
    def initialize(manip, node, lhs_manip, rhs_manip)
      super
      @lhs_manip = lhs_manip
      @rhs_manip = rhs_manip
    end

    private
    def do_narrowing
      @lhs_manip.execute!
      @lhs_manip.ensure_result_equal_to(scalar_value_of_true)
      lhs_var = object_to_variable(@lhs_manip.result, @node.lhs_operand)

      # NOTE: The ISO C99 standard says;
      #
      # 6.5.14 Logical OR operator
      #
      # Semantics
      #
      # 4 Unlike the bitwise | operator, the || operator guarantees
      #   left-to-right evaluation; there is a sequence point after the
      #   evaluation of the first operand.  If the first operand compares
      #   unequal to 0, the second operand is not evaluated.
      notify_sequence_point_reached(SequencePoint.new(@node.lhs_operand))

      # TODO: Must look about the short-circuit evaluation.
      # FIXME: Base value of the RHS narrowing should be updated to ensure that
      #        the LHS condition is false.
      @rhs_manip.execute!
      @rhs_manip.ensure_result_equal_to(scalar_value_of_true)
      rhs_var = object_to_variable(@rhs_manip.result, @node.rhs_operand)

      notify_sequence_point_reached(SequencePoint.new(@node.rhs_operand))

      widening_merge!(@lhs_manip, @rhs_manip)
      notify_variable_value_referred(@node, lhs_var)
      notify_variable_value_referred(@node, rhs_var)

      unless lhs_var.type.scalar? && rhs_var.type.scalar?
        return create_tmpvar(int_t)
      end

      unless lhs_var.value.scalar? && rhs_var.value.scalar?
        return create_tmpvar(int_t)
      end

      lhs_conved, rhs_conved =
        do_logical_arithmetic_conversion(@node, lhs_var, rhs_var)

      lhs_val = lhs_conved.value
      rhs_val = rhs_conved.value

      rslt_var = create_tmpvar(int_t, lhs_val.logical_or(rhs_val))
      notify_logical_or_expr_evaled(@node, lhs_conved, rhs_conved, rslt_var)
      rslt_var
    end
  end

  class StrictObjectDerivation < ValueDomainNarrowing
    def initialize(manip, node)
      super(manip, node)
      @object = interpret(node)
    end

    private
    def do_narrowing
      if @object.variable? && @object.named?
        if orig_val = original_value_of(@object)
          @object = PhantomVariable.new(@object, orig_val)
        end
      end
      @object
    end
  end

  class DelayedObjectDerivation < ValueDomainNarrowing
    def initialize(manip, node, *children, &block)
      super(manip, node, *children)
      @block = block
    end

    private
    def do_narrowing
      @block.call
    end
  end

  class PhantomVariable < AliasVariable
    def initialize(named_var, phantom_val = nil)
      super(named_var)
      @base_var    = named_var
      @phantom_val = phantom_val ? phantom_val : named_var.memory.read.dup
    end

    def value
      @phantom_val
    end

    def assign!(val)
      @phantom_val = val
    end

    def to_named_variable
      @base_var.to_named_variable
    end

    def pretty_print(pp)
      Summary.new(object_id, name, type, @phantom_val).pretty_print(pp)
    end

    Summary = Struct.new(:object_id, :name, :type, :value)
  end

end
end
