-- vim: set noai ts=4 sw=4:
--
-- LSP debug utility
-- :LspDebug  — open overview in a scratch buffer

local SEP = string.rep('─', 64)

-- Severity index: 1=ERROR 2=WARN 3=INFO 4=HINT
local function diag_counts(bufnr)
    local counts = { 0, 0, 0, 0 }
    for _, d in ipairs(vim.diagnostic.get(bufnr)) do
        counts[d.severity] = counts[d.severity] + 1
    end
    return counts
end

-- Load lsp/<server>.lua and try to resolve the cmd binary
local function server_cmd_status(name)
    local path = vim.fn.stdpath('config') .. '/lsp/' .. name .. '.lua'
    if vim.fn.filereadable(path) == 0 then
        return '(no lsp/' .. name .. '.lua)'
    end
    local ok, cfg = pcall(dofile, path)
    if not ok or type(cfg) ~= 'table' then
        return '(failed to load config)'
    end
    local cmd = cfg.cmd
    if type(cmd) == 'function' then
        local ok2, result = pcall(cmd)
        cmd = ok2 and result or nil
        if not ok2 then return '(cmd() error: ' .. tostring(result) .. ')' end
    end
    if type(cmd) ~= 'table' or not cmd[1] then
        return '(cmd not a table)'
    end
    local bin = cmd[1]
    if vim.fn.executable(bin) == 1 then
        return bin .. '  [ok]'
    else
        return bin .. '  [NOT FOUND]'
    end
end

-- Read last n ERROR lines from the LSP log
local function log_errors(n)
    local path = vim.lsp.get_log_path()
    local f = io.open(path, 'r')
    if not f then return nil, path end
    local errors = {}
    for line in f:lines() do
        if line:find('%[ERROR%]') then
            table.insert(errors, line)
        end
    end
    f:close()
    local tail = {}
    for i = math.max(1, #errors - n + 1), #errors do
        table.insert(tail, errors[i])
    end
    return tail, path
end

-- Collect names of configured servers from lsp/*.lua
local function configured_servers()
    local names = {}
    local pattern = vim.fn.stdpath('config') .. '/lsp/*.lua'
    for _, p in ipairs(vim.fn.glob(pattern, false, true)) do
        table.insert(names, vim.fn.fnamemodify(p, ':t:r'))
    end
    return names
end

local function build_report()
    local L = {}
    local add = function(s) table.insert(L, s or '') end

    local buf     = vim.api.nvim_get_current_buf()
    local ft      = vim.bo[buf].filetype
    local fname   = vim.api.nvim_buf_get_name(buf)
    local clients  = vim.lsp.get_clients()
    local attached = vim.lsp.get_clients({ bufnr = buf })

    -- Header
    add('LSP Debug  ' .. os.date('%Y-%m-%d %H:%M:%S'))
    add(SEP)

    -- Active clients
    add('')
    add('Active clients')
    if #clients == 0 then
        add('  (none)')
    else
        for _, c in ipairs(clients) do
            local bufs = vim.tbl_map(tostring, vim.lsp.get_buffers_by_client_id(c.id))
            add(string.format('  %-16s  id=%-3d  root=%s  bufs=[%s]',
                c.name, c.id,
                c.root_dir or '(none)',
                table.concat(bufs, ',')))
        end
    end

    -- Current buffer
    add('')
    add('Current buffer')
    add(string.format('  buf=%-4d  ft=%-12s  %s', buf, ft ~= '' and ft or '(none)', fname))
    if #attached == 0 then
        add('  attached: (none)')
    else
        for _, c in ipairs(attached) do
            add(string.format('  attached: %s (id=%d)', c.name, c.id))
        end
    end

    -- Diagnostics
    add('')
    add('Diagnostics')
    local dc = diag_counts(buf)
    add(string.format('  errors=%-4d  warnings=%-4d  hints=%-4d  info=%-4d',
        dc[1], dc[2], dc[4], dc[3]))

    -- Configured servers vs running
    add('')
    add('Configured servers  (lsp/*.lua)')
    local running = {}
    for _, c in ipairs(clients) do running[c.name] = c end

    for _, name in ipairs(configured_servers()) do
        if running[name] then
            local c = running[name]
            add(string.format('  %-16s  running  (id=%d, root=%s)',
                name, c.id, c.root_dir or 'none'))
        else
            local cmd_status = server_cmd_status(name)
            add(string.format('  %-16s  NOT RUNNING  —  %s', name, cmd_status))
        end
    end

    -- Log errors
    add('')
    local errors, log_path = log_errors(15)
    add('Log errors  (' .. log_path .. ')')
    if not errors or #errors == 0 then
        add('  (none)')
    else
        for _, line in ipairs(errors) do
            add('  ' .. line)
        end
    end

    add('')
    return L
end

local function open_debug_window()
    local report = build_report()

    local dbuf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(dbuf, 0, -1, false, report)
    vim.bo[dbuf].modifiable = false
    vim.bo[dbuf].buftype    = 'nofile'
    vim.bo[dbuf].bufhidden  = 'wipe'
    vim.bo[dbuf].filetype   = 'lspdebug'

    vim.cmd('botright 20split')
    vim.api.nvim_win_set_buf(0, dbuf)
    vim.keymap.set('n', 'q', '<cmd>bd!<CR>', { buffer = dbuf, silent = true })
end

vim.api.nvim_create_user_command('LspDebug', open_debug_window, { desc = 'LSP debug overview' })
