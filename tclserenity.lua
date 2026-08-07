local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

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
local BACKGROUND = Color3.fromRGB(15, 10, 25)
local BACKGROUND_SOFT = Color3.fromRGB(12, 8, 22)
local CONTROL_OFF = Color3.fromRGB(50, 50, 70)
local TEXT_MUTED = Color3.fromRGB(200, 190, 210)

local ReachEnabled = false
local BallReachSize = 6.0
local Transparency = 0.5
local ProxyEnabled = true

local CharacterReachEnabled = false
local CharacterReachSize = 12.0
local CharacterVisualizerIntensity = 0.5

local PlatformEnabled = false
local PlatformSize = 15
local Smoothness = 0.95
local ShowPlatform = false
local PlatformTransparency = 0.7

local WalkSpeedValue = 22
local WalkSpeedEnabled = false
local DefaultWalkSpeed = 16

local JumpPowerEnabled = false
local JumpPowerValue = 50
local DefaultJumpPower = 50

local ReactSettings = {
    MossReact = false,
    LegReact = false,
    BallReact = false,
    DribbleReact = false,
    React15 = false,
    React25 = false,
    React50 = false,
    React75 = false,
    React100 = false,
    BallMagnet = false,
    NoBallDelay = false,
    AlzReact = false,
    FoxtedeReact = false
}

local FFlagValues = {
    ["DFIntTargetTimeDelayFactorTenths"] = "100",
    ["FIntInterpolationMaxDelayMSec"] = "1000",
    ["DFIntS2PhysicsSenderRate"] = "0"
}

local platforms = {}
local platformRunning = false
local platformConnection = nil

local reachOriginalProperties = {}

local characterReachPart = nil
local characterReachWeld = nil
local characterReachOutline = nil

local ballParts = {}
local ballAirStates = {}
local ballProxies = {}
local ballVisualizers = {}

local AIR_CHECK_INTERVAL = 0.18
local INITIAL_SCAN_BATCH = 450

local walkSpeedConnection = nil
local currentHumanoid = nil
local changingWalkSpeed = false
local isCharacterRespawning = false

local activeSliderInput = nil
local activeSliderUpdate = nil

local uiVisible = true
local ShowNotification
local reachLoopConnection = nil

local REJECTED_BALL_NAME_HINTS = {
    "field", "court", "goal", "spawn", "spawner", "stadium",
    "folder", "container", "holder", "storage", "stand", "platform"
}

local function IsBallName(name)
    local lowered = string.lower(name or "")
    if lowered == "ball" or lowered == "football" or lowered == "soccerball"
        or lowered == "soccer ball" or lowered == "bola" then
        return true
    end

    local containsBallTerm = string.find(lowered, "ball", 1, true) ~= nil
        or string.find(lowered, "football", 1, true) ~= nil
        or string.find(lowered, "soccer", 1, true) ~= nil
    if not containsBallTerm then return false end

    for _, hint in ipairs(REJECTED_BALL_NAME_HINTS) do
        if string.find(lowered, hint, 1, true) then
            return false
        end
    end

    return true
end

local function IsReasonableBallPart(part)
    local size = part.Size
    local largest = math.max(size.X, size.Y, size.Z)
    local smallest = math.min(size.X, size.Y, size.Z)

    if smallest <= 0.02 or largest > 20 then return false end
    if largest / smallest > 6 then return false end
    return true
end

local function ResolveBallPart(instance)
    if not instance then return nil end

    if instance:IsA("BasePart") then
        return instance
    end

    if instance:IsA("Model") then
        return instance.PrimaryPart or instance:FindFirstChildWhichIsA("BasePart")
    end

    return nil
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
        RegisterBallPart(ResolveBallPart(instance))
    end

    if instance:IsA("BasePart") then
        local ancestor = instance.Parent
        while ancestor and ancestor ~= workspace do
            if ancestor:IsA("Model") and IsBallName(ancestor.Name) then
                RegisterBallPart(ResolveBallPart(ancestor) or instance)
                break
            end
            ancestor = ancestor.Parent
        end
    end
