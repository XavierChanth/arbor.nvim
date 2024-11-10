---@class arbor
---@field actions arbor.actions
---@field config arbor.config
---@field events arbor.events
---@field git arbor.git
---@field add arbor.core.add
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

---@param opts arbor.config_opts
---@return nil
function M.setup(opts)
	require("arbor.config").set(opts)
end

return M
