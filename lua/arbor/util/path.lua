local M = {}

-- Lazy.nvim and LazyVim don't have a proper copyright in the licenses
-- so I've provided permalinks to where the code is from

-- https://github.com/folke/lazy.nvim/blob/b1134ab82ee4279e31f7ddf7e34b2a99eb9b7bc9/lua/lazy/core/util.lua#L74
function M.norm(path)
	if path:sub(1, 1) == "~" then
		local home = vim.uv.os_homedir()
		if home == nil then
			return nil
		end
		if home:sub(-1) == "\\" or home:sub(-1) == "/" then
			home = home:sub(1, -2)
		end
		path = home .. path:sub(2)
	end
	path = path:gsub("\\", "/"):gsub("/+", "/")
	return path:sub(-1) == "/" and path:sub(1, -2) or path
end

-- https://github.com/LazyVim/LazyVim/blob/4876d1137d374af6f39661e402926220517ae4ab/lua/lazyvim/util/root.lua#L77
function M.realpath(path)
	if path == "" or path == nil then
		return nil
	end
	path = vim.uv.fs_realpath(path) or path
	return M.norm(path)
end

return M
