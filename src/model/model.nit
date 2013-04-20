import backbone
import ast

import directives
import operands
import vars

redef class AnalysisManager
	fun build_model(ast: AListing): Model
	do
		var model = new Model(ast)
		return model
	end
end

class Model
	# lines to appear on the resulting program
	var lines = new Array[ANonEmptyLine]

	# labet to declaation line
	var labels_to_line = new HashMap[String,ALine]
	var labels_to_address = new HashMap[String,Int]

	# from adress to line
	var address_to_line = new HashMap[Int,ANonEmptyLine]

	init (ast: AListing)
	do
		var offset = 0
		for line in ast.n_lines do
			# TODO if directive = equate
			var label_decl = line.n_label_decl
			if label_decl != null then
				var lbl = label_decl.n_id
				var label_name = lbl.text
				labels_to_address[label_name] = offset
				lbl.labels_to_address[label_name] = offset
			end

			line.address = offset
			if line isa ANonEmptyLine then
				lines.add( line )
				address_to_line[offset] = line
			end
			offset += line.size
		end

		for lbl,address in labels_to_address do
			var line = address_to_line[address]
			labels_to_line[lbl] = line
		end
	end
end

redef class ALine
	var address: Int = -1
	fun size: Int is abstract
end
redef class AInstructionLine
	redef fun size do return 4
end
redef class ADirectiveLine
	redef fun size do return n_directive.size
end
redef class AEmptyLine
	redef fun size do return 0
end
