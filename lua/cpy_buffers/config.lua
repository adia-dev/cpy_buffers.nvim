local M = {}

M.defaults = {
	keymaps = {
		open_picker = "<leader>fc",
		toggle_selection = "<TAB>",
		fast_copy_all = "<leader>fa",
		toggle_all = "<leader>ta",
		invert_selection = "<leader>iv",
	},
	hide_gitignored_files = true,
	prompt_title = "Cpy Buffers",
	additional_rg_options = "",
}

M.state = {
	hide_gitignored_files = M.defaults.hide_gitignored_files,
	rg_options = M.defaults.additional_rg_options,
}

function M.setup(user_config)
	M.config = vim.tbl_deep_extend("force", {}, M.defaults, user_config or {})

	M.state.rg_options = M.config.additional_rg_options
	M.state.hide_gitignored_files = M.config.hide_gitignored_files
end

function M.get_config()
	return M.config
end

function M.get_state()
	return M.state
end

-- toggles/update
-- TODO: maybe use this fn directly instead of using an indirection
function M.toggle_gitignore()
	M.state.hide_gitignored_files = not M.state.hide_gitignored_files
end

function M.update_rg_options(new_options)
	M.state.rg_options = new_options
end

return M
