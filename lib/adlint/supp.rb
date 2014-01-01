# Message suppressions.
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

module AdLint #:nodoc:

  class MessageSuppressorSet
    def initialize
      @file_wise_suppressions = {}
      @line_wise_suppressions = {}
    end

    def add(supp)
      case
      when supp.file_wise?
        @file_wise_suppressions[supp.key] = supp
      when supp.line_wise?
        @line_wise_suppressions[supp.key] = supp
      end
    end

    def suppress?(msg)
      (supp = @file_wise_suppressions[file_wise_key_of(msg)]) &&
        supp.suppress?(msg) or
      (supp = @line_wise_suppressions[line_wise_key_of(msg)]) &&
        supp.suppress?(msg) or
      false
    end

    private
    def file_wise_key_of(msg)
      FileWiseMessageSuppressor.key_of(msg.location)
    end

    def line_wise_key_of(msg)
      LineWiseMessageSuppressor.key_of(msg.location)
    end
  end

  class MessageSuppressor
    def initialize(target_msg_ids)
      @target_msg_ids = target_msg_ids
    end

    def key
      subclass_responsibility
    end

    def file_wise?
      subclass_responsibility
    end

    def line_wise?
      subclass_responsibility
    end

    def suppress?(msg)
      @target_msg_ids.include?(msg.id)
    end
  end

  class FileWiseMessageSuppressor < MessageSuppressor
    def self.key_of(loc)
      [loc.fpath]
    end

    def initialize(target_msg_ids, annot_loc)
      super(target_msg_ids)
      @key = [annot_loc.fpath]
    end

    attr_reader :key

    def file_wise?
      true
    end

    def line_wise?
      false
    end
  end

  class LineWiseMessageSuppressor < MessageSuppressor
    def self.key_of(loc)
      [loc.fpath, loc.line_no]
    end

    def initialize(target_msg_ids, annot_loc)
      super(target_msg_ids)
      @key = [annot_loc.fpath, annot_loc.line_no]
    end

    attr_reader :key

    def file_wise?
      false
    end

    def line_wise?
      true
    end
  end

end
