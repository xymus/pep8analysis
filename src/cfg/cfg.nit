import cfg_base
import dot_printer

redef class AnalysisManager
	var opt_cfg = new OptionBool("Print the CFG", "--cfg")
	var opt_cfg_long = new OptionBool("Print the long format CFG", "--cfg-long")

	#var opt_cfg_inline = new OptionBool("Inline function calls in the CFG", "--inline-fun")
	var opt_cfg_not_inline = new OptionBool("Do not inline function calls in the CFG", "--no-inline")

	redef init
	do
		super

		opts.add_option(opt_cfg)
		opts.add_option(opt_cfg_long)
		opts.add_option(opt_cfg_not_inline)
	end

	redef fun build_cfg(ast)
	do
		var cfg = super

		if not opt_cfg_not_inline.value then
			cfg.inline_functions
		else
			var to_link = new List[BasicBlock]
			cfg.link_ret_to_calls(cfg.start, to_link, 0)
		end

		if opt_cfg.value or opt_cfg_long.value then
			var of = new OFStream.open("cfg.dot")
			cfg.print_dot(of, opt_cfg_long.value)
		end

		return cfg
	end
end
