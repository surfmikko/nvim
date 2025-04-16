-- PlantUML connection direction keymaps
--
-- Keymaps (plantuml buffers only):
--   <Leader>udh/l/k/j     set connection direction left/right/up/down
--   <Leader>udd           remove direction
--   <Leader>ut            wrap selection in together{}
--   <Leader>un            wrap selection in node server{}
--
-- Works on current line (normal mode) or selected lines (visual mode).
-- Handles all connector styles: --> ..> <|-- *-- o-- -->> etc.
--
-- Connector chars: - .
-- Direction words: left right up down

local directions = { 'left', 'right', 'up', 'down' }

local function transform_line(line, dir)
    for _, d in ipairs(directions) do
        local repl = dir == '' and '%1%2' or ('%1' .. dir .. '%2')
        local new, n = line:gsub('([%-%.])' .. d .. '([%-%.>])', repl)
        if n > 0 then return new end
    end
    if dir ~= '' then
        local new, n = line:gsub('([%-%.])([%-%.]+)', '%1' .. dir .. '%2', 1)
        if n > 0 then return new end
    end
    return line
end

local function set_direction(dir)
    local lnum = vim.fn.line('.') - 1
    local line = vim.api.nvim_buf_get_lines(0, lnum, lnum + 1, false)[1]
    vim.api.nvim_buf_set_lines(0, lnum, lnum + 1, false,
        { transform_line(line, dir) })
end

local function set_direction_visual(dir)
    local line1 = vim.fn.line('v')
    local line2 = vim.fn.line('.')
    if line1 > line2 then line1, line2 = line2, line1 end
    for lnum = line1, line2 do
        local lines = vim.api.nvim_buf_get_lines(0, lnum-1, lnum, false)
        if lines[1] then
            vim.api.nvim_buf_set_lines(0, lnum-1, lnum, false,
                { transform_line(lines[1], dir) })
        end
    end
end

local function wrap_block(label)
    local line1 = vim.fn.line('v')
    local line2 = vim.fn.line('.')
    if line1 > line2 then line1, line2 = line2, line1 end
    local indent = vim.api.nvim_buf_get_lines(0, line1-1, line1, false)[1]
                       :match('^(%s*)')
    vim.api.nvim_buf_set_lines(0, line2, line2, false, { indent .. '}' })
    vim.api.nvim_buf_set_lines(0, line1-1, line1-1, false,
        { indent .. label .. ' {' })
end

local function dir_left()     set_direction('left')         end
local function dir_right()    set_direction('right')        end
local function dir_up()       set_direction('up')           end
local function dir_down()     set_direction('down')         end
local function dir_none()     set_direction('')             end
local function dir_left_v()   set_direction_visual('left')  end
local function dir_right_v()  set_direction_visual('right') end
local function dir_up_v()     set_direction_visual('up')    end
local function dir_down_v()   set_direction_visual('down')  end
local function dir_none_v()   set_direction_visual('')      end
local function wrap_together() wrap_block('together')       end
local function wrap_node()     wrap_block('node server')    end

local function setup_keymaps(ev)
    local opts = { buffer = ev.buf, silent = true }
    local function map(key, fn_n, fn_v, desc)
        local o = vim.tbl_extend('force', opts, { desc = desc })
        vim.keymap.set('n', key, fn_n, o)
        vim.keymap.set('v', key, fn_v, o)
    end
    local function mapv(key, fn, desc)
        vim.keymap.set('v', key,
            fn, vim.tbl_extend('force', opts, { desc = desc }))
    end
    map('<Leader>udh', dir_left,  dir_left_v,  'set direction left')
    map('<Leader>udl', dir_right, dir_right_v, 'set direction right')
    map('<Leader>udk', dir_up,    dir_up_v,    'set direction up')
    map('<Leader>udj', dir_down,  dir_down_v,  'set direction down')
    map('<Leader>udd', dir_none,  dir_none_v,  'remove direction')
    mapv('<Leader>ut', wrap_together, 'wrap in together{}')
    mapv('<Leader>un', wrap_node,     'wrap in node server{}')
end

local function setup()
    vim.api.nvim_create_autocmd('FileType', {
        pattern  = 'plantuml',
        callback = setup_keymaps,
    })
end

return {
    packages = {},
    setup    = setup,
}
