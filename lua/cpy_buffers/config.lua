local M = {}

M.defaults = {
	register = "+", -- "+" Copy to the host machine clipboard
	selection_indicator = "✔", -- Icon for selected entries
	selection_caret = "➜ ", -- Icon for the selection caret
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
	highlights = {
		multi_selection = {
			guifg = "#7aa2f7", -- Brighter blue for active selection
			guibg = "#292e42", -- Slightly lighter gray-blue for active background
		},
	},
	log = {
		use_notify = true,
		level = vim.log.levels.DEBUG,
	},
	-- Change the layout of the picker
	-- layout_config = {
	-- 	width = 0.8,
	-- 	height = 0.9,
	-- 	prompt_position = "top",
	-- 	preview_cutoff = 120,
	-- 	horizontal = {
	-- 		preview_width = 0.6,
	-- 	},
	-- },
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

	local highlight_cfg = M.config.highlights.multi_selection
	local highlight_cmd =
		string.format("highlight TelescopeMultiSelection guifg=%s guibg=%s", highlight_cfg.guifg, highlight_cfg.guibg)
	vim.cmd(highlight_cmd)
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
