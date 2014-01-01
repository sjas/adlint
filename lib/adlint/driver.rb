# Analysis drivers.
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

require "adlint/prelude"
require "adlint/traits"
require "adlint/message"
require "adlint/analyzer"

module AdLint #:nodoc:

  class AdLint
    def initialize(traits_fpath, output_dpath = nil, verbose = false,
                   cmd_name = File.basename($0))
      @cmd_name     = cmd_name
      @traits       = load_traits(traits_fpath)
      @msg_catalog  = load_message_catalog(@traits)
      @output_dpath = output_dpath
      @verbose      = verbose

      if verbose
        $stdout.sync = true
        at_exit { print_elapsed_time($stdout) }
      end
    end

    attr_reader :traits
    attr_reader :msg_catalog
    attr_reader :verbose

    def run_sma!(src_fpath, strip_num = 0)
      FileUtils.mkdir_p(sma_output_dpath(src_fpath, strip_num, @output_dpath))
      SingleModuleAnalyzer.new(@traits, @msg_catalog, src_fpath, strip_num,
                               @output_dpath, @verbose).run
    end

    def run_cma!(met_fpaths)
      FileUtils.mkdir_p(@output_dpath) if @output_dpath
      CrossModuleAnalyzer.new(@traits, @msg_catalog, met_fpaths, @output_dpath,
                              @verbose).run
    end

    def run_chk!(src_fpath, strip_num = 0)
      FileUtils.mkdir_p(sma_output_dpath(src_fpath, strip_num, @output_dpath))
      ConfigurationValidator.new(@traits, @msg_catalog, src_fpath, strip_num,
                                 @output_dpath, @verbose).run
    end

    def met_fpaths_of(src_fpaths, strip_num)
      src_fpaths.map do |fpath|
        if @output_dpath
          @output_dpath.join(fpath.strip(strip_num)).add_ext(".met.csv")
        else
          fpath.strip(strip_num).add_ext(".met.csv")
        end
      end
    end

    private
    def load_traits(traits_fpath)
      begin
        traits = Traits.new(traits_fpath)
        unless traits.valid?
          $stderr.puts "#{@cmd_name}: Failed to read `#{traits_fpath}'."
          $stderr.puts
          $stderr.puts "Detailed message is below;"
          traits.errors.each_with_index do |err, idx|
            $stderr.puts "#{idx + 1}. #{err}"
          end
          $stderr.puts
          exit 3
        end
        traits
      rescue Psych::SyntaxError, StandardError => ex
        $stderr.puts "#{@cmd_name}: Failed to read `#{traits_fpath}'."
        $stderr.puts
        $stderr.puts "Detailed message is below;"
        $stderr.puts ex.message, ex.backtrace
        $stderr.puts
        exit 2
      end
    end

    def load_message_catalog(traits)
      begin
        MessageCatalog.new(traits)
      rescue Psych::SyntaxError, StandardError => ex
        $stderr.puts "#{@cmd_name}: Failed to read the message catalog for " +
                     "`#{traits.of_message.language}'."
        $stderr.puts
        $stderr.puts "Detailed message is below;"
        $stderr.puts ex.message, ex.backtrace
        $stderr.puts
        exit 2
      end
    end

    def sma_output_dpath(src_fpath, strip_num, output_dpath)
      src_fpath.strip(strip_num).expand_path(output_dpath).dirname
    end

    def print_elapsed_time(io)
      tms = Process.times
      io.print "  %.3fs user, %.3fs system, " % [tms.utime, tms.stime]
      total = tms.utime + tms.stime
      h = total / 3600
      m = total / 60 % 60
      s = (total % 60).floor
      io.puts "%02d:%02d:%02d.%02d total" % [h, m, s, ((total % 60) - s) * 100]
    end
  end

end
