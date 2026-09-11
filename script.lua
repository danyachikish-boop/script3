-- ==================== UNIVERSAL SUPER-HUB v2.0 (WindUI Loader Fixed) ====================
-- by Flor1x :)

local function FetchWindUI()
    local urls = {
        "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua",
        "https://tree-hub.fyle.dev/windui",
        "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"
    }
    
    for _, url in ipairs(urls) do
        local success, result = pcall(function()
            return game:HttpGet(url)
        end)
        if success and result and #result > 100 then
            local loadSuccess, library = pcall(loadstring(result))
            if loadSuccess and library then
                return library
            end
        end
    end
    return nil
end

local WindUI = FetchWindUI()

if not WindUI then
    warn("[Super-Hub Error]: Не удалось загрузить WindUI! Проверь подключение к интернету или включи VPN.")
    return
end

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local TextChatService = game:GetService("TextChatService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local Window = WindUI:CreateWindow({
    Title = "UNIVERSAL SUPER-HUB | v2.0",
    Icon = "rbxassetid://4483362458",
    Author = "by Flor1x",
    Folder = "UniversalSuperHub",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 200,
    HasOutline = true,
})

-- ==================== 1. MOVEMENT & PHYSICS ====================
local MoveTab = Window:Tab({
    Title = "Movement",
    Icon = "footprints"
})

_G.UnsafeSpeed = 16
MoveTab:Slider({
    Title = "Speed (WalkSpeed)",
    Desc = "Range from 0 to 1000",
    Value = { Min = 0, Max = 1000, Default = 16 },
    Callback = function(v)
        _G.UnsafeSpeed = typeof(v) == "table" and v.Value or v
    end
})

RunService.RenderStepped:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = _G.UnsafeSpeed
    end
end)

_G.WASDFly = false
_G.WASDFlySpeed = 50

MoveTab:Toggle({
    Title = "Fly (WASD)",
    Desc = "Fly in camera direction using movement keys",
    Value = false,
    Callback = function(v)
        _G.WASDFly = v
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local hrp = char.HumanoidRootPart

        if _G.WASDFly then
            local bv = Instance.new("BodyVelocity", hrp)
            bv.Name = "WASDFlyVelocity"
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)

            task.spawn(function()
                while _G.WASDFly do
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        local moveDir = hum.MoveDirection
                        local camCFrame = workspace.CurrentCamera.CFrame
                        local flyDir = (camCFrame.LookVector * moveDir.Z * -1) + (camCFrame.RightVector * moveDir.X)
                        bv.Velocity = flyDir * _G.WASDFlySpeed
                    end
                    task.wait()
                end
                bv:Destroy()
            end)
        end
    end
})

MoveTab:Slider({
    Title = "Fly Speed",
    Desc = "Adjust flying velocity",
    Value = { Min = 10, Max = 300, Default = 50 },
    Callback = function(v)
        _G.WASDFlySpeed = typeof(v) == "table" and v.Value or v
    end
})

_G.InfJump = false
MoveTab:Toggle({
    Title = "Infinite Jump",
    Desc = "Jump continuously in the air",
    Value = false,
    Callback = function(v) _G.InfJump = v end
})

