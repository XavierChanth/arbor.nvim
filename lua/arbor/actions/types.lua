---@meta

---@class arbor.actions.config : arbor.actions_spec
---@field preset? arbor.actions.preset | arbor.actions.preset[]
---@field prefix? string

---@class arbor.actions_spec
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
