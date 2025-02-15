local M = {}

local function get_git_root()
	local handle = io.popen("git rev-parse --show-toplevel 2>/dev/null")
	if handle then
		local result = handle:read("*a")
		handle:close()
		return result:gsub("%s+$", "")
	end
	return vim.fn.getcwd()
end

M.strategies = {

	git = {
		name = "git",
		description = "Show only uncommitted git files",
		get_command = function()
			local git_root = get_git_root()

			return {
				"sh",
				"-c",
				"cd '"
					.. git_root
					.. "' && "
					.. "(git ls-files -m && "
					.. "git ls-files -o --exclude-standard && "
					.. "git diff --cached --name-only)",
			}
		end,
	},

	cpp = {
		name = "cpp",
		description = "Show only C++ related files",
		get_command = function()
			return {
				"rg",
				"--files",
				"--glob",
				"*.{cpp,hpp,h,cc}",
			}
		end,
	},

	default = {
		name = "default",
		description = "Default file finder (using ripgrep)",
		get_command = function(cfg_state)
			local cmd = { "rg", "--files", "--hidden" }

			if cfg_state.hide_hidden_files then
				table.insert(cmd, "--glob")
				table.insert(cmd, "!.git/*")
				table.insert(cmd, "--glob")
				table.insert(cmd, "!node_modules/*")
				table.insert(cmd, "--glob")
				table.insert(cmd, "!vendor/*")
			end

			return cmd
		end,
	},
}

function M.register_strategy(name, strategy)
	if type(strategy) ~= "table" or type(strategy.get_command) ~= "function" then
		error("Invalid strategy format. Strategy must be a table with a get_command function")
	end

	M.strategies[name] = vim.tbl_extend("force", strategy, { name = name })
end

function M.get_strategy(name)
	return M.strategies[name] or M.strategies.default
end

function M.list_strategies()
	local strategy_list = {}
	for name, strategy in pairs(M.strategies) do
		table.insert(strategy_list, {
			name = name,
			description = strategy.description or "No description available",
		})
	end
	return strategy_list
end

return M
