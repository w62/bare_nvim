-- ============================================================
-- Pure Neovim 0.11+ configuration
-- Languages: Rust, C, C++, Markdown, TOML, Lua
-- LSP: rust-analyzer, clangd, marksman, Taplo, lua_language_server
-- Formatters: rustfmt, clang-format, prettier, Taplo, LuaLS
-- No plugins or plugin manager required
-- ============================================================

-- 1. Basic settings
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.smartindent = true
vim.opt.signcolumn = "yes"
vim.opt.termguicolors = true
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.updatetime = 300

-- 2. Diagnostics
vim.diagnostic.config({
    virtual_text = true,
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
})

-- 3. Rust LSP
vim.lsp.config("rust_analyzer", {
    cmd = { "rust-analyzer" },
    filetypes = { "rust" },
    root_markers = {
        "Cargo.toml",
        "rust-project.json",
    },
    settings = {
        ["rust-analyzer"] = {
            check = {
                command = "clippy",
            },
        },
    },
})

-- 4. C/C++ LSP
local clangd = "/opt/homebrew/opt/llvm/bin/clangd"

if vim.fn.executable(clangd) == 0 then
    clangd = "clangd"
end

vim.lsp.config("clangd", {
    cmd = {
        clangd,
        "--background-index",
        "--clang-tidy",
        "--completion-style=detailed",
    },
    filetypes = {
        "c",
        "cpp",
        "objc",
        "objcpp",
        "cuda",
    },
    root_markers = {
        "compile_commands.json",
        "compile_flags.txt",
        ".clangd",
        "CMakeLists.txt",
        "Makefile",
        ".git",
    },
})

-- 5. Markdown LSP
vim.lsp.config("marksman", {
    cmd = { "marksman", "server" },
    filetypes = { "markdown" },
    root_markers = {
        ".marksman.toml",
        ".git",
    },
    workspace_required = false,
})

-- ==========================================
-- Lua: Lua Language Server
-- ==========================================
vim.lsp.config("lua_ls", {
    cmd = { "lua-language-server" },
    filetypes = { "lua" },

    root_markers = {
        ".luarc.json",
        ".luarc.jsonc",
        ".git",
    },

    workspace_required = false,

    settings = {
        Lua = {
            runtime = {
                version = "LuaJIT",
            },

            diagnostics = {
                globals = { "vim" },
            },

            workspace = {
                checkThirdParty = false,
                library = {
                    vim.env.VIMRUNTIME,
                },
            },

            telemetry = {
                enable = false,
            },

            format = {
                enable = true,
                defaultConfig = {
                    indent_style = "space",
                    indent_size = "2",
                },
            },
        },
    },
})

-- ==========================================
-- TOML: Taplo LSP
-- ==========================================
vim.lsp.config("taplo", {
    cmd = { "taplo", "lsp", "stdio" },
    filetypes = { "toml" },
    root_markers = {
        "taplo.toml",
        ".taplo.toml",
        ".git",
    },
    workspace_required = false,
})

-- 6. Enable language servers
vim.lsp.enable({
    "rust_analyzer",
    "clangd",
    "marksman",
    "taplo",
    "lua_ls",
})

-- 7. LSP attachment and keymaps
local group = vim.api.nvim_create_augroup(
    "MyNeovimConfig",
    { clear = true }
)

vim.api.nvim_create_autocmd("LspAttach", {
    group = group,
    callback = function(args)
        local client = vim.lsp.get_client_by_id(
            args.data.client_id
        )

        if not client then
            return
        end

        local opts = { buffer = args.buf }

        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

        vim.keymap.set(
            "n", "<leader>rn", vim.lsp.buf.rename, opts
        )

        vim.keymap.set(
            "n", "<leader>ca", vim.lsp.buf.code_action, opts
        )

        -- Built-in completion
        if client:supports_method("textDocument/completion") then
            vim.lsp.completion.enable(
                true,
                client.id,
                args.buf,
                { autotrigger = true }
            )
        end
    end,
})

