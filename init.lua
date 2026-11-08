-- ============================================================
-- Pure Neovim 0.11+ configuration
-- Languages: Rust, C, C++, Markdown, TOML, Lua
-- LSP: rust-analyzer, clangd, marksman, Taplo, lua_language_server
-- Formatters: rustfmt, clang-format, prettier, Taplo, LuaLS
-- No plugins or plugin manager required
-- ============================================================

-- 1. Basic settings
--
-- Moved to here before any other plug in initialization
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = false
vim.opt.relativenumber = false
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.smartindent = true
vim.opt.signcolumn = "yes"
vim.opt.termguicolors = true
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.updatetime = 300

-- 1.1 Load colorscheme
--

--[[
mkdir -p ~/.local/share/nvim/site/pack/themes/start

git clone https://github.com/folke/tokyonight.nvim.git \
  ~/.local/share/nvim/site/pack/themes/start/tokyonight.nvim

THEMES="$HOME/.local/share/nvim/site/pack/themes/start"
mkdir -p "$THEMES"

git clone https://github.com/catppuccin/nvim.git \
  "$THEMES/catppuccin"

git clone https://github.com/rebelot/kanagawa.nvim.git \
  "$THEMES/kanagawa.nvim"

git clone https://github.com/EdenEast/nightfox.nvim.git \
  "$THEMES/nightfox.nvim"

git clone https://github.com/rose-pine/neovim.git \
  "$THEMES/rose-pine"

--]]
--
-- Tokyo Night colorscheme
vim.opt.termguicolors = true
--[[
require("tokyonight").setup({
    style = "night",
    transparent = false,
    styles = {
        comments = { italic = false },
        keywords = { italic = false },
    },
})
--]]
vim.cmd.colorscheme("catppuccin-mocha")


--[[
--
mkdir -p ~/.local/share/nvim/site/pack/plugins/start

git clone https://github.com/nvim-lualine/lualine.nvim.git \
  ~/.local/share/nvim/site/pack/plugins/start/lualine.nvim

nvim
----]]

-- 1.2 Lualine status line

-- ==========================================
-- Lualine statusline
-- ==========================================
vim.opt.laststatus = 3

require("lualine").setup({
    options = {
        theme = "auto",
        icons_enabled = true,
        component_separators = { left = "│", right = "│" },
        section_separators = { left = "", right = "" },
        globalstatus = true,
    },

    sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
    },
})


-- 1.3 tree-sitter
--
--[[
--
mkdir -p ~/.local/share/nvim/site/pack/plugins/start

git clone --branch master \
  https://github.com/nvim-treesitter/nvim-treesitter.git \
  ~/.local/share/nvim/site/pack/plugins/start/nvim-treesitter

----
--- Change from main to master
---
TS="$HOME/.local/share/nvim/site/pack/plugins/start/nvim-treesitter"

git -C "$TS" fetch origin master
git -C "$TS" switch master
git -C "$TS" pull --ff-only origin master

--]]
-- ==========================================
-- Tree-sitter (Neovim 0.11 / master branch)
-- ==========================================
require("nvim-treesitter.configs").setup({
    ensure_installed = {
        "rust",
        "c",
        "cpp",
        "lua",
        "toml",
        "markdown",
    },

    sync_install = false,
    auto_install = false,

    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },

    indent = {
        enable = true,
    },
})

-- 1.4 nvim-tree
--
--[[
mkdir -p ~/.local/share/nvim/site/pack/plugins/start

git clone https://github.com/nvim-tree/nvim-tree.lua.git \
  ~/.local/share/nvim/site/pack/plugins/start/nvim-tree.lua
--]]

-- ==========================================
-- Nvim-tree file explorer
-- ==========================================

-- Recommended by nvim-tree

require("nvim-tree").setup({
    sort = {
        sorter = "case_sensitive",
    },

    view = {
        width = 35,
        side = "left",
        preserve_window_proportions = true,
    },

    renderer = {
        group_empty = true,

        highlight_git = true,

        icons = {
            show = {
                file = true,
                folder = true,
                folder_arrow = true,
                git = true,
            },
        },
    },

    filters = {
        dotfiles = false,
        git_ignored = false,
    },

    git = {
        enable = true,
        ignore = false,
    },

    update_focused_file = {
        enable = true,
        update_root = false,
    },

    actions = {
        open_file = {
            quit_on_open = false,
            resize_window = true,
        },
    },
})

-- nvim-tree toggle file explorer
--[[
vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", {
    desc = "Toggle file explorer",
})
--]]
--
-- Toggle file explorer
vim.keymap.set("n", "<leader>e", function()
    require("nvim-tree.api").tree.toggle()
end, {
    desc = "Toggle file explorer",
    silent = true,
})
-- Focus file explorer
vim.keymap.set("n", "<leader>o", "<cmd>NvimTreeFocus<CR>", {
    desc = "Focus file explorer",
})

