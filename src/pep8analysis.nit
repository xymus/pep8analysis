module pep8analysis

import backbone
import ast
import model

redef class AnalysisManager
	var opt_help = new OptionBool("Display this help message", "--help","-h")

	redef init
	do
		super

		opts.add_option(opt_help)
	end

	fun run
	do
		opts.parse(args)
		var files = opts.rest

		if files.length != 1 or opt_help.value then
			print "Usage: {sys.program_name} [options] file.pep"
			print "Options:"
			opts.usage
			return
		end

		# Parsing
		var filename = files.first
		if not filename.file_exists then
				print "Target file \"{filename}\" does not exist."
				exit 1
		end
		var ast = build_ast( filename )
		assert ast != null

		# check instructions and directives
		## check if directive values overflow from type

		# Build program model
		var model = build_model(ast)

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
