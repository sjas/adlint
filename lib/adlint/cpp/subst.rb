# Pre-analysis code substitution mechanism.
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

require "adlint/report"
require "adlint/util"
require "adlint/cpp/lexer"

module AdLint #:nodoc:
module Cpp #:nodoc:

  class CodeSubstitution
    def initialize(ptn_str, repl_str)
      @pattern     = StringToPPTokensLexer.new(ptn_str).execute.to_a
      @replacement = StringToPPTokensLexer.new(repl_str).execute.to_a
    end

    extend Pluggable

    def_plugin :on_substitution

    def execute(toks)
      rslt_toks = []
      idx = 0
      while first_tok = toks[idx]
        matcher = Matcher.new(@pattern)
        matched_len = matcher.match(toks, idx)
        if matcher.accepted? || idx + matched_len == toks.size
          notify_substitution(toks, idx, matched_len)
          rslt_toks.concat(@replacement.map { |tok|
            Token.new(tok.type, tok.value, first_tok.location, tok.type_hint)
          })
          idx += matched_len
        else
          rslt_toks.push(first_tok)
          idx += 1
        end
      end
      rslt_toks
    end

    private
    def notify_substitution(toks, idx, len)
      matched_toks = toks[idx, len]
      on_substitution.invoke(matched_toks) unless matched_toks.empty?
    end
  end

  class Matcher
    def initialize(ptn_toks)
      @state = OuterTokenMatching.new(self)
      @pattern_tokens = ptn_toks
      @pattern_index  = 0
    end

    def rest_pattern_tokens
      @pattern_tokens[@pattern_index..-1]
    end

    def next_pattern_token
      ptn_tok = @pattern_tokens[@pattern_index]
      @pattern_index += 1
      ptn_tok
    end

    def match(toks, idx)
      return 0 if head = toks[idx] and head.type == :NEW_LINE

      match_len = 0
      while tok = toks[idx]
        unless tok.type == :NEW_LINE
          @state = @state.process(tok)
          break unless @state.matching?
        end
        match_len += 1
        idx += 1
      end
      match_len
    end

    def accepted?
      @state.accepted?
    end

    def matching?
      @state.matching?
    end

    def rejected?
      @state.rejected?
    end

    class State
      def initialize(matcher)
        @matcher = matcher
      end

      attr_reader :matcher

      def process(tok)
        subclass_responsibility
      end

      def accepted?
        subclass_responsibility
      end

      def rejected?
        subclass_responsibility
      end

      def matching?
        !accepted? && !rejected?
      end

      private
      def next_pattern_token
        @matcher.next_pattern_token
      end

      def rest_pattern_tokens
        @matcher.rest_pattern_tokens
      end
    end
    private_constant :State

    class Accepted < State
      def accepted?
        true
      end

      def rejected?
        false
      end
    end
    private_constant :Accepted

    class Rejected < State
      def accepted?
        false
      end

      def rejected?
        true
      end
    end
    private_constant :Rejected

    class Matching < State
      def accepted?
        false
      end

      def rejected?
        false
      end
    end
    private_constant :Matching

    class OuterTokenMatching < Matching
      def process(tok)
        if ptn_tok = next_pattern_token
          if tok.value == ptn_tok.value
            case tok.value
            when "(", "[", "{"
              InnerTokenMatching.new(matcher, self)
            else
              self
            end
          else
            if ptn_tok.value == "__adlint__any"
              if sentry_tok = rest_pattern_tokens.first and
                  tok.value == sentry_tok.value
                case tok.value
                when "(", "[", "{"
                  InnerTokenMatching.new(matcher, self).process(tok)
                else
                  self
                end
              else
                OuterAnyMatching.new(matcher)
              end
            else
              Rejected.new(matcher)
            end
          end
        else
          Accepted.new(matcher)
        end
      end
    end
    private_constant :OuterTokenMatching

    class OuterAnyMatching < Matching
      def process(tok)
        if sentry_tok = rest_pattern_tokens.first
          if tok.value == sentry_tok.value
            return OuterTokenMatching.new(@matcher).process(tok)
          end
        end
        self
      end
    end
    private_constant :OuterAnyMatching

    class InnerTokenMatching < Matching
      def initialize(matcher, prv_state)
        super(matcher)
        @prv_state = prv_state
      end

      def process(tok)
        if ptn_tok = next_pattern_token
          if tok.value == ptn_tok.value
            case tok.value
            when "(", "[", "{"
              InnerTokenMatching.new(matcher, self)
            when ")", "]", "}"
              @prv_state
            else
              self
            end
          else
            if ptn_tok.value == "__adlint__any"
              case tok.value
              when "(", "[", "{"
                InnerAnyMatching.new(matcher, self, 1)
              when ")", "]", "}"
                # NOTE: Return to the upper matching state and process the
                #       current token in order not to discard it.
                @prv_state.process(tok)
              else
                InnerAnyMatching.new(matcher, self, 0)
              end
            else
              Rejected.new(matcher)
            end
          end
        else
          Accepted.new(matcher)
        end
      end
    end
    private_constant :InnerTokenMatching

    class InnerAnyMatching < Matching
      def initialize(matcher, prv_state, depth)
        super(matcher)
        @prv_state = prv_state
        @depth = depth
      end

      def process(tok)
        case tok.value
        when "(", "[", "{"
          @depth += 1
        when ")", "]", "}"
          @depth -= 1
        end

        if sentry_tok = rest_pattern_tokens.first
          if tok.value == sentry_tok.value
            if @depth < 0
              return @prv_state.process(tok)
            end
          end
        end
        self
      end
    end
    private_constant :InnerAnyMatching
  end

end
end
