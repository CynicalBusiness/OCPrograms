local harvesterEditor = dofile("../harvester-edit")

local args, opts = shell.parse(...)
local cmd = string.lower(table.remove(args, 1))

if harvesterEditor[cmd] and not opts.help then
    harvesterEditor[cmd](args, opts)
else
    harvesterEditor.help(args, opts)
end
