# Global ruby extensions preloaded before execution.
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

require "adlint/memo"

module Kernel
  private
  def subclass_responsibility
    raise NotImplementedError, self.class.name
  end
  module_function :subclass_responsibility

  def __NOTREACHED__
    raise "NOTREACHED"
  end
  module_function :__NOTREACHED__
end

class Module
  include ::AdLint::Memoizable

  # NOTE: Module.private_constant is added in Ruby 1.9.3-p0.
  unless public_instance_methods.include?(:private_constant)
    def private_constant(*) end
  end

  def outer_module
    eval self.name.sub(/(.*)::.*\z/, "\\1")
  end
  memoize :outer_module
end

class Encoding
  def self.include_name?(enc_name)
    if enc_name && !enc_name.empty?
      Encoding.find(enc_name)
    end
    true
  rescue
    false
  end
end

class String
  def to_default_external
    encode(Encoding.default_external, :invalid => :replace, :undef => :replace)
  end
end

class LazyInstantiation
  def initialize(klass, *args, &block)
    @klass = klass
    @args = args
    @block = block
  end

  undef_method(*(Object.new.public_methods - [:__id__, :object_id, :__send__]))

  def method_missing(name, *args)
    @receiver ||= @klass.new(*@args, &@block)
    @receiver.__send__(name, *args)
  end
end

class Class
  def lazy_new(*args, &block)
    LazyInstantiation.new(self, *args, &block)
  end
end

class Integer
  # NOTE: To restrict the bit-shift width.
  SHIFT_MAX_BITS = 64

  def logical_right_shift(rhs)
    return self if rhs < 0
    bits = to_s(2)
    shift_width = [rhs, SHIFT_MAX_BITS].min
    if bits.length < shift_width
      0
    else
      ("0" * shift_width + bits[0..-(shift_width + 1)]).to_i(2)
    end
  end

  def arithmetic_right_shift(rhs)
    rhs < 0 ? self : self >> [rhs, SHIFT_MAX_BITS].min
  end

  def left_shift(rhs)
    rhs < 0 ? self : self << [rhs, SHIFT_MAX_BITS].min
  end
end

class Pathname
  def components
    self.each_filename.to_a
  end
  memoize :components

  def real_components
    self.realpath.each_filename.to_a
  end
  memoize :real_components

  memoize :realpath
  memoize :cleanpath

  def strip(num = 0)
    comps = self.components
    comps = comps.slice(num..-1) if num >= 0 && num < comps.size
    Pathname.new(comps.reduce { |stripped, comp| File.join(stripped, comp) })
  end

  def add_ext(ext_str)
    Pathname.new(self.to_s + ext_str)
  end

  def identical?(rhs)
    case rhs
    when Pathname
      self.cleanpath == rhs.cleanpath
    when String
      self.cleanpath == Pathname.new(rhs).cleanpath
    else
      false
    end
  end
  memoize :identical?

  def under?(parent_dpath)
    lhs_comps, rhs_comps = self.real_components, parent_dpath.real_components
    if rhs_comps.size < lhs_comps.size
      rhs_comps.zip(lhs_comps).all? { |rhs, lhs| lhs == rhs }
    else
      false
    end
  end
end

class String
  # === DESCRIPTION
  # Finds the longest common substrings in two strings.
  #
  # Fast and small memory footprint clone detection algorithm developed by
  # Yutaka Yanoh.
  # This algorithm is based on "suffix array with height" data structure.
  #
  # === PARAMETER
  # _rhs_:: String -- A String comparing to the receiver.
  #
  # === RETURN VALUE
  # Array< SubstringPair > -- The longest common substrings.
  def longest_common_substrings_with(rhs)
    suffix_array = SuffixArray.new(LeftSuffix.of(self) + RightSuffix.of(rhs))
    suffix_array.longest_common_substrings
  end
end

class Substring < String
  def initialize(str, idx, len)
    @range = idx...(idx + len)
    super(str.slice(@range))
  end

  attr_reader :range
end

