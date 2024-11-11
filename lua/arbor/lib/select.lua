---@alias arbor.select
---| function(items: core.item[], opts: table, cb: function(item: core.item|nil, idx: integer|nil)): item, idx
local M = {}

local providers = {}

providers.vim = vim.ui.select
-- TODO telescope, fzf

setmetatable(M, {
	_call = function(items, opts, cb)
		local key = require("arbor.config").select
		return providers[key](items, opts, cb)
	end,
})

return M
