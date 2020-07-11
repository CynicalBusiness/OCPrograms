local util = require("harvester-util")
local shell = require("shell")

local USAGE_INIT = "init"
local USAGE_SET = "set <address: string> <side: string> [=slot: number] [threshold: number]"

-- === MODULE
local module = {}

function module.init (args, opts)
    local cfg = util.readConfig()
    local fs = util.getStorageFileSystem()
    if fs.exists(cfg.databasePath) and not opts.reinit then
        print("Database already exists. If you wish to wipe the database and re-initialize, use `--reinit`")
    else
        util.writeStorage({})
    end
end

function module.set (args, opts)
    local address, side = args[1], args[2]
    local key = util.createStorageKey(address, side)
    local storage = util.readStorage()

    if #args == 2 then
        storage[key] = nil
        print("Cleared: " .. key)
    elseif #args == 4 then
        local slot, threshold = tonumber(args[3]), tonumber(args[4])
        local item = util.readFromDatabase(slot)
        storage[key] = {
            address = address,
            side = side,
            item = item,
            threshold = threshold
        }
        print(string.format("Set: %s to x%i %s/%i", key, threshold, item.name, item.damage))
    else
        error(USAGE_SET)
    end

    util.writeStorage(storage)
end

function module.help ()
    for _, v in ipairs({ USAGE_INIT, USAGE_SET }) do
        print("harvester-edit " .. v)
    end
end

-- CLI
local args, opts = shell.parse(...)
local cmd = #args > 1 and string.lower(table.remove(args, 1)) or nil

if cmd and module[cmd] and not opts.help then
    module[cmd](args, opts)
else
    module.help(args, opts)
end
