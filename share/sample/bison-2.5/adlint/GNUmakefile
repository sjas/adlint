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
  lib/bison-2.5/lib/abitset.c.met.csv \
  lib/bison-2.5/lib/argmatch.c.met.csv \
  lib/bison-2.5/lib/asnprintf.c.met.csv \
  lib/bison-2.5/lib/basename-lgpl.c.met.csv \
  lib/bison-2.5/lib/basename.c.met.csv \
  lib/bison-2.5/lib/bitset.c.met.csv \
  lib/bison-2.5/lib/bitset_stats.c.met.csv \
  lib/bison-2.5/lib/bitsetv-print.c.met.csv \
  lib/bison-2.5/lib/bitsetv.c.met.csv \
  lib/bison-2.5/lib/c-ctype.c.met.csv \
  lib/bison-2.5/lib/c-strcasecmp.c.met.csv \
  lib/bison-2.5/lib/c-strncasecmp.c.met.csv \
  lib/bison-2.5/lib/cloexec.c.met.csv \
  lib/bison-2.5/lib/close-hook.c.met.csv \
  lib/bison-2.5/lib/dirname-lgpl.c.met.csv \
  lib/bison-2.5/lib/dirname.c.met.csv \
  lib/bison-2.5/lib/dup-safer-flag.c.met.csv \
  lib/bison-2.5/lib/dup-safer.c.met.csv \
  lib/bison-2.5/lib/ebitset.c.met.csv \
  lib/bison-2.5/lib/exitfail.c.met.csv \
  lib/bison-2.5/lib/fatal-signal.c.met.csv \
  lib/bison-2.5/lib/fcntl.c.met.csv \
  lib/bison-2.5/lib/fd-safer-flag.c.met.csv \
  lib/bison-2.5/lib/fd-safer.c.met.csv \
  lib/bison-2.5/lib/fopen-safer.c.met.csv \
  lib/bison-2.5/lib/fprintf.c.met.csv \
  lib/bison-2.5/lib/fseterr.c.met.csv \
  lib/bison-2.5/lib/get-errno.c.met.csv \
  lib/bison-2.5/lib/hash.c.met.csv \
  lib/bison-2.5/lib/ioctl.c.met.csv \
  lib/bison-2.5/lib/isnand.c.met.csv \
  lib/bison-2.5/lib/isnanf.c.met.csv \
  lib/bison-2.5/lib/isnanl.c.met.csv \
  lib/bison-2.5/lib/lbitset.c.met.csv \
  lib/bison-2.5/lib/localcharset.c.met.csv \
  lib/bison-2.5/lib/main.c.met.csv \
  lib/bison-2.5/lib/mbchar.c.met.csv \
  lib/bison-2.5/lib/mbschr.c.met.csv \
  lib/bison-2.5/lib/mbsrchr.c.met.csv \
  lib/bison-2.5/lib/mbswidth.c.met.csv \
  lib/bison-2.5/lib/nonblocking.c.met.csv \
  lib/bison-2.5/lib/pipe-safer.c.met.csv \
  lib/bison-2.5/lib/pipe2-safer.c.met.csv \
  lib/bison-2.5/lib/pipe2.c.met.csv \
  lib/bison-2.5/lib/printf-args.c.met.csv \
  lib/bison-2.5/lib/printf-frexp.c.met.csv \
  lib/bison-2.5/lib/printf-frexpl.c.met.csv \
  lib/bison-2.5/lib/printf-parse.c.met.csv \
  lib/bison-2.5/lib/printf.c.met.csv \
  lib/bison-2.5/lib/quote.c.met.csv \
  lib/bison-2.5/lib/quotearg.c.met.csv \
  lib/bison-2.5/lib/snprintf.c.met.csv \
  lib/bison-2.5/lib/spawn-pipe.c.met.csv \
  lib/bison-2.5/lib/sprintf.c.met.csv \
  lib/bison-2.5/lib/stripslash.c.met.csv \
  lib/bison-2.5/lib/strnlen1.c.met.csv \
  lib/bison-2.5/lib/timevar.c.met.csv \
  lib/bison-2.5/lib/uniwidth/width.c.met.csv \
  lib/bison-2.5/lib/vasnprintf.c.met.csv \
  lib/bison-2.5/lib/vbitset.c.met.csv \
  lib/bison-2.5/lib/vfprintf.c.met.csv \
  lib/bison-2.5/lib/vsnprintf.c.met.csv \
  lib/bison-2.5/lib/vsprintf.c.met.csv \
  lib/bison-2.5/lib/wait-process.c.met.csv \
  lib/bison-2.5/lib/xalloc-die.c.met.csv \
  lib/bison-2.5/lib/xmalloc.c.met.csv \
  lib/bison-2.5/lib/xstrndup.c.met.csv \
  lib/bison-2.5/lib/yyerror.c.met.csv \
  src/bison-2.5/src/AnnotationList.c.met.csv \
  src/bison-2.5/src/InadequacyList.c.met.csv \
  src/bison-2.5/src/LR0.c.met.csv \
  src/bison-2.5/src/Sbitset.c.met.csv \
  src/bison-2.5/src/assoc.c.met.csv \
  src/bison-2.5/src/closure.c.met.csv \
  src/bison-2.5/src/complain.c.met.csv \
  src/bison-2.5/src/conflicts.c.met.csv \
  src/bison-2.5/src/derives.c.met.csv \
  src/bison-2.5/src/files.c.met.csv \
  src/bison-2.5/src/getargs.c.met.csv \
  src/bison-2.5/src/gram.c.met.csv \
  src/bison-2.5/src/graphviz.c.met.csv \
  src/bison-2.5/src/ielr.c.met.csv \
  src/bison-2.5/src/lalr.c.met.csv \
  src/bison-2.5/src/location.c.met.csv \
  src/bison-2.5/src/main.c.met.csv \
  src/bison-2.5/src/muscle-tab.c.met.csv \
  src/bison-2.5/src/named-ref.c.met.csv \
  src/bison-2.5/src/nullable.c.met.csv \
  src/bison-2.5/src/output.c.met.csv \
  src/bison-2.5/src/parse-gram.c.met.csv \
  src/bison-2.5/src/print-xml.c.met.csv \
  src/bison-2.5/src/print.c.met.csv \
  src/bison-2.5/src/print_graph.c.met.csv \
  src/bison-2.5/src/reader.c.met.csv \
  src/bison-2.5/src/reduce.c.met.csv \
  src/bison-2.5/src/relation.c.met.csv \
  src/bison-2.5/src/scan-code-c.c.met.csv \
  src/bison-2.5/src/scan-gram-c.c.met.csv \
  src/bison-2.5/src/scan-skel-c.c.met.csv \
  src/bison-2.5/src/state.c.met.csv \
  src/bison-2.5/src/symlist.c.met.csv \
  src/bison-2.5/src/symtab.c.met.csv \
  src/bison-2.5/src/tables.c.met.csv \
  src/bison-2.5/src/uniqstr.c.met.csv

%.c.met.csv :
	@$(MAKE) -C `echo $@ | sed 's/\/.*$$//'` `echo $@ | sed 's/^[^/]\+\///'`

CMA_MSG_FILE = bison-2.5.msg.csv
CMA_MET_FILE = bison-2.5.met.csv
CMA_LOG_FILE = bison-2.5.log

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

.PHONY: verbose-cma-only
verbose-cma-only :
	$(ADLINT_CMA) $(ADLINT_CMA_FLAGS) -v $(SMA_MET_FILES)

.PHONY: clean
clean :
	@for f in $(SMA_MET_FILES); do \
	    dir=`echo $$f | sed 's/\/.*$$//'`; \
	    if [ "$$last_dir" != "$$dir" ]; then $(MAKE) -C $$dir clean; fi; \
	    last_dir=$$dir; \
	done
	@$(RM) $(CMA_MSG_FILE) $(CMA_MET_FILE) $(CMA_LOG_FILE)
