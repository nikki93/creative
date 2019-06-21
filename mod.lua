local Mod = {}


local nextId = 1


function Mod:new()
    self = self or {}
    setmetatable(self, { __index = Mod })

    self.id = nextId
    nextId = nextId + 1

    self.name = self.name or 'mod' .. self.id
    self.code = self.code or ''

    self.lastCodeChangeTime = nil
    self.errored = false

    self.E = {}

    self:compile()

    return self
end


function Mod:compile()
    self.lastCodeChangeTime = nil
    self.errored = false

    local env = setmetatable({ E = self.E }, { __index = _G })
    local compiled, err = load(self.code, 'code', 't', env)

    if compiled then
        self:safeCall(compiled)
    else
        self:error(err)
    end
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
        func = self.E[nameOrFunc]
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


function Mod:ui(props)
    props = props or {}

    L.ui.section(self.name, { defaultOpen = props.defaultOpen }, function()
        self.code = L.ui.codeEditor('code', self.code, {
            hideLabel = true,
            onChange = function()
                self.lastCodeChangeTime = L.getTime()
            end,
        })

        self:safeCall('ui')
    end)

    if self.lastCodeChangeTime ~= nil and L.getTime() - self.lastCodeChangeTime >= 0.4 then
        self:compile()
    end
end


return Mod