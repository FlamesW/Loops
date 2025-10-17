-- // Made by Kaori6~ (@hikari_kuroi)
local cloneref = (cloneref or clonereference or function(instance: any)
    return instance
end)

-- // Services
local RunService: RunService = cloneref(game:GetService("RunService"));
local LoopModule = {ActiveConnections = {},
    Storage = {},
}

-- // Settings
local LoopManager = {Unloaded = false, Debug = true, Safecall = true}; 
local Notify = function(...) LoopManager.Debug and warn("[Loop Manager]:", ...) end

local SafeCall = function(Src, ...)
    if not (Src and typeof(Src) == "function") then
        return
    end
    if LoopManager.Safecall then
        local Result = table.pack(xpcall(Src, function(Error)
            task.defer(error, debug.traceback(Error, 2))
            Notify("Callback error at:", Error);
            return Error
        end, ...))

        if not Result[1] then
            return nil
        end

        return table.unpack(Result, 2, Result.n);
    else
        return Src(...)
    end
end

function LoopModule.WhileLoop(waitBoy, LoopManager, Call, Name, waitLol)
    if Name then
        LoopModule.Storage[Name] = function()
            while true do
                if waitLol and waitBoy then
                    task.wait(waitBoy);
                end

                if not LoopManager.Unloaded then
                    SafeCall(Call);
                end

                if not waitLol and waitBoy then
                    task.wait(waitBoy);
                end
            end
        end
    end

    local thread = task.spawn(LoopModule.Storage[Name]);

    if Name then
        LoopModule.ActiveConnections[Name] = {Type = "thread", Thread = thread}
    end

    return thread
end

function LoopModule.RenderStep(LoopManager, Call, Name)
    if Name then
        LoopModule.Storage[Name] = function(dt)
            if LoopManager.Unloaded then 
                return
            end
            SafeCall(Call, dt)
        end
    end

    local Connection = RunService.RenderStepped:Connect(LoopModule.Storage[Name]);

    if Name then
        LoopModule.ActiveConnections[Name] = {Type = "RBXScriptConnection", Connection = Connection, Service = "RenderStepped"}
    end

    return Connection
end

function LoopModule.BindRender(LoopManager, Call, Name, Priority)
    if Name then
        LoopModule.Storage[Name] = function(dt)
            if LoopManager.Unloaded then 
                return
            end
            SafeCall(Call, dt)
        end
    end

    RunService:BindToRenderStep(Name, Priority or Enum.RenderPriority.Last.Value, LoopModule.Storage[Name]);

    if Name then
        LoopModule.ActiveConnections[Name] = {Type = "BindToRenderStep", Name = Name}
    end

    return LoopModule.ActiveConnections[Name]
end

function LoopModule.Stepped(LoopManager, Call, Name)
    if Name then
        LoopModule.Storage[Name] = function(t, dt)
            if LoopManager.Unloaded then 
                return
            end
            SafeCall(Call, t, dt)
        end
    end

    local Connection = RunService.Stepped:Connect(LoopModule.Storage[Name])

    if Name then
        LoopModule.ActiveConnections[Name] = {Type = "RBXScriptConnection", Connection = Connection, Service = "Stepped"}
    end

    return Connection
end

function LoopModule.Heartbeat(LoopManager, Call, Name)
    if Name then
        LoopModule.Storage[Name] = function(dt)
            if LoopManager.Unloaded then 
                return
            end
            SafeCall(Call, dt)
        end
    end

    local Connection = RunService.Heartbeat:Connect(LoopModule.Storage[Name]);

    if Name then
        LoopModule.ActiveConnections[Name] = {Type = "RBXScriptConnection", Connection = Connection, Service = "Heartbeat"}
    end

    return Connection
end

function LoopModule:ForceStop(Name, Del)
    local Floop = LoopModule.ActiveConnections[Name]
    if Floop then
        if Floop.Type == "RBXScriptConnection" and Floop.Connection then
            Floop.Connection:Disconnect();
        elseif Floop.Type == "thread" and coroutine.status(Floop.Thread) ~= "dead" then
            -- // Dinga la ginga ding ding dong~
        elseif Floop.Type == "BindToRenderStep" then
            RunService:UnbindFromRenderStep(Floop.Name);
        end

        if Del then
            LoopModule.ActiveConnections[Name] = nil
            LoopModule.Storage[Name] = nil
        end
    end
end

function LoopModule:ForceStart(Name)
    local FLoop = LoopModule.ActiveConnections[Name]

    if not FLoop then
        Notify("'" .. Name .. "' is not defined or got deleted.")
        return nil
    end

    if FLoop.Type == "thread" and coroutine.status(FLoop.Thread) == "dead" then
        local Restart = LoopModule.Storage[Name]
        if Restart then
            LoopModule.ActiveConnections[Name] = {Type = "thread", Thread = task.spawn(Restart)}
            return LoopModule.ActiveConnections[Name].Thread;
        else
            Notify("Failed to restart "..'"'..Name..'"');
            return nil
        end
    elseif FLoop.Type == "RBXScriptConnection" and not FLoop.Connection.Connected then
        local Restart = LoopModule.Storage[Name]
        if Restart then
            local Type
            if FLoop.Service == "RenderStepped" then
                Type = RunService.RenderStepped:Connect(Restart);
            elseif FLoop.Service == "Heartbeat" then
                Type = RunService.Heartbeat:Connect(Restart);
            elseif FLoop.Service == "Stepped" then
                Type = RunService.Stepped:Connect(Restart);
            else
                return nil
            end

            LoopModule.ActiveConnections[Name] = {Type = "RBXScriptConnection", Connection = Type, Service = FLoop.Service}
            return Type
        else
            Notify("Failed to restart "..'"'..Name..'"')
            return nil
        end
    elseif FLoop.Type == "BindToRenderStep" then
        local Restart = LoopModule.Storage[Name]
        if Restart then
            RunService:BindToRenderStep(FLoop.Name, Enum.RenderPriority.Last.Value, Restart);
            return LoopModule.ActiveConnections[Name]
        else
            Notify("Failed to restart "..'"'..Name..'"')
            return nil
        end
    else
        Notify("'"..Name.."' is already running in the background.")
        return FLoop
    end
end

function LoopModule:Kill(LoopManager)
    if LoopManager then LoopManager.Unloaded = true end

    for Floop in pairs(LoopModule.ActiveConnections) do
        self:ForceStop(Floop, true);
    end

    table.clear(LoopModule.Storage);
    table.clear(LoopModule.ActiveConnections);
end

function LoopModule:Toggle(LoopManager, bool)
    if typeof(bool) == "boolean" and LoopManager then
        LoopManager.Unloaded = bool;
    end
end

return LoopModule, LoopManager
