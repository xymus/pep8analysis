import framework
import range

redef class AnalysisManager
	fun do_types_analysis(ast: AListing, cfg: CFG)
	do
		# find types at program init
		var tia = new TypesInitAnalysis(ast)
		tia.analyze(ast)

		# evaluate types with program flow
		var ta = new TypesAnalysis(tia)
		ta.analyze(cfg)

		# check for errors
		var tc = new TypesChecker(ast)
		tc.analyze(ast)
	end
end

# Types 1st step, find state at program load
# one pass over the AST
class TypesInitAnalysis
	super StaticAnalysis[TypesMap]

	var current_line: ALine

	init(prog: AListing)
	do
		super( new TypesMap )
		current_line = prog.n_lines.first
	end
	redef fun visit(node)
	do
		if node isa ALine then current_line = node
		node.accept_types_init_analysis(self, set)
	end
end

# Types 2nd step, evaluate types evolution
# one pass over the AST
class TypesAnalysis
	super FineFlowAnalysis[TypesMap]

	var default_in_set_cache: nullable TypesMap = null
	redef fun default_in_set do
		var n = new TypesMap
		default_in_set_cache.copy_to(n)
		return n
	end

	init(tia: TypesInitAnalysis)
	do
		default_in_set_cache = tia.set
		super
	end

	redef fun visit(node) do node.accept_types_analysis(self, current_in, current_out)

	redef fun merge(a, b) do return a.union(b)

	redef fun backup_in(bb) do return bb.backup_types_in or else new TypesMap
	redef fun backup_out(bb) do return bb.backup_types_out or else new TypesMap
	redef fun backup_in=(bb, v) do bb.backup_types_in = v
	redef fun backup_out=(bb, v) do bb.backup_types_out = v

	redef fun line_in(line) do return line.types_in or else new TypesMap
	redef fun line_out(line) do return line.types_out or else new TypesMap
	redef fun line_in=(line, v) do line.types_in = v
	redef fun line_out=(line, v) do line.types_out = v

	fun verify_change( from, to: Char )
	do
	end
end

# Types 3rd step, verification
# one pass over the AST
class TypesChecker
	super StaticAnalysis[TypesMap]

	var current_line: ALine

	init(prog: AListing)
	do
		super( new TypesMap )
		current_line = prog.n_lines.first
	end
	redef fun visit(node)
	do
		if node isa ALine then current_line = node
		node.accept_types_checker(self)
	end
end

