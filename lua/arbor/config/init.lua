---@class arbor.config_module : arbor.config
---@field set function(opts: arbor.config|nil): arbor.config
local M = {}
local default_config = require("arbor.config.default")

---@type arbor.config
local config = vim.tbl_extend("force", default_config, {})

---@param opts arbor.config_opts
---@return arbor.config
function M.set(opts)
	opts = opts or {}

	opts.actions = opts.actions or {}

	if opts.actions.preset then
		if type(opts.actions.preset) == "string" then
			opts.actions.preset = {
				opts.actions.preset --[[@as arbor.actions.preset]],
			}
		end
		for _, preset in
			ipairs(opts.actions.preset--[[@as arbor.actions.preset[] ]])
		do
			opts.actions = vim.tbl_deep_extend(
				"keep",
				opts.actions,
				require("arbor.actions.init")[opts.actions.preset[preset]] or {}
			)
		end
	end

	return vim.tbl_deep_extend("force", config, opts)
end

setmetatable(M, {
	__index = function(_, k)
		--- resolve the git binary as a string
		if k == "git" and config.git and type(config.git.binary) == "function" then
			config.git.binary = config.git.binary()
		end

		return config[k]
	end,
})

return M
