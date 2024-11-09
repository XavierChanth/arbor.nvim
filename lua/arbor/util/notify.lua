local M = {}

-- TODO: make it possible to disable notifications

---@param msg string
function M.error(msg)
	vim.notify(msg, vim.log.levels.ERROR)
end

return M
