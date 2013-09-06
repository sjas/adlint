# Base of all source code examinations.
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

require "adlint/message"
require "adlint/report"
require "adlint/util"

module AdLint #:nodoc:

  # == DESCRIPTION
  # Base of all kinds of source code examinations.
  class Examination
    include ReportUtil
    include LogUtil

    class << self
      def registrant_phase_class
        self.ancestors.each do |klass|
          if phase_class = @@registrant_phase_classes[klass]
            return phase_class
          end
        end
        nil
      end

      def required?(phase_ctxt)
        subclass_responsibility
      end

      def catalog
        eval "::#{self.name.sub(/(.*::).*\z/, "\\1")}Catalog"
      end
      memoize :catalog

      private
      def inherited(subclass)
        subclass.instance_variable_set(:@registrant_phase_class, nil)
      end

      def def_registrant_phase(phase_class)
        @@registrant_phase_classes ||= {}
        @@registrant_phase_classes[self] = phase_class
      end
    end

    def initialize(phase_ctxt)
      @phase_ctxt = phase_ctxt
    end

    def execute
      do_prepare(@phase_ctxt)
      do_execute(@phase_ctxt)
    end

    private
    def do_prepare(phase_ctxt)
      subclass_responsibility
    end

    def do_execute(phase_ctxt)
      subclass_responsibility
    end

    def targeted_method(name, loc_holder_idx = 0)
      lambda do |*args|
        if args[loc_holder_idx].analysis_target?(traits)
          self.__send__(name, *args)
        end
      end
    end
    alias :T :targeted_method
    alias :M :method

    extend Forwardable

    def_delegator :@phase_ctxt, :traits
    private :traits

    def_delegator :@phase_ctxt, :report
    private :report

    def_delegator :@phase_ctxt, :message_catalog
    private :message_catalog

    def_delegator :@phase_ctxt, :logger
    private :logger

    def suppressors
      @phase_ctxt[:suppressors]
    end
  end

  class ExaminationCatalog
    def initialize(loader_fpath)
      @loader_fpath = loader_fpath
      yield(self) if block_given?
    end

    attr_accessor :name
    attr_accessor :major_version
    attr_accessor :minor_version
    attr_accessor :patch_version
    attr_accessor :release_date
    attr_accessor :examination_classes

    def short_version
      "#{major_version}.#{minor_version}.#{patch_version}"
    end

    def message_definition_dpath
      Pathname.new("etc/mesg.d/#{name}").expand_path(package_prefix)
    end

    private
    def package_prefix
      catalog_dpath = Pathname.new(@loader_fpath).realpath.dirname
      Pathname.new("../../..").expand_path(catalog_dpath)
    end
  end

  class ExaminationPackage
    def initialize(name)
      @name = name
    end

    attr_reader :name

    def load
      require "adlint/exam/#{@name}"
      true
    rescue LoadError
      false
    end

    def catalog
      eval "Exam::#{module_name}::Catalog"
    end

    private
    def module_name
      @name.sub(/\A./) { |str| str.upcase }.gsub(/_(.)/) { $1.upcase }
    end
  end

  # == DESCRIPTION
  # Base of code checking classes.
  class CodeCheck < Examination
    class << self
      def message_name
        self.name.sub(/.*::(W\d{4}).*\z/, "\\1").to_sym
      end
      memoize :message_name

      def message_id
        MessageId.new(catalog.name, message_name)
      end

      def required?(phase_ctxt)
        excluded?(phase_ctxt) ? included?(phase_ctxt) : true
      end

      def must_be_unique?
        @must_be_unique
      end

      def must_be_deferred?
        @must_be_deferred
      end

      private
      def inherited(subclass)
        subclass.instance_variable_set(:@must_be_unique,   false)
        subclass.instance_variable_set(:@must_be_deferred, false)
      end

      def mark_as_unique
        @must_be_unique = true
      end

      def mark_as_deferred
        @must_be_deferred = true
      end

      def excluded?(phase_ctxt)
        excluded_by_category?(phase_ctxt) ||
          excluded_by_severity?(phase_ctxt) || excluded_by_id?(phase_ctxt)
      end

      def included?(phase_ctxt)
        included_by_id?(phase_ctxt)
      end

      def excluded_by_category?(phase_ctxt)
        exclusion = phase_ctxt.traits.of_message.exclusion
        if exclusion.categories.empty?
          false
        else
          if tmpl = phase_ctxt.message_catalog.lookup(message_id)
            exclusion.categories.any? { |cat| tmpl.categories.include?(cat) }
          else
            false
          end
        end
      end

      def excluded_by_severity?(phase_ctxt)
        exclusion = phase_ctxt.traits.of_message.exclusion
        if exclusion.severities
          false
        else
          if tmpl = phase_ctxt.message_catalog.lookup(message_id)
            tmpl.severities.any? { |sev| sev =~ exclusion.severities }
          else
            false
          end
        end
      end

      def excluded_by_id?(phase_ctxt)
        exclusion = phase_ctxt.traits.of_message.exclusion
        exclusion.messages.include?(message_id)
      end

      def included_by_id?(phase_ctxt)
        inclusion = phase_ctxt.traits.of_message.inclusion
        inclusion.messages.include?(message_id)
      end
    end

    def message_name
      self.class.message_name
    end
  end

  class PassiveCodeCheck < CodeCheck
    private
    def do_prepare(phase_ctxt) end
    def do_execute(phase_ctxt) end
  end

  # == DESCRIPTION
  # Base of metric measurement classes.
  class MetricMeasurement < Examination
    def self.required?(phase_ctxt)
      true
    end
  end

  # == DESCRIPTION
  # Base of code structure extraction classes.
  class CodeExtraction < Examination
    def self.required?(phase_ctxt)
      true
    end
  end

end
