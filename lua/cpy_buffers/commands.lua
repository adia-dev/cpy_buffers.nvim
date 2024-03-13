local config = require("cpy_buffers.config")

local M = {}

function M.change_rg_command()
	local current_rg_options = config.get_state().rg_options
	local new_command = vim.fn.input("Enter new rg command options: ", current_rg_options)
	config.update_rg_options(new_command)
end

function M.toggle_gitignore()
	config.toggle_gitignore()
end

function M.register_commands()
	vim.cmd('command! CpyBufChangeRgCommand lua require("cpy_buffers.commands").change_rg_command()')
	vim.cmd('command! CpyBufToggleGitignore lua require("cpy_buffers.commands").toggle_gitignore()')
end

return M
