---@class arbor.git
---@field info arbor.git.__info
---@field query arbor.git.__query
---@field porcelain arbor.git.__porcelain
---@field worktree arbor.git.__worktree
local M = {}

setmetatable(M, {
	__index = function(_, k)
		return require("arbor.lib.git." .. k)
	end,
})

return M
