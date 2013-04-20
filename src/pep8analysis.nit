module pep8analysis

import backbone
import ast
import model
import cfg
import flow_analysis

redef class AnalysisManager
	var opt_help = new OptionBool("Display this help message", "--help","-h")
	var opt_quiet = new OptionBool("Do not show notes", "--quiet","-q")
	fun quiet: Bool do return opt_quiet.value
	fun verbose: Bool do return not opt_quiet.value

	var opt_output = new OptionString("Output directory", "--output", "-o")

	redef init
	do
		super

		opts.add_option(opt_help)
		opts.add_option(opt_quiet)
		opts.add_option(opt_output)
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

		var dir = opt_output.value
		if dir == null then dir = "out"
		if not dir.file_exists then dir.mkdir

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
		var cfg = build_cfg(model)

		# Run analysis

		## Range
		var range_analysis = new RangeAnalysis
		range_analysis.analyze(cfg)
		var of = new OFStream.open("range.dot")
		cfg.print_dot(of, true)

		## dead code

		## type

		## duplications
	end
end

redef class Object
	redef fun noter do return once new AnalysisManager
end

var manager = noter.as(AnalysisManager)
manager.run
