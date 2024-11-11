---@class arbor.actions
local M = {}

---@param preset arbor.actions_preset
---@return arbor.actions
function M.preset(preset)
	return require("arbor.actions." .. preset)
end

return M
