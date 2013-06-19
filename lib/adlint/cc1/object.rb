# C runtime object model.
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

require "adlint/util"
require "adlint/cc1/syntax"
require "adlint/cc1/value"
require "adlint/cc1/scope"
require "adlint/cc1/seqp"
require "adlint/cc1/operator"

module AdLint #:nodoc:
module Cc1 #:nodoc:

  module Bindable
    attr_accessor :binding

    def bind_to(target)
      case target
      when Memory
        Binding.bind(self, target)
      when Object
        Binding.bind(target, self)
      end
    end

    def be_alias_to(mem)
      case mem
      when Memory
        Binding.create_alias(self, mem)
      else
        raise TypeError, "an object cannot be an alias to other objects."
      end
    end
  end

  class Binding
    def self.bind(obj, mem)
      binding = new(obj, mem)
      obj.binding = binding
      mem.binding = binding
      binding
    end

    def self.create_alias(obj, mem)
      binding = new(obj, mem)
      obj.binding = binding
      binding
    end

    def initialize(obj, mem)
      @object = obj
      @memory = mem
    end
    private_class_method :new

    attr_reader :object
    attr_reader :memory
  end

  class Object
    include Bindable

    def initialize(dcl_or_def = nil)
      @declarations_and_definitions = [dcl_or_def].compact
    end

    attr_reader :declarations_and_definitions

    def storage_class_specifiers
      @declarations_and_definitions.map { |dcl_or_def|
        dcl_or_def.storage_class_specifier
      }.compact
    end

    def declared_as_extern?
      sc_spec = first_storage_class_specifier
      sc_spec.nil? || sc_spec.type == :EXTERN
    end

    def declared_as_static?
      sc_spec = first_storage_class_specifier and sc_spec.type == :STATIC
    end

    def declared_as_auto?
      sc_spec = first_storage_class_specifier and sc_spec.type == :AUTO
    end

    def declared_as_register?
      sc_spec = first_storage_class_specifier and sc_spec.type == :REGISTER
    end

    def designated_by_lvalue?
      subclass_responsibility
    end

    def named?
      subclass_responsibility
    end

    def temporary?
      subclass_responsibility
    end

    def function?
      subclass_responsibility
    end

    def variable?
      subclass_responsibility
    end

    private
    def first_storage_class_specifier
      if @declarations_and_definitions.empty?
        nil
      else
        @declarations_and_definitions.first.storage_class_specifier
      end
    end
  end

  module InterpObjectBridge
    # NOTE: InterpreterMediator includes this module to bridge runtime object
    #       creator to this layer.

    def _interp_object_bridge_
      {
        create_tmpvar:   method(:create_tmpvar),
        scalar_value_of: method(:scalar_value_of)
      }
    end
  end

  class TypedObject < Object
    def initialize(type, dcl_or_def = nil)
      super(dcl_or_def)
      @type = type
    end

    attr_reader :type

    def to_variable(interp_bridge)
      if function? or variable? && @type.array?
        to_pointer(interp_bridge)
      else
        self
      end
    end

    def to_pointer(interp_bridge)
      if @type.array?
        ptr_type = @type.type_table.pointer_type(@type.base_type)
      else
        ptr_type = @type.type_table.pointer_type(@type)
      end
      interp_bridge[:create_tmpvar][ptr_type, to_pointer_value(interp_bridge)]
    end

    def to_value(interp_bridge)
      if @type.array? || @type.function?
        to_pointer_value(interp_bridge)
      else
        value.to_single_value
      end
    end

    def to_pointer_value(interp_bridge)
      interp_bridge[:scalar_value_of][binding.memory.address]
    end
  end

  # == DESCRIPTION
  # === Variable class hierarchy
  #  Variable
  #    <-- ScopedVariable
  #          <-- OuterVariable
  #                <-- NamedVariable --------> Nameable <<module>>
  #                      <-- AliasVariable        ^
  #                <-- TemporaryVariable          |
  #                <-- InnerVariable -------------+
  #                      <-- ArrayElementVariable
  #                      <-- CompositeMemberVariable
  class Variable < TypedObject
    def initialize(mem, dcl_or_def, type)
      super(type, dcl_or_def)
      relate_to_memory(mem)
    end

    def function?
      false
    end

    def variable?
      true
    end

    def name
      subclass_responsibility
    end

    def named?
      false
    end

    def inner?
      subclass_responsibility
    end

    def outer?
      !inner?
    end

    def value
      binding.memory.read
    end

    def assign!(val)
      # NOTE: Length of the incomplete array type should be deducted while
      #       initializer evaluation.  So, adjustment of the assigning value
      #       can be done at this point by Value#coerce_to(type).
      # NOTE: Domain of the assigning value must be narrowed before writing to
      #       the memory by Value#coerce_to(type).
      binding.memory.write(val.coerce_to(type))
    end

    def uninitialize!
      assign!(self.type.undefined_value)
    end

    def narrow_value_domain!(op, val)
      assign!(type.arbitrary_value) unless self.value

      self.value.narrow_domain!(op, val.coerce_to(type))
      # NOTE: Write via memory to correctly propagate inner variable's
      #       mutation to its outer variable.
      binding.memory.write(self.value)

      self.value.exist?
    end

    def widen_value_domain!(op, val)
      assign!(type.nil_value) unless self.value

      self.value.widen_domain!(op, val.coerce_to(type))
      # NOTE: Write via memory to correctly propagate inner variable's
      #       mutation to its outer variable.
      binding.memory.write(self.value)

      self.value.exist?
    end

    def enter_value_versioning_group
      value.enter_versioning_group
    end

    def leave_value_versioning_group(raise_complement)
      value.leave_versioning_group(raise_complement)
    end

    def begin_value_versioning
      value.begin_versioning
    end

    def end_value_versioning
      value.end_versioning
    end

    def thin_latest_value_version!(with_rollback)
      value.thin_latest_version!(with_rollback)
    end

    def rollback_all_value_versions!
      value.rollback_all_versions!
    end

    private
    def relate_to_memory(mem)
      bind_to(mem)
    end
  end

  class ScopedVariable < Variable
    def initialize(mem, dcl_or_def, type, scope)
      super(mem, dcl_or_def, type)
      @scope = scope
    end

    attr_accessor :scope

    def declared_as_extern?
      if @scope.global?
        super
      else
      sc_spec = first_storage_class_specifier and sc_spec.type == :EXTERN
      end
    end

    def declared_as_auto?
      if @scope.global?
        super
      else
        sc_spec = first_storage_class_specifier
        sc_spec.nil? || sc_spec.type == :AUTO
      end
    end
  end

  class OuterVariable < ScopedVariable
    def initialize(mem, dcl_or_def, type, scope)
      super(mem, dcl_or_def, type, scope)
      # TODO: If too slow, make an index of inner variables.
      @inner_variables = create_inner_variables(type.unqualify, scope)
    end

    def enter_value_versioning_group
      super
      if @inner_variables
        @inner_variables.each do |inner|
          inner.enter_value_versioning_group
        end
      end
    end

    def leave_value_versioning_group(raise_complement)
      super
      if @inner_variables
        @inner_variables.each do |inner|
          inner.leave_value_versioning_group(raise_complement)
        end
      end
    end

    def begin_value_versioning
      super
      if @inner_variables
        @inner_variables.each do |inner|
          inner.begin_value_versioning
        end
      end
    end

    def end_value_versioning
      super
      if @inner_variables
        @inner_variables.each do |inner|
          inner.end_value_versioning
        end
      end
    end

    def thin_latest_value_version!(with_rollback)
      super
      if @inner_variables
        @inner_variables.each do |inner|
          inner.thin_latest_value_version!(with_rollback)
        end
      end
    end

    def inner?
      false
    end

    def inner_variable_at(idx)
      if @type.array?
        # TODO: If linear searching is too slow, use an index of inner
        #       variables.
        target_name = ArrayElementVariable.component_name_of(idx)
        @inner_variables.find { |inner| inner.component_name == target_name }
      else
        nil
      end
    end

    def inner_variable_named(name)
      if @type.composite?
        # TODO: If linear searching is too slow, use an index of inner
        #       variables.
        target_name = CompositeMemberVariable.component_name_of(name)
        @inner_variables.find { |inner| inner.component_name == target_name }
      else
        nil
      end
    end

    private
    def create_inner_variables(type, scope)
      case
      when type.array?
        create_array_elements(type, scope, binding.memory)
      when type.composite?
        create_composite_members(type, scope, binding.memory)
      else
        nil
      end
    end

    def create_array_elements(type, scope, mem)
      offset = 0
      type.impl_length.times.map do |idx|
        win = mem.create_window(offset, type.base_type.aligned_byte_size)
        offset += win.byte_size
        ArrayElementVariable.new(win, self, type.base_type, idx)
      end
    end

    def create_composite_members(type, scope, mem)
      offset = 0
      type.members.map do |memb|
        win = mem.create_window(offset, memb.type.aligned_byte_size)
        offset += win.byte_size
        CompositeMemberVariable.new(win, self, memb.type, memb.name)
      end
    end
  end

  module Nameable
    attr_reader :name

    def named?
      true
    end

    private
    def name=(name)
      # NOTE: Private attr_writer to suppress `private attribute?' warning.
      @name = name
    end
  end

  class NamedVariable < OuterVariable
    include Nameable

    def initialize(mem, dcl_or_def, scope)
      self.name = dcl_or_def.identifier.value
      super(mem, dcl_or_def, dcl_or_def.type, scope)
    end

    def temporary?
      false
    end

    def designated_by_lvalue?
      true
    end

    # NOTE: This method should be overridden by PhantomVariable.
    def to_named_variable
      self
    end

    def pretty_print(pp)
      Summary.new(object_id, name, type, binding.memory).pretty_print(pp)
    end

    Summary = Struct.new(:object_id, :name, :type, :memory)
  end

  class TemporaryVariable < OuterVariable
    def initialize(mem, type, scope)
      super(mem, nil, type, scope)
    end

    def temporary?
      true
    end

    def designated_by_lvalue?
      false
    end

    def named?
      false
    end

    def pretty_print(pp)
      Summary.new(object_id, type, binding.memory).pretty_print(pp)
    end

    Summary = Struct.new(:object_id, :type, :memory)
  end

  class InnerVariable < OuterVariable
    include Nameable

    def initialize(mem, outer_var, type, component_name)
      @owner = outer_var
      @component_name = component_name
      self.name = create_qualified_name(outer_var, component_name)
      super(mem, nil, type, outer_var.scope)
    end

    attr_reader :owner
    attr_reader :component_name

    def storage_class_specifiers
      @owner.storage_class_specifiers
    end

    def declared_as_extern?
      @owner.declared_as_extern?
    end

    def declared_as_static?
      @owner.declared_as_static?
    end

    def declared_as_auto?
      @owner.declared_as_auto?
    end

    def declared_as_register?
      @owner.declared_as_register?
    end

    def named?
      @owner.named?
    end

    def temporary?
      @owner.temporary?
    end

    def inner?
      true
    end

    def designated_by_lvalue?
      true
    end

    def to_named_variable
      self
    end

    private
    def create_qualified_name(outer_var, component_name)
      if outer_var.named?
        "#{outer_var.name}#{component_name}"
      else
        "__adlint__tempvar#{component_name}"
      end
    end
  end

  class ArrayElementVariable < InnerVariable
    def self.component_name_of(idx)
      "[#{idx}]"
    end

    def initialize(mem, outer_var, type, idx)
      super(mem, outer_var, type, self.class.component_name_of(idx))
    end
  end

  class CompositeMemberVariable < InnerVariable
    def self.component_name_of(name)
      ".#{name}"
    end

    def initialize(mem, outer_var, type, name)
      super(mem, outer_var, type, self.class.component_name_of(name))
    end
  end

  class AliasVariable < NamedVariable
    def initialize(var)
      super(var.binding.memory,
            var.declarations_and_definitions.first, var.scope)
    end

    private
    def relate_to_memory(mem)
      be_alias_to(mem)
    end
  end

  class VariableTable
    def initialize(mem_pool)
      @memory_pool     = mem_pool
      @named_variables = [{}]
      @temp_variables  = [[]]
      @scope_stack     = [GlobalScope.new]
    end

    def all_named_variables
      @named_variables.map { |hash| hash.values }.flatten
    end

    def enter_scope
      @named_variables.push({})
      @temp_variables.push([])
      @scope_stack.push(Scope.new(@scope_stack.size))
    end

    def leave_scope
      @named_variables.pop.each_value do |var|
        @memory_pool.free(var.binding.memory)
      end
      @temp_variables.pop.each do |var|
        @memory_pool.free(var.binding.memory)
      end

      @scope_stack.pop
      rollback_all_global_variables_value! if current_scope.global?
    end

    def declare(dcl)
      if var = lookup(dcl.identifier.value)
        var.declarations_and_definitions.push(dcl)
        return var
      end

      # NOTE: External variable may have undefined values.
      define_variable(dcl, dcl.type, allocate_memory(dcl),
                      dcl.type.undefined_value)
    end

    def define(dcl_or_def, init_val = nil)
      if storage_duration_of(dcl_or_def) == :static && !dcl_or_def.type.const?
        # NOTE: Value of the inconstant static duration variable should be
        #       arbitrary because execution of its accessors are out of order.
        #       So, a value of the initializer should be ignored.
        init_val = dcl_or_def.type.arbitrary_value
      else
        init_val ||= dcl_or_def.type.undefined_value
      end

      if var = lookup(dcl_or_def.identifier.value)
        if var.scope == current_scope
          var.declarations_and_definitions.push(dcl_or_def)
          var.value.force_overwrite!(init_val.coerce_to(var.type))
          return var
        end
      end

      # NOTE: Domain of the init-value will be restricted by type's min-max in
      #       define_variable.
      define_variable(dcl_or_def, dcl_or_def.type,
                      allocate_memory(dcl_or_def), init_val)
    end

    def define_temporary(type, init_val)
      mem = @memory_pool.allocate_dynamic(type.aligned_byte_size)

      # NOTE: Domain of the init-value will be restricted by type's min-max in
      #       define_variable.
      define_variable(nil, type, mem, init_val)
    end

    def lookup(name_str)
      @named_variables.reverse_each do |hash|
        if var = hash[name_str]
          return var
        end
      end
      nil
    end

    def designators
      @named_variables.map { |hash| hash.keys }.flatten.to_set
    end

    def enter_variables_value_versioning_group
      @named_variables.each do |hash|
        hash.each_value { |var| var.enter_value_versioning_group }
      end
    end

    def leave_variables_value_versioning_group(raise_complement)
      @named_variables.each do |hash|
        hash.each_value do |var|
          var.leave_value_versioning_group(raise_complement)
        end
      end
    end

    def begin_variables_value_versioning
      @named_variables.each do |hash|
        hash.each_value { |var| var.begin_value_versioning }
      end
    end

    def end_variables_value_versioning
      @named_variables.each do |hash|
        hash.each_value { |var| var.end_value_versioning }
      end
    end

    def thin_latest_variables_value_version!(with_rollback)
      @named_variables.each do |hash|
        hash.each_value { |var| var.thin_latest_value_version!(with_rollback) }
      end
    end

    def storage_duration_of(dcl_or_def)
      # NOTE: The ISO C99 standard says;
      #
      # 6.2.2 Linkages of identifiers
      #
      # 1 An identifier declared in different scopes or in the same scope more
      #   than once can be made to refer to the same object or function by a
      #   process called linkage.  There are three kinds of linkage: external,
      #   internal, and none.
      #
      # 3 If the declaration of a file scope identifier for an object or a
      #   function contains the storage-class specifier static, the identifier
      #   has internal linkage.
      #
      # 4 For an identifier declared with the storage-class specifier extern in
      #   a scope in which a prior declaration of that identifier is visible,
      #   if the prior declaration specifies internal or external linkage, the
      #   linkage of the identifier at the later declaration is the same as the
      #   linkage specified at the prior declaration. If no prior declaration
      #   is visible, or if the prior declaration specifies no linkage, then
      #   the identifier has external linkage.
      #
      # 5 If the declaration of an identifier for a function has no
      #   storage-class specifier, its linkage is determined exactly as if it
      #   were declared with the storage-class specifier extern. If the
      #   declaration of an identifier for an object has file scope and no
      #   storage-class specifier, its linkage is external.
      #
      # 6 The following identifiers have no linkage: an identifier declared to
      #   be anything other than an object or a function; an identifier
      #   declared to be a function parameter; a block scope identifier for an
      #   object declared without the storage-class specifier extern.
      #
      # 6.2.4 Storage durations of objects
      #
      # 1 An object has a storage duration that determines its lifetime. There
      #   are three storage durations: static, automatic, and allocated.
      #   Allocated storage is described in 7.20.3.
      #
      # 3 An object whose identifier is declared with external or internal
      #   linkage, or with the storage-class specifier static has static
      #   storage duration. Its lifetime is the entire execution of the program
      #   and its stored value is initialized only once, prior to program
      #   startup.
      #
      # 4 An object whose identifier is declared with no linkage and without
      #   the storage-class specifier static has automatic storage duration.

      if sc_spec = dcl_or_def.storage_class_specifier and
          sc_spec.type == :EXTERN || sc_spec.type == :STATIC
        :static
      else
        current_scope.global? ? :static : :automatic
      end
    end

    private
    def define_variable(dcl_or_def, type, mem, init_val)
      var = create_variable(dcl_or_def, type, mem)
      var.assign!(init_val)

      if var.named?
        @named_variables.last[var.name] = var
      else
        @temp_variables.last.push(var)
      end

      var
    end

    def allocate_memory(dcl_or_def)
      byte_size = dcl_or_def.type.aligned_byte_size
      if storage_duration_of(dcl_or_def) == :static
        @memory_pool.allocate_static(byte_size)
      else
        @memory_pool.allocate_dynamic(byte_size)
      end
    end

    def create_variable(dcl_or_def, type, mem)
      if dcl_or_def
        NamedVariable.new(mem, dcl_or_def, current_scope)
      else
        TemporaryVariable.new(mem, type, current_scope)
      end
    end

    def current_scope
      @scope_stack.last
    end

    def rollback_all_global_variables_value!
      @named_variables.first.each_value do |var|
        # NOTE: Rollback effects recorded to global variables because execution
        #       of its accessors are out of order.
        var.rollback_all_value_versions!
      end
    end
  end

  # == DESCRIPTION
  # === Function class hierarchy
  #  Function
  #    <-- NamedFunction ------> Nameable <<module>>
  #          <-- ExplicitFunction
  #          <-- ImplicitFunction
  #          <-- BuiltinFunction
  #    <-- AnonymousFunction
  class Function < TypedObject
    def initialize(dcl_or_def, type)
      super(type, dcl_or_def)
    end

    def name
      subclass_responsibility
    end

    def named?
      false
    end

    def temporary?
      false
    end

    def variable?
      false
    end

    def function?
      true
    end

    def explicit?
      subclass_responsibility
    end

    def implicit?
      !explicit?
    end

    def builtin?
      subclass_responsibility
    end

    def call(interp, funcall_expr, args)
      assign_arguments_to_parameters(interp, args)
      return_values_via_pointer_arguments(interp, funcall_expr, args)

      if type.return_type.function?
        interp.create_tmpvar
      else
        retn_type = type.return_type
        interp.create_tmpvar(retn_type, retn_type.return_value)
      end
    end

    def signature
      subclass_responsibility
    end

    private
    def assign_arguments_to_parameters(interp, args)
      args.zip(type.parameter_types).each do |(arg, expr), param_type|
        arg_var = interp.object_to_variable(arg, expr)

        if param_type
          case
          when arg_var.type.pointer? && param_type.array?
            conved = interp.pointee_of(arg_var)
          when !arg_var.type.same_as?(param_type)
            conved = interp.do_conversion(arg_var, param_type) ||
                     interp.create_tmpvar(param_type)
            interp.notify_implicit_conv_performed(expr, arg_var, conved)
          else
            conved = arg_var
          end
        else
          conved = interp.do_default_argument_promotion(arg_var)
          if arg_var != conved
            interp.notify_implicit_conv_performed(expr, arg_var, conved)
          end
        end

        # NOTE: Value of the argument is referred when the assignment to the
        #       parameter is performed.
        interp.notify_variable_value_referred(expr, arg_var)
      end
    end

    def return_values_via_pointer_arguments(interp, funcall_expr, args)
      args.zip(type.parameter_types).each do |(arg, expr), param_type|
        next if param_type && param_type.void?
        next unless arg.variable? and arg.type.pointer? || arg.type.array?

        param_type = param_type.unqualify if param_type

        case
        when param_type.nil? && (arg.type.pointer? || arg.type.array?),
             param_type && param_type.pointer? && !param_type.base_type.const?,
             param_type && param_type.array? && !param_type.base_type.const?
        else
          next
        end

        case
        when arg.type.pointer?
          pointee = interp.pointee_of(arg)
          if pointee && pointee.designated_by_lvalue? && pointee.variable?
            sink = pointee
          else
            next
          end
        when arg.type.array?
          sink = arg
        end

        sink.assign!(sink.type.return_value)
        interp.notify_variable_value_updated(expr, sink)

        # NOTE: Returning a value via a pointer parameter can be considered as
        #       an evaluation of a statement-expression with a
        #       simple-assignment-expression.
        #       Control will reach to a sequence-point at the end of a full
        #       expression.
        interp.notify_sequence_point_reached(
          SequencePoint.new(funcall_expr, false))
      end
    end
  end

  class NamedFunction < Function
    include Nameable

    def initialize(dcl_or_def, type, name)
      super(dcl_or_def, type)
      self.name = name
    end

    def designated_by_lvalue?
      true
    end

    def call(*)
      case name
      when "exit", "_exit", "abort"
        BreakEvent.of_return.throw
      when "longjmp", "siglongjmp"
        BreakEvent.of_return.throw
      else
        super
      end
    end

    def signature
      FunctionSignature.new(name, type)
    end
  end

  class ExplicitFunction < NamedFunction
    def initialize(dcl_or_def)
      super(dcl_or_def, dcl_or_def.type, dcl_or_def.identifier.value)
    end

    def explicit?
      true
    end

    def builtin?
      false
    end
  end

  class ImplicitFunction < NamedFunction
    def initialize(type, name)
      super(nil, type, name)
    end

    def explicit?
      false
    end

    def builtin?
      false
    end
  end

  class AnonymousFunction < Function
    def initialize(type)
      super(nil, type)
    end

    def designated_by_lvalue?
      false
    end

    def explicit?
      false
    end

    def builtin?
      false
    end

    def signature
      FunctionSignature.new("__adlint__anon_func", type)
    end
  end

  class FunctionTable
    def initialize(mem_pool)
      @memory_pool = mem_pool
      @functions   = [{}]
      @scope_stack = [GlobalScope.new]
    end

    def enter_scope
      @functions.push({})
      @scope_stack.push(Scope.new(@scope_stack.size))
    end

    def leave_scope
      @functions.pop.each_value do |fun|
        @memory_pool.free(fun.binding.memory)
      end
      @scope_stack.pop
    end

    def declare_explicitly(dcl)
      if fun = lookup(dcl.identifier.value) and fun.explicit?
        fun.declarations_and_definitions.push(dcl)
        return fun
      end

      define(ExplicitFunction.new(dcl))
    end

    def declare_implicitly(fun)
      if fun.named? && fun.implicit?
        define(fun, true)
      end
      fun
    end

    def define(fun, in_global_scope = false)
      # NOTE: A function has a starting address in the TEXT segment.
      #       This is ad-hoc implementation, but it's enough for analysis.
      fun.bind_to(@memory_pool.allocate_static(0))

      if in_global_scope
        @functions.first[fun.name] = fun
      else
        @functions.last[fun.name] = fun if fun.named?
      end

      fun
    end

    def lookup(name_str)
      @functions.reverse_each do |hash|
        if fun = hash[name_str]
          return fun
        end
      end
      nil
    end

    def designators
      @functions.map { |hash| hash.keys }.flatten.to_set
    end
  end

  class Memory
    include Bindable

    def initialize(addr, byte_size)
      @address   = addr
      @byte_size = byte_size
      @value     = nil
    end

    attr_reader :address
    attr_reader :byte_size

    def static?
      subclass_responsibility
    end

    def dynamic?
      subclass_responsibility
    end

    def read
      @value
    end

    def write(val)
      if @value
        @value.overwrite!(val)
      else
        @value = VersionedValue.new(val)
      end
    end
  end

  class MemoryBlock < Memory
    def initialize(addr, byte_size)
      super
      @windows = []
    end

    attr_reader :windows

    def create_window(offset, byte_size)
      win = MemoryWindow.new(self, @address + offset, byte_size)
      win.on_written += method(:handle_written_through_window)
      @windows.push(win)
      win
    end

    def write(val)
      super
      if !@windows.empty? and
          @value.array? && val.array? or
          @value.composite? && val.composite?
        single_val = val.to_single_value
        @windows.zip(single_val.values).each do |win, inner_val|
          win.write(inner_val, false)
        end
      end
    end

    protected
    def create_value_from_windows
      case
      when @value.scalar?
        @value
      when @value.array?
        ArrayValue.new(@windows.map { |w| w.create_value_from_windows })
      when @value.composite?
        CompositeValue.new(@windows.map { |w| w.create_value_from_windows })
      end
    end

    private
    def handle_written_through_window(*)
      val = create_value_from_windows

      if @value
        @value.overwrite!(val)
      else
        @value = VersionedValue.new(val)
      end
    end
  end

  class MemoryWindow < MemoryBlock
    def initialize(owner, addr, byte_size)
      super(addr, byte_size)
      @owner = owner
    end

    extend Pluggable

    def_plugin :on_written

    def static?
      @owner.static?
    end

    def dynamic?
      @owner.dynamic?
    end

    def write(val, cascade = true)
      super(val)
      on_written.invoke(self) if cascade
    end

    private
    def handle_written_through_window(*)
      super
      on_written.invoke(self)
    end
  end

  class StaticMemoryBlock < MemoryBlock
    def static?
      true
    end

    def dynamic?
      false
    end
  end

  class DynamicMemoryBlock < MemoryBlock
    def static?
      false
    end

    def dynamic?
      true
    end
  end

  class MemoryPool
    def initialize
      @memory_blocks  = {}
      @address_ranges = []
      # NOTE: To make room for NULL and controlling expressions.
      @free_address = 10
    end

    def allocate_static(byte_size)
      mem_block = StaticMemoryBlock.new(@free_address, byte_size)
      @free_address += allocating_byte_size(byte_size)
      @memory_blocks[mem_block.address] = mem_block
      @address_ranges.push(mem_block.address...@free_address)
      mem_block
    end

    def allocate_dynamic(byte_size)
      mem_block = DynamicMemoryBlock.new(@free_address, byte_size)
      @free_address += allocating_byte_size(byte_size)
      @memory_blocks[mem_block.address] = mem_block
      @address_ranges.push(mem_block.address...@free_address)
      mem_block
    end

    def free(mem_block)
      @memory_blocks.delete(mem_block.address)
      @address_ranges.reject! { |range| range.include?(mem_block.address) }
    end

    def lookup(addr)
      if mem_block = @memory_blocks[addr]
        return mem_block
      else
        if addr_range = @address_ranges.find { |r| r.include?(addr) }
          mem_block = @memory_blocks[addr_range.first]
          return mem_block.windows.find { |w| w.address == addr }
        end
      end
      nil
    end

    private
    def allocating_byte_size(byte_size)
      byte_size == 0 ? 1 : byte_size
    end
  end

end
end
