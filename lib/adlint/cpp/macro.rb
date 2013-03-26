# C preprocessor macros.
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
require "adlint/report"
require "adlint/util"
require "adlint/cpp/syntax"
require "adlint/cpp/lexer"

module AdLint #:nodoc:
module Cpp #:nodoc:

  class Macro
    include LocationHolder

    def initialize(define_line)
      @define_line = define_line
    end

    attr_reader :define_line

    def name
      @define_line.identifier
    end

    def replacement_list
      @define_line.replacement_list
    end

    def location
      @define_line.location
    end

    def expand(toks, macro_tbl, repl_ctxt)
      @define_line.mark_as_referred_by(toks.first)
    end

    def function_like?
      subclass_responsibility
    end
  end

  class ObjectLikeMacro < Macro
    def replaceable_size(toks)
      if toks.first.value == "NULL" then
        0
      else
        name.value == toks.first.value ? 1 : 0
      end
    end

    def expand(toks, macro_tbl, repl_ctxt)
      super

      if repl_list = self.replacement_list
        loc = toks.first.location
        res_toks = repl_list.tokens.map { |tok|
          ReplacedToken.new(tok.type, tok.value, loc, tok.type_hint, false)
        }
      else
        res_toks = []
      end

      macro_tbl.notify_object_like_macro_replacement(self, toks, res_toks)
      res_toks
    end

    def function_like?; false end
  end

  class FunctionLikeMacro < Macro
    def initialize(define_line)
      super
      if params = define_line.identifier_list
        @parameter_names = params.identifiers.map { |tok| tok.value }
      else
        @parameter_names = []
      end
    end

    attr_reader :parameter_names

    def replaceable_size(toks)
      return 0 unless name.value == toks.first.value
      args, idx = parse_arguments(toks, 1)
      case
      when args && @parameter_names.empty?
        idx + 1
      when args && @parameter_names.size >= args.size
        idx + 1
      else
        0
      end
    end

    def expand(toks, macro_tbl, repl_ctxt)
      super

      args, * = parse_arguments(toks, 1)
      args = [] if @parameter_names.empty?
      args_hash =
        @parameter_names.zip(args).each_with_object({}) { |(param, arg), hash|
          hash[param] = arg
        }

      res_toks = expand_replacement_list(args_hash, toks.first.location,
                                         macro_tbl, repl_ctxt)
      macro_tbl.notify_function_like_macro_replacement(self, toks, args,
                                                       res_toks)
      res_toks
    end

    def function_like?; true end

    private
    def parse_arguments(toks, idx)
      while tok = toks[idx]
        case
        when tok.type == :NEW_LINE
          idx += 1
        when tok.value == "("
          idx += 1
          break
        else
          return nil, idx
        end
      end
      return nil, idx unless tok

      args = []
      loop do
        arg, idx, lst = parse_one_argument(toks, idx)
        args.push(arg)
        break if lst
      end
      return args, idx
    end

    def parse_one_argument(toks, idx)
      arg = []
      paren_depth = 0
      while tok = toks[idx]
        case tok.value
        when "("
          arg.push(tok)
          paren_depth += 1
        when ")"
          paren_depth -= 1
          if paren_depth >= 0
            arg.push(tok)
          else
            return arg, idx, true
          end
        when ","
          if paren_depth > 0
            arg.push(tok)
          else
            return arg, idx + 1, false
          end
        when "\n"
          ;
        else
          arg.push(tok)
        end
        idx += 1
      end
      return arg, idx, true # NOTREACHED
    end

    def expand_replacement_list(args, loc, macro_tbl, repl_ctxt)
      unless repl_list = self.replacement_list
        return []
      end

      res_toks = []
      idx = 0
      while cur_tok = repl_list.tokens[idx]
        nxt_tok = repl_list.tokens[idx + 1]

        case
        when arg = args[cur_tok.value]
          substitute_argument(cur_tok, nxt_tok, arg, loc, res_toks, macro_tbl,
                              repl_ctxt)
        when cur_tok.value == "#"
          if nxt_tok
            tok = stringize_argument(args[nxt_tok.value], loc, macro_tbl)
            res_toks.push(tok)
            idx += 1
          end
        when cur_tok.value == "##" && nxt_tok.value == "#"
          if nxt_nxt_tok = repl_list.tokens[idx + 2]
            tok = stringize_argument(args[nxt_nxt_tok.value], loc, macro_tbl)
            concat_with_last_token([tok], loc, res_toks, macro_tbl)
            idx += 2
          end
        when cur_tok.value == "##"
          if nxt_tok and arg = args[nxt_tok.value]
            concat_with_last_token(arg, loc, res_toks, macro_tbl)
          else
            concat_with_last_token([nxt_tok], loc, res_toks, macro_tbl)
          end
          idx += 1
        else
          res_toks.push(ReplacedToken.new(cur_tok.type, cur_tok.value, loc,
                                          cur_tok.type_hint, false))
        end
        idx += 1
      end
      res_toks
    end

    def substitute_argument(param_tok, nxt_tok, arg, loc, res_toks, macro_tbl,
                            repl_ctxt)
      # NOTE: The ISO C99 standard says;
      #
      # 6.10.3.1 Argument substitution
      #
      # 1 After the arguments for the invocation of a function-like macro have
      #   been identified, argument substitution take place.  A parameter in
      #   the replacement list, unless proceeded by a # or ## preprocessing
      #   token or followed by a ## preprocessing token, is replaced by the
      #   corresponding argument after all macros contained therein have been
      #   expanded.  Before being substituted, each argument's preprocessing
      #   tokens are completely macro replaced as if they formed the rest of
      #   the preprocessing file; no other preprocessing tokens are available.

      if nxt_tok && nxt_tok.value == "##"
        res_toks.concat(arg.map { |tok|
          ReplacedToken.new(tok.type, tok.value, loc, tok.type_hint, false)
        })
      else
        macro_tbl.replace(arg, repl_ctxt)
        res_toks.concat(arg.map { |tok|
          ReplacedToken.new(tok.type, tok.value, loc, tok.type_hint, true)
        })
      end
    end

    def stringize_argument(arg, expansion_loc, macro_tbl)
      # NOTE: The ISO C99 standard says;
      #
      # 6.10.3.2 The # operator
      #
      # Constraints
      #
      # 1 Each # preprocessing token in the replacement list for a
      #   function-like macro shall be followed by a parameter as the next
      #   preprocessing token in the replacement list.
      #
      # Semantics
      #
      # 2 If, in the replacement list, a parameter is immediately proceeded by
      #   a # preprocessing token, both are replaced by a single character
      #   string literal preprocessing token that contains the spelling of the
      #   preprocessing token sequence for the corresponding argument.  Each
      #   occurrence of white space between the argument's preprocessing tokens
      #   becomes a single space character in the character string literal.
      #   White space before the first preprocessing token and after the last
      #   preprocessing token composing the argument is deleted.  Otherwise,
      #   the original spelling of each preprocessing token in the argument is
      #   retained in the character string literal, except for special handling
      #   for producing the spelling of string literals and character
      #   constants: a \ character is inserted before each " and \ character of
      #   a character constant or string literal (including the delimiting "
      #   characters), except that it is implementation-defined whether a \
      #   character is inserted before the \ character beginning of universal
      #   character name.  If the replacement that results is not a valid
      #   character string literal, the behavior is undefined.  The character
      #   string literal corresponding to an empty argument is "".  The order
      #   of evaluation of # and ## operators is unspecified.
      #
      # NOTE: This code does not concern about contents of the string literal.
      #       But, it is enough for analysis.

      str = arg.map { |tok| tok.value }.join
      if str =~ /((:?\\*))\\\z/ && $1.length.even?
        str.chop!
        macro_tbl.notify_last_backslash_ignored(arg.last)
      end

      ReplacedToken.new(:PP_TOKEN, "\"#{str.gsub(/["\\]/) { "\\" + $& }}\"",
                        expansion_loc, :STRING_LITERAL, false)
    end

    def concat_with_last_token(arg_toks, expansion_loc, res_toks, macro_tbl)
      # NOTE: The ISO C99 standard says;
      #
      # 6.10.3.3 The ## operator
      #
      # Constraints
      #
      # 1 A ## preprocessing token shall not occur at the beginning or at the
      #   end of a replacement list for either form of macro definition.
      #
      # Semantics
      #
      # 2 If, in the replacement list of a function-form macro, a parameter is
      #   immediately preceded or followed by a ## preprocessing token, the
      #   parameter is replaced by the corresponding argument's preprocessing
      #   token sequence; however, if an argument consists of no preprocessing
      #   tokens, the parameter is replaced by a placemarker preprocessing
      #   token instead.
      #
      # 3 For both object-like and function-like macro invocations, before the
      #   replacement list is reexamined for more macro names to replace, each
      #   instance of a ## preprocessing token in the replacement list (not
      #   from an argument) is deleted and the preceding preprocessing token is
      #   concatenated with the following preprocessing token.  Placemarker
      #   preprocessing tokens are handled specially: concatenation of two
      #   placemarkers results in a single placemarker preprocessing token, and
      #   concatenation of a placemarker with a non-placemarker preprocessing
      #   token results in the non-placemarker preprocessing token.  If the
      #   result is not a valid preprocessing token, the behavior is undefined.
      #   The resulting token is available for further macro replacement.  The
      #   order of evaluation of ## operators is unspecified.

      if lhs = res_toks.pop
        if rhs = arg_toks.first
          # NOTE: To avoid syntax error when the concatenated token can be
          #       retokenize to two or more tokens.
          new_toks = StringToPPTokensLexer.new(lhs.value + rhs.value).execute
          new_toks.map! do |tok|
            ReplacedToken.new(tok.type, tok.value, expansion_loc,
                              tok.type_hint, false)
          end
          res_toks.concat(new_toks)
          res_toks.concat(arg_toks[1..-1].map { |tok|
            ReplacedToken.new(tok.type, tok.value, expansion_loc,
                              tok.type_hint, false)
          })
        else
          new_toks = [ReplacedToken.new(lhs.type, lhs.value, expansion_loc,
                                        lhs.type_hint, false)]
          res_toks.concat(new_toks)
        end

        macro_tbl.notify_sharpsharp_operator_evaled(lhs, rhs, new_toks)
      end
    end
  end

  class SpecialMacro < ObjectLikeMacro
    def initialize(name_str)
      super(PseudoObjectLikeDefineLine.new(name_str))
      @replacement_list = nil
    end

    attr_reader :replacement_list

    def expand(toks, macro_tbl, repl_ctxt)
      @replacement_list = generate_replacement_list(toks.first)
      super
    end

    private
    def generate_replacement_list(tok)
      subclass_responsibility
    end
  end

  class DateMacro < SpecialMacro
    def initialize
      super("__DATE__")
    end

    private
    def generate_replacement_list(tok)
      date = Time.now.strftime("%h %d %Y")
      PPTokens.new.push(Token.new(:PP_TOKEN, "\"#{date}\"", tok.location,
                                  :STRING_LITERAL))
    end
  end

  class FileMacro < SpecialMacro
    def initialize
      super("__FILE__")
    end

    private
    def generate_replacement_list(tok)
      PPTokens.new.push(
        Token.new(:PP_TOKEN, "\"#{tok.location.fpath}\"", tok.location,
                  :STRING_LITERAL))
    end
  end

  class LineMacro < SpecialMacro
    def initialize
      super("__LINE__")
    end

    private
    def generate_replacement_list(tok)
      PPTokens.new.push(
        Token.new(:PP_TOKEN, "#{tok.location.line_no}", tok.location,
                  :STRING_LITERAL))
    end
  end

  class StdcMacro < SpecialMacro
    def initialize
      super("__STDC__")
    end

    private
    def generate_replacement_list(tok)
      PPTokens.new.push(Token.new(:PP_TOKEN, "1", tok.location, :CONSTANT))
    end
  end

  class StdcHostedMacro < SpecialMacro
    def initialize
      super("__STDC_HOSTED__")
    end

    private
    def generate_replacement_list(tok)
      PPTokens.new.push(Token.new(:PP_TOKEN, "1", tok.location, :CONSTANT))
    end
  end

  class StdcMbMightNeqWcMacro < SpecialMacro
    def initialize
      super("__STDC_MB_MIGHT_NEQ_WC__")
    end

    private
    def generate_replacement_list(tok)
      PPTokens.new.push(Token.new(:PP_TOKEN, "1", tok.location, :CONSTANT))
    end
  end

  class StdcVersionMacro < SpecialMacro
    def initialize
      super("__STDC_VERSION__")
    end

    private
    def generate_replacement_list(tok)
      PPTokens.new.push(Token.new(:PP_TOKEN, "199901L", tok.location,
                                  :CONSTANT))
    end
  end

  class TimeMacro < SpecialMacro
    def initialize
      super("__TIME__")
    end

    private
    def generate_replacement_list(tok)
      time = Time.now.strftime("%H:%M:%S")
      PPTokens.new.push(Token.new(:PP_TOKEN, "\"#{time}\"", tok.location,
                                  :STRING_LITERAL))
    end
  end

  class StdcIec559Macro < SpecialMacro
    def initialize
      super("__STDC_IEC_559__")
    end

    private
    def generate_replacement_list(tok)
      PPTokens.new.push(Token.new(:PP_TOKEN, "0", tok.location, :CONSTANT))
    end
  end

  class StdcIec559ComplexMacro < SpecialMacro
    def initialize
      super("__STDC_IEC_559_COMPLEX__")
    end

    private
    def generate_replacement_list(tok)
      PPTokens.new.push(Token.new(:PP_TOKEN, "0", tok.location, :CONSTANT))
    end
  end

  class StdcIso10646Macro < SpecialMacro
    def initialize
      super("__STDC_ISO_10646__")
    end

    private
    def generate_replacement_list(tok)
      PPTokens.new.push(Token.new(:PP_TOKEN, "199712L", tok.location,
                                  :CONSTANT))
    end
  end

  class PragmaOperator < FunctionLikeMacro
    def initialize
      super(PseudoFunctionLikeDefineLine.new("_Pragma", ["str"]))
    end

    def expand(toks, macro_tbl, repl_ctxt)
      # TODO: Should implement pragma handling feature.
      []
    end
  end

  class LintSpecificMacro1 < SpecialMacro
    def initialize
      super("__LINT__")
    end

    private
    def generate_replacement_list(tok)
      PPTokens.new.push(Token.new(:PP_TOKEN, "1", tok.location, :CONSTANT))
    end
  end

  class LintSpecificMacro2 < SpecialMacro
    def initialize
      super("lint")
    end

    private
    def generate_replacement_list(tok)
      PPTokens.new.push(Token.new(:PP_TOKEN, "1", tok.location, :CONSTANT))
    end
  end

  class LintSpecificMacro3 < SpecialMacro
    def initialize
      super("__lint")
    end

    private
    def generate_replacement_list(tok)
      PPTokens.new.push(Token.new(:PP_TOKEN, "1", tok.location, :CONSTANT))
    end
  end

  class LintSpecificMacro4 < SpecialMacro
    def initialize
      super("__lint__")
    end

    private
    def generate_replacement_list(tok)
      PPTokens.new.push(Token.new(:PP_TOKEN, "1", tok.location, :CONSTANT))
    end
  end

  class AdLintSpecificMacro1 < SpecialMacro
    def initialize
      super("__ADLINT__")
    end

    private
    def generate_replacement_list(tok)
      PPTokens.new.push(Token.new(:PP_TOKEN, "1", tok.location, :CONSTANT))
    end
  end

  class AdLintSpecificMacro2 < SpecialMacro
    def initialize
      super("adlint")
    end

    private
    def generate_replacement_list(tok)
      PPTokens.new.push(Token.new(:PP_TOKEN, "1", tok.location, :CONSTANT))
    end
  end

  class AdLintSpecificMacro3 < SpecialMacro
    def initialize
      super("__adlint")
    end

    private
    def generate_replacement_list(tok)
      PPTokens.new.push(Token.new(:PP_TOKEN, "1", tok.location, :CONSTANT))
    end
  end

  class AdLintSpecificMacro4 < SpecialMacro
    def initialize
      super("__adlint__")
    end

    private
    def generate_replacement_list(tok)
      PPTokens.new.push(Token.new(:PP_TOKEN, "1", tok.location, :CONSTANT))
    end
  end

  class MacroReplacementContext
    def initialize
      @hide_sets = Hash.new { |hash, key| hash[key] = Set.new }
    end

    def add_to_hide_set(org_tok, new_toks, macro_name)
      new_toks.each do |new_tok|
        @hide_sets[new_tok].merge(@hide_sets[org_tok])
        @hide_sets[new_tok].add(macro_name)
      end
    end

    def hidden?(tok, macro_name)
      @hide_sets[tok].include?(macro_name)
    end
  end

  class MacroTable
    def initialize
      @macros = {}
      predefine_special_macros
    end

    extend Pluggable

    def_plugin :on_object_like_macro_replacement
    def_plugin :on_function_like_macro_replacement
    def_plugin :on_sharpsharp_operator_evaled
    def_plugin :on_last_backslash_ignored

    def define(macro)
      @macros[macro.name.value] = macro
      self
    end

    def undef(name_str)
      @macros.delete(name_str)
      self
    end

    def lookup(name_str)
      @macros[name_str]
    end

    def replace(toks, repl_ctxt = nil)
      replaced = false
      idx = 0

      while tok = toks[idx]
        case tok.value
        when "defined"
          in_defined = true
        when "(", ")"
          ;
        else
          if in_defined
            in_defined = false
          else
            if new_idx = do_replace(toks, idx, repl_ctxt)
              idx = new_idx
              replaced = true
            end
          end
        end
        idx += 1
      end

      replaced
    end

    def notify_object_like_macro_replacement(macro, replacing_toks, res_toks)
      on_object_like_macro_replacement.invoke(macro, replacing_toks, res_toks)
    end

    def notify_function_like_macro_replacement(macro, replacing_toks, args,
                                               res_toks)
      on_function_like_macro_replacement.invoke(macro, replacing_toks, args,
                                                res_toks)
    end

    def notify_sharpsharp_operator_evaled(lhs_tok, rhs_tok, new_toks)
      on_sharpsharp_operator_evaled.invoke(lhs_tok, rhs_tok, new_toks)
    end

    def notify_last_backslash_ignored(tok)
      on_last_backslash_ignored.invoke(tok)
    end

    private
    def do_replace(toks, idx, repl_ctxt)
      repl_ctxt ||= MacroReplacementContext.new

      return nil unless tok = toks[idx] and macro = lookup(tok.value)
      return nil if repl_ctxt.hidden?(tok, macro.name.value)

      size = macro.replaceable_size(toks[idx..-1])

      if toks[idx, size].all? { |t| t.need_no_further_replacement? }
        return nil
      end

      expanded = macro.expand(toks[idx, size], self, repl_ctxt)
      repl_ctxt.add_to_hide_set(toks[idx], expanded, macro.name.value)

      # NOTE: The ISO C99 standard says;
      #
      # 6.10.3.4 Rescanning and further replacement
      #
      # 1 After all parameters in the replacement list have been substituted
      #   and # and ## processing has take place, all placemarker preprocessing
      #   tokens are removed.  Then, the resulting preprocessing token sequence
      #   is rescanned, along with all subsequent preprocessing tokens of the
      #   source file, for more macro names to replace.
      #
      # 2 If the name of the macro being replaced is found during this scan of
      #   the replacement list (not including the rest of the source file's
      #   preprocessing tokens), it is not replaced.  Furthermore, if any
      #   nested replacements encounter the name of the macro being replaced,
      #   it is not replaced.  These nonreplaced macro name preprocessing
      #   tokens are no longer available for further replacement even if they
      #   are later (re)examined in contexts in which that macro name
      #   preprocessing token whould otherwise have been replaced.
      while replace(expanded, repl_ctxt); end
      toks[idx, size] = expanded

      idx + expanded.size - 1
    end

    def predefine_special_macros
      define(DateMacro.new)
      define(FileMacro.new)
      define(LineMacro.new)
      define(StdcMacro.new)
      define(StdcHostedMacro.new)
      define(StdcMbMightNeqWcMacro.new)
      define(StdcVersionMacro.new)
      define(TimeMacro.new)
      define(StdcIec559Macro.new)
      define(StdcIec559ComplexMacro.new)
      define(StdcIso10646Macro.new)
      define(PragmaOperator.new)
      define(LintSpecificMacro1.new)
      define(LintSpecificMacro2.new)
      define(LintSpecificMacro3.new)
      define(LintSpecificMacro4.new)
      define(AdLintSpecificMacro1.new)
      define(AdLintSpecificMacro2.new)
      define(AdLintSpecificMacro3.new)
      define(AdLintSpecificMacro4.new)
    end
  end

end
end
