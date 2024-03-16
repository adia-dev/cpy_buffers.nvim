local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local config = require("cpy_buffers.config")

local M = {}

M.selected_entries = {}

function M.copy_contents_of_selected_files()
    local contents = {}
    local paths = {}
    for path, selected in pairs(M.selected_entries) do
        if selected then
            table.insert(paths, path)
            local file_content, err = vim.fn.readfile(path)
            if err then
                vim.api.nvim_err_writeln("Error reading file: " .. path)
                goto continue
            end
            table.insert(contents, "# " .. path)
            table.insert(contents, table.concat(file_content, "\n"))
        end
        ::continue::
    end


    local all_contents = table.concat(contents, "\n\n")
    vim.fn.setreg("+", all_contents)

    if vim.tbl_isempty(contents) then
        vim.api.nvim_echo({ { "No files were copied", "WarningMsg" } }, true, {})
        return
    else
        -- message to print the paths of the copied files in a bullet list
        local message = "Copied the contents of the following files:\n"
        for _, path in ipairs(paths) do
            message = message .. "  - " .. path .. "\n"
        end
        vim.api.nvim_echo({ { message, "Normal" } }, true, {})
    end


    M.selected_entries = {}
end

function M.copy_all_files(prompt_bufnr)
    local current_picker = action_state.get_current_picker(prompt_bufnr)
    local entries = current_picker.finder.results

    if not entries or vim.tbl_isempty(entries) then
        vim.api.nvim_echo({ { "No files to copy", "WarningMsg" } }, true, {})
        return
    end

    -- Select all entries
    for _, entry in ipairs(entries) do
        M.selected_entries[entry.value] = true
    end

    -- Now copy the contents
    M.copy_contents_of_selected_files()

    -- Close the picker
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
    local prompt_bufnr = vim.api.nvim_get_current_buf()
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
                M.toggle_all_files(
                    prompt_bufnr)
            end
        },
        {
            modes = { "i", "n" },
            key = cfg.keymaps.invert_selection,
            action = function()
                M.invert_selection(
                    prompt_bufnr)
            end
        },
        {
            modes = { "i", "n" },
            key = cfg.keymaps.activate_all_visible,
            action = function()
                M
                    .activate_all_visible_entries(prompt_bufnr)
            end
        },
        {
            modes = { "i", "n" },
            key = cfg.keymaps.deactivate_all_visible,
            action = function()
                M
                    .deactivate_all_visible_entries(prompt_bufnr)
            end
        },
        { modes = { "i", "n" }, key = cfg.keymaps.toggle_selection, action = M.toggle_selection(prompt_bufnr) },
        {
            modes = { "i", "n" },
            key = cfg.keymaps.fast_copy_all,
            action = function()
                M.copy_all_files(
                    prompt_bufnr)
            end
        },
        {
            modes = { "i", "n" },
            key = cfg.keymaps.toggle_hidden,
            action = function()
                config.toggle_hidden()
                -- refresh the picker
                local current_picker = action_state.get_current_picker(prompt_bufnr)
                local rg_command
                if config.get_state().hide_hidden_files then
                    rg_command = { "rg", "--files", "--hidden", "--glob", "!.git/*", "--glob", "!node_modules/*",
                        "--glob", "!vendor/*" }
                else
                    rg_command = { "rg", "--files", "--hidden" }
                end

                for opt in string.gmatch(config.get_state().rg_options, "%S+") do
                    table.insert(rg_command, opt)
                end

                current_picker:refresh(finders.new_oneshot_job(rg_command))

                if config.get_state().hide_hidden_files then
                    vim.api.nvim_echo({ { "Hiding hidden files", "Normal" } }, true, {})
                else
                    vim.api.nvim_echo({ { "Showing hidden files", "Normal" } }, true, {})
                end
            end
        },
    }

    for _, mapping in ipairs(mappings) do
        for _, mode in ipairs(mapping.modes) do
            map(mode, mapping.key, mapping.action)
        end
    end

    return true
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

return M
