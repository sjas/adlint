# Phases of cross module analysis.
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
require "adlint/annot"
require "adlint/cpp/lexer"
require "adlint/ld/object"
require "adlint/ld/typedef"
require "adlint/ld/util"

module AdLint #:nodoc:
module Ld #:nodoc:

  class LdPhase < Phase
    def initialize(phase_ctxt, phase_name)
      super(phase_ctxt, "ld", phase_name)
    end
  end

  class MapTypedefPhase < LdPhase
    def initialize(phase_ctxt)
      super(phase_ctxt, "mtd")
    end

    private
    def do_execute(phase_ctxt, monitor)
      mapper = TypedefMapper.new
      phase_ctxt[:metric_fpaths].each do |fpath|
        mapper.execute(fpath)
        monitor.progress += 1.0 / phase_ctxt[:metric_fpaths].size
      end
      phase_ctxt[:ld_typedef_mapping] = mapper.result
    end
  end

  class MapFunctionPhase < LdPhase
    def initialize(phase_ctxt)
      super(phase_ctxt, "mfn")
    end

    private
    def do_execute(phase_ctxt, monitor)
      mapper = FunctionMapper.new
      phase_ctxt[:metric_fpaths].each do |fpath|
        mapper.execute(fpath)
        monitor.progress += 1.0 / phase_ctxt[:metric_fpaths].size
      end
      phase_ctxt[:ld_function_mapping] = mapper.result
    end
  end

  class MapVariablePhase < LdPhase
    def initialize(phase_ctxt)
      super(phase_ctxt, "mvr")
    end

    private
    def do_execute(phase_ctxt, monitor)
      mapper = VariableMapper.new
      phase_ctxt[:metric_fpaths].each do |fpath|
        mapper.execute(fpath)
        monitor.progress += 1.0 / phase_ctxt[:metric_fpaths].size
      end
      phase_ctxt[:ld_variable_mapping] = mapper.result
    end
  end

  class LinkFunctionPhase < LdPhase
    def initialize(phase_ctxt)
      super(phase_ctxt, "lfn")
    end

    private
    def do_execute(phase_ctxt, monitor)
      builder = FunctionCallGraphBuilder.new(phase_ctxt[:ld_function_mapping])
      phase_ctxt[:metric_fpaths].each do |fpath|
        builder.execute(fpath)
        monitor.progress += 1.0 / phase_ctxt[:metric_fpaths].size
      end
      phase_ctxt[:ld_function_call_graph] = builder.result
    ensure
      DebugUtil.dump_function_call_graph(phase_ctxt)
    end
  end

  class LinkVariablePhase < LdPhase
    def initialize(phase_ctxt)
      super(phase_ctxt, "lvr")
    end

    private
    def do_execute(phase_ctxt, monitor)
      builder = VariableReferenceGraphBuilder.new(
        phase_ctxt[:ld_variable_mapping], phase_ctxt[:ld_function_mapping],
        phase_ctxt[:ld_function_call_graph])
      phase_ctxt[:metric_fpaths].each do |fpath|
        builder.execute(fpath)
        monitor.progress += 1.0 / phase_ctxt[:metric_fpaths].size
      end
      phase_ctxt[:ld_variable_reference_graph] = builder.result
    ensure
      DebugUtil.dump_variable_reference_graph(phase_ctxt)
    end
  end

  class PreparePhase < LdPhase
    def initialize(phase_ctxt)
      super(phase_ctxt, "pre")
    end

    private
    def do_execute(phase_ctxt, *)
      collect_annotations
      phase_ctxt[:ld_typedef_traversal] =
        TypedefTraversal.new(phase_ctxt[:ld_typedef_mapping])
      phase_ctxt[:ld_function_traversal] =
        FunctionTraversal.new(phase_ctxt[:ld_function_mapping])
      phase_ctxt[:ld_variable_traversal] =
        VariableTraversal.new(phase_ctxt[:ld_variable_mapping])
    end

    def collect_annotations
      composing_fpaths.each do |fpath|
        lexer = Cpp::Lexer.new(
          Source.new(fpath, traits.of_project.file_encoding), traits)

        parser = method(:parse_annotation)
        lexer.on_line_comment_found  += parser
        lexer.on_block_comment_found += parser
        while lexer.next_token; end
      end
    end

    def composing_fpaths
      @phase_ctxt[:ld_function_mapping].composing_fpaths +
      @phase_ctxt[:ld_variable_mapping].composing_fpaths +
      @phase_ctxt[:ld_typedef_mapping].composing_fpaths
    end

    def parse_annotation(comment, loc)
      if annot = Annotation.parse(comment, loc)
        @phase_ctxt[:annotations].push(annot)
        if annot.message_suppression_specifier? &&
            traits.of_message.individual_suppression
          @phase_ctxt[:suppressors].add(annot.create_suppressor)
        end
      end
    end
  end

  class TypedefReviewPhase < LdPhase
    def initialize(phase_ctxt)
      super(phase_ctxt, "rtd")
    end

    private
    def do_execute(phase_ctxt, *)
      phase_ctxt[:ld_typedef_traversal].execute
    end
  end

  class FunctionReviewPhase < LdPhase
    def initialize(phase_ctxt)
      super(phase_ctxt, "rfn")
    end

    private
    def do_execute(phase_ctxt, *)
      phase_ctxt[:ld_function_traversal].execute
    end
  end

  class VariableReviewPhase < LdPhase
    def initialize(phase_ctxt)
      super(phase_ctxt, "rvr")
    end

    private
    def do_execute(phase_ctxt, *)
      phase_ctxt[:ld_variable_traversal].execute
    end
  end

  class ExaminationPhase < LdPhase
    def initialize(phase_ctxt)
      super(phase_ctxt, "exm")
    end

    private
    def do_execute(phase_ctxt, *)
      examinations.each { |exam| exam.execute }
    end
  end

end
end
