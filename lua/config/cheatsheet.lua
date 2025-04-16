-- Cheatsheet help file
--
return {
    packages = {},
    setup = function()
        vim.api.nvim_create_autocmd({'BufRead', 'BufNewFile'}, {
            pattern = vim.fn.stdpath('config') .. '/doc/*.txt',
            callback = function() vim.bo.filetype = 'help' end,
        })

        vim.keymap.set('n', '<Leader>hh', function()
            vim.cmd('helptags ' .. vim.fn.stdpath('config') .. '/doc')
            vim.cmd('h cheatsheet')
        end, { desc = 'open cheatsheet' })
    end
}
