-- ctrlp.vim - Fuzzy file finder
--
-- C-p  open file search
--
return {
    packages = { 'kien/ctrlp.vim' },
    setup = function()
        vim.g.ctrlp_map = '<c-p>'
        vim.g.ctrlp_custom_ignore = 'venv\\|.venv\\|node_modules\\|.git'
        vim.g.ctrlp_user_command = {
            '.git',
            'cd %s && git ls-files --exclude-standard -co | grep -Ev "\\.(png|jpg|jpeg|gif)$|node_modules"',
        }
    end
}
