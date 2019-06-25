local Mod = {}


local nextId = 1

local function generateId()
    local id = nextId
    nextId = nextId + 1
    return id
end

local allByName = {}
local allById = {}


function Mod:new()
    self = self or {}
    setmetatable(self, { __index = Mod })

    self.id = generateId()
    allById[self.id] = self

    self.name = self.name or 'mod' .. self.id
    allByName[self.name] = self

    self.code = self.code or ''
    self:compile()

    return self
end


function Mod:compile()
    self._lastCodeChangeTime = nil
    self._errored = false

    local env = setmetatable({
        restored = self._env or {},
    }, { __index = _G })
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
    local newCode = L.ui.codeEditor(label, self.code, props)
    if newCode ~= self.code then
        self.code = newCode
        self._lastCodeChangeTime = L.getTime()
    end

    if self._lastCodeChangeTime ~= nil and L.getTime() - self._lastCodeChangeTime >= 0.4 then
        self:compile()
    end
end


return Mod