---@class arbor.git.remote
local M = {}

---@class arbor.git.remote.opts
---@field cwd string

---@param opts arbor.git.remote.opts
---@return string[] | nil
function M.list_remotes(opts)
	local job = require("plenary.job"):new({
		command = require("arbor.config").git.binary,
		args = { "remote" },
		cwd = opts.cwd or require("arbor.lib.path").cwd(),
		enabled_recording = true,
	})

	local res, code = job:sync()
	if code ~= 0 then
		return
	end
	return res
end

---@class arbor.git.remote.remote_opts
---@field cwd string
---@field remote string
---@field pattern? string
---@field strip_prefix? boolean

---@param opts arbor.git.remote.remote_opts
---@return string[] | nil
function M.list_refs_for_remote(opts)
	local job = require("plenary.job"):new({
		command = require("arbor.config").git.binary,
		args = { "ls-remote", "-q", "--heads", opts.remote, opts.pattern },
		cwd = opts.cwd or require("arbor.lib.path").cwd(),
		enabled_recording = true,
	})

	local res, code = job:sync()
	if code ~= 0 then
		return
	end

	local results = {}
	local pattern = ".*[ ]+"
	if opts.strip_prefix then
		pattern = pattern .. "refs/heads"
	end
	for _, line in ipairs(res) do
		results[#results + 1] = line:gsub(pattern, "", 1)
	end
	return results
end

---@param base_spec arbor.git.internal_base_spec
---@param refname string
---@return string[][]
function M.disambiguate_refnames(base_spec, refname)
	local remotes = M.list_remotes({
		cwd = base_spec.common_dir,
	}) or {}

	-- gets all branches which could be ambiguous
	-- for example remote: origin, branch: second/hello
	-- has the same refname as:
	-- remote: origin/second, branch: hello
	-- this function will list out both

	local matches = {}
	for _, remote in ipairs(remotes) do
		if refname:find("^" .. remote) then
			local branch_pattern = refname:sub(#remote + 1)
			local remote_refs = origin.list_refs_for_remote({
				cwd = base_spec.common_dir,
				remote = remote,
				strip_prefix = true,
				pattern = branch_pattern,
			})
			for _, branch in ipairs(remote_refs) do
				if branch == branch_pattern then
					matches[#matches + 1] = { remote, branch }
				end
			end
		end
	end
	return matches
end

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
