local function post_pick(info)
	if info.new_path then
		require("arbor").actions.cd_new_path(info)
	else
		require("arbor").actions.cd_existing_worktree(info)
	end
	vim.cmd("bufdo bd")
	return info
end

---@type arbor.config
return {
	hooks = {
		post_add = function(info)
			info = require("arbor").actions.set_upstream(info) or info
			return post_pick(info)
		end,
		post_pick = post_pick,
	},
}
