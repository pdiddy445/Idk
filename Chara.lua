writefile("CharaULT.mp3", game:HttpGet("https://github.com/ian49972/smth/raw/refs/heads/main/CharaULT.mp3"))
writefile("CharaALT.mp3", game:HttpGet("https://github.com/ian49972/smth/raw/refs/heads/main/CharaALT.mp3"))
writefile("CHARA.rbxmx", game:HttpGet("https://github.com/ian49972/RBXMS/raw/refs/heads/main/CHARA.rbxmx"))
writefile("Reset.mp3", game:HttpGet("https://github.com/ian49972/smth/raw/refs/heads/main/Reset.mp3"))
writefile("Atonement.mp3", game:HttpGet("https://github.com/ian49972/smth/raw/refs/heads/main/Atonement.mp3"))
writefile("DeathCharge.mp3", game:HttpGet("https://github.com/ian49972/smth/raw/refs/heads/main/DeathCharge.mp3"))

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TextService = game:GetService("TextService")
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local backpack = player:WaitForChild("Backpack")

-- =====================================================
-- REMOTE EVENT SETUP (self-contained, single script)
-- =====================================================
local remote = ReplicatedStorage:FindFirstChild("_CharaSync")
if not remote then
    local success = pcall(function()
        local r = Instance.new("RemoteEvent")
        r.Name = "_CharaSync"
        r.Parent = ReplicatedStorage
    end)
    if not success then
        -- Already exists from another client, just wait
    end
end
local remote = ReplicatedStorage:WaitForChild("_CharaSync", 10)

-- Fire to all OTHER clients via server bounce
-- We do this by having the server script created once
local serverBounce = ReplicatedStorage:FindFirstChild("_CharaServer")
if not serverBounce then
    -- Insert a small BindableEvent-based relay using a temporary Script via loadstring on server
    -- Since we're in a single localscript, we use a workaround:
    -- Parent a Script to ServerScriptService via InsertService if possible,
    -- otherwise use a self-relay pattern where each client listens and the sender
    -- uses FireServer -> FireAllClients via a companion server script.
    -- 
    -- PRACTICAL APPROACH for exploits/executors: use a Script inserted into workspace
    local s = Instance.new("Script")
    s.Name = "_CharaServer"
    s.Source = [[
        local r = game:GetService("ReplicatedStorage"):WaitForChild("_CharaSync", 10)
        if r then
            r.OnServerEvent:Connect(function(sender, action, ...)
                r:FireAllClients(sender, action, ...)
            end)
        end
        script:Destroy()
    ]]
    s.Parent = Workspace
end

local tool = Instance.new("Tool")
tool.Name = "Awakening"
tool.RequiresHandle = false
tool.Parent = backpack

local assets = game:GetObjects(getcustomasset("CHARA.rbxmx"))[1]
local cameraModel = assets:WaitForChild("Camera")
local cameraPart = cameraModel:WaitForChild("camera")
local cameraKfs = assets:WaitForChild("camera")
local cameraKfs2 = assets:WaitForChild("camera2")
local playerKfs = assets:WaitForChild("player")
local playerKfs2 = assets:WaitForChild("player2")
local assetsFolder = assets:WaitForChild("Assets")
local torsoAttach = assetsFolder:WaitForChild("torso")
local auraPart = assetsFolder:WaitForChild("aura")
local eyeAttach = assetsFolder:WaitForChild("eye")
local knifeModel = assets:WaitForChild("Knife")
local heart2Model = assets:WaitForChild("Heart2")
local atonementCamModel = assets:WaitForChild("AtonementCam")
local atonementHit = assets:WaitForChild("Keyframes"):WaitForChild("AtonementHit")
local atonementVictim = assets:WaitForChild("Keyframes"):WaitForChild("AntonementHitVictim")
local deathCharge = assets:WaitForChild("Keyframes"):WaitForChild("DeathCharge")
local deathChargeVictim = assets:WaitForChild("Keyframes"):WaitForChild("DeathChargeVictim")
local deathChargeCam = assets:WaitForChild("Keyframes"):WaitForChild("DeathChargeCam")

local Heart = game:GetObjects("rbxassetid://5045128262")[1]

local camera = Workspace.CurrentCamera
local originalCameraType = camera.CameraType
local originalCameraSubject = camera.CameraSubject
local originalFieldOfView = camera.FieldOfView

local screenGui = Instance.new("ScreenGui")
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

local blackFrame = Instance.new("Frame")
blackFrame.Size = UDim2.new(1,0,1,0)
blackFrame.BackgroundColor3 = Color3.new(0,0,0)
blackFrame.BackgroundTransparency = 1
blackFrame.Parent = screenGui

local charaImage = Instance.new("ImageLabel")
charaImage.Size = UDim2.new(0.5,0,0.8,0)
charaImage.Position = UDim2.new(0.6,0,0.1,0)
charaImage.BackgroundTransparency = 1
charaImage.ImageTransparency = 1
charaImage.Image = "rbxassetid://14446502063"
charaImage.Parent = screenGui

local Object = game:GetObjects("rbxassetid://74714833540240")[1]
Object.Parent = workspace
local DialogueGui = Object.CUSTOM_DIALOGUE

