# The ISO C99 parser.
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

class AdLint::Cc1::Parser

token IDENTIFIER
      TYPEDEF_NAME
      CONSTANT
      STRING_LITERAL
      SIZEOF
      TYPEDEF
      EXTERN
      STATIC
      AUTO
      REGISTER
      INLINE
      RESTRICT
      CHAR
      SHORT
      INT
      LONG
      SIGNED
      UNSIGNED
      FLOAT
      DOUBLE
      CONST
      VOLATILE
      VOID
      BOOL
      COMPLEX
      IMAGINARY
      STRUCT
      UNION
      ENUM
      CASE
      DEFAULT
      IF
      ELSE
      SWITCH
      WHILE
      DO
      FOR
      GOTO
      CONTINUE
      BREAK
      RETURN
      NULL
      TYPEOF
      ALIGNOF

start translation_unit

expect 1 # NOTE: To ignore dangling-else shift/reduce conflict.

rule

#
# Expressions
#
primary_expression
    : IDENTIFIER
      {
        checkpoint(val[0].location)
        result = ObjectSpecifier.new(val[0])
        result.head_token = result.tail_token = val[0]
      }
    | CONSTANT
      {
        checkpoint(val[0].location)
        result = ConstantSpecifier.new(val[0])
        result.head_token = result.tail_token = val[0]
      }
    | STRING_LITERAL
      {
        checkpoint(val[0].location)
        result = StringLiteralSpecifier.new(val[0])
        result.head_token = result.tail_token = val[0]
      }
    | NULL
      {
        checkpoint(val[0].location)
        result = NullConstantSpecifier.new(val[0])
        result.head_token = result.tail_token = val[0]
      }
    | "(" expression ")"
      {
        checkpoint(val[0].location)
        result = GroupedExpression.new(val[1])
        result.head_token = val[0]
        result.tail_token = val[2]
      }
    | "(" compound_statement ")"
      {
        checkpoint(val[0].location)
        E(:E0013, val[0].location)
        result = ErrorExpression.new(val[0])
        result.head_token = val[0]
        result.tail_token = val[2]
      }
    ;

postfix_expression
    : primary_expression
    | postfix_expression "[" expression "]"
      {
        checkpoint(val[0].location)
        result = ArraySubscriptExpression.new(val[0], val[2], val[1])
        result.head_token = val[0].head_token
        result.tail_token = val[3]
      }
    | postfix_expression "(" ")"
      {
        checkpoint(val[0].location)
        result = FunctionCallExpression.new(val[0], [], val[1])
        result.head_token = val[0].head_token
        result.tail_token = val[2]
      }
    | postfix_expression "(" argument_expression_list ")"
      {
        checkpoint(val[0].location)
        result = FunctionCallExpression.new(val[0], val[2], val [1])
        result.head_token = val[0].head_token
        result.tail_token = val[3]
      }
    | postfix_expression "." IDENTIFIER
      {
        checkpoint(val[0].location)
        result = MemberAccessByValueExpression.new(val[0], val[2], val[1])
        result.head_token = val[0].head_token
        result.tail_token = val[2]
      }
    | postfix_expression "->" IDENTIFIER
      {
        checkpoint(val[0].location)
        result = MemberAccessByPointerExpression.new(val[0], val[2], val[1])
        result.head_token = val[0].head_token
        result.tail_token = val[2]
      }
    | postfix_expression "." CONSTANT
      {
        checkpoint(val[0].location)
        result = BitAccessByValueExpression.new(val[0], val[2], val[1])
        result.head_token = val[0].head_token
        result.tail_token = val[2]
      }
    | postfix_expression "->" CONSTANT
      {
        checkpoint(val[0].location)
        result = BitAccessByPointerExpression.new(val[0], val[2], val[1])
        result.head_token = val[0].head_token
        result.tail_token = val[2]
      }
    | postfix_expression "++"
      {
        checkpoint(val[0].location)
        result = PostfixIncrementExpression.new(val[1], val[0])
        result.head_token = val[0].head_token
        result.tail_token = val[1]
      }
    | postfix_expression "--"
      {
        checkpoint(val[0].location)
        result = PostfixDecrementExpression.new(val[1], val[0])
        result.head_token = val[0].head_token
        result.tail_token = val[1]
      }
    | "(" type_name ")" "{" initializer_list "}"
      {
        checkpoint(val[0].location)
        result = CompoundLiteralExpression.new(val[1], val[4], val[0])
        result.head_token = val[0]
        result.tail_token = val[5]
      }
    | "(" type_name ")" "{" initializer_list "," "}"
      {
        checkpoint(val[0].location)
        result = CompoundLiteralExpression.new(val[1], val[4], val[0])
        result.head_token = val[0]
        result.tail_token = val[6]
      }
    ;

argument_expression_list
    : assignment_expression
      {
        checkpoint(val[0].location)
        result = val
      }
    | argument_expression_list "," assignment_expression
      {
        checkpoint(val[0].first.location)
        result = val[0].push(val[2])
      }
    ;

unary_expression
    : postfix_expression
    | "++" unary_expression
      {
        checkpoint(val[0].location)
        result = PrefixIncrementExpression.new(val[0], val[1])
        result.head_token = val[0]
        result.tail_token = val[1].tail_token
      }
    | "--" unary_expression
      {
        checkpoint(val[0].location)
        result = PrefixDecrementExpression.new(val[0], val[1])
        result.head_token = val[0]
        result.tail_token = val[1].tail_token
      }
    | "&" cast_expression
      {
        checkpoint(val[0].location)
        result = AddressExpression.new(val[0], val[1])
        result.head_token = val[0]
        result.tail_token = val[1].tail_token
      }
    | "*" cast_expression
      {
        checkpoint(val[0].location)
        result = IndirectionExpression.new(val[0], val[1])
        result.head_token = val[0]
        result.tail_token = val[1].tail_token
      }
    | unary_arithmetic_operator cast_expression
      {
        checkpoint(val[0].location)
        result = UnaryArithmeticExpression.new(val[0], val[1])
        result.head_token = val[0]
        result.tail_token = val[1].tail_token
      }
    | SIZEOF unary_expression
      {
        checkpoint(val[0].location)
        result = SizeofExpression.new(val[0], val[1])
        result.head_token = val[0]
        result.tail_token = val[1].tail_token
      }
    | SIZEOF "(" type_name ")"
      {
        checkpoint(val[0].location)
        result = SizeofTypeExpression.new(val[0], val[2])
        result.head_token = val[0]
        result.tail_token = val[3]
      }
    | ALIGNOF unary_expression
      {
        checkpoint(val[0].location)
        result = AlignofExpression.new(val[0], val[1])
        result.head_token = val[0]
        result.tail_token = val[1].tail_token
      }
    | ALIGNOF "(" type_name ")"
      {
        checkpoint(val[0].location)
        result = AlignofTypeExpression.new(val[0], val[2])
        result.head_token = val[0]
        result.tail_token = val[3]
      }
    | "&&" unary_expression
      {
        checkpoint(val[0].location)
        E(:E0014, val[0].location, val[0].value)
        result = ErrorExpression.new(val[0])
        result.head_token = val[0]
        result.tail_token = val[1].tail_token
      }
    ;

