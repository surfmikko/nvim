local opt = vim.fn.stdpath('data') .. '/lsp/pylsp'

local function install()
    if vim.fn.isdirectory(opt) == 0 then
        vim.fn.system({ 'python3', '-m', 'venv', opt })
    end
    vim.fn.system({ opt .. '/bin/pip', 'install', '--upgrade', 'pip'})
    vim.fn.system({ opt .. '/bin/pip', 'install', '--upgrade',
        'python-lsp-server', 'pylint', 'python-lsp-ruff' })
    print('[pylsp] installed to ' .. opt)
end

local function before_init(_, config)
    local root = config.root_dir or vim.fn.getcwd()
    for _, name in ipairs({ '.venv', 'venv', 'env' }) do
        local python = root .. '/' .. name .. '/bin/python'
        if vim.fn.executable(python) == 1 then
            -- jedi uses project venv for completions and import resolution
            config.settings.pylsp.plugins.jedi = { environment = python }
            -- pylint runs from the pylsp venv but needs project packages visible;
            -- inject site-packages via --init-hook so import errors resolve correctly
            local sp = vim.fn.system(python ..
                ' -c "import site; print(site.getsitepackages()[0])"')
            sp = sp:gsub('%s+$', '')
            if vim.fn.isdirectory(sp) == 1 then
                config.settings.pylsp.plugins.pylint.args = {
                    '--init-hook',
                    'import sys; sys.path.insert(0, "' .. sp .. '")',
                }
            end
            return
        end
    end
end

return {
    install      = install,
    before_init  = before_init,
    cmd          = { opt .. '/bin/pylsp' },
    filetypes    = { 'python' },
    root_markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', '.git' },
    settings = {
        pylsp = {
            plugins = {
                pylint      = { enabled = true, executable = opt .. '/bin/pylint' },
                pyflakes    = { enabled = true },
                pycodestyle = { enabled = true },
                ruff        = { enabled = true, formatEnabled = true,
                                lineLength = 80 },
            }
        }
    }
}
