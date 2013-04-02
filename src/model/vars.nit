module vars

class Var
end

class RegisterVar
	super Var

	var register: Char

	redef fun ==(o) do return o isa RegisterVar and register == o.register
end

class StackVar
	super Var

	var offset: Int

	redef fun ==(o) do return o isa StackVar and offset == o.offset
end

class MemVar
	super Var

	var index: Int

	redef fun ==(o) do return o isa MemVar and index == o.index
end
