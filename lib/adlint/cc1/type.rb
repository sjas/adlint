# C type models.
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

require "adlint/traits"
require "adlint/token"
require "adlint/util"
require "adlint/cc1/syntax"
require "adlint/cc1/scope"
require "adlint/cc1/object"
require "adlint/cc1/conv"
require "adlint/cc1/option"
require "adlint/cc1/operator"

module AdLint #:nodoc:
module Cc1 #:nodoc:

  module StandardTypeCatalogAccessor
    # NOTE: Host class must respond to #standard_type_catalog.

    extend Forwardable

    def_delegator :standard_type_catalog, :void_t
    def_delegator :standard_type_catalog, :char_t
    def_delegator :standard_type_catalog, :signed_char_t
    def_delegator :standard_type_catalog, :unsigned_char_t
    def_delegator :standard_type_catalog, :short_t
    def_delegator :standard_type_catalog, :signed_short_t
    def_delegator :standard_type_catalog, :unsigned_short_t
    def_delegator :standard_type_catalog, :short_int_t
    def_delegator :standard_type_catalog, :signed_short_int_t
    def_delegator :standard_type_catalog, :unsigned_short_int_t
    def_delegator :standard_type_catalog, :int_t
    def_delegator :standard_type_catalog, :signed_t
    def_delegator :standard_type_catalog, :signed_int_t
    def_delegator :standard_type_catalog, :unsigned_t
    def_delegator :standard_type_catalog, :unsigned_int_t
    def_delegator :standard_type_catalog, :long_t
    def_delegator :standard_type_catalog, :signed_long_t
    def_delegator :standard_type_catalog, :unsigned_long_t
    def_delegator :standard_type_catalog, :long_int_t
    def_delegator :standard_type_catalog, :signed_long_int_t
    def_delegator :standard_type_catalog, :unsigned_long_int_t
    def_delegator :standard_type_catalog, :long_long_t
    def_delegator :standard_type_catalog, :signed_long_long_t
    def_delegator :standard_type_catalog, :unsigned_long_long_t
    def_delegator :standard_type_catalog, :long_long_int_t
    def_delegator :standard_type_catalog, :signed_long_long_int_t
    def_delegator :standard_type_catalog, :unsigned_long_long_int_t
    def_delegator :standard_type_catalog, :extended_big_int_t
    def_delegator :standard_type_catalog, :float_t
    def_delegator :standard_type_catalog, :double_t
    def_delegator :standard_type_catalog, :long_double_t
  end

  # == DESCRIPTION
  # === Type class hierarchy
  #  Type
  #    <-- UndeclaredType
  #    <-- UnresolvedType
  #    <-- QualifiedType
  #    <-- VoidType
  #    <-- FunctionType
  #    <-- ScalarDataType --------> UsualArithmeticTypeConversion <<module>>
  #          <-- IntegerType
  #                <-- StandardIntegerType
  #                      <-- CharType
  #                      <-- SignedCharType
  #                      <-- UnsignedCharType
  #                      <-- ShortType
  #                      <-- SignedShortType
  #                      <-- UnsignedShortType
  #                      <-- ShortIntType
  #                      <-- SignedShortIntType
  #                      <-- UnsignedShortIntType
  #                      <-- IntType
  #                      <-- SignedType
  #                      <-- SignedIntType
  #                      <-- UnsignedType
  #                      <-- UnsignedIntType
  #                      <-- LongType
  #                      <-- SignedLongType
  #                      <-- UnsignedLongType
  #                      <-- LongIntType
  #                      <-- SignedLongIntType
  #                      <-- UnsignedLongIntType
  #                      <-- LongLongType
  #                      <-- SignedLongLongType
  #                      <-- UnsignedLongLongType
  #                      <-- LongLongIntType
  #                      <-- SignedLongLongIntType
  #                      <-- UnsignedLongLongIntType
  #                <-- ExtendedBigIntType
  #                <-- BitfieldType
  #                <-- EnumType ----------------------> Scopeable <<module>>
  #                <-- PointerType                          ^
  #          <-- FloatingType                               |
  #                <-- StandardFloatingType                 |
  #                      <-- FloatType                      |
  #                      <-- DoubleType                     |
  #                      <-- LongDoubleType                 |
  #    <-- ArrayType                                        |
  #    <-- CompositeDataType -------------------------------+
  #          <-- StructType                                 |
  #          <-- UnionType                                  |
  #    <-- UserType ----------------------------------------+
  #    <-- ParameterType -----------------------------------+
  class Type
    include Visitable
    include StandardTypeCatalogAccessor
    include ArithmeticAccessor
    include StandardTypesAccessor

    def initialize(type_tbl, name, type_dcls = [])
      @type_table   = type_tbl
      @name         = name
      @declarations = type_dcls
    end

    attr_reader :type_table
    attr_reader :name
    attr_reader :declarations

    def id
      subclass_responsibility
    end

    def image
      subclass_responsibility
    end

    def brief_image
      subclass_responsibility
    end

    def location
      subclass_responsibility
    end

    def bit_size
      subclass_responsibility
    end

    def byte_size
      (bit_size / 8.0).ceil
    end

    def bit_alignment
      subclass_responsibility
    end

    def byte_alignment
      (bit_alignment / 8.0).ceil
    end

    def aligned_bit_size
      bit_size + (bit_alignment - bit_size)
    end

    def aligned_byte_size
      (aligned_bit_size / 8.0).ceil
    end

    def real_type
      subclass_responsibility
    end

    def base_type
      subclass_responsibility
    end

    def unqualify
      subclass_responsibility
    end

    def incomplete?
      subclass_responsibility
    end

    def compatible?(to_type)
      subclass_responsibility
    end

    def coercible?(to_type)
      subclass_responsibility
    end

    def convertible?(to_type)
      self.same_as?(to_type)
    end

    def more_cv_qualified?(than_type)
      false
    end

    def same_as?(type)
      self.real_type.unqualify == type.real_type.unqualify
    end

    def parameter?
      false
    end

    def scalar?
      subclass_responsibility
    end

    def integer?
      subclass_responsibility
    end

    def floating?
      subclass_responsibility
    end

    def array?
      subclass_responsibility
    end

    def composite?
      struct? || union?
    end

    def struct?
      subclass_responsibility
    end

    def union?
      subclass_responsibility
    end

    def pointer?
      subclass_responsibility
    end

    def qualified?
      subclass_responsibility
    end

    def function?
      subclass_responsibility
    end

    def enum?
      subclass_responsibility
    end

    def user?
      subclass_responsibility
    end

    def void?
      subclass_responsibility
    end

    def standard?
      subclass_responsibility
    end

    def undeclared?
      subclass_responsibility
    end

    def unresolved?
      subclass_responsibility
    end

    def const?
      subclass_responsibility
    end

    def volatile?
      subclass_responsibility
    end

    def restrict?
      subclass_responsibility
    end

    def bitfield?
      subclass_responsibility
    end

    def signed?
      subclass_responsibility
    end

    def unsigned?
      !signed?
    end

    def explicitly_signed?
      subclass_responsibility
    end

    def have_va_list?
      subclass_responsibility
    end

    def return_type
      subclass_responsibility
    end

    def parameter_types
      subclass_responsibility
    end

    def enumerators
      subclass_responsibility
    end

    def length
      subclass_responsibility
    end

    def length=(len)
      subclass_responsibility
    end

    def impl_length
      subclass_responsibility
    end

    def members
      subclass_responsibility
    end

    def member_named(name)
      subclass_responsibility
    end

    def min
      subclass_responsibility
    end

    def max
      subclass_responsibility
    end

    def nil_value
      subclass_responsibility
    end

    def zero_value
      subclass_responsibility
    end

    def arbitrary_value
      subclass_responsibility
    end

    def undefined_value
      subclass_responsibility
    end

    def parameter_value
      subclass_responsibility
    end

    def return_value
      subclass_responsibility
    end

    def coerce_scalar_value(val)
      subclass_responsibility
    end

    def coerce_array_value(val)
      subclass_responsibility
    end

    def coerce_composite_value(val)
      subclass_responsibility
    end

    def integer_conversion_rank
      subclass_responsibility
    end

    def integer_promoted_type
      subclass_responsibility
    end

    def argument_promoted_type
      subclass_responsibility
    end

    def arithmetic_type_with(type)
      subclass_responsibility
    end

    def _arithmetic_type_with_undeclared(lhs_type, rhs_type = self)
      subclass_responsibility
    end

    def _arithmetic_type_with_unresolved(lhs_type, rhs_type = self)
      subclass_responsibility
    end

    def _arithmetic_type_with_void(lhs_type, rhs_type = self)
      subclass_responsibility
    end

    def _arithmetic_type_with_function(lhs_type, rhs_type = self)
      subclass_responsibility
    end

    def _arithmetic_type_with_char(lhs_type, rhs_type = self)
      subclass_responsibility
    end

    def _arithmetic_type_with_signed_char(lhs_type, rhs_type = self)
      subclass_responsibility
    end

    def _arithmetic_type_with_unsigned_char(lhs_type, rhs_type = self)
      subclass_responsibility
    end

    def _arithmetic_type_with_short(lhs_type, rhs_type = self)
      subclass_responsibility
    end

    def _arithmetic_type_with_signed_short(lhs_type, rhs_type = self)
      subclass_responsibility
    end

    def _arithmetic_type_with_unsigned_short(lhs_type, rhs_type = self)
      subclass_responsibility
    end

    def _arithmetic_type_with_short_int(lhs_type, rhs_type = self)
      subclass_responsibility
    end

    def _arithmetic_type_with_signed_short_int(lhs_type, rhs_type = self)
      subclass_responsibility
    end

    def _arithmetic_type_with_unsigned_short_int(lhs_type, rhs_type = self)
      subclass_responsibility
    end

    def _arithmetic_type_with_int(lhs_type, rhs_type = self)
      subclass_responsibility
    end

    def _arithmetic_type_with_signed(lhs_type, rhs_type = self)
      subclass_responsibility
    end

    def _arithmetic_type_with_signed_int(lhs_type, rhs_type = self)
      subclass_responsibility
    end

    def _arithmetic_type_with_unsigned(lhs_type, rhs_type = self)
      subclass_responsibility
    end

    def _arithmetic_type_with_unsigned_int(lhs_type, rhs_type = self)
      subclass_responsibility
    end

    def _arithmetic_type_with_long(lhs_type, rhs_type = self)
      subclass_responsibility
    end

    def _arithmetic_type_with_signed_long(lhs_type, rhs_type = self)
      subclass_responsibility
    end

    def _arithmetic_type_with_unsigned_long(lhs_type, rhs_type = self)
      subclass_responsibility
    end

    def _arithmetic_type_with_long_int(lhs_type, rhs_type = self)
      subclass_responsibility
    end

    def _arithmetic_type_with_signed_long_int(lhs_type, rhs_type = self)
      subclass_responsibility
    end

    def _arithmetic_type_with_unsigned_long_int(lhs_type, rhs_type = self)
      subclass_responsibility
    end

    def _arithmetic_type_with_long_long(lhs_type, rhs_type = self)
      subclass_responsibility
    end

    def _arithmetic_type_with_signed_long_long(lhs_type, rhs_type = self)
      subclass_responsibility
    end

    def _arithmetic_type_with_unsigned_long_long(lhs_type, rhs_type = self)
      subclass_responsibility
    end

    def _arithmetic_type_with_long_long_int(lhs_type, rhs_type = self)
      subclass_responsibility
    end

    def _arithmetic_type_with_signed_long_long_int(lhs_type, rhs_type = self)
      subclass_responsibility
    end

    def _arithmetic_type_with_unsigned_long_long_int(lhs_type, rhs_type = self)
      subclass_responsibility
    end

    def _arithmetic_type_with_float(lhs_type, rhs_type = self)
      subclass_responsibility
    end

    def _arithmetic_type_with_double(lhs_type, rhs_type = self)
      subclass_responsibility
    end

    def _arithmetic_type_with_long_double(lhs_type, rhs_type = self)
      subclass_responsibility
    end

    def _arithmetic_type_with_bitfield(lhs_type, rhs_type = self)
      subclass_responsibility
    end

    def _arithmetic_type_with_enum(lhs_type, rhs_type = self)
      subclass_responsibility
    end

    def _arithmetic_type_with_pointer(lhs_type, rhs_type = self)
      subclass_responsibility
    end

    def _arithmetic_type_with_array(lhs_type, rhs_type = self)
      subclass_responsibility
    end

    def _arithmetic_type_with_struct(lhs_type, rhs_type = self)
      subclass_responsibility
    end

    def _arithmetic_type_with_union(lhs_type, rhs_type = self)
      subclass_responsibility
    end

    def _arithmetic_type_with_extended_big_int(lhs_type, rhs_type = self)
      subclass_responsibility
    end

    def corresponding_signed_type
      subclass_responsibility
    end

    def corresponding_unsigned_type
      subclass_responsibility
    end

    def ==(rhs_type)
      case rhs_type
      when Type
        id == rhs_type.id
      else
        super
      end
    end

    def dup
      subclass_responsibility
    end

    def inspect
      if @name == image
        if location
          "#{@name} (#{location.inspect})"
        else
          @name
        end
      else
        if location
          "#{@name}=>#{image} (#{location.inspect})"
        else
          "#{@name}=>#{image}"
        end
      end
    end

    extend Forwardable

    def_delegator :@type_table, :traits
    private :traits

    def_delegator :@type_table, :standard_type_catalog
    private :standard_type_catalog
  end

  class TypeId
    def initialize(val)
      @value = val
    end

    def ==(rhs_id)
      @value == rhs_id.value
    end

    def eql?(rhs_id)
      self == rhs_id
    end

    def hash
      @value.hash
    end

    protected
    attr_reader :value
  end

  class StandardTypeId < TypeId
    def initialize(name)
      super(name.split(" ").sort.join(" "))
    end
  end

  class UndeclaredType < Type
    def initialize(type_tbl)
      super(type_tbl, "__adlint__undeclared_type")
    end

    def id
      @id ||= TypeId.new(name)
    end

    def image
      name
    end

    def brief_image
      name
    end

    def location
      nil
    end

    def bit_size
      0
    end

    def bit_alignment
      0
    end

    def real_type
      self
    end

    def base_type
      self
    end

    def unqualify
      self
    end

    def incomplete?
      true
    end

    def compatible?(to_type)
      false
    end

    def coercible?(to_type)
      false
    end

    def convertible?(to_type)
      false
    end

    def same_as?(type)
      false
    end

    def scalar?
      false
    end

    def integer?
      false
    end

    def floating?
      false
    end

    def array?
      false
    end

    def struct?
      false
    end

    def union?
      false
    end

    def pointer?
      false
    end

    def qualified?
      false
    end

    def function?
      false
    end

    def enum?
      false
    end

    def user?
      false
    end

    def void?
      false
    end

    def standard?
      false
    end

    def undeclared?
      true
    end

    def unresolved?
      false
    end

    def const?
      false
    end

    def volatile?
      false
    end

    def restrict?
      false
    end

    def bitfield?
      false
    end

    def signed?
      false
    end

    def explicitly_signed?
      false
    end

    def have_va_list?
      false
    end

    def return_type
      self
    end

    def parameter_types
      []
    end

    def enumerators
      []
    end

    def length
      0
    end

    def impl_length
      0
    end

    def members
      []
    end

    def member_named(name)
      nil
    end

    def min
      0
    end

    def max
      0
    end

    def nil_value
      ScalarValue.of_nil(logical_right_shift?) # NOTREACHED
    end

    def zero_value
      ScalarValue.of_nil(logical_right_shift?) # NOTREACHED
    end

    def arbitrary_value
      ScalarValue.of_nil(logical_right_shift?) # NOTREACHED
    end

    def undefined_value
      ScalarValue.of_nil(logical_right_shift?) # NOTREACHED
    end

    def parameter_value
      ScalarValue.of_nil(logical_right_shift?) # NOTREACHED
    end

    def return_value
      ScalarValue.of_nil(logical_right_shift?) # NOTREACHED
    end

    def coerce_scalar_value(val)
      ScalarValue.of_nil(logical_right_shift?) # NOTREACHED
    end

    def coerce_array_value(val)
      ScalarValue.of_nil(logical_right_shift?) # NOTREACHED
    end

    def coerce_composite_value(val)
      ScalarValue.of_nil(logical_right_shift?) # NOTREACHED
    end

    def integer_conversion_rank
      0 # NOTREACHED
    end

    def integer_promoted_type
      self # NOTREACHED
    end

    def argument_promoted_type
      self # NOTREACHED
    end

    def arithmetic_type_with(type)
      # NOTE: An arithmetic operation with UndeclaredType must not be executed!
      type._arithmetic_type_with_undeclared(self)
    end

    def _arithmetic_type_with_undeclared(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UndeclaredType must not be executed!
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_unresolved(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UndeclaredType must not be executed!
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_void(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UndeclaredType must not be executed!
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_function(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UndeclaredType must not be executed!
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_char(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UndeclaredType must not be executed!
      # NOTE: Binary operation with `char' and UndeclaredType
      #       makes integer-promoted type of `char'.
      lhs_type.integer_promoted_type # NOTREACHED
    end

    def _arithmetic_type_with_signed_char(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UndeclaredType must not be executed!
      # NOTE: Binary operation with `signed char' and UndeclaredType
      #       makes integer-promoted type of `signed char'.
      lhs_type.integer_promoted_type # NOTREACHED
    end

    def _arithmetic_type_with_unsigned_char(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UndeclaredType must not be executed!
      # NOTE: Binary operation with `unsigned char' and UndeclaredType
      #       makes integer-promoted type of `unsigned char'.
      lhs_type.integer_promoted_type # NOTREACHED
    end

    def _arithmetic_type_with_short(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UndeclaredType must not be executed!
      # NOTE: Binary operation with `short' and UndeclaredType
      #       makes integer-promoted type of `short'.
      lhs_type.integer_promoted_type # NOTREACHED
    end

    def _arithmetic_type_with_signed_short(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UndeclaredType must not be executed!
      # NOTE: Binary operation with `signed short' and UndeclaredType
      #       makes integer-promoted type of `signed short'.
      lhs_type.integer_promoted_type # NOTREACHED
    end

    def _arithmetic_type_with_unsigned_short(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UndeclaredType must not be executed!
      # NOTE: Binary operation with `unsigned short' and UndeclaredType
      #       makes integer-promoted type of `unsigned short'.
      lhs_type.integer_promoted_type # NOTREACHED
    end

    def _arithmetic_type_with_short_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UndeclaredType must not be executed!
      # NOTE: Binary operation with `short int' and UndeclaredType
      #       makes integer-promoted type of `short int'.
      lhs_type.integer_promoted_type # NOTREACHED
    end

    def _arithmetic_type_with_signed_short_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UndeclaredType must not be executed!
      # NOTE: Binary operation with `signed short int' and UndeclaredType
      #       makes integer-promoted type of `signed short int'.
      lhs_type.integer_promoted_type # NOTREACHED
    end

    def _arithmetic_type_with_unsigned_short_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UndeclaredType must not be executed!
      # NOTE: Binary operation with `unsigned short int' and UndeclaredType
      #       makes integer-promoted type of `unsigned short int'.
      lhs_type.integer_promoted_type # NOTREACHED
    end

    def _arithmetic_type_with_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UndeclaredType must not be executed!
      # NOTE: Binary operation with `int' and UndeclaredType makes `int'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_signed(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UndeclaredType must not be executed!
      # NOTE: Binary operation with `signed' and UndeclaredType makes `signed'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_signed_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UndeclaredType must not be executed!
      # NOTE: Binary operation with `signed int' and UndeclaredType
      #       makes `signed int'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_unsigned(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UndeclaredType must not be executed!
      # NOTE: Binary operation with `unsigned' and UndeclaredType
      #       makes `unsigned'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_unsigned_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UndeclaredType must not be executed!
      # NOTE: Binary operation with `unsigned int' and UndeclaredType
      #       makes `unsigned int'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_long(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UndeclaredType must not be executed!
      # NOTE: Binary operation with `long' and UndeclaredType makes `long'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_signed_long(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UndeclaredType must not be executed!
      # NOTE: Binary operation with `signed long' and UndeclaredType
      #       makes `signed long'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_unsigned_long(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UndeclaredType must not be executed!
      # NOTE: Binary operation with `unsigned long' and UndeclaredType
      #       makes `unsigned long'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_long_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UndeclaredType must not be executed!
      # NOTE: Binary operation with `long int' and UndeclaredType
      #       makes `long int'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_signed_long_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UndeclaredType must not be executed!
      # NOTE: Binary operation with `signed long int' and UndeclaredType
      #       makes `signed long int'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_unsigned_long_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UndeclaredType must not be executed!
      # NOTE: Binary operation with `unsigned long int' and UndeclaredType
      #       makes `unsigned long int'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_long_long(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UndeclaredType must not be executed!
      # NOTE: Binary operation with `long long' and UndeclaredType
      #       makes `long long'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_signed_long_long(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UndeclaredType must not be executed!
      # NOTE: Binary operation with `signed long long' and UndeclaredType
      #       makes `signed long long'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_unsigned_long_long(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UndeclaredType must not be executed!
      # NOTE: Binary operation with `unsigned long long' and UndeclaredType
      #       makes `unsigned long long'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_long_long_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UndeclaredType must not be executed!
      # NOTE: Binary operation with `long long int' and UndeclaredType
      #       makes `long long int'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_signed_long_long_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UndeclaredType must not be executed!
      # NOTE: Binary operation with `signed long long int' and UndeclaredType
      #       makes `signed long long int'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_unsigned_long_long_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UndeclaredType must not be executed!
      # NOTE: Binary operation with `unsigned long long int' and UndeclaredType
      #       makes `unsigned long long int'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_float(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UndeclaredType must not be executed!
      # NOTE: Binary operation with `float' and UndeclaredType makes `float'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_double(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UndeclaredType must not be executed!
      # NOTE: Binary operation with `double' and UndeclaredType makes `double'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_long_double(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UndeclaredType must not be executed!
      # NOTE: Binary operation with `long double' and UndeclaredType
      #       makes `long double'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_bitfield(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UndeclaredType must not be executed!
      # NOTE: Binary operation with BitfieldType and UndeclaredType
      #       makes integer-promoted type of BitfieldType.
      lhs_type.integer_promoted_type # NOTREACHED
    end

    def _arithmetic_type_with_enum(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UndeclaredType must not be executed!
      # NOTE: Binary operation with EnumType and UndeclaredType makes EnumType.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_pointer(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UndeclaredType must not be executed!
      # NOTE: Binary operation with PointerType and UndeclaredType
      #       makes PointerType.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_array(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UndeclaredType must not be executed!
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_struct(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UndeclaredType must not be executed!
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_union(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UndeclaredType must not be executed!
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_extended_big_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UndeclaredType must not be executed!
      # NOTE: Binary operation with ExtendedBigIntType and UndeclaredType
      #       makes ExtendedBigIntType.
      lhs_type # NOTREACHED
    end

    def corresponding_signed_type
      self # NOTREACHED
    end

    def corresponding_unsigned_type
      self # NOTREACHED
    end

    def dup
      UndeclaredType.new(type_table)
    end
  end

  class UnresolvedType < Type
    def initialize(type_tbl)
      super(type_tbl, "__adlint__unresolved_type")
    end

    def id
      @id ||= TypeId.new(name)
    end

    def image
      name
    end

    def brief_image
      name
    end

    def location
      nil
    end

    def bit_size
      0
    end

    def bit_alignment
      0
    end

    def real_type
      self
    end

    def base_type
      self
    end

    def unqualify
      self
    end

    def incomplete?
      true
    end

    def compatible?(to_type)
      false
    end

    def coercible?(to_type)
      false
    end

    def convertible?(to_type)
      false
    end

    def same_as?(type)
      false
    end

    def scalar?
      false
    end

    def integer?
      false
    end

    def floating?
      false
    end

    def array?
      false
    end

    def struct?
      false
    end

    def union?
      false
    end

    def pointer?
      false
    end

    def qualified?
      false
    end

    def function?
      false
    end

    def enum?
      false
    end

    def user?
      false
    end

    def void?
      false
    end

    def standard?
      false
    end

    def undeclared?
      false
    end

    def unresolved?
      true
    end

    def const?
      false
    end

    def volatile?
      false
    end

    def restrict?
      false
    end

    def bitfield?
      false
    end

    def signed?
      false
    end

    def explicitly_signed?
      false
    end

    def have_va_list?
      false
    end

    def return_type
      self
    end

    def parameter_types
      []
    end

    def enumerators
      []
    end

    def length
      0
    end

    def impl_length
      0
    end

    def members
      []
    end

    def member_named(name)
      nil
    end

    def min
      0
    end

    def max
      0
    end

    def nil_value
      ScalarValue.of_nil(logical_right_shift?)
    end

    def zero_value
      ScalarValue.of_nil(logical_right_shift?)
    end

    def arbitrary_value
      ScalarValue.of_nil(logical_right_shift?)
    end

    def undefined_value
      ScalarValue.of_nil(logical_right_shift?)
    end

    def parameter_value
      ScalarValue.of_nil(logical_right_shift?)
    end

    def return_value
      ScalarValue.of_nil(logical_right_shift?)
    end

    def coerce_scalar_value(val)
      ScalarValue.of_nil(logical_right_shift?)
    end

    def coerce_array_value(val)
      ScalarValue.of_nil(logical_right_shift?)
    end

    def coerce_composite_value(val)
      ScalarValue.of_nil(logical_right_shift?)
    end

    def integer_conversion_rank
      0 # NOTREACHED
    end

    def integer_promoted_type
      self # NOTREACHED
    end

    def argument_promoted_type
      self # NOTREACHED
    end

    def arithmetic_type_with(type)
      # NOTE: An arithmetic operation with UnresolvedType must not be executed!
      type._arithmetic_type_with_unresolved(self)
    end

    def _arithmetic_type_with_undeclared(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UnresolvedType must not be executed!
      rhs_type.arithmetic_type_with(lhs_type)
    end

    def _arithmetic_type_with_unresolved(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UnresolvedType must not be executed!
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_void(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UnresolvedType must not be executed!
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_function(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UnresolvedType must not be executed!
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_char(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UnresolvedType must not be executed!
      # NOTE: Binary operation with `char' and UnresolvedType
      #       makes integer-promoted type of `char'.
      lhs_type.integer_promoted_type # NOTREACHED
    end

    def _arithmetic_type_with_signed_char(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UnresolvedType must not be executed!
      # NOTE: Binary operation with `signed char' and UnresolvedType
      #       makes integer-promoted type of `signed char'.
      lhs_type.integer_promoted_type # NOTREACHED
    end

    def _arithmetic_type_with_unsigned_char(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UnresolvedType must not be executed!
      # NOTE: Binary operation with `unsigned char' and UnresolvedType
      #       makes integer-promoted type of `unsigned char'.
      lhs_type.integer_promoted_type # NOTREACHED
    end

    def _arithmetic_type_with_short(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UnresolvedType must not be executed!
      # NOTE: Binary operation with `short' and UnresolvedType
      #       makes integer-promoted type of `short'.
      lhs_type.integer_promoted_type # NOTREACHED
    end

    def _arithmetic_type_with_signed_short(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UnresolvedType must not be executed!
      # NOTE: Binary operation with `signed short' and UnresolvedType
      #       makes integer-promoted type of `signed short'.
      lhs_type.integer_promoted_type # NOTREACHED
    end

    def _arithmetic_type_with_unsigned_short(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UnresolvedType must not be executed!
      # NOTE: Binary operation with `unsigned short' and UnresolvedType
      #       makes integer-promoted type of `unsigned short'.
      lhs_type.integer_promoted_type # NOTREACHED
    end

    def _arithmetic_type_with_short_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UnresolvedType must not be executed!
      # NOTE: Binary operation with `short int' and UnresolvedType
      #       makes integer-promoted type of `short int'.
      lhs_type.integer_promoted_type # NOTREACHED
    end

    def _arithmetic_type_with_signed_short_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UnresolvedType must not be executed!
      # NOTE: Binary operation with `signed short int' and UnresolvedType
      #       makes integer-promoted type of `signed short int'.
      lhs_type.integer_promoted_type # NOTREACHED
    end

    def _arithmetic_type_with_unsigned_short_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UnresolvedType must not be executed!
      # NOTE: Binary operation with `unsigned short int' and UnresolvedType
      #       makes integer-promoted type of `unsigned short int'.
      lhs_type.integer_promoted_type # NOTREACHED
    end

    def _arithmetic_type_with_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UnresolvedType must not be executed!
      # NOTE: Binary operation with `int' and UnresolvedType makes `int'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_signed(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UnresolvedType must not be executed!
      # NOTE: Binary operation with `signed' and UnresolvedType makes `signed'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_signed_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UnresolvedType must not be executed!
      # NOTE: Binary operation with `signed int' and UnresolvedType
      #       makes `signed int'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_unsigned(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UnresolvedType must not be executed!
      # NOTE: Binary operation with `unsigned' and UnresolvedType
      #       makes `unsigned'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_unsigned_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UnresolvedType must not be executed!
      # NOTE: Binary operation with `unsigned int' and UnresolvedType
      #       makes `unsigned int'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_long(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UnresolvedType must not be executed!
      # NOTE: Binary operation with `long' and UnresolvedType makes `long'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_signed_long(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UnresolvedType must not be executed!
      # NOTE: Binary operation with `signed long' and UnresolvedType
      #       makes `signed long'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_unsigned_long(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UnresolvedType must not be executed!
      # NOTE: Binary operation with `unsigned long' and UnresolvedType
      #       makes `unsigned long'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_long_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UnresolvedType must not be executed!
      # NOTE: Binary operation with `long int' and UnresolvedType
      #       makes `long int'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_signed_long_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UnresolvedType must not be executed!
      # NOTE: Binary operation with `signed long int' and UnresolvedType
      #       makes `signed long int'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_unsigned_long_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UnresolvedType must not be executed!
      # NOTE: Binary operation with `unsigned long int' and UnresolvedType
      #       makes `unsigned long int'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_long_long(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UnresolvedType must not be executed!
      # NOTE: Binary operation with `long long' and UnresolvedType
      #       makes `long long'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_signed_long_long(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UnresolvedType must not be executed!
      # NOTE: Binary operation with `signed long long' and UnresolvedType
      #       makes `signed long long'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_unsigned_long_long(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UnresolvedType must not be executed!
      # NOTE: Binary operation with `unsigned long long' and UnresolvedType
      #       makes `unsigned long long'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_long_long_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UnresolvedType must not be executed!
      # NOTE: Binary operation with `long long int' and UnresolvedType
      #       makes `long long int'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_signed_long_long_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UnresolvedType must not be executed!
      # NOTE: Binary operation with `signed long long int' and UnresolvedType
      #       makes `signed long long int'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_unsigned_long_long_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UnresolvedType must not be executed!
      # NOTE: Binary operation with `unsigned long long int' and UnresolvedType
      #       makes `unsigned long long int'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_float(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UnresolvedType must not be executed!
      # NOTE: Binary operation with `float' and UnresolvedType makes `float'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_double(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UnresolvedType must not be executed!
      # NOTE: Binary operation with `double' and UnresolvedType makes `double'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_long_double(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UnresolvedType must not be executed!
      # NOTE: Binary operation with `long double' and UnresolvedType
      #       makes `long double'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_bitfield(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UnresolvedType must not be executed!
      # NOTE: Binary operation with BitfieldType and UnresolvedType
      #       makes integer-promoted type of BitfieldType.
      lhs_type.integer_promoted_type # NOTREACHED
    end

    def _arithmetic_type_with_enum(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UnresolvedType must not be executed!
      # NOTE: Binary operation with EnumType and UnresolvedType makes EnumType.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_pointer(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UnresolvedType must not be executed!
      # NOTE: Binary operation with PointerType and UnresolvedType
      #       makes PointerType.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_array(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UnresolvedType must not be executed!
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_struct(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UnresolvedType must not be executed!
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_union(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UnresolvedType must not be executed!
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_extended_big_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with UnresolvedType must not be executed!
      # NOTE: Binary operation with ExtendedBigIntType and UnresolvedType
      #       makes ExtendedBigIntType.
      lhs_type # NOTREACHED
    end

    def corresponding_signed_type
      self # NOTREACHED
    end

    def corresponding_unsigned_type
      self # NOTREACHED
    end

    def dup
      UnresolvedType.new(type_table)
    end
  end

  class QualifiedType < Type
    def initialize(type_tbl, base_type, *cvr_quals)
      super(type_tbl, create_name(base_type, cvr_quals))
      @base_type = base_type
      @cvr_qualifiers = cvr_quals
    end

    attr_reader :base_type

    def id
      @id ||= QualifiedTypeId.new(@base_type, @cvr_qualifiers)
    end

    def image
      @image ||= create_image(@base_type, @cvr_qualifiers)
    end

    def brief_image
      @brief_image ||= create_brief_image(@base_type, @cvr_qualifiers)
    end

    extend Forwardable

    def_delegator :@base_type, :declarations
    def_delegator :@base_type, :location
    def_delegator :@base_type, :bit_size
    def_delegator :@base_type, :bit_alignment

    def real_type
      type_table.qualified_type(@base_type.real_type, *@cvr_qualifiers)
    end

    def_delegator :@base_type, :unqualify
    def_delegator :@base_type, :incomplete?
    def_delegator :@base_type, :compatible?
    def_delegator :@base_type, :coercible?

    def convertible?(to_type)
      real_type.unqualify.convertible?(to_type.real_type.unqualify)
    end

    def more_cv_qualified?(than_type)
      # NOTE: The term `more cv-qualified' means:
      #         const          > none
      #         volatile       > none
      #         const volatile > none
      #         const volatile > const
      #         const volatile > volatile
      if than_type.qualified?
        if than_type.const? && than_type.volatile?
          false
        else
          if self.const? && self.volatile?
            true
          else
            false
          end
        end
      else
        true
      end
    end

    def_delegator :@base_type, :scalar?
    def_delegator :@base_type, :integer?
    def_delegator :@base_type, :floating?
    def_delegator :@base_type, :array?
    def_delegator :@base_type, :struct?
    def_delegator :@base_type, :union?
    def_delegator :@base_type, :pointer?

    def qualified?
      true
    end

    def_delegator :@base_type, :function?
    def_delegator :@base_type, :enum?
    def_delegator :@base_type, :user?
    def_delegator :@base_type, :void?
    def_delegator :@base_type, :standard?
    def_delegator :@base_type, :undeclared?
    def_delegator :@base_type, :unresolved?

    def const?
      @cvr_qualifiers.include?(:const)
    end

    def volatile?
      @cvr_qualifiers.include?(:volatile)
    end

    def restrict?
      @cvr_qualifiers.include?(:restrict)
    end

    def_delegator :@base_type, :bitfield?
    def_delegator :@base_type, :signed?
    def_delegator :@base_type, :explicitly_signed?
    def_delegator :@base_type, :have_va_list?
    def_delegator :@base_type, :return_type
    def_delegator :@base_type, :parameter_types
    def_delegator :@base_type, :enumerators
    def_delegator :@base_type, :length
    def_delegator :@base_type, :length=
    def_delegator :@base_type, :impl_length
    def_delegator :@base_type, :members
    def_delegator :@base_type, :member_named
    def_delegator :@base_type, :min
    def_delegator :@base_type, :max
    def_delegator :@base_type, :nil_value
    def_delegator :@base_type, :zero_value
    def_delegator :@base_type, :arbitrary_value
    def_delegator :@base_type, :undefined_value
    def_delegator :@base_type, :parameter_value
    def_delegator :@base_type, :return_value
    def_delegator :@base_type, :coerce_scalar_value
    def_delegator :@base_type, :coerce_array_value
    def_delegator :@base_type, :coerce_composite_value
    def_delegator :@base_type, :integer_conversion_rank
    def_delegator :@base_type, :integer_promoted_type
    def_delegator :@base_type, :argument_promoted_type

    def_delegator :@base_type, :arithmetic_type_with
    def_delegator :@base_type, :_arithmetic_type_with_undeclared
    def_delegator :@base_type, :_arithmetic_type_with_unresolved
    def_delegator :@base_type, :_arithmetic_type_with_void
    def_delegator :@base_type, :_arithmetic_type_with_function
    def_delegator :@base_type, :_arithmetic_type_with_char
    def_delegator :@base_type, :_arithmetic_type_with_signed_char
    def_delegator :@base_type, :_arithmetic_type_with_unsigned_char
    def_delegator :@base_type, :_arithmetic_type_with_short
    def_delegator :@base_type, :_arithmetic_type_with_signed_short
    def_delegator :@base_type, :_arithmetic_type_with_unsigned_short
    def_delegator :@base_type, :_arithmetic_type_with_short_int
    def_delegator :@base_type, :_arithmetic_type_with_signed_short_int
    def_delegator :@base_type, :_arithmetic_type_with_unsigned_short_int
    def_delegator :@base_type, :_arithmetic_type_with_int
    def_delegator :@base_type, :_arithmetic_type_with_signed
    def_delegator :@base_type, :_arithmetic_type_with_signed_int
    def_delegator :@base_type, :_arithmetic_type_with_unsigned
    def_delegator :@base_type, :_arithmetic_type_with_unsigned_int
    def_delegator :@base_type, :_arithmetic_type_with_long
    def_delegator :@base_type, :_arithmetic_type_with_signed_long
    def_delegator :@base_type, :_arithmetic_type_with_unsigned_long
    def_delegator :@base_type, :_arithmetic_type_with_long_int
    def_delegator :@base_type, :_arithmetic_type_with_signed_long_int
    def_delegator :@base_type, :_arithmetic_type_with_unsigned_long_int
    def_delegator :@base_type, :_arithmetic_type_with_long_long
    def_delegator :@base_type, :_arithmetic_type_with_signed_long_long
    def_delegator :@base_type, :_arithmetic_type_with_unsigned_long_long
    def_delegator :@base_type, :_arithmetic_type_with_long_long_int
    def_delegator :@base_type, :_arithmetic_type_with_signed_long_long_int
    def_delegator :@base_type, :_arithmetic_type_with_unsigned_long_long_int
    def_delegator :@base_type, :_arithmetic_type_with_float
    def_delegator :@base_type, :_arithmetic_type_with_double
    def_delegator :@base_type, :_arithmetic_type_with_long_double
    def_delegator :@base_type, :_arithmetic_type_with_bitfield
    def_delegator :@base_type, :_arithmetic_type_with_enum
    def_delegator :@base_type, :_arithmetic_type_with_pointer
    def_delegator :@base_type, :_arithmetic_type_with_array
    def_delegator :@base_type, :_arithmetic_type_with_struct
    def_delegator :@base_type, :_arithmetic_type_with_union
    def_delegator :@base_type, :_arithmetic_type_with_extended_big_int

    def_delegator :@base_type, :corresponding_signed_type
    def_delegator :@base_type, :corresponding_unsigned_type

    def dup
      QualifiedType.new(type_table, @base_type.dup, *@cvr_qualifiers)
    end

    private
    def create_name(base_type, cvr_quals)
      append_cvr_qualifiers(base_type.name, cvr_quals)
    end

    def create_image(base_type, cvr_quals)
      append_cvr_qualifiers(base_type.image, cvr_quals)
    end

    def create_brief_image(base_type, cvr_quals)
      append_cvr_qualifiers(base_type.brief_image, cvr_quals)
    end

    def append_cvr_qualifiers(type_str, cvr_quals)
      qualed_str = type_str
      qualed_str = "#{qualed_str} const" if cvr_quals.include?(:const)
      qualed_str = "#{qualed_str} volatile" if cvr_quals.include?(:volatile)
      qualed_str = "#{qualed_str} restrict" if cvr_quals.include?(:restrict)
      qualed_str
    end
  end

  class QualifiedTypeId < TypeId
    def initialize(base_type, cvr_quals)
      super(create_value(base_type, cvr_quals))

      @base_type = base_type
      @cvr_qualifiers = cvr_quals.sort
    end

    def ==(rhs_id)
      case rhs_id
      when QualifiedTypeId
        @cvr_qualifiers == rhs_id.cvr_qualifiers &&
          @base_type == rhs_id.base_type
      else
        false
      end
    end

    protected
    attr_reader :base_type
    attr_reader :cvr_qualifiers

    private
    def create_value(base_type, cvr_quals)
      value = base_type.real_type.brief_image
      value = "#{value} const" if cvr_quals.include?(:const)
      value = "#{value} volatile" if cvr_quals.include?(:volatile)
      value = "#{value} restrict" if cvr_quals.include?(:restrict)
      value
    end
  end

  class VoidType < Type
    def initialize(type_tbl)
      super(type_tbl, "void")
    end

    def id
      @id ||= StandardTypeId.new("void")
    end

    def image
      name
    end

    def brief_image
      name
    end

    def location
      nil
    end

    def bit_size
      0
    end

    def bit_alignment
      0
    end

    def real_type
      self
    end

    def base_type
      nil
    end

    def unqualify
      self
    end

    def incomplete?
      true
    end

    def compatible?(to_type)
      false
    end

    def coercible?(to_type)
      false
    end

    def convertible?(to_type)
      to_type.void?
    end

    def same_as?(type)
      false
    end

    def scalar?
      false
    end

    def integer?
      false
    end

    def floating?
      false
    end

    def array?
      false
    end

    def struct?
      false
    end

    def union?
      false
    end

    def pointer?
      false
    end

    def qualified?
      false
    end

    def function?
      false
    end

    def enum?
      false
    end

    def user?
      false
    end

    def void?
      true
    end

    def standard?
      true
    end

    def undeclared?
      false
    end

    def unresolved?
      false
    end

    def const?
      false
    end

    def volatile?
      false
    end

    def restrict?
      false
    end

    def bitfield?
      false
    end

    def signed?
      false
    end

    def explicitly_signed?
      false
    end

    def have_va_list?
      false
    end

    def return_type
      self
    end

    def parameter_types
      []
    end

    def enumerators
      []
    end

    def length
      0
    end

    def impl_length
      0
    end

    def members
      []
    end

    def member_named(name)
      nil
    end

    def min
      0
    end

    def max
      0
    end

    def nil_value
      ScalarValue.of_nil(logical_right_shift?) # NOTREACHED
    end

    def zero_value
      ScalarValue.of_nil(logical_right_shift?) # NOTREACHED
    end

    def arbitrary_value
      ScalarValue.of_nil(logical_right_shift?) # NOTREACHED
    end

    def undefined_value
      ScalarValue.of_nil(logical_right_shift?) # NOTREACHED
    end

    def parameter_value
      ScalarValue.of_nil(logical_right_shift?) # NOTREACHED
    end

    def return_value
      ScalarValue.of_nil(logical_right_shift?) # NOTREACHED
    end

    def coerce_scalar_value(val)
      ScalarValue.of_nil(logical_right_shift?) # NOTREACHED
    end

    def coerce_array_value(val)
      ScalarValue.of_nil(logical_right_shift?) # NOTREACHED
    end

    def coerce_composite_value(val)
      ScalarValue.of_nil(logical_right_shift?) # NOTREACHED
    end

    def integer_conversion_rank
      0 # NOTREACHED
    end

    def integer_promoted_type
      self # NOTREACHED
    end

    def argument_promoted_type
      self # NOTREACHED
    end

    def arithmetic_type_with(type)
      # NOTE: An arithmetic operation with `void' must not be executed!
      type._arithmetic_type_with_void(self)
    end

    def _arithmetic_type_with_undeclared(lhs_type, rhs_type = self)
      rhs_type.arithmetic_type_with(lhs_type)
    end

    def _arithmetic_type_with_unresolved(lhs_type, rhs_type = self)
      rhs_type.arithmetic_type_with(lhs_type)
    end

    def _arithmetic_type_with_void(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with `void' must not be executed!
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_function(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with `void' must not be executed!
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_char(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with `void' must not be executed!
      # NOTE: Binary operation with `char' and `void'
      #       makes integer-promoted type of `char'.
      lhs_type.integer_promoted_type # NOTREACHED
    end

    def _arithmetic_type_with_signed_char(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with `void' must not be executed!
      # NOTE: Binary operation with `signed char' and `void'
      #       makes integer-promoted type of `signed char'.
      lhs_type.integer_promoted_type # NOTREACHED
    end

    def _arithmetic_type_with_unsigned_char(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with `void' must not be executed!
      # NOTE: Binary operation with `unsigned char' and `void'
      #       makes integer-promoted type of `unsigned char'.
      lhs_type.integer_promoted_type # NOTREACHED
    end

    def _arithmetic_type_with_short(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with `void' must not be executed!
      # NOTE: Binary operation with `short' and `void'
      #       makes integer-promoted type of `short'.
      lhs_type.integer_promoted_type # NOTREACHED
    end

    def _arithmetic_type_with_signed_short(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with `void' must not be executed!
      # NOTE: Binary operation with `signed short' and `void'
      #       makes integer-promoted type of `signed short'.
      lhs_type.integer_promoted_type # NOTREACHED
    end

    def _arithmetic_type_with_unsigned_short(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with `void' must not be executed!
      # NOTE: Binary operation with `unsigned short' and `void'
      #       makes integer-promoted type of `unsigned short'.
      lhs_type.integer_promoted_type # NOTREACHED
    end

    def _arithmetic_type_with_short_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with `void' must not be executed!
      # NOTE: Binary operation with `short int' and `void'
      #       makes integer-promoted type of `short int'.
      lhs_type.integer_promoted_type # NOTREACHED
    end

    def _arithmetic_type_with_signed_short_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with `void' must not be executed!
      # NOTE: Binary operation with `signed short int' and `void'
      #       makes integer-promoted type of `signed short int'.
      lhs_type.integer_promoted_type # NOTREACHED
    end

    def _arithmetic_type_with_unsigned_short_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with `void' must not be executed!
      # NOTE: Binary operation with `unsigned short int' and `void'
      #       makes integer-promoted type of `unsigned short int'.
      lhs_type.integer_promoted_type # NOTREACHED
    end

    def _arithmetic_type_with_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with `void' must not be executed!
      # NOTE: Binary operation with `int' and `void' makes `int'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_signed(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with `void' must not be executed!
      # NOTE: Binary operation with `signed' and `void' makes `signed'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_signed_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with `void' must not be executed!
      # NOTE: Binary operation with `signed int' and `void' makes `signed int'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_unsigned(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with `void' must not be executed!
      # NOTE: Binary operation with `unsigned' and `void' makes `unsigned'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_unsigned_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with `void' must not be executed!
      # NOTE: Binary operation with `unsigned int' and `void'
      #       makes `unsigned int'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_long(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with `void' must not be executed!
      # NOTE: Binary operation with `long' and `void' makes `long'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_signed_long(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with `void' must not be executed!
      # NOTE: Binary operation with `signed long' and `void'
      #       makes `signed long'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_unsigned_long(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with `void' must not be executed!
      # NOTE: Binary operation with `unsigned long' and `void'
      #       makes `unsigned long'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_long_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with `void' must not be executed!
      # NOTE: Binary operation with `long int' and `void' makes `long int'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_signed_long_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with `void' must not be executed!
      # NOTE: Binary operation with `signed long int' and `void'
      #       makes `signed long int'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_unsigned_long_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with `void' must not be executed!
      # NOTE: Binary operation with `unsigned long int' and `void'
      #       makes `unsigned long int'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_long_long(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with `void' must not be executed!
      # NOTE: Binary operation with `long long' and `void' makes `long long'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_signed_long_long(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with `void' must not be executed!
      # NOTE: Binary operation with `signed long long' and `void'
      #       makes `signed long long'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_unsigned_long_long(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with `void' must not be executed!
      # NOTE: Binary operation with `unsigned long long' and `void'
      #       makes `unsigned long long'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_long_long_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with `void' must not be executed!
      # NOTE: Binary operation with `long long int' and `void'
      #       makes `long long int'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_signed_long_long_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with `void' must not be executed!
      # NOTE: Binary operation with `signed long long int' and `void'
      #       makes `signed long long int'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_unsigned_long_long_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with `void' must not be executed!
      # NOTE: Binary operation with `unsigned long long int' and `void'
      #       makes `unsigned long long int'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_float(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with `void' must not be executed!
      # NOTE: Binary operation with `float' and `void' makes `float'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_double(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with `void' must not be executed!
      # NOTE: Binary operation with `double' and `void' makes `double'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_long_double(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with `void' must not be executed!
      # NOTE: Binary operation with `long double' and `void'
      #       makes `long double'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_bitfield(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with `void' must not be executed!
      # NOTE: Binary operation with BitfieldType and `void'
      #       makes integer-promoted type of BitfieldType.
      lhs_type.integer_promoted_type # NOTREACHED
    end

    def _arithmetic_type_with_enum(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with `void' must not be executed!
      # NOTE: Binary operation with EnumType and `void' makes EnumType.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_pointer(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with `void' must not be executed!
      # NOTE: Binary operation with PointerType and `void' makes PointerType.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_array(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with `void' must not be executed!
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_struct(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with `void' must not be executed!
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_union(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with `void' must not be executed!
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_extended_big_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with `void' must not be executed!
      # NOTE: Binary operation with ExtendedBigIntType and `void'
      #       makes ExtendedBigIntType.
      lhs_type # NOTREACHED
    end

    def corresponding_signed_type
      self # NOTREACHED
    end

    def corresponding_unsigned_type
      self # NOTREACHED
    end

    def dup
      VoidType.new(type_table)
    end
  end

  class FunctionType < Type
    def initialize(type_tbl, retn_type, param_types, have_va_list = false)
      super(type_tbl, create_name(retn_type, param_types, have_va_list))
      @return_type = retn_type
      @parameter_types = param_types
      @have_va_list = have_va_list
    end

    attr_reader :return_type
    attr_reader :parameter_types

    def declarations
      @return_type.declarations +
        @parameter_types.reduce([]) { |dcls, type| dcls + type.declarations }
    end

    def id
      @id ||= FunctionTypeId.new(@return_type, @parameter_types, @have_va_list)
    end

    def image
      @image ||= create_image(@return_type, @parameter_types, @have_va_list)
    end

    def brief_image
      @brief_image ||=
        create_brief_image(@return_type, @parameter_types, @have_va_list)
    end

    def location
      nil
    end

    def bit_size
      0
    end

    def bit_alignment
      0
    end

    def real_type
      type_table.function_type(@return_type.real_type,
                               @parameter_types.map { |type| type.real_type },
                               @have_va_list)
    end

    def base_type
      nil
    end

    def unqualify
      self
    end

    def incomplete?
      @return_type.incomplete? && !@return_type.void? or
        @parameter_types.empty? ||
          @parameter_types.any? { |type| type.incomplete? && !type.void? }
    end

    def compatible?(to_type)
      return false unless to_type.function?

      lhs_params = @parameter_types
      rhs_params = to_type.parameter_types

      @return_type.compatible?(to_type.return_type) &&
        lhs_params.size == rhs_params.size &&
        lhs_params.zip(rhs_params).all? { |lhs, rhs| lhs.compatible?(rhs) } &&
        @have_va_list == to_type.have_va_list?
    end

    def coercible?(to_type)
      false
    end

    def scalar?
      false
    end

    def integer?
      false
    end

    def floating?
      false
    end

    def array?
      false
    end

    def struct?
      false
    end

    def union?
      false
    end

    def pointer?
      false
    end

    def qualified?
      false
    end

    def function?
      true
    end

    def enum?
      false
    end

    def user?
      false
    end

    def void?
      false
    end

    def standard?
      false
    end

    def undeclared?
      false
    end

    def unresolved?
      @return_type.unresolved? ||
        @parameter_types.any? { |type| type.unresolved? }
    end

    def const?
      false
    end

    def volatile?
      false
    end

    def restrict?
      false
    end

    def bitfield?
      false
    end

    def signed?
      false
    end

    def explicitly_signed?
      false
    end

    def have_va_list?
      @have_va_list
    end

    def enumerators
      []
    end

    def length
      0
    end

    def impl_length
      0
    end

    def members
      []
    end

    def member_named(name)
      nil
    end

    def min
      0
    end

    def max
      0
    end

    def nil_value
      ScalarValue.of_nil(logical_right_shift?) # NOTREACHED
    end

    def zero_value
      ScalarValue.of_nil(logical_right_shift?) # NOTREACHED
    end

    def arbitrary_value
      ScalarValue.of_nil(logical_right_shift?) # NOTREACHED
    end

    def undefined_value
      ScalarValue.of_nil(logical_right_shift?) # NOTREACHED
    end

    def parameter_value
      ScalarValue.of_nil(logical_right_shift?) # NOTREACHED
    end

    def return_value
      ScalarValue.of_nil(logical_right_shift?) # NOTREACHED
    end

    def coerce_scalar_value(val)
      ScalarValue.of_nil(logical_right_shift?) # NOTREACHED
    end

    def coerce_array_value(val)
      ScalarValue.of_nil(logical_right_shift?) # NOTREACHED
    end

    def coerce_composite_value(val)
      ScalarValue.of_nil(logical_right_shift?) # NOTREACHED
    end

    def integer_conversion_rank
      0 # NOTREACHED
    end

    def integer_promoted_type
      self # NOTREACHED
    end

    def argument_promoted_type
      self # NOTREACHED
    end

    def arithmetic_type_with(type)
      # NOTE: An arithmetic operation with FunctionType must not be executed!
      type._arithmetic_type_with_function(self)
    end

    def _arithmetic_type_with_undeclared(lhs_type, rhs_type = self)
      rhs_type.arithmetic_type_with(lhs_type)
    end

    def _arithmetic_type_with_unresolved(lhs_type, rhs_type = self)
      rhs_type.arithmetic_type_with(lhs_type)
    end

    def _arithmetic_type_with_void(lhs_type, rhs_type = self)
      rhs_type.arithmetic_type_with(lhs_type)
    end

    def _arithmetic_type_with_function(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with FunctionType must not be executed!
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_char(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with FunctionType must not be executed!
      # NOTE: Binary operation with `char' and FunctionType
      #       makes integer-promoted type of `char'.
      lhs_type.integer_promoted_type # NOTREACHED
    end

    def _arithmetic_type_with_signed_char(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with FunctionType must not be executed!
      # NOTE: Binary operation with `signed char' and FunctionType
      #       makes integer-promoted type of `signed char'.
      lhs_type.integer_promoted_type # NOTREACHED
    end

    def _arithmetic_type_with_unsigned_char(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with FunctionType must not be executed!
      # NOTE: Binary operation with `unsigned char' and FunctionType
      #       makes integer-promoted type of `unsigned char'.
      lhs_type.integer_promoted_type # NOTREACHED
    end

    def _arithmetic_type_with_short(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with FunctionType must not be executed!
      # NOTE: Binary operation with `short' and FunctionType
      #       makes integer-promoted type of `short'.
      lhs_type.integer_promoted_type # NOTREACHED
    end

    def _arithmetic_type_with_signed_short(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with FunctionType must not be executed!
      # NOTE: Binary operation with `signed short' and FunctionType
      #       makes integer-promoted type of `signed short'.
      lhs_type.integer_promoted_type # NOTREACHED
    end

    def _arithmetic_type_with_unsigned_short(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with FunctionType must not be executed!
      # NOTE: Binary operation with `unsigned short' and FunctionType
      #       makes integer-promoted type of `unsigned short'.
      lhs_type.integer_promoted_type # NOTREACHED
    end

    def _arithmetic_type_with_short_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with FunctionType must not be executed!
      # NOTE: Binary operation with `short int' and FunctionType
      #       makes integer-promoted type of `short int'.
      lhs_type.integer_promoted_type # NOTREACHED
    end

    def _arithmetic_type_with_signed_short_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with FunctionType must not be executed!
      # NOTE: Binary operation with `signed short int' and FunctionType
      #       makes integer-promoted type of `signed short int'.
      lhs_type.integer_promoted_type # NOTREACHED
    end

    def _arithmetic_type_with_unsigned_short_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with FunctionType must not be executed!
      # NOTE: Binary operation with `unsigned short int' and FunctionType
      #       makes integer-promoted type of `unsigned short int'.
      lhs_type.integer_promoted_type # NOTREACHED
    end

    def _arithmetic_type_with_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with FunctionType must not be executed!
      # NOTE: Binary operation with `int' and FunctionType makes `int'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_signed(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with FunctionType must not be executed!
      # NOTE: Binary operation with `signed' and FunctionType makes `signed'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_signed_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with FunctionType must not be executed!
      # NOTE: Binary operation with `signed int' and FunctionType
      #       makes `signed int'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_unsigned(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with FunctionType must not be executed!
      # NOTE: Binary operation with `unsigned' and FunctionType
      #       makes `unsigned'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_unsigned_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with FunctionType must not be executed!
      # NOTE: Binary operation with `unsigned int' and FunctionType
      #       makes `unsigned int'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_long(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with FunctionType must not be executed!
      # NOTE: Binary operation with `long' and FunctionType makes `long'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_signed_long(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with FunctionType must not be executed!
      # NOTE: Binary operation with `signed long' and FunctionType
      #       makes `signed long'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_unsigned_long(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with FunctionType must not be executed!
      # NOTE: Binary operation with `unsigned long' and FunctionType
      #       makes `unsigned long'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_long_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with FunctionType must not be executed!
      # NOTE: Binary operation with `long int' and FunctionType
      #       makes `long int'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_signed_long_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with FunctionType must not be executed!
      # NOTE: Binary operation with `signed long int' and FunctionType
      #       makes `signed long int'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_unsigned_long_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with FunctionType must not be executed!
      # NOTE: Binary operation with `unsigned long int' and FunctionType
      #       makes `unsigned long int'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_long_long(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with FunctionType must not be executed!
      # NOTE: Binary operation with `long long' and FunctionType
      #       makes `long long'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_signed_long_long(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with FunctionType must not be executed!
      # NOTE: Binary operation with `signed long long' and FunctionType
      #       makes `signed long long'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_unsigned_long_long(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with FunctionType must not be executed!
      # NOTE: Binary operation with `unsigned long long' and FunctionType
      #       makes `unsigned long long'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_long_long_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with FunctionType must not be executed!
      # NOTE: Binary operation with `long long int' and FunctionType
      #       makes `long long int'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_signed_long_long_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with FunctionType must not be executed!
      # NOTE: Binary operation with `signed long long int' and FunctionType
      #       makes `signed long long int'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_unsigned_long_long_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with FunctionType must not be executed!
      # NOTE: Binary operation with `unsigned long long int' and FunctionType
      #       makes `unsigned long long int'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_float(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with FunctionType must not be executed!
      # NOTE: Binary operation with `float' and FunctionType makes `float'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_double(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with FunctionType must not be executed!
      # NOTE: Binary operation with `double' and FunctionType makes `double'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_long_double(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with FunctionType must not be executed!
      # NOTE: Binary operation with `long double' and FunctionType
      #       makes `long double'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_bitfield(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with FunctionType must not be executed!
      # NOTE: Binary operation with BitfieldType and FunctionType
      #       makes integer-promoted type of BitfieldType.
      lhs_type.integer_promoted_type # NOTREACHED
    end

    def _arithmetic_type_with_enum(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with FunctionType must not be executed!
      # NOTE: Binary operation with EnumType and FunctionType makes EnumType.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_pointer(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with FunctionType must not be executed!
      # NOTE: Binary operation with PointerType and FunctionType
      #       makes PointerType.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_array(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with FunctionType must not be executed!
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_struct(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with FunctionType must not be executed!
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_union(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with FunctionType must not be executed!
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_extended_big_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with FunctionType must not be executed!
      # NOTE: Binary operation with ExtendedBigIntType and FunctionType
      #       makes ExtendedBigIntType.
      lhs_type # NOTREACHED
    end

    def corresponding_signed_type
      self # NOTREACHED
    end

    def corresponding_unsigned_type
      self # NOTREACHED
    end

    def ==(rhs_type)
      case rhs_type
      when FunctionType
        if parameter_types.empty? || rhs_type.parameter_types.empty?
          return_type == rhs_type.return_type
        else
          return_type == rhs_type.return_type &&
            parameter_types == rhs_type.parameter_types &&
            have_va_list? == rhs_type.have_va_list?
        end
      else
        false
      end
    end

    def dup
      FunctionType.new(type_table, @return_type.dup,
                       @parameter_types.map { |t| t.dup }, @have_va_list)
    end

    private
    def create_name(retn_type, param_types, have_va_list)
      "#{retn_type.name}(" +
        param_types.map { |type| type.name }.join(", ") +
        (have_va_list ? ",...)" : ")")
    end

    def create_image(retn_type, param_types, have_va_list)
      "#{retn_type.image}(" +
        param_types.map { |type| type.image }.join(", ") +
        (have_va_list ? ",...)" : ")")
    end

    def create_brief_image(retn_type, param_types, have_va_list)
      "#{retn_type.brief_image}(" +
        param_types.map { |type| type.brief_image }.join(", ") +
        (have_va_list ? ",...)" : ")")
    end
  end

  class FunctionTypeId < TypeId
    def initialize(retn_type, param_types, have_va_list)
      super(create_value(retn_type, param_types, have_va_list))
    end

    private
    def create_value(retn_type, param_types, have_va_list)
      "#{retn_type.brief_image}(" +
        param_types.map { |type| type.brief_image }.join(",") +
        (have_va_list ? ",...)" : ")")
    end
  end

  class ScalarDataType < Type
    include UsualArithmeticTypeConversion

    def initialize(type_tbl, name, bit_size, bit_align, type_dcls = [])
      super(type_tbl, name, type_dcls)
      @bit_size = bit_size
      @bit_alignment = bit_align
    end

    attr_reader :bit_size
    attr_reader :bit_alignment

    def id
      subclass_responsibility
    end

    def image
      subclass_responsibility
    end

    def brief_image
      subclass_responsibility
    end

    def location
      subclass_responsibility
    end

    def real_type
      self
    end

    def base_type
      nil
    end

    def unqualify
      self
    end

    def compatible?(to_type)
      subclass_responsibility
    end

    def coercible?(to_type)
      to_type.scalar?
    end

    def scalar?
      true
    end

    def integer?
      subclass_responsibility
    end

    def floating?
      subclass_responsibility
    end

    def array?
      false
    end

    def struct?
      false
    end

    def union?
      false
    end

    def pointer?
      subclass_responsibility
    end

    def qualified?
      false
    end

    def function?
      false
    end

    def enum?
      subclass_responsibility
    end

    def user?
      false
    end

    def void?
      false
    end

    def standard?
      subclass_responsibility
    end

    def undeclared?
      false
    end

    def unresolved?
      false
    end

    def const?
      false
    end

    def volatile?
      false
    end

    def restrict?
      false
    end

    def bitfield?
      subclass_responsibility
    end

    def signed?
      subclass_responsibility
    end

    def explicitly_signed?
      subclass_responsibility
    end

    def have_va_list?
      false
    end

    def return_type
      nil
    end

    def parameter_types
      []
    end

    def enumerators
      subclass_responsibility
    end

    def length
      0
    end

    def impl_length
      0
    end

    def members
      []
    end

    def member_named(name)
      nil
    end

    def min
      subclass_responsibility
    end

    def max
      subclass_responsibility
    end

    def nil_value
      ScalarValue.of_nil(logical_right_shift?)
    end

    def zero_value
      ScalarValue.of(0, logical_right_shift?)
    end

    def arbitrary_value
      ScalarValue.of_arbitrary(logical_right_shift?)
    end

    def undefined_value
      ScalarValue.of_undefined(min..max, logical_right_shift?)
    end

    def parameter_value
      ScalarValue.of(min..max, logical_right_shift?)
    end

    def return_value
      ScalarValue.of(min..max, logical_right_shift?)
    end

    def coerce_scalar_value(val)
      val.dup.tap do |v|
        v.narrow_domain!(Operator::EQ,
                         ScalarValue.of(min..max, logical_right_shift?))
      end
    end

    def coerce_array_value(val)
      fst_val = val.values.first
      fst_val = fst_val.values.first until fst_val && fst_val.scalar?

      if fst_val && fst_val.scalar?
        coerce_scalar_value(fst_val)
      else
        undefined_value
      end
    end

    def coerce_composite_value(val)
      fst_val = val.values.first
      fst_val = fst_val.values.first until fst_val && fst_val.scalar?

      if fst_val && fst_val.scalar?
        coerce_scalar_value(fst_val)
      else
        undefined_value
      end
    end

    def integer_conversion_rank
      subclass_responsibility
    end

    def integer_promoted_type
      subclass_responsibility
    end

    def argument_promoted_type
      subclass_responsibility
    end

    def arithmetic_type_with(type)
      subclass_responsibility
    end

    def _arithmetic_type_with_undeclared(lhs_type, rhs_type = self)
      rhs_type.arithmetic_type_with(lhs_type)
    end

    def _arithmetic_type_with_unresolved(lhs_type, rhs_type = self)
      rhs_type.arithmetic_type_with(lhs_type)
    end

    def _arithmetic_type_with_void(lhs_type, rhs_type = self)
      rhs_type.arithmetic_type_with(lhs_type)
    end

    def _arithmetic_type_with_function(lhs_type, rhs_type = self)
      rhs_type.arithmetic_type_with(lhs_type)
    end

    def _arithmetic_type_with_char(lhs_type, rhs_type = self)
      do_usual_arithmetic_type_conversion(lhs_type, rhs_type)
    end

    def _arithmetic_type_with_signed_char(lhs_type, rhs_type = self)
      do_usual_arithmetic_type_conversion(lhs_type, rhs_type)
    end

    def _arithmetic_type_with_unsigned_char(lhs_type, rhs_type = self)
      do_usual_arithmetic_type_conversion(lhs_type, rhs_type)
    end

    def _arithmetic_type_with_short(lhs_type, rhs_type = self)
      do_usual_arithmetic_type_conversion(lhs_type, rhs_type)
    end

    def _arithmetic_type_with_signed_short(lhs_type, rhs_type = self)
      do_usual_arithmetic_type_conversion(lhs_type, rhs_type)
    end

    def _arithmetic_type_with_unsigned_short(lhs_type, rhs_type = self)
      do_usual_arithmetic_type_conversion(lhs_type, rhs_type)
    end

    def _arithmetic_type_with_short_int(lhs_type, rhs_type = self)
      do_usual_arithmetic_type_conversion(lhs_type, rhs_type)
    end

    def _arithmetic_type_with_signed_short_int(lhs_type, rhs_type = self)
      do_usual_arithmetic_type_conversion(lhs_type, rhs_type)
    end

    def _arithmetic_type_with_unsigned_short_int(lhs_type, rhs_type = self)
      do_usual_arithmetic_type_conversion(lhs_type, rhs_type)
    end

    def _arithmetic_type_with_int(lhs_type, rhs_type = self)
      do_usual_arithmetic_type_conversion(lhs_type, rhs_type)
    end

    def _arithmetic_type_with_signed(lhs_type, rhs_type = self)
      do_usual_arithmetic_type_conversion(lhs_type, rhs_type)
    end

    def _arithmetic_type_with_signed_int(lhs_type, rhs_type = self)
      do_usual_arithmetic_type_conversion(lhs_type, rhs_type)
    end

    def _arithmetic_type_with_unsigned(lhs_type, rhs_type = self)
      do_usual_arithmetic_type_conversion(lhs_type, rhs_type)
    end

    def _arithmetic_type_with_unsigned_int(lhs_type, rhs_type = self)
      do_usual_arithmetic_type_conversion(lhs_type, rhs_type)
    end

    def _arithmetic_type_with_long(lhs_type, rhs_type = self)
      do_usual_arithmetic_type_conversion(lhs_type, rhs_type)
    end

    def _arithmetic_type_with_signed_long(lhs_type, rhs_type = self)
      do_usual_arithmetic_type_conversion(lhs_type, rhs_type)
    end

    def _arithmetic_type_with_unsigned_long(lhs_type, rhs_type = self)
      do_usual_arithmetic_type_conversion(lhs_type, rhs_type)
    end

    def _arithmetic_type_with_long_int(lhs_type, rhs_type = self)
      do_usual_arithmetic_type_conversion(lhs_type, rhs_type)
    end

    def _arithmetic_type_with_signed_long_int(lhs_type, rhs_type = self)
      do_usual_arithmetic_type_conversion(lhs_type, rhs_type)
    end

    def _arithmetic_type_with_unsigned_long_int(lhs_type, rhs_type = self)
      do_usual_arithmetic_type_conversion(lhs_type, rhs_type)
    end

    def _arithmetic_type_with_long_long(lhs_type, rhs_type = self)
      do_usual_arithmetic_type_conversion(lhs_type, rhs_type)
    end

    def _arithmetic_type_with_signed_long_long(lhs_type, rhs_type = self)
      do_usual_arithmetic_type_conversion(lhs_type, rhs_type)
    end

    def _arithmetic_type_with_unsigned_long_long(lhs_type, rhs_type = self)
      do_usual_arithmetic_type_conversion(lhs_type, rhs_type)
    end

    def _arithmetic_type_with_long_long_int(lhs_type, rhs_type = self)
      do_usual_arithmetic_type_conversion(lhs_type, rhs_type)
    end

    def _arithmetic_type_with_signed_long_long_int(lhs_type, rhs_type = self)
      do_usual_arithmetic_type_conversion(lhs_type, rhs_type)
    end

    def _arithmetic_type_with_unsigned_long_long_int(lhs_type, rhs_type = self)
      do_usual_arithmetic_type_conversion(lhs_type, rhs_type)
    end

    def _arithmetic_type_with_float(lhs_type, rhs_type = self)
      do_usual_arithmetic_type_conversion(lhs_type, rhs_type)
    end

    def _arithmetic_type_with_double(lhs_type, rhs_type = self)
      do_usual_arithmetic_type_conversion(lhs_type, rhs_type)
    end

    def _arithmetic_type_with_long_double(lhs_type, rhs_type = self)
      do_usual_arithmetic_type_conversion(lhs_type, rhs_type)
    end

    def _arithmetic_type_with_bitfield(lhs_type, rhs_type = self)
      do_usual_arithmetic_type_conversion(lhs_type, rhs_type)
    end

    def _arithmetic_type_with_enum(lhs_type, rhs_type = self)
      do_usual_arithmetic_type_conversion(lhs_type, rhs_type)
    end

    def _arithmetic_type_with_pointer(lhs_type, rhs_type = self)
      do_usual_arithmetic_type_conversion(lhs_type, rhs_type)
    end

    def _arithmetic_type_with_array(lhs_type, rhs_type = self)
      rhs_type.arithmetic_type_with(lhs_type)
    end

    def _arithmetic_type_with_struct(lhs_type, rhs_type = self)
      rhs_type.arithmetic_type_with(lhs_type)
    end

    def _arithmetic_type_with_union(lhs_type, rhs_type = self)
      rhs_type.arithmetic_type_with(lhs_type)
    end

    def _arithmetic_type_with_extended_big_int(lhs_type, rhs_type = self)
      # NOTE: Binary operation with ExtendedBigIntType and any scalar type
      #       makes ExtendedBigIntType.
      lhs_type
    end

    def corresponding_signed_type
      subclass_responsibility
    end

    def corresponding_unsigned_type
      subclass_responsibility
    end

    def dup
      subclass_responsibility
    end
  end

  class IntegerType < ScalarDataType
    def initialize(type_tbl, name, bit_size, bit_align, signed,
                   explicitly_signed, type_dcls = [])
      super(type_tbl, name, bit_size, bit_align, type_dcls)
      @signed = signed
      @explicitly_signed = explicitly_signed
    end

    def id
      subclass_responsibility
    end

    def image
      name
    end

    def brief_image
      name
    end

    def location
      nil
    end

    def compatible?(to_type)
      to_type.integer? && to_type.min <= min && max <= to_type.max
    end

    def integer?
      true
    end

    def floating?
      false
    end

    def pointer?
      subclass_responsibility
    end

    def enum?
      subclass_responsibility
    end

    def standard?
      subclass_responsibility
    end

    def bitfield?
      subclass_responsibility
    end

    def signed?
      @signed
    end

    def explicitly_signed?
      @explicitly_signed
    end

    def enumerators
      subclass_responsibility
    end

    def min
      if @signed
        -2**(@bit_size - 1)
      else
        0
      end
    end

    def max
      if @signed
        2**(@bit_size - 1) - 1
      else
        2**@bit_size - 1
      end
    end

    def integer_conversion_rank
      subclass_responsibility
    end

    def integer_promoted_type
      # NOTE: The ISO C99 standard says;
      #
      # 6.3.1 Arithmetic operands
      # 6.3.1.1 Boolean, characters, and integers
      #
      # 2 The following may be used in an expression wherever an int or
      #   unsigned int may be used:
      #
      #     -- An object or expression with an integer type whose integer
      #        conversion rank is less than or equal to the rank of int and
      #        unsigned int.
      #     -- A bit-field of type _Bool, int, signed int, or unsigned int.
      #
      #   If an int can represent all values of the original type, the value is
      #   converted to an int; otherwise, it is converted to an unsigned int.
      #   These are called the integer promotions.  All other types are
      #   unchanged by the integer promotions.
      if self.integer_conversion_rank <= int_t.integer_conversion_rank
        self.compatible?(int_t) ? int_t : unsigned_int_t
      else
        self
      end
    end

    def argument_promoted_type
      # NOTE: The ISO C99 standard says;
      #
      # 6.5.2.2 Function calls
      #
      # 6 If the expression that denotes the called function has a type that
      #   does not include a prototype, the integer promotions are performed on
      #   each argument, and arguments that have type float are promoted to
      #   double.  These are called the default argument promotions.  If the
      #   number of arguments does not equal the number of parameters, the
      #   behavior is undefined.  If the function is defined with a type that
      #   includes a prototype, and either the prototype ends with an ellipsis
      #   (, ...) or the types of the arguments after promotion are not
      #   compatible with the types of the parameters, the behavior is
      #   undefined.  If the function is defined with a type that does not
      #   include a prototype, and the types of the arguments after promotion
      #   are not compatible with those of the parameters after promotion, the
      #   behavior is undefined, except for the following cases:
      #
      #     -- one promoted type is a signed integer type, the other promoted
      #        type is the corresponding unsigned integer type, and the value
      #        is representable in both types;
      #     -- both types are pointers to qualified or unqualified versions of
      #        a character type or void.
      self.integer_promoted_type
    end

    def arithmetic_type_with(type)
      subclass_responsibility
    end

    def corresponding_signed_type
      subclass_responsibility
    end

    def corresponding_unsigned_type
      subclass_responsibility
    end

    def dup
      subclass_responsibility
    end
  end

  class StandardIntegerType < IntegerType
    def id
      subclass_responsibility
    end

    def incomplete?
      false
    end

    def pointer?
      false
    end

    def enum?
      false
    end

    def standard?
      true
    end

    def bitfield?
      false
    end

    def enumerators
      []
    end

    def integer_conversion_rank
      subclass_responsibility
    end

    def arithmetic_type_with(type)
      subclass_responsibility
    end

    def corresponding_signed_type
      subclass_responsibility
    end

    def corresponding_unsigned_type
      subclass_responsibility
    end

    def dup
      self.class.new(type_table)
    end
  end

  class CharType < StandardIntegerType
    def initialize(type_tbl)
      # FIXME: StandardTypesAccessor is not ready until @type_table is
      #        initialized.
      @type_table = type_tbl
      super(type_tbl, "char",
            char_size, char_alignment, !char_as_unsigned_char?, false)
    end

    def id
      # NOTE: `char' type may be treated as `unsigned char'.
      #       Specialized type comparison is implemented in CharTypeId,
      #       SignedCharTypeId and UnsignedCharTypeId.
      @id ||= CharTypeId.new(char_as_unsigned_char?)
    end

    def integer_conversion_rank
      # NOTE: The ISO C99 standard says;
      #
      # 6.3.1 Arithmetic operands
      # 6.3.1.1 Boolean, characters, and integers
      #
      # 1 Every integer type has an integer conversion rank defined as follows:
      #
      #     -- No two signed integer types shall have the same rank, even if
      #        they have the same representation.
      #     -- The rank of a signed integer type shall be greater than the rank
      #        of any signed integer type with less precision.
      #     -- The rank of long long int shall be greater than the rank of long
      #        int, which shall be greater than the rank of int, which shall be
      #        greater than the rank of short int, which shall be greater than
      #        the rank of signed char.
      #     -- The rank of any unsigned integer type shall equal the rank of
      #        the corresponding signed integer type, if any.
      #     -- The rank of any standard integer type shall be greater than the
      #        rank of any extended integer type with the same width.
      #     -- The rank of char shall equal the rank of signed char and
      #        unsigned char.
      #     -- The rank of _Bool shall be less than the rank of all other
      #        standard integer types.
      #     -- The rank of any enumerated type shall equal the rank of the
      #        compatible integer type.
      #     -- The rank of any extended signed integer type relative to another
      #        extended signed integer type with the same precision is
      #        implementation-defined, but still subject to the other rules for
      #        determining the integer conversion rank.
      #     -- For all integer types T1, T2, and T3, if T1 has greater rank
      #        than T2 and T2 has greater rank than T3, then T1 has greater
      #        rank than T3.
      #
      # NOTE: char = 1, short int = 2, int = 3, long int = 4, long long int = 5
      1
    end

    def arithmetic_type_with(type)
      type._arithmetic_type_with_char(self)
    end

    def corresponding_signed_type
      signed_char_t
    end

    def corresponding_unsigned_type
      unsigned_char_t
    end
  end

  class CharTypeId < StandardTypeId
    def initialize(char_as_unsigned_char)
      super("char")
      @char_as_unsigned_char = char_as_unsigned_char
    end

    def ==(rhs_id)
      if @char_as_unsigned_char
        case rhs_id
        when CharTypeId, UnsignedCharTypeId
          return true
        end
      else
        case rhs_id
        when CharTypeId, SignedCharTypeId
          return true
        end
      end
      false
    end
  end

  class SignedCharType < StandardIntegerType
    def initialize(type_tbl)
      # FIXME: StandardTypesAccessor is not ready until @type_table is
      #        initialized.
      @type_table = type_tbl
      super(type_tbl, "signed char", char_size, char_alignment, true, true)
    end

    def id
      # NOTE: `char' type may be treated as `unsigned char'.
      #       Specialized type comparison is implemented in CharTypeId,
      #       SignedCharTypeId and UnsignedCharTypeId.
      @id ||= SignedCharTypeId.new(char_as_unsigned_char?)
    end

    def integer_conversion_rank
      1
    end

    def arithmetic_type_with(type)
      type._arithmetic_type_with_signed_char(self)
    end

    def corresponding_signed_type
      self
    end

    def corresponding_unsigned_type
      unsigned_char_t
    end
  end

  class SignedCharTypeId < StandardTypeId
    def initialize(char_as_unsigned_char)
      super("signed char")
      @char_as_unsigned_char = char_as_unsigned_char
    end

    def ==(rhs_id)
      if @char_as_unsigned_char
        case rhs_id
        when SignedCharTypeId
          return true
        end
      else
        case rhs_id
        when SignedCharTypeId, CharTypeId
          return true
        end
      end
      false
    end
  end

  class UnsignedCharType < StandardIntegerType
    def initialize(type_tbl)
      # FIXME: StandardTypesAccessor is not ready until @type_table is
      #        initialized.
      @type_table = type_tbl
      super(type_tbl, "unsigned char", char_size, char_alignment, false, true)
    end

    def id
      # NOTE: `char' type may be treated as `unsigned char'.
      #       Specialized type comparison is implemented in CharTypeId,
      #       SignedCharTypeId and UnsignedCharTypeId.
      @id ||= UnsignedCharTypeId.new(char_as_unsigned_char?)
    end

    def integer_conversion_rank
      1
    end

    def arithmetic_type_with(type)
      type._arithmetic_type_with_unsigned_char(self)
    end

    def corresponding_signed_type
      signed_char
    end

    def corresponding_unsigned_type
      self
    end
  end

  class UnsignedCharTypeId < StandardTypeId
    def initialize(char_as_unsigned_char)
      super("unsigned char")
      @char_as_unsigned_char = char_as_unsigned_char
    end

    def ==(rhs_id)
      if @char_as_unsigned_char
        case rhs_id
        when UnsignedCharTypeId, CharTypeId
          return true
        end
      else
        case rhs_id
        when UnsignedCharTypeId
          return true
        end
      end
      false
    end
  end

  class ShortType < StandardIntegerType
    def initialize(type_tbl)
      # FIXME: StandardTypesAccessor is not ready until @type_table is
      #        initialized.
      @type_table = type_tbl
      super(type_tbl, "short", short_size, short_alignment, true, false)
    end

    def id
      @id ||= ShortTypeId.new
    end

    def integer_conversion_rank
      2
    end

    def arithmetic_type_with(type)
      type._arithmetic_type_with_short(self)
    end

    def corresponding_signed_type
      signed_short_t
    end

    def corresponding_unsigned_type
      unsigned_short_t
    end
  end

  class ShortTypeId < StandardTypeId
    def initialize
      super("short")
    end

    def ==(rhs_id)
      case rhs_id
      when ShortTypeId, SignedShortTypeId, ShortIntTypeId, SignedShortIntTypeId
        true
      else
        false
      end
    end
  end

  class SignedShortType < StandardIntegerType
    def initialize(type_tbl)
      # FIXME: StandardTypesAccessor is not ready until @type_table is
      #        initialized.
      @type_table = type_tbl
      super(type_tbl, "signed short", short_size, short_alignment, true, true)
    end

    def id
      @id ||= SignedShortTypeId.new
    end

    def integer_conversion_rank
      2
    end

    def arithmetic_type_with(type)
      type._arithmetic_type_with_signed_short(self)
    end

    def corresponding_signed_type
      self
    end

    def corresponding_unsigned_type
      unsigned_short_t
    end
  end

  class SignedShortTypeId < StandardTypeId
    def initialize
      super("signed short")
    end

    def ==(rhs_id)
      case rhs_id
      when SignedShortTypeId, ShortTypeId, ShortIntTypeId, SignedShortIntTypeId
        true
      else
        false
      end
    end
  end

  class UnsignedShortType < StandardIntegerType
    def initialize(type_tbl)
      # FIXME: StandardTypesAccessor is not ready until @type_table is
      #        initialized.
      @type_table = type_tbl
      super(type_tbl, "unsigned short",
            short_size, short_alignment, false, true)
    end

    def id
      @id ||= UnsignedShortTypeId.new
    end

    def integer_conversion_rank
      2
    end

    def arithmetic_type_with(type)
      type._arithmetic_type_with_unsigned_short(self)
    end

    def corresponding_signed_type
      signed_short_t
    end

    def corresponding_unsigned_type
      self
    end
  end

  class UnsignedShortTypeId < StandardTypeId
    def initialize
      super("unsigned short")
    end

    def ==(rhs_id)
      case rhs_id
      when UnsignedShortTypeId, UnsignedShortIntTypeId
        true
      else
        false
      end
    end
  end

  class ShortIntType < StandardIntegerType
    def initialize(type_tbl)
      # FIXME: StandardTypesAccessor is not ready until @type_table is
      #        initialized.
      @type_table = type_tbl
      super(type_tbl, "short int", short_size, short_alignment, true, false)
    end

    def id
      @id ||= ShortIntTypeId.new
    end

    def integer_conversion_rank
      2
    end

    def arithmetic_type_with(type)
      type._arithmetic_type_with_short_int(self)
    end

    def corresponding_signed_type
      signed_short_int_t
    end

    def corresponding_unsigned_type
      unsigned_short_int_t
    end
  end

  class ShortIntTypeId < StandardTypeId
    def initialize
      super("short int")
    end

    def ==(rhs_id)
      case rhs_id
      when ShortIntTypeId, ShortTypeId, SignedShortTypeId, SignedShortIntTypeId
        true
      else
        false
      end
    end
  end

  class SignedShortIntType < StandardIntegerType
    def initialize(type_tbl)
      # FIXME: StandardTypesAccessor is not ready until @type_table is
      #        initialized.
      @type_table = type_tbl
      super(type_tbl, "signed short int",
            short_size, short_alignment, true, true)
    end

    def id
      @id ||= SignedShortIntTypeId.new
    end

    def integer_conversion_rank
      2
    end

    def arithmetic_type_with(type)
      type._arithmetic_type_with_signed_short_int(self)
    end

    def corresponding_signed_type
      self
    end

    def corresponding_unsigned_type
      unsigned_short_int_t
    end
  end

  class SignedShortIntTypeId < StandardTypeId
    def initialize
      super("signed short int")
    end

    def ==(rhs_id)
      case rhs_id
      when SignedShortIntTypeId, ShortTypeId, ShortIntTypeId, SignedShortTypeId
        true
      else
        false
      end
    end
  end

  class UnsignedShortIntType < StandardIntegerType
    def initialize(type_tbl)
      # FIXME: StandardTypesAccessor is not ready until @type_table is
      #        initialized.
      @type_table = type_tbl
      super(type_tbl, "unsigned short int",
            short_size, short_alignment, false, true)
    end

    def id
      @id ||= UnsignedShortIntTypeId.new
    end

    def integer_conversion_rank
      2
    end

    def arithmetic_type_with(type)
      type._arithmetic_type_with_unsigned_short_int(self)
    end

    def corresponding_signed_type
      signed_short_int_t
    end

    def corresponding_unsigned_type
      self
    end
  end

  class UnsignedShortIntTypeId < StandardTypeId
    def initialize
      super("unsigned short int")
    end

    def ==(rhs_id)
      case rhs_id
      when UnsignedShortIntTypeId, UnsignedShortTypeId
        true
      else
        false
      end
    end
  end

  class IntType < StandardIntegerType
    def initialize(type_tbl)
      # FIXME: StandardTypesAccessor is not ready until @type_table is
      #        initialized.
      @type_table = type_tbl
      super(type_tbl, "int", int_size, int_alignment, true, false)
    end

    def id
      @id ||= IntTypeId.new
    end

    def integer_conversion_rank
      3
    end

    def arithmetic_type_with(type)
      type._arithmetic_type_with_int(self)
    end

    def corresponding_signed_type
      signed_int_t
    end

    def corresponding_unsigned_type
      unsigned_int_t
    end
  end

  class IntTypeId < StandardTypeId
    def initialize
      super("int")
    end

    def ==(rhs_id)
      case rhs_id
      when IntTypeId, SignedTypeId, SignedIntTypeId
        true
      else
        false
      end
    end
  end

  class SignedType < StandardIntegerType
    def initialize(type_tbl)
      # FIXME: StandardTypesAccessor is not ready until @type_table is
      #        initialized.
      @type_table = type_tbl
      super(type_tbl, "signed", int_size, int_alignment, true, true)
    end

    def id
      @id ||= SignedTypeId.new
    end

    def integer_conversion_rank
      3
    end

    def arithmetic_type_with(type)
      type._arithmetic_type_with_signed(self)
    end

    def corresponding_signed_type
      self
    end

    def corresponding_unsigned_type
      unsigned_t
    end
  end

  class SignedTypeId < StandardTypeId
    def initialize
      super("signed")
    end

    def ==(rhs_id)
      case rhs_id
      when SignedTypeId, IntTypeId, SignedIntTypeId
        true
      else
        false
      end
    end
  end

  class SignedIntType < StandardIntegerType
    def initialize(type_tbl)
      # FIXME: StandardTypesAccessor is not ready until @type_table is
      #        initialized.
      @type_table = type_tbl
      super(type_tbl, "signed int", int_size, int_alignment, true, true)
    end

    def id
      @id ||= SignedIntTypeId.new
    end

    def integer_conversion_rank
      3
    end

    def arithmetic_type_with(type)
      type._arithmetic_type_with_signed_int(self)
    end

    def corresponding_signed_type
      self
    end

    def corresponding_unsigned_type
      unsigned_int_t
    end
  end

  class SignedIntTypeId < StandardTypeId
    def initialize
      super("signed int")
    end

    def ==(rhs_id)
      case rhs_id
      when SignedIntTypeId, IntTypeId, SignedTypeId
        true
      else
        false
      end
    end
  end

  class UnsignedType < StandardIntegerType
    def initialize(type_tbl)
      # FIXME: StandardTypesAccessor is not ready until @type_table is
      #        initialized.
      @type_table = type_tbl
      super(type_tbl, "unsigned", int_size, int_alignment, false, true)
    end

    def id
      @id ||= UnsignedTypeId.new
    end

    def integer_conversion_rank
      3
    end

    def arithmetic_type_with(type)
      type._arithmetic_type_with_unsigned(self)
    end

    def corresponding_signed_type
      signed_t
    end

    def corresponding_unsigned_type
      self
    end
  end

  class UnsignedTypeId < StandardTypeId
    def initialize
      super("unsigned")
    end

    def ==(rhs_id)
      case rhs_id
      when UnsignedTypeId, UnsignedIntTypeId
        true
      else
        false
      end
    end
  end

  class UnsignedIntType < StandardIntegerType
    def initialize(type_tbl)
      # FIXME: StandardTypesAccessor is not ready until @type_table is
      #        initialized.
      @type_table = type_tbl
      super(type_tbl, "unsigned int", int_size, int_alignment, false, true)
    end

    def id
      @id ||= UnsignedIntTypeId.new
    end

    def integer_conversion_rank
      3
    end

    def arithmetic_type_with(type)
      type._arithmetic_type_with_unsigned_int(self)
    end

    def corresponding_signed_type
      signed_int_t
    end

    def corresponding_unsigned_type
      self
    end
  end

  class UnsignedIntTypeId < StandardTypeId
    def initialize
      super("unsigned int")
    end

    def ==(rhs_id)
      case rhs_id
      when UnsignedIntTypeId, UnsignedTypeId
        true
      else
        false
      end
    end
  end

  class LongType < StandardIntegerType
    def initialize(type_tbl)
      # FIXME: StandardTypesAccessor is not ready until @type_table is
      #        initialized.
      @type_table = type_tbl
      super(type_tbl, "long", long_size, long_alignment, true, false)
    end

    def id
      @id ||= LongTypeId.new
    end

    def integer_conversion_rank
      4
    end

    def arithmetic_type_with(type)
      type._arithmetic_type_with_long(self)
    end

    def corresponding_signed_type
      signed_long_t
    end

    def corresponding_unsigned_type
      unsigned_long_t
    end
  end

  class LongTypeId < StandardTypeId
    def initialize
      super("long")
    end

    def ==(rhs_id)
      case rhs_id
      when LongTypeId, SignedLongTypeId, LongIntTypeId, SignedLongIntTypeId
        true
      else
        false
      end
    end
  end

  class SignedLongType < StandardIntegerType
    def initialize(type_tbl)
      # FIXME: StandardTypesAccessor is not ready until @type_table is
      #        initialized.
      @type_table = type_tbl
      super(type_tbl, "signed long", long_size, long_alignment, true, true)
    end

    def id
      @id ||= SignedLongTypeId.new
    end

    def integer_conversion_rank
      4
    end

    def arithmetic_type_with(type)
      type._arithmetic_type_with_signed_long(self)
    end

    def corresponding_signed_type
      self
    end

    def corresponding_unsigned_type
      unsigned_long_t
    end
  end

  class SignedLongTypeId < StandardTypeId
    def initialize
      super("signed long")
    end

    def ==(rhs_id)
      case rhs_id
      when SignedLongTypeId, LongTypeId, LongIntTypeId, SignedLongIntTypeId
        true
      else
        false
      end
    end
  end

  class UnsignedLongType < StandardIntegerType
    def initialize(type_tbl)
      # FIXME: StandardTypesAccessor is not ready until @type_table is
      #        initialized.
      @type_table = type_tbl
      super(type_tbl, "unsigned long", long_size, long_alignment, false, true)
    end

    def id
      @id ||= UnsignedLongTypeId.new
    end

    def integer_conversion_rank
      4
    end

    def arithmetic_type_with(type)
      type._arithmetic_type_with_unsigned_long(self)
    end

    def corresponding_signed_type
      signed_long_t
    end

    def corresponding_unsigned_type
      self
    end
  end

  class UnsignedLongTypeId < StandardTypeId
    def initialize
      super("unsigned long")
    end

    def ==(rhs_id)
      case rhs_id
      when UnsignedLongTypeId, UnsignedLongIntTypeId
        true
      else
        false
      end
    end
  end

  class LongIntType < StandardIntegerType
    def initialize(type_tbl)
      # FIXME: StandardTypesAccessor is not ready until @type_table is
      #        initialized.
      @type_table = type_tbl
      super(type_tbl, "long int", long_size, long_alignment, true, false)
    end

    def id
      @id ||= LongIntTypeId.new
    end

    def integer_conversion_rank
      4
    end

    def arithmetic_type_with(type)
      type._arithmetic_type_with_long_int(self)
    end

    def corresponding_signed_type
      signed_long_int_t
    end

    def corresponding_unsigned_type
      unsigned_long_int_t
    end
  end

  class LongIntTypeId < StandardTypeId
    def initialize
      super("long int")
    end

    def ==(rhs_id)
      case rhs_id
      when LongIntTypeId, LongTypeId, SignedLongTypeId, SignedLongIntTypeId
        true
      else
        false
      end
    end
  end

  class SignedLongIntType < StandardIntegerType
    def initialize(type_tbl)
      # FIXME: StandardTypesAccessor is not ready until @type_table is
      #        initialized.
      @type_table = type_tbl
      super(type_tbl, "signed long int", long_size, long_alignment, true, true)
    end

    def id
      @id ||= SignedLongIntTypeId.new
    end

    def integer_conversion_rank
      4
    end

    def arithmetic_type_with(type)
      type._arithmetic_type_with_signed_long_int(self)
    end

    def corresponding_signed_type
      self
    end

    def corresponding_unsigned_type
      unsigned_long_int_t
    end
  end

  class SignedLongIntTypeId < StandardTypeId
    def initialize
      super("signed long int")
    end

    def ==(rhs_id)
      case rhs_id
      when SignedLongIntTypeId, LongTypeId, LongIntTypeId, SignedLongTypeId
        true
      else
        false
      end
    end
  end

  class UnsignedLongIntType < StandardIntegerType
    def initialize(type_tbl)
      # FIXME: StandardTypesAccessor is not ready until @type_table is
      #        initialized.
      @type_table = type_tbl
      super(type_tbl, "unsigned long int",
            long_size, long_alignment, false, true)
    end

    def id
      @id ||= UnsignedLongIntTypeId.new
    end

    def integer_conversion_rank
      4
    end

    def arithmetic_type_with(type)
      type._arithmetic_type_with_unsigned_long_int(self)
    end

    def corresponding_signed_type
      signed_long_int_t
    end

    def corresponding_unsigned_type
      self
    end
  end

  class UnsignedLongIntTypeId < StandardTypeId
    def initialize
      super("unsigned long int")
    end

    def ==(rhs_id)
      case rhs_id
      when UnsignedLongIntTypeId, UnsignedLongTypeId
        true
      else
        false
      end
    end
  end

  class LongLongType < StandardIntegerType
    def initialize(type_tbl)
      # FIXME: StandardTypesAccessor is not ready until @type_table is
      #        initialized.
      @type_table = type_tbl
      super(type_tbl, "long long",
            long_long_size, long_long_alignment, true, false)
    end

    def id
      @id ||= LongLongTypeId.new
    end

    def integer_conversion_rank
      5
    end

    def arithmetic_type_with(type)
      type._arithmetic_type_with_long_long(self)
    end

    def corresponding_signed_type
      signed_long_long_t
    end

    def corresponding_unsigned_type
      unsigned_long_long_t
    end
  end

  class LongLongTypeId < StandardTypeId
    def initialize
      super("long long")
    end

    def ==(rhs_id)
      case rhs_id
      when LongLongTypeId, SignedLongLongTypeId, LongLongIntTypeId,
           SignedLongLongIntTypeId
        true
      else
        false
      end
    end
  end

  class SignedLongLongType < StandardIntegerType
    def initialize(type_tbl)
      # FIXME: StandardTypesAccessor is not ready until @type_table is
      #        initialized.
      @type_table = type_tbl
      super(type_tbl, "signed long long",
            long_long_size, long_long_alignment, true, true)
    end

    def id
      @id ||= SignedLongLongTypeId.new
    end

    def integer_conversion_rank
      5
    end

    def arithmetic_type_with(type)
      type._arithmetic_type_with_signed_long_long(self)
    end

    def corresponding_signed_type
      self
    end

    def corresponding_unsigned_type
      unsigned_long_long_t
    end
  end

  class SignedLongLongTypeId < StandardTypeId
    def initialize
      super("signed long long")
    end

    def ==(rhs_id)
      case rhs_id
      when SignedLongLongTypeId, LongLongTypeId, LongLongIntTypeId,
           SignedLongLongIntTypeId
        true
      else
        false
      end
    end
  end

  class UnsignedLongLongType < StandardIntegerType
    def initialize(type_tbl)
      # FIXME: StandardTypesAccessor is not ready until @type_table is
      #        initialized.
      @type_table = type_tbl
      super(type_tbl, "unsigned long long",
            long_long_size, long_long_alignment, false, true)
    end

    def id
      @id ||= UnsignedLongLongTypeId.new
    end

    def integer_conversion_rank
      5
    end

    def arithmetic_type_with(type)
      type._arithmetic_type_with_unsigned_long_long(self)
    end

    def corresponding_signed_type
      signed_long_long_t
    end

    def corresponding_unsigned_type
      self
    end
  end

  class UnsignedLongLongTypeId < StandardTypeId
    def initialize
      super("unsigned long long")
    end

    def ==(rhs_id)
      case rhs_id
      when UnsignedLongLongTypeId, UnsignedLongLongIntTypeId
        true
      else
        false
      end
    end
  end

  class LongLongIntType < StandardIntegerType
    def initialize(type_tbl)
      # FIXME: StandardTypesAccessor is not ready until @type_table is
      #        initialized.
      @type_table = type_tbl
      super(type_tbl, "long long int",
            long_long_size, long_long_alignment, true, false)
    end

    def id
      @id ||= LongLongIntTypeId.new
    end

    def integer_conversion_rank
      5
    end

    def arithmetic_type_with(type)
      type._arithmetic_type_with_long_long_int(self)
    end

    def corresponding_signed_type
      signed_long_long_int_t
    end

    def corresponding_unsigned_type
      unsigned_long_long_int_t
    end
  end

  class LongLongIntTypeId < StandardTypeId
    def initialize
      super("long long int")
    end

    def ==(rhs_id)
      case rhs_id
      when LongLongIntTypeId, LongLongTypeId, SignedLongLongTypeId,
           SignedLongLongIntTypeId
        true
      else
        false
      end
    end
  end

  class SignedLongLongIntType < StandardIntegerType
    def initialize(type_tbl)
      # FIXME: StandardTypesAccessor is not ready until @type_table is
      #        initialized.
      @type_table = type_tbl
      super(type_tbl, "signed long long int",
            long_long_size, long_long_alignment, true, true)
    end

    def id
      @id ||= SignedLongLongIntTypeId.new
    end

    def integer_conversion_rank
      5
    end

    def arithmetic_type_with(type)
      type._arithmetic_type_with_signed_long_long_int(self)
    end

    def corresponding_signed_type
      self
    end

    def corresponding_unsigned_type
      unsigned_long_long_int_t
    end
  end

  class SignedLongLongIntTypeId < StandardTypeId
    def initialize
      super("signed long long int")
    end

    def ==(rhs_id)
      case rhs_id
      when SignedLongLongIntTypeId, LongLongTypeId, LongLongIntTypeId,
           SignedLongLongType
        true
      else
        false
      end
    end
  end

  class UnsignedLongLongIntType < StandardIntegerType
    def initialize(type_tbl)
      # FIXME: StandardTypesAccessor is not ready until @type_table is
      #        initialized.
      @type_table = type_tbl
      super(type_tbl, "unsigned long long int",
            long_long_size, long_long_alignment, false, true)
    end

    def id
      @id ||= UnsignedLongLongIntTypeId.new
    end

    def integer_conversion_rank
      5
    end

    def arithmetic_type_with(type)
      type._arithmetic_type_with_unsigned_long_long_int(self)
    end

    def corresponding_signed_type
      signed_long_long_int_t
    end

    def corresponding_unsigned_type
      self
    end
  end

  class UnsignedLongLongIntTypeId < StandardTypeId
    def initialize
      super("unsigned long long int")
    end

    def ==(rhs_id)
      case rhs_id
      when UnsignedLongLongIntTypeId, UnsignedLongLongTypeId
        true
      else
        false
      end
    end
  end

  class BitfieldType < IntegerType
    def initialize(type_tbl, base_type, field_width)
      super(type_tbl, "#{base_type.real_type.name}:#{field_width}",
            field_width, base_type.bit_alignment,
            base_type.signed?, base_type.explicitly_signed?)
      @base_type = base_type
    end

    attr_reader :base_type

    def id
      @id ||= BitfieldTypeId.new(@base_type, bit_size)
    end

    def incomplete?
      @base_type.incomplete?
    end

    def pointer?
      false
    end

    def enum?
      false
    end

    def standard?
      false
    end

    def bitfield?
      true
    end

    def undeclared?
      @base_type.undeclared?
    end

    def unresolved?
      @base_type.unresolved?
    end

    def enumerators
      []
    end

    def integer_conversion_rank
      -1
    end

    def integer_promoted_type
      # TODO: Should support the C99 _Bool type.
      # NOTE: The ISO C99 standard says;
      #
      # 6.3.1 Arithmetic operands
      # 6.3.1.1 Boolean, characters, and integers
      #
      # 2 The following may be used in an expression wherever an int or
      #   unsigned int may be used:
      #
      #     -- An object or expression with an integer type whose integer
      #        conversion rank is less than or equal to the rank of int and
      #        unsigned int.
      #     -- A bit-field of type _Bool, int, signed int, or unsigned int.
      #
      #   If an int can represent all values of the original type, the value is
      #   converted to an int; otherwise, it is converted to an unsigned int.
      #   These are called the integer promotions.  All other types are
      #   unchanged by the integer promotions.
      if self.undeclared? || self.unresolved?
        self
      else
        if @base_type.same_as?(int_t) || @base_type.same_as?(unsigned_int_t)
          self.compatible?(int_t) ? int_t : unsigned_int_t
        else
          self
        end
      end
    end

    def arithmetic_type_with(type)
      type._arithmetic_type_with_bitfield(self)
    end

    def corresponding_signed_type
      self # NOTREACHED
    end

    def corresponding_unsigned_type
      self # NOTREACHED
    end

    def dup
      BitfieldType.new(type_table, @base_type.dup, bit_size)
    end
  end

  class BitfieldTypeId < TypeId
    def initialize(base_type, field_width)
      super(create_value(base_type, field_width))
    end

    private
    def create_value(base_type, field_width)
      "#{base_type.real_type.name.split(" ").sort.join(" ")}:#{field_width}"
    end
  end

  module Scopeable
    attr_accessor :scope
  end

  class EnumType < IntegerType
    include Scopeable

    def initialize(type_tbl, type_dcl)
      # FIXME: StandardTypeCatalogAccessor is not ready until @type_table is
      #        initialized.
      @type_table = type_tbl
      super(type_tbl, type_dcl.identifier.value,
            int_size, int_alignment, true, true, [type_dcl])
      @image = type_dcl.enum_specifier.to_s
      @location = type_dcl.location
    end

    attr_accessor :image
    attr_accessor :location

    def id
      @id ||= EnumTypeId.new(name)
    end

    def incomplete?
      declarations.all? { |dcl| dcl.enumerators.nil? }
    end

    def pointer?
      false
    end

    def enum?
      true
    end

    def standard?
      false
    end

    def bitfield?
      false
    end

    def brief_image
      "enum #{name}"
    end

    def enumerators
      declarations.map { |dcl| dcl.enumerators }.compact.flatten.uniq
    end

    def integer_conversion_rank
      # NOTE: The ISO C99 standard says;
      #
      # 6.3.1 Arithmetic operands
      # 6.3.1.1 Boolean, characters, and integers
      #
      # 1 Every integer type has an integer conversion rank defined as follows:
      #
      #     -- No two signed integer types shall have the same rank, even if
      #        they have the same representation.
      #     -- The rank of a signed integer type shall be greater than the rank
      #        of any signed integer type with less precision.
      #     -- The rank of long long int shall be greater than the rank of long
      #        int, which shall be greater than the rank of int, which shall be
      #        greater than the rank of short int, which shall be greater than
      #        the rank of signed char.
      #     -- The rank of any unsigned integer type shall equal the rank of
      #        the corresponding signed integer type, if any.
      #     -- The rank of any standard integer type shall be greater than the
      #        rank of any extended integer type with the same width.
      #     -- The rank of char shall equal the rank of signed char and
      #        unsigned char.
      #     -- The rank of _Bool shall be less than the rank of all other
      #        standard integer types.
      #     -- The rank of any enumerated type shall equal the rank of the
      #        compatible integer type.
      #     -- The rank of any extended signed integer type relative to another
      #        extended signed integer type with the same precision is
      #        implementation-defined, but still subject to the other rules for
      #        determining the integer conversion rank.
      #     -- For all integer types T1, T2, and T3, if T1 has greater rank
      #        than T2 and T2 has greater rank than T3, then T1 has greater
      #        rank than T3.
      #
      # NOTE: The integer conversion rank of any enumerated type is equal to
      #       the rank of int.
      int_t.integer_conversion_rank
    end

    def integer_promoted_type
      # NOTE: Any enumerated type should be treated as `int'.
      #       But AdLint internally treats enumerated type as itself, and omits
      #       integer-promotion of any enumerated type in order not to
      #       over-warn about enum-enum expressions like below;
      #
      #         static void foo(enum Color c)
      #         {
      #             if (c == RED) { /* No usual-arithmetic-conversion of
      #                                enumerated types and no W9003 warning */
      #                 ...
      #             }
      #         }
      self
    end

    def arithmetic_type_with(type)
      type._arithmetic_type_with_enum(self)
    end

    def corresponding_signed_type
      signed_int_t
    end

    def corresponding_unsigned_type
      unsigned_int_t
    end

    def dup
      EnumType.new(type_table, declarations.first)
    end
  end

  class EnumTypeId < TypeId
    def initialize(name)
      super("enum #{name}")
    end
  end

  class PointerType < IntegerType
    def initialize(type_tbl, base_type)
      # FIXME: StandardTypesAccessor is not ready until @type_table is
      #        initialized.
      @type_table = type_tbl
      super(type_tbl, create_name(base_type),
            base_type.function? ? code_ptr_size : data_ptr_size,
            base_type.function? ? code_ptr_alignment : data_ptr_alignment,
            false, true, base_type.declarations)
      @base_type = base_type
    end

    attr_reader :base_type

    def id
      @id ||= PointerTypeId.new(@base_type)
    end

    def image
      create_image(@base_type)
    end

    def brief_image
      create_brief_image(@base_type)
    end

    def real_type
      type_table.pointer_type(@base_type.real_type)
    end

    def incomplete?
      false
    end

    def convertible?(to_type)
      lhs_unqualified = self.real_type.unqualify
      rhs_unqualified = to_type.real_type.unqualify

      if rhs_unqualified.pointer? || rhs_unqualified.array?
        lhs_base = lhs_unqualified.base_type
        rhs_base = rhs_unqualified.base_type

        unless lhs_base.more_cv_qualified?(rhs_base)
          rhs_base.void? || lhs_base.convertible?(rhs_base)
        else
          false
        end
      else
        false
      end
    end

    def pointer?
      true
    end

    def enum?
      false
    end

    def standard?
      false
    end

    def undeclared?
      # NOTE: To avoid the infinite recursive call of #undeclared? when the
      #       composite type contains the pointer to it's owner type.
      @base_type.kind_of?(UndeclaredType)
    end

    def unresolved?
      # NOTE: To avoid the infinite recursive call of #unresolved? when the
      #       composite type contains the pointer to it's owner type.
      @base_type.kind_of?(UnresolvedType)
    end

    def bitfield?
      false
    end

    def enumerators
      []
    end

    def integer_conversion_rank
      # NOTE: Pointer variables must not be converted implicitly.
      100
    end

    def integer_promoted_type
      # NOTE: Pointer variables must not be converted implicitly.
      self
    end

    def arithmetic_type_with(type)
      type._arithmetic_type_with_pointer(self)
    end

    def corresponding_signed_type
      self # NOTREACHED
    end

    def corresponding_unsigned_type
      self # NOTREACHED
    end

    def dup
      PointerType.new(type_table, @base_type.dup)
    end

    private
    def create_name(base_type)
      if base_type.function?
        "#{base_type.return_type.name}(*)(" +
          base_type.parameter_types.map { |type| type.name }.join(",") +
          (base_type.have_va_list? ? ",...)" : ")")
      else
        "#{base_type.name} *"
      end
    end

    def create_image(base_type)
      if base_type.function?
        "#{base_type.return_type.image}(*)(" +
          base_type.parameter_types.map { |type| type.image }.join(",") +
          (base_type.have_va_list? ? ",...)" : ")")
      else
        "#{base_type.image} *"
      end
    end

    def create_brief_image(base_type)
      if base_type.function?
        "#{base_type.return_type.brief_image}(*)(" +
          base_type.parameter_types.map { |type| type.brief_image }.join(",") +
          (base_type.have_va_list? ? ",...)" : ")")
      else
        "#{base_type.brief_image} *"
      end
    end
  end

  class PointerTypeId < TypeId
    def initialize(base_type)
      super(create_value(base_type))
      @base_type = base_type
    end

    def ==(rhs_id)
      case rhs_id
      when PointerTypeId
        @base_type == rhs_id.base_type
      else
        false
      end
    end

    def hash
      "#{@base_type.id.hash}*".hash
    end

    protected
    attr_reader :base_type

    private
    def create_value(base_type)
      real_type = base_type.real_type

      if real_type.function?
        "#{real_type.return_type.brief_image}(*)(" +
          real_type.parameter_types.map { |type| type.brief_image }.join(",") +
          (real_type.have_va_list? ? ",...)" : ")")
      else
        "#{real_type.brief_image} *"
      end
    end
  end

  class FloatingType < ScalarDataType
    def id
      subclass_responsibility
    end

    def image
      name
    end

    def brief_image
      name
    end

    def location
      nil
    end

    def incomplete?
      false
    end

    def compatible?(to_type)
      type.floating? && to_type.min <= min && max <= to_type.max
    end

    def integer?
      false
    end

    def floating?
      true
    end

    def pointer?
      false
    end

    def enum?
      false
    end

    def bitfield?
      false
    end

    def signed?
      true
    end

    def explicitly_signed?
      true
    end

    def enumerators
      []
    end

    def min
      (-2**fraction_bit_size * 10**(exponent_bit_size - 1)).to_f
    end

    def max
      (2**fraction_bit_size * 10**(exponent_bit_size - 1)).to_f
    end

    def integer_conversion_rank
      0 # NOTREACHED
    end

    def integer_promoted_type
      self # NOTREACHED
    end

    def argument_promoted_type
      subclass_responsibility
    end

    def arithmetic_type_with(type)
      subclass_responsibility
    end

    def corresponding_signed_type
      self # NOTREACHED
    end

    def corresponding_unsigned_type
      self # NOTREACHED
    end

    def dup
      subclass_responsibility
    end

    private
    def fraction_bit_size
      subclass_responsibility
    end

    def exponent_bit_size
      subclass_responsibility
    end
  end

  class StandardFloatingType < FloatingType
    def standard?
      true
    end

    def dup
      self.class.new(type_table)
    end
  end

  class FloatType < StandardFloatingType
    def initialize(type_tbl)
      # FIXME: StandardTypesAccessor is not ready until @type_table is
      #        initialized.
      @type_table = type_tbl
      super(type_tbl, "float", float_size, float_alignment)
    end

    def id
      @id ||= FloatTypeId.new
    end

    def argument_promoted_type
      # NOTE: The ISO C99 standard says;
      #
      # 6.5.2.2 Function calls
      #
      # 6 If the expression that denotes the called function has a type that
      #   does not include a prototype, the integer promotions are performed on
      #   each argument, and arguments that have type float are promoted to
      #   double.  These are called the default argument promotions.  If the
      #   number of arguments does not equal the number of parameters, the
      #   behavior is undefined.  If the function is defined with a type that
      #   includes a prototype, and either the prototype ends with an ellipsis
      #   (, ...) or the types of the arguments after promotion are not
      #   compatible with the types of the parameters, the behavior is
      #   undefined.  If the function is defined with a type that does not
      #   include a prototype, and the types of the arguments after promotion
      #   are not compatible with those of the parameters after promotion, the
      #   behavior is undefined, except for the following cases:
      #
      #     -- one promoted type is a signed integer type, the other promoted
      #        type is the corresponding unsigned integer type, and the value
      #        is representable in both types;
      #     -- both types are pointers to qualified or unqualified versions of
      #        a character type or void.
      double_t
    end

    def arithmetic_type_with(type)
      type._arithmetic_type_with_float(self)
    end

    private
    def fraction_bit_size
      # TODO: Bit size of the fraction part of `float' should be configurable.
      23
    end

    def exponent_bit_size
      # TODO: Bit size of the exponent part of `float' should be configurable.
      8
    end
  end

  class FloatTypeId < StandardTypeId
    def initialize
      super("float")
    end
  end

  class DoubleType < StandardFloatingType
    def initialize(type_tbl)
      # FIXME: StandardTypesAccessor is not ready until @type_table is
      #        initialized.
      @type_table = type_tbl
      super(type_tbl, "double", double_size, double_alignment)
    end

    def id
      @id ||= DoubleTypeId.new
    end

    def argument_promoted_type
      self
    end

    def arithmetic_type_with(type)
      type._arithmetic_type_with_double(self)
    end

    private
    def fraction_bit_size
      # TODO: Bit size of the fraction part of `double' should be configurable.
      52
    end

    def exponent_bit_size
      # TODO: Bit size of the exponent part of `double' should be configurable.
      11
    end
  end

  class DoubleTypeId < StandardTypeId
    def initialize
      super("double")
    end
  end

  class LongDoubleType < StandardFloatingType
    def initialize(type_tbl)
      # FIXME: StandardTypesAccessor is not ready until @type_table is
      #        initialized.
      @type_table = type_tbl
      super(type_tbl, "long double", long_double_size, long_double_alignment)
    end

    def id
      @id ||= LongDoubleTypeId.new
    end

    def argument_promoted_type
      self
    end

    def arithmetic_type_with(type)
      type._arithmetic_type_with_long_double(self)
    end

    private
    def fraction_bit_size
      # TODO: Bit size of the fraction part of `long double' should be
      #       configurable.
      52
    end

    def exponent_bit_size
      # TODO: Bit size of the exponent part of `long double' should be
      #       configurable.
      11
    end
  end

  class LongDoubleTypeId < StandardTypeId
    def initialize
      super("long double")
    end
  end

  class ArrayType < Type
    # NOTE: To avoid huge array allocation in interpreting phase.
    MAX_LENGTH = 256
    private_constant :MAX_LENGTH

    def initialize(type_tbl, base_type, len = nil)
      super(type_tbl, create_name(base_type, len))
      @base_type = base_type
      @length = len
    end

    attr_reader :base_type

    # NOTE: Length of the array type may be deducted by the size of the
    #       initializer in interpret phase.
    attr_accessor :length

    def impl_length
      # NOTE: Implementation defined length of this array.
      @length ? [[0, @length].max, MAX_LENGTH].min : 0
    end

    def id
      # NOTE: ID of the array type cannot be cached.
      #       Length of the variable length array will be deducted in the
      #       interpret phase.
      ArrayTypeId.new(@base_type, @length)
    end

    def image
      create_image(@base_type, @length)
    end

    def brief_image
      create_brief_image(@base_type, @length)
    end

    def location
      nil
    end

    def bit_size
      @length ? @base_type.bit_size * @length : 0
    end

    def bit_alignment
      aligned_bit_size
    end

    def aligned_bit_size
      @length ? @base_type.aligned_bit_size * @length : 0
    end

    def real_type
      type_table.array_type(@base_type.real_type, @length)
    end

    def unqualify
      self
    end

    def incomplete?
      @base_type.incomplete? || @length.nil?
    end

    def compatible?(to_type)
      to_type.array? &&
        @length == to_type.length && @base_type.compatible?(to_type.base_type)
    end

    def coercible?(to_type)
      to_type.array? && @base_type.coercible?(to_type.base_type)
    end

    def convertible?(to_type)
      lhs_unqualified = self.real_type.unqualify
      rhs_unqualified = to_type.real_type.unqualify

      if rhs_unqualified.pointer? || rhs_unqualified.array?
        lhs_base = lhs_unqualified.base_type
        rhs_base = rhs_unqualified.base_type

        unless lhs_base.more_cv_qualified?(rhs_base)
          rhs_base.void? || lhs_base.convertible?(rhs_base)
        else
          false
        end
      else
        false
      end
    end

    def same_as?(type)
      lhs_unqualified = self.real_type.unqualify
      rhs_unqualified = type.real_type.unqualify

      case
      when rhs_unqualified.array?
        if lhs_unqualified.length
          lhs_unqualified.length == rhs_unqualified.length
        else
          lhs_unqualified.base_type.same_as?(rhs_unqualified.base_type)
        end
      when rhs_unqualified.pointer?
        lhs_unqualified.base_type.same_as?(rhs_unqualified.base_type)
      else
        false
      end
    end

    def scalar?
      false
    end

    def integer?
      false
    end

    def floating?
      false
    end

    def array?
      true
    end

    def struct?
      false
    end

    def union?
      false
    end

    def pointer?
      false
    end

    def qualified?
      false
    end

    def function?
      false
    end

    def enum?
      false
    end

    def user?
      false
    end

    def void?
      false
    end

    def standard?
      false
    end

    def undeclared?
      @base_type.undeclared?
    end

    def unresolved?
      @base_type.unresolved?
    end

    def const?
      @base_type.const?
    end

    def volatile?
      @base_type.volatile?
    end

    def restrict?
      @base_type.restrict?
    end

    def bitfield?
      false
    end

    def signed?
      false
    end

    def explicitly_signed?
      false
    end

    def have_va_list?
      false
    end

    def return_type
      nil
    end

    def parameter_types
      []
    end

    def enumerators
      []
    end

    def members
      []
    end

    def member_named(name)
      nil
    end

    def min
      0
    end

    def max
      0
    end

    def nil_value
      ArrayValue.new(impl_length.times.map { @base_type.nil_value })
    end

    def zero_value
      ArrayValue.new(impl_length.times.map { @base_type.zero_value })
    end

    def arbitrary_value
      ArrayValue.new(impl_length.times.map { @base_type.arbitrary_value })
    end

    def undefined_value
      ArrayValue.new(impl_length.times.map { @base_type.undefined_value })
    end

    def parameter_value
      ArrayValue.new(impl_length.times.map { @base_type.parameter_value })
    end

    def return_value
      ArrayValue.new(impl_length.times.map { @base_type.return_value })
    end

    def coerce_scalar_value(val)
      # NOTE: Cannot coerce scalar value into array in C language.
      undefined_value # NOTREACHED
    end

    def coerce_array_value(val)
      # NOTE: The ISO C99 standard says;
      #
      # 6.7.8 Initialization
      #
      # Semantics
      #
      # 10 If an object that has automatic storage duration is not initialized
      #    explicitly, its value is indeterminate.  If an object that has
      #    static storage duration is not initialized explicitly, then:
      #
      #    -- if it has pointer type, it is initialized to a null pointer;
      #    -- if it has arithmetic type, it is initialized to (positive or
      #       unsigned) zero;
      #    -- if it is an aggregate, every member is initialized (recursively)
      #       according to these rules;
      #    -- if it is a union, the first named member is initialized
      #       (recursively) according to these rules.
      #
      # 21 If there are fewer initializers in a brace-enclosed list than there
      #    are elements or members of an aggregate, or fewer characters in a
      #    string literal used to initialize an array of known size that there
      #    are elements in the array, the remainder of the aggregate shall be
      #    initialized implicitly the same as objects that have static storage
      #    duration.
      vals = ([@base_type] * impl_length).zip(val.values).map { |type, v|
        v ? v.coerce_to(type) : type.arbitrary_value
      }
      ArrayValue.new(vals)
    end

    def coerce_composite_value(val)
      # NOTE: Cannot coerce composite value into array in C language.
      undefined_value # NOTREACHED
    end

    def integer_conversion_rank
      0 # NOTREACHED
    end

    def integer_promoted_type
      self # NOTREACHED
    end

    def argument_promoted_type
      self # NOTREACHED
    end

    def arithmetic_type_with(type)
      # NOTE: An arithmetic operation with ArrayType must not be executed!
      type._arithmetic_type_with_array(self) # NOTREACHED
    end

    def _arithmetic_type_with_undeclared(lhs_type, rhs_type = self)
      rhs_type.arithmetic_type_with(lhs_type)
    end

    def _arithmetic_type_with_unresolved(lhs_type, rhs_type = self)
      rhs_type.arithmetic_type_with(lhs_type)
    end

    def _arithmetic_type_with_void(lhs_type, rhs_type = self)
      rhs_type.arithmetic_type_with(lhs_type)
    end

    def _arithmetic_type_with_function(lhs_type, rhs_type = self)
      rhs_type.arithmetic_type_with(lhs_type)
    end

    def _arithmetic_type_with_char(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with ArrayType must not be executed!
      # NOTE: Binary operation with `char' and ArrayType
      #       makes integer-promoted type of `char'.
      lhs_type.integer_promoted_type # NOTREACHED
    end

    def _arithmetic_type_with_signed_char(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with ArrayType must not be executed!
      # NOTE: Binary operation with `signed char' and ArrayType
      #       makes integer-promoted type of `signed char'.
      lhs_type.integer_promoted_type # NOTREACHED
    end

    def _arithmetic_type_with_unsigned_char(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with ArrayType must not be executed!
      # NOTE: Binary operation with `unsigned char' and ArrayType
      #       makes integer-promoted type of `unsigned char'.
      lhs_type.integer_promoted_type # NOTREACHED
    end

    def _arithmetic_type_with_short(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with ArrayType must not be executed!
      # NOTE: Binary operation with `short' and ArrayType
      #       makes integer-promoted type of `short'.
      lhs_type.integer_promoted_type # NOTREACHED
    end

    def _arithmetic_type_with_signed_short(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with ArrayType must not be executed!
      # NOTE: Binary operation with `signed short' and ArrayType
      #       makes integer-promoted type of `signed short'.
      lhs_type.integer_promoted_type # NOTREACHED
    end

    def _arithmetic_type_with_unsigned_short(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with ArrayType must not be executed!
      # NOTE: Binary operation with `unsigned short' and ArrayType
      #       makes integer-promoted type of `unsigned short'.
      lhs_type.integer_promoted_type # NOTREACHED
    end

    def _arithmetic_type_with_short_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with ArrayType must not be executed!
      # NOTE: Binary operation with `short int' and ArrayType
      #       makes integer-promoted type of `short int'.
      lhs_type.integer_promoted_type # NOTREACHED
    end

    def _arithmetic_type_with_signed_short_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with ArrayType must not be executed!
      # NOTE: Binary operation with `signed short int' and ArrayType
      #       makes integer-promoted type of `signed short int'.
      lhs_type.integer_promoted_type # NOTREACHED
    end

    def _arithmetic_type_with_unsigned_short_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with ArrayType must not be executed!
      # NOTE: Binary operation with `unsigned short int' and ArrayType
      #       makes integer-promoted type of `unsigned short int'.
      lhs_type.integer_promoted_type # NOTREACHED
    end

    def _arithmetic_type_with_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with ArrayType must not be executed!
      # NOTE: Binary operation with `int' and ArrayType makes `int'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_signed(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with ArrayType must not be executed!
      # NOTE: Binary operation with `signed' and ArrayType makes `signed'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_signed_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with ArrayType must not be executed!
      # NOTE: Binary operation with `signed int' and ArrayType
      #       makes `signed int'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_unsigned(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with ArrayType must not be executed!
      # NOTE: Binary operation with `unsigned' and ArrayType makes `unsigned'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_unsigned_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with ArrayType must not be executed!
      # NOTE: Binary operation with `unsigned int' and ArrayType
      #       makes `unsigned int'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_long(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with ArrayType must not be executed!
      # NOTE: Binary operation with `long' and ArrayType makes `long'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_signed_long(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with ArrayType must not be executed!
      # NOTE: Binary operation with `signed long' and ArrayType
      #       makes `signed long'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_unsigned_long(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with ArrayType must not be executed!
      # NOTE: Binary operation with `unsigned long' and ArrayType
      #       makes `unsigned long'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_long_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with ArrayType must not be executed!
      # NOTE: Binary operation with `long int' and ArrayType makes `long int'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_signed_long_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with ArrayType must not be executed!
      # NOTE: Binary operation with `signed long int' and ArrayType
      #       makes `signed long int'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_unsigned_long_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with ArrayType must not be executed!
      # NOTE: Binary operation with `unsigned long int' and ArrayType
      #       makes `unsigned long int'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_long_long(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with ArrayType must not be executed!
      # NOTE: Binary operation with `long long' and ArrayType makes
      #       `long long'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_signed_long_long(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with ArrayType must not be executed!
      # NOTE: Binary operation with `signed long long' and ArrayType
      #       makes `signed long long'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_unsigned_long_long(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with ArrayType must not be executed!
      # NOTE: Binary operation with `unsigned long long' and ArrayType
      #       makes `unsigned long long'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_long_long_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with ArrayType must not be executed!
      # NOTE: Binary operation with `long long int' and ArrayType
      #       makes `long long int'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_signed_long_long_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with ArrayType must not be executed!
      # NOTE: Binary operation with `signed long long int' and ArrayType
      #       makes `signed long long int'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_unsigned_long_long_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with ArrayType must not be executed!
      # NOTE: Binary operation with `unsigned long long int' and ArrayType
      #       makes `unsigned long long int'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_float(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with ArrayType must not be executed!
      # NOTE: Binary operation with `float' and ArrayType makes `float'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_double(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with ArrayType must not be executed!
      # NOTE: Binary operation with `double' and ArrayType makes `double'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_long_double(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with ArrayType must not be executed!
      # NOTE: Binary operation with `long double' and ArrayType
      #       makes `long double'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_bitfield(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with ArrayType must not be executed!
      # NOTE: Binary operation with BitfieldType and ArrayType
      #       makes integer-promoted type of BitfieldType.
      lhs_type.integer_promoted_type # NOTREACHED
    end

    def _arithmetic_type_with_enum(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with ArrayType must not be executed!
      # NOTE: Binary operation with EnumType and ArrayType makes EnumType.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_pointer(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with ArrayType must not be executed!
      # NOTE: Binary operation with PointerType and ArrayType makes
      #       PointerType.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_array(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with ArrayType must not be executed!
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_struct(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with ArrayType must not be executed!
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_union(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with ArrayType must not be executed!
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_extended_big_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with ArrayType must not be executed!
      # NOTE: Binary operation with ExtendedBigIntType and ArrayType
      #       makes ExtendedBigIntType.
      lhs_type # NOTREACHED
    end

    def corresponding_signed_type
      self # NOTREACHED
    end

    def corresponding_unsigned_type
      self # NOTREACHED
    end

    def dup
      ArrayType.new(type_table, @base_type.dup, @length)
    end

    private
    def create_name(base_type, len)
      "(#{base_type.name})[#{len ? len : ""}]"
    end

    def create_image(base_type, len)
      "(#{base_type.image})[#{len ? len : ""}]"
    end

    def create_brief_image(base_type, len)
      "(#{base_type.brief_image})[#{len ? len : ""}]"
    end
  end

  class ArrayTypeId < TypeId
    def initialize(base_type, len)
      super(create_value(base_type, len))
    end

    private
    def create_value(base_type, len)
      if len
        "#{base_type.brief_image}[#{len}]"
      else
        "#{base_type.brief_image}[]"
      end
    end
  end

  # == DESCRIPTION
  # Type of the `struct' or `union' data type.
  #
  # The ISO C99 standard specifies that the `struct' and array data type is an
  # aggregate type.
  # But the CompositeDataType is not an array type.
  class CompositeDataType < Type
    include Scopeable

    def initialize(type_tbl, name, type_dcls, membs)
      super(type_tbl, name, type_dcls)
      @members = membs
    end

    attr_reader :members

    def id
      subclass_responsibility
    end

    def image
      subclass_responsibility
    end

    def brief_image
      subclass_responsibility
    end

    def location
      subclass_responsibility
    end

    def bit_size
      @members.reduce(0) { |sum, memb| sum + memb.type.bit_size }
    end

    def bit_alignment
      bit_size
    end

    def aligned_bit_size
      @members.reduce(0) { |sum, memb| sum + memb.type.aligned_bit_size }
    end

    def real_type
      self
    end

    def base_type
      nil
    end

    def unqualify
      self
    end

    def incomplete?
      declarations.all? { |dcl| dcl.struct_declarations.nil? }
    end

    def compatible?(to_type)
      to_type.composite? &&
        @members.size == to_type.members.size &&
        @members.zip(to_type.members).all? { |lhs, rhs| lhs.compatible?(rhs) }
    end

    def coercible?(to_type)
      to_type.composite? &&
        @members.zip(to_type.members).all? { |lhs_memb, rhs_memb|
          rhs_memb && lhs_memb.type.coercible?(rhs_memb.type)
        }
    end

    def scalar?
      false
    end

    def integer?
      false
    end

    def floating?
      false
    end

    def array?
      false
    end

    def pointer?
      false
    end

    def qualified?
      false
    end

    def function?
      false
    end

    def enum?
      false
    end

    def user?
      false
    end

    def void?
      false
    end

    def standard?
      false
    end

    def undeclared?
      @members.any? { |memb| memb.type.undeclared? }
    end

    def unresolved?
      @members.any? { |memb| memb.type.unresolved? }
    end

    def const?
      false
    end

    def volatile?
      false
    end

    def restrict?
      false
    end

    def bitfield?
      false
    end

    def signed?
      false
    end

    def explicitly_signed?
      false
    end

    def have_va_list?
      false
    end

    def return_type
      nil
    end

    def parameter_types
      []
    end

    def enumerators
      []
    end

    def length
      0
    end

    def impl_length
      0
    end

    def member_named(name)
      # FIXME: Should use the member name index.
      @members.find { |memb| memb.name == name }
    end

    def min
      0
    end

    def max
      0
    end

    def nil_value
      CompositeValue.new(@members.map { |memb| memb.type.nil_value })
    end

    def zero_value
      CompositeValue.new(@members.map { |memb| memb.type.zero_value })
    end

    def arbitrary_value
      CompositeValue.new(@members.map { |memb| memb.type.arbitrary_value })
    end

    def undefined_value
      CompositeValue.new(@members.map { |memb| memb.type.undefined_value })
    end

    def parameter_value
      CompositeValue.new(@members.map { |memb| memb.type.parameter_value })
    end

    def return_value
      CompositeValue.new(@members.map { |memb| memb.type.return_value })
    end

    def coerce_scalar_value(val)
      # NOTE: Cannot coerce scalar value into composite in C language.
      undefined_value # NOTREACHED
    end

    def coerce_array_value(val)
      # NOTE: Cannot coerce array value into composite in C language.
      undefined_value # NOTREACHED
    end

    def coerce_composite_value(val)
      vals = @members.zip(val.values).map { |memb, v|
        v ? v.coerce_to(memb.type) : memb.type.undefined_value
      }
      CompositeValue.new(vals)
    end

    def integer_conversion_rank
      0 # NOTREACHED
    end

    def integer_promoted_type
      self # NOTREACHED
    end

    def argument_promoted_type
      self
    end

    def arithmetic_type_with(type)
      subclass_responsibility
    end

    def _arithmetic_type_with_undeclared(lhs_type, rhs_type = self)
      rhs_type.arithmetic_type_with(lhs_type)
    end

    def _arithmetic_type_with_unresolved(lhs_type, rhs_type = self)
      rhs_type.arithmetic_type_with(lhs_type)
    end

    def _arithmetic_type_with_void(lhs_type, rhs_type = self)
      rhs_type.arithmetic_type_with(lhs_type)
    end

    def _arithmetic_type_with_function(lhs_type, rhs_type = self)
      rhs_type.arithmetic_type_with(lhs_type)
    end

    def _arithmetic_type_with_char(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with CompositeDataType must not be
      #       executed!
      # NOTE: Binary operation with `char' and CompositeDataType makes
      #       integer-promoted type of `char'.
      lhs_type.integer_promoted_type # NOTREACHED
    end

    def _arithmetic_type_with_signed_char(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with CompositeDataType must not be
      #       executed!
      # NOTE: Binary operation with `signed char' and CompositeDataType makes
      #       integer-promoted type of `signed char'.
      lhs_type.integer_promoted_type # NOTREACHED
    end

    def _arithmetic_type_with_unsigned_char(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with CompositeDataType must not be
      #       executed!
      # NOTE: Binary operation with `unsigned char' and CompositeDataType makes
      #       integer-promoted type of `unsigned char'.
      lhs_type.integer_promoted_type # NOTREACHED
    end

    def _arithmetic_type_with_short(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with CompositeDataType must not be
      #       executed!
      # NOTE: Binary operation with `short' and CompositeDataType makes
      #       integer-promoted type of `short'.
      lhs_type.integer_promoted_type # NOTREACHED
    end

    def _arithmetic_type_with_signed_short(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with CompositeDataType must not be
      #       executed!
      # NOTE: Binary operation with `signed short' and CompositeDataType makes
      #       integer-promoted type of `signed short'.
      lhs_type.integer_promoted_type # NOTREACHED
    end

    def _arithmetic_type_with_unsigned_short(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with CompositeDataType must not be
      #       executed!
      # NOTE: Binary operation with `unsigned short' and CompositeDataType
      #       makes integer-promoted type of `unsigned short'.
      lhs_type.integer_promoted_type # NOTREACHED
    end

    def _arithmetic_type_with_short_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with CompositeDataType must not be
      #       executed!
      # NOTE: Binary operation with `short int' and CompositeDataType makes
      #       integer-promoted type of `short int'.
      lhs_type.integer_promoted_type # NOTREACHED
    end

    def _arithmetic_type_with_signed_short_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with CompositeDataType must not be
      #       executed!
      # NOTE: Binary operation with `signed short int' and CompositeDataType
      #       makes integer-promoted type of `signed short int'.
      lhs_type.integer_promoted_type # NOTREACHED
    end

    def _arithmetic_type_with_unsigned_short_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with CompositeDataType must not be
      #       executed!
      # NOTE: Binary operation with `unsigned short int' and CompositeDataType
      #       makes integer-promoted type of `unsigned short int'.
      lhs_type.integer_promoted_type # NOTREACHED
    end

    def _arithmetic_type_with_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with CompositeDataType must not be
      #       executed!
      # NOTE: Binary operation with `int' and CompositeDataType makes `int'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_signed(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with CompositeDataType must not be
      #       executed!
      # NOTE: Binary operation with `signed' and CompositeDataType makes
      #       `signed'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_signed_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with CompositeDataType must not be
      #       executed!
      # NOTE: Binary operation with `signed int' and CompositeDataType makes
      #       `signed int'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_unsigned(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with CompositeDataType must not be
      #       executed!
      # NOTE: Binary operation with `unsigned' and CompositeDataType makes
      #       `unsigned'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_unsigned_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with CompositeDataType must not be
      #       executed!
      # NOTE: Binary operation with `unsigned int' and CompositeDataType makes
      #       `unsigned int'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_long(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with CompositeDataType must not be
      #       executed!
      # NOTE: Binary operation with `long' and CompositeDataType makes `long'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_signed_long(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with CompositeDataType must not be
      #       executed!
      # NOTE: Binary operation with `signed long' and CompositeDataType makes
      #       `signed long'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_unsigned_long(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with CompositeDataType must not be
      #       executed!
      # NOTE: Binary operation with `unsigned long' and CompositeDataType makes
      #       `unsigned long'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_long_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with CompositeDataType must not be
      #       executed!
      # NOTE: Binary operation with `long int' and CompositeDataType makes
      #       `long int'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_signed_long_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with CompositeDataType must not be
      #       executed!
      # NOTE: Binary operation with `signed long int' and CompositeDataType
      #       makes `signed long int'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_unsigned_long_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with CompositeDataType must not be
      #       executed!
      # NOTE: Binary operation with `unsigned long int' and CompositeDataType
      #       makes `unsigned long int'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_long_long(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with CompositeDataType must not be
      #       executed!
      # NOTE: Binary operation with `long long' and CompositeDataType makes
      #       `long long'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_signed_long_long(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with CompositeDataType must not be
      #       executed!
      # NOTE: Binary operation with `signed long long' and CompositeDataType
      #       makes `signed long long'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_unsigned_long_long(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with CompositeDataType must not be
      #       executed!
      # NOTE: Binary operation with `unsigned long long' and CompositeDataType
      #       makes `unsigned long long'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_long_long_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with CompositeDataType must not be
      #       executed!
      # NOTE: Binary operation with `long long int' and CompositeDataType makes
      #       `long long int'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_signed_long_long_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with CompositeDataType must not be
      #       executed!
      # NOTE: Binary operation with `signed long long int' and
      #       CompositeDataType makes `signed long long int'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_unsigned_long_long_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with CompositeDataType must not be
      #       executed!
      # NOTE: Binary operation with `unsigned long long int' and
      #       CompositeDataType makes `unsigned long long int'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_float(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with CompositeDataType must not be
      #       executed!
      # NOTE: Binary operation with `float' and CompositeDataType makes
      #       `float'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_double(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with CompositeDataType must not be
      #       executed!
      # NOTE: Binary operation with `double' and CompositeDataType makes
      #       `double'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_long_double(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with CompositeDataType must not be
      #       executed!
      # NOTE: Binary operation with `long double' and CompositeDataType makes
      #       `long double'.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_bitfield(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with CompositeDataType must not be
      #       executed!
      # NOTE: Binary operation with BitfieldType and CompositeDataType makes
      #       integer-promoted type of BitfieldType.
      lhs_type.integer_promoted_type # NOTREACHED
    end

    def _arithmetic_type_with_enum(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with CompositeDataType must not be
      #       executed!
      # NOTE: Binary operation with EnumType and CompositeDataType makes
      #       EnumType.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_pointer(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with CompositeDataType must not be
      #       executed!
      # NOTE: Binary operation with PointerType and CompositeDataType makes
      #       PointerType.
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_array(lhs_type, rhs_type = self)
      rhs_type.arithmetic_type_with(lhs_type)
    end

    def _arithmetic_type_with_struct(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with CompositeDataType must not be
      #       executed!
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_union(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with CompositeDataType must not be
      #       executed!
      lhs_type # NOTREACHED
    end

    def _arithmetic_type_with_extended_big_int(lhs_type, rhs_type = self)
      # NOTE: An arithmetic operation with CompositeDataType must not be
      #       executed!
      # NOTE: Binary operation with ExtendedBigIntType and CompositeDataType
      #       makes ExtendedBigIntType.
      lhs_type # NOTREACHED
    end

    def corresponding_signed_type
      self # NOTREACHED
    end

    def corresponding_unsigned_type
      self # NOTREACHED
    end

    def dup
      self.class.new(type_table, declarations.first,
                     @members.map { |memb| memb.dup })
    end
  end

  class Member
    def initialize(name, type)
      @name = name
      @type = type
    end

    attr_reader :name
    attr_reader :type

    def dup
      Member.new(@name, @type.dup)
    end
  end

  class StructType < CompositeDataType
    def initialize(type_tbl, type_dcl, membs)
      super(type_tbl, type_dcl.identifier.value, [type_dcl], membs)
      @image = type_dcl.struct_specifier.to_s
      @location = type_dcl.location
    end

    attr_accessor :image
    attr_accessor :location

    def id
      @id ||= StructTypeId.new(name)
    end

    def brief_image
      "struct #{name}"
    end

    def struct?
      true
    end

    def union?
      false
    end

    def arithmetic_type_with(type)
      type._arithmetic_type_with_struct(self)
    end
  end

  class StructTypeId < TypeId
    def initialize(name)
      super("struct #{name}")
    end
  end

  class UnionType < CompositeDataType
    # TODO: Must implement member overlapping semantics.

    def initialize(type_tbl, type_dcl, membs)
      super(type_tbl, type_dcl.identifier.value, [type_dcl], membs)
      @image = type_dcl.union_specifier.to_s
      @location = type_dcl.location
    end

    attr_accessor :image
    attr_accessor :location

    def id
      @id ||= UnionTypeId.new(name)
    end

    def brief_image
      "union #{name}"
    end

    def struct?
      false
    end

    def union?
      true
    end

    def arithmetic_type_with(type)
      type._arithmetic_type_with_union(self)
    end
  end

  class UnionTypeId < TypeId
    def initialize(name)
      super("union #{name}")
    end
  end

  class UserType < Type
    include Scopeable

    def initialize(type_tbl, typedef_dcl, base_type)
      super(type_tbl, typedef_dcl.identifier.value, [typedef_dcl])
      @location = typedef_dcl.location
      @base_type = base_type
    end

    attr_reader :location

    def id
      @id ||= UserTypeId.new(name)
    end

    extend Forwardable

    def_delegator :@base_type, :image

    def brief_image
      name
    end

    def_delegator :@base_type, :bit_size
    def_delegator :@base_type, :bit_alignment
    def_delegator :@base_type, :real_type
    def_delegator :@base_type, :base_type

    def unqualify
      self
    end

    def_delegator :@base_type, :incomplete?
    def_delegator :@base_type, :compatible?
    def_delegator :@base_type, :coercible?
    def_delegator :@base_type, :scalar?
    def_delegator :@base_type, :integer?
    def_delegator :@base_type, :floating?
    def_delegator :@base_type, :array?
    def_delegator :@base_type, :struct?
    def_delegator :@base_type, :union?
    def_delegator :@base_type, :pointer?
    def_delegator :@base_type, :qualified?
    def_delegator :@base_type, :function?
    def_delegator :@base_type, :enum?

    def user?
      true
    end

    def_delegator :@base_type, :void?

    def standard?
      false
    end

    def_delegator :@base_type, :undeclared?
    def_delegator :@base_type, :unresolved?
    def_delegator :@base_type, :const?
    def_delegator :@base_type, :volatile?
    def_delegator :@base_type, :restrict?
    def_delegator :@base_type, :bitfield?
    def_delegator :@base_type, :signed?
    def_delegator :@base_type, :explicitly_signed?
    def_delegator :@base_type, :have_va_list?
    def_delegator :@base_type, :return_type
    def_delegator :@base_type, :parameter_types
    def_delegator :@base_type, :enumerators
    def_delegator :@base_type, :length
    def_delegator :@base_type, :length=
    def_delegator :@base_type, :impl_length
    def_delegator :@base_type, :members
    def_delegator :@base_type, :member_named
    def_delegator :@base_type, :min
    def_delegator :@base_type, :max
    def_delegator :@base_type, :nil_value
    def_delegator :@base_type, :zero_value
    def_delegator :@base_type, :arbitrary_value
    def_delegator :@base_type, :undefined_value
    def_delegator :@base_type, :parameter_value
    def_delegator :@base_type, :return_value
    def_delegator :@base_type, :coerce_scalar_value
    def_delegator :@base_type, :coerce_array_value
    def_delegator :@base_type, :coerce_composite_value
    def_delegator :@base_type, :integer_conversion_rank
    def_delegator :@base_type, :integer_promoted_type
    def_delegator :@base_type, :argument_promoted_type

    def_delegator :@base_type, :arithmetic_type_with
    def_delegator :@base_type, :_arithmetic_type_with_undeclared
    def_delegator :@base_type, :_arithmetic_type_with_unresolved
    def_delegator :@base_type, :_arithmetic_type_with_void
    def_delegator :@base_type, :_arithmetic_type_with_function
    def_delegator :@base_type, :_arithmetic_type_with_char
    def_delegator :@base_type, :_arithmetic_type_with_signed_char
    def_delegator :@base_type, :_arithmetic_type_with_unsigned_char
    def_delegator :@base_type, :_arithmetic_type_with_short
    def_delegator :@base_type, :_arithmetic_type_with_signed_short
    def_delegator :@base_type, :_arithmetic_type_with_unsigned_short
    def_delegator :@base_type, :_arithmetic_type_with_short_int
    def_delegator :@base_type, :_arithmetic_type_with_signed_short_int
    def_delegator :@base_type, :_arithmetic_type_with_unsigned_short_int
    def_delegator :@base_type, :_arithmetic_type_with_int
    def_delegator :@base_type, :_arithmetic_type_with_signed
    def_delegator :@base_type, :_arithmetic_type_with_signed_int
    def_delegator :@base_type, :_arithmetic_type_with_unsigned
    def_delegator :@base_type, :_arithmetic_type_with_unsigned_int
    def_delegator :@base_type, :_arithmetic_type_with_long
    def_delegator :@base_type, :_arithmetic_type_with_signed_long
    def_delegator :@base_type, :_arithmetic_type_with_unsigned_long
    def_delegator :@base_type, :_arithmetic_type_with_long_int
    def_delegator :@base_type, :_arithmetic_type_with_signed_long_int
    def_delegator :@base_type, :_arithmetic_type_with_unsigned_long_int
    def_delegator :@base_type, :_arithmetic_type_with_long_long
    def_delegator :@base_type, :_arithmetic_type_with_signed_long_long
    def_delegator :@base_type, :_arithmetic_type_with_unsigned_long_long
    def_delegator :@base_type, :_arithmetic_type_with_long_long_int
    def_delegator :@base_type, :_arithmetic_type_with_signed_long_long_int
    def_delegator :@base_type, :_arithmetic_type_with_unsigned_long_long_int
    def_delegator :@base_type, :_arithmetic_type_with_float
    def_delegator :@base_type, :_arithmetic_type_with_double
    def_delegator :@base_type, :_arithmetic_type_with_long_double
    def_delegator :@base_type, :_arithmetic_type_with_bitfield
    def_delegator :@base_type, :_arithmetic_type_with_enum
    def_delegator :@base_type, :_arithmetic_type_with_pointer
    def_delegator :@base_type, :_arithmetic_type_with_array
    def_delegator :@base_type, :_arithmetic_type_with_struct
    def_delegator :@base_type, :_arithmetic_type_with_union
    def_delegator :@base_type, :_arithmetic_type_with_extended_big_int

    def_delegator :@base_type, :corresponding_signed_type
    def_delegator :@base_type, :corresponding_unsigned_type

    def dup
      UserType.new(type_table, declarations.first, @base_type.dup)
    end
  end

  class UserTypeId < TypeId
    def initialize(name)
      super("typedef #{name}")
    end
  end

  # NOTE: ParameterType is a decorator which attaches a parameter name to other
  #       types.
  class ParameterType < Type
    include Scopeable

    def initialize(type_tbl, type, dcl_or_def = nil)
      super(type_tbl, type.name, type.declarations)
      @type = type

      if dcl_or_def and dcr = dcl_or_def.declarator
        identifier = dcr.identifier
      end

      @param_name = identifier ? identifier.value : ""
      @declaration_or_definition = dcl_or_def
    end

    attr_reader :type
    attr_reader :param_name

    extend Forwardable

    def_delegator :@type, :id

    def location
      @declaration_or_definition ?
        @declaration_or_definition.location : @type.location
    end

    def_delegator :@type, :image
    def_delegator :@type, :brief_image
    def_delegator :@type, :bit_size
    def_delegator :@type, :bit_alignment

    def real_type
      ParameterType.new(type_table, @type.real_type,
                        @declaration_or_definition)
    end

    def_delegator :@type, :base_type
    def_delegator :@type, :unqualify

    def_delegator :@type, :incomplete?
    def_delegator :@type, :compatible?
    def_delegator :@type, :coercible?
    def_delegator :@type, :convertible?
    def_delegator :@type, :more_cv_qualified?

    def parameter?
      true
    end

    def_delegator :@type, :scalar?
    def_delegator :@type, :integer?
    def_delegator :@type, :floating?
    def_delegator :@type, :array?
    def_delegator :@type, :struct?
    def_delegator :@type, :union?
    def_delegator :@type, :pointer?
    def_delegator :@type, :qualified?
    def_delegator :@type, :function?
    def_delegator :@type, :enum?
    def_delegator :@type, :user?
    def_delegator :@type, :void?
    def_delegator :@type, :standard?
    def_delegator :@type, :undeclared?
    def_delegator :@type, :unresolved?
    def_delegator :@type, :const?
    def_delegator :@type, :volatile?
    def_delegator :@type, :restrict?
    def_delegator :@type, :bitfield?
    def_delegator :@type, :signed?
    def_delegator :@type, :explicitly_signed?
    def_delegator :@type, :have_va_list?
    def_delegator :@type, :return_type
    def_delegator :@type, :parameter_types
    def_delegator :@type, :enumerators
    def_delegator :@type, :length
    def_delegator :@type, :length=
    def_delegator :@type, :impl_length
    def_delegator :@type, :members
    def_delegator :@type, :member_named
    def_delegator :@type, :min
    def_delegator :@type, :max
    def_delegator :@type, :nil_value
    def_delegator :@type, :zero_value
    def_delegator :@type, :arbitrary_value
    def_delegator :@type, :undefined_value
    def_delegator :@type, :parameter_value
    def_delegator :@type, :return_value
    def_delegator :@type, :coerce_scalar_value
    def_delegator :@type, :coerce_array_value
    def_delegator :@type, :coerce_composite_value
    def_delegator :@type, :integer_conversion_rank
    def_delegator :@type, :integer_promoted_type
    def_delegator :@type, :argument_promoted_type

    def_delegator :@type, :arithmetic_type_with
    def_delegator :@type, :_arithmetic_type_with_undeclared
    def_delegator :@type, :_arithmetic_type_with_unresolved
    def_delegator :@type, :_arithmetic_type_with_void
    def_delegator :@type, :_arithmetic_type_with_function
    def_delegator :@type, :_arithmetic_type_with_char
    def_delegator :@type, :_arithmetic_type_with_signed_char
    def_delegator :@type, :_arithmetic_type_with_unsigned_char
    def_delegator :@type, :_arithmetic_type_with_short
    def_delegator :@type, :_arithmetic_type_with_signed_short
    def_delegator :@type, :_arithmetic_type_with_unsigned_short
    def_delegator :@type, :_arithmetic_type_with_short_int
    def_delegator :@type, :_arithmetic_type_with_signed_short_int
    def_delegator :@type, :_arithmetic_type_with_unsigned_short_int
    def_delegator :@type, :_arithmetic_type_with_int
    def_delegator :@type, :_arithmetic_type_with_signed
    def_delegator :@type, :_arithmetic_type_with_signed_int
    def_delegator :@type, :_arithmetic_type_with_unsigned
    def_delegator :@type, :_arithmetic_type_with_unsigned_int
    def_delegator :@type, :_arithmetic_type_with_long
    def_delegator :@type, :_arithmetic_type_with_signed_long
    def_delegator :@type, :_arithmetic_type_with_unsigned_long
    def_delegator :@type, :_arithmetic_type_with_long_int
    def_delegator :@type, :_arithmetic_type_with_signed_long_int
    def_delegator :@type, :_arithmetic_type_with_unsigned_long_int
    def_delegator :@type, :_arithmetic_type_with_long_long
    def_delegator :@type, :_arithmetic_type_with_signed_long_long
    def_delegator :@type, :_arithmetic_type_with_unsigned_long_long
    def_delegator :@type, :_arithmetic_type_with_long_long_int
    def_delegator :@type, :_arithmetic_type_with_signed_long_long_int
    def_delegator :@type, :_arithmetic_type_with_unsigned_long_long_int
    def_delegator :@type, :_arithmetic_type_with_float
    def_delegator :@type, :_arithmetic_type_with_double
    def_delegator :@type, :_arithmetic_type_with_long_double
    def_delegator :@type, :_arithmetic_type_with_bitfield
    def_delegator :@type, :_arithmetic_type_with_enum
    def_delegator :@type, :_arithmetic_type_with_pointer
    def_delegator :@type, :_arithmetic_type_with_array
    def_delegator :@type, :_arithmetic_type_with_struct
    def_delegator :@type, :_arithmetic_type_with_union
    def_delegator :@type, :_arithmetic_type_with_extended_big_int

    def_delegator :@type, :corresponding_signed_type
    def_delegator :@type, :corresponding_unsigned_type

    def dup
      ParameterType.new(type_table, @type.dup, @declaration_or_definition)
    end
  end

  class ExtendedBigIntType < IntegerType
    def initialize(type_tbl)
      super(type_tbl, "__adlint__extended_bigint_t", 256, 256, true, true)
    end

    def id
      @id ||= TypeId.new(name)
    end

    def incomplete?
      false
    end

    def pointer?
      false
    end

    def enum?
      false
    end

    def standard?
      false
    end

    def bitfield?
      false
    end

    def enumerators
      []
    end

    def integer_conversion_rank
      # NOTE: The ISO C99 standard says;
      #
      # 6.3.1 Arithmetic operands
      # 6.3.1.1 Boolean, characters, and integers
      #
      # 1 Every integer type has an integer conversion rank defined as follows:
      #
      #     -- No two signed integer types shall have the same rank, even if
      #        they have the same representation.
      #     -- The rank of a signed integer type shall be greater than the rank
      #        of any signed integer type with less precision.
      #     -- The rank of long long int shall be greater than the rank of long
      #        int, which shall be greater than the rank of int, which shall be
      #        greater than the rank of short int, which shall be greater than
      #        the rank of signed char.
      #     -- The rank of any unsigned integer type shall equal the rank of
      #        the corresponding signed integer type, if any.
      #     -- The rank of any standard integer type shall be greater than the
      #        rank of any extended integer type with the same width.
      #     -- The rank of char shall equal the rank of signed char and
      #        unsigned char.
      #     -- The rank of _Bool shall be less than the rank of all other
      #        standard integer types.
      #     -- The rank of any enumerated type shall equal the rank of the
      #        compatible integer type.
      #     -- The rank of any extended signed integer type relative to another
      #        extended signed integer type with the same precision is
      #        implementation-defined, but still subject to the other rules for
      #        determining the integer conversion rank.
      #     -- For all integer types T1, T2, and T3, if T1 has greater rank
      #        than T2 and T2 has greater rank than T3, then T1 has greater
      #        rank than T3.
      -2
    end

    def integer_promoted_type
      # NOTE: ExtendedBigIntType is very big integer.
      #       So, it is not compatible with int or unsigned int.
      self
    end

    def arithmetic_type_with(type)
      type._arithmetic_type_with_extended_big_int(self)
    end

    def corresponding_signed_type
      self
    end

    def corresponding_unsigned_type
      self
    end

    def dup
      ExtendedBigIntType.new(type_table)
    end
  end

  class StandardTypeCatalog
    def initialize(type_tbl)
      @types = {}

      install_char_t_family(type_tbl)
      install_short_t_family(type_tbl)
      install_int_t_family(type_tbl)
      install_long_t_family(type_tbl)
      install_long_long_t_family(type_tbl)

      install_float_t(type_tbl)
      install_double_t(type_tbl)
      install_long_double_t(type_tbl)

      install_void_t(type_tbl)
      install_extended_bit_int_t(type_tbl)
    end

    attr_reader :char_t
    attr_reader :signed_char_t
    attr_reader :unsigned_char_t
    attr_reader :short_t
    attr_reader :signed_short_t
    attr_reader :unsigned_short_t
    attr_reader :short_int_t
    attr_reader :signed_short_int_t
    attr_reader :unsigned_short_int_t
    attr_reader :int_t
    attr_reader :signed_t
    attr_reader :signed_int_t
    attr_reader :unsigned_t
    attr_reader :unsigned_int_t
    attr_reader :long_t
    attr_reader :signed_long_t
    attr_reader :unsigned_long_t
    attr_reader :long_int_t
    attr_reader :signed_long_int_t
    attr_reader :unsigned_long_int_t
    attr_reader :long_long_t
    attr_reader :signed_long_long_t
    attr_reader :unsigned_long_long_t
    attr_reader :long_long_int_t
    attr_reader :signed_long_long_int_t
    attr_reader :unsigned_long_long_int_t
    attr_reader :float_t
    attr_reader :double_t
    attr_reader :long_double_t
    attr_reader :void_t
    attr_reader :extended_big_int_t

    def lookup_by_type_specifiers(type_specs)
      type_name = type_specs.map { |ts| ts.to_s }.sort.join(" ")
      @types[type_name]
    end

    def all_types
      @types.each_value
    end

    private
    def install_char_t_family(type_tbl)
      install @char_t          = CharType.new(type_tbl)
      install @signed_char_t   = SignedCharType.new(type_tbl)
      install @unsigned_char_t = UnsignedCharType.new(type_tbl)
    end

    def install_short_t_family(type_tbl)
      install @short_t              = ShortType.new(type_tbl)
      install @signed_short_t       = SignedShortType.new(type_tbl)
      install @unsigned_short_t     = UnsignedShortType.new(type_tbl)
      install @short_int_t          = ShortIntType.new(type_tbl)
      install @signed_short_int_t   = SignedShortIntType.new(type_tbl)
      install @unsigned_short_int_t = UnsignedShortIntType.new(type_tbl)
    end

    def install_int_t_family(type_tbl)
      install @int_t          = IntType.new(type_tbl)
      install @signed_t       = SignedType.new(type_tbl)
      install @signed_int_t   = SignedIntType.new(type_tbl)
      install @unsigned_t     = UnsignedType.new(type_tbl)
      install @unsigned_int_t = UnsignedIntType.new(type_tbl)
    end

    def install_long_t_family(type_tbl)
      install @long_t              = LongType.new(type_tbl)
      install @signed_long_t       = SignedLongType.new(type_tbl)
      install @unsigned_long_t     = UnsignedLongType.new(type_tbl)
      install @long_int_t          = LongIntType.new(type_tbl)
      install @signed_long_int_t   = SignedLongIntType.new(type_tbl)
      install @unsigned_long_int_t = UnsignedLongIntType.new(type_tbl)
    end

    def install_long_long_t_family(type_tbl)
      install @long_long_t              = LongLongType.new(type_tbl)
      install @signed_long_long_t       = SignedLongLongType.new(type_tbl)
      install @unsigned_long_long_t     = UnsignedLongLongType.new(type_tbl)
      install @long_long_int_t          = LongLongIntType.new(type_tbl)
      install @signed_long_long_int_t   = SignedLongLongIntType.new(type_tbl)
      install @unsigned_long_long_int_t = UnsignedLongLongIntType.new(type_tbl)
    end

    def install_float_t(type_tbl)
      install @float_t = FloatType.new(type_tbl)
    end

    def install_double_t(type_tbl)
      install @double_t = DoubleType.new(type_tbl)
    end

    def install_long_double_t(type_tbl)
      install @long_double_t = LongDoubleType.new(type_tbl)
    end

    def install_void_t(type_tbl)
      install @void_t = VoidType.new(type_tbl)
    end

    def install_extended_bit_int_t(type_tbl)
      install @extended_big_int_t = ExtendedBigIntType.new(type_tbl)
    end

    def install(type)
      @types[type.name.split(" ").sort.join(" ")] = type
    end
  end

  class TypeTable
    include StandardTypeCatalogAccessor
    include InterpreterOptions

    def initialize(traits, monitor, logger)
      @traits         = traits
      @monitor        = monitor
      @logger         = logger
      @types_stack    = [{}]
      @scope_stack    = [GlobalScope.new]
      @all_type_names = Set.new

      @standard_type_catalog = StandardTypeCatalog.new(self)
      install_standard_types
    end

    attr_reader :traits
    attr_reader :monitor
    attr_reader :logger
    attr_reader :standard_type_catalog
    attr_reader :all_type_names

    def undeclared_type
      @undeclared_type ||= UndeclaredType.new(self)
    end

    def unresolved_type
      @unresolved_type ||= UnresolvedType.new(self)
    end

    def wchar_t
      lookup(UserTypeId.new("wchar_t")) or int_t
    end

    def array_type(base_type, len = nil)
      ArrayType.new(self, base_type, len)
    end

    def function_type(retn_type, param_types, have_va_list = false)
      FunctionType.new(self, retn_type, param_types, have_va_list)
    end

    def builtin_function_type
      function_type(undeclared_type, [undeclared_type])
    end

    def bitfield_type(base_type, field_width)
      BitfieldType.new(self, base_type, field_width)
    end

    def pointer_type(base_type)
      PointerType.new(self, base_type)
    end

    def qualified_type(base_type, *cvr_quals)
      QualifiedType.new(self, base_type, *cvr_quals)
    end

    def lookup(type_id)
      @types_stack.reverse_each { |hash| type = hash[type_id] and return type }
      nil
    end

    def lookup_standard_type(name_str)
      @standard_type_catalog.lookup_by_name(name_str)
    end

    def install(type)
      @types_stack.last[type.id] = type
      @all_type_names.add(type.name)
      type
    end

    def enter_scope
      @types_stack.push({})
      @scope_stack.push(Scope.new(@scope_stack.size))
    end

    def leave_scope
      @types_stack.pop
      @scope_stack.pop
    end

    def lookup_or_install_type(type_quals, type_specs, dcr, interp = nil)
      case fst_type_spec = type_specs.first
      when TypeofTypeSpecifier
        if type_name = fst_type_spec.type_name
          return type_name.type
        else
          if interp
            return interp.execute(fst_type_spec.expression, QUIET).type
          else
            return nil
          end
        end
      else
        unless base_type = lookup_type(type_specs, interp)
          case fst_type_spec
          when StructSpecifier
            base_type = install_struct_type(
              PseudoStructTypeDeclaration.new(fst_type_spec))
          when UnionSpecifier
            base_type = install_union_type(
              PseudoUnionTypeDeclaration.new(fst_type_spec))
          when EnumSpecifier
            base_type = install_enum_type(
              PseudoEnumTypeDeclaration.new(fst_type_spec))
          else
            return nil
          end
        end
        qualify_type(base_type, type_quals, dcr, interp)
      end
    end

    def lookup_type(type_specs, interp = nil)
      lookup(create_type_id(type_specs, interp))
    end

    def lookup_function_type(fun_def, interp = nil)
      if dcl_specs = fun_def.declaration_specifiers
        type = lookup_or_install_type(dcl_specs.type_qualifiers,
                                      dcl_specs.type_specifiers,
                                      fun_def.declarator, interp)
      else
        type = lookup_or_install_type([], [], fun_def.declarator, interp)
      end

      return nil unless type

      param_types = fun_def.parameter_definitions.map { |pdef| pdef.type }
      function_type(type.return_type, param_types, type.have_va_list?)
    end

    def lookup_parameter_type(dcl_or_def, interp = nil)
      dcr = dcl_or_def.declarator
      dcl_specs = dcl_or_def.declaration_specifiers

      if dcl_specs
        type_quals = dcl_specs.type_qualifiers
        type_specs = dcl_specs.type_specifiers
      else
        type_quals = []
        type_specs = []
      end

      if type = lookup_or_install_type(type_quals, type_specs, dcr, interp)
        type = pointer_type(type) if type.function?
      else
        return nil
      end

      ParameterType.new(self, type, dcl_or_def)
    end

    def install_struct_type(type_dcl)
      type_id = StructTypeId.new(type_dcl.identifier.value)

      if type = lookup(type_id) and type.scope == current_scope
        if type_dcl.struct_declarations
          rewrite_struct_type(type, type_dcl)
          return type
        end
      end

      type = StructType.new(self, type_dcl, [])
      type.scope = current_scope
      install(type)
      if type_dcl.struct_declarations
        rewrite_struct_type(type, type_dcl)
      end
      type
    end

    def install_union_type(type_dcl)
      type_id = UnionTypeId.new(type_dcl.identifier.value)

      if type = lookup(type_id) and type.scope == current_scope
        if type_dcl.struct_declarations
          rewrite_union_type(type, type_dcl)
          return type
        end
      end

      type = UnionType.new(self, type_dcl, [])
      type.scope = current_scope
      install(type)
      if type_dcl.struct_declarations
        rewrite_union_type(type, type_dcl)
      end
      type
    end

    def install_enum_type(type_dcl)
      type_id = EnumTypeId.new(type_dcl.identifier.value)

      if type = lookup(type_id) and type.scope == current_scope
        if type_dcl.enumerators
          rewrite_enum_type(type, type_dcl)
          return type
        end
      end

      type = EnumType.new(self, type_dcl)
      type.scope = current_scope
      install(type)
      if type_dcl.enumerators
        rewrite_enum_type(type, type_dcl)
      end
      type
    end

    def install_user_type(type_dcl)
      base_type = lookup_or_install_type(type_dcl.type_qualifiers,
                                         type_dcl.type_specifiers,
                                         type_dcl.declarator)
      type = UserType.new(self, type_dcl, base_type)
      type.scope = current_scope
      install(type)
      type
    end

    private
    def create_type_id(type_specs, interp)
      case type_specs.first
      when StandardTypeSpecifier
        type_id = create_standard_type_id(type_specs)
      when TypedefTypeSpecifier
        type_id = create_user_type_id(type_specs)
      when StructSpecifier
        type_id = create_struct_type_id(type_specs)
      when UnionSpecifier
        type_id = create_union_type_id(type_specs)
      when EnumSpecifier
        type_id = create_enum_type_id(type_specs)
      when nil
        type_id = int_t.id
      else
        raise TypeError
      end
      type_id
    end

    def create_standard_type_id(type_specs)
      if type = @standard_type_catalog.lookup_by_type_specifiers(type_specs)
        type.id
      else
        int_t.id
      end
    end

    def create_user_type_id(type_specs)
      UserTypeId.new(type_specs.first.identifier.value)
    end

    def create_struct_type_id(type_specs)
      StructTypeId.new(type_specs.first.identifier.value)
    end

    def create_union_type_id(type_specs)
      UnionTypeId.new(type_specs.first.identifier.value)
    end

    def create_enum_type_id(type_specs)
      EnumTypeId.new(type_specs.first.identifier.value)
    end

    def qualify_type(type, type_quals, dcr, interp = nil)
      cvr_quals = type_quals.map { |tok|
        case tok.type
        when :CONST then :const
        when :VOLATILE then :volatile
        else
          # TODO: Should support C99 `restrict' qualifier.
        end
      }.compact
      type = qualified_type(type, *cvr_quals) unless cvr_quals.empty?

      if dcr
        dcr_interp = DeclaratorInterpreter.new(self, interp, type)
        dcr.accept(dcr_interp)
      else
        type
      end
    end

    def create_members(struct_dcls)
      membs = []
      struct_dcls.each do |struct_dcl|
        struct_dcl.items.each do |item|
          membs.push(Member.new(item.identifier.value, item.type))
        end
      end
      membs
    end

    def rewrite_struct_type(struct_type, type_dcl)
      struct_type.declarations.push(type_dcl)
      struct_type.image = type_dcl.struct_specifier.to_s
      struct_type.location = type_dcl.location
      struct_type.members.replace(create_members(type_dcl.struct_declarations))
    end

    def rewrite_union_type(union_type, type_dcl)
      union_type.declarations.push(type_dcl)
      union_type.image = type_dcl.union_specifier.to_s
      union_type.location = type_dcl.location
      union_type.members.replace(create_members(type_dcl.struct_declarations))
    end

    def rewrite_enum_type(enum_type, type_dcl)
      enum_type.declarations.push(type_dcl)
      enum_type.image = type_dcl.enum_specifier.to_s
      enum_type.location = type_dcl.location
    end

    def current_scope
      @scope_stack.last
    end

    def install_standard_types
      @standard_type_catalog.all_types.each { |type| install(type) }
    end
  end

  class DeclaratorInterpreter
    def initialize(type_tbl, interp, type)
      @type_table = type_tbl
      @interpreter = interp
      @type = type
    end

    def visit_identifier_declarator(node)
      @type = qualify_by_pointer(@type, node)
    end

    def visit_grouped_declarator(node)
      @type = qualify_by_pointer(@type, node)
      @type = node.base.accept(self)
    end

    def visit_array_declarator(node)
      @type = qualify_by_pointer(@type, node)
      if size_expr = node.size_expression
        if ary_size = evaluate_size_expression(size_expr)
          @type = @type_table.array_type(@type, ary_size)
        else
          return @type_table.unresolved_type
        end
      else
        @type = @type_table.array_type(@type)
      end
      @type = node.base.accept(self)
    end

    def visit_ansi_function_declarator(node)
      @type = qualify_by_pointer(@type, node)
      param_types = lookup_parameter_types(node)
      if param_types.include?(nil)
        return @type_table.unresolved_type
      else
        have_va_list = node.parameter_type_list.have_va_list?
        @type = @type_table.function_type(@type, param_types, have_va_list)
        @type = node.base.accept(self)
      end
      @type
    end

    def visit_kandr_function_declarator(node)
      @type = qualify_by_pointer(@type, node)
      @type = @type_table.function_type(@type, [])
      @type = node.base.accept(self)
    end

    def visit_abbreviated_function_declarator(node)
      @type = qualify_by_pointer(@type, node)
      @type = @type_table.function_type(@type, [])
      @type = node.base.accept(self)
    end

    def visit_pointer_abstract_declarator(node)
      @type = qualify_by_pointer(@type, node)
      @type = node.base.accept(self) if node.base
      @type
    end

    def visit_grouped_abstract_declarator(node)
      @type = qualify_by_pointer(@type, node)
      @type = node.base.accept(self)
    end

    def visit_array_abstract_declarator(node)
      @type = qualify_by_pointer(@type, node)
      if size_expr = node.size_expression
        if ary_size = evaluate_size_expression(size_expr)
          @type = @type_table.array_type(@type, ary_size)
        else
          return @type_table.unresolved_type
        end
      else
        @type = @type_table.array_type(@type)
      end
      @type = node.base.accept(self) if node.base
      @type
    end

    def visit_function_abstract_declarator(node)
      @type = qualify_by_pointer(@type, node)
      param_types = lookup_parameter_types(node)
      if param_types.include?(nil)
        return @type_table.unresolved_type
      else
        @type = @type_table.function_type(@type, param_types)
        @type = node.base.accept(self) if node.base
      end
      @type
    end

    private
    def qualify_by_pointer(type, dcr)
      if dcr.pointer
        dcr.pointer.each do |tok|
          case tok.type
          when "*"
            type = @type_table.pointer_type(type)
          when :CONST
            type = @type_table.qualified_type(type, :const)
          when :VOLATILE
            type = @type_table.qualified_type(type, :volatile)
          when :RESTRICT
            # TODO: Should support C99 features.
          end
        end
      end
      type
    end

    def lookup_parameter_types(dcr, interp = nil)
      if param_type_list = dcr.parameter_type_list
        param_type_list.parameters.map do |param_dcl|
          @type_table.lookup_parameter_type(param_dcl, @interpreter)
        end
      else
        []
      end
    end

    def evaluate_size_expression(size_expr)
      if @interpreter
        obj = @interpreter.execute(size_expr)
        if obj.variable? && obj.value.scalar?
          size = obj.value.unique_sample
        end
        # NOTE: Size of an array should be greater than 0.
        size = 1 if size.nil? || size <= 0
      else
        if size_expr.object_specifiers.empty?
          obj = Interpreter.new(@type_table).execute(size_expr)
          if obj.variable? && obj.value.scalar?
            size = obj.value.unique_sample
          end
          # NOTE: Size of an array should be greater than 0.
          size = 1 if size.nil? || size <= 0
        else
          size = nil
        end
      end
      size ? size.to_i : nil
    end
  end

  class TypeVisitor
    def visit_undeclared_type(type)
    end

    def visit_unresolved_type(type)
    end

    def visit_qualified_type(type)
      type.base_type.accept(self)
    end

    def visit_void_type(type)
    end

    def visit_function_type(type)
      type.return_type.accept(self)
      type.parameter_types.each { |param_type| param_type.accept(self) }
    end

    def visit_char_type(type)
    end

    def visit_signed_char_type(type)
    end

    def visit_unsigned_char_type(type)
    end

    def visit_short_type(type)
    end

    def visit_signed_short_type(type)
    end

    def visit_unsigned_short_type(type)
    end

    def visit_short_int_type(type)
    end

    def visit_signed_short_int_type(type)
    end

    def visit_unsigned_short_int_type(type)
    end

    def visit_int_type(type)
    end

    def visit_signed_type(type)
    end

    def visit_signed_int_type(type)
    end

    def visit_unsigned_type(type)
    end

    def visit_unsigned_int_type(type)
    end

    def visit_long_type(type)
    end

    def visit_signed_long_type(type)
    end

    def visit_unsigned_long_type(type)
    end

    def visit_long_int_type(type)
    end

    def visit_signed_long_int_type(type)
    end

    def visit_unsigned_long_int_type(type)
    end

    def visit_long_long_type(type)
    end

    def visit_signed_long_long_type(type)
    end

    def visit_unsigned_long_long_type(type)
    end

    def visit_long_long_int_type(type)
    end

    def visit_signed_long_long_int_type(type)
    end

    def visit_unsigned_long_long_int_type(type)
    end

    def visit_extended_big_int_type(type)
    end

    def visit_bitfield_type(type)
      type.base_type.accept(self)
    end

    def visit_enum_type(type)
    end

    def visit_pointer_type(type)
      type.base_type.accept(self)
    end

    def visit_float_type(type)
    end

    def visit_double_type(type)
    end

    def visit_long_double_type(type)
    end

    def visit_array_type(type)
      type.base_type.accept(self)
    end

    def visit_struct_type(type)
      type.members.each { |memb| memb.type.accept(self) }
    end

    def visit_union_type(type)
      type.members.each { |memb| memb.type.accept(self) }
    end

    def visit_user_type(type)
      type.real_type.accept(self)
    end

    def visit_parameter_type(type)
      type.type.accept(self)
    end
  end

end
end
