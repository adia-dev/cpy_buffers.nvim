# Advanced Usage

This document covers the more advanced features and configuration options available in **CpyBuffers.nvim**, including:

- Customizing file search behavior (hidden files, advanced `rg` options, etc.)
- Adjusting display and labeling
- Using advanced keymaps and commands
- Configuring sorting behavior
- Integrating with custom Telescope sorters and extensions

## Table of Contents

- [Advanced File Filtering](#advanced-file-filtering)
- [Custom Labeling and Display Formatting](#custom-labeling-and-display-formatting)
- [Sorting and Custom Scoring](#sorting-and-custom-scoring)
- [Programmatic Control and Commands](#programmatic-control-and-commands)
- [Integration with Other Plugins](#integration-with-other-plugins)
- [Performance Tips](#performance-tips)
- [Debugging and Logging](#debugging-and-logging)

## Advanced File Filtering

### Toggling Hidden Files

By default, `CpyBuffers.nvim` hides certain files (like `.git`, `node_modules`, `vendor` directories) to streamline the search results. You can toggle the display of hidden files on the fly:

- Press the configured toggle hidden files key (default: `<leader>g`) to switch between showing and hiding hidden files.

**In your config:**

```lua
file_search = {
  hide_hidden_files = true,          -- Start with hidden files excluded
  exclude_patterns = { "node_modules/*", "vendor/*", ".git/*" },
  include_extensions = { ".lua", ".js", ".ts" }, -- Only show certain extensions if desired
  additional_rg_options = "",        -- Add more rg flags (e.g., "--type lua --glob=!test")
},
```

You can also modify the ripgrep (`rg`) command options at runtime using `:CpyBufChangeRgCommand`.

### Dynamically Adjusting `rg` Options

1. Run `:CpyBufChangeRgCommand`.
2. Enter new additional `rg` options (e.g. `--type-add 'mylang:*.mylang' --type mylang`).
3. Re-open the picker and the new options will take effect.

This allows you to refine your search patterns without changing your plugin configuration file.

## Custom Labeling and Display Formatting

When copying multiple files at once, `CpyBuffers.nvim` can insert labels before each file’s content. These labels can be fully customized.

**Key fields:**

- `display.label_buffers`: Enable or disable labeling of file contents.
- `display.label_format`: Define how labels appear.
  - `"%c"` is replaced by the file’s short name.
  - `"%a"` is replaced by the absolute path.
  - `"%f"` is replaced by the relative path to the current working directory.

**Example:**

```lua
display = {
  label_buffers = true,
  label_format = "## File: %f",
  content_separator = "\n\n", -- Separate file contents with blank lines
  show_icons = true,
}
```

If you want to change the label format on-the-fly, use `:CpyBufChangeLabelFormat`.

## Sorting and Custom Scoring

**CpyBuffers.nvim** leverages Telescope’s sorting infrastructure. By default, it uses `telescope.config.values.generic_sorter`, but you can enable a custom sorter that implements your own scoring logic.

**Example enabling custom sorter:**

```lua
sorting = {
  use_custom_sorter = true,
}
```

**Custom Scoring Logic (from `utils.lua`):**

- Boost exact matches.
- Prioritize files with matching extensions.

You can expand this logic to support more complex scoring in `utils.lua`.

## Programmatic Control and Commands

### Built-in Commands

- `:CpyBufChangeRgCommand` – Change `rg` options interactively.
- `:CpyBufToggleGitignore` – Toggle hidden files.
- `:CpyBufChangeLabelFormat` – Change label format interactively.

These commands let you modify the behavior of the plugin without editing your config and reloading Neovim.

### Copying to Buffers and Files Programmatically

You can use the integrated keymaps to copy selected file contents into a new buffer (`<C-b>` by default) or save them to a file (`<C-s>`).

**Example workflow:**

1. Open the file picker (`<leader>cb`).
2. Select multiple files.
3. Press `<C-b>` to paste them into a new buffer or `<C-s>` to save them into a single file.

This workflow speeds up tasks like assembling a report from multiple source files or aggregating code snippets.

## Integration with Other Plugins

### nvim-web-devicons

If `nvim-web-devicons` is installed, you’ll see file-type icons in the picker. If not, a fallback icon is used.

**Ensure `show_icons` is enabled:**

```lua
display = {
  show_icons = true,
}
```

### Other Telescope Extensions

Because `CpyBuffers.nvim` integrates seamlessly with Telescope’s ecosystem, you can combine it with other Telescope extensions. For example, you could:

- Use Telescope’s `fzy_native` sorter or `fzf` extension for advanced sorting and filtering.
- Integrate with `telescope-project` or `telescope-file-browser` to jump between directories before running `CpyBuffers`.

Adjusting or chaining commands might involve writing small wrapper functions in your config.

## Performance Tips

- Exclude large directories: If you often encounter performance issues, extend the `exclude_patterns` list to skip directories known to contain large or irrelevant files.
- Avoid previewing very large files: `CpyBuffers.nvim` automatically disables previews for files larger than 1MB by default. Adjust this limit in `utils.lua` if needed.
- Use additional `rg` options to narrow your search, for example `--type` flags to limit the search space.

## Debugging and Logging

**CpyBuffers.nvim** integrates with Neovim’s built-in logging. Increase the log level to see more detailed information:

```lua
log = {
  use_notify = true,      -- Use `vim.notify` for in-editor popups
  level = vim.log.levels.DEBUG,
}
```

**Levels:**

- `vim.log.levels.ERROR`
- `vim.log.levels.WARN`
- `vim.log.levels.INFO`
- `vim.log.levels.DEBUG`
- `vim.log.levels.TRACE`

When debugging issues, set the level to `DEBUG` or `TRACE` and review the logs or notifications.
