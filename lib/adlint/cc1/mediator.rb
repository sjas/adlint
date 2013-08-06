# C interpreter mediator.
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

require "adlint/traits"
require "adlint/cc1/type"
require "adlint/cc1/object"
require "adlint/cc1/enum"
require "adlint/cc1/syntax"

module AdLint #:nodoc:
module Cc1 #:nodoc:

  module TypeTableMediator
    # NOTE: Host class must respond to #type_table.

    include StandardTypeCatalogAccessor

    extend Forwardable

    def_delegator :type_table, :lookup, :type_of
    def_delegator :type_table, :undeclared_type
    def_delegator :type_table, :wchar_t
    def_delegator :type_table, :array_type
    def_delegator :type_table, :function_type
    def_delegator :type_table, :bitfield_type
    def_delegator :type_table, :pointer_type
    def_delegator :type_table, :qualified_type

    private
    def standard_type_catalog
      type_table.standard_type_catalog
    end
  end

  module MemoryPoolMediator
    # NOTE: Host class must respond to #memory_pool.

    extend Forwardable

    def_delegator :memory_pool, :lookup, :memory_at

    def pointee_of(ptr)
      # FIXME: This method should return multiple objects, because domain of
      #        the pointer_value may have multiple address values.
      #
      # ptr.value.to_enum.map { |addr|
      #   mem = memory_at(addr) ? mem.binding.object : nil
      # }.compact

      if ptr.value.definite?
        if addr = ptr.value.to_enum.first and mem = memory_at(addr)
          obj = mem.binding.object
          if obj.variable? or
              obj.function? && ptr.type.unqualify.base_type.function?
            return obj
          end
        end
      end
      nil
    end
  end

  module VariableTableMediator
    # NOTE: Host class must respond to #variable_table.

    extend Forwardable

    def_delegator :variable_table, :lookup, :variable_named
    def_delegator :variable_table, :declare, :declare_variable
    def_delegator :variable_table, :define, :define_variable
    def_delegator :variable_table, :storage_duration_of
    def_delegator :variable_table, :designators, :variable_designators

    def local_variables
      variable_table.all_named_variables.select { |var| var.scope.local? }
    end

    def create_tmpvar(type = undeclared_type, val = type.undefined_value)
      variable_table.define_temporary(type, val)
    end
  end

  module FunctionTableMediator
    # NOTE: The host class of this module must include TypeTableMediator.
    # NOTE: Host class must respond to #function_table.

    extend Forwardable

    def_delegator :function_table, :lookup, :function_named
    def_delegator :function_table, :designators, :function_designators

    def declare_explicit_function(fun_dcl)
      function_table.declare_explicitly(fun_dcl)
    end

    def declare_implicit_function(name)
      function_table.declare_implicitly(
        ImplicitFunction.new(default_function_type, name))
    end

    def define_explicit_function(fun_dcl_or_def)
      function_table.define(ExplicitFunction.new(fun_dcl_or_def))
    end

    def define_anonymous_function(type)
      function_table.define(AnonymousFunction.new(type))
    end

    private
    def default_function_type
      function_type(int_t, [])
    end
  end

  module EnumeratorTableMediator
    # NOTE: Host class must respond to #enumerator_table.

    extend Forwardable

    def_delegator :enumerator_table, :lookup, :enumerator_named
    def_delegator :enumerator_table, :define, :define_enumerator
    def_delegator :enumerator_table, :designators, :enumerator_designators
  end

  module NotifierMediator
    # NOTE: Host class must respond to #interpreter.

    extend Forwardable

    def_delegator :interpreter, :notify_variable_declared
    def_delegator :interpreter, :notify_variable_defined
    def_delegator :interpreter, :notify_variable_initialized
    def_delegator :interpreter, :notify_explicit_function_declared
    def_delegator :interpreter, :notify_explicit_function_defined
    def_delegator :interpreter, :notify_struct_declared
    def_delegator :interpreter, :notify_union_declared
    def_delegator :interpreter, :notify_enum_declared
    def_delegator :interpreter, :notify_typedef_declared
    def_delegator :interpreter, :notify_function_started
    def_delegator :interpreter, :notify_function_ended
    def_delegator :interpreter, :notify_parameter_defined
    def_delegator :interpreter, :notify_variable_referred
    def_delegator :interpreter, :notify_constant_referred
    def_delegator :interpreter, :notify_variable_value_referred
    def_delegator :interpreter, :notify_variable_value_updated
    def_delegator :interpreter, :notify_function_referred
    def_delegator :interpreter, :notify_implicit_function_declared
    def_delegator :interpreter, :notify_sizeof_expr_evaled
    def_delegator :interpreter, :notify_sizeof_type_expr_evaled
    def_delegator :interpreter, :notify_explicit_conv_performed
    def_delegator :interpreter, :notify_implicit_conv_performed
    def_delegator :interpreter, :notify_address_derivation_performed
    def_delegator :interpreter, :notify_array_subscript_expr_evaled
    def_delegator :interpreter, :notify_function_call_expr_evaled
    def_delegator :interpreter, :notify_unary_arithmetic_expr_evaled
    def_delegator :interpreter, :notify_multiplicative_expr_evaled
    def_delegator :interpreter, :notify_additive_expr_evaled
    def_delegator :interpreter, :notify_shift_expr_evaled
    def_delegator :interpreter, :notify_relational_expr_evaled
    def_delegator :interpreter, :notify_equality_expr_evaled
    def_delegator :interpreter, :notify_and_expr_evaled
    def_delegator :interpreter, :notify_exclusive_or_expr_evaled
    def_delegator :interpreter, :notify_inclusive_or_expr_evaled
    def_delegator :interpreter, :notify_logical_and_expr_evaled
    def_delegator :interpreter, :notify_logical_or_expr_evaled
    def_delegator :interpreter, :notify_conditional_expr_evaled
    def_delegator :interpreter, :notify_address_expr_evaled
    def_delegator :interpreter, :notify_indirection_expr_evaled
    def_delegator :interpreter, :notify_member_access_expr_evaled
    def_delegator :interpreter, :notify_prefix_increment_expr_evaled
    def_delegator :interpreter, :notify_postfix_increment_expr_evaled
    def_delegator :interpreter, :notify_prefix_decrement_expr_evaled
    def_delegator :interpreter, :notify_postfix_decrement_expr_evaled
    def_delegator :interpreter, :notify_assignment_expr_evaled
    def_delegator :interpreter, :notify_expression_stmt_started
    def_delegator :interpreter, :notify_expression_stmt_ended
    def_delegator :interpreter, :notify_switch_stmt_started
    def_delegator :interpreter, :notify_switch_stmt_ended
    def_delegator :interpreter, :notify_while_stmt_started
    def_delegator :interpreter, :notify_while_stmt_ended
    def_delegator :interpreter, :notify_do_stmt_started
    def_delegator :interpreter, :notify_do_stmt_ended
    def_delegator :interpreter, :notify_for_stmt_started
    def_delegator :interpreter, :notify_for_stmt_ended
    def_delegator :interpreter, :notify_c99_for_stmt_started
    def_delegator :interpreter, :notify_c99_for_stmt_ended
    def_delegator :interpreter, :notify_goto_stmt_evaled
    def_delegator :interpreter, :notify_return_stmt_evaled
    def_delegator :interpreter, :notify_implicit_return_evaled
    def_delegator :interpreter, :notify_if_ctrlexpr_evaled
    def_delegator :interpreter, :notify_if_else_ctrlexpr_evaled
    def_delegator :interpreter, :notify_switch_ctrlexpr_evaled
    def_delegator :interpreter, :notify_case_ctrlexpr_evaled
    def_delegator :interpreter, :notify_while_ctrlexpr_evaled
    def_delegator :interpreter, :notify_do_ctrlexpr_evaled
    def_delegator :interpreter, :notify_for_ctrlexpr_evaled
    def_delegator :interpreter, :notify_c99_for_ctrlexpr_evaled
    def_delegator :interpreter, :notify_label_defined
    def_delegator :interpreter, :notify_block_started
    def_delegator :interpreter, :notify_block_ended
    def_delegator :interpreter, :notify_branch_started
    def_delegator :interpreter, :notify_branch_ended
    def_delegator :interpreter, :notify_translation_unit_started
    def_delegator :interpreter, :notify_translation_unit_ended
    def_delegator :interpreter, :notify_sequence_point_reached
  end

  module InterpreterMediator
    # NOTE: Host class must respond to #interpreter.

    include TypeTableMediator
    include MemoryPoolMediator
    include VariableTableMediator
    include FunctionTableMediator
    include EnumeratorTableMediator
    include ArithmeticAccessor

    include InterpObjectBridge
    include InterpSyntaxBridge

    def interpret(node, *opts)
      interpreter.execute(node, *opts)
    end

    def reset_environment
      environment.reset
    end

    def current_branch
      environment.current_branch
    end

    def scalar_value_of(numeric)
      ScalarValue.of(numeric, logical_right_shift?)
    end

    def scalar_value_of_true
      ScalarValue.of_true(logical_right_shift?)
    end

    def scalar_value_of_false
      ScalarValue.of_false(logical_right_shift?)
    end

    def scalar_value_of_arbitrary
      ScalarValue.of_arbitrary(logical_right_shift?)
    end

    def constant_expression?(expr)
      expr.constant?(_interp_syntax_bridge_)
    end

    def object_to_variable(obj, init_or_expr = nil)
      obj.to_variable(_interp_object_bridge_).tap do |var|
        if init_or_expr && !obj.type.pointer? && var.type.pointer?
          notify_address_derivation_performed(init_or_expr, obj, var)
        end
      end
    end

    def object_to_pointer(obj, init_or_expr = nil)
      obj.to_pointer(_interp_object_bridge_).tap do |ptr|
        if init_or_expr
          notify_address_derivation_performed(init_or_expr, obj, ptr)
        end
      end
    end

    def value_of(obj)
      obj.to_value(_interp_object_bridge_)
    end

    def pointer_value_of(obj)
      obj.to_pointer_value(_interp_object_bridge_)
    end

    private
    def scoped_eval(&block)
      environment.enter_scope
      yield
    ensure
      environment.leave_scope
    end

    def branched_eval(expr = nil, *opts, &block)
      current_branch = environment.enter_branch(*opts)
      interpreter.notify_branch_started(current_branch)
      current_branch.execute(interpreter, expr, &block)
    ensure
      interpreter.notify_branch_ended(current_branch)
      environment.leave_branch_group if current_branch.final?
      environment.leave_branch
    end

    def resolve_unresolved_type(node)
      interpreter.type_resolver.resolve(node) if node.type.unresolved?
    end

    extend Forwardable

    def_delegator :environment, :type_table
    private :type_table

    def_delegator :environment, :memory_pool
    private :memory_pool

    def_delegator :environment, :variable_table
    private :variable_table

    def_delegator :environment, :function_table
    private :function_table

    def_delegator :environment, :enumerator_table
    private :enumerator_table

    def_delegator :interpreter, :environment
    private :environment

    def_delegator :interpreter, :traits
    private :traits
  end

end
end
