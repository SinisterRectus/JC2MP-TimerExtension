local events = {}

function Timer.Clear(timer)
    events[timer] = nil
end

function Timer.SetImmediate(callback, ...)
    local timer = Timer()
    events[timer] = {1, callback, {...}}
    return timer
end

function Timer.SetTimeout(delay, callback, ...)
    local timer = Timer()
    events[timer] = {2, callback, {...}, delay}
    return timer
end

function Timer.SetInterval(delay, callback, ...)
    local timer = Timer()
    events[timer] = {3, callback, {...}, delay}
    return timer
end

function Timer.Tick()
    for timer, event in pairs(events) do
        if event[1] == 1 then
            event[2](table.unpack(event[3]))
            timer:Clear()
        elseif event[1] == 2 then
            if timer:GetMilliseconds() > event[4] then
                event[2](table.unpack(event[3]))
                timer:Clear()
            end
        elseif event[1] == 3 then
            if timer:GetMilliseconds() > event[4] then
                event[2](table.unpack(event[3]))
                timer:Restart()
            end
        end
    end
end

Events:Subscribe("PreTick", Timer.Tick)
