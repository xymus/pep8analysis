module sanity

import cfg_base

redef class BasicBlock
	private var cfg_sanity_verified = false

	private fun verify_cfg_sanity_code(v: Noter)
	do
		var first_wrong_directive: nullable ALine = null
		var last_wrong_directive: nullable ALine = null
		for line in lines do
			if line isa ADirectiveLine then
				if first_wrong_directive == null then first_wrong_directive = line
				last_wrong_directive = line
			else if first_wrong_directive != null then
				# complete block
				if first_wrong_directive == last_wrong_directive then
					v.notes.add(new Error(last_wrong_directive.location, "Data in program flow"))
				else
					v.notes.add(new Error.range(first_wrong_directive.location, last_wrong_directive.location, "Data block in program flow"))
				end

				first_wrong_directive = null
			end
		end

		if first_wrong_directive != null then
			if first_wrong_directive == last_wrong_directive then
				v.notes.add(new Error(last_wrong_directive.location, "Data in program flow"))
			else
				v.notes.add(new Error.range(first_wrong_directive.location, last_wrong_directive.location, "Data block in program flow"))
			end
		end

		cfg_sanity_verified = true
	end

	private fun verify_cfg_sanity_data(v: Noter)
	do
		var first_wrong_instr: nullable ALine = null
		var last_wrong_instr: nullable ALine = null
		for line in lines do
			if line isa AInstructionLine then
				if first_wrong_instr == null then first_wrong_instr = line
				last_wrong_instr = line
			else if first_wrong_instr != null then
				if first_wrong_instr == last_wrong_instr then
					v.notes.add(new Error(last_wrong_instr.location, "Code is unreachable"))
				else
					v.notes.add(new Error.range(first_wrong_instr.location, last_wrong_instr.location, "Code block is unreachable"))
				end

				first_wrong_instr = null
			end
		end

		if first_wrong_instr != null then
			if first_wrong_instr == last_wrong_instr then
				v.notes.add(new Error(last_wrong_instr.location, "Code is unreachable"))
			else
				v.notes.add(new Error.range(first_wrong_instr.location, last_wrong_instr.location, "Code block is unreachable"))
			end
		end

		cfg_sanity_verified = true
	end
end

redef class AnalysisManager
	fun verify_cfg_sanity(cfg: CFG)
	do
		# verify executable code
		verify_cfg_sanity_recursively_code( cfg.start )

		# verify data or dead code
		for b in cfg.blocks do if not b.cfg_sanity_verified then
			b.verify_cfg_sanity_data(self)
		end
	end

	fun verify_cfg_sanity_recursively_code(b: BasicBlock)
	do
		if b.cfg_sanity_verified then return
		b.verify_cfg_sanity_code(self)
		for s in b.successors do verify_cfg_sanity_recursively_code( s )
	end
end
