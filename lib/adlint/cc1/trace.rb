# Context tracer.
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

require "adlint/cc1/branch"
require "adlint/cc1/value"

module AdLint #:nodoc:
module Cc1 #:nodoc:

  module ContextTracing
    # NOTE: Host class of this module must have instance variables named
    #       @positive_contribs and @negative_contribs.
    attr_reader :positive_contribs
    attr_reader :negative_contribs
  end

  module NegativePathsTracing
    include ContextTracing

    def trace_negative_paths(reporter, traced)
      trans = negative_contribs.map { |mval| mval.transition }
      branches = trans.map { |tr| tr.last.at_tag }.flatten
      sorted_branches = sort_branches_by_groups(branches)
      branches = branches.to_set

      rch_groups = []
      unr_groups = []

      sorted_branches.each_key.with_object([]) { |gr, msgs|
        case
        when gr.branches_to_trunk.any? { |upper| branches.include?(upper) }
          next
        when gr.complete? && gr.branches.size == sorted_branches[gr].size
          unr_groups.push(gr)
        else
          rch_groups.push(gr)
          sorted_branches[gr].each do |br|
            emit_negative_ctrlexpr(msgs, reporter, traced, br.ctrlexpr)
          end
        end
      } + emit_remaining_paths(reporter, traced, rch_groups, unr_groups)
    end

    private
    def emit_remaining_paths(reporter, traced, rch_groups, unr_groups)
      traced_groups = Set.new
      rch_groups.each_with_object([]) { |gr, msgs|
        cur_br = gr.trunk
        while cur_br
          emit_positive_ctrlexpr(msgs, reporter, traced, cur_br.ctrlexpr)
          traced_groups.add(cur_br.group)
          cur_br = cur_br.trunk
        end
      } + unr_groups.each_with_object([]) { |gr, msgs|
        cur_br = gr.trunk
        while cur_br
          unless traced_groups.include?(cur_br.group)
            emit_negative_ctrlexpr(msgs, reporter, traced, cur_br.ctrlexpr)
            break
          end
          cur_br = cur_br.trunk
        end
      }
    end

    def sort_branches_by_groups(branches)
      branches.each_with_object(Hash.new { |h, k| h[k] = [] }) do |br, groups|
        groups[br.group].push(br)
      end
    end

    def emit_positive_ctrlexpr(msgs, reporter, traced, ctrlexpr)
      if ctrlexpr and expr = ctrlexpr.to_expr
        if expr.location && !traced.include?(expr)
          msgs.push(reporter.C(:C1001, expr.location))
          traced.add(expr)
        end
      end
    end

    def emit_negative_ctrlexpr(msgs, reporter, traced, ctrlexpr)
      if ctrlexpr and expr = ctrlexpr.to_expr
        if expr.location && !traced.include?(expr)
          msgs.push(reporter.C(:C1002, expr.location))
          traced.add(expr)
        end
      end
    end
  end

  module UndefinableContextTracing
    include ContextTracing
    include NegativePathsTracing

    def emit_context_messages(reporter)
      traced = Set.new
      msgs = trace_positive_paths(reporter, traced) +
             trace_negative_paths(reporter, traced)

      unless msgs.empty?
        [reporter.C(:C1000, Location.new)] +
          msgs.sort { |a, b| a.location <=> b.location }
      else
        []
      end
    end

    private
    def trace_positive_paths(reporter, traced)
      # TODO: Basis of the test result might have two or more contributors.
      #       All the basis should be complemented by context messages?
      pos_trans = positive_contribs.first.transition

      pos_trans.each_with_object(Array.new) do |ss, msgs|
        val = ss.value
        src = ss.by_tag

        if src && src.location && !traced.include?(src)
          if src.kind_of?(VariableDefinition)
            if val.test_may_be_undefined.true?
              msgs.push(reporter.C(:C1003, src.location))
              traced.add(src)
            end
          end
        end
      end
    end

    # NOTE: Mix-in this module to AdLint::Cc1::UndefinableTestBasis.
    UndefinableTestBasis.class_eval { include UndefinableContextTracing }
  end

  module NullabilityContextTracing
    include ContextTracing
    include NegativePathsTracing

    def emit_context_messages(reporter)
      traced = Set.new
      msgs = trace_positive_paths(reporter, traced) +
             trace_negative_paths(reporter, traced)

      unless msgs.empty?
        [reporter.C(:C1000, Location.new)] +
          msgs.sort { |a, b| a.location <=> b.location }
      else
        []
      end
    end

    private
    def trace_positive_paths(reporter, traced)
      # TODO: Basis of the test result might have two or more contributors.
      #       All the basis should be complemented by context messages?
      pos_trans = positive_contribs.first.transition

      pos_trans.each_with_object(Array.new) do |ss, msgs|
        val = ss.value
        src = ss.by_tag

        branch = ss.at_tag.find { |br| br.ctrlexpr.to_expr }
        while branch
          if expr = branch.ctrlexpr.to_expr and expr.location
            unless traced.include?(expr)
              msgs.push(reporter.C(:C1001, expr.location))
              traced.add(expr)
            end
          end
          branch = branch.trunk
        end

        if src && src.location && !traced.include?(src)
          case
          when val.test_must_be_null.true?
            msgs.push(reporter.C(:C1004, src.location))
            traced.add(src)
          when val.test_may_be_null.true?
            msgs.push(reporter.C(:C1005, src.location))
            traced.add(src)
          end
        end
      end
    end

    # NOTE: Mix-in this module to AdLint::Cc1::NullabilityTestBasis.
    NullabilityTestBasis.class_eval { include NullabilityContextTracing }
  end

  module DefinableContextTracing
    # NOTE: Host class must have instance variable named @predicate.
    attr_reader :predicate

    include ContextTracing
    include NegativePathsTracing

    def emit_context_messages(reporter)
      traced = Set.new
      msgs = trace_positive_paths(reporter, traced) +
             trace_negative_paths(reporter, traced)

      unless msgs.empty?
        [reporter.C(:C1000, Location.new)] +
          msgs.sort { |a, b| a.location <=> b.location }
      else
        []
      end
    end

    private
    def trace_positive_paths(reporter, traced)
      # TODO: Basis of the test result might have two or more contributors.
      #       All the basis should be complemented by context messages?
      pos_trans = positive_contribs.first.transition

      pos_trans.each_with_object(Array.new) do |ss, msgs|
        val = ss.value
        src = ss.by_tag

        branch = ss.at_tag.find { |br| br.ctrlexpr.to_expr }
        while branch
          if expr = branch.ctrlexpr.to_expr and expr.location
            unless traced.include?(expr)
              msgs.push(reporter.C(:C1001, expr.location))
              traced.add(expr)
            end
          end
          branch = branch.trunk
        end

        if src && src.location && !traced.include?(src)
          if predicate.call(val)
            msgs.push(reporter.C(:C1006, src.location))
            traced.add(src)
          end
        end
      end
    end

    # NOTE: Mix-in this module to AdLint::Cc1::DefinableTestBasis.
    DefinableTestBasis.class_eval { include DefinableContextTracing }
  end

end
end
