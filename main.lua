-- Global libary aliases

L = require('https://raw.githubusercontent.com/nikki93/L/3f63e72eef6b19a9bab9a937e17e527ae4e22230/L.lua')


local code = [[
local radius = 40

function panel()
    radius = L.ui.slider('radius', radius, 20, 100)
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
    L.ui.section('code', { defaultOpen = true }, function()
        local newCode = L.ui.codeEditor('code', code, {
            hideLabel = true,
        })
        if newCode ~= code then
            code = newCode
            lastChangeTime = L.getTime()
        end
    end)

    L.ui.section('panel', { defaultOpen = true }, function()
        safeCall(namespace.panel)
    end)
end

function love.update()
    if lastChangeTime ~= nil and L.getTime() - lastChangeTime > 0.4 then
        lastChangeTime = nil
        compile()
    end
end

function love.draw()
    L.stacked('all', function()
        safeCall(namespace.draw)
    end)

    L.print('fps: ' .. L.getFPS(), 20, 20)
end
