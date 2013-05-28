# C typedef models for cross module analysis.
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

require "adlint/location"
require "adlint/metric"

module AdLint #:nodoc:
module Ld #:nodoc:

  class Typedef
    include LocationHolder

    def initialize(name, loc)
      @name = name
      @location = loc
    end

    attr_reader :name
    attr_reader :location

    def eql?(rhs)
      @name == rhs.name && @location == rhs.location
    end

    alias :== :eql?

    def hash
      "#{name} #{location}".hash
    end
  end

  class TypedefMap
    def initialize
      @name_index = Hash.new { |hash, key| hash[key] = Set.new }
      @composing_fpaths = Set.new
    end

    attr_reader :composing_fpaths

    def add(typedef)
      @name_index[typedef.name].add(typedef)
      @composing_fpaths.add(typedef.location.fpath)
    end

    def all_typedefs
      @name_index.values.each_with_object([]) do |typedefs, all|
        all.concat(typedefs.to_a)
      end
    end

    def lookup(typedef_name)
      @name_index[typedef_name].to_a
    end
  end

  class TypedefMapper
    def initialize
      @map = TypedefMap.new
    end

    attr_reader :map

    def execute(met_fpath)
      sma_wd = Pathname.pwd
      CSV.foreach(met_fpath) do |csv_row|
        rec = MetricRecord.of(csv_row, sma_wd)
        case
        when rec.version?
          sma_wd = Pathname.new(rec.exec_working_directory)
        when rec.typedef_declaration?
          @map.add(Typedef.new(rec.type_name, rec.location))
        end
      end
    end
  end

  class TypedefTraversal
    def initialize(typedef_map)
      @map = typedef_map
    end

    extend Pluggable

    def_plugin :on_declaration

    def execute
      @map.all_typedefs.each { |tdef| on_declaration.invoke(tdef) }
    end
  end

end
end
