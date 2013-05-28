# Analysis phases for C preprocessor language.
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
require "adlint/cpp/eval"
require "adlint/cpp/util"

module AdLint #:nodoc:
module Cpp #:nodoc:

  class CppPhase < Phase
    def initialize(phase_ctxt, phase_name)
      super(phase_ctxt, "cpp", phase_name)
    end
  end

  class Prepare1Phase < CppPhase
    def initialize(phase_ctxt)
      super(phase_ctxt, "pr1")
    end

    private
    def do_execute(phase_ctxt, *)
      root_src = phase_ctxt[:sources].first
      phase_ctxt[:cc1_source]        = PreprocessedSource.new(root_src)
      phase_ctxt[:cpp_macro_table]   = MacroTable.new
      phase_ctxt[:cpp_interpreter]   = Preprocessor.new
      phase_ctxt[:cpp_ast_traversal] = SyntaxTreeMulticastVisitor.new
      register_annotation_parser
    end

    def register_annotation_parser
      parser = method(:parse_annotation)
      @phase_ctxt[:cpp_interpreter].on_line_comment_found  += parser
      @phase_ctxt[:cpp_interpreter].on_block_comment_found += parser
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

  class Prepare2Phase < CppPhase
    def initialize(phase_ctxt)
      super(phase_ctxt, "pr2")
    end

    private
    def do_execute(*) end
  end

  class EvalPhase < CppPhase
    def initialize(phase_ctxt)
      super(phase_ctxt, "cpp")
    end

    private
    def do_execute(phase_ctxt, *)
      pp_ctxt = PreprocessContext.new(phase_ctxt)
      process_cinit_header(phase_ctxt, pp_ctxt)
      process_pinit_header(phase_ctxt, pp_ctxt)
      process_target_source(phase_ctxt, pp_ctxt)
    end

    def process_cinit_header(phase_ctxt, pp_ctxt)
      if fpath = traits.of_compiler.initial_header
        fenc = traits.of_project.file_encoding
        init_header = Source.new(Pathname.new(fpath), fenc)
      else
        init_header = EmptySource.new
      end
      phase_ctxt[:cpp_ast] =
        phase_ctxt[:cpp_interpreter].execute(pp_ctxt, init_header)
    end

    def process_pinit_header(phase_ctxt, pp_ctxt)
      if fpath = traits.of_project.initial_header
        fenc = traits.of_project.file_encoding
        init_header = Source.new(Pathname.new(fpath), fenc)
      else
        init_header = EmptySource.new
      end
      phase_ctxt[:cpp_ast].concat(
        phase_ctxt[:cpp_interpreter].execute(pp_ctxt, init_header))
    end

    def process_target_source(phase_ctxt, pp_ctxt)
      root_src = phase_ctxt[:sources].first
      phase_ctxt[:cpp_ast].concat(
        phase_ctxt[:cpp_interpreter].execute(pp_ctxt, root_src))
    end
  end

  class SubstPhase < CppPhase
    def initialize(phase_ctxt)
      super(phase_ctxt, "sub")
    end

    private
    def do_execute(phase_ctxt, *)
      phase_ctxt[:cc1_source].substitute_code_blocks(traits)
    end
  end

  class ReviewPhase < CppPhase
    def initialize(phase_ctxt)
      super(phase_ctxt, "rv1")
    end

    private
    def do_execute(phase_ctxt, *)
      phase_ctxt[:cpp_ast].accept(phase_ctxt[:cpp_ast_traversal])
    end
  end

  class ExaminationPhase < CppPhase
    def initialize(phase_ctxt)
      super(phase_ctxt, "ex1")
    end

    private
    def do_execute(phase_ctxt, *)
      examinations.each { |exam| exam.execute }
    end
  end

end
end
