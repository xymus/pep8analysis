module pretty_instructions

import ast_base
import rich_instructions

redef class AnalysisManager
	var opt_ast = new OptionBool("Print the AST","--ast")

	redef init
	do
		super
		opts.add_option(opt_ast)
	end

	redef fun build_ast(filename)
	do
		var ast = super

		if ast != null and opt_ast.value then
			var printer = new ASTPrinter
			printer.enter_visit(ast)
			print printer.str
		end

		return ast
	end
end

redef class ANode
	fun accept_ast_printer(v: ASTPrinter) do visit_all(v)
end

redef class Token
	redef fun to_s do return text
	redef fun accept_ast_printer(v: ASTPrinter) do v.str += self.to_s + " "
end

redef class ANonEmptyLine
	redef fun accept_ast_printer(v: ASTPrinter)
	do
		if n_label_decl == null then v.str += "        "
		visit_all(v)
	end
end

class ASTPrinter
	super Visitor

	var str = ""

	init do end
	redef fun visit(n) do n.accept_ast_printer(self)
end

redef class ALine
	redef fun to_s
	do
		var p = new ASTPrinter
		p.enter_visit( self )
		return p.str
	end
end
