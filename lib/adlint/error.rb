# AdLint specific runtime error classes.
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

require "adlint/token"

module AdLint #:nodoc:

  # == DESCRIPTION
  # Error base class for AdLint specific errors.
  class Error < StandardError
    # === DESCRIPTION
    # Constructs an error object.
    #
    # === PARAMETER
    # _msg_:: String -- Error message.
    # _loc_:: Location -- Location where an error occured.
    # _parts_:: Array< Object > -- Message formatting values.
    def initialize(msg, loc = nil, *parts)
      super(msg)
      @location = loc
      @parts = parts
    end

    # === VALUE
    # Location -- The location where this error occured.
    attr_reader :location

    # === VALUE
    # Array -- Message formatting values.
    attr_reader :parts

    def message_name
      subclass_responsibility
    end
  end

  # == DESCRIPTION
  # \AdLint fatal internal error.
  class InternalError < Error
    # === DESCRIPTION
    # Constructs an AdLint specific fatal internal error object.
    #
    # === PARAMETER
    # _cause_ex_:: Exception -- Cause exception object.
    # _loc_:: Location -- Location where an error occured.
    def initialize(cause_ex, loc)
      @cause_ex = cause_ex
      super(cause_ex.message, loc, "#{cause_ex.class} : #{cause_ex.message}")
    end

    def message_name
      :X0001
    end

    # === DESCRIPTION
    # Reads the message of this error.
    #
    # === RETURN VALUE
    # String -- Error message.
    def message
      @cause_ex.message
    end

    # === DESCRIPTION
    # Reads the backtrace information of this error.
    #
    # === RETURN VALUE
    # Array -- Backtrace information.
    def backtrace
      @cause_ex.backtrace
    end
  end

  # == DESCRIPTION
  # Internal error which indicates invalid message ID used.
  class InvalidMessageIdError < Error
    # === DESCRIPTION
    # Constructs a invalid message ID error.
    #
    # === PARAMETER
    # _msg_id_:: Symbol -- Invalid message ID.
    # _loc_:: Location -- Location where the error occured.
    def initialize(msg_id, loc = nil)
      super(msg_id.message_name, loc, msg_id.package_name, msg_id.message_name)
    end

    def message_name
      :X0002
    end
  end

  class InvalidMessageFormatError < Error
    def initialize(msg_id, loc = nil)
      super(msg_id.message_name, loc, msg_id.package_name, msg_id.message_name)
    end

    def message_name
      :X0004
    end
  end

  class FatalError < Error
    def message_name
      :X0003
    end
  end

  class ParseError < FatalError
    def initialize(loc, msg_fpath, log_fpath)
      super("failed to parse preprocessed file.", loc, msg_fpath, log_fpath)
    end
  end

  class MissingUserHeaderError < FatalError
    def initialize(loc, basename, msg_fpath, log_fpath)
      super("cannot open \"#{basename}\".", loc, msg_fpath, log_fpath)
    end
  end

  class MissingSystemHeaderError < FatalError
    def initialize(loc, basename, msg_fpath, log_fpath)
      super("cannot open <#{basename}>.", loc, msg_fpath, log_fpath)
    end
  end

  class IllformedIncludeDirectiveError < FatalError
    def initialize(loc, msg_fpath, log_fpath)
      super("#include expects a filename", loc, msg_fpath, log_fpath)
    end
  end

  class UnterminatedCommentError < FatalError
    def initialize(loc, msg_fpath, log_fpath)
      super("unterminated comment block found.", loc, msg_fpath, log_fpath)
    end
  end

end
