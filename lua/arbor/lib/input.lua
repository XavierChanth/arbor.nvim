---@class arbor.input
local M = {}

---@alias arbor.input.provider
---| "vim" Use vim.ui.input

---@type table<arbor.input.provider, function>
local providers = {}

function providers.vim(opts, on_confirm)
	return vim.ui.input(opts, on_confirm)
end

function M.input(opts, on_confirm)
	return providers[require("arbor.config").input](opts, on_confirm)
end

function M.synchronize(opts)
	local tx, rx = require("plenary.async.control").channel.oneshot()
	M.input(opts, function(user_input)
		tx(user_input or "")
	end)
	return rx()
end

return M
