# Scanner for C language.
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

module AdLint #:nodoc:
module Cc1 #:nodoc:

  # == DESCRIPTION
  # Constants for scanning the C source code.
  module ScannerConstants
    # === DESCRIPTION
    # C keywords table.
    KEYWORDS = {
      "sizeof" => :SIZEOF,
      "typedef" => :TYPEDEF,
      "extern" => :EXTERN,
      "static" => :STATIC,
      "auto" => :AUTO,
      "register" => :REGISTER,
      "inline" => :INLINE,
      "restrict" => :RESTRICT,
      "char" => :CHAR,
      "short" => :SHORT,
      "int" => :INT,
      "long" => :LONG,
      "signed" => :SIGNED,
      "unsigned" => :UNSIGNED,
      "float" => :FLOAT,
      "double" => :DOUBLE,
      "const" => :CONST,
      "volatile" => :VOLATILE,
      "void" => :VOID,
      "_Bool" => :BOOL,
      "_Complex" => :COMPLEX,
      "_Imaginary" => :IMAGINARY,
      "struct" => :STRUCT,
      "union" => :UNION,
      "enum" => :ENUM,
      "case" => :CASE,
      "default" => :DEFAULT,
      "if" => :IF,
      "else" => :ELSE,
      "switch" => :SWITCH,
      "while" => :WHILE,
      "do" => :DO,
      "for" => :FOR,
      "goto" => :GOTO,
      "continue" => :CONTINUE,
      "break" => :BREAK,
      "return" => :RETURN,
      "__typeof__" => :TYPEOF,
      "__alignof__" => :ALIGNOF
    }.freeze

    KEYWORD_VALUES = KEYWORDS.keys.to_set.freeze

    # === DESCRIPTION
    # C punctuators table.
    PUNCTUATORS = [
      "{", "}", "(", ")", "[", "]", ";", ",", "::", ":", "?", "||",
      "|=", "|", "&&", "&=", "&", "^=", "^", "==", "=", "!=", "!",
      "<<=", "<=", "<<", "<", ">>=", ">=", ">>", ">", "+=", "++", "+",
      "->*", "->", "-=", "--", "-", "*=", "*", "/=", "/", "%=", "%",
      "...", ".*", ".", "~",
    ].to_set.freeze
  end

  # == DESCRIPTION
  # Utility module for scanning the C source code.
  module Scanner
    include ScannerConstants

    # === DESCRIPTION
    # Scans C identifier.
    #
    # === PARAMETER
    # _cont_:: StringContent -- Scanning source.
    #
    # === RETURN VALUE
    # String -- Returns C identifier string if found at head of the content.
    def scan_identifier(cont)
      cont.scan(/[a-z_][a-z_0-9]*\b/i)
    end

    KEYWORDS_RE = Regexp.new(KEYWORD_VALUES.map { |keyword|
      "#{keyword}\\b"
    }.join("|")).freeze
    private_constant :KEYWORDS_RE

    # === DESCRIPTION
    # Scans C keyword.
    #
    # === PARAMETER
    # _cont_:: StringContent -- Scanning source.
    #
    # === RETURN VALUE
    # String -- Returns C keyword string if found at head of the content.
    def scan_keyword(cont)
      cont.scan(KEYWORDS_RE)
    end

    PUNCTUATORS_RE = Regexp.new(PUNCTUATORS.sort { |a, b|
      b.length <=> a.length
    }.map { |punct|
      punct.each_char.map { |ch| '\\' + ch }.join
    }.join("|")).freeze
    private_constant :PUNCTUATORS_RE

    # === DESCRIPTION
    # Scans C punctuator.
    #
    # === PARAMETER
    # _cont_:: StringContent -- Scanning source.
    #
    # === RETURN VALUE
    # String -- Returns C punctuator string if found at head of the content.
    def scan_punctuator(cont)
      cont.scan(PUNCTUATORS_RE)
    end

    # === DESCRIPTION
    # Scans C integer constant.
    #
    # === PARAMETER
    # _cont_:: StringContent -- Scanning source.
    #
    # === RETURN VALUE
    # String -- Returns C integer constant string if found at head of the
    # content.
    def scan_integer_constant(cont)
      cont.scan(/(?:0x[0-9a-f]+|0b[01]+|[0-9]+)[UL]*/i)
    end

    FLOATING1_RE = /(?:[0-9]*\.[0-9]*E[+-]?[0-9]+|[0-9]+\.?E[+-]?[0-9]+)[FL]*/i
    FLOATING2_RE = /(?:[0-9]*\.[0-9]+|[0-9]+\.)[FL]*/i
    private_constant :FLOATING1_RE, :FLOATING2_RE

    # === DESCRIPTION
    # Scans C floating constant.
    #
    # === PARAMETER
    # _cont_:: StringContent -- Scanning source.
    #
    # === RETURN VALUE
    # String -- Returns C floating constant string if found at head of the
    # content.
    def scan_floating_constant(cont)
      cont.scan(FLOATING1_RE) || cont.scan(FLOATING2_RE)
    end

    # === DESCRIPTION
    # Scans C character constant.
    #
    # === PARAMETER
    # _cont_:: StringContent -- Scanning source.
    #
    # === RETURN VALUE
    # String -- Returns C character constant string if found at head of the
    # content.
    def scan_char_constant(cont)
      unless scanned = cont.scan(/L?'/i)
        return nil
      end

      until cont.empty?
        if str = cont.scan(/.*?(?=\\|')/m)
          scanned << str
        end
        next if cont.scan(/\\[ \t]*\n/)

        case
        when cont.check(/\\/)
          scanned << cont.eat!(2)
        when quote = cont.scan(/'/)
          scanned << quote
          break
        end
      end

      scanned
    end

    # === DESCRIPTION
    # Scans C string literal.
    #
    # === PARAMETER
    # _cont_:: StringContent -- Scanning source.
    #
    # === RETURN VALUE
    # String -- Returns C string literal string if found at head of the
    # content.
    def scan_string_literal(cont)
      unless scanned = cont.scan(/L?"/i)
        return nil
      end

      until cont.empty?
        if str = cont.scan(/.*?(?=\\|")/m)
          scanned << str
        end
        next if cont.scan(/\\[ \t]*\n/)

        case
        when cont.check(/\\/)
          scanned << cont.eat!(2)
        when quote = cont.scan(/"/)
          scanned << quote
          break
        end
      end

      scanned
    end

    # === DESCRIPTION
    # Scans C NULL constant.
    #
    # === PARAMETER
    # _cont_:: StringContent -- Scanning source.
    #
    # === RETURN VALUE
    # String -- Returns C NULL constant string if found at head of the content.
    def scan_null_constant(cont)
      cont.scan(/NULL\b/)
    end
  end

end
end
