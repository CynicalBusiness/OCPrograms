local harvesterEditor = dofile("../harvester-edit")

local args, opts = shell.parse(...)
local cmd = string.lower(table.remove(args, 1))

if harvesterEditor[cmd] then
    harvesterEditor[cmd](args, opts)
end
