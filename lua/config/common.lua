-- Common plugins
--
return {

    packages = {
        'cocopon/iceberg.vim',
    },
    setup = function ()
        vim.cmd.colorscheme 'iceberg'

        -- Comment toggle (built-in gc)
        vim.keymap.set('n', '<Leader>cc', 'gcc',
            { remap = true, desc = 'toggle comment' })
        vim.keymap.set('v', '<Leader>cc', 'gc',
            { remap = true, desc = 'toggle comment' })
    end
}
