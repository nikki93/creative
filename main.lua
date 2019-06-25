L = require('https://raw.githubusercontent.com/nikki93/L/3f63e72eef6b19a9bab9a937e17e527ae4e22230/L.lua')


local Mod = require 'mod'


local selectedModName = nil

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
        -- Name input
        local newName = L.ui.textInput('name', selectedMod.name)
        if newName ~= selectedMod.name and not Mod.byName(newName) then
            selectedMod:rename(newName)
            selectedModName = newName
        end

        -- Code editor
        selectedMod:codeEditor('code')

        -- UI
        selectedMod:safeCall('ui')
    end
end


function love.draw()
    L.stacked('all', function()
        local main = Mod.byName('main')
        if main then
            main:safeCall('draw')
        end
    end)

    L.print('fps: ' .. L.getFPS(), 20, 20)
end


Mod.new({
    name = 'circle',
    code = [[
radius = restored.radius or 40

function draw()
    L.circle('fill', 200, 300, radius)
end

function ui()
    radius = L.ui.slider('radius', radius, 20, 100)
end
]],
})

Mod.new({
    name = 'main',
    code = [[
circle = require 'circle'

function draw()
    circle.draw()
end
]],
})