local function getColor(timeLength, points)
    local data1 = points[1]
    local allPoints = points[#points]
    for i = 1, #points - 1 do
        if points[i].Time <= timeLength and timeLength <= points[i + 1].Time then
            data1 = points[i]
            allPoints = points[i + 1]
            local newPoint = (timeLength - data1.Time) / (allPoints.Time - data1.Time)
            return data1.Value:Lerp(allPoints.Value, newPoint)
        end
    end
    return data1.Value
end

local function EndDialogue(gui)
    for _, v in gui:GetChildren() do
        if v.Name == "letter" then
            v:SetAttribute("Ending", true)
            TweenService:Create(v, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = v.Position + UDim2.new(0, 0, 0, 50),
                TextTransparency = 1,
                TextStrokeTransparency = 1
            }):Play()
            game.Debris:AddItem(v, 0.4)
        end
    end
end

local function CreateDialogue(data, displayName)
    displayName = player.Name
    local DialogueUI = DialogueGui:Clone()
    local posY = 0
    local posX = 0
    local Time = 0
    local Template = DialogueUI.Holder.Template
    local Holder = DialogueUI.Holder
    local ImageLabel = Template:WaitForChild("ImageLabel")
    local NameLabel = Template:WaitForChild("Name")
    ImageLabel.Position = ImageLabel.Position - UDim2.new(0, 0, 0, 100)
    ImageLabel.ImageTransparency = 1
    ImageLabel.Image = "rbxassetid://6192162228"
    NameLabel.Position = NameLabel.Position - UDim2.new(0, 0, 0, 100)
    NameLabel.TextTransparency = 1
    NameLabel.TextStrokeTransparency = 1
    TweenService:Create(ImageLabel, TweenInfo.new(0.8, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Position = ImageLabel.Position + UDim2.new(0, 0, 0, 100),
        ImageTransparency = 0
    }):Play()
    TweenService:Create(NameLabel, TweenInfo.new(0.8, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Position = NameLabel.Position + UDim2.new(0, 0, 0, 100),
        TextTransparency = 0,
        TextStrokeTransparency = 0
    }):Play()

    DialogueUI.Parent = playerGui
    DialogueUI.Enabled = true
    DialogueUI.Name = "CUSTOM_DIALOGUE"
    CollectionService:AddTag(DialogueUI, "CUSTOM_DIALOGUE")
    NameLabel.Text = displayName

    local isHigh = false
    for _, v in data do
        if v.HigherUp then
            isHigh = true
            TweenService:Create(Holder, TweenInfo.new(0.2), {Position = UDim2.new(0.5, 0, 0.965, 0)}):Play()
        end
    end
    if not isHigh then
        TweenService:Create(Holder, TweenInfo.new(0.8), {Position = UDim2.new(0.5, 0, 1, 0)}):Play()
    end

    for _, v in data do
        local split = string.split(v.Text, "")
        local font = v.Bold and Enum.Font.SourceSansBold or v.Italic and Enum.Font.SourceSansItalic or Enum.Font.SourceSans
        for _, b in split do
            posY = posY + TextService:GetTextSize(b, 25, font, Vector2.new(100, 100)).X
        end
    end

    local totalTypingTime = 0
    for _, v in data do
        local split = string.split(v.Text, "")
        local font = v.Bold and Enum.Font.SourceSansBold or v.Italic and Enum.Font.SourceSansItalic or Enum.Font.SourceSans
        for _, b in split do
            local TextService_TextLabel = TextService:GetTextSize(b, 25, font, Vector2.new(100, 100))
            local TextLabel = Instance.new("TextLabel")
            local newPosY = posY
            local newPosX = posX
            TextLabel.AnchorPoint = Vector2.new(0, 0.5)
            TextLabel.Position = UDim2.new(0.5, newPosX - newPosY / 2 // 1, 0.5, 10)
            TextLabel.Size = UDim2.new(0, TextService_TextLabel.X, 0, TextService_TextLabel.Y)
            TextLabel.Text = b
            TextLabel.Name = "letter"
            TextLabel.Font = font
            TextLabel.TextSize = 25
            TextLabel.Parent = Template
            TextLabel.BackgroundTransparency = 1
            TextLabel.TextStrokeColor3 = v.TextStrokeColor
            TextLabel.TextStrokeTransparency = 1
            TextLabel.TextTransparency = 1
            task.delay(Time, function()
                local osClock = os.clock()
                repeat
                    local keyPointTime = math.min((os.clock() - osClock) / 0.35, 1)
                    local shakeLifeTime = math.min((os.clock() - osClock) / (v.Shake.Lifetime or 0.3), 1)
                    local currentShake = not v.Shake.Enabled and UDim2.new(0, 0, 0, 0) or UDim2.new(0, math.random(-v.Shake.Intensity, v.Shake.Intensity) * (1 - shakeLifeTime), 0, math.random(-v.Shake.Intensity, v.Shake.Intensity) * (1 - shakeLifeTime))
                    local textSettings = 1 - (1 + 2.70158 * math.pow(keyPointTime - 1, 3) + 1.70158 * math.pow(keyPointTime - 1, 2))
                    TextLabel.TextStrokeTransparency = (1 - keyPointTime) ^ 10
                    TextLabel.TextTransparency = textSettings
                    TextLabel.TextSize = 25 + 25 * textSettings
                    TextLabel.TextColor3 = getColor(keyPointTime, v.Color.Keypoints)
                    TextLabel.Position = UDim2.new(0.5, newPosX - newPosY / 2 // 1, 0.5, 0) + currentShake
                    task.wait()
                until os.clock() - osClock > math.max(0.35, v.Shake.Lifetime or 0.3) or not TextLabel or TextLabel:GetAttribute("Ending")
                if TextLabel then
                    TextLabel.TextStrokeTransparency = 0
                    TextLabel.TextTransparency = 0
                    TextLabel.TextSize = 25
                    TextLabel.TextColor3 = v.Color.Keypoints[#v.Color.Keypoints].Value
                    TextLabel.Position = UDim2.new(0.5, newPosX - newPosY / 2 // 1, 0.5, 0)
                end
            end)
            Time = Time + (v.TypeSpeed or 0.03)
            posX = posX + TextService_TextLabel.X
            totalTypingTime = Time
        end
    end

    task.spawn(function()
        task.wait(totalTypingTime + 1)
        EndDialogue(Template)
        TweenService:Create(ImageLabel, TweenInfo.new(0.8, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
            Position = ImageLabel.Position - UDim2.new(0, 0, 0, 100),
            ImageTransparency = 1
        }):Play()
        TweenService:Create(NameLabel, TweenInfo.new(0.8, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
            Position = NameLabel.Position - UDim2.new(0, 0, 0, 100),
            TextTransparency = 1,
            TextStrokeTransparency = 1
        }):Play()
        task.delay(0.8, function()
            DialogueUI:Destroy()
        end)
    end)
end

local knifeMeshes = {}
for _, obj in ipairs(knifeModel:GetDescendants()) do
    if obj:IsA("MeshPart") or obj:IsA("Part") then
        table.insert(knifeMeshes, obj)
    end
end

local camKnifeMeshes = {}
local atonementCamKnife = atonementCamModel:FindFirstChild("Knife")
if atonementCamKnife then
    for _, obj in ipairs(atonementCamKnife:GetDescendants()) do
        if obj:IsA("MeshPart") or obj:IsA("Part") then
            table.insert(camKnifeMeshes, obj)
        end
    end
end

local function SetKnifeVisible(targetChar, visible)
    local transparency = visible and 0 or 1
    local knife = targetChar:FindFirstChild("Knife")
    if knife then
        for _, mesh in ipairs(knife:GetDescendants()) do
            if mesh:IsA("MeshPart") or mesh:IsA("Part") then
                mesh.Transparency = transparency
            end
        end
    end
end

local function SetCamKnifeVisible(visible)
    local transparency = visible and 0 or 1
    for _, mesh in ipairs(camKnifeMeshes) do
        if mesh and mesh.Parent then
            mesh.Transparency = transparency
        end
    end
end

-- Parent knife to character so it replicates to all clients
knifeModel.Parent = character
SetKnifeVisible(character, false)

local currentKnifeMotor = nil
local camConn = nil
local currentCamModel = nil

local function CloneCharacter(targetChar)
    targetChar.Archivable = true
    local clone = targetChar:Clone()
    targetChar.Archivable = false
    return clone
end

local dummyNpc = nil

local function CreateDummy()
    if dummyNpc and dummyNpc.Parent then
        dummyNpc:Destroy()
    end
    local obj = game:GetObjects("rbxassetid://74478360128080")[1]
    if obj:FindFirstChild("HumanoidRootPart") then
        obj.HumanoidRootPart.Anchored = true
    end
    for _, part in ipairs(obj:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
    dummyNpc = obj
    return dummyNpc
end

local atonementTool = Instance.new("Tool")
atonementTool.Name = "Atonement"
atonementTool.RequiresHandle = false
atonementTool.CanBeDropped = false

local tStyle = {
    [Enum.PoseEasingStyle.Linear] = Enum.EasingStyle.Linear,
    [Enum.PoseEasingStyle.Bounce] = Enum.EasingStyle.Bounce,
    [Enum.PoseEasingStyle.Cubic] = Enum.EasingStyle.Cubic,
    [Enum.PoseEasingStyle.Elastic] = Enum.EasingStyle.Elastic,
    [Enum.PoseEasingStyle.Constant] = Enum.EasingStyle.Linear,
}

local tDirection = {
    [Enum.PoseEasingDirection.In] = Enum.EasingDirection.In,
    [Enum.PoseEasingDirection.Out] = Enum.EasingDirection.Out,
    [Enum.PoseEasingDirection.InOut] = Enum.EasingDirection.InOut,
}

function PlayKeyframeSequence(Model, KeyFrameSequence, SpeedMult)
    SpeedMult = SpeedMult or 1
    local AllKeyFrames = {}
    for _, Keyframe in pairs(KeyFrameSequence:GetKeyframes()) do
        table.insert(AllKeyFrames, {Time = Keyframe.Time, Keyframe = Keyframe})
    end
    table.sort(AllKeyFrames, function(a,b) return a.Time < b.Time end)

    if #AllKeyFrames == 0 then return {getLength = function() return 0 end, stop = function() end} end

    local motors, motorValues = {}, {}

    local function GetMotorFromPose(Pose)
        for _, v in pairs(Model:GetDescendants()) do
            if v:IsA("Motor6D") and v.Part1 and v.Part1.Name == Pose.Name and v.Part0 and v.Part0.Name == Pose.Parent.Name then
                return v
            end
        end
    end

    for _, Keyframe in ipairs(AllKeyFrames) do
        for _, Pose in pairs(Keyframe.Keyframe:GetDescendants()) do
            if Pose:IsA("Pose") and Pose.Weight > 0 then
                local Motor6D = motors[Pose.Name] or GetMotorFromPose(Pose)
                if Motor6D then
                    motors[Pose.Name] = Motor6D
                    if not motorValues[Pose.Name] then
                        local motorVal = Instance.new("CFrameValue")
                        motorVal.Name = "MotorValue"
                        motorVal.Parent = Motor6D
                        motorVal.Value = Motor6D.Transform
                        motorValues[Pose.Name] = motorVal
                    end
                end
            end
        end
    end

    local tweens = {}
    local totalTime = 0
    if #AllKeyFrames > 1 then
        for i = 1, #AllKeyFrames - 1 do
            local KF1, KF2 = AllKeyFrames[i], AllKeyFrames[i+1]
            local duration = (KF2.Time - KF1.Time) / SpeedMult
            totalTime += duration

            for _, Pose in pairs(KF2.Keyframe:GetDescendants()) do
                if Pose:IsA("Pose") and Pose.Weight > 0 and motors[Pose.Name] then
                    local tweenInfo = TweenInfo.new(
                        duration,
                        tStyle[Pose.EasingStyle] or Enum.EasingStyle.Linear,
                        tDirection[Pose.EasingDirection] or Enum.EasingDirection.InOut
                    )
                    table.insert(tweens, {
                        Tween = TweenService:Create(motorValues[Pose.Name], tweenInfo, {Value = Pose.CFrame}),
                        Delay = totalTime - duration
                    })
                end
            end
        end
    end

    local function getLength()
        return AllKeyFrames[#AllKeyFrames].Time / SpeedMult
    end

    local connection

    local function play()
        for _, data in ipairs(tweens) do
            task.delay(data.Delay, function()
                data.Tween:Play()
            end)
        end
    end

    -- Use a NetworkOwnership-safe approach:
    -- Motor6D.Transform changes replicate when the character is network-owned by the server
    -- We set the Transform directly so other clients see it
    connection = RunService.Heartbeat:Connect(function()
        for name, motor in pairs(motors) do
            if motorValues[name] then
                motor.Transform = motorValues[name].Value
            end
        end
    end)

    task.spawn(function()
        play()
        task.wait(getLength())
        connection:Disconnect()
    end)

    return {
        getLength = getLength,
        stop = function()
            if connection then connection:Disconnect() end
            for _, data in ipairs(tweens) do
                if data.Tween then data.Tween:Cancel() end
            end
            for _, val in pairs(motorValues) do
                if val then val:Destroy() end
            end
        end
    }
end

-- =====================================================
-- REPLICATION HELPER
-- Fires to all clients (including self) via server relay
-- =====================================================
local function FireAll(action, ...)
    if remote then
        remote:FireServer(action, ...)
    end
end

-- =====================================================
-- CHARA ACTIVATE — runs on ALL clients via remote
-- =====================================================
local function RunCharaOnClient(fromPlayer, isSpecial)
    local targetChar = fromPlayer.Character
    if not targetChar then return end

    local hrp = targetChar:FindFirstChild("HumanoidRootPart")
    local torso = targetChar:FindFirstChild("Torso")
    local head = targetChar:FindFirstChild("Head")
    local rightArm = targetChar:FindFirstChild("Right Arm")
    if not hrp or not torso or not head or not rightArm then return end

    local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")

    -- Only destroy animator for our own character
    if fromPlayer == player then
        local originalAnimator = humanoid:FindFirstChildOfClass("Animator")
        if originalAnimator then originalAnimator:Destroy() end
        hrp.Anchored = true
    end

    -- Camera setup (local only — each player sees their own camera)
    local localCamModel = nil
    local localCamConn = nil
    if fromPlayer == player then
        localCamModel = cameraModel:Clone()
        localCamModel:PivotTo(hrp.CFrame)
        localCamModel.Parent = Workspace
        camera.CameraType = Enum.CameraType.Scriptable
        camera.FieldOfView = 70
        humanoid.CameraOffset = Vector3.new(0,0,0)
        local localCameraPart = localCamModel:FindFirstChild("camera")
        localCamConn = RunService.RenderStepped:Connect(function()
            if localCameraPart then
                camera.CFrame = localCameraPart.CFrame
            end
        end)
        camConn = localCamConn
    end

    -- Sound: parent to HRP so it plays spatially for all clients
    local sound = Instance.new("Sound")
    sound.SoundId = getcustomasset(isSpecial and "CharaALT.mp3" or "CharaULT.mp3")
    sound.Volume = 1
    sound.RollOffMaxDistance = 999999
    sound.Parent = hrp
    sound:Play()

    -- Knife: already parented to targetChar (replicates)
    SetKnifeVisible(targetChar, true)

    local knifeOnTarget = targetChar:FindFirstChild("Knife")
    local handle = knifeOnTarget and knifeOnTarget:FindFirstChild("Handle")

    if handle then handle.Anchored = false end

    if currentKnifeMotor and currentKnifeMotor.Parent then
        currentKnifeMotor:Destroy()
    end

    -- Motor6D on the character replicates to all clients
    currentKnifeMotor = Instance.new("Motor6D")
    currentKnifeMotor.Name = "KnifeWeld"
    currentKnifeMotor.Part0 = rightArm
    currentKnifeMotor.Part1 = handle
    currentKnifeMotor.C0 = CFrame.new(0, -1, 0) * CFrame.Angles(0, 0, math.rad(-90)) * CFrame.Angles(math.rad(-90), 0, 0) * CFrame.Angles(0, math.rad(180), 0)
    currentKnifeMotor.Parent = rightArm

    -- Keyframe animations
    local camAnim, playerAnim, animLength
    local localCamKfs = isSpecial and cameraKfs2 or cameraKfs
    local localPlayerKfs = isSpecial and playerKfs2 or playerKfs

    if fromPlayer == player and localCamModel then
        camAnim = PlayKeyframeSequence(localCamModel, localCamKfs, 1)
    end
    playerAnim = PlayKeyframeSequence(targetChar, localPlayerKfs, 1)
    animLength = playerAnim.getLength()

    -- Heart (non-special only)
    if not isSpecial then
        local heartInst = Heart
        if fromPlayer ~= player then
            heartInst = Heart:Clone()
        end
        heartInst.Anchored = false
        heartInst.CanCollide = false
        heartInst.Transparency = 1
        heartInst.Size = Vector3.new(1, 1, 1)
        heartInst.CFrame = torso.CFrame
        heartInst.Parent = targetChar

        local heartWeld = Instance.new("WeldConstraint")
        heartWeld.Part0 = torso
        heartWeld.Part1 = heartInst
        heartWeld.Parent = heartInst
    end

    if isSpecial then
        task.delay(1.5, function()
            local highlight = Instance.new("Highlight")
            highlight.FillTransparency = 1
            highlight.OutlineColor = Color3.new(1, 1, 1)
            highlight.OutlineTransparency = 0
            highlight.Parent = targetChar
            TweenService:Create(highlight, TweenInfo.new(2), {OutlineTransparency = 1}):Play()
            task.delay(2, function() if highlight.Parent then highlight:Destroy() end end)
        end)

        task.delay(1.5, function()
            local heartModel = heart2Model:Clone()
            heartModel.Parent = Workspace
            if fromPlayer == player and localCamModel then
                local lcp = localCamModel:FindFirstChild("camera")
                if lcp then heartModel:PivotTo(lcp.CFrame * CFrame.new(0, 0, -1)) end
            else
                heartModel:PivotTo(hrp.CFrame * CFrame.new(0, 0, -1))
            end
            local determination = heartModel:FindFirstChild("Determination")
            if determination then
                local det1 = determination:FindFirstChild("Determination1")
                local det2 = determination:FindFirstChild("Determination2")
                if det1 and det2 then
                    local originalDet1CFrame = det1.CFrame
                    local originalDet2CFrame = det2.CFrame
                    det1.CFrame = originalDet1CFrame * CFrame.new(0, 0, -0.3)
                    det2.CFrame = originalDet2CFrame * CFrame.new(0, 0, 0.3)
                    local heartHighlight = Instance.new("Highlight")
                    heartHighlight.FillColor = Color3.fromRGB(255, 0, 0)
                    heartHighlight.FillTransparency = 0
                    heartHighlight.OutlineColor = Color3.new(1, 1, 1)
                    heartHighlight.OutlineTransparency = 0
                    heartHighlight.Parent = heartModel
                    task.delay(0.5, function()
                        TweenService:Create(det1, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = originalDet1CFrame}):Play()
                        TweenService:Create(det2, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = originalDet2CFrame}):Play()
                    end)
                end
            end
            task.delay(1.5, function()
                if heartModel and heartModel.Parent then heartModel:Destroy() end
            end)
        end)

        -- Dialogue only shows for the activating player
        if fromPlayer == player then
            task.delay(6, function()
                CreateDialogue({{Text = "Imm...", TypeSpeed = 0.05, Bold = false, Italic = true, TextStrokeColor = Color3.new(0,0,0), HigherUp = false, Shake = {Enabled = true, Intensity = 4, Lifetime = 0.4}, Color = {Keypoints = {{Time = 0, Value = Color3.new(1,0,0)}, {Time = 1, Value = Color3.new(1,0,0)}}}}}, player.Name)
                task.delay(1, function()
                    CreateDialogue({{Text = "Baaaaaaacck~", TypeSpeed = 0.06, Bold = false, Italic = false, TextStrokeColor = Color3.new(0,0,0), HigherUp = true, Shake = {Enabled = true, Intensity = 1, Lifetime = 0.5}, Color = {Keypoints = {{Time = 0, Value = Color3.new(1,0,0)}, {Time = 1, Value = Color3.new(1,0,0)}}}}}, player.Name)
                end)
            end)
        end
    else
        -- Eye attach: parented to head so it replicates
        local eyeAttachClone = eyeAttach:Clone()
        eyeAttachClone.Parent = head
        local impacto1 = eyeAttachClone:FindFirstChild("impacto1")
        local otherEyeEmitter = nil
        for _, emitter in ipairs(eyeAttachClone:GetDescendants()) do
            if emitter:IsA("ParticleEmitter") and emitter.Name ~= "impacto1" then
                otherEyeEmitter = emitter
                break
            end
        end
        if impacto1 and impacto1:IsA("ParticleEmitter") then
            impacto1.Enabled = true
            task.delay(0.15, function() impacto1.Enabled = false end)
        end
        if otherEyeEmitter then
            otherEyeEmitter.Enabled = true
        end
        task.delay(2, function() if eyeAttachClone.Parent then eyeAttachClone:Destroy() end end)

        -- Chara image only for local player
        if fromPlayer == player then
            task.delay(2.7, function() TweenService:Create(charaImage, TweenInfo.new(0.5), {ImageTransparency = 0}):Play() end)
            task.delay(10.5, function() TweenService:Create(charaImage, TweenInfo.new(0.5), {ImageTransparency = 1}):Play() end)
            task.delay(4, function() CreateDialogue({{Text = "Since", TypeSpeed = 0.03, Bold = false, Italic = false, TextStrokeColor = Color3.new(0,0,0), HigherUp = false, Shake = {Enabled = true, Intensity = 3, Lifetime = 0.3}, Color = {Keypoints = {{Time = 0, Value = Color3.new(1,0,0)}, {Time = 1, Value = Color3.new(1,0,0)}}}}}, player.Name) end)
            task.delay(4.6, function() CreateDialogue({{Text = "WHEN", TypeSpeed = 0.03, Bold = true, Italic = false, TextStrokeColor = Color3.new(0,0,0), HigherUp = true, Shake = {Enabled = true, Intensity = 6, Lifetime = 0.4}, Color = {Keypoints = {{Time = 0, Value = Color3.new(1,0,0)}, {Time = 1, Value = Color3.new(1,0,0)}}}}}, player.Name) end)
            task.delay(5, function() CreateDialogue({{Text = "Were you the one in control??", TypeSpeed = 0.05, Bold = false, Italic = false, TextStrokeColor = Color3.new(0,0,0), HigherUp = false, Shake = {Enabled = false}, Color = {Keypoints = {{Time = 0, Value = Color3.new(1,0,0)}, {Time = 1, Value = Color3.new(1,0,0)}}}}}, player.Name) end)
            task.delay(15.5, function()
                CreateDialogue({{Text = "Now, partner.", TypeSpeed = 0.05, Bold = false, Italic = true, TextStrokeColor = Color3.new(0,0,0), HigherUp = false, Shake = {Enabled = false}, Color = {Keypoints = {{Time = 0, Value = Color3.new(1,0,0)}, {Time = 1, Value = Color3.new(1,0,0)}}}}}, player.Name)
                task.delay(3.2, function() CreateDialogue({{Text = "Let us send this world back into the abyss.", TypeSpeed = 0.06, Bold = true, Italic = false, TextStrokeColor = Color3.new(0,0,0), HigherUp = true, Shake = {Enabled = true, Intensity = 5, Lifetime = 0.4}, Color = {Keypoints = {{Time = 0, Value = Color3.new(1,0,0)}, {Time = 1, Value = Color3.new(1,0,0)}}}}}, player.Name) end)
            end)
        end

        task.delay(10.5, function()
            -- Highlight on targetChar (replicates)
            local highlight = Instance.new("Highlight")
            highlight.FillTransparency = 1
            highlight.OutlineColor = Color3.new(1, 1, 1)
            highlight.OutlineTransparency = 0
            highlight.Parent = targetChar

            local heartInTarget = targetChar:FindFirstChildOfClass("Part") -- fallback
            for _, v in ipairs(targetChar:GetChildren()) do
                if v.Name == "Heart" then heartInTarget = v break end
            end

            if heartInTarget then
                local heartHighlight = Instance.new("Highlight")
                heartHighlight.FillColor = Color3.fromRGB(255, 0, 0)
                heartHighlight.FillTransparency = 0
                heartHighlight.OutlineColor = Color3.new(1, 1, 1)
                heartHighlight.OutlineTransparency = 0
                heartHighlight.Parent = heartInTarget
                heartInTarget.Transparency = 0
                task.delay(2, function()
                    if heartHighlight and heartHighlight.Parent then heartHighlight:Destroy() end
                    if heartInTarget and heartInTarget.Parent then heartInTarget.Transparency = 1 end
                end)
            end

            local tween = TweenService:Create(highlight, TweenInfo.new(5), {OutlineTransparency = 1})
            tween:Play()

            -- Torso attach: parented to torso (replicates)
            local torsoAttachClone = torsoAttach:Clone()
            torsoAttachClone.Parent = torso
            for _, emitter in ipairs(torsoAttachClone:GetDescendants()) do
                if emitter:IsA("ParticleEmitter") then emitter.Enabled = true end
            end

            task.delay(3, function()
                local auraObjects = {}
                local auraCopy = auraPart:Clone()
                auraCopy.Parent = head
                for _, child in ipairs(auraCopy:GetChildren()) do
                    child.Parent = head
                    table.insert(auraObjects, child)
                    if child:IsA("ParticleEmitter") then child.Enabled = true end
                end
                for _, attach in ipairs(head:GetChildren()) do
                    if attach:IsA("Attachment") then
                        table.insert(auraObjects, attach)
                        for _, emitter in ipairs(attach:GetDescendants()) do
                            if emitter:IsA("ParticleEmitter") then emitter.Enabled = true end
                        end
                    end
                end
                auraCopy:Destroy()
                task.delay(animLength - 11, function()
                    for _, obj in ipairs(auraObjects) do
                        if obj and obj.Parent then obj:Destroy() end
                    end
                end)
            end)

            tween.Completed:Wait()
            if highlight and highlight.Parent then highlight:Destroy() end
        end)
    end

    task.delay(animLength, function()
        if playerAnim then playerAnim.stop() end
        if camAnim then camAnim.stop() end

        if fromPlayer == player then
            if localCamConn then localCamConn:Disconnect() end
            hrp.Anchored = false
            camera.CameraType = originalCameraType
            camera.CameraSubject = originalCameraSubject
            camera.FieldOfView = originalFieldOfView

            if not humanoid:FindFirstChildOfClass("Animator") then
                Instance.new("Animator").Parent = humanoid
            end

            if localCamModel and localCamModel.Parent then localCamModel:Destroy() end
        end

        if torsoAttach.Parent then torsoAttach:Destroy() end

        local heartInChar = targetChar:FindFirstChild("Heart")
        if heartInChar then heartInChar:Destroy() end

        SetKnifeVisible(targetChar, false)

        -- Flash effect (local screen only)
        if fromPlayer == player then
            TweenService:Create(blackFrame, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
            task.delay(0.2, function()
                TweenService:Create(blackFrame, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
                task.delay(0.2, function()
                    TweenService:Create(blackFrame, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
                    task.delay(0.2, function()
                        TweenService:Create(blackFrame, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
                    end)
                end)
            end)
            task.delay(1, function() screenGui:Destroy() end)
            atonementTool.Parent = backpack
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ian49972/SCRIPTS/refs/heads/main/Reset"))()
        end
    end)
end

-- =====================================================
-- ATONEMENT ACTIVATE — runs on ALL clients via remote
-- =====================================================
local function RunAtonementOnClient(fromPlayer, targetName)
    local targetChar = fromPlayer.Character
    if not targetChar then return end

    local hrp = targetChar:FindFirstChild("HumanoidRootPart")
    local head = targetChar:FindFirstChild("Head")
    local rightArm = targetChar:FindFirstChild("Right Arm")
    if not hrp or not head or not rightArm then return end

    local closestChar = nil
    if targetName == "__DUMMY__" then
        if fromPlayer == player then
            local dummy = CreateDummy()
            if dummy and dummy:FindFirstChild("HumanoidRootPart") then
                dummy.HumanoidRootPart.CFrame = hrp.CFrame * CFrame.new(0, 0, -5)
                dummy.Parent = Workspace
                closestChar = dummy
            end
        end
    else
        local targetPlayer = Players:FindFirstChild(targetName)
        if targetPlayer and targetPlayer.Character then
            closestChar = targetPlayer.Character
        end
    end

    if not closestChar then
        -- Other clients just use a blank stand-in at the location if no dummy
        if fromPlayer ~= player then return end
        return
    end

    if fromPlayer == player then
        local originalAnimator = humanoid:FindFirstChildOfClass("Animator")
        if originalAnimator then originalAnimator:Destroy() end
        camera.CameraSubject = head
        hrp.Anchored = true
    end

    SetKnifeVisible(targetChar, true)

    local knifeOnTarget = targetChar:FindFirstChild("Knife")
    local handle = knifeOnTarget and knifeOnTarget:FindFirstChild("Handle")
    if handle then handle.Anchored = false end

    if currentKnifeMotor and currentKnifeMotor.Parent then currentKnifeMotor:Destroy() end

    currentKnifeMotor = Instance.new("Motor6D")
    currentKnifeMotor.Name = "RightGrip"
    currentKnifeMotor.Part0 = rightArm
    currentKnifeMotor.Part1 = handle
    currentKnifeMotor.C0 = CFrame.new(0, -1, 0) * CFrame.Angles(0, 0, math.rad(-90)) * CFrame.Angles(math.rad(-90), 0, 0) * CFrame.Angles(0, math.rad(180), 0)
    currentKnifeMotor.Parent = rightArm

    -- Sound on HRP so all clients hear it
    local sound = Instance.new("Sound")
    sound.SoundId = getcustomasset("Atonement.mp3")
    sound.Volume = 1
    sound.RollOffMaxDistance = 999999
    sound.Parent = hrp
    sound:Play()

    local playerAnim = PlayKeyframeSequence(targetChar, atonementHit, 1.1)
    local victimClone = CloneCharacter(closestChar)
    victimClone.Parent = Workspace
    for _, part in ipairs(victimClone:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end

    local victimHrp = victimClone:FindFirstChild("HumanoidRootPart")
    local victimHead = victimClone:FindFirstChild("Head")
    local victimAnim = nil
    local weld = nil

    if victimHrp then
        victimHrp.CFrame = hrp.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(0, math.rad(180), 0)
        weld = Instance.new("WeldConstraint")
        weld.Part0 = hrp
        weld.Part1 = victimHrp
        weld.Parent = hrp
        victimAnim = PlayKeyframeSequence(victimClone, atonementVictim, 1.1)
    end

    if fromPlayer == player then
        task.spawn(function()
            task.wait(5)
            if victimHead and victimHead.Parent then
                camera.CameraSubject = victimHead
            end
        end)
    end

    local firstDuration = math.max(playerAnim.getLength(), victimAnim and victimAnim.getLength() or 0)

    task.delay(firstDuration, function()
        playerAnim.stop()
        if victimAnim then victimAnim.stop() end

        -- Death charge sound on HRP (replicates)
        local deathSound = Instance.new("Sound")
        deathSound.SoundId = getcustomasset("DeathCharge.mp3")
        deathSound.Volume = 1
        deathSound.RollOffMaxDistance = 999999
        deathSound.Parent = hrp
        deathSound:Play()

        local localAtonCam = atonementCamModel:Clone()
        localAtonCam:PivotTo(hrp.CFrame)
        localAtonCam.Parent = Workspace

        SetCamKnifeVisible(true)

        local localCamConn2 = nil
        if fromPlayer == player then
            camera.CameraType = Enum.CameraType.Scriptable
            camera.FieldOfView = 50
            if camConn then camConn:Disconnect() end
            localCamConn2 = RunService.RenderStepped:Connect(function()
                local camPart = localAtonCam:FindFirstChild("Camera")
                if camPart then camera.CFrame = camPart.CFrame end
            end)
            camConn = localCamConn2
        end

        local deathCamAnim = PlayKeyframeSequence(localAtonCam, deathChargeCam, 1)
        local deathPlayerAnim = PlayKeyframeSequence(targetChar, deathCharge, 1)
        local deathVictimAnim = victimClone and PlayKeyframeSequence(victimClone, deathChargeVictim, 1)

        task.spawn(function()
            task.wait(5)
            SetCamKnifeVisible(false)
            task.wait(3)
            SetCamKnifeVisible(true)
        end)

        -- Highlight on character (replicates)
        local playerHighlight = Instance.new("Highlight")
        playerHighlight.FillTransparency = 1
        playerHighlight.OutlineColor = Color3.new(1, 1, 1)
        playerHighlight.OutlineTransparency = 0

        -- ColorCorrection and Sky: local to each client's Lighting
        local colorCorrection = Instance.new("ColorCorrectionEffect")
        colorCorrection.Saturation = -1
        colorCorrection.Contrast = 0.2
        colorCorrection.Brightness = 0

        local sky = Instance.new("Sky")
        sky.SkyboxBk = "rbxassetid://15465935058"
        sky.SkyboxDn = "rbxassetid://15465935058"
        sky.SkyboxFt = "rbxassetid://15465935058"
        sky.SkyboxLf = "rbxassetid://15465935058"
        sky.SkyboxRt = "rbxassetid://15465935058"
        sky.SkyboxUp = "rbxassetid://15465935058"

        task.delay(8, function()
            playerHighlight.Parent = targetChar
            colorCorrection.Parent = Lighting
            sky.Parent = Lighting
        end)

        local deathDuration = math.max(deathPlayerAnim.getLength(), deathVictimAnim and deathVictimAnim.getLength() or 0, deathCamAnim.getLength())

        task.delay(deathDuration, function()
            deathPlayerAnim.stop()
            if deathVictimAnim then deathVictimAnim.stop() end
            deathCamAnim.stop()

            if fromPlayer == player then
                if localCamConn2 then localCamConn2:Disconnect() camConn = nil end
                hrp.Anchored = false
                camera.CameraType = originalCameraType
                camera.CameraSubject = originalCameraSubject
                camera.FieldOfView = originalFieldOfView

                if not humanoid:FindFirstChildOfClass("Animator") then
                    Instance.new("Animator").Parent = humanoid
                end
            end

            SetKnifeVisible(targetChar, false)

            if weld and weld.Parent then weld:Destroy() end
            if victimClone and victimClone.Parent then victimClone:Destroy() end
            if localAtonCam and localAtonCam.Parent then localAtonCam:Destroy() end
            if playerHighlight and playerHighlight.Parent then playerHighlight:Destroy() end
            if colorCorrection and colorCorrection.Parent then colorCorrection:Destroy() end
            if sky and sky.Parent then sky:Destroy() end
        end)
    end)
end

-- =====================================================
-- LISTEN for remote broadcasts from ALL clients
-- =====================================================
if remote then
    remote.OnClientEvent:Connect(function(fromPlayer, action, ...)
        if action == "CharaActivate" then
            RunCharaOnClient(fromPlayer, ...)
        elseif action == "AtonementActivate" then
            RunAtonementOnClient(fromPlayer, ...)
        end
    end)
end

-- =====================================================
-- TOOL ACTIVATION — fires to server to broadcast
-- =====================================================
tool.Activated:Connect(function()
    tool:Destroy()
    local isSpecial = math.random() < 0.5
    FireAll("CharaActivate", isSpecial)
end)

atonementTool.Activated:Connect(function()
    local hrp = character:WaitForChild("HumanoidRootPart")

    local closestPlayer = nil
    local closestDist = 50

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (hrp.Position - p.Character.HumanoidRootPart.Position).Magnitude
            if dist < closestDist then
                closestDist = dist
                closestPlayer = p
            end
        end
    end

    if closestPlayer then
        FireAll("AtonementActivate", closestPlayer.Name)
    else
        FireAll("AtonementActivate", "__DUMMY__")
    end
end)
