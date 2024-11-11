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
	-- store the resolved opts in the git_info so the user can use it
	-- in hooks & autocmds

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

	local callback = M.after_ref_selected(opts, git_info, local_branches or {})

	lib.select(items, {
		prompt = "Add worktree",
		format_item = common.generate_item_format,
	}, callback)
end -- end of add

---@param opts arbor.opts.add
---@param git_info arbor.git.info
---@param local_branches arbor.git.branch[]
function M.after_ref_selected(opts, git_info, local_branches)
	return function(item, idx)
		git_info.operation_opts = opts

		if not item or not idx then
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

		-- FIXME: this is being skipped
		if item.worktreepath and string.len(item.worktreepath) > 0 then
			if opts.switch_if_wt_exists then
				-- TODO: switch instead of add
				vim.print("TODO: auto switch")
			end
			return
		end

		if opts.force_prompt then
			opts.path_style = "prompt"
			opts.branch_style = "prompt"
		end

		if opts.path_style == "basename" then
			git_info.new_path = vim.fs.basename(git_info.branch_info.display_name)
		elseif opts.path_style == "smart" then
			local remotes = lib.git.query.list_remotes(git_info.common_dir) or {}
			local matches = {}
			for _, remote in ipairs(remotes) do
				if git_info.branch_info.display_name:find("^" .. remote) then
					matches[#matches + 1] = git_info.branch_info.display_name:sub(#remote + 2) -- strip '<remote>/'
				end
			end

			if #matches == 1 then
				git_info.new_path = matches[1]
			else
				lib.notify.info("Unable to resolve smart path name, prompting for path")
				opts.path_style = "same"
			end
		end

		if opts.path_style == "same" then
			git_info.new_path = git_info.branch_info.display_name
		elseif type(opts.path_style) == "function" then
			git_info.new_path = opts.path_style(git_info, local_branches)
		end

		if opts.path_style == "prompt" then
			lib.input({
				prompt = "Path for the worktree",
			}, M.after_path_selected(opts, git_info))
			return
		end

		M.after_path_selected(opts, git_info, true)()
	end
end

---@param opts arbor.opts.add
---@param git_info arbor.git.info
---@param is_sync? boolean
---@diagnostic disable-next-line: unused-local
function M.after_path_selected(opts, git_info, is_sync)
	return function(path)
		if path then
			git_info.new_path = path
		elseif not is_sync then
			-- user canceled the input
			return
		end

		if not git_info.new_path then
			lib.notify.error("Failed to resolve worktree path")
			return
		end

		if opts.branch_style == "path" then
			git_info.new_branch = git_info.new_path
		end

		-- Final path for worktree
		git_info.new_path = lib.path.norm(git_info.resolved_base .. "/" .. git_info.new_path)

		if not git_info.new_path then
			lib.notify.error("Failed to resolve worktree path")
			return
		end

		if opts.branch_style == "prompt" then
			lib.input({
				prompt = "Name for the branch",
			}, M.after_branch_selected(opts, git_info))
			return
		end

		M.after_branch_selected(opts, git_info, true)(nil)
	end
end

---@param opts arbor.opts.add
---@param git_info arbor.git.info
---@param is_sync? boolean
---@diagnostic disable-next-line: unused-local
function M.after_branch_selected(opts, git_info, is_sync)
	---@param branch string|nil
	return function(branch)
		if branch then
			git_info.new_branch = branch
		elseif not is_sync then
			-- user canceled the input
			return
		end

		local events = common.get_events("add", "ArborAdd")
		git_info = events.hookpre(git_info)
		if events.aupre then
			events.aupre(git_info)
		end

		if not lib.git.worktree.add(git_info, git_info.new_path, git_info.new_branch, opts.guess_remote) then
			return
		end

		git_info = events.hookpost(git_info)
		if events.aupost then
			events.aupost(git_info)
		end
	end
end

return M
