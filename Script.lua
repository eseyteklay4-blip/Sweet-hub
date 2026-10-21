BHolderOuter.Position = UDim2.new(0,10,0,54)
BHolderOuter.Size = UDim2.new(1,-20,1,-66)
BHolderOuter.BackgroundTransparency = 1

local BScroll = Instance.new("ScrollingFrame", BHolderOuter)
BScroll.Size = UDim2.new(1,0,1,0)
BScroll.BackgroundTransparency = 1
BScroll.BorderSizePixel = 0
BScroll.ScrollBarThickness = 3
BScroll.ScrollBarImageColor3 = Theme.Accent
BScroll.CanvasSize = UDim2.new(0,0,0,0)
BScroll.Active = true
local BLayout = Instance.new("UIListLayout", BScroll)
BLayout.Padding = UDim.new(0,7) BLayout.SortOrder = Enum.SortOrder.LayoutOrder
BLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    BScroll.CanvasSize = UDim2.new(0, 0, 0, BLayout.AbsoluteContentSize.Y)
end)
local BHolder = BScroll

_G.BindsWindow = BindsWindow

local function createBindRow(parent, text, currentBind, callback)
    local Row = Instance.new("Frame", parent)
    Row.Size = UDim2.new(1,-4,0,42) Row.BackgroundColor3 = Theme.BgRow
    Row.BorderSizePixel = 0 corner(Row, 9)
    mkStroke(Row, Theme.StrokeSoft, 1, 0.72)

    local Label = Instance.new("TextLabel", Row)
    Label.Position = UDim2.fromOffset(14,0) Label.Size = UDim2.new(1,-100,1,0)
    Label.BackgroundTransparency = 1 Label.Font = Enum.Font.GothamBold
    Label.TextSize = 14 Label.TextColor3 = Theme.Text
    Label.TextXAlignment = Enum.TextXAlignment.Left Label.Text = text

    local Btn = Instance.new("TextButton", Row)
    Btn.AnchorPoint = Vector2.new(1,0.5) Btn.Position = UDim2.new(1,-10,0.5,0)
    Btn.Size = UDim2.fromOffset(66,26) Btn.BackgroundColor3 = Theme.BtnBg
    Btn.Text = currentBind Btn.AutoButtonColor = false
    Btn.Font = Enum.Font.GothamBlack Btn.TextSize = 13 Btn.TextColor3 = Theme.AccentBright
    corner(Btn, 8)
    local btnStroke = mkStroke(Btn, Theme.AccentBright, 1, 0.55)

    local listening = false
    local inputConn

    Btn.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        Btn.Text = "..."
        Btn.TextColor3 = Theme.ResetAccent
        tween(btnStroke, 0.15, {Color=Theme.ResetAccent, Transparency=0.15})
        inputConn = UserInputService.InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                Btn.Text = input.KeyCode.Name
                Btn.TextColor3 = Theme.AccentBright
                tween(btnStroke, 0.15, {Color=Theme.AccentBright, Transparency=0.55})
                listening = false
                if callback then callback(input.KeyCode.Name) end
                if inputConn then inputConn:Disconnect() end
            end
        end)
    end)
    Btn.MouseEnter:Connect(function() tween(Btn,0.12,{BackgroundColor3=Theme.BtnBgHover}) end)
    Btn.MouseLeave:Connect(function() tween(Btn,0.12,{BackgroundColor3=Theme.BtnBg}) end)
    Row.MouseEnter:Connect(function() tween(Row,0.12,{BackgroundColor3=Theme.BgRowHov}) end)
    Row.MouseLeave:Connect(function() tween(Row,0.12,{BackgroundColor3=Theme.BgRow}) end)
    return Btn
end

createBindRow(BHolder, "Carpet Speed",  CONFIG.Bind_CarpetSpeed,  function(k) CONFIG.Bind_CarpetSpeed  = k saveConfig() end)
createBindRow(BHolder, "Instant Reset", CONFIG.Bind_InstantReset, function(k) CONFIG.Bind_InstantReset = k saveConfig() end)
createBindRow(BHolder, "Drop",          CONFIG.Bind_Drop,         function(k) CONFIG.Bind_Drop         = k saveConfig() end)
createBindRow(BHolder, "Aimbot",        CONFIG.Bind_Aimbot,       function(k) CONFIG.Bind_Aimbot       = k saveConfig() end)
createBindRow(BHolder, "Auto Kick",     CONFIG.Bind_AutoKick,     function(k) CONFIG.Bind_AutoKick     = k saveConfig() end)
createBindRow(BHolder, "Steal Boost",   CONFIG.Bind_StealBoost,   function(k) CONFIG.Bind_StealBoost   = k saveConfig() end)

local bDragging, bStart, bStartPos
BH.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        bDragging=true bStart=input.Position bStartPos=BindsWindow.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if bDragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
        local delta=input.Position-bStart
        local s = guiScale.Scale
        BindsWindow.Position=UDim2.new(
            bStartPos.X.Scale, bStartPos.X.Offset+delta.X / s,
            bStartPos.Y.Scale, bStartPos.Y.Offset+delta.Y / s)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        if bDragging then
            CONFIG.Positions.BindsWindow={X=BindsWindow.Position.X.Offset,Y=BindsWindow.Position.Y.Offset}
            saveConfig()
        end
        bDragging=false
    end
end)

