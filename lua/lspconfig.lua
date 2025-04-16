-- vim: set noai ts=4 sw=4:
--
-- LSP configuration
--
-- Usage in init.lua:
--   require("lspconfig")({ 'pylsp', ... })
--
-- Server configs go in lsp/<servername>.lua

local lspconfig = { _servers = {} }

-- Preview window — shared split buffer for doc and diagnostic display

local _preview_win = nil
local _preview_buf = nil

local function close_preview()
    if _preview_win and vim.api.nvim_win_is_valid(_preview_win) then
        vim.api.nvim_win_close(_preview_win, true)
        _preview_win = nil
    end
end

local function open_preview(lines, name)
    if not (_preview_buf and vim.api.nvim_buf_is_valid(_preview_buf)) then
        _preview_buf = vim.api.nvim_create_buf(false, true)
        vim.bo[_preview_buf].bufhidden = 'hide'
        vim.keymap.set('n', 'q', close_preview,
            { buffer = _preview_buf, silent = true })
    end
    pcall(vim.api.nvim_buf_set_name, _preview_buf, name)
    vim.lsp.util.stylize_markdown(_preview_buf, lines, {})
    if not (_preview_win and vim.api.nvim_win_is_valid(_preview_win)) then
        local cur_win = vim.api.nvim_get_current_win()
        vim.cmd('topleft ' .. math.min(15, #lines) .. 'split')
        _preview_win = vim.api.nvim_get_current_win()
        vim.api.nvim_win_set_buf(_preview_win, _preview_buf)
        vim.wo[_preview_win].conceallevel = 2
        vim.api.nvim_set_current_win(cur_win)
    end
end

-- Redirect LSP floating previews (hover, signature) into the preview split

local function lsp_open_preview(contents, _syntax, _opts)
    open_preview(contents, '[Doc]')
    return _preview_buf, _preview_win
end

-- Server config — load lsp/<name>.lua from the config directory

local function server_config(name)
    local path = vim.fn.stdpath('config') .. '/lsp/' .. name .. '.lua'
    if vim.fn.filereadable(path) == 0 then return nil end
    local ok, cfg = pcall(dofile, path)
    return ok and cfg or nil
end

-- Server management — install, start, and stop configured servers

local function lsp_install()
    for _, name in ipairs(lspconfig._servers) do
        local cfg = server_config(name)
        if cfg and cfg.install then
            cfg.install()
        else
            print('[lsp] no install() defined for ' .. name)
        end
    end
end

local function lsp_start()
    for _, name in ipairs(lspconfig._servers) do
        local cfg = server_config(name)
        if cfg then
            vim.lsp.start(cfg)
        else
            print('[lsp] no config found for ' .. name)
        end
    end
end

local function lsp_stop()
    for _, client in ipairs(vim.lsp.get_clients()) do
        if vim.tbl_contains(lspconfig._servers, client.name) then
            client:stop()
        end
    end
end

local function setup_commands()
    local cmd = vim.api.nvim_create_user_command
    cmd('LspInstall', lsp_install, { desc = 'Install LSP servers' })
    cmd('LspStart',   lsp_start,   { desc = 'Start LSP servers' })
    cmd('LspStop',    lsp_stop,    { desc = 'Stop LSP servers' })
end

-- Diagnostics — severity helpers, cmdline echo, location list sync

local severity_hl = {
    [vim.diagnostic.severity.ERROR] = 'DiagnosticError',
    [vim.diagnostic.severity.WARN]  = 'DiagnosticWarn',
    [vim.diagnostic.severity.INFO]  = 'DiagnosticInfo',
    [vim.diagnostic.severity.HINT]  = 'DiagnosticHint',
}

local severity_labels = { 'Error', 'Warning', 'Info', 'Hint' }

local function by_severity(a, b) return a.severity < b.severity end

local function on_diagnostic_changed()
    vim.diagnostic.setloclist({ open = false })
end

-- Echo the highest-severity diagnostic for the current line in the cmdline

local function on_cursor_moved()
    local diags = vim.diagnostic.get(0, { lnum = vim.fn.line('.') - 1 })
    if #diags == 0 then
        vim.api.nvim_echo({}, false, {})
        return
    end
    table.sort(diags, by_severity)
    local d = diags[1]
    local msg = d.message:match('[^\n]+') or d.message
    if #msg > 79 then msg = msg:sub(1, 76) .. '...' end
    vim.api.nvim_echo({{ msg, severity_hl[d.severity] }}, false, {})
end

local function setup_diagnostics(augroup)
    vim.diagnostic.config({
        virtual_text     = false,
        underline        = false,
        signs            = true,
        update_in_insert = false,
    })

    vim.lsp.util.open_floating_preview = lsp_open_preview

    vim.api.nvim_create_autocmd('DiagnosticChanged', {
        group    = augroup,
        callback = on_diagnostic_changed,
    })

    vim.api.nvim_create_autocmd('LspAttach', {
        group    = augroup,
        callback = function(ev)
            vim.api.nvim_create_autocmd('CursorMoved', {
                group  = augroup,
                buffer = ev.buf,
                callback = on_cursor_moved,
            })
        end,
    })
end

-- Keymaps — buffer-local LSP bindings, attached on LspAttach

local function toggle_doc()
    if _preview_win and vim.api.nvim_win_is_valid(_preview_win) then
        close_preview()
    else
        vim.lsp.buf.hover()
    end
end

-- Show diagnostics for the current line in the preview split

local function toggle_diagnostic()
    if _preview_win and vim.api.nvim_win_is_valid(_preview_win) then
        close_preview()
    else
        local diags = vim.diagnostic.get(0, { lnum = vim.fn.line('.') - 1 })
        if #diags == 0 then return end
        table.sort(diags, by_severity)
        local lines = {}
        for _, d in ipairs(diags) do
            local label = severity_labels[d.severity] or 'Diagnostic'
            local source = d.source and (' [' .. d.source .. ']') or ''
            table.insert(lines, label .. source .. ': ' .. d.message)
        end
        open_preview(lines, '[Diagnostic]')
    end
end

local function setup_keymaps(ev)
    local function map(keys, func, desc)
        vim.keymap.set('n', keys, func, { buffer = ev.buf, desc = desc })
    end
    map('gd',         vim.lsp.buf.definition,     'go to definition')
    map('gD',         vim.lsp.buf.declaration,    'go to declaration')
    map('gr',         vim.lsp.buf.references,     'list references')
    map('gi',         vim.lsp.buf.implementation, 'go to implementation')
    map('K',          toggle_doc,                 'toggle hover docs')
    map('<leader>rn', vim.lsp.buf.rename,         'rename symbol')
    map('<leader>ca', vim.lsp.buf.code_action,    'code action')
    map('<leader>f',  vim.lsp.buf.format,         'format buffer')
    map('<leader>e',  toggle_diagnostic,          'toggle diagnostic')
end

-- Initialisation

function lspconfig:init(servers)
    self._servers = servers
    vim.lsp.enable(servers)

    local augroup = vim.api.nvim_create_augroup('lspconfig', { clear = true })

    vim.api.nvim_create_autocmd('LspAttach', {
        group    = augroup,
        callback = setup_keymaps,
    })

    setup_diagnostics(augroup)
    setup_commands()
end

setmetatable(lspconfig, {
    __call = function(_, servers)
        lspconfig:init(servers)
    end
})

return lspconfig
