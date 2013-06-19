# C runtime environment.
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

require "adlint/cc1/enum"
require "adlint/cc1/object"
require "adlint/cc1/builtin"
require "adlint/cc1/branch"
require "adlint/cc1/mediator"

module AdLint #:nodoc:
module Cc1 #:nodoc:

  class Environment
    include TypeTableMediator
    include MemoryPoolMediator
    include VariableTableMediator
    include FunctionTableMediator
    include EnumeratorTableMediator

    def initialize(type_tbl)
      @type_table       = type_tbl
      @memory_pool      = MemoryPool.new
      @variable_table   = VariableTable.new(@memory_pool)
      @function_table   = FunctionTable.new(@memory_pool)
      @enumerator_table = EnumeratorTable.new
      install_builtin_functions
      reset
    end

    attr_reader :type_table
    attr_reader :memory_pool
    attr_reader :variable_table
    attr_reader :function_table
    attr_reader :enumerator_table
    attr_reader :current_scope

    def reset
      @current_scope = GlobalScope.new
      @branch_depth  = 0
      @branch_groups = {}
    end

    def enter_scope
      @current_scope = current_scope.inner_scope
      @variable_table.enter_scope
      @function_table.enter_scope
    end

    def leave_scope
      @current_scope = current_scope.outer_scope
      @variable_table.leave_scope
      @function_table.leave_scope
    end

    def enter_branch_group(*opts)
      @branch_groups[@branch_depth] =
        BranchGroup.new(self, @branch_groups[@branch_depth - 1], *opts)
    end

    def current_branch_group
      @branch_groups[@branch_depth]
    end

    def leave_branch_group
      @branch_groups.delete(@branch_depth)
    end

    def enter_branch(*opts)
      @branch_depth += 1

      if group = current_branch_group
        group.add_options(*opts)
        group.create_trailing_branch(*opts)
      else
        group = enter_branch_group(*opts)
        group.create_first_branch(*opts)
      end
    end

    def leave_branch
      # NOTE: Don't delete current branch!
      @branch_depth -= 1
    end

    def enter_versioning_group
      @variable_table.enter_variables_value_versioning_group
    end

    def leave_versioning_group(raise_complement)
      @variable_table.leave_variables_value_versioning_group(raise_complement)
    end

    def begin_versioning
      @variable_table.begin_variables_value_versioning
    end

    def end_versioning(thin_this_version, with_rollback = thin_this_version)
      if thin_this_version
        @variable_table.thin_latest_variables_value_version!(with_rollback)
      end
      @variable_table.end_variables_value_versioning
    end

    private
    def install_builtin_functions
      @function_table.define(InspectFunction.new(@type_table))
      @function_table.define(EvalFunction.new(@type_table))
    end
  end

end
end
