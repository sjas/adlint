# AST of C preprocessor language.
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

require "adlint/symbol"
require "adlint/location"
require "adlint/exam"
require "adlint/util"

module AdLint #:nodoc:
module Cpp #:nodoc:

  class SyntaxNode
    include Visitable
    include LocationHolder

    def location
      subclass_responsibility
    end

    def inspect(indent = 0)
      subclass_responsibility
    end

    def short_class_name
      self.class.name.sub(/\A.*::/, "")
    end
  end

  class IdentifierList < SyntaxNode
    def initialize(ids = [])
      @identifiers = ids
    end

    attr_reader :identifiers

    def push(id)
      @identifiers.push(id)
      self
    end

    def location
      @identifiers.first.location
    end

    def inspect(indent = 0)
      ([" " * indent + short_class_name] +
       @identifiers.map { |child| child.inspect }).join("\n")
    end
  end

  class PreprocessingFile < SyntaxNode
    def initialize(fpath, group = nil)
      @fpath = fpath
      @group = group
    end

    attr_reader :fpath
    attr_reader :group

    def location
      @group.location
    end

    def concat(pp_file)
      @group.group_parts.concat(pp_file.group.group_parts)
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name}\n" +
        (@group ? @group.inspect(indent + 1) : "")
    end
  end

  class Group < SyntaxNode
    def initialize
      super
      @group_parts = []
    end

    attr_reader :group_parts

    def push(group_part)
      @group_parts.push(group_part)
      self
    end

    def location
      @group_parts.first.location
    end

    def inspect(indent = 0)
      ([" " * indent + short_class_name] +
       @group_parts.map { |child| child.inspect(indent + 1) }).join("\n")
    end
  end

  class GroupPart < SyntaxNode; end

  class IfSection < GroupPart
    def initialize(if_group, elif_groups, else_group, endif_line)
      @if_group    = if_group
      @elif_groups = elif_groups
      @else_group  = else_group
      @endif_line  = endif_line
    end

    attr_reader :if_group
    attr_reader :elif_groups
    attr_reader :else_group
    attr_reader :endif_line

    def location
      @if_group.location
    end

    def inspect(indent = 0)
      [" " * indent + short_class_name,
        @if_group ? @if_group.inspect(indent + 1) : nil,
        @elif_groups ? @elif_groups.inspect(indent + 1) : nil,
        @else_group ? @else_group.inspect(indent + 1) : nil,
        @endif_line ? @endif_line.inspect(indent + 1) : nil
      ].compact.join("\n")
    end
  end

  class IfGroup < SyntaxNode
    def initialize(keyword)
      @keyword = keyword
    end

    attr_reader :keyword

    def location
      @keyword.location
    end
  end

  class IfStatement < IfGroup
    def initialize(keyword, expr, group)
      super(keyword)
      @expression = expr
      @group = group
    end

    attr_accessor :expression
    attr_reader :group

    def inspect(indent = 0)
      [" " * indent + "#{short_class_name}",
        @expression.inspect(indent + 1),
        @group ? @group.inspect(indent + 1) : nil].compact.join("\n")
    end
  end

  class IfdefStatement < IfGroup
    def initialize(keyword, id, group)
      super(keyword)
      @identifier = id
      @group = group
    end

    attr_reader :identifier
    attr_reader :group

    def inspect(indent = 0)
      [" " * indent + "#{short_class_name} #{@identifier.inspect}",
        @group ? @group.inspect(indent + 1) : nil].join("\n")
    end
  end

  class IfndefStatement < IfGroup
    def initialize(keyword, id, group)
      super(keyword)
      @identifier = id
      @group = group
    end

    attr_reader :identifier
    attr_reader :group

    def inspect(indent = 0)
      [" " * indent + "#{short_class_name} #{@identifier.inspect}",
        @group ? @group.inspect(indent + 1) : nil].join("\n")
    end
  end

  class ElifGroups < SyntaxNode
    def initialize
      super
      @elif_statements = []
    end

    attr_reader :elif_statements

    def push(elif_stmt)
      @elif_statements.push(elif_stmt)
      self
    end

    def inspect(indent = 0)
      ([" " * indent + short_class_name] +
       @elif_statements.map { |child| child.inspect(indent + 1) }).join("\n")
    end
  end

  class ElifGroup < SyntaxNode
    def initialize(keyword)
      @keyword = keyword
    end

    attr_reader :keyword

    def location
      @keyword.location
    end
  end

  class ElifStatement < ElifGroup
    def initialize(keyword, expr, group)
      super(keyword)
      @expression = expr
      @group = group
    end

    attr_accessor :expression
    attr_reader :group

    def inspect(indent = 0)
      [" " * indent + "#{short_class_name} #{@expression.inspect}",
        @group ? @group.inspect(indent + 1) : nil].compact.join("\n")
    end
  end

  class ElseGroup < SyntaxNode
    def initialize(keyword)
      @keyword = keyword
    end

    attr_reader :keyword

    def location
      @keyword.location
    end
  end

  class ElseStatement < ElseGroup
    def initialize(keyword, group)
      super(keyword)
      @group = group
    end

    attr_reader :group

    def inspect(indent = 0)
      [" " * indent + short_class_name,
        @group ? @group.inspect(indent + 1) : nil].compact.join("\n")
    end
  end

  class EndifLine < SyntaxNode
    def initialize(keyword)
      @keyword = keyword
    end

    attr_reader :keyword

    def location
      @keyword.location
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name} (#{@keyword.inspect})"
    end
  end

  class ControlLine < GroupPart
    def initialize(keyword)
      @keyword = keyword
    end

    attr_reader :keyword

    def location
      @keyword.location
    end
  end

  class IncludeLine < ControlLine
    def initialize(keyword, header_name, include_depth)
      super(keyword)
      @header_name   = header_name
      @include_depth = include_depth
    end

    attr_reader :include_depth
    attr_reader :header_name
    attr_accessor :fpath
  end

  class UserIncludeLine < IncludeLine
    def initialize(keyword, usr_header_name, include_depth)
      super(keyword, usr_header_name, include_depth)
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name} (#{header_name.inspect})"
    end
  end

  class UserIncludeNextLine < UserIncludeLine; end

  class SystemIncludeLine < IncludeLine
    def initialize(keyword, sys_header_name, include_depth)
      super(keyword, sys_header_name, include_depth)
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name} (#{header_name.inspect})"
    end
  end

  class SystemIncludeNextLine < SystemIncludeLine; end

  class DefineLine < ControlLine
    include SymbolicElement

    def initialize(keyword, id, repl_list, sym)
      super(keyword)
      @identifier = id
      @replacement_list = repl_list
      @symbol = sym
    end

    attr_reader :identifier
    attr_reader :replacement_list
    attr_reader :symbol
  end

  class ObjectLikeDefineLine < DefineLine
    def inspect(indent = 0)
      " " * indent + "#{short_class_name} (#{identifier.inspect})"
    end
  end

  class PseudoObjectLikeDefineLine < DefineLine
    def initialize(name_str)
      super(Token.new(:DEFINE, "#define", Location.new),
            Token.new(:PP_TOKEN, name_str, Location.new), nil, nil)
    end

    def mark_as_referred_by(tok) end
  end

  class FunctionLikeDefineLine < DefineLine
    def initialize(keyword, id, id_list, repl_list, sym)
      super(keyword, id, repl_list, sym)
      @identifier_list = id_list
    end

    attr_reader :identifier_list

    def have_va_list?
      false
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name} (#{identifier.inspect})"
    end
  end

  class PseudoFunctionLikeDefineLine < FunctionLikeDefineLine
    def initialize(name_str, param_names)
      id_list = IdentifierList.new(
        param_names.map { |str| Token.new(:PP_TOKEN, str, Location.new) })

      super(Token.new(:DEFINE, "#define", Location.new),
            Token.new(:PP_TOKEN, name_str, Location.new), id_list, nil, nil)
    end

    def mark_as_referred_by(tok) end
  end

  class VaFunctionLikeDefineLine < FunctionLikeDefineLine
    def have_va_list?
      true
    end
  end

  class UndefLine < ControlLine
    def initialize(keyword, id)
      super(keyword)
      @identifier = id
    end

    attr_reader :identifier

    def inspect(indent = 0)
      " " * indent + "#{short_class_name} (#{@identifier.inspect})"
    end
  end

  class LineLine < ControlLine
    def initialize(keyword, pp_toks)
      super(keyword)
      @pp_tokens = pp_toks
    end

    attr_reader :pp_tokens

    def inspect(indent = 0)
      " " * indent + "#{short_class_name} (#{@pp_tokens.inspect})"
    end
  end

  class ErrorLine < ControlLine
    def initialize(keyword, pp_toks)
      super(keyword)
      @pp_tokens = pp_toks
    end

    attr_reader :pp_tokens

    def inspect(indent = 0)
      " " * indent +
        "#{short_class_name} (#{@pp_tokens ? @pp_tokens.inspect : ""})"
    end
  end

  class PragmaLine < ControlLine
    def initialize(keyword, pp_toks)
      super(keyword)
      @pp_tokens = pp_toks
    end

    attr_reader :pp_tokens

    def inspect(indent = 0)
      " " * indent +
        "#{short_class_name} (#{@pp_tokens ? @pp_tokens.inspect : ""})"
    end
  end

  class TextLine < GroupPart
    def initialize(tok)
      @token = tok
    end

    attr_reader :token

    def location
      @token.location
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name} (#{@token.inspect})"
    end
  end

  class NullDirective < GroupPart
    def initialize(tok)
      @token = tok
    end

    attr_reader :token

    def location
      @token.location
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name} (#{@token.inspect})"
    end
  end

  class UnknownDirective < GroupPart
    def initialize(tok)
      @token = tok
    end

    attr_reader :token

    def location
      @token.location
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name} (#{@token.inspect})"
    end
  end

  class AsmSection < GroupPart
    def initialize(asm_line, endasm_line)
      @asm_line = asm_line
      @endasm_line = endasm_line
    end

    attr_reader :asm_line
    attr_reader :endasm_line

    def location
      @asm_line.location
    end

    def inspect(indent = 0)
      [" " * indent + short_class_name,
        @asm_line.inspect(indent + 1),
        @endasm_line.inspect(indent + 1)].join("\n")
    end
  end

  class AsmLine < SyntaxNode
    def initialize(keyword)
      @keyword = keyword
    end

    attr_reader :keyword

    def location
      @keyword.location
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name} (#{@keyword.inspect})"
    end
  end

  class EndasmLine < SyntaxNode
    def initialize(keyword)
      @keyword = keyword
    end

    attr_reader :keyword

    def location
      @keyword.location
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name} (#{@keyword.inspect})"
    end
  end

  class PPTokens < SyntaxNode
    def initialize
      super
      @tokens = []
    end

    attr_reader :tokens

    def push(tok)
      @tokens.push(tok)
      self
    end

    def location
      @tokens.first.location
    end

    def may_represent_expression?
      return false if @tokens.size < 2

      @tokens.all? do |pp_tok|
        case pp_tok.value
        when "{", "}"
          false
        when ";"
          false
        when "while", "do", "for", "if", "else", "switch", "case", "default",
             "goto", "return", "break", "continue"
          false
        when "typedef", "extern", "static", "auto", "regisiter"
          false
        else
          true
        end
      end
    end

    def may_represent_initializer?
      return false if @tokens.size < 2

      if @tokens.first.value == "{" && @tokens.last.value == "}"
        @tokens.all? do |pp_tok|
          case pp_tok.value
          when "while", "do", "for", "if", "else", "switch", "case", "default",
               "goto", "return", "break", "continue"
            false
          when ";"
            false
          else
            true
          end
        end
      else
        false
      end
    end

    def may_represent_block?
      return false if @tokens.size < 2

      if @tokens.first.value == "{" && @tokens.last.value == "}"
        @tokens.any? { |pp_tok| pp_tok.value == ";" }
      else
        false
      end
    end

    def may_represent_do_while_zero_idiom?
      return false if @tokens.size < 4

      @tokens[0].value == "do" && @tokens[-4].value == "while" &&
        @tokens[-3].value == "(" && @tokens[-2].value == "0" &&
        @tokens[-1].value == ")"
    end

    def may_represent_specifier_qualifier_list?
      @tokens.select { |pp_tok|
        case pp_tok.value
        when "const", "volatile", "restrict"
          true
        when "*"
          true
        when "void", "signed", "unsigned", "char", "short", "int", "long",
             "float", "double"
          true
        else
          false
        end
      }.size > 1
    end

    def may_represent_declaration_specifiers_head?
      @tokens.all? do |pp_tok|
        case pp_tok.value
        when "typedef", "extern", "static", "auto", "register"
          true
        when "const", "volatile", "restrict"
          true
        else
          false
        end
      end
    end

    PUNCTUATORS = [
      "[", "]", "(", ")", "{", "}", ".", "->", "++", "--", "&", "*", "+", "-",
      "~", "!", "/", "%", "<<", ">>", "<", ">", "<=", ">=", "==", "!=", "^",
      "|", "&&", "||", "?", ":", ";", "...", "=", "*=", "/=", "%=", "+=", "-=",
      "<<=", ">>=", "&=", "^=", "|=", ",", "#", "##", "<:", ":>", "<%", "%>",
      "%:", "%:%:"
    ].to_set.freeze
    private_constant :PUNCTUATORS

    def may_represent_punctuator?
      @tokens.size == 1 && PUNCTUATORS.include?(@tokens.first.value)
    end

    def may_represent_controlling_keyword?
      return false if @tokens.size > 1

      case @tokens.first.value
      when "while", "do", "for", "if", "else", "switch", "case", "default",
        "goto", "return", "break", "continue"
        true
      else
        false
      end
    end

    def to_s
      @tokens.map { |tok| tok.value }.join(" ")
    end

    def inspect(indent = 0)
      " " * indent + self.to_s
    end
  end

  class Expression < SyntaxNode
    def initialize(val)
      @value = val
    end

    attr_reader :value

    def to_s
      subclass_responsibility
    end
  end

  class ErrorExpression < Expression
    def initialize(err_tok)
      super(0)
      @error_token = err_tok
    end

    attr_reader :error_token

    def location
      @error_token.location
    end

    def to_s
      ""
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name} (#{@error_token.inspect})"
    end
  end

  class PrimaryExpression < Expression; end

  class ConstantSpecifier < PrimaryExpression
    def initialize(val, const)
      super(val)
      @constant = const
    end

    attr_reader :constant

    def location
      @constant.location
    end

    def to_s
      @constant.value
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name} (#{constant.inspect})"
    end
  end

  class GroupedExpression < PrimaryExpression
    def initialize(val, expr)
      super(val)
      @expression = expr
    end

    attr_reader :expression

    def location
      @expression.location
    end

    def to_s
      "(#{@expression.to_s})"
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name}\n" +
        @expression.inspect(indent + 1)
    end
  end

  class UnaryExpression < Expression
    def initialize(val, op)
      super(val)
      @operator = op
    end

    attr_reader :operator

    def location
      @operator.location
    end
  end

  class UnaryArithmeticExpression < UnaryExpression
    def initialize(val, op, expr)
      super(val, op)
      @expression = expr
    end

    attr_reader :expression

    def to_s
      "#{operator.value} #{@expression.to_s}"
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name} (#{operator.inspect})\n" +
        @expression.inspect(indent + 1)
    end
  end

  class DefinedExpression < UnaryExpression
    def initialize(val, op, id)
      super(val, op)
      @identifier = id
    end

    attr_reader :identifier

    def to_s
      "#{operator.value}(#{@identifier.value})"
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name} " +
        "(#{operator.inspect} #{@identifier.inspect}"
    end
  end

  class BinaryExpression < Expression
    def initialize(val, op, lhs_expr, rhs_expr)
      super(val)
      @operator = op
      @lhs_expression = lhs_expr
      @rhs_expression = rhs_expr
    end

    attr_reader :operator
    attr_reader :lhs_expression
    attr_reader :rhs_expression

    def location
      @lhs_expression.location
    end

    def to_s
      "#{@lhs_expression.to_s} #{@operator.value} #{@rhs_expression.to_s}"
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name} (#{@operator.inspect})\n" +
        @lhs_expression.inspect(indent + 1) + "\n" +
          @rhs_expression.inspect(indent + 1)
    end
  end

  class MultiplicativeExpression < BinaryExpression; end

  class AdditiveExpression < BinaryExpression; end

  class ShiftExpression < BinaryExpression; end

  class RelationalExpression < BinaryExpression; end

  class EqualityExpression < BinaryExpression; end

  class AndExpression < BinaryExpression; end

  class ExclusiveOrExpression < BinaryExpression; end

  class InclusiveOrExpression < BinaryExpression; end

  class LogicalAndExpression < BinaryExpression; end

  class LogicalOrExpression < BinaryExpression; end

  class ConditionalExpression < Expression
    def initialize(val, cond, fst_expr, snd_expr)
      super(val)
      @condition = cond
      @first_expression  = fst_expr
      @second_expression = snd_expr
    end

    attr_reader :condition
    attr_reader :first_expression
    attr_reader :second_expression

    def location
      @condition.location
    end

    def to_s
      "#{@condition.to_s}? " +
        "#{@first_expression.to_s} : #{@second_expression.to_s}"
    end

    def inspect(indent = 0)
      " " * indent + "#{short_class_name} (#{@condition.inspect})\n" +
        @first_expression.inspect(indent + 1) + "\n" +
          @second_expression.inspect(indent + 1)
    end
  end

  class CommaSeparatedExpression < Expression
    def initialize(val)
      super(val)
      @expressions = []
    end

    attr_writer :expressions

    def location
      @expressions.first.location
    end

    def to_s
      @expressions.map { |expr| expr.to_s }.join(",")
    end

    def push(expression)
      @expressions.push(expression)
      self
    end

    def inspect(indent = 0)
      ([" " * indent + short_class_name] +
       @expressions.map { |expr| expr.inspect(indent + 1) }).join("\n")
    end
  end

  class SyntaxTreeVisitor
    def visit_identifier_list(node)
    end

    def visit_preprocessing_file(node)
      node.group.accept(self) if node.group
    end

    def visit_group(node)
      node.group_parts.each { |group_part| group_part.accept(self) }
    end

    def visit_if_section(node)
      node.if_group.accept(self) if node.if_group
      node.elif_groups.accept(self) if node.elif_groups
      node.else_group.accept(self) if node.else_group
      node.endif_line.accept(self) if node.endif_line
    end

    def visit_if_statement(node)
      node.expression.accept(self)
      node.group.accept(self) if node.group
    end

    def visit_ifdef_statement(node)
      node.group.accept(self) if node.group
    end

    def visit_ifndef_statement(node)
      node.group.accept(self) if node.group
    end

    def visit_elif_groups(node)
      node.elif_statements.each { |elif_stmt| elif_stmt.accept(self) }
    end

    def visit_elif_statement(node)
      node.expression.accept(self)
      node.group.accept(self) if node.group
    end

    def visit_else_statement(node)
      node.group.accept(self) if node.group
    end

    def visit_endif_line(node)
    end

    def visit_user_include_line(node)
    end

    def visit_system_include_line(node)
    end

    def visit_user_include_next_line(node)
    end

    def visit_system_include_next_line(node)
    end

    def visit_object_like_define_line(node)
    end

    def visit_function_like_define_line(node)
    end

    def visit_va_function_like_define_line(node)
    end

    def visit_undef_line(node)
    end

    def visit_line_line(node)
    end

    def visit_error_line(node)
    end

    def visit_pragma_line(node)
    end

    def visit_text_line(node)
    end

    def visit_null_directive(node)
    end

    def visit_unknown_directive(node)
    end

    def visit_asm_section(node)
    end

    def visit_pp_tokens(node)
    end

    def visit_error_expression(node)
    end

    def visit_constant_specifier(node)
    end

    def visit_grouped_expression(node)
      node.expression.accept(self)
    end

    def visit_unary_arithmetic_expression(node)
      node.expression.accept(self)
    end

    def visit_defined_expression(node)
    end

    def visit_multiplicative_expression(node)
      node.lhs_expression.accept(self)
      node.rhs_expression.accept(self)
    end

    def visit_additive_expression(node)
      node.lhs_expression.accept(self)
      node.rhs_expression.accept(self)
    end

    def visit_shift_expression(node)
      node.lhs_expression.accept(self)
      node.rhs_expression.accept(self)
    end

    def visit_relational_expression(node)
      node.lhs_expression.accept(self)
      node.rhs_expression.accept(self)
    end

    def visit_equality_expression(node)
      node.lhs_expression.accept(self)
      node.rhs_expression.accept(self)
    end

    def visit_and_expression(node)
      node.lhs_expression.accept(self)
      node.rhs_expression.accept(self)
    end

    def visit_exclusive_or_expression(node)
      node.lhs_expression.accept(self)
      node.rhs_expression.accept(self)
    end

    def visit_inclusive_or_expression(node)
      node.lhs_expression.accept(self)
      node.rhs_expression.accept(self)
    end

    def visit_logical_and_expression(node)
      node.lhs_expression.accept(self)
      node.rhs_expression.accept(self)
    end

    def visit_logical_or_expression(node)
      node.lhs_expression.accept(self)
      node.rhs_expression.accept(self)
    end

    def visit_conditional_expression(node)
      node.condition.accept(self)
      node.first_expression.accept(self)
      node.second_expression.accept(self)
    end

    def visit_comma_separated_expression(node)
      node.expressions.each { |expr| expr.accept(self) }
    end
  end

  class SyntaxTreeMulticastVisitor < SyntaxTreeVisitor
    extend Pluggable

    def_plugin :enter_identifier_list
    def_plugin :leave_identifier_list
    def_plugin :enter_preprocessing_file
    def_plugin :leave_preprocessing_file
    def_plugin :enter_group
    def_plugin :leave_group
    def_plugin :enter_if_section
    def_plugin :leave_if_section
    def_plugin :enter_if_statement
    def_plugin :leave_if_statement
    def_plugin :enter_ifdef_statement
    def_plugin :leave_ifdef_statement
    def_plugin :enter_ifndef_statement
    def_plugin :leave_ifndef_statement
    def_plugin :enter_elif_groups
    def_plugin :leave_elif_groups
    def_plugin :enter_elif_statement
    def_plugin :leave_elif_statement
    def_plugin :enter_else_statement
    def_plugin :leave_else_statement
    def_plugin :enter_endif_line
    def_plugin :leave_endif_line
    def_plugin :enter_user_include_line
    def_plugin :leave_user_include_line
    def_plugin :enter_system_include_line
    def_plugin :leave_system_include_line
    def_plugin :enter_user_include_next_line
    def_plugin :leave_user_include_next_line
    def_plugin :enter_system_include_next_line
    def_plugin :leave_system_include_next_line
    def_plugin :enter_object_like_define_line
    def_plugin :leave_object_like_define_line
    def_plugin :enter_function_like_define_line
    def_plugin :leave_function_like_define_line
    def_plugin :enter_va_function_like_define_line
    def_plugin :leave_va_function_like_define_line
    def_plugin :enter_undef_line
    def_plugin :leave_undef_line
    def_plugin :enter_line_line
    def_plugin :leave_line_line
    def_plugin :enter_error_line
    def_plugin :leave_error_line
    def_plugin :enter_pragma_line
    def_plugin :leave_pragma_line
    def_plugin :enter_text_line
    def_plugin :leave_text_line
    def_plugin :enter_null_directive
    def_plugin :leave_null_directive
    def_plugin :enter_unknown_directive
    def_plugin :leave_unknown_directive
    def_plugin :enter_pp_tokens
    def_plugin :leave_pp_tokens
    def_plugin :enter_error_expression
    def_plugin :leave_error_expression
    def_plugin :enter_constant_specifier
    def_plugin :leave_constant_specifier
    def_plugin :enter_grouped_expression
    def_plugin :leave_grouped_expression
    def_plugin :enter_unary_arithmetic_expression
    def_plugin :leave_unary_arithmetic_expression
    def_plugin :enter_defined_expression
    def_plugin :leave_defined_expression
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
    def_plugin :enter_comma_separated_expression
    def_plugin :leave_comma_separated_expression

    def self.def_visitor_method(node_name)
      class_eval <<-EOS
        define_method("visit_#{node_name}") do |*args|
          visit_with_notifying(__method__, args.first) { super(args.first) }
        end
      EOS
    end
    private_class_method :def_visitor_method

    def_visitor_method :identifier_list
    def_visitor_method :preprocessing_file
    def_visitor_method :group
    def_visitor_method :if_section
    def_visitor_method :if_statement
    def_visitor_method :ifdef_statement
    def_visitor_method :ifndef_statement
    def_visitor_method :elif_groups
    def_visitor_method :elif_statement
    def_visitor_method :else_statement
    def_visitor_method :endif_line
    def_visitor_method :user_include_line
    def_visitor_method :system_include_line
    def_visitor_method :user_include_next_line
    def_visitor_method :system_include_next_line
    def_visitor_method :object_like_define_line
    def_visitor_method :function_like_define_line
    def_visitor_method :va_function_like_define_line
    def_visitor_method :undef_line
    def_visitor_method :line_line
    def_visitor_method :error_line
    def_visitor_method :pragma_line
    def_visitor_method :text_line
    def_visitor_method :null_directive
    def_visitor_method :unknown_directive
    def_visitor_method :pp_tokens
    def_visitor_method :error_expression
    def_visitor_method :constant_specifier
    def_visitor_method :grouped_expression
    def_visitor_method :unary_arithmetic_expression
    def_visitor_method :defined_expression
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
    def_visitor_method :comma_separated_expression

    private
    def visit_with_notifying(caller_method, node, &block)
      suffix = caller_method.to_s.sub(/\Avisit_/, "")
      __send__("enter_#{suffix}").invoke(node)
      yield
      __send__("leave_#{suffix}").invoke(node)
    end
  end

  module SyntaxNodeCollector
    def collect_define_lines(node)
      if node
        DefineLineCollector.new.tap { |col| node.accept(col) }.define_lines
      else
        []
      end
    end
    module_function :collect_define_lines

    def collect_undef_lines(node)
      if node
        UndefLineCollector.new.tap { |col| node.accept(col) }.undef_lines
      else
        []
      end
    end
    module_function :collect_undef_lines
  end

  class DefineLineCollector < SyntaxTreeVisitor
    def initialize
      @define_lines = []
    end

    attr_reader :define_lines

    def visit_object_like_define_line(node)
      super
      @define_lines.push(node)
    end

    def visit_function_like_define_line(node)
      super
      @define_lines.push(node)
    end

    def visit_va_function_like_define_line(node)
      super
      @define_lines.push(node)
    end
  end

  class UndefLineCollector < SyntaxTreeVisitor
    def initialize
      @undef_lines = []
    end

    attr_reader :undef_lines

    def visit_undef_line(node)
      super
      @undef_lines.push(node)
    end
  end

end
end
