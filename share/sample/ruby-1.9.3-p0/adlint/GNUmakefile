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
  core/ruby-1.9.3-p0/main.c.met.csv \
  core/ruby-1.9.3-p0/dmydln.c.met.csv \
  core/ruby-1.9.3-p0/dmyencoding.c.met.csv \
  core/ruby-1.9.3-p0/version.c.met.csv \
  core/ruby-1.9.3-p0/dmyversion.c.met.csv \
  core/ruby-1.9.3-p0/miniprelude.c.met.csv \
  core/ruby-1.9.3-p0/array.c.met.csv \
  core/ruby-1.9.3-p0/bignum.c.met.csv \
  core/ruby-1.9.3-p0/class.c.met.csv \
  core/ruby-1.9.3-p0/compar.c.met.csv \
  core/ruby-1.9.3-p0/complex.c.met.csv \
  core/ruby-1.9.3-p0/dir.c.met.csv \
  core/ruby-1.9.3-p0/dln_find.c.met.csv \
  core/ruby-1.9.3-p0/enum.c.met.csv \
  core/ruby-1.9.3-p0/enumerator.c.met.csv \
  core/ruby-1.9.3-p0/error.c.met.csv \
  core/ruby-1.9.3-p0/eval.c.met.csv \
  core/ruby-1.9.3-p0/load.c.met.csv \
  core/ruby-1.9.3-p0/proc.c.met.csv \
  core/ruby-1.9.3-p0/file.c.met.csv \
  core/ruby-1.9.3-p0/gc.c.met.csv \
  core/ruby-1.9.3-p0/hash.c.met.csv \
  core/ruby-1.9.3-p0/inits.c.met.csv \
  core/ruby-1.9.3-p0/io.c.met.csv \
  core/ruby-1.9.3-p0/marshal.c.met.csv \
  core/ruby-1.9.3-p0/math.c.met.csv \
  core/ruby-1.9.3-p0/node.c.met.csv \
  core/ruby-1.9.3-p0/numeric.c.met.csv \
  core/ruby-1.9.3-p0/object.c.met.csv \
  core/ruby-1.9.3-p0/pack.c.met.csv \
  core/ruby-1.9.3-p0/parse.c.met.csv \
  core/ruby-1.9.3-p0/process.c.met.csv \
  core/ruby-1.9.3-p0/random.c.met.csv \
  core/ruby-1.9.3-p0/range.c.met.csv \
  core/ruby-1.9.3-p0/rational.c.met.csv \
  core/ruby-1.9.3-p0/re.c.met.csv \
  core/ruby-1.9.3-p0/regcomp.c.met.csv \
  core/ruby-1.9.3-p0/regenc.c.met.csv \
  core/ruby-1.9.3-p0/regerror.c.met.csv \
  core/ruby-1.9.3-p0/regexec.c.met.csv \
  core/ruby-1.9.3-p0/regparse.c.met.csv \
  core/ruby-1.9.3-p0/regsyntax.c.met.csv \
  core/ruby-1.9.3-p0/ruby.c.met.csv \
  core/ruby-1.9.3-p0/safe.c.met.csv \
  core/ruby-1.9.3-p0/signal.c.met.csv \
  core/ruby-1.9.3-p0/sprintf.c.met.csv \
  core/ruby-1.9.3-p0/st.c.met.csv \
  core/ruby-1.9.3-p0/strftime.c.met.csv \
  core/ruby-1.9.3-p0/string.c.met.csv \
  core/ruby-1.9.3-p0/struct.c.met.csv \
  core/ruby-1.9.3-p0/time.c.met.csv \
  core/ruby-1.9.3-p0/transcode.c.met.csv \
  core/ruby-1.9.3-p0/util.c.met.csv \
  core/ruby-1.9.3-p0/variable.c.met.csv \
  core/ruby-1.9.3-p0/compile.c.met.csv \
  core/ruby-1.9.3-p0/debug.c.met.csv \
  core/ruby-1.9.3-p0/iseq.c.met.csv \
  core/ruby-1.9.3-p0/vm.c.met.csv \
  core/ruby-1.9.3-p0/vm_dump.c.met.csv \
  core/ruby-1.9.3-p0/thread.c.met.csv \
  core/ruby-1.9.3-p0/cont.c.met.csv \
  core/ruby-1.9.3-p0/enc/ascii.c.met.csv \
  core/ruby-1.9.3-p0/enc/us_ascii.c.met.csv \
  core/ruby-1.9.3-p0/enc/unicode.c.met.csv \
  core/ruby-1.9.3-p0/enc/utf_8.c.met.csv \
  core/ruby-1.9.3-p0/newline.c.met.csv \
  core/ruby-1.9.3-p0/missing/strlcpy.c.met.csv \
  core/ruby-1.9.3-p0/missing/strlcat.c.met.csv \
  core/ruby-1.9.3-p0/missing/setproctitle.c.met.csv \
  core/ruby-1.9.3-p0/addr2line.c.met.csv \
  core/ruby-1.9.3-p0/dmyext.c.met.csv \
  core/ruby-1.9.3-p0/dln.c.met.csv \
  core/ruby-1.9.3-p0/encoding.c.met.csv \
  core/ruby-1.9.3-p0/prelude.c.met.csv \
  enc/ruby-1.9.3-p0/enc/encdb.c.met.csv \
  enc/ruby-1.9.3-p0/enc/big5.c.met.csv \
  enc/ruby-1.9.3-p0/enc/cp949.c.met.csv \
  enc/ruby-1.9.3-p0/enc/emacs_mule.c.met.csv \
  enc/ruby-1.9.3-p0/enc/euc_jp.c.met.csv \
  enc/ruby-1.9.3-p0/enc/euc_kr.c.met.csv \
  enc/ruby-1.9.3-p0/enc/euc_tw.c.met.csv \
  enc/ruby-1.9.3-p0/enc/gb2312.c.met.csv \
  enc/ruby-1.9.3-p0/enc/gb18030.c.met.csv \
  enc/ruby-1.9.3-p0/enc/gbk.c.met.csv \
  enc/ruby-1.9.3-p0/enc/iso_8859_1.c.met.csv \
  enc/ruby-1.9.3-p0/enc/iso_8859_2.c.met.csv \
  enc/ruby-1.9.3-p0/enc/iso_8859_3.c.met.csv \
  enc/ruby-1.9.3-p0/enc/iso_8859_4.c.met.csv \
  enc/ruby-1.9.3-p0/enc/iso_8859_5.c.met.csv \
  enc/ruby-1.9.3-p0/enc/iso_8859_6.c.met.csv \
  enc/ruby-1.9.3-p0/enc/iso_8859_7.c.met.csv \
  enc/ruby-1.9.3-p0/enc/iso_8859_8.c.met.csv \
  enc/ruby-1.9.3-p0/enc/iso_8859_9.c.met.csv \
  enc/ruby-1.9.3-p0/enc/iso_8859_10.c.met.csv \
  enc/ruby-1.9.3-p0/enc/iso_8859_11.c.met.csv \
  enc/ruby-1.9.3-p0/enc/iso_8859_13.c.met.csv \
  enc/ruby-1.9.3-p0/enc/iso_8859_14.c.met.csv \
  enc/ruby-1.9.3-p0/enc/iso_8859_15.c.met.csv \
  enc/ruby-1.9.3-p0/enc/iso_8859_16.c.met.csv \
  enc/ruby-1.9.3-p0/enc/koi8_r.c.met.csv \
  enc/ruby-1.9.3-p0/enc/koi8_u.c.met.csv \
  enc/ruby-1.9.3-p0/enc/shift_jis.c.met.csv \
  enc/ruby-1.9.3-p0/enc/utf_16be.c.met.csv \
  enc/ruby-1.9.3-p0/enc/utf_16le.c.met.csv \
  enc/ruby-1.9.3-p0/enc/utf_32be.c.met.csv \
  enc/ruby-1.9.3-p0/enc/utf_32le.c.met.csv \
  enc/ruby-1.9.3-p0/enc/windows_1251.c.met.csv \
  enc-trans/ruby-1.9.3-p0/enc/trans/transdb.c.met.csv \
  enc-trans/ruby-1.9.3-p0/enc/trans/big5.c.met.csv \
  enc-trans/ruby-1.9.3-p0/enc/trans/chinese.c.met.csv \
  enc-trans/ruby-1.9.3-p0/enc/trans/emoji.c.met.csv \
  enc-trans/ruby-1.9.3-p0/enc/trans/emoji_iso2022_kddi.c.met.csv \
  enc-trans/ruby-1.9.3-p0/enc/trans/emoji_sjis_docomo.c.met.csv \
  enc-trans/ruby-1.9.3-p0/enc/trans/emoji_sjis_kddi.c.met.csv \
  enc-trans/ruby-1.9.3-p0/enc/trans/emoji_sjis_softbank.c.met.csv \
  enc-trans/ruby-1.9.3-p0/enc/trans/escape.c.met.csv \
  enc-trans/ruby-1.9.3-p0/enc/trans/gb18030.c.met.csv \
  enc-trans/ruby-1.9.3-p0/enc/trans/gbk.c.met.csv \
  enc-trans/ruby-1.9.3-p0/enc/trans/iso2022.c.met.csv \
  enc-trans/ruby-1.9.3-p0/enc/trans/japanese.c.met.csv \
  enc-trans/ruby-1.9.3-p0/enc/trans/japanese_euc.c.met.csv \
  enc-trans/ruby-1.9.3-p0/enc/trans/japanese_sjis.c.met.csv \
  enc-trans/ruby-1.9.3-p0/enc/trans/korean.c.met.csv \
  enc-trans/ruby-1.9.3-p0/enc/trans/single_byte.c.met.csv \
  enc-trans/ruby-1.9.3-p0/enc/trans/utf8_mac.c.met.csv \
  enc-trans/ruby-1.9.3-p0/enc/trans/utf_16_32.c.met.csv \
  ext-bigdecimal/ruby-1.9.3-p0/ext/bigdecimal/bigdecimal.c.met.csv \
  ext-continuation/ruby-1.9.3-p0/ext/continuation/continuation.c.met.csv \
  ext-coverage/ruby-1.9.3-p0/ext/coverage/coverage.c.met.csv \
  ext-curses/ruby-1.9.3-p0/ext/curses/curses.c.met.csv \
  ext-date/ruby-1.9.3-p0/ext/date/date_strptime.c.met.csv \
  ext-date/ruby-1.9.3-p0/ext/date/date_strftime.c.met.csv \
  ext-date/ruby-1.9.3-p0/ext/date/date_core.c.met.csv \
  ext-date/ruby-1.9.3-p0/ext/date/date_parse.c.met.csv \
  ext-dbm/ruby-1.9.3-p0/ext/dbm/dbm.c.met.csv \
  ext-digest/ruby-1.9.3-p0/ext/digest/digest.c.met.csv \
  ext-digest-bubblebabble/ruby-1.9.3-p0/ext/digest/bubblebabble/bubblebabble.c.met.csv \
  ext-digest-md5/ruby-1.9.3-p0/ext/digest/md5/md5init.c.met.csv \
  ext-digest-md5/ruby-1.9.3-p0/ext/digest/md5/md5ossl.c.met.csv \
  ext-digest-rmd160/ruby-1.9.3-p0/ext/digest/rmd160/rmd160init.c.met.csv \
  ext-digest-rmd160/ruby-1.9.3-p0/ext/digest/rmd160/rmd160ossl.c.met.csv \
  ext-digest-sha1/ruby-1.9.3-p0/ext/digest/sha1/sha1init.c.met.csv \
  ext-digest-sha1/ruby-1.9.3-p0/ext/digest/sha1/sha1ossl.c.met.csv \
  ext-digest-sha2/ruby-1.9.3-p0/ext/digest/sha2/sha2init.c.met.csv \
  ext-digest-sha2/ruby-1.9.3-p0/ext/digest/sha2/sha2ossl.c.met.csv \
  ext-dl/ruby-1.9.3-p0/ext/dl/dl.c.met.csv \
  ext-dl/ruby-1.9.3-p0/ext/dl/cptr.c.met.csv \
  ext-dl/ruby-1.9.3-p0/ext/dl/cfunc.c.met.csv \
  ext-dl/ruby-1.9.3-p0/ext/dl/handle.c.met.csv \
  ext-dl-callback/ruby-1.9.3-p0/ext/dl/callback/callback.c.met.csv \
  ext-dl-callback/ruby-1.9.3-p0/ext/dl/callback/callback-0.c.met.csv \
  ext-dl-callback/ruby-1.9.3-p0/ext/dl/callback/callback-1.c.met.csv \
  ext-dl-callback/ruby-1.9.3-p0/ext/dl/callback/callback-2.c.met.csv \
  ext-dl-callback/ruby-1.9.3-p0/ext/dl/callback/callback-3.c.met.csv \
  ext-dl-callback/ruby-1.9.3-p0/ext/dl/callback/callback-4.c.met.csv \
  ext-dl-callback/ruby-1.9.3-p0/ext/dl/callback/callback-5.c.met.csv \
  ext-dl-callback/ruby-1.9.3-p0/ext/dl/callback/callback-6.c.met.csv \
  ext-dl-callback/ruby-1.9.3-p0/ext/dl/callback/callback-7.c.met.csv \
  ext-dl-callback/ruby-1.9.3-p0/ext/dl/callback/callback-8.c.met.csv \
  ext-etc/ruby-1.9.3-p0/ext/etc/etc.c.met.csv \
  ext-fcntl/ruby-1.9.3-p0/ext/fcntl/fcntl.c.met.csv \
  ext-fiber/ruby-1.9.3-p0/ext/fiber/fiber.c.met.csv \
  ext-fiddle/ruby-1.9.3-p0/ext/fiddle/closure.c.met.csv \
  ext-fiddle/ruby-1.9.3-p0/ext/fiddle/function.c.met.csv \
  ext-fiddle/ruby-1.9.3-p0/ext/fiddle/conversions.c.met.csv \
  ext-fiddle/ruby-1.9.3-p0/ext/fiddle/fiddle.c.met.csv \
  ext-gdbm/ruby-1.9.3-p0/ext/gdbm/gdbm.c.met.csv \
  ext-iconv/ruby-1.9.3-p0/ext/iconv/iconv.c.met.csv \
  ext-io-console/ruby-1.9.3-p0/ext/io/console/console.c.met.csv \
  ext-io-nonblock/ruby-1.9.3-p0/ext/io/nonblock/nonblock.c.met.csv \
  ext-io-wait/ruby-1.9.3-p0/ext/io/wait/wait.c.met.csv \
  ext-json-generator/ruby-1.9.3-p0/ext/json/generator/generator.c.met.csv \
  ext-json-parser/ruby-1.9.3-p0/ext/json/parser/parser.c.met.csv \
  ext-mathn-complex/ruby-1.9.3-p0/ext/mathn/complex/complex.c.met.csv \
  ext-mathn-rational/ruby-1.9.3-p0/ext/mathn/rational/rational.c.met.csv \
  ext-nkf/ruby-1.9.3-p0/ext/nkf/nkf.c.met.csv \
  ext-openssl/ruby-1.9.3-p0/ext/openssl/ossl_rand.c.met.csv \
  ext-openssl/ruby-1.9.3-p0/ext/openssl/ossl_ocsp.c.met.csv \
  ext-openssl/ruby-1.9.3-p0/ext/openssl/ossl_pkey_dh.c.met.csv \
  ext-openssl/ruby-1.9.3-p0/ext/openssl/ossl_x509revoked.c.met.csv \
  ext-openssl/ruby-1.9.3-p0/ext/openssl/openssl_missing.c.met.csv \
  ext-openssl/ruby-1.9.3-p0/ext/openssl/ossl_pkcs12.c.met.csv \
  ext-openssl/ruby-1.9.3-p0/ext/openssl/ossl.c.met.csv \
  ext-openssl/ruby-1.9.3-p0/ext/openssl/ossl_pkey_ec.c.met.csv \
  ext-openssl/ruby-1.9.3-p0/ext/openssl/ossl_x509name.c.met.csv \
  ext-openssl/ruby-1.9.3-p0/ext/openssl/ossl_ns_spki.c.met.csv \
  ext-openssl/ruby-1.9.3-p0/ext/openssl/ossl_ssl_session.c.met.csv \
  ext-openssl/ruby-1.9.3-p0/ext/openssl/ossl_pkey_rsa.c.met.csv \
  ext-openssl/ruby-1.9.3-p0/ext/openssl/ossl_pkcs7.c.met.csv \
  ext-openssl/ruby-1.9.3-p0/ext/openssl/ossl_ssl.c.met.csv \
  ext-openssl/ruby-1.9.3-p0/ext/openssl/ossl_hmac.c.met.csv \
  ext-openssl/ruby-1.9.3-p0/ext/openssl/ossl_bio.c.met.csv \
  ext-openssl/ruby-1.9.3-p0/ext/openssl/ossl_pkcs5.c.met.csv \
  ext-openssl/ruby-1.9.3-p0/ext/openssl/ossl_x509req.c.met.csv \
  ext-openssl/ruby-1.9.3-p0/ext/openssl/ossl_x509store.c.met.csv \
  ext-openssl/ruby-1.9.3-p0/ext/openssl/ossl_x509cert.c.met.csv \
  ext-openssl/ruby-1.9.3-p0/ext/openssl/ossl_cipher.c.met.csv \
  ext-openssl/ruby-1.9.3-p0/ext/openssl/ossl_digest.c.met.csv \
  ext-openssl/ruby-1.9.3-p0/ext/openssl/ossl_config.c.met.csv \
  ext-openssl/ruby-1.9.3-p0/ext/openssl/ossl_bn.c.met.csv \
  ext-openssl/ruby-1.9.3-p0/ext/openssl/ossl_x509attr.c.met.csv \
  ext-openssl/ruby-1.9.3-p0/ext/openssl/ossl_x509.c.met.csv \
  ext-openssl/ruby-1.9.3-p0/ext/openssl/ossl_x509crl.c.met.csv \
  ext-openssl/ruby-1.9.3-p0/ext/openssl/ossl_x509ext.c.met.csv \
  ext-openssl/ruby-1.9.3-p0/ext/openssl/ossl_asn1.c.met.csv \
  ext-openssl/ruby-1.9.3-p0/ext/openssl/ossl_engine.c.met.csv \
  ext-openssl/ruby-1.9.3-p0/ext/openssl/ossl_pkey_dsa.c.met.csv \
  ext-openssl/ruby-1.9.3-p0/ext/openssl/ossl_pkey.c.met.csv \
  ext-pathname/ruby-1.9.3-p0/ext/pathname/pathname.c.met.csv \
  ext-psych/ruby-1.9.3-p0/ext/psych/psych.c.met.csv \
  ext-psych/ruby-1.9.3-p0/ext/psych/yaml_tree.c.met.csv \
  ext-psych/ruby-1.9.3-p0/ext/psych/parser.c.met.csv \
  ext-psych/ruby-1.9.3-p0/ext/psych/emitter.c.met.csv \
  ext-psych/ruby-1.9.3-p0/ext/psych/to_ruby.c.met.csv \
  ext-pty/ruby-1.9.3-p0/ext/pty/pty.c.met.csv \
  ext-racc-cparse/ruby-1.9.3-p0/ext/racc/cparse/cparse.c.met.csv \
  ext-readline/ruby-1.9.3-p0/ext/readline/readline.c.met.csv \
  ext-ripper/ruby-1.9.3-p0/ext/ripper/ripper.c.met.csv \
  ext-sdbm/ruby-1.9.3-p0/ext/sdbm/init.c.met.csv \
  ext-sdbm/ruby-1.9.3-p0/ext/sdbm/_sdbm.c.met.csv \
  ext-socket/ruby-1.9.3-p0/ext/socket/init.c.met.csv \
  ext-socket/ruby-1.9.3-p0/ext/socket/constants.c.met.csv \
  ext-socket/ruby-1.9.3-p0/ext/socket/basicsocket.c.met.csv \
  ext-socket/ruby-1.9.3-p0/ext/socket/socket.c.met.csv \
  ext-socket/ruby-1.9.3-p0/ext/socket/ipsocket.c.met.csv \
  ext-socket/ruby-1.9.3-p0/ext/socket/tcpsocket.c.met.csv \
  ext-socket/ruby-1.9.3-p0/ext/socket/tcpserver.c.met.csv \
  ext-socket/ruby-1.9.3-p0/ext/socket/sockssocket.c.met.csv \
  ext-socket/ruby-1.9.3-p0/ext/socket/udpsocket.c.met.csv \
  ext-socket/ruby-1.9.3-p0/ext/socket/unixsocket.c.met.csv \
  ext-socket/ruby-1.9.3-p0/ext/socket/unixserver.c.met.csv \
  ext-socket/ruby-1.9.3-p0/ext/socket/option.c.met.csv \
  ext-socket/ruby-1.9.3-p0/ext/socket/ancdata.c.met.csv \
  ext-socket/ruby-1.9.3-p0/ext/socket/raddrinfo.c.met.csv \
  ext-stringio/ruby-1.9.3-p0/ext/stringio/stringio.c.met.csv \
  ext-strscan/ruby-1.9.3-p0/ext/strscan/strscan.c.met.csv \
  ext-syck/ruby-1.9.3-p0/ext/syck/gram.c.met.csv \
  ext-syck/ruby-1.9.3-p0/ext/syck/handler.c.met.csv \
  ext-syck/ruby-1.9.3-p0/ext/syck/implicit.c.met.csv \
  ext-syck/ruby-1.9.3-p0/ext/syck/node.c.met.csv \
  ext-syck/ruby-1.9.3-p0/ext/syck/token.c.met.csv \
  ext-syck/ruby-1.9.3-p0/ext/syck/yaml2byte.c.met.csv \
  ext-syck/ruby-1.9.3-p0/ext/syck/emitter.c.met.csv \
  ext-syck/ruby-1.9.3-p0/ext/syck/bytecode.c.met.csv \
  ext-syck/ruby-1.9.3-p0/ext/syck/syck.c.met.csv \
  ext-syck/ruby-1.9.3-p0/ext/syck/rubyext.c.met.csv \
  ext-syslog/ruby-1.9.3-p0/ext/syslog/syslog.c.met.csv \
  ext-zlib/ruby-1.9.3-p0/ext/zlib/zlib.c.met.csv

%.c.met.csv :
	@$(MAKE) -C `echo $@ | sed 's/\/.*$$//'` `echo $@ | sed 's/^[^/]\+\///'`

CMA_MSG_FILE = ruby-1.9.3-p0.msg.csv
CMA_MET_FILE = ruby-1.9.3-p0.met.csv
CMA_LOG_FILE = ruby-1.9.3-p0.log

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
