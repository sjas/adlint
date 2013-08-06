# Location identifier of tokens.
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

module AdLint #:nodoc:

  # == DESCRIPTION
  # Location identifier of tokens.
  class Location
    include Comparable

    # === Constructs a location identifier.
    #
    # Param:: _fpath_ (Pathname) Path name of the file contains the token.
    # Param:: _line_no_ (Integer) Line-no where the token appears.
    # Param:: _column_no_ (Integer) Column-no where the token appears.
    def initialize(fpath = nil, line_no = nil, column_no = nil,
                   appearance_column_no = column_no)
      @fpath, @line_no, @column_no = fpath, line_no, column_no
      @appearance_column_no = appearance_column_no
    end

    # === VALUE
    # Pathname -- Path name of the file contains this token.
    attr_reader :fpath

    # === VALUE
    # Integer -- Line-no where this token appears.
    attr_reader :line_no

    # === VALUE
    # Integer -- Column-no where this token appears.
    attr_reader :column_no

    attr_reader :appearance_column_no

    def in_analysis_target?(traits)
      if @fpath
        under_inclusion_paths?(@fpath, traits) &&
          !under_exclusion_paths?(@fpath, traits) and
        !@fpath.identical?(traits.of_project.initial_header) &&
          !@fpath.identical?(traits.of_compiler.initial_header)
      else
        false
      end
    end
    # NOTE: Value of #in_analysis_target? depends on the `traits' parameter.
    #       But the `traits' parameter always points the same object in an
    #       AdLint instance.
    #       So, it is safe to treat this method as nullary method for improving
    #       the performance.
    memoize :in_analysis_target?, force_nullary: true

    def <=>(rhs)
      self.to_a <=> rhs.to_a
    end

    def eql?(rhs)
      self == rhs
    end

    def hash
      to_a.hash
    end

    # === DESCRIPTION
    # Converts this location identifier to an array representation.
    #
    # === RETURN VALUE
    # Array< Object > -- Array representation of this location identifier.
    def to_a
      [@fpath, @line_no, @column_no]
    end

    # === DESCRIPTION
    # Converts this location to a human readable string representation.
    #
    # === RETURN VALUE
    # String -- String representation of this location identifier.
    def to_s
      "#{@fpath}:#{@line_no}:#{@column_no}"
    end

    # === DESCRIPTION
    # Converts this location to debugging dump representation.
    #
    # === RETURN VALUE
    # String -- String representation of this location identifier.
    def inspect
      "#{@fpath ? @fpath : 'nil'}:" +
        "#{@line_no ? @line_no : 'nil'}:#{@column_no ? @column_no : 'nil'}"
    end

    private
    def under_inclusion_paths?(fpath, traits)
      traits.of_project.target_files.inclusion_paths.any? do |dpath|
        fpath.under?(dpath)
      end
    end

    def under_exclusion_paths?(fpath, traits)
      traits.of_project.target_files.exclusion_paths.any? do |dpath|
        fpath.under?(dpath)
      end
    end
  end

  module LocationHolder
    # NOTE: Host class must respond to #location.

    def analysis_target?(traits)
      location.in_analysis_target?(traits)
    end
  end

end
