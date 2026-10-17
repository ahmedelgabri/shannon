local M = {}

M.name = 'tmux'

function M.current_pane()
  return vim.env.TMUX_PANE
end

-- Returns one "<pane id> <pane pid>" line for each pane in the current
-- window, including the current pane.
function M.list_panes()
  return vim.fn.system("tmux list-panes -F '#{pane_id} #{pane_pid}'")
end

function M.paste(pane, tmpfile)
  -- Use a unique, named buffer so concurrent Shannon invocations can't race
  -- on tmux's anonymous-buffer stack (paste-buffer without -b always targets
  -- the most-recently-created buffer, not the one we just loaded).
  local buffer_name = string.format('shannon-%d-%d', vim.fn.getpid(), vim.uv.hrtime())
  vim.fn.system({ 'tmux', 'load-buffer', '-b', buffer_name, tmpfile })
  -- Use bracketed paste (-p) so agent TUIs (pi, claude) treat embedded
  -- newlines as literal newlines (like Shift+Enter) instead of submitting
  -- on the first LF. -r disables tmux's default LF->CR replacement so real
  -- newlines reach the application. -d deletes our named buffer afterwards
  -- so we don't leak onto the stack and eventually evict the user's own
  -- buffers when buffer-limit (default 50) is hit. The trailing send-keys
  -- Enter is sent outside the bracketed paste and triggers the actual submit.
  vim.fn.system({ 'tmux', 'paste-buffer', '-d', '-p', '-r', '-b', buffer_name, '-t', pane })
  vim.fn.system({ 'tmux', 'send-keys', '-t', pane, 'Enter' })
end

return M