-- Find current file in tree
vim.keymap.set("n", "<leader>fe", "<cmd>NvimTreeFindFile<CR>", {
    desc = "Reveal current file",
})

--1.5
--
--[[
brew install ripgrep fd
PLUGINS="$HOME/.local/share/nvim/site/pack/plugins/start"

mkdir -p "$PLUGINS"

git clone https://github.com/nvim-lua/plenary.nvim.git \
  "$PLUGINS/plenary.nvim"

git clone https://github.com/nvim-telescope/telescope.nvim.git \
  "$PLUGINS/telescope.nvim"

optional telescope-fzf-native

brew install cmake

PLUGINS="$HOME/.local/share/nvim/site/pack/plugins/start"

git clone https://github.com/nvim-telescope/telescope-fzf-native.nvim.git \
  "$PLUGINS/telescope-fzf-native.nvim"

make -C "$PLUGINS/telescope-fzf-native.nvim"

telescope.load_extension("fzf")


--]]

-- ==========================================
-- Telescope fuzzy finder
-- ==========================================

local telescope = require("telescope")
local builtin = require("telescope.builtin")
local actions = require("telescope.actions")

telescope.setup({
    defaults = {
        prompt_prefix = "   ",
        selection_caret = "➜ ",

        path_display = { "smart" },

        sorting_strategy = "ascending",

        layout_config = {
            horizontal = {
                prompt_position = "top",
                preview_width = 0.55,
            },
        },

        mappings = {
            i = {
                ["<C-j>"] = actions.move_selection_next,
                ["<C-k>"] = actions.move_selection_previous,
                ["<Esc>"] = actions.close,
            },
        },
    },

    pickers = {
        find_files = {
            hidden = true,
        },
    },
})

telescope.load_extension("fzf")


-- ==========================================
-- Telescope keybindings
-- ==========================================

vim.keymap.set("n", "<leader>sf", builtin.find_files, {
    desc = "Search files",
})

vim.keymap.set("n", "<leader>sg", builtin.live_grep, {
    desc = "Search text (ripgrep)",
})

vim.keymap.set("n", "<leader>sb", builtin.buffers, {
    desc = "Search open buffers",
})

vim.keymap.set("n", "<leader>sh", builtin.help_tags, {
    desc = "Search help",
})

vim.keymap.set("n", "<leader>sr", builtin.oldfiles, {
    desc = "Recent files",
})

vim.keymap.set("n", "<leader>ss", builtin.lsp_document_symbols, {
    desc = "Search document symbols",
})

vim.keymap.set("n", "<leader>sd", builtin.diagnostics, {
    desc = "Search diagnostics",
})

vim.keymap.set("n", "<leader>sc", builtin.commands, {
    desc = "Search Neovim commands",
})


-- 1.6 blink cmp
--
--[[
--PLUGINS="$HOME/.local/share/nvim/site/pack/plugins/start"

mkdir -p "$PLUGINS"

git clone https://github.com/saghen/blink.cmp.git \
  "$PLUGINS/blink.cmp"

cd "$PLUGINS/blink.cmp"

git fetch --tags
git checkout "$(git tag -l 'v1.*' --sort=-v:refname | head -1)"
--]]
--

-- ==========================================
-- Blink Completion
-- ==========================================
require("blink.cmp").setup({
    keymap = {
        preset = "default",
    },

    appearance = {
        nerd_font_variant = "mono",
    },

    completion = {
        documentation = {
            auto_show = true,
            auto_show_delay_ms = 300,
        },

        menu = {
            border = "rounded",
        },
    },

    sources = {
        default = {
            "lsp",
            "path",
            "snippets",
            "buffer",
        },
    },

    fuzzy = {
        --implementation = "lua",
        implementation = "prefer_rust_with_warning",
    },
})

-- 1.7 Markview.nvim
--
--
--[[
NVIM_DATA="$(nvim --clean --headless \
  '+lua io.write(vim.fn.stdpath("data"))' \
  +qa 2>/dev/null)"

PLUGIN_DIR="$NVIM_DATA/site/pack/plugins/start"

mkdir -p "$PLUGIN_DIR"

git clone https://github.com/OXY2DEV/markview.nvim.git \
  "$PLUGIN_DIR/markview.nvim"

    --]]
-- Markview.nvim configuration
--
require("markview").setup({
    preview = {
        icon_provider = "internal",
    },
})

-- Toggle inline Markdown rendering
vim.keymap.set("n", "<leader>mp", "<cmd>Markview toggle<CR>", {
    desc = "Toggle Markdown preview",
    silent = true,
})

-- Toggle side-by-side Markdown preview
vim.keymap.set("n", "<leader>ms", "<cmd>Markview splitToggle<CR>", {
    desc = "Toggle Markdown split preview",
    silent = true,
})
--
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
        --[[
        if client:supports_method("textDocument/completion") then
            vim.lsp.completion.enable(
                true,
                client.id,
                args.buf,
                { autotrigger = true }
            )
        end
        --]]
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
vim.keymap.set("n", "<leader>d", function()
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