end

local function RemoveCachedBallPart(part)
    ballParts[part] = nil
    ballAirStates[part] = nil
    reachOriginalProperties[part] = nil
    if ballProxies[part] then
        ballProxies[part]:Destroy()
        ballProxies[part] = nil
    end
    if ballVisualizers[part] then
        ballVisualizers[part]:Destroy()
        ballVisualizers[part] = nil
    end

    local data = platforms[part]
    if data then
        if data.part then
            data.part:Destroy()
        end
        platforms[part] = nil
    end
end

TrackConnection(workspace.DescendantAdded:Connect(RegisterBallCandidate))
TrackConnection(workspace.DescendantRemoving:Connect(function(instance)
    if instance:IsA("BasePart") then
        RemoveCachedBallPart(instance)
    end
end))

task.spawn(function()
    local descendants = workspace:GetDescendants()
    for index, instance in ipairs(descendants) do
        if not scriptAlive then return end
        RegisterBallCandidate(instance)

        if index % INITIAL_SCAN_BATCH == 0 then
            task.wait()
        end
    end
end)

local function GetBallOriginalSize(ball)
    if not reachOriginalProperties[ball] then
        reachOriginalProperties[ball] = {
            Size = ball.Size,
            Transparency = ball.Transparency,
            CanCollide = ball.CanCollide
        }
    end
    return reachOriginalProperties[ball].Size
end

local function CreateCollisionProxy(ball)
    if not ProxyEnabled then
        if ballProxies[ball] then
            ballProxies[ball]:Destroy()
            ballProxies[ball] = nil
        end
        return nil
    end
    
    if ballProxies[ball] and ballProxies[ball].Parent then
        return ballProxies[ball]
    end
    
    local originalSize = GetBallOriginalSize(ball)
    
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

local function RemoveCollisionProxy(ball)
    if ballProxies[ball] then
        ballProxies[ball]:Destroy()
        ballProxies[ball] = nil
    end
end

local function CreateVisualizer(ball)
    if ballVisualizers[ball] and ballVisualizers[ball].Parent then
        return ballVisualizers[ball]
    end
    
    local visualizer = Instance.new("Part")
    visualizer.Name = "__BallVisualizer"
    visualizer.Size = Vector3.new(BallReachSize, BallReachSize, BallReachSize)
    visualizer.CFrame = ball.CFrame
    visualizer.Anchored = true
    visualizer.CanCollide = false
    visualizer.CanTouch = false
    visualizer.CanQuery = false
    visualizer.CastShadow = false
    visualizer.Transparency = Transparency
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

local function RemoveVisualizer(ball)
    if ballVisualizers[ball] then
        ballVisualizers[ball]:Destroy()
        ballVisualizers[ball] = nil
    end
end

local function ApplyReachToBall(ball)
    if not ball or not ball.Parent or not ball:IsA("BasePart") then return end
    
    if not reachOriginalProperties[ball] then
        reachOriginalProperties[ball] = {
            Size = ball.Size,
            Transparency = ball.Transparency,
            CanCollide = ball.CanCollide
        }
    end
    
    local targetSize = Vector3.new(BallReachSize, BallReachSize, BallReachSize)
    if ball.Size ~= targetSize then
        ball.Size = targetSize
    end
    if ball.Transparency ~= 1 then
        ball.Transparency = 1
    end
    if ball.CanCollide ~= false then
        ball.CanCollide = false
    end
    
    if ProxyEnabled then
        if not ballProxies[ball] or not ballProxies[ball].Parent then
            CreateCollisionProxy(ball)
        end
    else
        RemoveCollisionProxy(ball)
    end
    
    if not ballVisualizers[ball] or not ballVisualizers[ball].Parent then
        CreateVisualizer(ball)
    end
end

