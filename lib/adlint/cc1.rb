# AdLint::Cc1 package loader.
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

require "adlint/cc1/branch"
require "adlint/cc1/builtin"
require "adlint/cc1/ctrlexpr"
require "adlint/cc1/const"
require "adlint/cc1/conv"
require "adlint/cc1/domain"
require "adlint/cc1/enum"
require "adlint/cc1/environ"
require "adlint/cc1/expr"
require "adlint/cc1/format"
require "adlint/cc1/interp"
require "adlint/cc1/lexer"
require "adlint/cc1/mediator"
require "adlint/cc1/object"
require "adlint/cc1/operator"
require "adlint/cc1/option"
require "adlint/cc1/parser"
require "adlint/cc1/phase"
require "adlint/cc1/resolver"
require "adlint/cc1/scanner"
require "adlint/cc1/scope"
require "adlint/cc1/seqp"
require "adlint/cc1/syntax"
require "adlint/cc1/type"
require "adlint/cc1/util"
require "adlint/cc1/value"
