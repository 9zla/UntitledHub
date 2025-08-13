local asdkasodpkasdpoaksdopaskdasopkdaspo = 7452832502

if game:GetService("Players").LocalPlayer.UserId ~= asdkasodpkasdpoaksdopaskdasopkdaspo then
    game:GetService("Players").LocalPlayer:Kick("You are not whitelisted")
    return
end

getgenv().rollingType = nil
getgenv().instanceName = nil
getgenv().flowMode = nil
getgenv().flowColor = nil

------------------------------ // Library \\ ------------------------------

local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

------------------------------ // Variables \\ ------------------------------

local Player = game:GetService("Players").LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Rerolls = ReplicatedStorage:WaitForChild("rerolls")

local WeaponReroll = Rerolls.specreroll
local TraitReroll = Rerolls.traitreroll
local AuraReroll = Rerolls.aurareroll
local BuffReroll = Rerolls.buffreroll
local FaceReroll = Rerolls.facereroll
local HeightReroll = Rerolls.heightreroll
local FlowReroll = Rerolls.flowreroll
local RollBack = Rerolls.KeybindChange
local RedeemAward = ReplicatedStorage.Tasks.RedeemAward

local WeaponConnection
local TraitConnection
local FlowConnection
local BuffConnection
local FaceConnection
local HeightConnection

local CurrentWeapons = {}
for _, weapon in ReplicatedStorage.Specs:GetChildren() do
    if not weapon:IsA("Folder") then
        table.insert(CurrentWeapons, weapon.Name)
    end
end
table.sort(CurrentWeapons)

local CurrentTraits = {}
for _, trait in ReplicatedStorage.Specs.Traits:GetChildren() do
    table.insert(CurrentTraits, trait.Name)
end
table.sort(CurrentTraits)

local SelectedWeapon = nil
local SelectedTrait = nil
local ActualColor = nil
local SelectedType = nil

local CurrentTypes = {"speed", "power", "hitbox", "cooldown", "stamina"}
local CurrentFaces = {"NAGI", "ANRI", "SILVA", "RIN"}
local CurrentHeights = {"5'3", "5'4", "5'5", "5'6", "5'7", "5'8", "5'9", "6'0", "6'1", "6'2", "6'3"}

local function hasDesiredColor(flowMode, flowColor, Character)
    local r = math.floor(Character.AuraColour.Red.Value * 255)
    local g = math.floor(Character.AuraColour.Green.Value * 255)
    local b = math.floor(Character.AuraColour.Blue.Value * 255)
    local targetR = math.floor(flowColor[1] * 255)
    local targetG = math.floor(flowColor[2] * 255)
    local targetB = math.floor(flowColor[3] * 255)

    if flowMode == "Exact" then
        return r == targetR and g == targetG and b == targetB
    elseif flowMode == "SameOrUnder" then
        return r <= targetR and g <= targetG and b <= targetB
    end
end

local function RejoinAndRollback(rollingType, instanceName, flowMode, flowColor)
    warn('rejoining')

    local args = {
        [1] = "Right",
        [2] = "F\255"
    }

    Rerolls:WaitForChild("KeybindChange"):FireServer(unpack(args))

    local teleport_code = string.format([[
        getgenv().rollingType = %q
        getgenv().instanceName = %q
        getgenv().flowMode = %q
        getgenv().flowColor = { %s }
        loadstring(game:HttpGet("https://raw.githubusercontent.com/9zla/UntitledHub/main/main.lua"))()

    ]], rollingType or "", instanceName or "", flowMode or "", flowColor and string.format("%s, %s, %s", flowColor[1], flowColor[2], flowColor[3]) or "")

    queue_on_teleport(teleport_code)
    game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
end

------------------------------ // Main \\ ------------------------------

