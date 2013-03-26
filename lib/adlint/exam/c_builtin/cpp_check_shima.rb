# Code checkings (cpp-phase) of adlint-exam-c_builtin package.
#
# Author::    Rie Shima <mailto:rkakuuchi@users.sourceforge.net>
# Copyright:: Copyright (C) 2010-2013, OGIS-RI Co.,Ltd.
# License::   GPLv3+: GNU General Public License version 3 or later
#
# Owner::     Rie Shima <mailto:rkakuuchi@users.sourceforge.net>

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
require "adlint/cpp/phase"
require "adlint/cpp/macro"

module AdLint #:nodoc:
module Exam #:nodoc:
module CBuiltin #:nodoc:

  class W0687 < PassiveCodeCheck
    def_registrant_phase Cpp::Prepare2Phase

    # NOTE: W0687 may be duplicative when the same header which causes this
    #       warning is included twice or more.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cpp_interpreter]
      interp.on_macro_undefined += T(:check)
    end

    private
    def check(undef_line, *)
      if undef_line.identifier.value == "defined"
        W(undef_line.identifier.location)
      end
    end
  end

  class W0688 < PassiveCodeCheck
    def_registrant_phase Cpp::Prepare2Phase

    # NOTE: W0688 may be duplicative when the same header which causes this
    #       warning is included twice or more.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      visitor = phase_ctxt[:cpp_visitor]
      visitor.enter_line_line += T(:check)
    end

    private
    def check(line_line)
      if line_no_arg = line_no_argument(line_line)
        line_no = Integer(line_no_arg.value)
        unless line_no > 0 && line_no < 32768
          W(line_no_arg.location)
        end
      end
    rescue
    end

    def line_no_argument(line_line)
      line_line.pp_tokens ? line_line.pp_tokens.tokens.first : nil
    end
  end

  class W0689 < W0688
    def_registrant_phase Cpp::Prepare2Phase

    # NOTE: W0689 may be duplicative when the same header which causes this
    #       warning is included twice or more.
    mark_as_unique

    private
    def check(line_line)
      if fname_arg = file_name_argument(line_line)
        unless fname_arg.value =~ /\A".*"\z/
          W(fname_arg.location)
        end
      end
    end

    def file_name_argument(line_line)
      line_line.pp_tokens ? line_line.pp_tokens.tokens[1] : nil
    end
  end

  class W0690 < W0688
    def_registrant_phase Cpp::Prepare2Phase

    # NOTE: W0690 may be duplicative when the same header which causes this
    #       warning is included twice or more.
    mark_as_unique

    private
    def check(line_line)
      if line_no_arg = line_no_argument(line_line)
        Integer(line_no_arg.value)
      end
    rescue
      W(line_no_arg.location)
    end
  end

  class W0695 < W0687
    def_registrant_phase Cpp::Prepare2Phase

    # NOTE: W0695 may be duplicative when the same header which causes this
    #       warning is included twice or more.
    mark_as_unique

    private
    def check(undef_line, *)
      if undef_line.identifier.value == "assert"
        W(undef_line.identifier.location)
      end
    end
  end

  class W0806 < PassiveCodeCheck
    def_registrant_phase Cpp::Prepare2Phase

    # NOTE: W0806 may be duplicative when the same header which causes this
    #       warning is included twice or more.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cpp_interpreter]
      interp.on_object_like_macro_defined += T(:check)
    end

    private
    def check(define_line, *)
      if define_line.identifier.value == "defined"
        W(define_line.identifier.location)
      end
    end
  end

  class W0807 < W0687
    def_registrant_phase Cpp::Prepare2Phase

    # NOTE: W0807 may be duplicative when the same header which causes this
    #       warning is included twice or more.
    mark_as_unique

    private
    def check(undef_line, macro)
      if macro.kind_of?(Cpp::SpecialMacro)
        identifier = undef_line.identifier
        W(identifier.location, identifier.value)
      end
    end
  end

  class W0808 < PassiveCodeCheck
    def_registrant_phase Cpp::Prepare2Phase

    # NOTE: W0808 may be duplicative when the same header which causes this
    #       warning is included twice or more.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cpp_interpreter]
      interp.on_object_like_macro_defined += T(:check)
      @macro_tbl = phase_ctxt[:cpp_macro_table]
    end

    private
    def check(define_line, *)
      id = define_line.identifier
      W(id.location, id.value) if @macro_tbl.lookup(id.value)
    end
  end

end
end
end
