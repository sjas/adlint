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

PROJECT = bison-2.5

SOURCES = \
  bison-2.5/lib/main.c \
  bison-2.5/lib/yyerror.c \
  bison-2.5/lib/c-ctype.c \
  bison-2.5/lib/c-strcasecmp.c \
  bison-2.5/lib/c-strncasecmp.c \
  bison-2.5/lib/close-hook.c \
  bison-2.5/lib/exitfail.c \
  bison-2.5/lib/fatal-signal.c \
  bison-2.5/lib/fd-safer-flag.c \
  bison-2.5/lib/dup-safer-flag.c \
  bison-2.5/lib/fseterr.c \
  bison-2.5/lib/localcharset.c \
  bison-2.5/lib/mbchar.c \
  bison-2.5/lib/mbschr.c \
  bison-2.5/lib/mbsrchr.c \
  bison-2.5/lib/mbswidth.c \
  bison-2.5/lib/nonblocking.c \
  bison-2.5/lib/pipe2.c \
  bison-2.5/lib/pipe2-safer.c \
  bison-2.5/lib/printf-frexp.c \
  bison-2.5/lib/printf-frexpl.c \
  bison-2.5/lib/spawn-pipe.c \
  bison-2.5/lib/strnlen1.c \
  bison-2.5/lib/uniwidth/width.c \
  bison-2.5/lib/wait-process.c \
  bison-2.5/lib/xalloc-die.c \
  bison-2.5/lib/xstrndup.c \
  bison-2.5/lib/get-errno.c \
  bison-2.5/lib/abitset.c \
  bison-2.5/lib/bitset.c \
  bison-2.5/lib/bitset_stats.c \
  bison-2.5/lib/bitsetv.c \
  bison-2.5/lib/ebitset.c \
  bison-2.5/lib/lbitset.c \
  bison-2.5/lib/vbitset.c \
  bison-2.5/lib/bitsetv-print.c \
  bison-2.5/lib/timevar.c \
  bison-2.5/lib/argmatch.c \
  bison-2.5/lib/asnprintf.c \
  bison-2.5/lib/basename.c \
  bison-2.5/lib/basename-lgpl.c \
  bison-2.5/lib/cloexec.c \
  bison-2.5/lib/dirname.c \
  bison-2.5/lib/dirname-lgpl.c \
  bison-2.5/lib/dup-safer.c \
  bison-2.5/lib/fcntl.c \
  bison-2.5/lib/fd-safer.c \
  bison-2.5/lib/fopen-safer.c \
  bison-2.5/lib/fprintf.c \
  bison-2.5/lib/hash.c \
  bison-2.5/lib/ioctl.c \
  bison-2.5/lib/isnand.c \
  bison-2.5/lib/isnanf.c \
  bison-2.5/lib/isnanl.c \
  bison-2.5/lib/pipe-safer.c \
  bison-2.5/lib/printf.c \
  bison-2.5/lib/printf-args.c \
  bison-2.5/lib/printf-parse.c \
  bison-2.5/lib/quote.c \
  bison-2.5/lib/quotearg.c \
  bison-2.5/lib/snprintf.c \
  bison-2.5/lib/sprintf.c \
  bison-2.5/lib/stripslash.c \
  bison-2.5/lib/vasnprintf.c \
  bison-2.5/lib/vfprintf.c \
  bison-2.5/lib/vsnprintf.c \
  bison-2.5/lib/vsprintf.c \
  bison-2.5/lib/xmalloc.c

VPATH = ../..
VPATH_COMPONENTS = 2

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