unary_arithmetic_operator
    : "+"
    | "-"
    | "~"
    | "!"
    ;

cast_expression
    : unary_expression
    | "(" type_name ")" cast_expression
      {
        checkpoint(val[0].location)
        result = CastExpression.new(val[1], val[3])
        result.head_token = val[0]
        result.tail_token = val[3].tail_token
      }
    ;

multiplicative_expression
    : cast_expression
    | multiplicative_expression "*" cast_expression
      {
        checkpoint(val[0].location)
        result = MultiplicativeExpression.new(val[1], val[0], val[2])
        result.head_token = val[0].head_token
        result.tail_token = val[2].tail_token
      }
    | multiplicative_expression "/" cast_expression
      {
        checkpoint(val[0].location)
        result = MultiplicativeExpression.new(val[1], val[0], val[2])
        result.head_token = val[0].head_token
        result.tail_token = val[2].tail_token
      }
    | multiplicative_expression "%" cast_expression
      {
        checkpoint(val[0].location)
        result = MultiplicativeExpression.new(val[1], val[0], val[2])
        result.head_token = val[0].head_token
        result.tail_token = val[2].tail_token
      }
    ;

additive_expression
    : multiplicative_expression
    | additive_expression "+" multiplicative_expression
      {
        checkpoint(val[0].location)
        result = AdditiveExpression.new(val[1], val[0], val[2])
        result.head_token = val[0].head_token
        result.tail_token = val[2].tail_token
      }
    | additive_expression "-" multiplicative_expression
      {
        checkpoint(val[0].location)
        result = AdditiveExpression.new(val[1], val[0], val[2])
        result.head_token = val[0].head_token
        result.tail_token = val[2].tail_token
      }
    ;

shift_expression
    : additive_expression
    | shift_expression "<<" additive_expression
      {
        checkpoint(val[0].location)
        result = ShiftExpression.new(val[1], val[0], val[2])
        result.head_token = val[0].head_token
        result.tail_token = val[2].tail_token
      }
    | shift_expression ">>" additive_expression
      {
        checkpoint(val[0].location)
        result = ShiftExpression.new(val[1], val[0], val[2])
        result.head_token = val[0].head_token
        result.tail_token = val[2].tail_token
      }
    ;

relational_expression
    : shift_expression
    | relational_expression "<" shift_expression
      {
        checkpoint(val[0].location)
        result = RelationalExpression.new(val[1], val[0], val[2])
        result.head_token = val[0].head_token
        result.tail_token = val[2].tail_token
      }
    | relational_expression ">" shift_expression
      {
        checkpoint(val[0].location)
        result = RelationalExpression.new(val[1], val[0], val[2])
        result.head_token = val[0].head_token
        result.tail_token = val[2].tail_token
      }
    | relational_expression "<=" shift_expression
      {
        checkpoint(val[0].location)
        result = RelationalExpression.new(val[1], val[0], val[2])
        result.head_token = val[0].head_token
        result.tail_token = val[2].tail_token
      }
    | relational_expression ">=" shift_expression
      {
        checkpoint(val[0].location)
        result = RelationalExpression.new(val[1], val[0], val[2])
        result.head_token = val[0].head_token
        result.tail_token = val[2].tail_token
      }
    ;

equality_expression
    : relational_expression
    | equality_expression "==" relational_expression
      {
        checkpoint(val[0].location)
        result = EqualityExpression.new(val[1], val[0], val[2])
        result.head_token = val[0].head_token
        result.tail_token = val[2].tail_token
      }
    | equality_expression "!=" relational_expression
      {
        checkpoint(val[0].location)
        result = EqualityExpression.new(val[1], val[0], val[2])
        result.head_token = val[0].head_token
        result.tail_token = val[2].tail_token
      }
    ;

and_expression
    : equality_expression
    | and_expression "&" equality_expression
      {
        checkpoint(val[0].location)
        result = AndExpression.new(val[1], val[0], val[2])
        result.head_token = val[0].head_token
        result.tail_token = val[2].tail_token
      }
    ;

exclusive_or_expression
    : and_expression
    | exclusive_or_expression "^" and_expression
      {
        checkpoint(val[0].location)
        result = ExclusiveOrExpression.new(val[1], val[0], val[2])
        result.head_token = val[0].head_token
        result.tail_token = val[2].tail_token
      }
    ;

inclusive_or_expression
    : exclusive_or_expression
    | inclusive_or_expression "|" exclusive_or_expression
      {
        checkpoint(val[0].location)
        result = InclusiveOrExpression.new(val[1], val[0], val[2])
        result.head_token = val[0].head_token
        result.tail_token = val[2].tail_token
      }
    ;

logical_and_expression
    : inclusive_or_expression
    | logical_and_expression "&&" inclusive_or_expression
      {
        checkpoint(val[0].location)
        result = LogicalAndExpression.new(val[1], val[0], val[2])
        result.head_token = val[0].head_token
        result.tail_token = val[2].tail_token
      }
    ;

logical_or_expression
    : logical_and_expression
    | logical_or_expression "||" logical_and_expression
      {
        checkpoint(val[0].location)
        result = LogicalOrExpression.new(val[1], val[0], val[2])
        result.head_token = val[0].head_token
        result.tail_token = val[2].tail_token
      }
    ;

conditional_expression
    : logical_or_expression
    | logical_or_expression "?" expression ":" conditional_expression
      {
        checkpoint(val[0].location)
        result = ConditionalExpression.new(val[0], val[2], val[4], val[1])
        result.head_token = val[0].head_token
        result.tail_token = val[4].tail_token
      }
    ;

