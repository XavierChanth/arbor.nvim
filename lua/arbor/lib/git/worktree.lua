---@class arbor.git.__worktree
local M = {}

---@param path? string
---@return nil
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
---@param git_info arbor.git.info
---@param path string
---@param branch string?
---@return boolean success
function M.add(git_info, path, branch)
	P(git_info)
	local args = {
		"worktree",
		"--guess-remote",
		path,
		-- so I did some testing, and the fully qualified refname will trigger ambiguity checks
		-- but, the display_name will automatically be inferred if possible, so it's less likely to fail
		git_info.branch_info.display_name,
	}
	-- git will automatically try to guess the branch based on path so it's optional
	if branch then
		table.insert(args, 3, branch)
		table.insert(args, 3, "-b")
	end

	local _, code = require("plenary.job")
		:new({
			command = require("arbor.config").git.binary,
			args = args,
			cwd = git_info.common_dir,
			enabled_recording = true,
			---@param job Job
			after_failure = function(job)
				require("arbor").lib.notify.error(table.concat(job:stderr_result(), "\n"))
			end,
		})
		:sync()
	return code == 0
end

function M.switch(opts) end

return M
