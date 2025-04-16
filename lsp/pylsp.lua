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

return {
    install      = install,
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
