
util = dofile("./harvester-util")

local db
local running = false

-- TODO display screen

function start ()
    running = true
    print("Starting harvester")

    local storage = util.readStorage()

    repeat
        for _, desc in pairs(storage) do
            local state = util.getSignalState(desc.address, desc.side)
            local newState = state

            local foundSize = 0

            if type(desc.threshold) == "number" and desc.threshold > 0 then
                -- get information about the item from the network
                -- TODO handle items that should be crafted first
                local item = util.findInNetwork(desc.item)
                if item then
                    foundSize = item.size
                    newState = foundSize < desc.threshold
                end
            end

            if state ~= newState then
                print(string.format("%s: %s/%s %i/%i (%s/%i)",
                    (newState and " Enable" or "Disable"),
                    desc.address, desc.side, foundSize,
                    desc.threshold, desc.item.name, desc.item.damage))
                -- set the state
                util.setSignalState(desc.address, desc.side, not not desc.active)
            end
        end
        os.sleep(1)
    until not running
end

function stop ()
    print("Stopping harvester")
    running = false
end