assignment_expression
    : conditional_expression
    | cast_expression "=" assignment_expression
      {
        checkpoint(val[0].location)
        result = SimpleAssignmentExpression.new(val[1], val[0], val[2])
        result.head_token = val[0].head_token
        result.tail_token = val[2].tail_token
      }
    | cast_expression compound_assignment_operator assignment_expression
      {
        checkpoint(val[0].location)
        result = CompoundAssignmentExpression.new(val[1], val[0], val[2])
        result.head_token = val[0].head_token
        result.tail_token = val[2].tail_token
      }
    ;

compound_assignment_operator
    : "*="
    | "/="
    | "%="
    | "+="
    | "-="
    | "<<="
    | ">>="
    | "&="
    | "^="
    | "|="
    ;

expression
    : assignment_expression
    | expression "," assignment_expression
      {
        checkpoint(val[0].location)
        case val[0]
        when CommaSeparatedExpression
          result = val[0].push(val[2])
        else
          result = CommaSeparatedExpression.new(val[0]).push(val[2])
        end
      }
    ;

constant_expression
    : conditional_expression
    ;

#
# Declarations
#
declaration
    : declaration_specifiers ";"
      {
        checkpoint(val[0].location)
        @lexer.enable_identifier_translation
        result = Declaration.new(val[0], [], @sym_tbl)
        result.head_token = val[0].head_token
        result.tail_token = val[1]
      }
    | declaration_specifiers init_declarator_list ";"
      {
        checkpoint(val[0].location)
        @lexer.enable_identifier_translation
        result = Declaration.new(val[0], val[1], @sym_tbl)
        result.head_token = val[0].head_token
        result.tail_token = val[2]
        result.items.each do |item|
          case item
          when TypedefDeclaration
            @lexer.add_typedef_name(item.identifier)
          when FunctionDeclaration, VariableDeclaration, VariableDefinition
            @lexer.add_object_name(item.identifier)
          end
        end
      }
    ;

global_declaration
    : declaration
    | init_declarator_list ";"
      {
        checkpoint(val[0].first.location)
        result = Declaration.new(nil, val[0], @sym_tbl)
        result.head_token = val[0].first.head_token
        result.tail_token = val[1]
      }
    ;

declaration_specifiers
    : storage_class_specifier
      {
        checkpoint(val[0].location)
        result = DeclarationSpecifiers.new
        result.storage_class_specifier = val[0]
        result.head_token = result.tail_token = val[0]
      }
    | declaration_specifiers storage_class_specifier
      {
        checkpoint(val[0].location)
        result = val[0]
        result.storage_class_specifier = val[1]
        result.tail_token = val[1]
      }
    | type_specifier
      {
        checkpoint(val[0].location)
        result = DeclarationSpecifiers.new
        result.type_specifiers.push(val[0])
        result.head_token = val[0].head_token
        result.tail_token = val[0].tail_token
      }
    | declaration_specifiers type_specifier
      {
        checkpoint(val[0].location)
        result = val[0]
        result.type_specifiers.push(val[1])
        result.tail_token = val[1].tail_token
      }
    | type_qualifier
      {
        checkpoint(val[0].location)
        result = DeclarationSpecifiers.new
        result.type_qualifiers.push(val[0])
        result.head_token = result.tail_token = val[0]
      }
    | declaration_specifiers type_qualifier
      {
        checkpoint(val[0].location)
        result = val[0]
        result.type_qualifiers.push(val[1])
        result.tail_token = val[1]
      }
    | function_specifier
      {
        checkpoint(val[0].location)
        result = DeclarationSpecifiers.new
        result.function_specifier = val[0]
        result.head_token = result.tail_token = val[0]
      }
    | declaration_specifiers function_specifier
      {
        checkpoint(val[0].location)
        result = val[0]
        result.function_specifier = val[1]
        result.tail_token = val[1]
      }
    ;

init_declarator_list
    : init_declarator
      {
        checkpoint(val[0].location)
        result = val
      }
    | init_declarator_list "," init_declarator
      {
        checkpoint(val[0].first.location)
        result = val[0].push(val[2])
      }
    ;

init_declarator
    : declarator
      {
        checkpoint(val[0].location)
        result = InitDeclarator.new(val[0], nil)
        result.head_token = val[0].head_token
        result.tail_token = val[0].tail_token
      }
    | declarator "=" initializer
      {
        checkpoint(val[0].location)
        result = InitDeclarator.new(val[0], val[2])
        result.head_token = val[0].head_token
        result.tail_token = val[2].tail_token
      }
    ;

storage_class_specifier
    : TYPEDEF
    | EXTERN
    | STATIC
    | AUTO
    | REGISTER
    ;

type_specifier
    : VOID
      {
        checkpoint(val[0].location)
        @lexer.disable_identifier_translation
        result = StandardTypeSpecifier.new(val[0])
        result.head_token = result.tail_token = val[0]
      }
    | CHAR
      {
        checkpoint(val[0].location)
        @lexer.disable_identifier_translation
        result = StandardTypeSpecifier.new(val[0])
        result.head_token = result.tail_token = val[0]
      }
    | SHORT
      {
        checkpoint(val[0].location)
        @lexer.disable_identifier_translation
        result = StandardTypeSpecifier.new(val[0])
        result.head_token = result.tail_token = val[0]
      }
    | INT
      {
        checkpoint(val[0].location)
        @lexer.disable_identifier_translation
        result = StandardTypeSpecifier.new(val[0])
        result.head_token = result.tail_token = val[0]
      }
    | LONG
      {
        checkpoint(val[0].location)
        @lexer.disable_identifier_translation
        result = StandardTypeSpecifier.new(val[0])
        result.head_token = result.tail_token = val[0]
      }
    | FLOAT
      {
        checkpoint(val[0].location)
        @lexer.disable_identifier_translation
        result = StandardTypeSpecifier.new(val[0])
        result.head_token = result.tail_token = val[0]
      }
    | DOUBLE
      {
        checkpoint(val[0].location)
        @lexer.disable_identifier_translation
        result = StandardTypeSpecifier.new(val[0])
        result.head_token = result.tail_token = val[0]
      }
    | SIGNED
      {
        checkpoint(val[0].location)
        @lexer.disable_identifier_translation
        result = StandardTypeSpecifier.new(val[0])
        result.head_token = result.tail_token = val[0]
      }
    | UNSIGNED
      {
        checkpoint(val[0].location)
        @lexer.disable_identifier_translation
        result = StandardTypeSpecifier.new(val[0])
        result.head_token = result.tail_token = val[0]
      }
    | BOOL
      {
        checkpoint(val[0].location)
        @lexer.disable_identifier_translation
        result = StandardTypeSpecifier.new(val[0])
        result.head_token = result.tail_token = val[0]
      }
    | COMPLEX
      {
        checkpoint(val[0].location)
        @lexer.disable_identifier_translation
        result = StandardTypeSpecifier.new(val[0])
        result.head_token = result.tail_token = val[0]
      }
    | IMAGINARY
      {
        checkpoint(val[0].location)
        @lexer.disable_identifier_translation
        result = StandardTypeSpecifier.new(val[0])
        result.head_token = result.tail_token = val[0]
      }
    | TYPEDEF_NAME
      {
        checkpoint(val[0].location)
        @lexer.disable_identifier_translation
        result = TypedefTypeSpecifier.new(val[0])
        result.head_token = result.tail_token = val[0]
      }
    | struct_or_union_specifier
      {
        checkpoint(val[0].location)
        @lexer.disable_identifier_translation
        result = val[0]
      }
    | enum_specifier
      {
        checkpoint(val[0].location)
        @lexer.disable_identifier_translation
        result = val[0]
      }
    | TYPEOF "(" constant_expression ")"
      {
        checkpoint(val[0].location)
        @lexer.disable_identifier_translation
        val[2].full = true
        result = TypeofTypeSpecifier.new(val[2], nil)
        result.head_token = val[0]
        result.tail_token = val[3]
      }
    | TYPEOF "(" type_name ")"
      {
        checkpoint(val[0].location)
        @lexer.disable_identifier_translation
        result = TypeofTypeSpecifier.new(nil, val[2])
        result.head_token = val[0]
        result.tail_token = val[3]
      }
    ;

