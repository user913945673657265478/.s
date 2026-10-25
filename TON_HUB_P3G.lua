--[[
	TON HUB  ×  P3G (Touchline)
	- UI nueva: tabs a la izquierda, marco doble profesional, fondo animado TON 618
	- Lógica del script original intacta (reach, react, GK, helpers, FFlags, etc.)
	- Ctrl DERECHO abre/cierra · "-" oculta · "X" detiene todo y destruye
]]

Players = game:GetService("Players")
LocalPlayer = Players.LocalPlayer
RunService = game:GetService("RunService")
TweenService = game:GetService("TweenService")
UserInputService = game:GetService("UserInputService")
Workspace = game:GetService("Workspace")
ReplicatedStorage = game:GetService("ReplicatedStorage")
CoreGui = game:GetService("CoreGui")
Lighting = game:GetService("Lighting")
HttpService = game:GetService("HttpService")
MarketplaceService = game:GetService("MarketplaceService")
Stats = game:GetService("Stats")

RuntimeEnvironment = (getgenv and getgenv()) or _G
if RuntimeEnvironment.__P3G_HUB_CLEANUP then
    pcall(RuntimeEnvironment.__P3G_HUB_CLEANUP)
end

trackedConnections = {}
scriptAlive = true

function TrackConnection(connection)
    table.insert(trackedConnections, connection)
    return connection
end

function DisconnectTrackedConnections()
    for i = #trackedConnections, 1, -1 do
        local conn = trackedConnections[i]
        if conn then pcall(function() conn:Disconnect() end) end
        trackedConnections[i] = nil
    end
end

RED = Color3.fromRGB(255, 30, 30)
BLACK = Color3.fromRGB(0, 0, 0)

-- ============================================
--  VARIABLES
-- ============================================

m1_enabled = false
m1_size = 6.0
m1_transparency = 0.7
REACH_SIZE = 10
reachMethod2Enabled = false
reachTransparency2 = 1
proxyEnabled = false
ballProxies = {}
proxyOriginalSizes = {}
CharacterReachEnabled = false
CharacterReachSize = 12.0
CharacterVisualizerIntensity = 0.5
PlatformEnabled = false
PlatformSize = 15
Smoothness = 0.95
ShowPlatform = false
PlatformTransparency = 0.7
WalkSpeedValue = 26
WalkSpeedEnabled = false
DefaultWalkSpeed = 16
JumpPowerEnabled = false
JumpPowerValue = 50
DefaultJumpPower = 50
DIVE_RANGE = 40
DIVE_SPEED = 45
DIVE_LIFT = 28
COOLDOWN = 0.2
HIT_RADIUS = 6
gkAutoDiveEnabled = false
onCooldown = false
animPlaying = false
liveTrack = nil
touchCD = false
ANIM_HEADER = "rbxassetid://83669895507175"
ANIM_BACK = "rbxassetid://133843606757895"
ANIM_RIGHT = "rbxassetid://130737929982335"
ANIM_LEFT = "rbxassetid://97298506180835"
PRED_RANGE = 20
PRED_TOUCH = 6
PRED_GRAVITY = -98.1
PRED_TIME = 1.4
predOn = false
predObjs = {}
predConn = nil
cachedPingGlobal = 0.06
_reactActive = false
_reactThread = nil
_lastReactTT, _lastReactInterp = "13", "90"
_gkReactActive = false
_gkReactThread = nil
_lastGkReactTT, _lastGkReactInterp = "13", "90"
kickLoopEnabled = false
kickReach = 20
kickConnection = nil
dribbleEnabled = false
dribbleConn = nil
dribbleSpeed = 26
flyEnabled = false
flySpeed = 40
flyBV = nil
flyConn = nil
tpEnabled = false
tpSpeed = 3
tpConn = nil

ballParts = {}
ballVisualizers = {}
reachOriginalProperties = {}
platforms = {}
platformRunning = false
platformConnection = nil
characterReachPart = nil
characterReachWeld = nil
characterReachOutline = nil
walkSpeedConnection = nil
currentHumanoid = nil
changingWalkSpeed = false
isCharacterRespawning = false

-- ============================================
--  AVATAR STEALER (97mzu)
-- ============================================

function stopCharacterAnimations(humanoid)
    local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
    if not animator then return end
    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
        track:Stop()
    end
end

function cloneClassicAppearance(sourceModel, targetCharacter, targetHumanoid)
    if not sourceModel then return end
    for _, obj in pairs(targetCharacter:GetChildren()) do
        if obj:IsA("Accessory") or obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("BodyColors") or obj:IsA("CharacterMesh") then
            obj:Destroy()
        end
    end
    for _, obj in pairs(sourceModel:GetChildren()) do
        if obj:IsA("Accessory") then
            targetHumanoid:AddAccessory(obj:Clone())
        elseif obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("BodyColors") or obj:IsA("CharacterMesh") then
            obj:Clone().Parent = targetCharacter
        end
    end
    local targetHead = targetCharacter:FindFirstChild("Head")
    if targetHead then
        for _, child in pairs(targetHead:GetChildren()) do
            if child:IsA("Decal") and (child.Name == "face" or child.Name == "Face") then
                child:Destroy()
            end
        end
        local texture
        local sourceHead = sourceModel:FindFirstChild("Head")
        if sourceHead then
            for _, child in ipairs(sourceHead:GetDescendants()) do
                if child:IsA("Decal") and (child.Name == "face" or child.Name == "Face") then
                    texture = child.Texture
                    break
                end
            end
        end
        local face = Instance.new("Decal")
        face.Name = "face"
        face.Face = Enum.NormalId.Front
        face.Texture = texture or "rbxasset://textures/face.png"
        face.Parent = targetHead
    end
end

function applyAvatarFromUserId(userId, character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    stopCharacterAnimations(humanoid)
    local okAppearance, appearanceModel = pcall(function()
        return Players:GetCharacterAppearanceAsync(userId)
    end)
    local okDescription, description = pcall(function()
        return Players:GetHumanoidDescriptionFromUserId(userId)
    end)
    if okDescription and description then
        pcall(function() humanoid:ApplyDescription(description) end)
    end
    if okAppearance and appearanceModel then
        cloneClassicAppearance(appearanceModel, character, humanoid)
    end
    local parent = character.Parent
    character.Parent = nil
    character.Parent = parent
    if appearanceModel then appearanceModel:Destroy() end
end

function StealAvatarByName(username)
    if not username or username == "" then return end
    local success, userId = pcall(function()
        return Players:GetUserIdFromNameAsync(username)
    end)
    if success and userId and LocalPlayer.Character then
        applyAvatarFromUserId(userId, LocalPlayer.Character)
    end
end

-- ============================================
--  UTILITY FUNCTIONS
-- ============================================

function getFootballFolder()
    return workspace:FindFirstChild("Footballs")
end

function getClosestFootball()
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

function getKickRemote()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if remotes then
        local gameRemote = remotes:FindFirstChild("Game")
        if gameRemote then
            local touch = gameRemote:FindFirstChild("Touch")
            if touch then return touch:FindFirstChild("Kick") end
        end
    end
    return nil
end

function getAllBalls()
    local folder = getFootballFolder()
    if not folder then return {} end
    local balls = {}
    for _, obj in ipairs(folder:GetChildren()) do
        local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
        if part then table.insert(balls, part) end
    end
    return balls
end

function inBox()
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

function IsBallName(name)
    local lowered = string.lower(name or "")
    if lowered == "ball" or lowered == "football" or lowered == "soccerball" then return true end
    return string.find(lowered, "ball", 1, true) ~= nil
end

function IsReasonableBallPart(part)
    local size = part.Size
    local largest = math.max(size.X, size.Y, size.Z)
    local smallest = math.min(size.X, size.Y, size.Z)
    if smallest <= 0.02 or largest > 20 then return false end
    if largest / smallest > 6 then return false end
    return true
end

function RegisterBallPart(part)
    if part and part:IsA("BasePart") and part.Parent and IsReasonableBallPart(part) then
        if not ballParts[part] then ballParts[part] = true end
    end
end

function RegisterBallCandidate(instance)
    if not instance or not instance.Parent then return end
    if (instance:IsA("BasePart") or instance:IsA("Model")) and IsBallName(instance.Name) then
        local part = instance:IsA("BasePart") and instance or instance.PrimaryPart or instance:FindFirstChildWhichIsA("BasePart")
        if part then
            RegisterBallPart(part)
            if not proxyOriginalSizes[part] then proxyOriginalSizes[part] = part.Size end
        end
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
--  VISUALIZER
-- ============================================

function CreateVisualizerP3g(ball, size, transparency)
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
    visualizer.Color = RED
    visualizer.Shape = ball.Shape
    visualizer.Massless = true
    visualizer.Parent = workspace
    local outline = Instance.new("Highlight")
    outline.Name = "__BallVisualizerOutline"
    outline.Adornee = visualizer
    outline.FillTransparency = 1
    outline.OutlineColor = RED
    outline.OutlineTransparency = 0.2
    outline.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    outline.Parent = visualizer
    ballVisualizers[ball] = visualizer
    return visualizer
end

function RemoveVisualizerP3g(ball)
    if ballVisualizers[ball] then
        ballVisualizers[ball]:Destroy()
        ballVisualizers[ball] = nil
    end
end

function UpdateVisualizers(size, transparency)
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
--  BALL COLLISION PROXY
-- ============================================

proxySyncConnection = nil

function CreateCollisionProxy(ball)
    if ballProxies[ball] and ballProxies[ball].Parent then
        return ballProxies[ball]
    end
    local originalSize = proxyOriginalSizes[ball]
    if not originalSize then
        originalSize = ball.Size
        proxyOriginalSizes[ball] = originalSize
    end
    local proxy = Instance.new("Part")
    proxy.Name = "__CollisionProxy"
    proxy.Size = originalSize
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

function RemoveCollisionProxy(ball)
    if ballProxies[ball] then
        ballProxies[ball]:Destroy()
        ballProxies[ball] = nil
    end
end

function StartProxySystem()
    if proxySyncConnection then proxySyncConnection:Disconnect() end
    if not proxyEnabled then return end
    local folder = getFootballFolder()
    if folder then
        for _, ball in folder:GetChildren() do
            if ball:IsA("BasePart") then
                if not proxyOriginalSizes[ball] then proxyOriginalSizes[ball] = ball.Size end
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
                if not proxyOriginalSizes[ball] then proxyOriginalSizes[ball] = ball.Size end
                if not ballProxies[ball] or not ballProxies[ball].Parent then
                    CreateCollisionProxy(ball)
                else
                    ballProxies[ball].CFrame = ball.CFrame
                end
            end
        end
        for ball, proxy in pairs(ballProxies) do
            if not ball or not ball.Parent then RemoveCollisionProxy(ball) end
        end
    end)
end

function StopProxySystem()
    if proxySyncConnection then proxySyncConnection:Disconnect(); proxySyncConnection = nil end
    for ball, proxy in pairs(ballProxies) do RemoveCollisionProxy(ball) end
    table.clear(ballProxies)
end

-- ============================================
--  REACH METHOD 1
-- ============================================

m1_connection = nil
m1_visualizer_connection = nil
m1_grey_color = Color3.fromRGB(128, 128, 128)

function ApplyReachMethod1(ball)
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

function RestoreBallMethod1(ball)
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
    RemoveVisualizerP3g(ball)
end

