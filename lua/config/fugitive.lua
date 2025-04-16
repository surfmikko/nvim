-- Fugitive - Git integration
--
return {
    packages = {
        'tpope/vim-git',
        'tpope/vim-fugitive',
        'tpope/vim-rhubarb',
    },
    setup = function()
        local function map(key, cmd, desc)
            vim.keymap.set('n', key, cmd, { desc = desc })
        end

        local _prev_win = nil

        local function toggle_git()
            local wins = vim.api.nvim_list_wins()
            for _, w in ipairs(wins) do
                local buf = vim.api.nvim_win_get_buf(w)
                if vim.bo[buf].filetype == 'fugitive' then
                    vim.api.nvim_win_close(w, false)
                    if _prev_win and vim.api.nvim_win_is_valid(_prev_win) then
                        vim.api.nvim_set_current_win(_prev_win)
                    end
                    _prev_win = nil
                    return
                end
            end
            _prev_win = vim.api.nvim_get_current_win()
            vim.cmd('Git')
        end

        map('<leader>gg', toggle_git,          'toggle git status')
        map('<leader>gw', ':Gwrite<CR>',       'git stage file')
        map('<leader>gc', ':Git commit<CR>',   'git commit')
        map('<leader>gd', ':Git diff<CR>',     'git diff')
        map('<leader>gb', ':Git blame<CR>',    'git blame')
        map('<leader>ge', ':Gedit<CR>',        'git edit')
        map('<leader>gr', ':Gread<CR>',        'git checkout file')
        map('<leader>gl', ':Git log -- %<CR>', 'git log file')
    end
}
