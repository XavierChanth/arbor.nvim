---@alias arbor.select
---| function(items: core.item[], opts: table, cb: function(item: core.item|nil, idx: integer|nil))

local providers = {}

providers.vim = vim.ui.select
-- TODO telescope, fzf

---@type arbor.select
return function(items, opts, cb)
	local key = require("arbor.config").select
	return providers[key](items, opts, cb)
end
