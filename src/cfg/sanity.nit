module sanity

import cfg_base

redef class BasicBlock
	private var cfg_sanity_verified = false

	private fun verify_cfg_sanity_code(v: Noter)
	do
		for line in lines do
			if line isa ADirectiveLine then
				v.notes.add(new Error(line.location, "Directive in program flow path"))
			end
		end

		cfg_sanity_verified = true
	end

	private fun verify_cfg_sanity_data(v: Noter)
	do
		for line in lines do
			if line isa AInstructionLine then
				v.notes.add(new Error(line.location, "Instruction appears to be unreachable"))
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
