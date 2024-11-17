if vim.g.loaded_arbor_nvim == 1 then
	return
end
vim.g.loaded_arbor_nvim = 1

vim.api.nvim_create_user_command("Arbor", function(opts)
	require("arbor").run(unpack(opts.fargs))
end, {
	nargs = "*",
	range = true,
})
