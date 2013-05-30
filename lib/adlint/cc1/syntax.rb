# AST of C language.
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

require "adlint/symbol"
require "adlint/location"
require "adlint/exam"
require "adlint/util"
require "adlint/cc1/seqp"
require "adlint/cc1/operator"

module AdLint #:nodoc:
module Cc1 #:nodoc:

  # == DESCRIPTION
  # === SyntaxNode class hierarchy
  #  SyntaxNode
  #    <-- Expression
  #          <-- ErrorExpression
  #          <-- PrimaryExpression
  #                <-- ObjectSpecifier
  #                <-- ConstantSpecifier
  #                <-- StringLiteralSpecifier
  #                <-- NullConstantSpecifier
  #                <-- GroupedExpression
  #          <-- PostfixExpression
  #                <-- ArraySubscriptExpression
  #                <-- FunctionCallExpression
  #                <-- MemberAccessByValueExpression
  #                <-- MemberAccessByPointerExpression
  #                <-- BitAccessByValueExpression
  #                <-- BitAccessByPointerExpression
  #                <-- PostfixIncrementExpression
  #                <-- PostfixDecrementExpression
  #                <-- CompoundLiteralExpression
  #          <-- UnaryExpression
  #                <-- PrefixIncrementExpression
  #                <-- PrefixDecrementExpression
  #                <-- AddressExpression
  #                <-- IndirectionExpression
  #                <-- UnaryArithmeticExpression
  #                <-- SizeofExpression
  #                <-- SizeofTypeExpression
  #                <-- AlignofExpression
  #                <-- AlignofTypeExpression
  #          <-- CastExpression
  #          <-- BinaryExpression
  #                <-- MultiplicativeExpression
  #                <-- AdditiveExpression
  #                <-- ShiftExpression
  #                <-- RelationalExpression
  #                <-- EqualityExpression
  #                <-- AndExpression
  #                <-- ExclusiveOrExpression
  #                <-- InclusiveOrExpression
  #                <-- LogicalAndExpression
  #                <-- LogicalOrExpression
  #                <-- ConditionalExpression
  #                <-- SimpleAssignmentExpression
  #                <-- CompoundAssignmentExpression
  #          <-- CommaSeparatedExpression
  #    <-- Declaration
  #    <-- FunctionDeclaration -------------------- SymbolicElement <<module>>
  #    <-- VariableDeclaration ----------------------+  |  |  |  |
  #    <-- Definition                                   |  |  |  |
  #          <-- VariableDefinition --------------------+  |  |  |
  #                <-- PseudoVariableDefinition            |  |  |
  #          <-- FunctionDefinition -----------------------+  |  |
  #                <-- KandRFunctionDefinition                |  |
  #                <-- AnsiFunctionDefinition                 |  |
  #          <-- ParameterDefinition                          |  |
  #    <-- TypeDeclaration -----------------------------------+  |
  #          <-- TypedefDeclaration                              |
  #          <-- StructTypeDeclaration                           |
  #                <-- PseudoStructTypeDeclaration               |
  #          <-- UnionTypeDeclaration                            |
  #                <-- PseudoUnionTypeDeclaration                |
  #          <-- EnumTypeDeclaration                             |
  #                <-- PseudoEnumTypeDeclaration                 |
  #    <-- DeclarationSpecifiers                                 |
  #    <-- InitDeclarator                                        |
  #    <-- TypeSpecifier                                         |
  #          <-- StandardTypeSpecifier                           |
  #          <-- TypedefTypeSpecifier                            |
  #          <-- StructSpecifier                                 |
  #          <-- UnionSpecifier                                  |
  #          <-- TypeofTypeSpecifier                             |
  #    <-- StructDeclaration                                     |
  #    <-- MemberDeclaration                                     |
  #    <-- SpecifierQualifierList                                |
  #    <-- StructDeclarator                                      |
  #    <-- EnumSpecifier                                         |
  #    <-- Enumerator -------------------------------------------+
  #    <-- Declarator
  #          <-- IdentifierDeclarator
  #          <-- GroupedDeclarator
  #          <-- ArrayDeclarator
  #          <-- FunctionDeclarator
  #                <-- AnsiFunctionDeclarator
  #                <-- KandRFunctionDeclarator
  #                <-- AbbreviatedFunctionDeclarator
  #          <-- AbstractDeclarator
  #                <-- PointerAbstractDeclarator
  #                <-- GroupedAbstractDeclarator
  #                <-- ArrayAbstractDeclarator
  #                <-- FunctionAbstractDeclarator
  #    <-- ParameterTypeList
  #    <-- ParameterDeclaration
  #    <-- Statement
  #          <-- ErrorStatement
  #          <-- LabeledStatement
  #                <-- GenericLabeledStatement
  #                <-- CaseLabeledStatement
  #                <-- DefaultLabeledStatement
  #          <-- CompoundStatement
  #          <-- ExpressionStatement
  #          <-- SelectionStatement
  #                <-- IfStatement
  #                <-- IfElseStatement
  #                <-- SwitchStatement
  #          <-- IterationStatement
  #                <-- WhileStatement
  #                <-- DoStatement
  #                <-- ForStatement
  #                <-- C99ForStatement
  #          <-- JumpStatement
  #                <-- GotoStatement
  #                <-- ContinueStatement
  #                <-- BreakStatement
  #                <-- ReturnStatement
  #    <-- TranslationUnit
  #    <-- TypeName
  #    <-- Initializer
  class SyntaxNode
    include Visitable
    include LocationHolder

    def initialize
      @head_token = nil
      @tail_token = nil
      @subsequent_sequence_point = nil
    end

    attr_accessor :head_token
    attr_accessor :tail_token
    attr_reader :subsequent_sequence_point

    def location
      subclass_responsibility
    end

    def head_location
      @head_token ? @head_token.location : nil
    end

    def tail_location
      @tail_token ? @tail_token.location : nil
    end

    def inspect(indent = 0)
      subclass_responsibility
    end

    def short_class_name
      self.class.name.sub(/\A.*::/, "")
    end

    protected
    # === DESCRIPTION
    # Append a subsequent sequence-point of this node.
    def append_sequence_point!
      @subsequent_sequence_point = SequencePoint.new(self)
    end

    # === DESCRIPTION
    # Delete a subsequent sequence-point of this node.
    def delete_sequence_point!
      @subsequent_sequence_point = nil
    end
  end

  module SyntaxNodeCollector
    def collect_object_specifiers(node)
      if node
        ObjectSpecifierCollector.new.tap { |col|
          node.accept(col)
        }.object_specifiers
      else
        []
      end
    end
    module_function :collect_object_specifiers

    def collect_identifier_declarators(node)
      if node
        IdentifierDeclaratorCollector.new.tap { |col|
          node.accept(col)
        }.identifier_declarators
      else
        []
      end
    end
    module_function :collect_identifier_declarators

    def collect_typedef_type_specifiers(node)
      if node
        TypedefTypeSpecifierCollector.new.tap { |col|
          node.accept(col)
        }.typedef_type_specifiers
      else
        []
      end
    end
    module_function :collect_typedef_type_specifiers

    def collect_function_declarators(node)
      if node
        FunctionDeclaratorCollector.new.tap { |col|
          node.accept(col)
        }.function_declarators
      else
        []
      end
    end
    module_function :collect_function_declarators

    def collect_simple_assignment_expressions(node)
      if node
        SimpleAssignmentExpressionCollector.new.tap { |col|
          node.accept(col)
        }.simple_assignment_expressions
      else
        []
      end
    end
    module_function :collect_simple_assignment_expressions

    def collect_compound_assignment_expressions(node)
      if node
        CompoundAssignmentExpressionCollector.new.tap { |col|
          node.accept(col)
        }.compound_assignment_expressions
      else
        []
      end
    end
    module_function :collect_compound_assignment_expressions

    def collect_prefix_increment_expressions(node)
      if node
        PrefixIncrementExpressionCollector.new.tap { |col|
          node.accept(col)
        }.prefix_increment_expressions
      else
        []
      end
    end
    module_function :collect_prefix_increment_expressions

    def collect_prefix_decrement_expressions(node)
      if node
        PrefixDecrementExpressionCollector.new.tap { |col|
          node.accept(col)
        }.prefix_decrement_expressions
      else
        []
      end
    end
    module_function :collect_prefix_decrement_expressions

    def collect_postfix_increment_expressions(node)
      if node
        PostfixIncrementExpressionCollector.new.tap { |col|
          node.accept(col)
        }.postfix_increment_expressions
      else
        []
      end
    end
    module_function :collect_postfix_increment_expressions

    def collect_postfix_decrement_expressions(node)
      if node
        PostfixDecrementExpressionCollector.new.tap { |col|
          node.accept(col)
        }.postfix_decrement_expressions
      else
        []
      end
    end
    module_function :collect_postfix_decrement_expressions

    def collect_additive_expressions(node)
      if node
        AdditiveExpressionCollector.new.tap { |col|
          node.accept(col)
        }.additive_expressions
      else
        []
      end
    end
    module_function :collect_additive_expressions

    def collect_relational_expressions(node)
      if node
        RelationalExpressionCollector.new.tap { |col|
          node.accept(col)
        }.relational_expressions
      else
        []
      end
    end
    module_function :collect_relational_expressions

    def collect_equality_expressions(node)
      if node
        EqualityExpressionCollector.new.tap { |col|
          node.accept(col)
        }.equality_expressions
      else
        []
      end
    end
    module_function :collect_equality_expressions

    def collect_logical_and_expressions(node)
      if node
        LogicalAndExpressionCollector.new.tap { |col|
          node.accept(col)
        }.logical_and_expressions
      else
        []
      end
    end
    module_function :collect_logical_and_expressions

    def collect_logical_or_expressions(node)
      if node
        LogicalOrExpressionCollector.new.tap { |col|
          node.accept(col)
        }.logical_or_expressions
      else
        []
      end
    end
    module_function :collect_logical_or_expressions

    def collect_generic_labeled_statements(node)
      if node
        GenericLabeledStatementCollector.new.tap { |col|
          node.accept(col)
        }.generic_labeled_statements
      else
        []
      end
    end
    module_function :collect_generic_labeled_statements

    def collect_if_statements(node)
      if node
        IfStatementCollector.new.tap { |col|
          node.accept(col)
        }.if_statements
      else
        []
      end
    end
    module_function :collect_if_statements

    def collect_if_else_statements(node)
      if node
        IfElseStatementCollector.new.tap { |col|
          node.accept(col)
        }.if_else_statements
      else
        []
      end
    end
    module_function :collect_if_else_statements

    def collect_goto_statements(node)
      if node
        GotoStatementCollector.new.tap { |col|
          node.accept(col)
        }.goto_statements
      else
        []
      end
    end
    module_function :collect_goto_statements

    def collect_array_declarators(node)
      if node
        ArrayDeclaratorCollector.new.tap { |col|
          node.accept(col)
        }.array_declarators
      else
        []
      end
    end
    module_function :collect_array_declarators

    def collect_constant_specifiers(node)
      if node
        ConstantSpecifierCollector.new.tap { |col|
          node.accept(col)
        }.constant_specifiers
      else
        []
      end
    end
    module_function :collect_constant_specifiers
  end

  module InterpSyntaxBridge
    # NOTE: InterpreterMediator includes this module to bridge constant
    #       designator collector to this layer.

    def _interp_syntax_bridge_
      {
        enumerator_designators: method(:enumerator_designators),
        function_designators:   method(:function_designators),
        variable_designators:   method(:variable_designators)
      }
    end
  end

  class Expression < SyntaxNode
    def initialize
      super
      @full = false
    end

    def full=(expr_is_full)
      @full = expr_is_full

      # NOTE: The ISO C99 standard says;
      #
      # Annex C (informative) Sequence points
      #
      # 1 The following are the sequence points described in 5.1.2.3:
      #
      #   -- The end of a full expression: an initializer (6.7.8); the
      #      expression in an expression statement (6.8.3); the controlling
      #      expression of a while or do statement (6.8.5); each of the
      #      expressions of a for statement (6.8.5.3); the expression in a
      #      return statement (6.8.6.4).
      if expr_is_full
        append_sequence_point!
      else
        delete_sequence_point!
      end
    end

    def have_side_effect?
      subclass_responsibility
    end

    def constant?(interp_bridge)
      ExpressionConstancy.new(interp_bridge).check(self)
    end

    def logical?
      subclass_responsibility
    end

    def arithmetic?
      subclass_responsibility
    end

    def bitwise?
      subclass_responsibility
    end

    def object_specifiers
      ObjectSpecifierCollector.new.tap { |col|
        self.accept(col)
      }.object_specifiers
    end

    def to_normalized_logical(parent_expr = nil)
      subclass_responsibility
    end

    def to_complemental_logical
      # NOTE: This method must be invoked on a normalized expression.
      subclass_responsibility
    end

    def to_s
      subclass_responsibility
    end

    private
    def create_normalized_logical_of(expr)
      EqualityExpression.new(Token.new("!=", "!=", expr.location),
                             GroupedExpression.new(expr),
                             ConstantSpecifier.of_zero(expr.location))
    end
  end

  class ErrorExpression < Expression
    def initialize(err_tok)
      super()
      @error_token = err_tok
    end

    def location
      head_location
    end

    def have_side_effect?
      true
    end

    def logical?
      false
    end

    def arithmetic?
      false
    end

    def bitwise?
      false
    end

    def to_normalized_logical(parent_expr = nil)
      self
    end

    def to_complemental_logical
      self
    end

    def to_s
      @error_token.value
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name} (#{location.inspect}) " +
        "#{@error_token.value}"
    end
  end

  class PrimaryExpression < Expression; end

  class ObjectSpecifier < PrimaryExpression
    def initialize(id)
      super()
      @identifier = id
    end

    attr_reader :identifier

    def location
      @identifier.location
    end

    def have_side_effect?
      false
    end

    def logical?
      false
    end

    def arithmetic?
      false
    end

    def bitwise?
      false
    end

    def to_normalized_logical(parent_expr = nil)
      case parent_expr
      when nil, LogicalAndExpression, LogicalOrExpression
        create_normalized_logical_of(self)
      else
        self
      end
    end

    def to_complemental_logical
      self
    end

    def to_s
      @identifier.value
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name} (#{location.inspect}) " +
        "#{@identifier.value}"
    end
  end

  class ConstantSpecifier < PrimaryExpression
    def self.of_zero(loc = nil)
      self.new(Token.new(:CONSTANT, "0", loc || Location.new))
    end

    def initialize(const)
      super()
      @constant = const
    end

    attr_reader :constant

    def location
      @constant.location
    end

    def prefix
      @constant.value.scan(/\A(?:0x|0b|0(?=[0-9])|L)/i).first
    end

    def suffix
      @constant.value.scan(/(?:[UL]+|[FL]+)\z/i).first
    end

    def character?
      @constant.value =~ /'.*'/
    end

    def have_side_effect?
      false
    end

    def logical?
      false
    end

    def arithmetic?
      false
    end

    def bitwise?
      false
    end

    def to_normalized_logical(parent_expr = nil)
      case parent_expr
      when nil, LogicalAndExpression, LogicalOrExpression
        create_normalized_logical_of(self)
      else
        self
      end
    end

    def to_complemental_logical
      self
    end

    def to_s
      @constant.value
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name} (#{location.inspect}) " +
        "#{@constant.value}"
    end
  end

  class StringLiteralSpecifier < PrimaryExpression
    def initialize(lit)
      super()
      @literal = lit
    end

    attr_reader :literal

    def location
      @literal.location
    end

    def prefix
      @literal.value.scan(/\AL/i).first
    end

    def have_side_effect?
      false
    end

    def logical?
      false
    end

    def arithmetic?
      false
    end

    def bitwise?
      false
    end

    def to_normalized_logical(parent_expr = nil)
      case parent_expr
      when nil, LogicalAndExpression, LogicalOrExpression
        create_normalized_logical_of(self)
      else
        self
      end
    end

    def to_complemental_logical
      self
    end

    def to_s
      @literal.value
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name} (#{location.inspect}) " +
        "#{@literal.value}"
    end
  end

  class NullConstantSpecifier < PrimaryExpression
    def initialize(tok)
      super()
      @token = tok
    end

    attr_reader :token

    def location
      @token.location
    end

    def have_side_effect?
      false
    end

    def logical?
      false
    end

    def arithmetic?
      false
    end

    def bitwise?
      false
    end

    def to_normalized_logical(parent_expr = nil)
      case parent_expr
      when nil, LogicalAndExpression, LogicalOrExpression
        create_normalized_logical_of(self)
      else
        self
      end
    end

    def to_complemental_logical
      self
    end

    def to_s
      @token.value
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name} (#{location.inspect}) " +
        "#{@token.value}"
    end
  end

  class GroupedExpression < PrimaryExpression
    def initialize(expr)
      super()
      @expression = expr
      self.head_token = expr.head_token
      self.tail_token = expr.tail_token
    end

    attr_reader :expression

    def location
      head_location
    end

    def have_side_effect?
      @expression.have_side_effect?
    end

    def logical?
      @expression.logical?
    end

    def arithmetic?
      @expression.arithmetic?
    end

    def bitwise?
      @expression.bitwise?
    end

    def to_normalized_logical(parent_expr = nil)
      case parent_expr
      when nil, LogicalAndExpression, LogicalOrExpression
        GroupedExpression.new(@expression.to_normalized_logical(parent_expr))
      else
        self
      end
    end

    def to_complemental_logical
      GroupedExpression.new(@expression.to_complemental_logical)
    end

    def to_s
      "(#{expression.to_s})"
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name} (#{location.inspect})\n" +
        @expression.inspect(indent + 1)
    end
  end

  class PostfixExpression < Expression
    def initialize(op)
      @operator = op
    end

    attr_reader :operator

    def location
      @operator.location
    end
  end

  class ArraySubscriptExpression < PostfixExpression
    def initialize(expr, ary_subs, left_bracket)
      super(left_bracket)
      @expression = expr
      @array_subscript = ary_subs
    end

    attr_reader :expression
    attr_reader :array_subscript

    def have_side_effect?
      @expression.have_side_effect? || @array_subscript.have_side_effect?
    end

    def logical?
      false
    end

    def arithmetic?
      false
    end

    def bitwise?
      false
    end

    def to_normalized_logical(parent_expr = nil)
      case parent_expr
      when nil, LogicalAndExpression, LogicalOrExpression
        create_normalized_logical_of(self)
      else
        self
      end
    end

    def to_complemental_logical
      self
    end

    def to_s
      "#{@expression.to_s}[#{@array_subscript.to_s}]"
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name} (#{location.inspect})\n" +
        @expression.inspect(indent + 1) + "\n" +
        @array_subscript.inspect(indent + 1)
    end
  end

  class FunctionCallExpression < PostfixExpression
    def initialize(expr, arg_exprs, left_paren)
      super(left_paren)
      @expression = expr
      @argument_expressions = arg_exprs
    end

    attr_reader :expression
    attr_reader :argument_expressions

    def have_side_effect?
      true
    end

    def logical?
      false
    end

    def arithmetic?
      false
    end

    def bitwise?
      false
    end

    def to_normalized_logical(parent_expr = nil)
      case parent_expr
      when nil, LogicalAndExpression, LogicalOrExpression
        create_normalized_logical_of(self)
      else
        self
      end
    end

    def to_complemental_logical
      self
    end

    def to_s
      "#{@expression.to_s}(" +
        @argument_expressions.map { |expr| expr.to_s }.join(",") + ")"
    end

    def inspect(indent = 0)
      ([" " * indent + "#{short_class_name} (#{location.inspect})"] +
       [@expression.inspect(indent + 1)] +
       @argument_expressions.map { |a| a.inspect(indent + 1) }).join("\n")
    end
  end

  class MemberAccessByValueExpression < PostfixExpression
    def initialize(expr, id, dot)
      super(dot)
      @expression = expr
      @identifier = id
    end

    attr_reader :expression
    attr_reader :identifier

    def have_side_effect?
      @expression.have_side_effect?
    end

    def logical?
      false
    end

    def arithmetic?
      false
    end

    def bitwise?
      false
    end

    def to_normalized_logical(parent_expr = nil)
      case parent_expr
      when nil, LogicalAndExpression, LogicalOrExpression
        create_normalized_logical_of(self)
      else
        self
      end
    end

    def to_complemental_logical
      self
    end

    def to_s
      "#{@expression.to_s}.#{@identifier.value}"
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name} (#{location.inspect}) " +
        "#{@expression.inspect}.#{@identifier.value}"
    end
  end

  class MemberAccessByPointerExpression < PostfixExpression
    def initialize(expr, id, arrow)
      super(arrow)
      @expression = expr
      @identifier = id
    end

    attr_reader :expression
    attr_reader :identifier

    def have_side_effect?
      @expression.have_side_effect?
    end

    def logical?
      false
    end

    def arithmetic?
      false
    end

    def bitwise?
      false
    end

    def to_normalized_logical(parent_expr = nil)
      case parent_expr
      when nil, LogicalAndExpression, LogicalOrExpression
        create_normalized_logical_of(self)
      else
        self
      end
    end

    def to_complemental_logical
      self
    end

    def to_s
      "#{@expression.to_s}->#{@identifier.value}"
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name} (#{location.inspect}) " +
        "#{@expression.inspect}->#{@identifier.value}"
    end
  end

  class BitAccessByValueExpression < PostfixExpression
    def initialize(expr, const, dot)
      super(dot)
      @expression = expr
      @constant = const
    end

    attr_reader :expression
    attr_reader :constant

    def have_side_effect?
      @expression.have_side_effect?
    end

    def logical?
      false
    end

    def arithmetic?
      false
    end

    def bitwise?
      false
    end

    def to_normalized_logical(parent_expr = nil)
      case parent_expr
      when nil, LogicalAndExpression, LogicalOrExpression
        create_normalized_logical_of(self)
      else
        self
      end
    end

    def to_complemental_logical
      self
    end

    def to_s
      "#{@expression.to_s}.#{@constant.value}"
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name} (#{location.inspect}) " +
        "#{@expression.inspect}.#{@constant.value}"
    end
  end

  class BitAccessByPointerExpression < PostfixExpression
    def initialize(expr, const, arrow)
      super(arrow)
      @expression = expr
      @constant = const
    end

    attr_reader :expression
    attr_reader :constant

    def have_side_effect?
      @expression.have_side_effect?
    end

    def logical?
      false
    end

    def arithmetic?
      false
    end

    def bitwise?
      false
    end

    def to_normalized_logical(parent_expr = nil)
      case parent_expr
      when nil, LogicalAndExpression, LogicalOrExpression
        create_normalized_logical_of(self)
      else
        self
      end
    end

    def to_complemental_logical
      self
    end

    def to_s
      "#{@expression.to_s}->#{@constant.value}"
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name} (#{location.inspect}) " +
        "#{@expression.inspect}->#{@constant.value}"
    end
  end

  class PostfixIncrementExpression < PostfixExpression
    def initialize(op, ope)
      super(op)
      @operand = ope
    end

    attr_reader :operand

    def have_side_effect?
      true
    end

    def logical?
      false
    end

    def arithmetic?
      true
    end

    def bitwise?
      false
    end

    def to_normalized_logical(parent_expr = nil)
      case parent_expr
      when nil, LogicalAndExpression, LogicalOrExpression
        create_normalized_logical_of(self)
      else
        self
      end
    end

    def to_complemental_logical
      self
    end

    def to_s
      "#{@operand.to_s}++"
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name} (#{location.inspect}) " +
        @operand.inspect
    end
  end

  class PostfixDecrementExpression < PostfixExpression
    def initialize(op, ope)
      super(op)
      @operand = ope
    end

    attr_reader :operand

    def have_side_effect?
      true
    end

    def logical?
      false
    end

    def arithmetic?
      true
    end

    def bitwise?
      false
    end

    def to_normalized_logical(parent_expr = nil)
      case parent_expr
      when nil, LogicalAndExpression, LogicalOrExpression
        create_normalized_logical_of(self)
      else
        self
      end
    end

    def to_complemental_logical
      self
    end

    def to_s
      "#{@operand.to_s}--"
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name} (#{location.inspect}) " +
        @operand.inspect
    end
  end

  class CompoundLiteralExpression < PostfixExpression
    def initialize(type_name, inits, left_paren)
      super(left_paren)
      @type_name = type_name
      @initializers = inits
    end

    attr_reader :type_name
    attr_reader :initializers

    def have_side_effect?
      false
    end

    def logical?
      false
    end

    def arithmetic?
      false
    end

    def bitwise?
      false
    end

    def to_normalized_logical(parent_expr = nil)
      case parent_expr
      when nil, LogicalAndExpression, LogicalOrExpression
        create_normalized_logical_of(self)
      else
        self
      end
    end

    def to_complemental_logical
      self
    end

    def to_s
      "(#{@type_name.to_s}){" +
        @initializers.map { |ini| ini.to_s }.join(",") + "}"
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name} (#{location.inspect}) " +
        @initializers.map { |init| init.inspect }.join(",")
    end
  end

  class UnaryExpression < Expression
    def initialize(op, ope)
      super()
      @operator = op
      @operand = ope
    end

    attr_reader :operator
    attr_reader :operand

    def location
      @operator.location
    end

    def to_s
      @operator.value + @operand.to_s
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name} (#{location.inspect}) " +
        "#{@operator.value} #{@operand.inspect}"
    end
  end

  class PrefixIncrementExpression < UnaryExpression
    def have_side_effect?
      true
    end

    def logical?
      false
    end

    def arithmetic?
      true
    end

    def bitwise?
      false
    end

    def to_normalized_logical(parent_expr = nil)
      case parent_expr
      when nil, LogicalAndExpression, LogicalOrExpression
        create_normalized_logical_of(self)
      else
        self
      end
    end

    def to_complemental_logical
      self
    end
  end

  class PrefixDecrementExpression < UnaryExpression
    def have_side_effect?
      true
    end

    def logical?
      false
    end

    def arithmetic?
      true
    end

    def bitwise?
      false
    end

    def to_normalized_logical(parent_expr = nil)
      case parent_expr
      when nil, LogicalAndExpression, LogicalOrExpression
        create_normalized_logical_of(self)
      else
        self
      end
    end

    def to_complemental_logical
      self
    end
  end

  class AddressExpression < UnaryExpression
    def have_side_effect?
      operand.have_side_effect?
    end

    def logical?
      false
    end

    def arithmetic?
      false
    end

    def bitwise?
      false
    end

    def to_normalized_logical(parent_expr = nil)
      case parent_expr
      when nil, LogicalAndExpression, LogicalOrExpression
        create_normalized_logical_of(self)
      else
        self
      end
    end

    def to_complemental_logical
      self
    end
  end

  class IndirectionExpression < UnaryExpression
    def have_side_effect?
      operand.have_side_effect?
    end

    def logical?
      false
    end

    def arithmetic?
      false
    end

    def bitwise?
      false
    end

    def to_normalized_logical(parent_expr = nil)
      case parent_expr
      when nil, LogicalAndExpression, LogicalOrExpression
        create_normalized_logical_of(self)
      else
        self
      end
    end

    def to_complemental_logical
      self
    end
  end

  class UnaryArithmeticExpression < UnaryExpression
    def have_side_effect?
      operand.have_side_effect?
    end

    def logical?
      operator.type == "!"
    end

    def arithmetic?
      false
    end

    def bitwise?
      operator.type == "~"
    end

    def to_normalized_logical(parent_expr = nil)
      if operator.type == "!"
        normalized_operand = @operand.to_normalized_logical
        GroupedExpression.new(normalized_operand.to_complemental_logical)
      else
        case parent_expr
        when nil, LogicalAndExpression, LogicalOrExpression
          create_normalized_logical_of(self)
        else
          self
        end
      end
    end

    def to_complemental_logical
      if operator.type == "!"
        # NOTE: `!' expression should be normalized into an equality-expression
        #       before invoking #to_complemental_logical.
        __NOTREACHED__
      else
        self
      end
    end
  end

  class SizeofExpression < UnaryExpression
    def have_side_effect?
      false
    end

    def logical?
      false
    end

    def arithmetic?
      false
    end

    def bitwise?
      false
    end

    def to_normalized_logical(parent_expr = nil)
      case parent_expr
      when nil, LogicalAndExpression, LogicalOrExpression
        create_normalized_logical_of(self)
      else
        self
      end
    end

    def to_complemental_logical
      self
    end

    def to_s
      "sizeof(#{@operand.to_s})"
    end
  end

  class SizeofTypeExpression < UnaryExpression
    def have_side_effect?
      false
    end

    def logical?
      false
    end

    def arithmetic?
      false
    end

    def bitwise?
      false
    end

    def to_normalized_logical(parent_expr = nil)
      case parent_expr
      when nil, LogicalAndExpression, LogicalOrExpression
        create_normalized_logical_of(self)
      else
        self
      end
    end

    def to_complemental_logical
      self
    end

    def to_s
      "sizeof(#{@operand.to_s})"
    end
  end

  class AlignofExpression < UnaryExpression
    def have_side_effect?
      false
    end

    def logical?
      false
    end

    def arithmetic?
      false
    end

    def bitwise?
      false
    end

    def to_normalized_logical(parent_expr = nil)
      case parent_expr
      when nil, LogicalAndExpression, LogicalOrExpression
        create_normalized_logical_of(self)
      else
        self
      end
    end

    def to_complemental_logical
      self
    end

    def to_s
      "alignof(#{@operand.to_s})"
    end
  end

  class AlignofTypeExpression < UnaryExpression
    def have_side_effect?
      false
    end

    def logical?
      false
    end

    def arithmetic?
      false
    end

    def bitwise?
      false
    end

    def to_normalized_logical(parent_expr = nil)
      case parent_expr
      when nil, LogicalAndExpression, LogicalOrExpression
        create_normalized_logical_of(self)
      else
        self
      end
    end

    def to_complemental_logical
      self
    end

    def to_s
      "alignof(#{@operand.to_s})"
    end
  end

  class CastExpression < Expression
    def initialize(type_name, ope)
      super()
      @type_name = type_name
      @operand = ope
    end

    attr_reader :type_name
    attr_reader :operand

    def location
      head_location
    end

    def have_side_effect?
      @operand.have_side_effect?
    end

    def logical?
      @operand.logical?
    end

    def arithmetic?
      @operand.arithmetic?
    end

    def bitwise?
      @operand.bitwise?
    end

    def to_normalized_logical(parent_expr = nil)
      case parent_expr
      when nil, LogicalAndExpression, LogicalOrExpression
        create_normalized_logical_of(self)
      else
        self
      end
    end

    def to_complemental_logical
      self
    end

    def to_s
      "(#{@type_name.to_s}) #{@operand.to_s}"
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name} (#{location.inspect}) " +
        "#{@type_name.inspect} #{@operand.inspect}"
    end
  end

  class BinaryExpression < Expression
    def initialize(op, lhs_operand, rhs_operand)
      super()
      @operator = op
      @lhs_operand = lhs_operand
      @rhs_operand = rhs_operand
    end

    attr_reader :operator
    attr_reader :lhs_operand
    attr_reader :rhs_operand

    def location
      @operator.location
    end

    def to_s
      "#{@lhs_operand.to_s} #{@operator.value} #{@rhs_operand.to_s}"
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name} (#{location.inspect}) " +
        "#{@operator.value} #{lhs_operand.inspect} #{rhs_operand.inspect}"
    end
  end

  class MultiplicativeExpression < BinaryExpression
    def have_side_effect?
      lhs_operand.have_side_effect? || rhs_operand.have_side_effect?
    end

    def logical?
      false
    end

    def arithmetic?
      true
    end

    def bitwise?
      false
    end

    def to_normalized_logical(parent_expr = nil)
      case parent_expr
      when nil, LogicalAndExpression, LogicalOrExpression
        create_normalized_logical_of(self)
      else
        self
      end
    end

    def to_complemental_logical
      self
    end
  end

  class AdditiveExpression < BinaryExpression
    def have_side_effect?
      lhs_operand.have_side_effect? || rhs_operand.have_side_effect?
    end

    def logical?
      false
    end

    def arithmetic?
      true
    end

    def bitwise?
      false
    end

    def to_normalized_logical(parent_expr = nil)
      case parent_expr
      when nil, LogicalAndExpression, LogicalOrExpression
        create_normalized_logical_of(self)
      else
        self
      end
    end

    def to_complemental_logical
      self
    end
  end

  class ShiftExpression < BinaryExpression
    def have_side_effect?
      lhs_operand.have_side_effect? || rhs_operand.have_side_effect?
    end

    def logical?
      false
    end

    def arithmetic?
      false
    end

    def bitwise?
      true
    end

    def to_normalized_logical(parent_expr = nil)
      case parent_expr
      when nil, LogicalAndExpression, LogicalOrExpression
        create_normalized_logical_of(self)
      else
        self
      end
    end

    def to_complemental_logical
      self
    end
  end

  class RelationalExpression < BinaryExpression
    def have_side_effect?
      lhs_operand.have_side_effect? || rhs_operand.have_side_effect?
    end

    def logical?
      true
    end

    def arithmetic?
      false
    end

    def bitwise?
      false
    end

    def to_normalized_logical(parent_expr = nil)
      self
    end

    def to_complemental_logical
      op = ComparisonOperator.new(@operator).for_complement.to_s
      op_tok = Token.new(op, op, @operator.location)
      RelationalExpression.new(op_tok, @lhs_operand, @rhs_operand)
    end
  end

  class EqualityExpression < BinaryExpression
    def have_side_effect?
      lhs_operand.have_side_effect? || rhs_operand.have_side_effect?
    end

    def logical?
      true
    end

    def arithmetic?
      false
    end

    def bitwise?
      false
    end

    def to_normalized_logical(parent_expr = nil)
      self
    end

    def to_complemental_logical
      op = ComparisonOperator.new(@operator).for_complement.to_s
      op_tok = Token.new(op, op, @operator.location)
      EqualityExpression.new(op_tok, @lhs_operand, @rhs_operand)
    end
  end

  class AndExpression < BinaryExpression
    def have_side_effect?
      lhs_operand.have_side_effect? || rhs_operand.have_side_effect?
    end

    def logical?
      false
    end

    def arithmetic?
      false
    end

    def bitwise?
      true
    end

    def to_normalized_logical(parent_expr = nil)
      case parent_expr
      when nil, LogicalAndExpression, LogicalOrExpression
        create_normalized_logical_of(self)
      else
        self
      end
    end

    def to_complemental_logical
      self
    end
  end

  class ExclusiveOrExpression < BinaryExpression
    def have_side_effect?
      lhs_operand.have_side_effect? || rhs_operand.have_side_effect?
    end

    def logical?
      false
    end

    def arithmetic?
      false
    end

    def bitwise?
      true
    end

    def to_normalized_logical(parent_expr = nil)
      case parent_expr
      when nil, LogicalAndExpression, LogicalOrExpression
        create_normalized_logical_of(self)
      else
        self
      end
    end

    def to_complemental_logical
      self
    end
  end

  class InclusiveOrExpression < BinaryExpression
    def have_side_effect?
      lhs_operand.have_side_effect? || rhs_operand.have_side_effect?
    end

    def logical?
      false
    end

    def arithmetic?
      false
    end

    def bitwise?
      true
    end

    def to_normalized_logical(parent_expr = nil)
      case parent_expr
      when nil, LogicalAndExpression, LogicalOrExpression
        create_normalized_logical_of(self)
      else
        self
      end
    end

    def to_complemental_logical
      self
    end
  end

  class LogicalAndExpression < BinaryExpression
    def initialize(op, lhs_operand, rhs_operand)
      super

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
      #
      # NOTE: Sequence point will be reached after lhs value reference.
      #       So, notification should be done by ExpressionEvaluator manually.
      # @lhs_operand.append_sequence_point!
    end

    def have_side_effect?
      lhs_operand.have_side_effect? || rhs_operand.have_side_effect?
    end

    def logical?
      true
    end

    def arithmetic?
      false
    end

    def bitwise?
      false
    end

    def to_normalized_logical(parent_expr = nil)
      LogicalAndExpression.new(@operator,
                               @lhs_operand.to_normalized_logical(self),
                               @rhs_operand.to_normalized_logical(self))
    end

    def to_complemental_logical
      LogicalOrExpression.new(Token.new("||", "||", @operator.location),
                              @lhs_operand.to_complemental_logical,
                              @rhs_operand.to_complemental_logical)
    end
  end

  class LogicalOrExpression < BinaryExpression
    def initialize(op, lhs_operand, rhs_operand)
      super

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
      #
      # NOTE: Sequence point will be reached after lhs value reference.
      #       So, notification should be done by ExpressionEvaluator manually.
      # @lhs_operand.append_sequence_point!
    end

    def have_side_effect?
      lhs_operand.have_side_effect? || rhs_operand.have_side_effect?
    end

    def logical?
      true
    end

    def arithmetic?
      false
    end

    def bitwise?
      false
    end

    def to_normalized_logical(parent_expr = nil)
      LogicalOrExpression.new(@operator,
                              @lhs_operand.to_normalized_logical(self),
                              @rhs_operand.to_normalized_logical(self))
    end

    def to_complemental_logical
      LogicalAndExpression.new(Token.new("&&", "&&", @operator.location),
                               @lhs_operand.to_complemental_logical,
                               @rhs_operand.to_complemental_logical)
    end
  end

  class ConditionalExpression < Expression
    def initialize(cond, then_expr, else_expr, question_mark)
      super()
      @condition = cond
      @then_expression = then_expr
      @else_expression = else_expr
      @question_mark = question_mark

      # NOTE: The ISO C99 standard says;
      #
      # 6.5.15 Conditional operator
      #
      # Semantics
      #
      # 4 The first operand is evaluated; there is a sequence poit after its
      #   evaluation.  The second operand is evaluated only if the first
      #   compares unequal to 0; the third operand is evaluated only if the
      #   first compares equal to 0; thre result is the value of the second or
      #   third operand (whichever is evaluated), converted to the type
      #   described below.  If an attempt is made to modify the result of a
      #   conditional operator or to access it after the next sequence point,
      #   the behavior is undefined.
      @condition.append_sequence_point!

      # NOTE: Add extra sequence points in order not to warn about side-effects
      #       in both the 2nd and 3rd expressions because only one of the 2nd
      #       and 3rd expressions is actually executed.
      @then_expression.append_sequence_point!
      @else_expression.append_sequence_point!
    end

    attr_reader :condition
    attr_reader :then_expression
    attr_reader :else_expression

    def location
      @question_mark.location
    end

    def have_side_effect?
      @condition.have_side_effect? ||
        @then_expression.have_side_effect? ||
        @else_expression.have_side_effect?
    end

    def logical?
      @then_expression.logical? || @else_expression.logical?
    end

    def arithmetic?
      @then_expression.arithmetic? || @else_expression.arithmetic?
    end

    def bitwise?
      @then_expression.bitwise? || @else_expression.bitwise?
    end

    def to_normalized_logical(parent_expr = nil)
      case parent_expr
      when nil, LogicalAndExpression, LogicalOrExpression
        create_normalized_logical_of(self)
      else
        self
      end
    end

    def to_complemental_logical
      self
    end

    def to_s
      "#{@condition.to_s} ? " +
        "#{@then_expression.to_s} : #{@else_expression.to_s}"
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name}\n" +
        @condition.inspect(indent + 1) + "\n" +
        @then_expression.inspect(indent + 1) + "\n" +
        @else_expression.inspect(indent + 1)
    end
  end

  class SimpleAssignmentExpression < BinaryExpression
    def have_side_effect?
      true
    end

    def logical?
      rhs_operand.logical?
    end

    def arithmetic?
      rhs_operand.arithmetic?
    end

    def bitwise?
      rhs_operand.bitwise?
    end

    def to_normalized_logical(parent_expr = nil)
      case parent_expr
      when nil, LogicalAndExpression, LogicalOrExpression
        create_normalized_logical_of(self)
      else
        self
      end
    end

    def to_complemental_logical
      self
    end
  end

  class CompoundAssignmentExpression < BinaryExpression
    def have_side_effect?
      true
    end

    def logical?
      false
    end

    def arithmetic?
      ["*=", "/=", "%=", "+=", "-="].include?(operator.type)
    end

    def bitwise?
      ["<<=", ">>=", "&=", "^=", "|="].include?(operator.type)
    end

    def to_normalized_logical(parent_expr = nil)
      case parent_expr
      when nil, LogicalAndExpression, LogicalOrExpression
        create_normalized_logical_of(self)
      else
        self
      end
    end

    def to_complemental_logical
      self
    end
  end

  class CommaSeparatedExpression < Expression
    def initialize(fst_expr)
      super()
      @expressions = []
      push(fst_expr)
    end

    attr_reader :expressions

    def location
      head_location
    end

    def have_side_effect?
      @expressions.any? { |expr| expr.have_side_effect? }
    end

    def logical?
      @expressions.last.logical?
    end

    def arithmetic?
      @expressions.last.arithmetic?
    end

    def bitwise?
      @expressions.last.bitwise?
    end

    def to_normalized_logical(parent_expr = nil)
      case parent_expr
      when nil, LogicalAndExpression, LogicalOrExpression
        create_normalized_logical_of(@expressions.last)
      else
        self
      end
    end

    def to_complemental_logical
      @expressions.last.to_complemental_logical
    end

    def to_s
      @expressions.map { |expr| expr.to_s }.join(",")
    end

    def push(expr)
      self.head_token = expr.head_token if @expressions.empty?
      @expressions.push(expr)
      self.tail_token = expr.tail_token

      # NOTE: The ISO C99 standard says;
      #
      # 6.5.17 Comma operator
      #
      # Semantics
      #
      # 2 The left operand of a comma operator is evaluated as a void
      #   expression; there is a sequence point after its evaluation.  Then the
      #   right operand is evaluated; the result has its type and value.  If an
      #   attempt is made to modify the result of a comma operator or to access
      #   it after the next sequence point, the behavior is undefined.
      @expressions[-2].append_sequence_point! if @expressions.size > 1
      self
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name}\n" +
        @expressions.map { |expr| expr.inspect(indent + 1) }.join("\n")
    end
  end

  module DeclarationSpecifiersHolder
    def storage_class_specifier
      @declaration_specifiers ?
        @declaration_specifiers.storage_class_specifier : nil
    end

    def function_specifier
      # NOTE: A function-specifier should only be in function-definitions.
      @declaration_specifiers ?
        @declaration_specifiers.function_specifier : nil
    end

    def type_qualifiers
      @declaration_specifiers ? @declaration_specifiers.type_qualifiers : []
    end

    def type_specifiers
      @declaration_specifiers ? @declaration_specifiers.type_specifiers : []
    end

    def explicitly_typed?
      @declaration_specifiers && @declaration_specifiers.explicitly_typed?
    end

    def implicitly_typed?
      !explicitly_typed?
    end
  end

  class Declaration < SyntaxNode
    include DeclarationSpecifiersHolder

    def initialize(dcl_specs, init_dcrs, sym_tbl)
      super()
      @declaration_specifiers = dcl_specs
      @init_declarators = init_dcrs
      @items = build_items(dcl_specs, init_dcrs, sym_tbl)
    end

    attr_reader :declaration_specifiers
    attr_reader :init_declarators
    attr_reader :items

    def location
      head_location
    end

    def inspect(indent = 0)
      ([" " * indent + "#{short_class_name} (#{location.inspect})"] +
       @items.map { |item| item.inspect(indent + 1) }).join("\n")
    end

    private
    def build_items(dcl_specs, init_dcrs, sym_tbl)
      build_type_declaration(dcl_specs, init_dcrs, sym_tbl) +
        build_function_declaration(dcl_specs, init_dcrs, sym_tbl) +
        build_variable_declaration(dcl_specs, init_dcrs, sym_tbl) +
        build_variable_definition(dcl_specs, init_dcrs, sym_tbl)
    end

    def build_type_declaration(dcl_specs, init_dcrs, sym_tbl)
      return [] unless dcl_specs

      type_dcls = []

      dcl_specs.type_specifiers.each do |type_spec|
        builder = TypeDeclarationBuilder.new(sym_tbl)
        type_spec.accept(builder)
        type_dcls.concat(builder.type_declarations)
      end

      if sc = dcl_specs.storage_class_specifier and sc.type == :TYPEDEF
        init_dcrs.each do |init_dcr|
          id = init_dcr.declarator.identifier
          sym = sym_tbl.create_new_symbol(TypedefName, id)
          type_dcls.push(TypedefDeclaration.new(dcl_specs, init_dcr, sym))
        end
      end

      type_dcls
    end

    def build_function_declaration(dcl_specs, init_dcrs, sym_tbl)
      if dcl_specs && sc_spec = dcl_specs.storage_class_specifier and
          sc_spec.type == :TYPEDEF
        return []
      end

      init_dcrs.each_with_object([]) do |init_dcr, fun_dcls|
        if init_dcr.declarator.function?
          id = init_dcr.declarator.identifier
          sym = sym_tbl.create_new_symbol(ObjectName, id)
          fun_dcls.push(FunctionDeclaration.new(dcl_specs, init_dcr, sym))
        end
      end
    end

    def build_variable_declaration(dcl_specs, init_dcrs, sym_tbl)
      return [] unless dcl_specs

      unless sc = dcl_specs.storage_class_specifier and sc.type == :EXTERN
        return []
      end

      init_dcrs.each_with_object([]) do |init_dcr, var_dcls|
        if init_dcr.declarator.variable?
          dcr = init_dcr.declarator
          sym = sym_tbl.create_new_symbol(ObjectName, dcr.identifier)
          var_dcls.push(VariableDeclaration.new(dcl_specs, dcr, sym))
        end
      end
    end

    def build_variable_definition(dcl_specs, init_dcrs, sym_tbl)
      if dcl_specs && sc = dcl_specs.storage_class_specifier and
          sc.type == :EXTERN || sc.type == :TYPEDEF
        return []
      end

      init_dcrs.each_with_object([]) do |init_dcr, var_defs|
        if init_dcr.declarator.variable?
          id = init_dcr.declarator.identifier
          sym = sym_tbl.create_new_symbol(ObjectName, id)
          var_defs.push(VariableDefinition.new(dcl_specs, init_dcr, sym))
        end
      end
    end
  end

  class FunctionDeclaration < SyntaxNode
    include SymbolicElement
    include DeclarationSpecifiersHolder
    include SyntaxNodeCollector

    def initialize(dcl_specs, init_dcr, sym)
      super()
      @declaration_specifiers = dcl_specs
      @init_declarator = init_dcr
      @symbol = sym
      @type = nil
    end

    attr_reader :declaration_specifiers
    attr_reader :init_declarator
    attr_reader :symbol
    attr_accessor :type

    def identifier
      @init_declarator.declarator.identifier
    end

    def signature
      FunctionSignature.new(identifier.value, @type)
    end

    def function_declarator
      collect_function_declarators(@init_declarator).first
    end

    def location
      identifier.location
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name} (#{location.inspect}) " +
        identifier.value
    end
  end

  class VariableDeclaration < SyntaxNode
    include SymbolicElement
    include DeclarationSpecifiersHolder

    def initialize(dcl_specs, dcr, sym)
      super()
      @declaration_specifiers = dcl_specs
      @declarator = dcr
      @symbol = sym
      @type = nil
    end

    attr_reader :declaration_specifiers
    attr_reader :declarator
    attr_reader :symbol
    attr_accessor :type

    def identifier
      @declarator.identifier
    end

    def location
      identifier.location
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name} (#{location.inspect}) " +
        identifier.value
    end
  end

  class Definition < SyntaxNode
    include DeclarationSpecifiersHolder

    def initialize(dcl_specs)
      @declaration_specifiers = dcl_specs
      @type = nil
    end

    attr_reader :declaration_specifiers
    attr_accessor :type
  end

  class VariableDefinition < Definition
    include SymbolicElement

    def initialize(dcl_specs, init_dcr, sym)
      super(dcl_specs)

      @init_declarator = init_dcr
      @symbol = sym
    end

    attr_reader :init_declarator
    attr_reader :symbol

    def identifier
      @init_declarator.declarator.identifier
    end

    def initializer
      @init_declarator.initializer
    end

    def location
      identifier.location
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name} (#{location.inspect}) " +
        identifier.value
    end
  end

  class TypeDeclaration < SyntaxNode
    include SymbolicElement

    def initialize(sym)
      super()
      @symbol = sym
    end

    attr_reader :symbol
  end

  class TypedefDeclaration < TypeDeclaration
    include DeclarationSpecifiersHolder

    def initialize(dcl_specs, init_dcr, sym)
      super(sym)
      @declaration_specifiers = dcl_specs
      @init_declarator = init_dcr
      @type = nil
    end

    attr_reader :declaration_specifiers
    attr_reader :init_declarator
    attr_accessor :type

    def identifier
      @init_declarator.declarator.identifier
    end

    def declarator
      @init_declarator.declarator
    end

    def location
      identifier.location
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name} (#{location.inspect}) " +
        identifier.value
    end
  end

  class StructTypeDeclaration < TypeDeclaration
    def initialize(struct_spec, sym)
      super(sym)
      @struct_specifier = struct_spec
      @struct_declarations = struct_spec.struct_declarations
      @type = nil
    end

    attr_reader :struct_specifier
    attr_reader :struct_declarations
    attr_accessor :type

    def identifier
      @struct_specifier.identifier
    end

    def location
      identifier.location
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name} (#{location.inspect}) " +
        "#{identifier.value}\n" +
        @struct_declarations.map { |sd| sd.inspect(indent + 1) }.join("\n")
    end
  end

  class PseudoStructTypeDeclaration < StructTypeDeclaration
    def initialize(struct_spec)
      super(struct_spec, nil)
    end

    def mark_as_referred_by(tok) end
  end

  class UnionTypeDeclaration < TypeDeclaration
    def initialize(union_spec, sym)
      super(sym)
      @union_specifier = union_spec
      @struct_declarations = union_spec.struct_declarations
      @type = nil
    end

    attr_reader :union_specifier
    attr_reader :struct_declarations
    attr_accessor :type

    def identifier
      @union_specifier.identifier
    end

    def location
      identifier.location
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name} (#{location.inspect}) " +
        "#{identifier.value}\n" +
        @struct_declarations.map { |sd| sd.inspect(indent + 1) }.join("\n")
    end
  end

  class PseudoUnionTypeDeclaration < UnionTypeDeclaration
    def initialize(union_spec)
      super(union_spec, nil)
    end

    def mark_as_referred_by(tok) end
  end

  class EnumTypeDeclaration < TypeDeclaration
    def initialize(enum_spec, sym)
      super(sym)
      @enum_specifier = enum_spec
      @type = nil
    end

    attr_reader :enum_specifier
    attr_accessor :type

    def identifier
      @enum_specifier.identifier
    end

    def location
      identifier.location
    end

    def enumerators
      @enum_specifier.enumerators
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name} (#{location.inspect}) " +
        "#{identifier.value}"
    end
  end

  class PseudoEnumTypeDeclaration < EnumTypeDeclaration
    def initialize(enum_spec)
      super(enum_spec, nil)
    end

    def mark_as_referred_by(tok) end
  end

  class DeclarationSpecifiers < SyntaxNode
    def initialize
      super
      @storage_class_specifier = nil
      @function_specifier = nil
      @type_qualifiers = []
      @type_specifiers = []
    end

    attr_accessor :storage_class_specifier
    attr_accessor :function_specifier
    attr_reader :type_qualifiers
    attr_reader :type_specifiers

    def location
      head_location
    end

    def explicitly_typed?
      !implicitly_typed?
    end

    def implicitly_typed?
      @type_specifiers.empty?
    end

    def inspect(indent = 0)
      " " * indent + short_class_name
    end
  end

  class InitDeclarator < SyntaxNode
    def initialize(dcr, init)
      super()
      @declarator = dcr
      @initializer = init
    end

    attr_reader :declarator
    attr_reader :initializer

    def location
      @declarator.identifier.location
    end

    def inspect(indent = 0)
      " " * indent + short_class_name
    end
  end

  class TypeSpecifier < SyntaxNode
    def to_s
      subclass_responsibility
    end
  end

  class StandardTypeSpecifier < TypeSpecifier
    def initialize(tok)
      super()
      @token = tok
    end

    attr_reader :token

    def location
      head_location
    end

    def to_s
      @token.value
    end

    def inspect(indent = 0)
      " " * indent + short_class_name
    end
  end

  class TypedefTypeSpecifier < TypeSpecifier
    def initialize(tok)
      super()
      @token = tok
    end

    attr_reader :token

    def location
      head_location
    end

    def identifier
      @token
    end

    def to_s
      @token.value
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name} (#{location.inspect}) " +
        @token.value
    end
  end

  class StructSpecifier < TypeSpecifier
    def initialize(id, struct_dcls)
      super()
      @identifier = id
      @struct_declarations = struct_dcls
    end

    attr_reader :identifier
    attr_reader :struct_declarations

    def location
      @identifier.location
    end

    def to_s
      if @struct_declarations
        if @struct_declarations.empty?
          "struct #{identifier.value} {}"
        else
          "struct #{identifier.value} { " +
            @struct_declarations.map { |decl| decl.to_s }.join(" ") + " }"
        end
      else
        "struct #{identifier.value}"
      end
    end

    def inspect(indent = 0)
      " " * indent + short_class_name
    end
  end

  class UnionSpecifier < TypeSpecifier
    def initialize(id, struct_dcls)
      super()
      @identifier = id
      @struct_declarations = struct_dcls
    end

    attr_reader :identifier
    attr_reader :struct_declarations

    def location
      @identifier.location
    end

    def to_s
      if @struct_declarations
        if @struct_declarations.empty?
          "union #{identifier.value} {}"
        else
          "union #{identifier.value} { " +
            @struct_declarations.map { |decl| decl.to_s }.join(" ") +
            " }"
        end
      else
        "union #{identifier.value}"
      end
    end

    def inspect(indent = 0)
      " " * indent + short_class_name
    end
  end

  class StructDeclaration < SyntaxNode
    def initialize(spec_qual_list, struct_dcrs)
      super()
      @specifier_qualifier_list = spec_qual_list
      @struct_declarators = struct_dcrs
      @items = build_items(spec_qual_list, struct_dcrs)
    end

    attr_reader :specifier_qualifier_list
    attr_reader :struct_declarators
    attr_reader :items

    def location
      @specifier_qualifier_list.location
    end

    def to_s
      @items.map { |item| item.to_s + ";" }.join(" ")
    end

    def inspect(indent = 0)
      ([" " * indent + "#{short_class_name} (#{location.inspect})"] +
       @items.map { |item| item.inspect(indent + 1) }).join("\n")
    end

    private
    def build_items(spec_qual_list, struct_dcrs)
      struct_dcrs.each_with_object([]) do |struct_dcr, items|
        # FIXME: Must support unnamed bit padding.
        next unless struct_dcr.declarator
        items.push(MemberDeclaration.new(spec_qual_list, struct_dcr))
      end
    end
  end

  class MemberDeclaration < SyntaxNode
    def initialize(spec_qual_list, struct_dcl)
      super()
      @specifier_qualifier_list = spec_qual_list
      @struct_declarator = struct_dcl
      @type = nil
    end

    attr_reader :specifier_qualifier_list
    attr_reader :struct_declarator
    attr_accessor :type

    def identifier
      @struct_declarator.declarator.identifier
    end

    def location
      identifier.location
    end

    def to_s
      "#{type.brief_image} #{identifier.value}"
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name} (#{location.inspect}) " +
        identifier.value
    end
  end

  class SpecifierQualifierList < SyntaxNode
    def initialize
      super
      @type_specifiers = []
      @type_qualifiers = []
    end

    attr_reader :type_specifiers
    attr_reader :type_qualifiers

    def location
      head_location
    end

    def inspect(indent = 0)
      " " * indent + short_class_name
    end
  end

  class StructDeclarator < SyntaxNode
    def initialize(dcr, expr)
      super()
      @declarator = dcr
      @expression = expr
    end

    attr_reader :declarator
    attr_reader :expression

    def location
      @declarator ? @declarator.location : @expression.location
    end

    def bitfield?
      @expression != nil
    end

    def inspect(indent = 0)
      " " * indent + short_class_name
    end
  end

  class EnumSpecifier < TypeSpecifier
    def initialize(id, enums, trailing_comma = nil)
      super()
      @identifier = id
      @enumerators = enums
      @trailing_comma = trailing_comma
    end

    attr_reader :identifier
    attr_reader :enumerators
    attr_reader :trailing_comma

    def location
      @identifier.location
    end

    def to_s
      if @enumerators
        if @enumerators.empty?
          "enum #{@identifier.value} {}"
        else
          "enum #{@identifier.value} { " +
            @enumerators.map { |enum| enum.to_s }.join(", ") + " }"
        end
      else
        "enum #{identifier.value}"
      end
    end

    def inspect(indent = 0)
      " " * indent + short_class_name
    end
  end

  class Enumerator < SyntaxNode
    include SymbolicElement

    def initialize(id, expr, sym)
      super()
      @identifier = id
      @expression = expr
      @symbol = sym
    end

    attr_reader :identifier
    attr_reader :expression
    attr_reader :symbol
    attr_accessor :value
    attr_accessor :type

    def location
      @identifier.location
    end

    def to_s
      if @expression
        "#{@identifier.value} = #{@expression.to_s}"
      else
        "#{@identifier.value}"
      end
    end

    def inspect(indent = 0)
      " " * indent + short_class_name
    end
  end

  class TypeofTypeSpecifier < TypeSpecifier
    def initialize(expr, type_name)
      super()
      @expression = expr
      @type_name = type_name
    end

    attr_reader :expression
    attr_reader :type_name

    def location
      head_location
    end

    def to_s
      if @expression
        "__typeof__(#{@expression.to_s})"
      else
        "__typeof__(#{@type_name.to_s})"
      end
    end

    def inspect(indent = 0)
      " " * indent + short_class_name
    end
  end

  class Declarator < SyntaxNode
    def initialize
      super
      @pointer = nil
      @full = false
    end

    attr_accessor :pointer

    def identifier
      subclass_responsibility
    end

    def abstract?
      false
    end

    def full=(dcr_is_full)
      @full = dcr_is_full

      # NOTE: The ISO C99 standard says;
      #
      # 6.7.5 Declarators
      #
      # Semantics
      #
      # 3 A full declarator is a declarator that is not part of another
      #   declarator.  The end of a full declarator is a sequence point.  If,
      #   in the nested sequence of declarators in a full declarator, there is
      #   a declarator specifying a variable length array type, the type
      #   specified by the full declarator is said to be variably modified.
      #   Furthermore, any type derived by declarator type derivation from a
      #   variably modified type is itself variably modified.
      if dcr_is_full
        append_sequence_point!
      else
        delete_sequence_point!
      end
    end

    def full?
      @full
    end

    def base
      subclass_responsibility
    end

    def function?
      subclass_responsibility
    end

    def variable?
      !function?
    end

    def parameter_type_list
      subclass_responsibility
    end

    def innermost_parameter_type_list
      subclass_responsibility
    end

    def identifier_list
      subclass_responsibility
    end
  end

  class IdentifierDeclarator < Declarator
    def initialize(id)
      super()
      @identifier = id
    end

    attr_reader :identifier

    def location
      @identifier.location
    end

    def base
      nil
    end

    def parameter_type_list
      nil
    end

    def innermost_parameter_type_list
      nil
    end

    def identifier_list
      nil
    end

    def function?(stack = [])
      stack.push(:pointer) if pointer
      stack.last == :function
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name} #{@identifier.value}"
    end
  end

  class GroupedDeclarator < Declarator
    def initialize(base_dcr)
      super()
      @base = base_dcr
    end

    attr_reader :base

    def location
      @base ? @base.location || head_location : head_location
    end

    def identifier
      @base.identifier
    end

    def parameter_type_list
      @base.parameter_type_list
    end

    def innermost_parameter_type_list
      @base.innermost_parameter_type_list
    end

    def identifier_list
      @base.identifier_list
    end

    def function?(stack = [])
      stack.push(:pointer) if pointer
      @base.function?(stack)
      stack.last == :function
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name}\n" + @base.inspect(indent + 1)
    end
  end

  class ArrayDeclarator < Declarator
    def initialize(base_dcr, size_expr)
      super()
      @base = base_dcr
      @size_expression = size_expr
    end

    attr_reader :base
    attr_reader :size_expression

    def location
      @base ? @base.location || head_location : head_location
    end

    def identifier
      @base.identifier
    end

    def parameter_type_list
      @base.parameter_type_list
    end

    def innermost_parameter_type_list
      @base.innermost_parameter_type_list
    end

    def identifier_list
      @base.identifier_list
    end

    def function?(stack = [])
      stack.push(:pointer) if pointer
      stack.push(:array)
      @base.function?(stack)
      stack.last == :function
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name}\n" + @base.inspect(indent + 1)
    end
  end

  class FunctionDeclarator < Declarator
    def initialize(base_dcr)
      super()
      @base = base_dcr
    end

    attr_reader :base

    def location
      @base ? @base.location || head_location : head_location
    end

    def identifier
      @base.identifier
    end

    def function?(stack = [])
      stack.push(:pointer) if pointer
      stack.push(:function)
      @base.function?(stack)
      stack.last == :function
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name}\n" + @base.inspect(indent + 1)
    end
  end

  class AnsiFunctionDeclarator < FunctionDeclarator
    def initialize(base_dcr, param_type_list)
      super(base_dcr)
      @parameter_type_list = param_type_list
    end

    attr_accessor :parameter_type_list

    def innermost_parameter_type_list
      @base.innermost_parameter_type_list || @parameter_type_list
    end

    def identifier_list
      @base.identifier_list
    end
  end

  class KandRFunctionDeclarator < FunctionDeclarator
    def initialize(base_dcr, id_list)
      super(base_dcr)
      @identifier_list = id_list
    end

    attr_reader :identifier_list

    def parameter_type_list
      @base.parameter_type_list
    end

    def innermost_parameter_type_list
      @base.innermost_parameter_type_list
    end
  end

  class AbbreviatedFunctionDeclarator < FunctionDeclarator
    def parameter_type_list
      @base.parameter_type_list
    end

    def innermost_parameter_type_list
      @base.innermost_parameter_type_list
    end

    def identifier_list
      @base.identifier_list
    end
  end

  class ParameterTypeList < SyntaxNode
    def initialize(params, have_va_list)
      super()
      @parameters = params
      @have_va_list = have_va_list
    end

    attr_reader :parameters

    def location
      head_location
    end

    def have_va_list?
      @have_va_list
    end

    def inspect(indent = 0)
      " " * indent + short_class_name
    end
  end

  class ParameterDeclaration < SyntaxNode
    include DeclarationSpecifiersHolder

    def initialize(dcl_specs, dcr)
      super()
      @declaration_specifiers = dcl_specs
      @declarator = dcr
      @type = nil
    end

    attr_reader :declaration_specifiers
    attr_reader :declarator
    attr_accessor :type

    def location
      @declarator ? @declarator.location : @declaration_specifiers.location
    end

    def inspect(indent = 0)
      " " * indent + short_class_name
    end
  end

  class Statement < SyntaxNode
    def initialize
      super
      @executed = false
    end

    attr_writer :executed

    def executed?
      @executed
    end
  end

  class ErrorStatement < Statement
    def initialize(err_tok)
      super()
      @error_token = err_tok
    end

    def location
      head_location
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name}"
    end
  end

  class LabeledStatement < Statement; end

  class GenericLabeledStatement < LabeledStatement
    def initialize(label, stmt)
      super()
      @label = label
      @statement = stmt
      @referrers = []
    end

    attr_reader :label
    attr_reader :statement
    attr_reader :referrers

    def location
      @label.location
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name} (#{@label.inspect})\n" +
        @statement.inspect(indent + 1)
    end
  end

  class CaseLabeledStatement < LabeledStatement
    def initialize(expr, stmt)
      super()
      @expression = expr
      @statement = stmt
    end

    attr_reader :expression
    attr_reader :statement
    attr_accessor :normalized_expression

    def location
      head_location
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name}\n" +
        @expression.inspect(indent + 1) + "\n" + @statement.inspect(indent + 1)
    end
  end

  class DefaultLabeledStatement < LabeledStatement
    def initialize(stmt)
      super()
      @statement = stmt
    end

    attr_reader :statement
    attr_accessor :normalized_expression

    def location
      head_location
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name}\n" + @statement.inspect(indent + 1)
    end
  end

  class CompoundStatement < Statement
    def initialize(block_items)
      super()
      @block_items = block_items
    end

    attr_reader :block_items

    def location
      head_location
    end

    def inspect(indent = 0)
      ([" " * indent + short_class_name] +
       @block_items.map { |item| item.inspect(indent + 1) }).join("\n")
    end
  end

  class ExpressionStatement < Statement
    def initialize(expr)
      super()
      @expression = expr
    end

    attr_reader :expression

    def location
      head_location
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name}" +
        (@expression ? "\n#{@expression.inspect(indent + 1)}" : "")
    end
  end

  class SelectionStatement < Statement; end

  class IfStatement < SelectionStatement
    def initialize(expr, stmt, header_term)
      super()
      @expression = expr
      @statement = stmt
      @header_terminator = header_term
    end

    attr_reader :expression
    attr_reader :statement
    attr_reader :header_terminator

    def location
      head_location
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name}\n" +
        @expression.inspect(indent + 1) + "\n" + @statement.inspect(indent + 1)
    end
  end

  class IfElseStatement < SelectionStatement
    def initialize(expr, then_stmt, else_stmt, then_term, else_term)
      super()
      @expression = expr
      @then_statement = then_stmt
      @else_statement = else_stmt
      @then_header_terminator = then_term
      @else_header_terminator = else_term
    end

    attr_reader :expression
    attr_reader :then_statement
    attr_reader :else_statement
    attr_reader :then_header_terminator
    attr_reader :else_header_terminator

    def location
      head_location
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name}\n" +
        @expression.inspect(indent + 1) + "\n" +
        @then_statement.inspect(indent + 1) + "\n" +
        @else_statement.inspect(indent + 1)
    end
  end

  class SwitchStatement < SelectionStatement
    def initialize(expr, stmt)
      super()
      @expression = expr
      @statement = stmt
      derive_clause_conditions
    end

    attr_reader :expression
    attr_reader :statement

    def location
      head_location
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name}\n" +
        @expression.inspect(indent + 1) + "\n" + @statement.inspect(indent + 1)
    end

    private
    def derive_clause_conditions
      case_exprs = []
      default_stmt = nil

      @statement.block_items.each do |item|
        case item
        when GenericLabeledStatement
          item = item.statement
          redo
        when CaseLabeledStatement
          item.normalized_expression =
            equal_to_expression(@expression, item.expression, item.location)
          case_exprs.push(item.normalized_expression)
          item = item.statement
          redo
        when DefaultLabeledStatement
          default_stmt = item
          item = item.statement
          redo
        end
      end

      if default_stmt
        default_stmt.normalized_expression =
          derive_default_clause_condition(case_exprs, default_stmt.location)
      end
    end

    def derive_default_clause_condition(case_exprs, loc)
      if case_exprs.empty?
        equal_to_expression(@expression, @expression, loc)
      else
        case_exprs.map { |expr|
          not_equal_to_expression(expr.lhs_operand, expr.rhs_operand, loc)
        }.reduce { |cond, expr| logical_and_expression(cond, expr, loc) }
      end
    end

    def equal_to_expression(lhs, rhs, loc)
      EqualityExpression.new(equal_to_operator(loc), lhs, rhs)
    end

    def not_equal_to_expression(lhs, rhs, loc)
      EqualityExpression.new(not_equal_to_operator(loc), lhs, rhs)
    end

    def logical_and_expression(lhs, rhs, loc)
      LogicalAndExpression.new(logical_and_operator(loc), lhs, rhs)
    end

    def equal_to_operator(loc)
      Token.new("==", "==", loc)
    end

    def not_equal_to_operator(loc)
      Token.new("!=", "!=", loc)
    end

    def logical_and_operator(loc)
      Token.new("&&", "&&", loc)
    end
  end

  class IterationStatement < Statement
    include SyntaxNodeCollector

    def deduct_controlling_expression
      subclass_responsibility
    end

    def varying_variable_names
      collect_varying_variable_names(self).uniq
    end

    def varying_expressions
      collect_varying_binary_expressions(self) +
        collect_varying_unary_expressions(self)
    end

    private
    def deduct_controlling_expression_candidates(rough_cands)
      varying_var_names = varying_variable_names
      rough_cands.select do |expr_pair|
        collect_object_specifiers(expr_pair.first).any? do |os|
          varying_var_names.include?(os.identifier.value)
        end
      end
    end

    def collect_loop_breaking_selection_statements(node)
      collect_loop_breaking_if_statements(node) +
        collect_loop_breaking_if_else_statements(node)
    end

    def collect_loop_breaking_if_statements(node)
      collect_if_statements(node).select do |stmt|
        contain_loop_breaking?(stmt.statement)
      end
    end

    def collect_loop_breaking_if_else_statements(node)
      collect_if_else_statements(node).select do |stmt|
        contain_loop_breaking?(stmt.then_statement) ||
          contain_loop_breaking?(stmt.else_statement)
      end
    end

    def contain_loop_breaking?(node)
      items = node.kind_of?(CompoundStatement) ? node.block_items : [node]
      items.any? do |item|
        case item
        when GenericLabeledStatement
          item = item.statement
          redo
        when GotoStatement
          # FIXME: Must check whether the goto-statement goes outside of the
          #        loop or not.
          true
        when BreakStatement
          true
        when ReturnStatement
          true
        else
          false
        end
      end
    end

    def collect_varying_variable_names(node)
      collect_varying_variable_names_in_binary_expression(node) +
        collect_varying_variable_names_in_unary_expression(node)
    end

    def collect_varying_variable_names_in_binary_expression(node)
      collect_varying_binary_expressions(node).map do |expr|
        expr.lhs_operand.identifier.value
      end
    end

    def collect_varying_binary_expressions(node)
      all_varying_binary_exprs =
        collect_simple_assignment_expressions(node) +
        collect_compound_assignment_expressions(node)

      all_varying_binary_exprs.select do |expr|
        expr.lhs_operand.kind_of?(ObjectSpecifier)
      end
    end
    memoize :collect_varying_binary_expressions

    def collect_varying_variable_names_in_unary_expression(node)
      collect_varying_unary_expressions(node).map do |expr|
        expr.operand.identifier.value
      end
    end

    def collect_varying_unary_expressions(node)
      all_varying_unary_exprs =
        collect_prefix_increment_expressions(node) +
        collect_prefix_decrement_expressions(node) +
        collect_postfix_increment_expressions(node) +
        collect_postfix_decrement_expressions(node)

      all_varying_unary_exprs.select do |expr|
        expr.operand.kind_of?(ObjectSpecifier)
      end
    end
    memoize :collect_varying_unary_expressions
  end

  class WhileStatement < IterationStatement
    def initialize(expr, stmt, header_term)
      super()
      @expression = expr
      @statement = stmt
      @header_terminator = header_term
    end

    attr_reader :expression
    attr_reader :statement
    attr_reader :header_terminator

    def location
      head_location
    end

    def deduct_controlling_expression
      sels = collect_loop_breaking_selection_statements(@statement)
      rough_cands = [[@expression, @expression]] + sels.map { |stmt|
        [stmt.expression,
          stmt.expression.to_normalized_logical.to_complemental_logical]
      }

      # FIXME: When many loop breaking selection-statements are found, how can
      #        I select one selection-statement?
      # FIXME: When the loop breaking selection-statement is a
      #        if-else-statement and the loop breaking is in the else branch,
      #        the controlling expression should be inverted.
      deduct_controlling_expression_candidates(rough_cands).first
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name}\n" +
        @expression.inspect(indent + 1) + "\n" + @statement.inspect(indent + 1)
    end
  end

  class DoStatement < IterationStatement
    def initialize(stmt, expr, header_term, footer_init)
      super()
      @statement = stmt
      @expression = expr
      @header_terminator = header_term
      @footer_initiator = footer_init
    end

    attr_reader :statement
    attr_reader :expression
    attr_reader :header_terminator
    attr_reader :footer_initiator

    def location
      head_location
    end

    def deduct_controlling_expression
      sels = collect_loop_breaking_selection_statements(@statement)
      rough_cands = [[@expression, @expression]] + sels.map { |stmt|
        [stmt.expression,
          stmt.expression.to_normalized_logical.to_complemental_logical]
      }

      # FIXME: When many loop breaking selection-statements are found, how can
      #        I select one selection-statement?
      # FIXME: When the loop breaking selection-statement is a
      #        if-else-statement and the loop breaking is in the else branch,
      #        the controlling expression should be inverted.
      deduct_controlling_expression_candidates(rough_cands).first
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name}\n" +
        @statement.inspect(indent + 1) + "\n" + @expression.inspect(indent + 1)
    end
  end

  class ForStatement < IterationStatement
    def initialize(init_stmt, cond_stmt, expr, body_stmt, header_term)
      super()
      @initial_statement   = init_stmt
      @condition_statement = cond_stmt
      @expression          = expr
      @body_statement      = body_stmt
      @header_terminator   = header_term
    end

    attr_reader :initial_statement
    attr_reader :condition_statement
    attr_reader :expression
    attr_reader :body_statement
    attr_reader :header_terminator

    def location
      head_location
    end

    def deduct_controlling_expression
      sels = collect_loop_breaking_selection_statements(@body_statement)
      rough_cands = [
        [@condition_statement.expression, @condition_statement.expression]
      ] + sels.map { |stmt|
        [stmt.expression,
          stmt.expression.to_normalized_logical.to_complemental_logical]
      }

      # FIXME: When many loop breaking selection-statements are found, how can
      #        I select one selection-statement?
      # FIXME: When the loop breaking selection-statement is a
      #        if-else-statement and the loop breaking is in the else branch,
      #        the controlling expression should be inverted.
      deduct_controlling_expression_candidates(rough_cands).first
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name}\n" +
        @initial_statement.inspect(indent + 1) + "\n" +
        @condition_statement.inspect(indent + 1) +
        (@expression ? "\n#{@expression.inspect(indent + 1)}" : "") +
        "\n" + @body_statement.inspect(indent + 1)
    end
  end

  class C99ForStatement < IterationStatement
    def initialize(dcl, cond_stmt, expr, body_stmt, header_term)
      super()
      @declaration         = dcl
      @condition_statement = cond_stmt
      @expression          = expr
      @body_statement      = body_stmt
      @header_terminator   = header_term
    end

    attr_reader :declaration
    attr_reader :condition_statement
    attr_reader :expression
    attr_reader :body_statement
    attr_reader :header_terminator

    def location
      head_location
    end

    def deduct_controlling_expression
      sels = collect_loop_breaking_selection_statements(@body_statement)
      rough_cands = [
        [@condition_statement.expression, @condition_statement.expression]
      ] + sels.map { |stmt|
        [stmt.expression,
          stmt.expression.to_normalized_logical.to_complemental_logical]
      }

      # FIXME: When many loop breaking selection-statements are found, how can
      #        I select one selection-statement?
      # FIXME: When the loop breaking selection-statement is a
      #        if-else-statement and the loop breaking is in the else branch,
      #        the controlling expression should be inverted.
      deduct_controlling_expression_candidates(rough_cands).first
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name}\n" +
        @declaration.inspect(indent + 1) + "\n" +
        @condition_statement.inspect(indent + 1) +
        (@expression ? "\n#{@expression.inspect(indent + 1)}" : "") +
        "\n" + @body_statement.inspect(indent + 1)
    end
  end

  class JumpStatement < Statement
    def location
      head_location
    end
  end

  class GotoStatement < JumpStatement
    def initialize(id)
      super()
      @identifier = id
    end

    attr_reader :identifier

    def inspect(indent = 0)
      " " * indent + "#{short_class_name} (#{@identifier.inspect})"
    end
  end

  class ContinueStatement < JumpStatement
    def inspect(indent = 0)
      " " * indent + "#{short_class_name} (#{location.inspect})"
    end
  end

  class BreakStatement < JumpStatement
    def inspect(indent = 0)
      " " * indent + "#{short_class_name} (#{location.inspect})"
    end
  end

  class ReturnStatement < JumpStatement
    def initialize(expr)
      super()
      @expression = expr
    end

    attr_reader :expression

    def inspect(indent = 0)
      " " * indent + "#{short_class_name} (#{location.inspect})" +
        (@expression ? "\n#{@expression.inspect(indent + 1)}" : "")
    end
  end

  class TranslationUnit < SyntaxNode
    def initialize
      super
      @external_declarations = []
    end

    attr_reader :external_declarations

    def push(external_dcl)
      if @external_declarations.empty?
        self.head_token = external_dcl.head_token
      end
      @external_declarations.push(external_dcl)
      self.tail_token = external_dcl.tail_token
      self
    end

    def location
      head_location ? head_location : Location.new
    end

    def inspect(indent = 0)
      ([" " * indent + short_class_name] +
       @external_declarations.map { |d| d.inspect(indent + 1) }).join("\n")
    end
  end

  class FunctionDefinition < Definition
    include SymbolicElement
    include SyntaxNodeCollector

    def initialize(dcl_specs, dcr, param_defs, compound_stmt, sym_tbl)
      super(dcl_specs)

      @declarator = dcr
      @parameter_definitions = param_defs
      @function_body = compound_stmt
      @symbol = sym_tbl.create_new_symbol(ObjectName, identifier)
      @type_declaration = build_type_declaration(dcl_specs, sym_tbl)
      build_label_references(compound_stmt)
    end

    attr_reader :declarator
    attr_reader :parameter_definitions
    attr_reader :function_body
    attr_reader :symbol
    attr_reader :type_declaration

    def identifier
      @declarator.identifier
    end

    def signature
      FunctionSignature.new(identifier.value, @type)
    end

    def function_declarator
      collect_function_declarators(@declarator).first
    end

    def lines
      start_line = identifier.location.line_no
      end_line = @function_body.tail_location.line_no
      end_line - start_line + 1
    end

    def location
      identifier.location
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name} (#{location.inspect}) " +
        (storage_class_specifier ? "#{storage_class_specifier.value} " : "") +
        (function_specifier ? "#{function_specifier.value} " : "") +
        "#{identifier.value}\n" +
        @parameter_definitions.map { |p| p.inspect(indent + 1) }.join("\n") +
        "\n#{@function_body.inspect(indent + 1)}"
    end

    private
    def build_type_declaration(dcl_specs, sym_tbl)
      return nil unless dcl_specs
      dcl_specs.type_specifiers.each do |type_spec|
        builder = TypeDeclarationBuilder.new(sym_tbl)
        type_spec.accept(builder)
        unless builder.type_declarations.empty?
          return builder.type_declarations.first
        end
      end
      nil
    end

    def build_label_references(compound_stmt)
      labels = collect_generic_labeled_statements(compound_stmt)

      gotos = collect_goto_statements(compound_stmt)

      labels.each do |generic_labeled_stmt|
        label_name = generic_labeled_stmt.label.value
        gotos.select { |goto_stmt|
          goto_stmt.identifier.value == label_name
        }.each do |goto_stmt|
          generic_labeled_stmt.referrers.push(goto_stmt)
        end
      end
    end
  end

  class KandRFunctionDefinition < FunctionDefinition
    def initialize(dcl_specs, dcr, dcls, compound_stmt, sym_tbl)
      param_defs = create_parameters(dcr.identifier_list, dcls, sym_tbl)
      super(dcl_specs, dcr, param_defs, compound_stmt, sym_tbl)
    end

    def identifier_list
      declarator.identifier_list
    end

    private
    def create_parameters(param_names, dcls, sym_tbl)
      return [] unless param_names

      param_names.each_with_object([]) do |name, param_defs|
        var_def = find_variable_definition(dcls, name, sym_tbl)
        param_defs.push(variable_definition_to_parameter_definition(var_def))
      end
    end

    def find_variable_definition(dcls, name, sym_tbl)
      dcls.each do |dcl|
        dcl.items.select { |item|
          item.kind_of?(VariableDefinition)
        }.each do |var_def|
          if var_def.identifier.value == name.value
            return var_def
          end
        end
      end

      dcls.push(dcl = implicit_parameter_definition(name, sym_tbl))
      dcl.items.first
    end

    def variable_definition_to_parameter_definition(var_def)
      dcl_specs = var_def.declaration_specifiers
      dcr = var_def.init_declarator.declarator
      param_def = ParameterDefinition.new(dcl_specs, dcr)

      unless dcl_specs
        param_def.head_token = dcr.head_token
        param_def.tail_token = dcr.tail_token
      end

      unless dcr
        param_def.head_token = dcl_specs.head_token
        param_def.tail_token = dcl_specs.tail_token
      end

      param_def
    end

    def implicit_parameter_definition(id, sym_tbl)
      init_dcr = InitDeclarator.new(IdentifierDeclarator.new(id), nil)
      Declaration.new(nil, [init_dcr], sym_tbl)
    end
  end

  class AnsiFunctionDefinition < FunctionDefinition
    def initialize(dcl_specs, dcr, compound_stmt, sym_tbl)
      super(dcl_specs, dcr,
            create_parameters(dcr.innermost_parameter_type_list),
            compound_stmt, sym_tbl)
    end

    def parameter_type_list
      declarator.parameter_type_list
    end

    private
    def create_parameters(param_type_list)
      return [] unless param_type_list
      param_type_list.parameters.map do |param_dcl|
        dcl_specs = param_dcl.declaration_specifiers
        dcr = param_dcl.declarator
        param_def = ParameterDefinition.new(dcl_specs, dcr)

        unless dcl_specs
          param_def.head_token = dcr.head_token
          param_def.tail_token = dcr.tail_token
        end

        unless dcr
          param_def.head_token = dcl_specs.head_token
          param_def.tail_token = dcl_specs.tail_token
        end

        param_def
      end
    end
  end

  class ParameterDefinition < Definition
    def initialize(dcl_specs, dcr)
      super(dcl_specs)
      @declarator = dcr
    end

    attr_reader :declarator

    def identifier
      if @declarator
        if @declarator.abstract?
          nil
        else
          @declarator.identifier
        end
      else
        nil
      end
    end

    def location
      case
      when identifier
        identifier.location
      when declaration_specifiers
        declaration_specifiers.location
      else
        Location.new
      end
    end

    def to_variable_definition
      PseudoVariableDefinition.new(declaration_specifiers,
                                   InitDeclarator.new(@declarator, nil),
                                   type)
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name} (#{location.inspect}) " +
        (storage_class_specifier ? storage_class_specifier.inspect : "") +
        (identifier ? identifier.value : "")
    end
  end

  class PseudoVariableDefinition < VariableDefinition
    def initialize(dcl_specs, init_dcr, type)
      super(dcl_specs, init_dcr, nil)
      self.type = type
    end

    def mark_as_referred_by(token) end
  end

  class TypeName < SyntaxNode
    def initialize(spec_qual_list, abstract_dcr, sym_tbl)
      super()
      @specifier_qualifier_list = spec_qual_list
      @abstract_declarator = abstract_dcr
      @type = nil
      @type_declaration = build_type_declaration(spec_qual_list, sym_tbl)
    end

    attr_reader :specifier_qualifier_list
    attr_reader :abstract_declarator
    attr_accessor :type
    attr_reader :type_declaration

    def location
      @specifier_qualifier_list.location
    end

    def to_s
      @type.image
    end

    def inspect(indent = 0)
      " " * indent + short_class_name + " (#{@type ? @type.image : "nil"})"
    end

    private
    def build_type_declaration(spec_qual_list, sym_tbl)
      spec_qual_list.type_specifiers.each do |type_spec|
        builder = TypeDeclarationBuilder.new(sym_tbl)
        type_spec.accept(builder)
        unless builder.type_declarations.empty?
          return builder.type_declarations.first
        end
      end
      nil
    end
  end

  class AbstractDeclarator < Declarator
    def identifier
      nil
    end

    def abstract?
      true
    end
  end

  class PointerAbstractDeclarator < AbstractDeclarator
    def initialize(abstract_dcr, ptr)
      super()
      @base = abstract_dcr
      @pointer = ptr
    end

    attr_reader :base

    def location
      @base ? @base.location || head_location : head_location
    end

    def function?(stack = [])
      stack.push(:pointer)
      @base.function?(stack) if @base
      stack.last == :function
    end

    def parameter_type_list
      @base.parameter_type_list
    end

    def innermost_parameter_type_list
      @base.innermost_parameter_type_list
    end

    def identifier_list
      @base.identifier_list
    end

    def inspect(indent = 0)
      " " * indent + short_class_name
    end
  end

  class GroupedAbstractDeclarator < AbstractDeclarator
    def initialize(abstract_dcr)
      super()
      @base = abstract_dcr
    end

    attr_reader :base

    def location
      @base ? @base.location || head_location : head_location
    end

    def function?
      @base.function?
    end

    def parameter_type_list
      @base.parameter_type_list
    end

    def innermost_parameter_type_list
      @base.innermost_parameter_type_list
    end

    def identifier_list
      @base.identifier_list
    end

    def inspect(indent = 0)
      " " * indent + short_class_name
    end
  end

  class ArrayAbstractDeclarator < AbstractDeclarator
    def initialize(abstract_dcr, size_expr)
      super()
      @base = abstract_dcr
      @size_expression = size_expr
    end

    attr_reader :base
    attr_reader :size_expression

    def location
      @base ? @base.location || head_location : head_location
    end

    def function?(stack = [])
      stack.push(:array)
      @base.function?(stack) if @base
      stack.last == :function
    end

    def parameter_type_list
      @base.parameter_type_list
    end

    def innermost_parameter_type_list
      @base.innermost_parameter_type_list
    end

    def identifier_list
      @base.identifier_list
    end

    def inspect(indent = 0)
      " " * indent + short_class_name
    end
  end

  class FunctionAbstractDeclarator < AbstractDeclarator
    def initialize(abstract_dcr, param_type_list)
      super()
      @base = abstract_dcr
      @parameter_type_list = param_type_list
    end

    attr_reader :base
    attr_reader :parameter_type_list

    def location
      @base ? @base.location || head_location : head_location
    end

    def function?(stack = [])
      stack.push(:function)
      @base.function?(stack) if @base
      stack.last == :function
    end

    def innermost_parameter_type_list
      @base.innermost_parameter_type_list || @parameter_type_list
    end

    def inspect(indent = 0)
      " " * indent + short_class_name
    end
  end

  class Initializer < SyntaxNode
    def initialize(expr, inits)
      super()
      @expression = expr
      @initializers = inits
    end

    attr_reader :expression
    attr_reader :initializers

    def location
      head_location
    end

    def to_s
      case
      when @expression
        @expression.to_s
      when @initializers
        "{#{@initializers.map { |ini| ini.to_s }.join(",")}}"
      else
        "{}"
      end
    end

    def inspect(indent = 0)
      " " * indent + short_class_name
    end
  end

  class FunctionSignature
    def initialize(name, type)
      @name = name
      @type = type
    end

    attr_reader :name

    def ==(rhs)
      if @type.parameter_types.empty? || rhs.type.parameter_types.empty?
        @name == rhs.name
      else
        @name == rhs.name && @type == rhs.type
      end
    end

    def to_s
      "#{@type.return_type.brief_image} #{@name}(" +
        @type.parameter_types.map { |t| t.brief_image }.join(",") +
        (@type.have_va_list? ? ",...)" : ")")
    end

    protected
    attr_reader :type
  end

  class TypeDeclarationBuilder
    def initialize(sym_tbl)
      @symbol_table = sym_tbl
      @type_declarations = []
    end

    attr_reader :type_declarations

    def visit_standard_type_specifier(node)
    end

    def visit_typedef_type_specifier(node)
    end

    def visit_struct_specifier(node)
      if node.struct_declarations
        node.struct_declarations.each { |child| child.accept(self) }
        sym = @symbol_table.create_new_symbol(StructTag, node.identifier)
        @type_declarations.push(StructTypeDeclaration.new(node, sym))
      end
    end

    def visit_union_specifier(node)
      if node.struct_declarations
        node.struct_declarations.each { |child| child.accept(self) }
        sym = @symbol_table.create_new_symbol(UnionTag, node.identifier)
        @type_declarations.push(UnionTypeDeclaration.new(node, sym))
      end
    end

    def visit_enum_specifier(node)
      if node.enumerators
        sym = @symbol_table.create_new_symbol(EnumTag, node.identifier)
        @type_declarations.push(EnumTypeDeclaration.new(node, sym))
      end
    end

    def visit_typeof_type_specifier(node)
    end

    def visit_struct_declaration(node)
      node.specifier_qualifier_list.accept(self)
    end

    def visit_specifier_qualifier_list(node)
      node.type_specifiers.each { |child| child.accept(self) }
    end
  end

  class SyntaxTreeVisitor
    def visit_error_expression(node)
    end

    def visit_object_specifier(node)
    end

    def visit_constant_specifier(node)
    end

    def visit_string_literal_specifier(node)
    end

    def visit_null_constant_specifier(node)
    end

    def visit_grouped_expression(node)
      node.expression.accept(self)
    end

    def visit_array_subscript_expression(node)
      node.expression.accept(self)
      node.array_subscript.accept(self)
    end

    def visit_function_call_expression(node)
      node.expression.accept(self)
      node.argument_expressions.each { |expr| expr.accept(self) }
    end

    def visit_member_access_by_value_expression(node)
      node.expression.accept(self)
    end

    def visit_member_access_by_pointer_expression(node)
      node.expression.accept(self)
    end

    def visit_bit_access_by_value_expression(node)
      node.expression.accept(self)
    end

    def visit_bit_access_by_pointer_expression(node)
      node.expression.accept(self)
    end

    def visit_postfix_increment_expression(node)
      node.operand.accept(self)
    end

    def visit_postfix_decrement_expression(node)
      node.operand.accept(self)
    end

    def visit_compound_literal_expression(node)
      node.type_name.accept(self) if node.type_name
      node.initializers.each { |init| init.accept(self) }
    end

    def visit_prefix_increment_expression(node)
      node.operand.accept(self)
    end

    def visit_prefix_decrement_expression(node)
      node.operand.accept(self)
    end

    def visit_address_expression(node)
      node.operand.accept(self)
    end

    def visit_indirection_expression(node)
      node.operand.accept(self)
    end

    def visit_unary_arithmetic_expression(node)
      node.operand.accept(self)
    end

    def visit_sizeof_expression(node)
      node.operand.accept(self)
    end

    def visit_sizeof_type_expression(node)
      node.operand.accept(self)
    end

    def visit_alignof_expression(node)
      node.operand.accept(self)
    end

    def visit_alignof_type_expression(node)
      node.operand.accept(self)
    end

    def visit_cast_expression(node)
      node.type_name.accept(self)
      node.operand.accept(self)
    end

    def visit_multiplicative_expression(node)
      node.lhs_operand.accept(self)
      node.rhs_operand.accept(self)
    end

    def visit_additive_expression(node)
      node.lhs_operand.accept(self)
      node.rhs_operand.accept(self)
    end

    def visit_shift_expression(node)
      node.lhs_operand.accept(self)
      node.rhs_operand.accept(self)
    end

    def visit_relational_expression(node)
      node.lhs_operand.accept(self)
      node.rhs_operand.accept(self)
    end

    def visit_equality_expression(node)
      node.lhs_operand.accept(self)
      node.rhs_operand.accept(self)
    end

    def visit_and_expression(node)
      node.lhs_operand.accept(self)
      node.rhs_operand.accept(self)
    end

    def visit_exclusive_or_expression(node)
      node.lhs_operand.accept(self)
      node.rhs_operand.accept(self)
    end

    def visit_inclusive_or_expression(node)
      node.lhs_operand.accept(self)
      node.rhs_operand.accept(self)
    end

    def visit_logical_and_expression(node)
      node.lhs_operand.accept(self)
      node.rhs_operand.accept(self)
    end

    def visit_logical_or_expression(node)
      node.lhs_operand.accept(self)
      node.rhs_operand.accept(self)
    end

    def visit_conditional_expression(node)
      node.condition.accept(self)
      node.then_expression.accept(self)
      node.else_expression.accept(self)
    end

    def visit_simple_assignment_expression(node)
      node.lhs_operand.accept(self)
      node.rhs_operand.accept(self)
    end

    def visit_compound_assignment_expression(node)
      node.lhs_operand.accept(self)
      node.rhs_operand.accept(self)
    end

    def visit_comma_separated_expression(node)
      node.expressions.each { |expr| expr.accept(self) }
    end

    def visit_declaration(node)
      node.declaration_specifiers.accept(self) if node.declaration_specifiers
      node.init_declarators.each { |dcr| dcr.accept(self) }
      node.items.each { |item| item.accept(self) }
    end

    def visit_function_declaration(node)
    end

    def visit_variable_declaration(node)
    end

    def visit_variable_definition(node)
    end

    def visit_typedef_declaration(node)
    end

    def visit_struct_type_declaration(node)
    end

    def visit_union_type_declaration(node)
    end

    def visit_enum_type_declaration(node)
    end

    def visit_declaration_specifiers(node)
      node.type_specifiers.each { |type_spec| type_spec.accept(self) }
    end

    def visit_init_declarator(node)
      node.declarator.accept(self)
      node.initializer.accept(self) if node.initializer
    end

    def visit_standard_type_specifier(node)
    end

    def visit_typedef_type_specifier(node)
    end

    def visit_struct_specifier(node)
      if node.struct_declarations
        node.struct_declarations.each { |dcl| dcl.accept(self) }
      end
    end

    def visit_union_specifier(node)
      if node.struct_declarations
        node.struct_declarations.each { |dcl| dcl.accept(self) }
      end
    end

    def visit_struct_declaration(node)
      node.specifier_qualifier_list.accept(self)
      node.struct_declarators.each { |dcr| dcr.accept(self) }
      node.items.each { |item| item.accept(self) }
    end

    def visit_member_declaration(node)
    end

    def visit_specifier_qualifier_list(node)
      node.type_specifiers.each { |type_spec| type_spec.accept(self) }
    end

    def visit_struct_declarator(node)
      node.declarator.accept(self) if node.declarator
      node.expression.accept(self) if node.expression
    end

    def visit_enum_specifier(node)
      if node.enumerators
        node.enumerators.each { |enum| enum.accept(self) }
      end
    end

    def visit_enumerator(node)
      node.expression.accept(self) if node.expression
    end

    def visit_typeof_type_specifier(node)
      node.expression.accept(self) if node.expression
      node.type_name.accept(self) if node.type_name
    end

    def visit_identifier_declarator(node)
    end

    def visit_grouped_declarator(node)
      node.base.accept(self)
    end

    def visit_array_declarator(node)
      node.base.accept(self)
      node.size_expression.accept(self) if node.size_expression
    end

    def visit_ansi_function_declarator(node)
      node.base.accept(self)
      node.parameter_type_list.accept(self)
    end

    def visit_kandr_function_declarator(node)
      node.base.accept(self)
    end

    def visit_abbreviated_function_declarator(node)
      node.base.accept(self)
    end

    def visit_parameter_type_list(node)
      node.parameters.each { |param| param.accept(self) }
    end

    def visit_parameter_declaration(node)
      node.declaration_specifiers.accept(self)
      node.declarator.accept(self) if node.declarator
    end

    def visit_error_statement(node)
    end

    def visit_generic_labeled_statement(node)
      node.statement.accept(self)
    end

    def visit_case_labeled_statement(node)
      node.expression.accept(self)
      node.statement.accept(self)
    end

    def visit_default_labeled_statement(node)
      node.statement.accept(self)
    end

    def visit_compound_statement(node)
      node.block_items.each { |item| item.accept(self) }
    end

    def visit_expression_statement(node)
      node.expression.accept(self) if node.expression
    end

    def visit_if_statement(node)
      node.expression.accept(self)
      node.statement.accept(self)
    end

    def visit_if_else_statement(node)
      node.expression.accept(self)
      node.then_statement.accept(self)
      node.else_statement.accept(self)
    end

    def visit_switch_statement(node)
      node.expression.accept(self)
      node.statement.accept(self)
    end

    def visit_while_statement(node)
      node.expression.accept(self)
      node.statement.accept(self)
    end

    def visit_do_statement(node)
      node.statement.accept(self)
      node.expression.accept(self)
    end

    def visit_for_statement(node)
      node.initial_statement.accept(self)
      node.condition_statement.accept(self)
      node.expression.accept(self) if node.expression
      node.body_statement.accept(self)
    end

    def visit_c99_for_statement(node)
      node.declaration.accept(self)
      node.condition_statement.accept(self)
      node.expression.accept(self) if node.expression
      node.body_statement.accept(self)
    end

    def visit_goto_statement(node)
    end

    def visit_continue_statement(node)
    end

    def visit_break_statement(node)
    end

    def visit_return_statement(node)
      node.expression.accept(self) if node.expression
    end

    def visit_translation_unit(node)
      node.external_declarations.each { |dcl| dcl.accept(self) }
    end

    def visit_kandr_function_definition(node)
      node.declaration_specifiers.accept(self) if node.declaration_specifiers
      node.declarator.accept(self)
      node.parameter_definitions.each { |param_def| param_def.accept(self) }
      node.function_body.accept(self)
      node.type_declaration.accept(self) if node.type_declaration
    end

    def visit_ansi_function_definition(node)
      node.declaration_specifiers.accept(self) if node.declaration_specifiers
      node.declarator.accept(self)
      node.parameter_definitions.each { |param_def| param_def.accept(self) }
      node.function_body.accept(self)
      node.type_declaration.accept(self) if node.type_declaration
    end

    def visit_parameter_definition(node)
    end

    def visit_type_name(node)
      node.specifier_qualifier_list.accept(self)
      node.abstract_declarator.accept(self) if node.abstract_declarator
      node.type_declaration.accept(self) if node.type_declaration
    end

    def visit_pointer_abstract_declarator(node)
      node.base.accept(self) if node.base
    end

    def visit_grouped_abstract_declarator(node)
      node.base.accept(self)
    end

    def visit_array_abstract_declarator(node)
      node.base.accept(self) if node.base
      node.size_expression.accept(self) if node.size_expression
    end

    def visit_function_abstract_declarator(node)
      node.base.accept(self) if node.base
      node.parameter_type_list.accept(self) if node.parameter_type_list
    end

    def visit_initializer(node)
      case
      when node.expression
        node.expression.accept(self)
      when node.initializers
        node.initializers.each { |init| init.accept(self) }
      end
    end
  end

  class SyntaxTreeMulticastVisitor < SyntaxTreeVisitor
    extend Pluggable

    def_plugin :enter_error_expression
    def_plugin :leave_error_expression
    def_plugin :enter_object_specifier
    def_plugin :leave_object_specifier
    def_plugin :enter_constant_specifier
    def_plugin :leave_constant_specifier
    def_plugin :enter_string_literal_specifier
    def_plugin :leave_string_literal_specifier
    def_plugin :enter_null_constant_specifier
    def_plugin :leave_null_constant_specifier
    def_plugin :enter_grouped_expression
    def_plugin :leave_grouped_expression
    def_plugin :enter_array_subscript_expression
    def_plugin :leave_array_subscript_expression
    def_plugin :enter_function_call_expression
    def_plugin :leave_function_call_expression
    def_plugin :enter_member_access_by_value_expression
    def_plugin :leave_member_access_by_value_expression
    def_plugin :enter_member_access_by_pointer_expression
    def_plugin :leave_member_access_by_pointer_expression
    def_plugin :enter_bit_access_by_value_expression
    def_plugin :leave_bit_access_by_value_expression
    def_plugin :enter_bit_access_by_pointer_expression
    def_plugin :leave_bit_access_by_pointer_expression
    def_plugin :enter_postfix_increment_expression
    def_plugin :leave_postfix_increment_expression
    def_plugin :enter_postfix_decrement_expression
    def_plugin :leave_postfix_decrement_expression
    def_plugin :enter_compound_literal_expression
    def_plugin :leave_compound_literal_expression
    def_plugin :enter_prefix_increment_expression
    def_plugin :leave_prefix_increment_expression
    def_plugin :enter_prefix_decrement_expression
    def_plugin :leave_prefix_decrement_expression
    def_plugin :enter_address_expression
    def_plugin :leave_address_expression
    def_plugin :enter_indirection_expression
    def_plugin :leave_indirection_expression
    def_plugin :enter_unary_arithmetic_expression
    def_plugin :leave_unary_arithmetic_expression
    def_plugin :enter_sizeof_expression
    def_plugin :leave_sizeof_expression
    def_plugin :enter_sizeof_type_expression
    def_plugin :leave_sizeof_type_expression
    def_plugin :enter_alignof_expression
    def_plugin :leave_alignof_expression
    def_plugin :enter_alignof_type_expression
    def_plugin :leave_alignof_type_expression
    def_plugin :enter_cast_expression
    def_plugin :leave_cast_expression
    def_plugin :enter_multiplicative_expression
    def_plugin :leave_multiplicative_expression
    def_plugin :enter_additive_expression
    def_plugin :leave_additive_expression
    def_plugin :enter_shift_expression
    def_plugin :leave_shift_expression
    def_plugin :enter_relational_expression
    def_plugin :leave_relational_expression
    def_plugin :enter_equality_expression
    def_plugin :leave_equality_expression
    def_plugin :enter_and_expression
    def_plugin :leave_and_expression
    def_plugin :enter_exclusive_or_expression
    def_plugin :leave_exclusive_or_expression
    def_plugin :enter_inclusive_or_expression
    def_plugin :leave_inclusive_or_expression
    def_plugin :enter_logical_and_expression
    def_plugin :leave_logical_and_expression
    def_plugin :enter_logical_or_expression
    def_plugin :leave_logical_or_expression
    def_plugin :enter_conditional_expression
    def_plugin :leave_conditional_expression
    def_plugin :enter_simple_assignment_expression
    def_plugin :leave_simple_assignment_expression
    def_plugin :enter_compound_assignment_expression
    def_plugin :leave_compound_assignment_expression
    def_plugin :enter_comma_separated_expression
    def_plugin :leave_comma_separated_expression
    def_plugin :enter_declaration
    def_plugin :leave_declaration
    def_plugin :enter_function_declaration
    def_plugin :leave_function_declaration
    def_plugin :enter_variable_declaration
    def_plugin :leave_variable_declaration
    def_plugin :enter_variable_definition
    def_plugin :leave_variable_definition
    def_plugin :enter_typedef_declaration
    def_plugin :leave_typedef_declaration
    def_plugin :enter_struct_type_declaration
    def_plugin :leave_struct_type_declaration
    def_plugin :enter_union_type_declaration
    def_plugin :leave_union_type_declaration
    def_plugin :enter_enum_type_declaration
    def_plugin :leave_enum_type_declaration
    def_plugin :enter_declaration_specifiers
    def_plugin :leave_declaration_specifiers
    def_plugin :enter_init_declarator
    def_plugin :leave_init_declarator
    def_plugin :enter_standard_type_specifier
    def_plugin :leave_standard_type_specifier
    def_plugin :enter_typedef_type_specifier
    def_plugin :leave_typedef_type_specifier
    def_plugin :enter_struct_specifier
    def_plugin :leave_struct_specifier
    def_plugin :enter_union_specifier
    def_plugin :leave_union_specifier
    def_plugin :enter_struct_declaration
    def_plugin :leave_struct_declaration
    def_plugin :enter_member_declaration
    def_plugin :leave_member_declaration
    def_plugin :enter_specifier_qualifier_list
    def_plugin :leave_specifier_qualifier_list
    def_plugin :enter_struct_declarator
    def_plugin :leave_struct_declarator
    def_plugin :enter_enum_specifier
    def_plugin :leave_enum_specifier
    def_plugin :enter_enumerator
    def_plugin :leave_enumerator
    def_plugin :enter_typeof_type_specifier
    def_plugin :leave_typeof_type_specifier
    def_plugin :enter_identifier_declarator
    def_plugin :leave_identifier_declarator
    def_plugin :enter_grouped_declarator
    def_plugin :leave_grouped_declarator
    def_plugin :enter_array_declarator
    def_plugin :leave_array_declarator
    def_plugin :enter_ansi_function_declarator
    def_plugin :leave_ansi_function_declarator
    def_plugin :enter_kandr_function_declarator
    def_plugin :leave_kandr_function_declarator
    def_plugin :enter_abbreviated_function_declarator
    def_plugin :leave_abbreviated_function_declarator
    def_plugin :enter_parameter_type_list
    def_plugin :leave_parameter_type_list
    def_plugin :enter_parameter_declaration
    def_plugin :leave_parameter_declaration
    def_plugin :enter_error_statement
    def_plugin :leave_error_statement
    def_plugin :enter_generic_labeled_statement
    def_plugin :leave_generic_labeled_statement
    def_plugin :enter_case_labeled_statement
    def_plugin :leave_case_labeled_statement
    def_plugin :enter_default_labeled_statement
    def_plugin :leave_default_labeled_statement
    def_plugin :enter_compound_statement
    def_plugin :leave_compound_statement
    def_plugin :enter_expression_statement
    def_plugin :leave_expression_statement
    def_plugin :enter_if_statement
    def_plugin :leave_if_statement
    def_plugin :enter_if_else_statement
    def_plugin :leave_if_else_statement
    def_plugin :enter_switch_statement
    def_plugin :leave_switch_statement
    def_plugin :enter_while_statement
    def_plugin :leave_while_statement
    def_plugin :enter_do_statement
    def_plugin :leave_do_statement
    def_plugin :enter_for_statement
    def_plugin :leave_for_statement
    def_plugin :enter_c99_for_statement
    def_plugin :leave_c99_for_statement
    def_plugin :enter_goto_statement
    def_plugin :leave_goto_statement
    def_plugin :enter_continue_statement
    def_plugin :leave_continue_statement
    def_plugin :enter_break_statement
    def_plugin :leave_break_statement
    def_plugin :enter_return_statement
    def_plugin :leave_return_statement
    def_plugin :enter_translation_unit
    def_plugin :leave_translation_unit
    def_plugin :enter_kandr_function_definition
    def_plugin :leave_kandr_function_definition
    def_plugin :enter_ansi_function_definition
    def_plugin :leave_ansi_function_definition
    def_plugin :enter_parameter_definition
    def_plugin :leave_parameter_definition
    def_plugin :enter_type_name
    def_plugin :leave_type_name
    def_plugin :enter_pointer_abstract_declarator
    def_plugin :leave_pointer_abstract_declarator
    def_plugin :enter_grouped_abstract_declarator
    def_plugin :leave_grouped_abstract_declarator
    def_plugin :enter_array_abstract_declarator
    def_plugin :leave_array_abstract_declarator
    def_plugin :enter_function_abstract_declarator
    def_plugin :leave_function_abstract_declarator
    def_plugin :enter_initializer
    def_plugin :leave_initializer

    def self.def_visitor_method(node_name)
      class_eval <<-EOS
        define_method("visit_#{node_name}") do |*args|
          visit_with_notifying(__method__, args.first) { super(args.first) }
        end
      EOS
    end
    private_class_method :def_visitor_method

    def_visitor_method :error_expression
    def_visitor_method :object_specifier
    def_visitor_method :constant_specifier
    def_visitor_method :string_literal_specifier
    def_visitor_method :null_constant_specifier
    def_visitor_method :grouped_expression
    def_visitor_method :array_subscript_expression
    def_visitor_method :function_call_expression
    def_visitor_method :member_access_by_value_expression
    def_visitor_method :member_access_by_pointer_expression
    def_visitor_method :bit_access_by_value_expression
    def_visitor_method :bit_access_by_pointer_expression
    def_visitor_method :postfix_increment_expression
    def_visitor_method :postfix_decrement_expression
    def_visitor_method :compound_literal_expression
    def_visitor_method :prefix_increment_expression
    def_visitor_method :prefix_decrement_expression
    def_visitor_method :address_expression
    def_visitor_method :indirection_expression
    def_visitor_method :unary_arithmetic_expression
    def_visitor_method :sizeof_expression
    def_visitor_method :sizeof_type_expression
    def_visitor_method :alignof_expression
    def_visitor_method :alignof_type_expression
    def_visitor_method :cast_expression
    def_visitor_method :multiplicative_expression
    def_visitor_method :additive_expression
    def_visitor_method :shift_expression
    def_visitor_method :relational_expression
    def_visitor_method :equality_expression
    def_visitor_method :and_expression
    def_visitor_method :exclusive_or_expression
    def_visitor_method :inclusive_or_expression
    def_visitor_method :logical_and_expression
    def_visitor_method :logical_or_expression
    def_visitor_method :conditional_expression
    def_visitor_method :simple_assignment_expression
    def_visitor_method :compound_assignment_expression
    def_visitor_method :comma_separated_expression
    def_visitor_method :declaration
    def_visitor_method :function_declaration
    def_visitor_method :variable_declaration
    def_visitor_method :variable_definition
    def_visitor_method :typedef_declaration
    def_visitor_method :struct_type_declaration
    def_visitor_method :union_type_declaration
    def_visitor_method :enum_type_declaration
    def_visitor_method :declaration_specifiers
    def_visitor_method :init_declarator
    def_visitor_method :standard_type_specifier
    def_visitor_method :typedef_type_specifier
    def_visitor_method :struct_specifier
    def_visitor_method :union_specifier
    def_visitor_method :struct_declaration
    def_visitor_method :member_declaration
    def_visitor_method :specifier_qualifier_list
    def_visitor_method :struct_declarator
    def_visitor_method :enum_specifier
    def_visitor_method :enumerator
    def_visitor_method :typeof_type_specifier
    def_visitor_method :identifier_declarator
    def_visitor_method :grouped_declarator
    def_visitor_method :array_declarator
    def_visitor_method :ansi_function_declarator
    def_visitor_method :kandr_function_declarator
    def_visitor_method :abbreviated_function_declarator
    def_visitor_method :parameter_type_list
    def_visitor_method :parameter_declaration
    def_visitor_method :error_statement
    def_visitor_method :generic_labeled_statement
    def_visitor_method :case_labeled_statement
    def_visitor_method :default_labeled_statement
    def_visitor_method :compound_statement
    def_visitor_method :expression_statement
    def_visitor_method :if_statement
    def_visitor_method :if_else_statement
    def_visitor_method :switch_statement
    def_visitor_method :while_statement
    def_visitor_method :do_statement
    def_visitor_method :for_statement
    def_visitor_method :c99_for_statement
    def_visitor_method :goto_statement
    def_visitor_method :continue_statement
    def_visitor_method :break_statement
    def_visitor_method :return_statement
    def_visitor_method :translation_unit
    def_visitor_method :kandr_function_definition
    def_visitor_method :ansi_function_definition
    def_visitor_method :parameter_definition
    def_visitor_method :type_name
    def_visitor_method :pointer_abstract_declarator
    def_visitor_method :grouped_abstract_declarator
    def_visitor_method :array_abstract_declarator
    def_visitor_method :function_abstract_declarator
    def_visitor_method :initializer

    private
    def visit_with_notifying(caller_method, node, &block)
      suffix = caller_method.to_s.sub(/\Avisit_/, "")
      __send__("enter_#{suffix}").invoke(node)
      yield
      __send__("leave_#{suffix}").invoke(node)
    end
  end

  class ObjectSpecifierCollector < SyntaxTreeVisitor
    def initialize
      @object_specifiers = []
    end

    attr_reader :object_specifiers

    def visit_object_specifier(node)
      super
      @object_specifiers.push(node)
    end
  end

  class IdentifierDeclaratorCollector < SyntaxTreeVisitor
    def initialize
      @identifier_declarators = []
    end

    attr_reader :identifier_declarators

    def visit_identifier_declarator(node)
      super
      @identifier_declarators.push(node)
    end
  end

  class TypedefTypeSpecifierCollector < SyntaxTreeVisitor
    def initialize
      @typedef_type_specifiers = []
    end

    attr_reader :typedef_type_specifiers

    def visit_variable_definition(node)
    end

    def visit_typedef_type_specifier(node)
      super
      @typedef_type_specifiers.push(node)
    end
  end

  class FunctionDeclaratorCollector < SyntaxTreeVisitor
    def initialize
      @function_declarators = []
    end

    attr_reader :function_declarators

    def visit_ansi_function_declarator(node)
      @function_declarators.push(node)
      super
    end

    def visit_kandr_function_declarator(node)
      @function_declarators.push(node)
      super
    end
  end

  class SimpleAssignmentExpressionCollector < SyntaxTreeVisitor
    def initialize
      @simple_assignment_expressions = []
    end

    attr_reader :simple_assignment_expressions

    def visit_simple_assignment_expression(node)
      super
      @simple_assignment_expressions.push(node)
    end
  end

  class CompoundAssignmentExpressionCollector < SyntaxTreeVisitor
    def initialize
      @compound_assignment_expressions = []
    end

    attr_reader :compound_assignment_expressions

    def visit_compound_assignment_expression(node)
      super
      @compound_assignment_expressions.push(node)
    end
  end

  class PrefixIncrementExpressionCollector < SyntaxTreeVisitor
    def initialize
      @prefix_increment_expressions = []
    end

    attr_reader :prefix_increment_expressions

    def visit_prefix_increment_expression(node)
      super
      @prefix_increment_expressions.push(node)
    end
  end

  class PrefixDecrementExpressionCollector < SyntaxTreeVisitor
    def initialize
      @prefix_decrement_expressions = []
    end

    attr_reader :prefix_decrement_expressions

    def visit_prefix_decrement_expression(node)
      super
      @prefix_decrement_expressions.push(node)
    end
  end

  class PostfixIncrementExpressionCollector < SyntaxTreeVisitor
    def initialize
      @postfix_increment_expressions = []
    end

    attr_reader :postfix_increment_expressions

    def visit_postfix_increment_expression(node)
      super
      @postfix_increment_expressions.push(node)
    end
  end

  class PostfixDecrementExpressionCollector < SyntaxTreeVisitor
    def initialize
      @postfix_decrement_expressions = []
    end

    attr_reader :postfix_decrement_expressions

    def visit_postfix_decrement_expression(node)
      super
      @postfix_decrement_expressions.push(node)
    end
  end

  class AdditiveExpressionCollector < SyntaxTreeVisitor
    def initialize
      @additive_expressions = []
    end

    attr_reader :additive_expressions

    def visit_additive_expression(node)
      super
      @additive_expressions.push(node)
    end
  end

  class RelationalExpressionCollector < SyntaxTreeVisitor
    def initialize
      @relational_expressions = []
    end

    attr_reader :relational_expressions

    def visit_relational_expression(node)
      super
      @relational_expressions.push(node)
    end
  end

  class EqualityExpressionCollector < SyntaxTreeVisitor
    def initialize
      @equality_expressions = []
    end

    attr_reader :equality_expressions

    def visit_equality_expression(node)
      super
      @equality_expressions.push(node)
    end
  end

  class LogicalAndExpressionCollector < SyntaxTreeVisitor
    def initialize
      @logical_and_expressions = []
    end

    attr_reader :logical_and_expressions

    def visit_logical_and_expression(node)
      super
      @logical_and_expressions.push(node)
    end
  end

  class LogicalOrExpressionCollector < SyntaxTreeVisitor
    def initialize
      @logical_or_expressions = []
    end

    attr_reader :logical_or_expressions

    def visit_logical_or_expression(node)
      super
      @logical_or_expressions.push(node)
    end
  end

  class GenericLabeledStatementCollector < SyntaxTreeVisitor
    def initialize
      @generic_labeled_statements = []
    end

    attr_reader :generic_labeled_statements

    def visit_generic_labeled_statement(node)
      super
      @generic_labeled_statements.push(node)
    end
  end

  class IfStatementCollector < SyntaxTreeVisitor
    def initialize
      @if_statements = []
    end

    attr_reader :if_statements

    def visit_if_statement(node)
      super
      @if_statements.push(node)
    end
  end

  class IfElseStatementCollector < SyntaxTreeVisitor
    def initialize
      @if_else_statements = []
    end

    attr_reader :if_else_statements

    def visit_if_else_statement(node)
      super
      @if_else_statements.push(node)
    end
  end

  class GotoStatementCollector < SyntaxTreeVisitor
    def initialize
      @goto_statements = []
    end

    attr_reader :goto_statements

    def visit_goto_statement(node)
      @goto_statements.push(node)
    end
  end

  class ArrayDeclaratorCollector < SyntaxTreeVisitor
    def initialize
      @array_declarators = []
    end

    attr_reader :array_declarators

    def visit_array_declarator(node)
      @array_declarators.push(node)
      super
    end
  end

  class ConstantSpecifierCollector < SyntaxTreeVisitor
    def initialize
      @constant_specifiers = []
    end

    attr_reader :constant_specifiers

    def visit_constant_specifier(node)
      @constant_specifiers.push(node)
    end
  end

  class ExpressionExtractor < SyntaxTreeVisitor
    def initialize
      @expressions = []
    end

    attr_reader :expressions

    def push_expression(expr)
      @expressions.push(expr)
    end
    private :push_expression

    alias :visit_error_expression :push_expression
    alias :visit_object_specifier :push_expression
    alias :visit_constant_specifier :push_expression
    alias :visit_string_literal_specifier :push_expression
    alias :visit_null_constant_specifier :push_expression
    alias :visit_grouped_expression :push_expression
    alias :visit_array_subscript_expression :push_expression
    alias :visit_function_call_expression :push_expression
    alias :visit_member_access_by_value_expression :push_expression
    alias :visit_member_access_by_pointer_expression :push_expression
    alias :visit_bit_access_by_value_expression :push_expression
    alias :visit_bit_access_by_pointer_expression :push_expression
    alias :visit_postfix_increment_expression :push_expression
    alias :visit_postfix_decrement_expression :push_expression
    alias :visit_compound_literal_expression :push_expression
    alias :visit_prefix_increment_expression :push_expression
    alias :visit_prefix_decrement_expression :push_expression
    alias :visit_address_expression :push_expression
    alias :visit_indirection_expression :push_expression
    alias :visit_unary_arithmetic_expression :push_expression
    alias :visit_sizeof_expression :push_expression
    alias :visit_sizeof_type_expression :push_expression
    alias :visit_alignof_expression :push_expression
    alias :visit_alignof_type_expression :push_expression
    alias :visit_cast_expression :push_expression
    alias :visit_multiplicative_expression :push_expression
    alias :visit_additive_expression :push_expression
    alias :visit_shift_expression :push_expression
    alias :visit_relational_expression :push_expression
    alias :visit_equality_expression :push_expression
    alias :visit_and_expression :push_expression
    alias :visit_exclusive_or_expression :push_expression
    alias :visit_inclusive_or_expression :push_expression
    alias :visit_logical_and_expression :push_expression
    alias :visit_logical_or_expression :push_expression
    alias :visit_conditional_expression :push_expression
    alias :visit_simple_assignment_expression :push_expression
    alias :visit_compound_assignment_expression :push_expression
  end

  class ConditionalExpressionExtractor < SyntaxTreeVisitor
    def initialize
      @expressions = []
    end

    attr_reader :expressions

    def visit_conditional_expression(node)
      @expressions.push(node)
    end
  end

  class ExpressionConstancy < SyntaxTreeVisitor
    def initialize(interp_bridge)
      @interp_bridge = interp_bridge
    end

    def check(expr)
      catch(:constancy) { expr.accept(self); true }
    end

    def visit_object_specifier(node)
      var_designators = @interp_bridge[:variable_designators][]
      if var_designators.include?(node.identifier.value)
        break_as_inconstant
      end
    end

    def visit_address_expression(node)
      # NOTE: To treat address of variables as an address-constant.
    end

    def break_as_inconstant(*)
      throw(:constancy, false)
    end
    private :break_as_inconstant

    alias :visit_function_call_expression :break_as_inconstant
    alias :visit_postfix_increment_expression :break_as_inconstant
    alias :visit_postfix_decrement_expression :break_as_inconstant
    alias :visit_prefix_increment_expression :break_as_inconstant
    alias :visit_prefix_decrement_expression :break_as_inconstant
    alias :visit_simple_assignment_expression :break_as_inconstant
    alias :visit_compound_assignment_expression :break_as_inconstant
  end

end
end
