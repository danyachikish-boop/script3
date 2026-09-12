-- ==================== UNIVERSAL SUPER-HUB v3.0 ====================
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
    warn("[Super-Hub Error]: Не удалось загрузить WindUI!")
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
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local Window = WindUI:CreateWindow({
    Title = "UNIVERSAL SUPER-HUB | v3.0",
    Icon = "rbxassetid://4483362458",
    Author = "by Flor1x",
    Folder = "UniversalSuperHub",
    Size = UDim2.fromOffset(600, 480),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 200,
    HasOutline = true,
})

-- ==================== 1. MOVEMENT & PHYSICS ====================
local MoveTab = Window:Tab({ Title = "Movement", Icon = "footprints" })

_G.UnsafeSpeed = 16
MoveTab:Slider({
    Title = "Speed (WalkSpeed)",
    Desc = "Range from 0 to 1000",
    Value = { Min = 0, Max = 1000, Default = 16 },
    Callback = function(v) _G.UnsafeSpeed = typeof(v) == "table" and v.Value or v end
})

RunService.RenderStepped:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = _G.UnsafeSpeed
    end
end)

_G.CustomJumpPower = 50
MoveTab:Slider({
    Title = "Jump Height (JumpPower)",
    Desc = "Default Roblox Jump Power is 50",
    Value = { Min = 50, Max = 500, Default = 50 },
    Callback = function(v) _G.CustomJumpPower = typeof(v) == "table" and v.Value or v end
})

RunService.RenderStepped:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        hum.UseJumpPower = true
        hum.JumpPower = _G.CustomJumpPower
    end
end)

_G.CustomGravity = 196.2
MoveTab:Slider({
    Title = "Gravity Control",
    Desc = "Default: 196.2",
    Value = { Min = 0, Max = 1000, Default = 196.2 },
    Callback = function(v)
        local gravityVal = typeof(v) == "table" and v.Value or v
        _G.CustomGravity = gravityVal
        workspace.Gravity = gravityVal
    end
})

MoveTab:Button({
    Title = "Reset Gravity",
    Callback = function()
        _G.CustomGravity = 196.2
        workspace.Gravity = 196.2
        WindUI:Notify({ Title = "Gravity Reset!", Content = "Gravity restored to 196.2 :)", Duration = 3 })
    end
})

_G.WASDFly = false
_G.WASDFlySpeed = 50
MoveTab:Toggle({
    Title = "Fly (WASD)",
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
    Value = { Min = 10, Max = 300, Default = 50 },
    Callback = function(v) _G.WASDFlySpeed = typeof(v) == "table" and v.Value or v end
})

_G.InfJump = false
MoveTab:Toggle({
    Title = "Infinite Jump",
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
    Value = false,
    Callback = function(v) _G.Noclip = v end
})

