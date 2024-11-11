---@class arbor.lib
---@field git arbor.git
---@field input arbor.input
---@field notify arbor.notify
---@field path arbor.path
---@field select arbor.select
local M = {}

setmetatable(M, {
	__index = function(_, k)
		return require("arbor.lib." .. k)
	end,
})

return M
