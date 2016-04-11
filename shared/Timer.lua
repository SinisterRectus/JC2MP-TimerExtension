local events = {}
local Events = Events

function Timer.Clear(timer)
    if not events[timer] then return end
    Events:Unsubscribe(events[timer])
    events[timer] = nil
end

function Timer.SetImmediate(callback, ...)
    local args = {...}
    local timer = Timer()
    local event = Events:Subscribe("PreTick", function()
        Timer.Clear(timer)
        callback(table.unpack(args))
    end)
    events[timer] = event
    return timer
end

function Timer.SetTimeout(delay, callback, ...)
    local args = {...}
    local timer = Timer()
    local event = Events:Subscribe("PreTick", function()
        if timer:GetMilliseconds() < delay then return end
        Timer.Clear(timer)
        callback(table.unpack(args))
    end)
    events[timer] = event
    return timer
end

function Timer.SetInterval(delay, callback, ...)
    local args = {...}
    local timer = Timer()
    local event = Events:Subscribe("PreTick", function()
        if timer:GetMilliseconds() < delay then return end
        timer:Restart()
        callback(table.unpack(args))
    end)
    events[timer] = event
    return timer
end
