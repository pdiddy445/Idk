-- Client vs Server Visual Viewer
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ClientServerViewer"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(1, 0, 1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Left Panel (Client View)
local LeftPanel = Instance.new("Frame")
LeftPanel.Name = "LeftPanel"
LeftPanel.Size = UDim2.new(0.5, -5, 1, 0)
LeftPanel.Position = UDim2.new(0, 0, 0, 0)
LeftPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
LeftPanel.BorderColor3 = Color3.fromRGB(0, 255, 127)
LeftPanel.BorderSizePixel = 2
LeftPanel.Parent = MainFrame

-- Right Panel (Server View)
local RightPanel = Instance.new("Frame")
RightPanel.Name = "RightPanel"
RightPanel.Size = UDim2.new(0.5, -5, 1, 0)
RightPanel.Position = UDim2.new(0.5, 5, 0, 0)
RightPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
RightPanel.BorderColor3 = Color3.fromRGB(255, 100, 100)
RightPanel.BorderSizePixel = 2
RightPanel.Parent = MainFrame

-- Left Title
local LeftTitle = Instance.new("TextLabel")
LeftTitle.Name = "LeftTitle"
LeftTitle.Size = UDim2.new(1, 0, 0, 40)
LeftTitle.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
LeftTitle.BorderSizePixel = 0
LeftTitle.Text = "CLIENT VIEW"
LeftTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
LeftTitle.TextSize = 16
LeftTitle.Font = Enum.Font.GothamBold
LeftTitle.Parent = LeftPanel

-- Right Title
local RightTitle = Instance.new("TextLabel")
RightTitle.Name = "RightTitle"
RightTitle.Size = UDim2.new(1, 0, 0, 40)
RightTitle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
RightTitle.BorderSizePixel = 0
RightTitle.Text = "SERVER VIEW"
RightTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
RightTitle.TextSize = 16
RightTitle.Font = Enum.Font.GothamBold
RightTitle.Parent = RightPanel

-- Left ScrollFrame
local LeftScroll = Instance.new("ScrollingFrame")
LeftScroll.Name = "LeftScroll"
LeftScroll.Size = UDim2.new(1, -20, 1, -60)
LeftScroll.Position = UDim2.new(0, 10, 0, 50)
LeftScroll.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
LeftScroll.BorderSizePixel = 0
LeftScroll.ScrollBarThickness = 6
LeftScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
LeftScroll.Parent = LeftPanel

-- Right ScrollFrame
local RightScroll = Instance.new("ScrollingFrame")
RightScroll.Name = "RightScroll"
RightScroll.Size = UDim2.new(1, -20, 1, -60)
RightScroll.Position = UDim2.new(0, 10, 0, 50)
RightScroll.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
RightScroll.BorderSizePixel = 0
RightScroll.ScrollBarThickness = 6
RightScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
RightScroll.Parent = RightPanel

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 40, 0, 40)
CloseButton.Position = UDim2.new(1, -50, 0, 10)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 18
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = MainFrame

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Function to display object data
local function DisplayObjectData(parent, obj, prefix)
    if not obj or not parent then return end
    
    local properties = {
        "Position",
        "Rotation",
        "Size",
        "Color",
        "Transparency",
        "CanCollide",
        "Anchored",
        "Health",
        "Velocity",
        "AssemblyLinearVelocity",
        "AssemblyAngularVelocity",
        "CFrame",
    }
    
    for _, prop in pairs(properties) do
        local success, value = pcall(function()
            return obj[prop]
        end)
        
        if success and value ~= nil then
            local Label = Instance.new("TextLabel")
            Label.Name = prop
            Label.Size = UDim2.new(1, -20, 0, 0)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = prefix .. prop .. ": " .. tostring(value)
            Label.TextColor3 = Color3.fromRGB(200, 200, 200)
            Label.TextSize = 11
            Label.Font = Enum.Font.Gotham
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.TextWrapped = true
            Label.Parent = parent
            
            local TextSize = game:GetService("TextService"):GetTextSize(
                Label.Text, 11, Enum.Font.Gotham, 
                Vector2.new(parent.AbsoluteSize.X - 40, 10000)
            )
            Label.Size = UDim2.new(1, -20, 0, TextSize.Y + 5)
            
            return TextSize.Y + 5
        end
    end
end

-- Function to update views
local function UpdateViews()
    LeftScroll:ClearAllChildren()
    RightScroll:ClearAllChildren()
    
    LeftScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    RightScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    -- Client View
    local LeftLabel = Instance.new("TextLabel")
    LeftLabel.Name = "Info"
    LeftLabel.Size = UDim2.new(1, -20, 0, 0)
    LeftLabel.Position = UDim2.new(0, 10, 0, 0)
    LeftLabel.BackgroundTransparency = 1
    LeftLabel.Text = "=== YOUR LOCAL VIEW (CLIENT) ==="
    LeftLabel.TextColor3 = Color3.fromRGB(0, 255, 127)
    LeftLabel.TextSize = 12
    LeftLabel.Font = Enum.Font.GothamBold
    LeftLabel.TextXAlignment = Enum.TextXAlignment.Left
    LeftLabel.TextWrapped = true
    LeftLabel.Parent = LeftScroll
    
    LeftLabel.Size = UDim2.new(1, -20, 0, 25)
    LeftScroll.CanvasSize = LeftScroll.CanvasSize + UDim2.new(0, 0, 0, 25)
    
    -- Display client data
    DisplayObjectData(LeftScroll, hrp, "")
    
    -- Server View (Simulated - what server likely sees)
    local RightLabel = Instance.new("TextLabel")
    RightLabel.Name = "Info"
    RightLabel.Size = UDim2.new(1, -20, 0, 0)
    RightLabel.Position = UDim2.new(0, 10, 0, 0)
    RightLabel.BackgroundTransparency = 1
    RightLabel.Text = "=== SERVER VIEW (REPLICATED) ==="
    RightLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    RightLabel.TextSize = 12
    RightLabel.Font = Enum.Font.GothamBold
    RightLabel.TextXAlignment = Enum.TextXAlignment.Left
    RightLabel.TextWrapped = true
    RightLabel.Parent = RightScroll
    
    RightLabel.Size = UDim2.new(1, -20, 0, 25)
    RightScroll.CanvasSize = RightScroll.CanvasSize + UDim2.new(0, 0, 0, 25)
    
    -- Display server data (what replicates)
    DisplayObjectData(RightScroll, hrp, "[REPLICATED] ")
    
    -- Add comparison notes
    local Note = Instance.new("TextLabel")
    Note.Name = "Note"
    Note.Size = UDim2.new(1, -20, 0, 0)
    Note.Position = UDim2.new(0, 10, 0, 0)
    Note.BackgroundTransparency = 1
    Note.Text = "\n⚠️ Server view shows what replicates. Client modifications that don't sync = client-sided."
    Note.TextColor3 = Color3.fromRGB(255, 200, 0)
    Note.TextSize = 10
    Note.Font = Enum.Font.Gotham
    Note.TextXAlignment = Enum.TextXAlignment.Left
    Note.TextWrapped = true
    Note.Parent = RightScroll
    
    Note.Size = UDim2.new(1, -20, 0, 50)
end

-- Update every frame
RunService.RenderStepped:Connect(function()
    UpdateViews()
end)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

print("Client vs Server Visual Viewer loaded! Comparing views in real-time.")
