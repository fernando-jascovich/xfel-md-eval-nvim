local buffer_number = -1
local util = {}

util.get_block = function()
  local st = vim.fn.search('```', 'bn')
  local en = vim.fn.search('```', 'n')
  local block = vim.api.nvim_buf_get_lines(0, st - 1, en, false)
  return block
end

util.get_buffer = function()
  local buffer_visible = vim.api.nvim_call_function(
    "bufwinnr", 
    { buffer_number }
  ) ~= -1

  if buffer_number == -1 or not buffer_visible then
    vim.api.nvim_command("botright split md-eval-output")
    buffer_number = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_keymap(
      buffer_number,
      'n', 
      'q',
      ":q<cr>", 
      { noremap = true }
    )
  end

  return buffer_number
end

util.lang_cmd = function(lang)
  local replacements = vim.g.md_eval_nvim or {
    javascript = 'node',
    js = 'node',
    r = 'Rscript'
  }

  if replacements[lang] ~= nil then
    return replacements[lang]
  end
  
  return lang
end

return util
