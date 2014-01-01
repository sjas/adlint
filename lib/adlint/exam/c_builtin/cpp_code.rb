# Code structure extractions (cpp-phase) of adlint-exam-c_builtin package.
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

require "adlint/exam"
require "adlint/report"
require "adlint/cpp/phase"

module AdLint #:nodoc:
module Exam #:nodoc:
module CBuiltin #:nodoc:

  class ObjLikeMacroExtraction < CodeExtraction
    def_registrant_phase Cpp::Prepare2Phase

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cpp_interpreter]
      interp.on_object_like_macro_defined += T(:extract)
    end

    private
    def do_prepare(*) end
    def do_execute(*) end

    def extract(define_line, macro)
      MACRODEF(define_line.location, macro.name.value, "O")
    end
  end

  class FunLikeMacroExtraction < CodeExtraction
    def_registrant_phase Cpp::Prepare2Phase

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cpp_interpreter]
      interp.on_function_like_macro_defined    += T(:extract)
      interp.on_va_function_like_macro_defined += T(:extract)
    end

    private
    def do_prepare(*) end
    def do_execute(*) end

    def extract(define_line, macro)
      MACRODEF(define_line.location, macro.name.value, "F")
    end
  end

  class IncludeDirectiveExtraction < CodeExtraction
    def_registrant_phase Cpp::Prepare2Phase

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cpp_interpreter]
      interp.on_system_header_included += T(:extract_system_include)
      interp.on_user_header_included   += T(:extract_user_include)
    end

    private
    def do_prepare(*) end
    def do_execute(*) end

    def extract_system_include(sys_include_line, sys_header)
      INCLUDE(sys_include_line.location, "<#{sys_header.fpath}>")
    end

    def extract_user_include(usr_include_line, usr_header)
      INCLUDE(usr_include_line.location, "\"#{usr_header.fpath}\"")
    end
  end

  class DirectiveExtraction < CodeExtraction
    def_registrant_phase Cpp::Prepare2Phase

    def initialize(phase_ctxt)
      super
      trav = phase_ctxt[:cpp_ast_traversal]
      trav.enter_if_statement                 += T(:extract_if)
      trav.enter_ifdef_statement              += T(:extract_ifdef)
      trav.enter_ifndef_statement             += T(:extract_ifndef)
      trav.enter_elif_statement               += T(:extract_elif)
      trav.enter_else_statement               += T(:extract_else)
      trav.enter_endif_line                   += T(:extract_endif)
      trav.enter_user_include_line            += T(:extract_usr_include)
      trav.enter_system_include_line          += T(:extract_sys_include)
      trav.enter_object_like_define_line      += T(:extract_define)
      trav.enter_function_like_define_line    += T(:extract_define)
      trav.enter_va_function_like_define_line += T(:extract_define)
      trav.enter_undef_line                   += T(:extract_undef)
      trav.enter_line_line                    += T(:extract_line)
      trav.enter_error_line                   += T(:extract_error)
      trav.enter_pragma_line                  += T(:extract_pragma)
      trav.enter_null_directive               += T(:extract_null)
    end

    private
    def do_prepare(*) end
    def do_execute(*) end

    def extract_if(if_stmt)
      PP_DIRECTIVE(if_stmt.location, if_stmt.keyword.value,
                   if_stmt.expression.to_s)
    end

    def extract_ifdef(ifdef_stmt)
      PP_DIRECTIVE(ifdef_stmt.location, ifdef_stmt.keyword.value,
                   ifdef_stmt.identifier.value)
    end

    def extract_ifndef(ifndef_stmt)
      PP_DIRECTIVE(ifndef_stmt.location, ifndef_stmt.keyword.value,
                   ifndef_stmt.identifier.value)
    end

    def extract_elif(elif_stmt)
      PP_DIRECTIVE(elif_stmt.location, elif_stmt.keyword.value,
                   elif_stmt.expression.to_s)
    end

    def extract_else(else_stmt)
      PP_DIRECTIVE(else_stmt.location, else_stmt.keyword.value, nil)
    end

    def extract_endif(endif_line)
      PP_DIRECTIVE(endif_line.location, endif_line.keyword.value, nil)
    end

    def extract_usr_include(usr_include_line)
      PP_DIRECTIVE(usr_include_line.location, usr_include_line.keyword.value,
                   usr_include_line.header_name.value)
    end

    def extract_sys_include(sys_include_line)
      PP_DIRECTIVE(sys_include_line.location, sys_include_line.keyword.value,
                   sys_include_line.header_name.value)
    end

    def extract_define(define_line)
      PP_DIRECTIVE(define_line.location, define_line.keyword.value,
                   define_line.identifier.value)
    end

    def extract_undef(undef_line)
      PP_DIRECTIVE(undef_line.location, undef_line.keyword.value,
                   undef_line.identifier.value)
    end

    def extract_line(line_line)
      PP_DIRECTIVE(line_line.location, line_line.keyword.value,
                   line_line.pp_tokens ? line_line.pp_tokens.to_s : "")
    end

    def extract_error(error_line)
      PP_DIRECTIVE(error_line.location, error_line.keyword.value,
                   error_line.pp_tokens.tokens.map { |t| t.value }.join(" "))
    end

    def extract_pragma(pragma_line)
      PP_DIRECTIVE(pragma_line.location, pragma_line.keyword.value,
                   pragma_line.pp_tokens ? pragma_line.pp_tokens.to_s : "")
    end

    def extract_null(null_directive)
      PP_DIRECTIVE(null_directive.location, null_directive.token.value, nil)
    end
  end

end
end
end
