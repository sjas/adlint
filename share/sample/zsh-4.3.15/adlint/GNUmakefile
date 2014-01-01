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
#   - to analyze whole project with compiler like messages
#     % make all
#   - to analyze whole project with progress report
#     % make verbose-all
#   - to analyze whole project *FAST* on 4-core processor machine
#     % make -j 4 all
#   - to analyze whole project *FAST* and silently with elapsed time
#     % time make -j 4 all 2>/dev/null
#   - to delete all result files
#     % make clean
#

ADLINT_CMA = adlint_cma
ADLINT_CMA_FLAGS = -t adlint_traits.yml -o .

SMA_MET_FILES = \
  builtins/zsh-4.3.15/Src/Builtins/rlimits.c.met.csv \
  builtins/zsh-4.3.15/Src/Builtins/sched.c.met.csv \
  core/zsh-4.3.15/Src/builtin.c.met.csv \
  core/zsh-4.3.15/Src/compat.c.met.csv \
  core/zsh-4.3.15/Src/cond.c.met.csv \
  core/zsh-4.3.15/Src/exec.c.met.csv \
  core/zsh-4.3.15/Src/glob.c.met.csv \
  core/zsh-4.3.15/Src/hashnameddir.c.met.csv \
  core/zsh-4.3.15/Src/hashtable.c.met.csv \
  core/zsh-4.3.15/Src/hist.c.met.csv \
  core/zsh-4.3.15/Src/init.c.met.csv \
  core/zsh-4.3.15/Src/input.c.met.csv \
  core/zsh-4.3.15/Src/jobs.c.met.csv \
  core/zsh-4.3.15/Src/lex.c.met.csv \
  core/zsh-4.3.15/Src/linklist.c.met.csv \
  core/zsh-4.3.15/Src/loop.c.met.csv \
  core/zsh-4.3.15/Src/main.c.met.csv \
  core/zsh-4.3.15/Src/math.c.met.csv \
  core/zsh-4.3.15/Src/mem.c.met.csv \
  core/zsh-4.3.15/Src/module.c.met.csv \
  core/zsh-4.3.15/Src/options.c.met.csv \
  core/zsh-4.3.15/Src/params.c.met.csv \
  core/zsh-4.3.15/Src/parse.c.met.csv \
  core/zsh-4.3.15/Src/pattern.c.met.csv \
  core/zsh-4.3.15/Src/prompt.c.met.csv \
  core/zsh-4.3.15/Src/signals.c.met.csv \
  core/zsh-4.3.15/Src/signames.c.met.csv \
  core/zsh-4.3.15/Src/sort.c.met.csv \
  core/zsh-4.3.15/Src/string.c.met.csv \
  core/zsh-4.3.15/Src/subst.c.met.csv \
  core/zsh-4.3.15/Src/text.c.met.csv \
  core/zsh-4.3.15/Src/utils.c.met.csv \
  core/zsh-4.3.15/Src/watch.c.met.csv \
  modules/zsh-4.3.15/Src/Modules/attr.c.met.csv \
  modules/zsh-4.3.15/Src/Modules/cap.c.met.csv \
  modules/zsh-4.3.15/Src/Modules/clone.c.met.csv \
  modules/zsh-4.3.15/Src/Modules/curses.c.met.csv \
  modules/zsh-4.3.15/Src/Modules/datetime.c.met.csv \
  modules/zsh-4.3.15/Src/Modules/db_gdbm.c.met.csv \
  modules/zsh-4.3.15/Src/Modules/example.c.met.csv \
  modules/zsh-4.3.15/Src/Modules/files.c.met.csv \
  modules/zsh-4.3.15/Src/Modules/langinfo.c.met.csv \
  modules/zsh-4.3.15/Src/Modules/mapfile.c.met.csv \
  modules/zsh-4.3.15/Src/Modules/mathfunc.c.met.csv \
  modules/zsh-4.3.15/Src/Modules/newuser.c.met.csv \
  modules/zsh-4.3.15/Src/Modules/parameter.c.met.csv \
  modules/zsh-4.3.15/Src/Modules/regex.c.met.csv \
  modules/zsh-4.3.15/Src/Modules/socket.c.met.csv \
  modules/zsh-4.3.15/Src/Modules/stat.c.met.csv \
  modules/zsh-4.3.15/Src/Modules/system.c.met.csv \
  modules/zsh-4.3.15/Src/Modules/tcp.c.met.csv \
  modules/zsh-4.3.15/Src/Modules/termcap.c.met.csv \
  modules/zsh-4.3.15/Src/Modules/terminfo.c.met.csv \
  modules/zsh-4.3.15/Src/Modules/zftp.c.met.csv \
  modules/zsh-4.3.15/Src/Modules/zprof.c.met.csv \
  modules/zsh-4.3.15/Src/Modules/zpty.c.met.csv \
  modules/zsh-4.3.15/Src/Modules/zselect.c.met.csv \
  modules/zsh-4.3.15/Src/Modules/zutil.c.met.csv \
  zle/zsh-4.3.15/Src/Zle/compcore.c.met.csv \
  zle/zsh-4.3.15/Src/Zle/compctl.c.met.csv \
  zle/zsh-4.3.15/Src/Zle/complete.c.met.csv \
  zle/zsh-4.3.15/Src/Zle/complist.c.met.csv \
  zle/zsh-4.3.15/Src/Zle/compmatch.c.met.csv \
  zle/zsh-4.3.15/Src/Zle/compresult.c.met.csv \
  zle/zsh-4.3.15/Src/Zle/computil.c.met.csv \
  zle/zsh-4.3.15/Src/Zle/deltochar.c.met.csv \
  zle/zsh-4.3.15/Src/Zle/zle_bindings.c.met.csv \
  zle/zsh-4.3.15/Src/Zle/zle_hist.c.met.csv \
  zle/zsh-4.3.15/Src/Zle/zle_keymap.c.met.csv \
  zle/zsh-4.3.15/Src/Zle/zle_main.c.met.csv \
  zle/zsh-4.3.15/Src/Zle/zle_misc.c.met.csv \
  zle/zsh-4.3.15/Src/Zle/zle_move.c.met.csv \
  zle/zsh-4.3.15/Src/Zle/zle_params.c.met.csv \
  zle/zsh-4.3.15/Src/Zle/zle_refresh.c.met.csv \
  zle/zsh-4.3.15/Src/Zle/zle_thingy.c.met.csv \
  zle/zsh-4.3.15/Src/Zle/zle_tricky.c.met.csv \
  zle/zsh-4.3.15/Src/Zle/zle_utils.c.met.csv \
  zle/zsh-4.3.15/Src/Zle/zle_vi.c.met.csv \
  zle/zsh-4.3.15/Src/Zle/zle_word.c.met.csv \
  zle/zsh-4.3.15/Src/Zle/zleparameter.c.met.csv

