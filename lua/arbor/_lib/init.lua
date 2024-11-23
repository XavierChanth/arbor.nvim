---@class arbor.lib
---@field git arbor.lib.git
---@field notify arbor.notify
---@field path arbor.path
---@field select arbor.select
local M = {}

setmetatable(M, {
	__index = function(_, k)
		return require("arbor._lib." .. k)
	end,
})

return M
