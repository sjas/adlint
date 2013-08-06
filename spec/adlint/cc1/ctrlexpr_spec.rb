# Unit specification of controlling expression of selection-statements and
# iteration-statements.
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

require "spec_helper"

module AdLint
module Cc1

  describe ControllingExpression do
    include InterpreterMediator

    before(:all) { @adlint = AdLint.new($default_traits) }

    before(:each) do
      @monitor      = ProgressMonitor.new(nil, nil, false)
      @logger       = Logger.new(File.open(File::NULL, "w"))
      @symbol_table = SymbolTable.new
      @type_table   = TypeTable.new(@adlint.traits, @monitor, @logger)
      @interpreter  = Interpreter.new(@type_table)
      @int_i        = @interpreter.define_variable(int_i_def, nil)
      @int_j        = @interpreter.define_variable(int_j_def, nil)
    end

    context "`int i = ((> 0) && (< 10)) || (== 0)' and " +
            "`int j = ((> 0) && (< 10)) || (== 0)'" do
      before do
        @int_i.narrow_value_domain!(Operator::GE, scalar_value_of(0))
        @int_i.narrow_value_domain!(Operator::LT, scalar_value_of(10))
        @int_j.narrow_value_domain!(Operator::GE, scalar_value_of(0))
        @int_j.narrow_value_domain!(Operator::LT, scalar_value_of(10))
      end

      it "(i == j) makes that `i' should contain 0 and 9, " +
         "and should not contain 10" do
        expr = EqualityExpression.new(eq_op, i_spec, j_spec)
        branched_eval(expr, NARROWING, FINAL) do
          @int_i.value.test_may_be_equal_to(
            scalar_value_of(0)).result.should be_true
          @int_i.value.test_may_be_equal_to(
            scalar_value_of(9)).result.should be_true
          @int_i.value.test_may_be_equal_to(
            scalar_value_of(10)).result.should be_false
        end
      end

      it "(i != j) makes that `i' should contain 0 and 9, " +
         "and should not contain 10" do
        expr = EqualityExpression.new(ne_op, i_spec, j_spec)
        branched_eval(expr, NARROWING, FINAL) do
          @int_i.value.test_may_be_equal_to(
            scalar_value_of(0)).result.should be_true
          @int_i.value.test_may_be_equal_to(
            scalar_value_of(9)).result.should be_true
          @int_i.value.test_may_be_equal_to(
            scalar_value_of(10)).result.should be_false
        end
      end
    end

    context "`int i = ((> 0) && (< 10)) || (== 0)' and " +
            "`int j = ((> 3) && (< 5)) || (== 3)'" do
      before do
        @int_i.narrow_value_domain!(Operator::GE, scalar_value_of(0))
        @int_i.narrow_value_domain!(Operator::LT, scalar_value_of(10))
        @int_j.narrow_value_domain!(Operator::GE, scalar_value_of(3))
        @int_j.narrow_value_domain!(Operator::LT, scalar_value_of(5))
      end

      it "(i == j) makes that `i' should contain 3 and 4, " +
         "and should not contain 0" do
        expr = EqualityExpression.new(eq_op, i_spec, j_spec)
        branched_eval(expr, NARROWING, FINAL) do
          @int_i.value.test_may_be_equal_to(
            scalar_value_of(3)).result.should be_true
          @int_i.value.test_may_be_equal_to(
            scalar_value_of(4)).result.should be_true
          @int_i.value.test_may_be_equal_to(
            scalar_value_of(0)).result.should be_false
        end
      end
    end

    private
    def eq_op
      Token.new("==", "==", nil_loc)
    end

    def ne_op
      Token.new("!=", "!=", nil_loc)
    end

    def i_spec
      obj_spec_of("i")
    end

    def j_spec
      obj_spec_of("j")
    end

    def obj_spec_of(name)
      ObjectSpecifier.new(id_of(name))
    end

    def int_i_def
      uninitialized_int_vardef("i", @type_table.int_t)
    end

    def int_j_def
      uninitialized_int_vardef("j", @type_table.int_t)
    end

    def uninitialized_int_vardef(name, type)
      dcl_specs = DeclarationSpecifiers.new.tap { |ds|
        ds.type_specifiers.push(int_t_spec)
      }
      decl = Declaration.new(dcl_specs, [uninitialized_int_dcl(name)],
                             @symbol_table)
      decl.items.each { |item| item.type = type }
      decl.items.find { |item| item.kind_of?(VariableDefinition) }
    end

    def uninitialized_int_dcl(name)
      InitDeclarator.new(IdentifierDeclarator.new(id_of(name)), nil)
    end

    def int_t_spec
      StandardTypeSpecifier.new(Token.new(:INT, "int", Location.new))
    end

    def id_of(name)
      Token.new(:IDENTIFIER, name, nil_loc)
    end

    def nil_loc
      Location.new
    end

    def resolve_type(node)
      StaticTypeResolver.new.resolve(node)
    end

    def interpreter
      @interpreter
    end
  end

  include BranchOptions

end
end
