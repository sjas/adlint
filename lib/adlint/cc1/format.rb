# Format of the formatted input/output functions.
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

require "adlint/cc1/mediator"

module AdLint #:nodoc:
module Cc1 #:nodoc:

  class PrintfFormat
    def initialize(fmt_str, loc, trailing_args, env)
      @location = loc
      @directives = create_directives(fmt_str, trailing_args, env)
      @extra_arguments = trailing_args
    end

    attr_reader :location
    attr_reader :directives
    attr_reader :extra_arguments

    def conversion_specifiers
      @directives.select { |dire| dire.conversion_specifier? }
    end

    def min_length
      @directives.reduce(0) { |len, dire| len + dire.min_length }
    end

    def max_length
      @directives.reduce(0) { |len, dire| len + dire.max_length }
    end

    private
    def create_directives(fmt_str, trailing_args, env)
      dires = []
      str = fmt_str.dup
      until str.empty?
        dires.push(Directive.guess(str, trailing_args, env))
      end
      dires
    end

    # == DESCRIPTION
    # === Directive class hierarchy
    #  Directive
    #    <-- Ordinary
    #    <-- ConversionSpecifier
    #          <-- CompleteConversionSpecifier
    #                <-- NumberConversionSpecifier
    #                      <-- Conversion_d
    #                            <-- Conversion_i
    #                            <-- Conversion_o
    #                                  <-- Conversion_u
    #                                  <-- Conversion_x
    #                                  <-- Conversion_X
    #                      <-- Conversion_f
    #                            <-- Conversion_F
    #                            <-- Conversion_e
    #                            <-- Conversion_E
    #                            <-- Conversion_g
    #                            <-- Conversion_G
    #                            <-- Conversion_a
    #                            <-- Conversion_A
    #                      <-- Conversion_p
    #                <-- CharacterConversionSpecifier
    #                      <-- Conversion_c
    #                <-- StringConversionSpecifier
    #                      <-- Conversion_s
    #                <-- Conversion_n
    #                <-- Conversion_percent
    #                <-- UndefinedConversionSpecifier
    #          <-- IncompleteConversionSpecifier
    class Directive
      def self.guess(fmt_str, trailing_args, env)
        try_to_create_ordinary(fmt_str) or
        try_to_create_conversion_specifier(fmt_str, trailing_args, env)
      end

      def initialize(fmt, consume_args)
        @format = fmt
        @consume_arguments = consume_args
      end

      attr_reader :format

      def ordinary?
        !conversion_specifier?
      end

      def conversion_specifier?
        subclass_responsibility
      end

      def consume_arguments?
        @consume_arguments
      end

      # === DESCRIPTION
      # Checks whether types of arguments match this directive.
      #
      # === RETURN VALUE
      # Boolean -- True if types of arguments match this directive.
      def acceptable?
        subclass_responsibility
      end

      # === DESCRIPTION
      # Checks whether the format string of this directive is the ISO C99
      # compliant.
      #
      # === RETURN VALUE
      # Boolean -- True if the format string is wellformed.
      def wellformed?
        subclass_responsibility
      end

      def illformed?
        !wellformed?
      end

      def complete?
        subclass_responsibility
      end

      def incomplete?
        !complete?
      end

      def undefined?
        subclass_responsibility
      end

      def valid_flags?
        subclass_responsibility
      end

      def valid_field_width?
        subclass_responsibility
      end

      def valid_precision?
        subclass_responsibility
      end

      def valid_length_modifier?
        subclass_responsibility
      end

      def valid_conversion_specifier_character?
        subclass_responsibility
      end

      def min_length
        subclass_responsibility
      end

      def max_length
        subclass_responsibility
      end

      def flags
        subclass_responsibility
      end

      def field_width
        subclass_responsibility
      end

      def precision
        subclass_responsibility
      end

      def length_modifier
        subclass_responsibility
      end

      def conversion_specifier_character
        subclass_responsibility
      end

      def self.try_to_create_ordinary(fmt_str)
        (fmt = Ordinary.scan(fmt_str)) ? Ordinary.new(fmt) : nil
      end
      private_class_method :try_to_create_ordinary

      def self.try_to_create_conversion_specifier(fmt_str, trailing_args, env)
        fmt, flags, field_width, prec, len_mod, cs_char =
          ConversionSpecifier.scan(fmt_str)

        case
        when cs_char.nil?
          IncompleteConversionSpecifier.new(fmt, flags, field_width, prec,
                                            len_mod)
        when cs_class = CONVERSION_SPECIFIER_TBL[cs_char]
          cs_class.new(fmt, trailing_args, env, flags, field_width, prec,
                       len_mod, cs_char)
        else
          UndefinedConversionSpecifier.new(fmt, flags, field_width, prec,
                                           len_mod, cs_char)
        end
      end
      private_class_method :try_to_create_conversion_specifier
    end
    private_constant :Directive

    class Ordinary < Directive
      def self.scan(fmt_str)
        # NOTE: The ISO C99 standard says;
        #
        # 7.19.6.1 The fprintf function
        #
        # 3 The format shall be a multibyte character sequence, beginning and
        #   ending in its initial shift state.  The format is composed of zero
        #   or more directives: ordinary multibyte characters (not %), which
        #   are copied unchanged to the output stream; and conversion
        #   specifiers, each of which results in fetching zero or more
        #   subsequent arguments, converting them, if applicable, according to
        #   the corresponding conversion specifier, and then writing the result
        #   to the output stream.
        fmt_str.slice!(/\A[^%]+/)
      end

      def initialize(fmt)
        super(fmt, false)
      end

      def conversion_specifier?
        false
      end

      # === DESCRIPTION
      # Checks whether types of arguments match this directive.
      #
      # === RETURN VALUE
      # Boolean -- True if types of arguments match this directive.
      def acceptable?
        true
      end

      # === DESCRIPTION
      # Checks whether the format string of this directive is the ISO C99
      # compliant.
      #
      # === RETURN VALUE
      # Boolean -- True if the format string is wellformed.
      def wellformed?
        true
      end

      def complete?
        true
      end

      def undefined?
        false
      end

      def valid_flags?
        false
      end

      def valid_field_width?
        false
      end

      def valid_precision?
        false
      end

      def valid_length_modifier?
        false
      end

      def valid_conversion_specifier_character?
        false
      end

      def min_length
        format.bytes.count
      end

      def max_length
        min_length
      end

      def flags
        nil
      end

      def field_width
        nil
      end

      def precision
        nil
      end

      def length_modifier
        nil
      end

      def conversion_specifier_character
        nil
      end
    end
    private_constant :Ordinary

    class ConversionSpecifier < Directive
      include TypeTableMediator
      include MemoryPoolMediator

      def self.scan(fmt_str)
        # NOTE: The ISO C99 standard says;
        #
        # 7.19.6.1 The fprintf function
        #
        # 4 Each conversion specification is introduced by the character %.
        #   After the %, the following appear in sequence:
        #
        #   -- Zero or more flags (in any order) that modify the meaning of the
        #      conversion specification.
        #   -- An optional minimum field width.  If the converted value has
        #      fewer characters than the field width, it is padded with spaces
        #      (by default) on the left (or right, if the left adjustment flag,
        #      described later, has been given) to the field width.  The field
        #      width takes the form of an asterisk * (described later) or a
        #      nonnegative decimal integer.
        #   -- An optional precision that gives the minimum number of digits to
        #      appear for the d, i, o, u, x, and X conversions, the number of
        #      digits to appear after the decimal-point character for a, A, e,
        #      E, f, and F conversions, the maximum number of significant
        #      digits for the g and G conversions, or the maximum number of
        #      bytes to be written for s conversions.  The precision takes the
        #      form of a period (.) followed either by an asterisk * (described
        #      later) or by an optional decimal interger; if only the period is
        #      specified, the precision is taken as zero.  If a precision
        #      appears with any other conversion specifier, the behavior is
        #      undefined.
        #   -- An optional length modifier that specifies the size of the
        #      argument.
        #   -- A conversion specifier character that specifies the type of
        #      conversion to be applied.

        if header = fmt_str.slice!(/\A%/)
          scanned = header
        else
          return nil, nil, nil, nil, nil, nil
        end

        if flags = fmt_str.slice!(/\A#{flags_re}/)
          scanned += flags
        end

        if field_width = fmt_str.slice!(/\A#{field_width_re}/)
          scanned += field_width
        end

        if prec = fmt_str.slice!(/\A#{precision_re}/)
          scanned += prec
        end

        if len_mod = fmt_str.slice!(/\A#{length_modifier_re}/)
          scanned += len_mod
        end

        if cs_char = fmt_str.slice!(/\A#{cs_char_re}/)
          scanned += cs_char
        else
          # NOTE: If no valid conversion specifier character, force to scan
          #       the heading 1 character as a conversion specifier character.
          if cs_char = fmt_str.slice!(/\A[a-z]/i)
            scanned += cs_char
          end
        end

        return scanned, flags, field_width, prec, len_mod, cs_char
      end

      def initialize(fmt, trailing_args, env, consume_args, flags, field_width,
                     prec, len_mod, cs_char)
        super(fmt, consume_args)

        @flags = flags
        @field_width = field_width
        @precision = prec
        @length_modifier = len_mod
        @conversion_specifier_character = cs_char

        if consume_arguments? && @field_width == "*"
          @field_width_argument = trailing_args.shift
        else
          @field_width_argument = nil
        end

        if consume_arguments? && @precision == ".*"
          @precision_argument = trailing_args.shift
        else
          @precision_argument = nil
        end

        if consume_arguments?
          @conversion_argument = trailing_args.shift
        else
          @conversion_argument = nil
        end

        @environment = env
      end

      def conversion_specifier?
        true
      end

      def undefined?
        false
      end

      attr_reader :flags
      attr_reader :field_width
      attr_reader :precision
      attr_reader :length_modifier
      attr_reader :conversion_specifier_character
      attr_reader :field_width_argument
      attr_reader :precision_argument
      attr_reader :conversion_argument

      def field_width_value
        case @field_width
        when "*"
          # TODO: Should support the parameterized field width.
          1
        when /\A[1-9][0-9]*\z/
          @field_width.to_i
        else
          1
        end
      end

      def precision_value
        # NOTE: The ISO C99 standard says;
        #
        # 7.19.6.1 The fprintf function
        #
        # 4 Each conversion specification is introduced by the character %.
        #   After the %, the following appear in sequence:
        #
        #   -- An optional precision that gives the minimum number of digits to
        #      appear for the d, i, o, u, x, and X conversions, the number of
        #      digits to appear after the decimal-point character for a, A, e,
        #      E, f, and F conversions, the maximum number of significant
        #      digits for the g and G conversions, or the maximum number of
        #      bytes to be written for s conversions.  The precision takes the
        #      form of a period (.) followed either by an asterisk * (described
        #      later) or by an optional decimal interger; if only the period is
        #      specified, the precision is taken as zero.  If a precision
        #      appears with any other conversion specifier, the behavior is
        #      undefined.
        case @precision
        when "."
          0
        when ".*"
          # TODO: Should support the parameterized precision.
          default_precision_value
        when /\A\.([1-9][0-9]*)\z/
          $1.to_i
        else
          default_precision_value
        end
      end

      def self.flags_re
        # NOTE: The ISO C99 standard says;
        #
        # 7.19.6.1 The fprintf function
        #
        # 6 The flag characters and their meaning are:
        #
        #   -     The result of the conversion is left-justified within the
        #         field. (It is right-justified if this flag is not specified.)
        #   +     The result of a signed conversion always begins with a plus
        #         or minus sign. (It begins with a sign only when a negative
        #         value is converted if this flag is not specified.)
        #   space If the first character of a signed conversion is not a sign,
        #         or if a signed conversion results in no characters, a space
        #         is prefixed to the result.  If the space and + flags both
        #         appear, the space flag is ignored.
        #   #     The result is converted to an "alternative form".  For o
        #         conversion, it increases the precision, if an only if
        #         necessary, to force the first digit of the result to be a
        #         zero (if the value and precision are both 0, a single 0 is
        #         printed).  For x (or X) conversion, a nonzero result has 0x
        #         (or 0X) prefixed to it.  For a, A, e, E, f, F, g, and G
        #         conversions, the result of converting a floating-point number
        #         always contains a decimal-point character, even if no digits
        #         follow it. (Normally, a decimal-point character appears in
        #         the result of these conversions only if a digit follows it.)
        #         For g and G conversions, trailing zeros are not removed from
        #         the result.  For other conversions, the behavior is
        #         undefined.
        #   0     For d, i, o, u, x, X, a, A, e, E, f, F, g, and G conversions,
        #         leading zeros (following any indication of sign or base) are
        #         used to pad to the field width rather than performing space
        #         padding, except when converting an infinity or NaN.  If the 0
        #         and - flags both appear, the 0 flag is ignored.  For d, i, o,
        #         u, x, and X conversions, if a precision is specified, the 0
        #         flag is ignored.  For other conversions, the behavior is
        #         undefined.
        /[-+ #0]*/
      end
      private_class_method :flags_re

      def self.field_width_re
        /(?:\*|[1-9][0-9]*)?/
      end
      private_class_method :field_width_re

      def self.precision_re
        /(?:\.\*|\.[1-9][0-9]*)?/
      end
      private_class_method :precision_re

      def self.length_modifier_re
        # NOTE: The ISO C99 standard says;
        #
        # 7.19.6.1 The fprintf function
        #
        # 7 The length modifiers and their meanings are:
        #
        #   hh   Specifies that a following d, i, o, u, x, or X conversion
        #        specifier applies to a signed char or unsigned char argument
        #        (the argument will have been promoted according to the integer
        #        promotions, but its value shall be converted to signed char or
        #        unsigned char before printing); or that a following n
        #        conversion specifier applies to a pointer to a signed char
        #        argument.
        #   h    Specifies that a following d, i, o, u, x, or X conversion
        #        specifier applies to a short int or unsigned short int
        #        argument (the argument will have been promoted according to
        #        the integer promotions, but its value shall be converted to
        #        short int or unsigned short int before printing); or that a
        #        following n conversion specifier applies to a pointer to a
        #        short int argument.
        #   l    Specifies that a following d, i, o, u, x, or X conversion
        #        specifier applies to a long int or unsigned long int argument;
        #        that a following n conversion specifier applies to a pointer
        #        to a long int argument; that a following c conversion
        #        specifier applies to a wint_t argument; that a following s
        #        conversion specifier applies to a pointer to a wchar_t
        #        argument; or has no effect on a following a, A, e, E, f, F, g,
        #        or G conversion specifier.
        #   ll   Specifies that a following d, i, o, u, x, or X conversion
        #        specifier applies to a long long int or unsigned long long int
        #        argument; or that a following n conversion specifier applies
        #        to a pointer to a long long int argument.
        #   j    Specifies that a following d, i, o, u, x, or X conversion
        #        specifier applies to an intmax_t or uintmax_t argument; or
        #        that a following n conversion specifier applies to a pointer
        #        to an intmax_t argument.
        #   z    Specifies that a following d, i, o, u, x, or X conversion
        #        specifier applies to a size_t or the corresponding signed
        #        integer type argument; or that a following n conversion
        #        specifier applies to a pointer to a signed integer type
        #        corresponding to size_t argument.
        #   t    Specifies that a following d, i, o, u, x, or X conversion
        #        specifier applies to a ptrdiff_t or the corresponding unsigned
        #        integer type argument; or that a following n conversion
        #        specifier applies to a pointer to a ptrdiff_t argument.
        #   L    Specifies that a following a, A, e, E, f, F, g, or G
        #        conversion specifier applies to a long double argument.
        /(?:h+|l+|j|z|t|L)?/
      end
      private_class_method :length_modifier_re

      def self.cs_char_re
        # NOTE: The ISO C99 standard says;
        #
        # 7.19.6.1 The fprintf function
        #
        # 8 The conversion specifiers and their meanings are:
        #
        #   d,i     The int argument is converted to signed decimal in the
        #           style [-]dddd.  The precision specifies the minimum number
        #           of digits to appear; if the value being converted can be
        #           represented in fewer digits, it is expanded with leading
        #           zeros.  The default precision is 1.  The result of
        #           converting a zero value with a precision of zero is no
        #           characters.
        #   o,u,x,X The unsigned int argument is converted to unsigned octal
        #           (o), unsigned decimal (u), or unsigned hexadecimal notation
        #           (x or X) in the style dddd; the letters abcdef are used for
        #           x conversion and the letters ABCDEF for X conversion.  The
        #           precision specifies the minimum number of digits to appear;
        #           if the value being converted can be represented in fewer
        #           digits, it is expanded with leading zeros.  The default
        #           precision in 1.  The result of converting a zero value with
        #           a precision of zero is no characters.
        #   f,F     A double argument representing a floating-point number is
        #           converted to decimal notation in the style [-]ddd.ddd,
        #           where the number of digits after the decimal-point
        #           character is equal to the precision specification.  If the
        #           precision is missing, it is taken as 6; if the precision is
        #           zero and the # flag is not specified, no decimal-point
        #           character appears.  If a decimal-point character appears,
        #           at least one digit appears before it.  The value is rounded
        #           to the appropriate number of digits.
        #           A double argument representing an infinity is converted in
        #           one of the styles [-]inf or [-]infinity -- which style is
        #           implementation-defined.  A double argument representing a
        #           NaN is converted in one of the styles [-]nan or
        #           [-]nan(n-char-sequence) -- which style, and the meaning of
        #           any n-char-sequence, is implementation-defined.  The F
        #           conversion specifier produces INF, INFINITY, or NAN instead
        #           of inf, infinity, or nan, respectively.
        #   e,E     A double argument representing a floating-point number is
        #           converted in the style [-]d.ddde[+-]dd, where there is one
        #           digit (which is nonzero if the argument is nonzero) before
        #           the decimal-point character and the number of digits after
        #           it is equal to the precision; if the precision is missing,
        #           it is taken as 6; if the precision is zero and the # flag
        #           is not specified, no decimal-point character appears.  The
        #           value is rounded to the appropriate number of digits.  The
        #           E conversion specifier produces a number with E instead of
        #           e introducing the exponent.  The exponent always contains
        #           at least two digits, and only as many more digits as
        #           necessary to represent the exponent.  If the value is zero,
        #           the exponent is zero.
        #   g,G     A double argument representing a floating-point number is
        #           converted in style f or e (or in style F or E in the case
        #           of a G conversion specifier), depending on the value
        #           converted and the precision.  Let P equal the precision if
        #           nonzero, 6 if the precision is omitted, or 1 if the
        #           precision is zero.  Then, if a conversion with style E
        #           would have an exponent of X:
        #             -- if P > X >= -4, the conversion is which style f (or F)
        #                and precision P - (X + 1).
        #             -- otherwise, the conversion is with style e (or E) and
        #                precision P - 1.
        #           Finally, unless the # flag is used, any trailing zeros are
        #           removed from the fractional portion of the result and the
        #           decimal-point character is removed if there is no
        #           fractional portion remaining.
        #           A double argument representing an infinity or NaN is
        #           converted in the style of an f or F conversion specifier.
        #   a,A     A double argument representing a floating-point number is
        #           converted in the style [-]0xh.hhhhp[+-]d, where there is
        #           one hexadecimal digit (which is nonzero if the argument is
        #           a normalized floating-point number and is otherwise
        #           unspecified) before the decimal-point character and the
        #           number of hexadecimal digits after it is equal to the
        #           precision; if the precision is missing and FLT_RADIX is a
        #           power of 2, then the precision is sufficient for an exact
        #           representation of the value; if the precision is missing
        #           and FLT_RADIX is not a power of 2, then the precision is
        #           sufficient to distinguish values of type double, except
        #           that trailing zeros may be omitted; if the precision is
        #           zero and the # flag is not specified, no decimal-point
        #           character appears.  The letters abcdef are used for a
        #           conversion and the letters ABCDEF for A conversion.  The A
        #           conversion specifier produces a number with X and P instead
        #           of x and p.  The exponent always contains at least one
        #           digit, and only as many more digits as necessary to
        #           represent the decimal exponent of 2.  If the value is zero,
        #           the exponent is zero.
        #   c       If no l length modifier is present, the int argument is
        #           converted to an unsigned char, and the resulting character
        #           is written.
        #   s       If no l length modifier is present, the argument shall be a
        #           pointer to the initial element of an array of character
        #           type.  Characters from the array are written up to (but not
        #           including) the terminating null character.  If the
        #           precision is specified, no more than that many bytes are
        #           written.  If the precision is not specified or is greater
        #           than the size of the array, the array shall contain a null
        #           character.
        #           If an l length modifier is present, the argument shall be a
        #           pointer to the initial element of an array of wchar_t type.
        #           Wide characters from the array are converted to multibyte
        #           characters (each as if by a call to the wcrtomb function,
        #           with the conversion state described by an mbstate_t object
        #           initialized to zero before the first wide character is
        #           converted) up to and including a terminating null wide
        #           character.  The resulting multibyte characters are written
        #           up to (but not including) the terminating null character
        #           (byte).  If no precision is specified, the array shall
        #           contain a null wide character.  If a precision is
        #           specified, no more than that many bytes are written
        #           (including shift sequence, if any), and the array shall
        #           contain a null wide character if, to equal the multibyte
        #           character sequence length given by the precision, the
        #           function would need to access a wide character one past the
        #           end of the array.  In no case is a partial multibyte
        #           character written.
        #   p       The argument shall be a pointer to void.  The value of the
        #           pointer is converted to a sequence of printing characters,
        #           in an implementation-defined manner.
        #   n       The argument shall be a pointer to signed integer into
        #           which is written the number of characters written to the
        #           output stream so far by this call to fprintf.  No argument
        #           is converted, but one is consumed.  If the conversion
        #           specification includes any flags, a field width, or a
        #           precision, the behavior is undefined.
        #   %       A % character is written.  No argument is converted.  The
        #           complete conversion specification shall be %%.
        /[diouxXfFeEgGaAcspn%]/
      end
      private_class_method :cs_char_re

      private
      def default_precision_value
        subclass_responsibility
      end

      def ruby_sprintf_format
        # TODO: Should support the parameterized field width and the
        #       parameterized precision.
        fw = @field_width == "*" ? "1" : @field_width
        pr = @precision == ".*" ? ".1" : @precision
        "%#{flags}#{fw}#{pr}#{conversion_specifier_character}"
      end

      extend Forwardable

      def_delegator :@environment, :type_table
      private :type_table

      def_delegator :@environment, :memory_pool
      private :memory_pool
    end
    private_constant :ConversionSpecifier

    class CompleteConversionSpecifier < ConversionSpecifier
      # === DESCRIPTION
      # Checks whether types of arguments match this directive.
      #
      # === RETURN VALUE
      # Boolean -- True if types of arguments match this directive.
      def acceptable?
        if @field_width_argument
          unless @field_width_argument.type.convertible?(signed_int_t) ||
              @field_width_argument.type.convertible?(unsigned_int_t)
            return false
          end
        end

        if @precision_argument
          unless @precision_argument.type.convertible?(signed_int_t) ||
              @precision_argument.type.convertible?(unsigned_int_t)
            return false
          end
        end

        if @conversion_argument
          if argument_types
            argument_types.any? do |arg_type|
              @conversion_argument.type.convertible?(arg_type)
            end
          else
            true
          end
        else
          false
        end
      end

      # === DESCRIPTION
      # Checks whether the format string of this directive is the ISO C99
      # compliant.
      #
      # === RETURN VALUE
      # Boolean -- True if the format string is wellformed.
      def wellformed?
        valid_flags? && valid_field_width? && valid_precision? &&
          valid_length_modifier? && valid_conversion_specifier_character?
      end

      def complete?
        true
      end

      def valid_flags?
        true
      end

      def valid_field_width?
        true
      end

      def valid_precision?
        true
      end

      def valid_length_modifier?
        if length_modifier.empty?
          true
        else
          suitable_length_modifiers.include?(length_modifier)
        end
      end

      private
      def argument_types
        subclass_responsibility
      end

      def suitable_length_modifiers
        subclass_responsibility
      end
    end
    private_constant :CompleteConversionSpecifier

    class NumberConversionSpecifier < CompleteConversionSpecifier
      def initialize(fmt, trailing_args, env, flags, field_width, prec,
                     len_mod, cs_char)
        super(fmt, trailing_args, env, true, flags, field_width, prec, len_mod,
              cs_char)
      end

      def valid_conversion_specifier_character?
        true
      end

      def min_length
        # NOTE: Ruby has the buitin mostly C compliant sprintf.
        (ruby_sprintf_format % 0).length
      end

      def max_length
        # NOTE: Ruby has the buitin mostly C compliant sprintf.
        if conversion_type.signed?
          (ruby_sprintf_format % conversion_type.min).length
        else
          (ruby_sprintf_format % conversion_type.max).length
        end
      end

      private
      def conversion_type
        subclass_responsibility
      end
    end
    private_constant :NumberConversionSpecifier

    class Conversion_d < NumberConversionSpecifier
      def self.suitable_conversion_specifier_character
        "d"
      end

      private
      def default_precision_value
        # NOTE: The ISO C99 standard says;
        #
        # 7.19.6.1 The fprintf function
        #
        # 8 The conversion specifiers and their meanings are:
        #
        #   d,i     The int argument is converted to signed decimal in the
        #           style [-]dddd.  The precision specifies the minimum number
        #           of digits to appear; if the value being converted can be
        #           represented in fewer digits, it is expanded with leading
        #           zeros.  The default precision is 1.  The result of
        #           converting a zero value with a precision of zero is no
        #           characters.
        #   o,u,x,X The unsigned int argument is converted to unsigned octal
        #           (o), unsigned decimal (u), or unsigned hexadecimal notation
        #           (x or X) in the style dddd; the letters abcdef are used for
        #           x conversion and the letters ABCDEF for X conversion.  The
        #           precision specifies the minimum number of digits to appear;
        #           if the value being converted can be represented in fewer
        #           digits, it is expanded with leading zeros.  The default
        #           precision in 1.  The result of converting a zero value with
        #           a precision of zero is no characters.
        1
      end

      def argument_types
        # NOTE: The ISO C99 standard says;
        #
        # 7.19.6.1 The fprintf function
        #
        # 7 The length modifiers and their meanings are:
        #
        #   hh   Specifies that a following d, i, o, u, x, or X conversion
        #        specifier applies to a signed char or unsigned char argument
        #        (the argument will have been promoted according to the integer
        #        promotions, but its value shall be converted to signed char or
        #        unsigned char before printing); or that a following n
        #        conversion specifier applies to a pointer to a signed char
        #        argument.
        #   h    Specifies that a following d, i, o, u, x, or X conversion
        #        specifier applies to a short int or unsigned short int
        #        argument (the argument will have been promoted according to
        #        the integer promotions, but its value shall be converted to
        #        short int or unsigned short int before printing); or that a
        #        following n conversion specifier applies to a pointer to a
        #        short int argument.
        #   l    Specifies that a following d, i, o, u, x, or X conversion
        #        specifier applies to a long int or unsigned long int argument;
        #        that a following n conversion specifier applies to a pointer
        #        to a long int argument; that a following c conversion
        #        specifier applies to a wint_t argument; that a following s
        #        conversion specifier applies to a pointer to a wchar_t
        #        argument; or has no effect on a following a, A, e, E, f, F, g,
        #        or G conversion specifier.
        #   ll   Specifies that a following d, i, o, u, x, or X conversion
        #        specifier applies to a long long int or unsigned long long int
        #        argument; or that a following n conversion specifier applies
        #        to a pointer to a long long int argument.
        #   j    Specifies that a following d, i, o, u, x, or X conversion
        #        specifier applies to an intmax_t or uintmax_t argument; or
        #        that a following n conversion specifier applies to a pointer
        #        to an intmax_t argument.
        #   z    Specifies that a following d, i, o, u, x, or X conversion
        #        specifier applies to a size_t or the corresponding signed
        #        integer type argument; or that a following n conversion
        #        specifier applies to a pointer to a signed integer type
        #        corresponding to size_t argument.
        #   t    Specifies that a following d, i, o, u, x, or X conversion
        #        specifier applies to a ptrdiff_t or the corresponding unsigned
        #        integer type argument; or that a following n conversion
        #        specifier applies to a pointer to a ptrdiff_t argument.
        case length_modifier
        when "hh"
          [signed_char_t, unsigned_char_t]
        when "h"
          [signed_short_t, unsigned_short_t]
        when "l"
          [signed_long_t, unsigned_long_t]
        when "ll"
          [signed_long_long_t, unsigned_long_long_t]
        when "j"
          # FIXME: `intmax_t' and `uintmax_t' are not supported yet.
          [signed_long_long_t, unsigned_long_long_t]
        when "z"
          # FIXME: `size_t' is not supported yet.
          [unsigned_long_t]
        when "t"
          # FIXME: `ptrdiff_t' is not supported yet.
          [signed_int_t]
        else
          [signed_int_t, unsigned_int_t]
        end
      end

      def suitable_length_modifiers
        ["hh", "h", "l", "ll", "j", "z", "t"]
      end

      def conversion_type
        case length_modifier
        when "hh"
          if conversion_argument && conversion_argument.type.signed?
            signed_char_t
          else
            unsigned_char_t
          end
        when "h"
          if conversion_argument && conversion_argument.type.signed?
            signed_short_t
          else
            unsigned_short_t
          end
        when "l"
          if conversion_argument && conversion_argument.type.signed?
            signed_long_t
          else
            unsigned_long_t
          end
        when "ll"
          if conversion_argument && conversion_argument.type.signed?
            signed_long_long_t
          else
            unsigned_long_long_t
          end
        when "j"
          # FIXME: `intmax_t' and `uintmax_t' are not supported yet.
          if conversion_argument && conversion_argument.type.signed?
            signed_long_long_t
          else
            unsigned_long_long_t
          end
        when "z"
          # FIXME: `size_t' is not supported yet.
          unsigned_long_t
        when "t"
          # FIXME: `ptrdiff_t' is not supported yet.
          signed_int_t
        else
          default_conversion_type
        end
      end

      def default_conversion_type
        signed_int_t
      end
    end
    private_constant :Conversion_d

    class Conversion_i < Conversion_d
      def self.suitable_conversion_specifier_character
        "i"
      end
    end
    private_constant :Conversion_i

    class Conversion_o < Conversion_d
      def self.suitable_conversion_specifier_character
        "o"
      end

      private
      def default_conversion_type
        unsigned_int_t
      end
    end
    private_constant :Conversion_o

    class Conversion_u < Conversion_o
      def self.suitable_conversion_specifier_character
        "u"
      end
    end
    private_constant :Conversion_u

    class Conversion_x < Conversion_o
      def self.suitable_conversion_specifier_character
        "x"
      end
    end
    private_constant :Conversion_x

    class Conversion_X < Conversion_o
      def self.suitable_conversion_specifier_character
        "X"
      end
    end
    private_constant :Conversion_X

    class Conversion_f < NumberConversionSpecifier
      def self.suitable_conversion_specifier_character
        "f"
      end

      private
      def default_precision_value
        # NOTE: The ISO C99 standard says;
        #
        # 7.19.6.1 The fprintf function
        #
        # 8 The conversion specifiers and their meanings are:
        #
        #   f,F     A double argument representing a floating-point number is
        #           converted to decimal notation in the style [-]ddd.ddd,
        #           where the number of digits after the decimal-point
        #           character is equal to the precision specification.  If the
        #           precision is missing, it is taken as 6; if the precision is
        #           zero and the # flag is not specified, no decimal-point
        #           character appears.  If a decimal-point character appears,
        #           at least one digit appears before it.  The value is rounded
        #           to the appropriate number of digits.
        #           A double argument representing an infinity is converted in
        #           one of the styles [-]inf or [-]infinity -- which style is
        #           implementation-defined.  A double argument representing a
        #           NaN is converted in one of the styles [-]nan or
        #           [-]nan(n-char-sequence) -- which style, and the meaning of
        #           any n-char-sequence, is implementation-defined.  The F
        #           conversion specifier produces INF, INFINITY, or NAN instead
        #           of inf, infinity, or nan, respectively.
        #   e,E     A double argument representing a floating-point number is
        #           converted in the style [-]d.ddde[+-]dd, where there is one
        #           digit (which is nonzero if the argument is nonzero) before
        #           the decimal-point character and the number of digits after
        #           it is equal to the precision; if the precision is missing,
        #           it is taken as 6; if the precision is zero and the # flag
        #           is not specified, no decimal-point character appears.  The
        #           value is rounded to the appropriate number of digits.  The
        #           E conversion specifier produces a number with E instead of
        #           e introducing the exponent.  The exponent always contains
        #           at least two digits, and only as many more digits as
        #           necessary to represent the exponent.  If the value is zero,
        #           the exponent is zero.
        #   g,G     A double argument representing a floating-point number is
        #           converted in style f or e (or in style F or E in the case
        #           of a G conversion specifier), depending on the value
        #           converted and the precision.  Let P equal the precision if
        #           nonzero, 6 if the precision is omitted, or 1 if the
        #           precision is zero.  Then, if a conversion with style E
        #           would have an exponent of X:
        #             -- if P > X >= -4, the conversion is which style f (or F)
        #                and precision P - (X + 1).
        #             -- otherwise, the conversion is with style e (or E) and
        #                precision P - 1.
        #           Finally, unless the # flag is used, any trailing zeros are
        #           removed from the fractional portion of the result and the
        #           decimal-point character is removed if there is no
        #           fractional portion remaining.
        #           A double argument representing an infinity or NaN is
        #           converted in the style of an f or F conversion specifier.
        6
      end

      def argument_types
        # NOTE: The ISO C99 standard says;
        #
        # 7.19.6.1 The fprintf function
        #
        # 7 The length modifiers and their meanings are:
        #
        #   L    Specifies that a following a, A, e, E, f, F, g, or G
        #        conversion specifier applies to a long double argument.
        case length_modifier
        when "L"
          [long_double_t]
        else
          # NOTE: The argument will be argument promoted, so float type should
          #       be acceptable, too.
          [float_t, double_t]
        end
      end

      def suitable_length_modifiers
        ["L"]
      end

      def conversion_type
        case length_modifier
        when "L"
          long_double_t
        else
          double_t
        end
      end
    end
    private_constant :Conversion_f

    class Conversion_F < Conversion_f
      def self.suitable_conversion_specifier_character
        "F"
      end
    end
    private_constant :Conversion_F

    class Conversion_e < Conversion_f
      def self.suitable_conversion_specifier_character
        "e"
      end
    end
    private_constant :Conversion_e

    class Conversion_E < Conversion_f
      def self.suitable_conversion_specifier_character
        "E"
      end
    end
    private_constant :Conversion_E

    class Conversion_g < Conversion_f
      def self.suitable_conversion_specifier_character
        "g"
      end
    end
    private_constant :Conversion_g

    class Conversion_G < Conversion_f
      def self.suitable_conversion_specifier_character
        "G"
      end
    end
    private_constant :Conversion_G

    class Conversion_a < Conversion_f
      def self.suitable_conversion_specifier_character
        "a"
      end

      private
      def default_precision_value
        # NOTE: The ISO C99 standard says;
        #
        # 7.19.6.1 The fprintf function
        #
        # 8 The conversion specifiers and their meanings are:
        #
        #   a,A     A double argument representing a floating-point number is
        #           converted in the style [-]0xh.hhhhp[+-]d, where there is
        #           one hexadecimal digit (which is nonzero if the argument is
        #           a normalized floating-point number and is otherwise
        #           unspecified) before the decimal-point character and the
        #           number of hexadecimal digits after it is equal to the
        #           precision; if the precision is missing and FLT_RADIX is a
        #           power of 2, then the precision is sufficient for an exact
        #           representation of the value; if the precision is missing
        #           and FLT_RADIX is not a power of 2, then the precision is
        #           sufficient to distinguish values of type double, except
        #           that trailing zeros may be omitted; if the precision is
        #           zero and the # flag is not specified, no decimal-point
        #           character appears.  The letters abcdef are used for a
        #           conversion and the letters ABCDEF for A conversion.  The A
        #           conversion specifier produces a number with X and P instead
        #           of x and p.  The exponent always contains at least one
        #           digit, and only as many more digits as necessary to
        #           represent the decimal exponent of 2.  If the value is zero,
        #           the exponent is zero.

        # FIXME: This is not the ISO C99 compliant.
        6
      end
    end
    private_constant :Conversion_a

    class Conversion_A < Conversion_f
      def self.suitable_conversion_specifier_character
        "A"
      end
    end
    private_constant :Conversion_A

    class CharacterConversionSpecifier < CompleteConversionSpecifier
      def initialize(fmt, trailing_args, env, flags, field_width, prec,
                     len_mod, cs_char)
        super(fmt, trailing_args, env, true, flags, field_width, prec, len_mod,
              cs_char)
      end

      def valid_conversion_specifier_character?
        true
      end

      def min_length
        # NOTE: Ruby has the buitin mostly C compliant sprintf.
        (ruby_sprintf_format % " ").length
      end

      def max_length
        min_length
      end
    end
    private_constant :CharacterConversionSpecifier

    class Conversion_c < CharacterConversionSpecifier
      def self.suitable_conversion_specifier_character
        "c"
      end

      private
      def default_precision_value
        0
      end

      def argument_types
        # NOTE: The ISO C99 standard says;
        #
        # 7.19.6.1 The fprintf function
        #
        # 7 The length modifiers and their meanings are:
        #
        #   l    Specifies that a following d, i, o, u, x, or X conversion
        #        specifier applies to a long int or unsigned long int argument;
        #        that a following n conversion specifier applies to a pointer
        #        to a long int argument; that a following c conversion
        #        specifier applies to a wint_t argument; that a following s
        #        conversion specifier applies to a pointer to a wchar_t
        #        argument; or has no effect on a following a, A, e, E, f, F, g,
        #        or G conversion specifier.
        case length_modifier
        when "l"
          # FIXME: `wint_t' is not supported yet.
          [wchar_t]
        else
          # NOTE: The argument will be integer promoted, so the argument type
          #       whose conversion-rank is less than one of the int should be
          #       acceptable, too.
          [signed_char_t, unsigned_char_t, signed_short_t,
            unsigned_short_t, signed_int_t, unsigned_int_t]
        end
      end

      def suitable_length_modifiers
        ["l"]
      end
    end
    private_constant :Conversion_c

    class StringConversionSpecifier < CompleteConversionSpecifier
      def initialize(fmt, trailing_args, env, flags, field_width, prec,
                     len_mod, cs_char)
        super(fmt, trailing_args, env, true, flags, field_width, prec, len_mod,
              cs_char)
      end

      def valid_conversion_specifier_character?
        true
      end

      def min_length
        # NOTE: Ruby has the buitin mostly C compliant sprintf.
        (ruby_sprintf_format % "").length
      end

      def max_length
        # NOTE: Ruby has the buitin mostly C compliant sprintf.
        if conversion_argument && conversion_argument.type.pointer? and
            pointee = pointee_of(conversion_argument) and pointee.type.array?
          len = pointee.type.length ? pointee.type.length - 1 : 0
          (ruby_sprintf_format % (" " * len)).length
        else
          min_length
        end
      end
    end
    private_constant :StringConversionSpecifier

    class Conversion_s < StringConversionSpecifier
      def self.suitable_conversion_specifier_character
        "s"
      end

      private
      def default_precision_value
        0
      end

      def argument_types
        # NOTE: The ISO C99 standard says;
        #
        # 7.19.6.1 The fprintf function
        #
        # 7 The length modifiers and their meanings are:
        #
        #   l    Specifies that a following d, i, o, u, x, or X conversion
        #        specifier applies to a long int or unsigned long int argument;
        #        that a following n conversion specifier applies to a pointer
        #        to a long int argument; that a following c conversion
        #        specifier applies to a wint_t argument; that a following s
        #        conversion specifier applies to a pointer to a wchar_t
        #        argument; or has no effect on a following a, A, e, E, f, F, g,
        #        or G conversion specifier.
        case length_modifier
        when "l"
          [pointer_type(qualified_type(wchar_t, :const))]
        else
          [pointer_type(qualified_type(signed_char_t, :const)),
            pointer_type(qualified_type(unsigned_char_t, :const))]
        end
      end

      def suitable_length_modifiers
        ["l"]
      end
    end
    private_constant :Conversion_s

    class Conversion_p < NumberConversionSpecifier
      def self.suitable_conversion_specifier_character
        "p"
      end

      def min_length
        # NOTE: `%p' conversion specifier of the Ruby's builtin sprintf does
        #       not convert the argument.
        ("%##{flags}#{field_width}#{precision}x" % 0).length
      end

      def max_length
        # NOTE: `%p' conversion specifier of the Ruby's builtin sprintf does
        #       not convert the argument.
        ("%##{flags}#{field_width}#{precision}x" % conversion_type.max).length
      end

      private
      def default_precision_value
        0
      end

      def argument_types
        if conversion_argument && conversion_argument.type.pointer?
          [conversion_argument.type.unqualify]
        else
          [pointer_type(qualified_type(void_t, :const))]
        end
      end

      def suitable_length_modifiers
        []
      end

      def conversion_type
        pointer_type(void_t)
      end
    end
    private_constant :Conversion_p

    class Conversion_n < CompleteConversionSpecifier
      def self.suitable_conversion_specifier_character
        "n"
      end

      def initialize(fmt, trailing_args, env, flags, field_width, prec,
                     len_mod, cs_char)
        super(fmt, trailing_args, env, true, flags, field_width, prec, len_mod,
              cs_char)
      end

      def valid_conversion_specifier_character?
        true
      end

      def min_length
        0
      end

      def max_length
        0
      end

      private
      def default_precision_value
        0
      end

      def argument_types
        # NOTE: The ISO C99 standard says;
        #
        # 7.19.6.1 The fprintf function
        #
        # 7 The length modifiers and their meanings are:
        #
        #   hh   Specifies that a following d, i, o, u, x, or X conversion
        #        specifier applies to a signed char or unsigned char argument
        #        (the argument will have been promoted according to the integer
        #        promotions, but its value shall be converted to signed char or
        #        unsigned char before printing); or that a following n
        #        conversion specifier applies to a pointer to a signed char
        #        argument.
        #   h    Specifies that a following d, i, o, u, x, or X conversion
        #        specifier applies to a short int or unsigned short int
        #        argument (the argument will have been promoted according to
        #        the integer promotions, but its value shall be converted to
        #        short int or unsigned short int before printing); or that a
        #        following n conversion specifier applies to a pointer to a
        #        short int argument.
        #   l    Specifies that a following d, i, o, u, x, or X conversion
        #        specifier applies to a long int or unsigned long int argument;
        #        that a following n conversion specifier applies to a pointer
        #        to a long int argument; that a following c conversion
        #        specifier applies to a wint_t argument; that a following s
        #        conversion specifier applies to a pointer to a wchar_t
        #        argument; or has no effect on a following a, A, e, E, f, F, g,
        #        or G conversion specifier.
        #   ll   Specifies that a following d, i, o, u, x, or X conversion
        #        specifier applies to a long long int or unsigned long long int
        #        argument; or that a following n conversion specifier applies
        #        to a pointer to a long long int argument.
        #   j    Specifies that a following d, i, o, u, x, or X conversion
        #        specifier applies to an intmax_t or uintmax_t argument; or
        #        that a following n conversion specifier applies to a pointer
        #        to an intmax_t argument.
        #   z    Specifies that a following d, i, o, u, x, or X conversion
        #        specifier applies to a size_t or the corresponding signed
        #        integer type argument; or that a following n conversion
        #        specifier applies to a pointer to a signed integer type
        #        corresponding to size_t argument.
        #   t    Specifies that a following d, i, o, u, x, or X conversion
        #        specifier applies to a ptrdiff_t or the corresponding unsigned
        #        integer type argument; or that a following n conversion
        #        specifier applies to a pointer to a ptrdiff_t argument.
        case length_modifier
        when "hh"
          [pointer_type(qualified_type(signed_char_t, :const))]
        when "h"
          [pointer_type(qualified_type(signed_short_t, :const))]
        when "l"
          [pointer_type(qualified_type(signed_long_t, :const))]
        when "ll"
          [pointer_type(qualified_type(signed_long_long_t, :const))]
        when "j"
          # FIXME: `intmax_t' is not supported yet.
          [pointer_type(qualified_type(signed_long_long_t, :const))]
        when "z"
          # FIXME: `size_t' is not supported yet.
          [pointer_type(qualified_type(signed_long_t, :const))]
        when "t"
          # FIXME: `ptrdiff_t' is not supported yet.
          [pointer_type(qualified_type(signed_int_t, :const))]
        else
          [pointer_type(qualified_type(signed_int_t, :const))]
        end
      end

      def suitable_length_modifiers
        ["hh", "h", "l", "ll", "j", "z", "t"]
      end
    end
    private_constant :Conversion_n

    class Conversion_percent < CompleteConversionSpecifier
      def self.suitable_conversion_specifier_character
        "%"
      end

      def initialize(fmt, trailing_args, env, flags, field_width, prec,
                     len_mod, cs_char)
        super(fmt, trailing_args, env, false, flags, field_width, prec,
              len_mod, cs_char)
      end

      def valid_flags?
        flags.empty?
      end

      def valid_field_width?
        field_width.empty?
      end

      def valid_precision?
        precision.empty?
      end

      def valid_length_modifier?
        length_modifier.empty?
      end

      def valid_conversion_specifier_character?
        true
      end

      def min_length
        1
      end

      def max_length
        1
      end

      private
      def default_precision_value
        0
      end

      def argument_types
        nil
      end

      def suitable_length_modifiers
        []
      end
    end
    private_constant :Conversion_percent

    class UndefinedConversionSpecifier < CompleteConversionSpecifier
      def initialize(fmt, flags, field_width, prec, len_mod, cs_char)
        super(fmt, [], nil, false, flags, field_width, prec, len_mod, cs_char)
      end

      def undefined?
        true
      end

      def valid_conversion_specifier_character?
        false
      end

      def min_length
        0
      end

      def max_length
        0
      end

      private
      def default_precision_value
        0
      end

      def argument_types
        nil
      end

      def suitable_length_modifiers
        []
      end
    end
    private_constant :UndefinedConversionSpecifier

    class IncompleteConversionSpecifier < ConversionSpecifier
      def initialize(fmt, flags, field_width, prec, len_mod)
        super(fmt, [], nil, false, flags, field_width, prec, len_mod, nil)
      end

      # === DESCRIPTION
      # Checks whether types of arguments match this directive.
      #
      # === RETURN VALUE
      # Boolean -- True if types of arguments match this directive.
      def acceptable?
        false
      end

      # === DESCRIPTION
      # Checks whether the format string of this directive is the ISO C99
      # compliant.
      #
      # === RETURN VALUE
      # Boolean -- True if the format string is wellformed.
      def wellformed?
        false
      end

      def complete?
        false
      end

      def undefined?
        true
      end

      def valid_flags?
        false
      end

      def valid_field_width?
        false
      end

      def valid_precision?
        false
      end

      def valid_length_modifier?
        false
      end

      def valid_conversion_specifier_character?
        false
      end

      def min_length
        0
      end

      def max_length
        0
      end

      private
      def default_precision_value
        0
      end
    end
    private_constant :IncompleteConversionSpecifier

    CONVERSION_SPECIFIERS = [
      Conversion_d,
      Conversion_i,
      Conversion_o,
      Conversion_u,
      Conversion_x,
      Conversion_X,
      Conversion_f,
      Conversion_F,
      Conversion_e,
      Conversion_E,
      Conversion_g,
      Conversion_G,
      Conversion_a,
      Conversion_A,
      Conversion_p,
      Conversion_c,
      Conversion_s,
      Conversion_n,
      Conversion_percent
    ]
    private_constant :CONVERSION_SPECIFIERS

    CONVERSION_SPECIFIER_TBL =
      CONVERSION_SPECIFIERS.each_with_object({}) { |cs_class, hash|
        hash[cs_class.suitable_conversion_specifier_character] = cs_class
      }.freeze
    private_constant :CONVERSION_SPECIFIER_TBL
  end

  class ScanfFormat
    def initialize(fmt_str, loc, trailing_args, env)
      @location        = loc
      @directives      = create_directives(fmt_str, trailing_args, env)
      @extra_arguments = trailing_args
    end

    attr_reader :location
    attr_reader :directives
    attr_reader :extra_arguments

    def conversion_specifiers
      @directives.select { |dire| dire.conversion_specifier? }
    end

    private
    def create_directives(fmt_str, trailing_args, env)
      dires = []
      str = fmt_str.dup
      until str.empty?
        dires.push(Directive.guess(str, trailing_args, env))
      end
      dires
    end

    # == DESCRIPTION
    # === Directive class hierarchy
    #  Directive
    #    <-- Whitespace
    #    <-- Ordinary
    #    <-- ConversionSpecifier
    #          <-- CompleteConversionSpecifier
    #                <-- Conversion_d
    #                      <-- Conversion_i
    #                      <-- Conversion_o
    #                            <-- Conversion_u
    #                            <-- Conversion_x
    #                            <-- Conversion_X
    #                <-- Conversion_a
    #                      <-- Conversion_A
    #                      <-- Conversion_e
    #                      <-- Conversion_E
    #                      <-- Conversion_f
    #                      <-- Conversion_F
    #                      <-- Conversion_g
    #                      <-- Conversion_G
    #                <-- Conversion_c
    #                      <-- Conversion_s
    #                      <-- Conversion_bracket
    #                <-- Conversion_p
    #                <-- Conversion_n
    #                <-- Conversion_percent
    #                <-- UndefinedConversionSpecifier
    #          <-- IncompleteConversionSpecifier
    class Directive
      def self.guess(fmt_str, trailing_args, env)
        try_to_create_whitespace(fmt_str) or
        try_to_create_ordinary(fmt_str) or
        try_to_create_conversion_specifier(fmt_str, trailing_args, env)
      end

      def initialize(fmt)
        @format = fmt
      end

      attr_reader :format

      def whitespace?
        subclass_responsibility
      end

      def ordinary?
        subclass_responsibility
      end

      def conversion_specifier?
        subclass_responsibility
      end

      def consume_arguments?
        subclass_responsibility
      end

      # === DESCRIPTION
      # Checks whether types of arguments match this directive.
      #
      # === RETURN VALUE
      # Boolean -- True if types of arguments match this directive.
      def acceptable?
        subclass_responsibility
      end

      # === DESCRIPTION
      # Checks whether the format string of this directive is the ISO C99
      # compliant.
      #
      # === RETURN VALUE
      # Boolean -- True if the format string is wellformed.
      def wellformed?
        subclass_responsibility
      end

      def illformed?
        !wellformed?
      end

      def complete?
        subclass_responsibility
      end

      def incomplete?
        !complete?
      end

      def undefined?
        subclass_responsibility
      end

      def valid_assignment_suppressing_character?
        subclass_responsibility
      end

      def valid_field_width?
        subclass_responsibility
      end

      def valid_length_modifier?
        subclass_responsibility
      end

      def valid_conversion_specifier_character?
        subclass_responsibility
      end

      def valid_scanset?
        subclass_responsibility
      end

      def assignment_suppressing_character
        subclass_responsibility
      end

      def field_width
        subclass_responsibility
      end

      def length_modifier
        subclass_responsibility
      end

      def conversion_specifier_character
        subclass_responsibility
      end

      def scanset
        subclass_responsibility
      end

      def self.try_to_create_whitespace(fmt_str)
        (fmt = Whitespace.scan(fmt_str)) ? Whitespace.new(fmt) : nil
      end
      private_class_method :try_to_create_whitespace

      def self.try_to_create_ordinary(fmt_str)
        (fmt = Ordinary.scan(fmt_str)) ? Ordinary.new(fmt) : nil
      end
      private_class_method :try_to_create_ordinary

      def self.try_to_create_conversion_specifier(fmt_str, trailing_args, env)
        fmt, as_char, field_width, len_mod, cs_char, scanset =
          ConversionSpecifier.scan(fmt_str)

        case
        when cs_char.nil?
          IncompleteConversionSpecifier.new(fmt, as_char, field_width, len_mod,
                                            nil)
        when cs_char == "[" && scanset.nil?
          IncompleteConversionSpecifier.new(fmt, as_char, field_width, len_mod,
                                            cs_char)
        when cs_class = CONVERSION_SPECIFIER_TBL[cs_char]
          cs_class.new(fmt, trailing_args, env, as_char, field_width, len_mod,
                       cs_char, scanset)
        else
          UndefinedConversionSpecifier.new(fmt, as_char, field_width, len_mod,
                                           cs_char)
        end
      end
      private_class_method :try_to_create_conversion_specifier
    end
    private_constant :Directive

    class Whitespace < Directive
      def self.scan(fmt_str)
        # NOTE: The ISO C99 standard says;
        #
        # 7.19.6.2 The fscanf function
        #
        # 3 The format shall be a multibyte character sequence, beginning and
        #   ending in its initial shift state.  The format is composed of zero
        #   or more directives: one or more white-space characters, an ordinary
        #   multibyte character (neither % nor a white-space character), or a
        #   conversion specification.  Each conversion specification is
        #   introduced by the character %.  After the %, the following appear
        #   in sequence:
        #
        #   -- An optional assignment-suppressing character *.
        #   -- An optional decimal integer greater than zero that specifies the
        #      maximum field width (in characters).
        #   -- An optional length modifier that specifies the size of the
        #      receiving object.
        #   -- A conversion specifier character that specifies the type of
        #      conversion to be applied.
        fmt_str.slice!(/\A\s+/)
      end

      def whitespace?
        true
      end

      def ordinary?
        false
      end

      def conversion_specifier?
        false
      end

      def consume_arguments?
        false
      end

      # === DESCRIPTION
      # Checks whether types of arguments match this directive.
      #
      # === RETURN VALUE
      # Boolean -- True if types of arguments match this directive.
      def acceptable?
        true
      end

      # === DESCRIPTION
      # Checks whether the format string of this directive is the ISO C99
      # compliant.
      #
      # === RETURN VALUE
      # Boolean -- True if the format string is wellformed.
      def wellformed?
        true
      end

      def complete?
        true
      end

      def undefined?
        false
      end

      def valid_assignment_suppressing_character?
        false
      end

      def valid_field_width?
        false
      end

      def valid_length_modifier?
        false
      end

      def valid_conversion_specifier_character?
        false
      end

      def valid_scanset?
        false
      end

      def assignment_suppressing_character
        nil
      end

      def field_width
        nil
      end

      def length_modifier
        nil
      end

      def conversion_specifier_character
        nil
      end

      def scanset
        nil
      end
    end
    private_constant :Whitespace

    class Ordinary < Directive
      def self.scan(fmt_str)
        # NOTE: The ISO C99 standard says;
        #
        # 7.19.6.2 The fscanf function
        #
        # 3 The format shall be a multibyte character sequence, beginning and
        #   ending in its initial shift state.  The format is composed of zero
        #   or more directives: one or more white-space characters, an ordinary
        #   multibyte character (neither % nor a white-space character), or a
        #   conversion specification.  Each conversion specification is
        #   introduced by the character %.  After the %, the following appear
        #   in sequence:
        #
        #   -- An optional assignment-suppressing character *.
        #   -- An optional decimal integer greater than zero that specifies the
        #      maximum field width (in characters).
        #   -- An optional length modifier that specifies the size of the
        #      receiving object.
        #   -- A conversion specifier character that specifies the type of
        #      conversion to be applied.
        fmt_str.slice!(/\A[^%\s]+/)
      end

      def whitespace?
        false
      end

      def ordinary?
        true
      end

      def conversion_specifier?
        false
      end

      def consume_arguments?
        false
      end

      # === DESCRIPTION
      # Checks whether types of arguments match this directive.
      #
      # === RETURN VALUE
      # Boolean -- True if types of arguments match this directive.
      def acceptable?
        true
      end

      # === DESCRIPTION
      # Checks whether the format string of this directive is the ISO C99
      # compliant.
      #
      # === RETURN VALUE
      # Boolean -- True if the format string is wellformed.
      def wellformed?
        true
      end

      def complete?
        true
      end

      def undefined?
        false
      end

      def valid_assignment_suppressing_character?
        false
      end

      def valid_field_width?
        false
      end

      def valid_length_modifier?
        false
      end

      def valid_conversion_specifier_character?
        false
      end

      def valid_scanset?
        false
      end

      def assignment_suppressing_character
        nil
      end

      def field_width
        nil
      end

      def length_modifier
        nil
      end

      def conversion_specifier_character
        nil
      end

      def scanset
        nil
      end
    end
    private_constant :Ordinary

    class ConversionSpecifier < Directive
      include TypeTableMediator

      def self.scan(fmt_str)
        # NOTE: The ISO C99 standard says;
        #
        # 7.19.6.2 The fscanf function
        #
        # 3 The format shall be a multibyte character sequence, beginning and
        #   ending in its initial shift state.  The format is composed of zero
        #   or more directives: one or more white-space characters, an ordinary
        #   multibyte character (neither % nor a white-space character), or a
        #   conversion specification.  Each conversion specification is
        #   introduced by the character %.  After the %, the following appear
        #   in sequence:
        #
        #   -- An optional assignment-suppressing character *.
        #   -- An optional decimal integer greater than zero that specifies the
        #      maximum field width (in characters).
        #   -- An optional length modifier that specifies the size of the
        #      receiving object.
        #   -- A conversion specifier character that specifies the type of
        #      conversion to be applied.

        if header = fmt_str.slice!(/\A%/)
          scanned = header
        else
          return nil, nil, nil, nil, nil, nil
        end

        if as_char = fmt_str.slice!(/\A#{as_char_re}/)
          scanned += as_char
        end

        if field_width = fmt_str.slice!(/\A#{field_width_re}/)
          scanned += field_width
        end

        if len_mod = fmt_str.slice!(/\A#{length_modifier_re}/)
          scanned += len_mod
        end

        if cs_char = fmt_str.slice!(/\A#{cs_char_re}/)
          scanned += cs_char
        else
          # NOTE: If no valid conversion specifier character, force to scan
          #       the heading 1 character as a conversion specifier character.
          if cs_char = fmt_str.slice!(/\A[a-z]/i)
            scanned += cs_char
          end
        end

        if cs_char == "["
          if scanset = fmt_str.slice!(/\A#{scanset_re}/)
            scanned += scanset
          end
        else
          scanset = nil
        end

        return scanned, as_char, field_width, len_mod, cs_char, scanset
      end

      def initialize(fmt, trailing_args, env, consume_args, as_char,
                     field_width, len_mod, cs_char, scanset)
        super(fmt)

        if as_char == "*"
          @consume_arguments = false
        else
          @consume_arguments = consume_args
        end

        @assignment_suppressing_character = as_char
        @field_width = field_width
        @length_modifier = len_mod
        @conversion_specifier_character = cs_char
        @scanset = scanset

        if consume_arguments?
          @conversion_argument = trailing_args.shift
        else
          @conversion_argument = nil
        end

        @environment = env
      end

      def whitespace?
        false
      end

      def ordinary?
        false
      end

      def conversion_specifier?
        true
      end

      def consume_arguments?
        @consume_arguments
      end

      def undefined?
        false
      end

      attr_reader :assignment_suppressing_character
      attr_reader :field_width
      attr_reader :length_modifier
      attr_reader :conversion_specifier_character
      attr_reader :scanset
      attr_reader :conversion_argument

      def field_width_value
        case @field_width
        when /\A[1-9][0-9]*\z/
          @field_width.to_i
        else
          1
        end
      end

      def self.as_char_re
        /\*?/
      end
      private_class_method :as_char_re

      def self.field_width_re
        /(?:[1-9][0-9]*)?/
      end
      private_class_method :field_width_re

      def self.length_modifier_re
        # NOTE: The ISO C99 standard says;
        #
        # 7.19.6.2 The fscanf function
        #
        # 11 The length modifiers and their meanings are:
        #
        #    hh Specifies that a following d, i, o, u, x, X, or n conversion
        #       specifier applies to an argument with type pointer to signed
        #       char or unsigned char.
        #    h  Specifies that a following d, i, o, u, x, X, or n conversion
        #       specifier applies to an argument with type pointer to short int
        #       or unsigned short int.
        #    l  Specifies that a following d, i, o, u, x, X, or n conversion
        #       specifier applies to an argument with type pointer to long int
        #       or unsigned long int; that a following a, A, e, E, f, F, g, or
        #       G conversion specifier applies to an argument with type pointer
        #       to double; or that a following c, s, or [ conversion specifier
        #       applies to an argument with type pointer to wchar_t.
        #    ll Specifies that a following d, i, o, u, x, X, or n conversion
        #       specifier applies to an argument with type pointer to long long
        #       int or unsigned long long int.
        #    j  Specifies that a following d, i, o, u, x, X, or n conversion
        #       specifier applies to an argument with type pointer to intmax_t
        #       or uintmax_t.
        #    z  Specifies that a following d, i, o, u, x, X, or n conversion
        #       specifier applies to an argument with type pointer to size_t or
        #       the corresponding signed integer type.
        #    t  Specifies that a following d, i, o, u, x, X, or n conversion
        #       specifier applies to an argument with type pointer to ptrdiff_t
        #       or the corresponding unsigned integer type.
        #    L  Specifies that a following a, A, e, E, f, F, g, or G conversion
        #       specifier applies to an argument with type pointer to long
        #       double.
        /(?:h+|l+|j|z|t|L)?/
      end
      private_class_method :length_modifier_re

      def self.cs_char_re
        # NOTE: The ISO C99 standard says;
        #
        # 7.19.6.2 The fscanf function
        #
        # 12 The conversion specifiers and their meanings are:
        #
        #    d       Matches an optionally signed decimal integer, whose format
        #            is the same as expected for the subject sequence of the
        #            strtol function with the value 10 for the base argument.
        #            The corresponding argument shall be a pointer to signed
        #            integer.
        #    i       Matches an optionally signed integer, whose format is the
        #            same as expected for the subject sequence of the strtol
        #            function with the value 0 for the base argument.  The
        #            corresponding argument shall be a pointer to signed
        #            integer.
        #    o       Matches an optionally signed octal integer, whose format
        #            is the same as expected for the subject sequence of the
        #            strtoul function with the value 8 for the base argument.
        #            The corresponding argument shall be a pointer to unsigned
        #            integer.
        #    u       Matches an optionally signed decimal integer, whose format
        #            is the same as expected for the subject sequence of the
        #            strtoul function with the value 10 for the base argument.
        #            The corresponding argument shall be a pointer to unsigned
        #            integer.
        #    x       Matches an optionally signed hexadecimal integer, whose
        #            format is the same as expected for the subject sequence of
        #            the strtoul function with the value 16 for the base
        #            argument.  The corresponding argument shall be a pointer
        #            to unsigned integer.
        #    a,e,f,g Matches an optionally signed floating-point number,
        #            infinity, or NaN, whose format is the same as expected for
        #            the subject sequence of the strtod function.  The
        #            corresponding argument shall be a pointer to floating.
        #    c       Matches a sequence of characters of exactly the number
        #            specified by the field width (1 if no field width is
        #            present in the directive).
        #            If no l length modifier is present, the corresponding
        #            argument shall be a pointer to the initial element of
        #            character array large enough to accept the sequence.  No
        #            null character is added.
        #            If an l length modifier is present, the input shall be a
        #            sequence of multibyte characters that begins in the
        #            initial shift state.  Each multibyte character in the
        #            sequence is converted to a wide character as if by a call
        #            to the mbrtowc function, with the conversion state
        #            described by an mbstate_t object initialized to zero
        #            before the first multibyte character is converted.  The
        #            corresponding argument shall be a pointer to the initial
        #            element of an array of wchar_t large enough to accept the
        #            resulting sequence of wide characters.  No null wide
        #            character is added.
        #    s       Matches a sequence of non-white-space characters.
        #            If no l length modifier is present, the corresponding
        #            argument shall be a pointer to the initial element of a
        #            character array large enough to accept the sequence and a
        #            terminating null character, which will be added
        #            automatically.
        #            If an l length modifier is present, the input shall be a
        #            sequence of multibyte characters that begins in the
        #            initial shift state.  Each multibyte character is
        #            converted to a wide character as if by a call to the
        #            mbrtowc function, with the conversion state described by
        #            an mbstate_t object initialized to zero before the first
        #            multibyte character is converted.  The corresponding
        #            argument shall be a pointer to the initial element of an
        #            array of wchar_t large enough to accept the sequence and
        #            the terminating null wide character, which will be added
        #            automatically.
        #    [       Matches a nonempty sequence of characters from a set of
        #            expected characters (the scanset).
        #            If no l length modifier is present, the corresponding
        #            argument shall be a pointer to the initial element of a
        #            character array large enough to accept the sequence and a
        #            terminating null character, which will be added
        #            automatically.
        #            If an l length modifier is present, the input shall be a
        #            sequence of multibyte characters that begins in the
        #            initial shift state.  Each multibyte character is
        #            converted to a wide character as if by a call to the
        #            mbrtowc function, with the conversion state described by
        #            an mbstate_t object initialized to zero before the first
        #            multibyte character is converted.  The corresponding
        #            argument shall be a pointer to the initial element of an
        #            array of wchar_t large enough to accept the sequence and
        #            the terminating null wide character, which will be added
        #            automatically.
        #            The conversion specifier includes all subsequent
        #            characters in the format string, up to and including the
        #            matching right bracket (]).  The characters between the
        #            brackets (the scanlist) compose the scanset, unless the
        #            character after the left bracket is a circumflex (^), in
        #            which case the scanset contains all characters that do not
        #            appear in the scanlist between the circumflex and the
        #            right bracket.  If the conversion specifier begins with []
        #            or [^], the right bracket character is in the scanlist and
        #            the next following right bracket character is the matching
        #            right bracket that ends the specification; otherwise the
        #            first following right bracket character is the one that
        #            ends the specification.  If a - character is in the
        #            scanlist and is not the first, nor the second where the
        #            first character is a ^, nor the last character, the
        #            behavior is implementation-defined.
        #    p       Matches an implementation-defined set of sequences, which
        #            should be the same as the set of sequence that may be
        #            produced by the %p conversion of the fprintf function.
        #            The corresponding argument shall be a pointer to a pointer
        #            to void.  The input item is converted to a pointer value
        #            in an implementation-defined manner.  If the input item is
        #            a value converted earlier during the same program
        #            execution, the pointer that results shall compare equal to
        #            the value; otherwise the behavior of the %p conversion is
        #            undefined.
        #    n       No input is consumed.  The corresponding argument shall be
        #            a pointer to signed integer into which is to be written
        #            the number of characters read from the input stream so far
        #            by this call to the fscanf function.  Execution of a %n
        #            directive does not increment the assignment count returned
        #            at the completion of execution of the fscanf function.  No
        #            argument is converted, but one is consumed.  If the
        #            conversion specification includes an
        #            assignment-suppressing character or a field width, the
        #            behavior is undefined.
        #    %       Matches a single % character; no conversion or assignment
        #            occurs.  The complete conversion specification shall be
        #            %%.
        #
        # 14 The conversion specifiers A, E, F, G, and X are also valid and
        #    behave the same as, respectively, a, e, f, g, and x.
        /[diouxXaAeEfFgGcs\[pn%]/
      end
      private_class_method :cs_char_re

      def self.scanset_re
        # NOTE: The ISO C99 standard says;
        #
        # 7.19.6.2 The fscanf function
        #
        # 12 The conversion specifiers and their meanings are:
        #
        #    [       Matches a nonempty sequence of characters from a set of
        #            expected characters (the scanset).
        #            If no l length modifier is present, the corresponding
        #            argument shall be a pointer to the initial element of a
        #            character array large enough to accept the sequence and a
        #            terminating null character, which will be added
        #            automatically.
        #            If an l length modifier is present, the input shall be a
        #            sequence of multibyte characters that begins in the
        #            initial shift state.  Each multibyte character is
        #            converted to a wide character as if by a call to the
        #            mbrtowc function, with the conversion state described by
        #            an mbstate_t object initialized to zero before the first
        #            multibyte character is converted.  The corresponding
        #            argument shall be a pointer to the initial element of an
        #            array of wchar_t large enough to accept the sequence and
        #            the terminating null wide character, which will be added
        #            automatically.
        #            The conversion specifier includes all subsequent
        #            characters in the format string, up to and including the
        #            matching right bracket (]).  The characters between the
        #            brackets (the scanlist) compose the scanset, unless the
        #            character after the left bracket is a circumflex (^), in
        #            which case the scanset contains all characters that do not
        #            appear in the scanlist between the circumflex and the
        #            right bracket.  If the conversion specifier begins with []
        #            or [^], the right bracket character is in the scanlist and
        #            the next following right bracket character is the matching
        #            right bracket that ends the specification; otherwise the
        #            first following right bracket character is the one that
        #            ends the specification.  If a - character is in the
        #            scanlist and is not the first, nor the second where the
        #            first character is a ^, nor the last character, the
        #            behavior is implementation-defined.
        /\].*?\]|\^\].*?\]|.*?\]/
      end
      private_class_method :scanset_re

      extend Forwardable

      def_delegator :@environment, :type_table
      private :type_table
    end
    private_constant :ConversionSpecifier

    class CompleteConversionSpecifier < ConversionSpecifier
      # === DESCRIPTION
      # Checks whether types of arguments match this directive.
      #
      # === RETURN VALUE
      # Boolean -- True if types of arguments match this directive.
      def acceptable?
        if @conversion_argument
          if argument_types
            argument_types.any? do |arg_type|
              @conversion_argument.type.convertible?(arg_type)
            end
          else
            true
          end
        else
          false
        end
      end

      # === DESCRIPTION
      # Checks whether the format string of this directive is the ISO C99
      # compliant.
      #
      # === RETURN VALUE
      # Boolean -- True if the format string is wellformed.
      def wellformed?
        valid_assignment_suppressing_character? && valid_field_width? &&
          valid_length_modifier? && valid_conversion_specifier_character?
      end

      def complete?
        true
      end

      def valid_length_modifier?
        if length_modifier.empty?
          true
        else
          suitable_length_modifiers.include?(length_modifier)
        end
      end

      private
      def argument_types
        if consume_arguments?
          subclass_responsibility
        else
          nil
        end
      end

      def suitable_length_modifiers
        subclass_responsibility
      end
    end
    private_constant :CompleteConversionSpecifier

    class Conversion_d < CompleteConversionSpecifier
      def self.suitable_conversion_specifier_character
        "d"
      end

      def initialize(fmt, trailing_args, env, as_char, field_width, len_mod,
                     cs_char, scanset)
        super(fmt, trailing_args, env, true, as_char, field_width, len_mod,
              cs_char, scanset)
      end

      def valid_assignment_suppressing_character?
        true
      end

      def valid_field_width?
        true
      end

      def valid_conversion_specifier_character?
        true
      end

      def valid_scanset?
        true
      end

      private
      def argument_types
        # NOTE: The ISO C99 standard says;
        #
        # 7.19.6.2 The fscanf function
        #
        # 11 The length modifiers and their meanings are:
        #
        #    hh Specifies that a following d, i, o, u, x, X, or n conversion
        #       specifier applies to an argument with type pointer to signed
        #       char or unsigned char.
        #    h  Specifies that a following d, i, o, u, x, X, or n conversion
        #       specifier applies to an argument with type pointer to short int
        #       or unsigned short int.
        #    l  Specifies that a following d, i, o, u, x, X, or n conversion
        #       specifier applies to an argument with type pointer to long int
        #       or unsigned long int; that a following a, A, e, E, f, F, g, or
        #       G conversion specifier applies to an argument with type pointer
        #       to double; or that a following c, s, or [ conversion specifier
        #       applies to an argument with type pointer to wchar_t.
        #    ll Specifies that a following d, i, o, u, x, X, or n conversion
        #       specifier applies to an argument with type pointer to long long
        #       int or unsigned long long int.
        #    j  Specifies that a following d, i, o, u, x, X, or n conversion
        #       specifier applies to an argument with type pointer to intmax_t
        #       or uintmax_t.
        #    z  Specifies that a following d, i, o, u, x, X, or n conversion
        #       specifier applies to an argument with type pointer to size_t or
        #       the corresponding signed integer type.
        #    t  Specifies that a following d, i, o, u, x, X, or n conversion
        #       specifier applies to an argument with type pointer to ptrdiff_t
        #       or the corresponding unsigned integer type.
        case length_modifier
        when "hh"
          [pointer_type(signed_char_t), pointer_type(unsigned_char_t)]
        when "h"
          [pointer_type(signed_short_t), pointer_type(unsigned_short_t)]
        when "l"
          [pointer_type(signed_long_t), pointer_type(unsigned_long_t)]
        when "ll"
          [pointer_type(signed_long_long_t),
            pointer_type(unsigned_long_long_t)]
        when "j"
          # FIXME: `intmax_t' and `uintmax_t' are not supported yet.
          [pointer_type(signed_long_long_t),
            pointer_type(unsigned_long_long_t)]
        when "z"
          # FIXME: `size_t' is not supported yet.
          [pointer_type(signed_long_t), pointer_type(unsigned_long_t)]
        when "t"
          # FIXME: `ptrdiff_t' is not supported yet.
          [pointer_type(signed_int_t), pointer_type(unsigned_int_t)]
        else
          default_argument_types
        end
      end

      def suitable_length_modifiers
        ["hh", "h", "l", "ll", "j", "z", "t"]
      end

      def default_argument_types
        [pointer_type(signed_int_t)]
      end
    end
    private_constant :Conversion_d

    class Conversion_i < Conversion_d
      def self.suitable_conversion_specifier_character
        "i"
      end
    end
    private_constant :Conversion_i

    class Conversion_o < Conversion_d
      def self.suitable_conversion_specifier_character
        "o"
      end

      private
      def default_argument_types
        [pointer_type(unsigned_int_t)]
      end
    end
    private_constant :Conversion_o

    class Conversion_u < Conversion_o
      def self.suitable_conversion_specifier_character
        "u"
      end
    end
    private_constant :Conversion_u

    class Conversion_x < Conversion_o
      def self.suitable_conversion_specifier_character
        "x"
      end
    end
    private_constant :Conversion_x

    class Conversion_X < Conversion_o
      def self.suitable_conversion_specifier_character
        "X"
      end
    end
    private_constant :Conversion_X

    class Conversion_a < CompleteConversionSpecifier
      def self.suitable_conversion_specifier_character
        "a"
      end

      def initialize(fmt, trailing_args, env, as_char, field_width, len_mod,
                     cs_char, scanset)
        super(fmt, trailing_args, env, true, as_char, field_width, len_mod,
              cs_char, scanset)
      end

      def valid_assignment_suppressing_character?
        true
      end

      def valid_field_width?
        true
      end

      def valid_conversion_specifier_character?
        true
      end

      def valid_scanset?
        true
      end

      private
      def argument_types
        # NOTE: The ISO C99 standard says;
        #
        # 7.19.6.2 The fscanf function
        #
        # 11 The length modifiers and their meanings are:
        #
        #    l  Specifies that a following d, i, o, u, x, X, or n conversion
        #       specifier applies to an argument with type pointer to long int
        #       or unsigned long int; that a following a, A, e, E, f, F, g, or
        #       G conversion specifier applies to an argument with type pointer
        #       to double; or that a following c, s, or [ conversion specifier
        #       applies to an argument with type pointer to wchar_t.
        #    L  Specifies that a following a, A, e, E, f, F, g, or G conversion
        #       specifier applies to an argument with type pointer to long
        #       double.
        case length_modifier
        when "l"
          [pointer_type(double_t)]
        when "L"
          [pointer_type(long_double_t)]
        else
          [pointer_type(float_t)]
        end
      end

      def suitable_length_modifiers
        ["l", "L"]
      end
    end
    private_constant :Conversion_a

    class Conversion_A < Conversion_a
      def self.suitable_conversion_specifier_character
        "A"
      end
    end
    private_constant :Conversion_A

    class Conversion_e < Conversion_a
      def self.suitable_conversion_specifier_character
        "e"
      end
    end
    private_constant :Conversion_e

    class Conversion_E < Conversion_a
      def self.suitable_conversion_specifier_character
        "E"
      end
    end
    private_constant :Conversion_E

    class Conversion_f < Conversion_a
      def self.suitable_conversion_specifier_character
        "f"
      end
    end
    private_constant :Conversion_f

    class Conversion_F < Conversion_a
      def self.suitable_conversion_specifier_character
        "F"
      end
    end
    private_constant :Conversion_F

    class Conversion_g < Conversion_a
      def self.suitable_conversion_specifier_character
        "g"
      end
    end
    private_constant :Conversion_g

    class Conversion_G < Conversion_a
      def self.suitable_conversion_specifier_character
        "G"
      end
    end
    private_constant :Conversion_G

    class Conversion_c < CompleteConversionSpecifier
      def self.suitable_conversion_specifier_character
        "c"
      end

      def initialize(fmt, trailing_args, env, as_char, field_width, len_mod,
                     cs_char, scanset)
        super(fmt, trailing_args, env, true, as_char, field_width, len_mod,
              cs_char, scanset)
      end

      def valid_assignment_suppressing_character?
        true
      end

      def valid_field_width?
        true
      end

      def valid_conversion_specifier_character?
        true
      end

      def valid_scanset?
        true
      end

      private
      def argument_types
        # NOTE: The ISO C99 standard says;
        #
        # 7.19.6.2 The fscanf function
        #
        # 11 The length modifiers and their meanings are:
        #
        #    l  Specifies that a following d, i, o, u, x, X, or n conversion
        #       specifier applies to an argument with type pointer to long int
        #       or unsigned long int; that a following a, A, e, E, f, F, g, or
        #       G conversion specifier applies to an argument with type pointer
        #       to double; or that a following c, s, or [ conversion specifier
        #       applies to an argument with type pointer to wchar_t.
        case length_modifier
        when "l"
          [pointer_type(wchar_t)]
        else
          [pointer_type(signed_char_t), pointer_type(unsigned_char_t)]
        end
      end

      def suitable_length_modifiers
        ["l"]
      end
    end
    private_constant :Conversion_c

    class Conversion_s < Conversion_c
      def self.suitable_conversion_specifier_character
        "s"
      end
    end
    private_constant :Conversion_s

    class Conversion_bracket < Conversion_c
      def self.suitable_conversion_specifier_character
        "["
      end

      def valid_scanset?
        # NOTE: The `-' character in the scanset causes implementation-defined
        #       behavior.  So, AdLint treats the `-' character as an ordinary
        #       character in the scanset.
        orig_set = scanset.chop.chars.to_a
        uniq_set = orig_set.uniq
        orig_set.size == uniq_set.size
      end
    end
    private_constant :Conversion_bracket

    class Conversion_p < CompleteConversionSpecifier
      def self.suitable_conversion_specifier_character
        "p"
      end

      def initialize(fmt, trailing_args, env, as_char, field_width, len_mod,
                     cs_char, scanset)
        super(fmt, trailing_args, env, true, as_char, field_width, len_mod,
              cs_char, scanset)
      end

      def valid_assignment_suppressing_character?
        true
      end

      def valid_field_width?
        true
      end

      def valid_conversion_specifier_character?
        true
      end

      def valid_scanset?
        true
      end

      private
      def argument_types
        if conversion_argument && conversion_argument.type.pointer?
          [conversion_argument.type.unqualify]
        else
          [pointer_type(void_t)]
        end
      end

      def suitable_length_modifiers
        []
      end
    end
    private_constant :Conversion_p

    class Conversion_n < CompleteConversionSpecifier
      def self.suitable_conversion_specifier_character
        "n"
      end

      def initialize(fmt, trailing_args, env, as_char, field_width, len_mod,
                     cs_char, scanset)
        super(fmt, trailing_args, env, true, as_char, field_width, len_mod,
              cs_char, scanset)
      end

      def valid_assignment_suppressing_character?
        # NOTE: The ISO C99 standard says;
        #
        # 7.19.6.2 The fscanf function
        #
        # 12 The conversion specifiers and their meanings are:
        #
        #    n       No input is consumed.  The corresponding argument shall be
        #            a pointer to signed integer into which is to be written
        #            the number of characters read from the input stream so far
        #            by this call to the fscanf function.  Execution of a %n
        #            directive does not increment the assignment count returned
        #            at the completion of execution of the fscanf function.  No
        #            argument is converted, but one is consumed.  If the
        #            conversion specification includes an
        #            assignment-suppressing character or a field width, the
        #            behavior is undefined.
        assignment_suppressing_character.empty?
      end

      def valid_field_width?
        field_width.empty?
      end

      def valid_conversion_specifier_character?
        true
      end

      def valid_scanset?
        true
      end

      private
      def argument_types
        # NOTE: The ISO C99 standard says;
        #
        # 7.19.6.2 The fscanf function
        #
        # 11 The length modifiers and their meanings are:
        #
        #    hh Specifies that a following d, i, o, u, x, X, or n conversion
        #       specifier applies to an argument with type pointer to signed
        #       char or unsigned char.
        #    h  Specifies that a following d, i, o, u, x, X, or n conversion
        #       specifier applies to an argument with type pointer to short int
        #       or unsigned short int.
        #    l  Specifies that a following d, i, o, u, x, X, or n conversion
        #       specifier applies to an argument with type pointer to long int
        #       or unsigned long int; that a following a, A, e, E, f, F, g, or
        #       G conversion specifier applies to an argument with type pointer
        #       to double; or that a following c, s, or [ conversion specifier
        #       applies to an argument with type pointer to wchar_t.
        #    ll Specifies that a following d, i, o, u, x, X, or n conversion
        #       specifier applies to an argument with type pointer to long long
        #       int or unsigned long long int.
        #    j  Specifies that a following d, i, o, u, x, X, or n conversion
        #       specifier applies to an argument with type pointer to intmax_t
        #       or uintmax_t.
        #    z  Specifies that a following d, i, o, u, x, X, or n conversion
        #       specifier applies to an argument with type pointer to size_t or
        #       the corresponding signed integer type.
        #    t  Specifies that a following d, i, o, u, x, X, or n conversion
        #       specifier applies to an argument with type pointer to ptrdiff_t
        #       or the corresponding unsigned integer type.
        case length_modifier
        when "hh"
          [pointer_type(signed_char_t), pointer_type(unsigned_char_t)]
        when "h"
          [pointer_type(signed_short_t), pointer_type(unsigned_short_t)]
        when "l"
          [pointer_type(signed_long_t), pointer_type(unsigned_long_t)]
        when "ll"
          [pointer_type(signed_long_long_t),
            pointer_type(unsigned_long_long_t)]
        when "j"
          # FIXME: `intmax_t' and `uintmax_t' are not supported yet.
          [pointer_type(signed_long_long_t),
            pointer_type(unsigned_long_long_t)]
        when "z"
          # FIXME: `size_t' is not supported yet.
          [pointer_type(signed_long_t), pointer_type(unsigned_long_t)]
        when "t"
          # FIXME: `ptrdiff_t' is not supported yet.
          [pointer_type(signed_int_t), pointer_type(unsigned_int_t)]
        else
          [pointer_type(signed_int_t)]
        end
      end

      def suitable_length_modifiers
        ["hh", "h", "l", "ll", "j", "z", "t"]
      end
    end
    private_constant :Conversion_n

    class Conversion_percent < CompleteConversionSpecifier
      def self.suitable_conversion_specifier_character
        "%"
      end

      def initialize(fmt, trailing_args, env, as_char, field_width, len_mod,
                     cs_char, scanset)
        super(fmt, trailing_args, env, false, as_char, field_width, len_mod,
              cs_char, scanset)
      end

      def valid_assignment_suppressing_character?
        # NOTE: The ISO C99 standard says;
        #
        # 7.19.6.2 The fscanf function
        #
        # 12 The conversion specifiers and their meanings are:
        #
        #    %       Matches a single % character; no conversion or assignment
        #            occurs.  The complete conversion specification shall be
        #            %%.
        assignment_suppressing_character.empty?
      end

      def valid_field_width?
        field_width.empty?
      end

      def valid_conversion_specifier_character?
        true
      end

      def valid_scanset?
        true
      end

      private
      def argument_types
        nil
      end

      def suitable_length_modifiers
        []
      end
    end
    private_constant :Conversion_percent

    class UndefinedConversionSpecifier < CompleteConversionSpecifier
      def initialize(fmt, as_char, field_width, len_mod, cs_char)
        super(fmt, [], nil, false, as_char, field_width, len_mod, cs_char, nil)
      end

      def undefined?
        true
      end

      def valid_assignment_suppressing_character?
        false
      end

      def valid_field_width?
        false
      end

      def valid_conversion_specifier_character?
        false
      end

      def valid_scanset?
        true
      end

      private
      def argument_types
        nil
      end

      def suitable_length_modifiers
        []
      end
    end
    private_constant :UndefinedConversionSpecifier

    class IncompleteConversionSpecifier < ConversionSpecifier
      def initialize(fmt, as_char, field_width, len_mod, cs_char)
        super(fmt, [], nil, false, as_char, field_width, len_mod, cs_char, nil)
      end

      # === DESCRIPTION
      # Checks whether types of arguments match this directive.
      #
      # === RETURN VALUE
      # Boolean -- True if types of arguments match this directive.
      def acceptable?
        false
      end

      # === DESCRIPTION
      # Checks whether the format string of this directive is the ISO C99
      # compliant.
      #
      # === RETURN VALUE
      # Boolean -- True if the format string is wellformed.
      def wellformed?
        false
      end

      def complete?
        false
      end

      def undefined?
        true
      end

      def valid_assignment_suppressing_character?
        false
      end

      def valid_field_width?
        false
      end

      def valid_length_modifier?
        false
      end

      def valid_conversion_specifier_character?
        conversion_specifier_character == "["
      end

      def valid_scanset?
        conversion_specifier_character == "[" ? !scanset.nil? : false
      end
    end
    private_constant :IncompleteConversionSpecifier

    CONVERSION_SPECIFIERS = [
      Conversion_d,
      Conversion_i,
      Conversion_o,
      Conversion_u,
      Conversion_x,
      Conversion_X,
      Conversion_a,
      Conversion_A,
      Conversion_e,
      Conversion_E,
      Conversion_f,
      Conversion_F,
      Conversion_g,
      Conversion_G,
      Conversion_c,
      Conversion_s,
      Conversion_bracket,
      Conversion_p,
      Conversion_n,
      Conversion_percent
    ]
    private_constant :CONVERSION_SPECIFIERS

    CONVERSION_SPECIFIER_TBL =
      CONVERSION_SPECIFIERS.each_with_object({}) { |cs_class, hash|
        hash[cs_class.suitable_conversion_specifier_character] = cs_class
      }.freeze
    private_constant :CONVERSION_SPECIFIER_TBL
  end

end
end
