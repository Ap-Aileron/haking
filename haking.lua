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

local Tab = Window:CreateTab("Main", 4483362458) -- Title, Image
local Section = Tab:CreateSection("Main Section")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Tracking settings
local TRACKING_DISTANCE = 100
local SMOOTHNESS = 0.1
local MAX_FOV = math.rad(50)
local isTracking = false

-- Aimbot state
local aimbotEnabled = false

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
    
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return nil, math.huge
    end
    
    local myPosition = player.Character.HumanoidRootPart.Position
    local players = Players:GetPlayers()
    
    for _, otherPlayer in ipairs(players) do
        if otherPlayer ~= player then
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

-- Input handling
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

-- Main tracking loop
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

-- Implement the toggle
local Toggle = Tab:CreateToggle({
    Name = "Aimbot",
    CurrentValue = false,
    Callback = function(Value)
        aimbotEnabled = Value
        if Value then
            print("Async Loaded")
        else
            print("Error Loading Async")
            isTracking = false  -- Stop tracking when aimbot is disabled
        end
    end,
})
