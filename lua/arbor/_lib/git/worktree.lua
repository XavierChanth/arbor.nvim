---@class arbor.lib.git.worktree
local M = {}

---@param path? string
---@return boolean
function M.is_inside(path)
	local res, code = require("plenary.job")
		:new({
			command = require("arbor.config").git.binary,
			args = { "rev-parse", "--is-inside-work-tree" },
			cwd = path,
			enabled_recording = true,
		})
		:sync()

	return code == 0 and res[1] == "true"
end

---@param cwd string
---@param path string
---@param ref string
---@param branch string?
---@return boolean success
function M.add(cwd, path, ref, branch)
	local args = {
		"worktree",
		"add",
		path,
		ref,
	}

	-- git will automatically try to guess the branch based on path so it's optional
	if branch then
		table.insert(args, 3, branch)
		table.insert(args, 3, "-b")
	end

	local job = require("plenary.job"):new({
		command = require("arbor.config").git.binary,
		args = args,
		cwd = cwd,
		enabled_recording = true,
	})

	local _, code = job:sync()
	if code ~= 0 then
		require("arbor._lib.notify").error(table.concat(job:stderr_result(), "\n"))
	end

	return code == 0
end

---@param git_info arbor.git.info
---@param path string
---@param force? boolean
---@return boolean success
function M.remove(git_info, path, force)
	local args = { "worktree", "remove", path }
	if force then
		table.insert(args, 3, "-f")
	end
	local job = require("plenary.job"):new({
		command = require("arbor.config").git.binary,
		args = args,
		cwd = git_info.common_dir,
		enabled_recording = true,
	})

	local _, code = job:sync()
	if code ~= 0 then
		require("arbor._lib.notify").error(table.concat(job:stderr_result(), "\n"))
	end

	return code == 0
end

return M
