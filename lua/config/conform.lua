-- conform.nvim - on-demand code formatting
--
-- <Leader>f  format selection or motion (all modes)

return {
    packages = { 'stevearc/conform.nvim' },
    setup = function()
        require('conform').setup({
            formatters_by_ft = {
                python = { 'ruff_format' },
            },
            formatters = {
                ruff_format = {
                    command = (function()
                        local venv = vim.fn.stdpath('data') .. '/lsp/pylsp/bin/ruff'
                        return vim.fn.executable(venv) == 1 and venv or 'ruff'
                    end)(),
                    args = { 'format', '--line-length', '80',
                             '--stdin-filename', '$FILENAME', '-' },
                },
            },
        })

        vim.keymap.set({ 'n', 'x' }, '<leader>f', function()
            require('conform').format({ lsp_fallback = false })
        end, { desc = 'ruff format selection' })
    end
}
