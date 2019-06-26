local Mod = {}


local nextId = 1

local function generateId()
    local id = nextId
    nextId = nextId + 1
    return id
end


local allById = {}
local allByName = {}


function Mod.byId(id)
    return allById[id]
end

function Mod.allById()
    return allById
end

function Mod.byName(name)
    return allByName[name]
end

function Mod.allByName()
    return allByName
end


function Mod:new()
    self = self or {}
    setmetatable(self, { __index = Mod })

    self.id = generateId()
    allById[self.id] = self

    self:rename(self.name or 'mod' .. self.id)

    self.envBase = self.envBase or {}

    self.code = self.code or ''
    self:compile()

    return self
end

function Mod:rename(newName)
    assert(not allByName[newName], "mod with name '" .. newName .. "' already exists")
    allByName[self.name] = nil
    self.name = newName
    allByName[self.name] = self
end

function Mod:delete()
    allById[self.id] = nil
    allByName[self.name] = nil
    self._proxyMeta.__index = function()
        error("use of deleted mod '" .. self.name .. "'")
    end
end


local function modRequire(name)
    return assert(allByName[name], "no module named '" .. name .. "'").proxy
end

function Mod:compile()
    self._editCode = self.code
    self._editCodeTime = nil
    self._errored = false

    local env = setmetatable({
        require = modRequire,
        restored = self._env or {},
    }, { __index = _G })
    for k, v in pairs(self.envBase) do
        env[k] = v
    end
    local compiled, err = load(self.code, self.name, 't', env)
    if not compiled then
        self:error(err)
    end
    self:safeCall(compiled)
 
    self._env = env
    if not self.proxy then
        self._proxyMeta = {}
        self.proxy = setmetatable({}, self._proxyMeta)
    end
    self._proxyMeta.__index = env
end

function Mod:error(err)
    self._errored = true
    error(err, 0)
end


function Mod:safeCall(nameOrFunc, ...)
    if self._errored then
        return
    end

    local func
    if type(nameOrFunc) == 'string' then
        func = self._env[nameOrFunc]
    else
        func = nameOrFunc
    end

    if func then
        local succeeded, err = pcall(func, ...)
        if not succeeded then
            self:error(err)
        end
    end
end


function Mod:codeEditor(label, props)
    local newCode = L.ui.codeEditor(label, self._editCode, props)
    if newCode ~= self._editCode then
        self._editCode = newCode
        self._editCodeTime = L.getTime()
    end

    if self._editCodeTime ~= nil and L.getTime() - self._editCodeTime >= 0.4 then
        self.code = self._editCode
        self:compile()
    end
end


return Mod