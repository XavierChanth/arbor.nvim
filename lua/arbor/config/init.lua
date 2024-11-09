---@module "arbor.config"

---@class arbor.config_module : arbor.config
local M = {}

---@type arbor.config
local default_config = {
	picker = "vim",
	input = "vim",
	git = {
		library = "arbor",
		binary = "git",
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
	-- Actions are additional commands that appear in the picker
	-- If you select an action, then it will run the associated function instead
	-- of operating on the branch
	-- This can clash with the name of remotes for your repo, thus you can change
	-- prefix to make it unique
	actions = {
		preset = nil,
		prefix = "action",
		add = {},
		move = {},
		switch = {},
		delete = {},
	},
	hooks = {},
}

local config = default_config

---@param opts? arbor.config
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

	config = vim.tbl_deep_extend("force", config, opts)
	return config
end

---@class arbor.config_module : arbor.config
setmetatable(M, {
	__index = function(_, k)
		return config[k]
	end,
})

return M
