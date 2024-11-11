---@class arbor.git.__worktree
local M = {}

---@param path? string
---@return nil
function M.is_inside(path)
	local res, exit_code = require("plenary.job")
		:new({
			command = require("arbor.config").git.binary,
			args = { "rev-parse", "--is-inside-work-tree" },
			cwd = path,
			enabled_recording = true,
		})
		:sync()

	return exit_code == 0 and res[1] == "true"
end

function M.add(git_info, branch, path, refname)
	--
end

function M.switch(opts) end

return M
