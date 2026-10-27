-- Highlight on yank
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.hl.hl_op({
      higroup = 'IncSearch',
      timeout = 40,
    })
  end,
  group = highlight_group,
  pattern = '*',
})

-- Resize splits if window got resized
vim.api.nvim_create_autocmd({ 'VimResized' }, {
  callback = function() vim.cmd('tabdo wincmd =') end,
})

-- Cursorline control
local cursorline_group = vim.api.nvim_create_augroup('CursorLineControl', { clear = true })
local set_cursor_line = function(event, value, pattern)
  vim.api.nvim_create_autocmd(event, {
    group = cursorline_group,
    pattern = pattern,
    callback = function() vim.opt_local.cursorline = value end,
  })
end
set_cursor_line('WinLeave', false)
set_cursor_line('WinEnter', true)

-- Terminal settings
local terminal_group = vim.api.nvim_create_augroup('TerminalSettings', { clear = true })
vim.api.nvim_create_autocmd('TermOpen', {
  group = terminal_group,
  callback = function()
    vim.cmd('startinsert')
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
  end,
})
vim.api.nvim_create_autocmd('TermEnter', {
  group = terminal_group,
  callback = function() vim.opt_local.signcolumn = 'no' end,
})

-- Quickfix settings
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'qf',
  callback = function() vim.opt_local.colorcolumn = '' end,
})

-- Align netrw's long-list details with the window's right edge.
local netrw_group = vim.api.nvim_create_augroup('NetrwLayout', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  group = netrw_group,
  pattern = 'netrw',
  callback = function()
    vim.opt_local.colorcolumn = ''
    if vim.w.netrw_liststyle ~= 1 then return end
    local info = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1]
    local date_width = vim.fn.strdisplaywidth(vim.fn.strftime(vim.g.netrw_timefmt))
    vim.g.netrw_maxfilenamelen = math.max(1, info.width - info.textoff - date_width - 18)
  end,
})
vim.api.nvim_create_autocmd('WinResized', {
  group = netrw_group,
  callback = function()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.bo[buf].filetype == 'netrw' and vim.w[win].netrw_liststyle == 1 then
        vim.api.nvim_win_call(win, function()
          local view = vim.fn.winsaveview()
          vim.fn['netrw#LocalBrowseCheck'](vim.b.netrw_curdir)
          vim.fn.winrestview(view)
        end)
      end
    end
  end,
})

-- Ripgrep integration
if vim.fn.executable('rg') == 1 then
  ---@diagnostic disable-next-line: duplicate-set-field
  function _G.RgFindFiles(cmdarg)
    local fnames = vim.fn.systemlist('rg --files --hidden --color=never --glob="!.git" --glob="!node_modules" --glob "!dist" --glob "!build" --glob "!target" --glob "!out" --glob "!coverage" --glob "!*.lock" --glob "!*.log" --glob "!*.tmp" --glob "!*.cache" --glob "!*.bak" --glob "!*.swp" --glob "!*.swo" --glob "!*.DS_Store"')
    if #cmdarg == 0 then
      return fnames
    else
      return vim.fn.matchfuzzy(fnames, cmdarg)
    end
  end

  vim.o.findfunc = 'v:lua.RgFindFiles'
end
