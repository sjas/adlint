# AdLint analysis project configuration.
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

require "adlint/version"
require "adlint/util"

module AdLint #:nodoc:

  # == DESCRIPTION
  # Analysis configuration information.
  class Traits
    include Validation

    def initialize(traits_fpath)
      File.open(traits_fpath, "r:utf-8") do |io|
        case ary_or_stream = YAML.load_stream(io)
        when Array
          # NOTE: YAML.load_stream returns Array in Ruby 1.9.3-preview1.
          doc = ary_or_stream.first
        when YAML::Stream
          doc = ary_or_stream.documents.first
        end
        validate_version(doc["version"])

        @exam_packages = (doc["exam_packages"] || []).uniq.map { |name|
          ExaminationPackage.new(name)
        }.freeze

        @project_traits  = ProjectTraits.new(doc["project_traits"]).freeze
        @compiler_traits = CompilerTraits.new(doc["compiler_traits"]).freeze
        @linker_traits   = LinkerTraits.new(doc["linker_traits"]).freeze
        @message_traits  = MessageTraits.new(doc["message_traits"]).freeze
      end
    end

    attr_reader :exam_packages

    def of_project
      @project_traits
    end

    def of_compiler
      @compiler_traits
    end

    def of_linker
      @linker_traits
    end

    def of_message
      @message_traits
    end

    def entity_name
      ""
    end

    ensure_exam_packages_presence_of :exam_packages
    ensure_validity_of :project_traits
    ensure_validity_of :compiler_traits
    ensure_validity_of :linker_traits
    ensure_validity_of :message_traits

    private
    def validate_version(ver)
      ver == TRAITS_SCHEMA_VERSION or
        raise "invalid version of the traits file.\n" +
              "regenerate or migrate traits file by new `adlintize' command."
    end
  end

  class ProjectTraits
    include Validation
    include CompoundPathParser

    def initialize(doc)
      @project_name      = doc["project_name"]
      @project_root      = Pathname.new(doc["project_root"])
      @target_files      = TargetFiles.new(doc["target_files"])
      @initial_header    = doc["initial_header"]
      @file_search_paths = parse_compound_path_list(doc["file_search_paths"])
      @coding_style      = CodingStyle.new(doc["coding_style"])
      @file_encoding     = doc["file_encoding"]
    end

    def entity_name
      "project_traits"
    end

    attr_reader :project_name
    ensure_presence_of :project_name

    attr_reader :project_root
    ensure_dir_presence_of :project_root

    attr_reader :target_files
    ensure_validity_of :target_files

    attr_reader :initial_header
    ensure_file_presence_of :initial_header, :allow_nil => true

    attr_reader :file_search_paths
    ensure_dirs_presence_of :file_search_paths

    attr_reader :coding_style
    ensure_validity_of :coding_style

    attr_reader :file_encoding
    ensure_with :file_encoding, :message => "is not a valid encoding name.",
                :validator => Encoding.method(:include_name?)

    class TargetFiles
      include Validation
      include CompoundPathParser

      def initialize(doc)
        @inclusion_paths = parse_compound_path_list(doc["inclusion_paths"])
        @exclusion_paths = parse_compound_path_list(doc["exclusion_paths"])
      end

      def entity_name
        "project_traits:target_files"
      end

      attr_reader :inclusion_paths
      ensure_dirs_presence_of :inclusion_paths

      attr_reader :exclusion_paths
      ensure_dirs_presence_of :exclusion_paths

      def freeze
        @inclusion_paths.freeze
        @exclusion_paths.freeze
        super
      end
    end

    class CodingStyle
      include Validation

      K_AND_R = "K&R"
      ALLMAN  = "Allman"
      GNU     = "GNU"

      def initialize(doc)
        @indent_style = doc["indent_style"]
        @tab_width    = doc["tab_width"]
        @indent_width = doc["indent_width"]
      end

      def entity_name
        "project_traits:coding_style"
      end

      attr_reader :indent_style
      ensure_inclusion_of :indent_style, :values => [K_AND_R, ALLMAN, GNU]

      attr_reader :tab_width
      ensure_numericality_of :tab_width, :only_integer => true, :min => 1

      attr_reader :indent_width
      ensure_numericality_of :indent_width, :only_integer => true, :min => 1

      def freeze
        @indent_style.freeze
        @tab_width.freeze
        @indent_width.freeze
        super
      end
    end

    def freeze
      @project_name.freeze
      @target_files.freeze
      @file_search_paths.freeze
      @coding_style.freeze
      @file_encoding.freeze
      super
    end
  end

  # == DESCRIPTION
  # Traits information of the compiler used in the project.
  class CompilerTraits
    include Validation
    include CompoundPathParser

    def initialize(doc)
      @initial_header    = doc["initial_header"]
      @file_search_paths = parse_compound_path_list(doc["file_search_paths"])
      @standard_types    = StandardTypes.new(doc["standard_types"])
      @arithmetic        = Arithmetic.new(doc["arithmetic"])
      @identifier_max    = doc["identifier_max"]

      @extension_substitutions = doc["extension_substitutions"] || {}
      @arbitrary_substitutions = doc["arbitrary_substitutions"] || {}
    end

    def entity_name
      "compiler_traits"
    end

    # === VALUE
    # String -- The file path of the initial source.
    attr_reader :initial_header
    ensure_file_presence_of :initial_header, :allow_nil => true

    # === VALUE
    # Array< String > -- System include paths.
    attr_reader :file_search_paths
    ensure_dirs_presence_of :file_search_paths

    # === VALUE
    # CompilerTraits::StandardTypes -- The standard type traits information.
    attr_reader :standard_types
    ensure_validity_of :standard_types

    # === VALUE
    # CompilerTraits::Arithmetic -- The arithmetic traits information.
    attr_reader :arithmetic
    ensure_validity_of :arithmetic

    # === VALUE
    # Integer -- Max length of all symbols identified by the compiler.
    attr_reader :identifier_max
    ensure_numericality_of :identifier_max, :only_integer => true, :min => 1

    # === VALUE
    # Hash<String, String > -- The compiler-extension code substitution
    # settings.
    attr_reader :extension_substitutions

    # === VALUE
    # Hash<String, String > -- The arbitrary code substitution settings.
    attr_reader :arbitrary_substitutions

    # == DESCRIPTION
    # Traits information of standard types.
    class StandardTypes
      include Validation

      def initialize(doc)
        @char_size             = doc["char_size"]
        @char_alignment        = doc["char_alignment"]
        @short_size            = doc["short_size"]
        @short_alignment       = doc["short_alignment"]
        @int_size              = doc["int_size"]
        @int_alignment         = doc["int_alignment"]
        @long_size             = doc["long_size"]
        @long_alignment        = doc["long_alignment"]
        @long_long_size        = doc["long_long_size"]
        @long_long_alignment   = doc["long_long_alignment"]
        @float_size            = doc["float_size"]
        @float_alignment       = doc["float_alignment"]
        @double_size           = doc["double_size"]
        @double_alignment      = doc["double_alignment"]
        @long_double_size      = doc["long_double_size"]
        @long_double_alignment = doc["long_double_alignment"]

        @code_ptr_size         = doc["code_ptr_size"]
        @code_ptr_alignment    = doc["code_ptr_alignment"]
        @data_ptr_size         = doc["data_ptr_size"]
        @data_ptr_alignment    = doc["data_ptr_alignment"]

        @char_as_unsigned_char = doc["char_as_unsigned_char"]
      end

      def entity_name
        "compiler_traits:standard_types"
      end

      # === VALUE
      # Integer -- Bit length of the `char' type.
      attr_reader :char_size
      ensure_numericality_of :char_size, :only_integer => true,
                             :min => 1, :max => 256

      attr_reader :char_alignment
      ensure_numericality_of :char_alignment, :only_integer => true, :min => 1

      # === VALUE
      # Integer -- Bit length of the `short' type.
      attr_reader :short_size
      ensure_numericality_of :short_size, :only_integer => true,
                             :min => 1, :max => 256

      attr_reader :short_alignment
      ensure_numericality_of :short_alignment, :only_integer => true, :min => 1

      # === VALUE
      # Integer -- Bit length of the `int' type.
      attr_reader :int_size
      ensure_numericality_of :int_size, :only_integer => true,
                             :min => 1, :max => 256

      attr_reader :int_alignment
      ensure_numericality_of :int_alignment, :only_integer => true, :min => 1

      # === VALUE
      # Integer -- Bit length of the `long' type.
      attr_reader :long_size
      ensure_numericality_of :long_size, :only_integer => true,
                             :min => 1, :max => 256

      attr_reader :long_alignment
      ensure_numericality_of :long_alignment, :only_integer => true, :min => 1

      # === VALUE
      # Integer -- Bit length of the `long long' type.
      attr_reader :long_long_size
      ensure_numericality_of :long_long_size, :only_integer => true,
                             :min => 1, :max => 256

      attr_reader :long_long_alignment
      ensure_numericality_of :long_long_alignment, :only_integer => true,
                             :min => 1

      # === VALUE
      # Integer -- Bit length of the `float' type.
      attr_reader :float_size
      ensure_numericality_of :float_size, :only_integer => true,
                             :min => 1, :max => 256

      attr_reader :float_alignment
      ensure_numericality_of :float_alignment, :only_integer => true, :min => 1

      # === VALUE
      # Integer -- Bit length of the `double' type.
      attr_reader :double_size
      ensure_numericality_of :double_size, :only_integer => true,
                             :min => 1, :max => 256

      attr_reader :double_alignment
      ensure_numericality_of :double_alignment, :only_integer => true,
                             :min => 1

      # === VALUE
      # Integer -- Bit length of the `long double' type.
      attr_reader :long_double_size
      ensure_numericality_of :long_double_size, :only_integer => true,
                             :min => 1, :max => 256

      attr_reader :long_double_alignment
      ensure_numericality_of :long_double_alignment, :only_integer => true,
                             :min => 1

      attr_reader :code_ptr_size
      ensure_numericality_of :code_ptr_size, :only_integer => true,
                             :min => 1, :max => 256

      attr_reader :code_ptr_alignment
      ensure_numericality_of :code_ptr_alignment, :only_integer => true,
                             :min => 1

      attr_reader :data_ptr_size
      ensure_numericality_of :data_ptr_size, :only_integer => true,
                             :min => 1, :max => 256

      attr_reader :data_ptr_alignment
      ensure_numericality_of :data_ptr_alignment, :only_integer => true,
                             :min => 1

      # === VALUE
      # Boolean -- The flag indicates `char' is `unsigned char'.
      attr_reader :char_as_unsigned_char
      ensure_true_or_false_of :char_as_unsigned_char

      def freeze
        @char_size.freeze
        @char_alignment.freeze
        @short_size.freeze
        @short_alignment.freeze
        @int_size.freeze
        @int_alignment.freeze
        @long_size.freeze
        @long_alignment.freeze
        @long_long_size.freeze
        @long_long_alignment.freeze
        @float_size.freeze
        @float_alignment.freeze
        @double_size.freeze
        @double_alignment.freeze
        @long_double_size.freeze
        @long_double_alignment.freeze
        @code_ptr_size.freeze
        @code_ptr_alignment.freeze
        @data_ptr_size.freeze
        @data_ptr_alignment.freeze
        @char_as_unsigned_char.freeze
        super
      end
    end
    private_constant :StandardTypes

    # == DESCRIPTION
    # Traits information of arithmetic process.
    class Arithmetic
      include Validation

      def initialize(doc)
        @logical_right_shift = doc["logical_right_shift"]
      end

      def entity_name
        "compiler_traits:arithmetic"
      end

      # === VALUE
      # Boolean -- The flag value indicates the right shift operation is
      # logical.
      attr_reader :logical_right_shift
      ensure_true_or_false_of :logical_right_shift

      def freeze
        @logical_right_shift.freeze
        super
      end
    end
    private_constant :Arithmetic

    def freeze
      @file_search_paths.freeze
      @standard_types.freeze
      @arithmetic.freeze
      @identifier_max.freeze
      @extension_substitutions.freeze
      @arbitrary_substitutions.freeze
      super
    end
  end

  # == DESCRIPTION
  # Traits information of the linker used in the project.
  class LinkerTraits
    include Validation

    def initialize(doc)
      @identifier_max         = doc["identifier_max"]
      @identifier_ignore_case = doc["identifier_ignore_case"]
    end

    def entity_name
      "linker_traits"
    end

    # === VALUE
    # Integer -- Max length of all external symbols identified by the linker.
    attr_reader :identifier_max
    ensure_numericality_of :identifier_max, :only_integer => true, :min => 1

    # === VALUE
    # Boolean -- The flag indicates that external symbols are identified
    # without case by the linker.
    attr_reader :identifier_ignore_case
    ensure_true_or_false_of :identifier_ignore_case

    def freeze
      @identifier_max.freeze
      @identifier_ignore_case.freeze
      super
    end
  end

  class MessageTraits
    include Validation
    include CompoundPathParser

    def initialize(doc)
      @language               = doc["language"]
      @individual_suppression = doc["individual_suppression"]
      @exclusion              = Exclusion.new(doc["exclusion"])
      @inclusion              = Inclusion.new(doc["inclusion"])

      @change_list =
        (doc["change_list"] || []).each_with_object({}) { |(name, cont), hash|
          hash[MessageId.new(cont["package"], name.to_sym)] = cont
        }
    end

    def entity_name
      "message_traits"
    end

    attr_reader :language
    ensure_inclusion_of :language, :values => %w(ja_JP en_US)

    attr_reader :individual_suppression
    ensure_true_or_false_of :individual_suppression

    attr_reader :exclusion
    ensure_validity_of :exclusion

    attr_reader :inclusion
    ensure_validity_of :inclusion

    attr_reader :change_list

    class Exclusion
      include Validation

      def initialize(doc)
        if doc
          @categories = doc["categories"] || []
          @severities = doc["severities"] ? Regexp.new(doc["severities"]) : nil
          @messages   = (doc["messages"] || {}).map { |msg_name, pkg_name|
            MessageId.new(pkg_name, msg_name.to_sym)
          }.to_set
        else
          @categories = []
          @severities = nil
          @messages   = Set.new
        end
      end

      def entity_name
        "message_traits:exclusion"
      end

      attr_reader :categories
      attr_reader :severities
      attr_reader :messages

      def freeze
        @categories.freeze
        @severities.freeze
        @messages.freeze
        super
      end
    end
    private_constant :Exclusion

    class Inclusion
      include Validation

      def initialize(doc)
        if doc
          @messages = (doc["messages"] || {}).map { |msg_name, pkg_name|
            MessageId.new(pkg_name, msg_name.to_sym)
          }.to_set
        else
          @messages = Set.new
        end
      end

      def entity_name
        "message_traits:inclusion"
      end

      attr_reader :messages

      def freeze
        @messages.freeze
        super
      end
    end
    private_constant :Inclusion

    def freeze
      @language.freeze
      @individual_suppression.freeze
      @exclusion.freeze
      @inclusion.freeze
      @change_list.freeze
      super
    end
  end

  module CodingStyleAccessor
    # NOTE: Host class must respond to #traits.

    def coding_style
      traits.of_project.coding_style
    end

    def indent_style
      coding_style.indent_style
    end

    def tab_width
      coding_style.tab_width
    end

    def indent_width
      coding_style.indent_width
    end

    INDENT_STYLE_K_AND_R = ProjectTraits::CodingStyle::K_AND_R
    INDENT_STYLE_ALLMAN  = ProjectTraits::CodingStyle::ALLMAN
    INDENT_STYLE_GNU     = ProjectTraits::CodingStyle::GNU
  end

  module StandardTypesAccessor
    # NOTE: Host class must respond to #traits.

    def standard_types
      traits.of_compiler.standard_types
    end

    def char_size
      standard_types.char_size
    end

    def char_alignment
      standard_types.char_alignment
    end

    def short_size
      standard_types.short_size
    end

    def short_alignment
      standard_types.short_alignment
    end

    def int_size
      standard_types.int_size
    end

    def int_alignment
      standard_types.int_alignment
    end

    def long_size
      standard_types.long_size
    end

    def long_alignment
      standard_types.long_alignment
    end

    def long_long_size
      standard_types.long_long_size
    end

    def long_long_alignment
      standard_types.long_long_alignment
    end

    def float_size
      standard_types.float_size
    end

    def float_alignment
      standard_types.float_alignment
    end

    def double_size
      standard_types.double_size
    end

    def double_alignment
      standard_types.double_alignment
    end

    def long_double_size
      standard_types.long_double_size
    end

    def long_double_alignment
      standard_types.long_double_alignment
    end

    def code_ptr_size
      standard_types.code_ptr_size
    end

    def code_ptr_alignment
      standard_types.code_ptr_alignment
    end

    def data_ptr_size
      standard_types.data_ptr_size
    end

    def data_ptr_alignment
      standard_types.data_ptr_alignment
    end

    def char_as_unsigned_char?
      standard_types.char_as_unsigned_char
    end
  end

  module ArithmeticAccessor
    # NOTE: Host class must respond to #traits.

    def arithmetic
      traits.of_compiler.arithmetic
    end

    def logical_right_shift?
      arithmetic.logical_right_shift
    end
  end

  module ExclusionAccessor
    # NOTE: Host class must respond to #traits.

    def exclusion
      traits.of_message.exclusion
    end

    def categories
      exclusion.categories
    end

    def severities
      exclusion.severities
    end

    def messages
      exclusion.messages
    end
  end

  module InclusionAccessor
    # NOTE: Host class must respond to #traits.

    def inclusion
      traits.of_message.inclusion
    end

    def messages
      inclusion.messages
    end
  end

end
