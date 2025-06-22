-- // Made by @flames9925 (Discord)~
local cloneref = cloneref or function(o) return o end;
local RunService = cloneref(game:GetService("RunService"));
local LoopModule = {ActiveConnections = {},
    Storage = {},
}

local LoopManager = {Unloaded = false};

function LoopModule.WhileLoop(waitPls, LoopManager, Call, Name)
    if Name then
        LoopModule.Storage[Name] = function()
            while true do task.wait(waitPls or 0.35);
                if not LoopManager.Unloaded and Call then
                    Call();
                end
            end
        end
    end

    local thread = task.spawn(LoopModule.Storage[Name]);

    if Name then
        LoopModule.ActiveConnections[Name] = thread
    end

    return thread
end

function LoopModule.RenderStep(LoopManager, Call, Name)
    if Name then
        LoopModule.Storage[Name] = function(dt)
            if LoopManager.Unloaded then return end;
            if Call then Call(dt) end
        end
    end

    local Connection = RunService.RenderStepped:Connect(LoopModule.Storage[Name]);

    if Name then
        LoopModule.ActiveConnections[Name] = Connection
    end

    return Connection
end

function LoopModule:ForceStop(Name, Del)
    local Floop = LoopModule.ActiveConnections[Name]
    if Floop then
        if typeof(Floop) == "RBXScriptConnection" then
            Floop:Disconnect();
        elseif typeof(Floop) == "thread" and coroutine.status(Floop) ~= "dead" then
            coroutine.close(Floop);
        end

        if Del then
            LoopModule.ActiveConnections[Name] = nil
        end
    end
end

function LoopModule:ForceStart(Name)
    local FLoop = LoopModule.ActiveConnections[Name]

    if not FLoop then
        warn("[Loop Manager]: '"..Name.."' is not defined or got deleted.");
        return nil
    end

    if typeof(FLoop) == "thread" and coroutine.status(FLoop) == "dead" then
        local Restart = LoopModule.Storage[Name]
        if Restart then
            LoopModule.ActiveConnections[Name] = task.spawn(Restart)
            return LoopModule.ActiveConnections[Name];
        else
            warn("[Loop Manager]: Failed to restart "..'"..Name.."');
            return nil
        end
    elseif typeof(FLoop) == "RBXScriptConnection" and not FLoop.Connected then
        local Restart = LoopModule.Storage[Name]
        if Restart then
            LoopModule.ActiveConnections[Name] = RunService.RenderStepped:Connect(Restart)
            return LoopModule.ActiveConnections[Name];
        else
            warn("[Loop Manager]: Failed to restart "..'"..Name.."');
            return nil
        end
    else
        warn("[Loop Manager]: '"..Name.."' is already running in the background.");
        return FLoop
    end
end

function LoopModule:Kill(LoopManager)
    if LoopManager then LoopManager.Unloaded = true end

    for floop, cons in pairs(LoopModule.ActiveConnections) do
        if typeof(cons) == "RBXScriptConnection" then
            cons:Disconnect();
        elseif typeof(cons) == "thread" and coroutine.status(cons) ~= "dead" then
            coroutine.close(cons);
        end
        LoopModule.ActiveConnections[floop] = nil
    end

    for memory in pairs(LoopModule) do
        LoopModule[memory] = nil;
    end

    getgenv().LoopModule, getgenv().LoopManager = nil, nil
    warn("[Loop Manager]: Bye bye:) *Windows Shutdown Sound*");
end

function LoopModule:Toggle(LoopManager, bool)
    if typeof(bool) == "boolean" and LoopManager then
        LoopManager.Unloaded = bool;
    end
end

getgenv().LoopModule = LoopModule;
getgenv().LoopManager = LoopManager;

return LoopModule,LoopManager;
