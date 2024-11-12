---@class arbor.action.fetch.opts
---@field fetch_args? string[]
---@field cwd? string

---@param info? arbor.git.info
---@param opts? arbor.action.fetch.opts
---@return arbor.git.info | nil
return function(info, opts)
	opts = opts or {}
	local args = opts.fetch_args or {}
	table.insert(args, 1, "fetch")
	local job = require("arbor.git").job({
		args = args,
		cwd = opts.cwd or (info and info.common_dir),
		enabled_recording = true,
		on_exit = function(job, code)
			if code ~= 0 then
				require("arbor._lib.notify").warn(table.concat(job:stderr_result(), "\n"))
			end
		end,
	})
	job:sync()
end
