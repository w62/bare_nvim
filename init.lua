vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.pack.add({
  "https://github.com/nvim-lualine/lualine.nvim",
  "https://github.com/nvim-tree/nvim-web-devicons", -- optional icons
  "https://github.com/nvim-mini/mini.nvim",
  "https://github.com/neovim/nvim-lspconfig", -- ships the default server configs
  "https://github.com/stevearc/conform.nvim",
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/MeanderingProgrammer/render-markdown.nvim",
  "https://github.com/mrcjkb/rustaceanvim",
  "https://github.com/saecki/crates.nvim",
  "https://github.com/stevearc/oil.nvim",
  "https://github.com/ibhagwan/fzf-lua",
  { src = "https://github.com/ThePrimeagen/harpoon", version = "harpoon2" },
  "https://github.com/nvim-lua/plenary.nvim", -- harpoon dependency
})
require("oil").setup({ view_options = { show_hidden = true } })
require("fzf-lua").setup({})
local harpoon = require("harpoon")
harpoon:setup()

local fzf = require("fzf-lua")
vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "Parent directory" })
vim.keymap.set("n", "<leader>ff", fzf.files, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", fzf.live_grep, { desc = "Grep" })
vim.keymap.set("n", "<leader>fb", fzf.buffers, { desc = "Buffers" })
vim.keymap.set("n", "<leader>fr", fzf.oldfiles, { desc = "Recent files" })

vim.keymap.set("n", "<leader>a", function()
  harpoon:list():add()
end)
vim.keymap.set("n", "<C-e>", function()
  harpoon.ui:toggle_quick_menu(harpoon:list())
end)
for i = 1, 4 do
  vim.keymap.set("n", "<leader>" .. i, function()
    harpoon:list():select(i)
  end)
end
-- rustaceanvim configures itself; set options before it loads if needed
vim.g.rustaceanvim = {
  server = {
    default_settings = {
      ["rust-analyzer"] = {
        check = { command = "clippy" }, -- run clippy instead of cargo check
        cargo = { allFeatures = true },
      },
    },
  },
}

require("crates").setup({
  lsp = { enabled = true, actions = true, completion = true, hover = true },
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "rust",
  callback = function(ev)
    vim.keymap.set("n", "<leader>rr", function()
      vim.cmd.RustLsp("runnables")
    end, { buffer = ev.buf })
    vim.keymap.set("n", "<leader>rt", function()
      vim.cmd.RustLsp("testables")
    end, { buffer = ev.buf })
    vim.keymap.set("n", "<leader>re", function()
      vim.cmd.RustLsp("expandMacro")
    end, { buffer = ev.buf })
  end,
})

require("mini.basics").setup()
require("mini.surround").setup()
require("render-markdown").setup({})

require("conform").setup({
  formatters_by_ft = {
    markdown = { "prettier" },
    lua = { "stylua" },
    toml = { "taplo" },
    go = { "goimports", "gofmt" },
  },
  format_on_save = { timeout_ms = 2000, lsp_format = "fallback" },
})

require("lualine").setup({ options = { theme = "auto" } })

-- Optional: tweak lua_ls so it knows about Neovim's runtime
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      workspace = { library = { vim.env.VIMRUNTIME }, checkThirdParty = false },
    },
  },
})

-- vim.lsp.enable({ "lua_ls", "rust_analyzer", "clangd", "marksman", "gopls", "taplo" })
vim.lsp.enable({ "lua_ls", "clangd", "marksman", "gopls", "taplo" })

-- Built-in completion when a server attaches
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    vim.lsp.completion.enable(true, ev.data.client_id, ev.buf, { autotrigger = true })
  end,
})

--
vim.keymap.set("n", "<leader>f", function()
  require("conform").format({ async = true, lsp_format = "fallback" })
end)

-- auto resize splits when the terminal's window is resized
vim.api.nvim_create_autocmd("VimResized", {
  command = "wincmd =",
})