RunService.Stepped:Connect(function()
    if _G.Noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

MoveTab:Button({
    Title = "Get Click TP Tool",
    Desc = "Gives item to teleport anywhere on click",
    Callback = function()
        local tpTool = Instance.new("Tool")
        tpTool.Name = "TP Tool"
        tpTool.RequiresHandle = false
        tpTool.Activated:Connect(function()
            local mouse = LocalPlayer:GetMouse()
            if mouse.Hit and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = mouse.Hit + Vector3.new(0, 3, 0)
            end
        end)
        tpTool.Parent = LocalPlayer.Backpack
        WindUI:Notify({ Title = "TP Tool Granted!", Content = "Equip the tool and click to teleport :)", Duration = 3 })
    end
})

-- ==================== 2. VISUALS & WORLD ====================
local VisualsTab = Window:Tab({ Title = "Visuals / World", Icon = "eye" })

_G.ESP = false
VisualsTab:Toggle({
    Title = "ESP (Player Highlight)",
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
                    if p.Character:FindFirstChild("Highlight") then p.Character.Highlight:Destroy() end
                end
            end
        end
    end
})

VisualsTab:Slider({
    Title = "Time Of Day",
    Desc = "Change environment time (0 - 24)",
    Value = { Min = 0, Max = 24, Default = 12 },
    Callback = function(v)
        local val = typeof(v) == "table" and v.Value or v
        Lighting.ClockTime = val
    end
})

VisualsTab:Dropdown({
    Title = "Custom Skybox",
    Values = {"Default", "Purple Nebula", "Space", "Neat Neon"},
    Value = "Default",
    Callback = function(option)
        local choice = type(option) == "table" and option[1] or option
        local sky = Lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky", Lighting)
        if choice == "Purple Nebula" then
            sky.SkyboxBk = "rbxassetid://159454299"
            sky.SkyboxDn = "rbxassetid://159454296"
            sky.SkyboxFt = "rbxassetid://159454293"
            sky.SkyboxLf = "rbxassetid://159454298"
            sky.SkyboxRt = "rbxassetid://159454300"
            sky.SkyboxUp = "rbxassetid://159454288"
        elseif choice == "Space" then
            sky.SkyboxBk = "rbxassetid://260384779"
            sky.SkyboxDn = "rbxassetid://260384807"
            sky.SkyboxFt = "rbxassetid://260384833"
            sky.SkyboxLf = "rbxassetid://260384859"
            sky.SkyboxRt = "rbxassetid://260384883"
            sky.SkyboxUp = "rbxassetid://260384909"
        elseif choice == "Neat Neon" then
            sky.SkyboxBk = "rbxassetid://12064107"
            sky.SkyboxDn = "rbxassetid://12064152"
            sky.SkyboxFt = "rbxassetid://12064121"
            sky.SkyboxLf = "rbxassetid://12064131"
            sky.SkyboxRt = "rbxassetid://12064115"
            sky.SkyboxUp = "rbxassetid://12064141"
        end
    end
})

VisualsTab:Slider({
    Title = "FOV Changer",
    Desc = "Field of View (Default 70)",
    Value = { Min = 30, Max = 120, Default = 70 },
    Callback = function(v)
        local val = typeof(v) == "table" and v.Value or v
        workspace.CurrentCamera.FieldOfView = val
    end
})

VisualsTab:Slider({
    Title = "Screen Stretch (Resolution)",
    Desc = "Compress / stretch camera view",
    Value = { Min = 50, Max = 100, Default = 100 },
    Callback = function(v)
        local val = typeof(v) == "table" and v.Value or v
        local cam = workspace.CurrentCamera
        cam.ViewportSize = Vector2.new(cam.ViewportSize.X * (val / 100), cam.ViewportSize.Y)
    end
})

-- ==================== 3. UTILITIES & SERVER HOP ====================
local UtilTab = Window:Tab({ Title = "Utilities / Hop", Icon = "server" })

local SelectedHopFilter = "Lowest Ping"

UtilTab:Dropdown({
    Title = "Server Hop Filter",
    Values = {"Lowest Ping", "Highest Ping", "Lowest Players", "Highest Players"},
    Value = "Lowest Ping",
    Callback = function(opt)
        SelectedHopFilter = type(opt) == "table" and opt[1] or opt
    end
})

UtilTab:Button({
    Title = "Execute Server Hop",
    Desc = "Search server based on selected filter",
    Callback = function()
        WindUI:Notify({ Title = "Searching...", Content = "Filtering servers, please wait...", Duration = 3 })
        local api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100"
        local success, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(api))
        end)

        if success and result and result.data then
            local servers = {}
            for _, s in ipairs(result.data) do
                if s.playing < s.maxPlayers and s.id ~= game.JobId then
                    table.insert(servers, s)
                end
            end

            if SelectedHopFilter == "Lowest Players" then
                table.sort(servers, function(a, b) return a.playing < b.playing end)
            elseif SelectedHopFilter == "Highest Players" then
                table.sort(servers, function(a, b) return a.playing > b.playing end)
            elseif SelectedHopFilter == "Lowest Ping" then
                table.sort(servers, function(a, b) return (a.ping or 999) < (b.ping or 999) end)
            elseif SelectedHopFilter == "Highest Ping" then
                table.sort(servers, function(a, b) return (a.ping or 0) > (b.ping or 0) end)
            end

            if #servers > 0 then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[1].id, LocalPlayer)
            else
                WindUI:Notify({ Title = "Error", Content = "No matching servers found :)", Duration = 3 })
            end
        end
    end
})

