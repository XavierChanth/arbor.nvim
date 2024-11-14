---@param info? arbor.git.info
---@return arbor.git.info | nil
local function create_branch_hook(info)
	if not info or not info.branch_info or info.branch_info.refname:find("^refs/remotes/") then
		return
	end
	if not info.new_branch and info.new_path then
		return
	end
	local job = require("arbor.git").job({
		args = { "branch", "-c", info.branch_info.display_name, info.new_branch or info.new_path },
	})
	job:sync()
end

---@param _? arbor.git.info
---@param opts? arbor.opts.add
---@return arbor.git.info | nil
return function(_, opts)
	opts = opts or {}
	opts.path_style = "prompt"
	opts.on_existing = opts.on_existing or false
	if opts.show_actions == nil then
		opts.show_actions = false
	end
	opts.hooks = opts.hooks or {}
	opts.hooks.pre = function(info)
		create_branch_hook(info)
		if opts.hooks.pre then
			info = opts.hooks.pre(info) or info
		end
		return info
	end
	require("arbor").add(opts)
end
