---@class arbor.notify
local M = {}

--- Keep this as an internal value in case the vim api for this changes
--- It is marked as a private API in the vim code base
local default_level = (vim.log and vim.log.levels and vim.log.levels.INFO) or 2

local function call_notify(msg, level)
	local config = require("arbor.config").notify
	local log_level = config.level or default_level
	if not config.enabled or (level < log_level) then
		return
	end
	vim.notify(msg, level, config.opts)
end

---@param msg string
function M.error(msg)
	call_notify(msg, vim.log.levels.ERROR)
end

---@param msg string
function M.warn(msg)
	call_notify(msg, vim.log.levels.WARN)
end

---@param msg string
function M.info(msg)
	call_notify(msg, vim.log.levels.INFO)
end

return M
