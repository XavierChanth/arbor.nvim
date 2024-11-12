---@class arbor.core.common
local M = {}

---@class arbor.core_events
---@field hookpre? arbor.hooks.pre
---@field hookpost? arbor.hooks.post
---@field aupre? function
---@field aupost? function

local function identity(...)
	return ...
end

---@param key arbor.feature
---@param autocmd_prefix arbor.auprefix
---@param opts? arbor.opts
---@return arbor.core_events
function M.get_events(key, autocmd_prefix, opts)
	opts = opts or {}
	opts.hooks = opts.hooks or {}
	local config = require("arbor.config")

	-- Setup hooks
	local hookpre = "pre_" .. key
	local hookpost = "post_" .. key

	---@type arbor.core_events
	local res

	if opts.preserve_default_hooks then
		res = {
			hookpre = function(git_info)
				if config.hooks[hookpre] then
					git_info = config.hooks[hookpre](git_info) or git_info
				end
				if opts.hooks.pre then
					git_info = opts.hooks.pre(git_info) or git_info
				end
				return git_info
			end,
			hookpost = function(git_info)
				if config.hooks[hookpost] then
					git_info = config.hooks[hookpost](git_info) or git_info
				end
				if opts.hooks.post then
					git_info = opts.hooks.post(git_info) or git_info
				end
				return git_info
			end,
		}
	else
		res = {
			hookpre = opts.hooks.pre or config.hooks[hookpre] and config.hooks[hookpost] or identity,
			hookpost = opts.hooks.post or config.hooks[hookpost] and config.hooks[hookpost] or identity,
		}
	end

	-- setup autocmds
	local aupre = autocmd_prefix .. "Pre"
	local aupost = autocmd_prefix .. "Post"
	for _, ev in ipairs(config.events) do
		if ev == aupre then
			res["aupre"] = function(git_info)
				vim.api.nvim_exec_autocmds(aupre, {
					group = require("arbor.extensions.hooks").get_augroup(),
					data = git_info,
				})
			end
		elseif ev == aupost then
			res["aupost"] = function(git_info)
				vim.api.nvim_exec_autocmds(aupre, {
					group = require("arbor.extensions.hooks").get_augroup(),
					data = git_info,
				})
			end
		end
	end

	return res
end

---@param actions table<string, arbor.action>
---@param items? arbor.item[]
---@return arbor.item[]
function M.append_actions_to_items(actions, items)
	items = items or {}
	for id, callback in pairs(actions) do
		items[#items + 1] = {
			id = id,
			type = "action",
			label = id,
			action_callback = callback,
		}
	end
	return items
end

---@param branches? arbor.git.branch[]
---@param items arbor.item[]
---@return arbor.item[]
function M.add_branches_to_items(branches, items)
	items = items or {}
	if branches ~= nil then
		for _, entry in ipairs(branches) do
			local index = 1
			if not entry.head then
				index = #items + 1
			end
			table.insert(items, index, {
				id = entry.refname,
				label = entry.display_name,
				type = "branch",
				branch_info = entry,
			})
		end
	end
	return items
end

---@param item arbor.item
---@return string
function M.generate_item_format(item)
	return item.type .. " : " .. item.label
end

---@param base_spec arbor.git.info
---@param item arbor.item
---@param idx integer
---@return boolean?
function M.handle_if_action(base_spec, item, idx)
	if item.type == "action" then
		item.action_callback(base_spec)
		return true
	end
	return false
end

return M
