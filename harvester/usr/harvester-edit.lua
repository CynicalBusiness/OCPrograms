local CONFIG_PATH = "/etc/harvester.cfg"

local component = require("component")
local filesystem = require("filesystem")
local serialization = require("serialization")

-- === CACHE
local cahce = {}

-- === HELPERS
-- reads the config from disk
function readConfig ()
    if cache.config then return cache.config end

    local cfgFile = filesystem.open(CONFIG_PATH)
    local cfg = serialization.unserialize(cfgFile:read(0xFFFFFFFF))
    cfgFile:close()

    cache.config = cfg
    return cfg
end

-- gets the `filesystem` component for the DB to be stored
function getDBFileSystem ()
    if cache.fs then return cache.fs end

    local cfg = readConfig()
    local label = cfg.databaseLabel

    if not type(label) == "string" or #label == 0 then error("DB Disk label must be non-empty string") end

    local path = "/dev/components/by-label" .. label
    local addressFile = filesystem.open(path .. "/address")
    local address = addressFile:read(0xFFFFFFFF)
    addressFile:close()

    local fs = component.proxy(address)
    cache.fs = fs
    return fs
end

-- reads the database from disk
function readDB ()
    if cache.db then return cache.db end

    local cfg = readConfig()
    local fs = getDBFileSystem()

    local path = cfg.databasePath
    if not type(path) == "string" or string.len(path) == 0 then error("DB file path must be a non-empty string") end

    local dbFile = fs.open(path)
    local dbData = fs.read(dbFile, 0xFFFFFFFF)
    local db = serialization.unserialize(dbData)
    fs.close(dbFile)

    db.nodes = db.nodes or {}

    print("read DB: " .. string.len(dbData) .. " chars")
    return db
end

-- writes the current value of the database to disk
function writeDB (db)
    local cfg = readConfig()
    local fs = getDBFileSystem()

    local path = cfg.databasePath
    if not type(path) == "string" or string.len(path) == 0 then error("DB file path must be a non-empty string") end

    local dir = filesystem.path(path)
    fs.makeDirectory(dir)

    local dbFile = fs.open(path)
    local dbData = serialization.serialize(db)
    fs.write(dbFile, dbData)
    fs.close(dbFile)

    print("wrote DB: " .. string.len(dbData))
end

-- === MODULE
local module = {}

function module:init (args, opts)
    local cfg = readConfig()
    local fs = getDBFileSystem()
    if fs.exists(cfg.databasePath) and not opts.reinit then
        print("Database already exists. If you wish to wipe the database and re-initialize, use `--reinit`")
    else
        writeDB({})
    end
end

return module
