local util = require('xfel-md-eval-nvim.util')
local execution = require('xfel-md-eval-nvim.execution')
local userfns = {}

userfns.eval = function(opts)
  local block = util.get_block()
  if #block < 1 then
    print('Cannot eval outside a code block')
    return
  end

  local lang = util.lang_cmd(
    string.gsub(block[1], '.*```', '')
  )
  if lang == nil or lang == '' then
    print('Cannot eval without a lang')
    return
  end

  table.remove(block, 1)
  table.remove(block, #block)
  execution.execute_async(lang, block)
  -- todo: output selection, maybe on the same document below block
end

return userfns
