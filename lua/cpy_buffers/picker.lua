local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local previewers = require("telescope.previewers")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values
local config = require("cpy_buffers.config")
local utils = require("cpy_buffers.utils")

local M = {}

function M.open_file_picker(opts)
	opts = opts or {}
	local cfg = config.get_config()
	local cfg_state = config.get_state()
	local rg_command = { "rg", "--files", "--hidden" }

	if cfg_state.hide_gitignored_files then
		table.insert(rg_command, "--glob")
		table.insert(rg_command, "!.git/*")
	end

	for opt in string.gmatch(cfg_state.rg_options, "%S+") do
		table.insert(rg_command, opt)
	end

	pickers
		.new(opts, {
			prompt_title = cfg.prompt_title,
			finder = finders.new_oneshot_job(rg_command),
			previewer = previewers.cat.new({}),
			sorter = conf.generic_sorter(opts),
			attach_mappings = utils.attach_mappings,
		})
		:find()
end

return M
