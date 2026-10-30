vim.pack.add({
  "https://github.com/numerataz/ninetyfive.nvim"
})

require("ninetyfive").setup({
  enable_on_startup = true,
  mappings = {
    accept = "<tab>",
    reject = "<C-w>",
  }
})