class TypesMap
	type T: Char

	# bits
	#  'u' unset
	#  's' set
	var bs = new HashMap[Char,T]

	# The type can be:
	#  'u' for uninitialized
	#  '0' zeroed
	#  'b' byte
	#  'w' word begin
	#  'W' word end
	#  'c' executable code
	#  'a' ascii

	# registers
	var rs = new HashMap[Char,Array[T]]

	# stack
	var stack = new Array[T]

	# mem
	var mem = new HashMap[Int, T]

	init
	do
		rs['A'] = new Array[T].with_items('u', 'u')
		rs['X'] = new Array[T].with_items('u', 'u')
		bs['N'] = 'u'
		bs['Z'] = 'u'
		bs['V'] = 'u'
		bs['C'] = 'u'
	end

	fun memory(a: Int): T do return mem[a]
	fun memory=(a: Int, v: T) do mem[a] = v

	fun copy_to(o: TypesMap)
	do
		for k,v in rs do for b in [0..1] do o.rs[k][b] = rs[k][b]
		for k,v in bs do o.bs[k] = v
		for f in stack do o.stack.add(f)
		for k, v in mem do o.mem[k] = v
	end

	fun union(o: TypesMap): TypesMap
	do
		var tm = new TypesMap
		for k,v in rs do for b in [0..1] do
			var v1 = tm.rs[k][b]
			var v2 = rs[k][b]
			if v1 == v2 then
				tm.rs[k][b] = v1
			else tm.rs[k][b] = 't'
		end
		for k,v in bs do o.bs[k] = v
		for f in stack do o.stack.add(f)
		for k, v in mem do o.mem[k] = v
		return tm
	end

	redef fun to_s
	do
		var s = "regs:\{{rs.join(":",",")}\}\n"
		s = "{s}bits:\{{bs.join(":",",")}\}\n"
		s = "stack:\{{stack.join(",")}\}\n"
		s = "mem:\{{mem.join(":",",")}\}"
		return s
	end

	redef fun ==(o)
	do
		if o == null or not o isa TypesMap then return false
		for r,v in rs do for i in [0..2[ do if o.rs[r][i] != v[i] then return false

		if stack.length != o.stack.length then return false
		for s in [0..stack.length[ do if o.stack[s] != stack[s] then return false

		for k,v in mem do if not o.mem.has_key(k) or o.mem[k] != v then return false

		return true
	end
end

redef class ALine
	var types_in: nullable TypesMap = null
	var types_out: nullable TypesMap = null
end

redef class BasicBlock
	var backup_types_in: nullable TypesMap = null
	var backup_types_out: nullable TypesMap = null
end

redef class ANode
	fun accept_types_analysis(v: TypesAnalysis, ins: TypesMap, outs: TypesMap) do visit_all(v)
	fun accept_types_init_analysis(v: TypesInitAnalysis, set: TypesMap) do visit_all(v)
	fun accept_types_checker(v: TypesChecker) do visit_all(v)
end

redef class AInstruction
	# does not change the set
	redef fun accept_types_analysis(v, ins, outs)
	do
		ins.copy_to(outs)
	end

	# set the memory for the line as being code
	redef fun accept_types_init_analysis(v, set)
	do
		set.memory(v.current_line.address) = 'c'
	end
end


## Section: directives

redef class AByteDirective
	redef fun accept_types_init_analysis(v, set)
	do
		set.memory(v.current_line.address) = 'b'
	end
end

redef class AWordDirective
	redef fun accept_types_init_analysis(v, set)
	do
		set.memory(v.current_line.address) = 'w'
		set.memory(v.current_line.address+1) = 'W'
	end
end

redef class AAsciiDirective
	redef fun accept_types_init_analysis(v, set)
	do
		# TODO AOperand::data
		#for i in [0..v.data.len[ do
			#set.memory(v.current_line.address+i) = 'a'
		#end
	end
end

redef class AAddrssDirective
	redef fun accept_types_init_analysis(v, set)
	do
		# TODO change
		set.memory(v.current_line.address) = 'b'
	end
end

## Section: other instructions

redef class ALdInstruction
	redef fun accept_types_analysis(v, ins, outs)
	do
		super

		v.verify_change(ins.rs[register][0],'w')
		v.verify_change(ins.rs[register][1],'W')

		outs.rs[register][0] = 'w'
		outs.rs[register][1] = 'W'
	end
end

redef class ALdbyteInstruction
	redef fun accept_types_analysis(v, ins, outs)
	do
		super
		# TODO check sourse isa byte
		outs.rs[register][1] = 'b'
	end
end

redef class AStInstruction
	redef fun accept_types_analysis(v, ins, outs)
	do
		super
		outs.mem[n_operand.n_value.to_i  ] = 'w'
		outs.mem[n_operand.n_value.to_i+1] = 'W'
	end
end

redef class AStbyteInstruction
	redef fun accept_types_analysis(v, ins, outs)
	do
		super
		outs.mem[n_operand.n_value.to_i] = 'b'
	end
end

redef class AShiftInstruction
	redef fun accept_types_analysis(v, ins, outs)
	do
		super
	end
end

redef class AArithmeticInstruction
	redef fun accept_types_checker(v)
	do
		var content = v.current_line.types_in.as(not null).rs[register]
		if content.count('u') == 2 then
			# uninitialized data
			noter.notes.add(new Warn(location, "use of uninitialized values (reg: {content})"))
		else if content[0] == 'W' or content[1] == 'w' then
			noter.notes.add(new Warn(location, "use of deorganized word (reg: {content})"))
		else if (content[0] == 'w' and content[1] != 'W') or (content[1] == 'W' and content[0] != 'w') then
			noter.notes.add(new Warn(location, "use of partial word (reg: {content})"))
		else if content.count('u') == 1 then
			# partially unitialized, a bad sign
			noter.notes.add(new Warn(location, "use of partially uninitialized values (reg: {content})"))
		end
	end
end
