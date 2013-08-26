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
    # NOTE: Host class of this module must respond to #positive_contribs and
    #       #negative_contribs.
    def traceable_positive_contribs
      positive_contribs.select { |mval| mval.transition.last.tag.traceable? }
    end

    def traceable_negative_contribs
      negative_contribs.select { |mval| mval.transition.last.tag.traceable? }
    end

    def sample_positive_transition
      if contrib = traceable_positive_contribs.first
        contrib.transition
      else
        nil
      end
    end
  end

  module NegativePathsTracing
    include ContextTracing

    def trace_negative_paths(report, loc, traced)
      trans = traceable_negative_contribs.map { |mval| mval.transition }
      branches = trans.map { |tr| tr.last.tag.at }.flatten
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
            emit_negative_ctrlexpr(msgs, report, loc, traced, br.ctrlexpr)
          end
        end
      } + emit_remaining_paths(report, loc, traced, rch_groups, unr_groups)
    end

    private
    def emit_remaining_paths(report, loc, traced, rch_groups, unr_groups)
      traced_groups = Set.new
      rch_groups.each_with_object([]) { |gr, msgs|
        cur_br = gr.trunk
        while cur_br
          emit_positive_ctrlexpr(msgs, report, loc, traced, cur_br.ctrlexpr)
          traced_groups.add(cur_br.group)
          cur_br = cur_br.trunk
        end
      } + unr_groups.each_with_object([]) { |gr, msgs|
        cur_br = gr.trunk
        while cur_br
          unless traced_groups.include?(cur_br.group)
            emit_negative_ctrlexpr(msgs, report, loc, traced, cur_br.ctrlexpr)
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

    def emit_positive_ctrlexpr(msgs, report, loc, traced, ctrlexpr)
      if ctrlexpr and expr = ctrlexpr.to_expr
        if expr.location && expr.location < loc && !traced.include?(expr)
          msgs.push(report.C(:C1001, expr.location))
          traced.add(expr)
        end
      end
    end

    def emit_negative_ctrlexpr(msgs, report, loc, traced, ctrlexpr)
      if ctrlexpr and expr = ctrlexpr.to_expr
        if expr.location && expr.location < loc && !traced.include?(expr)
          msgs.push(report.C(:C1002, expr.location))
          traced.add(expr)
        end
      end
    end
  end

  module UndefinableContextTracing
    include ContextTracing
    include NegativePathsTracing

    def emit_context_messages(report, loc)
      traced = Set.new
      msgs = trace_positive_paths(report, loc, traced) +
             trace_negative_paths(report, loc, traced)

      unless msgs.empty?
        [report.C(:C1000, Location.new)] +
          msgs.sort { |a, b| a.location <=> b.location }
      else
        []
      end
    end

    private
    def trace_positive_paths(report, loc, traced)
      # TODO: Evidence of the test result might have two or more contributors.
      #       All the evidences should be complemented by context messages?
      unless pos_trans = sample_positive_transition
        return []
      end

      pos_trans.each_with_object([]) do |ss, msgs|
        if src = ss.tag.by.find { |node| node.kind_of?(VariableDefinition) }
          if src.location && src.location < loc && !traced.include?(src)
            if ss.value.test_may_be_undefined.true?
              msgs.push(report.C(:C1003, src.location))
              traced.add(src)
            end
          end
        end
      end
    end

    # NOTE: Mix-in this module to AdLint::Cc1::UndefinableTestEvidence.
    UndefinableTestEvidence.class_eval { include UndefinableContextTracing }
  end

  module NullabilityContextTracing
    include ContextTracing
    include NegativePathsTracing

    def emit_context_messages(report, loc)
      traced = Set.new
      msgs = trace_positive_paths(report, loc, traced) +
             trace_negative_paths(report, loc, traced)

      unless msgs.empty?
        [report.C(:C1000, Location.new)] +
          msgs.sort { |a, b| a.location <=> b.location }
      else
        []
      end
    end

    private
    def trace_positive_paths(report, loc, traced)
      # TODO: Evidence of the test result might have two or more contributors.
      #       All the evidences should be complemented by context messages?
      unless pos_trans = sample_positive_transition
        return []
      end

      pos_trans.each_with_object([]) do |ss, msgs|
        branch = ss.tag.at.find { |br| br.ctrlexpr.to_expr }
        while branch
          if expr = branch.ctrlexpr.to_expr and
              expr.location && expr.location < loc
            unless traced.include?(expr)
              msgs.push(report.C(:C1001, expr.location))
              traced.add(expr)
            end
          end
          branch = branch.trunk
        end

        src = ss.tag.by.find { |node|
          node.location && node.location < loc && !traced.include?(node)
        }
        if src
          case
          when ss.value.test_must_be_null.true?
            msgs.push(report.C(:C1004, src.location))
            traced.add(src)
          when ss.value.test_may_be_null.true?
            msgs.push(report.C(:C1005, src.location))
            traced.add(src)
          end
        end
      end
    end

    # NOTE: Mix-in this module to AdLint::Cc1::NullabilityTestEvidence.
    NullabilityTestEvidence.class_eval { include NullabilityContextTracing }
  end

  module DefinableContextTracing
    # NOTE: Host class must have instance variable named @predicate.
    attr_reader :predicate

    include ContextTracing
    include NegativePathsTracing

    def emit_context_messages(report, loc)
      traced = Set.new
      msgs = trace_positive_paths(report, loc, traced) +
             trace_negative_paths(report, loc, traced)

      unless msgs.empty?
        [report.C(:C1000, Location.new)] +
          msgs.sort { |a, b| a.location <=> b.location }
      else
        []
      end
    end

    private
    def trace_positive_paths(report, loc, traced)
      # TODO: Evidence of the test result might have two or more contributors.
      #       All the evidences should be complemented by context messages?
      unless pos_trans = sample_positive_transition
        return []
      end

      pos_trans.each_with_object([]) do |ss, msgs|
        branch = ss.tag.at.find { |br| br.ctrlexpr.to_expr }
        while branch
          if expr = branch.ctrlexpr.to_expr and
              expr.location && expr.location < loc
            unless traced.include?(expr)
              msgs.push(report.C(:C1001, expr.location))
              traced.add(expr)
            end
          end
          branch = branch.trunk
        end

        src = ss.tag.by.find { |node|
          node.location && node.location < loc && !traced.include?(node)
        }
        if src && predicate.call(ss.value)
          msgs.push(report.C(:C1006, src.location))
          traced.add(src)
        end
      end
    end

    # NOTE: Mix-in this module to AdLint::Cc1::DefinableTestEvidence.
    DefinableTestEvidence.class_eval { include DefinableContextTracing }
  end

end
end