local Script = Library:CreateWindow({
    Title = "Untitled Hub | Locked",
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Tabs = {
    Rerolls = Script:AddTab("Rolling"),
    Misc = Script:AddTab("Misc"),
    ["UI Settings"] = Script:AddTab("UI Settings"),
    PlayerInfo = Script:AddTab("Player Info")
}

local RerollTab = Tabs.Rerolls
local MiscTab = Tabs.Misc
local Settings = Tabs["UI Settings"]
local PlayerInfo = Tabs.PlayerInfo

--------------- // Weapon Roll UI \\ ---------------

local RerollWeaponBox = RerollTab:AddLeftGroupbox("Weapon Roll")

RerollWeaponBox:AddDivider()
RerollWeaponBox:AddLabel("Select a weapon from 'Select Weapon' then click 'Weapon Roll'", true)
RerollWeaponBox:AddDivider()

RerollWeaponBox:AddDropdown("Select Weapon", {
    Values = CurrentWeapons,
    Default = 1,
    Multi = false,
    Text = "Select Weapon",
    Tooltip = "Select the weapon you want to roll for",

    Callback = function(Value)
        warn('Selected:', Value)
        SelectedWeapon = Value
    end,
})

RerollWeaponBox:AddDivider()

RerollWeaponBox:AddToggle("Weapon Roll", {
    Text = "Weapon Roll",
    Default = false,
    Tooltip = "Select a weapon before enabling this",
    Callback = function(Value)
        if Value then
            if SelectedWeapon == nil then
                Library:Notify("Select a weapon first!")
                return
            end
            if Player.Backpack:FindFirstChild(SelectedWeapon) then
                Library:Notify("You already have " .. SelectedWeapon)
                return
            end

            Library:Notify("Weapon Reroll Started || Rolling For: " .. SelectedWeapon)

            WeaponConnection = Player.Backpack.ChildAdded:Connect(function(NewWeapon)
                print('Recieved Weapon: ' .. NewWeapon.Name)
                if NewWeapon.Name == SelectedWeapon then
                    warn("Got Weapon: ".. NewWeapon.Name)
                    WeaponConnection:Disconnect()
                    getgenv().rollingType = nil
                    getgenv().instanceName = nil
                    Library:Notify("Got Weapon:" .. '' .. NewWeapon.Name .. " || " .. "Rejoining")
                    queue_on_teleport('loadstring(game:HttpGet("https://raw.githubusercontent.com/9zla/UntitledHub/main/main.lua"))()')
                    task.wait(3)
                    game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
                    return
                else
                    if Player.Character:WaitForChild("RankSystem").Yen.Value < 3000 then
                        RejoinAndRollback("Weapon", SelectedWeapon)
                        return
                    else
                        WeaponReroll:FireServer()
                    end
                end
            end)
            WeaponReroll:FireServer()
        else
            if WeaponConnection then
                warn("Weapon Reroll Stopped")
                WeaponConnection:Disconnect()
                WeaponConnection = nil
                Library:Notify("Weapon Reroll Stopped")
            end
        end
    end
})

RerollWeaponBox:AddDivider()

--------------- // Trait Roll UI \\ ---------------

local RerollTraitBox = RerollTab:AddLeftGroupbox("Trait Roll")

RerollTraitBox:AddDivider()
RerollTraitBox:AddLabel("Select a trait from 'Select Trait' then click 'Trait Roll'", true)
RerollTraitBox:AddDivider()

RerollTraitBox:AddDropdown("Select Trait", {
    Values = CurrentTraits,
    Default = 1,
    Multi = false,
    Text = "Select Trait",
    Tooltip = "Select the trait you want to roll for",

    Callback = function(Value)
        warn('Selected:', Value)
        SelectedTrait = Value
    end,
})

RerollTraitBox:AddDivider()

RerollTraitBox:AddToggle("Trait Roll", {
    Text = "Trait Roll",
    Default = false,
    Tooltip = "Select a trait before enabling this",
    Callback = function(Value)
        if Value then

            if SelectedTrait == nil then
                Library:Notify("Select a trait first!")
                return
            end

            if Player.Backpack.Trait:FindFirstChild(SelectedTrait) then
                Library:Notify("You already have " .. SelectedTrait)
                return
            end

            Library:Notify("Trait Reroll Started || Rolling For: " .. SelectedTrait)

            TraitConnection = Player.Backpack.Trait.ChildAdded:Connect(function(NewTrait)
                print('Recieved Trait: ' .. NewTrait.Name)
                if NewTrait.Name == SelectedTrait then
                    warn("Got Trait: ".. NewTrait.Name)
                    TraitConnection:Disconnect()
                    getgenv().rollingType = nil
                    getgenv().instanceName = nil
                    Library:Notify("Got Trait:" .. '' .. NewTrait.Name .. " || " .. "Rejoining")
                    task.wait(3)
                    queue_on_teleport('loadstring(game:HttpGet("https://raw.githubusercontent.com/9zla/UntitledHub/main/main.lua"))()')
                    game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
                    return
                else
                    if Player.Character:WaitForChild("RankSystem").Yen.Value < 3000 then
                        RejoinAndRollback("Trait", SelectedTrait)
                        return
                    else
                        TraitReroll:FireServer()
                    end
                end
            end)
            TraitReroll:FireServer()
        else
            if TraitConnection then
                warn("Trait Reroll Stopped")
                TraitConnection:Disconnect()
                TraitConnection = nil
                Library:Notify("Trait Reroll Stopped")
            end
        end
    end
})

RerollTraitBox:AddDivider()

---

--------------- // Flow Roll UI \\ ---------------

local RerollFlowBox = RerollTab:AddRightGroupbox("Flow roll")

local SelectedFlowColor = Color3.new(1, 1, 1)
local FlowConnection

RerollFlowBox:AddDivider()
RerollFlowBox:AddLabel("Select a color then enable Exact Color", true)
RerollFlowBox:AddDivider()

-- Color Picker (only stores the value now)
RerollFlowBox:AddLabel("Select flow color"):AddColorPicker("Select flow color", {
    Default = SelectedFlowColor,
    Title = "Select flow color then select the type of roll",
    Transparency = 0,

    Callback = function(Value)
        SelectedFlowColor = Value
        ActualColor = Value
    end,
})

RerollFlowBox:AddDivider()

local ExactColorToggle
local SameOrUnderToggle

local function toggleFlowRoll(state, mode)
    if state then
        local flowColorTable = {SelectedFlowColor.R, SelectedFlowColor.G, SelectedFlowColor.B}
        if hasDesiredColor(mode, flowColorTable, Character) then
            Library:Notify("You already have that flow color or a better one.")
            if mode == "Exact" then
                ExactColorToggle:SetValue(false)
            elseif mode == "SameOrUnder" then
                SameOrUnderToggle:SetValue(false)
            end
            return
        end

        -- Ensure only one toggle is active at a time
        if mode == "Exact" and SameOrUnderToggle:GetValue() then
            SameOrUnderToggle:SetValue(false)
        elseif mode == "SameOrUnder" and ExactColorToggle:GetValue() then
            ExactColorToggle:SetValue(false)
        end

        getgenv().rollingType = "Flow"
        getgenv().flowMode = mode
        getgenv().flowColor = flowColorTable

        Library:Notify("Flow Reroll Started || Rolling For: " .. mode)
        FlowReroll:FireServer()

        FlowConnection = Character.AuraColour.Red:GetPropertyChangedSignal("Value"):Connect(function()
            if hasDesiredColor(mode, flowColorTable, Character) then
                FlowConnection:Disconnect()
                FlowConnection = nil
                getgenv().rollingType = nil
                getgenv().flowMode = nil
                getgenv().flowColor = nil
                Library:Notify("Got Flow Color || Rejoining")
                task.wait(3)
                queue_on_teleport('loadstring(game:HttpGet("https://raw.githubusercontent.com/9zla/UntitledHub/main/main.lua"))()')
                game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
            else
                if Player.Character:WaitForChild("RankSystem").Yen.Value < 1000 then
                    RejoinAndRollback("Flow", nil, mode, flowColorTable)
                else
                    FlowReroll:FireServer()
                end
            end
        end)
    else
        if FlowConnection then
            FlowConnection:Disconnect()
            FlowConnection = nil
            getgenv().rollingType = nil
            getgenv().flowMode = nil
            getgenv().flowColor = nil
            Library:Notify("Flow Reroll Stopped")
        end
    end
end

-- Exact Color Toggle
ExactColorToggle = RerollFlowBox:AddToggle("Exact Color", {
    Text = "Exact Color",
    Default = false,
    Tooltip = "Rolls until you get the exact flow color you picked",
    Callback = function(State)
        toggleFlowRoll(State, "Exact")
    end,
})

-- Same or Under Toggle
SameOrUnderToggle = RerollFlowBox:AddToggle("Same or under", {
    Text = "Same or under",
    Default = false,
    Tooltip = "Rolls until you get the same flow color you picked or lower",
    Callback = function(State)
        toggleFlowRoll(State, "SameOrUnder")
    end,
})


--------------- // Buff Roll UI \\ ---------------

local RerollBuffBox = RerollTab:AddRightGroupbox("Buff Roll")

RerollBuffBox:AddDivider()
RerollBuffBox:AddLabel("Select the type of flow, then select the number and select the type of roll", true)
RerollBuffBox:AddDivider()

RerollBuffBox:AddDropdown("Select Flow Type", {
    Values = CurrentTypes,
    Default = 1,
    Multi = false,
    Text = "Select flow type",
    Tooltip = "Select the type of flow you want to roll for",

    Callback = function(Value)
        warn('Selected:', Value)
        SelectedType = Value
    end,
})

RerollBuffBox:AddDivider()

RerollBuffBox:AddToggle("15% Buff", {
    Text = "15% Buff",
    Default = false,
    Tooltip = "Rolls until you get 15% of the flow type you selected",

    Callback = function(Value)
    end,
})

RerollBuffBox:AddToggle("Same or under", {
    Text = "Same or above",
    Default = false,
    Tooltip = "Rolls until you get at least the number you selected or more",

    callback = function(Value)
    end,
})

RerollBuffBox:AddDivider()

--------------- // Face Roll UI \\ ---------------

local RerollFaceBox = RerollTab:AddLeftGroupbox("Face Roll")

RerollFaceBox:AddDivider()
RerollFaceBox:AddLabel("Select the face you want, then click 'Face Roll'", true)
RerollFaceBox:AddDivider()

RerollFaceBox:AddDropdown("Select Face", {
    Values = CurrentFaces,
    Default = 1,
    Multi = false,
    Text = "Select face",
    Tooltip = "Select the face you want to roll for",

    Callback = function(Value)
        warn('Selected:', Value)
        SelectedType = Value
    end,
})

RerollFaceBox:AddDivider()

RerollFaceBox:AddToggle("Face Roll", {
    Text = "Face Roll",
    Default = false,
    Tooltip = "Rolls until you get the face you selected",

    Callback = function(Value)
    end,
})

RerollFaceBox:AddDivider()

--------------- // Height Roll UI \\ ---------------

local RerollHeightBox = RerollTab:AddRightGroupbox("Height Roll")

RerollHeightBox:AddDivider()
RerollHeightBox:AddLabel("Select the height you want, then click 'Height Roll'", true)
RerollHeightBox:AddDivider()

RerollHeightBox:AddDropdown("Select Height", {
    Values = CurrentHeights,
    Default = 1,
    Multi = false,
    Text = "Select height",
    Tooltip = "Select the height you want to roll for",

    Callback = function(Value)
        warn('Selected:', Value)
        SelectedType = Value
    end,
})

RerollHeightBox:AddDivider()

RerollHeightBox:AddToggle("Height Roll", {
    Text = "Height Roll",
    Default = false,
    Tooltip = "Rolls until you get the height you selected",

    Callback = function(Value)
    end,
})

RerollHeightBox:AddDivider()

------------------------------ // Settings \\ ------------------------------


local FrameTimer = tick()
local FrameCounter = 0
local FPS = 60

Library:OnUnload(function()
    Library.Unloaded = true
end)

local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu")

MenuGroup:AddButton("Unload", function()
    Library:Unload()
end)

MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "End", NoUI = true, Text = "Menu keybind" })

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })

