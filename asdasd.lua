getgenv().Settings = {
    ["Auto Detect Closest Player"] = true, -- best for close combat, recommended true, but there'd be a little chance you may get miss click
    ["High Position"] = true,
}
repeat wait(); until game:IsLoaded();


getgenv().HeartbeatConnection = nil


--// many simple definations
local sizeCoefficient
local currentMap = game.Workspace.Map:GetChildren()[1] or game.Workspace.Map:GetChildren()[0]

if not currentMap then
    repeat
        wait()
    until #currentMap:GetChildren() > 0
    currentMap = game.Workspace.Map:GetChildren()[1] or game.Workspace.Map:GetChildren()[0]
end

local LocalPlayer = game.Players.LocalPlayer
local ballFolder = workspace.Balls
local parryButton = game:GetService("ReplicatedStorage").Remotes.ParryButtonPress
local textLabel, VisualPart
local ball = ballFolder:GetChildren()[1]
local character = LocalPlayer.Character
local VirtualInputManager = game:GetService("VirtualInputManager")

local function IsReadyToParry(loliBall) --// to determine should we parry or not
    if character:FindFirstChild("Highlight") then
        local vectorToMe = (character.HumanoidRootPart.Position - loliBall.Position)
        local Distance = vectorToMe.Magnitude
        local Direction = vectorToMe.Unit
        local Speed = loliBall.Velocity:Dot(Direction)
        if Speed <= 0 then return; end
        if Distance < 40 and math.abs(loliBall.Velocity.Magnitude) >= 30 then
            parryButton:Fire();
            print("Close")
            -- game:GetService'VirtualUser':CaptureController()
            -- game:GetService'VirtualUser':Button1Down(Vector2.new(1, 1))
            -- VirtualInputManager:SendMouseButtonEvent(1, 1, 0, true, game, 1)
            -- VirtualInputManager:SendMouseButtonEvent(1, 1, 0, false, game, 1)
        end
        return ((Distance - (sizeCoefficient or 15)) / Speed) < 0.5
    end;
    return false --// Definitely false
end

local function CreateVisual()
    local part = Instance.new("Part", game.Workspace)
    local Size = Vector3.new(0.1, 0.1, 0.1)
    part.Name = "Visual"
    part.Anchored = true
    part.CanCollide = false
    part.CanQuery = false
    part.CanTouch = false
    part.Size = Size
    part.Material = Enum.Material.ForceField
    part.Shape = Enum.PartType.Ball
    part.CastShadow = false
    return part
end
VisualPart = CreateVisual()

game.Workspace.Map.ChildAdded:Connect(function(v)
    currentMap = v
end)


--// Events
if not getgenv().SynergyHubLoaded then
    ballFolder.ChildAdded:Connect(function()
        sizeCoefficient_temp = 0
        sizeCoefficient = 0
        Size = 0
        warn("New ball detected")
    end)
    LocalPlayer.CharacterAdded:Connect(function(newCharacter)
        character = newCharacter --// detect and re-define the "character" whenever local player dies
        for i, v in pairs(game.Workspace:GetChildren()) do
            if v.Name == "Visual" then
                v:Destroy()
            end
        end
        VisualPart = CreateVisual()
        print("Visual Ball created")
    end)

end
getgenv().HeartbeatConnection = game:GetService("RunService").Heartbeat:Connect(function(v)
    local ball = ballFolder:GetChildren()[1]
    if character then
        VisualPart.Position = character.HumanoidRootPart.Position
    end

    if getgenv().Settings["High Position"] then
        if tostring(LocalPlayer.Team) == "Playing" then
            local cframe = currentMap.BALLSPAWN.cframe
            LocalPlayer.Character:SetPrimaryPartCFrame(cframe * CFrame.new(0, 20, 0))
        end
    end
    if ball then
        -- Detects spam case
        -- if getgenv().Settings["Auto Detect Closest Player"] then
        --     local realTarget = ball:GetAttribute("target")
        --     --if realTarget ~= LocalPlayer.Name then
        --         local tarChar = (game.Players:FindFirstChild(realTarget) and game.Players[realTarget].Character) or game.Workspace.Alive:FindFirstChild(realTarget)
        --         if tarChar then
        --             if (tarChar.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude > 1 and (tarChar.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude <= 13 then
        --                 if CheckClosest(tarChar, ball) then
        --                     game:GetService'VirtualUser':CaptureController()
        --                     game:GetService'VirtualUser':Button1Down(Vector2.new(1, 1))
        --                     VirtualInputManager:SendMouseButtonEvent(1, 1, 0, true, game, 1)
        --                     VirtualInputManager:SendMouseButtonEvent(1, 1, 0, false, game, 1)
        --                     parryButton:Fire()
        --                     return
        --                 end
        --             end
        --         end
        --     --end
        -- end

        -- Auto Parry
        if IsReadyToParry(ball) then
            sizeCoefficient = sizeCoefficient_temp or 30
            parryButton:Fire()
        end
        do 
            local Size = ball.Velocity.Magnitude / 7.5
            VisualPart.Size = Vector3.new(Size, Size, Size)
            if sizeCoefficient_temp ~= nil and sizeCoefficient_temp > 0 and sizeCoefficient_temp < 1000 then
                if Size > sizeCoefficient_temp then
                    sizeCoefficient_temp = Size
                end
            else
                sizeCoefficient_temp = Size
            end
        end        
    end
end)

getgenv().SynergyHubLoaded = true
warn(getgenv().SynergyHubLoaded)

