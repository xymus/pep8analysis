import cfg_base

redef class CFG
	fun print_dot( f: OFStream, long: Bool )
	do
		f.write("digraph \{\n")
		f.write("charset=latin1\n")
		f.write("node [shape=box,style=rounded,fontname=courier]\n")
		for block in blocks do block.print_dot_nodes(f, long)
		for block in blocks do block.print_dot_edges(f, long)
		f.write("\}")
	end
end

redef class BasicBlock
	fun print_dot_nodes( f: OFStream, long: Bool )
	do
		var lbl
		if long then
			lbl = "\"{name}:\\n{dot_node_text}\""
		else
			lbl = name
		end
		f.write( "{name} [label={lbl}]\n" )
	end

	fun dot_node_text : String
	do
		var code_lines = new Array[String]
		for line in lines do code_lines.add(line.text)
		var code = code_lines.join("")

		code = code.replace("\n","\\l").replace("\"","\\\"").replace("\\n","|n").replace("/","\\/")
		# the last one is a hack
		return "{dot_node_header}{code}{dot_node_footer}"
	end

	fun dot_node_header: String do return ""
	fun dot_node_footer: String do return ""

	fun print_dot_edges( f: OFStream, long: Bool )
	do
		for s in successors do
			f.write( "{name} -> {s.name}\n" )
		end
		var n = after_call
		if n != null then
				f.write( "{name} -> {n.name} [style=\"dashed\"]\n" )
		end
	end
end
