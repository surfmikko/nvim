-- nvim-tree.lua - File explorer
--
-- <Leader>o  focus nvim-tree (open if closed), or switch back
-- <Leader>O  open/close nvim-tree
-- h          close directory
-- l          open directory / open file in buffer
--
return {
    packages = {
        'nvim-tree/nvim-tree.lua',
    },
    setup = function()
        local function on_attach(bufnr)
            local api = require('nvim-tree.api')
            local opts = function(desc)
                return {
                    buffer = bufnr,
                    noremap = true,
                    silent = true,
                    desc = desc,
                }
            end
            api.config.mappings.default_on_attach(bufnr)
            vim.keymap.set('n', 'l',
                api.node.open.edit,
                opts('open dir / open file'))
            vim.keymap.set('n', 'h',
                api.node.navigate.parent_close,
                opts('close dir'))
            vim.keymap.set('n', '<Esc>',
                api.tree.close,
                opts('close nvim-tree'))
        end

        require('nvim-tree').setup({
            on_attach = on_attach,
            renderer = {
                icons = {
                    show = {
                        file = false,
                        folder = false,
                        folder_arrow = true,
                        git = false,
                    },
                    glyphs = {
                        folder = {
                            arrow_closed = '\u{25B6}',
                            arrow_open   = '\u{25BC}',
                        },
                    },
                },
            },
        })
        vim.keymap.set('n', '<Leader>o', function()
            if vim.bo.filetype == 'NvimTree' then
                vim.cmd('wincmd p')
            else
                vim.cmd('NvimTreeFocus')
            end
        end, { desc = 'focus/switch nvim-tree' })
        vim.keymap.set('n', '<Leader>O',
            '<cmd>NvimTreeToggle<cr>',
            { desc = 'open/close nvim-tree' })
    end
}
