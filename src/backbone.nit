import opts

import parser

class AnalysisManager
	super Noter
	var opts = new OptionContext

	init do end
end

abstract class Noter
	var notes = new Array[Note]

	var failed = false

	fun print_notes
	do
		if not notes.is_empty then
			print "# Notes:"
			for n in notes do print n
		end
	end

	fun fatal_error(n: nullable ANode, msg: String)
	do
		var loc = null
		if n != null then loc = n.location
		notes.add( new Fatal(loc, msg) )
		failed = true
	end

	fun reset
	do
		failed = false
	end
end

abstract class Note
	var line: nullable Location
	var to: nullable Location = null
	var msg: String

	init (line: nullable Location, msg: String)
	do
		self.line = line
		self.msg = msg
	end
	init range(from, to: Location, msg: String)
	do
		self.line = from
		self.to = to
		self.msg = msg
	end

	fun prefix: String is abstract
	redef fun to_s do
		var s = ""
		var line = line
		var to = to
		if line != null then
			if to != null then
				s += " from {line} to {to}"
				s = "{line.to_file_s}:{line.to_line_s}--{to.to_line_s}; "
			else
				s = "{line.to_file_s}:{line.to_line_s}; "
			end
		end
		return "{prefix}{s}{msg}"
	end
end

class Warn
	super Note
	init (line: nullable Location, msg: String) do super
	init range(from, to: Location, msg: String) do super
	redef fun prefix do return "Warning: "
end

class Error
	super Note
	init (line: nullable Location, msg: String) do super
	init range(from, to: Location, msg: String) do super
	redef fun prefix do return "Error:   "
end

class Fatal
	super Note
	init (line: nullable Location, msg: String) do super
	init range(from, to: Location, msg: String) do super
	redef fun prefix do return "Fatal:   "
end

redef class Object
	protected fun noter: Noter is abstract
end

redef class Location
	# "line 5"
	fun to_line_s: String
	do
		return line_start.to_s
	end

	fun to_file_s: String
	do
		return file.filename
	end
end
