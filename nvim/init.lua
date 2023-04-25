require('lplatzer.base')
require('lplatzer.plugins')

local has = vim.fn.has
local is_mac = has "macunix"
local is_win = has "win32"


if is_mac then
    require('lplatzer.macos')
end
if is_win then
    require('lplatzer.windows')
end

