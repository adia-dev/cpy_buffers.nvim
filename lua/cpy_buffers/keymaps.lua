local M = {}
local keymap = vim.keymap
local config = require("cpy_buffers.config")
local picker = require("cpy_buffers.picker")

function M.setup()
	local cfg = config.get_config()
	keymap.set("n", cfg.keymaps.open_picker, picker.open_file_picker, { silent = true })
end

return M
