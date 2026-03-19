local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "lauude Hub",
    SubTitle = "Created by lauude",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Amethyst",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Home = Window:AddTab({ Title = "Home", Icon = "home" }),
    Movement = Window:AddTab({ Title = "Movement", Icon = "gauge" }),
    Roles = Window:AddTab({ Title = "Roles", Icon = "shield" }),
    Tasks = Window:AddTab({ Title = "Tasks", Icon = "list" }),
    Auto = Window:AddTab({ Title = "Auto", Icon = "bot" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local plr = game:GetService("Players").LocalPlayer
local mouse = plr:GetMouse()

local function killESP(name)
    pcall(function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v.Name == name or v.Name == name:gsub("Highlight", "Tag") then
                v:Destroy()
            end
        end
    end)
end

Tabs.Home:AddParagraph({
    Title = "Created by lauude",
    Content = "User: " .. plr.Name .. "\nStatus: Running\nTheme: Amethyst"
})

Tabs.Home:AddButton({
    Title = "Copy Discord Link",
    Description = "https://discord.gg/W8NDmMp4fN",
    Callback = function()
        setclipboard("https://discord.gg/W8NDmMp4fN")
        Fluent:Notify({Title = "Clipboard", Content = "Link copied!", Duration = 3})
    end
})

local walkSpeed = 50
Tabs.Movement:AddSlider("Spd", {Title = "Speed Multiplier", Default = 16, Min = 16, Max = 300, Rounding = 1}):OnChanged(function(v) walkSpeed = v end)
Tabs.Movement:AddToggle("LoopSpd", {Title = "Enable Speed", Default = false}):OnChanged(function(v)
    _G.LoopSpeed = v
    task.spawn(function()
        while _G.LoopSpeed do
            pcall(function()
                if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                    plr.Character.Humanoid.WalkSpeed = walkSpeed
                end
            end)
            task.wait(0.1)
        end
    end)
end)

Tabs.Movement:AddButton({
    Title = "Get Click TP Tool",
    Callback = function()
        pcall(function()
            local tool = Instance.new("Tool")
            tool.RequiresHandle = false
            tool.Name = "Click Teleport"
            tool.Activated:Connect(function()
                if plr.Character then
                    plr.Character:MoveTo(mouse.Hit.p + Vector3.new(0, 3, 0))
                end
            end)
            tool.Parent = plr.Backpack
        end)
    end
})

Tabs.Movement:AddToggle("NC", {Title = "Noclip", Default = false}):OnChanged(function(v)
    _G.Noclip = v
    game:GetService("RunService").Stepped:Connect(function()
        pcall(function()
            if _G.Noclip and plr.Character then
                for _, p in pairs(plr.Character:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
        end)
    end)
end)

Tabs.Roles:AddToggle("KESP", {Title = "Killer ESP", Default = false}):OnChanged(function(v)
    _G.KE = v
    if not v then killESP("KillerHighlight") end
    task.spawn(function()
        while _G.KE do
            pcall(function()
                local folder = workspace:FindFirstChild("KillerFolder")
                if folder then
                    for _, m in pairs(folder:GetChildren()) do
                        if m:IsA("Model") and not m:FindFirstChild("KillerHighlight") then
                            local h = Instance.new("Highlight", m); h.Name = "KillerHighlight"; h.FillColor = Color3.fromRGB(255, 0, 0)
                            local t = m:FindFirstChild("Head") or m:FindFirstChildWhichIsA("BasePart")
                            if t then
                                local g = Instance.new("BillboardGui", m); g.Name = "KillerTag"; g.Size = UDim2.new(0,200,0,50); g.AlwaysOnTop = true; g.ExtentsOffset = Vector3.new(0,3,0)
                                local l = Instance.new("TextLabel", g); l.Size = UDim2.new(1,0,1,0); l.BackgroundTransparency = 1; l.Text = "KILLER"; l.TextColor3 = Color3.fromRGB(255,0,0); l.Font = 3; l.TextSize = 25; l.Parent = g
                            end
                        end
                    end
                end
            end)
            task.wait(1)
        end
    end)
end)

Tabs.Roles:AddToggle("IESP", {Title = "Innocent ESP", Default = false}):OnChanged(function(v)
    _G.IE = v
    if not v then killESP("InnocentHighlight") end
    task.spawn(function()
        while _G.IE do
            pcall(function()
                for _, p in pairs(game.Players:GetPlayers()) do
                    if p ~= plr and p.Character then
                        local folder = workspace:FindFirstChild("KillerFolder")
                        if not folder or not p.Character:IsDescendantOf(folder) then
                            if not p.Character:FindFirstChild("InnocentHighlight") then
                                local h = Instance.new("Highlight", p.Character); h.Name = "InnocentHighlight"; h.FillColor = Color3.fromRGB(0, 255, 0)
                            end
                        end
                    end
                end
            end)
            task.wait(1)
        end
    end)
end)

local function refreshTasks()
    pcall(function()
        for _, item in pairs(workspace:GetDescendants()) do
            if item.Name == "TaskFolder" then
                for _, part in pairs(item:GetChildren()) do
                    if part:IsA("BasePart") then
                        Tabs.Tasks:AddButton({
                            Title = "TP: " .. part.Name,
                            Callback = function() 
                                pcall(function() plr.Character.HumanoidRootPart.CFrame = part.CFrame + Vector3.new(0,3,0) end)
                            end
                        })
                    end
                end
            end
        end
    end)
end
Tabs.Tasks:AddButton({Title = "Refresh Tasks", Callback = refreshTasks})

Tabs.Auto:AddToggle("AFK", {Title = "Anti-AFK", Default = true}):OnChanged(function(v)
    if v then 
        _G.AFK = plr.Idled:Connect(function() 
            pcall(function() game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame) end)
        end)
    else 
        if _G.AFK then _G.AFK:Disconnect() end 
    end
end)

Tabs.Auto:AddButton({
    Title = "Rejoin Server",
    Callback = function()
        pcall(function()
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, plr)
        end)
    end
})

Tabs.Auto:AddButton({
    Title = "Server Hop",
    Callback = function()
        pcall(function()
            local Http = game:GetService("HttpService")
            local TPS = game:GetService("TeleportService")
            local Api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
            local function Get(cursor)
                local Raw = game:HttpGet(Api .. (cursor and "&cursor=" .. cursor or ""))
                return Http:JSONDecode(Raw)
            end
            local Next;
            repeat
                local Servers = Get(Next)
                for _, s in pairs(Servers.data) do
                    if s.playing < s.maxPlayers and s.id ~= game.JobId then
                        TPS:TeleportToPlaceInstance(game.PlaceId, s.id, plr)
                        break
                    end
                end
                Next = Servers.nextPageCursor
            until not Next
        end)
    end
})

local pDrop = Tabs.Auto:AddDropdown("PlayerTP", {Title = "Select Player", Values = {}, Multi = false})
local function updatePlrs()
    pcall(function()
        local tbl = {}
        for _, p in pairs(game.Players:GetPlayers()) do if p ~= plr then table.insert(tbl, p.Name) end end
        pDrop:SetValues(tbl)
    end)
end
updatePlrs()
game.Players.PlayerAdded:Connect(updatePlrs)
game.Players.PlayerRemoving:Connect(updatePlrs)

pDrop:OnChanged(function(val)
    pcall(function()
        local target = game.Players:FindFirstChild(val)
        if target and target.Character then
            plr.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
        end
    end)
end)

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
InterfaceManager:SetFolder("lauudeHub")
SaveManager:SetFolder("lauudeHub/configs")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()
