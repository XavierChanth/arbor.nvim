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
	opts = vim.tbl_deep_extend("force", require("arbor.config").config.settings.add, {
		on_existing = false,
		show_actions = false,
		hooks = {},
		branch_style = "prompt",
		path_style = "branch",
	}, opts or {})

	if
		not opts.branch_style == "prompt"
		and not opts.path_style == "prompt"
		and not type(opts.branch_style) == "function"
		and not type(opts.path_style) == "function"
	then
		require("arbor._lib.notify").error(
			'One of branch_style or path_style must be set to "prompt" or a function to use the add_new_branch action'
		)
		return
	end

	-- Cache the hook in the closure to prevent infinite recursion
	local pre_hook
	if opts.hooks.pre then
		pre_hook = opts.hooks.pre
	end

	opts.hooks.pre = function(info)
		create_branch_hook(info)
		if pre_hook then
			info = pre_hook(info) or info
		end
		return info
	end
	require("arbor").add(opts)
end