local function RestoreBall(ball)
    if reachOriginalProperties[ball] then
        local props = reachOriginalProperties[ball]
        pcall(function()
            if ball.Size ~= props.Size then
                ball.Size = props.Size
            end
            if ball.Transparency ~= props.Transparency then
                ball.Transparency = props.Transparency
            end
            if ball.CanCollide ~= props.CanCollide then
                ball.CanCollide = props.CanCollide
            end
        end)
        reachOriginalProperties[ball] = nil
    end
    RemoveCollisionProxy(ball)
    RemoveVisualizer(ball)
end

local function RefreshReach()
    for ball in pairs(ballParts) do
        if ball and ball.Parent then
            if ReachEnabled then
                ApplyReachToBall(ball)
            else
                RestoreBall(ball)
            end
        else
            RemoveCachedBallPart(ball)
        end
    end
end

local function StartReachSystem()
    if reachLoopConnection then
        reachLoopConnection:Disconnect()
        reachLoopConnection = nil
    end
    
    if not ReachEnabled then return end

    RefreshReach()
    
    reachLoopConnection = RunService.Stepped:Connect(function()
        if not scriptAlive or not ReachEnabled then
            return
        end
        
        for ball, proxy in pairs(ballProxies) do
            if ball and ball.Parent and proxy and proxy.Parent then
                proxy.CFrame = ball.CFrame
            else
                if proxy then proxy:Destroy() end
                ballProxies[ball] = nil
            end
        end
        
        for ball, visualizer in pairs(ballVisualizers) do
            if ball and ball.Parent and visualizer and visualizer.Parent then
                visualizer.CFrame = ball.CFrame
                local targetSize = Vector3.new(BallReachSize, BallReachSize, BallReachSize)
                if visualizer.Size ~= targetSize then
                    visualizer.Size = targetSize
                end
                if visualizer.Transparency ~= Transparency then
                    visualizer.Transparency = Transparency
                end
            else
                if visualizer then visualizer:Destroy() end
                ballVisualizers[ball] = nil
            end
        end
    end)
end

local function StopReachSystem()
    if reachLoopConnection then
        reachLoopConnection:Disconnect()
        reachLoopConnection = nil
    end
    
    for ball in pairs(ballProxies) do
        RestoreBall(ball)
    end
    for ball in pairs(ballVisualizers) do
        RemoveVisualizer(ball)
    end
    for ball, props in pairs(reachOriginalProperties) do
        if ball and ball.Parent then
            RestoreBall(ball)
        end
        reachOriginalProperties[ball] = nil
    end
    table.clear(ballProxies)
    table.clear(ballVisualizers)
end

local function DetectExecutor()
    local executor = "Unknown"
    
    if syn and syn.request then
        executor = "Synapse X"
    elseif krnl and krnl.request then
        executor = "Krnl"
    elseif getexecutorname then
        local name = getexecutorname()
        if name then executor = name end
    elseif identifyexecutor then
        local success, result = pcall(identifyexecutor)
        if success and result then executor = result end
    elseif game:GetService("RunService"):IsStudio() then
        executor = "Roblox Studio"
    end
    
    if not executor or executor == "Unknown" then
        if _G["Script"] then
            executor = "Script"
        elseif getgenv and getgenv().Executor then
            executor = getgenv().Executor
        end
    end
    
    return executor
end

local function ApplyFFlags()
    local setter = setfflag or setflag or set_fflag
    if type(setter) ~= "function" then
        return false
    end

    local ok = pcall(function()
        for flag, value in pairs(FFlagValues) do
            setter(flag, value)
        end
    end)

    return ok
end

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
    if walkSpeedConnection then
        walkSpeedConnection:Disconnect()
        walkSpeedConnection = nil
    end

    local humanoid = currentHumanoid
        or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid"))

    if restoreDefault and humanoid then
        SetWalkSpeedSafely(humanoid, DefaultWalkSpeed)
    end

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
        pcall(function()
            humanoid.JumpHeight = JumpPowerValue / 7
        end)
    end
