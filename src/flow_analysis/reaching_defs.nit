module reaching_defs

import framework

class ReachingDefsAnalysis
	super FlowAnalysis[ReachingDefsMap]

	init do end

	redef fun visit( node )
	do
		node.accept_reaching_defs_analysis( self, current_in, current_out )
	end
	redef fun merge(a,b) do return a.union(b)

	redef fun get_in(bb) do return bb.reaching_defs_in
	redef fun get_out(bb) do return bb.reaching_defs_out
	redef fun set_in(bb, v) do bb.reaching_defs_in = v
	redef fun set_out(bb, v) do bb.reaching_defs_out = v

	redef fun default_in_set do return new ReachingDefsMap
end

redef class ANode
	fun accept_reaching_defs_analysis(v: ReachingDefsAnalysis, ins: ReachingDefsMap, outs: ReachingDefsMap) do visit_all(v)
end

redef class AInstruction
	redef fun accept_reaching_defs_analysis(v, ins, outs)
	do
		outs.recover_with(ins)
	end
end

redef class ALoadInstruction
	redef fun accept_reaching_defs_analysis(v, ins, outs)
	do
		outs.recover_with(ins)

		var variable = def_var
		if variable != null then
			# kill & gen
			var set = new HashSet[ALine]
			set.add(parent.as(ALine))
			outs[variable] = set
		else
			# TODO top
		end
	end
end

redef class AStoreInstruction
	redef fun accept_reaching_defs_analysis(v, ins, outs)
	do
		outs.recover_with(ins)

		var variable = def_var
		if variable != null then
			# kill & gen
			var set = new HashSet[ALine]
			set.add(parent.as(ALine))
			outs[variable] = set
		else
			# TODO top
		end
	end
end

class ReachingDefsMap
	super HashMap[Var,Set[ALine]]

	fun union(o: ReachingDefsMap): ReachingDefsMap
	do
		var n = new ReachingDefsMap
		for k, v in self do
			n[k] = new HashSet[ALine]
			n[k].add_all(v)
		end
		for k, v in o do
			if not n.has_key(k) then n[k] = new HashSet[ALine]
			n[k].add_all(v)
		end
		return n
	end

	fun intersection(o: ReachingDefsMap): ReachingDefsMap
	do
		var n = new ReachingDefsMap
		for k, v in self do if n.has_key(k) then n[k].add_all(v)
		for k, v in o    do if n.has_key(k) then n[k].add_all(v)
		return n
	end

	redef fun to_s do return join(";", ":")

	redef fun ==(o)
	do
		if o != null and o isa ReachingDefsMap then
			if length != o.length then return false
			for k,v in self do
				if not o.has_key(k) then return false
				var ok = o[k]
				if v.length != ok.length then return false
				for l in v do if not ok.has(l) then return false
			end
			return true
		else
			return false
		end
	end
end

redef class ALine
	var reaching_defs_in: nullable ReachingDefsMap = null
	var reaching_defs_out: nullable ReachingDefsMap = null
end

redef class BasicBlock
	var backup_reaching_defs_in: nullable ReachingDefsMap = null
	var backup_reaching_defs_out: nullable ReachingDefsMap = null

	fun reaching_defs_in: nullable ReachingDefsMap do
		if lines.is_empty then return backup_reaching_defs_in or else new ReachingDefsMap
		return lines.first.reaching_defs_in or else new ReachingDefsMap
	end

	fun reaching_defs_out: nullable ReachingDefsMap do
		if lines.is_empty then return backup_reaching_defs_out or else new ReachingDefsMap
		return lines.last.reaching_defs_out or else new ReachingDefsMap
	end

	fun reaching_defs_in=(v: nullable ReachingDefsMap) do
		if lines.is_empty then
			backup_reaching_defs_in = v
		else
			lines.first.reaching_defs_in = v
		end
	end

	fun reaching_defs_out=(v: nullable ReachingDefsMap) do
		if lines.is_empty then
			backup_reaching_defs_out = v
		else
			lines.last.reaching_defs_out = v
		end
	end

	redef fun dot_node_header do return "{super}-- r defs in = \{{reaching_defs_in.to_s}\}\\l"
	redef fun dot_node_footer: String do return "{super}-- r defs out = \{{reaching_defs_out.to_s}\}\\l"
end

# This is bad.
redef class HashSet[E]
	redef fun to_s do return join(",")
end
