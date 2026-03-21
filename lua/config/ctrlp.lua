-- ctrlp.vim - Fuzzy file finder
--
-- <Leader>p  open file search
-- <Leader>P  clear all caches and open file search
-- C-p        open file search (backup)
--

local _ignore = {
    'venv', '.venv', 'node_modules', '.git',
    '__pycache__', '.pytest_cache', '.mypy_cache',
    '.ruff_cache', 'dist', 'build', '.eggs', '*.egg-info',
}

local _ignore_ext = {
    'pyc', 'pyo', 'pyd',
    'png', 'jpg', 'jpeg', 'gif',
    'min.js', 'min.css',
}

local _ignore_name = {
    '.DS_Store',
}

local function build_grep()
    local parts = {
        '\\.(' .. table.concat(_ignore_ext, '|') .. ')$',
    }
    for _, d in ipairs(_ignore) do
        table.insert(parts, '/' .. d .. '/')
    end
    for _, n in ipairs(_ignore_name) do
        table.insert(parts, '/' .. n .. '$')
    end
    return table.concat(parts, '|')
end

local function build_find()
    local parts = {}
    for _, d in ipairs(_ignore) do
        table.insert(parts, '-not -path "*/' .. d .. '/*"')
    end
    for _, e in ipairs(_ignore_ext) do
        table.insert(parts, '-not -name "*.' .. e .. '"')
    end
    for _, n in ipairs(_ignore_name) do
        table.insert(parts, '-not -name "' .. n .. '"')
    end
    return table.concat(parts, ' ')
end

return {
    packages = { 'kien/ctrlp.vim' },
    setup = function()
        vim.g.ctrlp_map = '<Leader>p'
        vim.g.ctrlp_custom_ignore = table.concat(_ignore, '\\|')
        vim.g.ctrlp_user_command = {
            '.git',
            'cd %s && git ls-files --exclude-standard -co | grep -Ev "' .. build_grep() .. '"',
            'find %s -type f ' .. build_find(),
        }
        vim.keymap.set('n', '<c-p>', '<cmd>CtrlP<cr>',
            { desc = 'CtrlP open' })
        vim.keymap.set('n', '<Leader>P', function()
            vim.cmd('CtrlPClearAllCaches')
            vim.cmd('CtrlP')
        end, { desc = 'CtrlP clear cache and open' })
    end
}
