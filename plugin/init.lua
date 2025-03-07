vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter"}, {
  pattern = { "*.md" },
  callback = function()
    local userfns = require('xfel-md-eval-nvim.userfns')

    vim.api.nvim_create_user_command(
      'MDEval',
      userfns.eval,
      {}
    )
  end
})


