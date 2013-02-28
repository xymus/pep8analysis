# Raw AST node hierarchy.
# This file was generated by SableCC (http://www.sablecc.org/).
package parser_nodes

import location

# Root of the AST hierarchy
abstract class ANode
	var _location: nullable Location

	# Location is set during AST building. Once built, location cannon be null
	# However, manual instanciated nodes may need mode care
	fun location: Location do return _location.as(not null)
end

# Ancestor of all tokens
abstract class Token
	super ANode

	fun text : String is abstract
end

# Ancestor of all productions
abstract class Prod
	super ANode
	fun location=(loc: Location) do _location = loc
end
class TEol
	super Token
end
class TNumber
	super Token
end
class TFloat
	super Token
end
class TChar
	super Token
end
class TString
	super Token
end
class THex
	super Token
end
class TColon
	super Token
end
class TComma
	super Token
end
class TComment
	super Token
end
class TTkByte
	super Token
end
class TTkWord
	super Token
end
class TTkBlock
	super Token
end
class TTkAscii
	super Token
end
class TTkAddrss
	super Token
end
class TTkEquate
	super Token
end
class TTkBurn
	super Token
end
class TEndBlock
	super Token
end
class TId
	super Token
end
class EOF
	super Token
private init noinit do end
end
class AError
	super EOF
private init noinit do end
end

class ALine super Prod end
class AInstruction super Prod end
class AAccess super Prod end
class AValue super Prod end
class ADirective super Prod end

class AListing
	super Prod
    readable var _n_lines: List[ALine] = new List[ALine]
    readable var _n_label_decl: nullable ALabelDecl = null
    readable var _n_end_block: TEndBlock
end
class AEmptyLine
	super ALine
    readable var _n_comment: nullable TComment = null
    readable var _n_eol: TEol
end
class AInstructionLine
	super ALine
    readable var _n_label_decl: nullable ALabelDecl = null
    readable var _n_instruction: AInstruction
    readable var _n_comment: nullable TComment = null
    readable var _n_eol: TEol
end
class ADirectiveLine
	super ALine
    readable var _n_label_decl: nullable ALabelDecl = null
    readable var _n_directive: ADirective
    readable var _n_comment: nullable TComment = null
    readable var _n_eol: TEol
end
class ALabelDecl
	super Prod
    readable var _n_id: TId
    readable var _n_colon: TColon
end
class AUnaryInstruction
	super AInstruction
    readable var _n_id: TId
end
class ABinaryInstruction
	super AInstruction
    readable var _n_id: TId
    readable var _n_access: AAccess
end
class AImmediateAccess
	super AAccess
    readable var _n_value: AValue
end
class AAnyAccess
	super AAccess
    readable var _n_value: AValue
    readable var _n_comma: TComma
    readable var _n_id: TId
end
class ALabelValue
	super AValue
    readable var _n_id: TId
end
class ANumberValue
	super AValue
    readable var _n_number: TNumber
end
class ACharValue
	super AValue
    readable var _n_char: TChar
end
class AStringValue
	super AValue
    readable var _n_string: TString
end
class AHexValue
	super AValue
    readable var _n_hex: THex
end
class AByteDirective
	super ADirective
    readable var _n_tk_byte: TTkByte
    readable var _n_value: AValue
end
class AWordDirective
	super ADirective
    readable var _n_tk_word: TTkWord
    readable var _n_value: AValue
end
class ABlockDirective
	super ADirective
    readable var _n_tk_block: TTkBlock
    readable var _n_number: TNumber
end
class AAsciiDirective
	super ADirective
    readable var _n_tk_ascii: TTkAscii
    readable var _n_string: TString
end
class AAddrssDirective
	super ADirective
    readable var _n_tk_addrss: TTkAddrss
    readable var _n_value: AValue
end
class AEquateDirective
	super ADirective
    readable var _n_tk_equate: TTkEquate
    readable var _n_value: AValue
end
class ABurnDirective
	super ADirective
    readable var _n_tk_burn: TTkBurn
    readable var _n_value: AValue
end

class Start
	super Prod
    readable var _n_base: nullable AListing
    readable var _n_eof: EOF
    init(
        n_base: nullable AListing,
        n_eof: EOF)
    do
        _n_base = n_base
        _n_eof = n_eof
    end

end
