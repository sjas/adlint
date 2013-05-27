# Code structure information.
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

  # == DESCRIPTION
  # Base class of code structure information.
  class CodeStructure
    def print_as_csv(io)
      io.puts(to_csv)
    end

    # === DESCRIPTION
    # Converts this code structure information into string representation.
    #
    # === RETURN VALUE
    # String -- String representation.
    def to_s
      delim = ",".to_default_external
      to_a.map { |obj| obj.to_s.to_default_external }.join(delim)
    end

    private
    # === DESCRIPTION
    # Converts this code structure information into array representation.
    #
    # Subclasses must implement this method.
    #
    # === RETURN VALUE
    # Array< Object > -- Array representation.
    def to_a
      subclass_responsibility
    end

    def to_csv
      to_a.map { |obj| obj ? obj.to_s.to_default_external : nil }.to_csv
    end
  end

  # == DESCRIPTION
  # Type declaration information.
  class TypeDcl < CodeStructure
    # === DESCRIPTION
    # Constructs the type declaration information.
    #
    # === PARAMETER
    # _loc_:: Location -- Location where the declaration appears.
    # _dcl_type_:: String -- Type string of the type declaration.
    # _type_name_:: String -- Type name.
    # _type_rep_:: String -- Type representation.
    def initialize(loc, dcl_type, type_name, type_rep)
      @loc       = loc
      @dcl_type  = dcl_type
      @type_name = type_name
      @type_rep  = type_rep
    end

    private
    # === DESCRIPTION
    # Converts this code structure information into array representation.
    #
    # === RETURN VALUE
    # Array< Object > -- Array representation.
    def to_a
      ["DCL", *@loc.to_a, "T", @dcl_type, @type_name, @type_rep]
    end
  end

  # == DESCRIPTION
  # Global variable declaration information.
  class GVarDcl < CodeStructure
    # === DESCRIPTION
    # Constructs the global variable declaration information.
    #
    # === PARAMETER
    # _loc_:: Location -- Location where the declaration appears.
    # _var_name_:: String -- Global variable name.
    # _type_rep_:: String -- Type of the global variable.
    def initialize(loc, var_name, type_rep)
      @loc      = loc
      @var_name = var_name
      @type_rep = type_rep
    end

    private
    # === DESCRIPTION
    # Converts this code structure information into array representation.
    #
    # === RETURN VALUE
    # Array< Object > -- Array representation.
    def to_a
      ["DCL", *@loc.to_a, "V", @var_name, @type_rep]
    end
  end

  # == DESCRIPTION
  # Function declaration information.
  class FunDcl < CodeStructure
    # === DESCRIPTION
    # Constructs the function declaration information.
    #
    # === PARAMETER
    # _loc_:: Location -- Location where the declaration appears.
    # _linkage_:: String -- Function linkage type string.
    # _scope_type_:: String -- Declaration scope type string.
    # _dcl_type_:: String -- Declaration type string.
    # _fun_id_:: FunctionId -- Identifier of the function.
    def initialize(loc, linkage, scope_type, dcl_type, fun_id)
      @loc        = loc
      @linkage    = linkage
      @scope_type = scope_type
      @dcl_type   = dcl_type
      @fun_id     = fun_id
    end

    private
    # === DESCRIPTION
    # Converts this code structure information into array representation.
    #
    # === RETURN VALUE
    # Array< Object > -- Array representation.
    def to_a
      ["DCL", *@loc.to_a, "F", @linkage, @scope_type, @dcl_type, *@fun_id.to_a]
    end
  end

  # == DESCRIPTION
  # Variable definition information.
  class VarDef < CodeStructure
    # === DESCRIPTION
    # Constructs the variable definition information.
    #
    # === PARAMETER
    # _loc_:: Location -- Location where the definition appears.
    # _linkage_:: String -- Variable linkage type string.
    # _scope_type_:: String -- Variable scope type string.
    # _sc_type_:: String -- Variable storage class type.
    # _var_name_:: String -- Variable name.
    # _type_rep_:: String -- Variable type representation string.
    def initialize(loc, linkage, scope_type, sc_type, var_name, type_rep)
      @loc        = loc
      @linkage    = linkage
      @scope_type = scope_type
      @sc_type    = sc_type
      @var_name   = var_name
      @type_rep   = type_rep
    end

    private
    # === DESCRIPTION
    # Converts this code structure information into array representation.
    #
    # === RETURN VALUE
    # Array< Object > -- Array representation.
    def to_a
      ["DEF", *@loc.to_a, "V", @linkage, @scope_type, @sc_type, @var_name,
        @type_rep]
    end
  end

  # == DESCRIPTION
  # Function definition information.
  class FunDef < CodeStructure
    # === DESCRIPTION
    # Constructs the function definition information.
    #
    # === PARAMETER
    # _loc_:: Location -- Location where the definition appears.
    # _linkage_:: String -- Function linkage type string.
    # _scope_type_:: String -- Definition scope type string.
    # _fun_id_:: FunctionId -- Function identifier.
    # _lines_:: Integer -- Physical lines.
    def initialize(loc, linkage, scope_type, fun_id, lines)
      @loc        = loc
      @linkage    = linkage
      @scope_type = scope_type
      @fun_id     = fun_id
      @lines      = lines
    end

    private
    # === DESCRIPTION
    # Converts this code structure information into array representation.
    #
    # === RETURN VALUE
    # Array< Object > -- Array representation.
    def to_a
      ["DEF", *@loc.to_a, "F", @linkage, @scope_type, *@fun_id.to_a, @lines]
    end
  end

  # == DESCRIPTION
  # Macro definition information.
  class MacroDef < CodeStructure
    # === DESCRIPTION
    # Constructs the macro definition information.
    #
    # === PARAMETER
    # _loc_:: Location -- Location where the definition appears.
    # _macro_name_:: String -- Macro name.
    # _macro_type_:: String -- Macro type string.
    def initialize(loc, macro_name, macro_type)
      @loc        = loc
      @macro_name = macro_name
      @macro_type = macro_type
    end

    private
    # === DESCRIPTION
    # Converts this code structure information into array representation.
    #
    # === RETURN VALUE
    # Array< Object > -- Array representation.
    def to_a
      ["DEF", *@loc.to_a, "M", @macro_name, @macro_type]
    end
  end

  # == DESCRIPTION
  # Label definition information.
  class LabelDef < CodeStructure
    # === DESCRIPTION
    # Constructs the label definition information.
    #
    # === PARAMETER
    # _loc_:: Location -- Location where the definition appears.
    # _label_name_:: String -- Label name.
    def initialize(loc, label_name)
      @loc        = loc
      @label_name = label_name
    end

    private
    # === DESCRIPTION
    # Converts this code structure information into array representation.
    #
    # === RETURN VALUE
    # Array< Object > -- Array representation.
    def to_a
      ["DEF", *@loc.to_a, "L", @label_name]
    end
  end

  # == DESCRIPTION
  # Initialization information.
  class Initialization < CodeStructure
    # === DESCRIPTION
    # Constructs the initialization information.
    #
    # === PARAMETER
    # _loc_:: Location -- Location where the variable appears.
    # _var_name_:: String -- Initialized variable name.
    # _init_rep_:: String -- Initializer representation.
    def initialize(loc, var_name, init_rep)
      @loc      = loc
      @var_name = var_name
      @init_rep = init_rep
    end

    private
    # === DESCRIPTION
    # Converts this code structure information into array representation.
    #
    # === RETURN VALUE
    # Array< Object > -- Array representation.
    def to_a
      ["INI", *@loc.to_a, @var_name, @init_rep]
    end
  end

  # == DESCRIPTION
  # Assignment information.
  class Assignment < CodeStructure
    # === DESCRIPTION
    # Constructs the assignment information.
    #
    # === PARAMETER
    # _loc_:: Location -- Location where the variable appears.
    # _var_name_:: String -- Assigned variable name.
    # _assign_rep_:: String -- Assignment expression representation.
    def initialize(loc, var_name, assign_rep)
      @loc        = loc
      @var_name   = var_name
      @assign_rep = assign_rep
    end

    private
    # === DESCRIPTION
    # Converts this code structure information into array representation.
    #
    # === RETURN VALUE
    # Array< Object > -- Array representation.
    def to_a
      ["ASN", *@loc.to_a, @var_name, @assign_rep]
    end
  end

  # == DESCRIPTION
  # Header include information.
  class Include < CodeStructure
    # === DESCRIPTION
    # Constructs the header include information.
    #
    # === PARAMETER
    # _loc_:: Location -- Location where the directive appears.
    # _fpath_:: Pathname -- Path name of the included file.
    def initialize(loc, fpath)
      @loc   = loc
      @fpath = fpath
    end

    private
    # === DESCRIPTION
    # Converts this code structure information into array representation.
    #
    # === RETURN VALUE
    # Array< Object > -- Array representation.
    def to_a
      ["DEP", *@loc.to_a, "I", @fpath]
    end
  end

  # == DESCRIPTION
  # Function call information.
  class FunCall < CodeStructure
    # === DESCRIPTION
    # Constructs the function call informatin.
    #
    # === PARAMETER
    # _loc_:: Location -- Location where the function call appears.
    # _caller_fun_:: FunctionId -- Calling function identifier.
    # _callee_fun_:: FunctionId -- Called function identifier.
    def initialize(loc, caller_fun, callee_fun)
      @loc        = loc
      @caller_fun = caller_fun
      @callee_fun = callee_fun
    end

    private
    # === DESCRIPTION
    # Converts this code structure information into array representation.
    #
    # === RETURN VALUE
    # Array< Object > -- Array representation.
    def to_a
      ["DEP", *@loc.to_a, "C", *@caller_fun.to_a, *@callee_fun.to_a]
    end
  end

  # == DESCRIPTION
  # Variable cross reference information.
  class XRefVar < CodeStructure
    # === DESCRIPTION
    # Constructs the cross reference information.
    #
    # === PARAMETER
    # _loc_:: Location -- Location where the cross-ref appears.
    # _referrer_:: FunctionId -- Accessing function identifier.
    # _ref_type_:: String -- Referencing type string.
    # _var_name_:: String -- Accessed variable name.
    def initialize(loc, referrer, ref_type, var_name)
      @loc      = loc
      @referrer = referrer
      @ref_type = ref_type
      @var_name = var_name
    end

    private
    # === DESCRIPTION
    # Converts this code structure information into array representation.
    #
    # === RETURN VALUE
    # Array< Object > -- Array representation.
    def to_a
      ["DEP", *@loc.to_a, "X", "V", *@referrer.to_a, @ref_type, @var_name]
    end
  end

  class XRefFun < CodeStructure
    # === DESCRIPTION
    # Constructs the cross reference information.
    #
    # === PARAMETER
    # _loc_:: Location -- Location where the cross-ref appears.
    # _referrer_:: FunctionId -- Accessing function identifier.
    # _ref_type_:: String -- Referencing type string.
    # _fun_:: FunctionId -- Accessed function identifier.
    def initialize(loc, referrer, ref_type, fun)
      @loc      = loc
      @referrer = referrer
      @ref_type = ref_type
      @fun      = fun
    end

    private
    # === DESCRIPTION
    # Converts this code structure information into array representation.
    #
    # === RETURN VALUE
    # Array< Object > -- Array representation.
    def to_a
      ["DEP", *@loc.to_a, "X", "F", *@referrer.to_a, @ref_type, *@fun.to_a]
    end
  end

  class Literal < CodeStructure
    def initialize(loc, lit_type, prefix, suffix, value)
      @loc      = loc
      @lit_type = lit_type
      @prefix   = prefix
      @suffix   = suffix
      @value    = value
    end

    private
    def to_a
      ["LIT", *@loc.to_a, @lit_type, @prefix, @suffix, @value]
    end
  end

  class PPDirective < CodeStructure
    def initialize(loc, pp_dire, pp_tokens)
      @loc       = loc
      @pp_dire   = pp_dire
      @pp_tokens = pp_tokens
    end

    private
    def to_a
      ["PRE", *@loc.to_a, @pp_dire, @pp_tokens]
    end
  end

  class FunctionId
    def initialize(name, sig_str)
      @name, @signature = name, sig_str
    end

    attr_reader :name
    attr_reader :signature

    def to_a
      [@name, @signature]
    end
  end

end
