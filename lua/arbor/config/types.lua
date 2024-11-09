---@meta

---@class arbor.config_module : arbor.config
---@field set function(opts? arbor.config): arbor.config

---@class arbor.config
---@field picker? arbor.picker.providers
---@field input? arbor.input.providers
---@field git? arbor.config.git
---@field worktree? arbor.config.worktree_spec
---@field actions? arbor.config.actions
---@field hooks? arbor.config.hooks

---@class arbor.config.git
---@field library? arbor.config.git.library
---@field binary? string
---@field main_branch? string | string[]

---@alias arbor.config.git.library
---| "arbor" Use built-in arbor

---@class arbor.config.worktree_spec
---@field normal arbor.config.worktree
---@field bare arbor.config.worktree

---@class arbor.config.worktree
---@field style? arbor.config.worktree.style
---@field path? string

---@alias arbor.config.worktree.style
---| "relative_common"
---| "relative_cwd"
---| "absolute"

---@class arbor.config.actions : arbor.actions_spec
---@field preset? arbor.actions.preset | arbor.actions.preset[]
---@field prefix? string

---@class arbor.config.hooks
---@field pre_add? arbor.hooks.pre.add
---@field post_add? arbor.hooks.post.add
---@field pre_delete? arbor.hooks.pre.delete
---@field post_delete? arbor.hooks.post.delete
---@field pre_switch? arbor.hooks.pre.switch
---@field post_switch? arbor.hooks.post.switch
---@field pre_move? arbor.hooks.pre.move
---@field post_move? arbor.hooks.post.move
