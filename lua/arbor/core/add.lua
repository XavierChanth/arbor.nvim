---@class arbor.core.add
local M = {}

setmetatable(M, {
	__call = function(...)
		M.add(...)
	end,
})

local config = require("arbor.config")
local lib = require("arbor.lib")
local common = require("arbor.core.common")

---@param opts? arbor.opts.add
function M.add(opts)
	local git_info = lib.git.info.resolve()
	if not git_info or not git_info.resolved_base then
		lib.notify.error("Failed to resolve repo base")
		return
	end

	opts = vim.tbl_deep_extend("force", config.settings.add, opts or {})

	local actions = config.actions.add or {}
	---@type arbor.item[]
	local items = common.append_actions_to_items(actions)

	local include_remote_branches = opts.show_remote_branches--[[@as boolean]]
	if opts.show_remote_branches == nil then
		include_remote_branches = config.settings.add.show_remote_branches
	end

	local branches, local_branches, remote_branches = lib.git.query.get_branches({
		cwd = lib.path.cwd(),
		include_remote_branches = include_remote_branches,
		pattern = opts.branch_pattern,
	})

	for _, branch in ipairs(local_branches or {}) do
		branches[#branches + 1] = branch
	end

	for _, branch in ipairs(remote_branches or {}) do
		branches[#branches + 1] = branch
	end

	items = common.add_branches_to_items(branches, items)

	lib.select(items, {
		prompt = "Add worktree",
		format_item = common.generate_item_format,
	}, M.item_selected(opts, git_info, local_branches or {}))
end -- end of add

---@param opts arbor.opts.add
---@param git_info arbor.git.info
---@param local_branches arbor.git.branch[]
function M.item_selected(opts, git_info, local_branches)
	return function(item, idx)
		if not common.handle_if_action(git_info, item, idx) then
			return
		end

		if item.type == "branch" then
			if not item.branch_info then
				lib.notify.error("Failed to extract branch info from git")
				return
			end
			git_info.branch_info = item.branch_info
		end

		-- FIXME: this if is being skipped
		if item.branch_info.worktreepath and string.len(item.branch_info.worktreepath) > 0 then
			if opts.switch_if_wt_exists then
				-- TODO: switch instead of add
				vim.print("TODO: auto switch")
			end
			return
		end

		-- TODO: once "smart" is working, make basename it's own type
		if opts.path_style == "smart" then
			git_info.new_path = vim.fs.basename(git_info.branch_info.display_name)
			-- TODO: fix this version of smart
			-- local remotes = lib.git.query.list_remotes(git_info.common_dir) or {}
			-- local found = false
			-- for _, remote in ipairs(remotes) do
			-- 	if
			-- 		#remote ~= #git_info.branch_info.display_name
			-- 		and git_info.branch_info.display_name:find("^" .. remote)
			-- 	then
			-- 		git_info.new_path = git_info.branch_info.display_name:sub(#remote + 1)
			-- 		found = true
			-- 		break
			-- 	end
			-- end
			-- if not found then
			-- 	opts.path_style = "same"
			-- end
		end

		if opts.path_style == "same" then
			git_info.new_path = git_info.branch_info.display_name
		elseif type(opts.path_style) == "function" then
			git_info.new_path = opts.path_style(git_info, local_branches)
		end

		-- TODO check if path already in use and prompt

		if opts.path_style == "prompt" then
			lib.input({
				prompt = "Path for the worktree",
			}, M.create_worktree(git_info))
			return
		end

		-- TODO check if path already in use and return

		-- nil implies that the branch_name is already stored in base_spec
		-- (when not a callback from input)
		M.create_worktree(git_info, true)(nil)
	end
end

function M.create_worktree(git_info, is_sync)
	return function(path)
		if path then
			git_info.new_path = path
		elseif not is_sync then
			-- user canceled the input
			return
		end

		if not git_info.new_path then
			lib.notify.error("Worktree path is nil")
			return
		end
		git_info.new_path = git_info.resolved_base .. "/" .. git_info.new_path

		-- TODO: when do we prompt for a branch_name?

		local events = common.get_events("add", "ArborAdd")
		git_info = events.hookpre(git_info)
		if events.aupre then
			events.aupre(git_info)
		end

		if not lib.git.worktree.add(git_info, git_info.new_path) then
			return
		end

		git_info = events.hookpost(git_info)
		if events.aupost then
			events.aupost(git_info)
		end
	end
end

return M
