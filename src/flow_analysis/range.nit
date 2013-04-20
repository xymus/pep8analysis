module range

import framework

# for linex, and should be used in the future
import reaching_defs

class RangeAnalysis
	super FlowAnalysis[RangeMap]

	var current_range: nullable ValRange = null

	init do end

	redef fun visit(node)
	do
		node.accept_range_analysis(self,
			current_in, current_out)
	end
	redef fun merge(a, b)
	do
		var n = new RangeMap
		for k, v in a do
			if b.has_key(k) then
				# merge ranges
				var u = b[k]
				n[k] = new ValRange(v.min.min(u.min), v.max.max(u.max))
			else
				n[k] = v
			end
		end

		for k, v in b do
			if not n.has_key(k) then
				n[k] = v
			end
		end

		return n
	end

	redef fun in_set(bb) do return bb.ranges_in or else new RangeMap
	redef fun out_set(bb) do return bb.ranges_out or else new RangeMap
	redef fun in_set=(bb, s) do bb.ranges_in = s
	redef fun out_set=(bb, s) do bb.ranges_out = s

	redef fun default_in_set do return new RangeMap #HashMap[String, ValRange]
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
end

redef class ANode
	fun accept_range_analysis(v: RangeAnalysis,
		ins, outs: RangeMap) do visit_all(v)
end

redef class AInstruction
	redef fun accept_range_analysis(v, ins, outs)
	do
			#super
		outs.recover_with(ins)
	end
end

redef class ALoadInstruction
	redef fun accept_range_analysis(v, ins, outs)
	do
		visit_all(v)
		#super

		outs.recover_with(ins)
		var variable = def_var
		#var add = new RangeMap[Var, ValRange](variable,

		# kill every set for variable
		# (is automatic by HashMap)

		if variable != null then
			# gen (&kill)
			outs[variable] = v.current_range.as(not null)
		else
			# TODO top!
		end
		v.current_range = null
	end
end

redef class AOperand
	redef fun accept_range_analysis(v, ins, outs)
	do
		v.current_range = new ValRange(n_value.to_i, n_value.to_i)
	end
end