ThemeManager:SetFolder("MyScriptHub")
SaveManager:SetFolder("MyScriptHub/specific-game")

SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])

SaveManager:LoadAutoloadConfig()

------------------------------ // Auto-Resume Rolling After Rejoin \\ ------------------------------

task.defer(function()
    local rollingType = getgenv().rollingType
    local instanceName = getgenv().instanceName
    local flowMode = getgenv().flowMode
    local flowColor = getgenv().flowColor

    if rollingType then
        
        -- Weapon Rolling
        if rollingType == "Weapon" then
            warn('Was Rolling For: ' .. instanceName)
            SelectedWeapon = instanceName
            WeaponConnection = Player.Backpack.ChildAdded:Connect(function(NewWeapon)
                print('Received Weapon: ' .. NewWeapon.Name)
                if NewWeapon.Name == instanceName then
                    warn("Got Weapon: " .. NewWeapon.Name)
                    WeaponConnection:Disconnect()
                    getgenv().rollingType = nil
                    getgenv().instanceName = nil
                    Library:Notify("Got Weapon: " .. instanceName .. ' || Rejoining')
                    task.wait(3)
                    queue_on_teleport('loadstring(game:HttpGet("https://raw.githubusercontent.com/9zla/UntitledHub/main/main.lua"))()')
                    game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
                else
                    if Player.Character:WaitForChild("RankSystem").Yen.Value < 3000 then
                        RejoinAndRollback("Weapon", instanceName)
                    else
                        WeaponReroll:FireServer()
                    end
                end
            end)
            WeaponReroll:FireServer()

        -- Trait Rolling
        elseif rollingType == "Trait" then
            warn('Was Rolling For: ' .. instanceName)
            SelectedTrait = instanceName
            TraitConnection = Player.Backpack.Trait.ChildAdded:Connect(function(NewTrait)
                print('Received Trait: ' .. NewTrait.Name)
                if NewTrait.Name == instanceName then
                    warn("Got Trait: " .. NewTrait.Name)
                    TraitConnection:Disconnect()
                    getgenv().rollingType = nil
                    getgenv().instanceName = nil
                    Library:Notify("Got Trait: " .. instanceName .. ' || Rejoining')
                    task.wait(3)
                    queue_on_teleport('loadstring(game:HttpGet("https://raw.githubusercontent.com/9zla/UntitledHub/main/main.lua"))()')
                    game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
                else
                    if Player.Character:WaitForChild("RankSystem").Yen.Value < 3000 then
                        RejoinAndRollback("Trait", instanceName)
                    else
                        TraitReroll:FireServer()
                    end
                end
            end)
            TraitReroll:FireServer()

        -- Flow Rolling
        elseif rollingType == "Flow" and flowMode and flowColor then
            warn('Was Rolling For Flow Color: ' .. table.concat(flowColor, ", "))
            SelectedFlowColor = flowColor
            
            FlowConnection = Character.AuraColour.Red:GetPropertyChangedSignal("Value"):Connect(function()
                if hasDesiredColor(flowMode, flowColor, Character) then
                    FlowConnection:Disconnect()
                    getgenv().rollingType = nil
                    getgenv().flowMode = nil
                    getgenv().flowColor = nil
                    Library:Notify(
                        string.format(
                            "Got Flow Color: R:%d G:%d B:%d || Rejoining",
                            flowColor[1] * 255,
                            flowColor[2] * 255,
                            flowColor[3] * 255
                        )
                    )
                    task.wait(3)
                    queue_on_teleport('loadstring(game:HttpGet("https://raw.githubusercontent.com/9zla/UntitledHub/main/main.lua"))()')
                    game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
                else
                    if Player.Character:WaitForChild("RankSystem").Yen.Value < 1000 then
                        RejoinAndRollback("Flow", nil, flowMode, flowColor)
                    else
                        FlowReroll:FireServer()
                    end
                end
            end)

            FlowReroll:FireServer()
        end
    end
end)