struct_or_union_specifier
    : STRUCT IDENTIFIER "{" struct_declaration_list "}"
      {
        checkpoint(val[0].location)
        result = StructSpecifier.new(val[1], val[3])
        result.head_token = val[0]
        result.tail_token = val[4]
      }
    | STRUCT IDENTIFIER "{" "}"
      {
        checkpoint(val[0].location)
        result = StructSpecifier.new(val[1], [])
        result.head_token = val[0]
        result.tail_token = val[3]
      }
    | UNION IDENTIFIER "{" struct_declaration_list "}"
      {
        checkpoint(val[0].location)
        result = UnionSpecifier.new(val[1], val[3])
        result.head_token = val[0]
        result.tail_token = val[4]
      }
    | UNION IDENTIFIER "{" "}"
      {
        checkpoint(val[0].location)
        result = UnionSpecifier.new(val[1], [])
        result.head_token = val[0]
        result.tail_token = val[3]
      }
    | STRUCT "{" struct_declaration_list "}"
      {
        checkpoint(val[0].location)
        result = StructSpecifier.new(create_anon_tag_name(val[0]), val[2])
        result.head_token = val[0]
        result.tail_token = val[3]
      }
    | STRUCT "{" "}"
      {
        checkpoint(val[0].location)
        result = StructSpecifier.new(create_anon_tag_name(val[0]), [])
        result.head_token = val[0]
        result.tail_token = val[2]
      }
    | UNION "{" struct_declaration_list "}"
      {
        checkpoint(val[0].location)
        result = UnionSpecifier.new(create_anon_tag_name(val[0]), val[2])
        result.head_token = val[0]
        result.tail_token = val[3]
      }
    | UNION "{" "}"
      {
        checkpoint(val[0].location)
        result = UnionSpecifier.new(create_anon_tag_name(val[0]), [])
        result.head_token = val[0]
        result.tail_token = val[2]
      }
    | STRUCT IDENTIFIER
      {
        checkpoint(val[0].location)
        result = StructSpecifier.new(val[1], nil)
        result.head_token = val[0]
        result.tail_token = val[1]
      }
    | UNION IDENTIFIER
      {
        checkpoint(val[0].location)
        result = UnionSpecifier.new(val[1], nil)
        result.head_token = val[0]
        result.tail_token = val[1]
      }
    ;

struct_declaration_list
    : struct_declaration
      {
        checkpoint(val[0].location)
        @lexer.enable_identifier_translation
        result = val
      }
    | struct_declaration_list struct_declaration
      {
        checkpoint(val[0].first.location)
        @lexer.enable_identifier_translation
        result = val[0].push(val[1])
      }
    ;

struct_declaration
    : specifier_qualifier_list ";"
      {
        checkpoint(val[0].location)
        result = StructDeclaration.new(val[0], [])
        result.head_token = val[0].head_token
        result.tail_token = val[1]
      }
    | specifier_qualifier_list struct_declarator_list ";"
      {
        checkpoint(val[0].location)
        result = StructDeclaration.new(val[0], val[1])
        result.head_token = val[0].head_token
        result.tail_token = val[2]
      }
    ;

specifier_qualifier_list
    : specifier_qualifier_list type_specifier
      {
        checkpoint(val[0].location)
        result = val[0]
        result.type_specifiers.push(val[1])
        result.tail_token = val[1].tail_token
      }
    | type_specifier
      {
        checkpoint(val[0].location)
        result = SpecifierQualifierList.new
        result.type_specifiers.push(val[0])
        result.head_token = val[0].head_token
        result.tail_token = val[0].tail_token
      }
    | specifier_qualifier_list type_qualifier
      {
        checkpoint(val[0].location)
        result = val[0]
        result.type_qualifiers.push(val[1])
        result.tail_token = val[1]
      }
    | type_qualifier
      {
        checkpoint(val[0].location)
        result = SpecifierQualifierList.new
        result.type_qualifiers.push(val[0])
        result.head_token = result.tail_token = val[0]
      }
    ;

struct_declarator_list
    : struct_declarator
      {
        checkpoint(val[0].location)
        result = val
      }
    | struct_declarator_list "," struct_declarator
      {
        checkpoint(val[0].first.location)
        result = val[0].push(val[2])
      }
    ;

struct_declarator
    : declarator
      {
        checkpoint(val[0].location)
        result = StructDeclarator.new(val[0], nil)
        result.head_token = val[0].head_token
        result.tail_token = val[0].tail_token
      }
    | ":" constant_expression
      {
        checkpoint(val[0].location)
        val[1].full = true
        result = StructDeclarator.new(nil, val[1])
        result.head_token = val[0]
        result.tail_token = val[1].tail_token
      }
    | declarator ":" constant_expression
      {
        checkpoint(val[0].location)
        val[2].full = true
        result = StructDeclarator.new(val[0], val[2])
        result.head_token = val[0].head_token
        result.tail_token = val[2].tail_token
      }
    ;

