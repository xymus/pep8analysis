module range

import framework

# for linex, and should be used in the future
import reaching_defs

redef class AnalysisManager
	fun run_range_analysis(ast: AListing, cfg: CFG)
	do
		var range_init_analysis = new InitRangeAnalysis(ast)
		range_init_analysis.analyze(ast)

		var range_analysis = new RangeAnalysis(range_init_analysis.set)
		range_analysis.analyze(cfg)
	end
end

class RangeAnalysis
	super FlowAnalysis[RangeMap]

	var current_range: nullable ValRange = null
	var current_var: nullable Var = null

	var default_in_set_cache: RangeMap
	redef fun default_in_set do return default_in_set_cache.copy

	init(default_in: RangeMap)
	do
		default_in_set_cache = default_in

		super
	end

	redef fun visit(node)
	do
		node.accept_range_analysis(self,
			current_in, current_out)
	end

	# union
	redef fun merge(a, b)
	do
		var n = new RangeMap
		for k, v in a do
			if b.has_key(k) then
				# merge ranges
				var u = b[k]
				n[k] = new ValRange(v.min.min(u.min), v.max.max(u.max))
			end
		end

		return n
	end

	redef fun in_set(bb) do return bb.ranges_in or else new RangeMap
	redef fun out_set(bb) do return bb.ranges_out or else new RangeMap
	redef fun in_set=(bb, s) do bb.ranges_in = s
	redef fun out_set=(bb, s) do bb.ranges_out = s
end

class InitRangeAnalysis
	super StaticAnalysis[RangeMap]

	var current_line: ALine

	init(prog: AListing)
	do
		super( new RangeMap )
		current_line = prog.n_lines.first
	end
	redef fun visit(node)
	do
		if node isa ALine then current_line = node
		node.accept_init_range_analysis(self, set)
	end
end

redef class BasicBlock
	var ranges_in: nullable RangeMap = null
	var ranges_out: nullable RangeMap = null

	redef fun dot_node_header
	do
		if ranges_in != null then
			return "{super}-- ranges in = \{{ranges_in.join(", ", ":")}\}\\l"
		else return super
	end
	redef fun dot_node_footer
	do
		if ranges_out != null then
			return "{super}-- ranges out = \{{ranges_out.join(", ", ":")}\}\\l"
		else return super
	end
end

class ValRange
	var min: Int
	var max: Int
	init(min, max: Int)
	do
		self.min = min
		self.max = max
	end

	redef fun to_s do
		if min == max then return min.to_s
		return "[{min}..{max}]"
	end

	redef fun ==(o) do return o != null and o isa ValRange and
		min == o.min and max == o.max
end
class RangeMap
	super HashMap[Var, ValRange]
	redef fun ==(o)
	do
		if o == null or not o isa RangeMap then return false
		if o.length != length then return false

		for k, v in self do if not o.has_key(k) or o[k] != v then return false

		return true
	end

	fun copy: RangeMap
	do
		var c = new RangeMap
		c.recover_with(self)
		return c
	end
end

redef class ANode
	fun accept_range_analysis(v: RangeAnalysis,
		ins, outs: RangeMap) do visit_all(v)
	fun accept_init_range_analysis(v: InitRangeAnalysis,
		set: RangeMap) do visit_all(v)
end

redef class AInstruction
	redef fun accept_range_analysis(v, ins, outs)
	do
		visit_all(v)
		outs.recover_with(ins)
	end
end

redef class ALoadInstruction
	redef fun accept_range_analysis(v, ins, outs)
	do
		visit_all(v)

		outs.recover_with(ins)
		var variable = def_var
		#var add = new RangeMap[Var, ValRange](variable,

		# kill every set for variable
		# (is automatic by HashMap)

		if variable != null then
			# gen (&kill)
			var cr = v.current_range
			if cr != null then
				outs[variable] = cr
			else
				outs.remove(variable)
			end
		end
		v.current_range = null
	end
end

redef class AStoreInstruction
	redef fun accept_range_analysis(v, ins, outs)
	do
		visit_all(v)

		outs.recover_with(ins)
		var src = src_var # reg
		var def = def_var # mem

		if def != null then
			if src != null and ins.has_key(src) then # we know the source and dest
				print "{self.location} st {def}"
				var cr = ins[src]
				outs[def] = cr
			else
				outs.remove(def)
			end
		end
	end
end

redef class AAnyOperand
	redef fun accept_range_analysis(v, ins, outs)
	do
		if addressing_mode == "i" then # immediate
			v.current_var = null
			v.current_range = new ValRange(n_value.to_i, n_value.to_i)
			return
		else if addressing_mode == "d" then # direct
			var ci = v.current_in
			var address = n_value.to_i
			var variable = new MemVar(address)
			v.current_var = variable
			if ci.has_key(variable) then
				var value = ci[variable]
				v.current_range = new ValRange(value.min, value.max)
				return
			end
		end

		v.current_range = null
	end
end

redef class AWordDirective
	redef fun accept_init_range_analysis(v, set)
	do
		var variable = new MemVar(v.current_line.address)
		var value = new ValRange(n_value.to_i, n_value.to_i)
		set[variable] = value
	end
end

