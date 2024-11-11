---@class arbor.input
local M = {}

---@type table<arbor.input.provider, function>
local providers = {}

function providers.vim(opts, on_confirm)
	return vim.ui.input(opts, on_confirm)
end

setmetatable(M, {
	__call = function(opts, on_confirm)
		return providers[require("arbor.config").input](opts, on_confirm)
	end,
})

return M
