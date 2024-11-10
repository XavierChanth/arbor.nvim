---@class arbor.git.branch
local M = {}

-- Parts of get_branches are referenced from telescope.nvim and subject to the following license:
-- Copyright (c) 2020-2021 nvim-telescope
--
-- Referenced code:
-- https://github.com/nvim-telescope/telescope.nvim/blob/85922dde3767e01d42a08e750a773effbffaea3e/lua/telescope/builtin/__git.lua#L246

---@class arbor.git.branch_info
---@field head boolean
---@field main_branch boolean?
---@field refname string
---@field upstream string?
---@field worktreepath string?
---@field displayname string

---@class arbor.git.get_branches_opts
---@field pattern? string
---@field cwd? string
---@field include_remote_branches boolean?

---@param opts? arbor.git.get_branches_opts
---@return arbor.git.branch_info[]?, arbor.git.branch_info[]?, arbor.git.branch_info[]?
function M.get_branches(opts)
	opts = opts or {}
	local format = "%(HEAD)" .. "%(refname)" .. "%(upstream:lstrip=2)" .. "%(worktreepath)"

	local git_args = {
		"for-each-ref",
		"--perl",
		"--format",
		format,
		"--sort",
		"-authordate",
		opts.pattern,
	}

	local job = require("plenary.job"):new({
		command = require("arbor.config").git.binary,
		args = git_args,
		cwd = opts.cwd or require("arbor.lib.path").cwd(),
		enabled_recording = true,
	})

	local res, code = job:sync()
	if code ~= 0 then
		return
	end

	local unescape_single_quote = function(v)
		return string.gsub(v, "\\([\\'])", "%1")
	end
	---@type arbor.git.branch_info[]
	local priority_branches = {}
	local local_branches = {}
	local remote_branches = {}
	local main_branches = require("arbor.config").git.main_branch or {}
	if type(main_branches) == "string" then
		main_branches = { main_branches }
	end

	local parse_line = function(line)
		local fields = vim.split(string.sub(line, 2, -2), "''")
		local entry = {
			head = fields[1] == "*",
			refname = unescape_single_quote(fields[2]),
			upstream = unescape_single_quote(fields[3]),
			worktreepath = unescape_single_quote(fields[4]),
		}

		local prefix
		if vim.startswith(entry.refname, "refs/remotes/") then
			if opts.include_remote_branches then
				prefix = "refs/remotes/"
			else
				return
			end
		elseif vim.startswith(entry.refname, "refs/heads/") then
			prefix = "refs/heads/"
		else
			return
		end
		entry.displayname = string.sub(entry.refname, string.len(prefix) + 1)

		-- priority sorting
		if entry.head then
			table.insert(priority_branches, 1, entry)
			return
		end

		for _, branch in ipairs(main_branches) do
			if branch == entry.displayname then
				entry.main_branch = true
				priority_branches[#priority_branches] = entry
				return
			end
		end
		if not entry.upstream or string.len(entry.upstream) == 0 then
			local_branches[#local_branches + 1] = entry
		else
			remote_branches[#remote_branches + 1] = entry
		end
	end

	for _, line in ipairs(res) do
		parse_line(line)
	end

	return priority_branches, local_branches, remote_branches
end

return M
