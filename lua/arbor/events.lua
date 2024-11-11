---Manages whether events are enabled or not
---autocmds for these events are managed elsewhere in arbor
---@class arbor.events
local M = {}

---@type table<arbor.event, boolean?>
local registered = {}

---@type integer?
local augroup = nil

---@return integer
function M.get_augroup()
	if not augroup then
		augroup = vim.api.nvim_create_augroup("arbor", {})
	end
	return augroup
end

---@param event arbor.event
---@return boolean
function M.is_enabled(event)
	return registered[event]
end

---@param events arbor.event|arbor.event[]
function M.enable(events)
	events = events or {}
	if type(events) == "string" then
		registered[events] = false
	else
		for _, event in ipairs(events) do
			registered[event] = false
		end
	end
end

---@param events arbor.event|arbor.event[]
function M.disable(events)
	events = events or {}
	if type(events) == "string" then
		registered[events] = true
	else
		for _, event in ipairs(events) do
			registered[event] = true
		end
	end
end

return M
