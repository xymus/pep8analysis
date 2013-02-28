module pep8analysis

import parser
import opts

var opts = new OptionContext
opts.parse(args)

var files = opts.rest

if files.length > 0 then
	var filename = files.first
	var file = new IFStream.open( filename )

	var source = new SourceFile(filename, file)
	var lexer = new Lexer(source)
	var parser = new Parser(lexer)
	var node_tree = parser.parse
	if node_tree.n_base == null then
		var err = node_tree.n_eof
		assert err isa AError
		print "error at {err.location}: {err.message}"
	end

	var node_module = node_tree.n_base
	assert node_module != null
end
