L = require('https://raw.githubusercontent.com/nikki93/L/3f63e72eef6b19a9bab9a937e17e527ae4e22230/L.lua')


local Mod = require 'mod'


local mods = {}


function refer(modName)
    local foundMod = mods[modName]
    if foundMod then
        return foundMod.env
    end
    return nil
end

function add(mod)
    mods[mod.name] = mod
end

function remove(mod)
    mods[mod.name] = nil
end


local selectedModName = nil

function castle.uiupdate()
    local selectedMod = mods[selectedModName]
    if not selectedMod then
        selectedModName = nil
    end

    -- Dropdown box for selecting a mod
    do
        local modNames = {}
        for _, mod in pairs(mods) do
            table.insert(modNames, mod.name)
        end
        table.sort(modNames, function(a, b)
            return a:upper() < b:upper()
        end)
        selectedModName = L.ui.dropdown('Selected mod name', selectedModName, modNames, {
            hideLabel = true,
        })
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
            selectedModName = newName
        end

        -- Code editor
        selectedMod:codeEditor('code')

        -- Panel
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


add(Mod.new({
    name = 'circle',
    code = [[
radius = restored.radius or 40

function draw()
    L.circle('fill', 200, 300, radius)
end

function panel()
    radius = L.ui.slider('radius', radius, 20, 100)
end
]],
}))

add(Mod.new({
    name = 'main',
    code = [[
circle = refer 'circle'

function draw()
    circle.draw()
end
]],
}))