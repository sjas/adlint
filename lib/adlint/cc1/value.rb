# Values associated with memory blocks.
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

require "adlint/cc1/domain"
require "adlint/cc1/operator"

module AdLint #:nodoc:
module Cc1 #:nodoc:

  module BuggyValueSampler
    def unique_sample
      # NOTE: A value may have multiple sample values.
      #       So, callers of this method have potential bugs!
      to_enum.to_a.min
    end
  end

  # == DESCRIPTION
  # === TestEvidence class hierarchy
  #  TestEvidence
  #    <-- TrivialTestEvidence
  #    <-- NontrivialTestEvidence
  #          <-- UndefinableTestEvidence
  #          <-- NullabilityTestEvidence
  #          <-- DefinableTestEvidence
  class TestEvidence
    def fulfilled?
      subclass_responsibility
    end

    def emit_context_messages(report, loc)
      subclass_responsibility
    end
  end

  # == DESCRIPTION
  # === ValueTest class hierarchy
  #  ValueTest
  #    <-- TrivialValueTest
  #    <-- NontrivialValueTest
  class ValueTest
    def initialize(evid)
      @evidence = evid
    end

    attr_reader :evidence

    def result
      subclass_responsibility
    end

    def true?
      !!result
    end

    def false?
      !true?
    end
  end

  # == DESCRIPTION
  # === Value class hierarchy
  #  Value
  #    <-- SingleValue
  #          <-- ScalarValue
  #          <-- ArrayValue
  #          <-- CompositeValue
  #    <-- MultipleValue
  #          <-- VersionedValue
  class Value
    include BuggyValueSampler

    def scalar?
      subclass_responsibility
    end

    def array?
      subclass_responsibility
    end

    def composite?
      subclass_responsibility
    end

    def undefined?
      subclass_responsibility
    end

    def ambiguous?
      subclass_responsibility
    end

    def exist?
      subclass_responsibility
    end

    def definite?
      subclass_responsibility
    end

    def contain?(val)
      subclass_responsibility
    end

    def multiple?
      subclass_responsibility
    end

    def overwrite!(val, tag)
      subclass_responsibility
    end

    def narrow_domain!(op, ope_val)
      subclass_responsibility
    end

    def widen_domain!(op, ope_val)
      subclass_responsibility
    end

    def invert_domain!
      subclass_responsibility
    end

    def single_value_unified_with(rhs_val)
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

    def +(rhs_val)
      subclass_responsibility
    end

    def -(rhs_val)
      subclass_responsibility
    end

    def *(rhs_val)
      subclass_responsibility
    end

    def /(rhs_val)
      subclass_responsibility
    end

    def %(rhs_val)
      subclass_responsibility
    end

    def &(rhs_val)
      subclass_responsibility
    end

    def |(rhs_val)
      subclass_responsibility
    end

    def ^(rhs_val)
      subclass_responsibility
    end

    def <<(rhs_val)
      subclass_responsibility
    end

    def >>(rhs_val)
      subclass_responsibility
    end

    def !
      subclass_responsibility
    end

    def <(rhs_val)
      subclass_responsibility
    end

    def >(rhs_val)
      subclass_responsibility
    end

    def ==(rhs_val)
      subclass_responsibility
    end

    def !=(rhs_val)
      subclass_responsibility
    end

    def <=(rhs_val)
      subclass_responsibility
    end

    def >=(rhs_val)
      subclass_responsibility
    end

    def logical_and(rhs_val)
      # NOTE: Operator && cannot be defined as a method in Ruby.
      subclass_responsibility
    end

    def logical_or(rhs_val)
      # NOTE: Operator || cannot be defined as a method in Ruby.
      subclass_responsibility
    end

    def test_must_be_undefined
      subclass_responsibility
    end

    def test_may_be_undefined
      subclass_responsibility
    end

    def test_must_be_equal_to(val)
      subclass_responsibility
    end

    def test_may_be_equal_to(val)
      subclass_responsibility
    end

    def test_must_not_be_equal_to(val)
      subclass_responsibility
    end

    def test_may_not_be_equal_to(val)
      subclass_responsibility
    end

    def test_must_be_less_than(val)
      subclass_responsibility
    end

    def test_may_be_less_than(val)
      subclass_responsibility
    end

    def test_must_be_greater_than(val)
      subclass_responsibility
    end

    def test_may_be_greater_than(val)
      subclass_responsibility
    end

    def test_must_be_null
      subclass_responsibility
    end

    def test_may_be_null
      subclass_responsibility
    end

    def test_must_be_true
      subclass_responsibility
    end

    def test_may_be_true
      subclass_responsibility
    end

    def test_must_be_false
      subclass_responsibility
    end

    def test_may_be_false
      subclass_responsibility
    end

    def coerce_to(type)
      subclass_responsibility
    end

    def to_enum
      subclass_responsibility
    end

    def to_single_value
      subclass_responsibility
    end

    def to_defined_value
      subclass_responsibility
    end

    def eql?(rhs_val)
      subclass_responsibility
    end

    def hash
      subclass_responsibility
    end

    def dup
      subclass_responsibility
    end
  end

  class TrivialTestEvidence < TestEvidence
    def fulfilled?
      true
    end

    def emit_context_messages(report, loc)
      # NOTE: Evidence of the test result about SingleValue is trivial.
      #       So, nothing to be complemented.
      []
    end
  end

  class TrivialValueTest < ValueTest
    def initialize(rslt)
      super(TrivialTestEvidence.new)
      @result = rslt
    end

    attr_reader :result
  end

  class SingleValue < Value
    def multiple?
      false
    end

    def test_must_be_undefined
      TrivialValueTest.new(self.undefined?)
    end

    def test_may_be_undefined
      # NOTE: SingleValue has exactly one value domain.
      #       So, the value of SingleValue may be undefined when the value
      #       must be undefined.
      self.test_must_be_undefined
    end

    def to_single_value
      self
    end

    private
    def scalar_value_of_null
      ScalarValue.of_null(logical_shr?)
    end

    def scalar_value_of_true
      ScalarValue.of_true(logical_shr?)
    end

    def scalar_value_of_false
      ScalarValue.of_false(logical_shr?)
    end

    def scalar_value_of_nil
      ScalarValue.of_nil(logical_shr?)
    end

    def logical_shr?
      subclass_responsibility
    end
  end

  module ScalarValueFactory
    def of(numeric_or_range, logical_shr)
      case numeric_or_range
      when Numeric
        new(ValueDomain.equal_to(numeric_or_range, logical_shr))
      when Range
        new(ValueDomain.greater_than_or_equal_to(
          numeric_or_range.first, logical_shr
        ).intersection(ValueDomain.less_than_or_equal_to(
          numeric_or_range.last, logical_shr
        )))
      else
        raise TypeError, "argument must be a Numeric or a Range."
      end
    end

    def not_of(numeric_or_range, logical_shr)
      case numeric_or_range
      when Numeric
        new(ValueDomain.not_equal_to(numeric_or_range, logical_shr))
      when Range
        new(ValueDomain.less_than(
          numeric_or_range.first, logical_shr
        ).union(ValueDomain.greater_than(
          numeric_or_range.last, logical_shr
        )))
      else
        raise TypeError, "argument must be a Numeric or a Range."
      end
    end

    def of_true(logical_shr)
      not_of(0, logical_shr)
    end

    def of_false(logical_shr)
      of(0, logical_shr)
    end

    def of_null(logical_shr)
      # TODO: NULL may not be 0 on some environments. Representation of NULL
      #       should be configurable?
      of(0, logical_shr)
    end

    def of_arbitrary(logical_shr)
      new(ValueDomain.of_unlimited(logical_shr))
    end

    def of_undefined(range, logical_shr)
      new(ValueDomain.of_undefined(ValueDomain.greater_than_or_equal_to(
        range.first, logical_shr
      ).intersection(ValueDomain.less_than_or_equal_to(
        range.last, logical_shr
      ))))
    end

    def of_nil(logical_shr)
      new(ValueDomain.of_nil(logical_shr))
    end

    def of_nan(logical_shr)
      new(ValueDomain.of_nan(logical_shr))
    end
  end

  class ScalarValue < SingleValue
    extend ScalarValueFactory

    def initialize(domain)
      @domain = domain
    end

    def scalar?
      true
    end

    def array?
      false
    end

    def composite?
      false
    end

    def exist?
      !@domain.empty?
    end

    def definite?
      @domain.kind_of?(EqualToValueDomain)
    end

    def contain?(val)
      case sval = val.to_single_value
      when ScalarValue
        @domain.contain?(sval.domain)
      else
        false
      end
    end

    def undefined?
      @domain.undefined?
    end

    def ambiguous?
      @domain.ambiguous?
    end

    def overwrite!(val, *)
      case sval = val.to_single_value
      when ScalarValue
        @domain = sval.domain
      else
        raise TypeError, "cannot overwrite scalar with non-scalar."
      end
    end

    def narrow_domain!(op, ope_val)
      case ope_sval = ope_val.to_single_value
      when ScalarValue
        @domain = @domain.narrow(op, ope_sval.domain)
      else
        raise TypeError, "cannot narrow scalar value domain with non-scalar."
      end
    end

    def widen_domain!(op, ope_val)
      case ope_sval = ope_val.to_single_value
      when ScalarValue
        @domain = @domain.widen(op, ope_sval.domain)
      else
        raise TypeError, "cannot widen scalar value domain with non-scalar."
      end
    end

    def invert_domain!
      @domain = @domain.inversion
    end

    def single_value_unified_with(rhs_val)
      case rhs_sval = rhs_val.to_single_value
      when ScalarValue
        ScalarValue.new(@domain.union(rhs_sval.domain))
      else
        raise TypeError, "cannot unify scalar value with non-scalar."
      end
    end

    def ~
      ScalarValue.new(~@domain)
    end

    def +@
      ScalarValue.new(+@domain)
    end

    def -@
      ScalarValue.new(-@domain)
    end

    def +(rhs_val)
      case rhs_sval = rhs_val.to_single_value
      when ScalarValue
        ScalarValue.new(@domain + rhs_sval.domain)
      else
        raise TypeError, "binary operation between scalar and non-scalar."
      end
    end

    def -(rhs_val)
      case rhs_sval = rhs_val.to_single_value
      when ScalarValue
        ScalarValue.new(@domain - rhs_sval.domain)
      else
        raise TypeError, "binary operation between scalar and non-scalar."
      end
    end

    def *(rhs_val)
      case rhs_sval = rhs_val.to_single_value
      when ScalarValue
        ScalarValue.new(@domain * rhs_sval.domain)
      else
        raise TypeError, "binary operation between scalar and non-scalar."
      end
    end

    def /(rhs_val)
      case rhs_sval = rhs_val.to_single_value
      when ScalarValue
        ScalarValue.new(@domain / rhs_sval.domain)
      else
        raise TypeError, "binary operation between scalar and non-scalar."
      end
    end

    def %(rhs_val)
      case rhs_sval = rhs_val.to_single_value
      when ScalarValue
        ScalarValue.new(@domain % rhs_sval.domain)
      else
        raise TypeError, "binary operation between scalar and non-scalar."
      end
    end

    def &(rhs_val)
      case rhs_sval = rhs_val.to_single_value
      when ScalarValue
        ScalarValue.new(@domain & rhs_sval.domain)
      else
        raise TypeError, "binary operation between scalar and non-scalar."
      end
    end

    def |(rhs_val)
      case rhs_sval = rhs_val.to_single_value
      when ScalarValue
        ScalarValue.new(@domain | rhs_sval.domain)
      else
        raise TypeError, "binary operation between scalar and non-scalar."
      end
    end

    def ^(rhs_val)
      case rhs_sval = rhs_val.to_single_value
      when ScalarValue
        ScalarValue.new(@domain ^ rhs_sval.domain)
      else
        raise TypeError, "binary operation between scalar and non-scalar."
      end
    end

    def <<(rhs_val)
      case rhs_sval = rhs_val.to_single_value
      when ScalarValue
        ScalarValue.new(@domain << rhs_sval.domain)
      else
        raise TypeError, "binary operation between scalar and non-scalar."
      end
    end

    def >>(rhs_val)
      case rhs_sval = rhs_val.to_single_value
      when ScalarValue
        ScalarValue.new(@domain >> rhs_sval.domain)
      else
        raise TypeError, "binary operation between scalar and non-scalar."
      end
    end

    def !
      ScalarValue.new(!@domain)
    end

    def <(rhs_val)
      case rhs_sval = rhs_val.to_single_value
      when ScalarValue
        ScalarValue.new(@domain < rhs_sval.domain)
      else
        raise TypeError, "comparison between scalar and non-scalar."
      end
    end

    def >(rhs_val)
      case rhs_sval = rhs_val.to_single_value
      when ScalarValue
        ScalarValue.new(@domain > rhs_sval.domain)
      else
        raise TypeError, "comparison between scalar and non-scalar."
      end
    end

    def ==(rhs_val)
      case rhs_sval = rhs_val.to_single_value
      when ScalarValue
        ScalarValue.new(@domain == rhs_sval.domain)
      else
        raise TypeError, "comparison between scalar and non-scalar."
      end
    end

    def !=(rhs_val)
      case rhs_sval = rhs_val.to_single_value
      when ScalarValue
        ScalarValue.new(@domain != rhs_sval.domain)
      else
        raise TypeError, "comparison between scalar and non-scalar."
      end
    end

    def <=(rhs_val)
      case rhs_sval = rhs_val.to_single_value
      when ScalarValue
        ScalarValue.new(@domain <= rhs_sval.domain)
      else
        raise TypeError, "comparison between scalar and non-scalar."
      end
    end

    def >=(rhs_val)
      case rhs_sval = rhs_val.to_single_value
      when ScalarValue
        ScalarValue.new(@domain >= rhs_sval.domain)
      else
        raise TypeError, "comparison between scalar and non-scalar."
      end
    end

    def logical_and(rhs_val)
      case rhs_sval = rhs_val.to_single_value
      when ScalarValue
        ScalarValue.new(@domain.logical_and(rhs_sval.domain))
      else
        raise TypeError, "comparison between scalar and non-scalar."
      end
    end

    def logical_or(rhs_val)
      case rhs_sval = rhs_val.to_single_value
      when ScalarValue
        ScalarValue.new(@domain.logical_or(rhs_sval.domain))
      else
        raise TypeError, "comparison between scalar and non-scalar."
      end
    end

    def test_must_be_equal_to(val)
      case sval = val.to_single_value.dup
      when ScalarValue
        comp_val = (self == sval)
        sval.invert_domain!
        sval.narrow_domain!(Operator::EQ, self)
        TrivialValueTest.new(
          comp_val.domain.intersect?(scalar_value_of_true.domain) &&
          !comp_val.domain.contain?(scalar_value_of_false.domain) &&
          !@domain.intersect?(sval.domain))
      else
        raise TypeError, "comparison between scalar and non-scalar."
      end
    end

    def test_may_be_equal_to(val)
      case sval = val.to_single_value
      when ScalarValue
        TrivialValueTest.new(
          (self == sval).domain.intersect?(scalar_value_of_true.domain))
      else
        raise TypeError, "comparison between scalar and non-scalar."
      end
    end

    def test_must_not_be_equal_to(val)
      case sval = val.to_single_value
      when ScalarValue
        comp_val = (self != sval)
        TrivialValueTest.new(
          comp_val.domain.intersect?(scalar_value_of_true.domain) &&
          !comp_val.domain.contain?(scalar_value_of_false.domain) &&
          !@domain.intersect?(sval.domain))
      else
        raise TypeError, "comparison between scalar and non-scalar."
      end
    end

    def test_may_not_be_equal_to(val)
      case sval = val.to_single_value
      when ScalarValue
        TrivialValueTest.new(
          (self != sval).domain.intersect?(scalar_value_of_true.domain))
      else
        raise TypeError, "comparison between scalar and non-scalar."
      end
    end

    def test_must_be_less_than(val)
      case sval = val.to_single_value
      when ScalarValue
        comp_val = (self < sval)
        TrivialValueTest.new(
          comp_val.domain.intersect?(scalar_value_of_true.domain) &&
          !comp_val.domain.contain?(scalar_value_of_false.domain))
      else
        raise TypeError, "comparison between scalar and non-scalar."
      end
    end

    def test_may_be_less_than(val)
      case sval = val.to_single_value
      when ScalarValue
        TrivialValueTest.new(
          (self < sval).domain.intersect?(scalar_value_of_true.domain))
      else
        raise TypeError, "comparison between scalar and non-scalar."
      end
    end

    def test_must_be_greater_than(val)
      case sval = val.to_single_value
      when ScalarValue
        comp_val = (self > sval)
        TrivialValueTest.new(
          comp_val.domain.intersect?(scalar_value_of_true.domain) &&
          !comp_val.domain.contain?(scalar_value_of_false.domain))
      else
        raise TypeError, "comparison between scalar and non-scalar."
      end
    end

    def test_may_be_greater_than(val)
      case sval = val.to_single_value
      when ScalarValue
        TrivialValueTest.new(
          (self > sval).domain.intersect?(scalar_value_of_true.domain))
      else
        raise TypeError, "comparison between scalar and non-scalar."
      end
    end

    def test_must_be_null
      test_must_be_equal_to(scalar_value_of_null)
    end

    def test_may_be_null
      test_may_be_equal_to(scalar_value_of_null)
    end

    def test_must_be_true
      TrivialValueTest.new(
        test_may_be_equal_to(scalar_value_of_true).true? &&
        test_must_not_be_equal_to(scalar_value_of_false).true?)
    end

    def test_may_be_true
      test_may_be_equal_to(scalar_value_of_true)
    end

    def test_must_be_false
      test_must_be_equal_to(scalar_value_of_false)
    end

    def test_may_be_false
      test_may_be_equal_to(scalar_value_of_false)
    end

    def coerce_to(type)
      type.coerce_scalar_value(self)
    end

    def to_enum
      @domain.each_sample
    end

    def to_defined_value
      ScalarValue.new(@domain.to_defined_domain)
    end

    def eql?(rhs_val)
      rhs_val.kind_of?(ScalarValue) && @domain.eql?(rhs_val.domain)
    end

    def hash
      @domain.hash
    end

    def dup
      ScalarValue.new(@domain)
    end

    protected
    attr_reader :domain

    private
    def logical_shr?
      @domain.logical_shr?
    end
  end

  class ArrayValue < SingleValue
    def initialize(vals)
      @values = vals
    end

    attr_reader :values

    def scalar?
      false
    end

    def array?
      true
    end

    def composite?
      false
    end

    def exist?
      @values.empty? ? true : @values.all? { |val| val.exist? }
    end

    def definite?
      @values.empty? ? true : @values.all? { |val| val.definite? }
    end

    def contain?(val)
      case sval = val.to_single_value
      when ArrayValue
        if @values.size == sval.values.size
          @values.zip(sval.values).all? { |lhs, rhs| lhs.contain?(rhs) }
        else
          false
        end
      else
        false
      end
    end

    def undefined?
      @values.empty? ? false : @values.all? { |val| val.undefined? }
    end

    def ambiguous?
      @values.empty? ? false : @values.all? { |val| val.ambiguous? }
    end

    def overwrite!(val, tag)
      case sval = val.to_single_value
      when ArrayValue
        @values.zip(sval.values).each do |lhs, rhs|
          rhs && lhs.overwrite!(rhs, tag)
        end
      else
        raise TypeError, "cannot overwrite array with non-array."
      end
    end

    def narrow_domain!(op, ope_val)
      case ope_sval = ope_val.to_single_value
      when ArrayValue
        @values.zip(ope_sval.values).each do |lhs, rhs|
          if rhs
            lhs.narrow_domain!(op, rhs)
          else
            next
          end
        end
      else
        raise TypeError, "cannot narrow array value domain with non-array."
      end
    end

    def widen_domain!(op, ope_val)
      case ope_sval = ope_val.to_single_value
      when ArrayValue
        @values.zip(ope_sval.values).each do |lhs, rhs|
          if rhs
            lhs.widen_domain!(op, rhs)
          else
            next
          end
        end
      else
        raise TypeError, "cannot widen array value domain with non-array."
      end
    end

    def invert_domain!
      @values.each { |val| val.invert_domain! }
    end

    def single_value_unified_with(rhs_val)
      case rhs_sval = rhs_val.to_single_value
      when ArrayValue
        ArrayValue.new(@values.zip(rhs_sval.values).map { |lhs, rhs|
          lhs.single_value_unified_with(rhs)
        })
      else
        raise TypeError, "cannot unify array value with non-array."
      end
    end

    def ~
      # NOTE: When an array variable appears in expressions, object-specifier
      #       of an array variable should be evaluated into a pointer to the
      #       array body.
      dup # NOTREACHED
    end

    def +@
      # NOTE: When an array variable appears in expressions, object-specifier
      #       of an array variable should be evaluated into a pointer to the
      #       array body.
      dup # NOTREACHED
    end

    def -@
      # NOTE: When an array variable appears in expressions, object-specifier
      #       of an array variable should be evaluated into a pointer to the
      #       array body.
      dup # NOTREACHED
    end

    def +(rhs_val)
      # NOTE: When an array variable appears in expressions, object-specifier
      #       of an array variable should be evaluated into a pointer to the
      #       array body.
      dup # NOTREACHED
    end

    def -(rhs_val)
      # NOTE: When an array variable appears in expressions, object-specifier
      #       of an array variable should be evaluated into a pointer to the
      #       array body.
      dup # NOTREACHED
    end

    def *(rhs_val)
      # NOTE: When an array variable appears in expressions, object-specifier
      #       of an array variable should be evaluated into a pointer to the
      #       array body.
      dup # NOTREACHED
    end

    def /(rhs_val)
      # NOTE: When an array variable appears in expressions, object-specifier
      #       of an array variable should be evaluated into a pointer to the
      #       array body.
      dup # NOTREACHED
    end

    def %(rhs_val)
      # NOTE: When an array variable appears in expressions, object-specifier
      #       of an array variable should be evaluated into a pointer to the
      #       array body.
      dup # NOTREACHED
    end

    def &(rhs_val)
      # NOTE: When an array variable appears in expressions, object-specifier
      #       of an array variable should be evaluated into a pointer to the
      #       array body.
      dup # NOTREACHED
    end

    def |(rhs_val)
      # NOTE: When an array variable appears in expressions, object-specifier
      #       of an array variable should be evaluated into a pointer to the
      #       array body.
      dup # NOTREACHED
    end

    def ^(rhs_val)
      # NOTE: When an array variable appears in expressions, object-specifier
      #       of an array variable should be evaluated into a pointer to the
      #       array body.
      dup # NOTREACHED
    end

    def <<(rhs_val)
      # NOTE: When an array variable appears in expressions, object-specifier
      #       of an array variable should be evaluated into a pointer to the
      #       array body.
      dup # NOTREACHED
    end

    def >>(rhs_val)
      # NOTE: When an array variable appears in expressions, object-specifier
      #       of an array variable should be evaluated into a pointer to the
      #       array body.
      dup # NOTREACHED
    end

    def !
      # NOTE: When an array variable appears in expressions, object-specifier
      #       of an array variable should be evaluated into a pointer to the
      #       array body.
      scalar_value_of_false # NOTREACHED
    end

    def <(rhs_val)
      # NOTE: When an array variable appears in expressions, object-specifier
      #       of an array variable should be evaluated into a pointer to the
      #       array body.
      #       So, this comparison operator should not be reached.
      case rhs_sval = rhs_val.to_single_value
      when ArrayValue
        if @values.size == rhs_sval.values.size
          zipped = @values.zip(rhs_sval.values)
          zipped.reduce(scalar_value_of_nil) do |rslt_val, (lhs, rhs)|
            rslt_val.single_value_unified_with(lhs < rhs)
          end
        else
          scalar_value_of_false
        end
      else
        raise TypeError, "comparison between array and non-array."
      end
    end

    def >(rhs_val)
      # NOTE: When an array variable appears in expressions, object-specifier
      #       of an array variable should be evaluated into a pointer to the
      #       array body.
      #       So, this comparison operator should not be reached.
      case rhs_sval = rhs_val.to_single_value
      when ArrayValue
        if @values.size == rhs_sval.values.size
          zipped = @values.zip(rhs_sval.values)
          zipped.reduce(scalar_value_of_nil) do |rslt_val, (lhs, rhs)|
            rslt_val.single_value_unified_with(lhs > rhs)
          end
        else
          scalar_value_of_false
        end
      else
        raise TypeError, "comparison between array and non-array."
      end
    end

    def ==(rhs_val)
      # NOTE: When an array variable appears in expressions, object-specifier
      #       of an array variable should be evaluated into a pointer to the
      #       array body.
      #       So, this comparison operator should not be reached.
      case rhs_sval = rhs_val.to_single_value
      when ArrayValue
        if @values.size == rhs_sval.values.size
          zipped = @values.zip(rhs_sval.values)
          zipped.reduce(scalar_value_of_nil) do |rslt_val, (lhs, rhs)|
            rslt_val.single_value_unified_with(lhs == rhs)
          end
        else
          scalar_value_of_false
        end
      else
        raise TypeError, "comparison between array and non-array."
      end
    end

    def !=(rhs_val)
      # NOTE: When an array variable appears in expressions, object-specifier
      #       of an array variable should be evaluated into a pointer to the
      #       array body.
      #       So, this comparison operator should not be reached.
      case rhs_sval = rhs_val.to_single_value
      when ArrayValue
        if @values.size == rhs_sval.values.size
          zipped = @values.zip(rhs_sval.values)
          zipped.reduce(scalar_value_of_nil) do |rslt_val, (lhs, rhs)|
            rslt_val.single_value_unified_with(lhs != rhs)
          end
        else
          scalar_value_of_false
        end
      else
        raise TypeError, "comparison between array and non-array."
      end
    end

    def <=(rhs_val)
      # NOTE: When an array variable appears in expressions, object-specifier
      #       of an array variable should be evaluated into a pointer to the
      #       array body.
      #       So, this comparison operator should not be reached.
      case rhs_sval = rhs_val.to_single_value
      when ArrayValue
        if @values.size == rhs_sval.values.size
          zipped = @values.zip(rhs_sval.values)
          zipped.reduce(scalar_value_of_nil) do |rslt_val, (lhs, rhs)|
            rslt_val.single_value_unified_with(lhs <= rhs)
          end
        else
          scalar_value_of_false
        end
      else
        raise TypeError, "comparison between array and non-array."
      end
    end

    def >=(rhs_val)
      # NOTE: When an array variable appears in expressions, object-specifier
      #       of an array variable should be evaluated into a pointer to the
      #       array body.
      #       So, this comparison operator should not be reached.
      case rhs_sval = rhs_val.to_single_value
      when ArrayValue
        if @values.size == rhs_sval.values.size
          zipped = @values.zip(rhs_sval.values)
          zipped.reduce(scalar_value_of_nil) do |rslt_val, (lhs, rhs)|
            rslt_val.single_value_unified_with(lhs >= rhs)
          end
        else
          scalar_value_of_false
        end
      else
        raise TypeError, "comparison between array and non-array."
      end
    end

    def logical_and(rhs_val)
      # NOTE: When an array variable appears in expressions, object-specifier
      #       of an array variable should be evaluated into a pointer to the
      #       array body.
      #       So, this comparison operator should not be reached.
      case rhs_sval = rhs_val.to_single_value
      when ArrayValue
        if @values.size == rhs_sval.values.size
          zipped = @values.zip(rhs_sval.values)
          zipped.reduce(scalar_value_of_nil) do |rslt_val, (lhs, rhs)|
            rslt_val.single_value_unified_with(lhs.logical_and(rhs))
          end
        else
          scalar_value_of_false
        end
      else
        raise TypeError, "comparison between array and non-array."
      end
    end

    def logical_or(rhs_val)
      # NOTE: When an array variable appears in expressions, object-specifier
      #       of an array variable should be evaluated into a pointer to the
      #       array body.
      #       So, this comparison operator should not be reached.
      case rhs_sval = rhs_val.to_single_value
      when ArrayValue
        if @values.size == rhs_sval.values.size
          zipped = @values.zip(rhs_sval.values)
          zipped.reduce(scalar_value_of_nil) do |rslt_val, (lhs, rhs)|
            rslt_val.single_value_unified_with(lhs.logical_or(rhs))
          end
        else
          scalar_value_of_false
        end
      else
        raise TypeError, "comparison between array and non-array."
      end
    end

    def test_must_be_equal_to(val)
      case sval = val.to_single_value
      when ArrayValue
        TrivialValueTest.new((self == sval).test_must_be_true.result)
      else
        raise TypeError, "comparison between array and non-array."
      end
    end

    def test_may_be_equal_to(val)
      case sval = val.to_single_value
      when ArrayValue
        TrivialValueTest.new((self == sval).test_may_be_true.result)
      else
        raise TypeError, "comparison between array and non-array."
      end
    end

    def test_must_not_be_equal_to(val)
      case sval = val.to_single_value
      when ArrayValue
        TrivialValueTest.new((self != sval).test_must_be_true.result)
      else
        raise TypeError, "comparison between array and non-array."
      end
    end

    def test_may_not_be_equal_to(val)
      case sval = val.to_single_value
      when ArrayValue
        TrivialValueTest.new((self != sval).test_may_be_true.result)
      else
        raise TypeError, "comparison between array and non-array."
      end
    end

    def test_must_be_less_than(val)
      case sval = value.to_single_value
      when ArrayValue
        TrivialValueTest.new((self < sval).test_must_be_true.result)
      else
        raise TypeError, "comparison between array and non-array."
      end
    end

    def test_may_be_less_than(val)
      case sval = val.to_single_value
      when ArrayValue
        TrivialValueTest.new((self < sval).test_may_be_true.result)
      else
        raise TypeError, "comparison between array and non-array."
      end
    end

    def test_must_be_greater_than(val)
      case sval = val.to_single_value
      when ArrayValue
        TrivialValueTest.new((self > sval).test_must_be_true.result)
      else
        raise TypeError, "comparison between array and non-array."
      end
    end

    def test_may_be_greater_than(val)
      case sval = val.to_single_value
      when ArrayValue
        TrivialValueTest.new((self > sval).test_may_be_true.result)
      else
        raise TypeError, "comparison between array and non-array."
      end
    end

    def test_must_be_null
      TrivialValueTest.new(@values.all? { |val| val.test_must_be_null.result })
    end

    def test_may_be_null
      TrivialValueTest.new(@values.all? { |val| val.test_may_be_null.result })
    end

    def test_must_be_true
      # NOTE: When an array variable appears in expressions, object-specifier
      #       of an array variable should be evaluated into a pointer to the
      #       array body.
      #       So, this method should not be reached.
      TrivialValueTest.new(@values.all? { |val| val.test_must_be_true.result })
    end

    def test_may_be_true
      # NOTE: When an array variable appears in expressions, object-specifier
      #       of an array variable should be evaluated into a pointer to the
      #       array body.
      #       So, this method should not be reached.
      TrivialValueTest.new(@values.all? { |val| val.test_may_be_true.result })
    end

    def test_must_be_false
      # NOTE: When an array variable appears in expressions, object-specifier
      #       of an array variable should be evaluated into a pointer to the
      #       array body.
      #       So, this method should not be reached.
      TrivialValueTest.new(
        @values.all? { |val| val.test_must_be_false.result })
    end

    def test_may_be_false
      # NOTE: When an array variable appears in expressions, object-specifier
      #       of an array variable should be evaluated into a pointer to the
      #       array body.
      #       So, this method should not be reached.
      TrivialValueTest.new(@values.all? { |val| val.test_may_be_false.result })
    end

    def coerce_to(type)
      type.coerce_array_value(self)
    end

    def to_enum
      # FIXME: This method generates only one of sample values.
      @values.map { |val| val.to_enum.first }
    end

    def to_defined_value
      ArrayValue.new(@values.map { |val| val.to_defined_value })
    end

    def eql?(rhs_val)
      rhs_val.kind_of?(ArrayValue) && @values.eql?(rhs_val.values)
    end

    def hash
      @values.hash
    end

    def dup
      ArrayValue.new(@values.map { |val| val.dup })
    end

    private
    def logical_shr?
      @values.all? { |val| val.logical_shr? }
    end
    memoize :logical_shr?
  end

  class CompositeValue < SingleValue
    def initialize(vals)
      @values = vals
    end

    attr_reader :values

    def scalar?
      false
    end

    def array?
      false
    end

    def composite?
      true
    end

    def exist?
      @values.empty? ? true : @values.all? { |val| val.exist? }
    end

    def definite?
      @values.empty? ? true : @values.all? { |val| val.definite? }
    end

    def contain?(val)
      case sval = val.to_single_value
      when CompositeValue
        if @values.size == sval.values.size
          @values.zip(sval.values).all? { |lhs, rhs| lhs.contain?(rhs) }
        else
          false
        end
      else
        false
      end
    end

    def undefined?
      @values.empty? ? false : @values.all? { |val| val.undefined? }
    end

    def ambiguous?
      @values.empty? ? false : @values.all? { |val| val.ambiguous? }
    end

    def overwrite!(val, tag)
      case sval = val.to_single_value
      when CompositeValue
        @values.zip(sval.values).each do |lhs, rhs|
          rhs && lhs.overwrite!(rhs, tag)
        end
      else
        raise TypeError, "cannot overwrite composite with non-composite."
      end
    end

    def narrow_domain!(op, ope_val)
      case ope_sval = ope_val.to_single_value
      when CompositeValue
        @values.zip(ope_sval.values).each do |lhs, rhs|
          if rhs
            lhs.narrow_domain!(op, rhs)
          else
            next
          end
        end
      else
        raise TypeError,
          "cannot narrow composite value domain with non-composite."
      end
    end

    def widen_domain!(op, ope_val)
      case ope_sval = ope_val.to_single_value
      when CompositeValue
        @values.zip(ope_sval.values).each do |lhs, rhs|
          if rhs
            lhs.widen_domain!(op, rhs)
          else
            next
          end
        end
      else
        raise TypeError,
          "cannot widen composite value domain with non-composite."
      end
    end

    def invert_domain!
      @values.each { |val| val.invert_domain! }
    end

    def single_value_unified_with(rhs_val)
      case rhs_sval = rhs_val.to_single_value
      when CompositeValue
        CompositeValue.new(
          @values.zip(rhs_sval.values).map { |lhs, rhs|
            lhs.single_value_unified_with(rhs)
          })
      else
        raise TypeError, "cannot unify composite value with non-composite."
      end
    end

    def ~
      # NOTE: A composite variable cannot appear in expressions except the
      #       primary-expression(object-specifier followed by `.').
      dup # NOTREACHED
    end

    def +@
      # NOTE: A composite variable cannot appear in expressions except the
      #       primary-expression(object-specifier followed by `.').
      dup # NOTREACHED
    end

    def -@
      # NOTE: A composite variable cannot appear in expressions except the
      #       primary-expression(object-specifier followed by `.').
      dup # NOTREACHED
    end

    def +(rhs_val)
      # NOTE: A composite variable cannot appear in expressions except the
      #       primary-expression(object-specifier followed by `.').
      dup # NOTREACHED
    end

    def -(rhs_val)
      # NOTE: A composite variable cannot appear in expressions except the
      #       primary-expression(object-specifier followed by `.').
      dup # NOTREACHED
    end

    def *(rhs_val)
      # NOTE: A composite variable cannot appear in expressions except the
      #       primary-expression(object-specifier followed by `.').
      dup # NOTREACHED
    end

    def /(rhs_val)
      # NOTE: A composite variable cannot appear in expressions except the
      #       primary-expression(object-specifier followed by `.').
      dup # NOTREACHED
    end

    def %(rhs_val)
      # NOTE: A composite variable cannot appear in expressions except the
      #       primary-expression(object-specifier followed by `.').
      dup # NOTREACHED
    end

    def &(rhs_val)
      # NOTE: A composite variable cannot appear in expressions except the
      #       primary-expression(object-specifier followed by `.').
      dup # NOTREACHED
    end

    def |(rhs_val)
      # NOTE: A composite variable cannot appear in expressions except the
      #       primary-expression(object-specifier followed by `.').
      dup # NOTREACHED
    end

    def ^(rhs_val)
      # NOTE: A composite variable cannot appear in expressions except the
      #       primary-expression(object-specifier followed by `.').
      dup # NOTREACHED
    end

    def <<(rhs_val)
      # NOTE: A composite variable cannot appear in expressions except the
      #       primary-expression(object-specifier followed by `.').
      dup # NOTREACHED
    end

    def >>(rhs_val)
      # NOTE: A composite variable cannot appear in expressions except the
      #       primary-expression(object-specifier followed by `.').
      dup # NOTREACHED
    end

    def !
      # NOTE: A composite variable cannot appear in expressions except the
      #       primary-expression(object-specifier followed by `.').
      scalar_value_of_false # NOTREACHED
    end

    def <(rhs_val)
      # NOTE: A composite variable cannot appear in expressions except the
      #       primary-expression(object-specifier followed by `.').
      case rhs_sval = rhs_val.to_single_value
      when CompositeValue
        if @values.size == rhs_sval.values.size
          zipped = @values.zip(rhs_sval.values)
          zipped.reduce(scalar_value_of_nil) do |rslt_val, (lhs, rhs)|
            rslt_val.single_value_unified_with(lhs < rhs)
          end
        else
          scalar_value_of_false
        end
      else
        raise TypeError, "comparison between composite and non-composite."
      end
    end

    def >(rhs_val)
      # NOTE: A composite variable cannot appear in expressions except the
      #       primary-expression(object-specifier followed by `.').
      case rhs_sval = rhs_val.to_single_value
      when CompositeValue
        if @values.size == rhs_sval.values.size
          zipped = @values.zip(rhs_sval.values)
          zipped.reduce(scalar_value_of_nil) do |rslt_val, (lhs, rhs)|
            rslt_val.single_value_unified_with(lhs > rhs)
          end
        else
          scalar_value_of_false
        end
      else
        raise TypeError, "comparison between composite and non-composite."
      end
    end

    def ==(rhs_val)
      # NOTE: A composite variable cannot appear in expressions except the
      #       primary-expression(object-specifier followed by `.').
      case rhs_sval = rhs_val.to_single_value
      when CompositeValue
        if @values.size == rhs_sval.values.size
          zipped = @values.zip(rhs_sval.values)
          zipped.reduce(scalar_value_of_nil) do |rslt_val, (lhs, rhs)|
            rslt_val.single_value_unified_with(lhs == rhs)
          end
        else
          scalar_value_of_false
        end
      else
        raise TypeError, "comparison between composite and non-composite."
      end
    end

    def !=(rhs_val)
      # NOTE: A composite variable cannot appear in expressions except the
      #       primary-expression(object-specifier followed by `.').
      case rhs_sval = rhs_val.to_single_value
      when CompositeValue
        if @values.size == rhs_sval.values.size
          zipped = @values.zip(rhs_sval.values)
          zipped.reduce(scalar_value_of_nil) do |rslt_val, (lhs, rhs)|
            rslt_val.single_value_unified_with(lhs != rhs)
          end
        else
          scalar_value_of_false
        end
      else
        raise TypeError, "comparison between composite and non-composite."
      end
    end

    def <=(rhs_val)
      # NOTE: A composite variable cannot appear in expressions except the
      #       primary-expression(object-specifier followed by `.').
      case rhs_sval = rhs_val.to_single_value
      when CompositeValue
        if @values.size == rhs_sval.values.size
          zipped = @values.zip(rhs_sval.values)
          zipped.reduce(scalar_value_of_nil) do |rslt_val, (lhs, rhs)|
            rslt_val.single_value_unified_with(lhs <= rhs)
          end
        else
          scalar_value_of_false
        end
      else
        raise TypeError, "comparison between composite and non-composite."
      end
    end

    def >=(rhs_val)
      # NOTE: A composite variable cannot appear in expressions except the
      #       primary-expression(object-specifier followed by `.').
      case rhs_sval = rhs_val.to_single_value
      when CompositeValue
        if @values.size == rhs_sval.values.size
          zipped = @values.zip(rhs_sval.values)
          zipped.reduce(scalar_value_of_nil) do |rslt_val, (lhs, rhs)|
            rslt_val.single_value_unified_with(lhs >= rhs)
          end
        else
          scalar_value_of_false
        end
      else
        raise TypeError, "comparison between composite and non-composite."
      end
    end

    def logical_and(rhs_val)
      # NOTE: A composite variable cannot appear in expressions except the
      #       primary-expression(object-specifier followed by `.').
      case rhs_sval = rhs_val.to_single_value
      when CompositeValue
        if @values.size == rhs_sval.values.size
          zipped = @values.zip(rhs_sval.values)
          zipped.reduce(scalar_value_of_nil) do |rslt_val, (lhs, rhs)|
            rslt_val.single_value_unified_with(lhs.logical_and(rhs))
          end
        else
          scalar_value_of_false
        end
      else
        raise TypeError, "comparison between composite and non-composite."
      end
    end

    def logical_or(rhs_val)
      # NOTE: A composite variable cannot appear in expressions except the
      #       primary-expression(object-specifier followed by `.').
      case rhs_sval = rhs_val.to_single_value
      when CompositeValue
        if @values.size == rhs_sval.values.size
          zipped = @values.zip(rhs_sval.values)
          zipped.reduce(scalar_value_of_nil) do |rslt_val, (lhs, rhs)|
            rslt_val.single_value_unified_with(lhs.logical_or(rhs))
          end
        else
          scalar_value_of_false
        end
      else
        raise TypeError, "comparison between composite and non-composite."
      end
    end

    def test_must_be_equal_to(val)
      case sval = val.to_single_value
      when CompositeValue
        TrivialValueTest.new((self == sval).test_must_be_true.result)
      else
        raise TypeError, "comparison between composite and non-composite."
      end
    end

    def test_may_be_equal_to(val)
      case sval = val.to_single_value
      when CompositeValue
        TrivialValueTest.new((self == sval).test_may_be_true.result)
      else
        raise TypeError, "comparison between composite and non-composite."
      end
    end

    def test_must_not_be_equal_to(val)
      case sval = val.to_single_value
      when CompositeValue
        TrivialValueTest.new((self != sval).test_must_be_true.result)
      else
        raise TypeError, "comparison between composite and non-composite."
      end
    end

    def test_may_not_be_equal_to(val)
      case sval = val.to_single_value
      when CompositeValue
        TrivialValueTest.new((self != sval).test_may_be_true.result)
      else
        raise TypeError, "comparison between composite and non-composite."
      end
    end

    def test_must_be_less_than(val)
      case sval = val.to_single_value
      when CompositeValue
        TrivialValueTest.new((self < sval).test_must_be_true.result)
      else
        raise TypeError, "comparison between composite and non-composite."
      end
    end

    def test_may_be_less_than(val)
      case sval = val.to_single_value
      when CompositeValue
        TrivialValueTest.new((self < sval).test_may_be_true.result)
      else
        raise TypeError, "comparison between composite and non-composite."
      end
    end

    def test_must_be_greater_than(val)
      case sval = val.to_single_value
      when CompositeValue
        TrivialValueTest.new((self > sval).test_must_be_true.result)
      else
        raise TypeError, "comparison between composite and non-composite."
      end
    end

    def test_may_be_greater_than(val)
      case sval = val.to_single_value
      when CompositeValue
        TrivialValueTest.new((self > sval).test_may_be_true.result)
      else
        raise TypeError, "comparison between composite and non-composite."
      end
    end

    def test_must_be_null
      TrivialValueTest.new(@values.all? { |val| val.test_must_be_null.result })
    end

    def test_may_be_null
      TrivialValueTest.new(@values.all? { |val| val.test_may_be_null.result })
    end

    def test_must_be_true
      # NOTE: A composite variable cannot appear in expressions except the
      #       primary-expression(object-specifier followed by `.').
      TrivialValueTest.new(@values.all? { |val| val.test_must_be_true.result })
    end

    def test_may_be_true
      # NOTE: A composite variable cannot appear in expressions except the
      #       primary-expression(object-specifier followed by `.').
      TrivialValueTest.new(@values.all? { |val| val.test_may_be_true.result })
    end

    def test_must_be_false
      # NOTE: A composite variable cannot appear in expressions except the
      #       primary-expression(object-specifier followed by `.').
      TrivialValueTest.new(
        @values.all? { |val| val.test_must_be_false.result })
    end

    def test_may_be_false
      # NOTE: A composite variable cannot appear in expressions except the
      #       primary-expression(object-specifier followed by `.').
      TrivialValueTest.new(@values.all? { |val| val.test_may_be_false.result })
    end

    def coerce_to(type)
      type.coerce_composite_value(self)
    end

    def to_enum
      # FIXME: This method generates only one of sample values.
      @values.map { |val| val.to_enum.first }
    end

    def to_defined_value
      CompositeValue.new(@values.map { |val| val.to_defined_value })
    end

    def eql?(rhs_val)
      rhs_val.kind_of?(CompositeValue) && @values.eql?(rhs_val.values)
    end

    def hash
      @values.hash
    end

    def dup
      CompositeValue.new(@values.map { |val| val.dup })
    end

    private
    def logical_shr?
      @values.all? { |val| val.logical_shr? }
    end
    memoize :logical_shr?
  end

  class NontrivialTestEvidence < TestEvidence
    def initialize(exact)
      @exact = exact
      @positive_contribs = []
      @negative_contribs = []
    end

    attr_reader :positive_contribs
    attr_reader :negative_contribs

    def fulfilled?
      if @exact
        @negative_contribs.any? { |mval| mval._base.tag.traceable? }
      else
        @positive_contribs.any? { |mval| mval._base.tag.traceable? } &&
          @negative_contribs.any? { |mval| mval._base.tag.traceable? }
      end
    end

    def add_positive_contributor(mval)
      @positive_contribs.push(mval)
    end

    def add_negative_contributor(mval)
      @negative_contribs.push(mval)
    end
  end

  class UndefinableTestEvidence < NontrivialTestEvidence
    # NOTE: Context tracing feature will be mixed-in at trace.rb later.
  end

  class NullabilityTestEvidence < NontrivialTestEvidence
    # NOTE: Context tracing feature will be mixed-in at trace.rb later.
  end

  class DefinableTestEvidence < NontrivialTestEvidence
    # NOTE: Context tracing feature will be mixed-in at trace.rb later.

    def initialize(pred, exact)
      super(exact)
      @predicate = pred
    end
  end

  class NontrivialValueTest < ValueTest
    def initialize(evid, exact)
      super(evid)
      @exact = exact
    end

    def result
      # NOTE: TestEvidence of an NontrivialValueTest must be a kind of
      #       NontrivialTestEvidence.
      if @exact
        !evidence.positive_contribs.empty? && evidence.negative_contribs.empty?
      else
        !evidence.positive_contribs.empty?
      end
    end
  end

  class TransitionTag
    def initialize(by = nil, at = nil)
      self.by = by
      self.at = at
    end

    # NOTE: This value is generated by `by' points to AST nodes.
    attr_reader :by

    def by=(by)
      @by = by ? by.dup.compact.uniq : []
    end

    # NOTE: This value is generated in `at' points to branch trees.
    attr_reader :at

    def at=(at)
      @at = at ? at.dup.compact.uniq : []
    end

    def traceable?
      !@by.empty?
    end

    def merge!(tag)
      if tag
        if at == tag.at
          self.by = tag.by + by
          self.at = tag.at + at
        else
          self.by = tag.by
          self.at = tag.at
        end
      end
    end

    def pretty_print(pp)
      {
        by: @by.map(&:location),
        at: @at.map { |br| br.ctrlexpr.to_expr }.compact.map(&:location)
      }.pretty_print(pp)
    end
  end

  class ValueTransition
    include Enumerable

    Snapshot = Struct.new(:value, :tag)
    private_constant :Snapshot

    def initialize(mval)
      @ordered_snapshots = create_ordered_snapshots(mval)
    end

    def first
      @ordered_snapshots.first
    end

    def last
      @ordered_snapshots.last
    end

    def each(&block)
      if block_given?
        @ordered_snapshots.each(&block)
      else
        to_enum(:each)
      end
    end

    private
    def create_ordered_snapshots(mval)
      if mval.ancestor
        older = create_ordered_snapshots(mval.ancestor)
      else
        older = []
      end
      older.push(Snapshot.new(mval._base.value, mval._base.tag))
    end
  end

  class MultipleValue < Value
    Base = Struct.new(:value, :tag)
    private_constant :Base

    def initialize(val, ancestor, tag)
      @base = Base.new(val.to_single_value, tag)
      @ancestor = ancestor
      @descendants = []
    end

    attr_reader :ancestor

    def scalar?
      _base.value.scalar?
    end

    def array?
      _base.value.array?
    end

    def composite?
      _base.value.composite?
    end

    def undefined?
      effective_values.all? { |mval| mval._base.value.undefined? }
    end

    def ambiguous?
      effective_values.all? { |mval| mval._base.value.ambiguous? }
    end

    def exist?
      effective_values.any? { |mval| mval._base.value.exist? }
    end

    def definite?
      effective_values.all? { |mval| mval._base.value.definite? }
    end

    def contain?(val)
      sval = val.to_single_value
      effective_values.any? { |mval| mval._base.value.contain?(sval) }
    end

    def multiple?
      true
    end

    def overwrite!(val, tag)
      sval = val.to_single_value
      effective_values.each do |mval|
        mval._base.value.overwrite!(sval, nil)
        mval._base.tag.merge!(tag)
      end
    end

    def narrow_domain!(op, ope_val)
      ope_sval = ope_val.to_single_value
      effective_values.each do |mval|
        if anc = mval.ancestor
          anc._base.value.narrow_domain!(op.for_complement, ope_sval)
        end
        mval._base.value.narrow_domain!(op, ope_sval)
      end
    end

    def widen_domain!(op, ope_val)
      ope_sval = ope_val.to_single_value
      effective_values.each do |mval|
        # NOTE: Value domain widening is used to widen the controlling
        #       variables's value only when the interpreter simulates an
        #       iteration statement.
        #       So, domain complementing is unnecessary for this purpose.
        #
        # if anc = mval.ancestor
        #   anc._base.value.narrow_domain!(op.for_complement, ope_sval)
        # end

        mval._base.value.widen_domain!(op, ope_sval)

        # NOTE: No code is corresponding to the controlling variable's value
        #       widenning.
        mval._base.tag.by = nil
        mval._base.tag.at = nil
      end
    end

    def invert_domain!
      effective_values.each do |mval|
        mval._base.value.invert_domain!
      end
    end

    def single_value_unified_with(rhs_val)
      to_single_value.single_value_unified_with(rhs_val)
    end

    def fork
      same_val = @descendants.find { |desc| desc.eql?(_base.value) }
      if same_val
        same_val._base.tag.by = _base.tag.by + same_val._base.tag.by
        same_val._base.tag.at = _base.tag.at + same_val._base.tag.at
        same_val
      else
        MultipleValue.new(_base.value.dup, self, _base.tag.dup).tap do |desc|
          @descendants.push(desc)
        end
      end
    end

    def rollback!
      @descendants.pop
    end

    def delete_descendants!
      @descendants.clear
    end

    def ~
      ~to_single_value
    end

    def +@
      +to_single_value
    end

    def -@
      -to_single_value
    end

    def +(rhs_val)
      to_single_value + rhs_val.to_single_value
    end

    def -(rhs_val)
      to_single_value - rhs_val.to_single_value
    end

    def *(rhs_val)
      to_single_value * rhs_val.to_single_value
    end

    def /(rhs_val)
      to_single_value / rhs_val.to_single_value
    end

    def %(rhs_val)
      to_single_value % rhs_val.to_single_value
    end

    def &(rhs_val)
      to_single_value & rhs_val.to_single_value
    end

    def |(rhs_val)
      to_single_value | rhs_val.to_single_value
    end

    def ^(rhs_val)
      to_single_value ^ rhs_val.to_single_value
    end

    def <<(rhs_val)
      to_single_value << rhs_val.to_single_value
    end

    def >>(rhs_val)
      to_single_value >> rhs_val.to_single_value
    end

    def !
      !to_single_value
    end

    def <(rhs_val)
      to_single_value < rhs_val.to_single_value
    end

    def >(rhs_val)
      to_single_value > rhs_val.to_single_value
    end

    def ==(rhs_val)
      to_single_value == rhs_val.to_single_value
    end

    def !=(rhs_val)
      to_single_value != rhs_val.to_single_value
    end

    def <=(rhs_val)
      to_single_value <= rhs_val.to_single_value
    end

    def >=(rhs_val)
      to_single_value >= rhs_val.to_single_value
    end

    def logical_and(rhs_val)
      to_single_value.logical_and(rhs_val.to_single_value)
    end

    def logical_or(rhs_val)
      to_single_value.logical_or(rhs_val.to_single_value)
    end

    def test_must_be_undefined
      evid = UndefinableTestEvidence.new(true)
      effective_values.each do |mval|
        if mval._base.value.test_must_be_undefined.true?
          evid.add_positive_contributor(mval)
        else
          evid.add_negative_contributor(mval)
        end
        break if evid.fulfilled?
      end
      NontrivialValueTest.new(evid, true)
    end

    def test_may_be_undefined
      evid = UndefinableTestEvidence.new(false)
      effective_values.each do |mval|
        if mval._base.value.test_may_be_undefined.true?
          evid.add_positive_contributor(mval)
        else
          evid.add_negative_contributor(mval)
        end
        break if evid.fulfilled?
      end
      NontrivialValueTest.new(evid, false)
    end

    def test_must_be_equal_to(val)
      sval = val.to_single_value
      non_nil_vals = effective_values.select { |mval| mval._base.value.exist? }
      if non_nil_vals.empty?
        TrivialValueTest.new(false)
      else
        pred = lambda { |v| v.test_must_be_equal_to(sval).true? }
        evid = DefinableTestEvidence.new(pred, true)
        non_nil_vals.each do |mval|
          if pred.call(mval._base.value)
            evid.add_positive_contributor(mval)
          else
            evid.add_negative_contributor(mval)
          end
          break if evid.fulfilled?
        end
        NontrivialValueTest.new(evid, true)
      end
    end

    def test_may_be_equal_to(val)
      sval = val.to_single_value
      pred = lambda { |v| v.test_may_be_equal_to(sval).true? }
      evid = DefinableTestEvidence.new(pred, false)
      effective_values.each do |mval|
        if pred.call(mval._base.value)
          evid.add_positive_contributor(mval)
        else
          evid.add_negative_contributor(mval)
        end
        break if evid.fulfilled?
      end
      NontrivialValueTest.new(evid, false)
    end

    def test_must_not_be_equal_to(val)
      sval = val.to_single_value
      non_nil_vals = effective_values.select { |mval| mval._base.value.exist? }
      if non_nil_vals.empty?
        TrivialValueTest.new(false)
      else
        pred = lambda { |v| v.test_must_not_be_equal_to(sval).true? }
        evid = DefinableTestEvidence.new(pred, true)
        non_nil_vals.each do |mval|
          if pred.call(mval._base.value)
            evid.add_positive_contributor(mval)
          else
            evid.add_negative_contributor(mval)
          end
          break if evid.fulfilled?
        end
        NontrivialValueTest.new(evid, true)
      end
    end

    def test_may_not_be_equal_to(val)
      sval = val.to_single_value
      pred = lambda { |v| v.test_may_not_be_equal_to(sval).true? }
      evid = DefinableTestEvidence.new(pred, false)
      effective_values.each do |mval|
        if pred.call(mval._base.value)
          evid.add_positive_contributor(mval)
        else
          evid.add_negative_contributor(mval)
        end
        break if evid.fulfilled?
      end
      NontrivialValueTest.new(evid, false)
    end

    def test_must_be_less_than(val)
      sval = val.to_single_value
      non_nil_vals = effective_values.select { |mval| mval._base.value.exist? }
      if non_nil_vals.empty?
        TrivialValueTest.new(false)
      else
        pred = lambda { |v| v.test_must_be_less_than(sval).true? }
        evid = DefinableTestEvidence.new(pred, true)
        non_nil_vals.each do |mval|
          if pred.call(mval._base.value)
            evid.add_positive_contributor(mval)
          else
            evid.add_negative_contributor(mval)
          end
          break if evid.fulfilled?
        end
        NontrivialValueTest.new(evid, true)
      end
    end

    def test_may_be_less_than(val)
      sval = val.to_single_value
      pred = lambda { |v| v.test_may_be_less_than(sval).true? }
      evid = DefinableTestEvidence.new(pred, false)
      effective_values.each do |mval|
        if pred.call(mval._base.value)
          evid.add_positive_contributor(mval)
        else
          evid.add_negative_contributor(mval)
        end
        break if evid.fulfilled?
      end
      NontrivialValueTest.new(evid, false)
    end

    def test_must_be_greater_than(val)
      sval = val.to_single_value
      non_nil_vals = effective_values.select { |mval| mval._base.value.exist? }
      if non_nil_vals.empty?
        TrivialValueTest.new(false)
      else
        pred = lambda { |v| v.test_must_be_greater_than(sval).true? }
        evid = DefinableTestEvidence.new(pred, true)
        non_nil_vals.each do |mval|
          if pred.call(mval._base.value)
            evid.add_positive_contributor(mval)
          else
            evid.add_negative_contributor(mval)
          end
          break if evid.fulfilled?
        end
        NontrivialValueTest.new(evid, true)
      end
    end

    def test_may_be_greater_than(val)
      sval = val.to_single_value
      pred = lambda { |v| v.test_may_be_greater_than(sval).true? }
      evid = DefinableTestEvidence.new(pred, false)
      effective_values.any? do |mval|
        if pred.call(mval._base.value)
          evid.add_positive_contributor(mval)
        else
          evid.add_negative_contributor(mval)
        end
        break if evid.fulfilled?
      end
      NontrivialValueTest.new(evid, false)
    end

    def test_must_be_null
      non_nil_vals = effective_values.select { |mval| mval._base.value.exist? }
      if non_nil_vals.empty?
        TrivialValueTest.new(false)
      else
        evid = NullabilityTestEvidence.new(true)
        non_nil_vals.each do |mval|
          if mval._base.value.test_must_be_null.true?
            evid.add_positive_contributor(mval)
          else
            evid.add_negative_contributor(mval)
          end
          break if evid.fulfilled?
        end
        NontrivialValueTest.new(evid, true)
      end
    end

    def test_may_be_null
      evid = NullabilityTestEvidence.new(false)
      effective_values.each do |mval|
        if mval._base.value.test_may_be_null.true?
          evid.add_positive_contributor(mval)
        else
          evid.add_negative_contributor(mval)
        end
        break if evid.fulfilled?
      end
      NontrivialValueTest.new(evid, false)
    end

    def test_must_be_true
      non_nil_vals = effective_values.select { |mval| mval._base.value.exist? }
      if non_nil_vals.empty?
        TrivialValueTest.new(false)
      else
        pred = lambda { |val| val.test_must_be_true.true? }
        evid = DefinableTestEvidence.new(pred, true)
        non_nil_vals.each do |mval|
          if pred.call(mval._base.value)
            evid.add_positive_contributor(mval)
          else
            evid.add_negative_contributor(mval)
          end
          break if evid.fulfilled?
        end
        NontrivialValueTest.new(evid, true)
      end
    end

    def test_may_be_true
      pred = lambda { |val| val.test_may_be_true.true? }
      evid = DefinableTestEvidence.new(pred, false)
      effective_values.each do |mval|
        if pred.call(mval._base.value)
          evid.add_positive_contributor(mval)
        else
          evid.add_negative_contributor(mval)
        end
        break if evid.fulfilled?
      end
      NontrivialValueTest.new(evid, false)
    end

    def test_must_be_false
      non_nil_vals = effective_values.select { |mval| mval._base.value.exist? }
      if non_nil_vals.empty?
        TrivialValueTest.new(false)
      else
        pred = lambda { |val| val.test_must_be_false.true? }
        evid = DefinableTestEvidence.new(pred, true)
        non_nil_vals.each do |mval|
          if pred.call(mval._base.value)
            evid.add_positive_contributor(mval)
          else
            evid.add_negative_contributor(mval)
          end
          break if evid.fulfilled?
        end
        NontrivialValueTest.new(evid, true)
      end
    end

    def test_may_be_false
      pred = lambda { |val| val.test_may_be_false.true? }
      evid = DefinableTestEvidence.new(pred, false)
      effective_values.each do |mval|
        if pred.call(mval._base.value)
          evid.add_positive_contributor(mval)
        else
          evid.add_negative_contributor(mval)
        end
        break if evid.fulfilled?
      end
      NontrivialValueTest.new(evid, false)
    end

    def transition
      ValueTransition.new(self)
    end

    def coerce_to(type)
      sval = to_single_value.coerce_to(type)
      MultipleValue.new(sval, nil, _base.tag.dup)
    end

    def to_enum
      to_single_value.to_enum
    end

    def to_single_value
      # NOTE: The _base.value of the MultipleValue object must be a
      #       SingleValue.
      effective_values.map { |mval| mval._base.value }.reduce { |unified, sval|
        unified.single_value_unified_with(sval)
      }
    end

    def to_defined_value
      to_single_value.to_defined_value
    end

    def eql?(rhs_val)
      to_single_value.eql?(rhs_val.to_single_value)
    end

    def hash
      to_single_value.hash
    end

    def dup
      MultipleValue.new(to_single_value.dup, nil, _base.tag.dup)
    end

    def effective_values
      @descendants.empty? ? [self] : @descendants
    end

    def descendants
      if @descendants.empty?
        [self]
      else
        @descendants.map { |mval| mval.descendants }.flatten
      end
    end

    def _base
      # NOTE: This method will be invoked only from this file.
      @base
    end
  end

  class VersionedValue < MultipleValue
    def initialize(orig_val, tag)
      # NOTE: `orig_val.to_single_value' will be done in
      #       MultipleValue#initialize.
      super(orig_val, nil, tag)

      @version_controller = ValueVersionController.new(self)
    end

    def enter_versioning_group
      @version_controller.enter_new_versioning_group
    end

    def leave_versioning_group(raise_complement)
      @version_controller.copy_current_version if raise_complement
      @version_controller.merge_forked_versions
      @version_controller.leave_current_versioning_group
      invalidate_memo!
    end

    def begin_versioning
      @version_controller.begin_forking
    end

    def end_versioning
      @version_controller.end_forking
      invalidate_memo!
    end

    def thin_latest_version!(with_rollback)
      @version_controller.thin_current_version(with_rollback)
      invalidate_memo!
    end

    def rollback_all_versions!
      delete_descendants!
      orig_val = @version_controller.original_value
      @version_controller = nil
      _orig_overwrite!(orig_val, TransitionTag.new)
      @version_controller = ValueVersionController.new(self)
      invalidate_memo!
    end

    alias :_orig_overwrite! :overwrite!

    def overwrite!(val, tag)
      @version_controller.fork_current_version
      super
      @version_controller.mark_current_versioning_group_as_sticky
      invalidate_memo!
    end

    def force_overwrite!(val)
      # NOTE: This method will be invoked only from VariableTable#define.
      sval = val.to_single_value
      @version_controller.original_value.overwrite!(sval, nil)
      _orig_overwrite!(sval, nil)
      invalidate_memo!
    end

    def narrow_domain!(op, ope_val)
      @version_controller.fork_current_version
      super
      invalidate_memo!
    end

    def widen_domain!(op, ope_val)
      @version_controller.fork_current_version
      super
      @version_controller.mark_current_versioning_group_as_sticky
      invalidate_memo!
    end

    def invert_domain!
      @version_controller.fork_current_version
      super
      invalidate_memo!
    end

    def coerce_to(type)
      VersionedValue.new(to_single_value.coerce_to(type), _base.tag.dup)
    end

    def effective_values
      @version_controller ? @version_controller.current_values : [self]
    end

    memoize :to_single_value

    def invalidate_memo!
      forget_memo_of__to_single_value
    end

    private
    def compact_descendants!
      @descendants = @version_controller.current_values.reject { |mval|
        mval.equal?(self)
      }.uniq
    end
  end

  class ValueVersionController
    def initialize(orig_val)
      @versioning_group_stack = [RootVersioningGroup.new(orig_val)]
    end

    def original_value
      root_versioning_group.initial_values.first
    end

    def current_values
      current_versioning_group.current_values
    end

    def enter_new_versioning_group
      new_group = VersioningGroup.new(current_versioning_group.current_version)
      @versioning_group_stack.push(new_group)
    end

    def leave_current_versioning_group
      @versioning_group_stack.pop
    end

    def begin_forking
      current_versioning_group.begin_new_version
    end

    def end_forking
      current_versioning_group.end_current_version
    end

    def fork_current_version
      fork_all_versions
    end

    def thin_current_version(with_rollback)
      # NOTE: This method must be called in the forking section.

      forked = current_version.forked?

      if with_rollback
        initial_vals = current_version.initial_values
        current_versioning_group.delete_current_version_completely
        base_vals = current_versioning_group.base_values
        base_vals.zip(initial_vals).each do |mval, init_val|
          mval.rollback! if forked
          mval.overwrite!(init_val, TransitionTag.new) if init_val
        end
        begin_forking
      else
        current_versioning_group.delete_current_version
        if forked
          current_versioning_group.base_values.each { |mval| mval.rollback! }
        end
      end

      mark_current_versioning_group_as_sticky
    end

    def mark_current_versioning_group_as_sticky
      @versioning_group_stack.reverse_each do |group|
        if group.sticky?
          break
        else
          group.sticky = true
        end
      end
    end

    def copy_current_version
      # NOTE: This method must be called between ending of the forking section
      #       and ending of the versioning group.
      if current_versioning_group.sticky?
        current_values.each { |mval| mval.fork }
      end
    end

    def merge_forked_versions
      # NOTE: This method must be called between ending of the forking section
      #       and ending of the versioning group.
      base_ver = current_versioning_group.base_version

      case
      when current_versioning_group.sticky?
        fork_all_versions
        base_vals = base_ver.values.map { |mval| mval.descendants }.flatten
        base_ver.values = base_vals.each_with_object({}) { |mval, hash|
          if eql_mval = hash[mval]
            eql_mval._base.tag.by = mval._base.tag.by + eql_mval._base.tag.by
            eql_mval._base.tag.at = mval._base.tag.at + eql_mval._base.tag.at
          else
            hash[mval] = mval
          end
        }.keys
      when current_versioning_group.versions_forked?
        # NOTE: When versions in the current versioning group have been forked,
        #       base_version of the current versioning group has already been
        #       forked.  So, it is safe to overwrite the base_version's values
        #       with the current versioning group's initial snapshot values.
        init_vals = current_versioning_group.initial_values
        vals = base_ver.values.zip(init_vals)
        vals.each do |base_mval, init_sval|
          base_mval.delete_descendants!
          if base_mval.kind_of?(VersionedValue)
            base_mval._orig_overwrite!(init_sval, TransitionTag.new)
          else
            base_mval.overwrite!(init_sval, TransitionTag.new)
          end
        end
      else
        # NOTE: Nothing to be done when base_version of the current versioning
        #       group has not been forked.
      end
    end

    private
    def fork_all_versions
      parent_group = root_versioning_group
      active_versioning_groups.each do |active_group|
        active_group.base_version = parent_group.current_version
        active_group.fork_all_versions
        parent_group = active_group
      end
    end

    def root_versioning_group
      @versioning_group_stack.first
    end

    def active_versioning_groups
      @versioning_group_stack.drop(1)
    end

    def current_versioning_group
      @versioning_group_stack.last
    end

    def current_version
      current_versioning_group.current_version
    end

    class VersioningGroup
      def initialize(base_ver, sticky = false)
        @base_version = base_ver
        @sticky = sticky
        @initial_values = base_ver.values.map { |mval| mval._base.value.dup }
        @current_version = nil
        @all_versions = []
      end

      attr_accessor :base_version
      attr_writer :sticky
      attr_reader :initial_values

      def sticky?
        @sticky
      end

      def versions_forked?
        @all_versions.any? { |ver| ver.forked? }
      end

      def base_values
        @base_version.values
      end

      def current_version
        @current_version || @base_version
      end

      def current_values
        current_version.values
      end

      def begin_new_version
        @current_version = Version.new(base_values)
        @all_versions.push(@current_version)
      end

      def end_current_version
        @current_version = nil
      end

      def delete_current_version_completely
        end_current_version
        delete_current_version
      end

      def delete_current_version
        @all_versions.pop
      end

      def fork_all_versions
        @all_versions.each { |ver| ver.fork_from(@base_version) }
      end
    end
    private_constant :VersioningGroup

    class RootVersioningGroup < VersioningGroup
      def initialize(orig_val)
        super(Version.new([orig_val], true), true)
      end
    end
    private_constant :RootVersioningGroup

    class Version
      def initialize(vals, original = false)
        @values = vals
        @initial_values = []
        @state = original ? :original : :forking
      end

      attr_accessor :values
      attr_reader :initial_values

      def original?
        @state == :original
      end

      def forking?
        @state == :forking
      end

      def forked?
        @state == :forked
      end

      def fork_from(base_ver)
        if forking?
          @values = base_ver.values.map { |mval| mval.fork }
          @initial_values = @values.each_with_object([]) { |val, ary|
            ary.push(val.to_single_value.dup)
          }
          @state = :forked
        end
      end
    end
    private_constant :Version
  end

end
end
