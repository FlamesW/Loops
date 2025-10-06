# Loop Manager Example:
```lua
-- // Made by @hikari_kuroi (Discord)~
local LoopModule, LoopManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/FlamesW/Loops/home/Manager.lua"))();

--[[ RenderStep Example:
LoopModule.RenderStep(LoopManager,function(dt) -- // You can use dt to get the time.
    -- // Empty lol.
end,"MyRenderStepped") -- // Name to identify your loop in the Loop Manager (Optional but helps you to identify your loop).
--]]

-- // Active Loops (Runs by default).
LoopModule.WhileLoop(1,LoopManager,function() -- // 1 Second loop.
    print("[FLoop Manager]: Loop 1");
end,"Loop1Second")

LoopModule.WhileLoop(2,LoopManager,function() -- // 2 Second loop.
    print("[FLoop Manager]: Loop 2");
end,"Loop2Second")

task.wait(3);

-- // Will try to restart Loop2Second (Even though it already runs).
print("[FLoop Manager]: Attempted to restart. (Loop2Second)");
LoopModule:ForceStart("Loop2Second"); -- // Will return you with a warn in F9 Console that its already running.

task.wait(3);

-- // Will stop Loop2Second.
print("[FLoop Manager]: Attempted to stop. (Loop2Second)");
LoopModule:ForceStop("Loop2Second",false); -- // Stops certain loop but keeps it in the active connections.

task.wait(3);

-- // Will start Loop2Second.
print("[FLoop Manager]: Attempted to restart. (Loop2Second)");
LoopModule:ForceStart("Loop2Second"); -- // Starts certain loop again (Only if you didnt delete it from storage).

task.wait(3);

-- // Will stop and delete Loop1Second.
print("[FLoop Manager]: Attempted to stop and delete. (Loop1Second)");
LoopModule:ForceStop("Loop1Second",true);  -- // Stops certain loop and deletes it from the active connections.

task.wait(3);

-- // Will try to restart Loop1Second (Even though it got deleted).
print("[FLoop Manager]: Attempted to restart. (Loop1Second)");
LoopModule:ForceStart("Loop1Second"); -- // Will return you with a warn in F9 Console (You cant restart loops that were deleted).

task.wait(3);

-- // Kills everything.
LoopModule:Kill(LoopManager); -- // Recalling it will return in error, It completely removes everything (Use it on Ui Library's unloaded functions).
```

---------------------------------------------------------------------------------------------------------------------------------------------------------------

# How you would control it:
```lua
-- // Made by @hikari_kuroi (Discord)~
shared.Settings = {
    ["AimbotChecks"] = {
        WallCheck = (true), -- // Defaults to true~
    },
};

local LoopModule, LoopManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/FlamesW/Loops/home/Manager.lua"))();

-- // Obsidian Lib UI
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/Library.lua"))();

local Window = Library:CreateWindow({
	Title = "Floops (Example)",
	Footer = "Internal Version e.127.exe | By @hikari_kuroi",
	Icon = 72133521375266,
	NotifySide = "Right",
	ShowCustomCursor = false,
})

local Tabs = {
    Main = Window:AddTab("Aimbot","sticker"),
}

local AimbotOptionsGroup = Tabs.Main:AddLeftGroupbox("Aimbot Options","file-code-2");

-- // Obsidian Lib Components.
LoopModule.WhileLoop(1,LoopManager,function()
    if shared.Settings.AimbotChecks.WallCheck then
        print("Wall Checking.");
    end
end,"AimbotWallCheckToggle")

AimbotOptionsGroup:AddToggle("AimbotWallCheckToggle",{
    Text = "Wall Check",
    Default = shared.Settings.AimbotChecks.WallCheck,
    Tooltip = "Will not target people behind a wall",
    Callback = function(Value)
        shared.Settings.AimbotChecks.WallCheck = Value;
    end
})
```

# Docs: 

- Set up
```lua
Env.LoopModule, Env.LoopManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/FlamesW/Loops/home/Manager.lua"))();
Env.Debug = true -- // Debug Mode.
```

- While Loop
```lua
LoopModule.WhileLoop(1,LoopManager,function()
    print("Hi:)");
end,"FLoop")
```

- Render Stepped/ HeartBeat /Stepped
```lua
LoopModule.RenderStep(LoopManager,function(dt)
    print("Render:", dt);
end,"RenderStepLoop")
```

```lua
LoopModule.HeartBeat(LoopManager,function(dt)
    print("Render:", dt);
end,"HeartBeatLoop")
```

```lua
LoopModule.Stepped(LoopManager,function(dt)
    print("Render:", dt);
end,"SteppedLoop")
```

- Bind Render (BindToRenderStep)
```lua
LoopModule.BindRender(LoopManager,function(dt)
    print("Render:", dt);
end,"PriorityRender",Enum.RenderPriority.Camera.Value)
```
* Default: end,"PriorityRender") --> Enum.RenderPriority.Last.Value


# Misc:

- While Loop RenderStepped / HeartBeat / Stepped / BindToRenderStep

- Stop Floops
```lua
-- // Stops but keeps the loop.
LoopModule:ForceStop("MyFLoop",false);

-- // Stops and deletes the loop from memory.
LoopModule:ForceStop("MyFLoop",true);
```

- Start Floops (Recovers Loops)
```lua
LoopModule:ForceStart("MyFLoop");
```

## Behold, Za WAURODOOO!!

```lua
 -- // Stops everything
LoopModule:Toggle(LoopManager,true);

 -- // Time has begun to move again.
LoopModule:Toggle(LoopManager,false);
```

## Kills Everything (KYS)
```lua
LoopModule:Kill(LoopManager); -- // Bye:)~ <3
```
