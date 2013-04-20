import opts

import parser

class AnalysisManager
	super Noter
	var opts = new OptionContext

	init do end
end

abstract class Noter
	var main_notes = new Array[Note]
	var notes = new Array[Note]

	var failed = false

	fun print_notes
	do
		if not main_notes.is_empty then
			print "# Main notes:"
			for n in main_notes do print n
		end
		if not notes.is_empty then
			if not main_notes.is_empty then
				print "# Notes:"
			else
				print "# Other notes:"
			end
			for n in notes do print n
		end
	end

	fun fatal_error(n: ANode, msg: String)
	do
		notes.add( new Fatal(n.location, msg) )
		failed = true
	end

	fun reset
	do
		failed = false
	end
end

abstract class Note
	var line: nullable Location
	var msg: String

	fun prefix: String is abstract
	redef fun to_s do
		var s = "{prefix}{msg}"
		var line = line
		if line != null then s += " at {line}"
		return s
	end
end

class Warn
	super Note
	redef fun prefix do return "Warning: "
end

class Error
	super Note
	redef fun prefix do return "Error:   "
end
