-- // Made by Kaori6~ (@hikari_kuroi)
local cloneref = (cloneref or clonereference or function(instance: any)
    return instance
end)

local RunService: RunService = cloneref(game:GetService("RunService"));
local LoopModule = {ActiveConnections = {}, KeyBinds = {},
    Storage = {},
}

local LoopManager = {Unloaded = false};
local Env = (getgenv and getgenv()) or shared or _G
local Notify = Env.Debug and function(...) warn("[Kaori6]:", ...) end or function() end

-- // Skidded by Obsidian's Lib
local SafeCall = function(Src,...)
    if not (Src and typeof(Src) == "function") then
        return
    end

    local Result = table.pack(xpcall(Src, function(Error)
        task.defer(error, debug.traceback(Error, 2))
        Notify("Callback error at:", Error);
        return Error
    end, ...))

    if not Result[1] then
        return nil
    end

    return table.unpack(Result, 2, Result.n);
end

function LoopModule.WhileLoop(waitBoy, LoopManager, Call, Name)
    if Name then
        LoopModule.Storage[Name] = function()
            while true do
                if not LoopManager.Unloaded then
                    SafeCall(Call)
                end
                task.wait(waitBoy or 0.35);
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
            if LoopManager.Unloaded then return end;
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
            if LoopManager.Unloaded then return end;
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
            if LoopManager.Unloaded then return end;
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
            if LoopManager.Unloaded then return end;
            SafeCall(Call, dt)
        end
    end

    local Connection = RunService.Heartbeat:Connect(LoopModule.Storage[Name]);

    if Name then
        LoopModule.ActiveConnections[Name] = {Type = "RBXScriptConnection", Connection = Connection, Service = "Heartbeat"}
    end

    return Connection
end

function LoopModule.BindKey(Name, Key, Mode, Call, Released, waitBoy)
    Mode = Mode or "Began"
    Delay = waitBoy or 0.1

    if not Name or not Key or not Call then
        Notify("Incorrect Keybind arguments.")
        return
    end

    LoopModule.UnbindKey(Name)

    if Mode == "Hold" then
        local Holding, Stopping = false,false;

        local StartHolding = function() 
            Stopping = false
            task.spawn(function()
                while not Stopping do
                    if LoopManager.Unloaded then return end SafeCall(Call) task.wait(Delay);
                end
            end)
        end

        local Beginning = UserInputService.InputBegan:Connect(function(Input, __)
            if not __ and Input.KeyCode == Key and not Holding then Holding = true;
                StartHolding()
            end
        end)

        local Ending = UserInputService.InputEnded:Connect(function(Input, __)
            if not __ and Input.KeyCode == Key then local Holding, Stopping = false, false;
                if Released then
                    SafeCall(Released)
                end
            end
        end)

        LoopModule.KeyBinds[Name] = {Connection = {Beginning, Ending}, Mode = "Hold", Key = Key}
    elseif Mode == "Began" or Mode == "Ended" then
        local Signal = (Mode == "Began") and UserInputService.InputBegan or UserInputService.InputEnded

        local Connection = Signal:Connect(function(Input, __)
            if not __ and Input.KeyCode == Key and not LoopManager.Unloaded then
                SafeCall(Call)
            end
        end)

        LoopModule.KeyBinds[Name] = {Connection = Connection, Mode = Mode, Key = Key}
    else
        Notify("Invalid Mode '"..tostring(Mode).."' in Keybinds.")
    end
end

function LoopModule.RebindKey(Name, ReBind)
    local Keybinds = LoopModule.KeyBinds[Name]
    if not Keybinds then
        Notify("Keybind '"..Name.."' is not defined or got deleted.")
        return
    end

    LoopModule.BindKey(Name, ReBind, Keybinds.Mode, Keybinds.Call, Keybinds.Released, Keybinds.Delay or 0.1;)
end

function LoopModule.UnbindKey(Name)
    local Keybinds = LoopModule.KeyBinds[Name]
    if Keybinds then
        if typeof(Keybinds.Connection) == "table" then
            for _, Connections in pairs(Keybinds.Connection) do
                if Connections.Disconnect then Connections:Disconnect() end
            end
        elseif Keybinds.Connection and Keybinds.Connection.Disconnect then
            Keybinds.Connection:Disconnect();
        end
        LoopModule.KeyBinds[Name] = nil
    end
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

    for Fbind in pairs(LoopModule.KeyBinds) do
        self.UnbindKey(Fbind);
    end

    table.clear(LoopModule.Storage) table.clear(LoopModule.Keybinds);
    table.clear(LoopModule.ActiveConnections);

    Env.LoopModule, Env.LoopManager = nil, nil
    -- // Notify("Bye bye:) *Windows Shutdown Sound*");
end

function LoopModule:Toggle(LoopManager, bool)
    if typeof(bool) == "boolean" and LoopManager then
        LoopManager.Unloaded = bool;
    end
end


Env.LoopModule = LoopModule;
Env.LoopManager = LoopManager;

return LoopModule,LoopManager
