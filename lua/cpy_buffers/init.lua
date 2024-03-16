local config = require("cpy_buffers.config")
local keymaps = require("cpy_buffers.keymaps")
local commands = require("cpy_buffers.commands")

local M = {}

function M.setup(opts)
	opts = opts or {}
	config.setup(opts)
	keymaps.setup()
	commands.register_commands()
end

return M