------------------------------ // Misc \\ ------------------------------

-- Unlock All Emotes

local UnlockAllEmotes = MiscTab:AddLeftGroupbox("Unlock All Emotes")

UnlockAllEmotes:AddDivider()

UnlockAllEmotes:AddLabel("Click the button below to unlock all emotes", true)

UnlockAllEmotes:AddDivider()

UnlockAllEmotes:AddButton("Unlock All Emotes", function()

    local EmoteArguments = {"BarouPack", "IsagiPack", "LockedtinesEmotepack", "ReoPack"}

    for _, emote in EmoteArguments do
        ReplicatedStorage.Lockedtines.ExclusiveAdd:FireServer(emote)
    end

    Library:Notify("Unlocked All Emotes!")
end)

UnlockAllEmotes:AddDivider()

-- Redeem All Tasks

local AutoRedeemTasks = MiscTab:AddRightGroupbox("Auto Redeem Tasks")

AutoRedeemTasks:AddDivider()

AutoRedeemTasks:AddLabel("Click the button below to auto redeem tasks", true)

AutoRedeemTasks:AddDivider()

AutoRedeemTasks:AddButton("Auto Redeem Tasks", function()

    for Task = 1, 6 do
        ReplicatedStorage.Tasks.RedeemAward:FireServer(Task)
    end

    Library:Notify("Redeemed Tasks Successfully!")
end)

