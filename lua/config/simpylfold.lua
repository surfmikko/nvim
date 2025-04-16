-- SimpylFold - Python folding
--
return {
    packages = {
        'tmhedberg/SimpylFold',
    },
    setup = function()
        vim.api.nvim_create_autocmd('FileType', {
            pattern  = 'python',
            callback = function()
                vim.opt_local.foldmethod = 'expr'
                vim.opt_local.foldexpr   = 'SimpylFold(v:lnum)'
                vim.opt_local.foldenable = false
            end,
        })
    end
}
