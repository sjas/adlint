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
    end

    private
    def check(fun)
      call_graph = @phase_ctxt[:ld_function_call_graph]
      if call_graph.indirect_callers_of(fun).include?(fun)
        W(fun.location)
      end
    end
  end

  class W0586 < PassiveCodeCheck
    def_registrant_phase Ld::PreparePhase

    def initialize(phase_ctxt)
      super
      phase_ctxt[:ld_typedef_traversal].on_declaration += T(:check)
    end

    private
    def check(typedef)
      mapping = @phase_ctxt[:ld_typedef_mapping]
      if mapping.lookup(typedef.name).any? { |td| td != typedef }
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
    end

    private
    def check_function(fun)
      return unless fun.extern?
      call_graph = @phase_ctxt[:ld_function_call_graph]
      direct_callers = call_graph.direct_callers_of(fun)
      if direct_callers.size == 1 &&
          direct_callers.first.location.fpath == fun.location.fpath
        W(fun.location, fun.signature, direct_callers.first.signature)
      end
    end

    def check_variable(var)
      return unless var.extern?
      ref_graph = @phase_ctxt[:ld_variable_reference_graph]
      direct_referrers = ref_graph.direct_referrers_of(var)
      if direct_referrers.size == 1 &&
          direct_referrers.first.location.fpath == var.location.fpath
        W(var.location, var.name, direct_referrers.first.signature)
      end
    end
  end

  class W0591 < PassiveCodeCheck
    def_registrant_phase Ld::PreparePhase

    def initialize(phase_ctxt)
      super
      phase_ctxt[:ld_function_traversal].on_definition += T(:check)
    end

    private
    def check(fun)
      return unless fun.extern?
      call_graph = @phase_ctxt[:ld_function_call_graph]
      direct_callers = call_graph.direct_callers_of(fun)
      if !direct_callers.empty? &&
          direct_callers.all? { |f| f.location.fpath == fun.location.fpath }
        W(fun.location, fun.signature)
      end
    end
  end

  class W0593 < PassiveCodeCheck
    def_registrant_phase Ld::PreparePhase

    def initialize(phase_ctxt)
      super
      phase_ctxt[:ld_variable_traversal].on_definition += T(:check)
    end

    private
    def check(var)
      return unless var.extern?
      ref_graph = @phase_ctxt[:ld_variable_reference_graph]
      direct_referrers = ref_graph.direct_referrers_of(var)
      if !direct_referrers.empty? &&
          direct_referrers.all? { |f| f.location.fpath == var.location.fpath }
        W(var.location, var.name)
      end
    end
  end

  class W0628 < PassiveCodeCheck
    def_registrant_phase Ld::PreparePhase

    def initialize(phase_ctxt)
      super
      phase_ctxt[:ld_function_traversal].on_definition += T(:check)
    end

    private
    def check(fun)
      call_graph = @phase_ctxt[:ld_function_call_graph]
      unless fun.name == "main"
        if call_graph.direct_callers_of(fun).empty?
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
      var_traversal = phase_ctxt[:ld_variable_traversal]
      fun_traversal.on_declaration += T(:check_function_declaration)
      fun_traversal.on_definition  += T(:check_function_definition)
      var_traversal.on_declaration += T(:check_variable)
      var_traversal.on_definition  += T(:check_variable)
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
      mapping = @phase_ctxt[:ld_function_mapping]
      similar_dcls =
        mapping.lookup_function_declarations(fun.name).select { |fun_dcl|
          fun_dcl.explicit?
        }

      if similar_dcls.size > 1
        W(fun.location, fun.signature, *similar_dcls.map { |pair_dcl|
          next if pair_dcl == fun
          C(:C0001, pair_dcl.location, pair_dcl.signature)
        }.compact)
      end
    end

    def check_variable(var)
      return unless var.extern?

      mapping = @phase_ctxt[:ld_variable_mapping]
      similar_dcls = mapping.lookup_variable_declarations(var.name)

      if similar_dcls.size > 1
        W(var.location, var.name, *similar_dcls.map { |pair_dcl|
          next if pair_dcl == var
          C(:C0001, pair_dcl.location, pair_dcl.name)
        }.compact)
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
    end

    private
    def check_function(fun)
      return unless fun.extern?

      mapping = @phase_ctxt[:ld_function_mapping]
      similar_funs = mapping.lookup_functions(fun.name)

      if similar_funs.size > 1
        W(fun.location, fun.signature, *similar_funs.map { |pair_fun|
          next if pair_fun == fun
          C(:C0001, pair_fun.location, pair_fun.signature)
        }.compact)
      end
    end

    def check_variable(var)
      return unless var.extern?

      mapping = @phase_ctxt[:ld_variable_mapping]
      similar_vars = mapping.lookup_variables(var.name)

      if similar_vars.size > 1
        W(var.location, var.name, *similar_vars.map { |pair_var|
          next if pair_var == var
          C(:C0001, pair_var.location, pair_var.name)
        }.compact)
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
      var_traversal = phase_ctxt[:ld_variable_traversal]
      fun_traversal.on_declaration += T(:check_function_declaration)
      fun_traversal.on_definition  += T(:check_function_definition)
      var_traversal.on_declaration += T(:check_variable)
      var_traversal.on_definition  += T(:check_variable)
    end

    private
    def check_function_declaration(fun)
      check_function(fun) if fun.extern? && fun.explicit?
    end

    def check_function_definition(fun)
      check_function(fun) if fun.extern?
    end

    def check_function(fun)
      mapping = @phase_ctxt[:ld_function_mapping]
      similar_dcls_or_funs =
        mapping.lookup_function_declarations(fun.name).select { |dcl|
          dcl.explicit? && dcl.extern? && dcl.signature != fun.signature
        } + mapping.lookup_functions(fun.name).select { |mapped_fun|
          mapped_fun.extern? && mapped_fun.signature != fun.signature
        }

      unless similar_dcls_or_funs.empty?
        W(fun.location, fun.signature,
          *similar_dcls_or_funs.map { |pair_dcl_or_fun|
            C(:C0001, pair_dcl_or_fun.location, pair_dcl_or_fun.signature)
          })
      end
    end

    def check_variable(var)
      return unless var.extern?

      mapping = @phase_ctxt[:ld_variable_mapping]
      similar_dcls_or_vars =
        (mapping.lookup_variable_declarations(var.name) +
         mapping.lookup_variables(var.name)).select { |dcl_or_var|
           dcl_or_var.extern? && dcl_or_var.type != var.type
         }

      unless similar_dcls_or_vars.empty?
        W(var.location, var.name, *similar_dcls_or_vars.map { |pair_dcl_or_var|
          C(:C0001, pair_dcl_or_var.location, pair_dcl_or_var.name)
        })
      end
    end
  end

end
end
end
