# Domain of values bound to variables.
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

require "adlint/cc1/operator"

module AdLint #:nodoc:
module Cc1 #:nodoc:

  module ValueDomainFactory
    # NOTE: To avoid huge composite value-domain creation in the interp phase.
    COMPOSITE_MAX_COMPLEXITY = 16
    private_constant :COMPOSITE_MAX_COMPLEXITY

    def equal_to(numeric, logical_shr)
      EqualToValueDomain.new(numeric, logical_shr)
    end
    memoize :equal_to

    def not_equal_to(numeric, logical_shr)
      equal_to(numeric, logical_shr).inversion
    end
    memoize :not_equal_to

    def less_than(numeric, logical_shr)
      LessThanValueDomain.new(numeric, logical_shr)
    end
    memoize :less_than

    def greater_than(numeric, logical_shr)
      GreaterThanValueDomain.new(numeric, logical_shr)
    end
    memoize :greater_than

    def less_than_or_equal_to(numeric, logical_shr)
      less_than(numeric, logical_shr).union(equal_to(numeric, logical_shr))
    end
    memoize :less_than_or_equal_to

    def greater_than_or_equal_to(numeric, logical_shr)
      greater_than(numeric, logical_shr).union(equal_to(numeric, logical_shr))
    end
    memoize :greater_than_or_equal_to

    def of_true(logical_shr)
      not_equal_to(0, logical_shr)
    end
    memoize :of_true

    def of_false(logical_shr)
      equal_to(0, logical_shr)
    end
    memoize :of_false

    def of_unlimited(logical_shr)
      UnlimitedValueDomain.new(logical_shr)
    end
    memoize :of_unlimited

    def of_nil(logical_shr)
      NilValueDomain.new(logical_shr)
    end
    memoize :of_nil

    def of_nan(logical_shr)
      NaN.new(logical_shr)
    end
    memoize :of_nan

    def of_intersection(lhs_dom, rhs_dom)
      case lhs_dom
      when UndefinedValueDomain
        lhs_dom = lhs_dom.domain
        undefined = true
      end

      case rhs_dom
      when UndefinedValueDomain
        rhs_dom = rhs_dom.domain
        undefined = true
      end

      case
      when lhs_dom.empty?
        intersection = lhs_dom
      when rhs_dom.empty?
        intersection = rhs_dom
      when lhs_dom.contain?(rhs_dom)
        intersection = rhs_dom
      when rhs_dom.contain?(lhs_dom)
        intersection = lhs_dom
      when lhs_dom.intersect?(rhs_dom)
        intersection = _create_intersection(lhs_dom, rhs_dom)
      else
        intersection = of_nil(lhs_dom.logical_shr? && rhs_dom.logical_shr?)
      end

      undefined ? of_undefined(intersection) : intersection
    end
    memoize :of_intersection

    def of_union(lhs_dom, rhs_dom)
      case lhs_dom
      when UndefinedValueDomain
        lhs_dom = lhs_dom.domain
        undefined = true
      end

      case rhs_dom
      when UndefinedValueDomain
        rhs_dom = rhs_dom.domain
        undefined = true
      end

      case
      when lhs_dom.empty?
        union = rhs_dom
      when rhs_dom.empty?
        union = lhs_dom
      when lhs_dom.contain?(rhs_dom)
        union = lhs_dom
      when rhs_dom.contain?(lhs_dom)
        union = rhs_dom
      else
        union = _create_union(lhs_dom, rhs_dom)
      end

      undefined ? of_undefined(union) : union
    end
    memoize :of_union

    def of_undefined(dom)
      if dom.undefined?
        dom
      else
        UndefinedValueDomain.new(dom)
      end
    end
    memoize :of_undefined

    def of_ambiguous(undefined, logical_shr)
      AmbiguousValueDomain.new(undefined, logical_shr)
    end
    memoize :of_ambiguous

    def _create_intersection(lhs_dom, rhs_dom)
      expected = lhs_dom.complexity + rhs_dom.complexity
      if expected < COMPOSITE_MAX_COMPLEXITY
        IntersectionValueDomain.new(lhs_dom, rhs_dom)
      else
        of_ambiguous(lhs_dom.undefined? || rhs_dom.undefined?,
                     lhs_dom.logical_shr? && rhs_dom.logical_shr?)
      end
    end
    memoize :_create_intersection

    def _create_union(lhs_dom, rhs_dom)
      expected = lhs_dom.complexity + rhs_dom.complexity
      if expected < COMPOSITE_MAX_COMPLEXITY
        UnionValueDomain.new(lhs_dom, rhs_dom)
      else
        of_ambiguous(lhs_dom.undefined? || rhs_dom.undefined?,
                     lhs_dom.logical_shr? && rhs_dom.logical_shr?)
      end
    end
    memoize :_create_union

    def clear_memos
      clear_memo_of__equal_to
      clear_memo_of__not_equal_to
      clear_memo_of__less_than
      clear_memo_of__greater_than
      clear_memo_of__less_than_or_equal_to
      clear_memo_of__greater_than_or_equal_to
      clear_memo_of__of_true
      clear_memo_of__of_false
      clear_memo_of__of_unlimited
      clear_memo_of__of_nil
      clear_memo_of__of_nan
      clear_memo_of__of_intersection
      clear_memo_of__of_union
      clear_memo_of__of_undefined
      clear_memo_of__of_ambiguous
      clear_memo_of___create_intersection
      clear_memo_of___create_union
    end
  end

  # == DESCRIPTION
  # === ValueDomain class hierarchy
  #  ValueDomain <------------------------------+
  #    <-- NilValueDomain                       |
  #    <-- UnlimitedValueDomain                 |
  #          <-- NaN                            |
  #    <-- EqualToValueDomain                   |
  #    <-- LessThanValueDomain                  |
  #    <-- GreaterThanValueDomain               |
  #    <-- CompositeValueDomain <>--------------+
  #          <-- IntersectionValueDomain <------+
  #          <-- UnionValueDomain               |
  #    <-- UndefinedValueDomain <>--------------+
  #    <-- AmbiguousValueDomain
  class ValueDomain
    # NOTE: Instances of ValueDomain class are immutable.  It is safe to share
    #       the instance of the ValueDomain class of the same value.

    extend ValueDomainFactory

    def initialize(logical_shr)
      @logical_shr = logical_shr
    end

    def empty?
      subclass_responsibility
    end

    def nan?
      subclass_responsibility
    end

    def undefined?
      subclass_responsibility
    end

    def ambiguous?
      subclass_responsibility
    end

    def logical_shr?
      @logical_shr
    end

    def contain?(domain_or_numeric)
      case domain_or_numeric
      when ValueDomain
        contain_value_domain?(domain_or_numeric)
      when Numeric
        dom = ValueDomain.equal_to(domain_or_numeric, logical_shr?)
        contain_value_domain?(dom)
      else
        raise TypeError, "`#{domain_or_numeric.inspect}' " +
          "must be kind of ValueDomain or Numeric."
      end
    end

    def contain_value_domain?(rhs_dom)
      subclass_responsibility
    end

    def _contain_nil?(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _contain_unlimited?(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _contain_equal_to?(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _contain_less_than?(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _contain_greater_than?(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _contain_intersection?(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _contain_union?(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def intersect?(rhs_dom)
      subclass_responsibility
    end

    def _intersect_nil?(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _intersect_unlimited?(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _intersect_equal_to?(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _intersect_less_than?(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _intersect_greater_than?(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def narrow(op, ope_dom)
      case op
      when Operator::EQ
        _narrow_by_eq(ope_dom)
      when Operator::NE
        _narrow_by_ne(ope_dom)
      when Operator::LT
        _narrow_by_lt(ope_dom)
      when Operator::GT
        _narrow_by_gt(ope_dom)
      when Operator::LE
        _narrow_by_le(ope_dom)
      when Operator::GE
        _narrow_by_ge(ope_dom)
      else
        __NOTREACHED__
      end
    end

    def _narrow_by_eq(rhs_dom, lhs_dom = self)
      subclass_responsibility
    end

    def _narrow_nil_by_eq(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _narrow_unlimited_by_eq(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _narrow_equal_to_by_eq(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _narrow_less_than_by_eq(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _narrow_greater_than_by_eq(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _narrow_by_ne(rhs_dom, lhs_dom = self)
      subclass_responsibility
    end

    def _narrow_nil_by_ne(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _narrow_unlimited_by_ne(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _narrow_equal_to_by_ne(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _narrow_less_than_by_ne(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _narrow_greater_than_by_ne(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _narrow_by_lt(rhs_dom, lhs_dom = self)
      subclass_responsibility
    end

    def _narrow_nil_by_lt(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _narrow_unlimited_by_lt(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _narrow_equal_to_by_lt(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _narrow_less_than_by_lt(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _narrow_greater_than_by_lt(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _narrow_by_gt(rhs_dom, lhs_dom = self)
      subclass_responsibility
    end

    def _narrow_nil_by_gt(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _narrow_unlimited_by_gt(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _narrow_equal_to_by_gt(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _narrow_less_than_by_gt(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _narrow_greater_than_by_gt(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _narrow_by_le(rhs_dom, lhs_dom = self)
      _narrow_by_lt(rhs_dom).union(_narrow_by_eq(rhs_dom))
    end

    def _narrow_by_ge(rhs_dom, lhs_dom = self)
      _narrow_by_gt(rhs_dom).union(_narrow_by_eq(rhs_dom))
    end

    def widen(op, ope_dom)
      case op
      when Operator::EQ
        _widen_by_eq(ope_dom)
      when Operator::NE
        _widen_by_ne(ope_dom)
      when Operator::LT
        _widen_by_lt(ope_dom)
      when Operator::GT
        _widen_by_gt(ope_dom)
      when Operator::LE
        _widen_by_le(ope_dom)
      when Operator::GE
        _widen_by_ge(ope_dom)
      else
        __NOTREACHED__
      end
    end

    def _widen_by_eq(rhs_dom, lhs_dom = self)
      lhs_dom.union(rhs_dom)
    end

    def _widen_by_ne(rhs_dom, lhs_dom = self)
      lhs_dom.union(rhs_dom.inversion)
    end

    def _widen_by_lt(rhs_dom, lhs_dom = self)
      lhs_dom.union(ValueDomain.of_unlimited(logical_shr?).narrow(
        Operator::LT, rhs_dom))
    end

    def _widen_by_gt(rhs_dom, lhs_dom = self)
      lhs_dom.union(ValueDomain.of_unlimited(logical_shr?).narrow(
        Operator::GT, rhs_dom))
    end

    def _widen_by_le(rhs_dom, lhs_dom = self)
      _widen_by_lt(rhs_dom).union(_widen_by_eq(rhs_dom))
    end

    def _widen_by_ge(rhs_dom, lhs_dom = self)
      _widen_by_gt(rhs_dom).union(_widen_by_eq(rhs_dom))
    end

    def inversion
      subclass_responsibility
    end

    def ~
      subclass_responsibility
    end

    def +@
      subclass_responsibility
    end

    def -@
      subclass_responsibility
    end

    def +(rhs_dom)
      subclass_responsibility
    end

    def _add_nil(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _add_unlimited(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _add_equal_to(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _add_less_than(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _add_greater_than(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def -(rhs_dom)
      self + -rhs_dom
    end

    def *(rhs_dom)
      # NOTE: Operator * cannot be defined by `LHS / (1.0 / RHS)'.
      #       Because `1.0 / RHS' will make NaN, when the value domain of the
      #       right hand side contains 0.
      subclass_responsibility
    end

    def _mul_nil(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _mul_unlimited(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _mul_equal_to(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _mul_less_than(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _mul_greater_than(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def /(rhs_dom)
      subclass_responsibility
    end

    def _div_nil(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _div_unlimited(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _div_equal_to(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _div_less_than(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _div_greater_than(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def %(rhs_dom)
      self - rhs_dom * (self / rhs_dom).coerce_to_integer
    end

    def &(rhs_dom)
      subclass_responsibility
    end

    def _and_nil(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _and_unlimited(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _and_equal_to(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _and_less_than(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _and_greater_than(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def |(rhs_dom)
      subclass_responsibility
    end

    def _or_nil(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _or_unlimited(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _or_equal_to(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _or_less_than(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _or_greater_than(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def ^(rhs_dom)
      subclass_responsibility
    end

    def _xor_nil(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _xor_unlimited(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _xor_equal_to(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _xor_less_than(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _xor_greater_than(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def <<(rhs_dom)
      subclass_responsibility
    end

    def _shl_nil(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _shl_unlimited(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _shl_equal_to(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _shl_less_than(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _shl_greater_than(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def >>(rhs_dom)
      subclass_responsibility
    end

    def _shr_nil(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _shr_unlimited(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _shr_equal_to(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _shr_less_than(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _shr_greater_than(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def !
      subclass_responsibility
    end

    def <(rhs_dom)
      subclass_responsibility
    end

    def _less_nil(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _less_unlimited(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _less_equal_to(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _less_less_than(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _less_greater_than(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def >(rhs_dom)
      rhs_dom < self
    end

    def ==(rhs_dom)
      # NOTE: Operator == cannot be defined by `!(LHS < RHS || LHS > RHS)'.
      #       When the value domain of the left hand side is (--<===>-<===>--),
      #       and the value domain of the right hand side is (-------|-------).
      #       `LHS < RHS' should make `true or false' because values in the
      #       left hand side may be less than or greater than the value in
      #       the right hand side.
      #       `LHS > RHS' should make `true or false', too.
      #       So, `!(LHS < RHS) && !(LHS > RHS)' will make `true or false'.
      subclass_responsibility
    end

    def _equal_nil(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _equal_unlimited(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _equal_equal_to(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _equal_less_than(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _equal_greater_than(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def !=(rhs_dom)
      # NOTE: Operator != cannot be defined by `!(LHS == RHS)'.
      #       When the value domain of the left hand side or the right hand
      #       side is NilValueDomain, `LHS == RHS' should make `false'.
      #       But `LHS != RHS' should make `false', too.
      subclass_responsibility
    end

    def _not_equal_nil(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _not_equal_unlimited(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _not_equal_equal_to(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _not_equal_less_than(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _not_equal_greater_than(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def <=(rhs_dom)
      (self < rhs_dom).logical_or(self == rhs_dom)
    end

    def >=(rhs_dom)
      (self > rhs_dom).logical_or(self == rhs_dom)
    end

    def logical_and(rhs_dom)
      # NOTE: Operator && cannot be defined as a method in Ruby.
      subclass_responsibility
    end

    def _logical_and_nil(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _logical_and_unlimited(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _logical_and_equal_to(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _logical_and_less_than(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _logical_and_greater_than(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def logical_or(rhs_dom)
      # NOTE: Operator || cannot be defined as a method in Ruby.
      subclass_responsibility
    end

    def _logical_or_nil(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _logical_or_unlimited(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _logical_or_equal_to(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _logical_or_less_than(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _logical_or_greater_than(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def intersection(rhs_dom)
      subclass_responsibility
    end

    def _intersection_nil(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _intersection_unlimited(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _intersection_equal_to(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _intersection_less_than(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _intersection_greater_than(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def union(rhs_dom)
      subclass_responsibility
    end

    def _union_nil(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _union_unlimited(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _union_equal_to(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _union_less_than(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _union_greater_than(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def coerce_to_integer
      subclass_responsibility
    end

    def coerce_to_real
      subclass_responsibility
    end

    def min_value
      subclass_responsibility
    end

    def max_value
      subclass_responsibility
    end

    def each_sample
      subclass_responsibility
    end

    def to_defined_domain
      subclass_responsibility
    end

    def <=>(rhs_dom)
      to_s <=> rhs_dom.to_s
    end

    def eql?(rhs_dom)
      to_s.eql?(rhs_dom.to_s)
    end

    def hash
      to_s.hash
    end
    memoize :hash

    def to_s
      subclass_responsibility
    end

    def complexity
      subclass_responsibility
    end

    private
    def right_shift(lhs_numeric, rhs_numeric)
      if logical_shr?
        lhs_numeric.to_i.logical_right_shift(rhs_numeric.to_i)
      else
        lhs_numeric.to_i.arithmetic_right_shift(rhs_numeric.to_i)
      end
    end

    def left_shift(lhs_numeric, rhs_numeric)
      lhs_numeric.to_i.left_shift(rhs_numeric.to_i)
    end
  end

  class NilValueDomain < ValueDomain
    def empty?
      true
    end

    def nan?
      false
    end

    def undefined?
      false
    end

    def ambiguous?
      false
    end

    def contain_value_domain?(rhs_dom)
      rhs_dom._contain_nil?(self)
    end

    def _contain_nil?(lhs_dom, rhs_dom = self)
      false
    end

    def _contain_unlimited?(lhs_dom, rhs_dom = self)
      true
    end

    def _contain_equal_to?(lhs_dom, rhs_dom = self)
      true
    end

    def _contain_less_than?(lhs_dom, rhs_dom = self)
      true
    end

    def _contain_greater_than?(lhs_dom, rhs_dom = self)
      true
    end

    def _contain_intersection?(lhs_dom, rhs_dom = self)
      true
    end

    def _contain_union?(lhs_dom, rhs_dom = self)
      true
    end

    def intersect?(rhs_dom)
      rhs_dom._intersect_nil?(self)
    end

    def _intersect_nil?(lhs_dom, rhs_dom = self)
      false
    end

    def _intersect_unlimited?(lhs_dom, rhs_dom = self)
      false
    end

    def _intersect_equal_to?(lhs_dom, rhs_dom = self)
      false
    end

    def _intersect_less_than?(lhs_dom, rhs_dom = self)
      false
    end

    def _intersect_greater_than?(lhs_dom, rhs_dom = self)
      false
    end

    def _narrow_by_eq(rhs_dom, lhs_dom = self)
      rhs_dom._narrow_nil_by_eq(lhs_dom)
    end

    def _narrow_nil_by_eq(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, narrowing any value-domain by `== NilValueDomain' makes
      #       NilValueDomain.
      lhs_dom
    end

    def _narrow_unlimited_by_eq(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, narrowing any value-domain by `== NilValueDomain' makes
      #       NilValueDomain.
      rhs_dom
    end

    def _narrow_equal_to_by_eq(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, narrowing any value-domain by `== NilValueDomain' makes
      #       NilValueDomain.
      rhs_dom
    end

    def _narrow_less_than_by_eq(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, narrowing any value-domain by `== NilValueDomain' makes
      #       NilValueDomain.
      rhs_dom
    end

    def _narrow_greater_than_by_eq(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, narrowing any value-domain by `== NilValueDomain' makes
      #       NilValueDomain.
      rhs_dom
    end

    def _narrow_by_ne(rhs_dom, lhs_dom = self)
      rhs_dom._narrow_nil_by_ne(lhs_dom)
    end

    def _narrow_nil_by_ne(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, narrowing any value-domain by `!= NilValueDomain' makes
      #       no effect to the target value-domain.
      lhs_dom
    end

    def _narrow_unlimited_by_ne(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, narrowing any value-domain by `!= NilValueDomain' makes
      #       no effect to the target value-domain.
      # NOTE: NaN is a subclass of UnlimitedValueDomain.
      #       UnlimitedValueDomain should be narrowed to be
      #       UnlimitedValueDomain, and NaN should be narrowed to be NaN.
      lhs_dom
    end

    def _narrow_equal_to_by_ne(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, narrowing any value-domain by `!= NilValueDomain' makes
      #       no effect to the target value-domain.
      lhs_dom
    end

    def _narrow_less_than_by_ne(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, narrowing any value-domain by `!= NilValueDomain' makes
      #       no effect to the target value-domain.
      lhs_dom
    end

    def _narrow_greater_than_by_ne(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, narrowing any value-domain by `!= NilValueDomain' makes
      #       no effect to the target value-domain.
      lhs_dom
    end

    def _narrow_by_lt(rhs_dom, lhs_dom = self)
      rhs_dom._narrow_nil_by_lt(lhs_dom)
    end

    def _narrow_nil_by_lt(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, narrowing any value-domain by `< NilValueDomain' makes
      #       no effect to the target value-domain.
      lhs_dom
    end

    def _narrow_unlimited_by_lt(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, narrowing any value-domain by `< NilValueDomain' makes
      #       no effect to the target value-domain.
      # NOTE: NaN is a subclass of UnlimitedValueDomain.
      #       UnlimitedValueDomain should be narrowed to be
      #       UnlimitedValueDomain, and NaN should be narrowed to be NaN.
      lhs_dom
    end

    def _narrow_equal_to_by_lt(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, narrowing any value-domain by `< NilValueDomain' makes
      #       no effect to the target value-domain.
      lhs_dom
    end

    def _narrow_less_than_by_lt(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, narrowing any value-domain by `< NilValueDomain' makes
      #       no effect to the target value-domain.
      lhs_dom
    end

    def _narrow_greater_than_by_lt(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, narrowing any value-domain by `< NilValueDomain' makes
      #       no effect to the target value-domain.
      lhs_dom
    end

    def _narrow_by_gt(rhs_dom, lhs_dom = self)
      rhs_dom._narrow_nil_by_gt(lhs_dom)
    end

    def _narrow_nil_by_gt(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, narrowing any value-domain by `> NilValueDomain' makes
      #       no effect to the target value-domain.
      lhs_dom
    end

    def _narrow_unlimited_by_gt(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, narrowing any value-domain by `> NilValueDomain' makes
      #       no effect to the target value-domain.
      # NOTE: NaN is a subclass of UnlimitedValueDomain.
      #       UnlimitedValueDomain should be narrowed to be
      #       UnlimitedValueDomain, and NaN should be narrowed to be NaN.
      lhs_dom
    end

    def _narrow_equal_to_by_gt(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, narrowing any value-domain by `> NilValueDomain' makes
      #       no effect to the target value-domain.
      lhs_dom
    end

    def _narrow_less_than_by_gt(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, narrowing any value-domain by `> NilValueDomain' makes
      #       no effect to the target value-domain.
      lhs_dom
    end

    def _narrow_greater_than_by_gt(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, narrowing any value-domain by `> NilValueDomain' makes
      #       no effect to the target value-domain.
      lhs_dom
    end

    def inversion
      ValueDomain.of_unlimited(logical_shr?)
    end

    def ~
      # NOTE: NilValueDomain contains no values.
      #       So, any arithmetic operation with NilValueDomain makes
      #       NilValueDomain.
      self
    end

    def +@
      # NOTE: NilValueDomain contains no values.
      #       So, any arithmetic operation with NilValueDomain makes
      #       NilValueDomain.
      self
    end

    def -@
      # NOTE: NilValueDomain contains no values.
      #       So, any arithmetic operation with NilValueDomain makes
      #       NilValueDomain.
      self
    end

    def +(rhs_dom)
      rhs_dom._add_nil(self)
    end

    def _add_nil(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any arithmetic operation with NilValueDomain makes
      #       NilValueDomain.
      lhs_dom
    end

    def _add_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any arithmetic operation with NilValueDomain makes
      #       NilValueDomain.
      # NOTE: NaN is a subclass of UnlimitedValueDomain.
      #       Arithmetic operation with UnlimitedValueDomain should make
      #       UnlimitedValueDomain, and with NaN should make NaN.
      rhs_dom
    end

    def _add_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any arithmetic operation with NilValueDomain makes
      #       NilValueDomain.
      rhs_dom
    end

    def _add_less_than(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any arithmetic operation with NilValueDomain makes
      #       NilValueDomain.
      rhs_dom
    end

    def _add_greater_than(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any arithmetic operation with NilValueDomain makes
      #       NilValueDomain.
      rhs_dom
    end

    def *(rhs_dom)
      rhs_dom._mul_nil(self)
    end

    def _mul_nil(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any arithmetic operation with NilValueDomain makes
      #       NilValueDomain.
      lhs_dom
    end

    def _mul_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any arithmetic operation with NilValueDomain makes
      #       NilValueDomain.
      # NOTE: NaN is a subclass of UnlimitedValueDomain.
      #       Arithmetic operation with UnlimitedValueDomain should make
      #       UnlimitedValueDomain, and with NaN should make NaN.
      rhs_dom
    end

    def _mul_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any arithmetic operation with NilValueDomain makes
      #       NilValueDomain.
      rhs_dom
    end

    def _mul_less_than(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any arithmetic operation with NilValueDomain makes
      #       NilValueDomain.
      rhs_dom
    end

    def _mul_greater_than(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any arithmetic operation with NilValueDomain makes
      #       NilValueDomain.
      rhs_dom
    end

    def /(rhs_dom)
      rhs_dom._div_nil(self)
    end

    def _div_nil(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any arithmetic operation with NilValueDomain makes
      #       NilValueDomain.
      lhs_dom
    end

    def _div_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any arithmetic operation with NilValueDomain makes
      #       NilValueDomain.
      rhs_dom
    end

    def _div_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any arithmetic operation with NilValueDomain makes
      #       NilValueDomain.
      rhs_dom
    end

    def _div_less_than(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any arithmetic operation with NilValueDomain makes
      #       NilValueDomain.
      rhs_dom
    end

    def _div_greater_than(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any arithmetic operation with NilValueDomain makes
      #       NilValueDomain.
      rhs_dom
    end

    def &(rhs_dom)
      rhs_dom.coerce_to_integer._add_nil(coerce_to_integer)
    end

    def _and_nil(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any arithmetic operation with NilValueDomain makes
      #       NilValueDomain.
      lhs_dom
    end

    def _and_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any arithmetic operation with NilValueDomain makes
      #       NilValueDomain.
      rhs_dom
    end

    def _and_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any arithmetic operation with NilValueDomain makes
      #       NilValueDomain.
      rhs_dom
    end

    def _and_less_than(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any arithmetic operation with NilValueDomain makes
      #       NilValueDomain.
      rhs_dom
    end

    def _and_greater_than(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any arithmetic operation with NilValueDomain makes
      #       NilValueDomain.
      rhs_dom
    end

    def |(rhs_dom)
      rhs_dom.coerce_to_integer._or_nil(coerce_to_integer)
    end

    def _or_nil(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any arithmetic operation with NilValueDomain makes
      #       NilValueDomain.
      lhs_dom
    end

    def _or_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any arithmetic operation with NilValueDomain makes
      #       NilValueDomain.
      rhs_dom
    end

    def _or_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any arithmetic operation with NilValueDomain makes
      #       NilValueDomain.
      rhs_dom
    end

    def _or_less_than(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any arithmetic operation with NilValueDomain makes
      #       NilValueDomain.
      rhs_dom
    end

    def _or_greater_than(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any arithmetic operation with NilValueDomain makes
      #       NilValueDomain.
      rhs_dom
    end

    def ^(rhs_dom)
      rhs_dom.coerce_to_integer._xor_nil(coerce_to_integer)
    end

    def _xor_nil(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any arithmetic operation with NilValueDomain makes
      #       NilValueDomain.
      lhs_dom
    end

    def _xor_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any arithmetic operation with NilValueDomain makes
      #       NilValueDomain.
      rhs_dom
    end

    def _xor_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any arithmetic operation with NilValueDomain makes
      #       NilValueDomain.
      rhs_dom
    end

    def _xor_less_than(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any arithmetic operation with NilValueDomain makes
      #       NilValueDomain.
      rhs_dom
    end

    def _xor_greater_than(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any arithmetic operation with NilValueDomain makes
      #       NilValueDomain.
      rhs_dom
    end

    def <<(rhs_dom)
      rhs_dom.coerce_to_integer._shl_nil(coerce_to_integer)
    end

    def _shl_nil(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any arithmetic operation with NilValueDomain makes
      #       NilValueDomain.
      lhs_dom
    end

    def _shl_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any arithmetic operation with NilValueDomain makes
      #       NilValueDomain.
      rhs_dom
    end

    def _shl_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any arithmetic operation with NilValueDomain makes
      #       NilValueDomain.
      rhs_dom
    end

    def _shl_less_than(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any arithmetic operation with NilValueDomain makes
      #       NilValueDomain.
      rhs_dom
    end

    def _shl_greater_than(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any arithmetic operation with NilValueDomain makes
      #       NilValueDomain.
      rhs_dom
    end

    def >>(rhs_dom)
      rhs_dom.coerce_to_integer._shr_nil(coerce_to_integer)
    end

    def _shr_nil(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any arithmetic operation with NilValueDomain makes
      #       NilValueDomain.
      lhs_dom
    end

    def _shr_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any arithmetic operation with NilValueDomain makes
      #       NilValueDomain.
      rhs_dom
    end

    def _shr_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any arithmetic operation with NilValueDomain makes
      #       NilValueDomain.
      lhs_dom
    end

    def _shr_less_than(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any arithmetic operation with NilValueDomain makes
      #       NilValueDomain.
      rhs_dom
    end

    def _shr_greater_than(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any arithmetic operation with NilValueDomain makes
      #       NilValueDomain.
      rhs_dom
    end

    def !
      # NOTE: NilValueDomain contains no values.
      #       So, logical negation of NilValueDomain makes no sense.
      ValueDomain.of_nil(logical_shr?)
    end

    def <(rhs_dom)
      rhs_dom._less_nil(self)
    end

    def _less_nil(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any comparison with NilValueDomain makes no sense.
      ValueDomain.of_nil(logical_shr?)
    end

    def _less_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any comparison with NilValueDomain makes no sense.
      ValueDomain.of_nil(logical_shr?)
    end

    def _less_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any comparison with NilValueDomain makes no sense.
      ValueDomain.of_nil(logical_shr?)
    end

    def _less_less_than(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any comparison with NilValueDomain makes no sense.
      ValueDomain.of_nil(logical_shr?)
    end

    def _less_greater_than(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any comparison with NilValueDomain makes no sense.
      ValueDomain.of_nil(logical_shr?)
    end

    def ==(rhs_dom)
      rhs_dom._equal_nil(self)
    end

    def _equal_nil(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any comparison with NilValueDomain makes no sense.
      ValueDomain.of_nil(logical_shr?)
    end

    def _equal_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any comparison with NilValueDomain makes no sense.
      ValueDomain.of_nil(logical_shr?)
    end

    def _equal_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any comparison with NilValueDomain makes no sense.
      ValueDomain.of_nil(logical_shr?)
    end

    def _equal_less_than(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any comparison with NilValueDomain makes no sense.
      ValueDomain.of_nil(logical_shr?)
    end

    def _equal_greater_than(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any comparison with NilValueDomain makes no sense.
      ValueDomain.of_nil(logical_shr?)
    end

    def !=(rhs_dom)
      rhs_dom._not_equal_nil(self)
    end

    def _not_equal_nil(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any comparison with NilValueDomain makes no sense.
      ValueDomain.of_nil(logical_shr?)
    end

    def _not_equal_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any comparison with NilValueDomain makes no sense.
      ValueDomain.of_nil(logical_shr?)
    end

    def _not_equal_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any comparison with NilValueDomain makes no sense.
      ValueDomain.of_nil(logical_shr?)
    end

    def _not_equal_less_than(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any comparison with NilValueDomain makes no sense.
      ValueDomain.of_nil(logical_shr?)
    end

    def _not_equal_greater_than(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any comparison with NilValueDomain makes no sense.
      ValueDomain.of_nil(logical_shr?)
    end

    def logical_and(rhs_dom)
      rhs_dom._logical_and_nil(self)
    end

    def _logical_and_nil(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       If the value-domain of the other side of NilValueDomain contains
      #       only zero value, the logical AND makes false.
      ValueDomain.of_unlimited(logical_shr?)
    end

    def _logical_and_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       If the value-domain of the other side of NilValueDomain contains
      #       only zero value, the logical AND makes false.
      ValueDomain.of_unlimited(logical_shr?)
    end

    def _logical_and_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       If the value-domain of the other side of NilValueDomain contains
      #       only zero value, the logical AND makes false.
      if lhs_dom.value == 0
        ValueDomain.of_false(logical_shr?)
      else
        ValueDomain.of_unlimited(logical_shr?)
      end
    end

    def _logical_and_less_than(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       If the value-domain of the other side of NilValueDomain contains
      #       only zero value, the logical AND makes false.
      ValueDomain.of_unlimited(logical_shr?)
    end

    def _logical_and_greater_than(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       If the value-domain of the other side of NilValueDomain contains
      #       only zero value, the logical AND makes false.
      ValueDomain.of_unlimited(logical_shr?)
    end

    def logical_or(rhs_dom)
      rhs_dom._logical_or_nil(self)
    end

    def _logical_or_nil(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       If the value-domain of the other side of NilValueDomain contains
      #       only non-zero values, the logical OR makes true.
      ValueDomain.of_unlimited(logical_shr?)
    end

    def _logical_or_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       If the value-domain of the other side of NilValueDomain contains
      #       only non-zero values, the logical OR makes true.
      ValueDomain.of_unlimited(logical_shr?)
    end

    def _logical_or_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       If the value-domain of the other side of NilValueDomain contains
      #       only non-zero values, the logical OR makes true.
      if lhs_dom.value == 0
        ValueDomain.of_unlimited(logical_shr?)
      else
        ValueDomain.of_true(logical_shr?)
      end
    end

    def _logical_or_less_than(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       If the value-domain of the other side of NilValueDomain contains
      #       only non-zero values, the logical OR makes true.
      if lhs_dom.max_value >= 0
        ValueDomain.of_unlimited(logical_shr?)
      else
        ValueDomain.of_true(logical_shr?)
      end
    end

    def _logical_or_greater_than(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       If the value-domain of the other side of NilValueDomain contains
      #       only non-zero values, the logical OR makes true.
      if lhs_dom.min_value <= 0
        ValueDomain.of_unlimited(logical_shr?)
      else
        ValueDomain.of_true(logical_shr?)
      end
    end

    def intersection(rhs_dom)
      rhs_dom._intersection_nil(self)
    end

    def _intersection_nil(lhs_dom, rhs_dom = self)
      rhs_dom
    end

    def _intersection_unlimited(lhs_dom, rhs_dom = self)
      rhs_dom
    end

    def _intersection_equal_to(lhs_dom, rhs_dom = self)
      rhs_dom
    end

    def _intersection_less_than(lhs_dom, rhs_dom = self)
      rhs_dom
    end

    def _intersection_greater_than(lhs_dom, rhs_dom = self)
      rhs_dom
    end

    def union(rhs_dom)
      rhs_dom._union_nil(self)
    end

    def _union_nil(lhs_dom, rhs_dom = self)
      lhs_dom
    end

    def _union_unlimited(lhs_dom, rhs_dom = self)
      lhs_dom
    end

    def _union_equal_to(lhs_dom, rhs_dom = self)
      lhs_dom
    end

    def _union_less_than(lhs_dom, rhs_dom = self)
      lhs_dom
    end

    def _union_greater_than(lhs_dom, rhs_dom = self)
      lhs_dom
    end

    def coerce_to_integer
      self
    end

    def coerce_to_real
      self
    end

    def min_value
      nil
    end

    def max_value
      nil
    end

    def each_sample
      if block_given?
        self
      else
        to_enum(:each_sample)
      end
    end

    def to_defined_domain
      self
    end

    def to_s
      "(== Nil)"
    end
    memoize :to_s

    def complexity
      1
    end
  end

  class UnlimitedValueDomain < ValueDomain
    def empty?
      false
    end

    def nan?
      false
    end

    def undefined?
      false
    end

    def ambiguous?
      false
    end

    def contain_value_domain?(rhs_dom)
      rhs_dom._contain_unlimited?(self)
    end

    def _contain_nil?(lhs_dom, rhs_dom = self)
      false
    end

    def _contain_unlimited?(lhs_dom, rhs_dom = self)
      true
    end

    def _contain_equal_to?(lhs_dom, rhs_dom = self)
      false
    end

    def _contain_less_than?(lhs_dom, rhs_dom = self)
      false
    end

    def _contain_greater_than?(lhs_dom, rhs_dom = self)
      false
    end

    def _contain_intersection?(lhs_dom, rhs_dom = self)
      false
    end

    def _contain_union?(lhs_dom, rhs_dom = self)
      false
    end

    def intersect?(rhs_dom)
      rhs_dom._intersect_unlimited?(self)
    end

    def _intersect_nil?(lhs_dom, rhs_dom = self)
      # NOTE: `LHS intersect? RHS' equals to `RHS intersect? LHS'.
      #       This method invokes NilValueDomain#_intersect_unlimited?.
      rhs_dom.intersect?(lhs_dom)
    end

    def _intersect_unlimited?(lhs_dom, rhs_dom = self)
      true
    end

    def _intersect_equal_to?(lhs_dom, rhs_dom = self)
      true
    end

    def _intersect_less_than?(lhs_dom, rhs_dom = self)
      true
    end

    def _intersect_greater_than?(lhs_dom, rhs_dom = self)
      true
    end

    def _narrow_by_eq(rhs_dom, lhs_dom = self)
      rhs_dom._narrow_unlimited_by_eq(lhs_dom)
    end

    def _narrow_nil_by_eq(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, narrowing any value-domain by `== UnlimitedValueDomain' makes
      #       no effect to the target value-domain.
      lhs_dom
    end

    def _narrow_unlimited_by_eq(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, narrowing any value-domain by `== UnlimitedValueDomain' makes
      #       no effect to the target value-domain.
      # NOTE: NaN is a subclass of UnlimitedValueDomain.
      #       UnlimitedValueDomain should be narrowed to be
      #       UnlimitedValueDomain, and NaN should be narrowed to be NaN.
      lhs_dom
    end

    def _narrow_equal_to_by_eq(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, narrowing any value-domain by `== UnlimitedValueDomain' makes
      #       no effect to the target value-domain.
      lhs_dom
    end

    def _narrow_less_than_by_eq(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, narrowing any value-domain by `== UnlimitedValueDomain' makes
      #       no effect to the target value-domain.
      lhs_dom
    end

    def _narrow_greater_than_by_eq(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, narrowing any value-domain by `== UnlimitedValueDomain' makes
      #       no effect to the target value-domain.
      lhs_dom
    end

    def _narrow_by_ne(rhs_dom, lhs_dom = self)
      rhs_dom._narrow_unlimited_by_ne(lhs_dom)
    end

    def _narrow_nil_by_ne(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, narrowing any value-domain by `!= UnlimitedValueDomain' makes
      #       NilValueDomain.
      lhs_dom
    end

    def _narrow_unlimited_by_ne(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, narrowing any value-domain by `!= UnlimitedValueDomain' makes
      #       NilValueDomain.
      # NOTE: NaN is a subclass of UnlimitedValueDomain.
      #       UnlimitedValueDomain should be narrowed to be
      #       UnlimitedValueDomain, and NaN should be narrowed to be NaN.
      ValueDomain.of_nil(logical_shr?)
    end

    def _narrow_equal_to_by_ne(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, narrowing any value-domain by `!= UnlimitedValueDomain' makes
      #       NilValueDomain.
      ValueDomain.of_nil(logical_shr?)
    end

    def _narrow_less_than_by_ne(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, narrowing any value-domain by `!= UnlimitedValueDomain' makes
      #       NilValueDomain.
      ValueDomain.of_nil(logical_shr?)
    end

    def _narrow_greater_than_by_ne(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, narrowing any value-domain by `!= UnlimitedValueDomain' makes
      #       NilValueDomain.
      ValueDomain.of_nil(logical_shr?)
    end

    def _narrow_by_lt(rhs_dom, lhs_dom = self)
      rhs_dom._narrow_unlimited_by_lt(lhs_dom)
    end

    def _narrow_nil_by_lt(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, narrowing any value-domain by `< UnlimitedValueDomain' makes
      #       NilValueDomain.
      lhs_dom
    end

    def _narrow_unlimited_by_lt(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, narrowing any value-domain by `< UnlimitedValueDomain' makes
      #       NilValueDomain.
      # NOTE: NaN is a subclass of UnlimitedValueDomain.
      #       UnlimitedValueDomain should be narrowed to be
      #       UnlimitedValueDomain, and NaN should be narrowed to be NaN.
      ValueDomain.of_nil(logical_shr?)
    end

    def _narrow_equal_to_by_lt(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, narrowing any value-domain by `< UnlimitedValueDomain' makes
      #       NilValueDomain.
      ValueDomain.of_nil(logical_shr?)
    end

    def _narrow_less_than_by_lt(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, narrowing any value-domain by `< UnlimitedValueDomain' makes
      #       NilValueDomain.
      ValueDomain.of_nil(logical_shr?)
    end

    def _narrow_greater_than_by_lt(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, narrowing any value-domain by `< UnlimitedValueDomain' makes
      #       NilValueDomain.
      ValueDomain.of_nil(logical_shr?)
    end

    def _narrow_by_gt(rhs_dom, lhs_dom = self)
      rhs_dom._narrow_unlimited_by_gt(lhs_dom)
    end

    def _narrow_nil_by_gt(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, narrowing any value-domain by `> UnlimitedValueDomain' makes
      #       NilValueDomain.
      lhs_dom
    end

    def _narrow_unlimited_by_gt(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, narrowing any value-domain by `> UnlimitedValueDomain' makes
      #       NilValueDomain.
      # NOTE: NaN is a subclass of UnlimitedValueDomain.
      #       UnlimitedValueDomain should be narrowed to be
      #       UnlimitedValueDomain, and NaN should be narrowed to be NaN.
      ValueDomain.of_nil(logical_shr?)
    end

    def _narrow_equal_to_by_gt(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, narrowing any value-domain by `> UnlimitedValueDomain' makes
      #       NilValueDomain.
      ValueDomain.of_nil(logical_shr?)
    end

    def _narrow_less_than_by_gt(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, narrowing any value-domain by `> UnlimitedValueDomain' makes
      #       NilValueDomain.
      ValueDomain.of_nil(logical_shr?)
    end

    def _narrow_greater_than_by_gt(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, narrowing any value-domain by `> UnlimitedValueDomain' makes
      #       NilValueDomain.
      ValueDomain.of_nil(logical_shr?)
    end

    def inversion
      ValueDomain.of_nil(logical_shr?)
    end

    def ~
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, this arithmetic operation with UnlimitedValueDomain makes
      #       UnlimitedValueDomain.
      self
    end

    def +@
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, this arithmetic operation with UnlimitedValueDomain makes
      #       UnlimitedValueDomain.
      self
    end

    def -@
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, this arithmetic operation with UnlimitedValueDomain makes
      #       UnlimitedValueDomain.
      self
    end

    def +(rhs_dom)
      rhs_dom._add_unlimited(self)
    end

    def _add_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS + RHS' equals to `RHS + LHS'.
      #       This method invokes NilValueDomain#_add_unlimited.
      rhs_dom + lhs_dom
    end

    def _add_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, this arithmetic operation with UnlimitedValueDomain makes
      #       UnlimitedValueDomain.
      # NOTE: NaN is a subclass of UnlimitedValueDomain.
      #       Arithmetic operation with UnlimitedValueDomain should make
      #       UnlimitedValueDomain, and with NaN should make NaN.
      lhs_dom.nan? ? lhs_dom : rhs_dom
    end

    def _add_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, this arithmetic operation with UnlimitedValueDomain makes
      #       UnlimitedValueDomain.
      rhs_dom
    end

    def _add_less_than(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, this arithmetic operation with UnlimitedValueDomain makes
      #       UnlimitedValueDomain.
      rhs_dom
    end

    def _add_greater_than(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, this arithmetic operation with UnlimitedValueDomain makes
      #       UnlimitedValueDomain.
      rhs_dom
    end

    def *(rhs_dom)
      rhs_dom._mul_unlimited(self)
    end

    def _mul_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS * RHS' equals to `RHS * LHS'.
      #       This method invokes NilValueDomain#_mul_unlimited.
      rhs_dom * lhs_dom
    end

    def _mul_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, this arithmetic operation with UnlimitedValueDomain makes
      #       UnlimitedValueDomain.
      # NOTE: NaN is a subclass of UnlimitedValueDomain.
      #       Arithmetic operation with UnlimitedValueDomain should make
      #       UnlimitedValueDomain, and with NaN should make NaN.
      lhs_dom.nan? ? lhs_dom : rhs_dom
    end

    def _mul_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, this arithmetic operation with UnlimitedValueDomain makes
      #       UnlimitedValueDomain.
      rhs_dom
    end

    def _mul_less_than(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, this arithmetic operation with UnlimitedValueDomain makes
      #       UnlimitedValueDomain.
      rhs_dom
    end

    def _mul_greater_than(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, this arithmetic operation with UnlimitedValueDomain makes
      #       UnlimitedValueDomain.
      rhs_dom
    end

    def /(rhs_dom)
      rhs_dom._div_unlimited(self)
    end

    def _div_nil(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any arithmetic operation with NilValueDomain makes
      #       NilValueDomain.
      lhs_dom
    end

    def _div_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, this arithmetic operation with UnlimitedValueDomain makes
      #       UnlimitedValueDomain.
      # NOTE: NaN is a subclass of UnlimitedValueDomain.
      #       Arithmetic operation with UnlimitedValueDomain should make
      #       UnlimitedValueDomain, and with NaN should make NaN.
      lhs_dom.nan? ? lhs_dom : rhs_dom
    end

    def _div_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, this arithmetic operation with UnlimitedValueDomain makes
      #       UnlimitedValueDomain.
      rhs_dom
    end

    def _div_less_than(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, this arithmetic operation with UnlimitedValueDomain makes
      #       UnlimitedValueDomain.
      rhs_dom
    end

    def _div_greater_than(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, this arithmetic operation with UnlimitedValueDomain makes
      #       UnlimitedValueDomain.
      rhs_dom
    end

    def &(rhs_dom)
      rhs_dom.coerce_to_integer._and_unlimited(coerce_to_integer)
    end

    def _and_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS & RHS' equals to `RHS & LHS'.
      #       This method invokes NilValueDomain#_and_unlimited.
      rhs_dom & lhs_dom
    end

    def _and_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, this arithmetic operation with UnlimitedValueDomain makes
      #       UnlimitedValueDomain.
      # NOTE: NaN is a subclass of UnlimitedValueDomain.
      #       Arithmetic operation with UnlimitedValueDomain should make
      #       UnlimitedValueDomain, and with NaN should make NaN.
      lhs_dom.nan? ? lhs_dom : rhs_dom
    end

    def _and_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, this arithmetic operation with UnlimitedValueDomain makes
      #       UnlimitedValueDomain.
      rhs_dom
    end

    def _and_less_than(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, this arithmetic operation with UnlimitedValueDomain makes
      #       UnlimitedValueDomain.
      rhs_dom
    end

    def _and_greater_than(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, this arithmetic operation with UnlimitedValueDomain makes
      #       UnlimitedValueDomain.
      rhs_dom
    end

    def |(rhs_dom)
      rhs_dom.coerce_to_integer._or_unlimited(coerce_to_integer)
    end

    def _or_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS | RHS' equals to `RHS | LHS'.
      #       This method invokes NilValueDomain#_or_unlimited.
      rhs_dom | lhs_dom
    end

    def _or_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, this arithmetic operation with UnlimitedValueDomain makes
      #       UnlimitedValueDomain.
      # NOTE: NaN is a subclass of UnlimitedValueDomain.
      #       Arithmetic operation with UnlimitedValueDomain should make
      #       UnlimitedValueDomain, and with NaN should make NaN.
      lhs_dom.nan? ? lhs_dom : rhs_dom
    end

    def _or_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, this arithmetic operation with UnlimitedValueDomain makes
      #       UnlimitedValueDomain.
      rhs_dom
    end

    def _or_less_than(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, this arithmetic operation with UnlimitedValueDomain makes
      #       UnlimitedValueDomain.
      rhs_dom
    end

    def _or_greater_than(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, this arithmetic operation with UnlimitedValueDomain makes
      #       UnlimitedValueDomain.
      rhs_dom
    end

    def ^(rhs_dom)
      rhs_dom.coerce_to_integer._xor_unlimited(coerce_to_integer)
    end

    def _xor_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS ^ RHS' equals to `RHS ^ LHS'.
      #       This method invokes NilValueDomain#_or_unlimited.
      rhs_dom ^ lhs_dom
    end

    def _xor_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, this arithmetic operation with UnlimitedValueDomain makes
      #       UnlimitedValueDomain.
      # NOTE: NaN is a subclass of UnlimitedValueDomain.
      #       Arithmetic operation with UnlimitedValueDomain should make
      #       UnlimitedValueDomain, and with NaN should make NaN.
      lhs_dom.nan? ? lhs_dom : rhs_dom
    end

    def _xor_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, this arithmetic operation with UnlimitedValueDomain makes
      #       UnlimitedValueDomain.
      rhs_dom
    end

    def _xor_less_than(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, this arithmetic operation with UnlimitedValueDomain makes
      #       UnlimitedValueDomain.
      rhs_dom
    end

    def _xor_greater_than(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, this arithmetic operation with UnlimitedValueDomain makes
      #       UnlimitedValueDomain.
      rhs_dom
    end

    def <<(rhs_dom)
      rhs_dom.coerce_to_integer._shl_unlimited(coerce_to_integer)
    end

    def _shl_nil(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any arithmetic operation with NilValueDomain makes
      #       NilValueDomain.
      lhs_dom
    end

    def _shl_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, this arithmetic operation with UnlimitedValueDomain makes
      #       UnlimitedValueDomain because of the bit-overflow.
      # NOTE: NaN is a subclass of UnlimitedValueDomain.
      #       Arithmetic operation with UnlimitedValueDomain should make
      #       UnlimitedValueDomain, and with NaN should make NaN.
      lhs_dom.nan? ? lhs_dom : rhs_dom
    end

    def _shl_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, this arithmetic operation with UnlimitedValueDomain makes
      #       UnlimitedValueDomain because of the bit-overflow.
      rhs_dom
    end

    def _shl_less_than(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, this arithmetic operation with UnlimitedValueDomain makes
      #       UnlimitedValueDomain because of the bit-overflow.
      rhs_dom
    end

    def _shl_greater_than(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, this arithmetic operation with UnlimitedValueDomain makes
      #       UnlimitedValueDomain because of the bit-overflow.
      rhs_dom
    end

    def >>(rhs_dom)
      rhs_dom.coerce_to_integer._shr_unlimited(coerce_to_integer)
    end

    def _shr_nil(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any arithmetic operation with NilValueDomain makes
      #       NilValueDomain.
      lhs_dom
    end

    def _shr_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, this arithmetic operation with UnlimitedValueDomain makes
      #       UnlimitedValueDomain because of the bit-underflow.
      # NOTE: NaN is a subclass of UnlimitedValueDomain.
      #       Arithmetic operation with UnlimitedValueDomain should make
      #       UnlimitedValueDomain, and with NaN should make NaN.
      lhs_dom.nan? ? lhs_dom : rhs_dom
    end

    def _shr_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, this arithmetic operation with UnlimitedValueDomain makes
      #       UnlimitedValueDomain because of the bit-underflow.
      rhs_dom
    end

    def _shr_less_than(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, this arithmetic operation with UnlimitedValueDomain makes
      #       UnlimitedValueDomain because of the bit-underflow.
      rhs_dom
    end

    def _shr_greater_than(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, this arithmetic operation with UnlimitedValueDomain makes
      #       UnlimitedValueDomain because of the bit-underflow.
      rhs_dom
    end

    def !
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, logical negation of UnlimitedValueDomain makes
      #       UnlimitedValueDomain.
      ValueDomain.of_unlimited(logical_shr?)
    end

    def <(rhs_dom)
      rhs_dom._less_unlimited(self)
    end

    def _less_nil(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any comparison with NilValueDomain makes no sense.
      ValueDomain.of_nil(logical_shr?)
    end

    def _less_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, any comparison with UnlimitedValueDomain makes
      #       UnlimitedValueDomain.
      ValueDomain.of_unlimited(logical_shr?)
    end

    def _less_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, any comparison with UnlimitedValueDomain makes
      #       UnlimitedValueDomain.
      ValueDomain.of_unlimited(logical_shr?)
    end

    def _less_less_than(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, any comparison with UnlimitedValueDomain makes
      #       UnlimitedValueDomain.
      ValueDomain.of_unlimited(logical_shr?)
    end

    def _less_greater_than(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, any comparison with UnlimitedValueDomain makes
      #       UnlimitedValueDomain.
      ValueDomain.of_unlimited(logical_shr?)
    end

    def ==(rhs_dom)
      rhs_dom._equal_unlimited(self)
    end

    def _equal_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS == RHS' equals to `RHS == LHS'.
      #       This method invokes NilValueDomain#_equal_unlimited.
      rhs_dom == lhs_dom
    end

    def _equal_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, any comparison with UnlimitedValueDomain makes
      #       UnlimitedValueDomain.
      ValueDomain.of_unlimited(logical_shr?)
    end

    def _equal_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, any comparison with UnlimitedValueDomain makes
      #       UnlimitedValueDomain.
      ValueDomain.of_unlimited(logical_shr?)
    end

    def _equal_less_than(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, any comparison with UnlimitedValueDomain makes
      #       UnlimitedValueDomain.
      ValueDomain.of_unlimited(logical_shr?)
    end

    def _equal_greater_than(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, any comparison with UnlimitedValueDomain makes
      #       UnlimitedValueDomain.
      ValueDomain.of_unlimited(logical_shr?)
    end

    def !=(rhs_dom)
      rhs_dom._not_equal_unlimited(self)
    end

    def _not_equal_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS != RHS' equals to `RHS != LHS'.
      #       This method invokes NilValueDomain#_not_equal_nil.
      rhs_dom != lhs_dom
    end

    def _not_equal_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, any comparison with UnlimitedValueDomain makes
      #       UnlimitedValueDomain.
      ValueDomain.of_unlimited(logical_shr?)
    end

    def _not_equal_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, any comparison with UnlimitedValueDomain makes
      #       UnlimitedValueDomain.
      ValueDomain.of_unlimited(logical_shr?)
    end

    def _not_equal_less_than(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, any comparison with UnlimitedValueDomain makes
      #       UnlimitedValueDomain.
      ValueDomain.of_unlimited(logical_shr?)
    end

    def _not_equal_greater_than(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, any comparison with UnlimitedValueDomain makes
      #       UnlimitedValueDomain.
      ValueDomain.of_unlimited(logical_shr?)
    end

    def logical_and(rhs_dom)
      rhs_dom._logical_and_unlimited(self)
    end

    def _logical_and_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS && RHS' equals to `RHS && LHS'.
      #       This method invokes NilValueDomain#_logical_and_unlimited.
      rhs_dom.logical_and(lhs_dom)
    end

    def _logical_and_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       If the value-domain of the other side of UnlimitedValueDomain
      #       contains only zero value, the logical AND makes false.
      ValueDomain.of_unlimited(logical_shr?)
    end

    def _logical_and_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       If the value-domain of the other side of UnlimitedValueDomain
      #       contains only zero value, the logical AND makes false.
      if lhs_dom.value == 0
        ValueDomain.of_false(logical_shr?)
      else
        ValueDomain.of_unlimited(logical_shr?)
      end
    end

    def _logical_and_less_than(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       If the value-domain of the other side of UnlimitedValueDomain
      #       contains only zero value, the logical AND makes false.
      ValueDomain.of_unlimited(logical_shr?)
    end

    def _logical_and_greater_than(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       If the value-domain of the other side of UnlimitedValueDomain
      #       contains only zero value, the logical AND makes false.
      ValueDomain.of_unlimited(logical_shr?)
    end

    def logical_or(rhs_dom)
      rhs_dom._logical_or_unlimited(self)
    end

    def _logical_or_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS || RHS' equals to `RHS || LHS'.
      #       This method invokes NilValueDomain#_logical_or_unlimited.
      rhs_dom.logical_or(lhs_dom)
    end

    def _logical_or_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       If the value-domain of the other side of UnlimitedValueDomain
      #       contains only non-zero values, the logical OR makes true.
      ValueDomain.of_unlimited(logical_shr?)
    end

    def _logical_or_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       If the value-domain of the other side of UnlimitedValueDomain
      #       contains only non-zero values, the logical OR makes true.
      if lhs_dom.value == 0
        ValueDomain.of_unlimited(logical_shr?)
      else
        ValueDomain.of_true(logical_shr?)
      end
    end

    def _logical_or_less_than(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       If the value-domain of the other side of UnlimitedValueDomain
      #       contains only non-zero values, the logical OR makes true.
      if lhs_dom.max_value >= 0
        ValueDomain.of_unlimited(logical_shr?)
      else
        ValueDomain.of_true(logical_shr?)
      end
    end

    def _logical_or_greater_than(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       If the value-domain of the other side of UnlimitedValueDomain
      #       contains only non-zero values, the logical OR makes true.
      if lhs_dom.min_value <= 0
        ValueDomain.of_unlimited(logical_shr?)
      else
        ValueDomain.of_true(logical_shr?)
      end
    end

    def intersection(rhs_dom)
      rhs_dom._intersection_unlimited(self)
    end

    def _intersection_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS intersection RHS' equals to `RHS intersection LHS'.
      #       This method invokes NilValueDomain#_intersection_unlimited.
      rhs_dom.intersection(lhs_dom)
    end

    def _intersection_unlimited(lhs_dom, rhs_dom = self)
      lhs_dom
    end

    def _intersection_equal_to(lhs_dom, rhs_dom = self)
      lhs_dom
    end

    def _intersection_less_than(lhs_dom, rhs_dom = self)
      lhs_dom
    end

    def _intersection_greater_than(lhs_dom, rhs_dom = self)
      lhs_dom
    end

    def union(rhs_dom)
      rhs_dom._union_unlimited(self)
    end

    def _union_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS union RHS' equals to `RHS union LHS'.
      #       This method invokes NilValueDomain#_union_unlimited.
      rhs_dom.union(lhs_dom)
    end

    def _union_unlimited(lhs_dom, rhs_dom = self)
      rhs_dom
    end

    def _union_equal_to(lhs_dom, rhs_dom = self)
      rhs_dom
    end

    def _union_less_than(lhs_dom, rhs_dom = self)
      rhs_dom
    end

    def _union_greater_than(lhs_dom, rhs_dom = self)
      rhs_dom
    end

    def coerce_to_integer
      self
    end

    def coerce_to_real
      self
    end

    def min_value
      nil
    end

    def max_value
      nil
    end

    def each_sample
      if block_given?
        yield(0)
        self
      else
        to_enum(:each_sample)
      end
    end

    def to_defined_domain
      self
    end

    def to_s
      "(== Unlimited)"
    end
    memoize :to_s

    def complexity
      1
    end
  end

  # NOTE: To increase the coverage of the analysis, NaN should not be derived
  #       from NilValueDomain but UnlimitedValueDomain.
  class NaN < UnlimitedValueDomain
    def nan?
      true
    end

    def to_s
      "(== NaN)"
    end
    memoize :to_s
  end

  class EqualToValueDomain < ValueDomain
    def initialize(val, logical_shr)
      super(logical_shr)
      if val
        @value = val
      else
        raise ArgumentError, "equal to nil?"
      end
    end

    attr_reader :value

    def empty?
      false
    end

    def nan?
      false
    end

    def undefined?
      false
    end

    def ambiguous?
      false
    end

    def contain_value_domain?(rhs_dom)
      rhs_dom._contain_equal_to?(self)
    end

    def _contain_nil?(lhs_dom, rhs_dom = self)
      false
    end

    def _contain_unlimited?(lhs_dom, rhs_dom = self)
      true
    end

    def _contain_equal_to?(lhs_dom, rhs_dom = self)
      lhs_dom.value == rhs_dom.value
    end

    def _contain_less_than?(lhs_dom, rhs_dom = self)
      lhs_dom.max_value >= rhs_dom.value
    end

    def _contain_greater_than?(lhs_dom, rhs_dom = self)
      lhs_dom.min_value <= rhs_dom.value
    end

    def _contain_intersection?(lhs_dom, rhs_dom = self)
      lhs_dom.domain_pair.all? { |lhs| lhs.contain_value_domain?(rhs_dom) }
    end

    def _contain_union?(lhs_dom, rhs_dom = self)
      lhs_dom.domain_pair.any? { |lhs| lhs.contain_value_domain?(rhs_dom) }
    end

    def intersect?(rhs_dom)
      rhs_dom._intersect_equal_to?(self)
    end

    def _intersect_nil?(lhs_dom, rhs_dom = self)
      # NOTE: `LHS intersect? RHS' equals to `RHS intersect? LHS'.
      #       This method invokes NilValueDomain#_intersect_equal_to?.
      rhs_dom.intersect?(lhs_dom)
    end

    def _intersect_unlimited?(lhs_dom, rhs_dom = self)
      # NOTE: `LHS intersect? RHS' equals to `RHS intersect? LHS'.
      #       This method invokes
      #       UnlimitedValueDomain#_intersect_equal_to?.
      rhs_dom.intersect?(lhs_dom)
    end

    def _intersect_equal_to?(lhs_dom, rhs_dom = self)
      lhs_dom.value == rhs_dom.value
    end

    def _intersect_less_than?(lhs_dom, rhs_dom = self)
      lhs_dom.max_value >= rhs_dom.value
    end

    def _intersect_greater_than?(lhs_dom, rhs_dom = self)
      lhs_dom.min_value <= rhs_dom.value
    end

    def _narrow_by_eq(rhs_dom, lhs_dom = self)
      rhs_dom._narrow_equal_to_by_eq(lhs_dom)
    end

    def _narrow_nil_by_eq(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, narrowing NilValueDomain by anything makes no effect to the
      #       target value-domain.
      lhs_dom
    end

    def _narrow_unlimited_by_eq(lhs_dom, rhs_dom = self)
      rhs_dom
    end

    def _narrow_equal_to_by_eq(lhs_dom, rhs_dom = self)
      if lhs_dom.value == rhs_dom.value
        # NOTE: Narrowing `------|------' by `== ------|-----' makes
        #       `------|------'.
        lhs_dom
      else
        # NOTE: Narrowing `---|---------' by `== --------|---' makes
        #       `-------------'.
        ValueDomain.of_nil(logical_shr?)
      end
    end

    def _narrow_less_than_by_eq(lhs_dom, rhs_dom = self)
      if lhs_dom.max_value >= rhs_dom.value
        # NOTE: Narrowing `=========>---' by `== ---|--------' makes
        #       `---|---------'.
        rhs_dom
      else
        # NOTE: Narrowing `===>---------' by `== --------|---' makes
        #       `-------------'.
        ValueDomain.of_nil(logical_shr?)
      end
    end

    def _narrow_greater_than_by_eq(lhs_dom, rhs_dom = self)
      if lhs_dom.min_value <= rhs_dom.value
        # NOTE: Narrowing `---<=========' by `== --------|---' makes
        #       `---------|---'.
        rhs_dom
      else
        # NOTE: Narrowing `---------<===' by `== ---|--------' makes
        #       `-------------'.
        ValueDomain.of_nil(logical_shr?)
      end
    end

    def _narrow_by_ne(rhs_dom, lhs_dom = self)
      rhs_dom._narrow_equal_to_by_ne(lhs_dom)
    end

    def _narrow_nil_by_ne(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, narrowing NilValueDomain by anything makes no effect to the
      #       target value-domain.
      lhs_dom
    end

    def _narrow_unlimited_by_ne(lhs_dom, rhs_dom = self)
      rhs_dom.inversion
    end

    def _narrow_equal_to_by_ne(lhs_dom, rhs_dom = self)
      if lhs_dom.value == rhs_dom.value
        # NOTE: Narrowing `------|------' by `!= ------|-----' makes
        #       `-------------'.
        ValueDomain.of_nil(logical_shr?)
      else
        # NOTE: Narrowing `---|---------' by `!= --------|---' makes
        #       `---|---------'.
        lhs_dom
      end
    end

    def _narrow_less_than_by_ne(lhs_dom, rhs_dom = self)
      if lhs_dom.max_value >= rhs_dom.value
        # NOTE: Narrowing `=========>---' by `!= ------|------' makes
        #       `=====>-<=>---'.
        lhs_dom.intersection(rhs_dom.inversion)
      else
        # NOTE: Narrowing `===>---------' by `!= ------|------' makes
        #       `===>---------'.
        lhs_dom
      end
    end

    def _narrow_greater_than_by_ne(lhs_dom, rhs_dom = self)
      if lhs_dom.min_value <= rhs_dom.value
        # NOTE: Narrowing `---<=========' by `!= ------|------' makes
        #       `---<=>-<====='.
        lhs_dom.intersection(rhs_dom.inversion)
      else
        lhs_dom
      end
    end

    def _narrow_by_lt(rhs_dom, lhs_dom = self)
      rhs_dom._narrow_equal_to_by_lt(lhs_dom)
    end

    def _narrow_nil_by_lt(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, narrowing NilValueDomain by anything makes no effect to the
      #       target value-domain.
      lhs_dom
    end

    def _narrow_unlimited_by_lt(lhs_dom, rhs_dom = self)
      ValueDomain.less_than(rhs_dom.value, logical_shr?)
    end

    def _narrow_equal_to_by_lt(lhs_dom, rhs_dom = self)
      if lhs_dom.value < rhs_dom.value
        lhs_dom
      else
        ValueDomain.of_nil(logical_shr?)
      end
    end

    def _narrow_less_than_by_lt(lhs_dom, rhs_dom = self)
      if lhs_dom.max_value >= rhs_dom.value
        # NOTE: Narrowing `=========>---' by `< ------|------' makes
        #       `=====>-------'.
        ValueDomain.less_than(rhs_dom.value, logical_shr?)
      else
        lhs_dom
      end
    end

    def _narrow_greater_than_by_lt(lhs_dom, rhs_dom = self)
      if lhs_dom.min_value <= rhs_dom.value
        # NOTE: Narrowing `---<=========' by `< ------|------' makes
        #       `---<=>-------'.
        lhs_dom.intersection(
          ValueDomain.less_than(rhs_dom.value, logical_shr?))
      else
        ValueDomain.of_nil(logical_shr?)
      end
    end

    def _narrow_by_gt(rhs_dom, lhs_dom = self)
      rhs_dom._narrow_equal_to_by_gt(lhs_dom)
    end

    def _narrow_nil_by_gt(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, narrowing NilValueDomain by anything makes no effect to the
      #       target value-domain.
      lhs_dom
    end

    def _narrow_unlimited_by_gt(lhs_dom, rhs_dom = self)
      ValueDomain.greater_than(rhs_dom.value, logical_shr?)
    end

    def _narrow_equal_to_by_gt(lhs_dom, rhs_dom = self)
      if lhs_dom.value > rhs_dom.value
        # NOTE: Narrowing `---------|---' by `> ---|---------' makes
        #       `---------|---'.
        lhs_dom
      else
        # NOTE: Narrowing `---|---------' by `> ---------|---' makes
        #       `-------------'.
        ValueDomain.of_nil(logical_shr?)
      end
    end

    def _narrow_less_than_by_gt(lhs_dom, rhs_dom = self)
      if lhs_dom.max_value >= rhs_dom.value
        # NOTE: Narrowing `=========>---' by `> ---|---------' makes
        #       `---<=====>---'.
        ValueDomain.greater_than(rhs_dom.value,
                                 logical_shr?).intersection(lhs_dom)
      else
        # NOTE: Narrowing `===>---------' by `> ------|------' makes
        #       `-------------'.
        ValueDomain.of_nil(logical_shr?)
      end
    end

    def _narrow_greater_than_by_gt(lhs_dom, rhs_dom = self)
      if lhs_dom.min_value <= rhs_dom.value
        # NOTE: Narrowing `---<=========' by `> ------|------' makes
        #       `------<======'.
        ValueDomain.greater_than(rhs_dom.value, logical_shr?)
      else
        # NOTE: Narrowing `---------<===' by `> ---|---------' makes
        #       `---------<==='.
        lhs_dom
      end
    end

    def inversion
      ValueDomain.less_than(@value, logical_shr?).union(
        ValueDomain.greater_than(@value, logical_shr?))
    end

    def ~
      ValueDomain.equal_to(~coerce_to_integer.value, logical_shr?)
    end

    def +@
      self
    end

    def -@
      ValueDomain.equal_to(-@value, logical_shr?)
    end

    def +(rhs_dom)
      rhs_dom._add_equal_to(self)
    end

    def _add_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS + RHS' equals to `RHS + LHS'.
      #       This method invokes NilValueDomain#_add_equal_to.
      rhs_dom + lhs_dom
    end

    def _add_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: `LHS + RHS' equals to `RHS + LHS'.
      #       This method invokes UnlimitedValueDomain#_add_equal_to.
      rhs_dom + lhs_dom
    end

    def _add_equal_to(lhs_dom, rhs_dom = self)
      ValueDomain.equal_to(lhs_dom.value + rhs_dom.value, logical_shr?)
    end

    def _add_less_than(lhs_dom, rhs_dom = self)
      ValueDomain.less_than(lhs_dom.value + rhs_dom.value, logical_shr?)
    end

    def _add_greater_than(lhs_dom, rhs_dom = self)
      ValueDomain.greater_than(lhs_dom.value + rhs_dom.value, logical_shr?)
    end

    def *(rhs_dom)
      rhs_dom._mul_equal_to(self)
    end

    def _mul_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS * RHS' equals to `RHS * LHS'.
      #       This method invokes NilValueDomain#_mul_equal_to.
      rhs_dom * lhs_dom
    end

    def _mul_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: `LHS * RHS' equals to `RHS * LHS'.
      #       This method invokes UnlimitedValueDomain#_mul_equal_to.
      rhs_dom * lhs_dom
    end

    def _mul_equal_to(lhs_dom, rhs_dom = self)
      ValueDomain.equal_to(lhs_dom.value * rhs_dom.value, logical_shr?)
    end

    def _mul_less_than(lhs_dom, rhs_dom = self)
      return ValueDomain.equal_to(0, logical_shr?) if rhs_dom.value == 0

      if lhs_dom.value <= 0
        if rhs_dom.value < 0
          ValueDomain.greater_than(lhs_dom.value * rhs_dom.value, logical_shr?)
        else
          ValueDomain.less_than(lhs_dom.value * rhs_dom.value, logical_shr?)
        end
      else
        if rhs_dom.value < 0
          ValueDomain.greater_than(lhs_dom.value * rhs_dom.value, logical_shr?)
        else
          ValueDomain.less_than(lhs_dom.value * rhs_dom.value, logical_shr?)
        end
      end
    end

    def _mul_greater_than(lhs_dom, rhs_dom = self)
      return ValueDomain.equal_to(0, logical_shr?) if rhs_dom.value == 0

      if lhs_dom.value >= 0
        if rhs_dom.value < 0
          ValueDomain.less_than(lhs_dom.value * rhs_dom.value, logical_shr?)
        else
          ValueDomain.greater_than(lhs_dom.value * rhs_dom.value, logical_shr?)
        end
      else
        if rhs_dom.value < 0
          ValueDomain.less_than(lhs_dom.value * rhs_dom.value, logical_shr?)
        else
          ValueDomain.greater_than(lhs_dom.value * rhs_dom.value, logical_shr?)
        end
      end
    end

    def /(rhs_dom)
      rhs_dom._div_equal_to(self)
    end

    def _div_nil(lhs_dom, rhs_dom = self)
      if rhs_dom.value == 0
        ValueDomain.of_nan(logical_shr?)
      else
        lhs_dom
      end
    end

    def _div_unlimited(lhs_dom, rhs_dom = self)
      if rhs_dom.value == 0
        ValueDomain.of_nan(logical_shr?)
      else
        lhs_dom
      end
    end

    def _div_equal_to(lhs_dom, rhs_dom = self)
      if rhs_dom.value == 0
        ValueDomain.of_nan(logical_shr?)
      else
        ValueDomain.equal_to(lhs_dom.value / rhs_dom.value, logical_shr?)
      end
    end

    def _div_less_than(lhs_dom, rhs_dom = self)
      case
      when rhs_dom.value < 0
        ValueDomain.greater_than(lhs_dom.value / rhs_dom.value, logical_shr?)
      when rhs_dom.value == 0
        ValueDomain.of_nan(logical_shr?)
      when rhs_dom.value > 0
        ValueDomain.less_than(lhs_dom.value / rhs_dom.value, logical_shr?)
      end
    end

    def _div_greater_than(lhs_dom, rhs_dom = self)
      case
      when rhs_dom.value < 0
        ValueDomain.less_than(lhs_dom.value / rhs_dom.value, logical_shr?)
      when rhs_dom.value == 0
        ValueDomain.of_nan(logical_shr?)
      when rhs_dom.value > 0
        ValueDomain.greater_than(lhs_dom.value / rhs_dom.value, logical_shr?)
      end
    end

    def &(rhs_dom)
      rhs_dom.coerce_to_integer._and_equal_to(coerce_to_integer)
    end

    def _and_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS & RHS' equals to `RHS & LHS'.
      #       This method invokes NilValueDomain#_and_equal_to.
      rhs_dom & lhs_dom
    end

    def _and_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: `LHS & RHS' equals to `RHS & LHS'.
      #       This method invokes UnlimitedValueDomain#_and_equal_to.
      rhs_dom & lhs_dom
    end

    def _and_equal_to(lhs_dom, rhs_dom = self)
      ValueDomain.equal_to(lhs_dom.value & rhs_dom.value, logical_shr?)
    end

    def _and_less_than(lhs_dom, rhs_dom = self)
      case
      when rhs_dom.value < 0
        ValueDomain.less_than(0, logical_shr?)
      when rhs_dom.value == 0
        ValueDomain.equal_to(0, logical_shr?)
      when rhs_dom.value > 0
        ValueDomain.greater_than(0, logical_shr?)
      end
    end

    def _and_greater_than(lhs_dom, rhs_dom = self)
      case
      when rhs_dom.value < 0
        ValueDomain.less_than(0, logical_shr?)
      when rhs_dom.value == 0
        ValueDomain.equal_to(0, logical_shr?)
      when rhs_dom.value > 0
        ValueDomain.greater_than(0, logical_shr?)
      end
    end

    def |(rhs_dom)
      rhs_dom.coerce_to_integer._or_equal_to(coerce_to_integer)
    end

    def _or_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS | RHS' equals to `RHS | LHS'.
      #       This method invokes NilValueDomain#_or_equal_to.
      rhs_dom | lhs_dom
    end

    def _or_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: `LHS | RHS' equals to `RHS | LHS'.
      #       This method invokes UnlimitedValueDomain#_or_equal_to.
      rhs_dom | lhs_dom
    end

    def _or_equal_to(lhs_dom, rhs_dom = self)
      ValueDomain.equal_to(lhs_dom.value | rhs_dom.value, logical_shr?)
    end

    def _or_less_than(lhs_dom, rhs_dom = self)
      ValueDomain.less_than(lhs_dom.value | rhs_dom.value, logical_shr?)
    end

    def _or_greater_than(lhs_dom, rhs_dom = self)
      ValueDomain.greater_than(lhs_dom.value | rhs_dom.value, logical_shr?)
    end

    def ^(rhs_dom)
      rhs_dom.coerce_to_integer._xor_equal_to(coerce_to_integer)
    end

    def _xor_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS ^ RHS' equals to `RHS ^ LHS'.
      #       This method invokes NilValueDomain#_xor_equal_to.
      rhs_dom ^ lhs_dom
    end

    def _xor_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: `LHS ^ RHS' equals to `RHS ^ LHS'.
      #       This method invokes UnlimitedValueDomain#_xor_equal_to.
      rhs_dom ^ lhs_dom
    end

    def _xor_equal_to(lhs_dom, rhs_dom = self)
      ValueDomain.equal_to(lhs_dom.value ^ rhs_dom.value, logical_shr?)
    end

    def _xor_less_than(lhs_dom, rhs_dom = self)
      ValueDomain.less_than(lhs_dom.value ^ rhs_dom.value, logical_shr?)
    end

    def _xor_greater_than(lhs_dom, rhs_dom = self)
      ValueDomain.greater_than(lhs_dom.value ^ rhs_dom.value, logical_shr?)
    end

    def <<(rhs_dom)
      rhs_dom.coerce_to_integer._shl_equal_to(coerce_to_integer)
    end

    def _shl_nil(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any arithmetic operation with NilValueDomain makes
      #       NilValueDomain.
      lhs_dom
    end

    def _shl_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, this arithmetic operation with UnlimitedValueDomain makes
      #       UnlimitedValueDomain because of the bit-overflow.
      # NOTE: NaN is a subclass of UnlimitedValueDomain.
      #       Arithmetic operation with UnlimitedValueDomain should make
      #       UnlimitedValueDomain, and with NaN should make NaN.
      lhs_dom
    end

    def _shl_equal_to(lhs_dom, rhs_dom = self)
      ValueDomain.equal_to(left_shift(lhs_dom.value, rhs_dom.value),
                           logical_shr?)
    end

    def _shl_less_than(lhs_dom, rhs_dom = self)
      ValueDomain.less_than(left_shift(lhs_dom.value, rhs_dom.value),
                            logical_shr?)
    end

    def _shl_greater_than(lhs_dom, rhs_dom = self)
      ValueDomain.greater_than(left_shift(lhs_dom.value, rhs_dom.value),
                               logical_shr?)
    end

    def >>(rhs_dom)
      rhs_dom.coerce_to_integer._shr_equal_to(coerce_to_integer)
    end

    def _shr_nil(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any arithmetic operation with NilValueDomain makes
      #       NilValueDomain.
      lhs_dom
    end

    def _shr_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, this arithmetic operation with UnlimitedValueDomain makes
      #       UnlimitedValueDomain because of the bit-overflow.
      # NOTE: NaN is a subclass of UnlimitedValueDomain.
      #       Arithmetic operation with UnlimitedValueDomain should make
      #       UnlimitedValueDomain, and with NaN should make NaN.
      lhs_dom
    end

    def _shr_equal_to(lhs_dom, rhs_dom = self)
      ValueDomain.equal_to(right_shift(lhs_dom.value, rhs_dom.value),
                           logical_shr?)
    end

    def _shr_less_than(lhs_dom, rhs_dom = self)
      ValueDomain.less_than(right_shift(lhs_dom.value, rhs_dom.value),
                            logical_shr?)
    end

    def _shr_greater_than(lhs_dom, rhs_dom = self)
      ValueDomain.greater_than(right_shift(lhs_dom.value, rhs_dom.value),
                               logical_shr?)
    end

    def !
      if @value == 0
        ValueDomain.of_true(logical_shr?)
      else
        ValueDomain.of_false(logical_shr?)
      end
    end

    def <(rhs_dom)
      rhs_dom._less_equal_to(self)
    end

    def _less_nil(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any comparison with NilValueDomain makes no sense.
      ValueDomain.of_nil(logical_shr?)
    end

    def _less_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, any comparison with UnlimitedValueDomain makes
      #       UnlimitedValueDomain.
      ValueDomain.of_unlimited(logical_shr?)
    end

    def _less_equal_to(lhs_dom, rhs_dom = self)
      if lhs_dom.value < rhs_dom.value
        ValueDomain.of_true(logical_shr?)
      else
        ValueDomain.of_false(logical_shr?)
      end
    end

    def _less_less_than(lhs_dom, rhs_dom = self)
      if lhs_dom.max_value < rhs_dom.value
        ValueDomain.of_true(logical_shr?)
      else
        ValueDomain.of_unlimited(logical_shr?)
      end
    end

    def _less_greater_than(lhs_dom, rhs_dom = self)
      if lhs_dom.min_value > rhs_dom.value
        ValueDomain.of_false(logical_shr?)
      else
        ValueDomain.of_unlimited(logical_shr?)
      end
    end

    def ==(rhs_dom)
      rhs_dom._equal_equal_to(self)
    end

    def _equal_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS == RHS' equals to `RHS == LHS'.
      #       This method invokes NilValueDomain#_equal_equal_to.
      rhs_dom == lhs_dom
    end

    def _equal_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: `LHS == RHS' equals to `RHS == LHS'.
      #       This method invokes UnlimitedValueDomain#_equal_equal_to.
      rhs_dom == lhs_dom
    end

    def _equal_equal_to(lhs_dom, rhs_dom = self)
      if lhs_dom.value == rhs_dom.value
        ValueDomain.of_true(logical_shr?)
      else
        ValueDomain.of_false(logical_shr?)
      end
    end

    def _equal_less_than(lhs_dom, rhs_dom = self)
      if lhs_dom.max_value >= rhs_dom.value
        ValueDomain.of_unlimited(logical_shr?)
      else
        ValueDomain.of_false(logical_shr?)
      end
    end

    def _equal_greater_than(lhs_dom, rhs_dom = self)
      if lhs_dom.min_value <= rhs_dom.value
        ValueDomain.of_unlimited(logical_shr?)
      else
        ValueDomain.of_false(logical_shr?)
      end
    end

    def !=(rhs_dom)
      rhs_dom._not_equal_equal_to(self)
    end

    def _not_equal_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS != RHS' equals to `RHS != LHS'.
      #       This method invokes NilValueDomain#_not_equal_equal_to.
      rhs_dom != lhs_dom
    end

    def _not_equal_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: `LHS != RHS' equals to `RHS != LHS'.
      #       This method invokes UnlimitedValueDomain#_not_equal_equal_to.
      rhs_dom != lhs_dom
    end

    def _not_equal_equal_to(lhs_dom, rhs_dom = self)
      if lhs_dom.value != rhs_dom.value
        ValueDomain.of_true(logical_shr?)
      else
        ValueDomain.of_false(logical_shr?)
      end
    end

    def _not_equal_less_than(lhs_dom, rhs_dom = self)
      if lhs_dom.max_value < rhs_dom.value
        ValueDomain.of_true(logical_shr?)
      else
        ValueDomain.of_unlimited(logical_shr?)
      end
    end

    def _not_equal_greater_than(lhs_dom, rhs_dom = self)
      if lhs_dom.min_value > rhs_dom.value
        ValueDomain.of_true(logical_shr?)
      else
        ValueDomain.of_unlimited(logical_shr?)
      end
    end

    def logical_and(rhs_dom)
      rhs_dom._logical_and_equal_to(self)
    end

    def _logical_and_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS && RHS' equals to `RHS && LHS'.
      #       This method invokes NilValueDomain#_logical_and_equal_to.
      rhs_dom.logical_and(lhs_dom)
    end

    def _logical_and_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: `LHS && RHS' equals to `RHS && LHS'.
      #       This method invokes UnlimitedValueDomain#_logical_and_equal_to.
      rhs_dom.logical_and(lhs_dom)
    end

    def _logical_and_equal_to(lhs_dom, rhs_dom = self)
      if lhs_dom.value == 0 || rhs_dom.value == 0
        ValueDomain.of_false(logical_shr?)
      else
        ValueDomain.of_true(logical_shr?)
      end
    end

    def _logical_and_less_than(lhs_dom, rhs_dom = self)
      if rhs_dom.value == 0
        ValueDomain.of_false(logical_shr?)
      else
        if lhs_dom.value < 0
          ValueDomain.of_true(logical_shr?)
        else
          ValueDomain.of_unlimited(logical_shr?)
        end
      end
    end

    def _logical_and_greater_than(lhs_dom, rhs_dom = self)
      if rhs_dom.value == 0
        ValueDomain.of_false(logical_shr?)
      else
        if lhs_dom.value > 0
          ValueDomain.of_true(logical_shr?)
        else
          ValueDomain.of_unlimited(logical_shr?)
        end
      end
    end

    def logical_or(rhs_dom)
      rhs_dom._logical_or_equal_to(self)
    end

    def _logical_or_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS || RHS' equals to `RHS || LHS'.
      #       This method invokes NilValueDomain#_logical_or_equal_to.
      rhs_dom.logical_or(lhs_dom)
    end

    def _logical_or_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: `LHS || RHS' equals to `RHS || LHS'.
      #       This method invokes UnlimitedValueDomain#_logical_or_equal_to.
      rhs_dom.logical_or(lhs_dom)
    end

    def _logical_or_equal_to(lhs_dom, rhs_dom = self)
      if lhs_dom.value == 0 && rhs_dom.value == 0
        ValueDomain.of_false(logical_shr?)
      else
        ValueDomain.of_true(logical_shr?)
      end
    end

    def _logical_or_less_than(lhs_dom, rhs_dom = self)
      if rhs_dom.value == 0
        if lhs_dom.value < 0
          ValueDomain.of_true(logical_shr?)
        else
          ValueDomain.of_unlimited(logical_shr?)
        end
      else
        ValueDomain.of_true(logical_shr?)
      end
    end

    def _logical_or_greater_than(lhs_dom, rhs_dom = self)
      if rhs_dom.value == 0
        if lhs_dom.value > 0
          ValueDomain.of_true(logical_shr?)
        else
          ValueDomain.of_unlimited(logical_shr?)
        end
      else
        ValueDomain.of_true(logical_shr?)
      end
    end

    def intersection(rhs_dom)
      rhs_dom._intersection_equal_to(self)
    end

    def _intersection_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS intersection RHS' equals to `RHS intersection LHS'.
      #       This method invokes NilValueDomain#_intersection_equal_to.
      rhs_dom.intersection(lhs_dom)
    end

    def _intersection_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: `LHS intersection RHS' equals to `RHS intersection LHS'.
      #       This method invokes UnlimitedValueDomain#_intersection_equal_to.
      rhs_dom.intersection(lhs_dom)
    end

    def _intersection_equal_to(lhs_dom, rhs_dom = self)
      if lhs_dom.value == rhs_dom.value
        lhs_dom
      else
        ValueDomain.of_nil(logical_shr?)
      end
    end

    def _intersection_less_than(lhs_dom, rhs_dom = self)
      if lhs_dom.max_value >= rhs_dom.value
        rhs_dom
      else
        ValueDomain.of_nil(logical_shr?)
      end
    end

    def _intersection_greater_than(lhs_dom, rhs_dom = self)
      if lhs_dom.min_value <= rhs_dom.value
        rhs_dom
      else
        ValueDomain.of_nil(logical_shr?)
      end
    end

    def union(rhs_dom)
      rhs_dom._union_equal_to(self)
    end

    def _union_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS union RHS' equals to `RHS union LHS'.
      #       This method invokes NilValueDomain#_union_equal_to.
      rhs_dom.union(lhs_dom)
    end

    def _union_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: `LHS union RHS' equals to `RHS union LHS'.
      #       This method invokes UnlimitedValueDomain#_union_equal_to.
      rhs_dom.union(lhs_dom)
    end

    def _union_equal_to(lhs_dom, rhs_dom = self)
      if lhs_dom.value == rhs_dom.value
        lhs_dom
      else
        ValueDomain._create_union(lhs_dom, rhs_dom)
      end
    end

    def _union_less_than(lhs_dom, rhs_dom = self)
      if lhs_dom.max_value >= rhs_dom.value
        lhs_dom
      else
        ValueDomain._create_union(lhs_dom, rhs_dom)
      end
    end

    def _union_greater_than(lhs_dom, rhs_dom = self)
      if lhs_dom.min_value <= rhs_dom.value
        lhs_dom
      else
        ValueDomain._create_union(lhs_dom, rhs_dom)
      end
    end

    def coerce_to_integer
      if @value.integer?
        self
      else
        ValueDomain.equal_to(@value.to_i, logical_shr?)
      end
    end

    def coerce_to_real
      if @value.real?
        self
      else
        ValueDomain.equal_to(@value.to_f, logical_shr?)
      end
    end

    def min_value
      @value
    end

    def max_value
      @value
    end

    def each_sample
      if block_given?
        yield(@value)
        self
      else
        to_enum(:each_sample)
      end
    end

    def to_defined_domain
      self
    end

    def to_s
      "(== #{@value})"
    end
    memoize :to_s

    def complexity
      1
    end
  end

  class LessThanValueDomain < ValueDomain
    def initialize(val, logical_shr)
      super(logical_shr)
      if val
        @value = val
      else
        raise ArgumentError, "less than nil?"
      end
    end

    attr_reader :value

    def empty?
      false
    end

    def nan?
      false
    end

    def undefined?
      false
    end

    def ambiguous?
      false
    end

    def contain_value_domain?(rhs_dom)
      rhs_dom._contain_less_than?(self)
    end

    def _contain_nil?(lhs_dom, rhs_dom = self)
      false
    end

    def _contain_unlimited?(lhs_dom, rhs_dom = self)
      true
    end

    def _contain_equal_to?(lhs_dom, rhs_dom = self)
      false
    end

    def _contain_less_than?(lhs_dom, rhs_dom = self)
      lhs_dom.value >= rhs_dom.value
    end

    def _contain_greater_than?(lhs_dom, rhs_dom = self)
      false
    end

    def _contain_intersection?(lhs_dom, rhs_dom = self)
      lhs_dom.domain_pair.all? { |lhs| lhs.contain_value_domain?(rhs_dom) }
    end

    def _contain_union?(lhs_dom, rhs_dom = self)
      lhs_dom.domain_pair.any? { |lhs| lhs.contain_value_domain?(rhs_dom) }
    end

    def intersect?(rhs_dom)
      rhs_dom._intersect_less_than?(self)
    end

    def _intersect_nil?(lhs_dom, rhs_dom = self)
      # NOTE: `LHS intersect? RHS' equals to `RHS intersect? LHS'.
      #       This method invokes NilValueDomain#_intersect_less_than?.
      rhs_dom.intersect?(lhs_dom)
    end

    def _intersect_unlimited?(lhs_dom, rhs_dom = self)
      # NOTE: `LHS intersect? RHS' equals to `RHS intersect? LHS'.
      #       This method invokes
      #       UnlimitedValueDomain#_intersect_less_than?.
      rhs_dom.intersect?(lhs_dom)
    end

    def _intersect_equal_to?(lhs_dom, rhs_dom = self)
      # NOTE: `LHS intersect? RHS' equals to `RHS intersect? LHS'.
      #       This method invokes EqualToValueDomain#_intersect_less_than?.
      rhs_dom.intersect?(lhs_dom)
    end

    def _intersect_less_than?(lhs_dom, rhs_dom = self)
      true
    end

    def _intersect_greater_than?(lhs_dom, rhs_dom = self)
      lhs_dom.min_value <= rhs_dom.max_value
    end

    def _narrow_by_eq(rhs_dom, lhs_dom = self)
      rhs_dom._narrow_less_than_by_eq(lhs_dom)
    end

    def _narrow_nil_by_eq(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, narrowing NilValueDomain by anything makes no effect to the
      #       target value-domain.
      lhs_dom
    end

    def _narrow_unlimited_by_eq(lhs_dom, rhs_dom = self)
      rhs_dom
    end

    def _narrow_equal_to_by_eq(lhs_dom, rhs_dom = self)
      if lhs_dom.value < rhs_dom.value
        # NOTE: Narrowing `------|------' by `== =========>---' makes
        #       `------|------'.
        lhs_dom
      else
        # NOTE: Narrowing `---------|---' by `== ===>---------' makes
        #       `-------------'.
        ValueDomain.of_nil(logical_shr?)
      end
    end

    def _narrow_less_than_by_eq(lhs_dom, rhs_dom = self)
      if lhs_dom.value < rhs_dom.value
        # NOTE: Narrowing `===>---------' by `== =========>---' makes
        #       `===>---------'.
        lhs_dom
      else
        # NOTE: Narrowing `=========>---' by `== ===>---------' makes
        #       `===>---------'.
        rhs_dom
      end
    end

    def _narrow_greater_than_by_eq(lhs_dom, rhs_dom = self)
      if lhs_dom.min_value > rhs_dom.max_value
        ValueDomain.of_nil(logical_shr?)
      else
        # NOTE: Narrowing `---<=========' by `== =========>---' makes
        #       `---<=====>---'.
        lhs_dom.intersection(rhs_dom)
      end
    end

    def _narrow_by_ne(rhs_dom, lhs_dom = self)
      rhs_dom._narrow_less_than_by_ne(lhs_dom)
    end

    def _narrow_nil_by_ne(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, narrowing NilValueDomain by anything makes no effect to the
      #       target value-domain.
      lhs_dom
    end

    def _narrow_unlimited_by_ne(lhs_dom, rhs_dom = self)
      rhs_dom.inversion
    end

    def _narrow_equal_to_by_ne(lhs_dom, rhs_dom = self)
      if lhs_dom.value <= rhs_dom.max_value
        # NOTE: Narrowing `---|---------' by `!= =========>---' makes
        #       `-------------'.
        ValueDomain.of_nil(logical_shr?)
      else
        # NOTE: Narrowing `---------|---' by `!= ===>---------' makes
        #       `---------|---'.
        lhs_dom
      end
    end

    def _narrow_less_than_by_ne(lhs_dom, rhs_dom = self)
      if lhs_dom.max_value <= rhs_dom.max_value
        # NOTE: Narrowing `===>---------' by `!= =========>---' makes
        #       `-------------'.
        ValueDomain.of_nil(logical_shr?)
      else
        # NOTE: Narrowing `=========>---' by `!= ===>---------' makes
        #       `---<=====>---'.
        lhs_dom.intersection(rhs_dom.inversion)
      end
    end

    def _narrow_greater_than_by_ne(lhs_dom, rhs_dom = self)
      if lhs_dom.min_value <= rhs_dom.max_value
        # NOTE: Narrowing `---<=========' by `!= =========>---' makes
        #       `---------<==='.
        rhs_dom.inversion
      else
        # NOTE: Narrowing `---------<===' by `!= ===>---------' makes
        #       `---------<==='.
        lhs_dom
      end
    end

    def _narrow_by_lt(rhs_dom, lhs_dom = self)
      rhs_dom._narrow_less_than_by_lt(lhs_dom)
    end

    def _narrow_nil_by_lt(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, narrowing NilValueDomain by anything makes no effect to the
      #       target value-domain.
      lhs_dom
    end

    def _narrow_unlimited_by_lt(lhs_dom, rhs_dom = self)
      # NOTE: Narrowing `=============' by `< ======>------' makes
      #       `-------------'.
      ValueDomain.of_nil(logical_shr?)
    end

    def _narrow_equal_to_by_lt(lhs_dom, rhs_dom = self)
      # NOTE: Narrowing `------|------' by `< ======>------' makes
      #       `-------------'.
      ValueDomain.of_nil(logical_shr?)
    end

    def _narrow_less_than_by_lt(lhs_dom, rhs_dom = self)
      # NOTE: Narrowing `=========>---' by `< =======>-----' makes
      #       `-------------'.
      ValueDomain.of_nil(logical_shr?)
    end

    def _narrow_greater_than_by_lt(lhs_dom, rhs_dom = self)
      # NOTE: Narrowing `---<=========' by `< =========>---' makes
      #       `-------------'.
      ValueDomain.of_nil(logical_shr?)
    end

    def _narrow_by_gt(rhs_dom, lhs_dom = self)
      rhs_dom._narrow_less_than_by_gt(lhs_dom)
    end

    def _narrow_nil_by_gt(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, narrowing NilValueDomain by anything makes no effect to the
      #       target value-domain.
      lhs_dom
    end

    def _narrow_unlimited_by_gt(lhs_dom, rhs_dom = self)
      # NOTE: Narrowing `=============' by `> ======>------' makes
      #       `------<======'.
      rhs_dom.inversion
    end

    def _narrow_equal_to_by_gt(lhs_dom, rhs_dom = self)
      if lhs_dom.value > rhs_dom.max_value
        # NOTE: Narrowing `---------|---' by `> ===>---------' makes
        #       `---------|---'.
        lhs_dom
      else
        # NOTE: Narrowing `---|---------' by `> =========>---' makes
        #       `-------------'.
        ValueDomain.of_nil(logical_shr?)
      end
    end

    def _narrow_less_than_by_gt(lhs_dom, rhs_dom = self)
      if lhs_dom.max_value > rhs_dom.max_value
        # NOTE: Narrowing `=========>---' by `> ===>---------' makes
        #       `---<=====>---'.
        rhs_dom.inversion.intersection(lhs_dom)
      else
        # NOTE: Narrowing `===>---------' by `> =========>---' makes
        #       `-------------'.
        ValueDomain.of_nil(logical_shr?)
      end
    end

    def _narrow_greater_than_by_gt(lhs_dom, rhs_dom = self)
      if lhs_dom.min_value < rhs_dom.max_value
        # NOTE: Narrowing `---<=========' by `> =========>---' makes
        #       `---------<==='.
        rhs_dom.inversion
      else
        # NOTE: Narrowing `---------<===' by `> ===>---------' makes
        #       `---------<==='.
        lhs_dom
      end
    end

    def inversion
      ValueDomain.greater_than_or_equal_to(@value, logical_shr?)
    end

    def ~
      ValueDomain.less_than(~coerce_to_integer.value, logical_shr?)
    end

    def +@
      self
    end

    def -@
      ValueDomain.greater_than(-@value, logical_shr?)
    end

    def +(rhs_dom)
      rhs_dom._add_less_than(self)
    end

    def _add_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS + RHS' equals to `RHS + LHS'.
      #       This method invokes NilValueDomain#_add_less_than.
      rhs_dom + lhs_dom
    end

    def _add_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: `LHS + RHS' equals to `RHS + LHS'.
      #       This method invokes UnlimitedValueDomain#_add_less_than.
      rhs_dom + lhs_dom
    end

    def _add_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: `LHS + RHS' equals to `RHS + LHS'.
      #       This method invokes EqualToValueDomain#_add_less_than.
      rhs_dom + lhs_dom
    end

    def _add_less_than(lhs_dom, rhs_dom = self)
      ValueDomain.less_than(lhs_dom.value + rhs_dom.value, logical_shr?)
    end

    def _add_greater_than(lhs_dom, rhs_dom = self)
      ValueDomain.of_unlimited(logical_shr?)
    end

    def *(rhs_dom)
      rhs_dom._mul_less_than(self)
    end

    def _mul_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS * RHS' equals to `RHS * LHS'.
      #       This method invokes NilValueDomain#_mul_less_than.
      rhs_dom * lhs_dom
    end

    def _mul_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: `LHS * RHS' equals to `RHS * LHS'.
      #       This method invokes UnlimitedValueDomain#_mul_less_than.
      rhs_dom * lhs_dom
    end

    def _mul_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: `LHS * RHS' equals to `RHS * LHS'.
      #       This method invokes EqualToValueDomain#_mul_less_than.
      rhs_dom * lhs_dom
    end

    def _mul_less_than(lhs_dom, rhs_dom = self)
      if lhs_dom.value <= 0
        if rhs_dom.value <= 0
          ValueDomain.greater_than(lhs_dom.value * rhs_dom.value, logical_shr?)
        else
          ValueDomain.of_unlimited(logical_shr?)
        end
      else
        if rhs_dom.value <= 0
          ValueDomain.of_unlimited(logical_shr?)
        else
          ValueDomain.of_unlimited(logical_shr?)
        end
      end
    end

    def _mul_greater_than(lhs_dom, rhs_dom = self)
      if lhs_dom.value >= 0
        if rhs_dom.value <= 0
          ValueDomain.less_than(lhs_dom.value * rhs_dom.value, logical_shr?)
        else
          ValueDomain.of_unlimited(logical_shr?)
        end
      else
        if rhs_dom.value <= 0
          ValueDomain.of_unlimited(logical_shr?)
        else
          ValueDomain.of_unlimited(logical_shr?)
        end
      end
    end

    def /(rhs_dom)
      rhs_dom._div_less_than(self)
    end

    def _div_nil(lhs_dom, rhs_dom = self)
      if rhs_dom.max_value >= 0
        ValueDomain.of_nan(logical_shr?)
      else
        lhs_dom
      end
    end

    def _div_unlimited(lhs_dom, rhs_dom = self)
      if rhs_dom.max_value >= 0
        ValueDomain.of_nan(logical_shr?)
      else
        lhs_dom
      end
    end

    def _div_equal_to(lhs_dom, rhs_dom = self)
      if rhs_dom.value >= 0
        ValueDomain.of_nan(logical_shr?)
      else
        case
        when lhs_dom.value < 0
          ValueDomain.greater_than(0, logical_shr?).intersection(
            ValueDomain.less_than(lhs_dom.value / rhs_dom.value, logical_shr?))
        when lhs_dom.value == 0
          ValueDomain.equal_to(0, logical_shr?)
        when lhs_dom.value > 0
          ValueDomain.greater_than(
            lhs_dom.value / rhs_dom.value, logical_shr?
          ).intersection(ValueDomain.less_than(0, logical_shr?))
        end
      end
    end

    def _div_less_than(lhs_dom, rhs_dom = self)
      if rhs_dom.value > 0
        ValueDomain.of_nan(logical_shr?)
      else
        case
        when lhs_dom.value <= 0
          ValueDomain.greater_than(0, logical_shr?)
        when lhs_dom.value > 0
          ValueDomain.less_than(0, logical_shr?)
        end
      end
    end

    def _div_greater_than(lhs_dom, rhs_dom = self)
      if rhs_dom.value > 0
        ValueDomain.of_nan(logical_shr?)
      else
        case
        when lhs_dom.value >= 0
          ValueDomain.less_than(0, logical_shr?)
        when lhs_dom.value < 0
          ValueDomain.greater_than(0, logical_shr?)
        end
      end
    end

    def &(rhs_dom)
      rhs_dom.coerce_to_integer._and_less_than(coerce_to_integer)
    end

    def _and_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS & RHS' equals to `RHS & LHS'.
      #       This method invokes NilValueDomain#_and_less_than.
      rhs_dom & lhs_dom
    end

    def _and_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: `LHS & RHS' equals to `RHS & LHS'.
      #       This method invokes UnlimitedValueDomain#_and_less_than.
      rhs_dom & lhs_dom
    end

    def _and_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: `LHS & RHS' equals to `RHS & LHS'.
      #       This method invokes EqualToValueDomain#_and_less_than.
      rhs_dom & lhs_dom
    end

    def _and_less_than(lhs_dom, rhs_dom = self)
      if lhs_dom.value < 0 && rhs_dom.value < 0
        ValueDomain.less_than(lhs_dom.value & rhs_dom.value, logical_shr?)
      else
        ValueDomain.of_unlimited(logical_shr?)
      end
    end

    def _and_greater_than(lhs_dom, rhs_dom = self)
      if lhs_dom.value > 0 && rhs_dom.value < 0
        ValueDomain.less_than(lhs_dom.value & rhs_dom.value, logical_shr?)
      else
        ValueDomain.of_unlimited(logical_shr?)
      end
    end

    def |(rhs_dom)
      rhs_dom.coerce_to_integer._or_less_than(coerce_to_integer)
    end

    def _or_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS | RHS' equals to `RHS | LHS'.
      #       This method invokes NilValueDomain#_or_less_than.
      rhs_dom | lhs_dom
    end

    def _or_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: `LHS | RHS' equals to `RHS | LHS'.
      #       This method invokes UnlimitedValueDomain#_or_less_than.
      rhs_dom | lhs_dom
    end

    def _or_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: `LHS | RHS' equals to `RHS | LHS'.
      #       This method invokes EqualToValueDomain#_or_less_than.
      rhs_dom | lhs_dom
    end

    def _or_less_than(lhs_dom, rhs_dom = self)
      ValueDomain.less_than(lhs_dom.value | rhs_dom.value, logical_shr?)
    end

    def _or_greater_than(lhs_dom, rhs_dom = self)
      ValueDomain.of_unlimited(logical_shr?)
    end

    def ^(rhs_dom)
      rhs_dom.coerce_to_integer._xor_less_than(coerce_to_integer)
    end

    def _xor_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS ^ RHS' equals to `RHS ^ LHS'.
      #       This method invokes NilValueDomain#_xor_less_than.
      rhs_dom ^ lhs_dom
    end

    def _xor_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: `LHS ^ RHS' equals to `RHS ^ LHS'.
      #       This method invokes UnlimitedValueDomain#_xor_less_than.
      rhs_dom ^ lhs_dom
    end

    def _xor_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: `LHS ^ RHS' equals to `RHS ^ LHS'.
      #       This method invokes EqualToValueDomain#_xor_less_than.
      rhs_dom ^ lhs_dom
    end

    def _xor_less_than(lhs_dom, rhs_dom = self)
      case
      when lhs_dom.value < 0 && rhs_dom.value < 0
        ValueDomain.greater_than(0, logical_shr?)
      when lhs_dom.value < 0 || rhs_dom.value < 0
        ValueDomain.less_than(0, logical_shr?)
      else
        ValueDomain.greater_than(0, logical_shr?)
      end
    end

    def _xor_greater_than(lhs_dom, rhs_dom = self)
      case
      when lhs_dom.value < 0 && rhs_dom.value < 0
        ValueDomain.greater_than(0, logical_shr?)
      when lhs_dom.value < 0 || rhs_dom.value < 0
        ValueDomain.less_than(0, logical_shr?)
      else
        ValueDomain.greater_than(0, logical_shr?)
      end
    end

    def <<(rhs_dom)
      rhs_dom.coerce_to_integer._shl_less_than(coerce_to_integer)
    end

    def _shl_nil(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any arithmetic operation with NilValueDomain makes
      #       NilValueDomain.
      lhs_dom
    end

    def _shl_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, this arithmetic operation with UnlimitedValueDomain makes
      #       UnlimitedValueDomain because of the bit-overflow.
      # NOTE: NaN is a subclass of UnlimitedValueDomain.
      #       Arithmetic operation with UnlimitedValueDomain should make
      #       UnlimitedValueDomain, and with NaN should make NaN.
      lhs_dom
    end

    def _shl_equal_to(lhs_dom, rhs_dom = self)
      ValueDomain.less_than(left_shift(lhs_dom.value, rhs_dom.value),
                            logical_shr?)
    end

    def _shl_less_than(lhs_dom, rhs_dom = self)
      ValueDomain.less_than(left_shift(lhs_dom.value, rhs_dom.value),
                            logical_shr?)
    end

    def _shl_greater_than(lhs_dom, rhs_dom = self)
      ValueDomain.less_than(left_shift(lhs_dom.value, rhs_dom.value),
                            logical_shr?)
    end

    def >>(rhs_dom)
      rhs_dom.coerce_to_integer._shr_less_than(coerce_to_integer)
    end

    def _shr_nil(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any arithmetic operation with NilValueDomain makes
      #       NilValueDomain.
      lhs_dom
    end

    def _shr_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, this arithmetic operation with UnlimitedValueDomain makes
      #       UnlimitedValueDomain because of the bit-overflow.
      # NOTE: NaN is a subclass of UnlimitedValueDomain.
      #       Arithmetic operation with UnlimitedValueDomain should make
      #       UnlimitedValueDomain, and with NaN should make NaN.
      lhs_dom
    end

    def _shr_equal_to(lhs_dom, rhs_dom = self)
      ValueDomain.greater_than(right_shift(lhs_dom.value, rhs_dom.value),
                               logical_shr?)
    end

    def _shr_less_than(lhs_dom, rhs_dom = self)
      ValueDomain.greater_than(right_shift(lhs_dom.value, rhs_dom.value),
                               logical_shr?)
    end

    def _shr_greater_than(lhs_dom, rhs_dom = self)
      ValueDomain.greater_than(right_shift(lhs_dom.value, rhs_dom.value),
                               logical_shr?)
    end

    def !
      if @value < 0
        ValueDomain.of_false(logical_shr?)
      else
        ValueDomain.of_unlimited(logical_shr?)
      end
    end

    def <(rhs_dom)
      rhs_dom._less_less_than(self)
    end

    def _less_nil(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any comparison with NilValueDomain makes no sense.
      ValueDomain.of_nil(logical_shr?)
    end

    def _less_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, any comparison with UnlimitedValueDomain makes
      #       UnlimitedValueDomain.
      ValueDomain.of_unlimited(logical_shr?)
    end

    def _less_equal_to(lhs_dom, rhs_dom = self)
      if lhs_dom.value >= rhs_dom.max_value
        ValueDomain.of_false(logical_shr?)
      else
        ValueDomain.of_unlimited(logical_shr?)
      end
    end

    def _less_less_than(lhs_dom, rhs_dom = self)
      ValueDomain.of_unlimited(logical_shr?)
    end

    def _less_greater_than(lhs_dom, rhs_dom = self)
      if lhs_dom.min_value >= rhs_dom.max_value
        ValueDomain.of_false(logical_shr?)
      else
        ValueDomain.of_unlimited(logical_shr?)
      end
    end

    def ==(rhs_dom)
      rhs_dom._equal_less_than(self)
    end

    def _equal_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS == RHS' equals to `RHS == LHS'.
      #       This method invokes NilValueDomain#_equal_less_than.
      rhs_dom == lhs_dom
    end

    def _equal_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: `LHS == RHS' equals to `RHS == LHS'.
      #       This method invokes UnlimitedValueDomain#_equal_less_than.
      rhs_dom == lhs_dom
    end

    def _equal_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: `LHS == RHS' equals to `RHS == LHS'.
      #       This method invokes EqualToValueDomain#_equal_less_than.
      rhs_dom == lhs_dom
    end

    def _equal_less_than(lhs_dom, rhs_dom = self)
      ValueDomain.of_unlimited(logical_shr?)
    end

    def _equal_greater_than(lhs_dom, rhs_dom = self)
      if lhs_dom.min_value <= rhs_dom.max_value
        ValueDomain.of_unlimited(logical_shr?)
      else
        ValueDomain.of_false(logical_shr?)
      end
    end

    def !=(rhs_dom)
      rhs_dom._not_equal_less_than(self)
    end

    def _not_equal_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS != RHS' equals to `RHS != LHS'.
      #       This method invokes NilValueDomain#_not_equal_less_than.
      rhs_dom != lhs_dom
    end

    def _not_equal_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: `LHS != RHS' equals to `RHS != LHS'.
      #       This method invokes UnlimitedValueDomain#_not_equal_less_than.
      rhs_dom != lhs_dom
    end

    def _not_equal_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: `LHS != RHS' equals to `RHS != LHS'.
      #       This method invokes EqualToValueDomain#_not_equal_less_than.
      rhs_dom != lhs_dom
    end

    def _not_equal_less_than(lhs_dom, rhs_dom = self)
      ValueDomain.of_unlimited(logical_shr?)
    end

    def _not_equal_greater_than(lhs_dom, rhs_dom = self)
      if lhs_dom.min_value <= rhs_dom.max_value
        ValueDomain.of_unlimited(logical_shr?)
      else
        ValueDomain.of_true(logical_shr?)
      end
    end

    def logical_and(rhs_dom)
      rhs_dom._logical_and_less_than(self)
    end

    def _logical_and_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS && RHS' equals to `RHS && LHS'.
      #       This method invokes NilValueDomain#_logical_and_less_than.
      rhs_dom.logical_and(lhs_dom)
    end

    def _logical_and_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: `LHS && RHS' equals to `RHS && LHS'.
      #       This method invokes UnlimitedValueDomain#_logical_and_less_than.
      rhs_dom.logical_and(lhs_dom)
    end

    def _logical_and_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: `LHS && RHS' equals to `RHS && LHS'.
      #       This method invokes EqualToValueDomain#_logical_and_less_than.
      rhs_dom.logical_and(lhs_dom)
    end

    def _logical_and_less_than(lhs_dom, rhs_dom = self)
      if lhs_dom.max_value >= 0 || rhs_dom.max_value >= 0
        ValueDomain.of_unlimited(logical_shr?)
      else
        ValueDomain.of_true(logical_shr?)
      end
    end

    def _logical_and_greater_than(lhs_dom, rhs_dom = self)
      if lhs_dom.min_value <= 0 || rhs_dom.max_value >= 0
        ValueDomain.of_unlimited(logical_shr?)
      else
        ValueDomain.of_true(logical_shr?)
      end
    end

    def logical_or(rhs_dom)
      rhs_dom._logical_or_less_than(self)
    end

    def _logical_or_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS || RHS' equals to `RHS || LHS'.
      #       This method invokes NilValueDomain#_logical_or_less_than.
      rhs_dom.logical_or(lhs_dom)
    end

    def _logical_or_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: `LHS || RHS' equals to `RHS || LHS'.
      #       This method invokes UnlimitedValueDomain#_logical_or_less_than.
      rhs_dom.logical_or(lhs_dom)
    end

    def _logical_or_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: `LHS || RHS' equals to `RHS || LHS'.
      #       This method invokes EqualToValueDomain#_logical_or_less_than.
      rhs_dom.logical_or(lhs_dom)
    end

    def _logical_or_less_than(lhs_dom, rhs_dom = self)
      if lhs_dom.value < 0 || rhs_dom.value < 0
        ValueDomain.of_true(logical_shr?)
      else
        ValueDomain.of_unlimited(logical_shr?)
      end
    end

    def _logical_or_greater_than(lhs_dom, rhs_dom = self)
      if lhs_dom.value > 0 || rhs_dom.value < 0
        ValueDomain.of_true(logical_shr?)
      else
        ValueDomain.of_unlimited(logical_shr?)
      end
    end

    def intersection(rhs_dom)
      rhs_dom._intersection_less_than(self)
    end

    def _intersection_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS intersection RHS' equals to `RHS intersection LHS'.
      #       This method invokes NilValueDomain#_intersection_less_than.
      rhs_dom.intersection(lhs_dom)
    end

    def _intersection_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: `LHS intersection RHS' equals to `RHS intersection LHS'.
      #       This method invokes UnlimitedValueDomain#_intersection_less_than.
      rhs_dom.intersection(lhs_dom)
    end

    def _intersection_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: `LHS intersection RHS' equals to `RHS intersection LHS'.
      #       This method invokes EqualToValueDomain#_intersection_less_than.
      rhs_dom.intersection(lhs_dom)
    end

    def _intersection_less_than(lhs_dom, rhs_dom = self)
      if lhs_dom.max_value <= rhs_dom.max_value
        lhs_dom
      else
        rhs_dom
      end
    end

    def _intersection_greater_than(lhs_dom, rhs_dom = self)
      case
      when lhs_dom.min_value < rhs_dom.max_value
        ValueDomain._create_intersection(lhs_dom, rhs_dom)
      when lhs_dom.min_value == rhs_dom.max_value
        ValueDomain.equal_to(lhs_dom.min_value, logical_shr?)
      when lhs_dom.min_value > rhs_dom.max_value
        ValueDomain.of_nil(logical_shr?)
      end
    end

    def union(rhs_dom)
      rhs_dom._union_less_than(self)
    end

    def _union_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS union RHS' equals to `RHS union LHS'.
      #       This method invokes NilValueDomain#_union_less_than.
      rhs_dom.union(lhs_dom)
    end

    def _union_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: `LHS union RHS' equals to `RHS union LHS'.
      #       This method invokes UnlimitedValueDomain#_union_less_than.
      rhs_dom.union(lhs_dom)
    end

    def _union_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: `LHS union RHS' equals to `RHS union LHS'.
      #       This method invokes EqualToValueDomain#_union_less_than.
      rhs_dom.union(lhs_dom)
    end

    def _union_less_than(lhs_dom, rhs_dom = self)
      if lhs_dom.max_value <= rhs_dom.max_value
        rhs_dom
      else
        lhs_dom
      end
    end

    def _union_greater_than(lhs_dom, rhs_dom = self)
      if lhs_dom.min_value <= rhs_dom.max_value
        ValueDomain.of_unlimited(logical_shr?)
      else
        ValueDomain._create_union(lhs_dom, rhs_dom)
      end
    end

    def coerce_to_integer
      if @value.integer?
        self
      else
        ValueDomain.less_than(@value.to_i, logical_shr?)
      end
    end

    def coerce_to_real
      if @value.real?
        self
      else
        ValueDomain.less_than(@value.to_f, logical_shr?)
      end
    end

    def min_value
      nil
    end

    def max_value
      if @value.integer?
        @value - 1
      else
        @value - Float::EPSILON
      end
    end

    def each_sample
      if block_given?
        yield(max_value)
        self
      else
        to_enum(:each_sample)
      end
    end

    def to_defined_domain
      self
    end

    def to_s
      "(< #{@value})"
    end
    memoize :to_s

    def complexity
      1
    end
  end

  class GreaterThanValueDomain < ValueDomain
    def initialize(val, logical_shr)
      super(logical_shr)
      if val
        @value = val
      else
        raise ArgumentError, "greater than nil?"
      end
    end

    attr_reader :value

    def empty?
      false
    end

    def nan?
      false
    end

    def undefined?
      false
    end

    def ambiguous?
      false
    end

    def contain_value_domain?(rhs_dom)
      rhs_dom._contain_greater_than?(self)
    end

    def _contain_nil?(lhs_dom, rhs_dom = self)
      false
    end

    def _contain_unlimited?(lhs_dom, rhs_dom = self)
      true
    end

    def _contain_equal_to?(lhs_dom, rhs_dom = self)
      false
    end

    def _contain_less_than?(lhs_dom, rhs_dom = self)
      false
    end

    def _contain_greater_than?(lhs_dom, rhs_dom = self)
      lhs_dom.value <= rhs_dom.value
    end

    def _contain_intersection?(lhs_dom, rhs_dom = self)
      lhs_dom.domain_pair.all? { |lhs| lhs.contain_value_domain?(rhs_dom) }
    end

    def _contain_union?(lhs_dom, rhs_dom = self)
      lhs_dom.domain_pair.any? { |lhs| lhs.contain_value_domain?(rhs_dom) }
    end

    def intersect?(rhs_dom)
      rhs_dom._intersect_greater_than?(self)
    end

    def _intersect_nil?(lhs_dom, rhs_dom = self)
      # NOTE: `LHS intersect? RHS' equals to `RHS intersect? LHS'.
      #       This method invokes NilValueDomain#_intersect_greater_than?.
      rhs_dom.intersect?(lhs_dom)
    end

    def _intersect_unlimited?(lhs_dom, rhs_dom = self)
      # NOTE: `LHS intersect? RHS' equals to `RHS intersect? LHS'.
      #       This method invokes
      #       UnlimitedValueDomain#_intersect_greater_than?.
      rhs_dom.intersect?(lhs_dom)
    end

    def _intersect_equal_to?(lhs_dom, rhs_dom = self)
      # NOTE: `LHS intersect? RHS' equals to `RHS intersect? LHS'.
      #       This method invokes
      #       EqualToValueDomain#_intersect_greater_than?.
      rhs_dom.intersect?(lhs_dom)
    end

    def _intersect_less_than?(lhs_dom, rhs_dom = self)
      # NOTE: `LHS intersect? RHS' equals to `RHS intersect? LHS'.
      #       This method invokes
      #       LessThanValueDomain#_intersect_greater_than?.
      rhs_dom.intersect?(lhs_dom)
    end

    def _intersect_greater_than?(lhs_dom, rhs_dom = self)
      true
    end

    def _narrow_by_eq(rhs_dom, lhs_dom = self)
      rhs_dom._narrow_greater_than_by_eq(lhs_dom)
    end

    def _narrow_nil_by_eq(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, narrowing NilValueDomain by anything makes no effect to the
      #       target value-domain.
      lhs_dom
    end

    def _narrow_unlimited_by_eq(lhs_dom, rhs_dom = self)
      rhs_dom
    end

    def _narrow_equal_to_by_eq(lhs_dom, rhs_dom = self)
      if lhs_dom.value > rhs_dom.value
        # NOTE: Narrowing `---------|---' by `== ---<=========' makes
        #       `---------|---'.
        lhs_dom
      else
        # NOTE: Narrowing `---|---------' by `== ---------<===' makes
        #       `-------------'.
        ValueDomain.of_nil(logical_shr?)
      end
    end

    def _narrow_less_than_by_eq(lhs_dom, rhs_dom = self)
      if lhs_dom.value > rhs_dom.value
        # NOTE: Narrowing `=========>---' by `== ---<=========' makes
        #       `---<=====>---'.
        lhs_dom.intersection(rhs_dom)
      else
        # NOTE: Narrowing `===>---------' by `== ---------<===' makes
        #       `-------------'.
        ValueDomain.of_nil(logical_shr?)
      end
    end

    def _narrow_greater_than_by_eq(lhs_dom, rhs_dom = self)
      if lhs_dom.min_value >= rhs_dom.min_value
        # NOTE: Narrowing `---------<===' by `== ---<=========' makes
        #       `---------<==='.
        lhs_dom
      else
        # NOTE: Narrowing `---<=========' by `== ---------<===' makes
        #       `---------<==='.
        rhs_dom
      end
    end

    def _narrow_by_ne(rhs_dom, lhs_dom = self)
      rhs_dom._narrow_greater_than_by_ne(lhs_dom)
    end

    def _narrow_nil_by_ne(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, narrowing NilValueDomain by anything makes no effect to the
      #       target value-domain.
      lhs_dom
    end

    def _narrow_unlimited_by_ne(lhs_dom, rhs_dom = self)
      rhs_dom.inversion
    end

    def _narrow_equal_to_by_ne(lhs_dom, rhs_dom = self)
      if lhs_dom.value >= rhs_dom.min_value
        # NOTE: Narrowing `---|---------' by `!= ---<=========' makes
        #       `-------------'.
        ValueDomain.of_nil(logical_shr?)
      else
        # NOTE: Narrowing `---|---------' by `!= ---------<===' makes
        #       `---|---------'.
        lhs_dom
      end
    end

    def _narrow_less_than_by_ne(lhs_dom, rhs_dom = self)
      if lhs_dom.max_value >= rhs_dom.min_value
        # NOTE: Narrowing `=========>---' by `!= ---<=========' makes
        #       `===>---------'.
        rhs_dom.inversion
      else
        # NOTE: Narrowing `===>---------' by `!= ---------<===' makes
        #       `===>---------'.
        lhs_dom
      end
    end

    def _narrow_greater_than_by_ne(lhs_dom, rhs_dom = self)
      if lhs_dom.min_value >= rhs_dom.min_value
        # NOTE: Narrowing `---------<===' by `!= ---<=========' makes
        #       `-------------'.
        ValueDomain.of_nil(logical_shr?)
      else
        # NOTE: Narrowing `---<=========' by `!= ---------<===' makes
        #       `---<=====>---'.
        lhs_dom.intersection(rhs_dom.inversion)
      end
    end

    def _narrow_by_lt(rhs_dom, lhs_dom = self)
      rhs_dom._narrow_greater_than_by_lt(lhs_dom)
    end

    def _narrow_nil_by_lt(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, narrowing NilValueDomain by anything makes no effect to the
      #       target value-domain.
      lhs_dom
    end

    def _narrow_unlimited_by_lt(lhs_dom, rhs_dom = self)
      # NOTE: Narrowing `=============' by `< ------<======' makes
      #       `======>------'.
      rhs_dom.inversion
    end

    def _narrow_equal_to_by_lt(lhs_dom, rhs_dom = self)
      if lhs_dom.value >= rhs_dom.min_value
        # NOTE: Narrowing `---------|---' by `< ---<=========' makes
        #       `-------------'.
        ValueDomain.of_nil(logical_shr?)
      else
        # NOTE: Narrowing `---|---------' by `< ---------<===' makes
        #       `---|---------'.
        lhs_dom
      end
    end

    def _narrow_less_than_by_lt(lhs_dom, rhs_dom = self)
      if lhs_dom.value > rhs_dom.value
        # NOTE: Narrowing `=========>---' by `< ---<=========' makes
        #       `===>---------'.
        rhs_dom.inversion
      else
        # NOTE: Narrowing `===>---------' by `< ---------<===' makes
        #       `===>---------'.
        lhs_dom
      end
    end

    def _narrow_greater_than_by_lt(lhs_dom, rhs_dom = self)
      if lhs_dom.value < rhs_dom.value
        # NOTE: Narrowing `---<=========' by `< ---------<===' makes
        #       `---<=====>---'.
        lhs_dom.intersect(rhs_dom.inversion)
      else
        # NOTE: Narrowing `---------<===' by `< ---<=========' makes
        #       `-------------'.
        ValueDomain.of_nil(logical_shr?)
      end
    end

    def _narrow_by_gt(rhs_dom, lhs_dom = self)
      rhs_dom._narrow_greater_than_by_gt(lhs_dom)
    end

    def _narrow_nil_by_gt(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, narrowing NilValueDomain by anything makes no effect to the
      #       target value-domain.
      lhs_dom
    end

    def _narrow_unlimited_by_gt(lhs_dom, rhs_dom = self)
      # NOTE: Narrowing `=============' by `> ------<======' makes
      #       `-------------'.
      ValueDomain.of_nil(logical_shr?)
    end

    def _narrow_equal_to_by_gt(lhs_dom, rhs_dom = self)
      # NOTE: Narrowing `------|------' by `> ------<======' makes
      #       `-------------'.
      ValueDomain.of_nil(logical_shr?)
    end

    def _narrow_less_than_by_gt(lhs_dom, rhs_dom = self)
      # NOTE: Narrowing `======>------' by `> ------<======' makes
      #       `-------------'.
      ValueDomain.of_nil(logical_shr?)
    end

    def _narrow_greater_than_by_gt(lhs_dom, rhs_dom = self)
      # NOTE: Narrowing `------<======' by `> ------<======' makes
      #       `-------------'.
      ValueDomain.of_nil(logical_shr?)
    end

    def inversion
      ValueDomain.less_than_or_equal_to(@value, logical_shr?)
    end

    def ~
      ValueDomain.greater_than(~coerce_to_integer.value, logical_shr?)
    end

    def +@
      self
    end

    def -@
      ValueDomain.less_than(-@value, logical_shr?)
    end

    def +(rhs_dom)
      rhs_dom._add_greater_than(self)
    end

    def _add_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS + RHS' equals to `RHS + LHS'.
      #       This method invokes NilValueDomain#_add_greater_than.
      rhs_dom + lhs_dom
    end

    def _add_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: `LHS + RHS' equals to `RHS + LHS'.
      #       This method invokes UnlimitedValueDomain#_add_greater_than.
      rhs_dom + lhs_dom
    end

    def _add_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: `LHS + RHS' equals to `RHS + LHS'.
      #       This method invokes EqualToValueDomain#_add_greater_than.
      rhs_dom + lhs_dom
    end

    def _add_less_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS + RHS' equals to `RHS + LHS'.
      #       This method invokes LessThanValueDomain#_add_greater_than.
      rhs_dom + lhs_dom
    end

    def _add_greater_than(lhs_dom, rhs_dom = self)
      ValueDomain.greater_than(lhs_dom.value + rhs_dom.value, logical_shr?)
    end

    def *(rhs_dom)
      rhs_dom._mul_greater_than(self)
    end

    def _mul_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS * RHS' equals to `RHS * LHS'.
      #       This method invokes NilValueDomain#_mul_greater_than.
      rhs_dom * lhs_dom
    end

    def _mul_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: `LHS * RHS' equals to `RHS * LHS'.
      #       This method invokes UnlimitedValueDomain#_mul_greater_than.
      rhs_dom * lhs_dom
    end

    def _mul_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: `LHS * RHS' equals to `RHS * LHS'.
      #       This method invokes EqualToValueDomain#_mul_greater_than.
      rhs_dom * lhs_dom
    end

    def _mul_less_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS * RHS' equals to `RHS * LHS'.
      #       This method invokes LessThanValueDomain#_mul_greater_than.
      rhs_dom * lhs_dom
    end

    def _mul_greater_than(lhs_dom, rhs_dom = self)
      if lhs_dom.value >= 0
        if rhs_dom.value >= 0
          ValueDomain.greater_than(lhs_dom.value * rhs_dom.value, logical_shr?)
        else
          ValueDomain.of_unlimited(logical_shr?)
        end
      else
        if rhs_dom.value >= 0
          ValueDomain.of_unlimited(logical_shr?)
        else
          ValueDomain.of_unlimited(logical_shr?)
        end
      end
    end

    def /(rhs_dom)
      rhs_dom._div_greater_than(self)
    end

    def _div_nil(lhs_dom, rhs_dom = self)
      if rhs_dom.min_value <= 0
        ValueDomain.of_nan(logical_shr?)
      else
        lhs_dom
      end
    end

    def _div_unlimited(lhs_dom, rhs_dom = self)
      if rhs_dom.min_value <= 0
        ValueDomain.of_nan(logical_shr?)
      else
        lhs_dom
      end
    end

    def _div_equal_to(lhs_dom, rhs_dom = self)
      if rhs_dom.value <= 0
        ValueDomain.of_nan(logical_shr?)
      else
        case
        when lhs_dom.value < 0
          ValueDomain.greater_than(
            lhs_dom.value / rhs_dom.value, logical_shr?
          ).intersection(ValueDomain.less_than(
            0, logical_shr?
          ))
        when lhs_dom.value == 0
          ValueDomain.equal_to(0, logical_shr?)
        when lhs_dom.value > 0
          ValueDomain.greater_than(
            0, logical_shr?
          ).intersection(ValueDomain.less_than(
            lhs_dom.value / rhs_dom.value, logical_shr?
          ))
        end
      end
    end

    def _div_less_than(lhs_dom, rhs_dom = self)
      if rhs_dom.value < 0
        ValueDomain.of_nan(logical_shr?)
      else
        case
        when lhs_dom.value >= 0
          ValueDomain.greater_than(0, logical_shr?)
        when lhs_dom.value < 0
          ValueDomain.less_than(0, logical_shr?)
        end
      end
    end

    def _div_greater_than(lhs_dom, rhs_dom = self)
      if rhs_dom.value < 0
        ValueDomain.of_nan(logical_shr?)
      else
        case
        when lhs_dom.value <= 0
          ValueDomain.less_than(0, logical_shr?)
        when lhs_dom.value > 0
          ValueDomain.greater_than(0, logical_shr?)
        end
      end
    end

    def &(rhs_dom)
      rhs_dom.coerce_to_integer._and_greater_than(coerce_to_integer)
    end

    def _and_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS & RHS' equals to `RHS & LHS'.
      #       This method invokes NilValueDomain#_and_greater_than.
      rhs_dom & lhs_dom
    end

    def _and_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: `LHS & RHS' equals to `RHS & LHS'.
      #       This method invokes UnlimitedValueDomain#_and_greater_than.
      rhs_dom & lhs_dom
    end

    def _and_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: `LHS & RHS' equals to `RHS & LHS'.
      #       This method invokes EqualToValueDomain#_and_greater_than.
      rhs_dom & lhs_dom
    end

    def _and_less_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS & RHS' equals to `RHS & LHS'.
      #       This method invokes LessThanValueDomain#_and_greater_than.
      rhs_dom & lhs_dom
    end

    def _and_greater_than(lhs_dom, rhs_dom = self)
      if lhs_dom.value > 0 && rhs_dom.value > 0
        ValueDomain.greater_than(lhs_dom.value & rhs_dom.value, logical_shr?)
      else
        ValueDomain.of_unlimited(logical_shr?)
      end
    end

    def |(rhs_dom)
      rhs_dom.coerce_to_integer._or_greater_than(coerce_to_integer)
    end

    def _or_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS | RHS' equals to `RHS | LHS'.
      #       This method invokes NilValueDomain#_or_greater_than.
      rhs_dom | lhs_dom
    end

    def _or_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: `LHS | RHS' equals to `RHS | LHS'.
      #       This method invokes UnlimitedValueDomain#_or_greater_than.
      rhs_dom | lhs_dom
    end

    def _or_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: `LHS | RHS' equals to `RHS | LHS'.
      #       This method invokes EqualToValueDomain#_or_greater_than.
      rhs_dom | lhs_dom
    end

    def _or_less_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS | RHS' equals to `RHS | LHS'.
      #       This method invokes LessThanValueDomain#_or_greater_than.
      rhs_dom | lhs_dom
    end

    def _or_greater_than(lhs_dom, rhs_dom = self)
      ValueDomain.of_unlimited(logical_shr?)
    end

    def ^(rhs_dom)
      rhs_dom.coerce_to_integer._xor_greater_than(coerce_to_integer)
    end

    def _xor_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS ^ RHS' equals to `RHS ^ LHS'.
      #       This method invokes NilValueDomain#_xor_greater_than.
      rhs_dom ^ lhs_dom
    end

    def _xor_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: `LHS ^ RHS' equals to `RHS ^ LHS'.
      #       This method invokes UnlimitedValueDomain#_xor_greater_than.
      rhs_dom ^ lhs_dom
    end

    def _xor_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: `LHS ^ RHS' equals to `RHS ^ LHS'.
      #       This method invokes EqualToValueDomain#_xor_greater_than.
      rhs_dom ^ lhs_dom
    end

    def _xor_less_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS ^ RHS' equals to `RHS ^ LHS'.
      #       This method invokes LessThanValueDomain#_xor_greater_than.
      rhs_dom ^ lhs_dom
    end

    def _xor_greater_than(lhs_dom, rhs_dom = self)
      case
      when lhs_dom.value > 0 && rhs_dom.value > 0
        ValueDomain.greater_than(0, logical_shr?)
      when lhs_dom.value > 0 || rhs_dom.value > 0
        ValueDomain.less_than(0, logical_shr?)
      else
        ValueDomain.greater_than(0, logical_shr?)
      end
    end

    def <<(rhs_dom)
      rhs_dom.coerce_to_integer._shl_greater_than(coerce_to_integer)
    end

    def _shl_nil(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any arithmetic operation with NilValueDomain makes
      #       NilValueDomain.
      lhs_dom
    end

    def _shl_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, this arithmetic operation with UnlimitedValueDomain makes
      #       UnlimitedValueDomain because of the bit-overflow.
      # NOTE: NaN is a subclass of UnlimitedValueDomain.
      #       Arithmetic operation with UnlimitedValueDomain should make
      #       UnlimitedValueDomain, and with NaN should make NaN.
      lhs_dom
    end

    def _shl_equal_to(lhs_dom, rhs_dom = self)
      ValueDomain.greater_than(left_shift(lhs_dom.value, rhs_dom.value),
                               logical_shr?)
    end

    def _shl_less_than(lhs_dom, rhs_dom = self)
      ValueDomain.greater_than(left_shift(lhs_dom.value, rhs_dom.value),
                               logical_shr?)
    end

    def _shl_greater_than(lhs_dom, rhs_dom = self)
      ValueDomain.greater_than(left_shift(lhs_dom.value, rhs_dom.value),
                               logical_shr?)
    end

    def >>(rhs_dom)
      rhs_dom.coerce_to_integer._shr_greater_than(coerce_to_integer)
    end

    def _shr_nil(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any arithmetic operation with NilValueDomain makes
      #       NilValueDomain.
      lhs_dom
    end

    def _shr_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, this arithmetic operation with UnlimitedValueDomain makes
      #       UnlimitedValueDomain because of the bit-overflow.
      # NOTE: NaN is a subclass of UnlimitedValueDomain.
      #       Arithmetic operation with UnlimitedValueDomain should make
      #       UnlimitedValueDomain, and with NaN should make NaN.
      lhs_dom
    end

    def _shr_equal_to(lhs_dom, rhs_dom = self)
      ValueDomain.less_than(right_shift(lhs_dom.value, rhs_dom.value),
                            logical_shr?)
    end

    def _shr_less_than(lhs_dom, rhs_dom = self)
      ValueDomain.less_than(right_shift(lhs_dom.value, rhs_dom.value),
                            logical_shr?)
    end

    def _shr_greater_than(lhs_dom, rhs_dom = self)
      ValueDomain.less_than(right_shift(lhs_dom.value, rhs_dom.value),
                            logical_shr?)
    end

    def !
      if @value > 0
        ValueDomain.of_false(logical_shr?)
      else
        ValueDomain.of_unlimited(logical_shr?)
      end
    end

    def <(rhs_dom)
      rhs_dom._less_greater_than(self)
    end

    def _less_nil(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any comparison with NilValueDomain makes no sense.
      ValueDomain.of_nil(logical_shr?)
    end

    def _less_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, any comparison with UnlimitedValueDomain makes
      #       UnlimitedValueDomain.
      ValueDomain.of_unlimited(logical_shr?)
    end

    def _less_equal_to(lhs_dom, rhs_dom = self)
      if lhs_dom.value < rhs_dom.min_value
        ValueDomain.of_true(logical_shr?)
      else
        ValueDomain.of_unlimited(logical_shr?)
      end
    end

    def _less_less_than(lhs_dom, rhs_dom = self)
      if lhs_dom.max_value < rhs_dom.min_value
        ValueDomain.of_true(logical_shr?)
      else
        ValueDomain.of_unlimited(logical_shr?)
      end
    end

    def _less_greater_than(lhs_dom, rhs_dom = self)
      ValueDomain.of_unlimited(logical_shr?)
    end

    def ==(rhs_dom)
      rhs_dom._equal_greater_than(self)
    end

    def _equal_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS == RHS' equals to `RHS == LHS'.
      #       This method invokes NilValueDomain#_equal_greater_than.
      rhs_dom == lhs_dom
    end

    def _equal_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: `LHS == RHS' equals to `RHS == LHS'.
      #       This method invokes UnlimitedValueDomain#_equal_greater_than.
      rhs_dom == lhs_dom
    end

    def _equal_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: `LHS == RHS' equals to `RHS == LHS'.
      #       This method invokes EqualToValueDomain#_equal_greater_than.
      rhs_dom == lhs_dom
    end

    def _equal_less_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS == RHS' equals to `RHS == LHS'.
      #       This method invokes LessThanValueDomain#_equal_greater_than.
      rhs_dom == lhs_dom
    end

    def _equal_greater_than(lhs_dom, rhs_dom = self)
      ValueDomain.of_unlimited(logical_shr?)
    end

    def !=(rhs_dom)
      rhs_dom._not_equal_greater_than(self)
    end

    def _not_equal_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS != RHS' equals to `RHS != LHS'.
      #       This method invokes NilValueDomain#_not_equal_greater_than.
      rhs_dom != lhs_dom
    end

    def _not_equal_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: `LHS != RHS' equals to `RHS != LHS'.
      #       This method invokes UnlimitedValueDomain#_not_equal_greater_than.
      rhs_dom != lhs_dom
    end

    def _not_equal_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: `LHS != RHS' equals to `RHS != LHS'.
      #       This method invokes EqualToValueDomain#_not_equal_greater_than.
      rhs_dom != lhs_dom
    end

    def _not_equal_less_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS != RHS' equals to `RHS != LHS'.
      #       This method invokes LessThanValueDomain#_not_equal_greater_than.
      rhs_dom != lhs_dom
    end

    def _not_equal_greater_than(lhs_dom, rhs_dom = self)
      ValueDomain.of_unlimited(logical_shr?)
    end

    def logical_and(rhs_dom)
      rhs_dom._logical_and_greater_than(self)
    end

    def _logical_and_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS && RHS' equals to `RHS && LHS'.
      #       This method invokes NilValueDomain#_logical_and_greater_than.
      rhs_dom.logical_and(lhs_dom)
    end

    def _logical_and_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: `LHS && RHS' equals to `RHS && LHS'.
      #       This method invokes
      #       UnlimitedValueDomain#_logical_and_greater_than.
      rhs_dom.logical_and(lhs_dom)
    end

    def _logical_and_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: `LHS && RHS' equals to `RHS && LHS'.
      #       This method invokes EqualToValueDomain#_logical_and_greater_than.
      rhs_dom.logical_and(lhs_dom)
    end

    def _logical_and_less_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS && RHS' equals to `RHS && LHS'.
      #       This method invokes
      #       LessThanValueDomain#_logical_and_greater_than.
      rhs_dom.logical_and(lhs_dom)
    end

    def _logical_and_greater_than(lhs_dom, rhs_dom = self)
      if lhs_dom.min_value <= 0 || rhs_dom.min_value <= 0
        ValueDomain.of_unlimited(logical_shr?)
      else
        ValueDomain.of_true(logical_shr?)
      end
    end

    def logical_or(rhs_dom)
      rhs_dom._logical_or_greater_than(self)
    end

    def _logical_or_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS || RHS' equals to `RHS || LHS'.
      #       This method invokes NilValueDomain#_logical_or_greater_than.
      rhs_dom.logical_or(lhs_dom)
    end

    def _logical_or_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: `LHS || RHS' equals to `RHS || LHS'.
      #       This method invokes
      #       UnlimitedValueDomain#_logical_or_greater_than.
      rhs_dom.logical_or(lhs_dom)
    end

    def _logical_or_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: `LHS || RHS' equals to `RHS || LHS'.
      #       This method invokes EqualToValueDomain#_logical_or_greater_than.
      rhs_dom.logical_or(lhs_dom)
    end

    def _logical_or_less_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS || RHS' equals to `RHS || LHS'.
      #       This method invokes LessThanValueDomain#_logical_or_greater_than.
      rhs_dom.logical_or(lhs_dom)
    end

    def _logical_or_greater_than(lhs_dom, rhs_dom = self)
      if lhs_dom.value > 0 || rhs_dom.value > 0
        ValueDomain.of_true(logical_shr?)
      else
        ValueDomain.of_unlimited(logical_shr?)
      end
    end

    def intersection(rhs_dom)
      rhs_dom._intersection_greater_than(self)
    end

    def _intersection_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS intersection RHS' equals to `RHS intersection LHS'.
      #       This method invokes NilValueDomain#_intersection_greater_than.
      rhs_dom.intersection(lhs_dom)
    end

    def _intersection_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: `LHS intersection RHS' equals to `RHS intersection LHS'.
      #       This method invokes
      #       UnlimitedValueDomain#_intersection_greater_than.
      rhs_dom.intersection(lhs_dom)
    end

    def _intersection_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: `LHS intersection RHS' equals to `RHS intersection LHS'.
      #       This method invokes
      #       EqualToValueDomain#_intersection_greater_than.
      rhs_dom.intersection(lhs_dom)
    end

    def _intersection_less_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS intersection RHS' equals to `RHS intersection LHS'.
      #       This method invokes
      #       LessThanValueDomain#_intersection_greater_than.
      rhs_dom.intersection(lhs_dom)
    end

    def _intersection_greater_than(lhs_dom, rhs_dom = self)
      if lhs_dom.min_value <= rhs_dom.min_value
        rhs_dom
      else
        lhs_dom
      end
    end

    def union(rhs_dom)
      rhs_dom._union_greater_than(self)
    end

    def _union_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS union RHS' equals to `RHS union LHS'.
      #       This method invokes NilValueDomain#_union_greater_than.
      rhs_dom.union(lhs_dom)
    end

    def _union_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: `LHS union RHS' equals to `RHS union LHS'.
      #       This method invokes UnlimitedValueDomain#_union_greater_than.
      rhs_dom.union(lhs_dom)
    end

    def _union_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: `LHS union RHS' equals to `RHS union LHS'.
      #       This method invokes EqualToValueDomain#_union_greater_than.
      rhs_dom.union(lhs_dom)
    end

    def _union_less_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS union RHS' equals to `RHS union LHS'.
      #       This method invokes LessThanValueDomain#_union_greater_than.
      rhs_dom.union(lhs_dom)
    end

    def _union_greater_than(lhs_dom, rhs_dom = self)
      if lhs_dom.min_value <= rhs_dom.min_value
        lhs_dom
      else
        rhs_dom
      end
    end

    def coerce_to_integer
      if @value.integer?
        self
      else
        ValueDomain.greater_than(@value.to_i, logical_shr?)
      end
    end

    def coerce_to_real
      if @value.real?
        self
      else
        ValueDomain.greater_than(@value.to_f, logical_shr?)
      end
    end

    def min_value
      if @value.integer?
        @value + 1
      else
        @value + Float::EPSILON
      end
    end

    def max_value
      nil
    end

    def each_sample
      if block_given?
        yield(min_value)
        self
      else
        to_enum(:each_sample)
      end
    end

    def to_defined_domain
      self
    end

    def to_s
      "(> #{@value})"
    end
    memoize :to_s

    def complexity
      1
    end
  end

  class CompositeValueDomain < ValueDomain
    def initialize(lhs_dom, rhs_dom)
      super(lhs_dom.logical_shr? && rhs_dom.logical_shr?)
      @domain_pair = [lhs_dom, rhs_dom].sort
    end

    attr_reader :domain_pair

    def empty?
      false
    end

    def nan?
      false
    end

    def undefined?
      false
    end

    def ambiguous?
      false
    end

    def _intersect_nil?(lhs_dom, rhs_dom = self)
      # NOTE: `LHS intersect? RHS' equals to `RHS intersect? LHS'.
      #       This method invokes CompositeValueDomain#intersect?.
      rhs_dom.intersect?(lhs_dom)
    end

    def _intersect_unlimited?(lhs_dom, rhs_dom = self)
      # NOTE: `LHS intersect? RHS' equals to `RHS intersect? LHS'.
      #       This method invokes CompositeValueDomain#intersect?.
      rhs_dom.intersect?(lhs_dom)
    end

    def _intersect_equal_to?(lhs_dom, rhs_dom = self)
      # NOTE: `LHS intersect? RHS' equals to `RHS intersect? LHS'.
      #       This method invokes CompositeValueDomain#intersect?.
      rhs_dom.intersect?(lhs_dom)
    end

    def _intersect_less_than?(lhs_dom, rhs_dom = self)
      # NOTE: `LHS intersect? RHS' equals to `RHS intersect? LHS'.
      #       This method invokes CompositeValueDomain#intersect?.
      rhs_dom.intersect?(lhs_dom)
    end

    def _intersect_greater_than?(lhs_dom, rhs_dom = self)
      # NOTE: `LHS intersect? RHS' equals to `RHS intersect? LHS'.
      #       This method invokes CompositeValueDomain#intersect?.
      rhs_dom.intersect?(lhs_dom)
    end

    def _narrow_by_eq(rhs_dom, lhs_dom = self)
      lhs_dom.intersection(rhs_dom)
    end

    def _narrow_nil_by_eq(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, narrowing NilValueDomain by anything makes no effect to the
      #       target value-domain.
      lhs_dom
    end

    def _narrow_unlimited_by_eq(lhs_dom, rhs_dom = self)
      rhs_dom
    end

    def _narrow_equal_to_by_eq(lhs_dom, rhs_dom = self)
      lhs_dom.intersection(rhs_dom)
    end

    def _narrow_less_than_by_eq(lhs_dom, rhs_dom = self)
      lhs_dom.intersection(rhs_dom)
    end

    def _narrow_greater_than_by_eq(lhs_dom, rhs_dom = self)
      lhs_dom.intersection(rhs_dom)
    end

    def _narrow_by_ne(rhs_dom, lhs_dom = self)
      lhs_dom.intersection(rhs_dom.inversion)
    end

    def _narrow_nil_by_ne(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, narrowing NilValueDomain by anything makes no effect to the
      #       target value-domain.
      lhs_dom
    end

    def _narrow_unlimited_by_ne(lhs_dom, rhs_dom = self)
      rhs_dom.inversion
    end

    def _narrow_equal_to_by_ne(lhs_dom, rhs_dom = self)
      lhs_dom.intersection(rhs_dom.inversion)
    end

    def _narrow_less_than_by_ne(lhs_dom, rhs_dom = self)
      lhs_dom.intersection(rhs_dom.inversion)
    end

    def _narrow_greater_than_by_ne(lhs_dom, rhs_dom = self)
      lhs_dom.intersection(rhs_dom.inversion)
    end

    def _narrow_by_lt(rhs_dom, lhs_dom = self)
      lhs_dom.intersection(
        ValueDomain.of_unlimited(logical_shr?).narrow(Operator::LT, rhs_dom))
    end

    def _narrow_nil_by_lt(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, narrowing NilValueDomain by anything makes no effect to the
      #       target value-domain.
      lhs_dom
    end

    def _narrow_unlimited_by_lt(lhs_dom, rhs_dom = self)
      if rhs_max = rhs_dom.max_value
        ValueDomain.less_than(rhs_max, logical_shr?)
      else
        lhs_dom
      end
    end

    def _narrow_equal_to_by_lt(lhs_dom, rhs_dom = self)
      if rhs_max = rhs_dom.max_value and lhs_dom.value > rhs_max
        ValueDomain.of_nil(logical_shr?)
      else
        lhs_dom
      end
    end

    def _narrow_less_than_by_lt(lhs_dom, rhs_dom = self)
      if rhs_max = rhs_dom.max_value and lhs_dom.max_value > rhs_max
        ValueDomain.less_than(rhs_max, logical_shr?)
      else
        lhs_dom
      end
    end

    def _narrow_greater_than_by_lt(lhs_dom, rhs_dom = self)
      if rhs_max = rhs_dom.max_value and lhs_dom.min_value > rhs_max
        ValueDomain.of_nil(logical_shr?)
      else
        lhs_dom
      end
    end

    def _narrow_by_gt(rhs_dom, lhs_dom = self)
      lhs_dom.intersection(
        ValueDomain.of_unlimited(logical_shr?).narrow(Operator::GT, rhs_dom))
    end

    def _narrow_nil_by_gt(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, narrowing NilValueDomain by anything makes no effect to the
      #       target value-domain.
      lhs_dom
    end

    def _narrow_unlimited_by_gt(lhs_dom, rhs_dom = self)
      if rhs_min = rhs_dom.min_value
        ValueDomain.greater_than(rhs_min, logical_shr?)
      else
        lhs_dom
      end
    end

    def _narrow_equal_to_by_gt(lhs_dom, rhs_dom = self)
      if rhs_min = rhs_dom.min_value and lhs_dom.value < rhs_min
        ValueDomain.of_nil(logical_shr?)
      else
        lhs_dom
      end
    end

    def _narrow_less_than_by_gt(lhs_dom, rhs_dom = self)
      if rhs_min = rhs_dom.min_value and lhs_dom.max_value < rhs_min
        ValueDomain.of_nil(logical_shr?)
      else
        lhs_dom
      end
    end

    def _narrow_greater_than_by_gt(lhs_dom, rhs_dom = self)
      if rhs_min = rhs_dom.min_value and lhs_dom.min_value < rhs_min
        ValueDomain.greater_than(rhs_min, logical_shr?)
      else
        lhs_dom
      end
    end

    def _add_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS + RHS' equals to `RHS + LHS'.
      #       This method invokes CompositeValueDomain#+.
      rhs_dom + lhs_dom
    end

    def _add_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: `LHS + RHS' equals to `RHS + LHS'.
      #       This method invokes CompositeValueDomain#+.
      rhs_dom + lhs_dom
    end

    def _add_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: `LHS + RHS' equals to `RHS + LHS'.
      #       This method invokes CompositeValueDomain#+.
      rhs_dom + lhs_dom
    end

    def _add_less_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS + RHS' equals to `RHS + LHS'.
      #       This method invokes CompositeValueDomain#+.
      rhs_dom + lhs_dom
    end

    def _add_greater_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS + RHS' equals to `RHS + LHS'.
      #       This method invokes CompositeValueDomain#+.
      rhs_dom + lhs_dom
    end

    def _div_nil(lhs_dom, rhs_dom = self)
      _div(lhs_dom, rhs_dom)
    end

    def _div_unlimited(lhs_dom, rhs_dom = self)
      _div(lhs_dom, rhs_dom)
    end

    def _div_equal_to(lhs_dom, rhs_dom = self)
      _div(lhs_dom, rhs_dom)
    end

    def _div_less_than(lhs_dom, rhs_dom = self)
      _div(lhs_dom, rhs_dom)
    end

    def _div_greater_than(lhs_dom, rhs_dom = self)
      _div(lhs_dom, rhs_dom)
    end

    def _and_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS & RHS' equals to `RHS & LHS'.
      #       This method invokes CompositeValueDomain#&.
      rhs_dom & lhs_dom
    end

    def _and_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: `LHS & RHS' equals to `RHS & LHS'.
      #       This method invokes CompositeValueDomain#&.
      rhs_dom & lhs_dom
    end

    def _and_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: `LHS & RHS' equals to `RHS & LHS'.
      #       This method invokes CompositeValueDomain#&.
      rhs_dom & lhs_dom
    end

    def _and_less_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS & RHS' equals to `RHS & LHS'.
      #       This method invokes CompositeValueDomain#&.
      rhs_dom & lhs_dom
    end

    def _and_greater_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS & RHS' equals to `RHS & LHS'.
      #       This method invokes CompositeValueDomain#&.
      rhs_dom & lhs_dom
    end

    def _or_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS | RHS' equals to `RHS | LHS'.
      #       This method invokes CompositeValueDomain#|.
      rhs_dom | lhs_dom
    end

    def _or_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: `LHS | RHS' equals to `RHS | LHS'.
      #       This method invokes CompositeValueDomain#|.
      rhs_dom | lhs_dom
    end

    def _or_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: `LHS | RHS' equals to `RHS | LHS'.
      #       This method invokes CompositeValueDomain#|.
      rhs_dom | lhs_dom
    end

    def _or_less_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS | RHS' equals to `RHS | LHS'.
      #       This method invokes CompositeValueDomain#|.
      rhs_dom | lhs_dom
    end

    def _or_greater_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS | RHS' equals to `RHS | LHS'.
      #       This method invokes CompositeValueDomain#|.
      rhs_dom | lhs_dom
    end

    def _xor_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS ^ RHS' equals to `RHS ^ LHS'.
      #       This method invokes CompositeValueDomain#^.
      rhs_dom ^ lhs_dom
    end

    def _xor_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: `LHS ^ RHS' equals to `RHS ^ LHS'.
      #       This method invokes CompositeValueDomain#^.
      rhs_dom ^ lhs_dom
    end

    def _xor_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: `LHS ^ RHS' equals to `RHS ^ LHS'.
      #       This method invokes CompositeValueDomain#^.
      rhs_dom ^ lhs_dom
    end

    def _xor_less_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS ^ RHS' equals to `RHS ^ LHS'.
      #       This method invokes CompositeValueDomain#^.
      rhs_dom ^ lhs_dom
    end

    def _xor_greater_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS ^ RHS' equals to `RHS ^ LHS'.
      #       This method invokes CompositeValueDomain#^.
      rhs_dom ^ lhs_dom
    end

    def _shl_nil(lhs_dom, rhs_dom = self)
      _shl(lhs_dom, rhs_dom)
    end

    def _shl_unlimited(lhs_dom, rhs_dom = self)
      _shl(lhs_dom, rhs_dom)
    end

    def _shl_equal_to(lhs_dom, rhs_dom = self)
      _shl(lhs_dom, rhs_dom)
    end

    def _shl_less_than(lhs_dom, rhs_dom = self)
      _shl(lhs_dom, rhs_dom)
    end

    def _shl_greater_than(lhs_dom, rhs_dom = self)
      _shl(lhs_dom, rhs_dom)
    end

    def _shr_nil(lhs_dom, rhs_dom = self)
      _shr(lhs_dom, rhs_dom)
    end

    def _shr_unlimited(lhs_dom, rhs_dom = self)
      _shr(lhs_dom, rhs_dom)
    end

    def _shr_equal_to(lhs_dom, rhs_dom = self)
      _shr(lhs_dom, rhs_dom)
    end

    def _shr_less_than(lhs_dom, rhs_dom = self)
      _shr(lhs_dom, rhs_dom)
    end

    def _shr_greater_than(lhs_dom, rhs_dom = self)
      _shr(lhs_dom, rhs_dom)
    end

    def _less_nil(lhs_dom, rhs_dom = self)
      _less(lhs_dom, rhs_dom)
    end

    def _less_unlimited(lhs_dom, rhs_dom = self)
      _less(lhs_dom, rhs_dom)
    end

    def _less_equal_to(lhs_dom, rhs_dom = self)
      _less(lhs_dom, rhs_dom)
    end

    def _less_less_than(lhs_dom, rhs_dom = self)
      _less(lhs_dom, rhs_dom)
    end

    def _less_greater_than(lhs_dom, rhs_dom = self)
      _less(lhs_dom, rhs_dom)
    end

    def ==(rhs_dom)
      _equal(rhs_dom, self)
    end

    def _equal_nil(lhs_dom, rhs_dom = self)
      _equal(lhs_dom, rhs_dom)
    end

    def _equal_unlimited(lhs_dom, rhs_dom = self)
      _equal(lhs_dom, rhs_dom)
    end

    def _equal_equal_to(lhs_dom, rhs_dom = self)
      _equal(lhs_dom, rhs_dom)
    end

    def _equal_less_than(lhs_dom, rhs_dom = self)
      _equal(lhs_dom, rhs_dom)
    end

    def _equal_greater_than(lhs_dom, rhs_dom = self)
      _equal(lhs_dom, rhs_dom)
    end

    def !=(rhs_dom)
      _not_equal(rhs_dom, self)
    end

    def _not_equal_nil(lhs_dom, rhs_dom = self)
      _not_equal(lhs_dom, rhs_dom)
    end

    def _not_equal_unlimited(lhs_dom, rhs_dom = self)
      _not_equal(lhs_dom, rhs_dom)
    end

    def _not_equal_equal_to(lhs_dom, rhs_dom = self)
      _not_equal(lhs_dom, rhs_dom)
    end

    def _not_equal_less_than(lhs_dom, rhs_dom = self)
      _not_equal(lhs_dom, rhs_dom)
    end

    def _not_equal_greater_than(lhs_dom, rhs_dom = self)
      _not_equal(lhs_dom, rhs_dom)
    end

    def _logical_and_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS && RHS' equals to `RHS && LHS'.
      #       This method invokes CompositeValueDomain#logical_and.
      rhs_dom.logical_and(lhs_dom)
    end

    def _logical_and_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: `LHS && RHS' equals to `RHS && LHS'.
      #       This method invokes CompositeValueDomain#logical_and.
      rhs_dom.logical_and(lhs_dom)
    end

    def _logical_and_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: `LHS && RHS' equals to `RHS && LHS'.
      #       This method invokes CompositeValueDomain#logical_and.
      rhs_dom.logical_and(lhs_dom)
    end

    def _logical_and_less_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS && RHS' equals to `RHS && LHS'.
      #       This method invokes CompositeValueDomain#logical_and.
      rhs_dom.logical_and(lhs_dom)
    end

    def _logical_and_greater_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS && RHS' equals to `RHS && LHS'.
      #       This method invokes CompositeValueDomain#logical_and.
      rhs_dom.logical_and(lhs_dom)
    end

    def _logical_or_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS || RHS' equals to `RHS || LHS'.
      #       This method invokes CompositeValueDomain#logical_or.
      rhs_dom.logical_or(lhs_dom)
    end

    def _logical_or_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: `LHS || RHS' equals to `RHS || LHS'.
      #       This method invokes CompositeValueDomain#logical_or.
      rhs_dom.logical_or(lhs_dom)
    end

    def _logical_or_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: `LHS || RHS' equals to `RHS || LHS'.
      #       This method invokes CompositeValueDomain#logical_or.
      rhs_dom.logical_or(lhs_dom)
    end

    def _logical_or_less_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS || RHS' equals to `RHS || LHS'.
      #       This method invokes CompositeValueDomain#logical_or.
      rhs_dom.logical_or(lhs_dom)
    end

    def _logical_or_greater_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS || RHS' equals to `RHS || LHS'.
      #       This method invokes CompositeValueDomain#logical_or.
      rhs_dom.logical_or(lhs_dom)
    end

    def _intersection_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS intersection RHS' equals to `RHS intersection LHS'.
      #       This method invokes CompositeValueDomain#intersection which
      #       should be overriden by IntersectionValueDomain and
      #       UnionValueDomain.
      rhs_dom.intersection(lhs_dom)
    end

    def _intersection_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: `LHS intersection RHS' equals to `RHS intersection LHS'.
      #       This method invokes CompositeValueDomain#intersection which
      #       should be overriden by IntersectionValueDomain and
      #       UnionValueDomain.
      rhs_dom.intersection(lhs_dom)
    end

    def _intersection_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: `LHS intersection RHS' equals to `RHS intersection LHS'.
      #       This method invokes CompositeValueDomain#intersection which
      #       should be overriden by IntersectionValueDomain and
      #       UnionValueDomain.
      rhs_dom.intersection(lhs_dom)
    end

    def _intersection_less_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS intersection RHS' equals to `RHS intersection LHS'.
      #       This method invokes CompositeValueDomain#intersection which
      #       should be overriden by IntersectionValueDomain and
      #       UnionValueDomain.
      rhs_dom.intersection(lhs_dom)
    end

    def _intersection_greater_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS intersection RHS' equals to `RHS intersection LHS'.
      #       This method invokes CompositeValueDomain#intersection which
      #       should be overriden by IntersectionValueDomain and
      #       UnionValueDomain.
      rhs_dom.intersection(lhs_dom)
    end

    def _union_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS union RHS' equals to `RHS union LHS'.
      #       This method invokes CompositeValueDomain#union which should be
      #       overriden by IntersectionValueDomain and UnionValueDomain.
      rhs_dom.union(lhs_dom)
    end

    def _union_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: `LHS union RHS' equals to `RHS union LHS'.
      #       This method invokes CompositeValueDomain#union which should be
      #       overriden by IntersectionValueDomain and UnionValueDomain.
      rhs_dom.union(lhs_dom)
    end

    def _union_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: `LHS union RHS' equals to `RHS union LHS'.
      #       This method invokes CompositeValueDomain#union which should be
      #       overriden by IntersectionValueDomain and UnionValueDomain.
      rhs_dom.union(lhs_dom)
    end

    def _union_less_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS union RHS' equals to `RHS union LHS'.
      #       This method invokes CompositeValueDomain#union which should be
      #       overriden by IntersectionValueDomain and UnionValueDomain.
      rhs_dom.union(lhs_dom)
    end

    def _union_greater_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS union RHS' equals to `RHS union LHS'.
      #       This method invokes CompositeValueDomain#union which should be
      #       overriden by IntersectionValueDomain and UnionValueDomain.
      rhs_dom.union(lhs_dom)
    end

    def to_defined_domain
      self
    end

    def complexity
      domain_pair.map { |dom| dom.complexity + 1 }.max
    end

    private
    def _div(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _shl(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _shr(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _less(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _equal(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end

    def _not_equal(lhs_dom, rhs_dom = self)
      subclass_responsibility
    end
  end

  class IntersectionValueDomain < CompositeValueDomain
    def contain_value_domain?(rhs_dom)
      rhs_dom._contain_intersection?(self)
    end

    def _contain_nil?(lhs_dom, rhs_dom = self)
      false
    end

    def _contain_unlimited?(lhs_dom, rhs_dom = self)
      true
    end

    def _contain_equal_to?(lhs_dom, rhs_dom = self)
      rhs_dom.domain_pair.any? { |rhs| lhs_dom.contain_value_domain?(rhs) }
    end

    def _contain_less_than?(lhs_dom, rhs_dom = self)
      rhs_dom.domain_pair.any? { |rhs| lhs_dom.contain_value_domain?(rhs) }
    end

    def _contain_greater_than?(lhs_dom, rhs_dom = self)
      rhs_dom.domain_pair.any? { |rhs| lhs_dom.contain_value_domain?(rhs) }
    end

    def _contain_intersection?(lhs_dom, rhs_dom = self)
      lhs_fst, lhs_snd = lhs_dom.domain_pair
      rhs_fst, rhs_snd = rhs_dom.domain_pair
      case
      when lhs_fst.contain_value_domain?(rhs_fst) &&
           lhs_snd.contain_value_domain?(rhs_snd)
        true
      when lhs_fst.contain_value_domain?(rhs_snd) &&
           lhs_snd.contain_value_domain?(rhs_fst)
        true
      else
        false
      end
    end

    def _contain_union?(lhs_dom, rhs_dom = self)
      lhs_dom.domain_pair.any? { |lhs| lhs.contain_value_domain?(rhs_dom) }
    end

    def intersect?(rhs_dom)
      domain_pair.all? { |lhs| lhs.intersect?(rhs_dom) }
    end

    def inversion
      new_sub_doms = domain_pair.map { |dom| dom.inversion }
      new_sub_doms.first.union(new_sub_doms.last)
    end

    def ~
      new_sub_doms = domain_pair.map { |dom| ~dom }
      new_sub_doms.first.intersection(new_sub_doms.last)
    end

    def +@
      new_sub_doms = domain_pair.map { |dom| +dom }
      new_sub_doms.first.intersection(new_sub_doms.last)
    end

    def -@
      new_sub_doms = domain_pair.map { |dom| -dom }
      new_sub_doms.first.intersection(new_sub_doms.last)
    end

    def +(rhs_dom)
      new_sub_doms = domain_pair.map { |lhs| lhs + rhs_dom }
      new_sub_doms.first.intersection(new_sub_doms.last)
    end

    def *(rhs_dom)
      # NOTE: Multiplication of LessThanValueDomain or GreaterThanValueDomain
      #       always makes UnlimitedValueDomain when the domain contains both
      #       positive and negative values.
      #       So, multiplication of IntersectionValueDomain cannot be defined
      #       in the same manner as other arithmetics.
      if rhs_dom.kind_of?(IntersectionValueDomain)
        lhs_dom = self

        lval = [
          (n = lhs_dom.min_value).integer? ? n - 1 : n - Float::EPSILON,
          (n = lhs_dom.max_value).integer? ? n + 1 : n + Float::EPSILON
        ]
        labs = lval.map { |val| val.abs }.sort

        rval = [
          (n = rhs_dom.min_value).integer? ? n - 1 : n - Float::EPSILON,
          (n = rhs_dom.max_value).integer? ? n + 1 : n + Float::EPSILON
        ]
        rabs = rval.map { |val| val.abs }.sort

        comp = lambda { |op, nums| nums.all? { |num| num.__send__(op, 0) } }
        only_negative, only_positive = comp.curry[:<], comp.curry[:>=]

        case lval
        when only_positive
          case rval
          when only_positive
            _mul_only_positive_and_only_positive(lval, labs, rval, rabs)
          when only_negative
            _mul_only_positive_and_only_negative(lval, labs, rval, rabs)
          else
            _mul_only_positive_and_positive_negative(lval, labs, rval, rabs)
          end
        when only_negative
          case rval
          when only_positive
            _mul_only_positive_and_only_negative(rval, rabs, lval, labs)
          when only_negative
            _mul_only_negative_and_only_negative(lval, labs, rval, rabs)
          else
            _mul_only_negative_and_positive_negative(lval, labs, rval, rabs)
          end
        else
          _mul_positive_negative_and_positive_negative(lval, labs, rval, rabs)
        end
      else
        rhs_dom * self
      end
    end

    def _mul_nil(lhs_dom, rhs_dom = self)
      # NOTE: NilValueDomain contains no values.
      #       So, any arithmetic operation with NilValueDomain makes
      #       NilValueDomain.
      lhs_dom
    end

    def _mul_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: UnlimitedValueDomain contains everything.
      #       So, this arithmetic operation with UnlimitedValueDomain makes
      #       UnlimitedValueDomain.
      lhs_dom
    end

    def _mul_equal_to(lhs_dom, rhs_dom = self)
      new_sub_doms = rhs_dom.domain_pair.map { |rhs| lhs_dom * rhs }
      new_sub_doms.first.intersection(new_sub_doms.last)
    end

    def _mul_less_than(lhs_dom, rhs_dom = self)
      new_sub_doms = rhs_dom.domain_pair.map { |rhs| lhs_dom * rhs }
      new_sub_doms.first.intersection(new_sub_doms.last)
    end

    def _mul_greater_than(lhs_dom, rhs_dom = self)
      new_sub_doms = rhs_dom.domain_pair.map { |rhs| lhs_dom * rhs }
      new_sub_doms.first.intersection(new_sub_doms.last)
    end

    def /(rhs_dom)
      new_sub_doms = domain_pair.map { |lhs| lhs / rhs_dom }
      new_sub_doms.first.intersection(new_sub_doms.last)
    end

    def &(rhs_dom)
      new_sub_doms = domain_pair.map { |lhs| lhs & rhs_dom }
      new_sub_doms.first.intersection(new_sub_doms.last)
    end

    def |(rhs_dom)
      new_sub_doms = domain_pair.map { |lhs| lhs | rhs_dom }
      new_sub_doms.first.intersection(new_sub_doms.last)
    end

    def ^(rhs_dom)
      new_sub_doms = domain_pair.map { |lhs| lhs ^ rhs_dom }
      new_sub_doms.first.intersection(new_sub_doms.last)
    end

    def <<(rhs_dom)
      new_sub_doms = domain_pair.map { |lhs| lhs << rhs_dom }
      new_sub_doms.first.intersection(new_sub_doms.last)
    end

    def >>(rhs_dom)
      new_sub_doms = domain_pair.map { |lhs| lhs >> rhs_dom }
      new_sub_doms.first.intersection(new_sub_doms.last)
    end

    def !
      new_sub_doms = domain_pair.map { |dom| !dom }
      new_sub_doms.first.intersection(new_sub_doms.last)
    end

    def <(rhs_dom)
      # NOTE: The intersection value domain must be a close-domain (--<===>--).
      if intersect?(rhs_dom)
        if rhs_dom.max_value && rhs_dom.max_value == min_value
          ValueDomain.of_false(logical_shr?)
        else
          ValueDomain.of_unlimited(logical_shr?)
        end
      else
        # NOTE: When value domains are not intersected, the RHS value domain is
        #       in the left or right of the LHS intersection value domain.
        if rhs_dom.min_value && max_value < rhs_dom.min_value
          # NOTE: The RHS value domain is in the right of the LHS intersection
          #       value domain.
          ValueDomain.of_true(logical_shr?)
        else
          # NOTE: The RHS value domain is in the left of the LHS intersection
          #       value domain.
          ValueDomain.of_false(logical_shr?)
        end
      end
    end

    def logical_and(rhs_dom)
      new_sub_doms = domain_pair.map { |lhs| lhs.logical_and(rhs_dom) }
      new_sub_doms.first.intersection(new_sub_doms.last)
    end

    def logical_or(rhs_dom)
      new_sub_doms = domain_pair.map { |lhs| lhs.logical_or(rhs_dom) }
      new_sub_doms.first.intersection(new_sub_doms.last)
    end

    def intersection(rhs_dom)
      if rhs_dom.kind_of?(UnionValueDomain)
        return rhs_dom.intersection(self)
      end

      case
      when contain_value_domain?(rhs_dom)
        rhs_dom
      when rhs_dom.contain_value_domain?(self)
        self
      else
        new_sub_doms = domain_pair.map { |lhs| lhs.intersection(rhs_dom) }
        ValueDomain.of_intersection(*new_sub_doms)
      end
    end

    def union(rhs_dom)
      case
      when contain_value_domain?(rhs_dom)
        self
      when rhs_dom.contain_value_domain?(self)
        rhs_dom
      else
        ValueDomain.of_union(self, rhs_dom)
      end
    end

    def coerce_to_integer
      new_sub_doms = domain_pair.map { |dom| dom.coerce_to_integer }
      new_sub_doms.first.intersection(new_sub_doms.last)
    end

    def coerce_to_real
      new_sub_doms = domain_pair.map { |dom| dom.coerce_to_real }
      new_sub_doms.first.intersection(new_sub_doms.last)
    end

    def min_value
      # NOTE: Intersection-value-domain must be a close-domain (---<=====>---).
      #       So, min-value is defined by the lower greater-than value domain.
      domain_pair.map { |dom| dom.min_value }.compact.min
    end
    memoize :min_value

    def max_value
      # NOTE: Intersection-value-domain must be a close-domain (---<=====>---).
      #       So, max-value is defined by the higher lower-than value domain.
      domain_pair.map { |dom| dom.max_value }.compact.max
    end
    memoize :max_value

    def each_sample
      return to_enum(:each_sample) unless block_given?
      domain_pair.map { |d| d.each_sample.to_a }.flatten.uniq.each do |sample|
        yield(sample) if contain?(sample)
      end
    end

    def to_s
      "(#{domain_pair.first.to_s} && #{domain_pair.last.to_s})"
    end
    memoize :to_s

    private
    def _mul_only_positive_and_only_positive(lval, labs, rval, rabs)
      # NOTE: (++) * (++) makes a new IntersectionValueDomain;
      #         lower bound: (labs.min * rabs.min)
      #         upper bound: (labs.max * rabs.max)
      ValueDomain.greater_than(
        labs.first * rabs.first, logical_shr?
      ).intersection(ValueDomain.less_than(
        labs.last * rabs.last, logical_shr?
      ))
    end

    def _mul_only_positive_and_only_negative(lval, labs, rval, rabs)
      # NOTE: (++) * (--) makes a new IntersectionValueDomain;
      #         lower bound: -(labs.max * rabs.max)
      #         upper bound: -(labs.min * rabs.min)
      ValueDomain.greater_than(
        -(labs.last * rabs.last), logical_shr?
      ).intersection(ValueDomain.less_than(
        -(labs.first * rabs.first), logical_shr?
      ))
    end

    def _mul_only_positive_and_positive_negative(lval, labs, rval, rabs)
      # NOTE: (++) * (-+) makes a new IntersectionValueDomain;
      #         lower bound: (labs.max * rval.min)
      #         upper bound: (labs.max * rval.max)
      ValueDomain.greater_than(
        labs.last * rval.first, logical_shr?
      ).intersection(ValueDomain.less_than(
        labs.last * rval.last, logical_shr?
      ))
    end

    def _mul_only_negative_and_only_negative(lval, labs, rval, rabs)
      # NOTE: (--) * (--) makes a new IntersectionValueDomain;
      #         upper bound: (labs.min * rabs.min)
      #         lower bound: (labs.max * rabs.max)
      ValueDomain.greater_than(
        labs.first * rabs.first, logical_shr?
      ).intersection(ValueDomain.less_than(
        labs.last * rabs.last, logical_shr?
      ))
    end

    def _mul_only_negative_and_positive_negative(lval, labs, rval, rabs)
      # NOTE: (--) * (-+) makes a new IntersectionValueDomain;
      #         lower bound: -(labs.max * rval.max)
      #         upper_bound: -(labs.max * rval.min)
      ValueDomain.greater_than(
        -(labs.last * rval.last), logical_shr?
      ).intersection(ValueDomain.less_than(
        -(labs.last * rval.first), logical_shr?
      ))
    end

    def _mul_positive_negative_and_positive_negative(lval, labs, rval, rabs)
      # NOTE: (-+) * (-+) makes a new IntersectionValueDomain;
      #         lower bound: ([lval.min * rval.max, lval.max * rval.min].min)
      #         upper bound: ([lval.min * rval.min, lval.max * rval.max].max)
      ValueDomain.greater_than(
        [lval.first * rval.last, lval.last * rval.first].min, logical_shr?
      ).intersection(ValueDomain.less_than(
        [lval.first * rval.first, lval.last, rval.last].max, logical_shr?
      ))
    end

    def _div(lhs_dom, rhs_dom = self)
      new_sub_doms = rhs_dom.domain_pair.map { |rhs| lhs_dom / rhs }
      new_sub_doms.first.intersection(new_sub_doms.last)
    end

    def _shl(lhs_dom, rhs_dom = self)
      new_sub_doms = rhs_dom.domain_pair.map { |rhs| lhs_dom << rhs }
      new_sub_doms.first.intersection(new_sub_doms.last)
    end

    def _shr(lhs_dom, rhs_dom = self)
      new_sub_doms = rhs_dom.domain_pair.map { |rhs| lhs_dom >> rhs }
      new_sub_doms.first.intersection(new_sub_doms.last)
    end

    def _less(lhs_dom, rhs_dom = self)
      comp_dom = rhs_dom.domain_pair.map { |rhs| lhs_dom < rhs }
      if comp_dom.any? { |dom| dom.eql?(ValueDomain.of_false(logical_shr?)) }
        ValueDomain.of_false(logical_shr?)
      else
        comp_dom.first.intersection(comp_dom.last)
      end
    end

    def _equal(lhs_dom, rhs_dom = self)
      # NOTE: The intersection value domain must be a close-domain (--<===>--).
      #       If one of the sub domains is not equal to LHS, result should be
      #       false.
      comp_dom = rhs_dom.domain_pair.map { |rhs| lhs_dom == rhs }
      if comp_dom.any? { |dom| dom.eql?(ValueDomain.of_false(logical_shr?)) }
        ValueDomain.of_false(logical_shr?)
      else
        comp_dom.first.intersection(comp_dom.last)
      end
    end

    def _not_equal(lhs_dom, rhs_dom = self)
      # NOTE: The intersection value domain must be a close-domain (--<===>--).
      #       If one of the sub domains is not equal to LHS, result should be
      #       true.
      comp_dom = rhs_dom.domain_pair.map { |rhs| lhs_dom != rhs }
      if comp_dom.any? { |dom| dom.eql?(ValueDomain.of_false(logical_shr?)) }
        ValueDomain.of_false(logical_shr?)
      else
        comp_dom.first.intersection(comp_dom.last)
      end
    end
  end

  class UnionValueDomain < CompositeValueDomain
    def contain_value_domain?(rhs_dom)
      rhs_dom._contain_union?(self)
    end

    def _contain_nil?(lhs_dom, rhs_dom = self)
      false
    end

    def _contain_unlimited?(lhs_dom, rhs_dom = self)
      true
    end

    def _contain_equal_to?(lhs_dom, rhs_dom = self)
      rhs_dom.domain_pair.all? { |rhs| lhs_dom.contain_value_domain?(rhs) }
    end

    def _contain_less_than?(lhs_dom, rhs_dom = self)
      rhs_dom.domain_pair.all? { |rhs| lhs_dom.contain_value_domain?(rhs) }
    end

    def _contain_greater_than?(lhs_dom, rhs_dom = self)
      rhs_dom.domain_pair.all? { |rhs| lhs_dom.contain_value_domain?(rhs) }
    end

    def _contain_intersection?(lhs_dom, rhs_dom = self)
      rhs_dom.domain_pair.all? { |rhs| lhs_dom.contain_value_domain?(rhs) }
    end

    def _contain_union?(lhs_dom, rhs_dom = self)
      lhs_fst, lhs_snd = lhs_dom.domain_pair
      rhs_dom_pair = rhs_dom.domain_pair
      case
      when rhs_dom_pair.all? { |rhs| lhs_fst.contain_value_domain?(rhs) }
        true
      when rhs_dom_pair.all? { |rhs| lhs_snd.contain_value_domain?(rhs) }
        true
      else
        rhs_fst, rhs_snd = rhs_dom.domain_pair
        case
        when lhs_fst.contain_value_domain?(rhs_fst) &&
             lhs_snd.contain_value_domain?(rhs_snd)
          true
        when lhs_fst.contain_value_domain?(rhs_snd) &&
             lhs_snd.contain_value_domain?(rhs_fst)
          true
        else
          false
        end
      end
    end

    def intersect?(rhs_dom)
      domain_pair.any? { |lhs| lhs.intersect?(rhs_dom) }
    end

    def inversion
      new_sub_doms = domain_pair.map { |dom| dom.inversion }
      new_sub_doms.first.intersection(new_sub_doms.last)
    end

    def ~
      new_sub_doms = domain_pair.map { |dom| ~dom }
      new_sub_doms.first.union(new_sub_doms.last)
    end

    def +@
      new_sub_doms = domain_pair.map { |dom| +dom }
      new_sub_doms.first.union(new_sub_doms.last)
    end

    def -@
      new_sub_doms = domain_pair.map { |dom| -dom }
      new_sub_doms.first.union(new_sub_doms.last)
    end

    def +(rhs_dom)
      new_sub_doms = domain_pair.map { |lhs| lhs + rhs_dom }
      new_sub_doms.first.union(new_sub_doms.last)
    end

    def *(rhs_dom)
      new_sub_doms = domain_pair.map { |lhs| lhs * rhs_dom }
      new_sub_doms.first.union(new_sub_doms.last)
    end

    def _mul_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS * RHS' equals to `RHS * LHS'.
      #       This method invokes CompositeValueDomain#*.
      rhs_dom * lhs_dom
    end

    def _mul_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: `LHS * RHS' equals to `RHS * LHS'.
      #       This method invokes CompositeValueDomain#*.
      rhs_dom * lhs_dom
    end

    def _mul_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: `LHS * RHS' equals to `RHS * LHS'.
      #       This method invokes CompositeValueDomain#*.
      rhs_dom * lhs_dom
    end

    def _mul_less_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS * RHS' equals to `RHS * LHS'.
      #       This method invokes CompositeValueDomain#*.
      rhs_dom * lhs_dom
    end

    def _mul_greater_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS * RHS' equals to `RHS * LHS'.
      #       This method invokes CompositeValueDomain#*.
      rhs_dom * lhs_dom
    end

    def /(rhs_dom)
      new_sub_doms = domain_pair.map { |lhs| lhs / rhs_dom }
      new_sub_doms.first.union(new_sub_doms.last)
    end

    def &(rhs_dom)
      new_sub_doms = domain_pair.map { |lhs| lhs & rhs_dom }
      new_sub_doms.first.union(new_sub_doms.last)
    end

    def |(rhs_dom)
      new_sub_doms = domain_pair.map { |lhs| lhs | rhs_dom }
      new_sub_doms.first.union(new_sub_doms.last)
    end

    def ^(rhs_dom)
      new_sub_doms = domain_pair.map { |lhs| lhs ^ rhs_dom }
      new_sub_doms.first.union(new_sub_doms.last)
    end

    def <<(rhs_dom)
      new_sub_doms = domain_pair.map { |lhs| lhs << rhs_dom }
      new_sub_doms.first.union(new_sub_doms.last)
    end

    def >>(rhs_dom)
      new_sub_doms = domain_pair.map { |lhs| lhs >> rhs_dom }
      new_sub_doms.first.union(new_sub_doms.last)
    end

    def !
      new_sub_doms = domain_pair.map { |dom| !dom }
      new_sub_doms.first.union(new_sub_doms.last)
    end

    def <(rhs_dom)
      comp_dom = domain_pair.map { |lhs| lhs < rhs_dom }
      comp_dom.first.union(comp_dom.last)
    end

    def logical_and(rhs_dom)
      new_sub_doms = domain_pair.map { |lhs| lhs.logical_and(rhs_dom) }
      new_sub_doms.first.union(new_sub_doms.last)
    end

    def logical_or(rhs_dom)
      new_sub_doms = domain_pair.map { |lhs| lhs.logical_or(rhs_dom) }
      new_sub_doms.first.union(new_sub_doms.last)
    end

    def intersection(rhs_dom)
      case
      when contain_value_domain?(rhs_dom)
        rhs_dom
      when rhs_dom.contain_value_domain?(self)
        self
      else
        new_sub_doms = domain_pair.map { |lhs| lhs.intersection(rhs_dom) }
        ValueDomain.of_union(*new_sub_doms)
      end
    end

    def union(rhs_dom)
      case
      when contain_value_domain?(rhs_dom)
        self
      when rhs_dom.contain_value_domain?(self)
        rhs_dom
      else
        new_sub_doms = domain_pair.map { |lhs| lhs.union(rhs_dom) }
        ValueDomain.of_union(*new_sub_doms)
      end
    end

    def coerce_to_integer
      new_sub_doms = domain_pair.map { |dom| dom.coerce_to_integer }
      new_sub_doms.first.union(new_sub_doms.last)
    end

    def coerce_to_real
      new_sub_doms = domain_pair.map { |dom| dom.coerce_to_real }
      new_sub_doms.first.union(new_sub_doms.last)
    end

    def min_value
      # NOTE: The union value domain may be a open-domain (==>---<==),
      #       a half-open-domain (==>--<==>-) or (-<==>--<==), or
      #       a close-domain (-<==>-<==>-).
      #       When the union value domain is a open-domain, the min-value is
      #       -infinite.
      #       When the union value domain is a half-open-domain and lower sub
      #       domain is less-than value domain, the min-value is -infinite.
      #       When the union value domain is a half-open-domain and higher sub
      #       domain is greater-than value domain, the min-value is defined by
      #       the lower value domain.
      #       When the union value domain is a close-domain, the min-value is
      #       defined by the lower value domain.
      min_vals = domain_pair.map { |dom| dom.min_value }
      min_vals.include?(nil) ? nil : min_vals.min
    end
    memoize :min_value

    def max_value
      # NOTE: If this is an "open-domain" (===>---<===), max-value is
      #       undefined.
      #       But, when the domain is (===>--<===>--), max-value is defined.
      max_vals = domain_pair.map { |dom| dom.max_value }
      max_vals.include?(nil) ? nil : max_vals.max
    end
    memoize :max_value

    def each_sample
      return to_enum(:each_sample) unless block_given?
      domain_pair.map { |d| d.each_sample.to_a }.flatten.uniq.each do |sample|
        yield(sample)
      end
    end

    def to_s
      "(#{domain_pair.first.to_s} || #{domain_pair.last.to_s})"
    end
    memoize :to_s

    private
    def _div(lhs_dom, rhs_dom = self)
      new_sub_doms = rhs_dom.domain_pair.map { |rhs| lhs_dom / rhs }
      new_sub_doms.first.union(new_sub_doms.last)
    end

    def _shl(lhs_dom, rhs_dom = self)
      new_sub_doms = rhs_dom.domain_pair.map { |rhs| lhs_dom << rhs }
      new_sub_doms.first.union(new_sub_doms.last)
    end

    def _shr(lhs_dom, rhs_dom = self)
      new_sub_doms = rhs_dom.domain_pair.map { |rhs| lhs_dom >> rhs }
      new_sub_doms.first.union(new_sub_doms.last)
    end

    def _less(lhs_dom, rhs_dom = self)
      comp_dom = rhs_dom.domain_pair.map { |rhs| lhs_dom < rhs }
      comp_dom.first.union(comp_dom.last)
    end

    def _equal(lhs_dom, rhs_dom = self)
      # NOTE: The union value domain may be a open-domain (==>---<==),
      #       a half-open-domain (==>--<==>-) or (-<==>--<==), or
      #       a close-domain (-<==>-<==>-).
      #       If one of the sub domains is equal to LHS, result should be true.
      comp_dom = rhs_dom.domain_pair.map { |rhs| lhs_dom == rhs }
      comp_dom.first.union(comp_dom.last)
    end

    def _not_equal(lhs_dom, rhs_dom = self)
      # NOTE: The union value domain may be a open-domain (==>---<==),
      #       a half-open-domain (==>--<==>-) or (-<==>--<==), or
      #       a close-domain (-<==>-<==>-).
      #       If one of the sub domains is equal to LHS, result should be
      #       false.
      comp_dom = rhs_dom.domain_pair.map { |rhs| lhs_dom != rhs }
      comp_dom.first.union(comp_dom.last)
    end
  end

  class UndefinedValueDomain < ValueDomain
    extend Forwardable

    def initialize(dom)
      super(dom.logical_shr?)
      @domain = dom
    end

    attr_reader :domain

    def_delegator :@domain, :empty?

    def nan?
      false
    end

    def undefined?
      true
    end

    def ambiguous?
      false
    end

    def_delegator :@domain, :contain?
    def_delegator :@domain, :contain_value_domain?
    def_delegator :@domain, :_contain_nil?
    def_delegator :@domain, :_contain_unlimited?
    def_delegator :@domain, :_contain_equal_to?
    def_delegator :@domain, :_contain_less_than?
    def_delegator :@domain, :_contain_greater_than?
    def_delegator :@domain, :_contain_intersection?
    def_delegator :@domain, :_contain_union?
    def_delegator :@domain, :intersect?
    def_delegator :@domain, :_intersect_nil?
    def_delegator :@domain, :_intersect_unlimited?
    def_delegator :@domain, :_intersect_equal_to?
    def_delegator :@domain, :_intersect_less_than?
    def_delegator :@domain, :_intersect_greater_than?

    def _narrow_by_eq(rhs_dom, lhs_dom = self)
      ValueDomain.of_undefined(lhs_dom.domain._narrow_by_eq(rhs_dom))
    end

    def_delegator :@domain, :_narrow_nil_by_eq
    def_delegator :@domain, :_narrow_unlimited_by_eq
    def_delegator :@domain, :_narrow_equal_to_by_eq
    def_delegator :@domain, :_narrow_less_than_by_eq
    def_delegator :@domain, :_narrow_greater_than_by_eq

    def _narrow_by_ne(rhs_dom, lhs_dom = self)
      ValueDomain.of_undefined(lhs_dom.domain._narrow_by_ne(rhs_dom))
    end

    def_delegator :@domain, :_narrow_nil_by_ne
    def_delegator :@domain, :_narrow_unlimited_by_ne
    def_delegator :@domain, :_narrow_equal_to_by_ne
    def_delegator :@domain, :_narrow_less_than_by_ne
    def_delegator :@domain, :_narrow_greater_than_by_ne

    def _narrow_by_lt(rhs_dom, lhs_dom = self)
      ValueDomain.of_undefined(lhs_dom.domain._narrow_by_lt(rhs_dom))
    end

    def_delegator :@domain, :_narrow_nil_by_lt
    def_delegator :@domain, :_narrow_unlimited_by_lt
    def_delegator :@domain, :_narrow_equal_to_by_lt
    def_delegator :@domain, :_narrow_less_than_by_lt
    def_delegator :@domain, :_narrow_greater_than_by_lt

    def _narrow_by_gt(rhs_dom, lhs_dom = self)
      ValueDomain.of_undefined(lhs_dom.domain._narrow_by_gt(rhs_dom))
    end

    def_delegator :@domain, :_narrow_nil_by_gt
    def_delegator :@domain, :_narrow_unlimited_by_gt
    def_delegator :@domain, :_narrow_equal_to_by_gt
    def_delegator :@domain, :_narrow_less_than_by_gt
    def_delegator :@domain, :_narrow_greater_than_by_gt

    def_delegator :@domain, :_widen_by_eq
    def_delegator :@domain, :_widen_by_ne
    def_delegator :@domain, :_widen_by_lt
    def_delegator :@domain, :_widen_by_gt
    def_delegator :@domain, :_widen_by_le
    def_delegator :@domain, :_widen_by_ge

    def inversion
      ValueDomain.of_undefined(@domain.inversion)
    end

    def ~
      ValueDomain.of_undefined(~@domain)
    end

    def +@
      ValueDomain.of_undefined(+@domain)
    end

    def -@
      ValueDomain.of_undefined(-@domain)
    end

    def +(rhs_dom)
      ValueDomain.of_undefined(@domain + rhs_dom)
    end

    def _add_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS + RHS' equals to `RHS + LHS'.
      #       This method invokes UndefinedValueDomain#+.
      rhs_dom + lhs_dom
    end

    def _add_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: `LHS + RHS' equals to `RHS + LHS'.
      #       This method invokes UndefinedValueDomain#+.
      rhs_dom + lhs_dom
    end

    def _add_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: `LHS + RHS' equals to `RHS + LHS'.
      #       This method invokes UndefinedValueDomain#+.
      rhs_dom + lhs_dom
    end

    def _add_less_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS + RHS' equals to `RHS + LHS'.
      #       This method invokes UndefinedValueDomain#+.
      rhs_dom + lhs_dom
    end

    def _add_greater_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS + RHS' equals to `RHS + LHS'.
      #       This method invokes UndefinedValueDomain#+.
      rhs_dom + lhs_dom
    end

    def *(rhs_dom)
      ValueDomain.of_undefined(@domain * rhs_dom)
    end

    def _mul_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS * RHS' equals to `RHS * LHS'.
      #       This method invokes UndefinedValueDomain#*.
      rhs_dom * lhs_dom
    end

    def _mul_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: `LHS * RHS' equals to `RHS * LHS'.
      #       This method invokes UndefinedValueDomain#*.
      rhs_dom * lhs_dom
    end

    def _mul_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: `LHS * RHS' equals to `RHS * LHS'.
      #       This method invokes UndefinedValueDomain#*.
      rhs_dom * lhs_dom
    end

    def _mul_less_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS * RHS' equals to `RHS * LHS'.
      #       This method invokes UndefinedValueDomain#*.
      rhs_dom * lhs_dom
    end

    def _mul_greater_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS * RHS' equals to `RHS * LHS'.
      #       This method invokes UndefinedValueDomain#*.
      rhs_dom * lhs_dom
    end

    def /(rhs_dom)
      ValueDomain.of_undefined(@domain / rhs_dom)
    end

    def _div_nil(lhs_dom, rhs_dom = self)
      ValueDomain.of_undefined(rhs_dom.domain._div_nil(lhs_dom))
    end

    def _div_unlimited(lhs_dom, rhs_dom = self)
      ValueDomain.of_undefined(rhs_dom.domain._div_unlimited(lhs_dom))
    end

    def _div_equal_to(lhs_dom, rhs_dom = self)
      ValueDomain.of_undefined(rhs_dom.domain._div_equal_to(lhs_dom))
    end

    def _div_less_than(lhs_dom, rhs_dom = self)
      ValueDomain.of_undefined(rhs_dom.domain._div_less_than(lhs_dom))
    end

    def _div_greater_than(lhs_dom, rhs_dom = self)
      ValueDomain.of_undefined(rhs_dom.domain._div_greater_than(lhs_dom))
    end

    def &(rhs_dom)
      ValueDomain.of_undefined(@domain & rhs_dom)
    end

    def _and_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS & RHS' equals to `RHS & LHS'.
      #       This method invokes UndefinedValueDomain#&.
      rhs_dom & lhs_dom
    end

    def _and_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: `LHS & RHS' equals to `RHS & LHS'.
      #       This method invokes UndefinedValueDomain#&.
      rhs_dom & lhs_dom
    end

    def _and_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: `LHS & RHS' equals to `RHS & LHS'.
      #       This method invokes UndefinedValueDomain#&.
      rhs_dom & lhs_dom
    end

    def _and_less_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS & RHS' equals to `RHS & LHS'.
      #       This method invokes UndefinedValueDomain#&.
      rhs_dom & lhs_dom
    end

    def _and_greater_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS & RHS' equals to `RHS & LHS'.
      #       This method invokes UndefinedValueDomain#&.
      rhs_dom & lhs_dom
    end

    def |(rhs_dom)
      ValueDomain.of_undefined(@domain | rhs_dom)
    end

    def _or_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS | RHS' equals to `RHS | LHS'.
      #       This method invokes UndefinedValueDomain#|.
      rhs_dom | lhs_dom
    end

    def _or_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: `LHS | RHS' equals to `RHS | LHS'.
      #       This method invokes UndefinedValueDomain#|.
      rhs_dom | lhs_dom
    end

    def _or_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: `LHS | RHS' equals to `RHS | LHS'.
      #       This method invokes UndefinedValueDomain#|.
      rhs_dom | lhs_dom
    end

    def _or_less_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS | RHS' equals to `RHS | LHS'.
      #       This method invokes UndefinedValueDomain#|.
      rhs_dom | lhs_dom
    end

    def _or_greater_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS | RHS' equals to `RHS | LHS'.
      #       This method invokes UndefinedValueDomain#|.
      rhs_dom | lhs_dom
    end

    def ^(rhs_dom)
      ValueDomain.of_undefined(@domain ^ rhs_dom)
    end

    def _xor_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS ^ RHS' equals to `RHS ^ LHS'.
      #       This method invokes UndefinedValueDomain#^.
      rhs_dom ^ lhs_dom
    end

    def _xor_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: `LHS ^ RHS' equals to `RHS ^ LHS'.
      #       This method invokes UndefinedValueDomain#^.
      rhs_dom ^ lhs_dom
    end

    def _xor_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: `LHS ^ RHS' equals to `RHS ^ LHS'.
      #       This method invokes UndefinedValueDomain#^.
      rhs_dom ^ lhs_dom
    end

    def _xor_less_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS ^ RHS' equals to `RHS ^ LHS'.
      #       This method invokes UndefinedValueDomain#^.
      rhs_dom ^ lhs_dom
    end

    def _xor_greater_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS ^ RHS' equals to `RHS ^ LHS'.
      #       This method invokes UndefinedValueDomain#^.
      rhs_dom ^ lhs_dom
    end

    def <<(rhs_dom)
      ValueDomain.of_undefined(@domain << rhs_dom)
    end

    def _shl_nil(lhs_dom, rhs_dom = self)
      ValueDomain.of_undefined(rhs_dom.domain._shl_nil(lhs_dom))
    end

    def _shl_unlimited(lhs_dom, rhs_dom = self)
      ValueDomain.of_undefined(rhs_dom.domain._shl_unlimited(lhs_dom))
    end

    def _shl_equal_to(lhs_dom, rhs_dom = self)
      ValueDomain.of_undefined(rhs_dom.domain._shl_equal_to(lhs_dom))
    end

    def _shl_less_than(lhs_dom, rhs_dom = self)
      ValueDomain.of_undefined(rhs_dom.domain._shl_less_than(lhs_dom))
    end

    def _shl_greater_than(lhs_dom, rhs_dom = self)
      ValueDomain.of_undefined(rhs_dom.domain._shl_greater_than(lhs_dom))
    end

    def >>(rhs_dom)
      ValueDomain.of_undefined(@domain >> rhs_dom)
    end

    def _shr_nil(lhs_dom, rhs_dom = self)
      ValueDomain.of_undefined(rhs_dom.domain._shr_nil(lhs_dom))
    end

    def _shr_unlimited(lhs_dom, rhs_dom = self)
      ValueDomain.of_undefined(rhs_dom.domain._shr_unlimited(lhs_dom))
    end

    def _shr_equal_to(lhs_dom, rhs_dom = self)
      ValueDomain.of_undefined(rhs_dom.domain._shr_equal_to(lhs_dom))
    end

    def _shr_less_than(lhs_dom, rhs_dom = self)
      ValueDomain.of_undefined(rhs_dom.domain._shr_less_than(lhs_dom))
    end

    def _shr_greater_than(lhs_dom, rhs_dom = self)
      ValueDomain.of_undefined(rhs_dom.domain._shr_greater_than(lhs_dom))
    end

    def_delegator :@domain, :!
    def_delegator :@domain, :<
    def_delegator :@domain, :_less_nil
    def_delegator :@domain, :_less_unlimited
    def_delegator :@domain, :_less_equal_to
    def_delegator :@domain, :_less_less_than
    def_delegator :@domain, :_less_greater_than
    def_delegator :@domain, :==
    def_delegator :@domain, :_equal_nil
    def_delegator :@domain, :_equal_unlimited
    def_delegator :@domain, :_equal_equal_to
    def_delegator :@domain, :_equal_less_than
    def_delegator :@domain, :_equal_greater_than
    def_delegator :@domain, :!=
    def_delegator :@domain, :_not_equal_nil
    def_delegator :@domain, :_not_equal_unlimited
    def_delegator :@domain, :_not_equal_equal_to
    def_delegator :@domain, :_not_equal_less_than
    def_delegator :@domain, :_not_equal_greater_than
    def_delegator :@domain, :logical_and
    def_delegator :@domain, :_logical_and_nil
    def_delegator :@domain, :_logical_and_unlimited
    def_delegator :@domain, :_logical_and_equal_to
    def_delegator :@domain, :_logical_and_less_than
    def_delegator :@domain, :_logical_and_greater_than
    def_delegator :@domain, :logical_or
    def_delegator :@domain, :_logical_or_nil
    def_delegator :@domain, :_logical_or_unlimited
    def_delegator :@domain, :_logical_or_equal_to
    def_delegator :@domain, :_logical_or_less_than
    def_delegator :@domain, :_logical_or_greater_than

    def intersection(rhs_dom)
      ValueDomain.of_undefined(@domain.intersection(rhs_dom))
    end

    def _intersection_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS intersection RHS' equals to `RHS intersection LHS'.
      #       This method invokes UndefinedValueDomain#intersection.
      rhs_dom.intersection(lhs_dom)
    end

    def _intersection_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: `LHS intersection RHS' equals to `RHS intersection LHS'.
      #       This method invokes UndefinedValueDomain#intersection.
      rhs_dom.intersection(lhs_dom)
    end

    def _intersection_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: `LHS intersection RHS' equals to `RHS intersection LHS'.
      #       This method invokes UndefinedValueDomain#intersection.
      rhs_dom.intersection(lhs_dom)
    end

    def _intersection_less_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS intersection RHS' equals to `RHS intersection LHS'.
      #       This method invokes UndefinedValueDomain#intersection.
      rhs_dom.intersection(lhs_dom)
    end

    def _intersection_greater_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS intersection RHS' equals to `RHS intersection LHS'.
      #       This method invokes UndefinedValueDomain#intersection.
      rhs_dom.intersection(lhs_dom)
    end

    def union(rhs_dom)
      ValueDomain.of_undefined(@domain.union(rhs_dom))
    end

    def _union_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS union RHS' equals to `RHS union LHS'.
      #       This method invokes UndefinedValueDomain#union.
      rhs_dom.union(lhs_dom)
    end

    def _union_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: `LHS union RHS' equals to `RHS union LHS'.
      #       This method invokes UndefinedValueDomain#union.
      rhs_dom.union(lhs_dom)
    end

    def _union_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: `LHS union RHS' equals to `RHS union LHS'.
      #       This method invokes UndefinedValueDomain#union.
      rhs_dom.union(lhs_dom)
    end

    def _union_less_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS union RHS' equals to `RHS union LHS'.
      #       This method invokes UndefinedValueDomain#union.
      rhs_dom.union(lhs_dom)
    end

    def _union_greater_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS union RHS' equals to `RHS union LHS'.
      #       This method invokes UndefinedValueDomain#union.
      rhs_dom.union(lhs_dom)
    end

    def coerce_to_integer
      ValueDomain.of_undefined(@domain.coerce_to_integer)
    end

    def coerce_to_real
      ValueDomain.of_undefined(@domain.coerce_to_real)
    end

    def_delegator :@domain, :min_value
    def_delegator :@domain, :max_value
    def_delegator :@domain, :each_sample

    def to_defined_domain
      @domain
    end

    def to_s
      "(== Undefined[#{@domain.to_s}])"
    end
    memoize :to_s

    def_delegator :@domain, :complexity
  end

  class AmbiguousValueDomain < ValueDomain
    def initialize(undefined, logical_shr)
      super(logical_shr)
      @undefined = undefined
    end

    def empty?
      false
    end

    def nan?
      false
    end

    def undefined?
      @undefined
    end

    def ambiguous?
      true
    end

    def contain_value_domain?(rhs_dom)
      true
    end

    def _contain_nil?(lhs_dom, rhs_dom = self)
      false
    end

    def _contain_unlimited?(lhs_dom, rhs_dom = self)
      true
    end

    def _contain_equal_to?(lhs_dom, rhs_dom = self)
      false
    end

    def _contain_less_than?(lhs_dom, rhs_dom = self)
      false
    end

    def _contain_greater_than?(lhs_dom, rhs_dom = self)
      false
    end

    def _contain_intersection?(lhs_dom, rhs_dom = self)
      false
    end

    def _contain_union?(lhs_dom, rhs_dom = self)
      false
    end

    def intersect?(rhs_dom)
      true
    end

    def _intersect_nil?(lhs_dom, rhs_dom = self)
      false
    end

    def _intersect_unlimited?(lhs_dom, rhs_dom = self)
      # NOTE: `LHS intersect? RHS' equals to `RHS intersect? LHS'.
      #       This method invokes AmbiguousValueDomain#intersect?.
      rhs_dom.intersect?(lhs_dom)
    end

    def _intersect_equal_to?(lhs_dom, rhs_dom = self)
      # NOTE: `LHS intersect? RHS' equals to `RHS intersect? LHS'.
      #       This method invokes AmbiguousValueDomain#intersect?.
      rhs_dom.intersect?(lhs_dom)
    end

    def _intersect_less_than?(lhs_dom, rhs_dom = self)
      # NOTE: `LHS intersect? RHS' equals to `RHS intersect? LHS'.
      #       This method invokes AmbiguousValueDomain#intersect?.
      rhs_dom.intersect?(lhs_dom)
    end

    def _intersect_greater_than?(lhs_dom, rhs_dom = self)
      # NOTE: `LHS intersect? RHS' equals to `RHS intersect? LHS'.
      #       This method invokes AmbiguousValueDomain#intersect?.
      rhs_dom.intersect?(lhs_dom)
    end

    def narrow(op, ope_dom)
      self
    end

    def _narrow_by_eq(rhs_dom, lhs_dom = self)
      ValueDomain.of_ambiguous(@undefined, logical_shr?)
    end

    def _narrow_nil_by_eq(lhs_dom, rhs_dom = self)
      ValueDomain.of_ambiguous(@undefined, logical_shr?)
    end

    def _narrow_unlimited_by_eq(lhs_dom, rhs_dom = self)
      ValueDomain.of_ambiguous(@undefined, logical_shr?)
    end

    def _narrow_equal_to_by_eq(lhs_dom, rhs_dom = self)
      ValueDomain.of_ambiguous(@undefined, logical_shr?)
    end

    def _narrow_less_than_by_eq(lhs_dom, rhs_dom = self)
      ValueDomain.of_ambiguous(@undefined, logical_shr?)
    end

    def _narrow_greater_than_by_eq(lhs_dom, rhs_dom = self)
      ValueDomain.of_ambiguous(@undefined, logical_shr?)
    end

    def _narrow_by_ne(rhs_dom, lhs_dom = self)
      ValueDomain.of_ambiguous(@undefined, logical_shr?)
    end

    def _narrow_nil_by_ne(lhs_dom, rhs_dom = self)
      ValueDomain.of_ambiguous(@undefined, logical_shr?)
    end

    def _narrow_unlimited_by_ne(lhs_dom, rhs_dom = self)
      ValueDomain.of_ambiguous(@undefined, logical_shr?)
    end

    def _narrow_equal_to_by_ne(lhs_dom, rhs_dom = self)
      ValueDomain.of_ambiguous(@undefined, logical_shr?)
    end

    def _narrow_less_than_by_ne(lhs_dom, rhs_dom = self)
      ValueDomain.of_ambiguous(@undefined, logical_shr?)
    end

    def _narrow_greater_than_by_ne(lhs_dom, rhs_dom = self)
      ValueDomain.of_ambiguous(@undefined, logical_shr?)
    end

    def _narrow_by_lt(rhs_dom, lhs_dom = self)
      ValueDomain.of_ambiguous(@undefined, logical_shr?)
    end

    def _narrow_nil_by_lt(lhs_dom, rhs_dom = self)
      ValueDomain.of_ambiguous(@undefined, logical_shr?)
    end

    def _narrow_unlimited_by_lt(lhs_dom, rhs_dom = self)
      ValueDomain.of_ambiguous(@undefined, logical_shr?)
    end

    def _narrow_equal_to_by_lt(lhs_dom, rhs_dom = self)
      ValueDomain.of_ambiguous(@undefined, logical_shr?)
    end

    def _narrow_less_than_by_lt(lhs_dom, rhs_dom = self)
      ValueDomain.of_ambiguous(@undefined, logical_shr?)
    end

    def _narrow_greater_than_by_lt(lhs_dom, rhs_dom = self)
      ValueDomain.of_ambiguous(@undefined, logical_shr?)
    end

    def _narrow_by_gt(rhs_dom, lhs_dom = self)
      ValueDomain.of_ambiguous(@undefined, logical_shr?)
    end

    def _narrow_nil_by_gt(lhs_dom, rhs_dom = self)
      ValueDomain.of_ambiguous(@undefined, logical_shr?)
    end

    def _narrow_unlimited_by_gt(lhs_dom, rhs_dom = self)
      ValueDomain.of_ambiguous(@undefined, logical_shr?)
    end

    def _narrow_equal_to_by_gt(lhs_dom, rhs_dom = self)
      ValueDomain.of_ambiguous(@undefined, logical_shr?)
    end

    def _narrow_less_than_by_gt(lhs_dom, rhs_dom = self)
      ValueDomain.of_ambiguous(@undefined, logical_shr?)
    end

    def _narrow_greater_than_by_gt(lhs_dom, rhs_dom = self)
      ValueDomain.of_ambiguous(@undefined, logical_shr?)
    end

    def widen(op, ope_dom)
      self
    end

    def _widen_by_eq(rhs_dom, lhs_dom = self)
      ValueDomain.of_ambiguous(@undefined, logical_shr?)
    end

    def _widen_by_ne(rhs_dom, lhs_dom = self)
      ValueDomain.of_ambiguous(@undefined, logical_shr?)
    end

    def _widen_by_lt(rhs_dom, lhs_dom = self)
      ValueDomain.of_ambiguous(@undefined, logical_shr?)
    end

    def _widen_by_gt(rhs_dom, lhs_dom = self)
      ValueDomain.of_ambiguous(@undefined, logical_shr?)
    end

    def _widen_by_le(rhs_dom, lhs_dom = self)
      ValueDomain.of_ambiguous(@undefined, logical_shr?)
    end

    def _widen_by_ge(rhs_dom, lhs_dom = self)
      ValueDomain.of_ambiguous(@undefined, logical_shr?)
    end

    def inversion
      self
    end

    def ~
      self
    end

    def +@
      self
    end

    def -@
      self
    end

    def +(rhs_dom)
      self
    end

    def _add_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS + RHS' equals to `RHS + LHS'.
      #       This method invokes AmbiguousValueDomain#+.
      rhs_dom + lhs_dom
    end

    def _add_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: `LHS + RHS' equals to `RHS + LHS'.
      #       This method invokes AmbiguousValueDomain#+.
      rhs_dom + lhs_dom
    end

    def _add_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: `LHS + RHS' equals to `RHS + LHS'.
      #       This method invokes AmbiguousValueDomain#+.
      rhs_dom + lhs_dom
    end

    def _add_less_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS + RHS' equals to `RHS + LHS'.
      #       This method invokes AmbiguousValueDomain#+.
      rhs_dom + lhs_dom
    end

    def _add_greater_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS + RHS' equals to `RHS + LHS'.
      #       This method invokes AmbiguousValueDomain#+.
      rhs_dom + lhs_dom
    end

    def *(rhs_dom)
      self
    end

    def _mul_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS * RHS' equals to `RHS * LHS'.
      #       This method invokes AmbiguousValueDomain#*.
      rhs_dom * lhs_dom
    end

    def _mul_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: `LHS * RHS' equals to `RHS * LHS'.
      #       This method invokes AmbiguousValueDomain#*.
      rhs_dom * lhs_dom
    end

    def _mul_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: `LHS * RHS' equals to `RHS * LHS'.
      #       This method invokes AmbiguousValueDomain#*.
      rhs_dom * lhs_dom
    end

    def _mul_less_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS * RHS' equals to `RHS * LHS'.
      #       This method invokes AmbiguousValueDomain#*.
      rhs_dom * lhs_dom
    end

    def _mul_greater_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS * RHS' equals to `RHS * LHS'.
      #       This method invokes AmbiguousValueDomain#*.
      rhs_dom * lhs_dom
    end

    def /(rhs_dom)
      self
    end

    def _div_nil(lhs_dom, rhs_dom = self)
      rhs_dom
    end

    def _div_unlimited(lhs_dom, rhs_dom = self)
      rhs_dom
    end

    def _div_equal_to(lhs_dom, rhs_dom = self)
      rhs_dom
    end

    def _div_less_than(lhs_dom, rhs_dom = self)
      rhs_dom
    end

    def _div_greater_than(lhs_dom, rhs_dom = self)
      rhs_dom
    end

    def &(rhs_dom)
      self
    end

    def _and_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS & RHS' equals to `RHS & LHS'.
      #       This method invokes AmbiguousValueDomain#&.
      rhs_dom & lhs_dom
    end

    def _and_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: `LHS & RHS' equals to `RHS & LHS'.
      #       This method invokes AmbiguousValueDomain#&.
      rhs_dom & lhs_dom
    end

    def _and_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: `LHS & RHS' equals to `RHS & LHS'.
      #       This method invokes AmbiguousValueDomain#&.
      rhs_dom & lhs_dom
    end

    def _and_less_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS & RHS' equals to `RHS & LHS'.
      #       This method invokes AmbiguousValueDomain#&.
      rhs_dom & lhs_dom
    end

    def _and_greater_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS & RHS' equals to `RHS & LHS'.
      #       This method invokes AmbiguousValueDomain#&.
      rhs_dom & lhs_dom
    end

    def |(rhs_dom)
      self
    end

    def _or_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS | RHS' equals to `RHS | LHS'.
      #       This method invokes AmbiguousValueDomain#|.
      rhs_dom | lhs_dom
    end

    def _or_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: `LHS | RHS' equals to `RHS | LHS'.
      #       This method invokes AmbiguousValueDomain#|.
      rhs_dom | lhs_dom
    end

    def _or_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: `LHS | RHS' equals to `RHS | LHS'.
      #       This method invokes AmbiguousValueDomain#|.
      rhs_dom | lhs_dom
    end

    def _or_less_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS | RHS' equals to `RHS | LHS'.
      #       This method invokes AmbiguousValueDomain#|.
      rhs_dom | lhs_dom
    end

    def _or_greater_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS | RHS' equals to `RHS | LHS'.
      #       This method invokes AmbiguousValueDomain#|.
      rhs_dom | lhs_dom
    end

    def ^(rhs_dom)
      self
    end

    def _xor_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS ^ RHS' equals to `RHS ^ LHS'.
      #       This method invokes AmbiguousValueDomain#^.
      rhs_dom ^ lhs_dom
    end

    def _xor_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: `LHS ^ RHS' equals to `RHS ^ LHS'.
      #       This method invokes AmbiguousValueDomain#^.
      rhs_dom ^ lhs_dom
    end

    def _xor_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: `LHS ^ RHS' equals to `RHS ^ LHS'.
      #       This method invokes AmbiguousValueDomain#^.
      rhs_dom ^ lhs_dom
    end

    def _xor_less_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS ^ RHS' equals to `RHS ^ LHS'.
      #       This method invokes AmbiguousValueDomain#^.
      rhs_dom ^ lhs_dom
    end

    def _xor_greater_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS ^ RHS' equals to `RHS ^ LHS'.
      #       This method invokes AmbiguousValueDomain#^.
      rhs_dom ^ lhs_dom
    end

    def <<(rhs_dom)
      self
    end

    def _shl_nil(lhs_dom, rhs_dom = self)
      rhs_dom
    end

    def _shl_unlimited(lhs_dom, rhs_dom = self)
      rhs_dom
    end

    def _shl_equal_to(lhs_dom, rhs_dom = self)
      rhs_dom
    end

    def _shl_less_than(lhs_dom, rhs_dom = self)
      rhs_dom
    end

    def _shl_greater_than(lhs_dom, rhs_dom = self)
      rhs_dom
    end

    def >>(rhs_dom)
      self
    end

    def _shr_nil(lhs_dom, rhs_dom = self)
      rhs_dom
    end

    def _shr_unlimited(lhs_dom, rhs_dom = self)
      rhs_dom
    end

    def _shr_equal_to(lhs_dom, rhs_dom = self)
      rhs_dom
    end

    def _shr_less_than(lhs_dom, rhs_dom = self)
      rhs_dom
    end

    def _shr_greater_than(lhs_dom, rhs_dom = self)
      rhs_dom
    end

    def !
      ValueDomain.of_unlimited(logical_shr?)
    end

    def <(rhs_dom)
      ValueDomain.of_unlimited(logical_shr?)
    end

    def _less_nil(lhs_dom, rhs_dom = self)
      ValueDomain.of_nil(logical_shr?)
    end

    def _less_unlimited(lhs_dom, rhs_dom = self)
      ValueDomain.of_unlimited(logical_shr?)
    end

    def _less_equal_to(lhs_dom, rhs_dom = self)
      ValueDomain.of_unlimited(logical_shr?)
    end

    def _less_less_than(lhs_dom, rhs_dom = self)
      ValueDomain.of_unlimited(logical_shr?)
    end

    def _less_greater_than(lhs_dom, rhs_dom = self)
      ValueDomain.of_unlimited(logical_shr?)
    end

    def ==(rhs_dom)
      ValueDomain.of_unlimited(logical_shr?)
    end

    def _equal_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS == RHS' equals to `RHS == LHS'.
      #       This method invokes AmbiguousValueDomain#==.
      rhs_dom == lhs_dom
    end

    def _equal_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: `LHS == RHS' equals to `RHS == LHS'.
      #       This method invokes AmbiguousValueDomain#==.
      rhs_dom == lhs_dom
    end

    def _equal_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: `LHS == RHS' equals to `RHS == LHS'.
      #       This method invokes AmbiguousValueDomain#==.
      rhs_dom == lhs_dom
    end

    def _equal_less_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS == RHS' equals to `RHS == LHS'.
      #       This method invokes AmbiguousValueDomain#==.
      rhs_dom == lhs_dom
    end

    def _equal_greater_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS == RHS' equals to `RHS == LHS'.
      #       This method invokes AmbiguousValueDomain#==.
      rhs_dom == lhs_dom
    end

    def !=(rhs_dom)
      ValueDomain.of_unlimited(logical_shr?)
    end

    def _not_equal_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS != RHS' equals to `RHS != LHS'.
      #       This method invokes AmbiguousValueDomain#!=.
      rhs_dom != lhs_dom
    end

    def _not_equal_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: `LHS != RHS' equals to `RHS != LHS'.
      #       This method invokes AmbiguousValueDomain#!=.
      rhs_dom != lhs_dom
    end

    def _not_equal_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: `LHS != RHS' equals to `RHS != LHS'.
      #       This method invokes AmbiguousValueDomain#!=.
      rhs_dom != lhs_dom
    end

    def _not_equal_less_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS != RHS' equals to `RHS != LHS'.
      #       This method invokes AmbiguousValueDomain#!=.
      rhs_dom != lhs_dom
    end

    def _not_equal_greater_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS != RHS' equals to `RHS != LHS'.
      #       This method invokes AmbiguousValueDomain#!=.
      rhs_dom != lhs_dom
    end

    def logical_and(rhs_dom)
      ValueDomain.of_unlimited(logical_shr?)
    end

    def _logical_and_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS && RHS' equals to `RHS && LHS'.
      #       This method invokes AmbiguousValueDomain#logical_and.
      rhs_dom.logical_and(lhs_dom)
    end

    def _logical_and_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: `LHS && RHS' equals to `RHS && LHS'.
      #       This method invokes AmbiguousValueDomain#logical_and.
      rhs_dom.logical_and(lhs_dom)
    end

    def _logical_and_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: `LHS && RHS' equals to `RHS && LHS'.
      #       This method invokes AmbiguousValueDomain#logical_and.
      rhs_dom.logical_and(lhs_dom)
    end

    def _logical_and_less_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS && RHS' equals to `RHS && LHS'.
      #       This method invokes AmbiguousValueDomain#logical_and.
      rhs_dom.logical_and(lhs_dom)
    end

    def _logical_and_greater_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS && RHS' equals to `RHS && LHS'.
      #       This method invokes AmbiguousValueDomain#logical_and.
      rhs_dom.logical_and(lhs_dom)
    end

    def logical_or(rhs_dom)
      ValueDomain.of_unlimited(logical_shr?)
    end

    def _logical_or_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS || RHS' equals to `RHS || LHS'.
      #       This method invokes AmbiguousValueDomain#logical_or.
      rhs_dom.logical_or(lhs_dom)
    end

    def _logical_or_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: `LHS || RHS' equals to `RHS || LHS'.
      #       This method invokes AmbiguousValueDomain#logical_or.
      rhs_dom.logical_or(lhs_dom)
    end

    def _logical_or_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: `LHS || RHS' equals to `RHS || LHS'.
      #       This method invokes AmbiguousValueDomain#logical_or.
      rhs_dom.logical_or(lhs_dom)
    end

    def _logical_or_less_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS || RHS' equals to `RHS || LHS'.
      #       This method invokes AmbiguousValueDomain#logical_or.
      rhs_dom.logical_or(lhs_dom)
    end

    def _logical_or_greater_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS || RHS' equals to `RHS || LHS'.
      #       This method invokes AmbiguousValueDomain#logical_or.
      rhs_dom.logical_or(lhs_dom)
    end

    def intersection(rhs_dom)
      self
    end

    def _intersection_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS intersection RHS' equals to `RHS intersection LHS'.
      #       This method invokes AmbiguousValueDomain#intersection.
      rhs_dom.intersection(lhs_dom)
    end

    def _intersection_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: `LHS intersection RHS' equals to `RHS intersection LHS'.
      #       This method invokes AmbiguousValueDomain#intersection.
      rhs_dom.intersection(lhs_dom)
    end

    def _intersection_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: `LHS intersection RHS' equals to `RHS intersection LHS'.
      #       This method invokes AmbiguousValueDomain#intersection.
      rhs_dom.intersection(lhs_dom)
    end

    def _intersection_less_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS intersection RHS' equals to `RHS intersection LHS'.
      #       This method invokes AmbiguousValueDomain#intersection.
      rhs_dom.intersection(lhs_dom)
    end

    def _intersection_greater_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS intersection RHS' equals to `RHS intersection LHS'.
      #       This method invokes AmbiguousValueDomain#intersection.
      rhs_dom.intersection(lhs_dom)
    end

    def union(rhs_dom)
      self
    end

    def _union_nil(lhs_dom, rhs_dom = self)
      # NOTE: `LHS union RHS' equals to `RHS union LHS'.
      #       This method invokes AmbiguousValueDomain#union.
      rhs_dom.union(lhs_dom)
    end

    def _union_unlimited(lhs_dom, rhs_dom = self)
      # NOTE: `LHS union RHS' equals to `RHS union LHS'.
      #       This method invokes AmbiguousValueDomain#union.
      rhs_dom.union(lhs_dom)
    end

    def _union_equal_to(lhs_dom, rhs_dom = self)
      # NOTE: `LHS union RHS' equals to `RHS union LHS'.
      #       This method invokes AmbiguousValueDomain#union.
      rhs_dom.union(lhs_dom)
    end

    def _union_less_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS union RHS' equals to `RHS union LHS'.
      #       This method invokes AmbiguousValueDomain#union.
      rhs_dom.union(lhs_dom)
    end

    def _union_greater_than(lhs_dom, rhs_dom = self)
      # NOTE: `LHS union RHS' equals to `RHS union LHS'.
      #       This method invokes AmbiguousValueDomain#union.
      rhs_dom.union(lhs_dom)
    end

    def coerce_to_integer
      self
    end

    def coerce_to_real
      self
    end

    def min_value
      nil
    end

    def max_value
      nil
    end

    def each_sample
      if block_given?
        yield(0)
        self
      else
        to_enum(:each_sample)
      end
    end

    def to_defined_domain
      ValueDomain.of_ambiguous(false, logical_shr?)
    end

    def to_s
      "(== Ambiguous)"
    end
    memoize :to_s

    def complexity
      1
    end
  end

end
end
