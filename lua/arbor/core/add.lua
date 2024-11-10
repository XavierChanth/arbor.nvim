---@class arbor.core.add
local M = {}

setmetatable(M, {
	__call = function(...)
		M.add(...)
	end,
})

local dep_modules = {
	select = "arbor.lib.select",
	notify = "arbor.lib.notify",
	input = "arbor.lib.input",
	git_remote = "arbor.lib.remote",
	git_branch = "arbor.lib.branch",
	git_origin = "arbor.lib.origin",
	path = "arbor.lib.path",
	common = "arbor.core.common",
	config = "arbor.config",
}

local d = {}

setmetatable(d, {
	__index = function(_, k)
		return require(dep_modules[k])
	end,
})

---@param opts arbor.core.add_opts
function M.add(opts)
	local base_spec = require("arbor.lib.base").resolve()
	if not base_spec or not base_spec.resolved_base then
		d.notify.error("Failed to resolve repo base")
		return
	end

	---@type arbor.core_item[]
	local actions = d.config.actions.add or {}
	local items = d.common.append_actions_to_items(actions, d.config.actions.prefix)

	-- append actions
	local include_remote_branches = opts.show_remote_branches--[[@as boolean]]
	if opts.show_remote_branches == nil then
		include_remote_branches = d.config.settings.add.show_remote_branches
	end

	local branches, local_branches, remote_branches = d.git_branch.get_branches({
		cwd = d.path.cwd(),
		include_remote_branches = include_remote_branches,
		pattern = opts.branch_pattern,
	})

	-- TODO allow the user to opt out of this
	for _, branch in ipairs(local_branches) do
		branches[#branches + 1] = branch
	end

	for _, branch in ipairs(remote_branches) do
		branches[#branches + 1] = branch
	end

	P(branches)
	items = d.common.add_branches_to_items(branches, items)

	d.picker.select(items, {
		prompt = "Add worktree",
		format_item = d.common.generate_item_format,
	}, M.item_selected(opts, base_spec))
end -- end of add

function M.item_selected(opts, base_spec)
	return function(item, idx)
		if not d.common.handle_if_action(base_spec, item, idx) then
			return
		end

		if item.type == "branch" then
			if not item.branch_info then
				d.notify.error("Failed to extract branch info from git")
				return
			end
		end

		if item.branch_info.worktreepath and string.len(item.branch_info.worktreepath) > 0 then
			if opts.switch_if_wt_exists then
				-- TODO: switch instead of add
				vim.print("TODO: auto switch")
				return
			end
		end

		M.create_worktree(opts, base_spec, item)
	end
end

function M.create_worktree(opts, base_spec, item)
	if opts.name_branch == "smart" then
		local remotes = d.git_origin.list_remotes({
			cwd = base_spec.common_dir,
		}) or {}
		local found = false
		for _, remote in ipairs(remotes) do
			if base_spec.branch_info.display_name:find("^" .. remote) then
				base_spec.new_branch = base_spec.branch_info.display_name:sub(#remote + 1)
				found = true
				break
			end
		end
		if not found then
			opts.name_branch = "same"
		end
	end
	if opts.name_branch == "same" then
		base_spec.new_branch = base_spec.branch_info.display_name
	elseif type(opts.name_branch) == "function" then
		local branches = d.git_branch.get_local_working_branches({ cwd = base_spec.common_dir })
		base_spec.new_branch = opts.name_branch(base_spec, branches)
	elseif opts.name_branch == "prompt" then
		base_spec.new_branch = d.input.synchronize({
			prompt = "Name local branch",
		})
	end

	local events = d.common.get_events("add", "ArborAdd")
	P({
		base_spec,
		item,
	})
end

return M
