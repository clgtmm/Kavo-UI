
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

    local remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")

    local vim = game:GetService("VirtualInputManager")
    local vu = game:GetService'VirtualUser'
    local targetConnection
    local movementConnection

    local closeRangecount = 0
    local spamCase = false

    local function IsReadyToParry(loliBall) --// to determine should we parry or not
        if character:FindFirstChild("Highlight") then
            local vectorToMe = (character.HumanoidRootPart.Position - loliBall.Position)
            local Distance = vectorToMe.Magnitude
            local Direction = vectorToMe.Unit
            local Speed = loliBall.Velocity:Dot(Direction)
            if Speed <= 0 then return; end
            if Distance < 17 then
                parryButton:Fire()
                return
            end
            if Distance < 40 and math.abs(loliBall.Velocity.Magnitude) >= 35 then
                parryButton:Fire();
                print("Close")
                -- game:GetService'VirtualUser':CaptureController()
                -- game:GetService'VirtualUser':Button1Down(Vector2.new(1, 1))
                -- VirtualInputManager:SendMouseButtonEvent(1, 1, 0, true, game, 1)
                -- VirtualInputManager:SendMouseButtonEvent(1, 1, 0, false, game, 1)
            end
            return ((Distance - 15) / Speed) < 0.5
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
                if realBall:GetAttribute('target') == myName then
                    if (realBall.Position - character.HumanoidRootPart.Position).Magnitude <= 20 then
                        closeRangecount = closeRangecount + 1
                        if closeRangecount >= 6 then
                            spamCase = true
                        end
                        parryButton:Fire()
                        vu:CaptureController()
                        vu:Button1Down(Vector2.new(1, 1))
                        vim:SendMouseButtonEvent(1, 1, 0, true, game, 1)
                        vim:SendMouseButtonEvent(1, 1, 0, false, game, 1)
                    else
                        closeRangecount = 0
                        spamCase = false
                    end
                else
                    if (realBall.Position - character.HumanoidRootPart.Position).Magnitude > 20 then
                        closeRangecount = 0
                        spamCase = false
                    end
                end
            end)
    end)


    getgenv().HeartbeatConnection = game:GetService("RunService").Heartbeat:Connect(function(v)
        if spamCase then
            parry()
                        parryButton:Fire()
                        vu:CaptureController()
                        vu:Button1Down(Vector2.new(1, 1))
                        vim:SendMouseButtonEvent(1, 1, 0, true, game, 1)
                        vim:SendMouseButtonEvent(1, 1, 0, false, game, 1)
            return
        end
        local ball = ballFolder:GetChildren()[1]
        if ball then
            if IsReadyToParry(ball) then
                parryButton:Fire()
            end
        end
    end)


    print('DMM')
