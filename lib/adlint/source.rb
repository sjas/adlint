# Analyzing source files.
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

require "adlint/traits"
require "adlint/report"
require "adlint/util"

module AdLint #:nodoc:

  # == DESCRIPTION
  # Target source file.
  class Source
    # === DESCRIPTION
    # Constructs a target source file.
    #
    # === PARAMETER
    # _fpath_:: Pathname -- Path name of the target source file.
    # _content_:: String -- Source content.
    def initialize(fpath, fenc, included_at = Location.new)
      @fpath       = fpath
      @fenc        = fenc
      @included_at = included_at
      @content     = nil
    end

    extend Pluggable

    def_plugin :on_cr_at_eol_found
    def_plugin :on_eof_mark_at_eof_found
    def_plugin :on_eof_newline_not_found

    # === VALUE
    # String -- The path name of this source file.
    attr_reader :fpath

    attr_reader :included_at

    def user_header?
      false
    end

    def system_header?
      false
    end

    def analysis_target?(traits)
      Location.new(@fpath).in_analysis_target?(traits)
    end

    # === DESCRIPTION
    # Opens the target source file.
    #
    # === PARAMETER
    # _block_:: Proc -- Yieldee block.
    def open(&block)
      @content ||= read_content(@fpath)
      io = StringIO.new(@content)
      yield(io)
    ensure
      io && io.close
    end

    # === DESCRIPTION
    # Converts this source content into string.
    #
    # === RETURN VALUE
    # String -- Content of this source file.
    def to_s
      @content ||= read_content(@fpath)
    end

    private
    def read_content(fpath)
      cont = IO.read(fpath, mode: "rb", encoding: @fenc || "binary")
      cont = cont.byteslice(3..-1) if cont.byteslice(0..2).bytes == UTF_8_BOM
      cont = cont.encode("UTF-8", 'binary', invalid: :replace, undef: :replace, replace: '')

      if cont =~ /\r/
        notify_cr_at_eol_found(Location.new(fpath))
        cont = cont.gsub(/\r\n|\r/, "\n")
      end

      if cont =~ /\x1a/
        notify_eof_mark_at_eof_found(Location.new(fpath))
        cont = cont.gsub(/\x1a/, "")
      end

      unless cont.end_with?("\n")
        notify_eof_newline_not_found(Location.new(fpath))
        cont << "\n"
      end

      cont
    end

    def notify_cr_at_eol_found(loc)
      on_cr_at_eol_found.invoke(loc)
    end

    def notify_eof_mark_at_eof_found(loc)
      on_eof_mark_at_eof_found.invoke(loc)
    end

    def notify_eof_newline_not_found(loc)
      on_eof_newline_not_found.invoke(loc)
    end

    UTF_8_BOM = [0xEF, 0xBB, 0xBF]
    private_constant :UTF_8_BOM
  end

  class EmptySource < Source
    def initialize
      super(File::NULL, nil, nil)
      @content = "\n"
    end
  end

  class UserHeader < Source
    def user_header?
      true
    end
  end

  class SystemHeader < Source
    def system_header?
      true
    end
  end

end
