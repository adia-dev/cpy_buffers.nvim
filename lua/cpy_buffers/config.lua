local M = {}

M.defaults = {
	keymaps = {
		open_picker = "<leader>cb",
		toggle_selection = "<TAB>",
		fast_copy_all = "<C-a>",
		toggle_all = "<C-t>",
		activate_all_visible = "<C-v>",
		deactivate_all_visible = "<C-d>",
		invert_selection = "<C-r>",
		toggle_hidden = "<leader>g",
		copy_to_buffer = "<C-b>",
		save_to_file = "<C-s>",
		copy_paths = "<C-p>",
	},

	display = {
		label_buffers = true,
		label_format = "-- %c --",
		prompt_title = "Cpy Buffers",
		content_separator = "\n\n",
		show_icons = true,
	},

	file_search = {
		hide_hidden_files = true,
		additional_rg_options = "",
		include_extensions = {},
		exclude_patterns = { "node_modules/*", "vendor/*" },
	},

	sorting = {
		sort_by_modification = false,
		sort_by_size = false,
		sort_by_extension = false,
		use_custom_sorter = false,
	},

	-- "+" Copy to the host machine clipboard
	register = "+",
}

-- Runtime state variables
M.state = {
	hide_hidden_files = M.defaults.file_search.hide_hidden_files,
	rg_options = M.defaults.file_search.additional_rg_options,
}

function M.setup(user_config)
	M.config = vim.tbl_deep_extend("force", {}, M.defaults, user_config or {})

	M.state.rg_options = M.config.file_search.additional_rg_options
	M.state.hide_hidden_files = M.config.file_search.hide_hidden_files
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
	M.config.display.label_buffers = not M.config.display.label_buffers
end

function M.update_label_format(new_format)
	M.config.display.label_format = new_format
end

function M.update_rg_options(new_options)
	M.state.rg_options = new_options
end

return M
