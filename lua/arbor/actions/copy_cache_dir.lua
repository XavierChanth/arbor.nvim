---This was a request I received:
---The idea is to copy node_modules/ when you create a new worktree so you
---don't have to npm install from a blank slate

---You must pass something to opts.matches or this action will do nothing
---This action is meant to be passed to add, otherwise it doesn't make sense.

---@class arbor.action.copy_cache_dir.opts
---@field matches? string[]
---@field background? boolean defaults to true

---@param info? arbor.git.info
---@param opts? arbor.action.copy_cache_dir.opts
---@return arbor.git.info | nil
return function(info, opts)
	if not opts or not opts.matches then
		require("arbor._lib.notify").warn("copy cache dir failed: no matches defined")
		return
	end
	if not info or not info.new_path then
		require("arbor._lib.notify").warn("copy cache dir failed: no new path set")
		return
	end
	if
		not info.branch_info
		or not info.branch_info.worktree_path
		or string.len(info.branch_info.worktree_path) == 0
	then
		-- Don't notify on this one, creating from a remote branch is an expected
		-- behavior where this won't be defined
		return
	end
	if opts.background == nil then
		opts.background = true
	end
	local src_base = info.branch_info.worktree_path
	local dst_base = info.new_path
	for _, match in ipairs(opts.matches) do
		local job = require("arbor").git.job({
			command = "cp",
			args = { "-R", src_base .. "/" .. match, dst_base .. "/" .. match },
			enabled_recording = true,
			on_exit = function(job, code)
				if code ~= 0 then
					require("arbor._lib.notify").warn(
						"Failed to copy " .. match .. ":\n" .. table.concat(job:stderr_result(), "\n")
					)
				end
			end,
		})

		if opts.background then
			job:start()
		else
			job:sync()
		end
	end
end
