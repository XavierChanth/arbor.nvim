---@class arbor.lib.git.info
local M = {}

---@type table<string, arbor.git.info?>
local base_spec_cache = {}

setmetatable(M, {
	__call = M.resolve,
})

local function default_resolve(res, code, job)
	if code ~= 0 then
		require("arbor._lib.notify").warn(job:stderr_result()[1])
		return
	end
	return res[1]
end

---@generic T
---@param cwd string
---@param key string
---@param resolve? function(res: string[]|nil, code: integer, job: Job): T
---@param job_fn function(cwd: string, ...): Job
---@vararg any Args to pass to job_fn
---@return T?
local function resolve_spec_item(cwd, key, resolve, job_fn, ...)
	base_spec_cache[cwd] = base_spec_cache[cwd] or {}

	if base_spec_cache[cwd][key] then
		return base_spec_cache[cwd][key]
	end

	local job = job_fn(cwd, ...)
	local res, code = job:sync()

	base_spec_cache[cwd][key] = (resolve or default_resolve)(res, code, job)
	return base_spec_cache[cwd][key]
end

---@param cwd? string
---@return arbor.git.info?
function M.resolve(cwd)
	cwd = cwd or require("arbor._lib.path").cwd()

	if
		not resolve_spec_item(cwd, "repo_type", function(res)
			return res[1] == "true" and "bare" or "normal"
		end, M.is_bare_job)
	then
		return
	end

	if not resolve_spec_item(cwd, "common_dir", nil, M.common_dir_job) then
		return
	end

	if not resolve_spec_item(cwd, "branch", nil, M.current_branch_job) then
		return
	end

	if
		not resolve_spec_item(cwd, "toplevel", function(res, code, _)
			if code ~= 0 then
				return cwd
			end
			return res[1]
		end, M.top_level_job)
	then
		return
	end

	local spec = base_spec_cache[cwd] or {}
	spec.cwd = cwd
	-- validate worktree config for repo_type
	local config = require("arbor.config").worktree[spec.repo_type] --[[@as arbor.config.worktree_spec]]
	if not config or not config.base or not config.path then
		require("arbor._lib.notify").warn(
			"Malformed arbor config: opts.worktree." .. spec.repo_type .. " contains a null value for a required field"
		)
		return
	end

	local path = config.path

	if type(path) == "function" then
		path = path(spec)
	end

	if config.base == "absolute" then
		spec.resolved_base = path
	elseif config.base == "relative_common" then
		spec.resolved_base = require("arbor._lib.path").realpath(spec.common_dir .. "/" .. path)
	elseif config.base == "relative_cwd" then
		spec.resolved_base = require("arbor._lib.path").realpath(cwd .. "/" .. path)
	else
		return nil
	end

	return spec
end

---@param path string
---@return Job
function M.is_bare_job(path)
	return require("plenary.job"):new({
		command = require("arbor.config").git.binary,
		args = { "rev-parse", "--is-bare-repository" },
		cwd = path,
		enabled_recording = true,
	})
end

---@param path string
---@return Job
function M.common_dir_job(path)
	return require("plenary.job"):new({
		command = require("arbor.config").git.binary,
		args = { "rev-parse", "--path-format=absolute", "--git-common-dir" },
		cwd = path,
		enabled_recording = true,
	})
end

---@param path string
---@return Job
function M.current_branch_job(path)
	return require("plenary.job"):new({
		command = require("arbor.config").git.binary,
		args = { "branch", "--show-current" },
		cwd = path,
		enabled_recording = true,
	})
end

---@param path string
---@return Job
function M.top_level_job(path)
	return require("plenary.job"):new({
		command = require("arbor.config").git.binary,
		args = { "rev-parse", "--show-toplevel" },
		cwd = path,
		enabled_recording = true,
	})
end

---@return nil
function M.purge_cache()
	base_spec_cache = {}
end

return M
