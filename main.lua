local asdkasodpkasdpoaksdopaskdasopkdaspo = 8079445823

if game.Players.LocalPlayer.UserId ~= asdkasodpkasdpoaksdopaskdasopkdaspo then
    game.Players.LocalPlayer:Kick("You are not whitelisted")
    return
end

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
        table.sort(CurrentWeapons)
    end
end

local CurrentTraits = {}
for _, trait in ReplicatedStorage.Specs.Traits:GetChildren() do
    table.insert(CurrentTraits, trait.Name)
    table.sort(CurrentTraits)
end

local SelectedWeapon = nil
local SelectedTrait = nil
local ActualColor = nil
local SelectedType = nil

local CurrentTypes = {"speed", "power", "hitbox", "cooldown", "stamina"}
local CurrentFaces = {"NAGI", "ANRI", "SILVA", "RIN"}
local CurrentHeights = {"5'3", "5'4", "5'5", "5'6", "5'7", "5'8", "5'9", "6'0", "6'1", "6'2", "6'3"}

local function RejoinAndRollback(rollingType, instanceName)
    warn('rejoining')

    local args = {
        [1] = "Right",
        [2] = "F\255"
    }

    Rerolls:WaitForChild("KeybindChange"):FireServer(unpack(args))

    local teleport_code = string.format([[
        getgenv().rollingType = %q
        getgenv().instanceName = %q
        loadstring(game:HttpGet("https://raw.githubusercontent.com/9zla/UntitledHub/a3499b9019886beab10113ab64f889353d0a605e/main.lua"))()
    ]], rollingType or "", instanceName or "")

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
}

local RerollTab = Tabs.Rerolls
local MiscTab = Tabs.Misc
local Settings = Tabs["UI Settings"]

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
            WeaponConnection = Player.Backpack.ChildAdded:Connect(function(NewWeapon)
                print('Recieved Weapon: ' .. NewWeapon.Name)
                if NewWeapon.Name == SelectedWeapon then
                    warn("Got Weapon: ".. NewWeapon.Name)
                    WeaponConnection:Disconnect()
                    return
                else
                    if Player.Character:WaitForChild("RankSystem").Yen.Value < 15000 then
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
            end
        end
    end
})

RerollWeaponBox:AddDivider()

--------------- // Trait Roll UI \\ ---------------

local RerollTraitBox = RerollTab:AddLeftGroupbox("Trait Roll")

RerollTraitBox:AddDivider()
RerollTraitBox:AddLabel("Select a weapon from 'Select Trait' then click 'Trait Roll'", true)
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
            TraitConnection = Player.Backpack.ChildAdded:Connect(function(NewTrait)
                print('Recieved Trait: ' .. NewTrait.Name)
                if NewTrait.Name == SelectedTrait then
                    warn("Got Trait: ".. NewTrait.Name)
                    TraitConnection:Disconnect()
                    return
                else
                    if Player.Character:WaitForChild("RankSystem").Yen.Value < 15000 then
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
            end
        end
    end
})

RerollTraitBox:AddDivider()

--------------- // Flow Roll UI \\ ---------------

local RerollFlowBox = RerollTab:AddRightGroupbox("Flow roll")

RerollFlowBox:AddDivider()
RerollFlowBox:AddLabel("Select a color then select the type of roll", true)
RerollFlowBox:AddDivider()
RerollFlowBox:AddLabel("Select flow color"):AddColorPicker("Select flow color", {
    Default = Color3.new(1, 1, 1),
    Title = "Select flow color then select the type of roll",
    Transparency = 0,

    Callback = function(Value)
        ActualColor = Value
    end,
})

RerollFlowBox:AddDivider()

RerollFlowBox:AddToggle("Exact Color", {
    Text = "Exact Color",
    Default = false,
    Tooltip = "Rolls until you get the exact flow color you picked, select a flow color before enabling this",

    Callback = function(Value)
    end,
})

RerollFlowBox:AddToggle("Same or under", {
    Text = "Same or under",
    Default = false,
    Tooltip = "Rolls until you get the same flow color you picked or lower, select a flow color before enabling this",

    callback = function(Value)
    end,
})

RerollTraitBox:AddDivider()

--------------- // Buff Roll UI \\ ---------------

local RerollBuffBox = RerollTab:AddRightGroupbox("Buff Roll")

RerollBuffBox:AddDivider()
RerollBuffBox:AddLabel("Select the type of flow, then select the number and select the type of roll", true)
RerollBuffBox:AddDivider()

RerollBuffBox:AddDropdown("Select Weapon", {
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

Library:SetWatermarkVisibility(true)

local FrameTimer = tick()
local FrameCounter = 0
local FPS = 60

local WatermarkConnection = game:GetService("RunService").RenderStepped:Connect(function()
    FrameCounter = FrameCounter + 1

    if (tick() - FrameTimer) >= 1 then
        FPS = FrameCounter
        FrameTimer = tick()
        FrameCounter = 0
    end

    Library:SetWatermark(
        ("Untitled Hub | %s fps | %s ms"):format(
            math.floor(FPS),
            math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
        )
    )
end)

Library.KeybindFrame.Visible = true

Library:OnUnload(function()
    WatermarkConnection:Disconnect()
    print("Unloaded!")
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

-- Auto-resume rolling for Weapon or Trait after rejoining
task.defer(function()
    local rollingType = getgenv().rollingType
    local instanceName = getgenv().instanceName

    if rollingType and instanceName then
        if rollingType == "Weapon" then
            warn('Was Rolling For: ' .. instanceName)
            SelectedWeapon = instanceName
            -- Corrected function for dropdowns: SetValue as shown in the example script
            Library:SetValue("Select Weapon", instanceName)
            -- This is the fix! It sets the toggle and fires the callback.
            Library:SetValue("Weapon Roll", true, true)
        elseif rollingType == "Trait" then
            warn('Was Rolling For: ' .. instanceName)
            SelectedTrait = instanceName
            -- Corrected function for dropdowns: SetValue as shown in the example script
            Library:SetValue("Select Trait", instanceName)
            -- This is the fix! It sets the toggle and fires the callback.
            Library:SetValue("Trait Roll", true, true)
        end
    end
end)

------------------------------ // Misc \\ ------------------------------
