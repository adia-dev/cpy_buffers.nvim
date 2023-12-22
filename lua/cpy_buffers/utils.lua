local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local M = {}

M.selected_entries = {}

function M.copy_contents_of_selected_files()
    local contents = {}
    for path, selected in pairs(M.selected_entries) do
        if selected then
            local file_content = vim.fn.readfile(path)
            table.insert(contents, "# " .. path)
            table.insert(contents, table.concat(file_content, "\n"))
        end
    end

    local all_contents = table.concat(contents, "\n\n")
    vim.fn.setreg("+", all_contents)
end

function M.attach_mappings(prompt_bufnr, map)
    actions.select_default:replace(function()
        M.copy_contents_of_selected_files()
        actions.close(prompt_bufnr)
    end)
    map("i", "<space>", M.toggle_selection(prompt_bufnr))
    map("n", "<space>", M.toggle_selection(prompt_bufnr))
    return true
end

function M.toggle_selection(prompt_bufnr)
    return function()
        local selection = action_state.get_selected_entry()
        actions.toggle_selection(prompt_bufnr)
        M.selected_entries[selection.value] = not M.selected_entries[selection.value]
    end
end

return M