enum_specifier
    : ENUM "{" enumerator_list "}"
      {
        checkpoint(val[0].location)
        result = EnumSpecifier.new(create_anon_tag_name(val[0]), val[2])
        result.head_token = val[0]
        result.tail_token = val[3]
        result.enumerators.each do |enum|
          @lexer.add_enumerator_name(enum.identifier)
        end
      }
    | ENUM IDENTIFIER "{" enumerator_list "}"
      {
        checkpoint(val[0].location)
        result = EnumSpecifier.new(val[1], val[3])
        result.head_token = val[0]
        result.tail_token = val[4]
        result.enumerators.each do |enum|
          @lexer.add_enumerator_name(enum.identifier)
        end
      }
    | ENUM "{" enumerator_list "," "}"
      {
        checkpoint(val[0].location)
        result = EnumSpecifier.new(create_anon_tag_name(val[0]),
                                   val[2], val[3])
        result.head_token = val[0]
        result.tail_token = val[4]
        result.enumerators.each do |enum|
          @lexer.add_enumerator_name(enum.identifier)
        end
      }
    | ENUM IDENTIFIER "{" enumerator_list "," "}"
      {
        checkpoint(val[0].location)
        result = EnumSpecifier.new(val[1], val[3], val[4])
        result.head_token = val[0]
        result.tail_token = val[5]
        result.enumerators.each do |enum|
          @lexer.add_enumerator_name(enum.identifier)
        end
      }
    | ENUM IDENTIFIER
      {
        checkpoint(val[0].location)
        result = EnumSpecifier.new(val[1], nil)
        result.head_token = val[0]
        result.tail_token = val[1]
      }
    ;

enumerator_list
    : enumerator
      {
        checkpoint(val[0].location)
        result = val
      }
    | enumerator_list "," enumerator
      {
        checkpoint(val[0].first.location)
        result = val[0].push(val[2])
      }
    ;

enumerator
    : enumerator_name
      {
        checkpoint(val[0].location)
        sym = @sym_tbl.create_new_symbol(EnumeratorName, val[0])
        result = Enumerator.new(val[0], nil, sym)
        result.head_token = result.tail_token = val[0]
      }
    | enumerator_name "=" constant_expression
      {
        checkpoint(val[0].location)
        val[2].full = true
        sym = @sym_tbl.create_new_symbol(EnumeratorName, val[0])
        result = Enumerator.new(val[0], val[2], sym)
        result.head_token = val[0]
        result.tail_token = val[2].tail_token
      }
    ;

enumerator_name
    : IDENTIFIER
    | TYPEDEF_NAME
      {
        result = val[0].class.new(:IDENTIFIER, val[0].value, val[0].location)
      }
    ;

type_qualifier
    : CONST
    | VOLATILE
    | RESTRICT
    ;

function_specifier
    : INLINE
    ;

declarator
    : pointer direct_declarator
      {
        checkpoint(val[0].first.location)
        result = val[1]
        result.pointer = val[0]
        result.head_token = val[0].first
        result.full = true
      }
    | direct_declarator
      {
        checkpoint(val[0].location)
        result = val[0]
        result.full = true
      }
    ;

direct_declarator
    : IDENTIFIER
      {
        checkpoint(val[0].location)
        @lexer.enable_identifier_translation
        result = IdentifierDeclarator.new(val[0])
        result.head_token = result.tail_token = val[0]
      }
    | "(" declarator ")"
      {
        checkpoint(val[0].location)
        result = GroupedDeclarator.new(val[1])
        result.head_token = val[0]
        result.tail_token = val[2]
      }
    | direct_declarator "[" type_qualifier_list assignment_expression "]"
      {
        checkpoint(val[0].location)
        val[3].full = true
        result = ArrayDeclarator.new(val[0], val[3])
        result.head_token = val[0].head_token
        result.tail_token = val[4]
      }
    | direct_declarator "[" type_qualifier_list "]"
      {
        checkpoint(val[0].location)
        result = ArrayDeclarator.new(val[0], nil)
        result.head_token = val[0].head_token
        result.tail_token = val[3]
      }
    | direct_declarator "[" assignment_expression "]"
      {
        checkpoint(val[0].location)
        val[2].full = true
        result = ArrayDeclarator.new(val[0], val[2])
        result.head_token = val[0].head_token
        result.tail_token = val[3]
      }
    | direct_declarator
      "[" STATIC type_qualifier_list assignment_expression "]"
      {
        checkpoint(val[0].location)
        val[4].full = true
        result = ArrayDeclarator.new(val[0], val[4])
        result.head_token = val[0].head_token
        result.tail_token = val[5]
      }
    | direct_declarator
      "[" type_qualifier_list STATIC assignment_expression "]"
      {
        checkpoint(val[0].location)
        val[4].full = true
        result = ArrayDeclarator.new(val[0], val[4])
        result.head_token = val[0].head_token
        result.tail_token = val[5]
      }
    | direct_declarator "[" type_qualifier_list "*" "]"
      {
        checkpoint(val[0].location)
        result = ArrayDeclarator.new(val[0], nil)
        result.head_token = val[0].head_token
        result.tail_token = val[4]
      }
    | direct_declarator "[" "*" "]"
      {
        checkpoint(val[0].location)
        result = ArrayDeclarator.new(val[0], nil)
        result.head_token = val[0].head_token
        result.tail_token = val[3]
      }
    | direct_declarator "[" "]"
      {
        checkpoint(val[0].location)
        result = ArrayDeclarator.new(val[0], nil)
        result.head_token = val[0].head_token
        result.tail_token = val[2]
      }
    | direct_declarator "(" { @lexer.enable_identifier_translation }
      parameter_type_list ")"
      {
        checkpoint(val[0].location)
        result = AnsiFunctionDeclarator.new(val[0], val[3])
        result.head_token = val[0].head_token
        result.tail_token = val[4]
      }
    | direct_declarator "(" identifier_list ")"
      {
        checkpoint(val[0].location)
        result = KandRFunctionDeclarator.new(val[0], val[2])
        result.head_token = val[0].head_token
        result.tail_token = val[3]
      }
    | direct_declarator "(" ")"
      {
        checkpoint(val[0].location)
        result = AbbreviatedFunctionDeclarator.new(val[0])
        result.head_token = val[0].head_token
        result.tail_token = val[2]
      }
    ;

