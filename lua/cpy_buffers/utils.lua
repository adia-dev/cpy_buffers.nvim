local uv = vim.loop
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local config = require("cpy_buffers.config")

local devicons = require("nvim-web-devicons")
local entry_display = require("telescope.pickers.entry_display")

local M = {}

M.selected_entries = {}

local function get_file_stats(path)
	local fd = vim.loop.fs_open(path, "r", 438)
	if not fd then
		return nil
	end

	local stat = vim.loop.fs_fstat(fd)
	vim.loop.fs_close(fd)
	return {
		size = stat.size,
		mtime = stat.mtime.sec,
		type = stat.type,
	}
end

function M.get_entry_maker()
	return function(entry)
		local stats = get_file_stats(entry)
		if not stats then
			return nil
		end

		local cfg = config.get_config()

		-- Get file attributes
		local relative_path = vim.fn.fnamemodify(entry, ":.") -- Relative path
		local filename = vim.fn.fnamemodify(entry, ":t") -- Filename
		local ext = filename:match("%.([^%.]+)$") or ""
		local icon = ""
		local icon_highlight = ""

		if cfg.show_icons then
			icon, icon_highlight = devicons.get_icon(filename, ext, { default = true })
		end

		if not icon then
			icon = " " -- Default icon
			icon_highlight = ""
		end

		-- Format size
		local size_str = ""
		if stats.size < 1024 then
			size_str = string.format("%dB", stats.size)
		elseif stats.size < 1024 * 1024 then
			size_str = string.format("%.1fKB", stats.size / 1024)
		else
			size_str = string.format("%.1fMB", stats.size / (1024 * 1024))
		end

		-- Create displayer
		local displayer = entry_display.create({
			separator = " ",
			items = {
				{ width = 2 }, -- Icon
				{ width = 10 }, -- Size
				{ remaining = true }, -- Relative path
			},
		})

		local display = displayer({
			{ icon, icon_highlight },
			size_str,
			relative_path,
		})

		return {
			value = entry,
			display = display,
			ordinal = relative_path,
		}
	end
end

function M.handle_file_preview(entry)
	if not entry or not entry.value then
		return
	end

	local stats = get_file_stats(entry.value)
	if not stats then
		return
	end

	-- Don't preview large files
	if stats.size > 1024 * 1024 then -- 1MB limit
		return string.format("File too large to preview (%.1fMB)", stats.size / (1024 * 1024))
	end

	-- Read and return file contents
	local file = io.open(entry.value, "r")
	if not file then
		return
	end

	local content = file:read("*a")
	file:close()
	return content
end

local function read_file(path)
	local fd = uv.fs_open(path, "r", 438)
	if not fd then
		return nil, "Error opening file: " .. path
	end
	local stat = uv.fs_fstat(fd)
	local data = uv.fs_read(fd, stat.size, 0)
	uv.fs_close(fd)
	return data, nil
end

function M.copy_contents_of_selected_files()
	local contents = {}
	local paths = {}
	local cfg = config.get_config()
	local total_chars = 0

	for path, selected in pairs(M.selected_entries) do
		if selected then
			table.insert(paths, path)
			local data, err = read_file(path)
			if err then
				vim.api.nvim_err_writeln(err)
			else
				if cfg.label_buffers then
					local label = M.format_label(cfg.label_format, path)
					table.insert(contents, label)
					total_chars = total_chars + #label + 2 -- +2 for separators
				end
				table.insert(contents, data)
				total_chars = total_chars + #data + 2
			end
		end
	end

	if vim.tbl_isempty(contents) then
		vim.notify("No files were copied", vim.log.levels.WARN)
		return
	end

	local separator = cfg.content_separator or "\n\n"
	local all_contents = table.concat(contents, separator)
	vim.fn.setreg(cfg.register, all_contents)

	local total_lines = select(2, all_contents:gsub("\n", "\n"))

	local message_lines = { "Copied the contents of the following files:" }
	for _, path in ipairs(paths) do
		table.insert(message_lines, "  - " .. path)
	end

	-- TODO: Make the printing of total characters optional
	table.insert(message_lines, "")
	table.insert(message_lines, "Total characters copied: " .. total_chars)
	table.insert(message_lines, "Total lines copied: " .. total_lines)

	local total_size = 0
	for path, selected in pairs(M.selected_entries) do
		if selected then
			local stats = get_file_stats(path)
			if stats then
				total_size = total_size + stats.size
			end
		end
	end

	-- TODO: Make the printing of total size optional
	local size_str
	if total_size < 1024 then
		size_str = string.format("%dB", total_size)
	elseif total_size < 1024 * 1024 then
		size_str = string.format("%.1fKB", total_size / 1024)
	else
		size_str = string.format("%.1fMB", total_size / (1024 * 1024))
	end

	table.insert(message_lines, "Total size: " .. size_str)

	local message = table.concat(message_lines, "\n")
	vim.api.nvim_echo({ { message, "Normal" } }, true, {})

	M.selected_entries = {}
