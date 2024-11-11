-- core utilities
---@class arbor
---@field config arbor.config
---@field lib arbor.lib

-- core features
---@class arbor
---@field add arbor.core.add

-- extensions
---@class arbor
---@field actions arbor.actions
---@field events arbor.events

---@class arbor
local M = {}

local modules = {
	-- core utilities
	config = "arbor.config",
	git = "arbor.git",

	-- core features
	add = "arbor.core.add",

	-- extensions
	actions = "arbor.actions",
	events = "arbor.events",
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
