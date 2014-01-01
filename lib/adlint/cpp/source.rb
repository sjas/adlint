# Preprocessed pure C language source.
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

require "adlint/util"
require "adlint/cpp/asm"
require "adlint/cpp/subst"

module AdLint #:nodoc:
module Cpp #:nodoc:

  class PreprocessedSource
    include InlineAssemblyDefinition

    def initialize(root_fpath)
      @root_fpath = root_fpath
      @tokens = []
    end

    extend Pluggable

    def_plugin :on_language_extension
    def_plugin :on_inline_assembly

    attr_reader :root_fpath

    def add_token(tok)
      @tokens.push(tok)
    end

    def pp_tokens
      @tokens.select { |tok| tok.type == :PP_TOKEN }
    end

    def substitute_code_blocks(traits)
      traits.of_compiler.extension_substitutions.each do |ptn, repl|
        @tokens = create_extension_substitution(ptn, repl).execute(@tokens)
      end

      traits.of_compiler.arbitrary_substitutions.each do |ptn, repl|
        @tokens = create_arbitrary_substitution(ptn, repl).execute(@tokens)
      end

      create_inline_assembly_substitutions(self).each do |sub|
        @tokens = sub.execute(@tokens)
      end

      self
    end

    def to_s
      @lst_fpath     = nil
      @lst_line_no   = 0
      @lst_column_no = 1
      @lst_token     = nil
      @io = StringIO.new
      @io.set_encoding(Encoding.default_external)
      @tokens.each { |tok| print(tok) }
      @io.string
    end

    private
    def create_extension_substitution(ptn, repl)
      CodeSubstitution.new(ptn, repl).tap do |sub|
        sub.on_substitution += lambda { |matched_toks|
          on_language_extension.invoke(matched_toks)
        }
      end
    end

    def create_arbitrary_substitution(ptn, repl)
      CodeSubstitution.new(ptn, repl)
    end

    def print(tok)
      return if @lst_column_no == 1 && tok.type == :NEW_LINE

      if tok.location.fpath == @lst_fpath
        if @lst_line_no < tok.location.line_no
          if (vsp = tok.location.line_no - @lst_line_no) > 3
            insert_line_marker(tok)
          else
            vsp.times { @io.puts }
          end
        end
        if (hsp = tok.location.appearance_column_no - @lst_column_no) > 0
          @io.print(" " * hsp)
        elsif need_hspace?(tok)
          @io.print(" ")
        end
        if tok.type == :NEW_LINE
          @io.puts
          @lst_line_no = tok.location.line_no + 1
          @lst_column_no = 1
        else
          @io.print(tok.value.to_default_external)
          @lst_line_no = tok.location.line_no
          @lst_column_no = tok.location.appearance_column_no + tok.value.length
        end
      else
        insert_line_marker(tok)
        print(tok)
      end

      @lst_token = tok
    end

    def need_hspace?(tok)
      return false unless @lst_token
      if keyword_or_identifier?(@lst_token.value)
        !start_with_punctuator?(tok.value)
      else
        !(end_with_punctuator?(@lst_token.value) ||
          start_with_punctuator?(tok.value))
      end
    end

    def start_with_punctuator?(str)
      str !~ /\A[a-z_0-9]/i
    end

    def end_with_punctuator?(str)
      str !~ /[a-z_0-9]\z/i
    end

    def keyword_or_identifier?(str)
      str =~ /\A[a-z_][a-z_0-9]*\z/i
    end

    def insert_line_marker(tok)
      if @lst_column_no > 1
        @io.puts
      end
      line_marker = "# #{tok.location.line_no.to_s.to_default_external} " +
                    "\"#{tok.location.fpath.to_s.to_default_external}\""
      @io.puts(line_marker.to_default_external)
      @lst_fpath     = tok.location.fpath
      @lst_line_no   = tok.location.line_no
      @lst_column_no = 1
    end
  end

end
end
