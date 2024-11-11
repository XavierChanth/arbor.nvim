-- core utilities
---@class arbor
---@field config arbor.config
---@field lib arbor.lib

-- core features
---@class arbor
---@field add arbor.core.add

-- extensions
---@class arbor
---@field events arbor.events
---@field actions arbor.actions

---@class arbor
local M = {}

local modules = {
	actions = "arbor.actions",
	config = "arbor.config",
	events = "arbor.event",
	git = "arbor.git",
	add = "arbor.core.add",
}

setmetatable(M, {
	__index = function(_, k)
		return require(modules[k])
	end,
})

---@param opts arbor.config
---@return nil
function M.setup(opts)
	require("arbor.config").set(opts)
end

return M
