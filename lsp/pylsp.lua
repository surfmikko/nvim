local opt = vim.fn.stdpath('data') .. '/opt/pylsp'

local function install()
    if vim.fn.isdirectory(opt) == 0 then
        vim.fn.system({ 'python3', '-m', 'venv', opt })
    end
    vim.fn.system({ opt .. '/bin/pip', 'install', '--upgrade', 'pip'})
    vim.fn.system({ opt .. '/bin/pip', 'install', '--upgrade',
        'python-lsp-server', 'pylint', 'pyflakes', 'pycodestyle' })
    print('[pylsp] installed to ' .. opt)
end

local function before_init(_, config)
    local root = config.root_dir or vim.fn.getcwd()
    for _, name in ipairs({ '.venv', 'venv', 'env' }) do
        local python = root .. '/' .. name .. '/bin/python'
        if vim.fn.executable(python) == 1 then
            config.settings.pylsp.plugins.jedi = { environment = python }
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
            }
        }
    }
}