end

local function ResetJumpPower(character)
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.JumpPower = DefaultJumpPower
        pcall(function()
            humanoid.JumpHeight = DefaultJumpPower / 7
        end)
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

    if WalkSpeedEnabled then
        StartWalkSpeedLoop()
    end
    
    if JumpPowerEnabled then
        ApplyJumpPower(character)
    end
end

TrackConnection(LocalPlayer.CharacterAdded:Connect(OnCharacterAdded))

if LocalPlayer.Character then
    task.spawn(OnCharacterAdded, LocalPlayer.Character)
end

local function createPlatform(ballPart)
    local existing = platforms[ballPart]
    if existing and existing.part and existing.part.Parent then
        return existing
    end

    local targetPosition = ballPart.Position - Vector3.new(0, 2, 0)
    local platform = Instance.new("Part")
    platform.Name = "SerenityAirPlatform"
    platform.Size = Vector3.new(PlatformSize, 0.2, PlatformSize)
    platform.Position = targetPosition
    platform.Anchored = true
    platform.CanCollide = true
    platform.CanTouch = false
    platform.CanQuery = false
    platform.CastShadow = false
    platform.Color = PURPLE
    platform.Material = Enum.Material.SmoothPlastic
    platform.Transparency = ShowPlatform and PlatformTransparency or 1
    platform.Parent = workspace

    local data = {
        part = platform,
        lastPosition = targetPosition,
        lastCanCollide = true
    }
    platforms[ballPart] = data
    return data
end

local function removePlatform(ballPart)
    local data = platforms[ballPart]
    if not data then return end

    if data.part then
        data.part:Destroy()
    end
    platforms[ballPart] = nil
end

local function ClearAllPlatforms()
    for ballPart, data in pairs(platforms) do
        if data and data.part then
            data.part:Destroy()
        end
        platforms[ballPart] = nil
    end
end

local function UpdatePlatformSize()
    local targetSize = Vector3.new(PlatformSize, 0.2, PlatformSize)
    for _, data in pairs(platforms) do
        local part = data and data.part
        if part and part.Parent and part.Size ~= targetSize then
            part.Size = targetSize
        end
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

local function UpdatePlatformTransparency()
    UpdatePlatformVisibility()
end

local function IsBallAirborne(ballPart, platformPart, character)
    local now = os.clock()
    local state = ballAirStates[ballPart]

    if not state then
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.IgnoreWater = true

        state = {
            lastCheck = -math.huge,
            inAir = false,
            params = params,
            filter = {}
        }
        ballAirStates[ballPart] = state
    elseif now - state.lastCheck < AIR_CHECK_INTERVAL then
        return state.inAir
    end

    local filter = state.filter
    table.clear(filter)

    local ballModel = ballPart:FindFirstAncestorOfClass("Model")
    if ballModel and IsBallName(ballModel.Name) then
        table.insert(filter, ballModel)
    else
        table.insert(filter, ballPart)
    end
    if character then table.insert(filter, character) end
    if platformPart then table.insert(filter, platformPart) end

    local original = reachOriginalProperties[ballPart]
    local originalHeight = original and original.Size.Y or ballPart.Size.Y
    local rayDistance = math.max(3.25, originalHeight * 0.5 + 2.25)

    state.params.FilterDescendantsInstances = filter

    local result = workspace:Raycast(
        ballPart.Position,
        Vector3.new(0, -rayDistance, 0),
        state.params
    )

    state.lastCheck = now
    state.inAir = result == nil
    return state.inAir
end

