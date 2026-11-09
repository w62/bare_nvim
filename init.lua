vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.pack.add({
	"https://github.com/nvim-lualine/lualine.nvim",
	"https://github.com/nvim-tree/nvim-web-devicons", -- optional icons
	"https://github.com/neovim/nvim-lspconfig", -- ships the default server configs
	"https://github.com/stevearc/conform.nvim",
})

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

vim.lsp.enable({ "lua_ls", "rust_analyzer", "clangd", "marksman", "gopls", "taplo" })
-- vim.lsp.enable({ 'rust_analyzer' , 'clangd'})

-- Built-in completion when a server attaches
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		vim.lsp.completion.enable(true, ev.data.client_id, ev.buf, { autotrigger = true })
	end,
})

--[[
vim.api.nvim_create_autocmd('LspAttach', {
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if client and client:supports_method('textDocument/formatting') then
			vim.api.nvim_create_autocmd('BufWritePre', {
				buffer = ev.buf,
				callback = function()
					vim.lsp.buf.format({ bufnr = ev.buf, id = client.id, timeout_ms = 2000 })
				end,
			})
		end
	end,
})

--]]
--[[
vim.keymap.set("n", "<leader>f", function()
	vim.lsp.buf.format({ async = true })
end)

--]]
--
--
vim.keymap.set("n", "<leader>f", function()
	require("conform").format({ async = true, lsp_format = "fallback" })
end)
