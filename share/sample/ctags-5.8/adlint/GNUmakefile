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
# How...
#   - to validate configuration files
#     % make check
#   - to analyze whole project with compiler like messages
#     % make all
#   - to do only single module analyses with compiler like messages
#     % make sma-only
#   - to analyze whole project with progress report
#     % make verbose-all
#   - to do only single module analyses with progress report
#     % make verbose-sma-only
#   - to do only cross module analysis with progress report
#     % make verbose-cma-only
#   - to analyze whole project *FAST* on 4-core processor machine
#     % make -j 4 all
#   - to analyze whole project *FAST* and silently with elapsed time
#     % time make -j 4 all 2>/dev/null
#   - to delete all result files
#     % make clean
#

PROJECT = ctags-5.8

SOURCES = \
  ctags-5.8/args.c \
  ctags-5.8/ant.c \
  ctags-5.8/asm.c \
  ctags-5.8/asp.c \
  ctags-5.8/awk.c \
  ctags-5.8/basic.c \
  ctags-5.8/beta.c \
  ctags-5.8/c.c \
  ctags-5.8/cobol.c \
  ctags-5.8/dosbatch.c \
  ctags-5.8/eiffel.c \
  ctags-5.8/entry.c \
  ctags-5.8/erlang.c \
  ctags-5.8/flex.c \
  ctags-5.8/fortran.c \
  ctags-5.8/get.c \
  ctags-5.8/html.c \
  ctags-5.8/jscript.c \
  ctags-5.8/keyword.c \
  ctags-5.8/lisp.c \
  ctags-5.8/lregex.c \
  ctags-5.8/lua.c \
  ctags-5.8/main.c \
  ctags-5.8/make.c \
  ctags-5.8/matlab.c \
  ctags-5.8/ocaml.c \
  ctags-5.8/options.c \
  ctags-5.8/parse.c \
  ctags-5.8/pascal.c \
  ctags-5.8/perl.c \
  ctags-5.8/php.c \
  ctags-5.8/python.c \
  ctags-5.8/read.c \
  ctags-5.8/rexx.c \
  ctags-5.8/routines.c \
  ctags-5.8/ruby.c \
  ctags-5.8/scheme.c \
  ctags-5.8/sh.c \
  ctags-5.8/slang.c \
  ctags-5.8/sml.c \
  ctags-5.8/sort.c \
  ctags-5.8/sql.c \
  ctags-5.8/strlist.c \
  ctags-5.8/tcl.c \
  ctags-5.8/tex.c \
  ctags-5.8/verilog.c \
  ctags-5.8/vhdl.c \
  ctags-5.8/vim.c \
  ctags-5.8/yacc.c \
  ctags-5.8/vstring.c \
  ctags-5.8/readtags.c

VPATH = ..
VPATH_COMPONENTS = 1

RUBY = ruby

ADLINT = adlint
ADLINT_FLAGS = -t adlint_traits.yml -o . -p $(VPATH_COMPONENTS)

ADLINT_SMA = adlint_sma
ADLINT_SMA_FLAGS = -t adlint_traits.yml -o . -p $(VPATH_COMPONENTS)

ADLINT_CMA = adlint_cma
ADLINT_CMA_FLAGS = -t adlint_traits.yml -o .

ADLINT_CHK = adlint_chk
ADLINT_CHK_FLAGS = -t adlint_traits.yml -o . -p $(VPATH_COMPONENTS)

RM = $(RUBY) -r fileutils -e 'FileUtils.rm_f(ARGV)'

VPATHED_SOURCES = $(addprefix $(VPATH)/, $(SOURCES))

SMA_MSG_FILES = $(addsuffix .msg.csv, $(SOURCES))
SMA_MET_FILES = $(addsuffix .met.csv, $(SOURCES))
SMA_I_FILES = $(addsuffix .i, $(basename $(SOURCES)))
SMA_LOG_FILES = $(addsuffix .log, $(SOURCES))

CMA_MSG_FILE = $(PROJECT).msg.csv
CMA_MET_FILE = $(PROJECT).met.csv
CMA_LOG_FILE = $(PROJECT).log

.SUFFIXES:

%.c.msg.csv %.c.met.csv : %.c
	$(ADLINT_SMA) $(ADLINT_SMA_FLAGS) $<

$(CMA_MET_FILE) : $(SMA_MET_FILES)
	$(ADLINT_CMA) $(ADLINT_CMA_FLAGS) $^

.PHONY: adlint_sma-all
adlint_sma-all : $(SMA_MET_FILES)

.PHONY: adlint_cma-all
adlint_cma-all : $(CMA_MET_FILE)

.PHONY: adlint_chk-all
adlint_chk-all :
	$(ADLINT_CHK) $(ADLINT_CHK_FLAGS) -v $(VPATHED_SOURCES)

.PHONY: adlint_verbose-all
adlint_verbose-all :
	$(ADLINT) $(ADLINT_FLAGS) -v $(VPATHED_SOURCES)

.PHONY: adlint_verbose-sma-only
adlint_verbose-sma-only :
	$(ADLINT_SMA) $(ADLINT_SMA_FLAGS) -v $(VPATHED_SOURCES)

.PHONY: adlint_verbose-cma-only
adlint_verbose-cma-only : $(SMA_MET_FILES)
	$(ADLINT_CMA) $(ADLINT_CMA_FLAGS) -v $^

.PHONY: adlint_clean
adlint_clean :
	@$(RM) $(SMA_MSG_FILES) $(SMA_MET_FILES) $(SMA_I_FILES) \
	       $(SMA_LOG_FILES) $(CMA_MSG_FILE) $(CMA_MET_FILE) $(CMA_LOG_FILE)

.PHONY: all
all : adlint_cma-all

.PHONY: sma-only
sma-only : adlint_sma-all

.PHONY: verbose-all
verbose-all : adlint_verbose-all

.PHONY: verbose-sma-only
verbose-sma-only : adlint_verbose-sma-only

.PHONY: verbose-cma-only
verbose-cma-only : adlint_verbose-cma-only

.PHONY: check
check : adlint_chk-all

.PHONY: clean
clean : adlint_clean
