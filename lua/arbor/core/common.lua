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

---@param key arbor.core_key
---@param autocmd_prefix arbor.core_autocmd_prefix
---@param opts? arbor.core_opts
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
			hookpre = function(spec)
				if config.hooks[hookpre] and config.hooks[hookpre] then
					spec = config.hooks[hookpre](spec)
				end
				if opts.hooks.pre then
					spec = opts.hooks.pre(spec)
				end
				return spec
			end,
			hookpost = function(spec)
				if config.hooks[hookpost] and config.hooks[hookpost] then
					spec = config.hooks[hookpost](spec)
				end
				if opts.hooks.post then
					spec = opts.hooks.post(spec)
				end
				return spec
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
			res["aupre"] = function(base_spec)
				vim.api.nvim_exec_autocmds(aupre, {
					group = require("arbor.events").get_augroup(),
					data = base_spec,
				})
			end
		elseif ev == aupost then
			res["aupost"] = function(base_spec)
				vim.api.nvim_exec_autocmds(aupre, {
					group = require("arbor.events").get_augroup(),
					data = base_spec,
				})
			end
		end
	end

	return res
end

---@param actions table<string, arbor.action>
---@param prefix string prefix to strip from label
---@param items? arbor.core_item[]
---@return arbor.core_item[]
function M.append_actions_to_items(actions, prefix, items)
	items = items or {}
	for id, callback in pairs(actions) do
		items[#items + 1] = {
			id = id,
			type = "action",
			label = id:sub(#prefix + 1),
			action_callback = callback,
		}
	end
	return items
end

---@param branches? arbor.git.branch_info[]
---@param items arbor.core_item[]
---@return arbor.core_item[]
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
				label = entry.displayname,
				type = "branch",
				branch_info = entry,
			})
		end
	end
	return items
end

---@param item arbor.core_item
---@return string
function M.generate_item_format(item)
	return item.type .. " : " .. item.label
end

---@param base_spec arbor.git.internal_base_spec
---@param item? arbor.core_item
---@param idx? integer
---@return boolean?
function M.handle_if_action(base_spec, item, idx)
	if not item or not idx then
		return
	end

	if item.type == "action" then
		item.action_callback(base_spec)
		return
	end
	return true
end

return M
