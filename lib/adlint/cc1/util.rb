# Miscellaneous utilities for C language.
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

module AdLint #:nodoc:
module Cc1 #:nodoc:

  class EscapeSequence
    def initialize(str)
      @str = str
    end

    def value
      case @str
      when "\\'" then "'".ord
      when "\\\"" then "\"".ord
      when "\\?" then "?".ord
      when "\\\\" then "\\".ord
      when "\\a" then "\a".ord
      when "\\b" then "\b".ord
      when "\\f" then "\f".ord
      when "\\n" then "\n".ord
      when "\\r" then "\r".ord
      when "\\t" then "\t".ord
      when "\\v" then "\v".ord
      else
        case @str
        when /\A\\([0-9]{1,3})\z/
          $1.to_i(8)
        when /\A\\x([0-9A-F]+)\z/i
          $1.to_i(16)
        when /\A\\u([0-9A-F]{4,8})\z/i
          $1.to_i(16)
        else
          0
        end
      end
    end
  end

  module DebugUtil
    def dump_syntax_tree(phase_ctxt)
      if $DEBUG
        ast_fname = phase_ctxt[:sources].first.fpath.basename.add_ext(".ast")
        ast_fpath = ast_fname.expand_path(phase_ctxt.msg_fpath.dirname)

        File.open(ast_fpath, "w") do |io|
          if phase_ctxt[:cc1_ast]
            PP.pp(phase_ctxt[:cc1_ast], io)
          end
        end
      end
    end
    module_function :dump_syntax_tree

    def dump_token_array(phase_ctxt)
      if $DEBUG
        tok_fname = phase_ctxt[:sources].first.fpath.basename.add_ext(".tok")
        tok_fpath = tok_fname.expand_path(phase_ctxt.msg_fpath.dirname)

        File.open(tok_fpath, "w") do |io|
          if phase_ctxt[:cc1_tokens]
            phase_ctxt[:cc1_tokens].each { |tok| io.puts(tok.inspect) }
          end
        end
      end
    end
    module_function :dump_token_array
  end

end
end