pointer
    : "*"
      {
        checkpoint(val[0].location)
        result = val
      }
    | "*" type_qualifier_list
      {
        checkpoint(val[0].location)
        result = val[1].unshift(val[0])
      }
    | "*" pointer
      {
        checkpoint(val[0].location)
        result = val[1].unshift(val[0])
      }
    | "*" type_qualifier_list pointer
      {
        checkpoint(val[0].location)
        result = val[1].unshift(val[0]).concat(val[2])
      }
    ;

type_qualifier_list
    : type_qualifier
      {
        checkpoint(val[0].location)
        result = val
      }
    | type_qualifier_list type_qualifier
      {
        checkpoint(val[0].first.location)
        result = val[0].push(val[1])
      }
    ;

parameter_type_list
    : parameter_list
      {
        checkpoint(val[0].first.location)
        result = ParameterTypeList.new(val[0], false)
        result.head_token = val[0].first.head_token
        result.tail_token = val[0].last.tail_token
      }
    | parameter_list "," "..."
      {
        checkpoint(val[0].first.location)
        result = ParameterTypeList.new(val[0], true)
        result.head_token = val[0].first.head_token
        result.tail_token = val[2]
      }
    ;

parameter_list
    : parameter_declaration
      {
        checkpoint(val[0].location)
        result = val
      }
    | parameter_list "," parameter_declaration
      {
        checkpoint(val[0].first.location)
        result = val[0].push(val[2])
      }
    ;

parameter_declaration
    : declaration_specifiers declarator
      {
        checkpoint(val[0].location)
        @lexer.enable_identifier_translation
        result = ParameterDeclaration.new(val[0], val[1])
        result.head_token = val[0].head_token
        result.tail_token = val[1].tail_token
      }
    | declaration_specifiers abstract_declarator
      {
        checkpoint(val[0].location)
        @lexer.enable_identifier_translation
        result = ParameterDeclaration.new(val[0], val[1])
        result.head_token = val[0].head_token
        result.tail_token = val[1].tail_token
      }
    | declaration_specifiers
      {
        checkpoint(val[0].location)
        @lexer.enable_identifier_translation
        result = ParameterDeclaration.new(val[0], nil)
        result.head_token = val[0].head_token
        result.tail_token = val[0].tail_token
      }
    ;

identifier_list
    : IDENTIFIER
      {
        checkpoint(val[0].location)
        result = val
      }
    | identifier_list "," IDENTIFIER
      {
        checkpoint(val[0].first.location)
        result = val[0].push(val[2])
      }
    ;

type_name
    : specifier_qualifier_list
      {
        checkpoint(val[0].location)
        @lexer.enable_identifier_translation
        result = TypeName.new(val[0], nil, @sym_tbl)
        result.head_token = val[0].head_token
        result.tail_token = val[0].tail_token
      }
    | specifier_qualifier_list abstract_declarator
      {
        checkpoint(val[0].location)
        @lexer.enable_identifier_translation
        result = TypeName.new(val[0], val[1], @sym_tbl)
        result.head_token = val[0].head_token
        result.tail_token = val[1].tail_token
      }
    ;

abstract_declarator
    : pointer
      {
        checkpoint(val[0].first.location)
        @lexer.enable_identifier_translation
        result = PointerAbstractDeclarator.new(nil, val[0])
        result.head_token = val[0].first
        result.tail_token = val[0].last
        result.full = true
      }
    | pointer direct_abstract_declarator
      {
        checkpoint(val[0].first.location)
        @lexer.enable_identifier_translation
        result = PointerAbstractDeclarator.new(val[1], val[0])
        result.head_token = val[0].first
        result.tail_token = val[1].tail_token
        result.full = true
      }
    | direct_abstract_declarator
      {
        checkpoint(val[0].location)
        result = val[0]
        result.full = true
      }
    ;

direct_abstract_declarator
    : "(" abstract_declarator ")"
      {
        checkpoint(val[0].location)
        result = GroupedAbstractDeclarator.new(val[1])
        result.head_token = val[0]
        result.tail_token = val[2]
      }
    | "[" "]"
      {
        checkpoint(val[0].location)
        result = ArrayAbstractDeclarator.new(nil, nil)
        result.head_token = val[0]
        result.tail_token = val[1]
      }
    | "[" assignment_expression "]"
      {
        checkpoint(val[0].location)
        val[1].full = true
        result = ArrayAbstractDeclarator.new(nil, val[1])
        result.head_token = val[0]
        result.tail_token = val[2]
      }
    | direct_abstract_declarator "[" "]"
      {
        checkpoint(val[0].location)
        result = ArrayAbstractDeclarator.new(val[0], nil)
        result.head_token = val[0].head_token
        result.tail_token = val[2]
      }
    | direct_abstract_declarator "[" assignment_expression "]"
      {
        checkpoint(val[0].location)
        val[2].full = true
        result = ArrayAbstractDeclarator.new(val[0], val[2])
        result.head_token = val[0].head_token
        result.tail_token = val[3]
      }
    | "[" "*" "]"
      {
        checkpoint(val[0].location)
        result = ArrayAbstractDeclarator.new(nil, nil)
        result.head_token = val[0]
        result.tail_token = val[2]
      }
    | direct_abstract_declarator "[" "*" "]"
      {
        checkpoint(val[0].location)
        result = ArrayAbstractDeclarator.new(val[0], nil)
        result.head_token = val[0].head_token
        result.tail_token = val[3]
      }
    | "(" ")"
      {
        checkpoint(val[0].location)
        result = FunctionAbstractDeclarator.new(nil, nil)
        result.head_token = val[0]
        result.tail_token = val[1]
      }
    | "(" { @lexer.enable_identifier_translation } parameter_type_list ")"
      {
        checkpoint(val[0].location)
        result = FunctionAbstractDeclarator.new(nil, val[2])
        result.head_token = val[0]
        result.tail_token = val[3]
      }
    | direct_abstract_declarator "(" ")"
      {
        checkpoint(val[0].location)
        result = FunctionAbstractDeclarator.new(val[0], nil)
        result.head_token = val[0].head_token
        result.tail_token = val[2]
      }
    | direct_abstract_declarator "(" { @lexer.enable_identifier_translation }
      parameter_type_list ")"
      {
        checkpoint(val[0].location)
        result = FunctionAbstractDeclarator.new(val[0], val[3])
        result.head_token = val[0].head_token
        result.tail_token = val[4]
      }
    ;