UserInputService.JumpRequest:Connect(function()
    if _G.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

_G.Noclip = false
MoveTab:Toggle({
    Title = "Noclip",
    Desc = "Walk directly through walls and objects",
    Value = false,
    Callback = function(v) _G.Noclip = v end
})

RunService.Stepped:Connect(function()
    if _G.Noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- ==================== 2. VISUALS & COMBAT ====================
local VisualsTab = Window:Tab({
    Title = "Visuals / Combat",
    Icon = "eye"
})

_G.ESP = false
VisualsTab:Toggle({
    Title = "ESP (Player Highlight)",
    Desc = "Highlight all players through walls",
    Value = false,
    Callback = function(v)
        _G.ESP = v
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                if _G.ESP then
                    if not p.Character:FindFirstChild("Highlight") then
                        local hl = Instance.new("Highlight", p.Character)
                        hl.FillColor = Color3.fromRGB(255, 0, 80)
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    end
                else
                    if p.Character:FindFirstChild("Highlight") then
                        p.Character.Highlight:Destroy()
                    end
                end
            end
        end
    end
})

_G.HitboxSize = 10
_G.HitboxToggle = false

VisualsTab:Toggle({
    Title = "Expand Hitboxes",
    Desc = "Enlarge player RootParts for easier targeting",
    Value = false,
    Callback = function(v) _G.HitboxToggle = v end
})

VisualsTab:Slider({
    Title = "Hitbox Size",
    Desc = "Range up to 1000",
    Value = { Min = 2, Max = 1000, Default = 10 },
    Callback = function(v)
        _G.HitboxSize = typeof(v) == "table" and v.Value or v
    end
})

RunService.RenderStepped:Connect(function()
    if _G.HitboxToggle then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = p.Character.HumanoidRootPart
                hrp.Size = Vector3.new(_G.HitboxSize, _G.HitboxSize, _G.HitboxSize)
                hrp.Transparency = 0.7
                hrp.BrickColor = BrickColor.new("Really red")
                hrp.Material = Enum.Material.Neon
                hrp.CanCollide = false
            end
        end
    end
end)

_G.Freecam = false
local origCamType = workspace.CurrentCamera.CameraType

VisualsTab:Toggle({
    Title = "Freecam",
    Desc = "Detach camera to fly freely across the map",
    Value = false,
    Callback = function(v)
        _G.Freecam = v
        local cam = workspace.CurrentCamera
        if _G.Freecam then
            origCamType = cam.CameraType
            cam.CameraType = Enum.CameraType.Scriptable
            task.spawn(function()
                while _G.Freecam do
                    local moveVec = Vector3.zero
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVec = moveVec + cam.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVec = moveVec - cam.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVec = moveVec - cam.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVec = moveVec + cam.CFrame.RightVector end
                    cam.CFrame = cam.CFrame + (moveVec * 2)
                    task.wait()
                end
            end)
        else
            cam.CameraType = Enum.CameraType.Custom
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                cam.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            end
        end
    end
})

VisualsTab:Button({
    Title = "Enable Fullbright",
    Desc = "Remove darkness and ambient shadows",
    Callback = function()
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 2
        Lighting.FogEnd = 1e10
    end
})

-- ==================== 3. UTILITIES & CHAT ====================
local UtilTab = Window:Tab({
    Title = "Utilities / Chat",
    Icon = "message-square"
})

local SpamText = "Universal Hub on Top!"
local SpamCount = 5
local IsSpamming = false

UtilTab:Input({
    Title = "Message Text",
    Desc = "Text to send in chat",
    Value = "Universal Hub on Top!",
    Placeholder = "Enter text...",
    Callback = function(txt) SpamText = txt end
})

UtilTab:Input({
    Title = "Repeat Count",
    Desc = "Amount of messages to send",
    Value = "5",
    Placeholder = "5",
    Callback = function(val) SpamCount = tonumber(val) or 5 end
})

local function SendChatMessage(msg)
    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        local generalChannel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
        if generalChannel then generalChannel:SendAsync(msg) end
    else
        local sayEvent = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
            and ReplicatedStorage.DefaultChatSystemChatEvents:FindFirstChild("SayMessageRequest")
        if sayEvent then sayEvent:FireServer(msg, "All") end
    end
end

UtilTab:Toggle({
    Title = "Start Chat Spam",
    Desc = "Spam configured message in global chat",
    Value = false,
    Callback = function(v)
        IsSpamming = v
        if IsSpamming then
            task.spawn(function()
                for i = 1, SpamCount do
                    if not IsSpamming then break end
                    SendChatMessage(SpamText)
                    task.wait(1)
                end
            end)
        end
    end
})

UtilTab:Button({
    Title = "Rejoin Server",
    Desc = "Reconnect to the current server instance",
    Callback = function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end
})

-- ==================== 4. COMBAT (TRIGGERBOT) ====================
local CombatTab = Window:Tab({
    Title = "Combat",
    Icon = "crosshair"
})

_G.Triggerbot = false
_G.TriggerKey = "MB1"

CombatTab:Toggle({
    Title = "Triggerbot (Auto-Attack)",
    Desc = "Automatically click/press key when aiming at a target",
    Value = false,
    Callback = function(v) _G.Triggerbot = v end
})

CombatTab:Dropdown({
    Title = "Auto-Click Key",
    Desc = "Key or mouse button to trigger",
    Values = {"MB1 (LMB)", "MB2 (RMB)", "E", "Q", "F", "R", "Space"},
    Value = "MB1 (LMB)",
    Callback = function(Option)
        _G.TriggerKey = type(Option) == "table" and Option[1] or Option
    end,
})

local function TriggerAction()
    local key = _G.TriggerKey
    if key == "MB1 (LMB)" or key == "MB1" then
        mouse1click()
    elseif key == "MB2 (RMB)" then
        mouse2click()
    elseif key == "E" then
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    elseif key == "Q" then
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
    elseif key == "F" then
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
    elseif key == "R" then
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.R, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.R, false, game)
    elseif key == "Space" then
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
    end
end

task.spawn(function()
    while task.wait(0.03) do
        if _G.Triggerbot then
            local mouse = LocalPlayer:GetMouse()
            if mouse.Target and mouse.Target.Parent then
                local hitChar = mouse.Target.Parent
                if hitChar:FindFirstChildOfClass("Humanoid") and hitChar ~= LocalPlayer.Character then
                    TriggerAction()
                end
            end
        end
    end
end)

-- ==================== 5. KILLFEED & CHAT SPAM ====================
local KillfeedTab = Window:Tab({
    Title = "Killfeed",
    Icon = "swords"
})

_G.KillfeedEnabled = true
_G.ChatAnnounce = true
_G.CustomKillText = "im noob lol"
_G.DisplayTime = 4.5

local function GetContainer()
    local sg = LocalPlayer.PlayerGui:FindFirstChild("FunnyKillfeedGui")
    if not sg then
        sg = Instance.new("ScreenGui")
        sg.Name = "FunnyKillfeedGui"
        sg.ResetOnSpawn = false
        sg.Parent = LocalPlayer.PlayerGui

        local frame = Instance.new("Frame")
        frame.Name = "Container"
        frame.Size = UDim2.new(0, 500, 0, 400)
        frame.Position = UDim2.new(0.5, -250, 0.12, 0)
        frame.BackgroundTransparency = 1
        frame.Parent = sg

        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 6)
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        layout.Parent = frame
    end
    return sg.Container
