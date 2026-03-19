
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")

local plr = Players.LocalPlayer
local camera = Workspace.CurrentCamera

local speedValue = 50
local flySpeed = 50
local batRange = 15
local basePos = CFrame.new(359.73, 212.41, -443.08)

local noclipOn = false
local speedOn = false
local infJumpOn = false
local flyOn = false
local godmodeOn = false
local antiAfkOn = false
local fullbrightOn = false
local antiLagOn = false
local autoFarmOn = false
local autoCashOn = false
local autoUpgradeOn = false
local autoBatOn = false
local autoExoticsOn = false
local antiIceOn = false
local invisOn = false
local fakeCloneOn = false
local savedLocation = nil
local visualBody = nil

local conn = {}

local Window = Fluent:CreateWindow({
    Title = "Lauude Hub",
    SubTitle = "created by lauude",
    TabWidth = 140,
    Size = UDim2.fromOffset(550, 450),
    Acrylic = true,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.N
})

local Tabs = {
    Home = Window:AddTab({ Title = "Home", Icon = "home" }),
    Player = Window:AddTab({ Title = "Player", Icon = "user" }),
    Combat = Window:AddTab({ Title = "Combat", Icon = "sword" }),
    Farm = Window:AddTab({ Title = "Farm", Icon = "cpu" }),
    Teleport = Window:AddTab({ Title = "Teleport", Icon = "map-pin" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

local function cleanup()
    for _, v in pairs(conn) do
        pcall(function() 
            if type(v) == "thread" then
                task.cancel(v)
            else
                v:Disconnect()
            end
        end)
    end
    conn = {}
end

local function toggleNoclip()
    noclipOn = not noclipOn
    if noclipOn then
        conn.noclip = RunService.Stepped:Connect(function()
            local char = plr.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if conn.noclip then
            conn.noclip:Disconnect()
            conn.noclip = nil
        end
    end
end

local function toggleSpeed()
    speedOn = not speedOn
    local char = plr.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            if speedOn then
                hum.WalkSpeed = speedValue
                if not conn.speed then
                    conn.speed = RunService.Stepped:Connect(function()
                        if speedOn and hum and hum.Parent then
                            pcall(function() hum.WalkSpeed = speedValue end)
                        end
                    end)
                end
            else
                if conn.speed then
                    conn.speed:Disconnect()
                    conn.speed = nil
                end
                if hum and hum.Parent then
                    hum.WalkSpeed = 16
                end
            end
        end
    end
end

local function toggleInfJump()
    infJumpOn = not infJumpOn
    if infJumpOn then
        if conn.infJump then
            conn.infJump:Disconnect()
        end
        conn.infJump = UserInputService.JumpRequest:Connect(function()
            if infJumpOn then
                local char = plr.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end
        end)
    else
        if conn.infJump then
            conn.infJump:Disconnect()
            conn.infJump = nil
        end
    end
end

local function toggleFly()
    flyOn = not flyOn
    local char = plr.Character
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        
        if flyOn and root and hum then
            hum.PlatformStand = true
            
            local gyro = Instance.new("BodyGyro")
            gyro.P = 9e4
            gyro.MaxTorque = Vector3.new(9e4, 9e4, 9e4)
            gyro.CFrame = root.CFrame
            gyro.Parent = root
            conn.flyGyro = gyro
            
            local vel = Instance.new("BodyVelocity")
            vel.Velocity = Vector3.new(0, 0, 0)
            vel.MaxForce = Vector3.new(9e4, 9e4, 9e4)
            vel.Parent = root
            conn.flyVel = vel
            
            conn.fly = RunService.Heartbeat:Connect(function()
                if flyOn and root and gyro and vel then
                    local move = Vector3.new()
                    
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        move = move + camera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        move = move - camera.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        move = move - camera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        move = move + camera.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        move = move + Vector3.new(0, 1, 0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                        move = move + Vector3.new(0, -1, 0)
                    end
                    
                    if move.Magnitude > 0 then
                        vel.Velocity = move.Unit * flySpeed
                    else
                        vel.Velocity = Vector3.new(0, 0, 0)
                    end
                    
                    gyro.CFrame = camera.CFrame
                end
            end)
        elseif not flyOn then
            if hum then
                hum.PlatformStand = false
            end
            if conn.flyGyro then
                pcall(function() conn.flyGyro:Destroy() end)
                conn.flyGyro = nil
            end
            if conn.flyVel then
                pcall(function() conn.flyVel:Destroy() end)
                conn.flyVel = nil
            end
            if conn.fly then
                conn.fly:Disconnect()
                conn.fly = nil
            end
        end
    end
end

local function toggleGodmode()
    godmodeOn = not godmodeOn
    if godmodeOn then
        if conn.godmode then
            conn.godmode:Disconnect()
        end
        conn.godmode = RunService.Stepped:Connect(function()
            local danger = Workspace:FindFirstChild("DangerZones", true)
            if danger then
                for _, a in pairs(danger:GetChildren()) do
                    for _, b in pairs(a:GetDescendants()) do
                        if b.Name == "HitBox" and b:IsA("BasePart") then
                            local touch = b:FindFirstChild("TouchInterest")
                            if touch then
                                touch:Destroy()
                            end
                        end
                    end
                end
            end
        end)
    else
        if conn.godmode then
            conn.godmode:Disconnect()
            conn.godmode = nil
        end
    end
end

local function toggleAntiAfk()
    antiAfkOn = not antiAfkOn
    if antiAfkOn then
        if conn.antiAfk then
            conn.antiAfk:Disconnect()
        end
        conn.antiAfk = RunService.Stepped:Connect(function()
            if plr.Character and plr.Character:FindFirstChildOfClass("Humanoid") then
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end
        end)
    else
        if conn.antiAfk then
            conn.antiAfk:Disconnect()
            conn.antiAfk = nil
        end
    end
end

local function toggleFullbright()
    fullbrightOn = not fullbrightOn
    if fullbrightOn then
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.Brightness = 2
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
        Lighting.ClockTime = 12
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 100000
    else
        Lighting.Ambient = Color3.new(0, 0, 0)
        Lighting.Brightness = 1
        Lighting.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
        Lighting.GlobalShadows = true
        Lighting.FogEnd = 100000
    end
end

local function toggleAntiLag()
    antiLagOn = not antiLagOn
    if antiLagOn then
        for _, v in pairs(Workspace:GetDescendants()) do
            pcall(function()
                if v:IsA("BasePart") and not v:IsDescendantOf(plr.Character) then
                    v.Material = Enum.Material.SmoothPlastic
                    v.Reflectance = 0
                end
                if v:IsA("Texture") or v:IsA("Decal") then
                    v:Destroy()
                end
            end)
        end
        
        conn.antiLag = Workspace.DescendantAdded:Connect(function(v)
            task.wait()
            pcall(function()
                if antiLagOn and v:IsA("BasePart") and not v:IsDescendantOf(plr.Character) then
                    v.Material = Enum.Material.SmoothPlastic
                    v.Reflectance = 0
                end
                if antiLagOn and (v:IsA("Texture") or v:IsA("Decal")) then
                    v:Destroy()
                end
            end)
        end)
    else
        if conn.antiLag then
            conn.antiLag:Disconnect()
            conn.antiLag = nil
        end
    end
end

local function toggleAutoFarm()
    autoFarmOn = not autoFarmOn
    if autoFarmOn then
        if conn.autoFarm then
            task.cancel(conn.autoFarm)
        end
        conn.autoFarm = task.spawn(function()
            while autoFarmOn do
                local char = plr.Character
                if char then
                    local root = char:FindFirstChild("HumanoidRootPart")
                    if root then
                        local items = Workspace:FindFirstChild("SpawnedItems")
                        if items then
                            for _, item in pairs(items:GetChildren()) do
                                if autoFarmOn then
                                    local prompt = item:FindFirstChildWhichIsA("ProximityPrompt", true)
                                    local part = item:FindFirstChildWhichIsA("BasePart")
                                    
                                    if prompt and part then
                                        root.CFrame = part.CFrame * CFrame.new(0, 10, 0)
                                        task.wait(0.5)
                                        if prompt then
                                            fireproximityprompt(prompt)
                                        end
                                        root.CFrame = basePos
                                        task.wait(0.3)
                                    end
                                end
                            end
                        end
                    end
                end
                task.wait(0.5)
            end
        end)
    else
        if conn.autoFarm then
            task.cancel(conn.autoFarm)
            conn.autoFarm = nil
        end
    end
end

local function toggleAutoCash()
    autoCashOn = not autoCashOn
    if autoCashOn then
        if conn.autoCash then
            task.cancel(conn.autoCash)
        end
        conn.autoCash = task.spawn(function()
            while autoCashOn do
                local char = plr.Character
                if char then
                    local root = char:FindFirstChild("HumanoidRootPart")
                    if root then
                        for _, obj in pairs(Workspace:GetDescendants()) do
                            pcall(function()
                                if obj:IsA("BasePart") and obj.Name == "Touch" then
                                    obj.Anchored = false
                                    obj.CFrame = root.CFrame
                                end
                            end)
                        end
                    end
                end
                task.wait(2)
            end
        end)
    else
        if conn.autoCash then
            task.cancel(conn.autoCash)
            conn.autoCash = nil
        end
    end
end

local function toggleAutoUpgrade()
    autoUpgradeOn = not autoUpgradeOn
    if autoUpgradeOn then
        if conn.autoUpgrade then
            task.cancel(conn.autoUpgrade)
        end
        conn.autoUpgrade = task.spawn(function()
            while autoUpgradeOn do
                pcall(function()
                    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
                    if remotes then
                        local upgrade = remotes:FindFirstChild("UpgradeCarry")
                        if upgrade then
                            upgrade:FireServer()
                        end
                    end
                end)
                task.wait(0.8)
            end
        end)
    else
        if conn.autoUpgrade then
            task.cancel(conn.autoUpgrade)
            conn.autoUpgrade = nil
        end
    end
end

local function getClosestPlayer()
    local char = plr.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    
    local closest = nil
    local dist = batRange
    
    for _, other in pairs(Players:GetPlayers()) do
        if other ~= plr and other.Character and other.Character:FindFirstChild("HumanoidRootPart") then
            local d = (char.HumanoidRootPart.Position - other.Character.HumanoidRootPart.Position).Magnitude
            if d < dist then
                dist = d
                closest = other
            end
        end
    end
    return closest
end

local function toggleAutoBat()
    autoBatOn = not autoBatOn
    if autoBatOn then
        if conn.autoBat then
            conn.autoBat:Disconnect()
        end
        conn.autoBat = RunService.Heartbeat:Connect(function()
            pcall(function()
                local char = plr.Character
                if not char then return end
                
                local hum = char:FindFirstChild("Humanoid")
                local target = getClosestPlayer()
                
                if target and hum then
                    local bat = plr.Backpack:FindFirstChild("Bat") or char:FindFirstChild("Bat")
                    
                    if bat then
                        if bat.Parent == plr.Backpack then
                            hum:EquipTool(bat)
                        end
                        bat:Activate()
                    end
                end
            end)
        end)
    else
        if conn.autoBat then
            conn.autoBat:Disconnect()
            conn.autoBat = nil
        end
    end
end

local function toggleAutoExotics()
    autoExoticsOn = not autoExoticsOn
    if autoExoticsOn then
        if conn.autoExotics then
            task.cancel(conn.autoExotics)
        end
        conn.autoExotics = task.spawn(function()
            while autoExoticsOn do
                local char = plr.Character
                if char then
                    local root = char:FindFirstChild("HumanoidRootPart")
                    local hum = char:FindFirstChild("Humanoid")
                    
                    if root and hum and hum.Health > 0 then
                        local folder = Workspace:FindFirstChild("SpawnedItems")
                        if folder then
                            for _, item in pairs(folder:GetChildren()) do
                                if autoExoticsOn then
                                    local name = item.Name
                                    if name == "Six Seven" or name == "Strawberry Elephant" or name == "La Grande Combinasion" then
                                        local prompt = item:FindFirstChildWhichIsA("ProximityPrompt", true)
                                        local part = item:FindFirstChildWhichIsA("BasePart")
                                        
                                        if prompt and part then
                                            root.CFrame = part.CFrame * CFrame.new(0, 10, 0)
                                            task.wait(0.3)
                                            if prompt then
                                                fireproximityprompt(prompt)
                                            end
                                            root.CFrame = basePos
                                            task.wait(0.3)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                task.wait(0.5)
            end
        end)
    else
        if conn.autoExotics then
            task.cancel(conn.autoExotics)
            conn.autoExotics = nil
        end
    end
end

local function toggleAntiIce()
    antiIceOn = not antiIceOn
    
    local function fixFriction(char)
        if not char then return end
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CustomPhysicalProperties = PhysicalProperties.new(2, 0.3, 0.5, 100, 100)
            end
        end
    end
    
    if antiIceOn then
        fixFriction(plr.Character)
        if not conn.antiIce then
            conn.antiIce = plr.CharacterAdded:Connect(fixFriction)
        end
    else
        if conn.antiIce then
            conn.antiIce:Disconnect()
            conn.antiIce = nil
        end
    end
end

local function toggleInvis()
    invisOn = not invisOn
    local char = plr.Character
    if char then
        if invisOn then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                savedLocation = hrp.CFrame
                char:MoveTo(Vector3.new(-25.95, 84, 3537.55))
                task.wait(0.15)
                local seat = Instance.new("Seat")
                seat.Anchored = true
                seat.CanCollide = false
                seat.Transparency = 1
                seat.CFrame = savedLocation
                seat.Parent = Workspace
                seat.Name = "InvisSeat"
                local weld = Instance.new("Weld")
                weld.Part0 = seat
                weld.Part1 = hrp
                weld.Parent = seat
                conn.invisSeat = seat
                conn.invisWeld = weld
            end
        else
            if conn.invisSeat then
                pcall(function() conn.invisSeat:Destroy() end)
                conn.invisSeat = nil
                conn.invisWeld = nil
            end
        end
    end
end

local function toggleFakeClone()
    fakeCloneOn = not fakeCloneOn
    local char = plr.Character
    if char then
        if fakeCloneOn then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            
            if not savedLocation then
                savedLocation = hrp.CFrame
            end
            
            char.Archivable = true
            local clone = char:Clone()
            char.Archivable = false
            clone.Name = "FakeClone"
            clone.Parent = Workspace
            
            local cloneHrp = clone:FindFirstChild("HumanoidRootPart")
            if cloneHrp then
                cloneHrp.CFrame = savedLocation
                cloneHrp.Anchored = true
            end
            
            for _, v in pairs(clone:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.Anchored = true
                    v.CanCollide = false
                    v.Transparency = 0.7
                    v.Material = Enum.Material.Neon
                    v.BrickColor = BrickColor.new("Really black")
                elseif v:IsA("Script") or v:IsA("LocalScript") then
                    v:Destroy()
                end
            end
            
            visualBody = clone
            
            local attach0 = Instance.new("Attachment", hrp)
            local attach1 = Instance.new("Attachment", cloneHrp)
            local beam = Instance.new("Beam")
            beam.Attachment0 = attach0
            beam.Attachment1 = attach1
            beam.Width0 = 0.3
            beam.Width1 = 0.3
            beam.Color = ColorSequence.new(Color3.fromRGB(255, 215, 0))
            beam.Parent = Workspace
            
            conn.beamAttach0 = attach0
            conn.beamAttach1 = attach1
            conn.beam = beam
            
            local anchor = Instance.new("Part")
            anchor.Anchored = true
            anchor.Transparency = 1
            anchor.CFrame = savedLocation
            anchor.Parent = Workspace
            anchor.Name = "FakeAnchor"
            
            local weld = Instance.new("Weld")
            weld.Part0 = anchor
            weld.Part1 = hrp
            weld.Parent = anchor
            
            conn.fakeAnchor = anchor
            conn.fakeWeld = weld
            
            hrp.CFrame = savedLocation * CFrame.new(0, 20, 0)
            
        else
            if visualBody then
                pcall(function() visualBody:Destroy() end)
                visualBody = nil
            end
            if conn.beam then
                pcall(function() conn.beam:Destroy() end)
                conn.beam = nil
            end
            if conn.beamAttach0 then
                pcall(function() conn.beamAttach0:Destroy() end)
                conn.beamAttach0 = nil
            end
            if conn.beamAttach1 then
                pcall(function() conn.beamAttach1:Destroy() end)
                conn.beamAttach1 = nil
            end
            if conn.fakeAnchor then
                pcall(function() conn.fakeAnchor:Destroy() end)
                conn.fakeAnchor = nil
                conn.fakeWeld = nil
            end
        end
    end
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.KeyCode == Enum.KeyCode.P then
        toggleSpeed()
    elseif input.KeyCode == Enum.KeyCode.L then
        local char = plr.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = basePos
        end
    elseif input.KeyCode == Enum.KeyCode.Z then
        toggleInvis()
    end
end)

Tabs.Home:AddParagraph({
    Title = "Lauude Hub",
    Content = "created by lauude\nPlayer: " .. plr.Name
})

Tabs.Home:AddButton({
    Title = "Teleport Base",
    Callback = function()
        local char = plr.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = basePos
        end
    end
})

Tabs.Home:AddButton({
    Title = "Destroy",
    Callback = function()
        cleanup()
        Fluent:Unload()
    end
})

Tabs.Player:AddToggle("NoclipToggle", {
    Title = "Noclip",
    Default = false,
    Callback = function(v)
        if v and not noclipOn then toggleNoclip()
        elseif not v and noclipOn then toggleNoclip() end
    end
})

Tabs.Player:AddToggle("InfJumpToggle", {
    Title = "Infinite Jump",
    Default = false,
    Callback = function(v)
        if v and not infJumpOn then toggleInfJump()
        elseif not v and infJumpOn then toggleInfJump() end
    end
})

Tabs.Player:AddToggle("FlyToggle", {
    Title = "Fly",
    Default = false,
    Callback = function(v)
        if v and not flyOn then toggleFly()
        elseif not v and flyOn then toggleFly() end
    end
})

Tabs.Player:AddSlider("FlySpeedSlider", {
    Title = "Fly Speed",
    Default = 50,
    Min = 1,
    Max = 500,
    Rounding = 1,
    Callback = function(v)
        flySpeed = v
    end
})

Tabs.Player:AddToggle("SpeedToggle", {
    Title = "Speed (P)",
    Default = false,
    Callback = function(v)
        if v and not speedOn then toggleSpeed()
        elseif not v and speedOn then toggleSpeed() end
    end
})

Tabs.Player:AddSlider("SpeedSlider", {
    Title = "Speed Value",
    Default = 50,
    Min = 1,
    Max = 999,
    Rounding = 1,
    Callback = function(v)
        speedValue = v
        if speedOn then
            local char = plr.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.WalkSpeed = speedValue
                end
            end
        end
    end
})

Tabs.Player:AddToggle("AntiIceToggle", {
    Title = "Anti Ice",
    Default = false,
    Callback = function(v)
        if v and not antiIceOn then toggleAntiIce()
        elseif not v and antiIceOn then toggleAntiIce() end
    end
})

Tabs.Player:AddToggle("InvisToggle", {
    Title = "Invisible (Z)",
    Default = false,
    Callback = function(v)
        if v and not invisOn then toggleInvis()
        elseif not v and invisOn then toggleInvis() end
    end
})

Tabs.Player:AddToggle("FakeCloneToggle", {
    Title = "Fake Clone (Beta)",
    Default = false,
    Callback = function(v)
        if v and not fakeCloneOn then toggleFakeClone()
        elseif not v and fakeCloneOn then toggleFakeClone() end
    end
})

Tabs.Combat:AddToggle("GodmodeToggle", {
    Title = "Godmode",
    Default = false,
    Callback = function(v)
        if v and not godmodeOn then toggleGodmode()
        elseif not v and godmodeOn then toggleGodmode() end
    end
})

Tabs.Combat:AddToggle("AutoBatToggle", {
    Title = "Auto Bat",
    Default = false,
    Callback = function(v)
        if v and not autoBatOn then toggleAutoBat()
        elseif not v and autoBatOn then toggleAutoBat() end
    end
})

Tabs.Combat:AddSlider("BatRangeSlider", {
    Title = "Bat Range",
    Default = 15,
    Min = 5,
    Max = 50,
    Rounding = 1,
    Callback = function(v)
        batRange = v
    end
})

Tabs.Combat:AddToggle("AntiAfkToggle", {
    Title = "Anti AFK",
    Default = false,
    Callback = function(v)
        if v and not antiAfkOn then toggleAntiAfk()
        elseif not v and antiAfkOn then toggleAntiAfk() end
    end
})

Tabs.Combat:AddToggle("FullbrightToggle", {
    Title = "Fullbright",
    Default = false,
    Callback = function(v)
        if v and not fullbrightOn then toggleFullbright()
        elseif not v and fullbrightOn then toggleFullbright() end
    end
})

Tabs.Farm:AddToggle("AutoFarmToggle", {
    Title = "Auto Farm",
    Default = false,
    Callback = function(v)
        if v and not autoFarmOn then toggleAutoFarm()
        elseif not v and autoFarmOn then toggleAutoFarm() end
    end
})

Tabs.Farm:AddToggle("AutoCashToggle", {
    Title = "Auto Cash",
    Default = false,
    Callback = function(v)
        if v and not autoCashOn then toggleAutoCash()
        elseif not v and autoCashOn then toggleAutoCash() end
    end
})

Tabs.Farm:AddToggle("AutoExoticsToggle", {
    Title = "Auto Exotics",
    Default = false,
    Callback = function(v)
        if v and not autoExoticsOn then toggleAutoExotics()
        elseif not v and autoExoticsOn then toggleAutoExotics() end
    end
})

Tabs.Farm:AddToggle("AutoUpgradeToggle", {
    Title = "Auto Upgrade",
    Default = false,
    Callback = function(v)
        if v and not autoUpgradeOn then toggleAutoUpgrade()
        elseif not v and autoUpgradeOn then toggleAutoUpgrade() end
    end
})

Tabs.Farm:AddToggle("AntiLagToggle", {
    Title = "Anti Lag",
    Default = false,
    Callback = function(v)
        if v and not antiLagOn then toggleAntiLag()
        elseif not v and antiLagOn then antiLagOn = false end
    end
})

Tabs.Teleport:AddParagraph({
    Title = "Save Location",
    Content = "Click button to save current position"
})

Tabs.Teleport:AddButton({
    Title = "Save Current Pos",
    Callback = function()
        local char = plr.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            savedLocation = char.HumanoidRootPart.CFrame
        end
    end
})

Tabs.Teleport:AddButton({
    Title = "Teleport to Saved",
    Callback = function()
        if savedLocation then
            local char = plr.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = savedLocation
            end
        end
    end
})

local playerDropdown = Tabs.Teleport:AddDropdown("PlayerList", {
    Title = "Player List",
    Values = {},
    Multi = false,
    Callback = function(v)
        if v then
            local target = Players:FindFirstChild(v)
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local char = plr.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
                end
            end
        end
    end
})

local function updatePlayerList()
    local list = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= plr then
            table.insert(list, p.Name)
        end
    end
    playerDropdown:SetValues(list)
end

updatePlayerList()
Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)

Tabs.Teleport:AddButton({
    Title = "Refresh List",
    Callback = updatePlayerList
})

Tabs.Settings:AddButton({
    Title = "Rejoin",
    Callback = function()
        local ts = game:GetService("TeleportService")
        ts:Teleport(game.PlaceId, plr)
    end
})

Tabs.Settings:AddButton({
    Title = "Server Hop",
    Callback = function()
        local ts = game:GetService("TeleportService")
        ts:TeleportToPlaceInstance(game.PlaceId, game.JobId, plr)
    end
})

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("LauudeHub")
SaveManager:SetFolder("LauudeHub")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)


pcall(function()
    SaveManager:LoadAutoloadConfig()
end)
