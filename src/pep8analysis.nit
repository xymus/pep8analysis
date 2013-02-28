module pep8analysis

import backbone
import ast
import model

redef class AnalysisManager

	fun run
	do
		opts.parse(args)
		var files = opts.rest

		if files.length == 0 then
			opts.usage
			return
		end

		# Parsing
		var filename = files.first
		var node_program = build_ast( filename )
		assert node_program != null

		# Build program model
		build_model

		# Create CFG
		# build_cfg

		# Run analysis

		## dead code

		## type

		## duplications
	end
end

var manager = new AnalysisManager
manager.run
