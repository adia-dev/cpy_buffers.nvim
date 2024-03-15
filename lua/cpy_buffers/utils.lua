local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local config = require("cpy_buffers.config")

local M = {}

M.selected_entries = {}

function M.copy_contents_of_selected_files()
    local contents = {}
    for path, selected in pairs(M.selected_entries) do
        if selected then
            local file_content, err = vim.fn.readfile(path)
            if err then
                print("Error reading file: " .. path .. "\n" .. err)
                goto continue
            end
            table.insert(contents, "# " .. path)
            table.insert(contents, table.concat(file_content, "\n"))
        end
        ::continue::
    end

    local all_contents = table.concat(contents, "\n\n")
    vim.fn.setreg("+", all_contents)

    M.selected_entries = {}
end

function M.copy_all_files(prompt_bufnr)
    local current_picker = action_state.get_current_picker(prompt_bufnr)
    local entries = current_picker.finder.results

    if not entries or vim.tbl_isempty(entries) then
        print("No files to copy")
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
        print("No files to toggle")
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

function M.invert_selection(prompt_bufnr)
    local current_picker = action_state.get_current_picker(prompt_bufnr)
    local entries = current_picker.finder.results
    if not entries or vim.tbl_isempty(entries) then
        print("No files to invert selection")
        return
    end

    -- First select all entries
    actions.select_all(prompt_bufnr)

    -- Then toggle each entry, effectively inverting the selection
    for _, entry in ipairs(entries) do
        M.selected_entries[entry.value] = not M.selected_entries[entry.value]
        actions.toggle_selection(prompt_bufnr)
    end
end

function M.attach_mappings(prompt_bufnr, map)
    actions.select_default:replace(function()
        M.copy_contents_of_selected_files()
        actions.close(prompt_bufnr)
        M.selected_entries = {}
    end)

    local cfg = config.get_config()

    -- Update mappings for new actions
    map("i", cfg.keymaps.toggle_all, function()
        M.toggle_all_files(prompt_bufnr)
    end)
    map("n", cfg.keymaps.toggle_all, function()
        M.toggle_all_files(prompt_bufnr)
    end)
    map("i", cfg.keymaps.invert_selection, function()
        M.invert_selection(prompt_bufnr)
    end)
    map("n", cfg.keymaps.invert_selection, function()
        M.invert_selection(prompt_bufnr)
    end)

    -- Existing mappings
    map("i", cfg.keymaps.toggle_selection, M.toggle_selection(prompt_bufnr))
    map("n", cfg.keymaps.toggle_selection, M.toggle_selection(prompt_bufnr))
    map("i", cfg.keymaps.fast_copy_all, function()
        M.copy_all_files(prompt_bufnr)
    end)
    map("n", cfg.keymaps.fast_copy_all, function()
        M.copy_all_files(prompt_bufnr)
    end)

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
