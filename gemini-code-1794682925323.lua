-- Roblox Mobile Ultimate-Trigger Macro GUI
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Clean up existing instance
if PlayerGui:FindFirstChild("DirectBindMacro") then
    PlayerGui.DirectBindMacro:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DirectBindMacro"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- Main Control Panel (Draggable)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 310)
MainFrame.Position = UDim2.new(0.5, -125, 0.15, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(80, 80, 100)
UIStroke.Thickness = 1.5
UIStroke.Parent = MainFrame

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "⚡ ULTIMATE MOBILE MACRO"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 12
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Variables to store linked button objects
local boundEnergyButton = nil
local boundAuraButton = nil

-- Energy Button Bind Status
local EnergyBindBtn = Instance.new("TextButton")
EnergyBindBtn.Size = UDim2.new(0.85, 0, 0, 32)
EnergyBindBtn.Position = UDim2.new(0.075, 0, 0.13, 0)
EnergyBindBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 255)
EnergyBindBtn.Text = "Bind Energy Button (Click me)"
EnergyBindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
EnergyBindBtn.TextSize = 10
EnergyBindBtn.Font = Enum.Font.GothamBold
EnergyBindBtn.Parent = MainFrame

local EBCorner = Instance.new("UICorner")
EBCorner.CornerRadius = UDim.new(0, 6)
EBCorner.Parent = EnergyBindBtn

-- Aura Button Bind Status
local AuraBindBtn = Instance.new("TextButton")
AuraBindBtn.Size = UDim2.new(0.85, 0, 0, 32)
AuraBindBtn.Position = UDim2.new(0.075, 0, 0.30, 0)
AuraBindBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 255)
AuraBindBtn.Text = "Bind Aura Button (Click me)"
AuraBindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AuraBindBtn.TextSize = 10
AuraBindBtn.Font = Enum.Font.GothamBold
AuraBindBtn.Parent = MainFrame

local ABCorner = Instance.new("UICorner")
ABCorner.CornerRadius = UDim.new(0, 6)
ABCorner.Parent = AuraBindBtn

-- Energy Delay
local Label1 = Instance.new("TextLabel")
Label1.Size = UDim2.new(0.55, 0, 0, 25)
Label1.Position = UDim2.new(0.075, 0, 0.48, 0)
Label1.BackgroundTransparency = 1
Label1.Text = "Energy Delay (s):"
Label1.TextColor3 = Color3.fromRGB(140, 180, 255)
Label1.TextSize = 11
Label1.TextXAlignment = Enum.TextXAlignment.Left
Label1.Font = Enum.Font.Gotham
Label1.Parent = MainFrame

local Box1 = Instance.new("TextBox")
Box1.Size = UDim2.new(0.3, 0, 0, 25)
Box1.Position = UDim2.new(0.625, 0, 0.48, 0)
Box1.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
Box1.Text = "0.5"
Box1.TextColor3 = Color3.fromRGB(255, 255, 255)
Box1.Font = Enum.Font.GothamBold
Box1.Parent = MainFrame

-- Aura Delay
local Label2 = Instance.new("TextLabel")
Label2.Size = UDim2.new(0.55, 0, 0, 25)
Label2.Position = UDim2.new(0.075, 0, 0.62, 0)
Label2.BackgroundTransparency = 1
Label2.Text = "Aura Delay (s):"
Label2.TextColor3 = Color3.fromRGB(210, 140, 255)
Label2.TextSize = 11
Label2.TextXAlignment = Enum.TextXAlignment.Left
Label2.Font = Enum.Font.Gotham
Label2.Parent = MainFrame

local Box2 = Instance.new("TextBox")
Box2.Size = UDim2.new(0.3, 0, 0, 25)
Box2.Position = UDim2.new(0.625, 0, 0.62, 0)
Box2.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
Box2.Text = "0.5"
Box2.TextColor3 = Color3.fromRGB(255, 255, 255)
Box2.Font = Enum.Font.GothamBold
Box2.Parent = MainFrame

for _, box in ipairs({Box1, Box2}) do
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 5)
    c.Parent = box
end

