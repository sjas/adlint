# Kernel of the abstract interpreter of C language.
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

require "adlint/monitor"
require "adlint/util"
require "adlint/cc1/environ"
require "adlint/cc1/resolver"
require "adlint/cc1/mediator"
require "adlint/cc1/syntax"
require "adlint/cc1/expr"
require "adlint/cc1/conv"
require "adlint/cc1/option"
require "adlint/cc1/operator"
require "adlint/cc1/util"

module AdLint #:nodoc:
module Cc1 #:nodoc:

  class Program
    def initialize(interp, tunit)
      @interpreter = interp
      @translation_unit = tunit
    end

    def execute
      @interpreter.notify_translation_unit_started(@translation_unit)
      @translation_unit.accept(ExecutionDriver.new(@interpreter))
      @interpreter.notify_translation_unit_ended(@translation_unit)
    end

    class ExecutionDriver < SyntaxTreeVisitor
      def initialize(interp)
        @interpreter = interp
      end

      def visit_declaration(node) @interpreter.execute(node) end
      def visit_ansi_function_definition(node) @interpreter.execute(node) end
      def visit_kandr_function_definition(node) @interpreter.execute(node) end
    end
    private_constant :ExecutionDriver
  end

  class Interpreter
    include InterpreterMediator
    include Conversion
    include InterpreterOptions
    include BranchOptions

    def initialize(type_tbl)
      @type_table    = type_tbl
      @environment   = Environment.new(type_tbl)
      @type_resolver = DynamicTypeResolver.new(type_tbl, self)

      @sub_interpreters = [
        DeclarationInterpreter.new(self),
        ParameterDefinitionInterpreter.new(self),
        FunctionInterpreter.new(self),
        SwitchStatementInterpreter.new(self),
        StatementInterpreter.new(self),
        ExpressionInterpreter.new(self)
      ]

      @options_stack = []

      # NOTE: Active (executing) function may be nested if the nested
      #       function-definition of the GCC extension is used.
      @active_function_stack = []
    end

    attr_reader :environment
    attr_reader :type_resolver

    extend Forwardable

    def_delegator :@type_table, :traits
    def_delegator :@type_table, :monitor
    def_delegator :@type_table, :logger

    extend Pluggable

    def self.def_plugin_and_notifier(event_name, *arg_names)
      class_eval <<-EOS
        def_plugin :on_#{event_name}
        def notify_#{event_name}(#{arg_names.join(",")})
          unless quiet?
            on_#{event_name}.invoke(#{arg_names.join(",")})
          end
        end
      EOS
    end
    private_class_method :def_plugin_and_notifier

    # NOTE: Notified when the interpreter evaluates a variable-declaration.
    def_plugin_and_notifier :variable_declared, :var_dcl, :var

    # NOTE: Notified when the interpreter evaluates a variable-definition.
    def_plugin_and_notifier :variable_defined, :var_def, :var

    # NOTE: Notified when the interpreter evaluates an initializer of
    #       variable-definition.
    def_plugin_and_notifier :variable_initialized, :var_def, :var, :init_var

    # NOTE: Notified when the interpreter evaluates a function-declaration.
    def_plugin_and_notifier :explicit_function_declared, :fun_dcl, :fun

    # NOTE: Notified when the interpreter evaluates a function-definition.
    def_plugin_and_notifier :explicit_function_defined, :fun_def, :fun

    # NOTE: Notified when the interpreter evaluates a struct-type-declaration.
    def_plugin_and_notifier :struct_declared, :struct_type_dcl

    # NOTE: Notified when the interpreter evaluates a union-type-declaration.
    def_plugin_and_notifier :union_declared, :union_type_dcl

    # NOTE: Notified when the interpreter evaluates a enum-type-declaration.
    def_plugin_and_notifier :enum_declared, :enum_type_dcl

    # NOTE: Notified when the interpreter evaluates a typedef-declaration.
    def_plugin_and_notifier :typedef_declared, :typedef_dcl

    # NOTE: Notified when the interpreter starts execution of a
    #       function-definition.
    def_plugin_and_notifier :function_started, :fun_def, :fun

    # NOTE: Notified when the interpreter ends execution of a
    #       function-definition.
    def_plugin_and_notifier :function_ended, :fun_def, :fun

    # NOTE: Notified when the interpreter evaluates a parameter-definition at
    #       beginning of execution of a function-definition.
    def_plugin_and_notifier :parameter_defined, :param_def, :var

    # NOTE: Notified when the interpreter evaluates an expression which results
    #       a named variable.
    def_plugin_and_notifier :variable_referred, :expr, :var

    # NOTE: Notified when the interpreter evaluates an expression which results
    #       a constant temporary variable.
    def_plugin_and_notifier :constant_referred, :const_spec, :var

    # NOTE: Notified when the interpreter refers to a value of a variable while
    #       evaluating an expression.
    def_plugin_and_notifier :variable_value_referred, :expr, :var

    # NOTE: Notified when the interpreter overwrites a value of a variable
    #       while evaluating an expression.
    def_plugin_and_notifier :variable_value_updated, :expr, :var

    # NOTE: Notified when the interpreter refers to a function object while
    #       evaluating an expression.
    def_plugin_and_notifier :function_referred, :expr, :fun

    # NOTE: Notified when the interpreter creates function-declaration of an
    #       implicit function.
    def_plugin_and_notifier :implicit_function_declared, :obj_spec, :fun

    # NOTE: Notified when the interpreter evaluates a sizeof-expression.
    def_plugin_and_notifier :sizeof_expr_evaled, :expr, :ope_var, :res_var

    # NOTE: Notified when the interpreter evaluates a sizeof-type-expression.
    def_plugin_and_notifier :sizeof_type_expr_evaled, :expr, :type, :res_var

    # NOTE: Notified when the interpreter evaluates a cast-expression.
    def_plugin_and_notifier :explicit_conv_performed, :expr, :org_var, :res_var

    # NOTE: Notified when the interpreter performs an implicit type conversion
    #       while evaluating an expression.
    def_plugin_and_notifier :implicit_conv_performed,
                            :init_or_expr, :org_var, :res_var

    # NOTE: Notified when the interpreter evaluates an
    #       array-subscript-expression.
    def_plugin_and_notifier :array_subscript_expr_evaled,
                            :expr, :ary_or_ptr, :subs, :ary_var, :res_var

    # NOTE: Notified when the interpreter evaluates a function-call-expression.
    def_plugin_and_notifier :function_call_expr_evaled,
                            :expr, :fun, :arg_vars, :res_var

    # NOTE: Notified when the interpreter evaluates an
    #       unary-arithmetic-expression.
    def_plugin_and_notifier :unary_arithmetic_expr_evaled,
                            :expr, :ope_var, :res_var

    # NOTE: Notified when the interpreter evaluates a
    #       multiplicative-expression.
    def_plugin_and_notifier :multiplicative_expr_evaled,
                            :expr, :lhs_var, :rhs_var, :res_var

    # NOTE: Notified when the interpreter evaluates an additive-expression.
    def_plugin_and_notifier :additive_expr_evaled,
                            :expr, :lhs_var, :rhs_var, :res_var

    # NOTE: Notified when the interpreter evaluates a shift-expression.
    def_plugin_and_notifier :shift_expr_evaled,
                            :expr, :lhs_var, :rhs_var, :res_var

    # NOTE: Notified when the interpreter evaluates a relational-expression.
    def_plugin_and_notifier :relational_expr_evaled,
                            :expr, :lhs_var, :rhs_var, :res_var

    # NOTE: Notified when the interpreter evaluates an equality-expression.
    def_plugin_and_notifier :equality_expr_evaled,
                            :expr, :lhs_var, :rhs_var, :res_var

    # NOTE: Notified when the interpreter evaluates a bitwise and-expression.
    def_plugin_and_notifier :and_expr_evaled,
                            :expr, :lhs_var, :rhs_var, :res_var

    # NOTE: Notified when the interpreter evaluates an exclusive-or-expression.
    def_plugin_and_notifier :exclusive_or_expr_evaled,
                            :expr, :lhs_var, :rhs_var, :res_var

    # NOTE: Notified when the interpreter evaluates a bitwise
    #       inclusive-or-expression.
    def_plugin_and_notifier :inclusive_or_expr_evaled,
                            :expr, :lhs_var, :rhs_var, :res_var

    # NOTE: Notified when the interpreter evaluates a logical-and-expression.
    def_plugin_and_notifier :logical_and_expr_evaled,
                            :expr, :lhs_var, :rhs_var, :res_var

    # NOTE: Notified when the interpreter evaluates a logical-or-expression.
    def_plugin_and_notifier :logical_or_expr_evaled,
                            :expr, :lhs_var, :rhs_var, :res_var

    # NOTE: Notified when the interpreter evaluates a conditional-expression.
    def_plugin_and_notifier :conditional_expr_evaled,
                            :expr, :ctrlexpr_var, :res_var

    # NOTE: Notified when the interpreter evaluates an address-expression.
    def_plugin_and_notifier :address_expr_evaled, :expr, :obj, :ptr_var

    # NOTE: Notified when the interpreter evaluates an indirection-expression.
    def_plugin_and_notifier :indirection_expr_evaled,
                            :expr, :ptr_var, :derefed_var

    # NOTE: Notified when the interpreter evaluates a
    #       member-access-by-value-expression or a
    #       member-access-by-pointer-expression.
    def_plugin_and_notifier :member_access_expr_evaled,
                            :expr, :outer_var, :inner_var

    # NOTE: Notified when the interpreter evaluates a
    #       prefix-increment-expression.
    def_plugin_and_notifier :prefix_increment_expr_evaled,
                            :expr, :ope_var, :org_val

    # NOTE: Notified when the interpreter evaluates a
    #       postfix-increment-expression.
    def_plugin_and_notifier :postfix_increment_expr_evaled,
                            :expr, :ope_var, :res_var

    # NOTE: Notified when the interpreter evaluates a
    #       prefix-decrement-expression.
    def_plugin_and_notifier :prefix_decrement_expr_evaled,
                            :expr, :ope_var, :org_val

    # NOTE: Notified when the interpreter evaluates a
    #       postfix-decrement-expression.
    def_plugin_and_notifier :postfix_decrement_expr_evaled,
                            :expr, :ope_var, :res_var

    # NOTE: Notified when the interpreter evaluates a
    #       simple-assignment-expression or a compound-assignment-expression.
    def_plugin_and_notifier :assignment_expr_evaled, :expr, :lhs_var, :rhs_var

    # NOTE: Notified when the interpreter starts execution of a
    #       expression-statement.
    def_plugin_and_notifier :expression_stmt_started, :stmt

    # NOTE: Notified when the interpreter ends execution of a
    #       expression-statement.
    def_plugin_and_notifier :expression_stmt_ended, :stmt

    # NOTE: Notified when the interpreter starts execution of a
    #       switch-statement.
    def_plugin_and_notifier :switch_stmt_started, :stmt

    # NOTE: Notified when the interpreter ends execution of a switch-statement.
    def_plugin_and_notifier :switch_stmt_ended, :stmt

    # NOTE: Notified when the interpreter starts execution of a
    #       while-statement.
    def_plugin_and_notifier :while_stmt_started, :stmt

    # NOTE: Notified when the interpreter ends execution of a while-statement.
    def_plugin_and_notifier :while_stmt_ended, :stmt

    # NOTE: Notified when the interpreter starts execution of a do-statement.
    def_plugin_and_notifier :do_stmt_started, :stmt

    # NOTE: Notified when the interpreter ends execution of a do-statement.
    def_plugin_and_notifier :do_stmt_ended, :stmt

    # NOTE: Notified when the interpreter starts execution of a for-statement.
    def_plugin_and_notifier :for_stmt_started, :stmt

    # NOTE: Notified when the interpreter ends execution of a for-statement.
    def_plugin_and_notifier :for_stmt_ended, :stmt

    # NOTE: Notified when the interpreter starts execution of a
    #       c99-for-statement.
    def_plugin_and_notifier :c99_for_stmt_started, :stmt

    # NOTE: Notified when the interpreter ends execution of a
    #       c99-for-statement.
    def_plugin_and_notifier :c99_for_stmt_ended, :stmt

    # NOTE: Notified when the interpreter evaluates a goto-statement.
    def_plugin_and_notifier :goto_stmt_evaled, :stmt, :label_name

    # NOTE: Notified when the interpreter evaluates a return-statement.
    def_plugin_and_notifier :return_stmt_evaled, :stmt, :retn_var

    # NOTE: Notified when the interpreter evaluates an implicit return.
    def_plugin_and_notifier :implicit_return_evaled, :loc

    # NOTE: Notified when the interpreter evaluates a controlling expression of
    #       the if-statement.
    def_plugin_and_notifier :if_ctrlexpr_evaled, :if_stmt, :ctrlexpr_val

    # NOTE: Notified when the interpreter evaluates a controlling expression of
    #       the if-else-statement.
    def_plugin_and_notifier :if_else_ctrlexpr_evaled,
                            :if_else_stmt, :ctrlexpr_val

    # NOTE: Notified when the interpreter evaluates a controlling expression of
    #       the switch-statement.
    def_plugin_and_notifier :switch_ctrlexpr_evaled,
                            :switch_stmt, :ctrlexpr_var

    # NOTE: Notified when the interpreter evaluates a controlling expression of
    #       the case-labeled-statement.
    def_plugin_and_notifier :case_ctrlexpr_evaled,
                            :case_labeled_stmt, :ctrlexpr_var

    # NOTE: Notified when the interpreter evaluates a controlling expression of
    #       the while-statement.
    def_plugin_and_notifier :while_ctrlexpr_evaled,
                            :while_statement, :ctrlexpr_val

    # NOTE: Notified when the interpreter evaluates a controlling expression of
    #       the do-statement.
    def_plugin_and_notifier :do_ctrlexpr_evaled, :do_stmt, :ctrlexpr_val

    # NOTE: Notified when the interpreter evaluates a controlling expression of
    #       the for-statement.
    def_plugin_and_notifier :for_ctrlexpr_evaled, :for_stmt, :ctrlexpr_val

    # NOTE: Notified when the interpreter evaluates a controlling expression of
    #       the c99-for-statement.
    def_plugin_and_notifier :c99_for_ctrlexpr_evaled,
                            :c99_for_stmt, :ctrlexpr_val

    # NOTE: Notified when the interpreter defines a generic-label.
    def_plugin_and_notifier :label_defined, :generic_labeled_stmt

    # NOTE: Notified when the interpreter starts execution of a
    #       compound-statement.
    def_plugin_and_notifier :block_started, :compound_stmt

    # NOTE: Notified when the interpreter ends execution of a
    #       compound-statement.
    def_plugin_and_notifier :block_ended, :compound_stmt

    # NOTE: Notified when the interpreter forks execution paths of a
    #       function-definition.
    def_plugin_and_notifier :branch_started, :branch

    # NOTE: Notified when the interpreter joins execution paths of a
    #       function-definition.
    def_plugin_and_notifier :branch_ended, :branch

    # NOTE: Notified when the interpreter starts execution of a
    #       translation-unit.
    def_plugin_and_notifier :translation_unit_started, :tunit

    # NOTE: Notified when the interpreter ends execution of a translation-unit.
    def_plugin_and_notifier :translation_unit_ended, :tunit

    # NOTE: Notified when the control reaches to a sequence-point.
    def_plugin_and_notifier :sequence_point_reached, :seqp

    def execute(node, *opts)
      @options_stack.push(cur_opts + opts)
      if quiet_without_side_effect?
        result = nil
        branched_eval(nil, FINAL) do
          result = node.accept(interpreter_for(node))
          # NOTE: To rollback latest variable value versions.
          BreakEvent.of_return.throw
        end
      else
        result = node.accept(interpreter_for(node))
      end
      result
    ensure
      @options_stack.pop
    end

    def object_to_variable(obj)
      case
      when obj.function?
        create_tmpvar(pointer_type(obj.type), pointer_value_of(obj))
      when obj.type.array?
        create_tmpvar(pointer_type(obj.type.base_type), pointer_value_of(obj))
      else
        obj
      end
    end

    def value_of(obj)
      if obj.type.array? || obj.type.function?
        pointer_value_of(obj)
      else
        obj.value.to_single_value
      end
    end

    def pointer_value_of(obj)
      scalar_value_of(obj.binding.memory.address)
    end

    def quiet?
      cur_opts.include?(QUIET) || cur_opts.include?(QUIET_WITHOUT_SIDE_EFFECT)
    end

    def _quiet=(quiet)
      # NOTE: This method is called only from ControllingExpression.
      if quiet
        cur_opts.add(QUIET)
      else
        cur_opts.delete(QUIET)
      end
    end

    def quiet_without_side_effect?
      cur_opts.include?(QUIET_WITHOUT_SIDE_EFFECT)
    end

    def _quiet_without_side_effect=(quiet_without_side_effect)
      # NOTE: This method is called only from ExpressionEvaluator.
      if quiet_without_side_effect
        cur_opts.add(QUIET_WITHOUT_SIDE_EFFECT)
      else
        cur_opts.delete(QUIET_WITHOUT_SIDE_EFFECT)
      end
    end

    def _active_function
      # NOTE: This method is called only from
      #       StatementInterpreter#visit_return_statement.
      # NOTE: To convert returning object, StatementInterpreter must have
      #       knowledge about conversion destination type.
      @active_function_stack.last
    end

    def _enter_function(fun_def)
      # NOTE: This method is called only from FunctionInterpreter.
      @active_function_stack.push(fun_def)
    end

    def _leave_function(*)
      # NOTE: This method is called only from FunctionInterpreter.
      @active_function_stack.pop
    end

    private
    def interpreter_for(node)
      @sub_interpreters.find do |interp|
        node.kind_of?(interp.target_node_class)
      end
    end

    def cur_opts
      @options_stack.last || Set.new
    end

    def interpreter
      # NOTE: This method is of the requirement for including
      #       InterpreterMediator.
      self
    end
  end

  class SubInterpreter < SyntaxTreeVisitor
    include InterpreterOptions
    include InterpreterMediator
    include NotifierMediator
    include Conversion
    include MonitorUtil
    include LogUtil

    def initialize(owner, target_node_class)
      @owner = owner
      @target_node_class = target_node_class
    end

    attr_reader :target_node_class

    private
    def interpreter
      # NOTE: This is private attr_reader for InterpreterMediator.
      #       This attribute is read via a normal method to suppress
      #       `private attribute?' warning.
      @owner
    end

    extend Forwardable

    def_delegator :interpreter, :monitor
    private :monitor

    def_delegator :interpreter, :logger
    private :logger
  end

  class DeclarationInterpreter < SubInterpreter
    def initialize(owner)
      super(owner, Declaration)
    end

    def visit_function_declaration(node)
      checkpoint(node.location)

      resolve_unresolved_type(node)
      node.type.declarations.each do |dcl|
        dcl.mark_as_referred_by(node.identifier)
      end

      fun = declare_explicit_function(node)
      notify_explicit_function_declared(node, fun)
      evaluate_sequence_point(node.init_declarator.declarator)
    end

    def visit_variable_declaration(node)
      checkpoint(node.location)

      resolve_unresolved_type(node)
      node.type.declarations.each do |dcl|
        dcl.mark_as_referred_by(node.identifier)
      end

      var = declare_variable(node)
      notify_variable_declared(node, var)
      evaluate_sequence_point(node.declarator)
    end

    def visit_variable_definition(node)
      checkpoint(node.location)

      resolve_unresolved_type(node)
      node.type.declarations.each do |dcl|
        dcl.mark_as_referred_by(node.identifier)
      end

      if node.initializer
        init_var, init_conved = evaluate_initializer(node)
        var = define_variable(node, init_conved.value.to_defined_value)
        notify_variable_value_referred(node, init_var)
        notify_variable_defined(node, var)
        notify_variable_initialized(node, var, init_var)
      else
        notify_variable_defined(node, define_variable(node))
      end

      evaluate_sequence_point(node.init_declarator.declarator)
    end

    def visit_struct_type_declaration(node)
      checkpoint(node.location)

      resolve_unresolved_type(node)
      notify_struct_declared(node)
    end

    def visit_union_type_declaration(node)
      checkpoint(node.location)

      resolve_unresolved_type(node)
      notify_union_declared(node)
    end

    def visit_enum_type_declaration(node)
      checkpoint(node)

      if enums = node.enum_specifier.enumerators
        seq = 0
        enums.each do |enum|
          if expr = enum.expression
            obj = interpret(expr)
            if obj.variable? && obj.value.scalar?
              enum.value = obj.value.unique_sample
            end
          end
          enum.value ||= seq
          define_enumerator(enum)
          seq = enum.value + 1
        end
      end

      notify_enum_declared(node)
    end

    def visit_typedef_declaration(node)
      checkpoint(node.location)

      resolve_unresolved_type(node)
      node.type.real_type.declarations.each do |dcl|
        dcl.mark_as_referred_by(node.identifier)
      end

      notify_typedef_declared(node)
      evaluate_sequence_point(node.init_declarator.declarator)

      LOG_I("user-type `#{node.identifier.value}' " +
            "defined at #{node.location.to_s}.")
    end

    private
    def evaluate_initializer(var_def)
      init_interp = InitializerInterpreter.new(interpreter)
      var, conved = init_interp.execute(var_def)

      # NOTE: An implicit conversion and size deduction of an incomplete array
      #       have been done by InitializerInterpreter.

      # NOTE: For the case of array variable definition with a
      #       string-literal-specifier as the initializer.
      if var_def.type.array? && var.type.pointer?
        unless ary = pointee_of(var) and ary.type.array?
          ary = create_tmpvar(var_def.type)
        end
        deduct_array_length_from_array_variable(var_def, ary)
        var = conved = ary
      end

      return var, conved
    end

    def deduct_array_length_from_array_variable(var_def, ary)
      unless var_def.type.length
        if var_def.type.user?
          var_def.type = var_def.type.dup
        end
        var_def.type.length = ary.type.length
      end
    end

    def evaluate_sequence_point(full_dcr)
      if seqp = full_dcr.subsequent_sequence_point
        notify_sequence_point_reached(seqp)
      end
    end
  end

  class InitializerInterpreter
    include InterpreterMediator
    include NotifierMediator
    include Conversion
    include MonitorUtil

    def initialize(interp)
      @interpreter = interp
    end

    def execute(var_def)
      checkpoint(var_def.initializer.location)

      case
      when expr = var_def.initializer.expression
        # NOTE: An implicit conversion is already notified in
        #       #evaluate_expression.
        return evaluate_expression(expr, var_def.type)
      when inits = var_def.initializer.initializers
        var = evaluate_initializers(inits, var_def.type)

        # NOTE: Size deduction of an incomplete array type have been done by
        #       #evaluate_initializers.
        if var_def.type.array? && var.type.array?
          var_def.type = var.type unless var_def.type.length
        end

        if var.type.same_as?(var_def.type)
          conved = var
        else
          conved = do_conversion(var, var_def.type) ||
                   create_tmpvar(var_def.type)
          notify_implicit_conv_performed(inits, var, conved)
        end
      else
        var = conved = create_tmpvar(var_def.type)
      end

      return var, conved
    end

    private
    def evaluate_expression(expr, type)
      checkpoint(expr.location)

      obj = interpret(expr)
      var = object_to_variable(obj)
      notify_implicit_conv_performed(expr, obj, var) unless var == obj

      if var.type.same_as?(type)
        conved = var
      else
        conved = do_conversion(var, type) || create_tmpvar(type)
        notify_implicit_conv_performed(expr, var, conved)
      end

      return var, conved
    end

    def evaluate_initializers(inits, type)
      case
      when type.union?
        # NOTE: The ISO C99 standard says;
        #
        # 6.7.8 Initialization
        #
        # Semantics
        #
        # 10 If an object that has automatic storage duration is not
        #    initialized explicitly, its value is indeterminate.  If an object
        #    that has static storage duration is not initialized explicitly,
        #    then:
        #    -- if it has pointer type, it is initialized to a null pointer;
        #    -- if it has arithmetic type, it is initialized to (positive or
        #       unsigned) zero;
        #    -- if it is an aggregate, every member is initialized
        #       (recursively) according to these rules;
        #    -- if it is a union, the first named member is initialized
        #       (recursively) according to these rules.
        if fst_memb = type.members.first
          fst_obj = evaluate_initializers(inits, fst_memb.type)
          return create_tmpvar(type, value_of(fst_obj))
        else
          return create_tmpvar(type)
        end
      when type.array?
        # NOTE: The ISO C99 standard says;
        #
        # 6.7.2.1 Structure and union specifiers
        #
        # Constraints
        #
        # 2 A structure or union shall not contain a member with incomplete
        #   or function type (hence, a structure shall not contain an
        #   instance of itself, but may contain a pointer to an instance of
        #   itself), except that the last member of a structure with more
        #   than one named member may have incomplete array type; such a
        #   structure (and any union containing, possibly recursively, a
        #   member that is such a structure) shall not be a member of a
        #   structure or an element of an array.
        #
        # NOTE: Size of the last incomplete array member should not be
        #       deducted in initialization.  It is treated as a pointer.
        #
        # NOTE: ISO C90 does not support flexible array members.
        type = deduct_array_length_from_initializers(type, inits)
        memb_types = [type.unqualify.base_type] * type.impl_length
      when type.struct?
        memb_types = type.members.map { |memb| memb.type }
      else
        memb_types = [type]
      end

      vals = memb_types.zip(inits).map { |memb_type, init|
        if init
          checkpoint(init.location)
          case
          when expr = init.expression
            value_of(evaluate_expression(expr, memb_type).last)
          when inits = init.initializers
            value_of(evaluate_initializers(inits, memb_type))
          else
            memb_type.undefined_value
          end
        else
          memb_type.undefined_value
        end
      }

      case
      when type.array?
        create_tmpvar(type, ArrayValue.new(vals))
      when type.composite?
        create_tmpvar(type, CompositeValue.new(vals))
      else
        create_tmpvar(type, vals.first)
      end
    end

    def deduct_array_length_from_initializers(org_ary_type, inits)
      unless org_ary_type.length
        if org_ary_type.user?
          org_ary_type = org_ary_type.dup
        end
        org_ary_type.length = inits.size
      end
      org_ary_type
    end

    def interpreter
      # NOTE: This is private attr_reader for InterpreterMediator.
      #       This attribute is read via a normal method to suppress
      #       `private attribute?' warning.
      @interpreter
    end

    extend Forwardable

    def_delegator :interpreter, :monitor
    private :monitor
  end

  class ParameterDefinitionInterpreter < SubInterpreter
    def initialize(owner)
      super(owner, ParameterDefinition)
    end

    def visit_parameter_definition(node)
      checkpoint(node.location)

      resolve_unresolved_type(node)
      id = node.identifier

      node.type.declarations.each do |dcl|
        if id
          dcl.mark_as_referred_by(id)
        else
          dcl.mark_as_referred_by(node.head_token)
        end
      end

      if id
        var = define_variable(node.to_variable_definition,
                              node.type.parameter_value)
        notify_parameter_defined(node, var)
      end
    end
  end

  class FunctionInterpreter < SubInterpreter
    def initialize(owner)
      super(owner, FunctionDefinition)
    end

    def visit_ansi_function_definition(node)
      interpret_function(node)
    end

    def visit_kandr_function_definition(node)
      interpret_function(node)
    end

    private
    def interpret_function(fun_def)
      checkpoint(fun_def.location)

      reset_environment
      resolve_unresolved_type(fun_def)
      fun = lookup_or_define_function(fun_def)
      notify_explicit_function_defined(fun_def, fun)

      interpret_function_body(fun_def, fun) if fun_def.analysis_target?(traits)
    end

    def interpret_function_body(fun_def, fun)
      interpreter._enter_function(fun_def)
      scoped_eval do
        notify_function_started(fun_def, fun)
        notify_block_started(fun_def.function_body)

        fun_def.parameter_definitions.each { |param_def| interpret(param_def) }
        BreakEvent.catch do
          fun_def.function_body.block_items.each { |item| interpret(item) }
          notify_implicit_return_evaled(fun_def.function_body.tail_location)
        end

        notify_block_ended(fun_def.function_body)
        notify_function_ended(fun_def, fun)
      end
    ensure
      interpreter._leave_function(fun_def)
    end

    def lookup_or_define_function(fun_def)
      fun_def.type.declarations.each do |dcl|
        dcl.mark_as_referred_by(fun_def.identifier)
      end

      if fun = function_named(fun_def.identifier.value) and fun.explicit?
        fun.declarations_and_definitions.each do |dcl_or_def|
          dcl_or_def.mark_as_referred_by(fun_def.identifier)
        end
        fun.declarations_and_definitions.push(fun_def)
        fun
      else
        define_explicit_function(fun_def)
      end
    end
  end

  class StatementInterpreter < SubInterpreter
    include BranchOptions
    include BranchGroupOptions
    include SyntaxNodeCollector

    def initialize(owner)
      super(owner, Statement)

      # NOTE: All effective controlling expressions in the executing
      #       iteration-statements.
      @effective_ctrlexpr_stack = []
    end

    def visit_generic_labeled_statement(node)
      checkpoint(node.location)

      node.executed = true
      notify_label_defined(node)

      uninitialize_block_local_variables(node)
      interpret(node.statement)
    end

    def visit_case_labeled_statement(node)
      checkpoint(node.location)

      node.executed = true
      ctrlexpr = node.expression
      ctrlexpr_var = object_to_variable(interpret(ctrlexpr, QUIET))
      notify_case_ctrlexpr_evaled(node, ctrlexpr_var)

      interpret(node.statement)
    end

    def visit_default_labeled_statement(node)
      checkpoint(node.location)

      node.executed = true
      interpret(node.statement)
    end

    def visit_compound_statement(node)
      checkpoint(node.location)

      node.executed = true
      scoped_eval do
        begin
          notify_block_started(node)
          node.block_items.each { |item| interpret(item) }
        ensure
          notify_block_ended(node)
        end
      end
    end

    def visit_expression_statement(node)
      checkpoint(node.location)

      node.executed = true
      notify_expression_stmt_started(node)

      interpret(node.expression) if node.expression
    ensure
      notify_expression_stmt_ended(node)
    end

    def visit_if_statement(node)
      checkpoint(node.location)

      node.executed = true

      org_ctrlexpr = node.expression
      if org_ctrlexpr == effective_ctrlexpr
        ctrlexpr_val = scalar_value_of_arbitrary
        ctrlexpr = nil
      else
        ctrlexpr_var = object_to_variable(interpret(org_ctrlexpr))
        ctrlexpr_val = value_of(ctrlexpr_var)
        notify_variable_value_referred(org_ctrlexpr, ctrlexpr_var)
        notify_sequence_point_reached(SequencePoint.new(org_ctrlexpr))
        ctrlexpr = org_ctrlexpr.to_normalized_logical
      end
      notify_if_ctrlexpr_evaled(node, ctrlexpr_val)

      case
      when ctrlexpr_val.must_be_true?
        branched_eval(ctrlexpr, NARROWING, FINAL, IMPLICIT_COND, COMPLETE) do
          interpret(node.statement)
        end
      when ctrlexpr_val.may_be_true?
        branched_eval(ctrlexpr, NARROWING, FINAL, IMPLICIT_COND) do
          interpret(node.statement)
        end
      else
        # NOTE: To end the current branch group of else-if sequence.
        branched_eval(nil, NARROWING, FINAL) {}
      end
    end

    def visit_if_else_statement(node)
      checkpoint(node.location)

      node.executed = true

      org_ctrlexpr = node.expression
      if org_ctrlexpr == effective_ctrlexpr
        ctrlexpr_val = scalar_value_of_arbitrary
        ctrlexpr = nil
      else
        ctrlexpr_var = object_to_variable(interpret(org_ctrlexpr))
        ctrlexpr_val = value_of(ctrlexpr_var)
        notify_variable_value_referred(org_ctrlexpr, ctrlexpr_var)
        notify_sequence_point_reached(SequencePoint.new(org_ctrlexpr))
        ctrlexpr = org_ctrlexpr.to_normalized_logical
      end
      notify_if_else_ctrlexpr_evaled(node, ctrlexpr_val)

      case
      when ctrlexpr_val.must_be_true?
        branched_eval(ctrlexpr, NARROWING, FINAL, IMPLICIT_COND, COMPLETE) do
          interpret(node.then_statement)
        end
        return
      when ctrlexpr_val.may_be_true?
        branched_eval(ctrlexpr, NARROWING, IMPLICIT_COND) do
          interpret(node.then_statement)
        end
      end

      case node.else_statement
      when IfStatement, IfElseStatement
        interpret(node.else_statement)
      else
        branched_eval(nil, NARROWING, COMPLEMENTAL, FINAL, COMPLETE) do
          interpret(node.else_statement)
        end
      end
    end

    def visit_while_statement(node)
      checkpoint(node.location)

      node.executed = true
      notify_while_stmt_started(node)

      widen_varying_variable_value_domain(node)

      ctrlexpr_var = object_to_variable(interpret(node.expression))
      ctrlexpr_val = value_of(ctrlexpr_var)
      notify_variable_value_referred(node.expression, ctrlexpr_var)
      notify_sequence_point_reached(SequencePoint.new(node.expression))
      notify_while_ctrlexpr_evaled(node, ctrlexpr_val)

      org_ctrlexpr, ctrlexpr = node.deduct_controlling_expression

      case
      when ctrlexpr_val.must_be_true?
        begin
          enter_iteration_statement(org_ctrlexpr)
          branched_eval(ctrlexpr, NARROWING, FINAL, IMPLICIT_COND, COMPLETE) do
            interpret(node.statement)
          end
        ensure
          leave_iteration_statement(org_ctrlexpr)
        end
      when ctrlexpr_val.may_be_true?
        begin
          enter_iteration_statement(org_ctrlexpr)
          branched_eval(ctrlexpr, NARROWING, FINAL, IMPLICIT_COND) do
            interpret(node.statement)
          end
        ensure
          leave_iteration_statement(org_ctrlexpr)
        end
      end
    ensure
      notify_while_stmt_ended(node)
    end

    def visit_do_statement(node)
      checkpoint(node.location)

      node.executed = true
      notify_do_stmt_started(node)

      widen_varying_variable_value_domain(node)

      org_ctrlexpr, ctrlexpr = node.deduct_controlling_expression

      begin
        enter_iteration_statement(org_ctrlexpr)
        branched_eval(ctrlexpr, NARROWING, FINAL, IMPLICIT_COND, COMPLETE) do
          interpret(node.statement)
        end
      ensure
        leave_iteration_statement(org_ctrlexpr)
      end

      ctrlexpr_var = object_to_variable(interpret(node.expression))
      ctrlexpr_val = value_of(ctrlexpr_var)
      notify_variable_value_referred(node.expression, ctrlexpr_var)
      notify_sequence_point_reached(SequencePoint.new(node.expression))
      notify_do_ctrlexpr_evaled(node, ctrlexpr_val)
    ensure
      notify_do_stmt_ended(node)
    end

    def visit_for_statement(node)
      checkpoint(node.location)

      node.executed = true
      notify_for_stmt_started(node)

      node.initial_statement.accept(self)

      widen_varying_variable_value_domain(node)
      org_ctrlexpr, ctrlexpr = node.deduct_controlling_expression

      node.condition_statement.executed = true
      if explicit_ctrlexpr = node.condition_statement.expression
        ctrlexpr_var = object_to_variable(interpret(explicit_ctrlexpr))
        ctrlexpr_val = value_of(ctrlexpr_var)
        notify_variable_value_referred(explicit_ctrlexpr, ctrlexpr_var)
        notify_sequence_point_reached(SequencePoint.new(explicit_ctrlexpr))
        notify_for_ctrlexpr_evaled(node, ctrlexpr_val)
      else
        ctrlexpr_val = scalar_value_of_true
      end

      case
      when ctrlexpr_val.must_be_true?
        interpret_for_body_statement(node, org_ctrlexpr, ctrlexpr, true)
      when ctrlexpr_val.may_be_true?
        interpret_for_body_statement(node, org_ctrlexpr, ctrlexpr, false)
      end
    ensure
      notify_for_stmt_ended(node)
    end

    def visit_c99_for_statement(node)
      checkpoint(node.location)

      scoped_eval do
        interpret(node.declaration)

        node.executed = true
        notify_c99_for_stmt_started(node)

        widen_varying_variable_value_domain(node)
        org_ctrlexpr, ctrlexpr = node.deduct_controlling_expression

        node.condition_statement.executed = true
        if explicit_ctrlexpr = node.condition_statement.expression
          ctrlexpr_var = object_to_variable(interpret(explicit_ctrlexpr))
          ctrlexpr_val = value_of(ctrlexpr_var)
          notify_variable_value_referred(explicit_ctrlexpr, ctrlexpr_var)
          notify_sequence_point_reached(SequencePoint.new(explicit_ctrlexpr))
          notify_c99_for_ctrlexpr_evaled(node, ctrlexpr_val)
        else
          ctrlexpr_val = scalar_value_of_true
        end

        case
        when ctrlexpr_val.must_be_true?
          interpret_for_body_statement(node, org_ctrlexpr, ctrlexpr, true)
        when ctrlexpr_val.may_be_true?
          interpret_for_body_statement(node, org_ctrlexpr, ctrlexpr, false)
        end
      end
    ensure
      notify_c99_for_stmt_ended(node)
    end

    def visit_goto_statement(node)
      checkpoint(node.location)

      # TODO: Must implement goto semantics.
      node.executed = true
      notify_goto_stmt_evaled(node, node.identifier.value)
    end

    def visit_continue_statement(node)
      checkpoint(node.location)

      node.executed = true
      BreakEvent.of_continue.throw
    end

    def visit_break_statement(node)
      checkpoint(node.location)

      node.executed = true
      BreakEvent.of_break.throw
    end

    def visit_return_statement(node)
      checkpoint(node.location)

      node.executed = true

      unless node.expression
        notify_return_stmt_evaled(node, nil)
        BreakEvent.of_return.throw
      end

      obj = interpret(node.expression)
      var = object_to_variable(obj)
      unless var == obj
        notify_implicit_conv_performed(node.expression, obj, var)
      end

      notify_variable_value_referred(node.expression, var)

      if active_fun = interpreter._active_function and
          retn_type = active_fun.type.return_type
        if var.type.same_as?(retn_type)
          conved = var
        else
          conved = do_conversion(var, retn_type) || create_tmpvar(retn_type)
          notify_implicit_conv_performed(node.expression, var, conved)
        end
      else
        conved = var
      end

      notify_sequence_point_reached(SequencePoint.new(node))
      notify_return_stmt_evaled(node, var)
      BreakEvent.of_return.throw
    end

    private
    def interpret_for_body_statement(node, org_ctrlexpr, ctrlexpr, complete)
      enter_iteration_statement(org_ctrlexpr)

      if complete
        branch_opts = [NARROWING, FINAL, IMPLICIT_COND, COMPLETE]
      else
        branch_opts = [NARROWING, FINAL, IMPLICIT_COND]
      end

      branched_eval(ctrlexpr, *branch_opts) do
        interpret(node.body_statement)
        interpret(node.expression) if node.expression

        if explicit_ctrlexpr = node.condition_statement.expression
          # NOTE: To avoid that value of the controlling variable is marked
          #       as updated at end of the for-statement.  Value of the
          #       controlling variable is referred by the controlling
          #       expression at the last iteration.
          # FIXME: This re-interpretation of the controlling expression may
          #        cause duplicative warning messages.
          # FIXME: This re-interpretation of the controlling expression always
          #        causes "logical-expression must be false" warnings about a
          #        one-time-for-loop.  To avoid this, now, workarounds are in
          #        builtin code checks W0609 and W0610.
          var = object_to_variable(interpret(explicit_ctrlexpr))
          notify_variable_value_referred(explicit_ctrlexpr, var)
          notify_sequence_point_reached(SequencePoint.new(explicit_ctrlexpr))
        end
      end
    ensure
      leave_iteration_statement(org_ctrlexpr)
    end

    def uninitialize_block_local_variables(generic_labeled_stmt)
      related_goto_stmts = generic_labeled_stmt.referrers
      return if related_goto_stmts.empty?

      local_variables.each do |var|
        var_def = var.declarations_and_definitions.first

        anterior_goto_stmts = related_goto_stmts.select { |goto_stmt|
          goto_stmt.location.line_no < var_def.location.line_no
        }

        unless anterior_goto_stmts.empty?
          var.value.enter_versioning_group
          var.value.begin_versioning
          var.uninitialize!
          var.value.end_versioning
          var.value.leave_versioning_group(true)
        end
      end
    end

    def widen_varying_variable_value_domain(iteration_stmt)
      varying_vars = {}
      iteration_stmt.varying_variable_names.each do |name|
        if var = variable_named(name)
          varying_vars[var] = var.value.dup
          var.widen_value_domain!(Operator::EQ, var.type.arbitrary_value)
        end
      end

      varying_vars.each do |var, org_val|
        case deduct_variable_varying_path(var, iteration_stmt)
        when :increase
          var.narrow_value_domain!(Operator::GE, org_val)
        when :decrease
          var.narrow_value_domain!(Operator::LE, org_val)
        end
      end
    end

    def deduct_variable_varying_path(var, iteration_stmt)
      histogram = iteration_stmt.varying_expressions.map { |expr|
        case expr
        when SimpleAssignmentExpression
          deduct_ctrl_var_path_by_simple_assignment_expr(var, expr)
        when CompoundAssignmentExpression
          deduct_ctrl_var_path_by_compound_assignment_expr(var, expr)
        when PrefixIncrementExpression, PostfixIncrementExpression
          expr.operand.identifier.value == var.name ? :increase : nil
        when PrefixDecrementExpression, PostfixDecrementExpression
          expr.operand.identifier.value == var.name ? :decrease : nil
        else
          nil
        end
      }.compact.each_with_object(Hash.new(0)) { |dir, hash| hash[dir] += 1 }

      if histogram.empty?
        nil
      else
        histogram[:decrease] <= histogram[:increase] ? :increase : :decrease
      end
    end

    def deduct_ctrl_var_path_by_simple_assignment_expr(var, expr)
      return nil unless expr.lhs_operand.identifier.value == var.name

      additive_exprs = collect_additive_expressions(expr.rhs_operand)
      histogram = additive_exprs.map { |additive_expr|
        if additive_expr.lhs_operand.kind_of?(ObjectSpecifier)
          lhs_name = additive_expr.lhs_operand.identifier.value
        end
        if additive_expr.rhs_operand.kind_of?(ObjectSpecifier)
          rhs_name = additive_expr.rhs_operand.identifier.value
        end

        next nil unless lhs_name == var.name || rhs_name == var.name

        case additive_expr.operator.type
        when "+"
          :increase
        when "-"
          :decrease
        else
          nil
        end
      }.compact.each_with_object(Hash.new(0)) { |dir, hash| hash[dir] += 1 }

      if histogram.empty?
        nil
      else
        histogram[:decrease] <= histogram[:increase] ? :increase : :decrease
      end
    end

    def deduct_ctrl_var_path_by_compound_assignment_expr(var, expr)
      return nil unless expr.lhs_operand.identifier.value == var.name

      case expr.operator.type
      when "+="
        :increase
      when "-="
        :decrease
      else
        nil
      end
    end

    def effective_ctrlexpr
      @effective_ctrlexpr_stack.last
    end

    def enter_iteration_statement(effective_ctrlexpr)
      @effective_ctrlexpr_stack.push(effective_ctrlexpr)
    end

    def leave_iteration_statement(effective_ctrlexpr)
      @effective_ctrlexpr_stack.pop
    end
  end

  class SwitchStatementInterpreter < SubInterpreter
    include BranchOptions
    include BranchGroupOptions

    def initialize(owner)
      super(owner, SwitchStatement)
    end

    def visit_switch_statement(node)
      checkpoint(node.location)

      node.executed = true
      notify_switch_stmt_started(node)

      ctrlexpr = node.expression
      ctrlexpr_var = object_to_variable(interpret(ctrlexpr))
      notify_switch_ctrlexpr_evaled(node, ctrlexpr_var)
      notify_variable_value_referred(ctrlexpr, ctrlexpr_var)

      execute_switch_body(ctrlexpr_var, node.statement)
      notify_switch_stmt_ended(node)
    end

    private
    def execute_switch_body(var, node)
      checkpoint(node.location)

      node.executed = true
      scoped_eval do
        begin
          notify_block_started(node)
          execute_switch_branches(var, node.block_items)
        ensure
          notify_block_ended(node)
        end
      end
    end

    def execute_switch_branches(var, block_items)
      if complete?(block_items)
        base_opts = [SMOTHER_BREAK, IMPLICIT_COND, NARROWING, COMPLETE]
      else
        base_opts = [SMOTHER_BREAK, IMPLICIT_COND, NARROWING]
      end

      idx = 0
      while block_item = block_items[idx]
        case block_item
        when GenericLabeledStatement
          block_item.executed = true
          notify_label_defined(block_item)
          block_item = block_item.statement
          redo
        when CaseLabeledStatement, DefaultLabeledStatement
          if final_branch?(block_items, idx)
            opts = base_opts + [FINAL]
          else
            opts = base_opts.dup
          end
          idx = execute_branch(block_item, block_items, idx, opts)
          break unless idx
        else
          interpret(block_item)
          idx += 1
        end
      end
    end

    def execute_branch(labeled_stmt, block_items, idx, branch_opts)
      ctrlexpr = labeled_stmt.normalized_expression
      ctrlexpr_val = value_of(interpret(ctrlexpr, QUIET))

      case labeled_stmt
      when DefaultLabeledStatement
        branch_opts.push(COMPLEMENTAL)
      end

      case
      when ctrlexpr_val.must_be_true?
        branch_opts.push(FINAL, COMPLETE)
      when ctrlexpr_val.must_be_false?
        # NOTE: To end the current branch group of switch-statement if this
        #       case-clause is the final one.
        branched_eval(ctrlexpr, *branch_opts) {}
        return seek_next_branch(block_items, idx)
      end

      branched_eval(ctrlexpr, *branch_opts) do |branch|
        case stmt = labeled_stmt.statement
        when CaseLabeledStatement, DefaultLabeledStatement
          # NOTE: Consecutive label appears!
          enter_next_clause(stmt, block_items, idx, branch, branch_opts)
        end
        interpret(labeled_stmt)
        idx += 1

        while item = block_items[idx]
          case item
          when GenericLabeledStatement
            item.executed = true
            notify_label_defined(item)
            item = item.statement
            redo
          when CaseLabeledStatement, DefaultLabeledStatement
            # NOTE: Fall through!
            enter_next_clause(item, block_items, idx, branch, branch_opts)
          end
          interpret(item)
          idx += 1
        end
        # NOTE: To simulate implicit breaking of the last case-clause.
        BreakEvent.of_break.throw
      end

      branch_opts.include?(FINAL) ? nil : seek_next_branch(block_items, idx)
    end

    def enter_next_clause(labeled_stmt, block_items, idx, branch, branch_opts)
      prepare_fall_through(branch, branch_opts, labeled_stmt)

      case labeled_stmt
      when DefaultLabeledStatement
        branch_opts.push(COMPLEMENTAL)
      end

      branch_opts.push(FINAL) if final_branch?(block_items, idx)
      branch.add_options(*branch_opts)

      case stmt = labeled_stmt.statement
      when CaseLabeledStatement, DefaultLabeledStatement
        enter_next_clause(stmt, block_items, idx, branch, branch_opts)
      end
    end

    def prepare_fall_through(branch, branch_opts, labeled_stmt)
      value_domain_manip = nil

      branch.restart_versioning do
        ctrlexpr = labeled_stmt.normalized_expression
        ctrlexpr_val = value_of(interpret(ctrlexpr, QUIET))

        case
        when ctrlexpr_val.must_be_true?
          branch_opts.push(FINAL, COMPLETE)
        when ctrlexpr_val.must_be_false?
          return
        end

        value_domain_manip =
          branch.controlling_expression.ensure_true_by_widening(ctrlexpr)
      end

      value_domain_manip.commit!
    end

    def final_branch?(block_items, idx)
      idx += 1
      while block_item = block_items[idx]
        case block_item
        when GenericLabeledStatement
          block_item = block_item.statement
          redo
        when CaseLabeledStatement, DefaultLabeledStatement
          return false
        else
          idx += 1
        end
      end
      true
    end

    def complete?(block_items)
      block_items.any? do |block_item|
        case block_item
        when GenericLabeledStatement, CaseLabeledStatement
          block_item = block_item.statement
          redo
        when DefaultLabeledStatement
          true
        else
          false
        end
      end
    end

    def seek_next_branch(block_items, idx)
      idx += 1
      while block_item = block_items[idx]
        case block_item
        when GenericLabeledStatement
          notify_label_defined(block_item)
          block_item = block_item.statement
          redo
        when CaseLabeledStatement, DefaultLabeledStatement
          return idx
        else
          idx += 1
        end
      end
      nil
    end
  end

  class ExpressionInterpreter < SubInterpreter
    include ExpressionEvaluator
    include BranchOptions
    include BranchGroupOptions

    def initialize(owner)
      super(owner, Expression)
    end

    def self.def_eval_with_sequence_point(method_name)
      class_eval <<-EOS
        def #{method_name}(node)
          super
        ensure
          if seqp = node.subsequent_sequence_point
            notify_sequence_point_reached(seqp)
          end
        end
      EOS
    end
    private_class_method :def_eval_with_sequence_point

    def_eval_with_sequence_point :visit_error_expression
    def_eval_with_sequence_point :visit_object_specifier
    def_eval_with_sequence_point :visit_constant_specifier
    def_eval_with_sequence_point :visit_string_literal_specifier
    def_eval_with_sequence_point :visit_null_constant_specifier
    def_eval_with_sequence_point :visit_grouped_expression
    def_eval_with_sequence_point :visit_array_subscript_expression
    def_eval_with_sequence_point :visit_function_call_expression
    def_eval_with_sequence_point :visit_member_access_by_value_expression
    def_eval_with_sequence_point :visit_member_access_by_pointer_expression
    def_eval_with_sequence_point :visit_bit_access_by_value_expression
    def_eval_with_sequence_point :visit_bit_access_by_pointer_expression
    def_eval_with_sequence_point :visit_postfix_increment_expression
    def_eval_with_sequence_point :visit_postfix_decrement_expression
    def_eval_with_sequence_point :visit_compound_literal_expression
    def_eval_with_sequence_point :visit_prefix_increment_expression
    def_eval_with_sequence_point :visit_prefix_decrement_expression
    def_eval_with_sequence_point :visit_address_expression
    def_eval_with_sequence_point :visit_indirection_expression
    def_eval_with_sequence_point :visit_unary_arithmetic_expression
    def_eval_with_sequence_point :visit_sizeof_expression
    def_eval_with_sequence_point :visit_sizeof_type_expression
    def_eval_with_sequence_point :visit_alignof_expression
    def_eval_with_sequence_point :visit_alignof_type_expression
    def_eval_with_sequence_point :visit_cast_expression
    def_eval_with_sequence_point :visit_multiplicative_expression
    def_eval_with_sequence_point :visit_additive_expression
    def_eval_with_sequence_point :visit_shift_expression
    def_eval_with_sequence_point :visit_relational_expression
    def_eval_with_sequence_point :visit_equality_expression
    def_eval_with_sequence_point :visit_and_expression
    def_eval_with_sequence_point :visit_exclusive_or_expression
    def_eval_with_sequence_point :visit_inclusive_or_expression
    def_eval_with_sequence_point :visit_logical_and_expression
    def_eval_with_sequence_point :visit_logical_or_expression
    def_eval_with_sequence_point :visit_simple_assignment_expression
    def_eval_with_sequence_point :visit_compound_assignment_expression
    def_eval_with_sequence_point :visit_comma_separated_expression

    def visit_conditional_expression(node)
      checkpoint(node.location)

      ctrlexpr = node.condition
      ctrlexpr_var = object_to_variable(interpret(ctrlexpr))
      ctrlexpr_val = value_of(ctrlexpr_var)
      notify_variable_value_referred(ctrlexpr, ctrlexpr_var)
      notify_sequence_point_reached(ctrlexpr.subsequent_sequence_point)
      ctrlexpr = ctrlexpr.to_normalized_logical

      then_var = nil
      if ctrlexpr_val.may_be_true?
        branched_eval(ctrlexpr, NARROWING, IMPLICIT_COND) do
          then_var = object_to_variable(interpret(node.then_expression))
        end
      end

      else_var = nil
      if ctrlexpr_val.may_be_false?
        branched_eval(nil, NARROWING, FINAL, COMPLETE) do
          else_var = object_to_variable(interpret(node.else_expression))
        end
      else
        branched_eval(nil, NARROWING, FINAL, COMPLETE) {}
      end

      case
      when then_var && else_var
        res_val = then_var.value.single_value_unified_with(else_var.value)
        res_var = create_tmpvar(then_var.type, res_val)
        # FIXME: Not to over-warn about discarding a function return value.
        #        Because the unified result is a new temporary variable, it is
        #        impossible to relate a reference of the unified result and a
        #        reference of the 2nd or 3rd expression's value.
        notify_variable_value_referred(node, then_var)
        notify_variable_value_referred(node, else_var)
      when then_var
        res_var = then_var
      when else_var
        res_var = else_var
      else
        # FIXME: Nevertheless, the then-expression is not reachable, the branch
        #        execution check may fail in evaluation of the else branch.
        res_var = create_tmpvar
      end

      notify_conditional_expr_evaled(node, ctrlexpr_var, res_var)
      res_var
    ensure
      if seqp = node.subsequent_sequence_point
        notify_sequence_point_reached(seqp)
      end
    end
  end

end
end
