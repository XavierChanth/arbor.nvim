---@alias arbor.select.provider
---| "telescope" Use telescope.nvim
---| "fzf"       Use fzf-lua
---| "vim"       Use vim.ui.select

---@class arbor.tui.select
local M = {}

local providers = {}

providers.vim = vim.ui.select
-- TODO telescope, fzf

---@return function(): item, idx
function M.select(items, opts, cb)
	local key = require("arbor.config").select
	return providers[key](items, opts, cb)
end

return M