-- Toggle Macro Button
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.85, 0, 0, 35)
ToggleBtn.Position = UDim2.new(0.075, 0, 0.77, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
ToggleBtn.Text = "MACRO: OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 12
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Parent = MainFrame

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = ToggleBtn

-- Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 25)
StatusLabel.Position = UDim2.new(0, 0, 0.9, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Tap buttons to bind"
StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
StatusLabel.TextSize = 10
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Parent = MainFrame

-- Binding Mode Logic
local bindingTarget = nil

EnergyBindBtn.MouseButton1Click:Connect(function()
    bindingTarget = "Energy"
    StatusLabel.Text = "Tap the IN-GAME Energy button!"
    StatusLabel.TextColor3 = Color3.fromRGB(40, 120, 255)
end)

AuraBindBtn.MouseButton1Click:Connect(function()
    bindingTarget = "Aura"
    StatusLabel.Text = "Tap the IN-GAME Aura button!"
    StatusLabel.TextColor3 = Color3.fromRGB(180, 40, 255)
end)

game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        if bindingTarget then
            local mousePos = input.Position
            local objects = PlayerGui:GetGuiObjectsAtPosition(mousePos.X, mousePos.Y)
            
            for _, obj in ipairs(objects) do
                if obj ~= MainFrame and not obj:IsDescendantOf(MainFrame) and (obj:IsA("GuiButton") or obj:IsA("ImageButton") or obj:IsA("TextButton")) then
                    if bindingTarget == "Energy" then
                        boundEnergyButton = obj
                        EnergyBindBtn.Text = "Energy: " .. obj.Name
                        StatusLabel.Text = "Energy Bound!"
                    elseif bindingTarget == "Aura" then
                        if obj == boundEnergyButton then
                            StatusLabel.Text = "Error: Can't use same button!"
                            StatusLabel.TextColor3 = Color3.fromRGB(220, 80, 80)
                            bindingTarget = nil
                            return
                        end
                        boundAuraButton = obj
                        AuraBindBtn.Text = "Aura: " .. obj.Name
                        StatusLabel.Text = "Aura Bound!"
                    end
                    StatusLabel.TextColor3 = Color3.fromRGB(100, 220, 100)
                    bindingTarget = nil
                    break
                end
            end
        end
    end
end)

-- Quadruple-Fallback Press Function (Guaranteed to trigger on mobile executors)
local function pressButton(btn)
    if not btn or not btn.Parent then return end
    pcall(function()
        local pos = btn.AbsolutePosition + (btn.AbsoluteSize / 2)
        
        -- 1. Firesignal (Delta / Mobile Executor native signal firing)
        if firesignal then
            pcall(function() firesignal(btn.MouseButton1Click) end)
            pcall(function() firesignal(btn.Activated) end)
        end
        
        -- 2. Firetouchtap at exact button center coordinates
        if firetouchtap then
            firetouchtap(pos.X, pos.Y, 0)
        end
        
        -- 3. VirtualInputManager Touch Begin & End
        pcall(function()
            VirtualInputManager:SendTouchEvent(1, Enum.UserInputState.Begin, pos.X, pos.Y, game)
            task.wait(0.02)
            VirtualInputManager:SendTouchEvent(1, Enum.UserInputState.End, pos.X, pos.Y, game)
        end)
        
        -- 4. Standard Connection Fire Fallback
        if getconnections then
            for _, conn in ipairs(getconnections(btn.MouseButton1Click) or {}) do
                pcall(function() conn:Fire() end)
            end
            for _, conn in ipairs(getconnections(btn.Activated) or {}) do
                pcall(function() conn:Fire() end)
            end
        end
    end)
end

local isRunning = false
local macroSession = 0

ToggleBtn.MouseButton1Click:Connect(function()
    if not boundEnergyButton or not boundAuraButton then
        StatusLabel.Text = "Error: Bind both buttons first!"
        StatusLabel.TextColor3 = Color3.fromRGB(220, 80, 80)
        return
    end
    
    isRunning = not isRunning
    macroSession = macroSession + 1
    local currentSession = macroSession
    
    if isRunning then
        ToggleBtn.Text = "MACRO: ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
        
        task.spawn(function()
            while isRunning and currentSession == macroSession do
                -- 1. Energy Phase
                if not boundEnergyButton or not boundEnergyButton.Parent then break end
                StatusLabel.Text = "Status: Energy (E)"
                pressButton(boundEnergyButton)
                
                -- Responsive Delay 1
                local delay1 = tonumber(Box1.Text) or 0.5
                local t1 = tick()
                while isRunning and currentSession == macroSession and (tick() - t1) < delay1 do
                    task.wait(0.03)
                end
                
                if not isRunning or currentSession ~= macroSession then break end
                
                -- 2. Aura Phase
                if not boundAuraButton or not boundAuraButton.Parent then break end
                StatusLabel.Text = "Status: Aura (A)"
                pressButton(boundAuraButton)
                
                -- Responsive Delay 2
                local delay2 = tonumber(Box2.Text) or 0.5
                local t2 = tick()
                while isRunning and currentSession == macroSession and (tick() - t2) < delay2 do
                    task.wait(0.03)
                end
            end
            if currentSession == macroSession then
                StatusLabel.Text = "Status: Idle"
            end
        end)
    else
        ToggleBtn.Text = "MACRO: OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        StatusLabel.Text = "Status: Idle"
    end
end)
