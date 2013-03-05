import ast

redef class AValue
	fun to_i: Int is abstract
end

redef class ALabelValue
	redef fun to_i do return n_id.labels_to_address[n_id.text]
end
redef class TId
	var labels_to_address: HashMap[String,Int] = (once new HashMap[String,Int])
	#redef fun to_i: Int do return label_to_address[text]
end

redef class ANumberValue
	redef fun to_i do return n_number.text.to_i
end

redef class ACharValue
	redef fun to_i do return n_char.content.first.ascii
end

redef class AStringValue
	# legal but no not recommended
	redef fun to_i do return n_string.content.first.ascii
end

redef class AHexValue
	#TODO
	#redef fun to_i return n_number.text.to_i
end

redef class TString # TkBlock
	fun content : String
	do
		return text.substring(1, text.length-2)
	end
end
redef class TChar # TkAscii
	fun content : String
	do
		return text.substring(1, text.length-2)
	end
end
