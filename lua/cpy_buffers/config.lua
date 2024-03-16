local M = {}

M.defaults = {
	keymaps = {
		open_picker = "<leader>fc",
		toggle_selection = "<TAB>",
		fast_copy_all = "<C-a>",
		toggle_all = "<C-t>",
		activate_all_visible = "<C-v>",
		deactivate_all_visible = "<C-d>",
		invert_selection = "<C-r>",
		toggle_hidden = "<leader>g",
	},
	label_buffers = true,
	-- format string for buffer labels at the top of each buffer
	-- %f will be replaced with the buffer's relative path to the directory
	-- %c will be replaced with the buffer's short name
	-- %a will be replaced with the buffer's absolute path
	-- TODO: %n will be replaced with the buffer's number
	-- TODO: %m will be replaced with the buffer's modified status
	-- e.g: "%n %c %m" will result in "1 init.lua [+]"
	-- e.g: "%f" will result in "lua/cpy_buffers"
	-- e.g: "// %a" will result in "// /home/user/.../lua/cpy_buffers/init.lua"
	-- e.g: "# %f" will result in "# lua/cpy_buffers"
	label_format = "# %c",
	hide_hidden_files = true,
	prompt_title = "Cpy Buffers",
	additional_rg_options = "",
}

M.state = {
	hide_hidden_files = M.defaults.hide_hidden_files,
	rg_options = M.defaults.additional_rg_options,
}

function M.setup(user_config)
	M.config = vim.tbl_deep_extend("force", {}, M.defaults, user_config or {})

	M.state.rg_options = M.config.additional_rg_options
	M.state.hide_hidden_files = M.config.hide_hidden_files
end

function M.get_config()
	return M.config
end

function M.get_state()
	return M.state
end

function M.toggle_hidden()
	M.state.hide_hidden_files = not M.state.hide_hidden_files
end

function M.toggle_label_buffers()
	M.config.label_buffers = not M.config.label_buffers
end

function M.update_label_format(new_format)
	M.config.label_format = new_format
end

function M.update_rg_options(new_options)
	M.state.rg_options = new_options
end

return M
