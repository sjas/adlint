# Inline assembly notations.
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

require "adlint/cpp/subst"

module AdLint #:nodoc:
module Cpp #:nodoc:

  module InlineAssemblyDefinition
    def create_inline_assembly_substitutions(src)
      [create_cxx_asm_definition(src)] + create_extended_asm_definitions(src)
    end

    def create_cxx_asm_definition(src)
      CodeSubstitution.new("asm(__adlint__any);", "").tap do |sub|
        sub.on_substitution += lambda { |matched_toks|
          src.on_inline_assembly.invoke(matched_toks)
        }
      end
    end

    def create_extended_asm_definitions(src)
      [
        "__asm(__adlint__any);",
        "asm { __adlint__any }",
        "__asm { __adlint__any }",
        "__asm__(__adlint__any);",
        "__asm__ volatile (__adlint__any);",
        "__asm__ __volatile__ (__adlint__any);",
        "asm(__adlint__any);",
        "asm volatile (__adlint__any);",
        "asm __volatile__ (__adlint__any);"
      ].map do |ptn|
        CodeSubstitution.new(ptn, "").tap { |sub|
          sub.on_substitution += lambda { |matched_toks|
            src.on_inline_assembly.invoke(matched_toks)
          }
        }
      end
    end
  end

end
end
