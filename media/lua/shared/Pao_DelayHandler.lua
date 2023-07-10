-- Since I often need this and I don't wanna use luatimers, let's get this done
--- TODO This can not run multiple instances

---@class DelayHandler
---@field eTime number Delay
---@field funcToRun function Function to be run after a delay
DelayHandler = {}
local os_time = os.time

---...
---@param funcToRun function
---@param delay number
function DelayHandler.RunAfterDelay(funcToRun, delay)
    DelayHandler.eTime = os_time() + delay
    DelayHandler.funcToRun = funcToRun

    Events.OnTick.Add(DelayHandler.Loop)
end

---Function which runs the loop for the delay
---@private
function DelayHandler.Loop()
    local cTime = os_time()
    if cTime > DelayHandler.eTime then
        DelayHandler.funcToRun()
        Events.OnTick.Remove(DelayHandler.Loop)
    end
end