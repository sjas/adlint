# C expression evaluator.
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

require "adlint/cc1/mediator"
require "adlint/cc1/const"
require "adlint/cc1/conv"
require "adlint/cc1/seqp"

module AdLint #:nodoc:
module Cc1 #:nodoc:

  module ExpressionEvaluator
    # NOTE: Host class of this module must include InterpreterMediator and
    #       MonitorUtil.

    include NotifierMediator
    include ConstantEvaluator
    include Conversion

    def visit_error_expression(node)
      checkpoint(node.location)
      create_tmpvar
    end

    def visit_object_specifier(node)
      checkpoint(node.location)
      eval_object_specifier(node)
    end

    def visit_constant_specifier(node)
      checkpoint(node.location)

      if const_var = eval_constant(node)
        notify_constant_referred(node, const_var)
        const_var
      else
        create_tmpvar
      end
    end

    def visit_string_literal_specifier(node)
      checkpoint(node.location)

      case node.literal.value
      when /\A"(.*)"\z/
        create_tmpvar(array_type(char_t, $1.length + 1),
                      create_array_value_of_string($1))
      when /\AL"(.*)"\z/i
        create_tmpvar(array_type(wchar_t, $1.length + 1),
                      create_array_value_of_string($1))
      else
        create_tmpvar(array_type(char_t))
      end
    end

    def visit_null_constant_specifier(node)
      checkpoint(node.location)
      # TODO: NULL may not be 0 on some environments.
      #       Representation of NULL should be configurable?
      create_tmpvar(pointer_type(void_t), scalar_value_of(0))
    end

    def visit_grouped_expression(node)
      checkpoint(node.location)
      node.expression.accept(self)
    end

    def visit_array_subscript_expression(node)
      checkpoint(node.location)
      eval_array_subscript_expr(node, node.expression.accept(self),
                                node.array_subscript.accept(self))
    end

    def visit_function_call_expression(node)
      checkpoint(node.location)
      args = node.argument_expressions.map { |expr| [expr.accept(self), expr] }
      eval_function_call_expr(node, node.expression.accept(self), args)
    end

    def visit_member_access_by_value_expression(node)
      checkpoint(node.location)
      eval_member_access_by_value_expr(node, node.expression.accept(self))
    end

    def visit_member_access_by_pointer_expression(node)
      checkpoint(node.location)
      eval_member_access_by_pointer_expr(node,node.expression.accept(self))
    end

    def visit_bit_access_by_value_expression(node)
      checkpoint(node.location)
      # TODO: Should support the GCC extension.
      create_tmpvar
    end

    def visit_bit_access_by_pointer_expression(node)
      checkpoint(node.location)
      # TODO: Should support the GCC extension.
      create_tmpvar
    end

    def visit_postfix_increment_expression(node)
      checkpoint(node.location)
      eval_postfix_increment_expr(node, node.operand.accept(self))
    end

    def visit_postfix_decrement_expression(node)
      checkpoint(node.location)
      eval_postfix_decrement_expr(node, node.operand.accept(self))
    end

    def visit_compound_literal_expression(node)
      checkpoint(node.location)
      # TODO: Should support C99 features.
      create_tmpvar(node.type_name.type)
    end

    def visit_prefix_increment_expression(node)
      checkpoint(node.location)
      eval_prefix_increment_expr(node, node.operand.accept(self))
    end

    def visit_prefix_decrement_expression(node)
      checkpoint(node.location)
      eval_prefix_decrement_expr(node, node.operand.accept(self))
    end

    def visit_address_expression(node)
      checkpoint(node.location)
      eval_address_expr(node, node.operand.accept(self))
    end

    def visit_indirection_expression(node)
      checkpoint(node.location)
      eval_indirection_expr(node, node.operand.accept(self))
    end

    def visit_unary_arithmetic_expression(node)
      checkpoint(node.location)
      eval_unary_arithmetic_expr(node, node.operand.accept(self))
    end

    def visit_sizeof_expression(node)
      checkpoint(node.location)

      ope_obj = rslt_var = nil
      eval_without_side_effect do
        rslt_type = type_of(UserTypeId.new("size_t")) || unsigned_long_t
        ope_obj = node.operand.accept(self)
        if ope_obj.variable?
          size = ope_obj.type.aligned_byte_size
          rslt_var = create_tmpvar(rslt_type, scalar_value_of(size))
        else
          return create_tmpvar(rslt_type)
        end
      end

      notify_sizeof_expr_evaled(node, ope_obj, rslt_var)
      rslt_var
    end

    def visit_sizeof_type_expression(node)
      checkpoint(node.location)
      resolve_unresolved_type(node.operand)

      rslt_var = nil
      eval_without_side_effect do
        rslt_type = type_of(UserTypeId.new("size_t")) || unsigned_long_t
        size = node.operand.type.aligned_byte_size
        rslt_var = create_tmpvar(rslt_type, scalar_value_of(size))
      end

      notify_sizeof_type_expr_evaled(node, node.operand.type, rslt_var)
      rslt_var
    end

    def visit_alignof_expression(node)
      checkpoint(node.location)

      eval_without_side_effect do
        rslt_type = type_of(UserTypeId.new("size_t")) || unsigned_long_t
        ope_obj = node.operand.accept(self)
        if ope_obj.variable?
          align = ope_obj.type.byte_alignment
          create_tmpvar(rslt_type, scalar_value_of(align))
        else
          create_tmpvar(rslt_type)
        end
      end
    end

    def visit_alignof_type_expression(node)
      checkpoint(node.location)
      resolve_unresolved_type(node.operand)

      eval_without_side_effect do
        rslt_type = type_of(UserTypeId.new("size_t")) || unsigned_long_t
        align = node.operand.type.aligned_byte_size
        create_tmpvar(rslt_type, scalar_value_of(align))
      end
    end

    def visit_cast_expression(node)
      checkpoint(node.location)
      eval_cast_expr(node, node.operand.accept(self))
    end

    def visit_multiplicative_expression(node)
      checkpoint(node.location)
      eval_multiplicative_expr(node, node.lhs_operand.accept(self),
                               node.rhs_operand.accept(self))
    end

    def visit_additive_expression(node)
      checkpoint(node.location)
      eval_additive_expr(node, node.lhs_operand.accept(self),
                         node.rhs_operand.accept(self))
    end

    def visit_shift_expression(node)
      checkpoint(node.location)
      eval_shift_expr(node, node.lhs_operand.accept(self),
                      node.rhs_operand.accept(self))
    end

    def visit_relational_expression(node)
      checkpoint(node.location)
      eval_relational_expr(node, node.lhs_operand.accept(self),
                           node.rhs_operand.accept(self))
    end

    def visit_equality_expression(node)
      checkpoint(node.location)
      eval_equality_expr(node, node.lhs_operand.accept(self),
                         node.rhs_operand.accept(self))
    end

    def visit_and_expression(node)
      checkpoint(node.location)
      eval_and_expr(node, node.lhs_operand.accept(self),
                    node.rhs_operand.accept(self))
    end

    def visit_exclusive_or_expression(node)
      checkpoint(node.location)
      eval_exclusive_or_expr(node, node.lhs_operand.accept(self),
                             node.rhs_operand.accept(self))
    end

    def visit_inclusive_or_expression(node)
      checkpoint(node.location)
      eval_inclusive_or_expr(node, node.lhs_operand.accept(self),
                             node.rhs_operand.accept(self))
    end

    def visit_logical_and_expression(node)
      checkpoint(node.location)

      lhs_obj = node.lhs_operand.accept(self)
      if lhs_obj.variable?
        lhs_var = lhs_obj
      else
        return create_tmpvar(int_t)
      end

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
      notify_sequence_point_reached(SequencePoint.new(node.lhs_operand))
      lhs_val = lhs_var.value

      if lhs_val.scalar? && lhs_val.must_be_false?
        # NOTE: Doing the short-circuit evaluation.
        notify_variable_value_referred(node, lhs_var)
        return create_tmpvar(int_t, scalar_value_of_false)
      end

      rhs_obj = node.rhs_operand.accept(self)
      if rhs_obj.variable?
        rhs_var = rhs_obj
      else
        return create_tmpvar(int_t)
      end

      notify_sequence_point_reached(SequencePoint.new(node.rhs_operand))
      rhs_val = rhs_var.value

      if lhs_val.scalar? && rhs_val.scalar?
        # NOTE: No usual-arithmetic-conversion.
        rslt_var = create_tmpvar(int_t, lhs_val.logical_and(rhs_val))
      else
        rslt_var = create_tmpvar(int_t)
      end
      notify_variable_value_referred(node, lhs_var)
      notify_variable_value_referred(node, rhs_var)

      notify_logical_and_expr_evaled(node, lhs_var, rhs_var, rslt_var)
      rslt_var
    end

    def visit_logical_or_expression(node)
      checkpoint(node.location)

      lhs_obj = node.lhs_operand.accept(self)
      if lhs_obj.variable?
        lhs_var = lhs_obj
      else
        return create_tmpvar(int_t)
      end

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
      notify_sequence_point_reached(SequencePoint.new(node.lhs_operand))
      lhs_val = lhs_var.value

      if lhs_val.scalar? && lhs_val.must_be_true?
        # NOTE: Doing the short-circuit evaluation.
        notify_variable_value_referred(node, lhs_var)
        return create_tmpvar(int_t, scalar_value_of_true)
      end

      rhs_obj = node.rhs_operand.accept(self)
      if rhs_obj.variable?
        rhs_var = rhs_obj
      else
        return create_tmpvar(int_t)
      end

      notify_sequence_point_reached(SequencePoint.new(node.rhs_operand))
      rhs_val = rhs_var.value

      if lhs_val.scalar? && rhs_val.scalar?
        # NOTE: No usual-arithmetic-conversion.
        rslt_var = create_tmpvar(int_t, lhs_val.logical_or(rhs_val))
      else
        rslt_var = create_tmpvar(int_t)
      end
      notify_variable_value_referred(node, lhs_var)
      notify_variable_value_referred(node, rhs_var)

      notify_logical_or_expr_evaled(node, lhs_var, rhs_var, rslt_var)
      rslt_var
    end

    def visit_simple_assignment_expression(node)
      checkpoint(node.location)
      eval_simple_assignment_expr(node, node.lhs_operand.accept(self),
                                  node.rhs_operand.accept(self))
    end

    def visit_compound_assignment_expression(node)
      checkpoint(node.location)
      eval_compound_assignment_expr(node, node.lhs_operand.accept(self),
                                    node.rhs_operand.accept(self))
    end

    def visit_comma_separated_expression(node)
      checkpoint(node.location)
      node.expressions.map { |expr| expr.accept(self) }.last
    end

    private
    def eval_without_side_effect(&block)
      originally_quiet = interpreter.quiet_without_side_effect?
      unless originally_quiet
        interpreter._quiet_without_side_effect = true
      end
      yield
    ensure
      unless originally_quiet
        interpreter._quiet_without_side_effect = false
        # FIXME: Evaluation of an object-specifier doesn't refer to value
        #        of a variable.  Thus, no cross-reference record on a
        #        sizeof-expression because cross-reference extraction
        #        watches variable value reference not variable reference.
        # collect_object_specifiers(node).each { |os| os.accept(self) }
      end
    end

    def create_array_value_of_string(str)
      ArrayValue.new(str.chars.map { |ch| scalar_value_of(ch.ord) } +
                     [scalar_value_of("\0".ord)])
    end

    module Impl
      # NOTE: Host class of this module must include InterpreterMediator,
      #       NotifierMediator and Conversion.

      def eval_object_specifier(node)
        if var = variable_named(node.identifier.value)
          var.declarations_and_definitions.each do |dcl_or_def|
            dcl_or_def.mark_as_referred_by(node.identifier)
          end
          _notify_object_referred(node, var)
          # NOTE: Array object will be converted into its start address by the
          #       outer expression.  So, it is correct to return an array
          #       object itself.
          return var
        end

        if fun = function_named(node.identifier.value)
          fun.declarations_and_definitions.each do |dcl_or_def|
            dcl_or_def.mark_as_referred_by(node.identifier)
          end
          _notify_object_referred(node, fun)
          return fun
        end

        if enum = enumerator_named(node.identifier.value)
          enum.mark_as_referred_by(node.identifier)
          return create_tmpvar(enum.type, scalar_value_of(enum.value))
        end

        fun = declare_implicit_function(node.identifier.value)
        _notify_implicit_function_declared(node, fun)
        _notify_object_referred(node, fun)
        fun
      end

      def eval_array_subscript_expr(node, obj, subs)
        unless obj.variable? and obj.type.array? || obj.type.pointer?
          return create_tmpvar
        end

        rslt_type = obj.type.unqualify.base_type

        case
        when obj.type.array?
          ary = obj
          # NOTE: An array-subscript-expression with an array object only
          #       refers the array object, never refer the value of the array
          #       object.
        when obj.type.pointer?
          ptr = obj
          if pointee = pointee_of(ptr) and pointee.type.array?
            ary = pointee
          end
          # NOTE: An array-subscript-expression with a pointer object do refers
          #       the value of the pointer object.
          _notify_variable_value_referred(node, ptr)
        end

        unless subs.variable? and
            subs.value.scalar? && subs.value.exist? or subs.type.void?
          # NOTE: To detect bad value reference of `void' expressions.
          return create_tmpvar(rslt_type)
        end
        _notify_variable_value_referred(node, subs)

        # NOTE: An array subscript converted to `int' implicitly.
        unless subs.type.same_as?(int_t)
          if int_subs = do_conversion(subs, int_t)
            notify_implicit_conv_performed(node.array_subscript,
                                           subs, int_subs)
            subs = int_subs
          else
            return create_tmpvar(rslt_type)
          end
        end

        rslt_var = _pick_array_element(ary, subs, rslt_type)
        _notify_object_referred(node, rslt_var)

        notify_array_subscript_expr_evaled(node, obj, subs, ary, rslt_var)
        rslt_var
      end

      def eval_function_call_expr(node, obj, args)
        if obj.function?
          fun = obj
        else
          return create_tmpvar unless obj.type.pointer?
          obj_base_type = obj.type.unqualify.base_type
          if obj_base_type.function?
            if pointee = pointee_of(obj) and pointee.function?
              fun = pointee
            else
              fun = define_anonymous_function(obj_base_type)
            end
          end
        end
        _notify_variable_value_referred(node, obj)

        # NOTE: The ISO C99 standard says;
        #
        # 6.5.2.2 Function calls
        #
        # Semantics
        #
        # 10 The order of evaluation of the function designator, the actual
        #    arguments, and subexpressions within the actual arguments is
        #    unspecified, but there is a sequence point before the actual call.
        unless args.empty?
          notify_sequence_point_reached(SequencePoint.new(node))
        end

        rslt_var = nil
        break_event = BreakEvent.catch {
          rslt_var = fun.call(interpreter, node, args)
        }

        unless fun.builtin?
          arg_vars = args.map { |arg_obj, arg_expr|
            object_to_variable(arg_obj, arg_expr)
          }
          notify_function_call_expr_evaled(node, fun, arg_vars, rslt_var)
        end

        if break_event
          break_event.throw
        else
          rslt_var
        end
      end

      def eval_member_access_by_value_expr(node, obj)
        if obj.variable? && obj.type.composite?
          outer_var = obj
        else
          return create_tmpvar
        end

        memb_var = outer_var.inner_variable_named(node.identifier.value)
        # NOTE: A member-access-by-value-expression only refers the composite
        #       object, never refer the value of the composite object.

        # NOTE: `memb_var' is nil when this expression represents the direct
        #       member access extension.
        notify_member_access_expr_evaled(node, outer_var, memb_var)

        if memb_var
          _notify_object_referred(node, memb_var)
          memb_var
        else
          create_tmpvar
        end
      end

      def eval_member_access_by_pointer_expr(node, obj)
        obj_type = obj.type.unqualify
        if obj.variable? && obj_type.pointer? && obj_type.base_type.composite?
          ptr = obj
        else
          return create_tmpvar
        end

        if pointee = pointee_of(ptr)
          if pointee.type.array?
            if first_elem = pointee.inner_variable_at(0)
              pointee = first_elem
            else
              pointee = create_tmpvar(obj_type.base_type)
            end
          end
        end
        # NOTE: A member-access-by-pointer-expression do refers the value of
        #       the pointer object.
        _notify_variable_value_referred(node, ptr)

        if pointee && pointee.type.composite?
          outer_var = pointee
          memb_var = outer_var.inner_variable_named(node.identifier.value)
        else
          if memb = obj_type.base_type.member_named(node.identifier.value)
            memb_var = create_tmpvar(memb.type)
          end
        end

        # NOTE: `memb_var' is nil when this expression represents the direct
        #       member access extension.
        notify_member_access_expr_evaled(node, ptr, memb_var)

        if memb_var
          _notify_object_referred(node, memb_var)
          memb_var
        else
          create_tmpvar
        end
      end

      def eval_postfix_increment_expr(node, obj)
        var = object_to_variable(obj, node)
        if !var.type.scalar? && !var.type.void?
          # NOTE: To detect bad value reference of `void' expressions.
          return create_tmpvar
        end

        rslt_var = create_tmpvar(var.type, var.value.dup)

        # NOTE: Value of the variable is referred at this point.  But value
        #       reference should not be notified not to confuse sequence-point
        #       warning detections.
        # _notify_variable_value_referred(node, var)

        if var.value.scalar?
          var.assign!(var.value + scalar_value_of(1))
          _notify_variable_value_updated(node, var)
        end

        notify_postfix_increment_expr_evaled(node, var, rslt_var)
        rslt_var
      end

      def eval_postfix_decrement_expr(node, obj)
        var = object_to_variable(obj, node)
        if !var.type.scalar? && !var.type.void?
          # NOTE: To detect bad value reference of `void' expressions.
          return create_tmpvar
        end

        rslt_var = create_tmpvar(var.type, var.value.dup)

        # NOTE: Value of the variable is referred at this point.  But value
        #       reference should not be notified not to confuse sequence-point
        #       warnings detections.
        # _notify_variable_value_referred(node, var)

        if var.value.scalar?
          var.assign!(var.value - scalar_value_of(1))
          _notify_variable_value_updated(node, var)
        end

        notify_postfix_decrement_expr_evaled(node, var, rslt_var)
        rslt_var
      end

      def eval_prefix_increment_expr(node, obj)
        var = object_to_variable(obj, node)
        if !var.type.scalar? && !var.type.void?
          # NOTE: To detect bad value reference of `void' expressions.
          return create_tmpvar
        end

        orig_val = var.value.dup

        # NOTE: Value of the variable is referred at this point.  But value
        #       reference should not be notified not to confuse sequence-point
        #       warnings detections.
        # _notify_variable_value_referred(node, var)

        if var.value.scalar?
          var.assign!(var.value + scalar_value_of(1))
          _notify_variable_value_updated(node, var)
        end

        notify_prefix_increment_expr_evaled(node, var, orig_val)
        create_tmpvar(var.type, var.value)
      end

      def eval_prefix_decrement_expr(node, obj)
        var = object_to_variable(obj, node)
        if !var.type.scalar? && !var.type.void?
          # NOTE: To detect bad value reference of `void' expressions.
          return create_tmpvar
        end

        orig_val = var.value.dup

        # NOTE: Value of the variable is referred at this point.  But value
        #       reference should not be notified not to confuse sequence-point
        #       warning detections.
        # _notify_variable_value_referred(node, var)

        if var.value.scalar?
          var.assign!(var.value - scalar_value_of(1))
          _notify_variable_value_updated(node, var)
        end

        notify_prefix_decrement_expr_evaled(node, var, orig_val)
        create_tmpvar(var.type, var.value)
      end

      def eval_address_expr(node, obj)
        # NOTE: An address-expression does not read the value of the object.
        #       But value reference should be notified to emphasize global
        #       variable cross-references.
        _notify_variable_value_referred(node, obj)

        ptr = object_to_pointer(obj, node)
        notify_address_expr_evaled(node, obj, ptr)
        ptr
      end

      def eval_indirection_expr(node, obj)
        var = object_to_variable(obj, node)
        if var.type.pointer?
          ptr = var
        else
          return create_tmpvar
        end

        pointee = pointee_of(ptr)
        _notify_variable_value_referred(node, ptr)

        ptr_base_type = ptr.type.unqualify.base_type

        case
        when pointee
          _notify_object_referred(node, pointee)
          if pointee.type.array?
            if first_elem = pointee.inner_variable_at(0)
              pointee = first_elem
            else
              pointee = create_tmpvar(ptr_base_type)
            end
          end

          unless ptr_base_type.same_as?(pointee.type)
            pointee = do_conversion(pointee, ptr_base_type) ||
                      create_tmpvar(ptr_base_type)
          end
        when ptr_base_type.function?
          pointee = define_anonymous_function(ptr_base_type)
        else
          pointee = create_tmpvar(ptr_base_type)
        end

        notify_indirection_expr_evaled(node, ptr, pointee)
        pointee
      end

      def eval_unary_arithmetic_expr(node, obj)
        var = object_to_variable(obj, node)
        if !var.type.scalar? && !var.type.void?
          # NOTE: To detect bad value reference of `void' expressions.
          return create_tmpvar
        end

        case node.operator.type
        when "+"
          rslt_var = create_tmpvar(var.type, +var.value)
        when "-"
          rslt_var = create_tmpvar(var.type, -var.value)
        when "~"
          rslt_var = create_tmpvar(var.type, ~var.value)
        when "!"
          rslt_var = create_tmpvar(int_t, !var.value)
        else
          __NOTREACHED__
        end
        _notify_variable_value_referred(node, var)

        notify_unary_arithmetic_expr_evaled(node, var, rslt_var)
        rslt_var
      end

      def eval_cast_expr(node, obj)
        resolve_unresolved_type(node.type_name)

        var = object_to_variable(obj, node)
        rslt_var = do_conversion(var, node.type_name.type) ||
                   create_tmpvar(node.type_name.type)

        notify_explicit_conv_performed(node, var, rslt_var)

        # NOTE: A cast-expression does not refer a source value essentially.
        #       But, to avoid misunderstand that a return value of a function
        #       is discarded when the return value is casted before assigning
        #       to a variable.
        _notify_variable_value_referred(node, var)
        rslt_var
      end

      def eval_multiplicative_expr(node, lhs_obj, rhs_obj)
        lhs_var = object_to_variable(lhs_obj, node.lhs_operand)
        if !lhs_var.type.scalar? && !lhs_var.type.void?
          # NOTE: To detect bad value reference of `void' expressions.
          return create_tmpvar
        end

        rhs_var = object_to_variable(rhs_obj, node.rhs_operand)
        if !rhs_var.type.scalar? && !rhs_var.type.void?
          # NOTE: To detect bad value reference of `void' expressions.
          return create_tmpvar
        end

        lhs_conved, rhs_conved =
          do_usual_arithmetic_conversion(lhs_var, rhs_var)

        unless lhs_conved == lhs_var
          notify_implicit_conv_performed(node.lhs_operand, lhs_var, lhs_conved)
        end
        unless rhs_conved == rhs_var
          notify_implicit_conv_performed(node.rhs_operand, rhs_var, rhs_conved)
        end

        lhs_val = lhs_conved.value
        rhs_val = rhs_conved.value

        case node.operator.type
        when "*"
          # NOTE: Domain of the arithmetic result value will be restricted by
          #       min-max of the variable type.
          rslt_var = create_tmpvar(lhs_conved.type, lhs_val * rhs_val)
        when "/"
          # NOTE: Domain of the arithmetic result value will be restricted by
          #       min-max of the variable type.
          # NOTE: "Div by 0" semantics is implemented in value-value
          #       arithmetic.
          rslt_var = create_tmpvar(lhs_conved.type, lhs_val / rhs_val)
        when "%"
          # NOTE: Domain of the arithmetic result value will be restricted by
          #       min-max of the variable type.
          # NOTE: "Div by 0" semantics is implemented in value-value
          #       arithmetic.
          rslt_var = create_tmpvar(lhs_conved.type, lhs_val % rhs_val)
        else
          __NOTREACHED__
        end
        _notify_variable_value_referred(node, lhs_var)
        _notify_variable_value_referred(node, rhs_var)

        notify_multiplicative_expr_evaled(node, lhs_var, rhs_var, rslt_var)
        rslt_var
      end

      def eval_additive_expr(node, lhs_obj, rhs_obj)
        lhs_var = object_to_variable(lhs_obj, node.lhs_operand)
        if !lhs_var.type.scalar? && !lhs_var.type.void?
          # NOTE: To detect bad value reference of `void' expressions.
          return create_tmpvar
        end

        rhs_var = object_to_variable(rhs_obj, node.rhs_operand)
        if !rhs_var.type.scalar? && !rhs_var.type.void?
          # NOTE: To detect bad value reference of `void' expressions.
          return create_tmpvar
        end

        lhs_conved, rhs_conved =
          do_usual_arithmetic_conversion(lhs_var, rhs_var)

        unless lhs_conved == lhs_var
          notify_implicit_conv_performed(node.lhs_operand, lhs_var, lhs_conved)
        end
        unless rhs_conved == rhs_var
          notify_implicit_conv_performed(node.rhs_operand, rhs_var, rhs_conved)
        end

        lhs_val = lhs_conved.value
        rhs_val = rhs_conved.value

        case node.operator.type
        when "+"
          # NOTE: Domain of the arithmetic result value will be restricted by
          #       min-max of the variable type.
          rslt_var = create_tmpvar(lhs_conved.type, lhs_val + rhs_val)
        when "-"
          # NOTE: Domain of the arithmetic result value will be restricted by
          #       min-max of the variable type.
          rslt_var = create_tmpvar(lhs_conved.type, lhs_val - rhs_val)
        else
          __NOTREACHED__
        end
        _notify_variable_value_referred(node, lhs_var)
        _notify_variable_value_referred(node, rhs_var)

        notify_additive_expr_evaled(node, lhs_var, rhs_var, rslt_var)
        rslt_var
      end

      def eval_shift_expr(node, lhs_obj, rhs_obj)
        lhs_var = object_to_variable(lhs_obj, node.lhs_operand)
        if !lhs_var.type.scalar? && !lhs_var.type.void?
          # NOTE: To detect bad value reference of `void' expressions.
          return create_tmpvar
        end

        rhs_var = object_to_variable(rhs_obj, node.rhs_operand)
        if !rhs_var.type.scalar? && !rhs_var.type.void?
          # NOTE: To detect bad value reference of `void' expressions.
          return create_tmpvar
        end

        # NOTE: The ISO C99 standard says;
        #
        # 6.5.7 Bitwise shift operators
        #
        # 3 The integer promotions are performed on each of the operands.  The
        #   type of the result is that of the promoted left operand.  If the
        #   value of the right operand is negative or is greater than or equal
        #   to the width of the promoted left operand, the behavior is
        #   undefined.

        lhs_conved = do_integer_promotion(lhs_var)
        rhs_conved = do_integer_promotion(rhs_var)

        unless lhs_conved == lhs_var
          notify_implicit_conv_performed(node.lhs_operand, lhs_var, lhs_conved)
        end
        unless rhs_conved == rhs_var
          notify_implicit_conv_performed(node.rhs_operand, rhs_var, rhs_conved)
        end

        lhs_val = lhs_conved.value
        rhs_val = rhs_conved.value

        case node.operator.type
        when "<<"
          # NOTE: Domain of the arithmetic result value will be restricted by
          #       min-max of the variable type.
          rslt_var = create_tmpvar(lhs_conved.type, lhs_val << rhs_val)
        when ">>"
          # NOTE: Domain of the arithmetic result value will be restricted by
          #       min-max of the variable type.
          rslt_var = create_tmpvar(lhs_conved.type, lhs_val >> rhs_val)
        else
          __NOTREACHED__
        end
        _notify_variable_value_referred(node, lhs_var)
        _notify_variable_value_referred(node, rhs_var)

        notify_shift_expr_evaled(node, lhs_var, rhs_var, rslt_var)
        rslt_var
      end

      def eval_relational_expr(node, lhs_obj, rhs_obj)
        lhs_var = object_to_variable(lhs_obj, node.lhs_operand)
        if !lhs_var.type.scalar? && !lhs_var.type.void?
          # NOTE: To detect bad value reference of `void' expressions.
          return create_tmpvar(int_t, scalar_value_of_arbitrary)
        end

        rhs_var = object_to_variable(rhs_obj, node.rhs_operand)
        if !rhs_var.type.scalar? && !rhs_var.type.void?
          # NOTE: To detect bad value reference of `void' expressions.
          return create_tmpvar(int_t, scalar_value_of_arbitrary)
        end

        lhs_conved, rhs_conved =
          do_usual_arithmetic_conversion(lhs_var, rhs_var)

        unless lhs_conved == lhs_var
          notify_implicit_conv_performed(node.lhs_operand, lhs_var, lhs_conved)
        end
        unless rhs_conved == rhs_var
          notify_implicit_conv_performed(node.rhs_operand, rhs_var, rhs_conved)
        end

        lhs_val = lhs_conved.value
        rhs_val = rhs_conved.value

        case node.operator.type
        when "<"
          rslt_var = create_tmpvar(int_t, lhs_val <  rhs_val)
        when ">"
          rslt_var = create_tmpvar(int_t, lhs_val >  rhs_val)
        when "<="
          rslt_var = create_tmpvar(int_t, lhs_val <= rhs_val)
        when ">="
          rslt_var = create_tmpvar(int_t, lhs_val >= rhs_val)
        else
          __NOTREACHED__
        end
        _notify_variable_value_referred(node, lhs_var)
        _notify_variable_value_referred(node, rhs_var)

        notify_relational_expr_evaled(node, lhs_var, rhs_var, rslt_var)
        rslt_var
      end

      def eval_equality_expr(node, lhs_obj, rhs_obj)
        lhs_var = object_to_variable(lhs_obj, node.lhs_operand)
        if !lhs_var.type.scalar? && !lhs_var.type.void?
          # NOTE: To detect bad value reference of `void' expressions.
          return create_tmpvar(int_t, scalar_value_of_arbitrary)
        end

        rhs_var = object_to_variable(rhs_obj, node.rhs_operand)
        if !rhs_var.type.scalar? && !rhs_var.type.void?
          # NOTE: To detect bad value reference of `void' expressions.
          return create_tmpvar(int_t, scalar_value_of_arbitrary)
        end

        lhs_conved, rhs_conved =
          do_usual_arithmetic_conversion(lhs_var, rhs_var)

        unless lhs_conved == lhs_var
          notify_implicit_conv_performed(node.lhs_operand, lhs_var, lhs_conved)
        end
        unless rhs_conved == rhs_var
          notify_implicit_conv_performed(node.rhs_operand, rhs_var, rhs_conved)
        end

        lhs_val = lhs_conved.value
        rhs_val = rhs_conved.value

        case node.operator.type
        when "=="
          rslt_var = create_tmpvar(int_t, lhs_val == rhs_val)
        when "!="
          rslt_var = create_tmpvar(int_t, lhs_val != rhs_val)
        else
          __NOTREACHED__
        end
        _notify_variable_value_referred(node, lhs_var)
        _notify_variable_value_referred(node, rhs_var)

        notify_equality_expr_evaled(node, lhs_var, rhs_var, rslt_var)
        rslt_var
      end

      def eval_and_expr(node, lhs_obj, rhs_obj)
        lhs_var = object_to_variable(lhs_obj, node.lhs_operand)
        if !lhs_var.type.scalar? && !lhs_var.type.void?
          # NOTE: To detect bad value reference of `void' expressions.
          return create_tmpvar
        end

        rhs_var = object_to_variable(rhs_obj, node.rhs_operand)
        if !rhs_var.type.scalar? && !rhs_var.type.void?
          # NOTE: To detect bad value reference of `void' expressions.
          return create_tmpvar
        end

        lhs_conved, rhs_conved =
          do_usual_arithmetic_conversion(lhs_var, rhs_var)

        unless lhs_conved == lhs_var
          notify_implicit_conv_performed(node.lhs_operand, lhs_var, lhs_conved)
        end
        unless rhs_conved == rhs_var
          notify_implicit_conv_performed(node.rhs_operand, rhs_var, rhs_conved)
        end

        lhs_val = lhs_conved.value
        rhs_val = rhs_conved.value

        # NOTE: Domain of the arithmetic result value will be restricted by
        #       min-max of the variable type.
        rslt_var = create_tmpvar(lhs_conved.type, lhs_val & rhs_val)
        _notify_variable_value_referred(node, lhs_var)
        _notify_variable_value_referred(node, rhs_var)

        notify_and_expr_evaled(node, lhs_var, rhs_var, rslt_var)
        rslt_var
      end

      def eval_exclusive_or_expr(node, lhs_obj, rhs_obj)
        lhs_var = object_to_variable(lhs_obj, node.lhs_operand)
        if !lhs_var.type.scalar? && !lhs_var.type.void?
          # NOTE: To detect bad value reference of `void' expressions.
          return create_tmpvar
        end

        rhs_var = object_to_variable(rhs_obj, node.rhs_operand)
        if !rhs_var.type.scalar? && !rhs_var.type.void?
          # NOTE: To detect bad value reference of `void' expressions.
          return create_tmpvar
        end

        lhs_conved, rhs_conved =
          do_usual_arithmetic_conversion(lhs_var, rhs_var)

        unless lhs_conved == lhs_var
          notify_implicit_conv_performed(node.lhs_operand, lhs_var, lhs_conved)
        end
        unless rhs_conved == rhs_var
          notify_implicit_conv_performed(node.rhs_operand, rhs_var, rhs_conved)
        end

        lhs_val = lhs_conved.value
        rhs_val = rhs_conved.value

        # NOTE: Domain of the arithmetic result value will be restricted by
        #       min-max of the variable type.
        rslt_var = create_tmpvar(lhs_conved.type, lhs_val ^ rhs_val)
        _notify_variable_value_referred(node, lhs_var)
        _notify_variable_value_referred(node, rhs_var)

        notify_exclusive_or_expr_evaled(node, lhs_var, rhs_var, rslt_var)
        rslt_var
      end

      def eval_inclusive_or_expr(node, lhs_obj, rhs_obj)
        lhs_var = object_to_variable(lhs_obj, node.lhs_operand)
        if !lhs_var.type.scalar? && !lhs_var.type.void?
          # NOTE: To detect bad value reference of `void' expressions.
          return create_tmpvar
        end

        rhs_var = object_to_variable(rhs_obj, node.rhs_operand)
        if !rhs_var.type.scalar? && !rhs_var.type.void?
          # NOTE: To detect bad value reference of `void' expressions.
          return create_tmpvar
        end

        lhs_conved, rhs_conved =
          do_usual_arithmetic_conversion(lhs_var, rhs_var)

        unless lhs_conved == lhs_var
          notify_implicit_conv_performed(node.lhs_operand, lhs_var, lhs_conved)
        end
        unless rhs_conved == rhs_var
          notify_implicit_conv_performed(node.rhs_operand, rhs_var, rhs_conved)
        end

        lhs_val = lhs_conved.value
        rhs_val = rhs_conved.value

        # NOTE: Domain of the arithmetic result value will be restricted by
        #       min-max of the variable type.
        rslt_var = create_tmpvar(lhs_conved.type, lhs_val | rhs_val)
        _notify_variable_value_referred(node, lhs_var)
        _notify_variable_value_referred(node, rhs_var)

        notify_inclusive_or_expr_evaled(node, lhs_var, rhs_var, rslt_var)
        rslt_var
      end

      def eval_simple_assignment_expr(node, lhs_obj, rhs_obj)
        lhs_var = object_to_variable(lhs_obj, node.lhs_operand)
        rhs_var = object_to_variable(rhs_obj, node.rhs_operand)

        if rhs_var.type.same_as?(lhs_var.type)
          rhs_conved = rhs_var
        else
          rhs_conved = do_conversion(rhs_var, lhs_var.type) ||
                       create_tmpvar(lhs_var.type)
          notify_implicit_conv_performed(node.rhs_operand, rhs_var, rhs_conved)
        end

        # NOTE: Domain of the arithmetic result value will be restricted by
        #       min-max of the variable type.
        # NOTE: Even if rhs_obj is a NamedVariable, new value will be
        #       instantiated in value-coercing.
        #       So, value-aliasing never occurs.
        lhs_var.assign!(rhs_conved.value.to_defined_value)
        _notify_variable_value_referred(node, rhs_var)
        _notify_variable_value_updated(node, lhs_var)

        notify_assignment_expr_evaled(node, lhs_var, rhs_var)
        lhs_var
      end

      def eval_compound_assignment_expr(node, lhs_obj, rhs_obj)
        lhs_var = object_to_variable(lhs_obj, node.lhs_operand)
        if !lhs_var.type.scalar? && !lhs_var.type.void?
          # NOTE: To detect bad value reference of `void' expressions.
          return lhs_obj
        end

        rhs_var = object_to_variable(rhs_obj, node.rhs_operand)
        if !rhs_var.type.scalar? && !rhs_var.type.void?
          # NOTE: To detect bad value reference of `void' expressions.
          return lhs_var
        end

        case node.operator.type
        when "*="
          _do_mul_then_assign(node, lhs_var, rhs_var)
        when "/="
          _do_div_then_assign(node, lhs_var, rhs_var)
        when "%="
          _do_mod_then_assign(node, lhs_var, rhs_var)
        when "+="
          _do_add_then_assign(node, lhs_var, rhs_var)
        when "-="
          _do_sub_then_assign(node, lhs_var, rhs_var)
        when "<<="
          _do_shl_then_assign(node, lhs_var, rhs_var)
        when ">>="
          _do_shr_then_assign(node, lhs_var, rhs_var)
        when "&="
          _do_and_then_assign(node, lhs_var, rhs_var)
        when "^="
          _do_xor_then_assign(node, lhs_var, rhs_var)
        when "|="
          _do_ior_then_assign(node, lhs_var, rhs_var)
        end

        lhs_var
      end

      private
      def _do_mul_then_assign(node, lhs_var, rhs_var)
        lhs_conved, rhs_conved = _do_uarith_conversion(node, lhs_var, rhs_var)

        lhs_val = lhs_conved.value
        rhs_val = rhs_conved.value
        rslt_var = create_tmpvar(lhs_conved.type, lhs_val * rhs_val)

        # NOTE: Value of the lhs_var is referred at this point.  But value
        #       reference should not be notified not to confuse sequence-point
        #       warning detections.
        # _notify_variable_value_referred(node, lhs_var)
        _notify_variable_value_referred(node, rhs_var)

        notify_multiplicative_expr_evaled(node, lhs_var, rhs_var, rslt_var)

        _do_assign(node, lhs_var, rslt_var)
      end

      def _do_div_then_assign(node, lhs_var, rhs_var)
        lhs_conved, rhs_conved = _do_uarith_conversion(node, lhs_var, rhs_var)

        lhs_val = lhs_conved.value
        rhs_val = rhs_conved.value
        # NOTE: "Div by 0" semantics is implemented in value-value arithmetic.
        rslt_var = create_tmpvar(lhs_conved.type, lhs_val / rhs_val)

        # NOTE: Value of the lhs_var is referred at this point.  But value
        #       reference should not be notified not to confuse sequence-point
        #       warning detections.
        # _notify_variable_value_referred(node, lhs_var)
        _notify_variable_value_referred(node, rhs_var)

        notify_multiplicative_expr_evaled(node, lhs_var, rhs_var, rslt_var)

        _do_assign(node, lhs_var, rslt_var)
      end

      def _do_mod_then_assign(node, lhs_var, rhs_var)
        lhs_conved, rhs_conved = _do_uarith_conversion(node, lhs_var, rhs_var)

        lhs_val = lhs_conved.value
        rhs_val = rhs_conved.value
        # NOTE: "Div by 0" semantics is implemented in value-value arithmetic.
        rslt_var = create_tmpvar(lhs_conved.type, lhs_val % rhs_val)

        # NOTE: Value of the lhs_var is referred at this point.  But value
        #       reference should not be notified not to confuse sequence-point
        #       warning detections.
        # _notify_variable_value_referred(node, lhs_var)
        _notify_variable_value_referred(node, rhs_var)

        notify_multiplicative_expr_evaled(node, lhs_var, rhs_var, rslt_var)

        _do_assign(node, lhs_var, rslt_var)
      end

      def _do_add_then_assign(node, lhs_var, rhs_var)
        lhs_conved, rhs_conved = _do_uarith_conversion(node, lhs_var, rhs_var)

        lhs_val = lhs_conved.value
        rhs_val = rhs_conved.value
        rslt_var = create_tmpvar(lhs_conved.type, lhs_val + rhs_val)

        # NOTE: Value of the lhs_var is referred at this point.  But value
        #       reference should not be notified not to confuse sequence-point
        #       warning detections.
        # _notify_variable_value_referred(node, lhs_var)
        _notify_variable_value_referred(node, rhs_var)

        notify_additive_expr_evaled(node, lhs_var, rhs_var, rslt_var)

        _do_assign(node, lhs_var, rslt_var)
      end

      def _do_sub_then_assign(node, lhs_var, rhs_var)
        lhs_conved, rhs_conved = _do_uarith_conversion(node, lhs_var, rhs_var)

        lhs_val = lhs_conved.value
        rhs_val = rhs_conved.value
        rslt_var = create_tmpvar(lhs_conved.type, lhs_val - rhs_val)

        # NOTE: Value of the lhs_var is referred at this point.  But value
        #       reference should not be notified not to confuse sequence-point
        #       warning detections.
        # _notify_variable_value_referred(node, lhs_var)
        _notify_variable_value_referred(node, rhs_var)

        notify_additive_expr_evaled(node, lhs_var, rhs_var, rslt_var)

        _do_assign(node, lhs_var, rslt_var)
      end

      def _do_shl_then_assign(node, lhs_var, rhs_var)
        # NOTE: The ISO C99 standard says;
        #
        # 6.5.7 Bitwise shift operators
        #
        # 3 The integer promotions are performed on each of the operands.  The
        #   type of the result is that of the promoted left operand.  If the
        #   value of the right operand is negative or is greater than or equal
        #   to the width of the promoted left operand, the behavior is
        #   undefined.
        lhs_conved, rhs_conved = _do_integer_promotions(node, lhs_var, rhs_var)

        lhs_val = lhs_conved.value
        rhs_val = rhs_conved.value
        rslt_var = create_tmpvar(lhs_conved.type, lhs_val << rhs_val)

        # NOTE: Value of the lhs_var is referred at this point.  But value
        #       reference should not be notified not to confuse sequence-point
        #       warning detections.
        # _notify_variable_value_referred(node, lhs_var)
        _notify_variable_value_referred(node, rhs_var)

        notify_shift_expr_evaled(node, lhs_var, rhs_var, rslt_var)

        _do_assign(node, lhs_var, rslt_var)
      end

      def _do_shr_then_assign(node, lhs_var, rhs_var)
        # NOTE: The ISO C99 standard says;
        #
        # 6.5.7 Bitwise shift operators
        #
        # 3 The integer promotions are performed on each of the operands.  The
        #   type of the result is that of the promoted left operand.  If the
        #   value of the right operand is negative or is greater than or equal
        #   to the width of the promoted left operand, the behavior is
        #   undefined.
        lhs_conved, rhs_conved = _do_integer_promotions(node, lhs_var, rhs_var)

        lhs_val = lhs_conved.value
        rhs_val = rhs_conved.value
        rslt_var = create_tmpvar(lhs_conved.type, lhs_val >> rhs_val)

        # NOTE: Value of the lhs_var is referred at this point.  But value
        #       reference should not be notified not to confuse sequence-point
        #       warning detections.
        # _notify_variable_value_referred(node, lhs_var)
        _notify_variable_value_referred(node, rhs_var)

        notify_shift_expr_evaled(node, lhs_var, rhs_var, rslt_var)

        _do_assign(node, lhs_var, rslt_var)
      end

      def _do_and_then_assign(node, lhs_var, rhs_var)
        lhs_conved, rhs_conved = _do_uarith_conversion(node, lhs_var, rhs_var)

        lhs_val = lhs_conved.value
        rhs_val = rhs_conved.value
        rslt_var = create_tmpvar(lhs_conved.type, lhs_val & rhs_val)

        # NOTE: Value of the lhs_var is referred at this point.  But value
        #       reference should not be notified not to confuse sequence-point
        #       warning detections.
        # _notify_variable_value_referred(node, lhs_var)
        _notify_variable_value_referred(node, rhs_var)

        notify_and_expr_evaled(node, lhs_var, rhs_var, rslt_var)

        _do_assign(node, lhs_var, rslt_var)
      end

      def _do_xor_then_assign(node, lhs_var, rhs_var)
        lhs_conved, rhs_conved = _do_uarith_conversion(node, lhs_var, rhs_var)

        lhs_val = lhs_conved.value
        rhs_val = rhs_conved.value
        rslt_var = create_tmpvar(lhs_conved.type, lhs_val ^ rhs_val)

        # NOTE: Value of the lhs_var is referred at this point.  But value
        #       reference should not be notified not to confuse sequence-point
        #       warning detections.
        # _notify_variable_value_referred(node, lhs_var)
        _notify_variable_value_referred(node, rhs_var)

        notify_exclusive_or_expr_evaled(node, lhs_var, rhs_var, rslt_var)

        _do_assign(node, lhs_var, rslt_var)
      end

      def _do_ior_then_assign(node, lhs_var, rhs_var)
        lhs_conved, rhs_conved = _do_uarith_conversion(node, lhs_var, rhs_var)

        lhs_val = lhs_conved.value
        rhs_val = rhs_conved.value
        rslt_var = create_tmpvar(lhs_conved.type, lhs_val | rhs_val)

        # NOTE: Value of the lhs_var is referred at this point.  But value
        #       reference should not be notified not to confuse sequence-point
        #       warning detections.
        # _notify_variable_value_referred(node, lhs_var)
        _notify_variable_value_referred(node, rhs_var)

        notify_inclusive_or_expr_evaled(node, lhs_var, rhs_var, rslt_var)

        _do_assign(node, lhs_var, rslt_var)
      end

      def _do_uarith_conversion(node, lhs_var, rhs_var)
        lhs_conved, rhs_conved =
          do_usual_arithmetic_conversion(lhs_var, rhs_var)

        unless lhs_conved == lhs_var
          notify_implicit_conv_performed(node.lhs_operand, lhs_var, lhs_conved)
        end
        unless rhs_conved == rhs_var
          notify_implicit_conv_performed(node.rhs_operand, rhs_var, rhs_conved)
        end

        return lhs_conved, rhs_conved
      end

      def _do_integer_promotions(node, lhs_var, rhs_var)
        lhs_conved = do_integer_promotion(lhs_var)
        unless lhs_conved == lhs_var
          notify_implicit_conv_performed(node.lhs_operand, lhs_var, lhs_conved)
        end

        rhs_conved = do_integer_promotion(rhs_var)
        unless rhs_conved == rhs_var
          notify_implicit_conv_performed(node.rhs_operand, rhs_var, rhs_conved)
        end

        return lhs_conved, rhs_conved
      end

      def _do_assign(node, lhs_var, rhs_var)
        if rhs_var.type.same_as?(lhs_var.type)
          rhs_conved = rhs_var
        else
          rhs_conved = do_conversion(rhs_var, lhs_var.type) ||
                       create_tmpvar(lhs_var.type)
          notify_implicit_conv_performed(node.lhs_operand, rhs_var, rhs_conved)
        end

        # NOTE: Domain of the arithmetic result value will be restricted by
        #       min-max of the variable type.
        lhs_var.assign!(rhs_conved.value.to_defined_value)
        _notify_variable_value_updated(node, lhs_var)

        notify_assignment_expr_evaled(node, lhs_var, rhs_conved)
      end

      def _pick_array_element(ary, subs, rslt_type)
        if interpreter.eval_as_controlling_expr?
          _pick_array_element_in_controlling_expr(ary, subs, rslt_type)
        else
          # FIXME: Domain of the subscript may have multiple values.
          subs_val = subs.value.unique_sample
          if ary and inner_var = ary.inner_variable_at(subs_val)
            if inner_var.type.same_as?(rslt_type)
              rslt_var = inner_var
            end
          end
          rslt_var || create_tmpvar(rslt_type)
        end
      end

      def _pick_array_element_in_controlling_expr(ary, subs, rslt_type)
        # NOTE: To improve heuristics of array subscript evaluation with
        #       indefinite subscript.
        if ary
          subs_smpls = subs.value.to_enum
          if subs_smpls.count == 1
            if inner_var = ary.inner_variable_at(subs_smpls.first) and
                inner_var.type.same_as?(rslt_type)
              rslt_var = inner_var
            end
          else
            rslt_val = subs_smpls.reduce(rslt_type.nil_value) { |val, smpl_val|
              if inner_var = ary.inner_variable_at(smpl_val) and
                  inner_var.type.same_as?(rslt_type)
                val.single_value_unified_with(inner_var.value)
              else
                val
              end
            }
            rslt_var = create_tmpvar(rslt_type, rslt_val)
          end
        end
        rslt_var || create_tmpvar(rslt_type)
      end

      def _notify_object_referred(node, obj)
        case obj
        when Variable
          interpreter.notify_variable_referred(node, obj)
        when Function
          interpreter.notify_function_referred(node, obj)
        end
      end

      def _notify_variable_value_referred(node, obj)
        if obj.variable?
          interpreter.notify_variable_value_referred(node, obj)
        end

        # NOTE: When a value of the inner-variable of array or composite object
        #       is referred, notification of the outer variable's value has
        #       already been done in sub expressions.
      end

      def _notify_variable_value_updated(node, obj)
        if obj.variable?
          interpreter.notify_variable_value_updated(node, obj)
          if obj.inner?
            # NOTE: When a value of the inner-variable of array or composite
            #       object is updated, the outer variable's value should also
            #       be notified to be updated.
            _notify_variable_value_updated(node, obj.owner)
          end
        end
      end

      def _notify_implicit_function_declared(node, obj)
        if obj.function? && obj.implicit?
          interpreter.notify_implicit_function_declared(node, obj)
        end
      end
    end

    include Impl
  end

end
end
