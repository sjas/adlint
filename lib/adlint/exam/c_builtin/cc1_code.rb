# Code structure extractions (cc1-phase) of adlint-exam-c_builtin package.
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

require "adlint/exam"
require "adlint/report"
require "adlint/cc1/phase"
require "adlint/cc1/syntax"

module AdLint #:nodoc:
module Exam #:nodoc:
module CBuiltin #:nodoc:

  class TypeDclExtraction < CodeExtraction
    def_registrant_phase Cc1::Prepare2Phase

    def initialize(phase_ctxt)
      super
      trav = phase_ctxt[:cc1_ast_traversal]
      trav.enter_typedef_declaration     += T(:extract_typedef_dcl)
      trav.enter_struct_type_declaration += T(:extract_struct_dcl)
      trav.enter_union_type_declaration  += T(:extract_union_dcl)
      trav.enter_enum_type_declaration   += T(:extract_enum_dcl)
    end

    private
    def do_prepare(*) end
    def do_execute(*) end

    def extract_typedef_dcl(typedef_dcl)
      TYPEDCL(typedef_dcl.identifier.location, "T",
              typedef_dcl.type.name, typedef_dcl.type.image)
    end

    def extract_struct_dcl(struct_type_dcl)
      TYPEDCL(struct_type_dcl.identifier.location, "S",
              struct_type_dcl.type.name, struct_type_dcl.type.image)
    end

    def extract_union_dcl(union_type_dcl)
      TYPEDCL(union_type_dcl.identifier.location, "U",
              union_type_dcl.type.name, union_type_dcl.type.image)
    end

    def extract_enum_dcl(enum_type_dcl)
      TYPEDCL(enum_type_dcl.identifier.location, "E",
              enum_type_dcl.type.name, enum_type_dcl.type.image)
    end
  end

  class GVarDclExtraction < CodeExtraction
    def_registrant_phase Cc1::Prepare2Phase

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_variable_declared += T(:extract)
    end

    private
    def do_prepare(*) end
    def do_execute(*) end

    def extract(var_dcl, var)
      if var.declared_as_extern?
        GVARDCL(var_dcl.identifier.location, var_dcl.identifier.value,
                var_dcl.type.brief_image)
      end
    end
  end

  class FunDclExtraction < CodeExtraction
    def_registrant_phase Cc1::Prepare2Phase

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_explicit_function_declared += T(:extract_explicit_dcl)
      interp.on_implicit_function_declared += T(:extract_implicit_dcl)
      interp.on_block_started              += T(:enter_block)
      interp.on_block_ended                += T(:leave_block)
      @block_level = 0
    end

    private
    def do_prepare(*) end
    def do_execute(*) end

    def extract_explicit_dcl(fun_dcl, fun)
      if fun.declared_as_extern?
        FUNDCL(fun_dcl.identifier.location, "X",
               @block_level == 0 ? "F" : "B", "E",
               FunctionId.new(fun_dcl.identifier.value,
                              fun_dcl.signature.to_s))
      else
        FUNDCL(fun_dcl.identifier.location, "I",
               @block_level == 0 ? "F" : "B", "E",
               FunctionId.new(fun_dcl.identifier.value,
                              fun_dcl.signature.to_s))
      end
    end

    def extract_implicit_dcl(expr, fun)
      if fun.named?
        FUNDCL(expr.location, "X", "F", "I",
               FunctionId.new(fun.name, fun.signature.to_s))
      end
    end

    def enter_block(*)
      @block_level += 1
    end

    def leave_block(*)
      @block_level -= 1
    end
  end

  class VarDefExtraction < CodeExtraction
    def_registrant_phase Cc1::Prepare2Phase

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_variable_defined  += T(:extract_variable)
      interp.on_parameter_defined += T(:extract_parameter)
      interp.on_block_started     += T(:enter_block)
      interp.on_block_ended       += T(:leave_block)
      @block_level = 0
    end

    private
    def do_prepare(*) end
    def do_execute(*) end

    def extract_variable(var_def, var)
      case
      when var.declared_as_extern?
        VARDEF(var_def.identifier.location, "X", @block_level == 0 ? "F" : "B",
               storage_class_type(var_def.storage_class_specifier),
               var_def.identifier.value, var_def.type.brief_image)
      when var.declared_as_static?
        VARDEF(var_def.identifier.location, "I", @block_level == 0 ? "F" : "B",
               storage_class_type(var_def.storage_class_specifier),
               var_def.identifier.value, var_def.type.brief_image)
      when var.declared_as_auto?
        VARDEF(var_def.identifier.location, "I", @block_level == 0 ? "F" : "B",
               storage_class_type(var_def.storage_class_specifier),
               var_def.identifier.value, var_def.type.brief_image)
      when var.declared_as_register?
        VARDEF(var_def.identifier.location, "I", @block_level == 0 ? "F" : "B",
               storage_class_type(var_def.storage_class_specifier),
               var_def.identifier.value, var_def.type.brief_image)
      end
    end

    def extract_parameter(param_def, var)
      if var.named?
        VARDEF(param_def.identifier.location, "I", "P",
               storage_class_type(param_def.storage_class_specifier),
               param_def.identifier.value, param_def.type.brief_image)
      end
    end

    def enter_block(*)
      @block_level += 1
    end

    def leave_block(*)
      @block_level -= 1
    end

    def storage_class_type(sc_spec)
      if sc_spec
        case sc_spec.type
        when :AUTO
          "A"
        when :REGISTER
          "R"
        when :STATIC
          "S"
        when :EXTERN
          "E"
        else
          "N"
        end
      else
        "N"
      end
    end
  end

  class FunDefExtraction < CodeExtraction
    def_registrant_phase Cc1::Prepare2Phase

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_explicit_function_defined += T(:extract_function)
    end

    private
    def do_prepare(*) end
    def do_execute(*) end

    def extract_function(fun_def, fun)
      fun_id = FunctionId.new(fun_def.identifier.value, fun_def.signature.to_s)
      case
      when fun.declared_as_extern?
        FUNDEF(fun_def.identifier.location, "X", "F", fun_id, fun_def.lines)
      when fun.declared_as_static?
        FUNDEF(fun_def.identifier.location, "I", "F", fun_id, fun_def.lines)
      end
    end
  end

  class LabelDefExtraction < CodeExtraction
    def_registrant_phase Cc1::Prepare2Phase

    def initialize(phase_ctxt)
      super
      trav = phase_ctxt[:cc1_ast_traversal]
      trav.enter_generic_labeled_statement += T(:extract)
    end

    private
    def do_prepare(*) end
    def do_execute(*) end

    def extract(labeled_stmt)
      LABELDEF(labeled_stmt.label.location, labeled_stmt.label.value)
    end
  end

  class InitializationExtraction < CodeExtraction
    def_registrant_phase Cc1::Prepare2Phase

    def initialize(phase_ctxt)
      super
      trav = phase_ctxt[:cc1_ast_traversal]
      trav.enter_variable_definition += T(:extract)
    end

    private
    def do_prepare(*) end
    def do_execute(*) end

    def extract(var_def)
      if var_def.initializer
        INITIALIZATION(var_def.identifier.location, var_def.identifier.value,
                       var_def.initializer.to_s)
      end
    end
  end

  class AssignmentExtraction < CodeExtraction
    def_registrant_phase Cc1::Prepare2Phase

    def initialize(phase_ctxt)
      super
      trav = phase_ctxt[:cc1_ast_traversal]
      trav.enter_simple_assignment_expression   += T(:extract)
      trav.enter_compound_assignment_expression += T(:extract)
    end

    private
    def do_prepare(*) end
    def do_execute(*) end

    def extract(assign_expr)
      ASSIGNMENT(assign_expr.operator.location, assign_expr.lhs_operand.to_s,
                 stringify(assign_expr))
    end

    def stringify(assign_expr)
      "#{assign_expr.operator.value} #{assign_expr.rhs_operand.to_s}"
    end
  end

  class FuncallExtraction < CodeExtraction
    def_registrant_phase Cc1::Prepare2Phase

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_function_started          += T(:update_caller)
      interp.on_function_ended            += T(:clear_caller)
      interp.on_function_call_expr_evaled += T(:extract_function_call)
      @caller = nil
    end

    private
    def do_prepare(*) end
    def do_execute(*) end

    def update_caller(*, fun)
      @caller = fun
    end

    def clear_caller(*)
      @caller = nil
    end

    def extract_function_call(funcall_expr, fun, *)
      if fun.named?
        if @caller
          referrer = FunctionId.new(@caller.name, @caller.signature.to_s)
        else
          referrer = FunctionId.of_ctors_section
        end
        FUNCALL(funcall_expr.location, referrer,
                FunctionId.new(fun.name, fun.signature.to_s))
      end
    end
  end

  class XRefExtraction < CodeExtraction
    def_registrant_phase Cc1::Prepare2Phase

    def initialize(phase_ctxt)
      super
      interp = phase_ctxt[:cc1_interpreter]
      interp.on_function_started        += T(:update_accessor)
      interp.on_function_ended          += T(:clear_accessor)
      interp.on_variable_value_referred += T(:extract_variable_read)
      interp.on_variable_value_updated  += T(:extract_variable_write)
      interp.on_function_referred       += T(:extract_function_reference)
      @accessor = nil
    end

    private
    def do_prepare(*) end
    def do_execute(*) end

    def update_accessor(*, fun)
      @accessor = fun
    end

    def clear_accessor(*)
      @accessor = nil
    end

    def extract_variable_read(expr, var)
      if var.scope.global? && var.named?
        # NOTE: When a value of the inner-variable of array or composite object
        #       is referred, dependency record of only outmost-variable access
        #       should be output.
        var = var.owner while var.inner?

        if @accessor
          referrer = FunctionId.new(@accessor.name, @accessor.signature.to_s)
        else
          referrer = FunctionId.of_ctors_section
        end
        XREF_VAR(expr.location, referrer, "R", var.name)
      end
    end

    def extract_variable_write(expr, var)
      # NOTE: When a value of the inner-variable of array or composite
      #       object is updated, dependency record of the inner-variable
      #       access should not be output and the outer variable's value
      #       will also be notified later.
      return if var.inner?

      if var.scope.global? && var.named?
        if @accessor
          referrer = FunctionId.new(@accessor.name, @accessor.signature.to_s)
        else
          referrer = FunctionId.of_ctors_section
        end
        XREF_VAR(expr.location, referrer, "W", var.name)
      end
    end

    def extract_function_reference(expr, fun)
      if fun.named?
        if @accessor
          referrer = FunctionId.new(@accessor.name, @accessor.signature.to_s)
        else
          referrer = FunctionId.of_ctors_section
        end
        XREF_FUN(expr.location, referrer, "R",
                 FunctionId.new(fun.name, fun.signature.to_s))
      end
    end
  end

  class LiteralExtraction < CodeExtraction
    def_registrant_phase Cc1::Prepare2Phase

    def initialize(phase_ctxt)
      super
      trav = phase_ctxt[:cc1_ast_traversal]
      trav.enter_constant_specifier       += T(:extract_constant)
      trav.enter_string_literal_specifier += T(:extract_string_literal)
    end

    private
    def do_prepare(*) end
    def do_execute(*) end

    def extract_constant(const_spec)
      LIT(const_spec.location, type_of(const_spec),
          const_spec.prefix, const_spec.suffix, const_spec.constant.value)
    end

    def extract_string_literal(str_lit_spec)
      LIT(str_lit_spec.location, type_of(str_lit_spec),
          str_lit_spec.prefix, nil, str_lit_spec.literal.value)
    end

    def type_of(const_or_str_lit_spec)
      case const_or_str_lit_spec
      when Cc1::ConstantSpecifier
        case const_or_str_lit_spec.constant.value
        when /\A0x[0-9a-f]+[UL]*\z/i
          "HN"
        when /\A0b[01]+[UL]*\z/i
          "BN"
        when /\A0[0-9]+[UL]*\z/i
          "ON"
        when /\A[0-9]+[UL]*\z/i
          "DN"
        when /\A(?:[0-9]*\.[0-9]*E[+-]?[0-9]+|[0-9]+\.?E[+-]?[0-9]+)[FL]*\z/i,
             /\A(?:[0-9]*\.[0-9]+|[0-9]+\.)[FL]*\z/i
          "FN"
        when /\A'.*'\z/i
          "CN"
        when /\AL'.*'\z/i
          "CW"
        else
          "NA"
        end
      when Cc1::StringLiteralSpecifier
        case const_or_str_lit_spec.literal.value
        when /\A".*"\z/i
          "SN"
        when /\AL".*"\z/i
          "SW"
        else
          "NA"
        end
      else
        raise TypeError
      end
    end
  end

end
end
end
