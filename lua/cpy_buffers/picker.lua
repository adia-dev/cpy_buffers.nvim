local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local previewers = require("telescope.previewers")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values
local utils = require("cpy_buffers.utils")

local M = {}

function M.open_file_picker(opts)
	opts = opts or {}
	pickers
		.new(opts, {
			prompt_title = "File Picker",
			finder = finders.new_oneshot_job({
				"rg",
				"--files",
				"--hidden",
				"--glob",
				"!.git/*",
			}),
			previewer = previewers.cat.new({}),
			sorter = conf.generic_sorter(opts),
			attach_mappings = utils.attach_mappings,
		})
		:find()
end

return M
