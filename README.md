# Neovim Telescope Extension: cpy_buffers.nvim

`cpy_buffers.nvim` is an extension for the Neovim Telescope plugin. It enhances the file picking experience by allowing users to select multiple files and copy their contents to the clipboard or a buffer. This extension is especially useful for quickly aggregating content from various files within a project.

## Demo

[Video Demo](https://github.com/adia-dev/cpy_buffers.nvim/assets/63371699/2ca0ef2d-819b-48c5-aae0-d7d0f102ad42)

## Features

- **File Picker**: Seamlessly list and select multiple files within your Neovim environment.
- **Clipboard Integration**: Copy the contents of selected files directly to the clipboard.
- **Toggle Selection**: Easily select or deselect files using the space key.
- **Preview Files**: Preview the contents of files before selecting them.
- **Dynamic Configuration**: Change `ripgrep` command options and toggle gitignored file filtering on the fly.

## Requirements

- **Telescope**: Ensure Telescope is correctly installed in your Neovim setup. [Installation Guide](https://github.com/nvim-telescope/telescope.nvim).
- **Rg**: This extension utilizes RipGrep, so ensure it's installed. [RipGrep GitHub](https://github.com/BurntSushi/ripgrep).

## Installation

To install `cpy_buffers.nvim`, add the following line to your Neovim configuration:

```bash
Plug 'adia-dev/cpy_buffers.nvim'
```

Or, using `packer.nvim`:

```lua
use({
    "adia-dev/cpy_buffers.nvim",
    requires = { "nvim-telescope/telescope.nvim" },
})
```

## Setup

```lua
require("cpy_buffers").setup({
    keymaps = {
        open_picker = "<leader>fc",
        toggle_selection = "<TAB>"
    },
    hide_gitignored_files = true,
    prompt_title = "Cpy Buffers",
    additional_rg_options = "",
})
```

## Usage

Once installed, use the following commands:

- `<leader>fc`: Open the file picker.
- `<TAB>`: Toggle the selection of files.
- `Enter`: Copy the contents of selected files to the clipboard.

## Custom Commands

- `:CpyBufChangeRgCommand`: Change the `ripgrep` command options.
- `:CpyBufToggleGitignore`: Toggle the inclusion of gitignored files.

## Keybindings

- `<leader>fc`: Open the file picker.
- `<TAB>`: Toggle selection of files in the picker.

## Contributing

Contributions to `cpy_buffers.nvim` are welcome! Feel free to submit suggestions, bug reports, or code contributions through issues or pull requests in the repository.

## License

This extension is distributed under the MIT License. See the LICENSE file in the repository for more details.

