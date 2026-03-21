# CLAUDE.md

## Style

- Expert audience - omit obvious explanations
- Clean, structured code over ad-hoc insertions
- Readable code and comments only for non-obvious
- Portability and compatibility over speed gains
- Clean implementation and readability over minor performance improvements
- Ease of use and simplicity over breadth of features
- Standard Linux/macOS shell commands; no 3rd-party package managers
- Prefer named functions over inline/anonymous functions
- Limit lines to 80 characters whenever possible

## Compatibility

- **Neovim only**: plugins, LSP, and all Lua configuration are Neovim-specific - do not port to Vim
- **`vimrc.vim`** is the compatibility layer: loaded by both Neovim and Vim 8/9, provides shared editing defaults (keymaps, colors, indentation) with no plugin dependencies
- Keep `vimrc.vim` clean Vimscript - no Lua, no plugin calls, no feature detection beyond what Vim 8 supports

## Architecture

- **`init.lua`** - modular main configuration; loads `vimrc.vim`, bootstrap and lsp manager
- **`lua/bootstrap.lua`** - plugin manager; clones missing plugins via git into `stdpath('data')/site/pack/plugins/start/`, drives plugin config modules
- **`lua/config/*.lua`** - plugin config modules; each exports `{ packages, setup }`
- **`lua/lspconfig.lua`** - lsp manager; wraps `vim.lsp.enable()`, keymaps, diagnostics, auto-install, `:LspInstall`
- **`lua/lspdebug.lua`** - lsp config debugger; `:LspDebug` opens scratch buffer overview
- **`lsp/*.lua`** - lsp server configs; one per server, installed to `stdpath('data')/lsp/<name>/`

Plugin config module interface: `setup()` runs on every startup. Toggle modules by commenting in `init.lua`. Missing plugins are cloned automatically on startup.

## Adding a plugin

1. Create `lua/config/myplugin.lua` returning `{ packages, setup }`
2. Add `'config.myplugin'` to the `require("bootstrap")` list in `init.lua`
3. Restart Neovim - missing plugins are cloned automatically

Active plugin config modules:
- `config.common`, `config.cheatsheet`, `config.ctrlp`, `config.vim_togglelist`
- `config.luasnip`, `config.plantuml_previewer`, `config.fugitive`, `config.simpylfold`
- `config.nvim_tree`

## Adding an LSP server

1. Create `lsp/myserver.lua` returning server config (`cmd`, `filetypes`, `root_markers`, `settings`)
2. Add `install = function() ... end` for auto-install support
3. Add `'myserver'` to the `require("lspconfig")` list in `init.lua`