initializer
    : assignment_expression
      {
        checkpoint(val[0].location)
        val[0].full = true
        result = Initializer.new(val[0], nil)
        result.head_token = val[0].head_token
        result.tail_token = val[0].tail_token
      }
    | "{" "}"
      {
        checkpoint(val[0].location)
        result = Initializer.new(nil, nil)
        result.head_token = val[0]
        result.tail_token = val[1]
      }
    | "{" initializer_list "}"
      {
        checkpoint(val[0].location)
        result = Initializer.new(nil, val[1])
        result.head_token = val[0]
        result.tail_token = val[2]
      }
    | "{" initializer_list "," "}"
      {
        checkpoint(val[0].location)
        result = Initializer.new(nil, val[1])
        result.head_token = val[0]
        result.tail_token = val[3]
      }
    ;

initializer_list
    : initializer
      {
        checkpoint(val[0].location)
        result = val
      }
    | designation initializer
      {
        checkpoint(val[1].location)
        result = [val[1]]
      }
    | initializer_list "," initializer
      {
        checkpoint(val[0].first.location)
        result = val[0].push(val[2])
      }
    | initializer_list "," designation initializer
      {
        checkpoint(val[0].first.location)
        result = val[0].push(val[3])
      }
    ;

designation
    : designator_list "="
    ;

designator_list
    : designator
    | designator_list designator
    ;

designator
    : "[" constant_expression "]"
    | "." IDENTIFIER
    ;

#
# Statements
#
statement
    : labeled_statement
    | compound_statement
    | expression_statement
    | selection_statement
    | iteration_statement
    | jump_statement
    ;

labeled_statement
    : label_name ":" statement
      {
        checkpoint(val[0].location)
        result = GenericLabeledStatement.new(val[0], val[2])
        result.head_token = val[0]
        result.tail_token = val[2].tail_token
      }
    | CASE constant_expression ":" statement
      {
        checkpoint(val[0].location)
        val[1].full = true
        result = CaseLabeledStatement.new(val[1], val[3])
        result.head_token = val[0]
        result.tail_token = val[3].tail_token
      }
    | DEFAULT ":" statement
      {
        checkpoint(val[0].location)
        result = DefaultLabeledStatement.new(val[2])
        result.head_token = val[0]
        result.tail_token = val[2].tail_token
      }
    ;

label_name
    : IDENTIFIER
    | TYPEDEF_NAME
      {
        result = val[0].class.new(:IDENTIFIER, val[0].value, val[0].location)
      }
    ;

compound_statement
    : "{" "}"
      {
        checkpoint(val[0].location)
        result = CompoundStatement.new([])
        result.head_token = val[0]
        result.tail_token = val[1]
      }
    | "{" { @lexer.enter_scope } block_item_list { @lexer.leave_scope } "}"
      {
        checkpoint(val[0].location)
        result = CompoundStatement.new(val[2])
        result.head_token = val[0]
        result.tail_token = val[4]
      }
    ;

block_item_list
    : block_item
      {
        checkpoint(val[0].location)
        result = val
      }
    | block_item_list block_item
      {
        checkpoint(val[0].first.location)
        result = val[0].push(val[1])
      }
    ;

block_item
    : declaration
    | statement
    | local_function_definition
    ;

expression_statement
    : ";"
      {
        checkpoint(val[0].location)
        result = ExpressionStatement.new(nil)
        result.head_token = result.tail_token = val[0]
      }
    | expression ";"
      {
        checkpoint(val[0].location)
        val[0].full = true
        result = ExpressionStatement.new(val[0])
        result.head_token = val[0].head_token
        result.tail_token = val[1]
      }
    ;

selection_statement
    : IF "(" expression ")" statement
      {
        checkpoint(val[0].location)
        val[2].full = true
        result = IfStatement.new(val[2], val[4], val[3])
        result.head_token = val[0]
        result.tail_token = val[4].tail_token
      }
    | IF "(" expression ")" statement ELSE statement
      {
        checkpoint(val[0].location)
        val[2].full = true
        result = IfElseStatement.new(val[2], val[4], val[6], val[3], val[5])
        result.head_token = val[0]
        result.tail_token = val[6].tail_token
      }
    | SWITCH "(" expression ")" statement
      {
        checkpoint(val[0].location)
        val[2].full = true
        result = SwitchStatement.new(val[2], val[4])
        result.head_token = val[0]
        result.tail_token = val[4].tail_token
      }
    ;

iteration_statement
    : WHILE "(" expression ")" statement
      {
        checkpoint(val[0].location)
        val[2].full = true
        result = WhileStatement.new(val[2], val[4], val[3])
        result.head_token = val[0]
        result.tail_token = val[4].tail_token
      }
    | DO statement WHILE "(" expression ")" ";"
      {
        checkpoint(val[0].location)
        val[4].full = true
        result = DoStatement.new(val[1], val[4], val[0], val[2])
        result.head_token = val[0]
        result.tail_token = val[6]
      }
    | FOR "(" expression_statement expression_statement ")" statement
      {
        checkpoint(val[0].location)
        result = ForStatement.new(val[2], val[3], nil, val[5], val[4])
        result.head_token = val[0]
        result.tail_token = val[5].tail_token
      }
    | FOR "(" expression_statement expression_statement expression ")"
      statement
      {
        checkpoint(val[0].location)
        val[4].full = true
        result = ForStatement.new(val[2], val[3], val[4], val[6], val[5])
        result.head_token = val[0]
        result.tail_token = val[6].tail_token
      }
    | FOR "(" declaration expression_statement ")" statement
      {
        checkpoint(val[0].location)
        result = C99ForStatement.new(val[2], val[3], nil, val[5], val[4])
        result.head_token = val[0]
        result.tail_token = val[5].tail_token
      }
    | FOR "(" declaration expression_statement expression ")" statement
      {
        checkpoint(val[0].location)
        val[4].full = true
        result = C99ForStatement.new(val[2], val[3], val[4], val[6], val[5])
        result.head_token = val[0]
        result.tail_token = val[6].tail_token
      }
    ;

