local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Spectrum Client",
   Icon = 0, 
   LoadingTitle = "",
   LoadingSubtitle = "",
   Theme = "Default", 
   DisableRayfieldPrompts = true,
   DisableBuildWarnings = true, 
})

Rayfield:Notify({
   Title = "Injected!",
   Content = "Injected Successfully!",
   Duration = 6.5,
   Image = 4483362458,
})

local Tab = Window:CreateTab("Main", 4483362458)
local Section = Tab:CreateSection("Main Section")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

local TRACKING_DISTANCE = 100
local SMOOTHNESS = 0.1
local MAX_FOV = math.rad(50)
local isTracking = false

local aimbotEnabled = false

local function isOnOpposingTeam(otherPlayer)
    local myCharacter = workspace:FindFirstChild(LocalPlayer.Name)
    local otherCharacter = workspace:FindFirstChild(otherPlayer.Name)
    
    if myCharacter and otherCharacter then
        local myTeam = myCharacter:GetAttribute("TeamColor")
        local otherTeam = otherCharacter:GetAttribute("TeamColor")
        
        return myTeam and otherTeam and myTeam ~= otherTeam
    end
    return false
end

local function getDistance(pos1, pos2)
    return (pos1 - pos2).Magnitude
end

local function isInFOV(targetPos)
    local cameraLookVector = camera.CFrame.LookVector
    local directionToTarget = (targetPos - camera.CFrame.Position).Unit
    local angle = math.acos(cameraLookVector:Dot(directionToTarget))
    return angle <= MAX_FOV
end

local function findNearestPlayer()
    local nearestPlayer = nil
    local shortestDistance = math.huge
    
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return nil, math.huge
    end
    
    local myPosition = LocalPlayer.Character.HumanoidRootPart.Position
    local players = Players:GetPlayers()
    
    for _, otherPlayer in ipairs(players) do
        if otherPlayer ~= LocalPlayer and isOnOpposingTeam(otherPlayer) then
            if otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local playerPosition = otherPlayer.Character.HumanoidRootPart.Position
                
                if isInFOV(playerPosition) then
                    local distance = getDistance(myPosition, playerPosition)
                    
                    if distance < shortestDistance and distance < TRACKING_DISTANCE then
                        shortestDistance = distance
                        nearestPlayer = otherPlayer
                    end
                end
            end
        end
    end
    
    return nearestPlayer, shortestDistance
end

local function smoothLookAt(targetCFrame)
    local currentCameraPosition = camera.CFrame.Position
    local targetPosition = targetCFrame.Position
    
    local targetCameraCFrame = CFrame.new(currentCameraPosition, targetPosition)
    local newCFrame = camera.CFrame:Lerp(targetCameraCFrame, SMOOTHNESS)
    
    camera.CFrame = newCFrame
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton2 and aimbotEnabled then
        isTracking = true
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        isTracking = false
    end
end)

RunService.RenderStepped:Connect(function()
    if isTracking and aimbotEnabled then
        local nearest, distance = findNearestPlayer()
        
        if nearest then
            local targetPart = nearest.Character:FindFirstChild("Head") or 
                              nearest.Character:FindFirstChild("HumanoidRootPart")
                              
            if targetPart then
                smoothLookAt(targetPart.CFrame)
            end
        end
    end
end)

local Toggle = Tab:CreateToggle({
    Name = "Aimbot",
    CurrentValue = false,
    Callback = function(Value)
        aimbotEnabled = Value
        if Value then
            print("Team-based aimbot enabled")
        else
            print("Team-based aimbot disabled")
            isTracking = false
        end
    end,
})
