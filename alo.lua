

    repeat wait()    
    until game:IsLoaded()


    local plr = game.Players
    local lp = plr.LocalPlayer
    local character = lp.Character
    local myName = lp.Name
    local alive = workspace.Alive
    local Dead = workspace.Dead
    local map = workspace.Map
    local ballFolder = workspace.Balls
    local parryButton = game:GetService("ReplicatedStorage").Remotes.ParryButtonPress
    local currentBallspeed = 0
    local remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")

    local vim = game:GetService("VirtualInputManager")
    local vu = game:GetService'VirtualUser'
    local targetConnection
    local movementConnection
    local currentBalldirectionSpeed
    local closeRangecount = 0
    local spamCase = false

    local maxSpeed = 0 

    local visualRange = 15
    local function IsReadyToParry(loliBall) --// to determine should we parry or not
        if character:FindFirstChild("Highlight") then
            local vectorToMe = (character.HumanoidRootPart.Position - loliBall.Position)
            local distance = vectorToMe.Magnitude
            local direction = vectorToMe.Unit
            local speed = loliBall.Velocity:Dot(direction) - character.HumanoidRootPart.Velocity:Dot(direction)

            currentBallspeed = loliBall.Velocity.Magnitude
            currentBalldirectionSpeed = loliBall.Velocity:Dot(direction)

            if speed <= 0 then return; end
            
            return ((distance - visualRange) / speed) < getgenv().config["Timing"]
        end;
        return false --// Definitely false
    end


    local function parry()
        local stuffs = {}
        for i, v in pairs(plr:GetPlayers()) do
            if not v ~= plr.LocalPlayer then
                if v.Character then
                    if v.Character:FindFirstChild("HumanoidRootPart") then
                        stuffs[tostring(v.UserId)] = game.workspace.CurrentCamera:WorldToScreenPoint(v.Character.PrimaryPart.Position)
                    end
                end
            end
        end
        remotes:WaitForChild("ParryAttempt"):FireServer("NaN", game.workspace.CurrentCamera.CFrame, stuffs, {
            game.workspace.CurrentCamera.ViewportSize.X / 2,
            game.workspace.CurrentCamera.ViewportSize.Y / 2
        })
    end

    --script

    if game:GetService("Players").LocalPlayer.PlayerScripts.Client:FindFirstChild("DeviceChecker") then
        game:GetService("Players").LocalPlayer.PlayerScripts.Client.DeviceChecker:Destroy()
    end


    lp.CharacterAdded:Connect(function(newCharacter)
        character = newCharacter
    end)

    local realBall = ballFolder:GetChildren()[1]
    local fakeBall = ballFolder:GetChildren()[2]
    ballFolder.ChildRemoved:Connect(function()
        closeRangecount = 0
        spamCase = false
    end)
    ballFolder.ChildAdded:Connect(function(v)
        closeRangecount = 0
        spamCase = false
        realBall = ballFolder:GetChildren()[1]
        fakeBall = ballFolder:GetChildren()[2]

            targetConnection = realBall:GetAttributeChangedSignal("target"):Connect(function()
                local currentTarget = realBall:GetAttribute("target")
                if currentTarget == myName then
                    local curDistance = (realBall.Position - character.HumanoidRootPart.Position).Magnitude
                    if curDistance <= 25 then
                            print("hello ball")
                            if curDistance < 14 then
                                parryButton:Fire()
                            end
                            if curDistance / maxSpeed < 0.32 then
                                closeRangecount = closeRangecount + 1
                                if closeRangecount >= 3 then
                                    spamCase = true
                                else
                                    spamCase = false
                                end
                            else
                                closeRangecount = 0
                                spamCase = false
                            end

                    else
                        closeRangecount = 0
                        spamCase = false
                    end
                else
                    if (alive[currentTarget].HumanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude > 25 then
                        closeRangecount = 0
                        spamCase = false
                    end
                end
            end)
    end)


    getgenv().HeartbeatConnection = game:GetService("RunService").Heartbeat:Connect(function(v)
        if spamCase then
            if currentBallspeed <= 0 then return; end
            parryButton:Fire()
            parry()
            vu:CaptureController()
            vu:Button1Down(Vector2.new(1, 1))
            vim:SendMouseButtonEvent(1, 1, 0, true, game, 1)
            vim:SendMouseButtonEvent(1, 1, 0, false, game, 1)
        end
        local ball = ballFolder:GetChildren()[1]
        if ball then
            if ball.Velocity.Magnitude > maxSpeed then
                maxSpeed = ball.Velocity.Magnitude
            end
            visualRange = ball.Velocity.Magnitude / getgenv().config["Visual Range"]
            if IsReadyToParry(ball) then
                parryButton:Fire()
            end
        end
    end)


    print('DMM')
