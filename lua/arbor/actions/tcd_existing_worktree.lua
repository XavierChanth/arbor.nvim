---@param info? arbor.git.info
---@return arbor.git.info | nil
return function(info)
	if
		not info
		or not info.branch_info
		or not info.branch_info.worktree_path
		or string.len(info.branch_info.worktree_path) <= 0
	then
		require("arbor._lib.notify").warn("tcd worktree failed: worktree path not set")
		return
	end
	vim.cmd("tcd " .. info.branch_info.worktree_path)
end