local function UpdatePlatformSystem(deltaTime)
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local smoothness = math.clamp(Smoothness, 0.1, 1)

    local alpha
    if smoothness >= 0.999 then
        alpha = 1
    else
        local response = 8 + (smoothness * 92)
        alpha = 1 - math.exp(-response * math.min(deltaTime, 1 / 15))
    end

    for ballPart in pairs(ballParts) do
        if not ballPart.Parent then
            RemoveCachedBallPart(ballPart)
        else
            local existingData = platforms[ballPart]
            local existingPlatform = existingData and existingData.part
            local inAir = IsBallAirborne(ballPart, existingPlatform, character)

            if inAir then
                local data = createPlatform(ballPart)
                local platform = data.part
                local targetPosition = ballPart.Position - Vector3.new(0, 2, 0)
                local newPosition

                if alpha >= 0.999 then
                    newPosition = targetPosition
                else
                    newPosition = data.lastPosition:Lerp(targetPosition, alpha)
                end

                if (platform.Position - newPosition).Magnitude > 0.0001 then
                    platform.Position = newPosition
                end
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

    for ballPart in pairs(platforms) do
        if not ballParts[ballPart] or not ballPart.Parent then
            removePlatform(ballPart)
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

    if platformConnection then
        platformConnection:Disconnect()
        platformConnection = nil
    end

    ClearAllPlatforms()
end

local function CharacterIntensityToTransparency(intensity)
    return math.clamp(0.95 - (math.clamp(intensity, 0.1, 1) * 0.65), 0.3, 0.9)
end

local function CharacterIntensityToOutlineTransparency(intensity)
    return math.clamp(0.78 - (math.clamp(intensity, 0.1, 1) * 0.68), 0.1, 0.72)
end

local function DestroyCharacterReach()
    if characterReachWeld then
        characterReachWeld:Destroy()
        characterReachWeld = nil
    end

    if characterReachOutline then
        characterReachOutline:Destroy()
        characterReachOutline = nil
    end

    if characterReachPart then
        characterReachPart:Destroy()
        characterReachPart = nil
    end
end

local function RefreshCharacterReach(character)
    if not CharacterReachEnabled then
        DestroyCharacterReach()
        return
    end

    character = character or LocalPlayer.Character
    if not character or not character.Parent then return end

    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if characterReachPart and characterReachPart.Parent ~= character then
        DestroyCharacterReach()
    end

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
    if characterReachPart.Size ~= targetSize then
        characterReachPart.Size = targetSize
    end

    if characterReachPart.Color ~= PURPLE then
        characterReachPart.Color = PURPLE
    end

    local targetTransparency = CharacterIntensityToTransparency(CharacterVisualizerIntensity)
    if characterReachPart.Transparency ~= targetTransparency then
        characterReachPart.Transparency = targetTransparency
    end

    if characterReachOutline then
        local targetOutlineTransparency = CharacterIntensityToOutlineTransparency(CharacterVisualizerIntensity)

        if characterReachOutline.OutlineColor ~= PURPLE then
            characterReachOutline.OutlineColor = PURPLE
        end
        if characterReachOutline.OutlineTransparency ~= targetOutlineTransparency then
            characterReachOutline.OutlineTransparency = targetOutlineTransparency
        end
    end
end

local function StartCharacterReachSystem()
    if not CharacterReachEnabled then return end

    local character = LocalPlayer.Character
    if not character then return end

    task.spawn(function()
        local root = character:FindFirstChild("HumanoidRootPart")
            or character:WaitForChild("HumanoidRootPart", 10)

        if root and scriptAlive and CharacterReachEnabled
            and character == LocalPlayer.Character then
            RefreshCharacterReach(character)
        end
    end)
end

local function StopCharacterReachSystem()
    DestroyCharacterReach()
end

TrackConnection(LocalPlayer.CharacterAdded:Connect(function()
    if CharacterReachEnabled then
        task.defer(function()
            if scriptAlive and CharacterReachEnabled then
                StartCharacterReachSystem()
            end
        end)
    end
end))

local ModernV2 = loadstring(game:HttpGet("https://robloxui.vercel.app/"))()

