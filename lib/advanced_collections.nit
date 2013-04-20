module advanced_collections

redef class HashSet[V]
	fun union( other : HashSet[V] ) : HashSet[V]
	do
		var nhs = new HashSet[V]
		nhs.add_all( self )
		nhs.add_all( other )
		return nhs
	end

	fun intersection( other : HashSet[V] ) : HashSet[V]
	do
		var nhs = new HashSet[V]
		for v in self do if other.has(v) then nhs.add(v)
		return nhs
	end
end
