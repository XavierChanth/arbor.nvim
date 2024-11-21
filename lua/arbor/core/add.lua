---@class arbor.core.add.internal
local M = {}

local config = require("arbor.config")
local lib = require("arbor._lib")
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
	local items = {}
	if opts.show_actions then
		items = common.append_actions_to_items(actions)
	end

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

	local select_opts = vim.tbl_deep_extend("force", {
		prompt = "Add worktree",
		format_item = common.generate_item_format,
	}, opts.select_opts or {})

	lib.select(items, select_opts, callback)
end -- end of add

---@param opts arbor.opts.add
---@param git_info arbor.git.info
---@param local_branches? arbor.git.branch[]
function M.after_ref_selected(opts, git_info, local_branches)
	return function(item, idx)
		git_info.operation_opts = opts

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

		if
			opts.on_existing
			and item.branch_info
			and item.branch_info.worktree_path
			and string.len(item.branch_info.worktree_path) > 0
		then
			git_info = opts.on_existing(git_info) or git_info
			return
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
				opts.path_style = "same"
			end
		end

		if opts.path_style == "same" then
			git_info.new_path = git_info.branch_info.display_name
		elseif type(opts.path_style) == "function" then
			git_info.new_path = opts.path_style(git_info, local_branches)
		end

		if opts.path_style == "prompt" then
			local input_opts = opts.path_input_opts or {
				prompt = "Path for the worktree: ",
			}
			lib.input(input_opts, M.after_path_selected(opts, git_info, local_branches))
			return
		end

		M.after_path_selected(opts, git_info, local_branches, true)()
	end
end

---@param opts arbor.opts.add
---@param git_info arbor.git.info
---@param local_branches? arbor.git.branch[]
---@param is_sync? boolean
---@diagnostic disable-next-line: unused-local
function M.after_path_selected(opts, git_info, local_branches, is_sync)
	return function(path)
		if path then
			git_info.new_path = path
		elseif not is_sync then
			-- user canceled the input
			return
		end

		if opts.branch_style == "path" then
			if opts.path_style == "branch" then
				lib.notify.error('branch_style="path" and path_style="branch" are mutually exclusive')
				return
			end
			git_info.new_branch = git_info.new_path
		end

		if opts.branch_style == "prompt" then
			local input_opts = opts.branch_input_opts or {
				prompt = "Name for the branch: ",
			}
			lib.input(input_opts, M.after_branch_selected(opts, git_info, local_branches))
			return
		end

		M.after_branch_selected(opts, git_info, local_branches, true)(nil)
	end
end

---@param opts arbor.opts.add
---@param git_info arbor.git.info
---@param local_branches? arbor.git.branch[]
---@param is_sync? boolean
---@diagnostic disable-next-line: unused-local
function M.after_branch_selected(opts, git_info, local_branches, is_sync)
	---@param branch string|nil
	return function(branch)
		if branch then
			git_info.new_branch = branch
		elseif not is_sync then
			-- user canceled the input
			return
		end

		if opts.path_style == "branch" then
			git_info.new_path = git_info.new_branch
		end

		if not git_info.new_path then
			lib.notify.error("Failed to resolve worktree path")
			return
		end

		-- Final path for worktree
		git_info.new_path = lib.path.norm(git_info.resolved_base .. "/" .. git_info.new_path)

		if not git_info.new_path then
			lib.notify.error("Failed to normalize worktree path")
			return
		end

		local events = common.get_events("add", "ArborAdd", opts)
		git_info = events.hookpre(git_info) or git_info
		if events.aupre then
			events.aupre(git_info)
		end

		-- Special case: branch already exists locally (i.e. don't use ref, use branch name)
		local ref = git_info.branch_info.display_name
		local new_branch = git_info.new_branch
		if new_branch then
			local branches = require("arbor._lib.git").query.get_local_branches(git_info.common_dir)
			for _, b in ipairs(branches or {}) do
				if b == new_branch then
					ref = new_branch --[[@as string]]
					new_branch = nil
				end
			end
		-- Removed git from the types, but keeping it in the code to prevent breaking changes
		elseif opts.branch_style ~= "git" then
			lib.notify.error("Failed to resolve the branch")
			return
		end

		if not lib.git.worktree.add(git_info.common_dir, git_info.new_path, ref, new_branch) then
			return
		end

		git_info = events.hookpost(git_info) or git_info
		if events.aupost then
			events.aupost(git_info)
		end
	end
end

setmetatable(M, {
	__call = function(_, opts)
		return M.add(opts)
	end,
})

return M