local Window = ModernV2:Window({
    Title = "Serenity HUB",
    Content = "Touchline",
    Color = PURPLE,
    Size = UDim2.fromOffset(500, 350),
    ShowUser = true,
    Search = true,
    Config = { ConfigFolder = "SerenityHubConfigs", AutoSave = false },
})

local Watermark = Window:Watermark({
    Name = "Serenity HUB",
    Enabled = true,
    Desc = "{NAME} | {TIME} | {FPS} FPS",
})

local HomeTab = Window:AddTab({ Name = "Home", Icon = "box", Type = "Double" })

local HomeSection = HomeTab:AddSection({ Name = "SERENITY HUB", Position = "Center" })

HomeSection:AddButton({ 
    Name = "Made By 0m3", 
    Callback = function() end 
})

HomeSection:AddButton({ 
    Name = "Last UPD: 7/8/2026", 
    Callback = function() end 
})

HomeSection:AddButton({ 
    Name = "SerenityOnTop!", 
    Callback = function() end 
})

local ReachTab = Window:AddTab({ Name = "Reach", Icon = "crosshairs", Type = "Double" })

local BallReachSection = ReachTab:AddSection({ Name = "BALL REACH", Position = "Center" })

BallReachSection:AddToggle({ 
    Name = "Ball Reach Enabled", 
    Default = ReachEnabled, 
    Flag = "ballreach", 
    Callback = function(v)
        ReachEnabled = v
        if v then
            StartReachSystem()
        else
            StopReachSystem()
        end
    end 
})

BallReachSection:AddSlider({ 
    Name = "Ball Reach Size", 
    Default = BallReachSize, 
    Min = 1, 
    Max = 30, 
    Flag = "ballreach_size", 
    Callback = function(v)
        BallReachSize = v
        if ReachEnabled then
            for ball in pairs(ballVisualizers) do
                if ball and ball.Parent then
                    local visualizer = ballVisualizers[ball]
                    if visualizer and visualizer.Parent then
                        local targetSize = Vector3.new(BallReachSize, BallReachSize, BallReachSize)
                        if visualizer.Size ~= targetSize then
                            visualizer.Size = targetSize
                        end
                    end
                end
            end
        end
    end 
})

BallReachSection:AddSlider({ 
    Name = "Ball Visualizer", 
    Default = Transparency * 100, 
    Min = 0, 
    Max = 100, 
    Flag = "ballreach_vis", 
    Callback = function(v)
        Transparency = v / 100
        if ReachEnabled then
            for ball, visualizer in pairs(ballVisualizers) do
                if ball and ball.Parent and visualizer and visualizer.Parent then
                    if visualizer.Transparency ~= Transparency then
                        visualizer.Transparency = Transparency
                    end
                end
            end
        end
    end 
})

BallReachSection:AddToggle({ 
    Name = "Ball Collision", 
    Default = ProxyEnabled, 
    Flag = "ball_collision", 
    Callback = function(v)
        ProxyEnabled = v
        if ReachEnabled then
            for ball in pairs(ballParts) do
                if ball and ball.Parent then
                    if ProxyEnabled then
                        CreateCollisionProxy(ball)
                    else
                        RemoveCollisionProxy(ball)
                    end
                end
            end
        end
    end 
})

local CharacterReachSection = ReachTab:AddSection({ Name = "CHARACTER REACH", Position = "Center" })

