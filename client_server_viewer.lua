-- Client vs Server - Two Phone View
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TwoPhoneViewer"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local currentView = "CLIENT" -- Track which view we're on

-- Main Frame (acts as a phone)
local PhoneFrame = Instance.new("Frame")
PhoneFrame.Name = "PhoneFrame"
PhoneFrame.Size = UDim2.new(0, 400, 0, 700)
PhoneFrame.Position = UDim2.new(0.5, -200, 0.5, -350)
PhoneFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
PhoneFrame.BorderColor3 = Color3.fromRGB(0, 255, 127)
PhoneFrame.BorderSizePixel = 3
PhoneFrame.Parent = ScreenGui

-- Phone Frame Corner (rounded look)
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 20)
UICorner.Parent = PhoneFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 50)
TitleBar.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = PhoneFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 20)
TitleCorner.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(0.7, 0, 1, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "CLIENT VIEW"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- Scroll Frame for content
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Name = "ScrollFrame"
ScrollFrame.Size = UDim2.new(1, -20, 1, -120)
ScrollFrame.Position = UDim2.new(0, 10, 0, 60)
ScrollFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 5
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.Parent = PhoneFrame

local ScrollCorner = Instance.new("UICorner")
ScrollCorner.CornerRadius = UDim.new(0, 10)
ScrollCorner.Parent = ScrollFrame

-- Button Frame (bottom of phone)
local ButtonFrame = Instance.new("Frame")
ButtonFrame.Name = "ButtonFrame"
ButtonFrame.Size = UDim2.new(1, 0, 0, 60)
ButtonFrame.Position = UDim2.new(0, 0, 1, -60)
ButtonFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ButtonFrame.BorderSizePixel = 0
ButtonFrame.Parent = PhoneFrame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 20)
ButtonCorner.Parent = ButtonFrame

-- Switch Button
local SwitchButton = Instance.new("TextButton")
SwitchButton.Name = "SwitchButton"
SwitchButton.Size = UDim2.new(0.8, 0, 0.8, 0)
SwitchButton.Position = UDim2.new(0.1, 0, 0.1, 0)
SwitchButton.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
SwitchButton.BorderSizePixel = 0
SwitchButton.Text = "SWITCH TO SERVER VIEW"
SwitchButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SwitchButton.TextSize = 12
SwitchButton.Font = Enum.Font.GothamBold
SwitchButton.Parent = ButtonFrame

local ButtonCornerRadius = Instance.new("UICorner")
ButtonCornerRadius.CornerRadius = UDim.new(0, 10)
ButtonCornerRadius.Parent = SwitchButton

-- Close Button (top right)
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 10)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 16
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = PhoneFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseButton

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
            Label.TextSize = 10
            Label.Font = Enum.Font.Gotham
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.TextWrapped = true
            Label.Parent = parent
            
            local TextSize = game:GetService("TextService"):GetTextSize(
                Label.Text, 10, Enum.Font.Gotham, 
                Vector2.new(parent.AbsoluteSize.X - 40, 10000)
            )
            Label.Size = UDim2.new(1, -20, 0, TextSize.Y + 5)
            
            return TextSize.Y + 5
        end
    end
end

-- Function to update CLIENT view
local function UpdateClientView()
    ScrollFrame:ClearAllChildren()
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    TitleLabel.Text = "CLIENT VIEW"
    PhoneFrame.BorderColor3 = Color3.fromRGB(0, 255, 127)
    TitleBar.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    
    local character = LocalPlayer.Character
    if not character then 
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -20, 0, 30)
        Label.Position = UDim2.new(0, 10, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = "Waiting for character..."
        Label.TextColor3 = Color3.fromRGB(255, 100, 100)
        Label.TextSize = 12
        Label.Font = Enum.Font.Gotham
        Label.Parent = ScrollFrame
        return 
    end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -20, 0, 25)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "=== YOUR LOCAL CLIENT DATA ==="
    Title.TextColor3 = Color3.fromRGB(0, 255, 127)
    Title.TextSize = 11
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.TextWrapped = true
    Title.Parent = ScrollFrame
    ScrollFrame.CanvasSize = ScrollFrame.CanvasSize + UDim2.new(0, 0, 0, 30)
    
    DisplayObjectData(ScrollFrame, hrp, "")
end

-- Function to update SERVER view
local function UpdateServerView()
    ScrollFrame:ClearAllChildren()
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    TitleLabel.Text = "SERVER VIEW"
    PhoneFrame.BorderColor3 = Color3.fromRGB(255, 100, 100)
    TitleBar.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    
    local character = LocalPlayer.Character
    if not character then 
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -20, 0, 30)
        Label.Position = UDim2.new(0, 10, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = "Waiting for character..."
        Label.TextColor3 = Color3.fromRGB(255, 100, 100)
        Label.TextSize = 12
        Label.Font = Enum.Font.Gotham
        Label.Parent = ScrollFrame
        return 
    end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -20, 0, 25)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "=== SERVER REPLICATED DATA ==="
    Title.TextColor3 = Color3.fromRGB(255, 100, 100)
    Title.TextSize = 11
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.TextWrapped = true
    Title.Parent = ScrollFrame
    ScrollFrame.CanvasSize = ScrollFrame.CanvasSize + UDim2.new(0, 0, 0, 30)
    
    DisplayObjectData(ScrollFrame, hrp, "[REPLICATED] ")
    
    local Note = Instance.new("TextLabel")
    Note.Size = UDim2.new(1, -20, 0, 50)
    Note.Position = UDim2.new(0, 10, 0, 0)
    Note.BackgroundTransparency = 1
    Note.Text = "\n⚠️ Values that match CLIENT = synced to server\n⚠️ Values that differ = client-sided only"
    Note.TextColor3 = Color3.fromRGB(255, 200, 0)
    Note.TextSize = 9
    Note.Font = Enum.Font.Gotham
    Note.TextXAlignment = Enum.TextXAlignment.Left
    Note.TextWrapped = true
    Note.Parent = ScrollFrame
    ScrollFrame.CanvasSize = ScrollFrame.CanvasSize + UDim2.new(0, 0, 0, 60)
end

-- Switch View
SwitchButton.MouseButton1Click:Connect(function()
    if currentView == "CLIENT" then
        currentView = "SERVER"
        SwitchButton.Text = "SWITCH TO CLIENT VIEW"
        UpdateServerView()
    else
        currentView = "CLIENT"
        SwitchButton.Text = "SWITCH TO SERVER VIEW"
        UpdateClientView()
    end
end)

-- Update every frame based on current view
RunService.RenderStepped:Connect(function()
    if currentView == "CLIENT" then
        UpdateClientView()
    else
        UpdateServerView()
    end
end)

-- Close button
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Dragging
local dragging = false
local dragStart = nil
local frameStart = nil

TitleBar.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = UserInputService:GetMouseLocation()
        frameStart = PhoneFrame.Position
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input, gameProcessed)
    if dragging and input.UserInputType == Enum.UserInputType.Mouse then
        local currentMouse = UserInputService:GetMouseLocation()
        local delta = currentMouse - dragStart
        PhoneFrame.Position = frameStart + UDim2.new(0, delta.X, 0, delta.Y)
    end
end)

print("Two Phone Viewer loaded! Click SWITCH to toggle between CLIENT and SERVER views.")
