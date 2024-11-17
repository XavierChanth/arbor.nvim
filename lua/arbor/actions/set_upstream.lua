---@class arbor.action.set_upstream.opts
---@field workdir? arbor.action.set_upstream.workdir
---@field quiet? boolean
---@field push_if_from_local? boolean

---@alias arbor.action.set_upstream.workdir
---| "cwd"
---| "new_path"

---@param info? arbor.git.info
---@param opts? arbor.action.set_upstream.opts
---@return arbor.git.info | nil
return function(info, opts)
	opts = vim.tbl_extend("force", {
		workdir = "new_path",
		quiet = false,
		push_if_from_local = true,
	}, opts or {})

	if not info or not info.branch_info then
		if not opts.quiet then
			require("arbor._lib.notify").warn("Set upstream failed: branch info missing")
		end
		return
	end
	if opts.workdir == "new_path" and not info.new_path then
		if not opts.quiet then
			require("arbor._lib.notify").warn("Set upstream failed: new path not set")
		end
		return
	end

	local args
	if info.branch_info.refname:find("^refs/heads/") then
		if not opts.push_if_from_local or not info.branch_info.upstream then
			return
		end
		local upstream = info.branch_info.upstream --[[@as string]]
		upstream = string.gsub(upstream, string.format("/%s$", info.branch_info.display_name), "", 1)
		args = { "push", "-u", upstream, info.new_branch }
	else
		args = { "branch", "-u", info.branch_info.display_name }
	end

	local job = require("arbor.git").job({
		args = args,
		cwd = opts.workdir == "new_path" and info.new_path or info.cwd,
		enabled_recording = true,
		on_exit = function(job, code)
			if not opts.quiet and code ~= 0 then
				require("arbor._lib.notify").warn(table.concat(job:stderr_result(), "\n"))
			end
		end,
	})

	---@diagnostic disable-next-line: undefined-field
	job:sync()
end
