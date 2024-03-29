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
        share.code = {
            server = [[
]],
            client = [[
function draw()
    L.circle('fill', 200, 200, 40, 40)
end
]],
        }
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
    if diff.code then -- Home code changed
        for name, code in pairs(diff.code) do
            if code ~= share.code[name] then
                -- Notify
                print('server: client ' .. clientId .. " changed mod '" .. name .. "'")

                -- Update share code
                share.code[name] = code

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
end
