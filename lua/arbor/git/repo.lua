local M = {}

function M.is_bare_job(path)
	return require("plenary.job"):new({
		command = require("arbor.config").git.binary,
		args = { "rev-parse", "--is-bare-repository" },
		cwd = path,
		enabled_recording = true,
	})
end

function M.common_dir_job(path)
	return require("plenary.job"):new({
		command = require("arbor.config").git.binary,
		args = { "rev-parse", "--git-common-dir" },
		cwd = path,
		enabled_recording = true,
	})
end

---@alias arbor.git.repo.type
---| "bare"
---| "normal"

---@type table<string, arbor.git.repo.type?>
local repo_type_cache = {}

---@type table<string, string?>
local common_dir_cache = {}

---@alias arbor.git.repo.base.resolver function(path: string):string
---@class arbor.git.repo.base
---@field resolve function(): string?
---@field relative_common arbor.git.repo.base.resolver
---@field relative_cwd arbor.git.repo.base.resolver
---@field absolute arbor.git.repo.base.resolver
M.base = {}

function M.base.resolve()
	local cwd, _, err_msg = vim.uv.cwd()
	if cwd == nil then
		require("arbor.util.notify").error(err_msg or "Failed to determine cwd")
		return
	end
	-- Start is_bare_job and common_dir_job in parallel if necessary
	local repo_type = repo_type_cache[cwd]
	local is_bare_job = nil
	if repo_type == nil then
		is_bare_job = M.is_bare_job(cwd)
		is_bare_job:add_on_exit_callback(vim.schedule_wrap(function(job, code)
			if code ~= 0 then
				require("arbor.util.notify").error(job:stderr_result()[1])
				return
			end
			repo_type = job.result[1] == "true" and "bare" or "normal"
			repo_type_cache[cwd] = repo_type
		end))
		is_bare_job:start()
	end

	local common_dir = common_dir_cache[cwd]
	local common_dir_job = nil
	if common_dir == nil then
		common_dir_job = M.common_dir_job(cwd)
		common_dir_job:add_on_exit_callback(function(job, code)
			if code ~= 0 then
				require("arbor.util.notify").error(job:stderr_result()[1])
				return
			end
			common_dir = job.result[1]
			common_dir_cache[cwd] = common_dir
		end)
		common_dir_job:start()
	end

	-- wait for repo_type
	if repo_type == nil then
		local finished, job = pcall(is_bare_job--[[@as Job]].wait, is_bare_job)
		if not finished or not job then
			require("arbor.util.notify").error("git rev-parse job timeout")
			return
		end
	end

	-- validate worktree config for repo_type
	local config = require("arbor.config").worktree[repo_type] --[[@as arbor.config.worktree]]
	if not config.style or not config.path then
		require("arbor.util.notify").error(
			"Malformed arbor config: opts.worktree." .. repo_type .. " contains a null value for a required field"
		)
		return
	end

	-- wait for common dir if needed
	if common_dir == nil and config.style == "relative_common" then
		local finished, job = pcall(common_dir_job--[[@as Job]].wait, common_dir_job)
		if not finished or not job then
			require("arbor.util.notify").error("git rev-parse job timeout")
			return
		end
	end

	if type(config.path) == "function" then
		config.path = config.path(repo_type)
	end

	local path = M.base[config.style](config.path --[[@as string]], common_dir)
	return require("arbor.util.path").realpath(path)
end

function M.base.relative_common(path, common_dir)
	return common_dir .. "/" .. path
end

---@return string?
function M.base.relative_cwd(path)
	local cwd = vim.uv.cwd()
	if cwd == nil then
		require("arbor.util.notify").error("vim.uv.cwd() returned nil")
		return
	end
	return cwd .. "/" .. path
end

function M.base.absolute(path)
	return path
end

return M