CharacterReachSection:AddToggle({ 
    Name = "Character Reach", 
    Default = CharacterReachEnabled, 
    Flag = "charreach", 
    Callback = function(v)
        CharacterReachEnabled = v
        if v then
            StartCharacterReachSystem()
        else
            StopCharacterReachSystem()
        end
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

local ReactTab = Window:AddTab({ Name = "React", Icon = "compass", Type = "Double" })

local ReactSection = ReactTab:AddSection({ Name = "REACT SETTINGS", Position = "Center" })

ReactSection:AddToggle({ 
    Name = "Moss React", 
    Default = ReactSettings.MossReact, 
    Flag = "mossreact", 
    Callback = function(v)
        ReactSettings.MossReact = v
    end 
})

ReactSection:AddToggle({ 
    Name = "Leg React", 
    Default = ReactSettings.LegReact, 
    Flag = "legreact", 
    Callback = function(v)
        ReactSettings.LegReact = v
    end 
})

ReactSection:AddToggle({ 
    Name = "Ball React", 
    Default = ReactSettings.BallReact, 
    Flag = "ballreact", 
    Callback = function(v)
        ReactSettings.BallReact = v
    end 
})

ReactSection:AddToggle({ 
    Name = "Dribble React", 
    Default = ReactSettings.DribbleReact, 
    Flag = "dribblereact", 
    Callback = function(v)
        ReactSettings.DribbleReact = v
    end 
})

ReactSection:AddToggle({ 
    Name = "15% React", 
    Default = ReactSettings.React15, 
    Flag = "react15", 
    Callback = function(v)
        ReactSettings.React15 = v
    end 
})

ReactSection:AddToggle({ 
    Name = "25% React", 
    Default = ReactSettings.React25, 
    Flag = "react25", 
    Callback = function(v)
        ReactSettings.React25 = v
    end 
})

ReactSection:AddToggle({ 
    Name = "50% React", 
    Default = ReactSettings.React50, 
    Flag = "react50", 
    Callback = function(v)
        ReactSettings.React50 = v
    end 
})

ReactSection:AddToggle({ 
    Name = "75% React", 
    Default = ReactSettings.React75, 
    Flag = "react75", 
    Callback = function(v)
        ReactSettings.React75 = v
    end 
})

ReactSection:AddToggle({ 
    Name = "100% React", 
    Default = ReactSettings.React100, 
    Flag = "react100", 
    Callback = function(v)
        ReactSettings.React100 = v
    end 
})

local CharacterTab = Window:AddTab({ Name = "Character", Icon = "user", Type = "Double" })

local AvatarSection = CharacterTab:AddSection({ Name = "CHARACTER SCRIPTS", Position = "Center" })

AvatarSection:AddButton({ 
    Name = "Korblox & Headless", 
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/VortexDEV-CVM/scripts/refs/heads/main/Headless%20and%20Korblox.lua"))()
    end 
})

local MovementSection = CharacterTab:AddSection({ Name = "MOVEMENT", Position = "Center" })

MovementSection:AddToggle({ 
    Name = "WalkSpeed Enabled", 
    Default = WalkSpeedEnabled, 
    Flag = "walkspeed", 
    Callback = function(v)
        WalkSpeedEnabled = v
        if v then
            StartWalkSpeedLoop()
        else
            StopWalkSpeedLoop(true)
        end
    end 
})

MovementSection:AddSlider({ 
    Name = "WalkSpeed", 
    Default = WalkSpeedValue, 
    Min = 0, 
    Max = 31, 
    Flag = "walkspeed_value", 
    Callback = function(v)
        WalkSpeedValue = v
        if WalkSpeedEnabled then
            ApplyWalkSpeed(LocalPlayer.Character)
        end
    end 
})

MovementSection:AddToggle({ 
    Name = "Jump Power Enabled", 
    Default = JumpPowerEnabled, 
    Flag = "jumppower", 
    Callback = function(v)
        JumpPowerEnabled = v
        if v then
            ApplyJumpPower(LocalPlayer.Character)
        else
            ResetJumpPower(LocalPlayer.Character)
        end
    end 
})

MovementSection:AddSlider({ 
    Name = "Jump Power", 
    Default = JumpPowerValue, 
    Min = 0, 
    Max = 1000, 
    Flag = "jumppower_value", 
    Callback = function(v)
        JumpPowerValue = v
        if JumpPowerEnabled then
            ApplyJumpPower(LocalPlayer.Character)
        end
    end 
})

local HelpersTab = Window:AddTab({ Name = "Helpers", Icon = "cloud", Type = "Double" })

local AirHelperSection = HelpersTab:AddSection({ Name = "AIR DRIBBLE HELPER", Position = "Center" })

AirHelperSection:AddToggle({ 
    Name = "Air Helper", 
    Default = PlatformEnabled, 
    Flag = "airhelper", 
    Callback = function(v)
        PlatformEnabled = v
        if v then
            StartPlatformSystem()
        else
            StopPlatformSystem()
        end
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
    Callback = function(v)
        Smoothness = v / 100
    end 
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
        UpdatePlatformTransparency()
    end 
})

local MiscTab = Window:AddTab({ Name = "Misc", Icon = "box", Type = "Double" })

local MiscSection = MiscTab:AddSection({ Name = "MISCELLANEOUS", Position = "Center" })

MiscSection:AddButton({ 
    Name = "Fullbright", 
    Callback = function()
        loadstring(game:HttpGet("https://pastebin.com/raw/5ic4YxBU", true))()
    end 
})

MiscSection:AddButton({ 
    Name = "Dark Textures", 
    Callback = function()
        loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-dark-texture-186319"))()
    end 
})

MiscSection:AddButton({ 
    Name = "Infinite Yield", 
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
    end 
})

MiscSection:AddButton({ 
    Name = "FFlag Script (Mobile)", 
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Masterstrap/Mobilestrap/main/script.lua"))()
    end 
})

local FFlagTab = Window:AddTab({ Name = "FFlags", Icon = "eye", Type = "Double" })

local FFlagSection = FFlagTab:AddSection({ Name = "FFLAG MANAGER", Position = "Center" })

FFlagSection:AddInput({ 
    Name = "DFIntTargetTimeDelayFactorTenths", 
    Placeholder = FFlagValues["DFIntTargetTimeDelayFactorTenths"], 
    Flag = "fflag1", 
    Callback = function(v)
        FFlagValues["DFIntTargetTimeDelayFactorTenths"] = v
        ApplyFFlags()
    end 
})

FFlagSection:AddInput({ 
    Name = "FIntInterpolationMaxDelayMSec", 
    Placeholder = FFlagValues["FIntInterpolationMaxDelayMSec"], 
    Flag = "fflag2", 
    Callback = function(v)
        FFlagValues["FIntInterpolationMaxDelayMSec"] = v
        ApplyFFlags()
    end 
})

FFlagSection:AddInput({ 
    Name = "DFIntS2PhysicsSenderRate", 
    Placeholder = FFlagValues["DFIntS2PhysicsSenderRate"], 
    Flag = "fflag3", 
    Callback = function(v)
        FFlagValues["DFIntS2PhysicsSenderRate"] = v
        ApplyFFlags()
    end 
})

FFlagSection:AddButton({ 
    Name = "Apply FFlags", 
    Callback = function()
        ApplyFFlags()
    end 
})

FFlagSection:AddButton({ 
    Name = "Reset FFlags", 
    Callback = function()
        FFlagValues["DFIntTargetTimeDelayFactorTenths"] = "100"
        FFlagValues["FIntInterpolationMaxDelayMSec"] = "1000"
        FFlagValues["DFIntS2PhysicsSenderRate"] = "0"
        ApplyFFlags()
    end 
})

RuntimeEnvironment.__SERENITY_HUB_CLEANUP = function()
    scriptAlive = false
    ReachEnabled = false
    CharacterReachEnabled = false
    PlatformEnabled = false
    WalkSpeedEnabled = false
    JumpPowerEnabled = false

    activeSliderInput = nil
    activeSliderUpdate = nil

    StopReachSystem()
    StopCharacterReachSystem()
    StopPlatformSystem()
    StopWalkSpeedLoop(true)
    ResetJumpPower(LocalPlayer.Character)
    DisconnectTrackedConnections()

    table.clear(ballParts)
    table.clear(ballAirStates)
    table.clear(reachOriginalProperties)
    table.clear(ballProxies)
    table.clear(ballVisualizers)
end