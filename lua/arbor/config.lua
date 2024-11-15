--- The default config for arbor.nvim
---@type arbor.config.internal
local default_config = {
	apply_recommended = true, -- apply recommended settings
	-- this is aimed at providing a better out of the box experience, but
	-- can be disabled for a cleaner base for adding customization
	select = "vim", -- Which selector to use, other options: "telescope", "fzf"
	input = "vim", -- Only vim is available right not (vim.ui.input)
	highlight = {
		action = "String", -- highlight group for actions when using telescope/fzf
		branch = "Function", -- highlight group for branches when using telescope/fzf
	},
	notify = {
		lib = false, -- suppress warnings about importing the arbor.lib
		---@type boolean
		enabled = true, -- whether to enable notifications
		---@type integer|nil
		level = nil, -- maximum level that logs will show for
		---@type table|nil
		opts = nil, -- options table to pass to vim.notify
	},
	settings = {
		add = {
			--- Input options
			path_input_opts = nil, -- Passed to vim.ui.input when prompted for worktree path
			branch_input_opts = nil, -- Passed to vim.ui.input when prompted for new branch name
			select_opts = nil, -- Passed to vim.ui.select/telescope/fzf for initial selection

			--- Naming resolution
			path_style = "smart", -- How we detect path name for a git ref
			-- Other options: "same", "basename", "prompt", function(git_info: arbor.git.info, local_branches?: string[]): string
			branch_style = "path", -- path will set the branch name to the same as the resolved path (relative to base)
			-- Other options: "git", "prompt"

			--- Git options
			show_remote_branches = true, -- Include remote branches
			branch_pattern = nil, -- Filter branches with pattern (see man git-for-each-ref)
			show_actions = true, -- Show actions by default
		},
		remove = {
			select_opts = nil, -- Passed to vim.ui.select/telescope/fzf for initial selection
			branch_pattern = nil, -- Filter branches with pattern (see man git-for-each-ref)

			--- Git options
			show_actions = true, -- show actions as selectable items
			force = false, -- pass force to git worktree remove
		},
		pick = {
			select_opts = nil, -- Passed to vim.ui.select/telescope/fzf for initial selection

			--- Git options
			show_actions = true, -- show actions as selectable items
			show_remote_branches = false, -- Include remote branches
		},
	},
	git = {
		binary = "git", -- path to the git binary if it isn't on PATH
		main_branch = { "main", "master", "trunk" }, -- branch names to match as main
	},
	worktree = {
		normal = {
			base = "relative_common", -- Where to resolve the base of the repo from
			-- "relative_common" - relative to the git common dir (i.e. .git/)
			-- "relative_cwd" - relative to vim's cwd
			-- "absolute" - take path as it is
			path = "..", -- path to the base of the repo (relative to base, unless absolute is set)
		},
		bare = {
			base = "relative_common", -- same thing as above, but for bare repos
			path = ".",
		},
	},
	actions = {
		add = {}, -- pickable actions when running add()
		remove = {}, -- pickable actions when running remove()
		pick = {}, -- pickable actions when running pick()
	},
	hooks = { -- default hooks for each core feature
		pre_add = nil,
		post_add = nil,
		pre_remove = nil,
		post_remove = nil,
		pre_pick = nil,
		post_pick = nil,
	},
	events = {}, -- events to enable:
	-- ArborAddPre, ArborAddPost
	-- ArborRemovePre, ArborRemovePost
	-- ArborPickPre, ArborPickPost
}

---@class arbor.config_module : arbor.config.internal
local M = {}

---@type arbor.config.internal
local config = vim.tbl_extend("force", default_config, {})

---@param opts? arbor.config
---@return arbor.config.internal
function M.set(opts)
	opts = opts or {}
	local recommended = {}
	if opts.apply_recommended then
		recommended = require("arbor.recommended_hooks")
	end
	config = vim.tbl_deep_extend("force", config, recommended, opts)
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
