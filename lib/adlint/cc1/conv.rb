# C conversion semantics.
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

module AdLint #:nodoc:
module Cc1 #:nodoc:

  module Conversion
    # NOTE: Host class of this module must include InterpreterMediator.

    def do_conversion(orig_var, to_type)
      if orig_var.type.coercible?(to_type)
        # NOTE: Value will be coerced into the destination type in
        #       VariableTableMediator#create_tmpvar.
        create_tmpvar(to_type, wrap_around_value(orig_var, to_type))
      else
        nil
      end
    end

    def do_integer_promotion(orig_var)
      return orig_var unless orig_var.type.integer?

      promoted_type = orig_var.type.integer_promoted_type
      if orig_var.type.same_as?(promoted_type)
        orig_var
      else
        do_conversion(orig_var, promoted_type) || orig_var
      end
    end

    def do_usual_arithmetic_conversion(lhs_orig, rhs_orig)
      if lhs_orig.type.pointer? && rhs_orig.type.pointer?
        return lhs_orig, rhs_orig
      end

      arith_type = lhs_orig.type.arithmetic_type_with(rhs_orig.type)

      if lhs_orig.type.same_as?(arith_type)
        lhs_conved = lhs_orig
      else
        lhs_conved = do_conversion(lhs_orig, arith_type) || lhs_orig
      end

      if rhs_orig.type.same_as?(arith_type)
        rhs_conved = rhs_orig
      else
        rhs_conved = do_conversion(rhs_orig, arith_type) || rhs_orig
      end

      return lhs_conved, rhs_conved
    end

    def do_default_argument_promotion(orig_var)
      promoted_type = orig_var.type.argument_promoted_type
      if orig_var.type.same_as?(promoted_type)
        orig_var
      else
        do_conversion(orig_var, promoted_type) || orig_var
      end
    end

    def untyped_pointer_conversion?(from_type, to_type, from_val)
      return false unless to_type.pointer?

      # NOTE: Untyped pointer conversion is defined as below;
      #
      #           from_type     |     to_type      |      result
      #       ------------------+------------------+-----------------
      #        void pointer     | void pointer     | true
      #        void pointer     | non-void pointer | true
      #        non-void pointer | void pointer     | true
      #        non-void pointer | non-void pointer | false
      #        non-enum integer | void pointer     | from_val == 0
      #        non-enum integer | non-void pointer | from_val == 0
      #        enum             | void pointer     | false
      #        enum             | non-void pointer | false
      #        other            | void pointer     | true
      #        other            | non-void pointer | false
      case
      when from_type.pointer?
        void_pointer?(from_type) || void_pointer?(to_type)
      when from_type.integer?
        !from_type.enum? && from_val.test_must_be_null.true?
      else
        void_pointer?(to_type)
      end
    end

    private
    def wrap_around_value(orig_var, to_type)
      return orig_var.value unless orig_var.type.scalar? && to_type.scalar?

      case
      when orig_var.type.signed? && to_type.unsigned?
        min_val = scalar_value_of(to_type.min)
        if (orig_var.value < min_val).test_may_be_true.true?
          return min_val - orig_var.value + scalar_value_of(1)
        end
      when orig_var.type.unsigned? && to_type.signed?
        max_val = scalar_value_of(to_type.max)
        if (orig_var.value > max_val).test_may_be_true.true?
          return max_val - orig_var.value + scalar_value_of(1)
        end
      end

      orig_var.value
    end

    def void_pointer?(type)
      unqual_type = type.unqualify
      unqual_type.pointer? && unqual_type.base_type.void?
    end
  end

  # Host class of this module must include StandardTypeCatalogAccessor.
  module UsualArithmeticTypeConversion
    def do_usual_arithmetic_type_conversion(lhs, rhs)
      # NOTE: The ISO C99 standard says;
      #
      # 6.3.1.8 Usual arithmetic conversions
      #
      # 1 Many operators that except operands of arithmetic type cause
      #   conversions and yield result types in a similar way.  The purpose is
      #   to determine a common real type for the operands and result.  For the
      #   specified operands, each operand is converted, without change of type
      #   domain, to a type whose corresponding real type is the common real
      #   type.  Unless explicitly stated otherwise, the common real type is
      #   also the corresponding real type of the result, whose type domain is
      #   the type domain of the operands if they are the same, and complex
      #   otherwise.  This pattern is called the usual arithmetic conversions:
      #
      #     First, if the corresponding real type of either operand is long
      #     double, the other operand is converted, without change of type
      #     domain, to a type whose corresponding real type is long double.
      #
      #     Otherwise, if the corresponding real type of either operand is
      #     double, the other operand is converted, without change of type
      #     domain, to a type whose corresponding real type is double.
      #
      #     Otherwise, if the corresponding real type of either operand is
      #     float, the other operand is converted, without change of type
      #     domain, to a type whose corresponding real type is float.
      #
      #     Otherwise, the integer promotions are performed on both operands.
      #     Then the following rules are applied to the promoted operands:
      #
      #       If both operands have the same type, then no further conversion
      #       is needed.
      #
      #       Otherwise, if both operands have signed integer types or both
      #       have unsigned integer types, the operand with the type of lesser
      #       integer conversion rank is converted to the type of the operand
      #       with greater rank.
      #
      #       Otherwise, if the operand that has unsigned integer type has rank
      #       greater or equal to the rank of the type of the other operand,
      #       then the operand with signed integer type is converted to the
      #       type of the operand with unsigned integer type.
      #
      #       Otherwise, if the type of the operand with signed integer type
      #       can represent all of the values of the type of the operand with
      #       unsigned integer type, then the operand with unsigned integer
      #       type is converted to the type of the operand with signed integer
      #       type.
      #
      #       Otherwise, both operands are converted to the unsigned integer
      #       type corresponding to the type of the operand with signed integer
      #       type.

      if lhs.same_as?(long_double_t) || rhs.same_as?(long_double_t)
        return long_double_t
      end

      if lhs.same_as?(double_t) || rhs.same_as?(double_t)
        return double_t
      end

      if lhs.same_as?(float_t) || rhs.same_as?(float_t)
        return float_t
      end

      lhs_promoted = lhs.integer_promoted_type
      rhs_promoted = rhs.integer_promoted_type

      return lhs_promoted if lhs_promoted.same_as?(rhs_promoted)

      lhs_rank = lhs_promoted.integer_conversion_rank
      rhs_rank = rhs_promoted.integer_conversion_rank

      case
      when lhs_promoted.signed? && rhs_promoted.signed?
        return lhs_rank < rhs_rank ? rhs_promoted : lhs_promoted
      when lhs_promoted.unsigned? && rhs_promoted.unsigned?
        return lhs_rank < rhs_rank ? rhs_promoted : lhs_promoted
      when lhs_promoted.unsigned? && lhs_rank >= rhs_rank
        return lhs_promoted
      when rhs_promoted.unsigned? && lhs_rank <= rhs_rank
        return rhs_promoted
      when lhs_promoted.signed? && rhs_promoted.compatible?(lhs_promoted)
        return lhs_promoted
      when rhs_promoted.signed? && lhs_promoted.compatible?(rhs_promoted)
        return rhs_promoted
      when lhs_promoted.signed?
        return lhs_promoted.corresponding_unsigned_type
      when rhs_promoted.signed?
        return rhs_promoted.corresponding_unsigned_type
      end

      raise TypeError, "cannot do usual arithmetic conversion."
    end
  end

end
end
