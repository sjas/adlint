# AdLint package loader.
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

require "pp"
require "pathname"
require "fileutils"
require "set"
require "csv"
require "psych"
require "yaml"
require "strscan"
require "stringio"
require "forwardable"
require "logger"

require "adlint/memo"
require "adlint/prelude"
require "adlint/analyzer"
require "adlint/annot"
require "adlint/code"
require "adlint/exam"
require "adlint/traits"
require "adlint/driver"
require "adlint/error"
require "adlint/lang"
require "adlint/lexer"
require "adlint/message"
require "adlint/metric"
require "adlint/monitor"
require "adlint/phase"
require "adlint/report"
require "adlint/source"
require "adlint/supp"
require "adlint/symbol"
require "adlint/location"
require "adlint/token"
require "adlint/util"
require "adlint/version"

require "adlint/cpp"
require "adlint/cc1"
require "adlint/ld"

module AdLint #:nodoc:
  Config = Hash.new
  Config[:libdir] = Pathname.new(__FILE__).realpath.dirname
  Config[:prefix] = Pathname.new("..").expand_path(Config[:libdir])
  Config[:bindir] = Pathname.new("bin").expand_path(Config[:prefix])
  Config[:etcdir] = Pathname.new("etc").expand_path(Config[:prefix])
end
