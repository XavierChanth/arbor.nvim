---@meta
---# Arbor type definitions

---@class arbor

---##Config
---> Implicitly type to supress warnings for the user
---@class arbor.config
---@field apply_recommended? boolean
---@field select? arbor.select.provider
---@field input? arbor.input.provider
---@field notify? arbor.config.notify
---@field settings? arbor.config.settings
---@field git? arbor.config.git
---@field worktree? arbor.config.worktree
---@field actions? arbor.config.actions
---@field hooks? arbor.hooks
---@field events? arbor.event[]
---@field highlight? arbor.highlight

---@class arbor.highlight
---@field action? string
---@field branch? string

---@class arbor.config.notify
---@field enabled? boolean
---@field level? integer
---@field opts? table
---@field lib? boolean

---@class arbor.config.settings
---@field add? arbor.opts.add
---@field remove? arbor.opts.remove
---@field pick? arbor.opts.pick

---@class arbor.config.actions
---@field add? table<string, arbor.action>
---@field remove? table<string, arbor.action>
---@field pick? table<string, arbor.action>

---@class arbor.config.git
---@field binary? arbor.config.git.binary
---@field main_branch? string | string[]

---@alias arbor.config.git.binary
---| string
---| function(): string

---@class arbor.config.worktree
---@field normal? arbor.config.worktree_spec
---@field bare? arbor.config.worktree_spec

---@class arbor.config.worktree_spec
---@field base? arbor.worktree.base
---@field path? arbor.config.worktree.path

---@alias arbor.select.provider
---| "vim"       Use vim.ui.select
---| "telescope" Use telescope.nvim
---| "fzf"       Use fzf-lua

---@alias arbor.input.provider
---| "vim" Use vim.ui.input

---@alias arbor.config.worktree.path
---| string
---| function(spec: arbor.git.info): string

---## Core features

---@class arbor.opts
---@field hooks? arbor.hook_pair
---@field preserve_default_hooks? boolean
---@field select_opts? table opts table for vim.ui.select/telescope/fzf
---@field show_actions? boolean
---@field branch_pattern? string

---@class arbor.opts.select
---@field prompt? string
---@field format_item? arbor.opts.select.format_item
---@field kind? string

---@alias arbor.opts.select.format_item
---| function(item: arbor.item): string

---@class arbor.opts.add : arbor.opts
---@field branch_style? arbor.opts.add.branch_style
---@field path_style? arbor.opts.add.path_style
---@field path_input_opts? table gets passed to vim.ui.input for path
---@field branch_input_opts? table gets passed to vim.ui.input for new branch
---@field on_existing? arbor.action | false
---@field on_add_failed? arbor.core.add.on_add_failed
---@field show_remote_branches? boolean

---@alias arbor.core.add.on_add_failed
---| function(info: arbor.git.info, branch: string)

---@alias arbor.core.add
---| function(opts: arbor.opts.add|nil)

---@alias arbor.core.pick
---| function(opts: arbor.opts.pick|nil)

---@alias arbor.core.remove
---| function(opts: arbor.opts.remove|nil)

---@class arbor.opts.remove :arbor.opts
---@field force? boolean

---@class arbor.opts.pick : arbor.opts
---@field show_remote_branches? boolean

---@alias arbor.opts.add.path_style
---| "prompt"       -- Prompt via vim.ui.input
---| "same"         -- Use the short ref name (e.g. origin/<branch>)
---| "basename"     -- Use the basename of the ref (if you have slashes in your branch name, it will only take the last part)
---| "smart"        -- Tries to guess the remote to strip and strip it
---| "path"         -- Uses the path resolution for the branch name
---| function(git_info: arbor.git.info, local_branches?: arbor.git.branch[]): string

---@alias arbor.opts.add.branch_style
---| "path"    -- Use resolved path as the branch name
---| "prompt"  -- Input branch name
---| function(git_info: arbor.git.info, local_branches?: arbor.git.branch[]): string

---@alias arbor.feature
---| "add"
---| "remove"
---| "pick"

---@alias arbor.auprefix
---| "ArborAdd"
---| "ArborRemove"
---| "ArborPick"

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
---@field operation_opts? arbor.opts
---@field branch string
---@field cwd string
---@field toplevel string
---@field repo_type arbor.git.repo_type
---@field common_dir string
---@field resolved_base? string
---@field branch_info? arbor.git.branch
---@field new_path? string
---@field new_branch? string

---@alias arbor.git.repo_type
---| "bare"
---| "normal"

---@alias arbor.worktree.base
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
---@field pattern? string | string[]
---@field cwd? string
---@field include_remote_branches boolean?

---## Extensions

---###Actions

---@alias arbor.action
---| function(info: arbor.git.info, ...: any): arbor.git.info|nil

---### Hooks

---@class arbor.hook_pair
---@field pre? arbor.hooks.pre
---@field post? arbor.hooks.post

---@class arbor.hooks
---@field pre_add? arbor.hooks.pre
---@field post_add? arbor.hooks.post
---@field pre_remove? arbor.hooks.pre
---@field post_remove? arbor.hooks.post
---@field pre_pick? arbor.hooks.pre
---@field post_pick? arbor.hooks.post

---@alias arbor.hooks.pre arbor.action
---@alias arbor.hooks.post arbor.action

---###Autocommands

---@alias arbor.event
---| "ArborAddPre"
---| "ArborAddPost"
---| "ArborRemovePre"
---| "ArborRemovePost"
---| "ArborPickPre"
---| "ArborPickPost"

---## Internal Config
---> Strongly typed to suppress warnings internally

---@class arbor.config.internal
---@field select arbor.select.provider
---@field input arbor.input.provider
---@field notify arbor.config.notify.internal
---@field settings arbor.config.settings.internal
---@field git arbor.config.git.internal
---@field worktree arbor.config.worktree.internal
---@field actions arbor.config.actions
---@field hooks arbor.hooks
---@field events arbor.event[]
---@field highlight arbor.highlight.internal

---@class arbor.highlight.internal
---@field action string
---@field branch string

---@class arbor.config.notify.internal
---@field enabled boolean
---@field level integer
---@field opts table
---@field lib boolean

---@class arbor.config.settings.internal
---@field add arbor.opts.add.internal
---@field remove arbor.opts.remove
---@field pick arbor.opts.pick

---@class arbor.opts.internal : arbor.opts
---@field hooks arbor.hook_pair
---@field preserve_default_hooks boolean

---@class arbor.opts.add.internal : arbor.opts.add
---@field show_remote_branches boolean
---@field branch_style arbor.opts.add.branch_style
---@field path_style arbor.opts.add.path_style

---@class arbor.opts.select.internal
---@field prompt string
---@field format_item? arbor.opts.select.format_item
---@field kind? string

---@class arbor.config.git.internal
---@field binary string
---@field main_branch string | string[]

---@class arbor.config.worktree.internal
---@field normal arbor.config.worktree_spec.internal
---@field bare arbor.config.worktree_spec.internal

---@class arbor.config.worktree_spec.internal
---@field base arbor.worktree.base
---@field path arbor.config.worktree.path
