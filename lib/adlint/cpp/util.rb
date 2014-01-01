# Miscellaneous utilities for C preprocessor language.
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
module Cpp #:nodoc:

  class EscapeSequence
    # TODO: Remove duplication in cc1/util.rb and cpp/util.rb .
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

  module BasicSourceCharacterSet
    def include?(str)
      str.chars.all? { |ch| CHARS.include?(ch.ord) }
    end
    module_function :include?

    def select_adapted(str)
      str.chars.select { |ch| CHARS.include?(ch.ord) }
    end
    module_function :select_adapted

    def select_not_adapted(str)
      str.chars.to_a - select_adapted(str)
    end
    module_function :select_not_adapted

    # NOTE: The ISO C99 standard says;
    #
    # 5.2 Environmental considerations
    # 5.2.1 Character sets
    #
    # 1 Two sets of characters and their associated collating sequences shall
    #   be defined: the set in which source files are written (the source
    #   character set), and the set interpreted in the execution environment
    #   (the execution character set). Each set is further divided into a basic
    #   character set, whose contents are given by this subclause, and a set of
    #   zero or more locale-specific members (which are not members of the
    #   basic character set) called extended characters. The combined set is
    #   also called the extended character set. The values of the members of
    #   the execution character set are implementation-defined.
    #
    # 3 Both the basic source and basic execution character sets shall have the
    #   following members: the 26 uppercase letters of the Latin alphabet
    #     A B C D E F G H I J K L M
    #     N O P Q R S T U V W X Y Z
    #   the 26 lowercase letters of the Latin alphabet
    #     a b c d e f g h i j k l m
    #     n o p q r s t u v w x y z
    #   the 10 decimal digits
    #     0 1 2 3 4 5 6 7 8 9
    #   the following 29 graphic characters
    #     ! " # % & ' ( ) * + , - . / :
    #     ; < = > ? [ \ ] ^ _ { | } ~
    #   the space character, and control characters representing horizontal
    #   tab, vertical tab, and form feed.
    CHARS = [
      "A", "B" , "C" , "D" , "E" , "F", "G", "H", "I" , "J", "K", "L", "M",
      "N", "O" , "P" , "Q" , "R" , "S", "T", "U", "V" , "W", "X", "Y", "Z",
      "a", "b" , "c" , "d" , "e" , "f", "g", "h", "i" , "j", "k", "l", "m",
      "n", "o" , "p" , "q" , "r" , "s", "t", "u", "v" , "w", "x", "y", "z",
      "0", "1" , "2" , "3" , "4" , "5", "6", "7", "8" , "9",
      "!", '"' , "#" , "%" , "&" , "'", "(", ")", "*" , "+", ",", "-", ".",
      "/", ":" , ";" , "<" , "=" , ">", "?", "[", "\\", "]", "^", "_", "{",
      "|", "}" , "~" ,
      " ", "\t", "\v", "\f", "\n"
    ].map { |ch| ch.ord }.to_set.freeze
    private_constant :CHARS
  end

end
end
