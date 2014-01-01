# The constant-expression evaluator.
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

class AdLint::Cpp::ConstantExpression

token CONSTANT
      IDENTIFIER
      DEFINED

start constant_expression

rule

primary_expression
    : CONSTANT
      {
        case val[0].value
        when /\A0b([01]+)[UL]*\z/i
          value = $1.to_i(2)
        when /\A(0[0-9]*)[UL]*\z/i
          value = $1.to_i(8)
        when /\A([1-9][0-9]*)[UL]*\z/i
          value = $1.to_i(10)
        when /\A0x([0-9a-f]+)[UL]*\z/i
          value = $1.to_i(16)
        when /\A([0-9]*\.[0-9]*E[+-]?[0-9]+|[0-9]+\.?E[+-]?[0-9]+)[FL]*\z/i,
             /\A([0-9]*\.[0-9]+|[0-9]+\.)[FL]*/i
          value = $1.to_f
        when /\AL?'(.*)'\z/i
          if $1.length > 1 && $1[0] == "\\"
            value = EscapeSequence.new($1).value
          else
            value = $1[0].ord
          end
        else
          value = 0
        end
        result = ConstantSpecifier.new(value, val[0])
        yyerrok
      }
    | IDENTIFIER
      {
        notify_undefined_macro_referred(val[0])
        result = ErrorExpression.new(val[0])
        yyerrok
      }
    | "(" expression ")"
      {
        result = GroupedExpression.new(val[1].value, val[1])
        yyerrok
      }
    ;

postfix_expression
    : primary_expression
    ;

unary_expression
    : postfix_expression
    | "+" unary_expression
      {
        value = val[1].value
        result = UnaryArithmeticExpression.new(value, val[0], val[1])
      }
    | "-" unary_expression
      {
        value = -val[1].value
        result = UnaryArithmeticExpression.new(value, val[0], val[1])
      }
    | "~" unary_expression
      {
        value = ~val[1].value
        result = UnaryArithmeticExpression.new(value, val[0], val[1])
      }
    | "!" unary_expression
      {
        value = val[1].value == 0 ? 1 : 0
        result = UnaryArithmeticExpression.new(value, val[0], val[1])
      }
    | DEFINED "(" IDENTIFIER ")"
      {
        if macro = @macro_tbl.lookup(val[2].value)
          macro.define_line.mark_as_referred_by(val[2])
          value = 1
        else
          value = 0
        end
        result = DefinedExpression.new(value, val[0], val[2])
      }
    | DEFINED IDENTIFIER
      {
        if macro = @macro_tbl.lookup(val[1].value)
          macro.define_line.mark_as_referred_by(val[1])
          value = 1
        else
          value = 0
        end
        result = DefinedExpression.new(value, val[0], val[1])
      }
    | DEFINED error
      {
        notify_illformed_defined_operator(loc_of(val[0]), val[1] == "$")
        result = ErrorExpression.new(val[1])
      }
    ;

multiplicative_expression
    : unary_expression
    | multiplicative_expression "*" unary_expression
      {
        value = val[0].value * val[2].value
        result = MultiplicativeExpression.new(value, val[1], val[0], val[2])
      }
    | multiplicative_expression "/" unary_expression
      {
        unless val[2].value == 0
          value = val[0].value / val[2].value
        else
          value = 0
        end
        result = MultiplicativeExpression.new(value, val[1], val[0], val[2])
      }
    | multiplicative_expression "%" unary_expression
      {
        unless val[2].value == 0
          value = val[0].value % val[2].value
        else
          value = 0
        end
        result = MultiplicativeExpression.new(value, val[1], val[0], val[2])
      }
    ;

additive_expression
    : multiplicative_expression
    | additive_expression "+" multiplicative_expression
      {
        value = val[0].value + val[2].value
        result = AdditiveExpression.new(value, val[1], val[0], val[2])
      }
    | additive_expression "-" multiplicative_expression
      {
        value = val[0].value - val[2].value
        result = AdditiveExpression.new(value, val[1], val[0], val[2])
      }
    ;

shift_expression
    : additive_expression
    | shift_expression "<<" additive_expression
      {
        value = val[0].value << val[2].value
        result = ShiftExpression.new(value, val[1], val[0], val[2])
      }
    | shift_expression ">>" additive_expression
      {
        value = val[0].value >> val[2].value
        result = ShiftExpression.new(value, val[1], val[0], val[2])
      }
    ;

relational_expression
    : shift_expression
    | relational_expression "<" shift_expression
      {
        value = val[0].value < val[2].value ? 1 : 0
        result = RelationalExpression.new(value, val[1], val[0], val[2])
      }
    | relational_expression ">" shift_expression
      {
        value = val[0].value > val[2].value ? 1 : 0
        result = RelationalExpression.new(value, val[1], val[0], val[2])
      }
    | relational_expression "<=" shift_expression
      {
        value = val[0].value <= val[2].value ? 1 : 0
        result = RelationalExpression.new(value, val[1], val[0], val[2])
      }
    | relational_expression ">=" shift_expression
      {
        value = val[0].value >= val[2].value ? 1 : 0
        result = RelationalExpression.new(value, val[1], val[0], val[2])
      }
    ;

