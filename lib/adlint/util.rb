# Miscellaneous utilities.
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

require "adlint/memo"

module AdLint #:nodoc:

  module Validation
    # NOTE: Host class must respond to #entity_name.

    def ensure_validity_of(*args)
      @validators ||= []
      attr_names = _attr_names_in(args)
      attr_names.each do |attr_name|
        @validators.push(ObjectValidator.new(attr_name))
      end
      self
    end

    def ensure_presence_of(*args)
      @validators ||= []
      attr_names = _attr_names_in(args)
      attr_names.each do |attr_name|
        @validators.push(PresenceValidator.new(attr_name))
      end
      self
    end

    def ensure_numericality_of(*args)
      @validators ||= []
      attr_names, opts = _attr_names_in(args), _options_in(args)
      only_int = opts[:only_integer] ? true : false
      min = opts[:min]
      max = opts[:max]
      attr_names.each do |attr_name|
        @validators.push(NumericalityValidator.new(attr_name, only_int,
                                                   min, max))
      end
      self
    end

    def ensure_file_presence_of(*args)
      @validators ||= []
      attr_names, opts = _attr_names_in(args), _options_in(args)
      allow_nil = opts[:allow_nil]
      attr_names.each do |attr_name|
        @validators.push(FilePresenceValidator.new(attr_name, allow_nil))
      end
      self
    end

    def ensure_dir_presence_of(*args)
      @validators ||= []
      attr_names, opts = _attr_names_in(args), _options_in(args)
      allow_nil = opts[:allow_nil]
      attr_names.each do |attr_name|
        @validators.push(DirPresenceValidator.new(attr_name, allow_nil))
      end
      self
    end

    def ensure_dirs_presence_of(*args)
      @validators ||= []
      attr_names = _attr_names_in(args)
      attr_names.each do |attr_name|
        @validators.push(DirsPresenceValidator.new(attr_name))
      end
      self
    end

    def ensure_inclusion_of(*args)
      @validators ||= []
      attr_names, opts = _attr_names_in(args), _options_in(args)
      vals = opts[:values] || []
      attr_names.each do |attr_name|
        @validators.push(InclusionValidator.new(attr_name, vals))
      end
      self
    end

    def ensure_true_or_false_of(*args)
      @validators ||= []
      attr_names = _attr_names_in(args)
      attr_names.each do |attr_name|
        @validators.push(TrueOrFalseValidator.new(attr_name))
      end
      self
    end

    def ensure_exam_packages_presence_of(*args)
      @validators ||= []
      attr_names = _attr_names_in(args)
      attr_names.each do |attr_name|
        @validators.push(ExamPackagesPresenceValidator.new(attr_name))
      end
      self
    end

    def ensure_with(*args)
      @validators ||= []
      attr_names, opts = _attr_names_in(args), _options_in(args)
      msg = opts[:message] || "is not valid."
      validator = opts[:validator] || lambda { |val| val }
      attr_names.each do |attr_name|
        @validators.push(CustomValidator.new(attr_name, msg, validator))
      end
      self
    end

    def validators
      @validators ||= []
    end

    def valid?
      if self.class.validators
        self.class.validators.map { |validator| validator.execute(self) }.all?
      else
        true
      end
    end

    def errors
      if self.class.validators
        self.class.validators.map { |validator| validator.errors }.flatten
      else
        []
      end
    end

    def self.included(class_or_module)
      class_or_module.extend(self)
    end

    private
    def _attr_names_in(args)
      args.select { |obj| obj.kind_of?(Symbol) }
    end

    def _options_in(args)
      args.find { |obj| obj.kind_of?(Hash) } || {}
    end

    class Validator
      def initialize(attr_name)
        @attr_name = attr_name
        @errors = []
      end

      attr_reader :errors

      def execute(attr_owner)
        subclass_responsibility
      end

      private
      def target_value(attr_owner)
        attr_owner.instance_variable_get("@#{@attr_name}")
      end

      def qualified_attr_name(attr_owner)
        if attr_owner.entity_name.nil? || attr_owner.entity_name.empty?
          @attr_name
        else
          "#{attr_owner.entity_name}:#{@attr_name}"
        end
      end
    end
    private_constant :Validator

    class ObjectValidator < Validator
      def execute(attr_owner)
        if obj = target_value(attr_owner)
          return true if obj.valid?
          @errors.concat(obj.errors)
        end
        false
      end
    end
    private_constant :ObjectValidator

    class PresenceValidator < Validator
      def execute(attr_owner)
        if target_value(attr_owner).nil?
          @errors.push("`#{qualified_attr_name(attr_owner)}' " +
                       "is not specified.")
          return false
        end
        true
      end
    end
    private_constant :PresenceValidator

    class NumericalityValidator < PresenceValidator
      def initialize(attr_name, only_int, min, max)
        super(attr_name)
        @only_integer = only_int
        @min = min
        @max = max
      end

      def execute(attr_owner)
        return false unless super
        val = target_value(attr_owner)

        case val
        when Numeric
          if @only_integer && !val.integer?
            @errors.push("`#{qualified_attr_name(attr_owner)}' " +
                         "is not an integer.")
            return false
          end
          if @min && val < @min
            @errors.push("`#{qualified_attr_name(attr_owner)}' " +
                         "is not greater than or equal to #{@min}.")
            return false
          end
          if @max && @max < val
            @errors.push("`#{qualified_attr_name(attr_owner)}' " +
                         "is not less than or equal to #{@max}.")
            return false
          end
        else
          @errors.push("`#{qualified_attr_name(attr_owner)}' " +
                       "is not a numerical value.")
          return false
        end

        true
      end
    end
    private_constant :NumericalityValidator

    class FilePresenceValidator < Validator
      def initialize(attr_name, allow_nil)
        super(attr_name)
        @allow_nil = allow_nil
      end

      def execute(attr_owner)
        val = target_value(attr_owner)

        unless val
          if @allow_nil
            return true
          else
            @errors.push("`#{qualified_attr_name(attr_owner)}' " +
                         "is not specified.")
            return false
          end
        end

        unless File.exist?(val) && File.file?(val)
          @errors.push("`#{qualified_attr_name(attr_owner)}' " +
                       "is non-existent pathname (#{val.to_s}).")
          return false
        end
        true
      end
    end
    private_constant :FilePresenceValidator

    class DirPresenceValidator < Validator
      def initialize(attr_name, allow_nil)
        super(attr_name)
        @allow_nil = allow_nil
      end

      def execute(attr_owner)
        val = target_value(attr_owner)

        unless val
          if @allow_nil
            return true
          else
            @errors.push("`#{qualified_attr_name(attr_owner)}' " +
                         "is not specified.")
            return false
          end
        end

        unless File.exist?(val) && File.directory?(val)
          @errors.push("`#{qualified_attr_name(attr_owner)}' " +
                       "is non-existent pathname (#{val.to_s}).")
          return false
        end
        true
      end
    end
    private_constant :DirPresenceValidator

    class DirsPresenceValidator < Validator
      def execute(attr_owner)
        val = target_value(attr_owner)

        bad_paths = val.reject { |path|
          File.exist?(path) && File.directory?(path)
        }

        unless bad_paths.empty?
          bad_paths.each do |path|
            @errors.push("`#{qualified_attr_name(attr_owner)}' " +
                         "contains non-existent pathname (#{path.to_s}).")
          end
          return false
        end
        true
      end
    end
    private_constant :DirsPresenceValidator

    class InclusionValidator < PresenceValidator
      def initialize(attr_name, vals)
        super(attr_name)
        @values = vals
      end

      def execute(attr_owner)
        return false unless super
        val = target_value(attr_owner)

        unless @values.include?(val)
          @errors.push("`#{qualified_attr_name(attr_owner)}' " +
                       "is not one of #{@values.join(", ")}.")
          return false
        end
        true
      end
    end
    private_constant :InclusionValidator

    class TrueOrFalseValidator < PresenceValidator
      def execute(attr_owner)
        return false unless super
        case target_value(attr_owner)
        when TrueClass, FalseClass
          true
        else
          @errors.push("`#{qualified_attr_name(attr_owner)}' " +
                       "is not a boolean value.")
          false
        end
      end
    end
    private_constant :TrueOrFalseValidator

    class ExamPackagesPresenceValidator < Validator
      def execute(attr_owner)
        val = target_value(attr_owner)

        if val.empty?
          @errors.push("`#{qualified_attr_name(attr_owner)}' " +
                       "is not specified.")
          return false
        end

        bad_exams = val.reject { |exam_pkg| exam_pkg.load }

        unless bad_exams.empty?
          bad_exams.each do |exam_pkg|
            @errors.push("`#{qualified_attr_name(attr_owner)}' " +
                         "contains non-existent exam-package name " +
                         "(#{exam_pkg.name}).")
          end
          return false
        end
        true
      end
    end
    private_constant :ExamPackagesPresenceValidator

    class CustomValidator < Validator
      def initialize(attr_name, msg, validator)
        super(attr_name)
        @message = msg
        @validator = validator
      end

      def execute(attr_owner)
        unless @validator[target_value(attr_owner)]
          @errors.push("`#{qualified_attr_name(attr_owner)}' " + @message)
          return false
        end
        true
      end
    end
    private_constant :CustomValidator
  end

  module Visitable
    def accept(visitor)
      visitor.__send__(visitor_method_name, self)
    end

    private
    def visitor_method_name
      node_name = self.class.name.sub(/\A.*::/, "")
      node_name = node_name.gsub(/([A-Z][a-z])/, "_\\1")
      node_name = node_name.sub(/\A_/, "").tr("A-Z", "a-z")
      "visit_#{node_name}".to_sym
    end
    memoize :visitor_method_name
  end

  class CsvRecord
    def initialize(ary)
      @ary = ary
    end

    def field_at(idx)
      @ary.fetch(idx)
    end
  end

  class Plugin
    def initialize(methods = [])
      @methods = methods
    end

    def +(method)
      Plugin.new(@methods + [method])
    end

    def invoke(*args)
      @methods.each { |method| method.call(*args) }
    end
  end

  module Pluggable
    def def_plugin(event)
      class_eval <<-EOS
        define_method("#{event}") do |*args|
          @#{event}_plugin ||= Plugin.new
        end
        define_method("#{event}=") do |*args|
          @#{event}_plugin = args.first
        end
      EOS
    end
  end

  module CompoundPathParser
    def parse_compound_path_list(ary)
      (ary || []).compact.map { |str| parse_compound_path_str(str) }.flatten
    end
    module_function :parse_compound_path_list

    def parse_compound_path_str(str)
      str.split(File::PATH_SEPARATOR).map { |s| Pathname.new(s) }
    end
    module_function :parse_compound_path_str
  end

  module LogUtil
    # NOTE: Host class must respond to #logger.

    def log_fatal(*args, &block)
      logger.fatal(*args, &block)
    end
    alias :LOG_F :log_fatal

    def log_error(*args, &block)
      logger.error(*args, &block)
    end
    alias :LOG_E :log_error

    def log_warn(*args, &block)
      logger.warn(*args, &block)
    end
    alias :LOG_W :log_warn

    def log_info(*args, &block)
      logger.info(*args, &block)
    end
    alias :LOG_I :log_info

    def log_debug(*args, &block)
      logger.debug(*args, &block)
    end
    alias :LOG_D :log_debug
  end

end

if $0 == __FILE__
  require_relative "prelude.rb"

  class Foo
    def initialize
      p "foo"
    end

    extend AdLint::Pluggable

    def_plugin :on_initialization

    def run
      on_initialization.invoke(1, 2)
    end
  end

  def bar(a1, a2)
    p a1, a2
  end

  def baz(a1, a2)
    p "baz"
  end

  foo = Foo.lazy_new
  p "foo?"
  foo.on_initialization += method(:bar)
  foo.on_initialization += method(:baz)
  foo.run
end
