# Lexical token classes.
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

require "adlint/location"

module AdLint #:nodoc:

  # == DESCRIPTION
  # Token.
  class Token
    include LocationHolder
    include Comparable

    # === DESCRIPTION
    # Constructs a token.
    #
    # === PARAMETER
    # _type_:: Symbol | String -- Type of the token.
    # _val_:: String -- String value of the token.
    # _loc_:: Location -- Location of the token.
    # _type_hint_:: Symbol | String -- Hint of the token type.
    def initialize(type, val, loc, type_hint = nil)
      @type, @value, @location = type, val, loc
      @type_hint = type_hint
    end

    # === VALUE
    # Symbol | String -- Type of this token.
    attr_reader :type

    # === VALUE
    # String -- Value of this token.
    attr_reader :value

    # === VALUE
    # Location -- Location of this token.
    attr_reader :location

    # === VALUE
    # Symbol | String -- Hint of the type of this token.
    attr_reader :type_hint

    def replaced?
      false
    end

    def need_no_further_replacement?
      false
    end

    # === DESCRIPTION
    # Compares tokens.
    #
    # === PARAMETER
    # _rhs_:: Token -- Right-hand-side token.
    #
    # === RETURN VALUE
    # Integer -- Comparision result.
    def <=>(rhs)
      case rhs
      when Symbol, String
        @type <=> rhs
      when Token
        if (type_diff = @type <=> rhs.type) == 0
          if (val_diff = @value <=> rhs.value) == 0
            @location <=> rhs.location
          else
            val_diff
          end
        else
          type_diff
        end
      else
        raise TypeError
      end
    end

    def eql?(rhs_tok)
      @type == rhs_tok.type && @value == rhs_tok.value &&
        @location == rhs_tok.location
    end

    def hash
      [@type, @value, @location].hash
    end
  end

  class ReplacedToken < Token
    def initialize(type, val, loc, type_hint = nil, no_further_repl = true)
      super(type, val, loc, type_hint)
      @need_no_further_replacement = no_further_repl
    end

    def need_no_further_replacement?
      @need_no_further_replacement
    end

    def replaced?
      true
    end

    def eql?(rhs_tok)
      equal?(rhs_tok)
    end

    def hash
      object_id
    end
  end

  # == DESCRIPTION
  # Array of tokens.
  class TokenArray < Array; end

end
