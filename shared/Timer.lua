local events = {}
local GetTime = Timer.GetMilliseconds

function Timer.Clear(timer)
    events[timer] = nil
end

function Timer.SetImmediate(callback)
    local timer = Timer()
    events[timer] = {1, callback}
    return timer
end

function Timer.SetTimeout(delay, callback)
    local timer = Timer()
    events[timer] = {2, callback, delay}
    return timer
end

function Timer.SetInterval(delay, callback)
    local timer = Timer()
    events[timer] = {3, callback, delay}
    return timer
end

function Timer.Sleep(delay)
    local coro = coroutine.running()
    Timer.SetTimeout(delay, function(args)
        coroutine.resume(coro, args)
    end)
    local args = coroutine.yield()
    return args
end

function Timer.Tick()
    for timer, event in pairs(events) do
        local delta = GetTime(timer)
        if event[1] == 1 then
            event[2]({delta = delta})
            timer:Clear()
        elseif event[1] == 2 then
            if delta >= event[3] then
                event[2]({delta = delta})
                timer:Clear()
            end
        elseif event[1] == 3 then
            if delta >= event[3] then
                event[2]({delta = delta})
                timer:Restart()
            end
        end
    end
end

Events:Subscribe("PreTick", Timer.Tick)
