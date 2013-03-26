# Source code annotations.
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

require "adlint/supp"

module AdLint #:nodoc:

  class Annotation
    def self.parse(str, loc)
      FileWiseMessageSuppressionSpecifier.parse(str, loc) ||
        LineWiseMessageSuppressionSpecifier.parse(str, loc)
    end

    def initialize(loc)
      @location = loc
    end

    def message_suppression_specifier?
      subclass_responsibility
    end
  end

  class MessageSuppressionSpecifier < Annotation
    def initialize(loc, msg_id_ary)
      super(loc)
      @message_ids = msg_id_ary.to_set
    end

    def message_suppression_specifier?
      true
    end

    def file_wise?
      subclass_responsibility
    end

    def line_wise?
      subclass_responsibility
    end

    def create_suppressor
      subclass_responsibility
    end

    private
    def parse_message_specifiers(trailer)
      msg_specs = []
      scanner = StringScanner.new(trailer)

      loop do
        case
        when scanned = scanner.scan(/:[a-z][a-z_0-9]*:\[.*?\]/m)
          *, pkg_name, msg_names = scanned.split(":")
          msg_specs.concat(parse_message_name_list(msg_names).map { |msg_name|
            MessageId.new(pkg_name, msg_name)
          })
        when scanned = scanner.scan(/:\[.*?\]/m)
          *, msg_names = scanned.split(":")
          msg_specs.concat(parse_message_name_list(msg_names).map { |msg_name|
            MessageId.new(nil, msg_name)
          })
        else
          break
        end
      end

      msg_specs
    end

    def parse_message_name_list(msg_names)
      msg_names.slice(/\[(.*)\]/m, 1).split(",").map do |msg_name_str|
        msg_name_str.strip.to_sym
      end
    end
  end

  class FileWiseMessageSuppressionSpecifier < MessageSuppressionSpecifier
    def self.parse(str, loc)
      str =~ /ADLINT:SF(:.*)\z/m ? new(loc, $1) : nil
    end

    def initialize(loc, trailer)
      super(loc, parse_message_specifiers(trailer))
    end

    def file_wise?
      true
    end

    def line_wise?
      false
    end

    def create_suppressor
      FileWiseMessageSuppressor.new(@message_ids, @location)
    end
  end

  class LineWiseMessageSuppressionSpecifier < MessageSuppressionSpecifier
    def self.parse(str, loc)
      str =~ /ADLINT:SL(:.*)\z/m ? new(loc, $1) : nil
    end

    def initialize(loc, trailer)
      super(loc, parse_message_specifiers(trailer))
    end

    def file_wise?
      false
    end

    def line_wise?
      true
    end

    def create_suppressor
      LineWiseMessageSuppressor.new(@message_ids, @location)
    end
  end

end
