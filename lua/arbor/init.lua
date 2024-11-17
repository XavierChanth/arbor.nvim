-- core utilities
---@class arbor
---@field config arbor.config
---@field lib arbor.lib

-- core features
---@class arbor
---@field add arbor.core.add
---@field pick arbor.core.pick
---@field remove arbor.core.remove

-- extensions
---@class arbor
---@field actions arbor.actions
---@field events arbor.events
---@field git arbor.git

---@class arbor
local M = {}

local modules = {
	-- core utilities
	config = "arbor.config",
	lib = "arbor._lib",

	-- core features
	add = "arbor.core.add",
	pick = "arbor.core.pick",
	remove = "arbor.core.remove",

	-- extensions
	actions = "arbor.actions",
	events = "arbor.events",
	git = "arbor.git",
}

setmetatable(M, {
	__index = function(_, k)
		if k == "lib" and not require("arbor.config").notify.lib then
			require("arbor._lib.notify").warn(
				"Anything in arbor.lib is subject to breaking changes across minor "
					.. "updates. By using arbor.lib, you are subjecting yourself to "
					.. "these breaking changes, and you understand that the devs will "
					.. "not prioritize support for its usage.\n"
					.. "To disable this message, set notify.lib = true in your config."
			)
		end
		return require(modules[k])
	end,
})

-- TODO: support passing args here?
function M.run(cmd)
	cmd = cmd or "pick"
	local valid = { "pick", "add", "remove" }
	if vim.tbl_contains(valid, cmd) then
		require(modules[cmd])[cmd]()
	else
		require("arbor._lib.notify").warn(
			string.format("%s is not a valid command. must be on of %s", cmd, vim.inspect(valid))
		)
	end
end

---@param opts arbor.config
---@return nil
function M.setup(opts)
	require("arbor.config").set(opts)
end

return M
