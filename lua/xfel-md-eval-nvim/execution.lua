local util = require('xfel-md-eval-nvim.util')

local tempfiles = {}

local clear_tempfile = function(job_id)
  if tempfiles[job_id] then
    vim.fn.delete(tempfiles[job_id])
    tempfiles[job_id] = nil
  end
end

local log_clear = function()
  local buffer = util.get_buffer()
  vim.api.nvim_buf_set_lines(buffer, 0, -1, true, {})
end

local log = function(contents)
  local buffer = util.get_buffer()
  vim.api.nvim_buf_set_lines(buffer, -1, -1, true, contents)
  vim.api.nvim_buf_set_option(buffer, "modified", false)

  local window = vim.api.nvim_call_function("bufwinid", { buffer })
  local line_count = vim.api.nvim_buf_line_count(buffer)
  vim.api.nvim_win_set_cursor(window, { line_count, 0 })
end

local on_async_event = function(job_id, data, event)
  if event == 'exit' then
    clear_tempfile(job_id)
    return
  end

  log(data)
end

local cmd = function(lang, tempfile)
  local cmd_table = ({ 
    lang, 
  })
  table.insert(cmd_table, tempfile)
  return table.concat(cmd_table, ' ')
end

local execution = {}

execution.execute_async = function(lang, contents)
  log_clear()
  local tempfile = vim.fn.tempname()
  vim.fn.writefile(contents, tempfile)

  local opts = {
    on_stdout = on_async_event,
    on_stderr = on_async_event,
    on_exit = on_async_event,
    stdin = 'null',
    pty = false
  }
  local job = vim.fn.jobstart(cmd(lang, tempfile), opts)

  vim.api.nvim_set_option_value("filetype", lang, {
    scope = "local",
    buf = util.get_buffer()
  })

  vim.api.nvim_buf_attach(util.get_buffer(), false, {
    on_detach = function()
      vim.fn.jobstop(job)
    end
  })

  tempfiles[job] = tempfile
end

return execution
