# Analysis phases for C language.
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

require "adlint/phase"
require "adlint/error"
require "adlint/cc1/lexer"
require "adlint/cc1/parser"
require "adlint/cc1/syntax"
require "adlint/cc1/interp"
require "adlint/cc1/util"

module AdLint #:nodoc:
module Cc1 #:nodoc:

  class CPhase < Phase
    def initialize(phase_ctxt, phase_name)
      super(phase_ctxt, "cc1", phase_name)
    end
  end

  class Prepare1Phase < CPhase
    def initialize(phase_ctxt)
      super(phase_ctxt, "pr3")
    end

    private
    def do_execute(phase_ctxt, *)
      phase_ctxt[:cc1_visitor] = SyntaxTreeMulticastVisitor.new
      phase_ctxt[:cc1_parser]  = Parser.new(phase_ctxt)
    end
  end

  class ParsePhase < CPhase
    def initialize(phase_ctxt)
      super(phase_ctxt, "prs")
    end

    private
    def do_execute(phase_ctxt, *)
      phase_ctxt[:cc1_syntax_tree] = phase_ctxt[:cc1_parser].execute
    ensure
      phase_ctxt[:cc1_token_array] = phase_ctxt[:cc1_parser].token_array
      DebugUtil.dump_token_array(phase_ctxt)
    end
  end

  class ResolvePhase < CPhase
    def initialize(phase_ctxt)
      super(phase_ctxt, "typ")
    end

    private
    def do_execute(phase_ctxt, *)
      resolver = StaticTypeResolver.new(TypeTable.new(traits, monitor, logger))
      phase_ctxt[:cc1_type_table] =
        resolver.resolve(phase_ctxt[:cc1_syntax_tree])
    end
  end

  class Prepare2Phase < CPhase
    def initialize(phase_ctxt)
      super(phase_ctxt, "pr4")
    end

    private
    def do_execute(phase_ctxt, *)
      phase_ctxt[:cc1_interpreter] =
        Interpreter.new(phase_ctxt[:cc1_type_table])
    end
  end

  class InterpPhase < CPhase
    def initialize(phase_ctxt)
      super(phase_ctxt, "int")
    end

    private
    def do_execute(phase_ctxt, *)
      Program.new(phase_ctxt[:cc1_interpreter],
                  phase_ctxt[:cc1_syntax_tree]).execute
      ValueDomain.clear_memos
    ensure
      DebugUtil.dump_syntax_tree(phase_ctxt)
    end
  end

  class ReviewPhase < CPhase
    def initialize(phase_ctxt)
      super(phase_ctxt, "rv2")
    end

    private
    def do_execute(phase_ctxt, *)
      phase_ctxt[:cc1_syntax_tree].accept(phase_ctxt[:cc1_visitor])
    end
  end

  class ExaminationPhase < CPhase
    def initialize(phase_ctxt)
      super(phase_ctxt, "ex2")
    end

    private
    def do_execute(phase_ctxt, *)
      examinations.each { |exam| exam.execute }
    end
  end

end
end
