# Sequence points of C language evaluation.
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
module Cc1 #:nodoc:

  # NOTE: The ISO C99 standard says;
  #
  # Annex C (informative) Sequence points
  #
  # 1 The following are the sequence points described in 5.1.2.3:
  #
  #   -- The call to a function, after the arguments have been evaluated
  #      (6.5.2.2).
  #   -- The end of the first operand of the following operators: logical AND
  #      && (6.5.13); logical OR || (6.5.14); conditional ? (6.5.15); comma ,
  #      (6.5.17).
  #   -- The end of a full declarator: declarators (6.7.5).
  #   -- The end of a full expression: an initializer (6.7.8); the expression
  #      in an expression statement (6.8.3); the controlling expression of a
  #      while or do statement (6.8.5); each of the expressions of a for
  #      statement (6.8.5.3); the expression in a return statement (6.8.6.4).
  #   -- Immediately before a library function returns (7.1.4).
  #   -- After the actions associated with each formatted input/output function
  #      conversion specifier (7.19.6, 7.24.2).
  #   -- Immediately before and immediately after each call to a comparison
  #      function, and also between any call to a comparison function and any
  #      movement of the objects passed as arguments to that call (7.20.5).

  class SequencePoint
    include LocationHolder

    def initialize(lst_node, obvious = true)
      @last_node = lst_node
      @obvious = obvious
    end

    attr_reader :last_node

    def location
      @last_node.location
    end

    def obvious?
      @obvious
    end
  end

end
end
