--- The default config for arbor.nvim
---@type arbor.config.internal
local default_config = {
	select = "vim",
	input = "vim",
	notify = {
		lib = false,
		---@type boolean
		enabled = true,
		---@type integer|nil
		level = nil,
		---@type table|nil
		opts = nil,
	},
	settings = {
		add = {
			--- Branch listing options
			show_remote_branches = true, -- Include remote branches
			branch_pattern = nil, -- Filter branches with pattern (see man git-for-each-ref)
			--- Naming resolution
			path_style = "smart", -- How we detect path name for a ref
			branch_style = "path", -- path will set the branch name to the same as the resolved path (relative to base)
			--- Worktree behaviour
			show_actions = true, -- Show actions by default
		},
		remove = {
			show_actions = true,
		},
		pick = {
			show_actions = true,
			show_remote_branches = false, -- Include remote branches
		},
		move = {
			show_actions = true,
		},
	},
	git = {
		binary = "git", -- path to the git binary
		main_branch = { "main", "master", "trunk" },
	},
	worktree = {
		normal = {
			base = "relative_common",
			path = "..",
		},
		bare = {
			base = "relative_common",
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
