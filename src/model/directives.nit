import ast

import operands

redef class ADirective
	fun size: Int is abstract
end
redef class AByteDirective
	redef fun size do return 1
end
redef class AWordDirective
	redef fun size do return 2
end
redef class ABlockDirective
	redef fun size do return n_value.to_i
end
redef class AAsciiDirective
	redef fun size do return n_value.as(AStringValue).n_string.content.length
end
redef class AAddrssDirective
	redef fun size do return 2
end
redef class AEquateDirective
	redef fun size do return 0 # TODO what is this?
end