function StartMethod1()
    if m1_connection then m1_connection:Disconnect(); m1_connection = nil end
    if m1_visualizer_connection then m1_visualizer_connection:Disconnect(); m1_visualizer_connection = nil end
    if not m1_enabled then return end
    for ball in pairs(ballParts) do
        if ball and ball.Parent then
            ApplyReachMethod1(ball)
            CreateVisualizerP3g(ball, m1_size, m1_transparency)
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
                    CreateVisualizerP3g(b, m1_size, m1_transparency)
                end
            end
        end
    end)
    m1_visualizer_connection = RunService.Heartbeat:Connect(function()
        if not m1_enabled then return end
        UpdateVisualizers(m1_size, m1_transparency)
    end)
end

function StopMethod1()
    if m1_connection then m1_connection:Disconnect(); m1_connection = nil end
    if m1_visualizer_connection then m1_visualizer_connection:Disconnect(); m1_visualizer_connection = nil end
    for ball in pairs(ballVisualizers) do RemoveVisualizerP3g(ball) end
    for ball, props in pairs(reachOriginalProperties) do
        if ball and ball.Parent then RestoreBallMethod1(ball) end
        reachOriginalProperties[ball] = nil
    end
end

-- ============================================
--  REACH METHOD 2
-- ============================================

method2_trackedParts = {}
method2_indicator = nil
method2_visualizer_connection = nil
originalColors = {}
originalSizes = {}

function SetupMethod2()
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
        RemoveVisualizerP3g(child)
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
            RemoveVisualizerP3g(part)
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
                    CreateVisualizerP3g(nearest, REACH_SIZE, reachTransparency2)
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

function StartMethod2()
    if reachMethod2Enabled then SetupMethod2() end
end

function StopMethod2()
    if getgenv().DisableReach then getgenv().DisableReach() end
    if method2_visualizer_connection then method2_visualizer_connection:Disconnect(); method2_visualizer_connection = nil end
    for ball in pairs(ballVisualizers) do RemoveVisualizerP3g(ball) end
end

-- ============================================
--  CHARACTER REACH
-- ============================================

function CharacterIntensityToTransparency(intensity)
    return math.clamp(0.95 - (math.clamp(intensity, 0.1, 1) * 0.65), 0.3, 0.9)
end

function CharacterIntensityToOutlineTransparency(intensity)
    return math.clamp(0.78 - (math.clamp(intensity, 0.1, 1) * 0.68), 0.1, 0.72)
end

function DestroyCharacterReach()
    if characterReachWeld then characterReachWeld:Destroy(); characterReachWeld = nil end
    if characterReachOutline then characterReachOutline:Destroy(); characterReachOutline = nil end
    if characterReachPart then characterReachPart:Destroy(); characterReachPart = nil end
end

function RefreshCharacterReach(character)
    if not CharacterReachEnabled then DestroyCharacterReach(); return end
    character = character or LocalPlayer.Character
    if not character or not character.Parent then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    if characterReachPart and characterReachPart.Parent ~= character then DestroyCharacterReach() end
    if not characterReachPart then
        local sphere = Instance.new("Part")
        sphere.Name = "P3gCharacterReach"
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
        sphere.Color = RED
        sphere.Transparency = CharacterIntensityToTransparency(CharacterVisualizerIntensity)
        sphere.Parent = character
        local outline = Instance.new("Highlight")
        outline.Name = "P3gCharacterReachOutline"
        outline.Adornee = sphere
        outline.FillTransparency = 1
        outline.OutlineColor = RED
        outline.OutlineTransparency = CharacterIntensityToOutlineTransparency(CharacterVisualizerIntensity)
        outline.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        outline.Parent = sphere
        local weld = Instance.new("WeldConstraint")
        weld.Name = "P3gCharacterReachWeld"
        weld.Part0 = root
        weld.Part1 = sphere
        weld.Parent = sphere
        characterReachPart = sphere
        characterReachOutline = outline
        characterReachWeld = weld
    end
    local targetSize = Vector3.new(CharacterReachSize, CharacterReachSize, CharacterReachSize)
    if characterReachPart.Size ~= targetSize then characterReachPart.Size = targetSize end
    characterReachPart.Color = RED
    local targetTransparency = CharacterIntensityToTransparency(CharacterVisualizerIntensity)
    if characterReachPart.Transparency ~= targetTransparency then characterReachPart.Transparency = targetTransparency end
    if characterReachOutline then
        characterReachOutline.OutlineColor = RED
        characterReachOutline.OutlineTransparency = CharacterIntensityToOutlineTransparency(CharacterVisualizerIntensity)
    end
end

function StartCharacterReachSystem()
    if not CharacterReachEnabled then return end
    local character = LocalPlayer.Character
    if character then RefreshCharacterReach(character) end
end

function StopCharacterReachSystem()
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
--  PLATFORM SYSTEM
-- ============================================

function createPlatform(ballPart)
    local existing = platforms[ballPart]
    if existing and existing.part and existing.part.Parent then return existing end
    local platform = Instance.new("Part")
    platform.Name = "P3gAirPlatform"
    platform.Size = Vector3.new(PlatformSize, 0.2, PlatformSize)
    platform.Position = ballPart.Position - Vector3.new(0, 2, 0)
    platform.Anchored = true
    platform.CanCollide = true
    platform.CanTouch = false
    platform.CanQuery = false
    platform.CastShadow = false
    platform.Color = RED
    platform.Material = Enum.Material.SmoothPlastic
    platform.Transparency = ShowPlatform and PlatformTransparency or 1
    platform.Parent = workspace
    local data = { part = platform, lastPosition = platform.Position, lastCanCollide = true }
    platforms[ballPart] = data
    return data
end

function removePlatform(ballPart)
    local data = platforms[ballPart]
    if data and data.part then data.part:Destroy() end
    platforms[ballPart] = nil
end

function ClearAllPlatforms()
    for ballPart, data in pairs(platforms) do
        if data and data.part then data.part:Destroy() end
        platforms[ballPart] = nil
    end
end

function UpdatePlatformSize()
    local targetSize = Vector3.new(PlatformSize, 0.2, PlatformSize)
    for _, data in pairs(platforms) do
        local part = data and data.part
        if part and part.Parent and part.Size ~= targetSize then part.Size = targetSize end
    end
end

function UpdatePlatformVisibility()
    local targetTransparency = ShowPlatform and PlatformTransparency or 1
    for _, data in pairs(platforms) do
        local part = data and data.part
        if part and part.Parent and part.Transparency ~= targetTransparency then
            part.Transparency = targetTransparency
        end
    end
end

function UpdatePlatformSystem(deltaTime)
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

function StartPlatformSystem()
    if platformRunning or not PlatformEnabled then return end
    platformRunning = true
    platformConnection = RunService.Heartbeat:Connect(function(deltaTime)
        if not scriptAlive or not PlatformEnabled or not platformRunning then return end
        UpdatePlatformSystem(deltaTime)
    end)
end

function StopPlatformSystem()
    platformRunning = false
    if platformConnection then platformConnection:Disconnect(); platformConnection = nil end
    ClearAllPlatforms()
end

-- ============================================
--  GK AUTO DIVE
-- ============================================

function stopAnim()
    if liveTrack then pcall(function() liveTrack:Stop() end); liveTrack = nil end
    animPlaying = false
end

function playAnim(char, animId)
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

function getMostDangerousBall()
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

function pickDive(hrp, ballPos)
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

function reachTouchAll()
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

function fireAllKicks(hrp, flags)
    local remote = getKickRemote()
    if not remote then return end
    local cf = CFrame.new(hrp.Position, hrp.Position + hrp.CFrame.LookVector)
    for _, ball in ipairs(getAllBalls()) do
        local args = {{ ball, "Dive", 1, flags, cf, Vector3.zero }}
        pcall(function() remote:FireServer(unpack(args)) end)
    end
end

function doDive(ball)
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
        frames = frames + 1
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
--  BALL PREDICTION (97mzu)
-- ============================================

function nearestFootballToPlayer()
    local footballs = workspace:FindFirstChild("Footballs")
    if not footballs then return nil end
    local character = LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end
    local best, bestDistance = nil, math.huge
    for _, object in pairs(footballs:GetChildren()) do
        if object:IsA("BasePart") then
            local distance = (object.Position - rootPart.Position).Magnitude
            if distance < bestDistance then
                bestDistance = distance
                best = object
            end
        end
    end
    return best
end

function createBallPredictionFX()
    local folder = Instance.new("Folder")
    folder.Name = "BallPredictionFX"
    folder.Parent = workspace
    local startAttachment = Instance.new("Attachment")
    startAttachment.Name = "PredictStart"
    local endPart = Instance.new("Part")
    endPart.Name = "PredictEndPart"
    endPart.Size = Vector3.new(0.1, 0.1, 0.1)
    endPart.Transparency = 1
    endPart.Anchored = true
    endPart.CanCollide = false
    endPart.Parent = folder
    local endAttachment = Instance.new("Attachment")
    endAttachment.Name = "PredictEnd"
    endAttachment.Parent = endPart
    local beam = Instance.new("Beam")
    beam.Attachment0 = startAttachment
    beam.Attachment1 = endAttachment
    beam.Width0 = 0.4
    beam.Width1 = 0.4
    beam.FaceCamera = true
    beam.ZOffset = -0.1
    beam.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 76, 76)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 150, 150)),
    })
    beam.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.1),
        NumberSequenceKeypoint.new(0.8, 0.3),
        NumberSequenceKeypoint.new(1, 1),
    })
    beam.Parent = folder
    local impactMarker = Instance.new("Part")
    impactMarker.Shape = Enum.PartType.Ball
    impactMarker.Size = Vector3.new(0.8, 0.8, 0.8)
    impactMarker.Color = Color3.fromRGB(255, 76, 76)
    impactMarker.Material = Enum.Material.Neon
    impactMarker.Anchored = true
    impactMarker.CanCollide = false
    impactMarker.Transparency = 0.2
    impactMarker.Parent = folder
    return folder, beam, startAttachment, endAttachment, impactMarker
end

predictionConnection = nil
predictionFolder = nil
predictionBeam = nil
predictionStart = nil
predictionEnd = nil
predictionMarker = nil
predictionBall = nil

function startPrediction97mzu()
    if predictionConnection then predictionConnection:Disconnect() end
    predictionFolder, predictionBeam, predictionStart, predictionEnd, predictionMarker = createBallPredictionFX()
    predictionConnection = RunService.RenderStepped:Connect(function()
        local ball = nearestFootballToPlayer()
        local usable = ball and ball.AssemblyLinearVelocity.Magnitude > 0.5
        if usable then
            if predictionBall ~= ball then
                predictionBall = ball
                predictionStart.Parent = ball
            end
            predictionFolder.Parent = workspace
            local position = ball.Position
            local velocity = ball.AssemblyLinearVelocity
            local gravity = Vector3.new(0, -workspace.Gravity, 0)
            local t = 1.2
            local predicted = position + velocity * t + gravity * 0.5 * 1.44
            predictionEnd.Parent.Position = predicted
            local fromStart = predicted - position
            local fromEnd = position - predicted
            predictionBeam.CurveSize0 = fromStart.Magnitude * 0.5
            predictionBeam.CurveSize1 = fromEnd.Magnitude * 0.5
            if fromStart.Magnitude > 0 then predictionStart.WorldAxis = fromStart.Unit end
            if fromEnd.Magnitude > 0 then predictionEnd.WorldAxis = fromEnd.Unit end
            predictionMarker.Position = predicted
        else
            if predictionFolder then predictionFolder.Parent = nil end
            predictionBall = nil
        end
    end)
end

function stopPrediction97mzu()
    if predictionConnection then predictionConnection:Disconnect(); predictionConnection = nil end
    if predictionFolder then predictionFolder:Destroy(); predictionFolder = nil end
    predictionBeam = nil; predictionStart = nil; predictionEnd = nil; predictionMarker = nil; predictionBall = nil
end

-- ============================================
--  IMPACT DISTANCE
-- ============================================

impactFolder = nil
impactPart = nil
impactConnection = nil

