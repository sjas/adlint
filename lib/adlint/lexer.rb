# Lexical analyzer base classes.
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

require "adlint/token"
require "adlint/source"
require "adlint/traits"
require "adlint/error"

module AdLint #:nodoc:

  # == DESCRIPTION
  # Token queue to interface to the parser.
  class TokenQueue < Array
    # === DESCRIPTION
    # Constructs an empty token queue or a solid token queue from specified
    # token array.
    #
    # === PARAMETER
    # _token_ary_:: TokenArray -- Array of tokens.
    def initialize(tok_ary = nil)
      if tok_ary
        super
      else
        super()
      end
    end

    def expect(tok_type)
      tok = self.first
      tok && tok.type == tok_type ? true : false
    end
  end

  # == DESCRIPTION
  # Object represents the whole content of something.
  class Content
    def location
      subclass_responsibility
    end

    def empty?
      subclass_responsibility
    end
  end

  # == DESCRIPTION
  # Object represents the whole content of the string.
  class StringContent < Content
    # === DESCRIPTION
    # Constructs the content object of the string.
    #
    # === PARAMETER
    # _str_:: String -- Target string.
    # _fpath_:: Pathname -- File path name contains the target string.
    # _line_no_:: Integer -- Initial line-no of the target string.
    def initialize(str, tab_width = 8, fpath = nil, line_no = 1, col_no = 1)
      @scanner = StringScanner.new(str)
      @tab_width = tab_width
      @fpath, @line_no, @col_no = fpath, line_no, col_no
      @appearance_col_no = col_no
    end

    def location
      Location.new(@fpath, @line_no, @col_no, @appearance_col_no)
    end
    memoize :location

    # === DESCRIPTION
    # Scans a token.
    #
    # === PARAMETER
    # _regexp_:: Regexp -- Token pattern.
    #
    # === RETURN VALUE
    # String -- Token string or nil.
    def scan(regexp)
      tok = @scanner.scan(regexp)
      if tok
        update_location(tok)
        tok
      else
        nil
      end
    end

    def check(regexp)
      @scanner.check(regexp)
    end

    # === DESCRIPTION
    # Skips a content.
    #
    # === PARAMETER
    # _len_:: Integer -- Skipping content length.
    #
    # === RETURN VALUE
    # String -- Eaten string.
    def eat!(len = 1)
      self.scan(/.{#{len}}/m)
    end

    # === DESCRIPTION
    # Checks whether this content is currently empty or not.
    #
    # === RETURN VALUE
    # Boolean -- Returns true if already empty.
    def empty?
      @scanner.eos?
    end

    def _debug_inspect
      @scanner.rest
    end

    private
    def update_location(tok)
      if (nl_cnt = tok.count("\n")) > 0
        @line_no += nl_cnt
        lst_line = tok[tok.rindex("\n")..-1]
        @col_no = lst_line.length
        @appearance_col_no = lst_line.gsub(/\t/, " " * @tab_width).length
      else
        @col_no += tok.length
        @appearance_col_no += tok.gsub(/\t/, " " * @tab_width).length
      end
      forget_memo_of__location
    end
  end

  # == DESCRIPTION
  # Object represents the whole content of the source file.
  class SourceContent < StringContent
    # === DESCRIPTION
    # Constructs the content object of the source file.
    #
    # === PARAMETER
    # _src_:: Source -- Target source object.
    def initialize(src, tab_width)
      super(src.open { |io| io.read }, tab_width, src.fpath)
    end
  end

  class TokensContent < Content
    def initialize(tok_ary)
      @token_ary = tok_ary
    end

    def location
      if self.empty?
        nil
      else
        @token_ary.first.location
      end
    end

    def empty?
      @token_ary.empty?
    end

    def next_token
      if empty?
        nil
      else
        @token_ary.shift
      end
    end
  end

  # == DESCRIPTION
  # Generic lexical analysis context.
  class LexerContext
    # === DESCRIPTION
    # Constructs a lexical analysis context object.
    #
    # === PARAMETER
    # _cont_:: SourceContent | StringContent -- Target content.
    def initialize(cont)
      @content = cont
    end

    # === VALUE
    # SourceContent | StringContent -- The target content of this context.
    attr_reader :content

    # === DESCRIPTION
    # Reads the current location of the target content.
    #
    # === RETURN VALUE
    # Location -- Current location.
    def location
      @content.location
    end
  end

  # == DESCRIPTION
  # Base class of the lexical analyzer of the string.
  class StringLexer
    # === DESCRIPTION
    # Constructs a lexical analyzer of the string.
    #
    # === PARAMETER
    # _str_:: String -- Target string.
    def initialize(str)
      @str = str
    end

    # === DESCRIPTION
    # Executes the lexical analysis.
    #
    # === RETURN VALUE
    # TokenArray -- Scanned tokens.
    def execute
      lexer_ctxt = create_lexer_context(@str)
      tokenize(lexer_ctxt)
    rescue Error
      raise
    rescue => ex
      if lexer_ctxt
        raise InternalError.new(ex, lexer_ctxt.location)
      else
        raise InternalError.new(ex, nil)
      end
    end

    private
    # === DESCRIPTION
    # Creates the context object.
    #
    # Subclasses must implement this method.
    #
    # === PARAMETER
    # _str_:: String -- Target string object.
    def create_lexer_context(str)
      subclass_responsibility
    end

    # === DESCRIPTION
    # Tokenize the target content.
    #
    # Subclasses must implement this method.
    #
    # === PARAMETER
    # _lexer_ctxt_:: LexerContext -- Lexical analysis context.
    def tokenize(lexer_ctxt)
      subclass_responsibility
    end
  end

  class TokensRelexer
    def initialize(tok_ary)
      @lexer_ctxt = create_lexer_context(tok_ary)
    end

    def next_token
      tokenize(@lexer_ctxt)
    rescue Error
      raise
    rescue => ex
      raise InternalError.new(ex, @lexer_ctxt.location)
    end

    private
    def create_lexer_context(tok_ary)
      subclass_responsibility
    end

    def tokenize(lexer_ctxt)
      subclass_responsibility
    end
  end

end
