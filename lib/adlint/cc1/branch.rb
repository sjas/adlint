# C runtime branch of execution path.
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

require "adlint/cc1/ctrlexpr"
require "adlint/cc1/option"

module AdLint #:nodoc:
module Cc1 #:nodoc:

  class Branch
    include BranchOptions

    def initialize(br_group, *opts)
      @group = br_group
      @options = opts
      @break_event = nil
      @controlling_expression = nil
    end

    attr_reader :group
    attr_reader :break_event
    attr_reader :controlling_expression

    def add_options(*new_opts)
      @options = (@options + new_opts).uniq
      @group.add_options(*new_opts)
    end

    def narrowing?
      @options.include?(NARROWING)
    end

    def widening?
      @options.include?(WIDENING)
    end

    def first?
      @options.include?(FIRST)
    end

    def final?
      @options.include?(FINAL)
    end

    def smother_break?
      @options.include?(SMOTHER_BREAK)
    end

    def implicit_condition?
      @options.include?(IMPLICIT_COND)
    end

    def complemental?
      @options.include?(COMPLEMENTAL)
    end

    def execute(interp, expr = nil, &block)
      env.enter_versioning_group if first?
      env.begin_versioning

      @controlling_expression = ControllingExpression.new(interp, self, expr)
      if ensure_condition(@controlling_expression)
        @break_event = BreakEvent.catch { yield(self) }
      else
        unless final? && @group.branches.size == 1
          @break_event = BreakEvent.of_return
        end
      end

    ensure
      if @controlling_expression.complexly_compounded? && !complemental?
        # NOTE: Give up value domain thinning of the controlling variables,
        #       because the controlling expression is too complex to manage
        #       value domains correctly.
        # TODO: Study about introducing inter-value-constraints to correctly
        #       manage value domains of controlling variables related with each
        #       other.
        env.end_versioning(break_with_return?, true)
      else
        env.end_versioning(break_with_return?, false)
      end

      if final?
        env.leave_versioning_group(!@group.complete?)
        if @group.complete?
          rethrow_break_event
        end
      end
    end

    def restart_versioning(&block)
      @controlling_expression.save_affected_variables
      env.end_versioning(false)
      env.leave_versioning_group(true)
      env.enter_versioning_group
      env.begin_versioning
      yield
      @controlling_expression.restore_affected_variables
    end

    def break_with_break?
      @break_event && @break_event.break?
    end

    def break_with_continue?
      @break_event && @break_event.continue?
    end

    def break_with_return?
      @break_event && @break_event.return?
    end

    private
    def ensure_condition(ctrlexpr)
      case
      when narrowing?
        ctrlexpr.ensure_true_by_narrowing.commit!
      when widening?
        ctrlexpr.ensure_true_by_widening.commit!
      end
      @group.all_controlling_variables_value_exist?
    end

    def rethrow_break_event
      case
      when @group.all_branches_break_with_break?
        BreakEvent.of_break.throw unless smother_break?
      when @group.all_branches_break_with_return?
        BreakEvent.of_return.throw
      end
    end

    def env
      @group.environment
    end
  end

  class BranchGroup
    include BranchOptions
    include BranchGroupOptions

    def initialize(env, *opts)
      @environment = env
      @options = opts
      @branches = []
    end

    attr_reader :environment
    attr_reader :branches

    def add_options(*new_opts)
      @options = (@options + new_opts).uniq
    end

    def complete?
      @options.include?(COMPLETE)
    end

    def create_first_branch(*opts)
      @branches.push(new_br = Branch.new(self, FIRST, *opts))
      new_br
    end

    def create_trailing_branch(*opts)
      @branches.push(new_br = Branch.new(self, *opts))
      new_br
    end

    def all_controlling_variables
      @branches.map { |br|
        ctrlexpr = br.controlling_expression and ctrlexpr.affected_variables
      }.compact.flatten.uniq
    end

    def all_controlling_variables_value_exist?
      all_controlling_variables.all? { |var| var.value.exist? }
    end

    def all_branches_break_with_break?
      @branches.all? { |br| br.break_with_break? }
    end

    def all_branches_break_with_continue?
      @branches.all? { |br| br.break_with_continue? }
    end

    def all_branches_break_with_return?
      @branches.all? { |br| br.break_with_return? }
    end
  end

  class BreakEvent
    class << self
      def catch(&block)
        Kernel.catch(:break) { yield; nil }
      end

      def of_break
        new(:break)
      end
      memoize :of_break

      def of_continue
        new(:continue)
      end
      memoize :of_continue

      def of_return
        new(:return)
      end
      memoize :of_return
    end

    def initialize(type)
      @type = type
    end
    private_class_method :new

    def break?
      @type == :break
    end

    def continue?
      @type == :continue
    end

    def return?
      @type == :return
    end

    def throw
      Kernel.throw(:break, self)
    end
  end

end
end
