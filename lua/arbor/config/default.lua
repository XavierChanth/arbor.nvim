--- The default config for arbor.nvim
local config = {
	---SECTION 1: Configure the base plugin functionality

	---The provider for selecting items
	---The default ("vim") calls vim.ui.select
	---Other options: "telescope", "fzf"
	---@type arbor.select.provider
	select = "vim",

	---The provider for inputs
	---The default ("vim") calls vim.ui.input
	---There are no other options at this time
	---@type arbor.input.provider
	input = "vim",

	---Settings for vim.notify
	---Currently, we only provide notifications if something has gone wrong
	--- - enabled: `Set enabled = false` to disable all notifications in this plugin
	--- - level:   level for vim.notify see :h |vim.notify|
	--- - opts:    opts for vim.notify see :h |vim.notify|
	---@type arbor.config.notify
	notify = {
		---@type boolean
		enabled = true,
		---@type integer|nil
		level = nil,
		---@type table|nil
		opts = nil,
	},

	---Defaults for each kind of picker
	settings = {
		---@type arbor.core_opts
		global = {},
		---@type arbor.core.add_opts
		add = {

			branch_from = "prompt",
			show_remote_branches = false,
			switch_if_wt_exists = true,
		},
		---@type arbor.core.delete_opts
		delete = {},
		---@type arbor.core.switch_opts
		switch = {},
		---@type arbor.core.move_opts
		move = {},
	},
	---Settings for git
	---@type arbor.config.git
	git = {
		---Path to the git binary on your system
		---Can also be a function which returns this string
		---@type string|function(): string
		binary = "git", -- path to the git binary
		---
		main_branch = { "main", "master", "trunk" },
	},
	---Worktree configuration
	---normal and bare repositories each have their own configuration
	---We detect bare repositories with `git rev-parse --is-bare-repository`
	---
	---style and path determine how we find the base of the repository.
	---The default configuration should "just work" if you are using a typical git setup:
	---e.g. `git clone <repo> <path>` or `git clone --bare <repo> <path>`
	---The default configuration will assume the base of the repo is <path> for both commands
	---
	---If you want to use normal repos, but not have your worktrees nested under the main
	---git working directory, use this configuration:
	---
	---worktree = {
	---  normal = {
	---    path = "../../"
	---  }
	---}
	---
	---Advanced use cases:
	---
	---There are three styles for determining the base:
	--- - "relative_common": path will be relative to the git common dir
	---   i.e. output of `git rev-parse --git-common-dir`
	--- - "relative_cwd": path will be relative to the cwd of vim
	--- - "absolute": path will be taken as the base as-is with no prefix or normalization applied
	---
	---For the "relative" styles:
	---After resolving the style's associated prefix, "path" will be appended it to it.
	---Then this path will be normalized, this is what arbor.nvim uses as the repo base.
	---
	---The base of the repository is also cached based on vim's cwd, to purge the cache use
	---the following lua function:
	---
	---require("arbor.lib.base").purge_cache()
	---
	---If you need a more advanced path resolver, you can use a function for path.
	---For full control, use style = "absolute" with it:
	---
	---worktree = {
	---  normal = {
	---    style = "absolute",
	---    path = function(spec)
	---      -- do something with spec.common_dir or spec.repo_type
	---      -- return a string
	---    end
	---  }
	---}
	---@type arbor.config.worktree
	worktree = {
		---@type arbor.config.worktree_spec
		normal = {
			---@type "relative_common"|"relative_cwd"|"absolute"
			style = "relative_common",
			---@type string|function(spec: arbor.git.base_spec): string
			path = "../",
		},
		---@type arbor.config.worktree_spec
		bare = {
			---@type "relative_common"|"relative_cwd"|"absolute"
			style = "relative_common",
			---@type string|function(spec: arbor.git.base_spec): string
			path = ".",
		},
	},

	---SECTION 2: Extend the plugin functionality
	---WARN: Functionality here is subject to breaking changes until arbor
	---is considered GA.

	---Will provide better docs for this section once this API is stable

	---@type arbor.actions.config
	actions = {
		preset = nil,
		prefix = "action",
		---@type arbor.actions_spec
		add = {},
		---@type arbor.actions_spec
		move = {},
		---@type arbor.actions_spec
		switch = {},
		---@type arbor.actions_spec
		delete = {},
	},
	---Synchronous functions for extending the behavior of each picker
	---@type arbor.hooks
	hooks = {},
	---Events (a.k.a. autocmds) to be enabled
	---By default all are disabled, as they aren't needed by the base plugin
	---@type arbor.event[]
	events = {},
}

return config
