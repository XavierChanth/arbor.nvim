---@class arbor.actions
---@field add_new_branch arbor.actions.add_new_branch
---@field cd_existing_worktree arbor.action
---@field cd_new_path arbor.action
---@field copy_cache_dir arbor.actions.copy_cache_dir
---@field fetch arbor.actions.fetch
---@field pick_if_current arbor.actions.pick_if_current
---@field set_upstream arbor.actions.set_upstream
---@field tcd_existing_worktree arbor.action
---@field tcd_new_path arbor.action

---@alias arbor.actions.add_new_branch
---| function(info?: arbor.git.info, opts?:arbor.opts.add): arbor.git.info|nil

---@alias arbor.actions.fetch
---| function(info?: arbor.git.info, opts?:arbor.opts.fetch.opts): arbor.git.info|nil

---@alias arbor.actions.pick_if_current
---| function(info?: arbor.git.info, opts?:arbor.opts.pick): arbor.git.info|nil

---@alias arbor.actions.set_upstream
---| function(info?: arbor.git.info, opts?:arbor.opts.set_upstream.opts): arbor.git.info|nil

---@alias arbor.actions.copy_cache_dir
---| function(info? arbor.git.info, opts? arbor.action.copy_cache_dir.opts): arbor.git.info | nil

local M = {}

setmetatable(M, {
	__index = function(_, k)
		return require("arbor.actions." .. k)
	end,
})

return M
