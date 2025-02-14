
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Configuration
local spinSpeed = 20 -- Adjust spin speed as needed
local enabled = true

-- Spin function
local function spin()
    if not enabled then return end
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    -- Rotate the character
    humanoidRootPart.CFrame = humanoidRootPart.CFrame * CFrame.Angles(0, math.rad(spinSpeed), 0)
end

-- Connect spin to RunService
RunService.RenderStepped:Connect(spin)

-- Handle character respawning
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
end)

-- Toggle function (optional)
local function toggleSpin()
    enabled = not enabled
end

-- Bind toggle to a key (example)
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.X then -- Press X to toggle
        toggleSpin()
    end
end)
