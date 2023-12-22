local picker = require("cpy_buffers.picker")

local M = {}

function M.setup(opts)
	opts = opts or {}
	vim.keymap.set("n", "<leader>h", picker.open_file_picker)
end

return M
