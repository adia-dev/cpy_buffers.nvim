# Neovim Telescope Extension: cpy_buffers.nvim

`cpy_buffers.nvim` is an extension for the Neovim Telescope plugin. It enhances the file picking experience by allowing users to select multiple files and copy their contents to the clipboard or a buffer. This extension is useful for quickly aggregating content from various files within a project.

## Demo

https://github.com/adia-dev/cpy_buffers.nvim/assets/63371699/2ca0ef2d-819b-48c5-aae0-d7d0f102ad42

## Features

- **File Picker**: Seamlessly list and select multiple files within your Neovim environment.
- **Clipboard Integration**: Copy the contents of selected files directly to the clipboard.
- **Toggle Selection**: Easily select or deselect files using the space key.
- **Preview Files**: Preview the contents of files before selecting them.

## Requirements

- **Telescope**: Make sure to have Telescope correctly installed on your Neovim setup, [see this](https://github.com/nvim-telescope/telescope.nvim).
- **Rg**: This extension makes use of RigGrep(for now) so make sure to have it available, [see this](https://github.com/BurntSushi/ripgrep).

## Installation

To install

`cpy_buffers.nvim`, you need to have Telescope installed. Then, add the following line to your Neovim configuration:

```bash
Plug 'adia-dev/cpy_buffers.nvim'

use({
    "adia-dev/cpy_buffers.nvim",
    requires = { "nvim-telescope/telescope.nvim" },
})
```

## Usage

Once installed, the extension can be used in the following way:

- Press `<leader>h` to open the file picker.
- Use the space key to toggle the selection of files.
- Press Enter to copy the contents of selected files to the clipboard.

## Keybindings

- `<leader>h`: Open the file picker.
- `<space>`: Toggle selection of files in the picker.

## Contributing

Contributions to `cpy_buffers.nvim` are welcome. Whether you have suggestions, bug reports, or code contributions, feel free to open an issue or a pull request in the repository.

## License

This extension is distributed under the MIT License. See the LICENSE file in the repository for more details.
