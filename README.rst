nvim
====

Boring Neovim configuration, with less dependencies and good compatibility.

- Automated plugin installation (git clone, no plugin manager)
- Automated LSP server installation on startup
- Python LSP server with dedicated venv (pylsp)
- Pytest integration with quickfix and tab preview
- Snippets (LuaSnip + vim-snippets)
- Git integration (fugitive)
- Fuzzy file search (CtrlP)
- File tree (nvim-tree)
- PlantUML live preview and goodies (plantuml-previewer, plantuml_keymap)
- No-plugin configuration for Vim 8/9
- Non-privileged tool installation (nvim, plantuml, java)
- Shell aliases and shortcuts included (git, venv)

Basic configuration works by cloning repository under ~/.config/nvim

For others (vimrc, tools under ~/.local) see the Makefile::

    % make
    make install    install shell and Vim configuration
    make java       install Eclipse Temurin JDK 21
    make nvim       install latest Nvim
    make plantuml   install latest PlantUML
    make shell      add configuration to zshrc/bashrc

Architecture
------------

Useful defaults as standard Vimscript. Plugin/LSP support as Lua configuration.
Neovim is the main target but occassional Vim-only environments should be
usable with standalone ``.vimrc`` config file.

Baseline configuration::

  vimrc.vim               Common config for Vim/Neovim
  ftplugin/*.vim          Filetype specific indentation rules

Plugin configuration::

  init.lua                Main configuration for Neovim
  lua/bootstrap.lua       Plugin manager (:Bootstrap, :Bootclean)
  lua/config/*.lua        Plugin configurations

LSP server configuration::

  lua/lspconfig.lua       LSP manager (:LspInstall, :LspStart, :LspStop)
  lua/lspdebug.lua        LSP debug utility (:LspDebug)
  lsp/*.lua               LSP server configurations

Tool installation scripts::

  Makefile                Modular install/configuration script
  include/Makefile-*      Component specific install scripts

Commands
--------

Useful commands::

  :cheatsheet        quick reference and documentation
  :Ggr <pattern>     git grep to quickfix list

Plugins / LSP::

  :Bootclean         remove all plugins (re-cloned on next start)
  :LspInstall        install LSP servers
  :LspStart/Stop     start/stop LSP servers
  :LspDebug          when it didn't work

PlantUML::

  :PlantumlOpen      open live preview in browser

Keymaps
-------

Navigation::

  <C-p>              CtrlP fuzzy file search
  <C-j>, <C-k>       scroll in filelist (and mostly in other lists too)

  <C-j>, <C-k>       next, prev location list item
  <C-l>, <C-h>       next, prev quickfix list item
  <Leader>l, q       toggle location, quickfix list

  th, tl             first, last tab
  tj, tk             next, prev tab
  td, tt             close, open tab

  <Leader>o, O       focus/switch, toggle nvim-tree

Coding support::

  <Tab>, <C-n>       snippets and completion
  <Leader-cc>        toggle comments

  K                  toggle documentation
  <Leader>e          toggle diagnostics
  <Leader>q,l        toggle quickfix, location list

  gd, gr, gi         lsp definition, references, implementation
  <C-O>, ..c         jump back, other standard navigation

  <Leader>gg         toggle :Git status window
  <Leader>gw, gc     stage, commit
  <Leader>gd, gb     diff, blame

  <leader>uh,j,k,l   plantuml: change arrow direction
  <leader>un, ut     plantuml: wrap selection with node, together
