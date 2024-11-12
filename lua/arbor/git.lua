---Public facing library for running commands in actions
---User's should use this over running anything in arbor.lib
---@class arbor.git
local M = {}

---@class ArborGitJob : Job
---@field command? string uses git.binary specified in config by default

---Provides a Plenary Job.
---The command field is optional, it will automatically set it to the git.binary
---value from your config if you don't specify it.
---@param opts ArborGitJob
---@return Job
function M.job(opts)
	opts.command = opts.command or require("arbor.config").git.binary
	return require("plenary.job")(opts)
end

---Get the arbor.git.info object for the cwd (optional)
---@param cwd? string
---@return arbor.git.info?
function M.info(cwd)
	return require("arbor._lib.git.info").resolve(cwd)
end

return M
