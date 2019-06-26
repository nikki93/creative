require 'common'


--- CLIENT

local client = cs.client

if USE_CASTLE_CONFIG then
    client.useCastleConfig()
else
    client.enabled = true
    client.start('127.0.0.1:22122')
end

local share = client.share
local home = client.home


--- CONNECT

function client.connect()
    do -- Walk
        home.code = {}
    end
end


--- UI

function castle.uiupdate()
    local selectedMod = Mod.byName(selectedModName)
    if not selectedMod then
        selectedModName = nil
    end

    -- Dropdown box for selecting a mod
    do
        local modNames = {}
        for name in pairs(Mod.allByName()) do
            table.insert(modNames, name)
        end
        table.sort(modNames, function(a, b)
            return a:upper() < b:upper()
        end)
        selectedModName = L.ui.dropdown('Selected mod name', selectedModName, modNames, {
            hideLabel = true,
            placeholder = 'Select a module...',
        })
    end

    L.ui.markdown('----')

    -- Editor for selected mod
    if selectedMod then
        -- Code editor
        selectedMod:codeEditor('code')

        -- UI
        selectedMod:safeCall('ui')
    end
end


--- DRAW

function client.draw()
    if client.connected then
        do -- Main
            local main = Mod.byName('client')
            if main then
                L.stacked('all', function()
                    main:safeCall('draw')
                end)
            end
        end
    else -- Not connected
        L.print('\n\nConnecting...', 20, 20)
    end

    L.print('fps: ' .. L.getFPS(), 20, 20)
end


--- UPDATE

function client.update(dt)
    for name, mod in pairs(Mod:allByName()) do
        if home.code[name] ~= mod.code then
            home.code[name] = mod.code
        end
    end
end


--- CHANGED

function client.changed(diff)
    if diff.code then -- Share code changed
        for name, code in pairs(diff.code) do
            -- Notify
            print("client: server changed mod '" .. name .. "'")

            -- Update Mod
            local mod = Mod.byName(name)
            if not mod then -- New mod?
                Mod.new({
                    name = name,
                    code = code,
                })
            elseif mod.code ~= code then -- Code changed?
                mod.code = code
                mod:compile()
            end
        end
    end
end