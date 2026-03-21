-- LuaSnip - snippet engine
-- Custom snippets: ~/.config/nvim/snippets/<filetype>.snippets
--
-- Keymaps:
--   <Tab>   insert mode: expand or jump / select mode: jump forward
--   <S-Tab> jump backward
--   <CR>    jump forward if inside snippet, else normal CR
--
return {
    packages = {
        'L3MON4D3/LuaSnip',
        'honza/vim-snippets',
    },
    setup = function()
        local ls   = require('luasnip')
        local data = vim.fn.stdpath('data')

        ls.config.set_config({
            history = false,
            delete_check_events = 'TextChanged',
        })

        require('luasnip.loaders.from_snipmate').lazy_load({
            paths = {
                vim.fn.stdpath('config') .. '/snippets',
                data .. '/site/pack/plugins/start/vim-snippets/snippets',
            }
        })

        -- Unlink snippet session when leaving insert/select to normal mode,
        -- but not during LuaSnip's internal jumps
        vim.api.nvim_create_autocmd('ModeChanged', {
            pattern = '[is]:n',
            callback = function()
                if ls.session.current_nodes[vim.api.nvim_get_current_buf()]
                    and not ls.session.jump_active
                then
                    ls.unlink_current()
                end
            end,
        })

        local tab = vim.api.nvim_replace_termcodes('<Tab>', true, false, true)
        local cr  = vim.api.nvim_replace_termcodes('<CR>',  true, false, true)

        -- Insert mode: jump if inside snippet, else expand, else real tab
        vim.keymap.set('i', '<Tab>', function()
            if ls.jumpable(1) then
                ls.jump(1)
            elseif ls.expandable() then
                ls.expand()
            else
                vim.api.nvim_feedkeys(tab, 'n', false)
            end
        end, { silent = true })

        -- Select mode: jump forward only (no expand)
        vim.keymap.set('s', '<Tab>', function()
            ls.jump(1)
        end, { silent = true })

        vim.keymap.set({ 'i', 's' }, '<S-Tab>', function()
            ls.jump(-1)
        end, { silent = true })

        -- Insert/select mode: jump forward if inside snippet, else normal CR
        vim.keymap.set({ 'i', 's' }, '<CR>', function()
            if ls.jumpable(1) then
                ls.jump(1)
            else
                vim.api.nvim_feedkeys(cr, 'n', false)
            end
        end, { silent = true })
    end
}
