# CpyBuffers.nvim

> 🔍 A powerful Neovim plugin for copying and managing file contents with an intuitive Telescope interface.

[INSERT DEMO GIF/IMAGE HERE]

## ✨ Features

- 🚀 **Fast and Efficient**: Quick file content copying powered by Telescope's fuzzy finder
- 📋 **Multi-Selection**: Select multiple files and copy their contents with ease
- 🎨 **Rich Preview**: Built-in file preview with syntax highlighting
- 🛠️ **Highly Configurable**: Customize everything from keymaps to display formats
- 🎯 **Smart Filtering**: Advanced file filtering with ripgrep integration
- 📝 **Buffer Labels**: Organize copied content with customizable file labels

## 🖼️ Screenshots

[INSERT SCREENSHOTS HERE]

## 📥 Installation

<details>
<summary>Using <a href="https://github.com/folke/lazy.nvim">lazy.nvim</a></summary>

```lua
{
  "adia-dev/cpy-buffers.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- optional, for file icons
  },
  config = function()
    require("cpy_buffers").setup({
      -- your configuration
    })
  end,
}
```

</details>

<details>
<summary>Using <a href="https://github.com/wbthomason/packer.nvim">packer.nvim</a></summary>

```lua
use {
  'adia-dev/cpy-buffers.nvim',
  requires = {
    'nvim-telescope/telescope.nvim',
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- optional, for file icons
  },
  config = function()
    require('cpy_buffers').setup({
      -- your configuration
    })
  end
}
```

</details>

## ⚡️ Quick Start

1. Open the file picker:

```lua
-- Default keymap
<leader>cb
```

2. Select files using:

- `<TAB>` to toggle selection
- `<C-a>` to select all
- `<C-t>` to toggle all
- `<CR>` to copy selected contents

[INSERT QUICK START GIF HERE]

## ⚙️ Configuration

Here's a basic configuration with default values:

```lua
require("cpy_buffers").setup({
  register = "+", -- Copy to system clipboard
  selection_indicator = "✔", -- Selected files indicator
  selection_caret = "➜ ", -- Selection cursor indicator

  -- Optional: Customize keymaps
  keymaps = {
    open_picker = "<leader>cb",
    toggle_selection = "<TAB>",
    fast_copy_all = "<C-a>",
    toggle_all = "<C-t>",
  },
})
```

<details>
<summary>🔧 Full Configuration</summary>

```lua
{
	register = "+", -- "+" Copy to the host machine clipboard
	selection_indicator = "✔", -- Icon for selected entries
	selection_caret = "➜ ", -- Icon for the selection caret
	keymaps = {
		open_picker = "<leader>cb",
		toggle_selection = "<TAB>",
		fast_copy_all = "<C-a>",
		toggle_all = "<C-t>",
		activate_all_visible = "<C-v>",
		deactivate_all_visible = "<C-d>",
		invert_selection = "<C-r>",
		toggle_hidden = "<leader>g",
		copy_to_buffer = "<C-b>",
		save_to_file = "<C-s>",
		copy_paths = "<C-p>",
	},
	highlights = {
		multi_selection = {
			guifg = "#7aa2f7", -- Brighter blue for active selection
			guibg = "#292e42", -- Slightly lighter gray-blue for active background
		},
	},
	log = {
		use_notify = true,
		level = vim.log.levels.DEBUG,
	},
	-- Change the layout of the picker
	-- layout_config = {
	-- 	width = 0.8,
	-- 	height = 0.9,
	-- 	prompt_position = "top",
	-- 	preview_cutoff = 120,
	-- 	horizontal = {
	-- 		preview_width = 0.6,
	-- 	},
	-- },
	display = {
		label_buffers = true,
		label_format = "-- %c --",
		prompt_title = "Cpy Buffers",
		content_separator = "\n\n",
		show_icons = true,
	},
	file_search = {
		hide_hidden_files = true,
		additional_rg_options = "",
		include_extensions = {},
		exclude_patterns = { "node_modules/*", "vendor/*" },
	},
	sorting = {
		sort_by_modification = false,
		sort_by_size = false,
		sort_by_extension = false,
		use_custom_sorter = false,
	},
}
```

</details>

<!-- TODO: write the CONFIGURATION.md file -->
<!-- See [detailed configuration](./CONFIGURATION.md) for all options. -->

## 🎮 Default Keymaps

| Key          | Action               |
| ------------ | -------------------- |
| `<leader>cb` | Open file picker     |
| `<TAB>`      | Toggle selection     |
| `<C-a>`      | Copy all files       |
| `<C-t>`      | Toggle all files     |
| `<C-v>`      | Select all visible   |
| `<C-d>`      | Deselect all visible |
| `<C-r>`      | Invert selection     |
| `<leader>g`  | Toggle hidden files  |
| `<C-b>`      | Copy to new buffer   |
| `<C-s>`      | Save to file         |
| `<C-p>`      | Copy file paths      |

## 📚 Commands

| Command                    | Description            |
| -------------------------- | ---------------------- |
| `:CpyBufChangeRgCommand`   | Modify ripgrep options |
| `:CpyBufToggleGitignore`   | Toggle hidden files    |
| `:CpyBufChangeLabelFormat` | Change label format    |

## 🔧 Advanced Usage

For detailed information about advanced features and customization options, check out our [Advanced Usage Guide](./ADVANCED.md).

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## 📄 License

MIT License - see the [LICENSE](LICENSE) file for details

---

<div align="center">
Made with ❤️ by adia-dev
</div>
