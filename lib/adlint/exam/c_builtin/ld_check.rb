# Code checkings (ld-phase) of adlint-exam-c_builtin package.
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
require "adlint/ld/phase"

module AdLint #:nodoc:
module Exam #:nodoc:
module CBuiltin #:nodoc:

  class W0555 < PassiveCodeCheck
    def_registrant_phase Ld::PreparePhase

    def initialize(phase_ctxt)
      super
      phase_ctxt[:ld_function_traversal].on_definition += T(:check)
      @call_graph = phase_ctxt[:ld_call_graph]
    end

    private
    def check(fun)
      refs = @call_graph.indirect_callers_of(fun)
      if refs.any? { |ref| caller_fun = ref.function and caller_fun == fun }
        W(fun.location)
      end
    end
  end

  class W0586 < PassiveCodeCheck
    def_registrant_phase Ld::PreparePhase

    def initialize(phase_ctxt)
      super
      phase_ctxt[:ld_typedef_traversal].on_declaration += T(:check)
      @map = phase_ctxt[:ld_typedef_map]
    end

    private
    def check(typedef)
      if @map.lookup(typedef.name).any? { |td| td != typedef }
        W(typedef.location, typedef.name)
      end
    end
  end

  class W0589 < PassiveCodeCheck
    def_registrant_phase Ld::PreparePhase

    def initialize(phase_ctxt)
      super
      phase_ctxt[:ld_function_traversal].on_definition += T(:check_function)
      phase_ctxt[:ld_variable_traversal].on_definition += T(:check_variable)
      @xref_graph = phase_ctxt[:ld_xref_graph]
    end

    private
    def check_function(fun)
      if fun.extern?
        refs = @xref_graph.direct_referrers_of(fun)
        ref_funs = refs.map { |ref| ref.function }.compact.uniq
        if ref_funs.size == 1
          if ref_funs.first.location.fpath == fun.location.fpath
            W(fun.location, fun.signature, ref_funs.first.signature)
          end
        end
      end
    end

    def check_variable(var)
      if var.extern?
        refs = @xref_graph.direct_referrers_of(var)
        ref_funs = refs.map { |ref| ref.function }.compact.uniq
        if ref_funs.size == 1
          if ref_funs.first.location.fpath == var.location.fpath
            W(var.location, var.name, ref_funs.first.signature)
          end
        end
      end
    end
  end

  class W0591 < PassiveCodeCheck
    def_registrant_phase Ld::PreparePhase

    def initialize(phase_ctxt)
      super
      phase_ctxt[:ld_function_traversal].on_definition += T(:check)
      @xref_graph = phase_ctxt[:ld_xref_graph]
    end

    private
    def check(fun)
      if fun.extern?
        direct_refs = @xref_graph.direct_referrers_of(fun)
        if !direct_refs.empty? &&
            direct_refs.all? { |ref| ref.location.fpath == fun.location.fpath }
          W(fun.location, fun.signature)
        end
      end
    end
  end

  class W0593 < PassiveCodeCheck
    def_registrant_phase Ld::PreparePhase

    def initialize(phase_ctxt)
      super
      phase_ctxt[:ld_variable_traversal].on_definition += T(:check)
      @xref_graph = phase_ctxt[:ld_xref_graph]
    end

    private
    def check(var)
      if var.extern?
        direct_refs = @xref_graph.direct_referrers_of(var)
        if !direct_refs.empty? &&
            direct_refs.all? { |ref| ref.location.fpath == var.location.fpath }
          W(var.location, var.name)
        end
      end
    end
  end

  class W0628 < PassiveCodeCheck
    def_registrant_phase Ld::PreparePhase

    def initialize(phase_ctxt)
      super
      phase_ctxt[:ld_function_traversal].on_definition += T(:check)
      @xref_graph = phase_ctxt[:ld_xref_graph]
    end

    private
    def check(fun)
      unless fun.name == "main"
        if @xref_graph.direct_referrers_of(fun).empty?
          W(fun.location, fun.signature)
        end
      end
    end
  end

  class W0770 < PassiveCodeCheck
    def_registrant_phase Ld::PreparePhase

    # NOTE: W0770 may be duplicative when function declarations of the same
    #       name appears twice or more in the project.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      fun_traversal = phase_ctxt[:ld_function_traversal]
      fun_traversal.on_declaration += T(:check_function_declaration)
      fun_traversal.on_definition  += T(:check_function_definition)
      @fun_map = phase_ctxt[:ld_function_map]
      var_traversal = phase_ctxt[:ld_variable_traversal]
      var_traversal.on_declaration += T(:check_variable)
      var_traversal.on_definition  += T(:check_variable)
      @var_map = phase_ctxt[:ld_variable_map]
    end

    private
    def check_function_declaration(fun_dcl)
      if fun_dcl.extern? && fun_dcl.explicit?
        check_function(fun_dcl)
      end
    end

    def check_function_definition(fun_def)
      if fun_def.extern?
        check_function(fun_def)
      end
    end

    def check_function(fun)
      similar_dcls =
        @fun_map.lookup_function_declarations(fun.name).select { |fun_dcl|
          fun_dcl.explicit?
        }

      if similar_dcls.size > 1
        W(fun.location, fun.signature, *similar_dcls.map { |pair|
          C(:C0001, pair.location, pair.signature) unless pair == fun
        }.compact)
      end
    end

    def check_variable(var)
      if var.extern?
        similar_dcls = @var_map.lookup_variable_declarations(var.name)
        if similar_dcls.size > 1
          W(var.location, var.name, *similar_dcls.map { |pair|
            C(:C0001, pair.location, pair.name) unless pair == var
          }.compact)
        end
      end
    end
  end

  class W0791 < PassiveCodeCheck
    def_registrant_phase Ld::PreparePhase

    # NOTE: W0791 may be duplicative when definitions of the same name appears
    #       twice or more in the project.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      phase_ctxt[:ld_function_traversal].on_definition += T(:check_function)
      phase_ctxt[:ld_variable_traversal].on_definition += T(:check_variable)
      @fun_map = phase_ctxt[:ld_function_map]
      @var_map = phase_ctxt[:ld_variable_map]
    end

    private
    def check_function(fun)
      if fun.extern?
        similar_funs = @fun_map.lookup_functions(fun.name)
        if similar_funs.size > 1
          W(fun.location, fun.signature, *similar_funs.map { |pair|
            C(:C0001, pair.location, pair.signature) unless pair == fun
          }.compact)
        end
      end
    end

    def check_variable(var)
      if var.extern?
        similar_vars = @var_map.lookup_variables(var.name)
        if similar_vars.size > 1
          W(var.location, var.name, *similar_vars.map { |pair|
            C(:C0001, pair.location, pair.name) unless pair == var
          }.compact)
        end
      end
    end
  end

  class W1037 < PassiveCodeCheck
    def_registrant_phase Ld::PreparePhase

    # NOTE: W1037 may be duplicative when declarations or definitions of the
    #       same name appears twice or more in the project.
    mark_as_unique

    def initialize(phase_ctxt)
      super
      fun_traversal = phase_ctxt[:ld_function_traversal]
      fun_traversal.on_declaration += T(:check_function_declaration)
      fun_traversal.on_definition  += T(:check_function_definition)
      @fun_map = phase_ctxt[:ld_function_map]
      var_traversal = phase_ctxt[:ld_variable_traversal]
      var_traversal.on_declaration += T(:check_variable)
      var_traversal.on_definition  += T(:check_variable)
      @var_map = phase_ctxt[:ld_variable_map]
    end

    private
    def check_function_declaration(fun)
      check_function(fun) if fun.extern? && fun.explicit?
    end

    def check_function_definition(fun)
      check_function(fun) if fun.extern?
    end

    def check_function(fun)
      similar_dcls_or_funs =
        @fun_map.lookup_function_declarations(fun.name).select { |dcl|
          dcl.explicit? && dcl.extern? && dcl.signature != fun.signature
        } + @fun_map.lookup_functions(fun.name).select { |mapped_fun|
          mapped_fun.extern? && mapped_fun.signature != fun.signature
        }

      unless similar_dcls_or_funs.empty?
        W(fun.location, fun.signature,
          *similar_dcls_or_funs.map { |pair|
            C(:C0001, pair.location, pair.signature)
          })
      end
    end

    def check_variable(var)
      if var.extern?
        dcls_or_vars = @var_map.lookup_variable_declarations(var.name) +
                       @var_map.lookup_variables(var.name)
        similar_dcls_or_vars = dcls_or_vars.select { |dcl_or_var|
          dcl_or_var.extern? && dcl_or_var.type != var.type
        }

        unless similar_dcls_or_vars.empty?
          W(var.location, var.name, *similar_dcls_or_vars.map { |pair|
            C(:C0001, pair.location, pair.name)
          })
        end
      end
    end
  end

end
end
end
