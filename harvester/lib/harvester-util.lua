local CONFIG_PATH = "/etc/harvester.cfg"
local ERR_NO_LABEL = "DB Disk label must be non-empty string"
local ERR_NO_PATH = "DB file path must be a non-empty string"
local ERR_BAD_ID = "ID must be a non-empty string"
local ERR_BAD_QUANTITY = "Quantity must be a positive number"
local ERR_NO_DB = "Unable to locate database"

local component = require("component")
local filesystem = require("filesystem")
local serialization = require("serialization")

-- == MODULE
local module = {}

-- === CACHE
local cahce = {}

-- reads the config from disk
function module.readConfig ()
    if cache.config then return cache.config end

    local cfgFile = filesystem.open(CONFIG_PATH)
    local cfg = serialization.unserialize(cfgFile:read(0xFFFFFFFF))
    cfgFile:close()

    cache.config = cfg
    return cfg
end

-- gets the `filesystem` component for the DB to be stored
function module.getStorageFileSystem ()
    local cfg = readConfig()
    local label = cfg.databaseLabel

    if not type(label) == "string" or #label == 0 then error(ERR_NO_LABEL) end

    local path = "/dev/components/by-label" .. label
    local addressFile = filesystem.open(path .. "/address")
    local address = addressFile:read(0xFFFFFFFF)
    addressFile:close()

    local fs = component.proxy(address)
    cache.fs = fs
    return fs
end

-- reads the database from disk
function module.readStorage ()
    local cfg = readConfig()
    local fs = getStorageFileSystem()

    local path = cfg.databasePath
    if not type(path) == "string" or string.len(path) == 0 then error(ERR_NO_PATH) end

    local dbFile = fs.open(path)
    local dbData = fs.read(dbFile, 0xFFFFFFFF)
    local db = serialization.unserialize(dbData)
    fs.close(dbFile)

    db.nodes = db.nodes or {}

    print("read DB: " .. string.len(dbData) .. " chars")
    return db
end

-- writes the current value of the database to disk
function module.writeStorage (db)
    local cfg = readConfig()
    local fs = getStorageFileSystem()

    local path = cfg.databasePath
    if not type(path) == "string" or string.len(path) == 0 then error(ERR_NO_PATH) end

    local dir = filesystem.path(path)
    fs.makeDirectory(dir)

    local dbFile = fs.open(path)
    local dbData = serialization.serialize(db)
    fs.write(dbFile, dbData)
    fs.close(dbFile)

    print("wrote DB: " .. string.len(dbData))
end

-- creates a key for the storage dictionary
function module.createStorageKey (address, side)
    if string.len(address) > 4 then
        address = string.sub(address, 1, 4)
    end
    return address .. "/" .. side
end

-- reads from a database slot. will read the database at the given address, or the "primary" database
function module.readFromDatabase (slot, address)
    local db =  address and component.proxy(address) or component.getPrimary("database")
    if db and type(db.get) == "function" then
        local item = db.get(slot)
        item.size = nil
        return item
    else
        error(ERR_NO_DB)
    end
end

-- finds an item in the ME network
function module.findInNetwork (itemDescription)
    local me = component.list("me_")[1]
    if not me then error("No ME devices are available") end

    return me.getItemsInNetwork(itemDescription)[1]
end

function module.getSignalState (address, side)
    return component.proxy(component.get(address)).getOutput(side)
end

-- sets the state of a Redstone component at the given address
function module.setSignalState (address, side, state)
    component.proxy(component.get(address)).setOutput(side, state)
end

return module
