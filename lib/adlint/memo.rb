# Memoizing utility.
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

module AdLint #:nodoc:

  module Memoizable
    def memoize(name, *opts)
      force_nullary, key_indices = extract_memoize_options(opts)
      case
      when instance_method(name).arity == 0 || force_nullary
        memoize_nullary_method(name)
      when instance_method(name).arity == 1 || key_indices.size == 1
        memoize_unary_method(name, key_indices.first || 0)
      else
        memoize_polynomial_method(name, key_indices)
      end
    end

    private
    def extract_memoize_options(opts)
      hash = opts.first || {}
      [hash[:force_nullary], hash[:key_indices] || []]
    end

    def memoize_nullary_method(name)
      save_memoizing_method(name)
      prepare_nullary_method_cache(name)
      class_eval <<-EOS
        define_method(:#{name}) do |*args|
          if #{cache_name_of(name)}_initialized ||= false
            #{cache_name_of(name)}_forbidden = false
            #{cache_name_of(name)}
          else
            if #{cache_name_of(name)}_forbidden ||= false
              #{cache_name_of(name)}_forbidden = false
              #{org_name_of(name)}
            else
              #{cache_name_of(name)}_initialized = true
              #{cache_name_of(name)} = #{org_name_of(name)}(*args)
            end
          end
        end
      EOS
    end

    def memoize_unary_method(name, key_index)
      save_memoizing_method(name)
      prepare_unary_method_cache(name, key_index)
      class_eval <<-EOS
        define_method(:#{name}) do |*args|
          key = args[#{key_index}]
          if #{cache_name_of(name)}_initialized ||= false
            #{cache_name_of(name)}_forbidden = false
            if #{cache_name_of(name)}.include?(key)
              #{cache_name_of(name)}[key]
            else
              #{cache_name_of(name)}[key] = #{org_name_of(name)}(*args)
            end
          else
            if #{cache_name_of(name)}_forbidden ||= false
              #{cache_name_of(name)}_forbidden = false
              #{org_name_of(name)}(*args)
            else
              #{cache_name_of(name)}_initialized = true
              #{cache_name_of(name)} = {}
              #{cache_name_of(name)}[key] = #{org_name_of(name)}(*args)
            end
          end
        end
      EOS
    end

    def memoize_polynomial_method(name, key_indices)
      save_memoizing_method(name)
      prepare_polynomial_method_cache(name, key_indices)
      class_eval <<-EOS
        define_method(:#{name}) do |*args|
          key = __key_for_#{name}(*args)
          if #{cache_name_of(name)}_initialized ||= false
            #{cache_name_of(name)}_forbidden = false
            if #{cache_name_of(name)}.include?(key)
              #{cache_name_of(name)}[key]
            else
              #{cache_name_of(name)}[key] = #{org_name_of(name)}(*args)
            end
          else
            if #{cache_name_of(name)}_forbidden ||= false
              #{cache_name_of(name)}_forbidden = false
              #{org_name_of(name)}(*args)
            else
              #{cache_name_of(name)}_initialized = true
              #{cache_name_of(name)} = {}
              #{cache_name_of(name)}[key] = #{org_name_of(name)}(*args)
            end
          end
        end
      EOS
    end

    def prepare_nullary_method_cache(name)
      class_eval <<-EOS
        define_method(:forbid_once_memo_of__#{name}) do
          #{cache_name_of(name)}_forbidden = true
        end
        define_method(:clear_memo_of__#{name}) do
          #{cache_name_of(name)} = nil
          #{cache_name_of(name)}_initialized = false
        end
        define_method(:forget_memo_of__#{name}) do
          clear_memo_of__#{name}
        end
      EOS
    end

    def prepare_unary_method_cache(name, key_index)
      class_eval <<-EOS
        define_method(:forbid_once_memo_of__#{name}) do
          #{cache_name_of(name)}_forbidden = true
        end
        define_method(:clear_memo_of__#{name}) do
          #{cache_name_of(name)} = nil
          #{cache_name_of(name)}_initialized = false
        end
        define_method(:forget_memo_of__#{name}) do |*args|
          if #{cache_name_of(name)}_initialized
            #{cache_name_of(name)}.delete(args[#{key_index}])
          end
        end
      EOS
    end

    def prepare_polynomial_method_cache(name, key_indices)
      define_key_generator(name, key_indices)
      class_eval <<-EOS
        define_method(:forbid_once_memo_of__#{name}) do
          #{cache_name_of(name)}_forbidden = true
        end
        define_method(:clear_memo_of__#{name}) do
          #{cache_name_of(name)} = nil
          #{cache_name_of(name)}_initialized = false
        end
        define_method(:forget_memo_of__#{name}) do |*args|
          if #{cache_name_of(name)}_initialized
            #{cache_name_of(name)}.delete(__key_for_#{name}(*args))
          end
        end
      EOS
    end

    def define_key_generator(name, key_indices)
      if key_indices.empty?
        class_eval <<-EOS
          define_method(:__key_for_#{name}) do |*args|
            args
          end
        EOS
      else
        class_eval <<-EOS
          define_method(:__key_for_#{name}) do |*args|
            args.values_at(#{key_indices.join(',')})
          end
        EOS
      end
      class_eval "private(:__key_for_#{name})"
    end

    def save_memoizing_method(name)
      class_eval <<-EOS
        alias_method(:#{org_name_of(name)}, :#{name})
        private(:#{org_name_of(name)})
      EOS
    end

    def cache_name_of(name)
      "@__cache_of__#{name.to_s.sub("?", "Q")}"
    end

    def org_name_of(name)
      "__org_#{name}"
    end
  end

end
