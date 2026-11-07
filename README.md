My barebone neovim lsp config. No plug-ins, Rust, C/C++, TOML, markdown and Lua. It serves as my real starting point of neovim config.

You can install blink.cmp in your custom-built Neovim 0.11+ on Apple Silicon macOS, using the same manual Git installation method as Telescope, nvim-tree, and lualine.

Blink provides fast, intelligent autocompletion for your existing language servers: Rust, C/C++, Lua, Nix, TOML, and Markdown.

Important: Blink's current development branch targets Neovim 0.12+ and introduces breaking changes. For your Neovim 0.11 setup, install the stable v1 release instead.&#x20;

[image](https://www.google.com/s2/favicons?domain=https://github.com&sz=32)

GitHub+1

## 1. Install blink.cmp

First, check your Neovim version:

```
nvim --version | head -1
```

Install the stable v1 release manually:

```
PLUGINS="$HOME/.local/share/nvim/site/pack/plugins/start"

mkdir -p "$PLUGINS"

git clone https://github.com/saghen/blink.cmp.git \
  "$PLUGINS/blink.cmp"

cd "$PLUGINS/blink.cmp"

git fetch --tags
git checkout "$(git tag -l 'v1.*' --sort=-v:refname | head -1)"
```

This selects the newest available v1 release tag instead of the development branch.

## 2. Configure blink.cmp

Edit:

```
nvim ~/.config/nvim/init.lua
```

Add the following near your other plugin configurations:

```
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
    implementation = "lua",
  },
})
```

I'm using the Lua fuzzy matcher initially. This avoids needing to compile or download Blink's native Rust matcher, so it's the simplest way to confirm everything works on your Mac. You can enable the faster native matcher afterward.&#x20;

[image](https://www.google.com/s2/favicons?domain=https://cmp.saghen.dev&sz=32)

Blink Completion (blink.cmp)

## 3. Disable your existing built-in LSP completion

Earlier, you enabled Neovim's native completion inside your `LspAttach` autocmd:

```
vim.lsp.completion.enable(true, client.id, args.buf, {
  autotrigger = true,
})
```

Remove or comment out those lines.

Blink will handle completion instead, so you don't want both systems competing to display suggestions.

Keep your existing `vim.lsp.config(...)`, `vim.lsp.enable(...)`, and other LSP keybindings unchanged.

With Neovim 0.11's built-in LSP configuration, Blink v1 generally does not require additional LSP capability configuration.&#x20;

[image](https://www.google.com/s2/favicons?domain=https://cmp.saghen.dev&sz=32)

Blink Completion (blink.cmp)

## 4. Completion keybindings

The `default` preset provides:

| Key          | Action                             |
| ------------ | ---------------------------------- |
| `Ctrl-Space` | Open completion menu               |
| `Ctrl-n`     | Next suggestion                    |
| `Ctrl-p`     | Previous suggestion                |
| `Ctrl-y`     | Accept selected suggestion         |
| `Ctrl-e`     | Close completion menu              |
| `Ctrl-k`     | Toggle signature help when enabled |

If you prefer accepting suggestions with Tab, change:

```
keymap = {
  preset = "super-tab",
},
```

I recommend starting with `default` because it preserves normal Tab behavior.

## 5. Restart and verify

Quit Neovim completely and reopen a Rust file:

```
cd ~/projects/rust-toys/tips
nvim src/main.rs
```

In Insert mode, type:

```
fn main() {
    let message = String::new();
    message.
}
```

After typing `message.`, Blink should offer methods such as `push_str`, `len`, and `is_empty`, assuming rust-analyzer is attached.

You can also test manually with `Ctrl-Space`.

Check Blink's health:

```
:checkhealth blink.cmp
```

Check your LSP:

```
:LspStatus
```

And verify the plugin module loads:

```
:lua print(pcall(require, "blink.cmp"))
```

Expected:

```
true
```

## 6. Optional: Enable the faster Rust fuzzy matcher

Because you're on Apple Silicon, Blink v1 supports a native macOS ARM64 fuzzy matcher.&#x20;

[image](https://www.google.com/s2/favicons?domain=https://cmp.saghen.dev&sz=32)

Blink Completion (blink.cmp)

Once the basic configuration works, change:

```
fuzzy = {
  implementation = "prefer_rust_with_warning",
},
```

With the plugin checked out at a release tag, Blink can download the appropriate prebuilt matcher. Alternatively, since you already work with Rust, you can build it yourself:

```
cd ~/.local/share/nvim/site/pack/plugins/start/blink.cmp

cargo build --release
```

Then restart Neovim.

## 7. Your updated Neovim environment

| Component                                           | Purpose                    |
| --------------------------------------------------- | -------------------------- |
| blink.cmp                                           | Autocompletion             |
| Telescope                                           | Fuzzy file and text search |
| nvim-tree                                           | File explorer              |
| nvim-treesitter                                     | Syntax highlighting        |
| lualine                                             | Status line                |
| Tokyo Night / Kanagawa                              | Colorscheme                |
| rust-analyzer, clangd, LuaLS, nixd, Taplo, Marksman | Language intelligence      |

You now have a modular IDE-like Neovim setup without a plugin manager.

Official documentation: [Blink Completion v1 installation](https://cmp.saghen.dev/installation?utm_source=chatgpt.com).