end

function M.get_custom_sorter(opts)
	opts = opts or {}

	return require("telescope.sorters").new({
		scoring_function = function(_, prompt, line)
			local score = 0

			-- Custom scoring logic
			-- Boost exact matches
			if line:lower():find(prompt:lower(), 1, true) then
				score = score - 2
			end

			-- Boost files with matching extensions
			local ext = prompt:match("%.([^%.]+)$")
			if ext and line:lower():match("%." .. ext:lower() .. "$") then
				score = score - 1
			end

			return score
		end,

		highlighter = function(self, prompt, display)
			local highlights = {}
			local start_pos, end_pos = display:lower():find(prompt:lower(), 1, true)
			if start_pos and end_pos then
				table.insert(highlights, { start = start_pos, finish = end_pos, highlight = "TelescopeMatching" })
			end
			return highlights
		end,
	})
end

function M.copy_all_files(prompt_bufnr)
	local current_picker = action_state.get_current_picker(prompt_bufnr)
	local entries = current_picker.finder.results

	if not entries or vim.tbl_isempty(entries) then
		vim.api.nvim_echo({ { "No files to copy", "WarningMsg" } }, true, {})
		return
	end

	for _, entry in ipairs(entries) do
		M.selected_entries[entry.value] = true
	end

	M.copy_contents_of_selected_files()

	actions.close(prompt_bufnr)
	M.selected_entries = {}
end

function M.toggle_all_files(prompt_bufnr)
	actions.toggle_all(prompt_bufnr)

	local current_picker = action_state.get_current_picker(prompt_bufnr)
	local entries = current_picker.finder.results
	if not entries or vim.tbl_isempty(entries) then
		vim.api.nvim_echo({ { "No files to select", "WarningMsg" } }, true, {})
		return
	end

	for _, entry in ipairs(entries) do
		if M.selected_entries[entry.value] == nil then
			M.selected_entries[entry.value] = true
		else
			M.selected_entries[entry.value] = not M.selected_entries[entry.value]
		end
	end
end

function M.activate_all_visible_entries(prompt_bufnr)
	M.change_visible_entry_state(prompt_bufnr, true)
end

function M.deactivate_all_visible_entries(prompt_bufnr)
	M.change_visible_entry_state(prompt_bufnr, false)
end

function M.change_visible_entry_state(prompt_bufnr, state)
	local current_picker = action_state.get_current_picker(prompt_bufnr)
	local i = 1

	for entry in current_picker.manager:iter() do
		if M.selected_entries[entry.value] ~= state then
			current_picker._multi:toggle(entry)
			local row = current_picker:get_row(i)
			if row > 0 and current_picker:can_select_row(row) then
				current_picker.highlighter:hi_multiselect(row, current_picker._multi:is_selected(entry))
			end
		end

		i = i + 1

		M.selected_entries[entry.value] = state

		if i > current_picker.max_results then
			break
		end
	end
end

