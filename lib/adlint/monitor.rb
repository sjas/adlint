# Progress monitoring mechanism.
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

require "adlint/token"
require "adlint/error"
require "adlint/report"

module AdLint #:nodoc:

  module MonitorUtil
    # NOTE: Host class must respond to #monitor.

    def monitored_region(title, total = 1)
      monitor.start(title, total)
      retval = yield(monitor)
      monitor.finish
      retval
    rescue Error
      monitor.abort
      raise
    rescue => ex
      monitor.abort
      raise InternalError.new(ex, monitor.location)
    end

    def checkpoint(loc_or_num)
      case loc_or_num
      when Location
        monitor.location = loc_or_num
      when Numeric
        monitor.progress = loc_or_num
      end
    end
  end

  class ProgressMonitor
    def initialize(fpath, phase_num, verbose)
      @fpath      = fpath
      @phase_num  = phase_num
      @verbose    = verbose
      @start_time = Time.now
      @cur_phase  = 0
    end

    attr_reader :location
    attr_reader :progress

    def start(title, total = 1)
      @total    = total
      @title    = title
      @location = nil
      @progress = 0
      @cur_phase += 1
      draw
    end

    def finish
      @progress = @total
      if @cur_phase == @phase_num
        draw_finished
      else
        draw
      end
    end

    def abort
      draw_aborted
    end

    def location=(loc)
      @location = loc
      if false && @fpath.identical?(@location.fpath)
        self.progress = @location.line_no
      end
    end

    def progress=(val)
      @progress = val
      draw
    end

    private
    def draw
      if @verbose
        draw_bar(@fpath, @title)
        print " %3d%%" % (total_progress * 100).to_i
      end
    end

    def draw_finished
      if @verbose
        draw_bar(@fpath, "fin")
        puts " %.3fs" % (Time.now - @start_time)
      end
    end

    def draw_aborted
      if @verbose
        draw_bar(@fpath, @title)
        puts " %.3fs!" % (Time.now - @start_time)
      end
    end

    def total_progress
      phase_start    = (@cur_phase - 1).to_f / @phase_num
      phase_progress = @progress.to_f / @total / @phase_num
      phase_start + phase_progress
    end

    def draw_bar(fpath, title)
      print "\r%30.30s [%3.3s] |" % [fpath.to_s.scan(/.{,30}\z/).first, title]
      print "=" * (28 * total_progress).to_i
      print " " * (28 - (28 * total_progress).to_i)
      print "|"
    end
  end

end
