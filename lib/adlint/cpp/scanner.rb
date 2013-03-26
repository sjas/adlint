# Scanner for C preprocessor language.
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
module Cpp #:nodoc:

  # == DESCRIPTION
  # Utility module for scanning the C preprocessor language code.
  module Scanner
    # === DESCRIPTION
    # Scans CPP keyword.
    #
    # === PARAMETER
    # _cont_:: StringContent -- Scanning source.
    #
    # === RETURN VALUE
    # String -- Returns CPP keyword string if found at head of the content.
    def scan_keyword(cont)
      cont.scan(/defined\b/)
    end

    # === DESCRIPTION
    # Scans CPP punctuator.
    #
    # === PARAMETER
    # _cont_:: StringContent -- Scanning source.
    #
    # === RETURN VALUE
    # String -- Returns CPP punctuator string if found at head of the content.
    def scan_punctuator(cont)
      Language::C.scan_punctuator(cont) or cont.scan(/##?/)
    end

    # === DESCRIPTION
    # Scans CPP user header name.
    #
    # === PARAMETER
    # _cont_:: StringContent -- Scanning source.
    #
    # === RETURN VALUE
    # String -- Returns CPP user header name string if found at head of the
    # content.
    def scan_user_header_name(cont)
      cont.scan(/"[^"]*"/)
    end

    # === DESCRIPTION
    # Scans CPP system header name.
    #
    # === PARAMETER
    # _cont_:: StringContent -- Scanning source.
    #
    # === RETURN VALUE
    # String -- Returns CPP system header name string if found at head of the
    # content.
    def scan_system_header_name(cont)
      cont.scan(/<[^>]*>/)
    end
  end

end
end
