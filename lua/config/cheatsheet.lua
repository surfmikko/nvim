-- Cheatsheet help file
--
return {
    packages = {},
    setup = function()
        vim.api.nvim_create_autocmd({'BufRead', 'BufNewFile'}, {
            pattern = vim.fn.stdpath('config') .. '/doc/*.txt',
            callback = function() vim.bo.filetype = 'help' end,
        })

        vim.keymap.set('n', '<Leader>h', function()
            for _, win in ipairs(vim.api.nvim_list_wins()) do
                local buf = vim.api.nvim_win_get_buf(win)
                local name = vim.api.nvim_buf_get_name(buf)
                if name:match('cheatsheet') then
                    vim.api.nvim_win_close(win, false)
                    return
                end
            end
            vim.cmd('helptags ' .. vim.fn.stdpath('config') .. '/doc')
            vim.cmd('tab h cheatsheet')
        end, { desc = 'toggle cheatsheet' })
    end
}
