---@alias arbor.select
---| function(items: arbor.item[], opts: table, cb: function(item: core.item|nil, idx: integer|nil))

---@param items arbor.item[]
---@param opts table
---@param cb function(item: core.item|nil, idx: integer|nil)
local function telescope(items, opts, cb)
	opts = opts or {}

	local displayer = require("telescope.pickers.entry_display").create({
		separator = " : ",
		items = {
			{ width = string.len("action") },
			{ remaining = true },
		},
	})

	local make_display = function(entry)
		local hl = require("arbor.config").highlight
		local type_hl = hl.branch
		if entry.type == "action" then
			type_hl = hl.action
		end

		return displayer({
			{ entry.type, type_hl },
			{ entry.label },
		})
	end

	local make_entry = function(item)
		item.value = item
		item.ordinal = item.label
		item.display = make_display
		return require("telescope.make_entry").set_default_entry_mt(item, opts)
	end

	local finder = require("telescope.finders").new_table({
		results = items,
		entry_maker = make_entry,
	})
	require("telescope.pickers")
		.new(opts, {
			prompt_title = opts.prompt or "Worktrees",
			finder = finder,
			sorter = require("telescope.config").values.generic_sorter(opts),
			initial_mode = "insert",
			attach_mappings = function(prompt_bufnr)
				local actions = require("telescope.actions")
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = require("telescope.actions.state").get_selected_entry()
					cb(selection.value)
				end)
				return true
			end,
		})
		:find()
end

local function fzf_line(type, label)
	return string.format("%s : %s", type, label)
end

---@param items arbor.item[]
---@param opts table
---@param cb function(item: core.item|nil, idx: integer|nil)
local function fzf(items, opts, cb)
	local lines = {}
	local entries = {}
	for _, item in ipairs(items) do
		local hl = require("arbor.config").highlight
		local type_hl = hl.branch
		if item.type == "action" then
			type_hl = hl.action
		end
		local type = require("fzf-lua.utils").ansi_from_hl(type_hl, item.type)
		local line_hl = fzf_line(type, item.label)
		lines[#lines + 1] = line_hl

		local line_nohl = fzf_line(item.type, item.label)
		entries[line_nohl] = item
	end
	if opts.prompt then
		opts.prompt = opts.prompt .. " "
	end
	opts = vim.tbl_deep_extend("force", {
		prompt = "Worktrees",
		actions = {
			enter = function(selected)
				cb(entries[selected[1]])
			end,
		},
	}, opts or {})

	require("fzf-lua").fzf_exec(lines, opts)
end

---@type table<arbor.select.provider, arbor.select>
local providers = {
	vim = function(...)
		vim.ui.select(...)
	end,
	telescope = telescope,
	fzf = fzf,
}

---@type arbor.select
return function(items, opts, cb)
	local key = require("arbor.config").select
	return providers[key](items, opts, cb)
end
