import pipeline

import framework
import range

redef class AnalysisManager
	fun do_types_analysis(ast: AListing, cfg: CFG)
	do
		# find types at program init
		var tia = new TypesInitAnalysis(ast)
		tia.analyze(ast)

		# evaluate types with program flow
		cfg.start.backup_types_out = tia.set
		var ta = new TypesAnalysis
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

	redef fun empty_set do return new TypesMap
	redef fun is_forward do return true

	init do super

	redef fun visit(node) do node.accept_types_analysis(self, current_in, current_out.as(not null))

	redef fun merge(a, b)
	do
		if a == null then return b
		if b == null then return a
		return a.union(b)
	end

	redef fun backup_in(bb) do return bb.backup_types_in
	redef fun backup_out(bb) do return bb.backup_types_out
	redef fun backup_in=(bb, v) do bb.backup_types_in = v
	redef fun backup_out=(bb, v) do bb.backup_types_out = v

	redef fun line_in(line) do return line.types_in
	redef fun line_out(line) do return line.types_out
	redef fun line_in=(line, v) do line.types_in = v
	redef fun line_out=(line, v) do line.types_out = v
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
	#  'A' address

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

	fun memory(a: Int): T
	do
		if mem.has_key(a) then return mem[a]
		return 'u'
	end
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
			var v1 = o.rs[k][b]
			var v2 = rs[k][b]
			if v1 == v2 then
				tm.rs[k][b] = v1
			else tm.rs[k][b] = 't'
		end

		for k,v in bs do o.bs[k] = v
		for f in stack do o.stack.add(f)

		for k, v in mem do if o.mem.has_key(k) then
			if v == o.mem[k] then
				tm.mem[k] = v
			else tm.mem[k] = 't'
		else tm.mem[k] = 't'
		for k, v in o.mem do if not tm.mem.has_key(k) then
			tm.mem[k] = 't'
		end
		return tm
	end

	redef fun to_s
	do
		var s = "regs:\{{rs.join(",",":")}\}, "
		#s = "{s}bits:\{{bs.join(",",":")}\}, "
		#s = "{s}stack:\{{stack.join(",")}\}, "

		var blocks = new Array[String]
		var block_begin: nullable Int = null
		var block_end = 0
		var block_type = ' '
		for a in mem.keys.to_a.sort_filter do
			var t = mem[a]
			if block_begin != null and block_type != t then
				if block_begin == block_end then
					blocks.add("{block_begin}:{block_type}")
				else blocks.add("[{block_begin}..{block_end}]:{block_type}")
				block_begin = null
			end

			if block_begin == null then block_begin = a

			block_type = t
			block_end = a
		end
		if block_begin != null then
			if block_begin == block_end then
				blocks.add("{block_begin}:{block_type}")
			else blocks.add("[{block_begin}..{block_end}]:{block_type}")
		end
		s = "{s}mem:\{{blocks.join(",")}\}"

		return s
	end

	redef fun ==(o)
	do
		if o == null or not o isa TypesMap then return false
		for r,v in rs do for i in [0..2[ do if o.rs[r][i] != v[i] then return false

		if stack.length != o.stack.length then return false
		for s in [0..stack.length[ do if o.stack[s] != stack[s] then return false

		if mem.length != o.mem.length then return false
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

	redef fun dot_node_header
	do
		if lines.is_empty then
			if backup_types_in != null then
				return "{super}-- types = \{{backup_types_in.to_s}\}\\l"
			end
		else if lines.first.types_in != null then return  "{super}-- types = \{{lines.first.types_in.to_s}\}\\l"
		return super
	end
	redef fun dot_node_footer
	do
		if lines.is_empty then
			if backup_types_out != null then
				return "{super}-- types = \{{backup_types_out.to_s}\}\\l"
			end
		else if lines.first.types_out != null then return  "{super}-- types = \{{lines.last.types_out.to_s}\}\\l"
		return super
	end
end

redef class ANode
	fun accept_types_analysis(v: TypesAnalysis, ins: nullable TypesMap, outs: TypesMap) do visit_all(v)
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
		for i in [0..4[ do set.memory(v.current_line.address+i) = 'c'
	end

	fun verify_word(content: Array[Char], mem_str: String)
	do
		if content.count('u') == 2 then
			# uninitialized data
			noter.notes.add(new Warn(location, "use of uninitialized values ({mem_str}: {content})"))
		else if content[0] == 'W' or content[1] == 'w' then
			noter.notes.add(new Warn(location, "use of deorganized word ({mem_str}: {content})"))
		else if (content[0] == 'w' and content[1] != 'W') or (content[1] == 'W' and content[0] != 'w') then
			noter.notes.add(new Warn(location, "use of partial word ({mem_str}: {content})"))
		else if content.count('u') == 1 then
			# partially unitialized, a bad sign
			noter.notes.add(new Warn(location, "use of partially uninitialized values ({mem_str}: {content})"))
		else if content[0] == '0' and content[1] == 'b' then # OK!
		else if content[0] == '0' and content[1] == '0' then # OK!
		else if content[0] != 'w' and content[1] != 'W' then
			noter.notes.add(new Warn(location, "expected word ({mem_str}: {content})"))
		end
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
		set.memory(v.current_line.address) = 'a'
		#end
	end
end

redef class AAddrssDirective
	redef fun accept_types_init_analysis(v, set)
	do
		set.memory(v.current_line.address) = 'A'
	end
end

## Section: other instructions

redef class ALdInstruction
	redef fun accept_types_analysis(v, ins, outs)
	do
		super

		if parent.as(ALine).address == 8 then print "{ins.to_s} r{register}"

		var op = n_operand
		if op isa AAnyOperand and op.addressing_mode == "i" and
		   op.n_value.to_i == 0 then
			outs.rs[register][0] = '0'
			outs.rs[register][1] = '0'
			return
		end

		var mem = mem_var
		if mem isa MemVar then
			var content = [ins.memory(mem.index), ins.memory(mem.index+1)]
			#verify_word(content, "m{mem.index}")
			outs.rs[register][0] = content[0]
			outs.rs[register][1] = content[1]
			#outs.rs[register][0] = 'w'

			if parent.as(ALine).address == 8 then print "bub"

			#outs.rs[register][1] = 'W'
		else
			if parent.as(ALine).address == 8 then print "mem not MemVar {mem == null}"
		end

		if parent.as(ALine).address == 8 then print outs
	end
end

redef class ALdbyteInstruction
	redef fun accept_types_analysis(v, ins, outs)
	do
		super
		# outs.rs[register][1] = 'b'
		var mem = mem_var
		if mem isa MemVar then
			var content = ins.memory(mem.index)
			#verify_word(content, "m{mem.index}")
			outs.rs[register][1] = content
		end
	end
end

redef class AStInstruction
	redef fun accept_types_analysis(v, ins, outs)
	do
		super
		#outs.mem[n_operand.n_value.to_i  ] = 'w'
		#outs.mem[n_operand.n_value.to_i+1] = 'W'
		var mem = mem_var
		if mem isa MemVar then
			var content = ins.rs[register]
			outs.mem[n_operand.n_value.to_i  ] = content[0]
			outs.mem[n_operand.n_value.to_i+1] = content[1]
		end
	end
end

redef class AStbyteInstruction
	redef fun accept_types_analysis(v, ins, outs)
	do
		super
		#outs.mem[n_operand.n_value.to_i] = 'b'
		var mem = mem_var
		if mem isa MemVar then
			var content = ins.rs[register]
			outs.mem[n_operand.n_value.to_i] = content[1]
		end
	end
end

redef class AShiftInstruction
	redef fun accept_types_analysis(v, ins, outs)
	do
		super
	end
end

redef class AArithmeticInstruction
	redef fun accept_types_analysis(v, ins, outs)
	do
		super
		outs.rs[register][0] = 'w'
		outs.rs[register][1] = 'W'
	end

	redef fun accept_types_checker(v)
	do
		var ins = v.current_line.types_in
		if ins == null then return

		# register
		var content = ins.rs[register]
		verify_word(content, "r{register}")

		# memory source
		var mem = mem_var
		if mem isa MemVar then
			content = [ins.memory(mem.index), ins.memory(mem.index+1)]
			verify_word(content, "m{mem.index}")
		end
	end
end

redef class ADecoInstruction
	redef fun accept_types_checker(v)
	do
		var ins = v.current_line.types_in
		if ins == null then return

		var mem = mem_var
		if mem isa MemVar then
			var content = [ins.memory(mem.index), ins.memory(mem.index+1)]
			verify_word(content, "m{mem.index}")
		end
	end
end

redef class ADeciInstruction
	redef fun accept_types_analysis(v, ins, outs)
	do
		super
		outs.mem[n_operand.n_value.to_i  ] = 'w'
		outs.mem[n_operand.n_value.to_i+1] = 'W'
	end
end

redef class AOutputInstruction
	fun verify_ascii(content: Char)
	do
		if content == 'u' then
			noter.notes.add(new Warn(location, "use of uninitialized values"))
		else if content != 'a' then
			noter.notes.add(new Warn(location, "use of non-ascii types ({content})"))
		end
	end
end

redef class ACharoInstruction
	redef fun accept_types_checker(v)
	do
		var ins = v.current_line.types_in
		if ins == null then return

		var mem = mem_var
		if mem isa MemVar then
			var content = ins.memory(mem.index)
			verify_ascii(content)
		end
	end
end

redef class AStroInstruction
	redef fun accept_types_checker(v)
	do
		var ins = v.current_line.types_in
		if ins == null then return

		var mem = mem_var
		if mem isa MemVar then
			var content = ins.memory(mem.index)
			verify_ascii(content)
		end
	end
end

redef class AChariInstruction
	redef fun accept_types_analysis(v, ins, outs)
	do
		super
		outs.mem[n_operand.n_value.to_i] = 'a'
	end
end

redef class ABranchInstruction
	redef fun accept_types_checker(v)
	do
		var ins = v.current_line.types_in
		if ins == null then return

		var mem = mem_var
		if mem isa MemVar then
			var content = ins.memory(mem.index)
			if content != 'A' then
				noter.notes.add(new Warn(location, "use of non-address data for branching, got: {content}"))
			end
		end
	end
end
