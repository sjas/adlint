# Comparison operator of controlling expressions.
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

  class Operator
    def initialize(tok_or_sym)
      case tok_or_sym
      when Token
        @sym = tok_or_sym.type.to_sym
      when ::Symbol
        @sym = tok_or_sym
      end
    end

    def to_sym
      @sym
    end

    def to_s
      @sym.to_s
    end

    def eql?(rhs)
      case rhs
      when Operator
        @sym == rhs.to_sym
      else
        super
      end
    end

    alias :== :eql?

    def hash
      @sym.hash
    end
  end

  class ComparisonOperator < Operator
    def for_complement
      case self
      when Operator::EQ then Operator::NE
      when Operator::NE then Operator::EQ
      when Operator::LT then Operator::GE
      when Operator::GT then Operator::LE
      when Operator::LE then Operator::GT
      when Operator::GE then Operator::LT
      else self
      end
    end

    def for_commutation
      case self
      when Operator::LT then Operator::GT
      when Operator::GT then Operator::LT
      when Operator::LE then Operator::GE
      when Operator::GE then Operator::LE
      else self
      end
    end
  end

  class Operator
    EQ = ComparisonOperator.new(:==)
    NE = ComparisonOperator.new(:!=)
    LT = ComparisonOperator.new(:<)
    GT = ComparisonOperator.new(:>)
    LE = ComparisonOperator.new(:<=)
    GE = ComparisonOperator.new(:>=)
  end

end
end
