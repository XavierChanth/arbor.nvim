---@meta

---# Arbor type definitions

---@class arbor

---##Config
---
---> All the types in config have implicit

---Developer note:
---Add new config type to arbor.config.internal first.
---Lua ls will give you a nice warning to set an optional type
---for the public facing version type [[arbor.config]]
---@type arbor.config
local _ = {}

---@class arbor.config : arbor.config.internal
---@field select? arbor.select.provider
---@field input? arbor.input.provider
---@field notify? arbor.config.notify
---@field settings? arbor.config.settings
---@field git? arbor.config.git
---@field worktree? arbor.config.worktree
---@field actions? arbor.config.actions
---@field hooks? arbor.hooks
---@field autocmds? arbor.autocmd[]

---@class arbor.config.notify
---@field enabled? boolean
---@field level? integer
---@field opts? table

---@class arbor.config.settings
---@field global? arbor.opts
---@field add? arbor.opts.add
---@field delete? arbor.opts.delete
---@field switch? arbor.opts.switch
---@field move? arbor.opts.move

---@class arbor.config.actions : arbor.actions
---@field preset? arbor.actions.preset | arbor.actions.preset[]
---@field prefix? string

---@class arbor.config.git
---@field binary? string
---@field main_branch? string | string[]
---TODO add git fetch before worktree arg

---@class arbor.config.worktree
---@field normal? arbor.config.worktree_spec
---@field bare? arbor.config.worktree_spec

---@class arbor.config.worktree_spec
---@field style? arbor.worktree.style
---@field path? arbor.config.worktree.path

---@alias arbor.select.provider
---| "vim"       Use vim.ui.select
--- These are coming soon:
--- "telescope" Use telescope.nvim
--- "fzf"       Use fzf-lua

---@alias arbor.input.provider
---| "vim" Use vim.ui.input

---@alias arbor.config.worktree.path
---| string
---| function(spec: arbor.git.path_base_spec): string

---## Core features

---@class arbor.opts
---@field select? arbor.opts.select opts table for vim.ui.select
---@field telescope? table opts table for telescope.nvim
---@field fzf? table opts table for fzf-lua
---@field hooks? arbor.hook_pair
---@field preserve_default_hooks? boolean default hooks defined in config always run first

---@class arbor.opts.select
---@field prompt? string
---@field format_item? function(item: arbor.core_item): string
---@field kind? string

---@class arbor.opts.add : arbor.opts
---@field show_remote_branches? boolean
---@field branch_pattern? string
---@field path_style? arbor.opts.add.path_style
---@field switch_if_wt_exists? boolean
---@field cd_after? boolean

---@class arbor.opts.delete :arbor.opts

---@class arbor.opts.switch : arbor.opts

---@class arbor.opts.move : arbor.opts

---@alias arbor.opts.add.path_style
---| "prompt"
---| "same"
---| "smart"
---| function(spec: arbor.hooks.post_spec, local_branches?: string[]): string

---@alias arbor.feature
---| "add"
---| "delete"
---| "switch"
---| "move"

---@alias arbor.auprefix
---| "ArborAdd"
---| "ArborDelete"
---| "ArborSwitch"
---| "ArborMove"

---@class arbor.item
---@field id string
---@field label string
---@field type arbor.item.type
---@field action_callback? arbor.action
---@field branch_info? arbor.git.branch

---@alias arbor.item.type
---| "action"
---| "branch"

---@class arbor.git.info
---@field branch string
---@field path string
---@field repo_type arbor.git.repo_type
---@field common_dir string
---@field new_path? string
---@field resolved_base? string
---@field branch_info? arbor.git.branch

---@alias arbor.git.repo_type
---| "bare"
---| "normal"

---@alias arbor.worktree.style
---| "relative_common"
---| "relative_cwd"
---| "absolute"

---@class arbor.git.branch
---@field head boolean
---@field main_branch boolean?
---@field refname string
---@field upstream string?
---@field worktree_path string?
---@field display_name string

---@class arbor.git.get_branches_opts
---@field pattern? string
---@field cwd? string
---@field include_remote_branches boolean?

---## Extensions

---### Hooks

---@class arbor.hook_pair
---@field pre? arbor.hooks.pre
---@field post? arbor.hooks.post

---@class arbor.hooks
---@field pre_add? arbor.hooks.pre
---@field post_add? arbor.hooks.post
---@field pre_delete? arbor.hooks.pre
---@field post_delete? arbor.hooks.post
---@field pre_switch? arbor.hooks.pre
---@field post_switch? arbor.hooks.post
---@field pre_move? arbor.hooks.pre
---@field post_move? arbor.hooks.post

---@alias arbor.hooks.pre function(spec: arbor.hooks.pre_spec): arbor.hooks.pre_spec
---@alias arbor.hooks.post function(spec: arbor.hooks.post_spec): arbor.hooks.post_spec

---###Actions

---@class arbor.actions
---@field add? table<string, arbor.action>
---@field delete? table<string, arbor.action>
---@field switch? table<string, arbor.action>
---@field move? table<string, arbor.action>

---@class arbor.action.info
---@field branch string
---@field path string
---@field git_dir string

---@alias arbor.action
---| function(info: arbor.git.hooks_base_spec): nil

---@alias arbor.actions.preset
---| "git"

---###Autocommands
---
---@alias arbor.autocmd
---| "ArborAddPre"
---| "ArborAddPost"
---| "ArborDeletePre"
---| "ArborDeletePost"
---| "ArborSwitchPre"
---| "ArborSwitchPost"
---| "ArborMovePre"
---| "ArborMovePost"

---## Internal Config
---> Strongly typed to suppress warnings
---@class arbor.config.internal
---@field select arbor.select.provider
---@field input arbor.input.provider
---@field notify arbor.config.notify.internal
---@field settings arbor.config.settings.internal
---@field git arbor.config.git.internal
---@field worktree arbor.config.worktree.internal
---@field actions arbor.config.actions
---@field hooks arbor.hooks
---@field autocmds arbor.autocmd[]

---@class arbor.config.notify.internal
---@field enabled boolean
---@field level integer
---@field opts table

---@class arbor.config.settings.internal
---@field global arbor.opts
---@field add arbor.opts.add
---@field delete arbor.opts.delete
---@field switch arbor.opts.switch
---@field move arbor.opts.move

---@class arbor.config.actions.internal : arbor.config.actions
---@field preset arbor.actions.preset | arbor.actions.preset[]
---@field prefix string

---@class arbor.config.git.internal
---@field binary string
---@field main_branch string | string[]

---@class arbor.config.worktree.internal
---@field normal arbor.config.worktree_spec.internal
---@field bare arbor.config.worktree_spec.internal

---@class arbor.config.worktree_spec.internal
---@field style arbor.worktree.style
---@field path arbor.config.worktree.path