function startImpactDistance()
    if impactConnection then impactConnection:Disconnect() end
    impactFolder = Instance.new("Folder")
    impactFolder.Name = "ImpactDistanceFX"
    impactFolder.Parent = workspace
    impactPart = Instance.new("Part")
    impactPart.Shape = Enum.PartType.Cylinder
    impactPart.Size = Vector3.new(0.1, 4, 4)
    impactPart.Color = Color3.fromRGB(255, 76, 76)
    impactPart.Material = Enum.Material.Neon
    impactPart.Anchored = true
    impactPart.CanCollide = false
    impactPart.Transparency = 0.4
    impactPart.CFrame = CFrame.new() * CFrame.Angles(0, 0, math.rad(90))
    impactPart.Parent = impactFolder
    impactConnection = RunService.RenderStepped:Connect(function()
        local ball = nearestFootballToPlayer()
        if not ball or ball.AssemblyLinearVelocity.Magnitude <= 0.5 then
            if impactFolder then impactFolder.Parent = nil end
            return
        end
        impactFolder.Parent = workspace
        local position = ball.Position
        local velocity = ball.AssemblyLinearVelocity
        local gravity = Vector3.new(0, -workspace.Gravity, 0)
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
        local impactPosition
        for t = 0, 3, 0.05 do
            local nextT = t + 0.05
            local p0 = position + velocity * t + gravity * 0.5 * (t ^ 2)
            local p1 = position + velocity * nextT + gravity * 0.5 * (nextT ^ 2)
            local hit = workspace:Raycast(p0, p1 - p0, rayParams)
            if hit then impactPosition = hit.Position; break end
        end
        if impactPosition then
            impactPart.Transparency = 0.4
            impactPart.CFrame = CFrame.new(impactPosition) * CFrame.Angles(0, 0, math.rad(90))
        else
            impactPart.Transparency = 1
        end
    end)
end

function stopImpactDistance()
    if impactConnection then impactConnection:Disconnect(); impactConnection = nil end
    if impactFolder then impactFolder:Destroy(); impactFolder = nil end
    impactPart = nil
end

-- ============================================
--  BALL STATS
-- ============================================

statsFolder = nil
statsBillboard = nil
statsLabel = nil
statsConnection = nil

function startBallStats()
    if statsConnection then statsConnection:Disconnect() end
    statsFolder = Instance.new("Folder")
    statsFolder.Name = "BallStatsFX"
    statsFolder.Parent = workspace
    statsBillboard = Instance.new("BillboardGui")
    statsBillboard.Size = UDim2.new(0, 200, 0, 50)
    statsBillboard.StudsOffset = Vector3.new(0, 2.5, 0)
    statsBillboard.AlwaysOnTop = true
    statsBillboard.Parent = statsFolder
    statsLabel = Instance.new("TextLabel")
    statsLabel.Size = UDim2.new(1, 0, 1, 0)
    statsLabel.BackgroundTransparency = 1
    statsLabel.TextColor3 = Color3.fromRGB(255, 76, 76)
    statsLabel.TextStrokeTransparency = 0
    statsLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    statsLabel.Font = Enum.Font.SourceSansBold
    statsLabel.TextSize = 14
    statsLabel.Parent = statsBillboard
    statsConnection = RunService.RenderStepped:Connect(function()
        local ball = nearestFootballToPlayer()
        if not ball then
            if statsFolder then statsFolder.Parent = nil end
            return
        end
        statsFolder.Parent = workspace
        statsBillboard.Adornee = ball
        local speed = math.floor(ball.AssemblyLinearVelocity.Magnitude)
        local altitude = math.floor(ball.Position.Y)
        local character = LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        local distance = 0
        if rootPart then distance = math.floor((ball.Position - rootPart.Position).Magnitude) end
        statsLabel.Text = string.format("Speed: %d SPS\nAlt: %d | Dist: %d studs", speed, altitude, distance)
    end)
end

function stopBallStats()
    if statsConnection then statsConnection:Disconnect(); statsConnection = nil end
    if statsFolder then statsFolder:Destroy(); statsFolder = nil end
    statsBillboard = nil; statsLabel = nil
end

-- ============================================
--  REACT SYSTEM
-- ============================================

function sf(k, v)
    if not setfflag then return end
    local ck = k:gsub("^DFInt",""):gsub("^DFFlag",""):gsub("^FFlag",""):gsub("^FInt","")
    pcall(function()
        if getfflag and getfflag(ck) ~= nil then setfflag(ck, v)
        else setfflag(k, v) end
    end)
end

function applyReact(tt, interp)
    _lastReactTT = tt; _lastReactInterp = interp
    if _reactThread then task.cancel(_reactThread); _reactThread = nil end
    if not _reactActive then return end
    local flags = {
        ["DFIntTargetTimeDelayFacctorTenths"] = tt,
        ["FIntInterpolationMaxDelayMSec"] = interp,
    }
    _reactThread = task.spawn(function()
        while true do
            for k, v in pairs(flags) do pcall(function() sf(k, v) end) end
            task.wait(20)
        end
    end)
end

function applyGkReact(tt, interp)
    _lastGkReactTT = tt; _lastGkReactInterp = interp
    if _gkReactThread then task.cancel(_gkReactThread); _gkReactThread = nil end
    if not _gkReactActive then return end
    local flags = {
        ["DFIntTargetTimeDelayFacctorTenths"] = tt,
        ["FIntInterpolationMaxDelayMSec"] = interp,
    }
    _gkReactThread = task.spawn(function()
        while true do
            for k, v in pairs(flags) do pcall(function() sf(k, v) end) end
            task.wait(20)
        end
    end)
end

-- ============================================
--  FFLAGS (97mzu)
-- ============================================

function pingReducer()
    local removable = { ParticleEmitter = true, Smoke = true, Fire = true }
    task.spawn(function()
        local descendants = workspace:GetDescendants()
        for i = #descendants, 1, -1 do
            local obj = descendants[i]
            if obj and removable[obj.ClassName] then obj:Destroy() end
        end
    end)
end

function darkAbyss()
    for _, child in pairs(Lighting:GetChildren()) do
        if child:IsA("Sky") then child:Destroy() end
    end
    local sky = Instance.new("Sky")
    sky.Name = "97mzuDarkSky"
    sky.SkyboxBk = "rbxassetid://0"
    sky.SkyboxDn = "rbxassetid://0"
    sky.SkyboxFt = "rbxassetid://0"
    sky.SkyboxLf = "rbxassetid://0"
    sky.SkyboxRt = "rbxassetid://0"
    sky.SkyboxUp = "rbxassetid://0"
    sky.Parent = Lighting
    Lighting.Ambient = Color3.fromRGB(128, 128, 128)
    Lighting.OutdoorAmbient = Color3.fromRGB(100, 100, 100)
    Lighting.FogColor = Color3.fromRGB(120, 120, 120)
    Lighting.FogEnd = 1000
end

savedPostEffects = {}
function disablePostFX(enabled)
    if enabled then
        for _, obj in pairs(Lighting:GetChildren()) do
            if obj:IsA("PostEffect") then savedPostEffects[obj] = obj.Enabled; obj.Enabled = false end
        end
        local camera = workspace.CurrentCamera
        if camera then
            for _, obj in pairs(camera:GetChildren()) do
                if obj:IsA("PostEffect") then savedPostEffects[obj] = obj.Enabled; obj.Enabled = false end
            end
        end
    else
        for obj, prev in pairs(savedPostEffects) do
            if obj and obj.Parent then obj.Enabled = prev end
        end
        table.clear(savedPostEffects)
    end
end

overrideState = { materials = {}, reflectance = {}, quality = nil, globalShadows = nil }

function overrideTexture(enabled)
    if enabled then
        overrideState.quality = settings().Rendering.QualityLevel
        overrideState.globalShadows = Lighting.GlobalShadows
        pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level03 end)
        Lighting.GlobalShadows = false
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                overrideState.materials[obj] = obj.Material
                overrideState.reflectance[obj] = obj.Reflectance
                obj.Material = Enum.Material.SmoothPlastic
                obj.Reflectance = 0
            elseif obj:IsA("Texture") or obj:IsA("Decal") then
                obj.Transparency = 1
            end
        end
    else
        pcall(function()
            if overrideState.quality then settings().Rendering.QualityLevel = overrideState.quality end
        end)
        if overrideState.globalShadows ~= nil then Lighting.GlobalShadows = overrideState.globalShadows end
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local mat = overrideState.materials[obj]
                if mat then obj.Material = mat end
                local ref = overrideState.reflectance[obj]
                if ref ~= nil then obj.Reflectance = ref end
            elseif obj:IsA("Texture") or obj:IsA("Decal") then
                obj.Transparency = 0
            end
        end
        table.clear(overrideState.materials); table.clear(overrideState.reflectance)
    end
end

disablePlayerShadowsConnection = nil
function disablePlayerShadows(enabled)
    if disablePlayerShadowsConnection then disablePlayerShadowsConnection:Disconnect(); disablePlayerShadowsConnection = nil end
    if not enabled then return end
    local function applyCharacter(character)
        if not character then return end
        for _, obj in pairs(character:GetDescendants()) do
            if obj:IsA("BasePart") then obj.CastShadow = false end
        end
    end
    local function bindPlayer(player)
        if player.Character then applyCharacter(player.Character) end
        player.CharacterAdded:Connect(applyCharacter)
    end
    for _, player in pairs(Players:GetPlayers()) do bindPlayer(player) end
    disablePlayerShadowsConnection = Players.PlayerAdded:Connect(bindPlayer)
end

-- ============================================
--  SKY TEXTURES (97mzu)
-- ============================================

function auroraSky()
    local sky = Instance.new("Sky")
    sky.SkyboxBk = "rbxassetid://75955506846727"
    sky.SkyboxDn = "rbxassetid://117391257413562"
    sky.SkyboxFt = "rbxassetid://109900307855247"
    sky.SkyboxLf = "rbxassetid://99736968434760"
    sky.SkyboxRt = "rbxassetid://130270741662079"
    sky.SkyboxUp = "rbxassetid://102086995250620"
    sky.Parent = Lighting
end

function fullNightSky()
    local sky = Instance.new("Sky")
    sky.Parent = Lighting
    sky.CelestialBodiesShown = false
    local texture = "http://www.roblox.com/asset/?id=17055447520"
    sky.SkyboxBk = texture; sky.SkyboxDn = texture; sky.SkyboxFt = texture
    sky.SkyboxLf = texture; sky.SkyboxRt = texture; sky.SkyboxUp = texture
end

function sakuraPinkSky()
    local sky = Instance.new("Sky")
    sky.Parent = Lighting
    sky.SkyboxBk = "http://www.roblox.com/asset/?id=271042516"
    sky.SkyboxDn = "http://www.roblox.com/asset/?id=271077243"
    sky.SkyboxFt = "http://www.roblox.com/asset/?id=271042556"
    sky.SkyboxLf = "http://www.roblox.com/asset/?id=271042310"
    sky.SkyboxRt = "http://www.roblox.com/asset/?id=271042467"
    sky.SkyboxUp = "http://www.roblox.com/asset/?id=271077958"
    sky.StarCount = 5000
end

-- ============================================
--  200 KICKS
-- ============================================

function fireKick()
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
    local direction = CFrame.new(hrp.Position + lookVector * 5, hrp.Position + lookVector * 10)
    local args = {{ ball, "Shoot", 1, { Right = false, Ground = true, Left = false }, direction, Vector3.zero }}
    pcall(function() kickRemote:FireServer(unpack(args)) end)
end

-- ============================================
--  FLY SYSTEM
-- ============================================

