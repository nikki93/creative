L = require('https://raw.githubusercontent.com/nikki93/L/3f63e72eef6b19a9bab9a937e17e527ae4e22230/L.lua')


local Mod = require 'mod'


local mods = {}


mods['main'] = Mod.new({
    name = 'main',
    code = [[
radius = restored.radius or 40

function draw()
    L.circle('fill', 200, 300, radius)
end

function panel()
    radius = L.ui.slider('radius', radius, 20, 100)
end
]],
})


local selectedMod = nil

function castle.uiupdate()
    -- Dropdown box for selecting a mod
    do
        local modNames = {}
        for _, mod in pairs(mods) do
            table.insert(modNames, mod.name)
        end
        table.sort(modNames, function(a, b)
            return a:upper() < b:upper()
        end)
        local selectedModName = L.ui.dropdown('Selected mod name', selectedMod and selectedMod.name, modNames, {
            hideLabel = true,
        })
        selectedMod = mods[selectedModName]
    end

    L.ui.markdown('----')

    -- Editor for selected mod
    if selectedMod then
        -- Name input
        local newName = L.ui.textInput('name', selectedMod.name)
        if newName ~= selectedMod.name and mods[newName] == nil then
            mods[selectedMod.name] = nil
            selectedMod.name = newName
            mods[newName] = selectedMod
        end

        selectedMod:codeEditor('code')

        selectedMod:safeCall('panel')
    end
end


function love.draw()
    L.stacked('all', function()
        if mods['main'] then
            mods['main']:safeCall('draw')
        end
    end)

    L.print('fps: ' .. L.getFPS(), 20, 20)
end