-- 8. Markdown formatting with Prettier
local function format_markdown(bufnr)
    local filename = vim.api.nvim_buf_get_name(bufnr)

    if vim.fn.executable("prettier") == 0 then
        vim.notify("prettier not found", vim.log.levels.ERROR)
        return false
    end

    local lines = vim.api.nvim_buf_get_lines(
        bufnr, 0, -1, false
    )

    local input = table.concat(lines, "\n") .. "\n"

    local result = vim.system({
        "prettier",
        "--stdin-filepath",
        filename ~= "" and filename or "README.md",
    }, {
        stdin = input,
        text = true,
    }):wait()

    if result.code ~= 0 or not result.stdout then
        vim.notify(
            result.stderr or "Prettier failed",
            vim.log.levels.ERROR
        )
        return false
    end

    local output = vim.split(
        result.stdout,
        "\n",
        { plain = true }
    )

    if output[#output] == "" then
        table.remove(output)
    end

    if not vim.deep_equal(lines, output) then
        local view = vim.fn.winsaveview()

        vim.api.nvim_buf_set_lines(
            bufnr, 0, -1, false, output
        )

        vim.fn.winrestview(view)
    end

    return true
end

-- 9. Unified formatter
local function format_buffer(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()

    local ft = vim.bo[bufnr].filetype

    if ft == "markdown" then
        return format_markdown(bufnr)
    end


    if ft == "toml" then
        local clients = vim.lsp.get_clients({
            bufnr = bufnr,
            method = "textDocument/formatting",
        })

        local available = false

        for _, client in ipairs(clients) do
            if client.name == "taplo" then
                available = true
                break
            end
        end

        if not available then
            vim.notify(
                "Taplo LSP is not attached",
                vim.log.levels.WARN
            )
            return false
        end

        vim.lsp.buf.format({
            bufnr = bufnr,
            async = false,
            timeout_ms = 5000,
            filter = function(client)
                return client.name == "taplo"
            end,
        })

        return true
    end

    --[[
  if ft == "rust" or ft == "c" or ft == "cpp"
      or ft == "objc" or ft == "objcpp" then

    local server = ft == "rust"
        and "rust_analyzer" or "clangd"

 --]]

    if ft == "rust" or ft == "c" or ft == "cpp"
        or ft == "objc" or ft == "objcpp"
        or ft == "lua" then
        local server

        if ft == "rust" then
            server = "rust_analyzer"
        elseif ft == "lua" then
            server = "lua_ls"
        else
            server = "clangd"
        end

        local clients = vim.lsp.get_clients({
            bufnr = bufnr,
            method = "textDocument/formatting",
        })

        local available = false

        for _, client in ipairs(clients) do
            if client.name == server then
                available = true
                break
            end
        end

        if not available then
            vim.notify(
                "Formatter LSP not attached: " .. server,
                vim.log.levels.WARN
            )
            return false
        end

        local ok, err = pcall(vim.lsp.buf.format, {
            bufnr = bufnr,
            async = false,
            timeout_ms = 5000,
            filter = function(client)
                return client.name == server
            end,
        })

        if not ok then
            vim.notify(tostring(err), vim.log.levels.ERROR)
            return false
        end

        return true
    end

    vim.notify(
        "No formatter for filetype: " .. ft,
        vim.log.levels.WARN
    )
    return false
end

-- 10. Manual formatting: Space + f
vim.keymap.set("n", "<leader>f", function()
    format_buffer()
end, {
    desc = "Format current buffer",
})

-- 11. Automatic formatting before save
vim.api.nvim_create_autocmd("BufWritePre", {
    group = group,
    pattern = {
        "*.rs",
        "*.c",
        "*.h",
        "*.cpp",
        "*.cc",
        "*.cxx",
        "*.hpp",
        "*.hh",
        "*.hxx",
        "*.md",
        "*.markdown",
        "*.toml",
        "*.lua",
    },
    callback = function(args)
        format_buffer(args.buf)
    end,
})

-- 12. Markdown editing options
vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "markdown",
    callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.linebreak = true
        vim.opt_local.spell = true
        vim.opt_local.conceallevel = 2
    end,
})

-- 13. Diagnostics keymaps
vim.keymap.set("n", "<leader>e", function()
    vim.diagnostic.open_float()
end, { desc = "Show diagnostics" })

vim.keymap.set("n", "<leader>q", function()
    vim.diagnostic.setloclist()
end, { desc = "Diagnostics list" })

-- 14. LSP status command
vim.api.nvim_create_user_command("LspStatus", function()
    local clients = vim.lsp.get_clients({ bufnr = 0 })

    if #clients == 0 then
        print("No LSP clients attached")
        return
    end

    for _, client in ipairs(clients) do
        print(
            client.name,
            "formatting:",
            client:supports_method("textDocument/formatting")
        )
    end
end, {})
