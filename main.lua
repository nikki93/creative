L = require('https://raw.githubusercontent.com/nikki93/L/3f63e72eef6b19a9bab9a937e17e527ae4e22230/L.lua')


local Mod = require 'mod'


local circle = Mod.new({
    name = 'circle',
    code = [[
local radius = 40

function E.ui()
    radius = L.ui.slider('radius', radius, 20, 100)
end

function E.draw()
    L.circle('fill', 200, 300, radius)
end
    ]],
})


function castle.uiupdate()
    circle:ui()
end

function love.draw()
    L.stacked('all', function()
        circle:safeCall('draw')
    end)

    L.print('fps: ' .. L.getFPS(), 20, 20)
end
