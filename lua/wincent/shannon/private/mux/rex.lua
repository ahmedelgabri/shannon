local M = {}

M.name = 'Rex'

-- The scripts live in `rex/` at the root of the plugin, beside `bin/`, so that
-- `bin/find-nvim-socket` can use them too.
local root = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p:h:h:h:h:h:h')

local function script(name)
  return root .. '/rex/' .. name
end

function M.current_pane()
  return vim.env.REX_BLOCK
end

-- Returns one "<block id> <pid>" line for each terminal in the current
-- window, including the current terminal.
function M.list_panes()
  return vim.fn.system({ 'rex', 'do', script('panes.lua') })
end

function M.paste(pane, tmpfile)
  vim.fn.system({ 'rex', 'do', script('paste.lua'), 'block_id=' .. pane, 'path=' .. tmpfile })
end

return M
