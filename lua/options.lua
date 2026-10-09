-- ============================================================
-- LINE NUMBERS & NAVIGATION
-- ============================================================
vim.opt.number = true
vim.opt.relativenumber = true
vim.keymap.set({ "n", "v" }, "j", "gj", { silent = true })
vim.keymap.set({ "n", "v" }, "k", "gk", { silent = true })

-- ============================================================
-- RULER & HARD WRAPPING
-- ============================================================
vim.g.my_colorcolumn = 100
vim.opt.colorcolumn = tostring(vim.g.my_colorcolumn)
vim.opt.textwidth = vim.g.my_colorcolumn
vim.opt.formatoptions = "tcqnj"
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.keymap.set("n", "<leader>cc", function()
  if vim.opt.colorcolumn:get()[1] ~= "" then
    vim.opt.colorcolumn = ""
    vim.opt.textwidth = 0
    vim.notify("Auto-Break OFF", vim.log.levels.INFO)
  else
    vim.opt.colorcolumn = tostring(vim.g.my_colorcolumn)
    vim.opt.textwidth = vim.g.my_colorcolumn
    vim.notify("Auto-Break ON (" .. vim.g.my_colorcolumn .. " cols)", vim.log.levels.INFO)
  end
end, { desc = "Toggle Ruler/Wrap" })
vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#44475a" })
vim.opt.scrolloff = 10

-- ============================================================
-- JUPYTER / MOLTEN
-- ============================================================
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.ipynb",
  callback = function()
    local py_file = vim.fn.expand("%:r") .. ".py"
    if vim.fn.filereadable(py_file) == 1 then
      vim.fn.delete(py_file)
    end
  end,
})

vim.o.conceallevel = 2
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "tex", "text" },
  callback = function()
    vim.opt_local.textwidth = 0
    vim.opt_local.formatoptions:remove("t")
    vim.opt_local.colorcolumn = tostring(vim.g.my_colorcolumn)
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true
  end,
})

-- ============================================================
-- TERMINAL: unlist + lock window (native winfixbuf, Neovim 0.10+)
-- ============================================================
-- 'winfixbuf' pins this window to its current buffer at the Neovim
-- core level: nothing (including internal tab/buffer-close reshuffling)
-- can put a different buffer into it. This replaces the old
-- TermOpen + BufWinEnter "kick it back out" pair, which reactively
-- swapped buffers with nvim_win_set_buf and ended up nesting inside
-- Neovim's own tab-close autocmd chain, crashing lualine's git diff
-- jobstart(). With winfixbuf, that intrusion never happens in the
-- first place, so there's nothing left to react to or crash.
vim.api.nvim_create_autocmd("TermOpen", {
  callback = function(ev)
    vim.bo[ev.buf].buflisted = false
    local win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_var(win, "_is_r_console", true)
    vim.wo[win].winfixbuf = true
  end,
})