AutoRedeemTasks:AddDivider()

-- Rollback

local RollbackBox = MiscTab:AddLeftGroupbox("Rollback")

RollbackBox:AddDivider()

RollbackBox:AddLabel("Click the button below to rollback and automatically rejoin", true)

RollbackBox:AddDivider()

RollbackBox:AddButton("Rollback", function()

    Library:Notify("Successfully Rolledback, Rejoining")

    task.wait(3)

    local args = {
        [1] = "Right",
        [2] = "F\255"
    }
    
    Rerolls:WaitForChild("KeybindChange"):FireServer(unpack(args))

    queue_on_teleport('loadstring(game:HttpGet("https://raw.githubusercontent.com/9zla/UntitledHub/main/main.lua"))()')

    game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
end)

RollbackBox:AddDivider()

-- Rejoin

local RejoinBox = MiscTab:AddRightGroupbox("Rejoin")

RejoinBox:AddDivider()

RejoinBox:AddLabel("Click the button below to rejoin", true)

RejoinBox:AddDivider()

RejoinBox:AddButton("Rejoin", function()

    Library:Notify("Rejoining")

    task.wait(3)

    queue_on_teleport('loadstring(game:HttpGet("https://raw.githubusercontent.com/9zla/UntitledHub/main/main.lua"))()')

    game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
end)

