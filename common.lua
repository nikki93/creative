cs = require 'https://raw.githubusercontent.com/castle-games/share.lua/09125a4c0ba5c0cbb61f51f518e64813ae773b3a/cs.lua'
state = require 'https://raw.githubusercontent.com/castle-games/share.lua/09125a4c0ba5c0cbb61f51f518e64813ae773b3a/state.lua'
L = require('https://raw.githubusercontent.com/nikki93/L/3f63e72eef6b19a9bab9a937e17e527ae4e22230/L.lua')

cjson = require 'cjson'

Mod = require 'mod'


-- Apply a diff from `:__diff` or `:__flush` to a target `t` that is itself a `state`
function customApply(t, diff)
    if diff == nil then return t end
    if diff.__exact then
        diff.__exact = nil
        return diff
    end
    t = (type(t) == 'table' or type(t) == 'userdata') and t or {}
    for k, v in pairs(diff) do
        if type(v) == 'table' then
            local r = customApply(t[k], v)
            if r ~= t[k] then
                t[k] = r
            end
        elseif v == DIFF_NIL then
            t[k] = nil
        else
            t[k] = v
        end
    end
    return t
end