end

local function OnKillEvent(killerName, victimName)
    if not _G.KillfeedEnabled then return end

    local container = GetContainer()
    local banner = Instance.new("Frame")
    banner.Size = UDim2.new(1, 0, 0, 32)
    banner.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    banner.BackgroundTransparency = 0.25
    banner.BorderSizePixel = 0

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = banner

    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(1, -10, 1, 0)
    txt.Position = UDim2.new(0, 5, 0, 0)
    txt.BackgroundTransparency = 1
    txt.Font = Enum.Font.SourceSansBold
    txt.TextSize = 21
    txt.TextColor3 = Color3.fromRGB(230, 225, 80)
    txt.TextStrokeTransparency = 0.5
    txt.Text = killerName .. " killed " .. victimName .. " (" .. _G.CustomKillText .. ")"
    txt.Parent = banner

    banner.Parent = container

    TweenService:Create(banner, TweenInfo.new(0.3), {BackgroundTransparency = 0.25}):Play()
    TweenService:Create(txt, TweenInfo.new(0.3), {TextTransparency = 0}):Play()

    task.delay(_G.DisplayTime, function()
        if banner and banner.Parent then
            local f1 = TweenService:Create(banner, TweenInfo.new(0.5), {BackgroundTransparency = 1})
            local f2 = TweenService:Create(txt, TweenInfo.new(0.5), {TextTransparency = 1})
            f1:Play() f2:Play()
            f1.Completed:Connect(function() banner:Destroy() end)
        end
    end)

    if _G.ChatAnnounce then
        SendChatMessage(victimName .. " got eliminated! (" .. _G.CustomKillText .. ")")
    end
