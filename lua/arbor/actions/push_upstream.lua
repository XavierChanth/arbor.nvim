---@class arbor.action.push_upstream.opts
---@field workdir? arbor.action.push_upstream.workdir
---@field quite? boolean

---@alias arbor.action.push_upstream.workdir
---| "cwd"
---| "new_path"

---@param info? arbor.git.info
---@param opts? arbor.action.push_upstream.opts
---@return arbor.git.info | nil
return function(info, opts)
	opts = vim.tbl_extend("force", {
		workdir = "new_path",
		quiet = false,
	}, opts or {})

	if not info or not info.branch_info then
		if not opts.quiet then
			require("arbor._lib.notify").warn("Push upstream failed: branch info missing")
		end
		return
	end
	if opts.workdir == "new_path" and not info.new_path then
		if not opts.quiet then
			require("arbor._lib.notify").warn("Push upstream failed: new path not set")
		end
		return
	end
	if info.branch_info.refname:find("^refs/heads/") then
		return
	end

	local job = require("arbor.git").job({
		args = { "push", "-u", info.branch_info.refname },
		cwd = opts.workdir == "new_path" and info.new_path or info.cwd,
		enabled_recording = true,
		on_exit = function(job, code)
			if not opts.quiet and code ~= 0 then
				require("arbor._lib.notify").warn(table.concat(job:stderr_result(), "\n"))
			end
		end,
	})
	job:sync()
end
