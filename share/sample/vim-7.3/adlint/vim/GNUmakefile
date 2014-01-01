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

PROJECT = vim-7.3

SOURCES = \
  vim73/src/buffer.c \
  vim73/src/blowfish.c \
  vim73/src/charset.c \
  vim73/src/diff.c \
  vim73/src/digraph.c \
  vim73/src/edit.c \
  vim73/src/eval.c \
  vim73/src/ex_cmds.c \
  vim73/src/ex_cmds2.c \
  vim73/src/ex_docmd.c \
  vim73/src/ex_eval.c \
  vim73/src/ex_getln.c \
  vim73/src/fileio.c \
  vim73/src/fold.c \
  vim73/src/getchar.c \
  vim73/src/hardcopy.c \
  vim73/src/hashtab.c \
  vim73/src/if_cscope.c \
  vim73/src/if_xcmdsrv.c \
  vim73/src/main.c \
  vim73/src/mark.c \
  vim73/src/memfile.c \
  vim73/src/memline.c \
  vim73/src/menu.c \
  vim73/src/message.c \
  vim73/src/misc1.c \
  vim73/src/misc2.c \
  vim73/src/move.c \
  vim73/src/mbyte.c \
  vim73/src/normal.c \
  vim73/src/ops.c \
  vim73/src/option.c \
  vim73/src/os_unix.c \
  vim73/src/auto/pathdef.c \
  vim73/src/popupmnu.c \
  vim73/src/quickfix.c \
  vim73/src/regexp.c \
  vim73/src/screen.c \
  vim73/src/search.c \
  vim73/src/sha256.c \
  vim73/src/spell.c \
  vim73/src/syntax.c \
  vim73/src/tag.c \
  vim73/src/term.c \
  vim73/src/ui.c \
  vim73/src/undo.c \
  vim73/src/window.c \
  vim73/src/gui.c \
  vim73/src/gui_gtk.c \
  vim73/src/gui_gtk_x11.c \
  vim73/src/pty.c \
  vim73/src/gui_gtk_f.c \
  vim73/src/gui_beval.c \
  vim73/src/netbeans.c \
  vim73/src/version.c

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
