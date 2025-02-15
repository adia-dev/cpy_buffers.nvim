local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local previewers = require("telescope.previewers")
local conf = require("telescope.config").values
local config = require("cpy_buffers.config")
local utils = require("cpy_buffers.utils")
local strategies = require("cpy_buffers.strategies")

local M = {}

function M.open_file_picker(opts)
	opts = opts or {}
	local cfg = config.get_config()
	local cfg_state = config.get_state()

	-- Get command from current strategy
	local strategy = strategies.get_strategy(cfg_state.current_strategy)
	local command = strategy.get_command(cfg_state)

	-- Add config-specific options
	for opt in string.gmatch(cfg_state.rg_options, "%S+") do
		table.insert(command, opt)
	end

	-- Add exclude patterns from config
	for _, pattern in ipairs(cfg.file_search.exclude_patterns or {}) do
		table.insert(command, "--glob")
		table.insert(command, "!" .. pattern)
	end

	-- Add include extensions from config
	for _, ext in ipairs(cfg.file_search.include_extensions or {}) do
		table.insert(command, "--glob")
		table.insert(command, "*" .. ext)
	end

	local sorter
	if cfg.sorting.use_custom_sorter then
		sorter = utils.get_custom_sorter(opts)
	else
		sorter = conf.generic_sorter(opts)
	end

	local multi_icon = cfg.selection_indicator or "+"
	local selection_caret = cfg.selection_caret or "> "

	local picker_opts = {
		prompt_title = string.format(
			"%s [Strategy: %s] (Change: %s)",
			cfg.display.prompt_title,
			cfg_state.current_strategy,
			cfg.keymaps.change_strategy
		),
		results_title = "Results (Copy All: "
			.. cfg.keymaps.fast_copy_all
			.. ", Toggle All: "
			.. cfg.keymaps.toggle_all
			.. ")",
		finder = finders.new_oneshot_job(command, {
			entry_maker = utils.get_entry_maker(),
		}),
		previewer = previewers.new_buffer_previewer({
			title = "File Preview",
			define_preview = function(self, entry)
				local content = utils.handle_file_preview(entry)
				if content then
					vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, vim.split(content, "\n"))

					-- Set filetype for syntax highlighting
					local ft = vim.filetype.match({ filename = entry.value })
					if ft then
						vim.api.nvim_buf_set_option(self.state.bufnr, "filetype", ft)
					end
				end
			end,
		}),
		sorter = sorter,
		selection_caret = selection_caret,
		multi_icon = multi_icon,
		layout_config = cfg.layout_config,
		attach_mappings = utils.attach_mappings,
	}

	pickers.new(opts, picker_opts):find()
end

function M.close_picker(prompt_bufnr)
	actions.close(prompt_bufnr)
end

return M
