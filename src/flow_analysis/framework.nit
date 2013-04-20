import cfg
import advanced_collections

class FlowAnalysis[S] # : Collection[Object]]
	super Visitor

	var current_in: S writable = default_in_set
	var current_out: S writable = default_in_set

	fun in_set(bb: BasicBlock): nullable S is abstract
	fun out_set(bb: BasicBlock): nullable S is abstract
	fun in_set=(bb: BasicBlock, s: S) is abstract
	fun out_set=(bb: BasicBlock, s: S) is abstract

	redef fun visit( node ) do node.visit_all(self)

	# If false, it is a backwards analysis
	fun is_forwards: Bool is abstract

	# ex: do return in1.union( in2 )
	# ex: do return in1.intersection( in2 )
	fun merge( in1, in2: S): S is abstract

	fun default_in_set: S is abstract

	fun analyze(cfg: CFG)
	do
		# set defaults
		var current_in: nullable S
		var current_out: nullable S

		# set current input as default start case
		var changed_blocks: Set[BasicBlock]

		# iterate until fixed point reached
		loop
			changed_blocks = new HashSet[BasicBlock]

			# iterate over all blocks
			for block in cfg.blocks do
				if block.predecessors.is_empty then
					# get default in (the most safe one)
					current_in = default_in_set
				else
					current_in = out_set(block.predecessors.first)
					for l in [1..block.predecessors.length[ do
						var b = block.predecessors[l]
						current_in = merge(current_in.as(not null), out_set(b).as(not null))
					end
				end

				if block.lines.is_empty then
				else
					if current_in != null then
						in_set(block) = current_in.as(not null)
					end

					for line in block.lines do
						self.current_in = current_in.as(not null)
						self.current_out = default_in_set # TODO change
						pre_line_visit(line)
						enter_visit(line)
						post_line_visit(line)
						current_out = self.current_out
						current_in = self.current_out
						#self.current_in = current_in
					end
				end

				var old_out = out_set(block)
				current_out = self.current_out
				if old_out != current_out then
					out_set(block) = current_out.as(not null)
					changed_blocks.add(block)
					#print "out changed"
				else
					#print "out not changed"
				end
			end

			#	limit -= 1
			#if changed_blocks.is_empty or limit <= 0 then break
			if changed_blocks.is_empty then break
		end
	end

	fun pre_line_visit(l: ALine) do end
	fun post_line_visit(l: ALine) do end
end
