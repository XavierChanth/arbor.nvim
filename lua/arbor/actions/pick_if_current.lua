---@param info? arbor.git.info
---@param opts? arbor.opts.pick
---@return arbor.git.info | nil
return function(info, opts)
	if
		not info
		or not info.branch_info
		or not info.branch_info.worktree_path
		or string.len(info.branch_info.worktree_path) == 0
	then
		return
	end

	if info.toplevel == info.branch_info.worktree_path then
		require("arbor.core.pick").pick(opts)
	end
end