class SubstringPair < Array
  def initialize(lhs_suffix, rhs_suffix, len)
    super([lhs_suffix.prefix(len), rhs_suffix.prefix(len)])
  end

  def lhs
    self.first
  end

  def rhs
    self.last
  end
end

class Suffix
  include Comparable

  def self.of(str)
    str.length.times.map { |idx| new(str, idx) }
  end

  def initialize(owner, idx)
    @owner = owner
    @index = idx
  end
  private_class_method :new

  def lhs?
    subclass_responsibility
  end

  def rhs?
    !lhs?
  end

  def same_owner?(rhs)
    @owner.equal?(rhs.owner)
  end

  def common_prefix_length(rhs)
    to_s.chars.zip(rhs.to_s.chars).take_while { |lch, rch| lch == rch }.size
  end

  def prefix(len)
    Substring.new(@owner, @index, len)
  end

  def <=>(rhs)
    self.to_s <=> rhs.to_s
  end

  def to_s
    @owner.slice(@index..-1)
  end

  protected
  attr_reader :owner
end

class LeftSuffix < Suffix
  def lhs?
    true
  end
end

class RightSuffix < Suffix
  def lhs?
    false
  end
end

class SuffixArray < Array
  def initialize(suffixes)
    super(suffixes.sort.map { |suffix| [suffix, 0] })
    update_height_of_each_suffixes!
  end

  def longest_common_substrings
    len = self.longest_common_prefix_length

    return [] if len == 0

    self.each_index.reduce([]) { |result, idx|
      self[idx][1] == len ? result + create_substring_pairs(idx, len) : result
    }
  end

  def longest_common_prefix_length
    self.map { |suffix, height| height }.max
  end

  private
  def update_height_of_each_suffixes!
    (1...self.size).each do |idx|
      self[idx][1] = self[idx - 1][0].common_prefix_length(self[idx][0])
    end
  end

  def create_substring_pairs(idx, len)
    base_suffix = self[idx][0]

    if base_suffix.lhs?
      create_entry = lambda { |lhs, rhs, l| SubstringPair.new(lhs, rhs, l) }
    else
      create_entry = lambda { |rhs, lhs, l| SubstringPair.new(lhs, rhs, l) }
    end

    result = []

    (0...idx).reverse_each do |i|
      break unless self[i + 1][1] == len

      unless base_suffix.same_owner?(self[i][0])
        result.push(create_entry[base_suffix, self[i][0], len])
      end
    end

    result
  end
end

# NOTE: To support environment variable substitution in YAML file.
#
#       Syntax of embedding environment variable is below;
#         env_var_specifier : '$' env_var_name
#                           | '$' '{' env_var_name '}'
#         env_var_name      : [A-Za-z_][0-9A-Za-z_]*
#
#       Examples of environment variable as any scalar value;
#         string_item: $VAR
#         boolean_item: $VAR
#         decimal_item: $VAR
#
#       Examples of embedding environment variable in string;
#         string_item: "foo${VAR}baz"
#
class Psych::TreeBuilder < Psych::Handler
  alias :_orig_scalar :scalar
  def scalar(value, anchor, tag, plain, quoted, style)
    _orig_scalar(substitute_environment_variables(value),
                 anchor, tag, plain, quoted, style)
  end

  private
  def substitute_environment_variables(string)
    string.gsub(/(?<!\\)\${?([a-z_][0-9a-z_]*)}?/i) do
      (value = ENV[$1]) ? value : ""
    end
  end
end


if $0 == __FILE__
  h1 = Hash.lazy_new(1)
  p h1[0]
  h2 = Hash.lazy_new { |h, k| h[k] = 1 }
  p h2[0]

  substrs = "foohogebargeho".longest_common_substrings_with("hogehoge")
  p substrs # => [["geho", "geho"], ["hoge", "hoge"], ["hoge", "hoge"]]
  p substrs.map { |l, r| l.range } # => [10...14, 3...7, 3...7]
  p substrs.map { |l, r| r.range } # => [2...6, 4...8, 0...4]
end
