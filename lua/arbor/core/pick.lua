---@class arbor.core.pick.internal
local M = {}

local config = require("arbor.config")
local lib = require("arbor._lib")
local common = require("arbor.core.common")

---@param opts? arbor.opts.pick
function M.pick(opts)
	local git_info = lib.git.info.resolve()
	if not git_info or not git_info.resolved_base then
		lib.notify.error("Failed to resolve repo base")
		return
	end

	opts = vim.tbl_deep_extend("force", config.settings.pick, opts or {})
	-- store the resolved opts in the git_info so the user can use it
	-- in hooks & autocmds

	local actions = config.actions.pick or {}
	---@type arbor.item[]
	local items = {}
	if opts.show_actions then
		items = common.append_actions_to_items(actions)
	end

	local priority_branches, local_branches, remote_branches = lib.git.query.get_branches({
		cwd = lib.path.cwd(),
		pattern = opts.branch_pattern,
		include_remote_branches = opts.show_remote_branches,
	})
	local branches = {}

	for _, branch in ipairs(priority_branches or {}) do
		if branch.worktree_path and string.len(branch.worktree_path) > 0 then
			branches[#branches + 1] = branch
		end
	end

	for _, branch in ipairs(local_branches or {}) do
		if branch.worktree_path and string.len(branch.worktree_path) > 0 then
			branches[#branches + 1] = branch
		end
	end

	for _, branch in ipairs(remote_branches or {}) do
		if branch.worktree_path and string.len(branch.worktree_path) > 0 then
			branches[#branches + 1] = branch
		end
	end

	items = common.add_branches_to_items(branches, items)

	local callback = M.after_ref_selected(opts, git_info)

	local select_opts = vim.tbl_deep_extend("force", {
		prompt = "Pick worktree",
		format_item = common.generate_item_format,
	}, opts.select_opts or {})

	lib.select(items, select_opts, callback)
end

---@param opts arbor.opts.pick
---@param git_info arbor.git.info
---@diagnostic disable-next-line: unused-local
function M.after_ref_selected(opts, git_info)
	return function(item, idx)
		if not item then
			return
		end

		if common.handle_if_action(git_info, item, idx) then
			return
		end

		if item.type == "branch" then
			if not item.branch_info then
				lib.notify.error("Failed to extract branch info from git")
				return
			end
			git_info.branch_info = item.branch_info
		end

		local events = common.get_events("pick", "ArborPick", opts)
		git_info = events.hookpre(git_info) or git_info
		if events.aupre then
			events.aupre(git_info)
		end

		git_info = events.hookpost(git_info) or git_info
		if events.aupost then
			events.aupost(git_info)
		end
	end
end

setmetatable(M, {
	__call = function(_, opts)
		return M.pick(opts)
	end,
})

return M
