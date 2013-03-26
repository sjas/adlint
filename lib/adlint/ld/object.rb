# C runtime object models for cross module analysis.
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

  class VariableMapping
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
      @result = VariableMapping.new
    end

    attr_reader :result

    def execute(met_fpath)
      sma_wd = Pathname.pwd
      CSV.foreach(met_fpath) do |csv_row|
        rec = MetricRecord.of(csv_row, sma_wd)
        case
        when rec.version?
          sma_wd = Pathname.new(rec.exec_working_directory)
        when rec.variable_definition?
          if rec.variable_linkage_type == "X"
            @result.add_variable(Variable.new(rec))
          end
        when rec.global_variable_declaration?
          @result.add_variable_declaration(VariableDeclaration.new(rec))
        end
      end
    end
  end

  class VariableReference
    include LocationHolder

    def initialize(fun, var, loc)
      @function = fun
      @variable = var
      @location = loc
    end

    attr_reader :function
    attr_reader :variable
    attr_reader :location

    def eql?(rhs)
      to_a == rhs.to_a
    end

    alias :== :eql?

    def hash
      to_a.hash
    end

    def to_a
      [@function, @variable, @location]
    end
  end

  class VariableReferenceGraph
    def initialize(funcall_graph)
      @funcall_graph = funcall_graph
      @ref_index = Hash.new { |hash, key| hash[key] = Set.new }
      @var_index = Hash.new { |hash, key| hash[key] = Set.new }
    end

    def add(var_ref)
      @ref_index[var_ref.function].add(var_ref)
      @var_index[var_ref.variable].add(var_ref)
    end

    def all_referrers_of(var)
      direct_referrers_of(var) + indirect_referrers_of(var)
    end

    def direct_referrers_of(var)
      @var_index[var].map { |var_ref| var_ref.function }.to_set
    end

    def indirect_referrers_of(var)
      direct_referrers = direct_referrers_of(var)
      direct_referrers.reduce(Set.new) do |result, fun|
        result + @funcall_graph.all_callers_of(fun)
      end
    end
  end

  class VariableReferenceGraphBuilder
    def initialize(var_mapping, fun_mapping, funcall_graph)
      @variable_mapping = var_mapping
      @function_mapping = fun_mapping
      @result = VariableReferenceGraph.new(funcall_graph)
    end

    attr_reader :result

    def execute(met_fpath)
      sma_wd = Pathname.pwd
      CSV.foreach(met_fpath) do |csv_row|
        rec = MetricRecord.of(csv_row, sma_wd)
        case
        when rec.version?
          sma_wd = Pathname.new(rec.exec_working_directory)
        when rec.variable_xref?
          fun = @function_mapping.lookup_functions(
            rec.accessor_function.name).first
          var = @variable_mapping.lookup_variables(rec.accessee_variable).first

          if fun && var
            @result.add(VariableReference.new(fun, var, rec.location))
          end
        end
      end
    end
  end

  class VariableTraversal
    def initialize(var_mapping)
      @variable_mapping = var_mapping
    end

    extend Pluggable

    def_plugin :on_declaration
    def_plugin :on_definition

    def execute
      @variable_mapping.all_variable_declarations.each do |var_dcl|
        on_declaration.invoke(var_dcl)
      end

      @variable_mapping.all_variables.each do |var_def|
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

  class FunctionMapping
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
      @result = FunctionMapping.new
    end

    attr_reader :result

    def execute(met_fpath)
      sma_wd = Pathname.pwd
      CSV.foreach(met_fpath) do |csv_row|
        rec = MetricRecord.of(csv_row, sma_wd)
        case
        when rec.version?
          sma_wd = Pathname.new(rec.exec_working_directory)
        when rec.function_definition?
          @result.add_function(Function.new(rec))
        when rec.function_declaration?
          @result.add_function_declaration(FunctionDeclaration.new(rec))
        end
      end
    end
  end

  class FunctionCall
    def initialize(caller_fun, callee_fun)
      @caller_function = caller_fun
      @callee_function = callee_fun
    end

    attr_reader :caller_function
    attr_reader :callee_function

    def eql?(rhs)
      to_a == rhs.to_a
    end

    alias :== :eql?

    def hash
      to_a.hash
    end

    def to_a
      [@caller_function, @callee_function]
    end
  end

  class FunctionCallGraph
    def initialize
      @caller_index = Hash.new { |hash, key| hash[key] = Set.new }
      @callee_index = Hash.new { |hash, key| hash[key] = Set.new }
    end

    def add(funcall)
      @caller_index[funcall.caller_function].add(funcall)
      @callee_index[funcall.callee_function].add(funcall)
    end

    def all_callers_of(callee_fun)
      direct_callers_of(callee_fun) + indirect_callers_of(callee_fun)
    end
    memoize :all_callers_of

    def direct_callers_of(callee_fun)
      @callee_index[callee_fun].map { |funcall|
        funcall.caller_function
      }.to_set
    end
    memoize :direct_callers_of

    def indirect_callers_of(callee_fun)
      direct_callers = direct_callers_of(callee_fun)
      direct_callers.reduce(Set.new) do |all_callers, fun|
        all_callers + collect_callers_of(fun, all_callers)
      end
    end
    memoize :indirect_callers_of

    private
    def collect_callers_of(callee_fun, exclusion_list)
      direct_callers = direct_callers_of(callee_fun)

      direct_callers.reduce(Set.new) do |all_callers, fun|
        if exclusion_list.include?(fun)
          all_callers.add(fun)
        else
          all_callers.add(fun) +
            collect_callers_of(fun, exclusion_list + all_callers)
        end
      end
    end
    memoize :collect_callers_of, 0
  end

  class FunctionCallGraphBuilder
    def initialize(fun_mapping)
      @function_mapping = fun_mapping
      @result = FunctionCallGraph.new
    end

    attr_reader :result

    def execute(met_fpath)
      sma_wd = Pathname.pwd
      CSV.foreach(met_fpath) do |csv_row|
        rec = MetricRecord.of(csv_row, sma_wd)
        case
        when rec.version?
          sma_wd = Pathname.new(rec.exec_working_directory)
        when rec.function_call?
          caller_fun, callee_fun = lookup_functions_by_call(rec)
          if caller_fun && callee_fun
            @result.add(FunctionCall.new(caller_fun, callee_fun))
          end
        when rec.function_xref?
          caller_fun, callee_fun = lookup_functions_by_xref(rec)
          if caller_fun && callee_fun
            @result.add(FunctionCall.new(caller_fun, callee_fun))
          end
        end
      end
    end

    def lookup_functions_by_call(funcall_rec)
      caller_fun = @function_mapping.lookup_functions(
        funcall_rec.caller_function.name).find { |fun|
          fun.location.fpath == funcall_rec.location.fpath
      }
      return nil, nil unless caller_fun

      callee_funs = @function_mapping.lookup_functions(
        funcall_rec.callee_function.name)

      callee_fun = callee_funs.first
      callee_funs.each do |fun|
        if fun.location.fpath == caller_fun.location.fpath
          callee_fun = fun
          break
        end
      end

      return caller_fun, callee_fun
    end

    def lookup_functions_by_xref(fun_xref_rec)
      caller_fun = @function_mapping.lookup_functions(
        fun_xref_rec.accessor_function.name).find { |fun|
          fun.location.fpath == fun_xref_rec.location.fpath
      }
      return nil, nil unless caller_fun

      callee_funs = @function_mapping.lookup_functions(
        fun_xref_rec.accessee_function.name)

      callee_fun = callee_funs.first
      callee_funs.each do |fun|
        if fun.location.fpath == caller_fun.location.fpath
          callee_fun = fun
          break
        end
      end

      return caller_fun, callee_fun
    end
  end

  class FunctionTraversal
    def initialize(fun_mapping)
      @function_mapping = fun_mapping
    end

    extend Pluggable

    def_plugin :on_declaration
    def_plugin :on_definition

    def execute
      @function_mapping.all_function_declarations.each do |fun_dcl|
        on_declaration.invoke(fun_dcl)
      end

      @function_mapping.all_functions.each do |fun_def|
        on_definition.invoke(fun_def)
      end
    end
  end

end
end
