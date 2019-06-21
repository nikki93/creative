-- Global libary aliases

L = require('https://raw.githubusercontent.com/nikki93/L/ff3406daa415076c1207b6894c00af61bc7405c4/L.lua')
C = castle
U = C.ui


local code = [[
local radius = 40

function panel()
    radius = U.slider('radius', radius, 20, 100)
end

function draw()
    L.circle('fill', 400, 400, radius)
end
]]

local lastChangeTime

local namespace

local function reset()
    namespace = setmetatable({}, { __index = _G })
end

reset()

local function compile()
    local compiled, err = load(code, 'code', 't', namespace)
    if compiled then
        compiled()
    else
        reset()
        error(err)
    end
end

compile()

local function safeCall(foo)
    if foo then
        local succ, err = pcall(foo)
        if not succ then
            reset()
            error(err)
        end
    end
end


function castle.uiupdate()
    U.section('code', function()
        local newCode = U.codeEditor('code', code)
        if newCode ~= code then
            code = newCode
            lastChangeTime = L.getTime()
        end
    end)

    U.section('panel', function()
        safeCall(namespace.panel)
    end)
end

function love.update()
    if lastChangeTime ~= nil and L.getTime() - lastChangeTime > 0.8 then
        lastChangeTime = nil
        compile()
    end
end

function love.draw()
    L.pushed('all', function()
        safeCall(namespace.draw)
    end)

    L.print('fps: ' .. L.getFPS(), 20, 20)
end
