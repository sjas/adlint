# Base classes of the warning and the error messages.
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

require "adlint/token"
require "adlint/error"

module AdLint #:nodoc:

  class MessageId
    def initialize(pkg_name, msg_name)
      @package_name = pkg_name
      @message_name = msg_name
    end

    attr_reader :package_name
    attr_reader :message_name

    def qualified?
      !@package_name.nil?
    end

    def ==(rhs)
      self.eql?(rhs)
    end

    def eql?(rhs)
      if self.qualified? && rhs.qualified?
        @package_name == rhs.package_name && @message_name == rhs.message_name
      else
        @message_name == rhs.message_name
      end
    end

    def hash
      @message_name.hash
    end
  end

  # == DESCRIPTION
  # Base class of all messages.
  class Message
    # === DESCRIPTION
    # Constructs a message.
    #
    # === PARAMETER
    # _msg_tmpl_:: MessageTemplate -- Template for the creating message.
    # _loc_:: Location -- Location where the message detected.
    # _parts_:: Array< Object > -- Message formatting parts.
    def initialize(msg_tmpl, loc, *parts)
      @template    = msg_tmpl
      @location    = loc
      @parts       = parts
      @complements = []
    end

    attr_reader :location

    def id
      @template.message_id
    end

    def must_be_unique?
      subclass_responsibility
    end

    def must_be_deferred?
      subclass_responsibility
    end

    def complement_with(msg)
      @complements.push(msg)
    end

    def eql?(rhs)
      id == rhs.id && @location == rhs.location && @parts == rhs.parts
    end

    def hash
      [id, @location, @parts].hash
    end

    def print_as_str(io)
      io.puts(to_s)
      @complements.each { |comp| comp.print_as_str(io) }
    end

    def print_as_csv(io)
      io.puts(to_csv)
      @complements.each { |comp| comp.print_as_csv(io) }
    end

    # === DESCRIPTION
    # Converts this message into a string for human readable output.
    #
    # === RETURN VALUE
    # String -- String representation of this message.
    def to_s
      begin
        "#{@location.to_s.to_default_external}:" +
          "#{type_str.to_default_external}:" +
          "#{id.package_name}:#{id.message_name.to_s}:" +
          "#{@template.typical_class.category}:" +
          "#{@template.typical_class.severity}:" +
          "#{@template.format(@parts)}"
      rescue
        raise InvalidMessageFormatError.new(id, @location)
      end
    end

    protected
    attr_reader :parts

    private
    # === DESCRIPTION
    # Reads the type of this message.
    #
    # Subclasses must implement this method.
    #
    # === RETURN VALUE
    # Symbol -- Message type symbol.
    def type
      subclass_responsibility
    end

    # === DESCRIPTION
    # Reads the type string of this message.
    #
    # Subclasses must implement this method.
    #
    # === RETURN VALUE
    # String -- Message type string.
    def type_str
      subclass_responsibility
    end

    # === DESCRIPTION
    # Converts this message into an array of message elements.
    #
    # === RETURN VALUE
    # Array< Object > -- Array of message elements.
    def to_a
      begin
        [
          type.to_s, *@location.to_a, id.package_name, id.message_name,
          @template.typical_class.category, @template.typical_class.severity,
          @template.format(@parts)
        ]
      rescue
        raise InvalidMessageFormatError.new(id, @location)
      end
    end

    def to_csv
      to_a.map { |obj| obj && obj.to_s.to_default_external }.to_csv
    end
  end

  # == DESCRIPTION
  # Syntactical error message.
  class ErrorMessage < Message
    def initialize(msg_catalog, msg_name, loc, *parts)
      super(msg_catalog.lookup(MessageId.new("core", msg_name)), loc, *parts)
    end

    def must_be_unique?
      false
    end

    def must_be_deferred?
      false
    end

    private
    # === DESCRIPTION
    # Reads the type of this message.
    #
    # === RETURN VALUE
    # Symbol -- Message type symbol.
    def type
      :E
    end

    # === DESCRIPTION
    # Reads the type string of this message.
    #
    # === RETURN VALUE
    # String -- Message type string.
    def type_str
      "error"
    end
  end

  # == DESCRIPTION
  # AdLint specific internal fatal error message.
  class FatalErrorMessage < Message
    # === DESCRIPTION
    # Constructs a AdLint specific internal fatal error message.
    #
    # === PARAMETER
    # _msg_catalog_:: MessageCatalog -- Message catalog.
    # _cause_ex_:: Exception -- Cause exception.
    def initialize(msg_catalog, cause_ex)
      msg_id = MessageId.new("core", cause_ex.message_name)
      super(msg_catalog.lookup(msg_id), cause_ex.location || Location.new,
            *cause_ex.parts)
      @cause_ex = cause_ex
    end

    def must_be_unique?
      false
    end

    def must_be_deferred?
      false
    end

    private
    # === DESCRIPTION
    # Reads the type of this message.
    #
    # === RETURN VALUE
    # Symbol -- Message type symbol.
    def type
      :X
    end

    # === DESCRIPTION
    # Reads the type string of this message.
    #
    # === RETURN VALUE
    # String -- Message type string.
    def type_str
      "fatal error"
    end
  end

  # == DESCRIPTION
  # Semantical warning message.
  class WarningMessage < Message
    def initialize(msg_catalog, check_class, loc, *parts)
      super(msg_catalog.lookup(check_class.message_id), loc, *parts)
      @check_class = check_class
    end

    def must_be_unique?
      @check_class.must_be_unique?
    end

    def must_be_deferred?
      @check_class.must_be_deferred?
    end

    private
    # === DESCRIPTION
    # Reads the type of this message.
    #
    # === RETURN VALUE
    # Symbol -- Message type symbol.
    def type
      :W
    end

    # === DESCRIPTION
    # Reads the type string of this message.
    #
    # === RETURN VALUE
    # String -- Message type string.
    def type_str
      "warning"
    end
  end

  # == DESCRIPTION
  # Message complements other messages.
  class ContextMessage < Message
    def initialize(msg_catalog, msg_name, check_class, loc, *parts)
      msg_id = MessageId.new(check_class.catalog.name, msg_name)
      super(msg_catalog.lookup(msg_id), loc, *parts)
    end

    def must_be_unique?
      false
    end

    def must_be_deferred?
      false
    end

    private
    # === DESCRIPTION
    # Reads the type of this message.
    #
    # === RETURN VALUE
    # Symbol -- Message type symbol.
    def type
      :C
    end

    # === DESCRIPTION
    # Reads the type string of this message.
    #
    # === RETURN VALUE
    # String -- Message type string.
    def type_str
      "context"
    end
  end

  class MessageClass
    def initialize(class_str)
      @category, @severity =
        class_str.split(":").map { |str| str.to_default_external }
    end

    attr_reader :category
    attr_reader :severity
  end

  # == DESCRIPTION
  # Message catalog entry.
  class MessageTemplate
    def initialize(msg_id, classes, fmt)
      @message_id    = msg_id
      @classes       = classes.map { |class_str| MessageClass.new(class_str) }
      @format        = fmt
      @typical_class = @classes.sort { |msg_class| msg_class.severity }.first
    end

    attr_reader :message_id
    attr_reader :classes
    attr_reader :typical_class

    def categories
      @classes.map { |c| c.category }
    end

    def severities
      @classes.map { |c| c.severity }
    end

    def format(parts)
      @format.to_s.to_default_external %
        parts.map { |obj| obj.to_s.to_default_external }
    end
  end

  class MessageDefinitionFile
    MESSAGES_FNAME = Pathname.new("messages.yml")
    private_constant :MESSAGES_FNAME

    def initialize(pkg_name, lang_name)
      @package_name  = pkg_name
      @language_name = lang_name
    end

    def read_into(msg_catalog)
      File.open(fpath, "r:utf-8") do |io|
        case ary_or_stream = YAML.load_stream(io)
        when Array
          # NOTE: YAML.load_stream returns Array in Ruby 1.9.3-preview1.
          doc = ary_or_stream.first
        when YAML::Stream
          doc = ary_or_stream.documents.first
        end
        validate_version(doc["version"])
        if msg_def = doc["message_definition"]
          msg_catalog.merge!(@package_name, msg_def)
        else
          raise "invalid form of the message definition file."
        end
      end
      self
    end

    private
    def base_dpath
      subclass_responsibility
    end

    def fpath
      base_dpath.join(Pathname.new(@language_name)).join(MESSAGES_FNAME)
    end

    def validate_version(ver)
      # NOTE: Version field of the message catalog does not mean the schema
      #       version of the catalog file, but a revision number of the catalog
      #       contents.
      #       When AdLint is installed normally, the schema version of the
      #       catalog is always valid.  So, schema version validation is
      #       unnecessary.
    end
  end

  class CoreMessageDefinitionFile < MessageDefinitionFile
    def initialize(lang_name)
      super("core", lang_name)
    end

    private
    def base_dpath
      Pathname.new("mesg.d/core").expand_path(Config[:etcdir])
    end
  end

  class ExamMessageDefinitionFile < MessageDefinitionFile
    def initialize(exam_pkg, lang_name)
      super(exam_pkg.name, lang_name)
      @exam_pkg = exam_pkg
    end

    private
    def base_dpath
      @exam_pkg.catalog.message_definition_dpath
    end
  end

  # == DESCRIPTION
  # Message catalog.
  class MessageCatalog
    def initialize(traits)
      @traits = traits
      @hash = Hash.new
      message_definition_files.each { |def_file| def_file.read_into(self) }
    end

    def lookup(msg_id)
      @hash[msg_id] or raise InvalidMessageIdError.new(msg_id)
    end

    def merge!(pkg_name, msg_def)
      msg_def.each do |msg_name_str, cont|
        msg_id = MessageId.new(pkg_name, msg_name_str.to_sym)
        if changed = @traits.of_message.change_list[msg_id]
          cont = changed
        end
        @hash[msg_id] =
          MessageTemplate.new(msg_id, cont["classes"], cont["format"])
      end
    end

    private
    def message_definition_files
      lang_name = @traits.of_message.language
      [CoreMessageDefinitionFile.new(lang_name)] +
        @traits.exam_packages.map { |pkg|
          ExamMessageDefinitionFile.new(pkg, lang_name)
        }
    end
  end

end
