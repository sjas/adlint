# Metric measurements (ld-phase) of adlint-exam-c_builtin package.
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

require "adlint/exam"
require "adlint/report"
require "adlint/ld/phase"

module AdLint #:nodoc:
module Exam #:nodoc:
module CBuiltin #:nodoc:

  class FN_CALL < MetricMeasurement
    def_registrant_phase Ld::PreparePhase

    def initialize(phase_ctxt)
      super
      phase_ctxt[:ld_function_traversal].on_definition += T(:measure)
      @call_graph = phase_ctxt[:ld_call_graph]
    end

    private
    def do_prepare(*) end
    def do_execute(*) end

    def measure(fun)
      FN_CALL(FunctionId.new(fun.name, fun.signature), fun.location,
              @call_graph.all_callers_of(fun).count { |ref| ref.function })
    end
  end

end
end
end
