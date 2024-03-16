# Cpy Buffers for Neovim

Cpy Buffers is a Neovim plugin that leverages Telescope to enable copying the contents of multiple files into the clipboard with ease. It's designed to streamline the process of managing and manipulating files directly from Neovim, making it a valuable tool for developers.

## Demo

https://github.com/adia-dev/cpy_buffers.nvim/assets/63371699/9c6a5090-4ffa-4b78-8296-a3391a17c840



## Requirements

- Neovim (0.8.0 or higher)
- [Telescope](https://github.com/nvim-telescope/telescope.nvim)
- [Ripgrep](https://github.com/BurntSushi/ripgrep) for efficient file searching
- git, for handling gitignore functionality

## Installation

### Packer

If you're using Packer, add the following to your Neovim configuration:

```lua
use {
  'adia-dev/cpy_buffers',
  requires = { {'nvim-telescope/telescope.nvim'} }
}
```

The process is similar for other package managers.

## Configuration

To initialize the plugin with (optional) custom configurations, add the following to your Neovim setup, here are the default configurations:

```lua
require('cpy_buffers').setup({
	keymaps = {
		open_picker = "<leader>fc",
		toggle_hidden = "<leader>g",
		toggle_selection = "<TAB>",
		fast_copy_all = "<C-a>",
		toggle_all = "<C-t>",
		label_buffers = true, -- show buffer labels at the top of each buffer
		-- format string for buffer labels at the top of each buffer
		-- %f will be replaced with the buffer's relative path to the directory
		-- %c will be replaced with the buffer's short name
		-- %a will be replaced with the buffer's absolute path
		-- TODO: %n will be replaced with the buffer's number
		-- TODO: %m will be replaced with the buffer's modified status
		-- e.g: "%n %c %m" will result in "1 init.lua [+]"
		-- e.g: "%f" will result in "lua/cpy_buffers"
		-- e.g: "// %a" will result in "// /home/user/.../lua/cpy_buffers/init.lua"
		-- e.g: "# %f" will result in "# lua/cpy_buffers"
		label_format = "# %c",
		activate_all_visible = "<C-v>",
		deactivate_all_visible = "<C-d>",
		invert_selection = "<C-r>",
	},
	hide_hidden_files = true,
	prompt_title = "Cpy Buffers",
	-- Additional options for the `rg` command, e.g. "--hidden --no-ignore"
	additional_rg_options = "",
})
```

### Default Keymaps

- `<leader>fc`: Open the file picker
- `<leader>g`: Toggle visibility of hidden files
- `<TAB>`: Toggle selection of a file
- `<C-a>`: Copy the contents of all selected files to the clipboard
- `<C-t>`: Toggle the selection of all files
- `<C-v>`: Activate all visible files in the picker
- `<C-d>`: Deactivate all visible files in the picker
- `<C-r>`: Invert the current selection

You can customize these keymaps in the setup configuration.

## Usage

After installation and configuration, use the plugin by invoking the file picker with the configured shortcut (default: `<leader>fc`). Within the picker:

- Use `<TAB>` to select or deselect files.
- Press `<C-a>` to copy the contents of all selected files to the clipboard.
- Adjust visibility of hidden files and change `rg` command options directly from Neovim's command line interface or through the plugin's setup configuration.

## Extending and Customizing

Cpy Buffers allows for extensive customization. You can modify key bindings, toggle gitignore filtering, and change `rg` command options to fit your workflow.

### Commands

- `:CpyBufChangeRgCommand`: Change the `rg` command options for file searching.
- `:CpyBufToggleGitignore`: Toggle the inclusion of hidden files in the search results.
- `:CpyBufChangeLabelFormat`: Change the format of the buffer labels at the top of each buffer.

## Contributing

Contributions are welcome! Feel free to open an issue or submit a pull request on GitHub.

## License

This project is licensed under [MIT](https://opensource.org/licenses/MIT).