function flyCleanup()
    if flyBV then pcall(function() flyBV:Destroy() end); flyBV = nil end
    pcall(function()
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum.PlatformStand = false end
    end)
end

-- ============================================
--  WALKSPEED & JUMP POWER
-- ============================================

function SetWalkSpeedSafely(humanoid, value)
    if not humanoid or not humanoid.Parent then return end
    if humanoid.WalkSpeed == value then return end
    changingWalkSpeed = true
    humanoid.WalkSpeed = value
    changingWalkSpeed = false
end

function ApplyWalkSpeed(character)
    if not WalkSpeedEnabled or isCharacterRespawning then return end
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then currentHumanoid = humanoid; SetWalkSpeedSafely(humanoid, WalkSpeedValue) end
end

function StopWalkSpeedLoop(restoreDefault)
    if walkSpeedConnection then walkSpeedConnection:Disconnect(); walkSpeedConnection = nil end
    local humanoid = currentHumanoid or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid"))
    if restoreDefault and humanoid then SetWalkSpeedSafely(humanoid, DefaultWalkSpeed) end
    currentHumanoid = nil
end

function StartWalkSpeedLoop()
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

function ApplyJumpPower(character)
    if not JumpPowerEnabled or isCharacterRespawning then return end
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.JumpPower = JumpPowerValue
        pcall(function() humanoid.JumpHeight = JumpPowerValue / 7 end)
    end
end

function ResetJumpPower(character)
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.JumpPower = DefaultJumpPower
        pcall(function() humanoid.JumpHeight = DefaultJumpPower / 7 end)
    end
end

function OnCharacterAdded(character)
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

if LocalPlayer.Character then task.spawn(OnCharacterAdded, LocalPlayer.Character) end

-- API de compatibilidad: conecta los controles de la UI con el estado real del script.
do
    local state = {}
    local aliases = {}
    local function alias(name, getter, setter)
        aliases[name] = { get = getter, set = setter }
    end
    alias("m1_enabled", function() return m1_enabled end, function(v) m1_enabled = v end)
    alias("m1_size", function() return m1_size end, function(v) m1_size = v end)
    alias("m1_transparency", function() return m1_transparency end, function(v) m1_transparency = v end)
    alias("REACH_SIZE", function() return REACH_SIZE end, function(v) REACH_SIZE = v end)
    alias("reachMethod2Enabled", function() return reachMethod2Enabled end, function(v) reachMethod2Enabled = v end)
    alias("reachTransparency2", function() return reachTransparency2 end, function(v) reachTransparency2 = v end)
    alias("proxyEnabled", function() return proxyEnabled end, function(v) proxyEnabled = v end)
    alias("CharacterReachEnabled", function() return CharacterReachEnabled end, function(v) CharacterReachEnabled = v end)
    alias("CharacterReachSize", function() return CharacterReachSize end, function(v) CharacterReachSize = v end)
    alias("CharacterVisualizerIntensity", function() return CharacterVisualizerIntensity end, function(v) CharacterVisualizerIntensity = v end)
    alias("PlatformEnabled", function() return PlatformEnabled end, function(v) PlatformEnabled = v end)
    alias("PlatformSize", function() return PlatformSize end, function(v) PlatformSize = v end)
    alias("Smoothness", function() return Smoothness end, function(v) Smoothness = v end)
    alias("ShowPlatform", function() return ShowPlatform end, function(v) ShowPlatform = v end)
    alias("PlatformTransparency", function() return PlatformTransparency end, function(v) PlatformTransparency = v end)
    alias("WalkSpeedValue", function() return WalkSpeedValue end, function(v) WalkSpeedValue = v end)
    alias("WalkSpeedEnabled", function() return WalkSpeedEnabled end, function(v) WalkSpeedEnabled = v end)
    alias("JumpPowerEnabled", function() return JumpPowerEnabled end, function(v) JumpPowerEnabled = v end)
    alias("JumpPowerValue", function() return JumpPowerValue end, function(v) JumpPowerValue = v end)
    alias("DIVE_RANGE", function() return DIVE_RANGE end, function(v) DIVE_RANGE = v end)
    alias("DIVE_SPEED", function() return DIVE_SPEED end, function(v) DIVE_SPEED = v end)
    alias("DIVE_LIFT", function() return DIVE_LIFT end, function(v) DIVE_LIFT = v end)
    alias("COOLDOWN", function() return COOLDOWN end, function(v) COOLDOWN = v end)
    alias("HIT_RADIUS", function() return HIT_RADIUS end, function(v) HIT_RADIUS = v end)
    alias("gkAutoDiveEnabled", function() return gkAutoDiveEnabled end, function(v) gkAutoDiveEnabled = v end)
    alias("kickLoopEnabled", function() return kickLoopEnabled end, function(v) kickLoopEnabled = v end)
    alias("kickReach", function() return kickReach end, function(v) kickReach = v end)
    alias("dribbleEnabled", function() return dribbleEnabled end, function(v) dribbleEnabled = v end)
    alias("dribbleSpeed", function() return dribbleSpeed end, function(v) dribbleSpeed = v end)
    alias("flyEnabled", function() return flyEnabled end, function(v) flyEnabled = v end)
    alias("flySpeed", function() return flySpeed end, function(v) flySpeed = v end)
    alias("tpEnabled", function() return tpEnabled end, function(v) tpEnabled = v end)
    alias("tpSpeed", function() return tpSpeed end, function(v) tpSpeed = v end)
    alias("_reactActive", function() return _reactActive end, function(v) _reactActive = v end)
    alias("_reactThread", function() return _reactThread end, function(v) _reactThread = v end)
    alias("_lastReactTT", function() return _lastReactTT end, function(v) _lastReactTT = v end)
    alias("_lastReactInterp", function() return _lastReactInterp end, function(v) _lastReactInterp = v end)
    alias("_gkReactActive", function() return _gkReactActive end, function(v) _gkReactActive = v end)
    alias("_gkReactThread", function() return _gkReactThread end, function(v) _gkReactThread = v end)
    alias("_lastGkReactTT", function() return _lastGkReactTT end, function(v) _lastGkReactTT = v end)
    alias("_lastGkReactInterp", function() return _lastGkReactInterp end, function(v) _lastGkReactInterp = v end)
    local functions = {
        StartProxySystem = StartProxySystem, StopProxySystem = StopProxySystem,
        StartMethod1 = StartMethod1, StopMethod1 = StopMethod1,
        StartMethod2 = StartMethod2, StopMethod2 = StopMethod2,
        StartCharacterReachSystem = StartCharacterReachSystem, StopCharacterReachSystem = StopCharacterReachSystem,
        RefreshCharacterReach = function() RefreshCharacterReach(LocalPlayer.Character) end,
        UpdateVisualizers = UpdateVisualizers,
        StartPlatformSystem = StartPlatformSystem, StopPlatformSystem = StopPlatformSystem,
        UpdatePlatformSize = UpdatePlatformSize, UpdatePlatformVisibility = UpdatePlatformVisibility,
        StartWalkSpeedLoop = StartWalkSpeedLoop, StopWalkSpeedLoop = StopWalkSpeedLoop,
        ApplyWalkSpeed = ApplyWalkSpeed, ResetJumpPower = ResetJumpPower,
        StealAvatarByName = StealAvatarByName, applyReact = applyReact, applyGkReact = applyGkReact,
        auroraSky = auroraSky, darkAbyss = darkAbyss, disablePlayerShadows = disablePlayerShadows,
        disablePostFX = disablePostFX, overrideTexture = overrideTexture, fullNightSky = fullNightSky,
        sakuraPinkSky = sakuraPinkSky, pingReducer = pingReducer, sf = sf,
        startPrediction97mzu = startPrediction97mzu, stopPrediction97mzu = stopPrediction97mzu,
        startImpactDistance = startImpactDistance, stopImpactDistance = stopImpactDistance,
        startBallStats = startBallStats, stopBallStats = stopBallStats, stopAnim = stopAnim,
    }
    functions.StartFly = function()
        flyEnabled = true
        if flyConn then flyConn:Disconnect() end
        flyConn = RunService.Heartbeat:Connect(function()
            if not scriptAlive or not flyEnabled then flyCleanup(); return end
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum then return end
            hum.PlatformStand = true
            if not flyBV or not flyBV.Parent then
                flyBV = Instance.new("BodyVelocity")
                flyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                flyBV.Parent = hrp
            end
            local up = UserInputService:IsKeyDown(Enum.KeyCode.Space) and Vector3.new(0,1,0) or Vector3.zero
            local down = (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)) and Vector3.new(0,-1,0) or Vector3.zero
            local dir = hum.MoveDirection + up + down
            flyBV.Velocity = dir.Magnitude > 0 and dir.Unit * flySpeed or Vector3.zero
        end)
    end
    functions.StopFly = function()
        flyEnabled = false
        if flyConn then flyConn:Disconnect(); flyConn = nil end
        flyCleanup()
    end
    functions.StartTPWalk = function()
        tpEnabled = true
        if tpConn then tpConn:Disconnect() end
        tpConn = RunService.Heartbeat:Connect(function()
            if not tpEnabled then return end
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.MoveDirection.Magnitude > 0.1 then hrp.CFrame = hrp.CFrame + hum.MoveDirection * tpSpeed end
        end)
    end
    functions.StopTPWalk = function()
        tpEnabled = false
        if tpConn then tpConn:Disconnect(); tpConn = nil end
    end
    functions.StartKickLoop = function()
        kickLoopEnabled = true
        if kickConnection then kickConnection:Disconnect() end
        kickConnection = RunService.PreSimulation:Connect(function() if kickLoopEnabled and scriptAlive then fireKick() end end)
    end
    functions.StopKickLoop = function()
        kickLoopEnabled = false
        if kickConnection then kickConnection:Disconnect(); kickConnection = nil end
    end
    functions.StartDribble = function()
        dribbleEnabled = true
        if dribbleConn then dribbleConn:Disconnect() end
        dribbleConn = RunService.Heartbeat:Connect(function()
            if not dribbleEnabled then return end
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local ball = getClosestFootball()
            if hum and ball then hum.WalkSpeed = dribbleSpeed; hum:MoveTo(ball.Position) end
        end)
    end
    functions.StopDribble = function()
        dribbleEnabled = false
        if dribbleConn then dribbleConn:Disconnect(); dribbleConn = nil end
        pcall(function() local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if hum then hum.WalkSpeed = DefaultWalkSpeed end end)
    end
    setmetatable(state, {
        __index = function(_, key) local a = aliases[key]; if a then return a.get() end; return functions[key] end,
        __newindex = function(t, key, value) local a = aliases[key]; if a then a.set(value) else rawset(t, key, value) end end,
    })
    _G.P3G_HUB_API = state
end

-- ============================================================================
--   TON HUB  ·  UI  (adaptada a P3G / Touchline)
--   Left sidebar tabs · animated TON 618 background
--   Right Ctrl = toggle  ·  "-" = hide  ·  "X" = stop everything and destroy
-- ============================================================================
do
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Players          = game:GetService("Players")
local CoreGui          = game:GetService("CoreGui")
local Lighting         = game:GetService("Lighting")
local Stats            = game:GetService("Stats")
local LocalPlayer      = Players.LocalPlayer

-- API del script (la exporta la lógica de arriba en _G.P3G_HUB_API)
local Touchline = _G.P3G_HUB_API or {}

local TH = {
	Bg      = Color3.fromRGB(6, 5, 9),
	Element = Color3.fromRGB(22, 17, 26),
	Accent  = Color3.fromRGB(255, 140, 26),
	Accent2 = Color3.fromRGB(255, 200, 100),
	Deep    = Color3.fromRGB(190, 52, 10),
	Text    = Color3.fromRGB(255, 240, 225),
	SubText = Color3.fromRGB(170, 146, 128),
	Off     = Color3.fromRGB(46, 36, 40),
	Jet     = Color3.fromRGB(150, 195, 255),
}