end

local function HookPlayer(p)
    local function OnCharacter(char)
        local hum = char:WaitForChild("Humanoid", 5)
        if hum then
            hum.Died:Connect(function()
                local creator = hum:FindFirstChild("creator")
                local killerName = "Someone"
                if creator and creator.Value and creator.Value:IsA("Player") then
                    killerName = creator.Value.Name
                elseif p == LocalPlayer then
                    killerName = LocalPlayer.Name
                end
                OnKillEvent(killerName, p.Name)
            end)
        end
    end
    if p.Character then OnCharacter(p.Character) end
    p.CharacterAdded:Connect(OnCharacter)
end

for _, p in pairs(Players:GetPlayers()) do HookPlayer(p) end
Players.PlayerAdded:Connect(HookPlayer)

KillfeedTab:Toggle({
    Title = "Enable Killfeed",
    Desc = "Display kill notifications on screen",
    Value = true,
    Callback = function(v) _G.KillfeedEnabled = v end
})

KillfeedTab:Toggle({
    Title = "Announce in Global Chat",
    Desc = "Broadcast kill notifications to global chat",
    Value = true,
    Callback = function(v) _G.ChatAnnounce = v end
})

KillfeedTab:Input({
    Title = "Text in Brackets",
    Desc = "Custom message added to kill notifications",
    Value = "im noob lol",
    Placeholder = "Enter text...",
    Callback = function(txt)
        if txt ~= "" then _G.CustomKillText = txt end
    end
})

KillfeedTab:Button({
    Title = "Test Push Banner",
    Desc = "Trigger a dummy kill notification",
    Callback = function()
        OnKillEvent(LocalPlayer.Name, "Noobie")
    end
})

-- ==================== 6. MISC ====================
local MiscTab = Window:Tab({
    Title = "Misc",
    Icon = "wrench"
})

_G.YeetPower = 500

MiscTab:Slider({
    Title = "Launch Power",
    Desc = "Force applied when launching players",
    Value = { Min = 100, Max = 5000, Default = 500 },
    Callback = function(v)
        _G.YeetPower = typeof(v) == "table" and v.Value or v
    end
})

MiscTab:Button({
    Title = "Get Yeet Gun (Launcher)",
    Desc = "Gives a tool that launches players you click on",
    Callback = function()
        local tool = Instance.new("Tool")
        tool.Name = "Yeet Launcher"
        tool.RequiresHandle = true
        
        local handle = Instance.new("Part")
        handle.Name = "Handle"
        handle.Size = Vector3.new(1, 1, 4)
        handle.BrickColor = BrickColor.new("Really red")
        handle.Material = Enum.Material.Neon
        handle.Parent = tool
        
        tool.Activated:Connect(function()
            local mouse = LocalPlayer:GetMouse()
            if mouse.Target and mouse.Target.Parent then
                local targetChar = mouse.Target.Parent
                if targetChar:IsA("Accessory") or targetChar:IsA("Model") then
                    if not targetChar:FindFirstChildOfClass("Humanoid") and targetChar.Parent then
                        targetChar = targetChar.Parent
                    end
                end

                local hrp = targetChar:FindFirstChild("HumanoidRootPart") or targetChar:FindFirstChild("Torso")
                
                if hrp and targetChar ~= LocalPlayer.Character then
                    local bv = Instance.new("BodyVelocity")
                    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    
                    local launchDirection = (mouse.Hit.LookVector + Vector3.new(0, 1.5, 0)).Unit
                    bv.Velocity = launchDirection * _G.YeetPower
                    bv.Parent = hrp
                    
                    task.delay(0.3, function()
                        bv:Destroy()
                    end)
                end
            end
        end)
        
        tool.Parent = LocalPlayer.Backpack
        
        WindUI:Notify({
            Title = "Weapon Granted!",
            Content = "Yeet Launcher added to your backpack :)",
            Duration = 3
        })
    end
})

WindUI:Notify({
    Title = "Super-Hub v2.0 Ready!",
    Content = "All modules loaded successfully with WindUI :)",
    Duration = 5
})
