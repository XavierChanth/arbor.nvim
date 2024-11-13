---@param _? arbor.git.info
---@param opts? arbor.opts.add
---@return arbor.git.info | nil
return function(_, opts)
	opts = opts or {}
	opts.path_style = "prompt"
	if opts.show_actions == nil then
		opts.show_actions = false
	end
	require("arbor").add(opts)
end
