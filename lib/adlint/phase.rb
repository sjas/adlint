# Base of analysis phase classes.
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

require "adlint/error"
require "adlint/report"
require "adlint/monitor"

module AdLint #:nodoc:

  # == DESCRIPTION
  # Base of analysis phase classes.
  class Phase
    include MonitorUtil

    # === DESCRIPTION
    # Constructs an analysis pass.
    #
    # === PARAMETER
    # _phase_ctxt_:: PhaseContext -- Analysis context.
    def initialize(phase_ctxt, pkg_name, phase_name)
      @phase_ctxt = phase_ctxt
      @pkg_name   = pkg_name
      @phase_name = phase_name
    end

    # === DESCRIPTION
    # Executes the analysis.
    def execute
      monitored_region(@phase_name) do |mon|
        do_execute(@phase_ctxt, mon)
        register_examinations(@phase_ctxt)
      end
    rescue Error => ex
      report.write_message(FatalErrorMessage.new(message_catalog, ex))
      raise
    end

    private
    # === DESCRIPTION
    # Executes the analysis.
    #
    # Subclasses must implement this method.
    def do_execute(phase_ctxt, monitor)
      subclass_responsibility
    end

    def register_examinations(phase_ctxt)
      key = context_key_of("examinations")
      phase_ctxt[key] ||= []
      traits.exam_packages.each do |exam_pkg|
        exam_pkg.catalog.examination_classes.each do |exam_class|
          next unless exam_class.registrant_phase_class == self.class
          if exam_class.required?(phase_ctxt)
            phase_ctxt[key].push(exam_class.new(phase_ctxt))
          end
        end
      end
    end

    def examinations
      @phase_ctxt[context_key_of("examinations")] || []
    end

    def context_key_of(str)
      "#{@pkg_name}_#{str}".to_sym
    end

    extend Forwardable

    def_delegator :@phase_ctxt, :traits
    private :traits

    def_delegator :@phase_ctxt, :report
    private :report

    def_delegator :@phase_ctxt, :message_catalog
    private :message_catalog

    def_delegator :@phase_ctxt, :monitor
    private :monitor

    def_delegator :@phase_ctxt, :logger
    private :logger
  end

  class PhaseContext < Hash
    def initialize(analyzer, report, monitor)
      super()
      @analyzer = analyzer
      @report   = report
      @monitor  = monitor
    end

    attr_reader :report
    attr_reader :monitor

    extend Forwardable

    def_delegator :@analyzer, :traits
    def_delegator :@analyzer, :message_catalog
    def_delegator :@analyzer, :logger

    def_delegator :@report, :msg_fpath
    def_delegator :@report, :met_fpath
    def_delegator :@report, :log_fpath

    def flush_deferred_report!
      if supps = self[:suppressors]
        @report.flush_deferred_messages(supps)
      end
    end
  end

end