--------------------------------------------------------------------
-- Utilidades
--------------------------------------------------------------------
local conns = {}
local function bind(signal, fn)
	local c = signal:Connect(fn)
	conns[#conns + 1] = c
	return c
end

local function new(class, props, children)
	local inst = Instance.new(class)
	local parent
	for k, v in pairs(props or {}) do
		if k == "Parent" then parent = v else inst[k] = v end
	end
	for _, c in ipairs(children or {}) do c.Parent = inst end
	if parent then inst.Parent = parent end
	return inst
end

local function tween(o, t, props, style, dir)
	local tw = TweenService:Create(o, TweenInfo.new(t, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
	tw:Play()
	return tw
end

local function corner(o, px) return new("UICorner", { CornerRadius = UDim.new(0, px), Parent = o }) end
local function stroke(o, color, th, tr)
	return new("UIStroke", { Color = color, Thickness = th, Transparency = tr or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = o })
end
local function safeCall(fn, ...)
	if typeof(fn) ~= "function" then return end
	local ok, err = pcall(fn, ...)
	if not ok then warn("[TON HUB] " .. tostring(err)) end
end
local function call(name, ...)
	local f = Touchline[name]
	if f then safeCall(f, ...) end
end
local function num(v, fb) return (type(v) == "number") and v or fb end
local function pct(v, fb) return math.floor(num(v, fb) * 100 + 0.5) end

local function getGuiParent()
	local ok, h = pcall(function() return gethui and gethui() end)
	if ok and h then return h end
	local ok2 = pcall(function() return CoreGui.Name end)
	if ok2 then return CoreGui end
	return LocalPlayer:WaitForChild("PlayerGui")
end

--------------------------------------------------------------------
-- ScreenGui + ventana
--------------------------------------------------------------------
local parent = getGuiParent()
for _, n in ipairs({ "TONHUB_P3G", "P3G_HUB_UI", "TONHUB" }) do
	local o = parent:FindFirstChild(n)
	if o then o:Destroy() end
end

local Gui = new("ScreenGui", { Name = "TONHUB_P3G", ResetOnSpawn = false, IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling })
pcall(function() if syn and syn.protect_gui then syn.protect_gui(Gui) end end)
Gui.Parent = parent

local Blur = Lighting:FindFirstChild("P3G_Blur") or new("BlurEffect", { Name = "P3G_Blur", Size = 0, Parent = Lighting })
Blur.Enabled = false

local W, H = 700, 470
local Main = new("Frame", {
	Name = "Main", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(W, H), BackgroundColor3 = TH.Bg, BorderSizePixel = 0,
	ClipsDescendants = true, Parent = Gui,
})
corner(Main, 14)
local Scale = new("UIScale", { Scale = 0.01, Parent = Main })

--------------------------------------------------------------------
-- ANIMATED BACKGROUND: TON 618
--------------------------------------------------------------------
local Space = new("Frame", {
	Name = "Space", Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(3, 2, 6),
	BorderSizePixel = 0, ZIndex = 1, Parent = Main,
})

local rng = Random.new(618)
local stars = {}
for i = 1, 55 do
	local s = rng:NextInteger(1, 2)
	local f = new("Frame", {
		Position = UDim2.fromScale(rng:NextNumber(), rng:NextNumber()), Size = UDim2.fromOffset(s, s),
		BorderSizePixel = 0, BackgroundColor3 = (i % 5 == 0) and TH.Accent2 or Color3.fromRGB(200, 215, 255),
		Parent = Space,
	})
	stars[#stars + 1] = { f = f, ph = rng:NextNumber() * 6.28, sp = 0.6 + rng:NextNumber() * 1.6 }
end

local Center = new("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.63, 0.54),
	Size = UDim2.fromOffset(0, 0), BackgroundTransparency = 1, Parent = Space,
})
local TILT = math.rad(-14)
local COS_T, SIN_T = math.cos(TILT), math.sin(TILT)

local glows = {}
for i = 1, 5 do
	local size = 150 + i * 62
	local f = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(size, size), BorderSizePixel = 0,
		BackgroundColor3 = (i < 3) and TH.Accent or TH.Deep, BackgroundTransparency = 0.82 + i * 0.03,
		ZIndex = 1, Parent = Center,
	})
	corner(f, 999)
	glows[#glows + 1] = { f = f, base = 0.82 + i * 0.03, i = i }
end

local Hole = new("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(112, 112), BackgroundColor3 = Color3.new(0, 0, 0),
	BorderSizePixel = 0, ZIndex = 3, Parent = Center,
})
corner(Hole, 999)

local Photon = new("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(122, 122), BackgroundTransparency = 1,
	ZIndex = 4, Parent = Center,
})
corner(Photon, 999)
local PhotonStroke = stroke(Photon, TH.Accent2, 2.5, 0)
local PhotonGrad = new("UIGradient", {
	Rotation = 200,
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 45, 10)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 200, 120)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 45, 10)),
	}),
	Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.8), NumberSequenceKeypoint.new(0.5, 0.05), NumberSequenceKeypoint.new(1, 0.8) }),
	Parent = PhotonStroke,
})
local Photon2 = new("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(138, 138), BackgroundTransparency = 1,
	ZIndex = 4, Parent = Center,
})
corner(Photon2, 999)
stroke(Photon2, TH.Accent, 1, 0.65)

-- Accretion disk: tilted, orbiting particles. Everything sits BEHIND the black
-- shadow, so nothing crosses in front of it.
local particles = {}
for _ = 1, 190 do
	local a = 66 + (rng:NextNumber() ^ 1.7) * 158
	local t = (a - 66) / 158
	local col
	if t < 0.3 then
		col = Color3.fromRGB(255, 205, 120):Lerp(TH.Accent, t / 0.3)
	else
		col = TH.Accent:Lerp(Color3.fromRGB(150, 40, 10), math.clamp((t - 0.3) / 0.7, 0, 1))
	end
	local size = rng:NextInteger(1, 3)
	local f = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(size, size), BackgroundColor3 = col,
		BorderSizePixel = 0, ZIndex = 2, Parent = Center,
	})
	particles[#particles + 1] = { f = f, a = a, b = a * 0.2, ang = rng:NextNumber() * 6.2832, w = 900 / (a ^ 1.5) }
end

-- Gravitational lensing: the far side of the disk is bent over the top and
-- under the bottom of the shadow, forming a thin glowing halo.
local lens = {}
for _ = 1, 70 do
	local r = 63 + (rng:NextNumber() ^ 2) * 24
	local size = rng:NextInteger(1, 3)
	local f = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(size, size),
		BackgroundColor3 = Color3.fromRGB(255, 205, 120):Lerp(TH.Accent, (r - 63) / 24),
		BorderSizePixel = 0, ZIndex = 2, Parent = Center,
	})
	lens[#lens + 1] = { f = f, r = r, ang = rng:NextNumber() * 6.2832, w = 0.45 + rng:NextNumber() * 0.45 }
end

--------------------------------------------------------------------
-- UI container (above the background)
--------------------------------------------------------------------
local UI = new("Frame", { Name = "UI", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 10, Parent = Main })

-- HEADER ---------------------------------------------------------
local Header = new("Frame", {
	Size = UDim2.new(1, 0, 0, 52), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.3,
	BorderSizePixel = 0, Parent = UI,
})
new("Frame", {
	AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 1),
	BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Parent = Header,
}, { new("UIGradient", {
	Color = ColorSequence.new(TH.Accent, TH.Accent),
	Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0.2), NumberSequenceKeypoint.new(1, 1) }),
}) })

-- Logo (mini agujero negro)
local Logo = new("Frame", {
	AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 18, 0.5, 0), Size = UDim2.fromOffset(26, 26),
	BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, Parent = Header,
})
corner(Logo, 999)
local LogoStroke = stroke(Logo, TH.Accent2, 2.5, 0)
local LogoGrad = new("UIGradient", {
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, TH.Deep), ColorSequenceKeypoint.new(0.5, TH.Accent2), ColorSequenceKeypoint.new(1, TH.Deep) }),
	Parent = LogoStroke,
})

new("TextLabel", {
	Position = UDim2.fromOffset(54, 0), Size = UDim2.fromOffset(130, 52), BackgroundTransparency = 1,
	Text = "TON HUB", Font = Enum.Font.GothamBlack, TextSize = 20, TextColor3 = Color3.new(1, 1, 1),
	TextXAlignment = Enum.TextXAlignment.Left, Parent = Header,
}, { new("UIGradient", { Color = ColorSequence.new(TH.Accent2, TH.Accent) }) })

local function headerBtn(text, xOff, hoverColor)
	local b = new("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, xOff, 0.5, 0), Size = UDim2.fromOffset(30, 30),
		BackgroundColor3 = TH.Element, BackgroundTransparency = 0.25, Text = text, Font = Enum.Font.GothamBold,
		TextSize = 14, TextColor3 = TH.Text, AutoButtonColor = false, Parent = Header,
	})
	corner(b, 8)
	stroke(b, TH.Accent, 1, 0.8)
	b.MouseEnter:Connect(function() tween(b, 0.15, { BackgroundColor3 = hoverColor, BackgroundTransparency = 0 }) end)
	b.MouseLeave:Connect(function() tween(b, 0.15, { BackgroundColor3 = TH.Element, BackgroundTransparency = 0.25 }) end)
	return b
end
local CloseBtn = headerBtn("X", -14, TH.Deep)
local MinBtn   = headerBtn("-", -50, Color3.fromRGB(70, 46, 22))

-- version badge
local Badge = new("TextLabel", {
	AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -92, 0.5, 0), Size = UDim2.fromOffset(48, 20),
	BackgroundColor3 = TH.Accent, BackgroundTransparency = 0.82, Text = "v1.0", Font = Enum.Font.GothamBold,
	TextSize = 11, TextColor3 = TH.Accent2, Parent = Header,
})
corner(Badge, 999)
stroke(Badge, TH.Accent, 1, 0.5)

-- Arrastrar desde el header
do
	local dragging, startMouse, startPos
	Header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging, startMouse, startPos = true, input.Position, Main.Position
		end
	end)
	bind(UserInputService.InputChanged, function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local d = input.Position - startMouse
			Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)
	bind(UserInputService.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

-- FOOTER ---------------------------------------------------------
local Footer = new("Frame", {
	AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 26),
	BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.3, BorderSizePixel = 0, Parent = UI,
})
new("Frame", { Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = TH.Accent, BackgroundTransparency = 0.8,
	BorderSizePixel = 0, Parent = Footer })
local statusDot = new("Frame", {
	AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 16, 0.5, 0), Size = UDim2.fromOffset(7, 7),
	BackgroundColor3 = Color3.fromRGB(90, 220, 130), BorderSizePixel = 0, Parent = Footer,
})
corner(statusDot, 999)
new("TextLabel", {
	Position = UDim2.fromOffset(30, 0), Size = UDim2.new(0.5, -30, 1, 0), BackgroundTransparency = 1,
	Text = "TON HUB  ·  active", Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = TH.SubText,
	TextXAlignment = Enum.TextXAlignment.Left, Parent = Footer,
})
local StatsLabel = new("TextLabel", {
	AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -16, 0, 0), Size = UDim2.new(0.5, 0, 1, 0),
	BackgroundTransparency = 1, Text = "", Font = Enum.Font.Code, TextSize = 11, TextColor3 = TH.SubText,
	TextXAlignment = Enum.TextXAlignment.Right, Parent = Footer,
})

