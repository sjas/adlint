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
    def memoize(name, *key_indices)
      var_name = name.to_s.sub("?", "Q")
      org_name = "_org_#{name}"
      class_eval <<-EOS
        alias_method("#{org_name}", "#{name}")
        private("#{org_name}")
      EOS
      if key_indices.empty?
        if instance_method("#{name}").arity == 0
          define_cache_manipulator(name, var_name)
          class_eval <<-EOS
            define_method("#{name}") do
              @_cache_of__#{var_name}_initialized ||= false
              if @_cache_of__#{var_name}_initialized
                @_cache_of__#{var_name}_forbidden = false
                @_cache_of__#{var_name}
              else
                @_cache_of__#{var_name}_forbidden ||= false
                if @_cache_of__#{var_name}_forbidden
                  @_cache_of__#{var_name}_forbidden = false
                  #{org_name}
                else
                  @_cache_of__#{var_name}_initialized = true
                  @_cache_of__#{var_name} = #{org_name}
                end
              end
            end
          EOS
        else
          define_cache_manipulator(name, var_name, key_indices)
          class_eval <<-EOS
            define_method("#{name}") do |*args|
              @_cache_of__#{var_name}_initialized ||= false
              if @_cache_of__#{var_name}_initialized
                @_cache_of__#{var_name}_forbidden = false
                if @_cache_of__#{var_name}.include?(args)
                  @_cache_of__#{var_name}[args]
                else
                  @_cache_of__#{var_name}[args] = #{org_name}(*args)
                end
              else
                @_cache_of__#{var_name}_forbidden ||= false
                if @_cache_of__#{var_name}_forbidden
                  @_cache_of__#{var_name}_forbidden = false
                  #{org_name}(*args)
                else
                  @_cache_of__#{var_name}_initialized = true
                  @_cache_of__#{var_name} = {}
                  @_cache_of__#{var_name}[args] = #{org_name}(*args)
                end
              end
            end
          EOS
        end
      else
        define_cache_manipulator(name, var_name, key_indices)
        class_eval <<-EOS
          define_method("#{name}") do |*args|
            @_cache_of__#{var_name}_initialized ||= false
            key = args.values_at(#{key_indices.join(',')})
            if @_cache_of__#{var_name}_initialized
              @_cache_of__#{var_name}_forbidden = false
              if @_cache_of__#{var_name}.include?(key)
                @_cache_of__#{var_name}[key]
              else
                @_cache_of__#{var_name}[key] = #{org_name}(*args)
              end
            else
              @_cache_of__#{var_name}_forbidden ||= false
              if @_cache_of__#{var_name}_forbidden
                @_cache_of__#{var_name}_forbidden = false
                #{org_name}(*args)
              else
                @_cache_of__#{var_name}_initialized = true
                @_cache_of__#{var_name} = {}
                @_cache_of__#{var_name}[key] = #{org_name}(*args)
              end
            end
          end
        EOS
      end
    end

    private
    def define_cache_manipulator(name, var_name, key_indices = nil)
      class_eval <<-EOS
        define_method("forbid_once_memo_of__#{name}") do
          @_cache_of__#{var_name}_forbidden = true
        end
        define_method("clear_memo_of__#{name}") do
          @_cache_of__#{var_name} = nil
          @_cache_of__#{var_name}_initialized = false
        end
      EOS
      case
      when key_indices && key_indices.empty?
        class_eval <<-EOS
          define_method("forget_memo_of__#{name}") do |*args|
            if @_cache_of__#{var_name}_initialized
              @_cache_of__#{var_name}.delete(args)
            end
          end
        EOS
      when key_indices
        class_eval <<-EOS
          define_method("forget_memo_of__#{name}") do |*args|
            if @_cache_of__#{var_name}_initialized
              key = args.values_at(#{key_indices.join(',')})
              @_cache_of__#{var_name}.delete(key)
            end
          end
        EOS
      else
        class_eval <<-EOS
          define_method("forget_memo_of__#{name}") do
            clear_memo_of__#{name}
          end
        EOS
      end
    end
  end

end
