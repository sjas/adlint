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

PROJECT = ruby-1.9.3-p0

SOURCES = \
  ruby-1.9.3-p0/main.c \
  ruby-1.9.3-p0/dmydln.c \
  ruby-1.9.3-p0/dmyencoding.c \
  ruby-1.9.3-p0/version.c \
  ruby-1.9.3-p0/dmyversion.c \
  ruby-1.9.3-p0/miniprelude.c \
  ruby-1.9.3-p0/array.c \
  ruby-1.9.3-p0/bignum.c \
  ruby-1.9.3-p0/class.c \
  ruby-1.9.3-p0/compar.c \
  ruby-1.9.3-p0/complex.c \
  ruby-1.9.3-p0/dir.c \
  ruby-1.9.3-p0/dln_find.c \
  ruby-1.9.3-p0/enum.c \
  ruby-1.9.3-p0/enumerator.c \
  ruby-1.9.3-p0/error.c \
  ruby-1.9.3-p0/eval.c \
  ruby-1.9.3-p0/load.c \
  ruby-1.9.3-p0/proc.c \
  ruby-1.9.3-p0/file.c \
  ruby-1.9.3-p0/gc.c \
  ruby-1.9.3-p0/hash.c \
  ruby-1.9.3-p0/inits.c \
  ruby-1.9.3-p0/io.c \
  ruby-1.9.3-p0/marshal.c \
  ruby-1.9.3-p0/math.c \
  ruby-1.9.3-p0/node.c \
  ruby-1.9.3-p0/numeric.c \
  ruby-1.9.3-p0/object.c \
  ruby-1.9.3-p0/pack.c \
  ruby-1.9.3-p0/parse.c \
  ruby-1.9.3-p0/process.c \
  ruby-1.9.3-p0/random.c \
  ruby-1.9.3-p0/range.c \
  ruby-1.9.3-p0/rational.c \
  ruby-1.9.3-p0/re.c \
  ruby-1.9.3-p0/regcomp.c \
  ruby-1.9.3-p0/regenc.c \
  ruby-1.9.3-p0/regerror.c \
  ruby-1.9.3-p0/regexec.c \
  ruby-1.9.3-p0/regparse.c \
  ruby-1.9.3-p0/regsyntax.c \
  ruby-1.9.3-p0/ruby.c \
  ruby-1.9.3-p0/safe.c \
  ruby-1.9.3-p0/signal.c \
  ruby-1.9.3-p0/sprintf.c \
  ruby-1.9.3-p0/st.c \
  ruby-1.9.3-p0/strftime.c \
  ruby-1.9.3-p0/string.c \
  ruby-1.9.3-p0/struct.c \
  ruby-1.9.3-p0/time.c \
  ruby-1.9.3-p0/transcode.c \
  ruby-1.9.3-p0/util.c \
  ruby-1.9.3-p0/variable.c \
  ruby-1.9.3-p0/compile.c \
  ruby-1.9.3-p0/debug.c \
  ruby-1.9.3-p0/iseq.c \
  ruby-1.9.3-p0/vm.c \
  ruby-1.9.3-p0/vm_dump.c \
  ruby-1.9.3-p0/thread.c \
  ruby-1.9.3-p0/cont.c \
  ruby-1.9.3-p0/enc/ascii.c \
  ruby-1.9.3-p0/enc/us_ascii.c \
  ruby-1.9.3-p0/enc/unicode.c \
  ruby-1.9.3-p0/enc/utf_8.c \
  ruby-1.9.3-p0/newline.c \
  ruby-1.9.3-p0/missing/strlcpy.c \
  ruby-1.9.3-p0/missing/strlcat.c \
  ruby-1.9.3-p0/missing/setproctitle.c \
  ruby-1.9.3-p0/addr2line.c \
  ruby-1.9.3-p0/dmyext.c \
  ruby-1.9.3-p0/dln.c \
  ruby-1.9.3-p0/encoding.c \
  ruby-1.9.3-p0/prelude.c

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