-- SIDEBAR (tabs on the left) ------------------------------------
local Sidebar = new("Frame", {
	Position = UDim2.fromOffset(0, 52), Size = UDim2.new(0, 176, 1, -78), BackgroundColor3 = Color3.new(0, 0, 0),
	BackgroundTransparency = 0.4, BorderSizePixel = 0, Parent = UI,
})
new("Frame", {
	AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(1, 0), Size = UDim2.new(0, 1, 1, 0),
	BackgroundColor3 = TH.Accent, BackgroundTransparency = 0.82, BorderSizePixel = 0, Parent = Sidebar,
})
new("TextLabel", {
	Position = UDim2.fromOffset(20, 12), Size = UDim2.fromOffset(100, 14), BackgroundTransparency = 1,
	Text = "MENU", Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = TH.Accent,
	TextXAlignment = Enum.TextXAlignment.Left, Parent = Sidebar,
})
local TabList = new("Frame", {
	Position = UDim2.fromOffset(10, 32), Size = UDim2.new(1, -20, 1, -100), BackgroundTransparency = 1, Parent = Sidebar,
}, { new("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }) })

-- tarjeta de usuario
local UserCard = new("Frame", {
	AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -10), Size = UDim2.new(1, -20, 0, 46),
	BackgroundColor3 = TH.Element, BackgroundTransparency = 0.25, BorderSizePixel = 0, Parent = Sidebar,
})
corner(UserCard, 9)
stroke(UserCard, TH.Accent, 1, 0.8)
local avatar = new("ImageLabel", {
	AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 8, 0.5, 0), Size = UDim2.fromOffset(30, 30),
	BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0,
	Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150", Parent = UserCard,
})
corner(avatar, 999)
stroke(avatar, TH.Accent, 1.5, 0.2)
new("TextLabel", {
	Position = UDim2.fromOffset(46, 6), Size = UDim2.new(1, -52, 0, 16), BackgroundTransparency = 1,
	Text = LocalPlayer.DisplayName, Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = TH.Text,
	TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = UserCard,
})
new("TextLabel", {
	Position = UDim2.fromOffset(46, 22), Size = UDim2.new(1, -52, 0, 14), BackgroundTransparency = 1,
	Text = "@" .. LocalPlayer.Name, Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = TH.SubText,
	TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = UserCard,
})

-- CONTENIDO --------------------------------------------------------
local PageTitle = new("TextLabel", {
	Position = UDim2.fromOffset(190, 62), Size = UDim2.new(1, -206, 0, 22), BackgroundTransparency = 1, Text = "",
	Font = Enum.Font.GothamBlack, TextSize = 18, TextColor3 = TH.Text, TextXAlignment = Enum.TextXAlignment.Left, Parent = UI,
})
local PageDesc = new("TextLabel", {
	Position = UDim2.fromOffset(190, 84), Size = UDim2.new(1, -206, 0, 14), BackgroundTransparency = 1, Text = "",
	Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = TH.SubText, TextXAlignment = Enum.TextXAlignment.Left, Parent = UI,
})
local Pages = new("Frame", {
	Position = UDim2.fromOffset(186, 106), Size = UDim2.new(1, -198, 1, -142), BackgroundTransparency = 1, Parent = UI,
})

--------------------------------------------------------------------
-- Tabs + componentes
--------------------------------------------------------------------
local tabs = {}
local Tab = {}
Tab.__index = Tab

local function selectTab(t)
	for _, x in ipairs(tabs) do
		local on = (x == t)
		if on and not x.Page.Visible then
			x.Page.Position = UDim2.fromOffset(0, 10)
			x.Page.Visible = true
			tween(x.Page, 0.25, { Position = UDim2.fromOffset(0, 0) })
		elseif not on then
			x.Page.Visible = false
		end
		tween(x.TabBtn, 0.2, { BackgroundTransparency = on and 0.84 or 1 })
		tween(x.Bar, 0.2, { Size = UDim2.fromOffset(3, on and 18 or 0) })
		tween(x.Lbl, 0.2, { TextColor3 = on and TH.Text or TH.SubText, Position = UDim2.fromOffset(on and 20 or 16, 0) })
	end
	PageTitle.Text = t.Title
	PageDesc.Text = t.Desc
end

local function nextOrder(self) self.Order += 1 return self.Order end

local function baseRow(self, height)
	local row = new("Frame", {
		Size = UDim2.new(1, 0, 0, height), BackgroundColor3 = TH.Element, BackgroundTransparency = 0.22,
		BorderSizePixel = 0, LayoutOrder = nextOrder(self), Parent = self.Page,
	})
	corner(row, 8)
	stroke(row, TH.Accent, 1, 0.84)
	return row
end

local function rowLabel(row, text, w)
	return new("TextLabel", {
		Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -(w or 80), 1, 0), BackgroundTransparency = 1,
		Text = text, Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = TH.Text,
		TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Parent = row,
	})
end

function Tab:Section(name)
	local f = new("Frame", { Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, LayoutOrder = nextOrder(self), Parent = self.Page })
	new("Frame", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 2, 0.5, 0), Size = UDim2.fromOffset(3, 12),
		BackgroundColor3 = TH.Accent, BorderSizePixel = 0, Parent = f })
	new("TextLabel", {
		Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -12, 1, 0), BackgroundTransparency = 1,
		Text = string.upper(name), Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = TH.Accent,
		TextXAlignment = Enum.TextXAlignment.Left, Parent = f,
	})
end

function Tab:Label(text)
	local row = baseRow(self, 32)
	local l = rowLabel(row, text, 28)
	l.TextColor3 = TH.SubText
	l.Font = Enum.Font.Gotham
	return l
end

function Tab:Toggle(o)
	local state = o.Default or false
	local row = baseRow(self, 40)
	rowLabel(row, o.Name or "Toggle", 80)
	local sw = new("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -14, 0.5, 0), Size = UDim2.fromOffset(42, 22),
		BackgroundColor3 = TH.Off, Text = "", AutoButtonColor = false, Parent = row,
	})
	corner(sw, 999)
	local knob = new("Frame", {
		AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 3, 0.5, 0), Size = UDim2.fromOffset(16, 16),
		BackgroundColor3 = TH.Text, BorderSizePixel = 0, Parent = sw,
	})
	corner(knob, 999)
	local obj = {}
	local function render()
		tween(sw, 0.18, { BackgroundColor3 = state and TH.Accent or TH.Off })
		tween(knob, 0.18, { Position = state and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0) })
	end
	function obj:Set(v)
		state = v and true or false
		render()
		safeCall(o.Callback, state)
	end
	function obj:Get() return state end
	sw.MouseButton1Click:Connect(function() obj:Set(not state) end)
	render()
	return obj
end

