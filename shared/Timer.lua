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

local modifier = 0
if GetTime == Timer.GetMicroseconds then
    modifier = 1000000
elseif GetTime == Timer.GetMilliseconds then
    modifier = 1000
elseif GetTime == Timer.GetSeconds then
    modifier = 1
elseif GetTime == Timer.GetMinutes then
    modifier = 1/60
elseif GetTime == Timer.GetHours then
    modifier = 1/3600
end

function Timer.Tick(args)
    for timer, event in pairs(events) do
        local delta = GetTime(timer)
        local corrected = delta + (args.delta * modifier)
        if event[1] == 1 then
            event[2]({delta = delta})
            timer:Clear()
        elseif event[1] == 2 then
            if corrected >= event[3] then
                event[2]({delta = delta})
                timer:Clear()
            end
        elseif event[1] == 3 then
            if corrected >= event[3] then
                event[2]({delta = delta})
                timer:Restart()
            end
        end
    end
end

Events:Subscribe("PreTick", Timer.Tick)
