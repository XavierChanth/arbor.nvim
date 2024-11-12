---@alias arbor.select
---| function(items: core.item[], opts: table, cb: function(item: core.item|nil, idx: integer|nil))

---@type table<arbor.select.provider, arbor.select>
local providers = {
	vim = function(...)
		vim.ui.select(...)
	end,
	--TODO
	--telescope =
	--fzf =
}

---@type arbor.select
return function(items, opts, cb)
	local key = require("arbor.config").select
	return providers[key](items, opts, cb)
end