jump_statement
    : GOTO label_name ";"
      {
        checkpoint(val[0].location)
        result = GotoStatement.new(val[1])
        result.head_token = val[0]
        result.tail_token = val[2]
      }
    | GOTO "*" expression ";"
      {
        checkpoint(val[0].location)
        E(:E0015, val[1].location, val[1].value)
        result = ErrorStatement.new(val[1])
        result.head_token = val[0]
        result.tail_token = val[3]
      }
    | CONTINUE ";"
      {
        checkpoint(val[0].location)
        result = ContinueStatement.new
        result.head_token = val[0]
        result.tail_token = val[1]
      }
    | BREAK ";"
      {
        checkpoint(val[0].location)
        result = BreakStatement.new
        result.head_token = val[0]
        result.tail_token = val[1]
      }
    | RETURN ";"
      {
        checkpoint(val[0].location)
        result = ReturnStatement.new(nil)
        result.head_token = val[0]
        result.tail_token = val[1]
      }
    | RETURN expression ";"
      {
        checkpoint(val[0].location)
        val[1].full = true
        result = ReturnStatement.new(val[1])
        result.head_token = val[0]
        result.tail_token = val[2]
      }
    ;

#
# External definitions
#
translation_unit
    :
      {
        result = TranslationUnit.new
      }
    | translation_unit external_declaration
      {
        checkpoint(val[0].location)
        result = val[0]
        result.push(val[1])
      }
    ;

external_declaration
    : function_definition
    | global_declaration
    ;

function_definition
    : declaration_specifiers declarator declaration_list compound_statement
      {
        checkpoint(val[0].location)
        result = KandRFunctionDefinition.new(val[0], val[1], val[2], val[3],
                                             @sym_tbl)
        result.head_token = val[0].head_token
        result.tail_token = val[3].tail_token
      }
    | declaration_specifiers declarator compound_statement
      {
        checkpoint(val[0].location)
        case val[1]
        when AnsiFunctionDeclarator
          result = AnsiFunctionDefinition.new(val[0], val[1], val[2], @sym_tbl)
        when KandRFunctionDeclarator
          result = KandRFunctionDefinition.new(val[0], val[1], [], val[2],
                                               @sym_tbl)
        when AbbreviatedFunctionDeclarator
          result = AnsiFunctionDefinition.new(val[0], val[1], val[2], @sym_tbl)
        end
        result.head_token = val[0].head_token
        result.tail_token = val[2].tail_token
      }
    | declarator declaration_list compound_statement
      {
        checkpoint(val[0].location)
        result = KandRFunctionDefinition.new(nil, val[0], val[1], val[2],
                                             @sym_tbl)
        result.head_token = val[0].head_token
        result.tail_token = val[2].tail_token
      }
    | declarator compound_statement
      {
        checkpoint(val[0].location)
        case val[0]
        when AnsiFunctionDeclarator
          result = AnsiFunctionDefinition.new(nil, val[0], val[1], @sym_tbl)
        when KandRFunctionDeclarator
          result = KandRFunctionDefinition.new(nil, val[0], [], val[1],
                                               @sym_tbl)
        when AbbreviatedFunctionDeclarator
          result = AnsiFunctionDefinition.new(nil, val[0], val[1], @sym_tbl)
        end
        result.head_token = val[0].head_token
        result.tail_token = val[1].tail_token
      }
    ;

local_function_definition
    : declaration_specifiers declarator declaration_list compound_statement
      {
        checkpoint(val[0].location)
        result = KandRFunctionDefinition.new(val[0], val[1], val[2], val[3],
                                             @sym_tbl)
        result.head_token = val[0].head_token
        result.tail_token = val[3].tail_token
      }
    | declaration_specifiers declarator compound_statement
      {
        checkpoint(val[0].location)
        case val[1]
        when AnsiFunctionDeclarator
          result = AnsiFunctionDefinition.new(val[0], val[1], val[2], @sym_tbl)
        when KandRFunctionDeclarator
          result = KandRFunctionDefinition.new(val[0], val[1], [], val[2],
                                               @sym_tbl)
        when AbbreviatedFunctionDeclarator
          result = AnsiFunctionDefinition.new(val[0], val[1], val[2], @sym_tbl)
        end
        result.head_token = val[0].head_token
        result.tail_token = val[2].tail_token
      }
    ;

declaration_list
    : declaration
      {
        checkpoint(val[0].location)
        result = val
      }
    | declaration_list declaration
      {
        checkpoint(val[0].first.location)
        result = val[0].push(val[1])
      }
    ;

end

---- header

require "adlint/error"
require "adlint/symbol"
require "adlint/monitor"
require "adlint/util"
require "adlint/cc1/lexer"
require "adlint/cc1/syntax"

---- inner

include ReportUtil
include MonitorUtil

def initialize(phase_ctxt)
  @phase_ctxt  = phase_ctxt
  @lexer       = create_lexer(phase_ctxt[:cc1_source])
  @sym_tbl     = phase_ctxt[:symbol_table]
  @token_array = []
  @anon_tag_no = 0
end

attr_reader :token_array

def execute
  do_parse
end

extend Pluggable

def_plugin :on_string_literals_concatenated

private
def create_lexer(pp_src)
  Lexer.new(pp_src).tap { |lexer| attach_lexer_plugin(lexer) }
end

def attach_lexer_plugin(lexer)
  lexer.on_string_literals_concatenated += lambda { |*args|
    on_string_literals_concatenated.invoke(*args)
  }
end

def next_token
  if tok = @lexer.next_token
    @token_array.push(tok)
    [tok.type, tok]
  else
    nil
  end
end

def on_error(err_tok, err_val, *)
  if fst_tok = @token_array[-2] and snd_tok = @token_array[-1]
    E(:E0008, loc_of(fst_tok), "#{val_of(fst_tok)} #{val_of(snd_tok)}")
    raise ParseError.new(loc_of(fst_tok),
                         @phase_ctxt.msg_fpath, @phase_ctxt.log_fpath)
  else
    E(:E0008, loc_of(err_val), val_of(err_val))
    raise ParseError.new(loc_of(err_val),
                         @phase_ctxt.msg_fpath, @phase_ctxt.log_fpath)
  end
end

def loc_of(val)
  val == "$" ? Location.new : val.location
end

def val_of(tok)
  tok == "$" ? "EOF" : tok.value
end

def create_anon_tag_name(base_tok)
  Token.new(:IDENTIFIER, "__adlint__anon_#{@anon_tag_no += 1}",
            base_tok.location)
end

extend Forwardable

def_delegator :@phase_ctxt, :report
private :report

def_delegator :@phase_ctxt, :message_catalog
private :message_catalog

def_delegator :@phase_ctxt, :monitor
private :monitor

# vim:ft=racc:sw=2:ts=2:sts=2:et:
