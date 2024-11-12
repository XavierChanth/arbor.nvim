---@class arbor.lib.git
---@field info arbor.lib.git.info
---@field query arbor.lib.git.query
---@field porcelain arbor.lib.git.porcelain
---@field worktree arbor.lib.git.worktree
local M = {}

setmetatable(M, {
	__index = function(_, k)
		return require("arbor._lib.git." .. k)
	end,
})

return M
