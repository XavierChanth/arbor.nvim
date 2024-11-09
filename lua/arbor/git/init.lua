---@class arbor.git
---@field worktree arbor.git.worktree

---@class arbor.git
local M = {}

setmetatable(M, {
	__index = function(_, k)
		local lib = require("arbor.config").git.library
		return require("arbor.git." .. lib)[k]
	end,
})

return M