function M.invert_selection(prompt_bufnr)
	local current_picker = action_state.get_current_picker(prompt_bufnr)
	local i = 1

	for entry in current_picker.manager:iter() do
		current_picker._multi:toggle(entry)
		local row = current_picker:get_row(i)
		if row > 0 and current_picker:can_select_row(row) then
			current_picker.highlighter:hi_multiselect(row, current_picker._multi:is_selected(entry))
		end

		i = i + 1

		if M.selected_entries[entry.value] == nil then
			M.selected_entries[entry.value] = true
		else
			M.selected_entries[entry.value] = not M.selected_entries[entry.value]
		end

		if i > current_picker.max_results then
			break
		end
	end
end

function M.toggle_selection(prompt_bufnr)
	return function()
		local selection = action_state.get_selected_entry()
		if selection then
			actions.toggle_selection(prompt_bufnr)
			M.selected_entries[selection.value] = not M.selected_entries[selection.value]
		end
	end
end

function M.format_label(format, path)
	local short_name = vim.fn.fnamemodify(path, ":.")
	local relative_path = vim.fn.fnamemodify(path, ":~:.:h")
	local absolute_path = vim.fn.fnamemodify(path, ":p")
	-- local number = vim.fn.bufnr(path)
	-- local modified = vim.fn.getbufvar(number, "&modified") == 1 and "[+]" or ""
	local label = format:gsub("%%f", relative_path)

	label = label:gsub("%%c", short_name)
	label = label:gsub("%%a", absolute_path)
	-- label = label:gsub("%%n", number)
	-- label = label:gsub("%%m", modified)
	return label
end

function M.attach_mappings(prompt_bufnr, map)
	M.selected_entries = {}

	actions.select_default:replace(function()
		M.copy_contents_of_selected_files()
		actions.close(prompt_bufnr)
	end)

	local cfg = config.get_config()
	local mappings = {
		{
			modes = { "i", "n" },
			key = cfg.keymaps.toggle_all,
			action = function()
				M.toggle_all_files(prompt_bufnr)
			end,
		},
		{
			modes = { "i", "n" },
			key = cfg.keymaps.invert_selection,
			action = function()
				M.invert_selection(prompt_bufnr)
			end,
		},
		{
			modes = { "i", "n" },
			key = cfg.keymaps.activate_all_visible,
			action = function()
				M.activate_all_visible_entries(prompt_bufnr)
			end,
		},
		{
			modes = { "i", "n" },
			key = cfg.keymaps.deactivate_all_visible,
			action = function()
				M.deactivate_all_visible_entries(prompt_bufnr)
			end,
		},
		{ modes = { "i", "n" }, key = cfg.keymaps.toggle_selection, action = M.toggle_selection(prompt_bufnr) },
		{
			modes = { "i", "n" },
			key = cfg.keymaps.fast_copy_all,
			action = function()
				M.copy_all_files(prompt_bufnr)
			end,
		},
		{
			modes = { "i", "n" },
			key = cfg.keymaps.copy_to_buffer,
			action = function()
				actions.close(prompt_bufnr)
				M.copy_contents_to_new_buffer()
			end,
		},
		{
			modes = { "i", "n" },
			key = cfg.keymaps.save_to_file,
			action = function()
				M.save_contents_to_file()
				actions.close(prompt_bufnr)
			end,
		},
		{
			modes = { "i", "n" },
			key = cfg.keymaps.copy_paths,
			action = function()
				M.copy_file_paths()
				actions.close(prompt_bufnr)
			end,
		},
		{
			modes = { "i", "n" },
			key = cfg.keymaps.toggle_hidden,
			action = function()
				config.toggle_hidden()

				local rg_command
				if config.get_state().hide_hidden_files then
					rg_command = {
						"rg",
						"--files",
						"--hidden",
						"--glob",
						"!.git/*",
						"--glob",
						"!node_modules/*",
						"--glob",
						"!vendor/*",
					}
				else
					rg_command = { "rg", "--files", "--hidden" }
				end

				for opt in string.gmatch(config.get_state().rg_options, "%S+") do
					table.insert(rg_command, opt)
				end

				local current_picker = action_state.get_current_picker(prompt_bufnr)
				current_picker:refresh(finders.new_oneshot_job(rg_command))

				if config.get_state().hide_hidden_files then
					vim.api.nvim_echo({ { "Hiding hidden files", "Normal" } }, true, {})
				else
					vim.api.nvim_echo({ { "Showing hidden files", "Normal" } }, true, {})
				end
			end,
		},
	}

	for _, mapping in ipairs(mappings) do
		for _, mode in ipairs(mapping.modes) do
			map(mode, mapping.key, mapping.action)
		end
	end

	return true
