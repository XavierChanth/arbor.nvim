---@class arbor.actions
local M = {}

---@param preset arbor.actions.preset
---@return arbor.actions_spec
function M.preset(preset)
	return require("arbor.actions." .. preset)
end

return M
