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
    do -- User
        home.user = castle.user.getMe()
    end

    do -- Code
        home.code = {}
    end

    do -- S
        home.S = {}
    end
end


--- UI

local selectedModName

function castle.uiupdate()
    if client.connected then
        L.ui.markdown("You control '" .. share.ownership[client.id] .. "'")

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
        local selectedMod = Mod.byName(selectedModName)
        if not selectedMod then
            selectedModName = nil
        end
        L.ui.markdown('----')

        -- Editor for selected mod
        if selectedMod then
            -- Code editor
            selectedMod:codeEditor('code')

            -- UI
            if selectedModName == share.ownership[client.id] then
                selectedMod:safeCall('ui')
            end
        end
    else
        L.ui.markdown('Connecting...')
    end
end


--- DRAW

function client.draw()
    if client.connected then
        do -- Mods
            for _, modName in pairs(share.ownership) do
                local mod = Mod.byName(modName)
                if mod then
                    L.stacked('all', function()
                        mod:safeCall('draw')
                    end)
                end
            end
        end
    else -- Not connected
        L.print('\n\nConnecting...', 20, 20)
    end

    L.print('fps: ' .. L.getFPS(), 20, 20)
end


--- UPDATE

function client.update(dt)
    if client.connected then
        do -- Mods -> Home code
            for name, mod in pairs(Mod:allByName()) do
                if home.code[name] ~= mod.code then
                    home.code[name] = mod.code
                end
            end
        end

        do -- Our update
            local mod = Mod.byName(share.ownership[client.id])
            if mod then
                mod:safeCall('update', dt)
            end
        end
    end
end


--- CHANGED

function client.changed(diff)
    if diff.code then -- Share code changed
        for name, code in pairs(diff.code) do
            -- Notify
            print("client: server changed mod '" .. name .. "'")

            -- Pick S
            local S
            if name == share.ownership[client.id] then -- Me
                S = home.S
            else -- Other
                S = share.S[name]
            end

            -- Update Mod
            local mod = Mod.byName(name)
            if not mod then -- New mod?
                Mod.new({
                    name = name,
                    code = code,
                    envBase = {
                        S = S,
                    },
                })
            elseif mod.code ~= code then -- Code changed?
                mod.code = code
                mod:compile()
            end
        end
    end
end