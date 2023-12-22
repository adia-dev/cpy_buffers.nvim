return require("telescope").register_extension({
	setup = function(ext_config, config) end,
	exports = {
		file_picker = require("cpy_buffers.picker").open_file_picker,
	},
})
