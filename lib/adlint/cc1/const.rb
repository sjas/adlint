# C constant-expression evaluator.
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

require "adlint/traits"

module AdLint #:nodoc:
module Cc1 #:nodoc:

  module ConstantEvaluator
    # NOTE: Host class of this module must include InterpreterMediator.

    def eval_constant(const_spec)
      eval_as_integer_constant(const_spec.constant.value) or
      eval_as_floating_constant(const_spec.constant.value) or
      eval_as_character_constant(const_spec.constant.value)
    end

    private
    def eval_as_integer_constant(str)
      # NOTE: The ISO C99 standard says;
      #
      # 6.4.4.1 Integer constants
      #
      # 5 The type of an integer constant is the first of the corresponding
      #   list in which its value can be represented.
      #
      #               |        decimal         |  octal or hexadecimal
      #   ------------+------------------------+------------------------
      #   unsuffixed  | int                    | int
      #               | long int               | unsigned int
      #               | long long int          | long int
      #               |                        | unsigned long int
      #               |                        | long long int
      #               |                        | unsigned long long int
      #   ------------+------------------------+------------------------
      #    u or U     | unsigned int           | unsigned int
      #               | unsigned long int      | unsigned long int
      #               | unsigned long long int | unsigned long long int
      #   ------------+------------------------+------------------------
      #    l or L     | long int               | long int
      #               | long long int          | unsigned long int
      #               |                        | long long int
      #               |                        | unsigned long long int
      #   ------------+------------------------+------------------------
      #    u or U and | unsigned long int      | unsigned long int
      #    l or L     | unsigned long long int | unsigned long long int
      #   ------------+------------------------+------------------------
      #    ll or LL   | long long int          | long long int
      #               |                        | unsigned long long int
      #   ------------+------------------------+------------------------
      #    u or U and | unsigned long long int | unsigned long long int
      #    ll or LL   |                        |

      # NOTE: For binary constants.
      case str
      when /\A0b([01]+)(?:ULL|LLU)\z/i
        return eval_as_non_decimal_integer_constant_with_ull($1.to_i(2))
      when /\A0b([01]+)LL\z/i
        return eval_as_non_decimal_integer_constant_with_ll($1.to_i(2))
      when /\A0b([01]+)(?:UL|LU)\z/i
        return eval_as_non_decimal_integer_constant_with_ul($1.to_i(2))
      when /\A0b([01]+)L\z/i
        return eval_as_non_decimal_integer_constant_with_l($1.to_i(2))
      when /\A0b([01]+)U\z/i
        return eval_as_non_decimal_integer_constant_with_u($1.to_i(2))
      when /\A0b([01]+)\z/i
        return eval_as_non_decimal_integer_constant_unsuffixed($1.to_i(2))
      end

      # NOTE: For octal constants.
      case str
      when /\A0([0-9]+)(?:ULL|LLU)\z/i
        return eval_as_non_decimal_integer_constant_with_ull($1.to_i(8))
      when /\A0([0-9]+)LL\z/i
        return eval_as_non_decimal_integer_constant_with_ll($1.to_i(8))
      when /\A0([0-9]+)(?:UL|LU)\z/i
        return eval_as_non_decimal_integer_constant_with_ul($1.to_i(8))
      when /\A0([0-9]+)L\z/i
        return eval_as_non_decimal_integer_constant_with_l($1.to_i(8))
      when /\A0([0-9]+)U\z/i
        return eval_as_non_decimal_integer_constant_with_u($1.to_i(8))
      when /\A0([0-9]+)\z/
        return eval_as_non_decimal_integer_constant_unsuffixed($1.to_i(8))
      end

      # NOTE: For decimal constants.
      case str
      when /\A([0-9]+)(?:ULL|LLU)\z/i
        return eval_as_decimal_integer_constant_with_ull($1.to_i(10))
      when /\A([0-9]+)LL\z/i
        return eval_as_decimal_integer_constant_with_ll($1.to_i(10))
      when /\A([0-9]+)(?:UL|LU)\z/i
        return eval_as_decimal_integer_constant_with_ul($1.to_i(10))
      when /\A([0-9]+)L\z/i
        return eval_as_decimal_integer_constant_with_l($1.to_i(10))
      when /\A([0-9]+)U\z/i
        return eval_as_decimal_integer_constant_with_u($1.to_i(10))
      when /\A([0-9]+)\z/
        return eval_as_decimal_integer_constant_unsuffixed($1.to_i(10))
      end

      # NOTE: For hexadecimal constants.
      case str
      when /\A0x([0-9A-F]+)(?:ULL|LLU)\z/i
        return eval_as_non_decimal_integer_constant_with_ull($1.to_i(16))
      when /\A0x([0-9A-F]+)LL\z/i
        return eval_as_non_decimal_integer_constant_with_ll($1.to_i(16))
      when /\A0x([0-9A-F]+)(?:UL|LU)\z/i
        return eval_as_non_decimal_integer_constant_with_ul($1.to_i(16))
      when /\A0x([0-9A-F]+)L\z/i
        return eval_as_non_decimal_integer_constant_with_l($1.to_i(16))
      when /\A0x([0-9A-F]+)U\z/i
        return eval_as_non_decimal_integer_constant_with_u($1.to_i(16))
      when /\A0x([0-9A-F]+)\z/i
        return eval_as_non_decimal_integer_constant_unsuffixed($1.to_i(16))
      end

      nil
    end

    def eval_as_floating_constant(str)
      # TODO: Must implement hexadecimal-floating-constant evaluation.
      case str
      when /\A([0-9]*\.[0-9]*E[+-]?[0-9]+)\z/i,
           /\A([0-9]+\.?E[+-]?[0-9]+)\z/i,
           /\A([0-9]*\.[0-9]+|[0-9]+\.)\z/
        return create_tmpvar(double_t, scalar_value_of($1.to_f))
      when /\A([0-9]*\.[0-9]*E[+-]?[0-9]+)F\z/i,
           /\A([0-9]+\.?E[+-]?[0-9]+)F\z/i,
           /\A([0-9]*\.[0-9]+|[0-9]+\.)F\z/i
        return create_tmpvar(float_t, scalar_value_of($1.to_f))
      when /\A([0-9]*\.[0-9]*E[+-]?[0-9]+)L\z/i,
           /\A([0-9]+\.?E[+-]?[0-9]+)L\z/i,
           /\A([0-9]*\.[0-9]+|[0-9]+\.)L\z/i
        return create_tmpvar(long_double_t, scalar_value_of($1.to_f))
      end
      nil
    end

    def eval_as_character_constant(str)
      if str =~ /\A(L?)'(.*)'\z/i
        case $2.length
        when 0
          char_code = 0
        when 1
          char_code = $2[0].ord
        else
          char_code = $2[0] == "\\" ? EscapeSequence.new($2).value : $2[0].ord
        end

        if $1 == "L"
          create_tmpvar(wchar_t, scalar_value_of(char_code))
        else
          create_tmpvar(int_t, scalar_value_of(char_code))
        end
      else
        nil
      end
    end

    def eval_as_decimal_integer_constant_unsuffixed(i)
      case
      when int_range.include?(i)
        create_tmpvar(int_t, scalar_value_of(i))
      when long_int_range.include?(i)
        create_tmpvar(long_int_t, scalar_value_of(i))
      when long_long_int_range.include?(i)
        create_tmpvar(long_long_int_t, scalar_value_of(i))
      else
        # NOTE: The ISO C99 standard says;
        #
        # 6.4.4.1 Integer constants
        #
        # 6 If an integer constant cannot be represented by any type in its
        #   list and has no extended integer type, then the integer constant
        #   has no type.
        #
        # NOTE: Use ExtendedBigIntType for unrepresentable integer constants.
        create_tmpvar(extended_big_int_t, scalar_value_of(i))
      end
    end

    def eval_as_decimal_integer_constant_with_u(i)
      case
      when unsigned_int_range.include?(i)
        create_tmpvar(unsigned_int_t, scalar_value_of(i))
      when unsigned_long_int_range.include?(i)
        create_tmpvar(unsigned_long_int_t, scalar_value_of(i))
      when unsigned_long_long_int_range.include?(i)
        create_tmpvar(unsigned_long_long_int_t, scalar_value_of(i))
      else
        # NOTE: The ISO C99 standard says;
        #
        # 6.4.4.1 Integer constants
        #
        # 6 If an integer constant cannot be represented by any type in its
        #   list and has no extended integer type, then the integer constant
        #   has no type.
        #
        # NOTE: Use ExtendedBigIntType for unrepresentable integer constants.
        create_tmpvar(extended_big_int_t, scalar_value_of(i))
      end
    end

    def eval_as_decimal_integer_constant_with_l(i)
      case
      when long_int_range.include?(i)
        create_tmpvar(long_int_t, scalar_value_of(i))
      when long_long_int_range.include?(i)
        create_tmpvar(long_long_int_t, scalar_value_of(i))
      else
        # NOTE: The ISO C99 standard says;
        #
        # 6.4.4.1 Integer constants
        #
        # 6 If an integer constant cannot be represented by any type in its
        #   list and has no extended integer type, then the integer constant
        #   has no type.
        #
        # NOTE: Use ExtendedBigIntType for unrepresentable integer constants.
        create_tmpvar(extended_big_int_t, scalar_value_of(i))
      end
    end

    def eval_as_decimal_integer_constant_with_ul(i)
      case
      when unsigned_long_int_range.include?(i)
        create_tmpvar(unsigned_long_int_t, scalar_value_of(i))
      when unsigned_long_long_int_range.include?(i)
        create_tmpvar(unsigned_long_long_int_t, scalar_value_of(i))
      else
        # NOTE: The ISO C99 standard says;
        #
        # 6.4.4.1 Integer constants
        #
        # 6 If an integer constant cannot be represented by any type in its
        #   list and has no extended integer type, then the integer constant
        #   has no type.
        #
        # NOTE: Use ExtendedBigIntType for unrepresentable integer constants.
        create_tmpvar(extended_big_int_t, scalar_value_of(i))
      end
    end

    def eval_as_decimal_integer_constant_with_ll(i)
      case
      when long_long_int_range.include?(i)
        create_tmpvar(long_long_int_t, scalar_value_of(i))
      else
        # NOTE: The ISO C99 standard says;
        #
        # 6.4.4.1 Integer constants
        #
        # 6 If an integer constant cannot be represented by any type in its
        #   list and has no extended integer type, then the integer constant
        #   has no type.
        #
        # NOTE: Use ExtendedBigIntType for unrepresentable integer constants.
        create_tmpvar(extended_big_int_t, scalar_value_of(i))
      end
    end

    def eval_as_decimal_integer_constant_with_ull(i)
      case
      when unsigned_long_long_int_range.include?(i)
        create_tmpvar(unsigned_long_long_int_t, scalar_value_of(i))
      else
        # NOTE: The ISO C99 standard says;
        #
        # 6.4.4.1 Integer constants
        #
        # 6 If an integer constant cannot be represented by any type in its
        #   list and has no extended integer type, then the integer constant
        #   has no type.
        #
        # NOTE: Use ExtendedBigIntType for unrepresentable integer constants.
        create_tmpvar(extended_big_int_t, scalar_value_of(i))
      end
    end

    def eval_as_non_decimal_integer_constant_unsuffixed(i)
      case
      when int_range.include?(i)
        create_tmpvar(int_t, scalar_value_of(i))
      when unsigned_int_range.include?(i)
        create_tmpvar(unsigned_int_t, scalar_value_of(i))
      when long_int_range.include?(i)
        create_tmpvar(long_int_t, scalar_value_of(i))
      when unsigned_long_int_range.include?(i)
        create_tmpvar(unsigned_long_int_t, scalar_value_of(i))
      when long_long_int_range.include?(i)
        create_tmpvar(long_long_int_t, scalar_value_of(i))
      when unsigned_long_long_int_range.include?(i)
        create_tmpvar(unsigned_long_long_int_t, scalar_value_of(i))
      else
        # NOTE: The ISO C99 standard says;
        #
        # 6.4.4.1 Integer constants
        #
        # 6 If an integer constant cannot be represented by any type in its
        #   list and has no extended integer type, then the integer constant
        #   has no type.
        #
        # NOTE: Use ExtendedBigIntType for unrepresentable integer constants.
        create_tmpvar(extended_big_int_t, scalar_value_of(i))
      end
    end

    def eval_as_non_decimal_integer_constant_with_u(i)
      case
      when unsigned_int_range.include?(i)
        create_tmpvar(unsigned_int_t, scalar_value_of(i))
      when unsigned_long_int_range.include?(i)
        create_tmpvar(unsigned_long_int_t, scalar_value_of(i))
      when unsigned_long_long_int_range.include?(i)
        create_tmpvar(unsigned_long_long_int_t, scalar_value_of(i))
      else
        # NOTE: The ISO C99 standard says;
        #
        # 6.4.4.1 Integer constants
        #
        # 6 If an integer constant cannot be represented by any type in its
        #   list and has no extended integer type, then the integer constant
        #   has no type.
        #
        # NOTE: Use ExtendedBigIntType for unrepresentable integer constants.
        create_tmpvar(extended_big_int_t, scalar_value_of(i))
      end
    end

    def eval_as_non_decimal_integer_constant_with_l(i)
      case
      when long_int_range.include?(i)
        create_tmpvar(long_int_t, scalar_value_of(i))
      when unsigned_long_int_range.include?(i)
        create_tmpvar(unsigned_long_int_t, scalar_value_of(i))
      when long_long_int_range.include?(i)
        create_tmpvar(long_long_int_t, scalar_value_of(i))
      when unsigned_long_long_int_range.include?(i)
        create_tmpvar(unsigned_long_long_int_t, scalar_value_of(i))
      else
        # NOTE: The ISO C99 standard says;
        #
        # 6.4.4.1 Integer constants
        #
        # 6 If an integer constant cannot be represented by any type in its
        #   list and has no extended integer type, then the integer constant
        #   has no type.
        #
        # NOTE: Use ExtendedBigIntType for unrepresentable integer constants.
        create_tmpvar(extended_big_int_t, scalar_value_of(i))
      end
    end

    def eval_as_non_decimal_integer_constant_with_ul(i)
      case
      when unsigned_long_int_range.include?(i)
        create_tmpvar(unsigned_long_int_t, scalar_value_of(i))
      when unsigned_long_long_int_range.include?(i)
        create_tmpvar(unsigned_long_long_int_t, scalar_value_of(i))
      else
        # NOTE: The ISO C99 standard says;
        #
        # 6.4.4.1 Integer constants
        #
        # 6 If an integer constant cannot be represented by any type in its
        #   list and has no extended integer type, then the integer constant
        #   has no type.
        #
        # NOTE: Use ExtendedBigIntType for unrepresentable integer constants.
        create_tmpvar(extended_big_int_t, scalar_value_of(i))
      end
    end

    def eval_as_non_decimal_integer_constant_with_ll(i)
      case
      when long_long_int_range.include?(i)
        create_tmpvar(long_long_int_t, scalar_value_of(i))
      when unsigned_long_long_int_range.include?(i)
        create_tmpvar(unsigned_long_long_int_t, scalar_value_of(i))
      else
        # NOTE: The ISO C99 standard says;
        #
        # 6.4.4.1 Integer constants
        #
        # 6 If an integer constant cannot be represented by any type in its
        #   list and has no extended integer type, then the integer constant
        #   has no type.
        #
        # NOTE: Use ExtendedBigIntType for unrepresentable integer constants.
        create_tmpvar(extended_big_int_t, scalar_value_of(i))
      end
    end

    def eval_as_non_decimal_integer_constant_with_ull(i)
      case
      when unsigned_long_long_int_range.include?(i)
        create_tmpvar(unsigned_long_long_int_t, scalar_value_of(i))
      else
        # NOTE: The ISO C99 standard says;
        #
        # 6.4.4.1 Integer constants
        #
        # 6 If an integer constant cannot be represented by any type in its
        #   list and has no extended integer type, then the integer constant
        #   has no type.
        #
        # NOTE: Use ExtendedBigIntType for unrepresentable integer constants.
        create_tmpvar(extended_big_int_t, scalar_value_of(i))
      end
    end

    def int_range
      int_t.min..int_t.max
    end

    def long_int_range
      long_int_t.min..long_int_t.max
    end

    def long_long_int_range
      long_long_int_t.min..long_long_int_t.max
    end

    def unsigned_int_range
      unsigned_int_t.min..unsigned_int_t.max
    end

    def unsigned_long_int_range
      unsigned_long_int_t.min..unsigned_long_int_t.max
    end

    def unsigned_long_long_int_range
      unsigned_long_long_t.min..unsigned_long_long_t.max
    end
  end

end
end