-- ============================================================
-- KEYBINDS
-- ============================================================
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    local k = input.KeyCode.Name
    if k == CONFIG.Bind_Aimbot then
        CONFIG.Aimbot = not CONFIG.Aimbot
        if CONFIG.Aimbot then Aimbot.Start() else Aimbot.Stop() end
        saveConfig()
        return
    end
    if k == CONFIG.Bind_CarpetSpeed then
        local newState = not CONFIG.CarpetSpeed
        CONFIG.CarpetSpeed = newState
        if newState then
            local ok = CarpetSpeed.Start()
            if not ok then CONFIG.CarpetSpeed = false end
        else
            CarpetSpeed.Stop()
        end
        saveConfig()
    elseif k == CONFIG.Bind_InstantReset then
        InstaReset.Run()
    elseif k == CONFIG.Bind_Drop then
        DropBrainrot.Run()
    elseif k == CONFIG.Bind_AutoKick then
        CONFIG.AutoKick = not CONFIG.AutoKick
        if CONFIG.AutoKick then _G.AutoKick_Start() else _G.AutoKick_Stop() end
        saveConfig()
    elseif k == CONFIG.Bind_StealBoost then
        CONFIG.StealBoost = not CONFIG.StealBoost
        if CONFIG.StealBoost then StealBoost.Start() else StealBoost.Stop() end
        saveConfig()
    end
end)

-- ============================================================
-- RESTORE STATES
-- ============================================================
local function restoreStates()
    if CONFIG.NextBase        then pcall(NextBase_Start)        end
    if CONFIG.AntiRagdoll     then pcall(AntiRagdoll.Enable)    end
    if CONFIG.InfiniteJump    then pcall(InfiniteJump.Enable)   end
    if CONFIG.XRay            then pcall(XRay.Enable)           end
    if CONFIG.AutoEquipOnSlot then pcall(AutoEquipSlot.Start)   end
    if CONFIG.Aimbot          then pcall(Aimbot.Start)          end
    if CONFIG.SlotsESP        then pcall(_G.SlotsESP_Start)     end
    if CONFIG.BrainrotESP     then pcall(_G.BrainrotESP_Start)  end
    if CONFIG.AutoKick        then pcall(_G.AutoKick_Start)     end
    if CONFIG.StealBoost      then pcall(StealBoost.Start)      end
    if CONFIG.CarpetSpeed then
        task.wait(0.5)
        local ok = CarpetSpeed.Start()
        if not ok then CONFIG.CarpetSpeed = false saveConfig() end
    end
end

task.spawn(function()
    repeat task.wait(0.1) until game:IsLoaded()
    if not LP.Character then
        LP.CharacterAdded:Wait()
    end
    task.wait(1)
    restoreStates()
end)

LP.CharacterAdded:Connect(function()
    task.wait(1.5)
    if CONFIG.InfiniteJump and InfiniteJump.enabled then
        InfiniteJump.Disable()
        InfiniteJump.Enable()
    end
    if CONFIG.AntiRagdoll and AntiRagdoll.enabled then
        pcall(function() AntiRagdoll.Disable() end)
        pcall(function() AntiRagdoll.Enable()  end)
    end
    if CONFIG.CarpetSpeed then
        local ok = CarpetSpeed.Start()
        if not ok then CONFIG.CarpetSpeed = false saveConfig() end
    end
end)

game:BindToClose(function() saveConfig() end)

-- ============================================================
-- MOBILE POSITIONING
-- ============================================================
if DEVICE == "iphone" then
    if not CONFIG.Positions.GearSafety  then CONFIG.Positions.GearSafety  = { X = 8,  Y = 40  } end
    if not CONFIG.Positions.JobId       then CONFIG.Positions.JobId       = { X = 8,  Y = 220 } end
    if not CONFIG.Positions.BindsWindow then CONFIG.Positions.BindsWindow = { X = 20, Y = 320 } end
elseif DEVICE == "ipad" then
    if not CONFIG.Positions.GearSafety  then CONFIG.Positions.GearSafety  = { X = 40, Y = 80  } end
    if not CONFIG.Positions.JobId       then CONFIG.Positions.JobId       = { X = 40, Y = 320 } end
end

pcall(function()
    for _, parent in ipairs({ (gethui and gethui()) or game:GetService("CoreGui"), LP:FindFirstChild("PlayerGui") }) do
        if parent then
            local publicHud = parent:FindFirstChild("XiPublicHUD")
            if publicHud and DEVICE ~= "desktop" then
                local root = publicHud:FindFirstChildWhichIsA("Frame", true)
                if root then
                    if DEVICE == "iphone" then root.Position = UDim2.new(0.5, 0, 1, -150)
                    else root.Position = UDim2.new(0.5, 0, 1, -110) end
                end
            end
            local autoGui = parent:FindFirstChild("bRXgmsaEVfze")
            if autoGui and DEVICE ~= "desktop" then
                local hud = autoGui:FindFirstChild("CurrentTargetHUD")
                if hud then
                    if DEVICE == "iphone" then hud.Position = UDim2.new(0.5, 0, 1, -260)
                    else hud.Position = UDim2.new(0.5, 0, 1, -240) end
                end
            end
        end
    end
end)

print("[sweet tp hub] loaded — device:", DEVICE, "scale:", string.format("%.2f", guiScale.Scale))
print("[sweet tp hub] discord.gg/sweettp — halloween edition 🎃")
print("[sweet tp hub] toggles: SlotsESP, BrainrotESP, AutoKick, NextBase, XRay, CarpetSpeed, Aimbot, AutoEquipSlot, StealBoost")
print("[sweet tp hub] auto grab: original block, untouched")