equality_expression
    : relational_expression
    | equality_expression "==" relational_expression
      {
        value = val[0].value == val[2].value ? 1 : 0
        result = EqualityExpression.new(value, val[1], val[0], val[2])
      }
    | equality_expression "!=" relational_expression
      {
        value = val[0].value != val[2].value ? 1 : 0
        result = EqualityExpression.new(value, val[1], val[0], val[2])
      }
    ;

and_expression
    : equality_expression
    | and_expression "&" equality_expression
      {
        value = val[0].value & val[2].value
        result = AndExpression.new(value, val[1], val[0], val[2])
      }
    ;

exclusive_or_expression
    : and_expression
    | exclusive_or_expression "^" and_expression
      {
        value = val[0].value ^ val[2].value
        result = ExclusiveOrExpression.new(value, val[1], val[0], val[2])
      }
    ;

inclusive_or_expression
    : exclusive_or_expression
    | inclusive_or_expression "|" exclusive_or_expression
      {
        value = val[0].value | val[2].value
        result = InclusiveOrExpression.new(value, val[1], val[0], val[2])
      }
    ;

logical_and_expression
    : inclusive_or_expression
    | logical_and_expression "&&" inclusive_or_expression
      {
        value = val[0].value == 1 && val[2].value == 1 ? 1 : 0
        result = LogicalAndExpression.new(value, val[1], val[0], val[2])
      }
    ;

logical_or_expression
    : logical_and_expression
    | logical_or_expression "||" logical_and_expression
      {
        value = val[0].value == 1 || val[2].value == 1 ? 1 : 0
        result = LogicalOrExpression.new(value, val[1], val[0], val[2])
      }
    ;

conditional_expression
    : logical_or_expression
    | logical_or_expression "?" expression ":" conditional_expression
      {
        value = val[0].value == 1 ? val[2].value : val[4].value
        result = ConditionalExpression.new(value, val[0], val[2], val[4])
      }
    ;

constant_expression
    : conditional_expression
    ;

expression
    : constant_expression
    | constant_expression "," expression
      {
        case val[0]
        when CommaSeparatedExpression then
          val[0].value = val[2].value
          result = val[0].push(val[2])
        else
          value = val[2].value
          result =
            CommaSeparatedExpression.new(value).push(val[0]).push(val[2])
        end
      }
    ;

end

---- header

require "adlint/report"
require "adlint/util"
require "adlint/cpp/util"

---- inner

include ReportUtil

def initialize(pp_ctxt, expr_toks)
  @pp_ctxt     = pp_ctxt
  @expr_toks   = expr_toks
  @macro_tbl   = pp_ctxt.macro_table
  @fpath       = expr_toks.first.location.fpath
  @lst_line_no = expr_toks.last.location.line_no
end

extend Pluggable

def_plugin :on_illformed_defined_op_found
def_plugin :on_undefined_macro_referred

def evaluate
  @tok_queue = relex(@expr_toks)
  if expr = do_parse
    expr
  else
    ErrorExpression.new(nil)
  end
end

private
def relex(expr_toks)
  tok_queue = []
  expr_toks.each do |tok|
    case tok.value
    when /\A(?:0x[0-9a-f]+|[0-9]+)[UL]*\z/i
      tok_queue.push(Token.new(:CONSTANT, tok.value, tok.location))
    when /\A(?:[0-9]*\.[0-9]*e[+-]?[0-9]+|[0-9]+\.?e[+-]?[0-9]+)[FL]*/i
      tok_queue.push(Token.new(:CONSTANT, tok.value, tok.location))
    when /\AL?'.*'\z/i
      tok_queue.push(Token.new(:CONSTANT, tok.value, tok.location))
    when /\AL?".*"\z/i
      tok_queue.push(Token.new(:CONSTANT, tok.value, tok.location))
    when "(", ")", "+", "-", "~", "!", "*", "/", "%", "<<", ">>", "<", ">",
         "<=", ">=", "==", "!=", "&", "^", "|", "&&", "||", "?", ":"
      tok_queue.push(Token.new(tok.value, tok.value, tok.location))
    when "defined"
      tok_queue.push(Token.new(:DEFINED, tok.value, tok.location))
    else
      tok_queue.push(Token.new(:IDENTIFIER, tok.value, tok.location))
    end
  end
  tok_queue
end

def next_token
  (tok = @tok_queue.shift) ? [tok.type, tok] : nil
end

def on_error(err_tok_id, err_val, *)
  E(:E0007, loc_of(err_val), val_of(err_val))
end

def loc_of(tok)
  tok == "$" ? Location.new(@fpath, @lst_line_no) : tok.location
end

def val_of(tok)
  tok == "$" ? "EOF" : tok.value
end

def notify_illformed_defined_operator(loc, no_args)
  on_illformed_defined_op_found.invoke(loc, no_args)
end

def notify_undefined_macro_referred(id)
  on_undefined_macro_referred.invoke(id)
end

extend Forwardable

def_delegator :@pp_ctxt, :report
private :report

def_delegator :@pp_ctxt, :message_catalog
private :message_catalog

# vim:ft=racc:sw=2:ts=2:sts=2:et:
