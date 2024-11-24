local config = require("cpy_buffers.config")
local logger = require("cpy_buffers.logger")

local M = {}

function M.change_rg_command()
	local current_rg_options = config.get_state().rg_options
	local new_command = vim.fn.input("Enter new rg command options: ", current_rg_options)
	if new_command ~= "" then
		config.update_rg_options(new_command)
		logger.info("Updated rg options to: " .. new_command)
	else
		logger.warn("No rg options entered. Keeping current options.")
	end
end

function M.change_label_format()
	local current_label_format = config.get_config().label_format
	local new_format = vim.fn.input("Enter new label format: ", current_label_format)
	config.update_label_format(new_format)
end

function M.toggle_hidden()
	config.toggle_hidden()
end

function M.register_commands()
	vim.cmd('command! CpyBufChangeRgCommand lua require("cpy_buffers.commands").change_rg_command()')
	vim.cmd('command! CpyBufToggleGitignore lua require("cpy_buffers.commands").toggle_hidden()')
	vim.cmd('command! CpyBufChangeLabelFormat lua require("cpy_buffers.commands").change_label_format()')
end

return M