RejoinBox:AddDivider()

local DupeSlotBox = MiscTab:AddLeftGroupbox("Dupe Slot")
DupeSlotBox:AddDivider()
DupeSlotBox:AddLabel("")


------------------------------ // Player Info \\ ------------------------------

local Information = PlayerInfo:AddLeftGroupbox("Player Information")
Information:AddDivider()

-- Yen
local PlayerYenText = Information:AddLabel("Yen: " .. Character.RankSystem.Yen.Value)
local function updateYen()
    PlayerYenText:SetText("Yen: " .. tostring(Character.RankSystem.Yen.Value))
end
Character.RankSystem.Yen.Changed:Connect(updateYen)
updateYen()

-- Weapon

local PlayerWeaponText = Information:AddLabel("Weapon: " .. Player.Backpack:FindFirstChildWhichIsA("NumberValue").Name)
local function UpdatedWeapon()
    PlayerWeaponText:SetText("Yen: " .. Player.Backpack:FindFirstChildWhichIsA("NumberValue").Name)
end


local PlayerTraitText = Information:AddLabel("Trait: " .. Player.Backpack.Trait:FindFirstChildWhichIsA("NumberValue").Name)

local function UpdatedTrait()
    PlayerTraitText:SetText("Trait: " .. Player.Backpack.Trait:FindFirstChildWhichIsA("NumberValue").Name)
