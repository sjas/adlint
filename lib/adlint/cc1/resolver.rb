# C type resolver.
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

require "adlint/monitor"
require "adlint/cc1/type"
require "adlint/cc1/syntax"

module AdLint #:nodoc:
module Cc1 #:nodoc:

  class TypeResolver < SyntaxTreeVisitor
    include MonitorUtil

    def initialize(type_tbl)
      @type_table = type_tbl
    end

    attr_reader :type_table

    def resolve(ast)
      ast.accept(self)
      @type_table
    end

    def visit_struct_type_declaration(node)
      checkpoint(node.location)
      node.struct_declarations.each { |dcl| dcl.accept(self) }
      node.type = @type_table.install_struct_type(node)
    end

    def visit_union_type_declaration(node)
      checkpoint(node.location)
      node.struct_declarations.each { |dcl| dcl.accept(self) }
      node.type = @type_table.install_union_type(node)
    end

    def visit_struct_declaration(node)
      node.items.each { |item| item.accept(self) }
    end

    def visit_member_declaration(node)
      checkpoint(node.location)
      node.specifier_qualifier_list.accept(self)
      node.struct_declarator.accept(self)

      type_quals = node.specifier_qualifier_list.type_qualifiers
      type_specs = node.specifier_qualifier_list.type_specifiers
      type = lookup_variable_type(type_quals, type_specs,
                                  node.struct_declarator.declarator)
      type = @type_table.pointer_type(type) if type.function?

      if node.struct_declarator.bitfield?
        if bit_width = compute_bitfield_width(node.struct_declarator)
          type = @type_table.bitfield_type(type, bit_width)
        else
          type = fallback_type
        end
      end

      node.type = type
    end

    def visit_enum_type_declaration(node)
      checkpoint(node.location)
      node.type = @type_table.install_enum_type(node)
      node.enumerators.each { |enum| enum.type = node.type }
    end

    def visit_typedef_declaration(node)
      checkpoint(node.location)
      node.declaration_specifiers.accept(self)
      node.init_declarator.accept(self)
      node.type = @type_table.install_user_type(node)
    end

    def visit_function_declaration(node)
      checkpoint(node.location)
      node.declaration_specifiers.accept(self) if node.declaration_specifiers
      node.init_declarator.accept(self)

      if dcl_specs = node.declaration_specifiers
        type_quals = dcl_specs.type_qualifiers
        type_specs = dcl_specs.type_specifiers
      else
        type_quals = []
        type_specs = []
      end

      node.type = lookup_variable_type(type_quals, type_specs,
                                       node.init_declarator.declarator)
    end

    def visit_parameter_declaration(node)
      checkpoint(node.location)
      node.declaration_specifiers.accept(self) if node.declaration_specifiers
      node.declarator.accept(self) if node.declarator

      if dcl_specs = node.declaration_specifiers
        type_quals = dcl_specs.type_qualifiers
        type_specs = dcl_specs.type_specifiers
      else
        type_quals = []
        type_specs = []
      end

      type = lookup_variable_type(type_quals, type_specs, node.declarator)

      if type.function?
        node.type = @type_table.pointer_type(type)
      else
        node.type = type
      end
    end

    def visit_variable_declaration(node)
      checkpoint(node.location)
      node.declaration_specifiers.accept(self) if node.declaration_specifiers
      node.declarator.accept(self)

      if dcl_specs = node.declaration_specifiers
        type_quals = dcl_specs.type_qualifiers
        type_specs = dcl_specs.type_specifiers
      else
        type_quals = []
        type_specs = []
      end

      type = lookup_variable_type(type_quals, type_specs, node.declarator)

      if type.function?
        node.type = @type_table.pointer_type(type)
      else
        node.type = type
      end
    end

    def visit_variable_definition(node)
      checkpoint(node.location)
      node.declaration_specifiers.accept(self) if node.declaration_specifiers
      node.init_declarator.accept(self)

      if dcl_specs = node.declaration_specifiers
        type_quals = dcl_specs.type_qualifiers
        type_specs = dcl_specs.type_specifiers
      else
        type_quals = []
        type_specs = []
      end

      type = lookup_variable_type(type_quals, type_specs,
                                  node.init_declarator.declarator)

      if type.function?
        node.type = @type_table.pointer_type(type)
      else
        node.type = type
      end
    end

    def visit_ansi_function_definition(node)
      checkpoint(node.location)
      super
      node.type = lookup_function_type(node)
    end

    def visit_kandr_function_definition(node)
      checkpoint(node.location)
      super
      node.type = lookup_function_type(node)
    end

    def visit_parameter_definition(node)
      checkpoint(node.location)
      node.declaration_specifiers.accept(self) if node.declaration_specifiers
      node.declarator.accept(self) if node.declarator

      type = @type_table.lookup_parameter_type(node, interpreter)
      type = @type_table.pointer_type(type) if type.function?
      node.type = type
    end

    def visit_type_name(node)
      checkpoint(node.location)
      super
      type_quals = node.specifier_qualifier_list.type_qualifiers
      type_specs = node.specifier_qualifier_list.type_specifiers
      node.type = lookup_variable_type(type_quals, type_specs,
                                       node.abstract_declarator)
    end

    def visit_compound_statement(node)
      @type_table.enter_scope
      super
      @type_table.leave_scope
    end

    private
    def lookup_variable_type(type_quals, type_specs, dcl)
      @type_table.lookup_or_install_type(
        type_quals, type_specs, dcl, interpreter) || fallback_type
    end

    def lookup_function_type(fun_def)
      @type_table.lookup_function_type(fun_def) || fallback_type
    end

    def compute_bitfield_width(struct_dcl)
      if expr = struct_dcl.expression
        if interpreter
          obj = interpreter.execute(expr)
        else
          obj = Interpreter.new(@type_table).execute(expr)
        end

        if obj.variable? && obj.value.scalar?
          return obj.value.unique_sample
        end
      end
      nil
    end

    extend Forwardable

    def_delegator :@type_table, :monitor
    private :monitor
  end

  class StaticTypeResolver < TypeResolver
    private
    def interpreter
      nil
    end

    def fallback_type
      type_table.unresolved_type
    end
  end

  class DynamicTypeResolver < TypeResolver
    def initialize(type_tbl, interp)
      super(type_tbl)
      @interpreter = interp
    end

    attr_reader :interpreter

    private
    def fallback_type
      type_table.undeclared_type
    end
  end

end
end
