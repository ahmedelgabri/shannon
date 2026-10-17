-- Usage: rex do panes.lua
--
-- Prints one "<block id> <pid>" line for each terminal in the window of the
-- calling block (`REX_BLOCK`). The pid is the terminal's child process, which
-- every program in the terminal descends from, like `#{pane_pid}` in tmux.

local terminal = 'com.superlogical.terminal'

local window_id = assert(rex.session.describe_block({ block_id = rex.block_id })).block.window_id

for _, block in ipairs(assert(rex.session.list_blocks({})).blocks) do
  if block.window_id == window_id and block.creator_name == terminal then
    local process = rex.block.call(terminal, 'process', { block_id = block.block_id })
    if process and process.child then
      print(block.block_id .. ' ' .. process.child.pid)
    end
  end
end