UtilTab:Button({
    Title = "FPS Booster",
    Desc = "Removes textures and visual effects for smooth FPS",
    Callback = function()
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.Material = Enum.Material.SmoothPlastic
            elseif obj:IsA("Texture") or obj:IsA("Decal") then
                obj:Destroy()
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                obj.Enabled = false
            end
        end
        Lighting.GlobalShadows = false
        WindUI:Notify({ Title = "FPS Boosted!", Content = "Textures & Shadows reduced :)", Duration = 3 })
    end
})
-- ==================== 4. ATTACH & INVISIBILITY ====================
local AttachTab = Window:Tab({ Title = "Attach / Stealth", Icon = "user-x" })

_G.RealInvisible = false
local CamPart = nil
local SpectatorCam = workspace.CurrentCamera
local SpectatorConnection = nil

AttachTab:Toggle({
    Title = "Real Invisibility (FE Ghost)",
    Desc = "Spectator Freecam: hides body underground and lets you fly freely",
    Value = false,
    Callback = function(v)
        _G.RealInvisible = v
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local hrp = char.HumanoidRootPart

        if _G.RealInvisible then
            -- 1. Визуальная полупрозрачность для себя
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = 0.6
                    part.CanCollide = false
                elseif part:IsA("Decal") or part:IsA("Texture") then
                    part.Transparency = 0.6
                end
            end

            -- 2. Создаем незаметную точку наблюдения для стандартной камеры
            CamPart = Instance.new("Part")
            CamPart.Name = "GhostCamFocus"
            CamPart.Size = Vector3.new(0.2, 0.2, 0.2)
            CamPart.Transparency = 1
            CamPart.CanCollide = false
            CamPart.Anchored = true
            CamPart.CFrame = SpectatorCam.CFrame
            CamPart.Parent = workspace

            -- Переключаем фокус стандартной камеры на наш блок
            SpectatorCam.CameraSubject = CamPart

            -- 3. Уводим тело под карту для сервера
            task.spawn(function()
                while _G.RealInvisible and char and char:FindFirstChild("HumanoidRootPart") do
                    hrp.CFrame = CFrame.new(CamPart.Position.X, -2000, CamPart.Position.Z)
                    task.wait(0.05)
                end
            end)

            -- 4. Управление полётом (WASD + Q/E)
            SpectatorConnection = RunService.RenderStepped:Connect(function()
                if not _G.RealInvisible or not CamPart then return end

                local moveVector = Vector3.new()
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + Vector3.new(0, 0, -1) end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector + Vector3.new(0, 0, 1) end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector + Vector3.new(-1, 0, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + Vector3.new(1, 0, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.E) then moveVector = moveVector + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.Q) then moveVector = moveVector + Vector3.new(0, -1, 0) end

                local speedMultiplier = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and 250 or 100
                local camCFrame = SpectatorCam.CFrame
                
                -- Двигаем виртуальную точку слежения
                CamPart.CFrame = CamPart.CFrame + (camCFrame:VectorToWorldSpace(moveVector) * (speedMultiplier * task.wait()))
            end)

            WindUI:Notify({ Title = "Invisibility Active!", Content = "Standard camera rotation working! :)", Duration = 4 })
        else
            -- 5. Возврат в нормальный режим
            if SpectatorConnection then SpectatorConnection:Disconnect() SpectatorConnection = nil end

            if char:FindFirstChildOfClass("Humanoid") then
                SpectatorCam.CameraSubject = char:FindFirstChildOfClass("Humanoid")
            end

            -- Телепортируем игрока туда, где остановился полёт
            if CamPart then
                hrp.CFrame = CFrame.new(CamPart.Position + Vector3.new(0, 3, 0))
                CamPart:Destroy()
                CamPart = nil
            end

            -- Возвращаем видимость
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = 0
                    part.CanCollide = true
                elseif part:IsA("Decal") or part:IsA("Texture") then
                    part.Transparency = 0
                end
            end

            WindUI:Notify({ Title = "Invisibility Disabled!", Content = "Returned to character :)", Duration = 3 })
        end
    end
})

