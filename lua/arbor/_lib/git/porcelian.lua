---@class arbor.lib.git.porcelain
local M = {}

---@return Job
local function fetch_job(base_spec, remote, branch, local_name)
	return require("plenary.job"):new({
		command = require("arbor.config").git.binary,
		args = { "fetch", remote, branch .. ":" .. local_name },
		cwd = base_spec.common_dir or require("arbor._lib.path").cwd(),
		enabled_recording = false,
	})
end

-- TODO: Typedefs

function M.fetch_sync(base_spec, remote, branch, local_name)
	local _, code = fetch_job(base_spec, remote, branch, local_name):sync()
	return code == 0
end

function M.fetch_in_background(base_spec, remote, branch, local_name)
	local job = fetch_job(base_spec, remote, branch, local_name)
	job:after_failure(function()
		require("arbor").lib.notify.warn("Background job `git fetch` failed")
	end)
	job:start()
end

return M