end

Player.Backpack.ChildAdded:Connect(function()
    UpdatedWeapon()
end)

Player.Backpack.Trait.ChildAdded:Connect(function()
    UpdatedTrait()
end)



-- Elo
local PlayerEloText = Information:AddLabel("Elo: " .. Character.RankSystem.Elo.Value)
local function updateElo()
    PlayerEloText:SetText("Elo: " .. tostring(Character.RankSystem.Elo.Value))
end
Character.RankSystem.Elo.Changed:Connect(updateElo)
updateElo()

-- Flow Color
local FlowColorLabel = Information:AddLabel("Flow Color: ")
local function updateFlowColor()
    local r = math.clamp(math.floor(Character.AuraColour.Red.Value * 255), 0, 255)
    local g = math.clamp(math.floor(Character.AuraColour.Green.Value * 255), 0, 255)
    local b = math.clamp(math.floor(Character.AuraColour.Blue.Value * 255), 0, 255)
    FlowColorLabel:SetText(("Flow Color: %d, %d, %d"):format(r, g, b))
end
Character.AuraColour.Red.Changed:Connect(updateFlowColor)
Character.AuraColour.Green.Changed:Connect(updateFlowColor)
Character.AuraColour.Blue.Changed:Connect(updateFlowColor)
updateFlowColor()

-- Flow Buff Value

local function formatPercent(value)
    return string.format("%.1f%%", value * 10) -- keeps one decimal place
end

local FlowBuffLabel = Information:AddLabel(
    "Flow Buff: " .. Character.AuraColour.Buff.Value)

local FlowBuffValueLabel = Information:AddLabel(
    "Flow Buff Value: " .. formatPercent(tonumber(Character.AuraColour.Buff:GetAttribute("BuffValue")) or 0)
)

local function updateFlowBuff()
    local buffValue = Character.AuraColour.Buff.Value
    local buffAttrValue = tonumber(Character.AuraColour.Buff:GetAttribute("BuffValue")) or 0

    FlowBuffLabel:SetText("Flow Buff: " .. buffValue)
    FlowBuffValueLabel:SetText("Flow Buff Value: " .. formatPercent(buffAttrValue))
end

-- Listen to both property changes and attribute changes
Character.AuraColour.Buff:GetPropertyChangedSignal("Value"):Connect(updateFlowBuff)
Character.AuraColour.Buff:GetAttributeChangedSignal("BuffValue"):Connect(updateFlowBuff)

updateFlowBuff()


-- Flow Type
local flowTypeStringValue = Player.Backpack.FlowType:FindFirstChildWhichIsA("StringValue")
local FlowTypeLabel = Information:AddLabel("Flow Type: " .. (flowTypeStringValue and flowTypeStringValue.Name or "N/A"))
local function updateFlowType()
    local currentFlowTypeStringValue = Player.Backpack.FlowType:FindFirstChildWhichIsA("StringValue")
    local flowName = currentFlowTypeStringValue and currentFlowTypeStringValue.Name or "N/A"
    FlowTypeLabel:SetText("Flow Type: " .. flowName)
end
Player.Backpack.FlowType.ChildAdded:Connect(updateFlowType)
Player.Backpack.FlowType.ChildRemoved:Connect(updateFlowType)
updateFlowType()

-- Height
local HeightLabel = Information:AddLabel("Height: ")
local function updateHeight()
    local heightValue = Character.HeightValue.Value
    local totalInches = 62 + heightValue
    local feet = math.floor(totalInches / 12)
    local inches = totalInches % 12
    HeightLabel:SetText(("Height: %d'%d\""):format(feet, inches))
end
Character.HeightValue.Changed:Connect(updateHeight)
updateHeight()

Information:AddDivider()
