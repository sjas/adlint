# Reference recordable symbols.
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

require "adlint/source"

module AdLint #:nodoc:

  class Symbol
    def initialize(id)
      @identifier = id
      @referred   = false
    end

    attr_writer :referred

    def location
      @identifier.location
    end

    def to_s
      subclass_responsibility
    end

    def useless?
      !@referred
    end
  end

  class MacroName < Symbol
    def to_s
      @identifier.value
    end
  end

  class ObjectName < Symbol
    def to_s
      @identifier.value
    end
  end

  class TypedefName < Symbol
    def to_s
      @identifier.value
    end
  end

  class StructTag < Symbol
    def to_s
      "struct #{@identifier.value}"
    end
  end

  class UnionTag < Symbol
    def to_s
      "union #{@identifier.value}"
    end
  end

  class EnumTag < Symbol
    def to_s
      "enum #{@identifier.value}"
    end
  end

  class EnumeratorName < Symbol
    def to_s
      @identifier.value
    end
  end

  class SymbolTable
    def initialize
      @hash = Hash.new { |hash, key| hash[key] = [] }
    end

    def create_new_symbol(sym_class, id)
      sym = sym_class.new(id)
      @hash[sym.location.fpath].push(sym)
      sym
    end

    def symbols_appeared_in(src)
      @hash[src.fpath]
    end
  end

  module SymbolicElement
    # NOTE: Host class must respond to #symbol.

    def mark_as_referred_by(tok)
      unless tok.location.fpath == symbol.location.fpath
        symbol.referred = true
      end
    end
  end

end
