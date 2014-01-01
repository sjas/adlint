# Programming language detection mechanism.
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

require "adlint/cpp/scanner"
require "adlint/cpp/phase"
require "adlint/cc1/scanner"
require "adlint/cc1/phase"

module AdLint #:nodoc:

  # == DESCRIPTION
  # Programming language.
  class Language
    # === DESCRIPTION
    # Detects programming language of the specified source file.
    #
    # === PARAMETER
    # _fpath_:: Pathname -- File path of the source file.
    #
    # === RETURN VALUE
    # Language -- Object of the derived class of Language class.
    def self.of(fpath)
      # FIXME: Dummy implementation.
      C
    end

    class Cpp
      extend ::AdLint::Cpp::Scanner

      class << self
        def single_module_phases; [] end
        def check_phases; [] end
      end
    end

    class C
      include Cc1::ScannerConstants
      extend  Cc1::Scanner

      class << self
        def single_module_phases
          [
            ::AdLint::Cpp::Prepare1Phase,
            ::AdLint::Cpp::Prepare2Phase,
            ::AdLint::Cpp::EvalPhase,
            ::AdLint::Cpp::SubstPhase,
            ::AdLint::Cc1::Prepare1Phase,
            ::AdLint::Cc1::ParsePhase,
            ::AdLint::Cc1::ResolvePhase,
            ::AdLint::Cc1::Prepare2Phase,
            ::AdLint::Cc1::InterpPhase,
            ::AdLint::Cpp::ReviewPhase,
            ::AdLint::Cc1::ReviewPhase,
            ::AdLint::Cpp::ExaminationPhase,
            ::AdLint::Cc1::ExaminationPhase
          ].freeze
        end

        def check_phases
          [
            ::AdLint::Cpp::Prepare1Phase,
            ::AdLint::Cpp::EvalPhase,
            ::AdLint::Cpp::SubstPhase,
            ::AdLint::Cc1::Prepare1Phase,
            ::AdLint::Cc1::ParsePhase
          ].freeze
        end
      end
    end
  end

end
