-- vim: set noai ts=4 sw=4:
--
-- Bootstrap - Install and configure plugins
--
-- Add plugin configuration to lua/config/mymodule.lua
--
--   return {
--       packages = { 'author/plugin', ... },  -- paq-nvim specs
--       install  = function() ... end,        -- optional, runs once after sync
--       setup    = function() ... end,        -- runs on every startup
--   }
--
-- Include config in init.lua:
--   require("bootstrap")({ 'config.foo', 'config.bar' })
--
-- Keymaps / commands:
--   <Leader>0  / :Bootstrap   re-sync plugins and re-run install + setup
--

local pack_path = vim.fn.stdpath('data') .. '/site/pack/paqs/start/'

local function is_installed(pkg)
    local name = (type(pkg) == 'string' and pkg or pkg[1]):match('[^/]+$')
    return vim.fn.isdirectory(pack_path .. name) == 1
end

local bootstrap = {
    configs = {}
}

local function reload()
    for k in pairs(package.loaded) do
        if k:match('^config%.') then package.loaded[k] = nil end
    end
    bootstrap.configs = {}
    bootstrap._syncing = true
    dofile(vim.env.MYVIMRC)
    bootstrap:sync()
end

vim.keymap.set('n', '<Leader>0', reload,
    { desc = 'reload config and sync plugins' })
vim.api.nvim_create_user_command('Bootstrap', reload,
    { desc = 'reload config and sync plugins' })
vim.api.nvim_create_user_command('Bootclean', function()
    local path = vim.fn.stdpath('data') .. '/site/pack/paqs'
    vim.fn.delete(path, 'rf')
    print('[bootstrap] removed ' .. path)
end, { desc = 'remove all installed plugins' })

function bootstrap:clone()
    local path = vim.fn.stdpath('data') .. '/site/pack/paqs/start/paq-nvim'
    local already_cloned = vim.fn.empty(vim.fn.glob(path)) == 0

    if not already_cloned then
        vim.fn.system({
            'git', 'clone', '--depth=1',
            'https://github.com/savq/paq-nvim.git',
            path
        })
    end
    vim.cmd.packadd('paq-nvim')
    return require("paq")
end

local paq_available, paq = pcall(require, "paq")

if not paq_available then
    paq = bootstrap:clone()
end

function bootstrap:packages()
    local _packages = {'savq/paq-nvim'}
    vim.iter(self.configs):each(function(c)
        local config = require(c)
        vim.iter(config.packages):each(function(p)
            table.insert(_packages, p)
        end)
    end)
    return _packages
end

function bootstrap:install()
    vim.iter(self.configs):each(function(c)
        local module = require(c)
        if module.install then
            module.install()
        end
    end)
end

function bootstrap:configure(on_ready)
    vim.iter(self.configs):each(function(c)
        local module = require(c)
        if vim.iter(module.packages):all(is_installed) then
            module.setup()
        end
    end)
    if on_ready then on_ready() end
end

function bootstrap:sync()
    paq(self:packages())
    vim.api.nvim_create_autocmd("User", {
        pattern = "PaqDoneSync",
        once = true,
        callback = function()
            self:install()
            vim.iter(self.configs):each(function(c) require(c).setup() end)
            if self._on_ready then self._on_ready() end
        end
    })
    paq:sync()
end

function bootstrap:init(configs, on_ready)
    vim.list_extend(self.configs, configs)
    self._on_ready = on_ready
    if self._syncing then return end
    if paq_available then
        self:configure(on_ready)
    else
        self:sync()
    end
end

setmetatable(bootstrap, {
    __call = function(_, configs, on_ready)
        bootstrap:init(configs, on_ready)
    end
})

return bootstrap
