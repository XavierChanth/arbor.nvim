---@meta

---@class arbor

---@class arbor.core_opts
---@field select? arbor.core_opts.select opts table for vim.ui.select
---@field telescope? table opts table for telescope.nvim
---@field fzf? table opts table for fzf-lua
---@field hooks? arbor.hooks.spec
---@field preserve_default_hooks? boolean default hooks defined in config always run first

local _ = vim.ui.select
---@class arbor.core_opts.select
---@field prompt? string
---@field format_item? function(item: arbor.core_item): string
---@field kind? string

---@class arbor.core.add_opts : arbor.core_opts
---@field show_remote_branches? boolean
---@field branch_pattern? string
---@field name_branch? arbor.core.add_opts.name_branch
---@field switch_if_wt_exists? boolean
---@field cd_after? boolean

---@alias arbor.core.add_opts.name_branch
---| "prompt"
---| "same"
---| "smart"
---| function(spec: arbor.hooks.post_spec, local_branches?: string[]): string

---@class arbor.core.delete_opts : arbor.core_opts
---@class arbor.core.switch_opts : arbor.core_opts
---@class arbor.core.move_opts : arbor.core_opts

---@alias arbor.core_key
---| "add"
---| "delete"
---| "switch"
---| "move"

---@alias arbor.core_autocmd_prefix
---| "ArborAdd"
---| "ArborDelete"
---| "ArborSwitch"
---| "ArborMove"

---@class arbor.core_item
---@field id string
---@field label string
---@field type arbor.core_item.type
---@field action_callback? arbor.action
---@field branch_info? arbor.git.branch_info

---@alias arbor.core_item.type
---| "action"
---| "branch"
