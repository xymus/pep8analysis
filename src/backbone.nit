import opts

import parser

class AnalysisManager
	var opts = new OptionContext

	var main_notes = new Array[Note]
	var notes = new Array[Note]
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
