-- Usage: rex do paste.lua block_id=BLOCK path=FILE
--
-- Types the contents of FILE into the terminal BLOCK and presses Enter, like
-- `tmux paste-buffer -p -r` followed by `tmux send-keys Enter`.

local terminal = 'com.superlogical.terminal'
local block_id = rex.args.block_id

local file = assert(io.open(rex.args.path, 'rb'))
local text = file:read('*a')
file:close()

-- Rex has no paste method, so do what `paste-buffer -p` does: add the
-- bracketed-paste markers only when the program has turned on bracketed paste
-- mode (DECSET 2004). Programs that haven't would see the markers as input.
local screen = assert(rex.block.call(terminal, 'format', {
  block_id = block_id,
  format = 'vt',
  extra_modes = true,
}))
if screen.content:find('\27[?2004h', 1, true) then
  text = '\27[200~' .. text .. '\27[201~'
end

-- Rex refuses requests over 64 KiB once encoded as JSON, where one byte can
-- take six (`\u001b`), so write in chunks. Cut only between UTF-8 characters,
-- because each chunk must be a valid JSON string.
local chunk_size = 8192
local first = 1
while first <= #text do
  local last = math.min(first + chunk_size - 1, #text)
  while last < #text and text:byte(last + 1) >= 0x80 and text:byte(last + 1) < 0xc0 do
    last = last - 1
  end
  assert(rex.block.call(terminal, 'write', { block_id = block_id, data = text:sub(first, last) }))
  first = last + 1
end

assert(rex.block.call(terminal, 'write', { block_id = block_id, data = '\r' }))
