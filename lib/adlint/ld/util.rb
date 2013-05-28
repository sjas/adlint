# Miscellaneous utilities for cross module analysis.
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

module AdLint #:nodoc:
module Ld #:nodoc:

  module DebugUtil
    def dump_function_call_graph(phase_ctxt)
      if $DEBUG
        proj_name = phase_ctxt.traits.of_project.project_name
        map_fname = Pathname.new("#{proj_name}.map")
        map_fpath = map_fname.expand_path(phase_ctxt.msg_fpath.dirname)

        map = phase_ctxt[:ld_function_map]
        call_graph = phase_ctxt[:ld_call_graph]
        return unless map && call_graph

        File.open(map_fpath, "w") do |io|
          io.puts("-- Function Call Graph --")
          map.all_functions.each do |callee|
            io.puts("DC of #{callee.signature}")
            call_graph.direct_callers_of(callee).each do |ref|
              if fun = ref.function
                io.puts(" #{fun.signature}")
              end
            end
            io.puts
            io.puts("IC of #{callee.signature}")
            call_graph.indirect_callers_of(callee).each do |ref|
              if fun = ref.function
                io.puts(" #{fun.signature}")
              end
            end
            io.puts
          end
        end
      end
    end
    module_function :dump_function_call_graph

    def dump_variable_reference_graph(phase_ctxt)
      if $DEBUG
        proj_name = phase_ctxt.traits.of_project.project_name
        map_fname = Pathname.new("#{proj_name}.map")
        map_fpath = map_fname.expand_path(phase_ctxt.msg_fpath.dirname)

        map = phase_ctxt[:ld_variable_map]
        ref_graph = phase_ctxt[:ld_xref_graph]
        return unless map && ref_graph

        File.open(map_fpath, "a") do |io|
          io.puts("-- Variable Reference Graph --")
          map.all_variables.each do |accessee|
            io.puts("DR of #{accessee.name}")
            ref_graph.direct_referrers_of(accessee).each do |ref|
              if fun = ref.function
                io.puts(" #{fun.signature}")
              end
            end
            io.puts
            io.puts("IR or #{accessee.name}")
            ref_graph.indirect_referrers_of(accessee).each do |ref|
              if fun = ref.function
                io.puts(" #{fun.signature}")
              end
            end
            io.puts
          end
        end
      end
    end
    module_function :dump_variable_reference_graph
  end

end
end
