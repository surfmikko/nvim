# CLAUDE.md

## Style

- Expert audience — omit obvious explanations
- Clean, structured code over ad-hoc insertions
- Readable over clever — no party tricks
- Comments only where intent is non-obvious
- Portability and compatibility over speed gains
- Clean implementation and readability over minor performance improvements
- Ease of use and simplicity over breadth of features
- Prefer standard Linux/macOS shell commands; avoid package managers (never brew, use macports/dnf/apt-get/pip sparingly)
- Limit lines to 80 characters whenever possible
- Prefer named functions over inline/anonymous functions

## Compatibility

- **Neovim only**: plugins, LSP, and all Lua configuration are Neovim-specific — do not port to Vim
- **`vimrc.vim`** is the compatibility layer: loaded by both Neovim and Vim 8/9, provides shared editing defaults (keymaps, colors, indentation) with no plugin dependencies
- Keep `vimrc.vim` clean Vimscript — no Lua, no plugin calls, no feature detection beyond what Vim 8 supports

## Architecture

- **`init.lua`** — modular main configuration; loads `vimrc.vim`, plugin manager and lsp manager
- **`lua/bootstrap.lua`** — plugin manager; wraps paq-nvim, drives plugin config modules
- **`lua/config/*.lua`** — plugin config modules; each exports `{ packages, install?, setup }`
- **`lua/lspconfig.lua`** — lsp manager; wraps `vim.lsp.enable()`, keymaps, diagnostics, `:LspInstall`
- **`lua/lspdebug.lua`** — lsp config debugger; `:LspDebug` opens scratch buffer overview
- **`lsp/*.lua`** — lsp configuration modules; one per server, loaded by the lsp manager

Plugin config module interface: `install()` runs once after sync, `setup()` on every startup. Toggle modules by commenting in `init.lua`. Reload with `<Leader>0` or `:Bootstrap`.

**Reference**: `vim_old/` — previous Vimscript config.

## Adding a plugin

1. Create `lua/config/myplugin.lua` returning `{ packages, setup }`
2. Add `'config.myplugin'` to the `require("bootstrap")` list in `init.lua`
3. Call `:Bootstrap` to sync

Active plugin config modules:
- `config.common`, `config.cheatsheet`, `config.ctrlp`, `config.vim_togglelist`
- `config.luasnip`, `config.plantuml_previewer`, `config.fugitive`, `config.simpylfold`

## Adding an LSP server

1. Create `lsp/myserver.lua` returning server config (`cmd`, `filetypes`, `root_markers`, `settings`)
2. Optionally add `install = function() ... end` for `:LspInstall` support
3. Add `'myserver'` to the `require("lspconfig")` list in `init.lua`
