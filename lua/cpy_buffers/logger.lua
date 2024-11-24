local config = require("cpy_buffers.config")

local M = {}

function M.log(msg, level)
	local default_log_level = config.get_config().log.level or vim.log.levels.INFO
	local use_notify = config.get_config().log.use_notify and vim.notify ~= nil

	level = level or default_log_level

	-- Only log messages that meet or exceed the configured log level
	if level < default_log_level then
		return
	end

	if use_notify then
		vim.notify(msg, level, { title = "CpyBuffers.nvim" })
	else
		local hl_map = {
			[vim.log.levels.ERROR] = "ErrorMsg",
			[vim.log.levels.WARN] = "WarningMsg",
			[vim.log.levels.INFO] = "None",
			[vim.log.levels.DEBUG] = "Comment",
			[vim.log.levels.TRACE] = "Comment",
		}
		local hl = hl_map[level] or "None"

		vim.api.nvim_echo({ { "CpyBuffers.nvim: " .. msg, hl } }, true, {})
	end
end

function M.error(msg)
	M.log(msg, vim.log.levels.ERROR)
end

function M.warn(msg)
	M.log(msg, vim.log.levels.WARN)
end

function M.info(msg)
	M.log(msg, vim.log.levels.INFO)
end

function M.debug(msg)
	M.log(msg, vim.log.levels.DEBUG)
end

return M
