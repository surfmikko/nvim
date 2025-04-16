-- vim: set noai ts=4 sw=4:
--
-- init.lua - Minimalistic configuration for Neovim

vim.cmd.runtime 'vimrc.vim'

require("bootstrap")({
    'config.common',
    'config.cheatsheet',
    'config.ctrlp',
    'config.fugitive',
    'config.luasnip',
    'config.vim_togglelist',
    'config.plantuml_previewer',
    'config.plantuml_keymap',
    'config.simpylfold',
}, function()
    require("lspdebug")
    require("lspconfig")({ 'pylsp' })
end)
