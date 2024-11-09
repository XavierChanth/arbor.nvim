---@meta

---@class arbor.actions_spec
---@field add? table<string, arbor.action>
---@field delete? table<string, arbor.action>
---@field switch? table<string, arbor.action>
---@field move? table<string, arbor.action>

---@class arbor.actions.action.info
---@field branch string
---@field path string
---@field git_dir string

---@alias arbor.action
---| function(info: arbor.actions.action.info): boolean

---@alias arbor.actions.preset
---| "git"
