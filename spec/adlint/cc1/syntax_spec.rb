# Unit specification of AST of C language.
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

require "spec_helper"

module AdLint
module Cc1

  describe Expression do
    let(:symbol_table) { SymbolTable.new }

    context "`*'" do
      subject { error_expression(operator("*")) }

      it { is_expected.not_to be_logical }
      it { is_expected.not_to be_arithmetic }
      it { is_expected.not_to be_bitwise }
    end

    context "`foo'" do
      subject { object_specifier("foo") }

      it { is_expected.not_to be_logical }
      it { is_expected.not_to be_arithmetic }
      it { is_expected.not_to be_bitwise }
    end

    context "`0x11'" do
      subject { constant_specifier("0x11") }

      it { is_expected.not_to be_logical }
      it { is_expected.not_to be_arithmetic }
      it { is_expected.not_to be_bitwise }
    end

    context %(`"aiueo"') do
      subject { string_literal_specifier('"aiueo"') }

      it { is_expected.not_to be_logical }
      it { is_expected.not_to be_arithmetic }
      it { is_expected.not_to be_bitwise }
    end

    context "`NULL'" do
      subject { null_constant_specifier }

      it { is_expected.not_to be_logical }
      it { is_expected.not_to be_arithmetic }
      it { is_expected.not_to be_bitwise }
    end

    # NOTE: GroupedExpression encloses an arithmetic expression.
    context "`(1 + 2)'" do
      subject do
        grouped_expression(
          additive_expression(
            "+", constant_specifier(1), constant_specifier(2)))
      end

      it { is_expected.not_to be_logical }
      it { is_expected.to be_arithmetic }
      it { is_expected.not_to be_bitwise }
    end

    # NOTE: GroupedExpression encloses a bitwise expression.
    context "`(1 << 2)'" do
      subject do
        grouped_expression(
          shift_expression("<<", constant_specifier(1), constant_specifier(2)))
      end

      it { is_expected.not_to be_logical }
      it { is_expected.not_to be_arithmetic }
      it { is_expected.to be_bitwise }
    end

    # NOTE: GroupedExpression encloses an expression which is neither
    #       arithmetic nor bitwise.
    context "`(1 && 2)'" do
      subject do
        grouped_expression(
          logical_and_expression(constant_specifier(1), constant_specifier(2)))
      end

      it { is_expected.to be_logical }
      it { is_expected.not_to be_arithmetic }
      it { is_expected.not_to be_bitwise }
    end

    context "`i++'" do
      subject { postfix_increment_expression(object_specifier("i")) }

      it { is_expected.not_to be_logical }
      it { is_expected.to be_arithmetic }
      it { is_expected.not_to be_bitwise }
    end

    context "`i--'" do
      subject { postfix_decrement_expression(object_specifier("i")) }

      it { is_expected.not_to be_logical }
      it { is_expected.to be_arithmetic }
      it { is_expected.not_to be_bitwise }
    end

    context "`++i'" do
      subject { prefix_increment_expression(object_specifier("i")) }

      it { is_expected.not_to be_logical }
      it { is_expected.to be_arithmetic }
      it { is_expected.not_to be_bitwise }
    end

    context "`--i'" do
      subject { prefix_decrement_expression(object_specifier("i")) }

      it { is_expected.not_to be_logical }
      it { is_expected.to be_arithmetic }
      it { is_expected.not_to be_bitwise }
    end

    context "`(char) i'" do
      subject { cast_expression(char_t_name, object_specifier("i")) }

      it { is_expected.not_to be_logical }
      it { is_expected.not_to be_arithmetic }
      it { is_expected.not_to be_bitwise }
    end

    context "`(char) (i + 1)'" do
      subject do
        cast_expression(
          char_t_name, grouped_expression(
            additive_expression(
              "+", object_specifier("i"), constant_specifier(1))))
      end

      it { is_expected.not_to be_logical }
      it { is_expected.to be_arithmetic }
      it { is_expected.not_to be_bitwise }
    end

    context "`(char) (i == 0)'" do
      subject do
        cast_expression(
          char_t_name,
          grouped_expression(
            equality_expression(
              "==", object_specifier("i"), constant_specifier(1))))
      end

      it { is_expected.to be_logical }
      it { is_expected.not_to be_arithmetic }
      it { is_expected.not_to be_bitwise }
    end

    context "`(char) (i & 1)'" do
      subject do
        cast_expression(
          char_t_name,
          grouped_expression(
            and_expression(object_specifier("i"), constant_specifier(1))))
      end

      it { is_expected.not_to be_logical }
      it { is_expected.not_to be_arithmetic }
      it { is_expected.to be_bitwise }
    end

    context "`i * j'" do
      subject do
        multiplicative_expression(
          "*", object_specifier("i"), object_specifier("j"))
      end

      it { is_expected.not_to be_logical }
      it { is_expected.to be_arithmetic }
      it { is_expected.not_to be_bitwise }
    end

    context "`i + j'" do
      subject do
        additive_expression("+", object_specifier("i"), object_specifier("j"))
      end

      it { is_expected.not_to be_logical }
      it { is_expected.to be_arithmetic }
      it { is_expected.not_to be_bitwise }
    end

    context "`i << 1'" do
      subject do
        shift_expression("<<", object_specifier("i"), constant_specifier(1))
      end

      it { is_expected.not_to be_logical }
      it { is_expected.not_to be_arithmetic }
      it { is_expected.to be_bitwise }
    end

    context "`i < 0'" do
      subject do
        relational_expression(
          "<", object_specifier("i"), constant_specifier(0))
      end

      it { is_expected.to be_logical }
      it { is_expected.not_to be_arithmetic }
      it { is_expected.not_to be_bitwise }
    end

    context "`i == j'" do
      subject do
        equality_expression("==", object_specifier("i"), object_specifier("j"))
      end

      it { is_expected.to be_logical }
      it { is_expected.not_to be_arithmetic }
      it { is_expected.not_to be_bitwise }
    end

    context "`i & 1'" do
      subject { and_expression(object_specifier("i"), constant_specifier(1)) }

      it { is_expected.not_to be_logical }
      it { is_expected.not_to be_arithmetic }
      it { is_expected.to be_bitwise }
    end

    context "`i ^ 2'" do
      subject do
        exclusive_or_expression(object_specifier("i"), constant_specifier(2))
      end

      it { is_expected.not_to be_logical }
      it { is_expected.not_to be_arithmetic }
      it { is_expected.to be_bitwise }
    end

    context "`i | 2'" do
      subject do
        inclusive_or_expression(object_specifier("i"), constant_specifier(2))
      end

      it { is_expected.not_to be_logical }
      it { is_expected.not_to be_arithmetic }
      it { is_expected.to be_bitwise }
    end

    context "`i && j'" do
      subject do
        logical_and_expression(object_specifier("i"), object_specifier("j"))
      end

      it { is_expected.to be_logical }
      it { is_expected.not_to be_arithmetic }
      it { is_expected.not_to be_bitwise }
    end

    context "`i || j'" do
      subject do
        logical_or_expression(object_specifier("i"), object_specifier("j"))
      end

      it { is_expected.to be_logical }
      it { is_expected.not_to be_arithmetic }
      it { is_expected.not_to be_bitwise }
    end

    # NOTE: ConditionalExpression has arithmetics as 2nd and 3rd expression.
    context "`i > 0 ? i + 2 : j - 4'" do
      subject do
        conditional_expression(
          relational_expression(
            ">", object_specifier("i"), constant_specifier(0)),
          additive_expression(
            "+", object_specifier("i"), constant_specifier(2)),
          additive_expression(
            "-", object_specifier("j"), constant_specifier(4)))
      end

      it { is_expected.not_to be_logical }
      it { is_expected.to be_arithmetic }
      it { is_expected.not_to be_bitwise }
    end

    # NOTE: ConditionalExpression has an arithmetic as 2nd expression and a
    #       logical as 3rd expression.
    context "`i > 0 ? i + 2 : j || k'" do
      subject do
        conditional_expression(
          relational_expression(
            ">", object_specifier("i"), constant_specifier(0)),
          additive_expression(
            "+", object_specifier("i"), constant_specifier(2)),
          logical_or_expression(
            object_specifier("j"), object_specifier("k")))
      end

      it { is_expected.to be_logical }
      it { is_expected.to be_arithmetic }
      it { is_expected.not_to be_bitwise }
    end

    # NOTE: ConditionalExpression has an arithmetic as 2nd expression and a
    #       bitwise as 3rd expression.
    context "`i < 10 ? i + 2 : i << 4'" do
      subject do
        conditional_expression(
          relational_expression(
            "<", object_specifier("i"), constant_specifier(10)),
          additive_expression(
            "+", object_specifier("i"), constant_specifier(2)),
          shift_expression(
            "<<", object_specifier("i"), constant_specifier(4)))
      end

      it { is_expected.not_to be_logical }
      it { is_expected.to be_arithmetic }
      it { is_expected.to be_bitwise }
    end

    # NOTE: ConditionalExpression has bitwises as 2nd and 3rd expression.
    context "`i < 10 ? i ^ 2 : i << 4'" do
      subject do
        conditional_expression(
          relational_expression(
            "<", object_specifier("i"), constant_specifier(10)),
          exclusive_or_expression(
            object_specifier("i"), constant_specifier(2)),
          shift_expression(
            "<<", object_specifier("i"), constant_specifier(4)))
      end

      it { is_expected.not_to be_logical }
      it { is_expected.not_to be_arithmetic }
      it { is_expected.to be_bitwise }
    end

    # NOTE: ConditionalExpression has a logical as 2nd expression and a bitwise
    #       as 3rd expression.
    context "`i < 10 ? i && j : i << 4'" do
      subject do
        conditional_expression(
          relational_expression(
            "<", object_specifier("i"), constant_specifier(10)),
          logical_and_expression(
            object_specifier("i"), object_specifier("j")),
          shift_expression(
            "<<", object_specifier("i"), constant_specifier(4)))
      end

      it { is_expected.to be_logical }
      it { is_expected.not_to be_arithmetic }
      it { is_expected.to be_bitwise }
    end

    # NOTE: ConditionalExpression has logicals as 2nd and 3rd expression.
    context "`i < 10 ? i && j : i || j'" do
      subject do
        conditional_expression(
          relational_expression(
            "<", object_specifier("i"), constant_specifier(10)),
          logical_and_expression(
            object_specifier("i"), object_specifier("j")),
          logical_or_expression(
            object_specifier("i"), object_specifier("j")))
      end

      it { is_expected.to be_logical }
      it { is_expected.not_to be_arithmetic }
      it { is_expected.not_to be_bitwise }
    end

    context "`i = 0'" do
      subject do
        simple_assignment_expression(
          object_specifier("i"), constant_specifier(0))
      end

      it { is_expected.not_to be_logical }
      it { is_expected.not_to be_arithmetic }
      it { is_expected.not_to be_bitwise }
    end

    context "`i = j = k + 1'" do
      subject do
        simple_assignment_expression(
          object_specifier("i"),
          simple_assignment_expression(
            object_specifier("j"),
            additive_expression(
              "+", object_specifier("k"), constant_specifier(1))))
      end

      it { is_expected.not_to be_logical }
      it { is_expected.to be_arithmetic }
      it { is_expected.not_to be_bitwise }
    end

    context "`i = j = k << 1'" do
      subject do
        simple_assignment_expression(
          object_specifier("i"),
          simple_assignment_expression(
            object_specifier("j"),
            shift_expression(
              "<<", object_specifier("k"), constant_specifier(1))))
      end

      it { is_expected.not_to be_logical }
      it { is_expected.not_to be_arithmetic }
      it { is_expected.to be_bitwise }
    end

    context "`i = j = (k > 5 && k < 10)'" do
      subject do
        simple_assignment_expression(
          object_specifier("i"),
          simple_assignment_expression(
            object_specifier("j"),
            grouped_expression(
              logical_and_expression(
                relational_expression(
                  ">", object_specifier("k"), constant_specifier(5)),
                relational_expression(
                  "<", object_specifier("k"), constant_specifier(10))))))
      end

      it { is_expected.to be_logical }
      it { is_expected.not_to be_arithmetic }
      it { is_expected.not_to be_bitwise }
    end

    context "`i += 2'" do
      subject do
        compound_assignment_expression(
          "+=", object_specifier("i"), constant_specifier(2))
      end

      it { is_expected.not_to be_logical }
      it { is_expected.to be_arithmetic }
      it { is_expected.not_to be_bitwise }
    end

    context "`i &= 2'" do
      subject do
        compound_assignment_expression(
          "&=", object_specifier("i"), constant_specifier(2))
      end

      it { is_expected.not_to be_logical }
      it { is_expected.not_to be_arithmetic }
      it { is_expected.to be_bitwise }
    end

    context "`i ^= j && k'" do
      subject do
        compound_assignment_expression(
          "^=", object_specifier("i"),
          logical_and_expression(
            object_specifier("j"), object_specifier("k")))
      end

      it { is_expected.not_to be_logical }
      it { is_expected.not_to be_arithmetic }
      it { is_expected.to be_bitwise }
    end

    # NOTE: CommaSeparatedExpression has two arithmetic expressions.
    context "`i + 1, j + 2'" do
      subject do
        comma_separated_expression(
          additive_expression(
            "+", object_specifier("i"), constant_specifier(1)),
          additive_expression(
            "+", object_specifier("j"), constant_specifier(2)))
      end

      it { is_expected.not_to be_logical }
      it { is_expected.to be_arithmetic }
      it { is_expected.not_to be_bitwise }
    end

    # NOTE: CommaSeparatedExpression has a logical expression followed by an
    #       arithmetic expression.
    context "`i < 1, j + 2'" do
      subject do
        comma_separated_expression(
          relational_expression(
            "<", object_specifier("i"), constant_specifier(1)),
          additive_expression(
            "+", object_specifier("j"), constant_specifier(2)))
      end

      it { is_expected.not_to be_logical }
      it { is_expected.to be_arithmetic }
      it { is_expected.not_to be_bitwise }
    end

    # NOTE: CommaSeparatedExpression has an arithmetic expression followed by a
    #       bitwise expression.
    context "`i + 1, j << 2'" do
      subject do
        comma_separated_expression(
          additive_expression(
            "+", object_specifier("i"), constant_specifier(1)),
          shift_expression(
            "<<", object_specifier("j"), constant_specifier(2)))
      end

      it { is_expected.not_to be_logical }
      it { is_expected.not_to be_arithmetic }
      it { is_expected.to be_bitwise }
    end

    # NOTE: CommaSeparatedExpression has two bitwise expressions.
    context "`i << 1, j << 2'" do
      subject do
        comma_separated_expression(
          shift_expression(
            "<<", object_specifier("i"), constant_specifier(1)),
          shift_expression(
            "<<", object_specifier("j"), constant_specifier(2)))
      end

      it { is_expected.not_to be_logical }
      it { is_expected.not_to be_arithmetic }
      it { is_expected.to be_bitwise }
    end

    # NOTE: CommaSeparatedExpression has a logical expression followed by a
    #       bitwise expression.
    context "`i > 0, i << 1'" do
      subject do
        comma_separated_expression(
          relational_expression(
            ">", object_specifier("i"), constant_specifier(0)),
          shift_expression(
            "<<", object_specifier("i"), constant_specifier(1)))
      end

      it { is_expected.not_to be_logical }
      it { is_expected.not_to be_arithmetic }
      it { is_expected.to be_bitwise }
    end

    # NOTE: CommaSeparatedExpression has two logical expressions.
    context "`i < 0, j > 0'" do
      subject do
        comma_separated_expression(
          relational_expression(
            "<", object_specifier("i"), constant_specifier(0)),
          relational_expression(
            ">", object_specifier("j"), constant_specifier(0)))
      end

      it { is_expected.to be_logical }
      it { is_expected.not_to be_arithmetic }
      it { is_expected.not_to be_bitwise }
    end

    private
    def comma_separated_expression(*exprs)
      CommaSeparatedExpression.new(exprs.first).tap do |obj|
        exprs.drop(1).each { |expr| obj.push(expr) }
      end
    end

    def compound_assignment_expression(op_str, lhs, rhs)
      CompoundAssignmentExpression.new(operator(op_str), lhs, rhs)
    end

    def simple_assignment_expression(lhs, rhs)
      SimpleAssignmentExpression.new(operator("="), lhs, rhs)
    end

    def conditional_expression(first, second, third)
      ConditionalExpression.new(first, second, third, operator("?"))
    end

    def inclusive_or_expression(lhs, rhs)
      InclusiveOrExpression.new(operator("|"), lhs, rhs)
    end

    def exclusive_or_expression(lhs, rhs)
      ExclusiveOrExpression.new(operator("^"), lhs, rhs)
    end

    def relational_expression(op_str, lhs, rhs)
      RelationalExpression.new(operator(op_str), lhs, rhs)
    end

    def multiplicative_expression(op_str, lhs, rhs)
      MultiplicativeExpression.new(operator(op_str), lhs, rhs)
    end

    def and_expression(lhs, rhs)
      AndExpression.new(operator("&"), lhs, rhs)
    end

    def equality_expression(op_str, lhs, rhs)
      EqualityExpression.new(operator(op_str), lhs, rhs)
    end

    def cast_expression(type_name, operand)
      CastExpression.new(type_name, operand)
    end

    def char_t_name
      sq_list = SpecifierQualifierList.new.tap { |obj|
        obj.type_qualifiers.push(char_t_specifier)
      }
      TypeName.new(sq_list, nil, symbol_table)
    end

    def char_t_specifier
      StandardTypeSpecifier.new(Token.new(:CHAR, "char", location))
    end

    def prefix_decrement_expression(operand)
      PrefixDecrementExpression.new(operator("--"), operand)
    end

    def prefix_increment_expression(operand)
      PrefixIncrementExpression.new(operator("++"), operand)
    end

    def postfix_decrement_expression(operand)
      PostfixDecrementExpression.new(operator("--"), operand)
    end

    def postfix_increment_expression(operand)
      PostfixIncrementExpression.new(operator("++"), operand)
    end

    def logical_or_expression(lhs, rhs)
      LogicalOrExpression.new(operator("||"), lhs, rhs)
    end

    def logical_and_expression(lhs, rhs)
      LogicalAndExpression.new(operator("&&"), lhs, rhs)
    end

    def shift_expression(op_str, lhs, rhs)
      ShiftExpression.new(operator(op_str), lhs, rhs)
    end

    def additive_expression(op_str, lhs, rhs)
      AdditiveExpression.new(operator(op_str), lhs, rhs)
    end

    def grouped_expression(expr)
      GroupedExpression.new(expr)
    end

    def error_expression(token)
      ErrorExpression.new(token)
    end

    def object_specifier(str)
      ObjectSpecifier.new(Token.new(:IDENTIFIER, str, location))
    end

    def null_constant_specifier
      NullConstantSpecifier.new(Token.new(:NULL, "NULL", location))
    end

    def constant_specifier(str)
      ConstantSpecifier.new(Token.new(:CONSTANT, str, location))
    end

    def string_literal_specifier(str)
      StringLiteralSpecifier.new(Token.new(:STRING_LITERAL, str, location))
    end

    def operator(str)
      Token.new(str, str, location)
    end

    def location
      Location.new
    end
  end

end
end
