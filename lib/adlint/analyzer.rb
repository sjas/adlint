# Analyzer classes.
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

require "adlint/version"
require "adlint/traits"
require "adlint/report"
require "adlint/metric"
require "adlint/phase"
require "adlint/lang"
require "adlint/source"
require "adlint/supp"
require "adlint/symbol"
require "adlint/monitor"
require "adlint/util"
require "adlint/ld/phase"

module AdLint #:nodoc:

  class Analyzer
    def initialize(name, traits, msg_catalog, target_name, output_dpath,
                   log_basename, verbose)
      @name            = name
      @traits          = traits
      @message_catalog = msg_catalog
      @target_name     = target_name
      @output_dpath    = output_dpath
      @log_basename    = log_basename
      @verbose         = verbose
      @logger          = nil
    end

    attr_reader :traits
    attr_reader :message_catalog
    attr_reader :logger

    def run
      File.open(log_fpath, "w") do |log_io|
        @logger = Logger.new(log_io).tap { |logger|
          logger.progname = @name
          logger.datetime_format = "%F %T "
        }
        begin
          log_start_analysis
          execute(ProgressMonitor.new(@target_name, phases.size, @verbose))
        rescue => ex
          @logger.fatal(ex)
          return false
        end
      end
      true
    end

    private
    def execute(monitor)
      subclass_responsibility
    end

    def phases
      subclass_responsibility
    end

    def log_fpath
      log_fname = @log_basename.add_ext(".log")
      @output_dpath ? @output_dpath.join(log_fname) : log_fname
    end

    def log_start_analysis
      exam_vers = @traits.exam_packages.map { |exam_pkg|
        exam_pkg.catalog
      }.map { |exam_cat| "#{exam_cat.name}-#{exam_cat.short_version}" }

      msg = "start analysis by adlint-#{SHORT_VERSION} with "
      if exam_vers.size < 3
        msg += exam_vers.join(" and ")
      else
        msg += exam_vers[0..-2].join(", ") + " and " + exam_vers.last
      end

      @logger.info("#{msg}.")
    end
  end

  # == Single module analysis driver.
  class SingleModuleAnalyzer < Analyzer
    def initialize(traits, msg_catalog, src_fpath, strip_num, output_dpath,
                   verbose)
      super("SMA-#{SHORT_VERSION}", traits, msg_catalog, src_fpath.to_s,
            output_dpath, src_fpath.strip(strip_num), verbose)
      @src_fpath = src_fpath
      @strip_num = strip_num
    end

    private
    def execute(monitor)
      Report.new(msg_fpath, met_fpath, log_fpath, @verbose) do |report|
        src = Source.new(@src_fpath, @traits.of_project.file_encoding)

        phase_ctxt = PhaseContext.new(self, report, monitor)
        phase_ctxt[:sources]      = [src]
        phase_ctxt[:annotations]  = []
        phase_ctxt[:suppressors]  = MessageSuppressorSet.new
        phase_ctxt[:symbol_table] = SymbolTable.new

        begin
          phases.each { |phase| phase.new(phase_ctxt).execute }
          phase_ctxt.flush_deferred_report!
        ensure
          File.open(i_fpath, "w") do |io|
            io.set_encoding(Encoding.default_external)
            io.puts(phase_ctxt[:cc1_source].to_s)
          end
        end
      end
    rescue
      if @verbose
        $stderr.puts "An error was occurred while processing `#{@src_fpath}'."
        $stderr.puts "See `#{msg_fpath}' and `#{log_fpath}' for more details."
      end
      raise
    end

    def phases
      (lang = Language.of(@src_fpath)) ? lang.single_module_phases : []
    end

    def msg_fpath
      msg_fname = @src_fpath.strip(@strip_num).add_ext(".msg.csv")
      @output_dpath ? @output_dpath.join(msg_fname) : msg_fname
    end

    def met_fpath
      met_fname = @src_fpath.strip(@strip_num).add_ext(".met.csv")
      @output_dpath ? @output_dpath.join(met_fname) : met_fname
    end

    def i_fpath
      i_fname = @src_fpath.strip(@strip_num).sub_ext(".i")
      @output_dpath ? @output_dpath.join(i_fname) : i_fname
    end
  end

  class CrossModuleAnalyzer < Analyzer
    def initialize(traits, msg_catalog, met_fpaths, output_dpath, verbose)
      proj_name = traits.of_project.project_name
      super("CMA-#{SHORT_VERSION}", traits, msg_catalog, proj_name,
            output_dpath, Pathname.new(proj_name), verbose)
      @met_fpaths = met_fpaths
    end

    private
    def execute(monitor)
      Report.new(msg_fpath, met_fpath, log_fpath, @verbose) do |report|
        phase_ctxt = PhaseContext.new(self, report, monitor)
        phase_ctxt[:metric_fpaths] = @met_fpaths
        phase_ctxt[:annotations]   = []
        phase_ctxt[:suppressors]   = MessageSuppressorSet.new

        phases.each { |phase| phase.new(phase_ctxt).execute }
        phase_ctxt.flush_deferred_report!
      end
    rescue
      if @verbose
        $stderr.puts "Error was occurred in cross module analysis."
        $stderr.puts "See `#{log_fpath}' for more details."
      end
      raise
    end

    def phases
      [
        Ld::MapTypedefPhase,
        Ld::MapFunctionPhase,
        Ld::MapVariablePhase,
        Ld::LinkFunctionPhase,
        Ld::LinkVariablePhase,
        Ld::PreparePhase,
        Ld::TypedefReviewPhase,
        Ld::FunctionReviewPhase,
        Ld::VariableReviewPhase,
        Ld::ExaminationPhase
      ]
    end

    def msg_fpath
      proj_name = @traits.of_project.project_name
      msg_fname = Pathname.new(proj_name).add_ext(".msg.csv")
      @output_dpath ? @output_dpath.join(msg_fname) : msg_fname
    end

    def met_fpath
      proj_name = @traits.of_project.project_name
      met_fname = Pathname.new(proj_name).add_ext(".met.csv")
      @output_dpath ? @output_dpath.join(met_fname) : met_fname
    end
  end

  # == Configuration files validator.
  class ConfigurationValidator < Analyzer
    def initialize(traits, msg_catalog, src_fpath, strip_num, output_dpath,
                   verbose)
      super("CHK-#{SHORT_VERSION}", traits, msg_catalog, src_fpath.to_s,
            output_dpath, src_fpath.strip(strip_num), verbose)
      @src_fpath = src_fpath
      @strip_num = strip_num
    end

    private
    def execute(monitor)
      Report.new(msg_fpath, met_fpath, log_fpath, @verbose) do |report|
        src = Source.new(@src_fpath, @traits.of_project.file_encoding)

        phase_ctxt = PhaseContext.new(self, report, monitor)
        phase_ctxt[:sources]      = [src]
        phase_ctxt[:annotations]  = []
        phase_ctxt[:suppressors]  = MessageSuppressorSet.new
        phase_ctxt[:symbol_table] = SymbolTable.new

        begin
          phases.each { |phase| phase.new(phase_ctxt).execute }
          phase_ctxt.flush_deferred_report!
        ensure
          File.open(i_fpath, "w") do |io|
            io.set_encoding(Encoding.default_external)
            io.puts(phase_ctxt[:cc1_source].to_s)
          end
        end
      end
    rescue
      if @verbose
        $stderr.puts "An error was occurred while processing `#{@src_fpath}'."
        $stderr.puts "See `#{msg_fpath}' and `#{log_fpath}' for more details."
      end
      raise
    end

    def phases
      (lang = Language.of(@src_fpath)) ? lang.check_phases : []
    end

    def msg_fpath
      msg_fname = @src_fpath.strip(@strip_num).add_ext(".msg.csv")
      @output_dpath ? @output_dpath.join(msg_fname) : msg_fname
    end

    def met_fpath
      met_fname = @fpath.strip(@strip_num).add_ext(".met.csv")
      @output_dpath ? @output_dpath.join(met_fname) : met_fname
    end

    def i_fpath
      i_fname = @fpath.strip(@strip_num).sub_ext(".i")
      @output_dpath ? @output_dpath.join(i_fname) : i_fname
    end
  end

end
