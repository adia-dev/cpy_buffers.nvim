local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local previewers = require("telescope.previewers")
local conf = require("telescope.config").values
local config = require("cpy_buffers.config")
local utils = require("cpy_buffers.utils")

local M = {}

function M.open_file_picker(opts)
	opts = opts or {}
	local cfg = config.get_config()
	local cfg_state = config.get_state()
	local rg_command = { "rg", "--files", "--hidden" }

	if cfg_state.hide_hidden_files then
		table.insert(rg_command, "--glob")
		table.insert(rg_command, "!.git/*")
		table.insert(rg_command, "--glob")
		table.insert(rg_command, "!node_modules/*")
		table.insert(rg_command, "--glob")
		table.insert(rg_command, "!vendor/*")
	end

	for _, pattern in ipairs(cfg.file_search.exclude_patterns or {}) do
		table.insert(rg_command, "--glob")
		table.insert(rg_command, "!" .. pattern)
	end

	for _, ext in ipairs(cfg.file_search.include_extensions or {}) do
		table.insert(rg_command, "--glob")
		table.insert(rg_command, "*" .. ext)
	end

	for opt in string.gmatch(cfg_state.rg_options, "%S+") do
		table.insert(rg_command, opt)
	end

	local sorter
	if cfg.sorting.use_custom_sorter then
		sorter = utils.get_custom_sorter(opts)
	else
		sorter = conf.generic_sorter(opts)
	end

	pickers
		.new(opts, {
			prompt_title = cfg.display.prompt_title .. " (Toggle Selection: " .. cfg.keymaps.toggle_selection .. ")",
			results_title = "Results (Copy All: "
				.. cfg.keymaps.fast_copy_all
				.. ", Toggle All: "
				.. cfg.keymaps.toggle_all
				.. ")",
			finder = finders.new_oneshot_job(rg_command, {
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
			attach_mappings = utils.attach_mappings,
		})
		:find()
end

function M.close_picker(prompt_bufnr)
	actions.close(prompt_bufnr)
end

return M
