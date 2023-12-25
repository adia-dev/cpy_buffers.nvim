local M = {}
local keymap = vim.keymap
local config = require("cpy_buffers.config")
local picker = require("cpy_buffers.picker")
local utils = require("cpy_buffers.utils")

function M.setup()
    local cfg = config.get_config()

    keymap.set("n", cfg.keymaps.open_picker, picker.open_file_picker, { silent = true })
    keymap.set("i", cfg.keymaps.toggle_selection, function() utils.toggle_selection() end, { silent = true })
    keymap.set("n", cfg.keymaps.toggle_selection, function() utils.toggle_selection() end, { silent = true })
    keymap.set("x", cfg.keymaps.toggle_selection, function() utils.toggle_selection() end, { silent = true })
    keymap.set("v", cfg.keymaps.toggle_selection, function() utils.toggle_selection() end, { silent = true })
end

return M

