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
		global = {
			hooks = {},
			preserve_default_hooks = false,
		},
		add = {
			path_style = "smart",
			show_remote_branches = true,
			switch_if_wt_exists = true,
			branch_pattern = "",
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
		prefix = "action",
	},
	hooks = {},
	events = {},
}

---@class arbor.config_module : arbor.config.internal
local M = {}

---@type arbor.config.internal
local config = vim.tbl_extend("force", default_config, {})

---@param opts? arbor.config
---@return arbor.config.internal
function M.set(opts)
	config = vim.tbl_deep_extend("force", config, opts or {})
	return config
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
