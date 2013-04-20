import cfg
import advanced_collections

class FlowAnalysis[S] # : Collection[Object]]
	super Visitor

	var current_in: S writable = default_in_set
	var current_out: S writable = default_in_set

	fun get_in(bb: BasicBlock): nullable S is abstract
	fun get_out(bb: BasicBlock): nullable S is abstract
	fun set_in(bb: BasicBlock, s: S) is abstract
	fun set_out(bb: BasicBlock, s: S) is abstract

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
					current_in = get_out(block.predecessors.first)
					for l in [1..block.predecessors.length[ do
						var b = block.predecessors[l]
						current_in = merge(current_in.as(not null), get_out(b).as(not null))
					end
				end

				if block.lines.is_empty then
				else
					if current_in != null then
						set_in(block,current_in.as(not null))
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

				var old_out = get_out(block)
				current_out = self.current_out
				if old_out != current_out then
					set_out(block,current_out.as(not null))
					changed_blocks.add(block)
					print "change"
				else
					print "no change"
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
