--- The default config for arbor.nvim
---@type arbor.config.internal
local default_config = {
	select = "vim",
	input = "vim",
	notify = {
		---@type boolean
		enabled = true,
		---@type integer|nil
		level = nil,
		---@type table|nil
		opts = nil,
	},
	settings = {
		global = {},
		add = {
			branch_from = "prompt",
			show_remote_branches = false,
			switch_if_wt_exists = true,
		},
		delete = {},
		switch = {},
		move = {},
	},
	git = {
		binary = "git", -- path to the git binary
		main_branch = { "main", "master", "trunk" },
	},
	worktree = {
		normal = {
			style = "relative_common",
			path = "../",
		},
		bare = {
			style = "relative_common",
			path = ".",
		},
	},
	actions = {
		preset = nil,
		prefix = "action",
		add = {},
		move = {},
		switch = {},
		delete = {},
	},
	hooks = {},
	autocmds = {},
}

---@class arbor.config_module : arbor.config.internal
---@field set function(opts: arbor.config|nil): arbor.config
local M = {}

---@type arbor.config.internal
local config = vim.tbl_extend("force", default_config, {})

---@param opts arbor.config
---@return arbor.config.internal
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
				require("arbor.extensions.actions")[opts.actions.preset[preset]] or {}
			)
		end
	end

	return vim.tbl_deep_extend("force", config, opts) --[[@as arbor.config.internal]]
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
