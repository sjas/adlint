# Builtin functions actually called by the interpreter.
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

require "adlint/cc1/type"
require "adlint/cc1/object"

module AdLint #:nodoc:
module Cc1 #:nodoc:

  class BuiltinFunction < NamedFunction
    def initialize(type_tbl, name)
      super(nil, type_tbl.builtin_function_type, name)
    end

    def explicit?
      true
    end

    def builtin?
      true
    end

    def call(interp, funcall_expr, args)
      interp.create_tmpvar(type.return_type)
    end
  end

  class InspectFunction < BuiltinFunction
    def initialize(type_tbl)
      super(type_tbl, "__adlint__inspect")
    end

    def call(*, args)
      puts "__adlint__inspect"
      args.each { |arg, expr| pp arg }
      puts "EOM"
      super
    end
  end

  class EvalFunction < BuiltinFunction
    def initialize(type_tbl)
      super(type_tbl, "__adlint__eval")
    end

    def call(interp, *, args)
      puts "__adlint__eval"
      char_ary = args.first.first
      if char_ary.type.array?
        without_nil = char_ary.value.to_single_value.values[0..-2]
        prog_text = without_nil.map { |char| char.unique_sample.chr }.join
        if prog_text.empty?
          puts "no program text"
        else
          eval prog_text
        end
        puts "EOM"
      end
      super
    end
  end

end
end