end

function M.copy_contents_to_new_buffer()
	local contents = {}
	local paths = {}
	local cfg = config.get_config()
	local total_chars = 0

	for path, selected in pairs(M.selected_entries) do
		if selected then
			table.insert(paths, path)
			local data, err = read_file(path)
			if err then
				vim.api.nvim_err_writeln(err)
			else
				if cfg.label_buffers then
					local label = M.format_label(cfg.label_format, path)
					table.insert(contents, label)
					total_chars = total_chars + #label + 2
				end
				table.insert(contents, data)
				total_chars = total_chars + #data + 2
			end
		end
	end

	if vim.tbl_isempty(contents) then
		vim.api.nvim_echo({ { "No files were copied", "WarningMsg" } }, true, {})
		return
	end

	local separator = cfg.content_separator or "\n\n"
	local all_contents = table.concat(contents, separator)

	if vim.api.nvim_buf_get_option(0, "modified") then
		local choice = vim.fn.confirm("Buffer has unsaved changes. Discard changes and continue?", "&Yes\n&No", 2)
		if choice ~= 1 then
			-- User chose not to discard changes
			vim.api.nvim_echo({ { "Operation cancelled.", "WarningMsg" } }, true, {})
			return
		end
	end

	vim.api.nvim_command("enew!") -- Force open a new buffer
	vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(all_contents, "\n"))

	local message_lines = { "Contents pasted into new buffer.", "Files included:" }
	for _, path in ipairs(paths) do
		table.insert(message_lines, "  - " .. path)
	end
	vim.api.nvim_echo({ { table.concat(message_lines, "\n"), "Normal" } }, true, {})

	M.selected_entries = {}
end

function M.save_contents_to_file()
	local contents = {}
	local paths = {}
	local cfg = config.get_config()

	for path, selected in pairs(M.selected_entries) do
		if selected then
			table.insert(paths, path)
			local data, err = read_file(path)
			if err then
				vim.api.nvim_err_writeln(err)
			else
				if cfg.label_buffers then
					local label = M.format_label(cfg.label_format, path)
					table.insert(contents, label)
				end
				table.insert(contents, data)
			end
		end
	end

	if vim.tbl_isempty(contents) then
		vim.api.nvim_echo({ { "No files to save", "WarningMsg" } }, true, {})
		return
	end

	local separator = cfg.content_separator or "\n\n"
	local all_contents = table.concat(contents, separator)

	local filepath = vim.fn.input("Save to file: ", "", "file")
	if filepath == "" then
		return
	end

	local file = io.open(filepath, "w")
	if file then
		file:write(all_contents)
		file:close()
		vim.api.nvim_echo({ { "Contents saved to " .. filepath, "Normal" } }, true, {})
	else
		vim.api.nvim_err_writeln("Error writing to file: " .. filepath)
	end

	M.selected_entries = {}
end

function M.copy_file_paths()
	local paths = {}
	for path, selected in pairs(M.selected_entries) do
		if selected then
			table.insert(paths, path)
		end
	end

	if vim.tbl_isempty(paths) then
		vim.api.nvim_echo({ { "No file paths to copy", "WarningMsg" } }, true, {})
		return
	end

	local path_str = table.concat(paths, "\n")
	local cfg = config.get_config()
	vim.fn.setreg(cfg.register, path_str)
	vim.api.nvim_echo({ { "File paths copied.", "Normal" } }, true, {})

	M.selected_entries = {}
end

return M
