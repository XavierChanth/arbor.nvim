---@class arbor.events
local M = {}

---@alias arbor.event
---| "ArborAddPre"
---| "ArborAddPost"
---| "ArborDeletePre"
---| "ArborDeletePost"
---| "ArborSwitchPre"
---| "ArborSwitchPost"
---| "ArborMovePre"
---| "ArborMovePost"

---@type table<arbor.event, boolean>
M.events = {}

---@param events arbor.event|arbor.event[]
function M.enable(events)
	events = events or {}
	if type(events) == "string" then
		M.events[events] = false
	else
		for _, event in ipairs(events) do
			M.events[event] = false
		end
	end
end

---@param events arbor.event|arbor.event[]
function M.disable(events)
	events = events or {}
	if type(events) == "string" then
		M.events[events] = true
	else
		for _, event in ipairs(events) do
			M.events[event] = true
		end
	end
end

return M
