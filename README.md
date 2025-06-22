# Loop Manager Example:
```lua
-- // Made by @Flames9925 (Discord)~
local LoopModule,LoopManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/FlamesW/Loops/home/Manager.lua"))();

--[[ RenderStep Example:
LoopModule.RenderStep(LoopManager,function(dt) -- // You can use dt to get the time.
    -- // Empty lol.
end,"MyRenderStepped") -- // Name to identify your loop in the Loop Manager (Optional but helps you to identify your loop).
--]]

-- // Active Loops (Runs by default).
LoopModule.WhileLoop(1,LoopManager,function() -- // 1 Second loop.
    print("[Loop Manager]: Loop 1");
end,"Loop1Second")

LoopModule.WhileLoop(2,LoopManager,function() -- // 2 Second loop.
    print("[Loop Manager]: Loop 2");
end,"Loop2Second")

task.wait(3);

-- // Will try to restart Loop2Second (Even though it already runs).
print("[Loop Manager]: Attempted to restart. (Loop2Second)");
LoopModule:ForceStart("Loop2Second"); -- // Will return you with a warn in F9 Console that its already running.

task.wait(3);

-- // Will stop Loop2Second.
print("[Loop Manager]: Attempted to stop. (Loop2Second)");
LoopModule:ForceStop("Loop2Second",false); -- // Stops certain loop but keeps it in the active connections.

task.wait(3);

-- // Will start Loop2Second.
print("[Loop Manager]: Attempted to restart. (Loop2Second)");
LoopModule:ForceStart("Loop2Second"); -- // Starts certain loop again (Only if you didnt delete it from storage).

task.wait(3);

-- // Will stop and delete Loop1Second.
print("[Loop Manager]: Attempted to stop and delete. (Loop1Second)");
LoopModule:ForceStop("Loop1Second",true);  -- // Stops certain loop and deletes it from the active connections.

task.wait(3);

-- // Will try to restart Loop1Second (Even though it got deleted).
print("[Loop Manager]: Attempted to restart. (Loop1Second)");
LoopModule:ForceStart("Loop1Second"); -- // Will return you with a warn in F9 Console (You cant restart loops that were deleted).

task.wait(3);

-- // Kills everything.
LoopModule:Kill(LoopManager); -- // Recalling it will return in error, It completely removes everything (Use it on Ui Library's unloaded functions).
```
