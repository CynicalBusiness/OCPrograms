local util = dofile("./harvester-util")

local USAGE_SET = "Usage: `set <address: string> <side: string> [=slot: number] [threshold: number]`"

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

return module
