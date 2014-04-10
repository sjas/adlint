# Code quality metrics.
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

  class CodeMetric
    def print_as_csv(io)
      io.puts(to_csv)
    end

    def to_s
      delim = ",".to_default_external
      to_a.map { |obj| obj.to_s.to_default_external }.join(delim)
    end

    private
    def to_a
      subclass_responsibility
    end

    def to_csv
      to_a.map { |obj| obj ? obj.to_s.to_default_external : nil }.to_csv
    end
  end

  class FileMetric < CodeMetric
    def initialize(name, fpath, val)
      @name  = name
      @fpath = fpath
      @val   = val
    end

    private
    def to_a
      ["MET", @name, @fpath, @val]
    end
  end

  class FL_STMT_Metric < FileMetric
    def initialize(fpath, stmt_cnt)
      super("FL_STMT", fpath, stmt_cnt)
    end
  end

  class FL_FUNC_Metric < FileMetric
    def initialize(fpath, fun_cnt)
      super("FL_FUNC", fpath, fun_cnt)
    end
  end

  class FunctionMetric < CodeMetric
    def initialize(name, fun_id, loc, val)
      @name   = name
      @fun_id = fun_id
      @loc    = loc
      @val    = val
    end

    private
    def to_a
      ["MET", @name, *@fun_id.to_a, *@loc.to_a, @val]
    end
  end

  class FN_STMT_Metric < FunctionMetric
    def initialize(fun_id, loc, stmt_cnt)
      super("FN_STMT", fun_id, loc, stmt_cnt)
    end
  end

  class FN_UNRC_Metric < FunctionMetric
    def initialize(fun_id, loc, unreached_stmt_cnt)
      super("FN_UNRC", fun_id, loc, unreached_stmt_cnt)
    end
  end

  class FN_LINE_Metric < FunctionMetric
    def initialize(fun_id, loc, fun_lines)
      super("FN_LINE", fun_id, loc, fun_lines)
    end
  end

  class FN_PARA_Metric < FunctionMetric
    def initialize(fun_id, loc, param_cnt)
      super("FN_PARA", fun_id, loc, param_cnt)
    end
  end

  class FN_UNUV_Metric < FunctionMetric
    def initialize(fun_id, loc, useless_var_cnt)
      super("FN_UNUV", fun_id, loc, useless_var_cnt)
    end
  end

  class FN_CSUB_Metric < FunctionMetric
    def initialize(fun_id, loc, funcall_cnt)
      super("FN_CSUB", fun_id, loc, funcall_cnt)
    end
  end

  class FN_GOTO_Metric < FunctionMetric
    def initialize(fun_id, loc, goto_cnt)
      super("FN_GOTO", fun_id, loc, goto_cnt)
    end
  end

  class FN_RETN_Metric < FunctionMetric
    def initialize(fun_id, loc, ret_cnt)
      super("FN_RETN", fun_id, loc, ret_cnt)
    end
  end

  class FN_UELS_Metric < FunctionMetric
    def initialize(fun_id, loc, if_stmt_cnt)
      super("FN_UELS", fun_id, loc, if_stmt_cnt)
    end
  end

  class FN_NEST_Metric < FunctionMetric
    def initialize(fun_id, loc, max_nest)
      super("FN_NEST", fun_id, loc, max_nest)
    end
  end

  class FN_PATH_Metric < FunctionMetric
    def initialize(fun_id, loc, path_cnt)
      super("FN_PATH", fun_id, loc, path_cnt)
    end
  end

  class FN_CYCM_Metric < FunctionMetric
    def initialize(fun_id, loc, cycl_compl)
      super("FN_CYCM", fun_id, loc, cycl_compl)
    end
  end

  class FN_CALL_Metric < FunctionMetric
    def initialize(fun_id, loc, caller_cnt)
      super("FN_CALL", fun_id, loc, caller_cnt)
    end
  end

  class MetricRecord < CsvRecord
    def self.of(csv_row, sma_wd)
      case csv_row[0]
      when "VER"
        create_version_record(csv_row)
      when "DCL"
        create_declaration_record(csv_row, sma_wd)
      when "DEF"
        create_definition_record(csv_row, sma_wd)
      when "INI"
        create_initialization_record(csv_row, sma_wd)
      when "ASN"
        create_assignment_record(csv_row, sma_wd)
      when "DEP"
        create_dependency_record(csv_row, sma_wd)
      when "LIT"
        create_literal_record(csv_row, sma_wd)
      when "PRE"
        create_pp_directive_record(csv_row, sma_wd)
      when "MET"
        create_metric_record(csv_row, sma_wd)
      else
        # NOTE: Silently ignore unknown records so that an optional examination
        #       package may output its own special ones.
        #
        #raise "invalid metric record."
        nil
      end
    end

    def initialize(csv_row, sma_wd)
      super(csv_row)
      @sma_wd = sma_wd
    end

    def type
      field_at(0)
    end

    def fpath
      sma_abs_fpath = Pathname.new(field_at(1)).expand_path(@sma_wd)
      sma_abs_fpath.relative_path_from(Pathname.pwd)
    end

    def line_no
      field_at(2).to_i
    end

    def column_no
      field_at(3).to_i
    end

    def location
      Location.new(fpath, line_no, column_no)
    end
    memoize :location

    def version?; false end

    def typedef_declaration?; false end

    def struct_declaration?; false end

    def union_declaration?; false end

    def enum_declaration?; false end

    def global_variable_declaration?; false end

    def function_declaration?; false end

    def variable_definition?; false end

    def function_definition?; false end

    def macro_definition?; false end

    def label_definition?; false end

    def initialization?; false end

    def assignment?; false end

    def include?; false end

    def function_call?; false end

    def variable_xref?; false end

    def function_xref?; false end

    def literal?; false end

    def pp_directive?; false end

    def self.create_version_record(csv_row)
      VersionRecord.new(csv_row)
    end
    private_class_method :create_version_record

    def self.create_declaration_record(csv_row, sma_wd)
      case csv_row[4]
      when "T"
        case csv_row[5]
        when "T"
          TypedefDeclarationRecord.new(csv_row, sma_wd)
        when "S"
          StructDeclarationRecord.new(csv_row, sma_wd)
        when "U"
          UnionDeclarationRecord.new(csv_row, sma_wd)
        when "E"
          EnumDeclarationRecord.new(csv_row, sma_wd)
        else
          raise "invalid DCL record."
        end
      when "V"
        GlobalVariableDeclarationRecord.new(csv_row, sma_wd)
      when "F"
        FunctionDeclarationRecord.new(csv_row, sma_wd)
      else
        raise "invalid DCL record."
      end
    end
    private_class_method :create_declaration_record

    def self.create_definition_record(csv_row, sma_wd)
      case csv_row[4]
      when "V"
        VariableDefinitionRecord.new(csv_row, sma_wd)
      when "F"
        FunctionDefinitionRecord.new(csv_row, sma_wd)
      when "M"
        MacroDefinitionRecord.new(csv_row, sma_wd)
      when "L"
        LabelDefinitionRecord.new(csv_row, sma_wd)
      else
        raise "invalid DEF record."
      end
    end
    private_class_method :create_definition_record

    def self.create_initialization_record(csv_row, sma_wd)
      InitializationRecord.new(csv_row, sma_wd)
    end
    private_class_method :create_initialization_record

    def self.create_assignment_record(csv_row, sma_wd)
      AssignmentRecord.new(csv_row, sma_wd)
    end
    private_class_method :create_assignment_record

    def self.create_dependency_record(csv_row, sma_wd)
      case csv_row[4]
      when "I"
        IncludeRecord.new(csv_row, sma_wd)
      when "C"
        FunctionCallRecord.new(csv_row, sma_wd)
      when "X"
        case csv_row[5]
        when "V"
          VariableXRefRecord.new(csv_row, sma_wd)
        when "F"
          FunctionXRefRecord.new(csv_row, sma_wd)
        else
          raise "invalid DEP record."
        end
      else
        raise "invalid DEP record."
      end
    end
    private_class_method :create_dependency_record

    def self.create_literal_record(csv_row, sma_wd)
      LiteralRecord.new(csv_row, sma_wd)
    end
    private_class_method :create_literal_record

    def self.create_pp_directive_record(csv_row, sma_wd)
      PPDirectiveRecord.new(csv_row, sma_wd)
    end
    private_class_method :create_pp_directive_record

    def self.create_metric_record(csv_row, sma_wd)
      new(csv_row, sma_wd)
    end
    private_class_method :create_metric_record

    class VersionRecord < MetricRecord
      def initialize(csv_row)
        super(csv_row, nil)
      end

      def version?
        true
      end

      def version_number
        field_at(1)
      end

      def exec_timestamp
        field_at(2)
      end

      def exec_working_directory
        field_at(3)
      end
    end
    private_constant :VersionRecord

    class TypedefDeclarationRecord < MetricRecord
      def typedef_declaration?
        true
      end

      def typedcl_type
        field_at(5)
      end

      def type_name
        field_at(6)
      end

      def type_rep
        field_at(7)
      end
    end
    private_constant :TypedefDeclarationRecord

    class StructDeclarationRecord < MetricRecord
      def struct_declaration?
        true
      end

      def typedcl_type
        field_at(5)
      end

      def type_name
        field_at(6)
      end

      def type_rep
        field_at(7)
      end
    end
    private_constant :StructDeclarationRecord

    class UnionDeclarationRecord < MetricRecord
      def union_declaration?
        true
      end

      def typedcl_type
        field_at(5)
      end

      def type_name
        field_at(6)
      end

      def type_rep
        field_at(7)
      end
    end
    private_constant :UnionDeclarationRecord

    class EnumDeclarationRecord < MetricRecord
      def enum_declaration?
        true
      end

      def typedcl_type
        field_at(5)
      end

      def type_name
        field_at(6)
      end

      def type_rep
        field_at(7)
      end
    end
    private_constant :EnumDeclarationRecord

    class GlobalVariableDeclarationRecord < MetricRecord
      def global_variable_declaration?
        true
      end

      def variable_name
        field_at(5)
      end

      def type_rep
        field_at(6)
      end
    end
    private_constant :GlobalVariableDeclarationRecord

    class FunctionDeclarationRecord < MetricRecord
      def function_declaration?
        true
      end

      def function_linkage_type
        field_at(5)
      end

      def function_scope_type
        field_at(6)
      end

      def function_declaration_type
        field_at(7)
      end

      def function_id
        FunctionId.new(field_at(8), field_at(9))
      end
    end
    private_constant :FunctionDeclarationRecord

    class VariableDefinitionRecord < MetricRecord
      def variable_definition?
        true
      end

      def variable_linkage_type
        field_at(5)
      end

      def variable_scope_type
        field_at(6)
      end

      def storage_class_type
        field_at(7)
      end

      def variable_name
        field_at(8)
      end

      def type_rep
        field_at(9)
      end
    end
    private_constant :VariableDefinitionRecord

    class FunctionDefinitionRecord < MetricRecord
      def function_definition?
        true
      end

      def function_linkage_type
        field_at(5)
      end

      def function_scope_type
        field_at(6)
      end

      def function_id
        FunctionId.new(field_at(7), field_at(8))
      end

      def lines
        field_at(9)
      end
    end
    private_constant :FunctionDefinitionRecord

    class MacroDefinitionRecord < MetricRecord
      def macro_definition?
        true
      end

      def macro_name
        field_at(5)
      end

      def macro_type
        field_at(6)
      end
    end
    private_constant :MacroDefinitionRecord

    class LabelDefinitionRecord < MetricRecord
      def label_definition?
        true
      end

      def label_name
        field_at(5)
      end
    end
    private_constant :LabelDefinitionRecord

    class InitializationRecord < MetricRecord
      def initialization?
        true
      end

      def variable_name
        field_at(4)
      end

      def initializer_rep
        field_at(5)
      end
    end
    private_constant :InitializationRecord

    class AssignmentRecord < MetricRecord
      def assignment?
        true
      end

      def variable_name
        field_at(4)
      end

      def assignment_rep
        field_at(5)
      end
    end
    private_constant :AssignmentRecord

    class IncludeRecord < MetricRecord
      def include?
        true
      end

      def included_fpath
        Pathname.new(field_at(5))
      end
    end
    private_constant :IncludeRecord

    class FunctionCallRecord < MetricRecord
      def function_call?
        true
      end

      def caller_function
        FunctionId.new(field_at(5), field_at(6))
      end

      def callee_function
        FunctionId.new(field_at(7), field_at(8))
      end
    end
    private_constant :FunctionCallRecord

    class VariableXRefRecord < MetricRecord
      def variable_xref?
        true
      end

      def accessor_function
        FunctionId.new(field_at(6), field_at(7))
      end

      def access_type
        field_at(8)
      end

      def accessee_variable
        field_at(9)
      end
    end
    private_constant :VariableXRefRecord

    class FunctionXRefRecord < MetricRecord
      def function_xref?
        true
      end

      def accessor_function
        FunctionId.new(field_at(6), field_at(7))
      end

      def access_type
        field_at(8)
      end

      def accessee_function
        FunctionId.new(field_at(9), field_at(10))
      end
    end
    private_constant :FunctionXRefRecord

    class LiteralRecord < MetricRecord
      def literal?
        true
      end

      def literal_type
        field_at(4)
      end

      def literal_prefix
        field_at(5)
      end

      def literal_suffix
        field_at(6)
      end

      def literal_value
        field_at(7)
      end
    end
    private_constant :LiteralRecord

    class PPDirectiveRecord < MetricRecord
      def pp_directive?
        true
      end

      def pp_directive
        field_at(4)
      end

      def pp_tokens
        field_at(5)
      end
    end
    private_constant :PPDirectiveRecord
  end

end
