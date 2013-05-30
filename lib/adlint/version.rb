# Version information.
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

  MAJOR_VERSION = 3
  MINOR_VERSION = 0
  PATCH_VERSION = 7
  RELEASE_DATE  = "2013-05-30"

  TRAITS_SCHEMA_VERSION = "3.0.0"

  SHORT_VERSION = "#{MAJOR_VERSION}.#{MINOR_VERSION}.#{PATCH_VERSION}"

  VERSION = "#{SHORT_VERSION} (#{RELEASE_DATE})"

  COPYRIGHT = <<EOS
     ___    ____  __    ___   _________
    /   |  / _  |/ /   / / | / /__  __/            Source Code Static Analyzer
   / /| | / / / / /   / /  |/ /  / /                    AdLint - Advanced Lint
  / __  |/ /_/ / /___/ / /|  /  / /
 /_/  |_|_____/_____/_/_/ |_/  /_/    Copyright (C) 2010-2013, OGIS-RI Co.,Ltd.

 AdLint is free software: you can redistribute it and/or modify it under the
 terms of the GNU General Public License as published by the Free Software
 Foundation, either version 3 of the License, or (at your option) any later
 version.

 AdLint is distributed in the hope that it will be useful, but WITHOUT ANY
 WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
 A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

 You should have received a copy of the GNU General Public License along with
 AdLint.  If not, see <http://www.gnu.org/licenses/>.

EOS

  AUTHOR = <<EOS
Written by Yutaka Yanoh, Rie Shima and OGIS-RI Co.,Ltd.

EOS

end
