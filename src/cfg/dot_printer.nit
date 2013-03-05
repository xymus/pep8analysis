import cfg_base

#redef class AnalysisManager
		#end

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
		var artp = new ASTPrinter
		for line in lines do
			artp.enter_visit( line )
		end
		var code = artp.str
		code = code.replace("\n","\\l").replace("\"","\\\"").replace("\\n","\\\\n")
		return code
	end

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