local TargetPlayerName = ""
_G.AttachLoop = false
_G.OrbitMode = false

AttachTab:Input({
    Title = "Target Player Name",
    Placeholder = "Enter partial username...",
    Callback = function(txt) 
        TargetPlayerName = txt 
    end
})

local function GetTargetPlayer()
    if TargetPlayerName == "" then return nil end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and (p.Name:lower():find(TargetPlayerName:lower(), 1, true) or p.DisplayName:lower():find(TargetPlayerName:lower(), 1, true)) then
            return p
        end
    end
    return nil
end

AttachTab:Toggle({
    Title = "Attach To Target",
    Value = false,
    Callback = function(v)
        _G.AttachLoop = v
        task.spawn(function()
            while _G.AttachLoop do
                local target = GetTargetPlayer()
                local myChar = LocalPlayer.Character
                if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and myChar and myChar:FindFirstChild("HumanoidRootPart") then
                    myChar.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                end
                task.wait()
            end
        end)
    end
})

AttachTab:Toggle({
    Title = "Orbit Around Target",
    Value = false,
    Callback = function(v)
        _G.OrbitMode = v
        local angle = 0
        task.spawn(function()
            while _G.OrbitMode do
                local target = GetTargetPlayer()
                local myChar = LocalPlayer.Character
                if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and myChar and myChar:FindFirstChild("HumanoidRootPart") then
                    angle = angle + 0.08
                    local targetPos = target.Character.HumanoidRootPart.Position
                    local offset = Vector3.new(math.cos(angle) * 6, 2, math.sin(angle) * 6)
                    myChar.HumanoidRootPart.CFrame = CFrame.new(targetPos + offset, targetPos)
                end
                task.wait()
            end
        end)
    end
})
-- ==================== 5. COMBAT & KILLFEED ====================
local CombatTab = Window:Tab({ Title = "Combat", Icon = "crosshair" })

_G.Triggerbot = false
_G.TriggerKey = "MB1"

CombatTab:Toggle({
    Title = "Triggerbot (Auto-Attack)",
    Value = false,
    Callback = function(v) _G.Triggerbot = v end
})

CombatTab:Dropdown({
    Title = "Auto-Click Key",
    Values = {"MB1 (LMB)", "MB2 (RMB)", "E", "Q", "F", "R", "Space"},
    Value = "MB1 (LMB)",
    Callback = function(Option)
        _G.TriggerKey = type(Option) == "table" and Option[1] or Option
    end,
})

local function TriggerAction()
    local key = _G.TriggerKey
    if key == "MB1 (LMB)" or key == "MB1" then mouse1click()
    elseif key == "MB2 (RMB)" then mouse2click()
    elseif key == "E" or key == "Q" or key == "F" or key == "R" or key == "Space" then
        local k = Enum.KeyCode[key]
        VirtualInputManager:SendKeyEvent(true, k, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, k, false, game)
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

WindUI:Notify({
    Title = "Super-Hub v3.0 Loaded!",
    Content = "All new features are ready to use :)",
    Duration = 5
})
