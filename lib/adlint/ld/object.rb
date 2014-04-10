# C runtime object models for cross module analysis.
#
# Author::    Yutaka Yanoh <mailto:yanoh@users.sourceforge.net>
# Copyright:: Copyright (C) 2010-2014, OGIS-RI Co.,Ltd.
# License::   GPLv3+: GNU General Public License version 3 or later
#
# Owner::     Yutaka Yanoh <mailto:yanoh@users.sourceforge.net>

#--
#     ___    ____  __    ___   _________
#    /   |  / _  |/ /   / / | / /__  __/           Source Code Static Analyzer
#   / /| | / / / / /   / /  |/ /  / /                   AdLint - Advanced Lint
#  / __  |/ /_/ / /___/ / /|  /  / /
# /_/  |_|_____/_____/_/_/ |_/  /_/   Copyright (C) 2010-2014, OGIS-RI Co.,Ltd.
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

require "adlint/location"
require "adlint/metric"
require "adlint/util"

module AdLint #:nodoc:
module Ld #:nodoc:

  class Variable
    include LocationHolder

    def initialize(var_def_rec)
      @met_record = var_def_rec
    end

    def location
      @met_record.location
    end

    def name
      @met_record.variable_name
    end

    def type
      @met_record.type_rep
    end

    def extern?
      @met_record.variable_linkage_type == "X"
    end

    def eql?(rhs)
      name == rhs.name && location == rhs.location
    end

    alias :== :eql?

    def hash
      "#{name} #{location}".hash
    end
  end

  class VariableDeclaration
    include LocationHolder

    def initialize(gvar_dcl_rec)
      @met_record = gvar_dcl_rec
    end

    def location
      @met_record.location
    end

    def name
      @met_record.variable_name
    end

    def type
      @met_record.type_rep
    end

    def extern?
      true
    end

    def eql?(rhs)
      name == rhs.name && location == rhs.location
    end

    alias :== :eql?

    def hash
      "#{name} #{location}".hash
    end
  end

  class VariableMap
    def initialize
      @def_index = Hash.new { |hash, key| hash[key] = Set.new }
      @dcl_index = Hash.new { |hash, key| hash[key] = Set.new }
      @composing_fpaths = Set.new
    end

    attr_reader :composing_fpaths

    def add_variable(var)
      @def_index[var.name].add(var)
      @composing_fpaths.add(var.location.fpath)
    end

    def add_variable_declaration(var_dcl)
      @dcl_index[var_dcl.name].add(var_dcl)
      @composing_fpaths.add(var_dcl.location.fpath)
    end

    def all_variables
      @def_index.values.reduce(Set.new) { |all, vars| all + vars }.to_a
    end

    def all_variable_declarations
      @dcl_index.values.reduce(Set.new) { |all, dcls| all + dcls }.to_a
    end

    def lookup_variables(var_name)
      @def_index[var_name].to_a
    end

    def lookup_variable_declarations(var_name)
      @dcl_index[var_name].to_a
    end
  end

  class VariableMapper
    def initialize
      @map = VariableMap.new
    end

    attr_reader :map

    def execute(met_fpath)
      sma_wd = Pathname.pwd
      CSV.foreach(met_fpath) do |csv_row|
        if rec = MetricRecord.of(csv_row, sma_wd)
          case
          when rec.version?
            sma_wd = Pathname.new(rec.exec_working_directory)
          when rec.variable_definition?
            if rec.variable_linkage_type == "X"
              @map.add_variable(Variable.new(rec))
            end
          when rec.global_variable_declaration?
            @map.add_variable_declaration(VariableDeclaration.new(rec))
          end
        end
      end
    end
  end

  class VariableTraversal
    def initialize(var_map)
      @map = var_map
    end

    extend Pluggable

    def_plugin :on_declaration
    def_plugin :on_definition

    def execute
      @map.all_variable_declarations.each do |var_dcl|
        on_declaration.invoke(var_dcl)
      end

      @map.all_variables.each do |var_def|
        on_definition.invoke(var_def)
      end
    end
  end

  class Function
    include LocationHolder

    def initialize(fun_def_rec)
      @met_record = fun_def_rec
    end

    def location
      @met_record.location
    end

    def signature
      @met_record.function_id.signature
    end

    def name
      @met_record.function_id.name
    end

    def extern?
      @met_record.function_linkage_type == "X"
    end

    def eql?(rhs)
      signature == rhs.signature && location == rhs.location
    end

    alias :== :eql?

    def hash
      "#{signature} #{location}".hash
    end
  end

  class FunctionDeclaration
    include LocationHolder

    def initialize(fun_dcl_rec)
      @met_record = fun_dcl_rec
    end

    def location
      @met_record.location
    end

    def signature
      @met_record.function_id.signature
    end

    def name
      @met_record.function_id.name
    end

    def extern?
      @met_record.function_linkage_type == "X"
    end

    def explicit?
      @met_record.function_declaration_type == "E"
    end

    def implicit?
      @met_record.function_declaration_type == "I"
    end

    def eql?(rhs)
      signature == rhs.signature && location == rhs.location
    end

    alias :== :eql?

    def hash
      "#{signature} #{location}".hash
    end
  end

  class FunctionMap
    def initialize
      @def_index = Hash.new { |hash, key| hash[key] = Set.new }
      @dcl_index = Hash.new { |hash, key| hash[key] = Set.new }
      @composing_fpaths = Set.new
    end

    attr_reader :composing_fpaths

    def add_function(fun)
      @def_index[fun.name].add(fun)
      @composing_fpaths.add(fun.location.fpath)
    end

    def add_function_declaration(fun_dcl)
      @dcl_index[fun_dcl.name].add(fun_dcl)
      @composing_fpaths.add(fun_dcl.location.fpath)
    end

    def all_functions
      @def_index.values.reduce(Set.new) { |all, funs| all + funs }.to_a
    end

    def all_function_declarations
      @dcl_index.values.reduce(Set.new) { |all, dcls| all + dcls }.to_a
    end

    def lookup_functions(fun_name)
      @def_index[fun_name].to_a
    end

    def lookup_function_declarations(fun_name)
      @dcl_index[fun_name].to_a
    end
  end

  class FunctionMapper
    def initialize
      @map = FunctionMap.new
    end

    attr_reader :map

    def execute(met_fpath)
      sma_wd = Pathname.pwd
      CSV.foreach(met_fpath) do |csv_row|
        if rec = MetricRecord.of(csv_row, sma_wd)
          case
          when rec.version?
            sma_wd = Pathname.new(rec.exec_working_directory)
          when rec.function_definition?
            @map.add_function(Function.new(rec))
          when rec.function_declaration?
            @map.add_function_declaration(FunctionDeclaration.new(rec))
          end
        end
      end
    end
  end

  class FunctionTraversal
    def initialize(fun_map)
      @map = fun_map
    end

    extend Pluggable

    def_plugin :on_declaration
    def_plugin :on_definition

    def execute
      @map.all_function_declarations.each do |fun_dcl|
        on_declaration.invoke(fun_dcl)
      end

      @map.all_functions.each do |fun_def|
        on_definition.invoke(fun_def)
      end
    end
  end

  class ObjectReferrer
    class << self
      def of_function(fun)
        Function.new(fun)
      end

      def of_ctors_section(ref_loc)
        CtorsSection.new(ref_loc)
      end
    end

    def location
      subclass_responsibility
    end

    def function
      subclass_responsibility
    end

    def hash
      subclass_responsibility
    end

    def eql?(rhs)
      subclass_responsibility
    end

    class Function < ObjectReferrer
      def initialize(fun)
        @function = fun
      end

      attr_reader :function

      def location
        @function.location
      end

      def hash
        @function.hash
      end

      def eql?(rhs)
        case rhs
        when Function
          @function == rhs.function
        else
          false
        end
      end
    end
    private_constant :Function

    class CtorsSection < ObjectReferrer
      def initialize(ref_loc)
        @location = ref_loc
      end

      attr_reader :location

      def function
        nil
      end

      def hash
        @location.fpath.hash
      end

      def eql?(rhs)
        case rhs
        when CtorsSection
          @location.fpath == rhs.location.fpath
        else
          false
        end
      end
    end
    private_constant :CtorsSection
  end

  class ObjectReference
    include LocationHolder

    def initialize(ref, obj, loc)
      @referrer = ref
      @object   = obj
      @location = loc
    end

    attr_reader :referrer
    attr_reader :object
    attr_reader :location

    def eql?(rhs)
      to_a == rhs.to_a
    end

    alias :== :eql?

    def hash
      to_a.hash
    end

    def to_a
      [@referrer, @object, @location]
    end
  end

  class ObjectXRefGraph
    def initialize(funcall_graph)
      @funcall_graph = funcall_graph
      @obj_index = Hash.new { |hash, key| hash[key] = Set.new }
    end

    def add(obj_ref)
      @obj_index[obj_ref.object].add(obj_ref)
    end

    def all_referrers_of(obj)
      direct_referrers_of(obj) + indirect_referrers_of(obj)
    end

    def direct_referrers_of(obj)
      @obj_index[obj].map { |obj_ref| obj_ref.referrer }.to_set
    end

    def indirect_referrers_of(obj)
      direct_referrers_of(obj).reduce(Set.new) do |res, ref|
        if fun = ref.function
          res + @funcall_graph.all_callers_of(fun)
        else
          res
        end
      end
    end
  end

  class ObjectXRefGraphBuilder
    def initialize(var_map, fun_map, funcall_graph)
      @var_map, @fun_map = var_map, fun_map
      @graph = ObjectXRefGraph.new(funcall_graph)
    end

    attr_reader :graph

    def execute(met_fpath)
      sma_wd = Pathname.pwd
      CSV.foreach(met_fpath) do |csv_row|
        if rec = MetricRecord.of(csv_row, sma_wd)
          case
          when rec.version?
            sma_wd = Pathname.new(rec.exec_working_directory)
          when rec.variable_xref?
            if var = @var_map.lookup_variables(rec.accessee_variable).first
              fun_id = rec.accessor_function
              if fun_id.named?
                fun = @fun_map.lookup_functions(fun_id.name).first
                ref = ObjectReferrer.of_function(fun)
              else
                ref = ObjectReferrer.of_ctors_section(rec.location)
              end
              @graph.add(ObjectReference.new(ref, var, rec.location))
            end
          when rec.function_xref?
            ref, fun = lookup_referrer_and_function_by_xref(rec)
            if ref && fun
              @graph.add(ObjectReference.new(ref, fun, rec.location))
            end
          end
        end
      end
    end

    private
    def lookup_referrer_and_function_by_xref(fun_xref)
      caller_id = fun_xref.accessor_function
      if caller_id.named?
        caller_fun = @fun_map.lookup_functions(caller_id.name).find { |fun|
          fun.location.fpath == fun_xref.location.fpath
        }
        return nil, nil unless caller_fun
        ref = ObjectReferrer.of_function(caller_fun)
      else
        ref = ObjectReferrer.of_ctors_section(fun_xref.location)
      end

      callee_funs = @fun_map.lookup_functions(fun_xref.accessee_function.name)
      callee_fun = callee_funs.find { |fun|
        fun.location.fpath == ref.location.fpath
      } || callee_funs.first

      return ref, callee_fun
    end
  end

  class FunctionCall
    def initialize(caller_ref, callee_fun)
      @caller = caller_ref
      @callee = callee_fun
    end

    attr_reader :caller
    attr_reader :callee

    def eql?(rhs)
      to_a == rhs.to_a
    end

    alias :== :eql?

    def hash
      to_a.hash
    end

    def to_a
      [@caller, @callee]
    end
  end

  class FunctionCallGraph
    def initialize
      @callee_index = Hash.new { |hash, key| hash[key] = Set.new }
    end

    def add(funcall)
      @callee_index[funcall.callee].add(funcall)
    end

    def all_callers_of(fun)
      direct_callers_of(fun) + indirect_callers_of(fun)
    end
    memoize :all_callers_of

    def direct_callers_of(fun)
      @callee_index[fun].map { |funcall| funcall.caller }.to_set
    end
    memoize :direct_callers_of

    def indirect_callers_of(fun)
      direct_callers_of(fun).reduce(Set.new) do |res, ref|
        if fun = ref.function
          res + collect_callers_of(fun, res)
        else
          res
        end
      end
    end
    memoize :indirect_callers_of

    private
    def collect_callers_of(fun, exclusions)
      direct_callers_of(fun).reduce(Set.new) do |res, ref|
        case
        when exclusions.include?(ref)
          res.add(ref)
        when caller_fun = ref.function
          res.add(ref) + collect_callers_of(caller_fun, exclusions + res)
        else
          res.add(ref)
        end
      end
    end
    memoize :collect_callers_of, key_indices: [0]
  end

  class FunctionCallGraphBuilder
    def initialize(fun_map)
      @fun_map = fun_map
      @graph = FunctionCallGraph.new
    end

    attr_reader :graph

    def execute(met_fpath)
      sma_wd = Pathname.pwd
      CSV.foreach(met_fpath) do |csv_row|
        if rec = MetricRecord.of(csv_row, sma_wd)
          case
          when rec.version?
            sma_wd = Pathname.new(rec.exec_working_directory)
          when rec.function_call?
            caller_ref, callee_fun = lookup_functions_by_call(rec)
            if caller_ref && callee_fun
              @graph.add(FunctionCall.new(caller_ref, callee_fun))
            end
          end
        end
      end
    end

    private
    def lookup_functions_by_call(funcall_rec)
      caller_fun = @fun_map.lookup_functions(
        funcall_rec.caller_function.name).find { |fun|
          fun.location.fpath == funcall_rec.location.fpath
        }
      if caller_fun
        caller_ref = ObjectReferrer.of_function(caller_fun)
      else
        return nil, nil
      end

      callee_funs = @fun_map.lookup_functions(funcall_rec.callee_function.name)

      callee_fun = callee_funs.first
      callee_funs.each do |fun|
        if fun.location.fpath == caller_ref.location.fpath
          callee_fun = fun
          break
        end
      end

      return caller_ref, callee_fun
    end
  end

end
end
