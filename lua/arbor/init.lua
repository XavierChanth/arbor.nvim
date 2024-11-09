---@class arbor
local M = {}

---@param events arbor.event|arbor.event[]
function M.enable_events(events)
	require("arbor.events").enable(events)
end
---@param events arbor.event|arbor.event[]
function M.disable_events(events)
	require("arbor.events").disable(events)
end

---@param opts arbor.config
---@return nil
function M.setup(opts)
	require("arbor.config").set(opts)
end

return M