%.c.met.csv :
	@$(MAKE) -C `echo $@ | sed 's/\/.*$$//'` `echo $@ | sed 's/^[^/]\+\///'`

CMA_MSG_FILE = zsh-4.3.15.msg.csv
CMA_MET_FILE = zsh-4.3.15.met.csv
CMA_LOG_FILE = zsh-4.3.15.log

.PHONY: all
all : $(SMA_MET_FILES)
	$(ADLINT_CMA) $(ADLINT_CMA_FLAGS) $(SMA_MET_FILES)

.PHONY: verbose-all
verbose-all :
	@for f in $(SMA_MET_FILES); do \
	    dir=`echo $$f | sed 's/\/.*$$//'`; \
	    if [ "$$last_dir" != "$$dir" ]; then $(MAKE) -C $$dir verbose-sma-only; fi; \
	    last_dir=$$dir; \
	done
	$(ADLINT_CMA) $(ADLINT_CMA_FLAGS) -v $(SMA_MET_FILES)

.PHONY: clean
clean :
	@for f in $(SMA_MET_FILES); do \
	    dir=`echo $$f | sed 's/\/.*$$//'`; \
	    if [ "$$last_dir" != "$$dir" ]; then $(MAKE) -C $$dir clean; fi; \
	    last_dir=$$dir; \
	done
	@$(RM) $(CMA_MSG_FILE) $(CMA_MET_FILE) $(CMA_LOG_FILE)
