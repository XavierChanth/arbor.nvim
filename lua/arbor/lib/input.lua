---@alias arbor.input
---| function(opts: table, on_confirm: function(input: string|nil))

---@type table<arbor.input.provider, function>
local providers = {}

function providers.vim(opts, on_confirm)
	return vim.ui.input(opts, on_confirm)
end

---@type arbor.input
return function(opts, on_confirm)
	return providers[require("arbor.config").input](opts, on_confirm)
end
