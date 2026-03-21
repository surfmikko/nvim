-- Python ftplugin / compiler extensions
--
-- <Leader>t  run pytest silently, open first error in new tab
-- <Leader>T  run pytest with color preview tab, open first error in new tab
--

vim.cmd('compiler pytest')

local function open_first_error()
    vim.cmd('tabnew')
    local ok = pcall(vim.cmd, 'cfirst')
    if not ok then
        vim.cmd('tabclose')
        vim.notify('pytest: all tests passed', vim.log.levels.INFO)
        return nil
    end
    return vim.api.nvim_get_current_tabpage()
end

local function load_quickfix(tmpfile, ef)
    local clean = tmpfile .. '.clean'
    vim.fn.system('sed "s/\\x1b\\[[0-9;]*m//g" ' .. tmpfile .. ' > ' .. clean)
    local saved = vim.o.errorformat
    vim.o.errorformat = ef
    vim.cmd('cgetfile ' .. clean)
    vim.o.errorformat = saved
    vim.fn.delete(tmpfile)
    vim.fn.delete(clean)
end

local function run_pytest_silent()
    vim.cmd('silent make!')
    open_first_error()
end

local function run_pytest_preview()
    local ef      = vim.bo.errorformat
    local tmpfile = vim.fn.tempname()
    local cmd     = 'pytest --color=yes --tb=line --lf --lfnf=all 2>&1 | tee ' .. tmpfile

    vim.cmd('tabnew')
    local term_tab = vim.api.nvim_get_current_tabpage()
    local term_buf

    vim.fn.termopen(cmd, {
        on_exit = function()
            load_quickfix(tmpfile, ef)
            vim.schedule(function()
                local error_tab = open_first_error()
                vim.api.nvim_set_current_tabpage(term_tab)
                local function close()
                    vim.cmd('tabclose')
                    if error_tab and vim.api.nvim_tabpage_is_valid(error_tab) then
                        vim.api.nvim_set_current_tabpage(error_tab)
                    end
                end
                vim.keymap.set('n', 'q',     close, { buffer = term_buf })
                vim.keymap.set('n', '<Esc>', close, { buffer = term_buf })
            end)
        end
    })
    term_buf = vim.api.nvim_get_current_buf()
end

vim.keymap.set('n', '<Leader>t', run_pytest_silent,  { buffer = true, desc = 'run pytest' })
vim.keymap.set('n', '<Leader>T', run_pytest_preview, { buffer = true, desc = 'run pytest with preview' })
