-- vim: set noai ts=4 sw=4:
--
-- Bootstrap - Install and configure plugins
--
-- Plugin config module interface (lua/config/myplugin.lua):
--   return {
--       packages = { 'author/plugin', ... },
--       setup    = function() ... end,
--   }
--
-- Usage in init.lua:
--   require("bootstrap")({ 'config.foo', 'config.bar' }, on_ready)
--
-- Commands:
--   :Bootstrap          clone missing and update all plugins
--   :Bootclean          remove all plugins (re-cloned on next start)

local pack = vim.fn.stdpath('data') .. '/site/pack/plugins/start/'

local function clone(pkg)
    local dir = pack .. pkg:match('[^/]+$')
    if vim.fn.isdirectory(dir) == 1 then return end
    print('[bootstrap] cloning ' .. pkg:match('[^/]+$') .. '...')
    vim.fn.system({ 'git', 'clone', '--depth=1',
        'https://github.com/' .. pkg, dir })
end

local function update(pkg)
    local dir = pack .. pkg:match('[^/]+$')
    if vim.fn.isdirectory(dir) == 0 then clone(pkg); return end
    vim.fn.system({ 'git', '-C', dir, 'pull', '--ff-only' })
end

local _configs = {}

vim.api.nvim_create_user_command('Bootstrap', function()
    for _, c in ipairs(_configs) do
        for _, pkg in ipairs(require(c).packages or {}) do update(pkg) end
    end
    print('[bootstrap] done')
end, { desc = 'clone missing and update all plugins' })

vim.api.nvim_create_user_command('Bootclean', function()
    vim.fn.delete(pack, 'rf')
    print('[bootstrap] removed all plugins')
end, { desc = 'remove all plugins' })

return function(configs, on_ready)
    _configs = configs
    for _, c in ipairs(configs) do
        for _, pkg in ipairs(require(c).packages or {}) do clone(pkg) end
    end
    vim.cmd('silent! packloadall')
    require('config.common').setup()
    vim.schedule(function()
        for _, c in ipairs(configs) do
            if c ~= 'config.common' then require(c).setup() end
        end
        if on_ready then on_ready() end
    end)
end
