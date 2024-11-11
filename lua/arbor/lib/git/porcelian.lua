---@class arbor.git.__porcelain
local M = {}

function M.fetch_sync(base_spec, remote, branch, local_name)
	local job = require("plenary.job"):new({
		command = require("arbor.config").git.binary,
		args = { "fetch", remote, branch .. ":" .. local_name },
		cwd = base_spec.common_dir or require("arbor.lib.path").cwd(),
		enabled_recording = false,
	})

	local _, code = job:sync()
	return code == 0
end
return M