function Tab:Slider(o)
	local min, max, inc = o.Min or 0, o.Max or 100, o.Increment or 1
	local value = math.clamp(o.Default or min, min, max)
	local suffix = o.Suffix or ""
	local row = baseRow(self, 56)
	rowLabel(row, o.Name or "Slider", 120).Position = UDim2.fromOffset(14, -10)
	local valLabel = new("TextLabel", {
		AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 9), Size = UDim2.fromOffset(90, 18),
		BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = TH.Accent2,
		TextXAlignment = Enum.TextXAlignment.Right, Text = "", Parent = row,
	})
	local track = new("Frame", {
		Position = UDim2.fromOffset(14, 38), Size = UDim2.new(1, -28, 0, 6), BackgroundColor3 = TH.Off,
		BorderSizePixel = 0, Parent = row,
	})
	corner(track, 3)
	local fill = new("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Parent = track },
		{ new("UIGradient", { Color = ColorSequence.new(TH.Deep, TH.Accent2) }) })
	corner(fill, 3)
	local knob = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0, 0.5), Size = UDim2.fromOffset(14, 14),
		BackgroundColor3 = TH.Text, BorderSizePixel = 0, ZIndex = 2, Parent = track,
	})
	corner(knob, 999)
	stroke(knob, TH.Accent, 2, 0)
	local hit = new("TextButton", {
		Position = UDim2.fromOffset(14, 28), Size = UDim2.new(1, -28, 0, 24), BackgroundTransparency = 1,
		Text = "", ZIndex = 3, Parent = row,
	})
	local obj = {}
	local function render()
		local a = (max == min) and 0 or (value - min) / (max - min)
		fill.Size = UDim2.fromScale(a, 1)
		knob.Position = UDim2.fromScale(a, 0.5)
		valLabel.Text = ((inc < 1) and string.format("%.2f", value) or string.format("%d", value)) .. suffix
	end
	local function setValue(v)
		v = math.floor((v - min) / inc + 0.5) * inc + min
		v = math.clamp(v, min, max)
		if v == value then return end
		value = v
		render()
		safeCall(o.Callback, value)
	end
	function obj:Set(v) setValue(v) end
	function obj:Get() return value end
	local dragging = false
	local function fromX(x)
		setValue(min + math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1) * (max - min))
	end
	hit.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			fromX(input.Position.X)
		end
	end)
	bind(UserInputService.InputChanged, function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			fromX(input.Position.X)
		end
	end)
	bind(UserInputService.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	render()
	return obj
end

function Tab:Button(o)
	local btn = new("TextButton", {
		Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = TH.Element, BackgroundTransparency = 0.22,
		Text = o.Name or "Button", Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = TH.Text,
		AutoButtonColor = false, BorderSizePixel = 0, LayoutOrder = nextOrder(self), Parent = self.Page,
	})
	corner(btn, 8)
	local st = stroke(btn, TH.Accent, 1, 0.6)
	btn.MouseEnter:Connect(function()
		tween(btn, 0.15, { BackgroundColor3 = Color3.fromRGB(58, 32, 14) })
		tween(st, 0.15, { Transparency = 0.05 })
	end)
	btn.MouseLeave:Connect(function()
		tween(btn, 0.15, { BackgroundColor3 = TH.Element })
		tween(st, 0.15, { Transparency = 0.6 })
	end)
	btn.MouseButton1Click:Connect(function()
		btn.BackgroundColor3 = TH.Accent
		btn.TextColor3 = Color3.fromRGB(20, 10, 4)
		tween(btn, 0.35, { BackgroundColor3 = TH.Element, TextColor3 = TH.Text })
		safeCall(o.Callback)
	end)
	return btn
end

function Tab:Textbox(o)
	local row = baseRow(self, 44)
	rowLabel(row, o.Name or "Textbox", 200)
	local box = new("TextBox", {
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(170, 28),
		BackgroundColor3 = Color3.fromRGB(10, 8, 13), BackgroundTransparency = 0.1, BorderSizePixel = 0,
		Text = o.Default or "", PlaceholderText = o.Placeholder or "Type here...", PlaceholderColor3 = TH.SubText,
		TextColor3 = TH.Text, Font = Enum.Font.Gotham, TextSize = 13, ClearTextOnFocus = false,
		TextXAlignment = Enum.TextXAlignment.Left, ClipsDescendants = true, Parent = row,
	}, { new("UIPadding", { PaddingLeft = UDim.new(0, 9), PaddingRight = UDim.new(0, 9) }) })
	corner(box, 6)
	local st = stroke(box, TH.Accent, 1, 0.7)
	box.Focused:Connect(function() tween(st, 0.15, { Transparency = 0, Color = TH.Accent2 }) end)
	box.FocusLost:Connect(function(enter)
		tween(st, 0.15, { Transparency = 0.7, Color = TH.Accent })
		safeCall(o.Callback, box.Text, enter)
	end)
	return box
end

local function CreateTab(name, desc)
	local i = #tabs + 1
	local btn = new("TextButton", {
		Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = TH.Accent, BackgroundTransparency = 1, Text = "",
		AutoButtonColor = false, LayoutOrder = i, Parent = TabList,
	})
	corner(btn, 8)
	local bar = new("Frame", {
		AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.fromOffset(3, 0),
		BackgroundColor3 = TH.Accent2, BorderSizePixel = 0, Parent = btn,
	})
	corner(bar, 2)
	local lbl = new("TextLabel", {
		Position = UDim2.fromOffset(16, 0), Size = UDim2.new(1, -20, 1, 0), BackgroundTransparency = 1, Text = name,
		Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = TH.SubText, TextXAlignment = Enum.TextXAlignment.Left,
		Parent = btn,
	})
	local page = new("ScrollingFrame", {
		Name = name, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.55,
		BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = TH.Accent, CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false, Parent = Pages,
	})
	corner(page, 10)
	new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = page })
	new("UIPadding", { PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 13), Parent = page })
	local t = setmetatable({ Page = page, TabBtn = btn, Bar = bar, Lbl = lbl, Title = name, Desc = desc or "", Order = 0 }, Tab)
	tabs[#tabs + 1] = t
	btn.MouseEnter:Connect(function()
		if page.Visible then return end
		tween(btn, 0.15, { BackgroundTransparency = 0.93 })
	end)
	btn.MouseLeave:Connect(function()
		if page.Visible then return end
		tween(btn, 0.15, { BackgroundTransparency = 1 })
	end)
	btn.MouseButton1Click:Connect(function() selectTab(t) end)
	return t
end

--------------------------------------------------------------------
-- Window state / open-close / destroy
--------------------------------------------------------------------
local opened, animatedBg, blurOn = true, true, true
local scaleBase, token = 1, 0

local function setOpen(v)
	opened = v
	token += 1
	local my = token
	if v then
		Main.Visible = true
		tween(Scale, 0.35, { Scale = scaleBase }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		if blurOn then Blur.Enabled = true; tween(Blur, 0.35, { Size = 10 }) end
	else
		tween(Scale, 0.2, { Scale = 0.01 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		tween(Blur, 0.2, { Size = 0 })
		task.delay(0.22, function()
			if token == my then Main.Visible = false; Blur.Enabled = false end
		end)
	end
end

local destroyed = false
local function destroyAll()
	if destroyed then return end
	destroyed = true
	opened = false
	-- detener todas las funciones del script
	pcall(function() scriptAlive = false end)
	for _, n in ipairs({ "StopMethod1", "StopMethod2", "StopProxySystem", "StopCharacterReachSystem", "StopPlatformSystem",
		"StopFly", "StopTPWalk", "StopKickLoop", "StopDribble", "stopPrediction97mzu", "stopImpactDistance",
		"stopBallStats", "stopAnim" }) do
		local f = Touchline[n]
		if f then pcall(f) end
	end
	pcall(function() Touchline.StopWalkSpeedLoop(true) end)
	pcall(function() if LocalPlayer.Character then Touchline.ResetJumpPower(LocalPlayer.Character) end end)
	pcall(function() if _reactThread then task.cancel(_reactThread) end end)
	pcall(function() if _gkReactThread then task.cancel(_gkReactThread) end end)
	pcall(function() if DisconnectTrackedConnections then DisconnectTrackedConnections() end end)
	for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
	pcall(function() if getgenv then getgenv().__P3G_HUB_CLEANUP = nil end end)
	tween(Scale, 0.2, { Scale = 0.01 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	tween(Blur, 0.2, { Size = 0 })
	task.delay(0.25, function()
		pcall(function() Gui:Destroy() end)
		pcall(function() Blur:Destroy() end)
	end)
end

CloseBtn.MouseButton1Click:Connect(destroyAll)
MinBtn.MouseButton1Click:Connect(function() setOpen(false) end)
bind(UserInputService.InputBegan, function(input)
	if input.KeyCode == Enum.KeyCode.RightControl then setOpen(not opened) end
end)
-- if the script is re-executed, the logic calls this cleanup at startup
pcall(function() (getgenv and getgenv() or _G).__P3G_HUB_CLEANUP = destroyAll end)

-- Animaciones + footer (FPS / ping)
local frames, acc = 0, 0
bind(RunService.Heartbeat, function(dt)
	if not opened then return end
	local t = os.clock()

	frames += 1
	acc += dt
	if acc >= 0.5 then
		local fps = math.floor(frames / acc + 0.5)
		local ping = 0
		pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue() + 0.5) end)
		StatsLabel.Text = string.format("FPS %d   ·   PING %d ms   ·   RCtrl = toggle", fps, ping)
		frames, acc = 0, 0
	end

	LogoGrad.Rotation = (t * 120) % 360

	if not animatedBg then return end
	for _, p in ipairs(particles) do
		p.ang += p.w * dt
		local x, y = p.a * math.cos(p.ang), p.b * math.sin(p.ang)
		p.f.Position = UDim2.fromOffset(x * COS_T - y * SIN_T, x * SIN_T + y * COS_T)
		p.f.BackgroundTransparency = 0.08 + 0.6 * (0.5 - 0.5 * math.cos(p.ang))
	end
	PhotonGrad.Rotation = 200 + 14 * math.sin(t * 0.6)
	for _, l in ipairs(lens) do
		l.ang += l.w * dt
		local c, sn = math.cos(l.ang), math.sin(l.ang)
		l.f.Position = UDim2.fromOffset(l.r * c, l.r * sn * 0.94)
		local base = 0.1 + 0.55 * (0.5 - 0.5 * c)
		l.f.BackgroundTransparency = 1 - (1 - base) * (0.4 + 0.6 * math.abs(sn))
	end
	for _, g in ipairs(glows) do
		g.f.BackgroundTransparency = g.base + 0.025 * math.sin(t * 1.4 + g.i)
	end
	for _, s in ipairs(stars) do
		s.f.BackgroundTransparency = 0.25 + 0.6 * (0.5 + 0.5 * math.sin(t * s.sp + s.ph))
	end
end)

--------------------------------------------------------------------
-- TABS (same as the original script + Settings)
--------------------------------------------------------------------
local Home      = CreateTab("Home", "Info and credits")
local Reach     = CreateTab("Reach", "Ball and character reach")
local React     = CreateTab("React", "Reaction tuning (player and goalkeeper)")
local Character = CreateTab("Character", "Name changer, movement and utilities")
local GK        = CreateTab("GK", "Goalkeeper tools")
local Helpers   = CreateTab("Helpers", "Gameplay helpers")
local FFlag     = CreateTab("FFlag", "Performance and graphics flags")
local Settings  = CreateTab("Settings", "TON HUB interface")

-- HOME ---------------------------------------------------------------
Home:Section("TON HUB")
Home:Label("Made By prvmised, Xin0, q0x9.")
Home:Label("Last Update: 22/10/2026")
Home:Label("P3gOnTop!")

-- REACH --------------------------------------------------------------
local sw1, sw2
Reach:Section("Reach · No ball collision")
sw1 = Reach:Toggle({ Name = "Enable Reach No Ball Collision", Default = false, Callback = function(v)
	if v and sw2 and sw2:Get() then sw2:Set(false) end
	Touchline.m1_enabled = v
	if v then call("StartMethod1") else call("StopMethod1") end
end })
Reach:Slider({ Name = "Reach Size", Min = 1, Max = 30, Default = num(Touchline.m1_size, 6), Callback = function(v)
	Touchline.m1_size = v
	call("UpdateVisualizers", v, num(Touchline.m1_transparency, 0.7))
end })
Reach:Slider({ Name = "Visualizer Transparency", Min = 0, Max = 100, Default = pct(Touchline.m1_transparency, 0.7), Suffix = "%", Callback = function(v)
	Touchline.m1_transparency = v / 100
	call("UpdateVisualizers", num(Touchline.m1_size, 6), v / 100)
end })

Reach:Section("Collision proxy")
Reach:Toggle({ Name = "Enable Collision Proxy", Default = false, Callback = function(v)
	Touchline.proxyEnabled = v
	if v then call("StartProxySystem") else call("StopProxySystem") end
end })

Reach:Section("Reach · Ball collision")
sw2 = Reach:Toggle({ Name = "Enable Reach Ball Collision", Default = false, Callback = function(v)
	if v and sw1 and sw1:Get() then sw1:Set(false) end
	Touchline.reachMethod2Enabled = v
	if v then call("StartMethod2") else call("StopMethod2") end
end })
Reach:Slider({ Name = "Reach Size", Min = 1, Max = 30, Default = num(Touchline.REACH_SIZE, 10), Callback = function(v)
	Touchline.REACH_SIZE = v
	local g = getgenv and getgenv()
	if g and g.Reach then g.Reach.Size = v end
end })
Reach:Slider({ Name = "Visualizer Transparency", Min = 0, Max = 100, Default = pct(Touchline.reachTransparency2, 1), Suffix = "%", Callback = function(v)
	Touchline.reachTransparency2 = v / 100
	local g = getgenv and getgenv()
	if g and g.Reach then g.Reach.Transparency = v / 100 end
end })

Reach:Section("Character reach")
Reach:Toggle({ Name = "Character Reach", Default = false, Callback = function(v)
	Touchline.CharacterReachEnabled = v
	if v then call("StartCharacterReachSystem") else call("StopCharacterReachSystem") end
end })
Reach:Slider({ Name = "Char Reach Size", Min = 1, Max = 30, Default = num(Touchline.CharacterReachSize, 12), Callback = function(v)
	Touchline.CharacterReachSize = v
	call("RefreshCharacterReach")
end })
Reach:Slider({ Name = "Char Visualizer", Min = 0, Max = 100, Default = pct(Touchline.CharacterVisualizerIntensity, 0.5), Suffix = "%", Callback = function(v)
	Touchline.CharacterVisualizerIntensity = v / 100
	call("RefreshCharacterReach")
end })

-- REACT --------------------------------------------------------------
React:Section("React")
React:Toggle({ Name = "Enable React", Default = false, Callback = function(v)
	Touchline._reactActive = v
	if not v then
		local th = Touchline._reactThread
		if th then pcall(task.cancel, th); Touchline._reactThread = nil end
	else
		call("applyReact", Touchline._lastReactTT or "13", Touchline._lastReactInterp or "90")
	end
end })
React:Button({ Name = "React 15% (Safest)",     Callback = function() call("applyReact", "13", "90") end })
React:Button({ Name = "React 25% (Light)",      Callback = function() call("applyReact", "12", "85") end })
React:Button({ Name = "React 50% (Balanced)",   Callback = function() call("applyReact", "10", "75") end })
React:Button({ Name = "React 75% (Aggressive)", Callback = function() call("applyReact", "8", "67") end })
React:Button({ Name = "React 100% (Maximum)",   Callback = function() call("applyReact", "6", "70") end })

React:Section("GK React")
React:Toggle({ Name = "Enable GK React", Default = false, Callback = function(v)
	Touchline._gkReactActive = v
	if not v then
		local th = Touchline._gkReactThread
		if th then pcall(task.cancel, th); Touchline._gkReactThread = nil end
	else
		call("applyGkReact", Touchline._lastGkReactTT or "13", Touchline._lastGkReactInterp or "90")
	end
end })
React:Button({ Name = "GK React 15% (Safest)",     Callback = function() call("applyGkReact", "13", "90") end })
React:Button({ Name = "GK React 25% (Light)",      Callback = function() call("applyGkReact", "12", "85") end })
React:Button({ Name = "GK React 50% (Balanced)",   Callback = function() call("applyGkReact", "10", "75") end })
React:Button({ Name = "GK React 75% (Aggressive)", Callback = function() call("applyGkReact", "8", "67") end })
React:Button({ Name = "GK React 100% (Maximum)",   Callback = function() call("applyGkReact", "6", "70") end })

-- CHARACTER ----------------------------------------------------------
-- Name & Level changer (local/visual only: edits your own name tag text)
local customPlayerName, customPlayerLevel = "", ""

local function UpdateLocalPlayerNameTag()
	local characters = workspace:FindFirstChild("Characters")
	if not characters then return end
	local character = characters:FindFirstChild(LocalPlayer.Name)
	if not character then return end
	local head = character:FindFirstChild("Head")
	local user = head and head:FindFirstChild("User")
	local playerName = user and user:FindFirstChild("PlayerName")
	if not playerName or not playerName:IsA("TextLabel") then return end

	local oldText = playerName.Text
	local level = oldText:match("^%((.-)%)") or "900"
	local name = oldText:match("^%(%d+%)%s*(.*)$") or LocalPlayer.Name
	if customPlayerLevel ~= "" then level = customPlayerLevel end
	if customPlayerName ~= "" then name = customPlayerName end
	playerName.Text = "(" .. level .. ") " .. name
end

Character:Section("Name & Level Changer")
Character:Textbox({ Name = "Player Name", Placeholder = "Enter display name...", Callback = function(text)
	customPlayerName = text
	UpdateLocalPlayerNameTag()
end })
Character:Textbox({ Name = "Player Level", Placeholder = "Enter level...", Callback = function(text)
	if text == "" or tonumber(text) then
		customPlayerLevel = text
		UpdateLocalPlayerNameTag()
	end
end })
Character:Button({ Name = "Apply Name & Level", Callback = UpdateLocalPlayerNameTag })

Character:Section("Utilities")
Character:Textbox({ Name = "Avatar Stealer", Placeholder = "Enter username...", Callback = function(text, enter)
	if enter and text ~= "" then call("StealAvatarByName", text) end
end })
Character:Button({ Name = "Fullbright", Callback = function()
	pcall(function() loadstring(game:HttpGet("https://pastebin.com/raw/5ic4YxBU", true))() end)
end })
Character:Button({ Name = "Infinite Yield", Callback = function()
	pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))() end)
end })

Character:Section("WalkSpeed / Jump")
Character:Toggle({ Name = "WalkSpeed Enabled", Default = false, Callback = function(v)
	Touchline.WalkSpeedEnabled = v
	if v then call("StartWalkSpeedLoop") else call("StopWalkSpeedLoop", true) end
end })
Character:Slider({ Name = "WalkSpeed", Min = 16, Max = 50, Default = num(Touchline.WalkSpeedValue, 26), Callback = function(v)
	Touchline.WalkSpeedValue = v
	if LocalPlayer.Character then call("ApplyWalkSpeed", LocalPlayer.Character) end
end })
Character:Toggle({ Name = "Jump Power Enabled", Default = false, Callback = function(v)
	Touchline.JumpPowerEnabled = v
	if not v and LocalPlayer.Character then call("ResetJumpPower", LocalPlayer.Character) end
end })
Character:Slider({ Name = "Jump Power", Min = 50, Max = 200, Default = num(Touchline.JumpPowerValue, 50), Callback = function(v)
	Touchline.JumpPowerValue = v
	if Touchline.JumpPowerEnabled and LocalPlayer.Character then
		local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum.JumpPower = v end
	end
end })

Character:Section("Movement")
Character:Toggle({ Name = "Enable Fly", Default = false, Callback = function(v)
	Touchline.flyEnabled = v
	if v then call("StartFly") else call("StopFly") end
end })
Character:Slider({ Name = "Fly Speed", Min = 10, Max = 120, Default = num(Touchline.flySpeed, 40), Callback = function(v) Touchline.flySpeed = v end })
Character:Toggle({ Name = "Enable TP Walk", Default = false, Callback = function(v)
	Touchline.tpEnabled = v
	if v then call("StartTPWalk") else call("StopTPWalk") end
end })
Character:Slider({ Name = "TP Speed", Min = 1, Max = 12, Default = num(Touchline.tpSpeed, 3), Callback = function(v) Touchline.tpSpeed = v end })

-- GK -------------------------------------------------------------------
GK:Section("Auto dive")
GK:Toggle({ Name = "Enable Auto Dive", Default = false, Callback = function(v)
	Touchline.gkAutoDiveEnabled = v
	if not v then call("stopAnim") end
end })
GK:Slider({ Name = "Dive Range", Min = 10, Max = 60, Default = num(Touchline.DIVE_RANGE, 40), Callback = function(v) Touchline.DIVE_RANGE = v end })
GK:Slider({ Name = "Dive Speed", Min = 20, Max = 100, Default = num(Touchline.DIVE_SPEED, 45), Callback = function(v) Touchline.DIVE_SPEED = v end })
GK:Slider({ Name = "Dive Lift", Min = 5, Max = 50, Default = num(Touchline.DIVE_LIFT, 28), Callback = function(v) Touchline.DIVE_LIFT = v end })
GK:Slider({ Name = "Cooldown", Min = 0, Max = 3, Increment = 0.05, Default = num(Touchline.COOLDOWN, 0.2), Suffix = "s", Callback = function(v) Touchline.COOLDOWN = v end })
GK:Slider({ Name = "Hit Radius", Min = 2, Max = 15, Default = num(Touchline.HIT_RADIUS, 6), Callback = function(v) Touchline.HIT_RADIUS = v end })

GK:Section("Visuals")
GK:Toggle({ Name = "Ball Prediction", Default = false, Callback = function(v)
	if v then call("startPrediction97mzu") else call("stopPrediction97mzu") end
end })
GK:Toggle({ Name = "Impact Distance", Default = false, Callback = function(v)
	if v then call("startImpactDistance") else call("stopImpactDistance") end
end })
GK:Toggle({ Name = "Ball Stats", Default = false, Callback = function(v)
	if v then call("startBallStats") else call("stopBallStats") end
end })

-- HELPERS ------------------------------------------------------------
Helpers:Section("Kick")
Helpers:Toggle({ Name = "Enable Kick Loop", Default = false, Callback = function(v)
	Touchline.kickLoopEnabled = v
	if v then call("StartKickLoop") else call("StopKickLoop") end
end })
Helpers:Slider({ Name = "Kick Reach", Min = 5, Max = 50, Default = num(Touchline.kickReach, 20), Callback = function(v) Touchline.kickReach = v end })

Helpers:Section("Dribble")
Helpers:Toggle({ Name = "Enable INF Dribble", Default = false, Callback = function(v)
	Touchline.dribbleEnabled = v
	if v then call("StartDribble") else call("StopDribble") end
end })
Helpers:Slider({ Name = "Dribble Speed", Min = 8, Max = 35, Default = num(Touchline.dribbleSpeed, 26), Callback = function(v) Touchline.dribbleSpeed = v end })

Helpers:Section("Air helper")
Helpers:Toggle({ Name = "Enable Air Helper", Default = false, Callback = function(v)
	Touchline.PlatformEnabled = v
	if v then call("StartPlatformSystem") else call("StopPlatformSystem") end
end })
Helpers:Slider({ Name = "Platform Size", Min = 3, Max = 30, Default = num(Touchline.PlatformSize, 15), Callback = function(v)
	Touchline.PlatformSize = v
	call("UpdatePlatformSize")
end })
Helpers:Slider({ Name = "Smoothness", Min = 0, Max = 100, Default = pct(Touchline.Smoothness, 0.95), Suffix = "%", Callback = function(v)
	Touchline.Smoothness = v / 100
end })
Helpers:Toggle({ Name = "Show Platform", Default = false, Callback = function(v)
	Touchline.ShowPlatform = v
	call("UpdatePlatformVisibility")
end })
Helpers:Slider({ Name = "Platform Visualizer", Min = 0, Max = 100, Default = pct(Touchline.PlatformTransparency, 0.7), Suffix = "%", Callback = function(v)
	Touchline.PlatformTransparency = v / 100
	call("UpdatePlatformVisibility")
end })

-- FFLAG ----------------------------------------------------------------
local function sf(k, v) if Touchline.sf then pcall(Touchline.sf, k, v) end end
FFlag:Section("Presets")
FFlag:Button({ Name = "Ping Reducer", Callback = function() call("pingReducer") end })
FFlag:Button({ Name = "FFlagDarkAbyss", Callback = function() call("darkAbyss") end })
FFlag:Toggle({ Name = "FFlagOverrideTexture", Default = false, Callback = function(v) call("overrideTexture", v) end })
FFlag:Toggle({ Name = "Disable Player Shadows", Default = false, Callback = function(v) call("disablePlayerShadows", v) end })
FFlag:Toggle({ Name = "Disable Post-FX", Default = false, Callback = function(v) call("disablePostFX", v) end })

FFlag:Section("Skies")
FFlag:Button({ Name = "Aurora Sky", Callback = function() call("auroraSky") end })
FFlag:Button({ Name = "Full Night Sky", Callback = function() call("fullNightSky") end })
FFlag:Button({ Name = "Sakura Pink Sky", Callback = function() call("sakuraPinkSky") end })

FFlag:Section("Manual values")
FFlag:Textbox({ Name = "Target Time Delay (TT)", Placeholder = "13", Callback = function(v)
	if v ~= "" then sf("DFIntTargetTimeDelayFacctorTenths", v) end
end })
FFlag:Textbox({ Name = "Interpolation Max Delay", Placeholder = "90", Callback = function(v)
	if v ~= "" then sf("FIntInterpolationMaxDelayMSec", v) end
end })
FFlag:Textbox({ Name = "Physics Sender Rate", Placeholder = "60", Callback = function(v)
	if v ~= "" then sf("DFIntS2PhysicsSenderRate", v) end
end })
FFlag:Textbox({ Name = "Target FPS", Placeholder = "9999", Callback = function(v)
	if v ~= "" then
		sf("DFIntTaskSchedulerTargetFps", v)
		if setfpscap then pcall(setfpscap, tonumber(v) or 60) end
	end
end })

FFlag:Section("Actions")
FFlag:Button({ Name = "Apply All Flags", Callback = function()
	sf("DFIntTargetTimeDelayFacctorTenths", "12")
	sf("FIntInterpolationMaxDelayMSec", "8")
	sf("DFIntS2PhysicsSenderRate", "90")
	sf("DFIntTaskSchedulerTargetFps", "9999")
	sf("FFlagTaskSchedulerLimitTargetFpsTo2402", "true")
	sf("FFlagDisablePostFx", "false")
end })
FFlag:Button({ Name = "Reset Flags", Callback = function()
	sf("DFIntTargetTimeDelayFacctorTenths", "13")
	sf("FIntInterpolationMaxDelayMSec", "90")
	sf("DFIntS2PhysicsSenderRate", "60")
	sf("DFIntTaskSchedulerTargetFps", "60")
	sf("FFlagTaskSchedulerLimitTargetFpsTo2402", "false")
	sf("FFlagDisablePostFx", "false")
end })

-- SETTINGS ---------------------------------------------------------------
Settings:Section("Interface")
Settings:Toggle({ Name = "Animated background (TON 618)", Default = true, Callback = function(v)
	animatedBg = v
	Space.Visible = v
end })
Settings:Toggle({ Name = "Background blur", Default = true, Callback = function(v)
	blurOn = v
	if opened then
		Blur.Enabled = v
		tween(Blur, 0.25, { Size = v and 10 or 0 })
	end
end })
Settings:Slider({ Name = "UI scale", Min = 70, Max = 120, Default = 100, Increment = 5, Suffix = "%", Callback = function(v)
	scaleBase = v / 100
	if opened then tween(Scale, 0.15, { Scale = scaleBase }) end
end })
Settings:Section("Script")
Settings:Button({ Name = "Stop everything and destroy TON HUB", Callback = destroyAll })

--------------------------------------------------------------------
-- Inicio
--------------------------------------------------------------------
selectTab(Home)
Main.Visible = true
if blurOn then Blur.Enabled = true; tween(Blur, 0.35, { Size = 10 }) end
tween(Scale, 0.4, { Scale = scaleBase }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end
