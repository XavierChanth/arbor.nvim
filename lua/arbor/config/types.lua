---@meta

---Get types

---@class arbor.config
---@field select arbor.select.provider
---@field input arbor.input.provider
---@field notify arbor.config.notify
---@field settings arbor.config.settings
---@field git arbor.config.git
---@field worktree arbor.config.worktree
---@field actions arbor.actions.config
---@field hooks arbor.hooks
---@field events arbor.event[]

---@class arbor.config.notify
---@field enabled boolean
---@field level? integer
---@field opts? table

---@class arbor.config.settings
---@field global arbor.core_opts
---@field add arbor.core.add_opts
---@field delete arbor.core.delete_opts
---@field switch arbor.core.switch_opts
---@field move arbor.core.move_opts

---@class arbor.config.git
---@field binary? string
---@field main_branch? string | string[]
---TODO add git fetch before worktree arg

---@class arbor.config.worktree
---@field normal arbor.config.worktree_spec
---@field bare arbor.config.worktree_spec

---@class arbor.config.worktree_spec
---@field style? arbor.worktree.style
---@field path? arbor.config.worktree.path

---Set types
---@class arbor.config_opts: arbor.config
---@field picker? arbor.select.provider
---@field input? arbor.input.provider
---@field git? arbor.config.git_opts
---@field worktree? arbor.config.worktree
---@field actions? arbor.actions.config
---@field hooks? arbor.hooks

---@class arbor.config.git_opts
---@field binary? string| function(): string
---@field main_branch? string | string[]
