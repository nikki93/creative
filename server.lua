require 'common'


--- SERVER

local server = cs.server

if USE_CASTLE_CONFIG then
    server.useCastleConfig()
else
    server.enabled = true
    server.start('22122')
end

local share = server.share
local homes = server.homes


--- LOAD

function server.load()
    do -- Code
        share.code = {}
    end

    do -- Ownership
        share.ownership = {}
    end

    do -- S
        share.S = {}
    end
end


--- CONNECT

function server.connect(clientId)
end


--- DISCONNECT

function server.disconnect(clientId)
end


--- CHANGED

function server.changed(clientId, diff)
    if diff.user then -- User data changed
        if not share.ownership[clientId] then
            -- Pick a new mod name
            local index = 0
            local newModName = diff.user.name
            while share.code[newModName] do
                index = index + 1
                newModName = diff.user.name .. index
            end

            -- Set ownership
            share.ownership[clientId] = newModName

            -- Initialize code
            share.code[newModName] = [[
-- Start at random position
S.x = S.x or math.random(0, L.getWidth())
S.y = S.y or math.random(0, L.getHeight())

-- ... and with random color
S.r = S.r or math.random()
S.g = S.g or math.random()
S.b = S.b or math.random()
S.a = S.a or 1

-- Walk speed
S.speed = 200

-- Draw as a circle
function draw()
    L.setColor(S.r, S.g, S.b, S.a)
    L.circle('fill', S.x, S.y, 40)
end

-- Walk around
function update(dt)
    if L.keyboard.isDown('a') then
        S.x = S.x - S.speed * dt
    end
    if L.keyboard.isDown('d') then
        S.x = S.x + S.speed * dt
    end
    if L.keyboard.isDown('w') then
        S.y = S.y - S.speed * dt
    end
    if L.keyboard.isDown('s') then
        S.y = S.y + S.speed * dt
    end
end

-- Show UI panel (you only see it for the module you control)
function ui()
    S.speed = L.ui.slider('speed', S.speed, 0, 800)
    S.r, S.g, S.b, S.a = L.ui.colorPicker('color', S.r, S.g, S.b, S.a)
end
            ]]
        end
    end

    if diff.code then -- Code changed
        for name, code in pairs(diff.code) do
            if code ~= share.code[name] then
                -- Notify
                print('server: client ' .. clientId .. " changed mod '" .. name .. "'")

                -- Update share code
                share.code[name] = code

                -- Update Mod
                -- local mod = Mod.byName(name)
                -- if not mod then -- New mod?
                --     Mod.new({
                --         name = name,
                --         code = code,
                --     })
                -- elseif mod.code ~= code then -- Code changed?
                --     mod.code = code
                --     mod:compile()
                -- end
            end
        end
    end

    if diff.S then -- S changed
        local modName = share.ownership[clientId]
        if diff.S.__exact then -- Special handling for top-level `.__exact`
            local oldExact = diff.S.__exact
            diff.S.__exact = nil
            share.S[modName] = diff.S
            diff.S.__exact = oldExact
        else
            if not share.S[modName] then
                share.S[modName] = {}
            end
            assert(customApply(share.S[modName], diff.S) == share.S[modName])
        end
    end
end
