local Mod = {}


local nextId = 1


function Mod:new()
    self = self or {}
    setmetatable(self, { __index = Mod })

    self.id = nextId
    nextId = nextId + 1

    self.name = self.name or 'mod' .. self.id
    self.code = self.code or ''

    self:compile()

    return self
end


function Mod:compile()
    self.lastCodeChangeTime = nil
    self.errored = false

    local env = setmetatable({
        restored = self.env or {},
    }, { __index = _G })
    local compiled, err = load(self.code, self.name, 't', env)
    if not compiled then
        self:error(err)
    end
    self:safeCall(compiled)
 
    self.env = env
    if not self.proxy then
        self.proxyMeta = {}
        self.proxy = setmetatable({}, self.proxyMeta)
    end
    self.proxyMeta.__index = env
end

function Mod:error(err)
    self.errored = true
    error(err, 0)
end


function Mod:safeCall(nameOrFunc, ...)
    if self.errored then
        return
    end

    local func
    if type(nameOrFunc) == 'string' then
        func = self.env[nameOrFunc]
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
        self.lastCodeChangeTime = L.getTime()
    end

    if self.lastCodeChangeTime ~= nil and L.getTime() - self.lastCodeChangeTime >= 0.4 then
        self:compile()
    end
end


return Mod