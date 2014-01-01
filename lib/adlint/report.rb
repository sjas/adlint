# Analysis report and its manipulation utility.
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

require "adlint/message"
require "adlint/code"
require "adlint/metric"
require "adlint/util"

module AdLint #:nodoc:

  class Report
    def initialize(msg_fpath, met_fpath, log_fpath, verbose, &block)
      @msg_fpath     = msg_fpath
      @msg_file      = open_msg_file(msg_fpath)
      @met_fpath     = met_fpath
      @met_file      = open_met_file(met_fpath)
      @log_fpath     = log_fpath
      @verbose       = verbose
      @unique_msgs   = Set.new
      @deferred_msgs = []

      yield(self)
    ensure
      @msg_file.close if @msg_file
      @met_file.close if @met_file
    end

    attr_reader :msg_fpath
    attr_reader :met_fpath
    attr_reader :log_fpath

    # === DESCRIPTION
    # Writes a message on this report.
    #
    # === PARAMETER
    # _message_:: Message -- Message to be written.
    #
    # === RETURN VALUE
    # Report -- Self.
    def write_message(msg, suppressors = nil)
      if suppressors.nil? || !suppressors.suppress?(msg)
        unless msg.must_be_unique? && !@unique_msgs.add?(msg)
          if msg.must_be_deferred?
            @deferred_msgs.push(msg)
          else
            rawrite_message(msg)
          end
        end
      end
      self
    end

    def flush_deferred_messages(suppressors)
      @deferred_msgs.each do |msg|
        rawrite_message(msg) unless suppressors.suppress?(msg)
      end
      @deferred_msgs.clear
      self
    end

    # === DESCRIPTION
    # Writes a code structure information on this report.
    #
    # === PARAMETER
    # _code_struct_:: CodeStructure -- Code structure info to be written.
    #
    # === RETURN VALUE
    # Report -- Self.
    def write_code_struct(code_struct)
      code_struct.print_as_csv(@met_file)
      self
    end

    # === DESCRIPTION
    # Writes a code quality metric on this report.
    #
    # === PARAMETER
    # _code_metric_:: CodeMetric -- Code metric information to be written.
    #
    # === RETURN VALUE
    # Report -- Self.
    def write_code_metric(code_metric)
      code_metric.print_as_csv(@met_file)
      self
    end

    private
    def rawrite_message(msg)
      msg.print_as_csv(@msg_file)
      msg.print_as_str($stderr) unless @verbose
    end

    def open_msg_file(fpath)
      File.open(fpath, "w").tap do |io|
        io.set_encoding(Encoding.default_external)
        io.puts(["V", SHORT_VERSION, Time.now.to_s, Dir.getwd].to_csv)
      end
    end

    def open_met_file(fpath)
      File.open(fpath, "w").tap do |io|
        io.set_encoding(Encoding.default_external)
        io.puts(["VER", SHORT_VERSION, Time.now.to_s, Dir.getwd].to_csv)
      end
    end
  end

  module ReportUtil
    # NOTE: Host class must respond to #report.
    # NOTE: Host class must respond to #message_catalog.
    # NOTE: Host class which needs #write_warning_message must respond to
    #       #suppressors.

    # === DESCRIPTION
    # Writes an error message on the report.
    #
    # Abbreviation below is available.
    #  write_error_message(msg_name, loc, ...) => E(msg_name, loc, ...)
    #
    # === PARAMETER
    # _msg_name_:: Symbol -- Message name.
    # _loc_:: Location -- Location where the message points to.
    # _parts_:: Array< Object > -- Message formatting parts.
    #
    # === RETURN VALUE
    # None.
    def write_error_message(msg_name, loc, *parts)
      report.write_message(
        ErrorMessage.new(message_catalog, msg_name, loc, *parts))
    end
    alias :E :write_error_message

    # === DESCRIPTION
    # Writes a warning message on the report.
    #
    # Abbreviation below is available.
    #  write_warning_message(loc, ...) => W(loc, ...)
    #
    # === PARAMETER
    # _loc_:: Location -- Location where the message points to.
    #
    # === RETURN VALUE
    # None.
    def write_warning_message(*args)
      check_class = self.class
      check_class = check_class.outer_module until check_class < CodeCheck

      head_msg = nil
      args.chunk { |arg| arg.kind_of?(Message) }.each do |*, chunk|
        case chunk.first
        when Message
          if head_msg
            chunk.each { |ctxt_msg| head_msg.complement_with(ctxt_msg) }
          end
        else
          head_msg = WarningMessage.new(message_catalog, check_class, *chunk)
        end
      end

      report.write_message(head_msg, suppressors) if head_msg
    end
    alias :W :write_warning_message

    # === DESCRIPTION
    # Creates a context message.
    #
    # Abbreviation below is available.
    #  create_context_message(msg_name, loc, ...) => C(msg_name, loc, ...)
    #
    # === PARAMETER
    # _msg_name_:: Symbol -- Message name.
    # _loc_:: Location -- Location where the message points to.
    # _parts_:: Array< Object > -- Message formatting parts.
    #
    # === RETURN VALUE
    # ContextMessage -- New context message.
    def create_context_message(msg_name, loc, *parts)
      ContextMessage.new(message_catalog, msg_name, self.class, loc, *parts)
    end
    alias :C :create_context_message

    # === DESCRIPTION
    # Writes a type declaration information on the report.
    #
    # Abbreviation below is available.
    #  write_typedcl(...) => TYPEDCL(...)
    #
    # === PARAMETER
    # _loc_:: Location -- Location where the declaration appears.
    # _dcl_type_:: String -- Type declaration type.
    # _type_name_:: String -- Type name.
    # _type_rep_:: String -- Type representation string.
    #
    # === RETURN VALUE
    # None.
    def write_typedcl(loc, dcl_type, type_name, type_rep)
      write_code_struct(TypeDcl.new(loc, dcl_type, type_name, type_rep))
    end
    alias :TYPEDCL :write_typedcl

    # === DESCRIPTION
    # Writes a global variable decaration information on the report.
    #
    # Abbreviation below is available.
    #  write_gvardcl(...) => GVARDCL(...)
    #
    # === PARAMETER
    # _loc_:: Location -- Location where the declaration appears.
    # _var_name_:: String -- Global variable name.
    # _type_rep_:: String -- Type representation string.
    #
    # === RETURN VALUE
    # None.
    def write_gvardcl(loc, var_name, type_rep)
      write_code_struct(GVarDcl.new(loc, var_name, type_rep))
    end
    alias :GVARDCL :write_gvardcl

    # === DESCRIPTION
    # Writes a function declaration information on the report.
    #
    # Abbreviation below is available.
    #  write_fundcl(...) => FUNDCL(...)
    #
    # === PARAMETER
    # _loc_:: Location -- Location where the declaration appears.
    # _linkage_:: String -- Function linkage type string.
    # _scope_type_:: String -- Declaration scope type string.
    # _dcl_type_:: String -- Declaration type string.
    # _fun_id_:: FunctionId -- Identifier of the function.
    #
    # === RETURN VALUE
    # None.
    def write_fundcl(loc, linkage, scope_type, dcl_type, fun_id)
      write_code_struct(FunDcl.new(loc, linkage, scope_type, dcl_type, fun_id))
    end
    alias :FUNDCL :write_fundcl

    # === DESCRIPTION
    # Writes a variable definition information on the report.
    #
    # Abbreviation below is available.
    #  write_vardef(...) => VARDEF(...)
    #
    # === PARAMETER
    # _loc_:: Location -- Location where the definition appears.
    # _linkage_type_:: String -- Variable linkage type string.
    # _scope_type_:: String -- Variable scope type string.
    # _sc_type_:: String -- Variable storage class type.
    # _var_name_:: String -- Variable name.
    # _type_rep_:: String -- Variable type representation string.
    #
    # === RETURN VALUE
    # None.
    def write_vardef(loc, linkage, scope_type, sc_type, var_name, type_rep)
      write_code_struct(VarDef.new(loc, linkage, scope_type, sc_type, var_name,
                                   type_rep))
    end
    alias :VARDEF :write_vardef

    # === DESCRIPTION
    # Writes a function definition information on the report.
    #
    # Abbreviation below is available.
    #  write_fundef(...) => FUNDEF(...)
    #
    # === PARAMETER
    # _loc_:: Location -- Location where the definition appears.
    # _linkage_:: String -- Function linkage type string.
    # _scope_type_:: String -- Definition scope type string.
    # _fun_id_:: FunctionId -- Identifier of the function.
    # _lines_:: Integer -- Physical lines.
    #
    # === RETURN VALUE
    # None.
    def write_fundef(loc, linkage, scope_type, fun_id, lines)
      write_code_struct(FunDef.new(loc, linkage, scope_type, fun_id, lines))
    end
    alias :FUNDEF :write_fundef

    # === DESCRIPTION
    # Writes a macro definition information on the report.
    #
    # Abbreviation below is available.
    #  write_macrodef(...) => MACRODEF(...)
    #
    # === PARAMETER
    # _loc_:: Location -- Location where the definition appears.
    # _macro_name_:: String -- Macro name.
    # _macro_type_:: String -- Macro type string.
    #
    # === RETURN VALUE
    # None.
    def write_macrodef(loc, macro_name, macro_type)
      write_code_struct(MacroDef.new(loc, macro_name, macro_type))
    end
    alias :MACRODEF :write_macrodef

    # === DESCRIPTION
    # Writes a label definition information on the report.
    #
    # Abbreviation below is available.
    #  write_labeldef(...) => LABELDEF(...)
    #
    # === PARAMETER
    # _loc_:: Location -- Location where the definition appears.
    # _label_name_:: String -- Label name.
    #
    # === RETURN VALUE
    # None.
    def write_labeldef(loc, label_name)
      write_code_struct(LabelDef.new(loc, label_name))
    end
    alias :LABELDEF :write_labeldef

    # === DESCRIPTION
    # Writes an initialization information on the report.
    #
    # Abbreviation below is available.
    #  write_initialization(...) => INITIALIZATION(...)
    #
    # === PARAMETER
    # _loc_:: Location -- Location where the variable appears.
    # _var_name_:: String -- Initialized variable name.
    # _init_rep_:: String -- String representation of the initializer.
    #
    # === RETURN VALUE
    # None.
    def write_initialization(loc, var_name, init_rep)
      write_code_struct(Initialization.new(loc, var_name, init_rep))
    end
    alias :INITIALIZATION :write_initialization

    # === DESCRIPTION
    # Writes an assignment information on the report.
    #
    # Abbreviation below is available.
    #  write_assignment(...) => ASSIGNMENT(...)
    #
    # === PARAMETER
    # _loc_:: Location -- Location where the variable appears.
    # _var_name_:: String -- Assigned variable name.
    # _assign_rep_:: String -- String representation of the assignment.
    #
    # === RETURN VALUE
    # None.
    def write_assignment(loc, var_name, assign_rep)
      write_code_struct(Assignment.new(loc, var_name, assign_rep))
    end
    alias :ASSIGNMENT :write_assignment

    # === DESCRIPTION
    # Writes a header include information on the report.
    #
    # Abbreviation below is available.
    #  write_include(...) => INCLUDE(...)
    #
    # === PARAMETER
    # _loc_:: Location -- Location where the directive appears.
    # _fpath_:: Pathname -- Path name of the included file.
    #
    # === RETURN VALUE
    # None.
    def write_include(loc, fpath)
      write_code_struct(Include.new(loc, fpath))
    end
    alias :INCLUDE :write_include

    # === DESCRIPTION
    # Writes a function call information on the report.
    #
    # Abbreviation below is available.
    #  write_funcall(...) => FUNCALL(...)
    #
    # === PARAMETER
    # _loc_:: Location -- Location where the function call appears.
    # _caller_fun_:: FunctionId -- Calling function identifier.
    # _callee_fun_:: FunctionId -- Called function identifier.
    def write_funcall(loc, caller_fun, callee_fun)
      write_code_struct(Funcall.new(loc, caller_fun, callee_fun))
    end
    alias :FUNCALL :write_funcall

    # === DESCRIPTION
    # Writes a variable cross reference information on the report.
    #
    # Abbreviation below is available.
    #  write_xref_variable(...) => XREF_VAR(...)
    #
    # === PARAMETER
    # _loc_:: Location -- Location where the cross-ref appears.
    # _referrer_:: FunctionId -- Accessing function identifier.
    # _ref_type_:: String -- Access type string.
    # _var_name_:: String -- Accessed variable name.
    #
    # === RETURN VALUE
    # None.
    def write_xref_variable(loc, referrer, ref_type, var_name)
      write_code_struct(XRefVar.new(loc, referrer, ref_type, var_name))
    end
    alias :XREF_VAR :write_xref_variable

    # === DESCRIPTION
    # Writes a function cross reference information on the report.
    #
    # Abbreviation below is available.
    #  write_xref_function(...) => XREF_FUN(...)
    #
    # === PARAMETER
    # _loc_:: Location -- Location where the cross-ref appears.
    # _referrer_:: FunctionId -- Accessing function identifier.
    # _ref_type_:: String -- Access type string.
    # _fun_:: FunctionId -- Accessed function identifier.
    #
    # === RETURN VALUE
    # None.
    def write_xref_function(loc, referrer, ref_type, fun)
      write_code_struct(XRefFun.new(loc, referrer, ref_type, fun))
    end
    alias :XREF_FUN :write_xref_function

    def write_literal(loc, lit_type, prefix, suffix, value)
      write_code_struct(Literal.new(loc, lit_type, prefix, suffix, value))
    end
    alias :LIT :write_literal

    def write_pp_directive(loc, pp_dire, pp_tokens)
      write_code_struct(PPDirective.new(loc, pp_dire, pp_tokens))
    end
    alias :PP_DIRECTIVE :write_pp_directive

    def write_FL_STMT(fpath, stmt_cnt)
      write_code_metric(FL_STMT_Metric.new(fpath, stmt_cnt))
    end
    alias :FL_STMT :write_FL_STMT

    def write_FL_FUNC(fpath, fun_cnt)
      write_code_metric(FL_FUNC_Metric.new(fpath, fun_cnt))
    end
    alias :FL_FUNC :write_FL_FUNC

    def write_FN_STMT(fun_id, loc, stmt_cnt)
      write_code_metric(FN_STMT_Metric.new(fun_id, loc, stmt_cnt))
    end
    alias :FN_STMT :write_FN_STMT

    def write_FN_UNRC(fun_id, loc, unreached_stmt_cnt)
      write_code_metric(FN_UNRC_Metric.new(fun_id, loc, unreached_stmt_cnt))
    end
    alias :FN_UNRC :write_FN_UNRC

    def write_FN_LINE(fun_id, loc, fun_lines)
      write_code_metric(FN_LINE_Metric.new(fun_id, loc, fun_lines))
    end
    alias :FN_LINE :write_FN_LINE

    def write_FN_PARA(fun_id, loc, param_cnt)
      write_code_metric(FN_PARA_Metric.new(fun_id, loc, param_cnt))
    end
    alias :FN_PARA :write_FN_PARA

    def write_FN_UNUV(fun_id, loc, useless_var_cnt)
      write_code_metric(FN_UNUV_Metric.new(fun_id, loc, useless_var_cnt))
    end
    alias :FN_UNUV :write_FN_UNUV

    def write_FN_CSUB(fun_id, loc, funcall_cnt)
      write_code_metric(FN_CSUB_Metric.new(fun_id, loc, funcall_cnt))
    end
    alias :FN_CSUB :write_FN_CSUB

    def write_FN_GOTO(fun_id, loc, goto_cnt)
      write_code_metric(FN_GOTO_Metric.new(fun_id, loc, goto_cnt))
    end
    alias :FN_GOTO :write_FN_GOTO

    def write_FN_RETN(fun_id, loc, ret_cnt)
      write_code_metric(FN_RETN_Metric.new(fun_id, loc, ret_cnt))
    end
    alias :FN_RETN :write_FN_RETN

    def write_FN_UELS(fun_id, loc, if_stmt_cnt)
      write_code_metric(FN_UELS_Metric.new(fun_id, loc, if_stmt_cnt))
    end
    alias :FN_UELS :write_FN_UELS

    def write_FN_NEST(fun_id, loc, max_nest)
      write_code_metric(FN_NEST_Metric.new(fun_id, loc, max_nest))
    end
    alias :FN_NEST :write_FN_NEST

    def write_FN_PATH(fun_id, loc, path_cnt)
      write_code_metric(FN_PATH_Metric.new(fun_id, loc, path_cnt))
    end
    alias :FN_PATH :write_FN_PATH

    def write_FN_CYCM(fun_id, loc, cycl_compl)
      write_code_metric(FN_CYCM_Metric.new(fun_id, loc, cycl_compl))
    end
    alias :FN_CYCM :write_FN_CYCM

    def write_FN_CALL(fun_sig, loc, caller_cnt)
      write_code_metric(FN_CALL_Metric.new(fun_sig, loc, caller_cnt))
    end
    alias :FN_CALL :write_FN_CALL

    private
    def write_code_struct(code_struct)
      report.write_code_struct(code_struct)
      nil
    end

    def write_code_metric(code_metric)
      report.write_code_metric(code_metric)
      nil
    end
  end

end
