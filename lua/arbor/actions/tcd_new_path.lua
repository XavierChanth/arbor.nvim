---@param info? arbor.git.info
---@return arbor.git.info | nil
return function(info)
	if not info or not info.new_path then
		require("arbor._lib.notify").warn("tcd new path failed: new path not set")
		return
	end
	vim.cmd("tcd " .. info.new_path)
end
