------------------------------ // Library \\ ------------------------------

local repo = "https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

------------------------------ // Variables \\ ------------------------------

local Player = game:GetService("Players").LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
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
local FastWeaponConnection
local FastTraitConnection
local FastFlowConnection

local WebhookURL = ""

getgenv().WeaponWebhookNotification = false

getgenv().TraitWebhookNotification = false

getgenv().FlowWebhookNotification = false

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

local SelectedWeapon
local SelectedTrait
local ActualColor
local SelectedType
local CurrentTypes = { "speed", "power", "hitbox", "cooldown", "stamina" }
local CurrentFaces = { "NAGI", "ANRI", "SILVA", "RIN" }
local CurrentHeights = { "5'3", "5'4", "5'5", "5'6", "5'7", "5'8", "5'9", "6'0", "6'1", "6'2", "6'3" }

local function RejoinAndRollback(rollingType, instanceName)
	local args = { [1] = "Right", [2] = "F\255" }
	Rerolls:WaitForChild("KeybindChange"):FireServer(unpack(args))
	local teleport_code = string.format(
		[[
        getgenv().rollingType = %q
        getgenv().instanceName = %q
        loadstring(game:HttpGet("https://raw.githubusercontent.com/9zla/UntitledHub/main/main.lua"))()
    ]],
		rollingType or "",
		instanceName or ""
	)
	queue_on_teleport(teleport_code)
	game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
end

local function FastRejoinAndRollbacK(FastRollingType, FastInstanceName)
	local args = { [1] = "Right", [2] = "F\255" }
	Rerolls:WaitForChild("KeybindChange"):FireServer(unpack(args))

	local teleport_code = string.format(
		[[
        getgenv().FastRollingType = %q
        getgenv().FastInstanceName = %q
        loadstring(game:HttpGet("https://raw.githubusercontent.com/9zla/UntitledHub/main/main.lua"))()
    ]],
		FastRollingType or "",
		FastInstanceName or ""
	)
	queue_on_teleport(teleport_code)
	TeleportService:Teleport(game.PlaceId, Player)
end

local HttpService = game:GetService("HttpService")

local requestFunc = (syn and syn.request)
	or (http and http.request)
	or http_request
	or request
	or (fluxus and fluxus.request)

local WebhookURL = "https://discord.com/api/webhooks/..."

function SendWebhook(data)
	if not requestFunc then
		return
	end
	if not WebhookURL or WebhookURL == "" then
		return
	end

	local embed = {
		title = data.title or "Untitled Title",
		description = data.description or "No Description",
		color = 0x6a2feb,
		footer = {
			text = data.footer or "",
		},
		author = {
			name = data.author or "",
			icon_url = data.authorIcon or "",
		},
	}

	local payload = {
		content = "@everyone",
		embeds = { embed },
	}

	pcall(function()
		requestFunc({
			Url = WebhookURL,
			Method = "POST",
			Headers = {
				["Content-Type"] = "application/json",
			},
			Body = HttpService:JSONEncode(payload),
		})
	end)
end

------------------------------ // Main \\ ------------------------------

local Script = Library:CreateWindow({
	Title = "Untitled Hub | Locked",
	Center = true,
	AutoShow = true,
	TabPadding = 8,
	MenuFadeTime = 0.2,
})

local Tabs = {
	Rerolls = Script:AddTab("Rolling"),
	Misc = Script:AddTab("Misc"),
	["UI Settings"] = Script:AddTab("UI Settings"),
}

local RerollTab = Tabs.Rerolls
local MiscTab = Tabs.Misc
local Settings = Tabs["UI Settings"]

--------------- // Webhook URL UI \\ ---------------

local WebhookBox = RerollTab:AddLeftGroupbox("Webhook")

WebhookBox:AddDivider()

WebhookBox:AddLabel(
	"If you want to get notified when you get the weapon / trait / flow you were rolling for, paste your webhook URL below",
	true
)

WebhookBox:AddDivider()

WebhookBox:AddInput("WebhookURL", {
	Default = "",
	Numeric = false,
	Finished = true,
	Text = "Webhook URL",
	Placeholder = "Paste Webhook URL Here",
	Callback = function(input)
		local prefix = "https://discord.com/api/webhooks/"

		if string.sub(input, 1, #prefix) == prefix then
			WebhookURL = input
			Library:Notify("Successfully set Webhook URL")
		else
			Library:Notify("Invalid Webhook URL")
		end
	end,
})

WebhookBox:AddDivider()

--------------- // Player Information UI \\ ---------------

local Information = RerollTab:AddRightGroupbox("Player Information")

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
	PlayerWeaponText:SetText("Weapon: " .. Player.Backpack:FindFirstChildWhichIsA("NumberValue").Name)
end

local PlayerTraitText =
	Information:AddLabel("Trait: " .. Player.Backpack.Trait:FindFirstChildWhichIsA("NumberValue").Name)

local function UpdatedTrait()
	PlayerTraitText:SetText("Trait: " .. Player.Backpack.Trait:FindFirstChildWhichIsA("NumberValue").Name)
end

Player.Backpack.ChildAdded:Connect(function()
	UpdatedWeapon()
end)

Player.Backpack.Trait.ChildAdded:Connect(function()
	UpdatedTrait()
end)

-- Flow Color
local FlowColorLabel = Information:AddLabel("Flow Color: ")
local function updateFlowColor()
	local r = math.floor(Character.AuraColour.Red.Value * 255)
	local g = math.floor(Character.AuraColour.Green.Value * 255)
	local b = math.floor(Character.AuraColour.Blue.Value * 255)
	FlowColorLabel:SetText(("Flow Color: %d, %d, %d"):format(r, g, b))
end
Character.AuraColour.Red.Changed:Connect(updateFlowColor)
updateFlowColor()

-- Flow Buff Value

local function formatPercent(value)
	return string.format("%.1f%%", value * 10) -- keeps one decimal place
end

local FlowBuffLabel = Information:AddLabel("Flow Buff: " .. Character.AuraColour.Buff.Value)

local FlowBuffValueLabel = Information:AddLabel(
	"Flow Buff Value: " .. formatPercent(tonumber(Character.AuraColour.Buff:GetAttribute("BuffValue")) or 0)
)

local function updateFlowBuff()
	local buffValue = Character.AuraColour.Buff.Value
	local buffAttrValue = tonumber(Character.AuraColour.Buff:GetAttribute("BuffValue")) or 0

	FlowBuffLabel:SetText("Flow Buff: " .. buffValue)
	FlowBuffValueLabel:SetText("Flow Buff Value: " .. formatPercent(buffAttrValue))
end

Character.AuraColour.Buff:GetPropertyChangedSignal("Value"):Connect(updateFlowBuff)
Character.AuraColour.Buff:GetAttributeChangedSignal("BuffValue"):Connect(updateFlowBuff)

updateFlowBuff()

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
		SelectedWeapon = Value
		Library:Notify("Selected Weapon: " .. Value)
	end,
})
RerollWeaponBox:AddDivider()
RerollWeaponBox:AddToggle("Weapon Roll", {
	Text = "Weapon Roll",
	Default = false,
	Tooltip = "Select a weapon before enabling this",
	Callback = function(Value)
		if Value then
			if SelectedWeapon == nil or SelectedWeapon == "" then
				Library:Notify("Select a weapon before rolling")
				return
			end

			if Player.Backpack:FindFirstChild(SelectedWeapon) then
				Library:Notify("You already have " .. SelectedWeapon)
				return
			end

			Library:Notify("Weapon Roll Started | Rolling for: " .. SelectedWeapon)

			WeaponConnection = Player.Backpack.ChildAdded:Connect(function(NewWeapon)
				if NewWeapon.Name == SelectedWeapon then
					WeaponConnection:Disconnect()
					WeaponConnection = nil
					getgenv().instanceName = nil
					getgenv().rollingType = nil
					Library:Notify("Got Weapon: " .. NewWeapon.Name .. " | " .. "Rejoining", 2.8)

					if getgenv().WeaponWebhookNotification then
						SendWebhook({
						title = "Weapon Reroll: Successfully Got Weapon",
						description = "**Weapon:** "
							.. SelectedWeapon
							.. "\n**Time:** <t:"
							.. os.time()
							.. ":F> [<t:"
							.. os.time()
							.. ":R>]"
							.. "\n**Username:** "
							.. Player.Name
							.. "\n**DisplayName:** "
							.. Player.DisplayName
							.. "\n**ID:** [`"
							.. Player.UserId
							.. "`]",
						footer = "Untitled Hub: Weapon Reroll [Normal]",
						author = "Untitled Hub | Locked",
					})
					end
					return
				else
					if Player.Character.RankSystem.Yen.Value < 3000 then
						RejoinAndRollback("Weapon", SelectedWeapon)
						WeaponConnection:Disconnect()
						WeaponConnection = nil
						return
					else
						WeaponReroll:FireServer()
					end
				end
			end)
			WeaponReroll:FireServer()
		else
			if WeaponConnection then
				WeaponConnection:Disconnect()
				WeaponConnection = nil
				Library:Notify("Weapon Reroll Stopped")
			end
		end
	end,
})

RerollWeaponBox:AddToggle("Fast Roll", {
	Text = "Fast Roll",
	default = false,
	Tooltip = "Select a weapon before enabling this",
	Callback = function(Value)
		if Value then
			if SelectedWeapon == "" or not SelectedWeapon then
				Library:Notify("Select a weapon before rolling")
				return
			end

			if Player.Backpack:FindFirstChild(SelectedWeapon) then
				Library:Notify("You already have " .. SelectedWeapon)
				return
			end

			Library:Notify("Fast Weapon Roll Started | Rolling for: " .. SelectedWeapon)

			FastWeaponConnection = RunService.RenderStepped:Connect(function()
				if Player.Backpack:FindFirstChild(SelectedWeapon) then
					FastWeaponConnection:Disconnect()
					FastWeaponConnection = nil
					getgenv().FastRollingType = nil
					getgenv().FastInstanceName = nil
					Library:Notify("Got Weapon: " .. SelectedWeapon .. " | " .. "Rejoining", 2.8)
					task.wait(3)
					queue_on_teleport(
						"loadstring(game:HttpGet('https://raw.githubusercontent.com/9zla/UntitledHub/main/main.lua'))()"
					)
				else
					if Character.RankSystem.Yen.Value < 3000 then
						FastWeaponConnection:Disconnect()
						FastWeaponConnection = nil
						Library:Notify("Rollback")
					else
						WeaponReroll:FireServer()
					end
				end
			end)
		else
			if FastWeaponConnection then
				FastWeaponConnection:Disconnect()
				FastWeaponConnection = nil
				Library:Notify("Fast Weapon Reroll Stopped")
			end
		end
	end,
})

RerollWeaponBox:AddToggle("Webhook Notification", {
	Text = "Webhook Notification",
	default = false,
	Tooltip = "Enable this to get notified through webhook when you get the weapon",
	Callback = function(Value)
		if Value then
			if WebhookURL == "" or not WebhookURL then
				Library:Notify("Input a Webhook URL first")
				return
			end

			getgenv().WeaponWebhookNotification = true
			Library:Notify("Weapon Webhook Notification Enabled, you will get notified when you get your weapon")
		else
			if getgenv().WeaponWebhookNotification == true then
				getgenv().WeaponWebhookNotification = false
				Library:Notify(
					"Weapon Webhook Notification Disabled, you will not get notified when you get your weapon"
				)
			end
		end
	end,
})
RerollWeaponBox:AddDivider()

--------------- // Trait Roll UI \\ ---------------
local RerollTraitBox = RerollTab:AddLeftGroupbox("Trait Roll")
RerollTraitBox:AddDivider()
RerollTraitBox:AddLabel("Select a trait from 'Select Trait' then start rolling", true)
RerollTraitBox:AddDivider()
RerollTraitBox:AddDropdown("Select Trait", {
	Values = CurrentTraits,
	Default = 1,
	Multi = false,
	Text = "Select Trait",
	Tooltip = "Select the trait you want to roll for",
	Callback = function(Value)
		SelectedTrait = Value
		Library:Notify("Selected Trait: " .. Value)
	end,
})
RerollTraitBox:AddDivider()
RerollTraitBox:AddToggle("Trait Roll", {
	Text = "Trait Roll",
	Default = false,
	Tooltip = "Select a trait before enabling this",
	Callback = function(Value)
		if Value then
			if SelectedTrait == nil or SelectedTrait == "" then
				Library:Notify("Select a trait before rolling")
				return
			end

			if Player.Backpack.Trait:FindFirstChild(SelectedTrait) then
				Library:Notify("You already have " .. SelectedTrait)
				return
			end

			Library:Notify("Trait Reroll Started | Rolling for: " .. SelectedTrait)

			TraitConnection = Player.Backpack.Trait.ChildAdded:Connect(function(NewTrait)
				if NewTrait.Name == SelectedTrait then
					TraitConnection:Disconnect()
					TraitConnection = nil
					getgenv().instanceName = nil
					getgenv().rollingType = nil
					Library:Notify("Got Trait: " .. NewTrait.Name .. " | " .. "Rejoining", 2.8)
					task.wait(3)
					queue_on_teleport(
						'loadstring(game:HttpGet("https://raw.githubusercontent.com/9zla/UntitledHub/main/main.lua"))()'
					)
					game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
					return
				else
					if Player.Character.RankSystem.Yen.Value < 3000 then
						RejoinAndRollback("Trait", SelectedTrait)
						TraitConnection:Disconnect()
						TraitConnection = nil
						return
					else
						TraitReroll:FireServer()
					end
				end
			end)
			TraitReroll:FireServer()
		else
			if TraitConnection then
				TraitConnection:Disconnect()
				TraitConnection = nil
				getgenv().rollingType = nil
				getgenv().instanceName = nil
				Library:Notify("Trait Reroll Stopped")
			end
		end
	end,
})
RerollTraitBox:AddDivider()

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
		warn("Selected:", Value)
		SelectedType = Value
	end,
})
RerollBuffBox:AddDivider()
RerollBuffBox:AddToggle("15% Buff", {
	Text = "15% Buff",
	Default = false,
	Tooltip = "Rolls until you get 15% of the flow type you selected",
	Callback = function(Value) end,
})
RerollBuffBox:AddToggle("Same or under", {
	Text = "Same or above",
	Default = false,
	Tooltip = "Rolls until you get at least the number you selected or more",
	callback = function(Value) end,
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
		warn("Selected:", Value)
		SelectedType = Value
	end,
})
RerollFaceBox:AddDivider()
RerollFaceBox:AddToggle("Face Roll", {
	Text = "Face Roll",
	Default = false,
	Tooltip = "Rolls until you get the face you selected",
	Callback = function(Value) end,
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
		warn("Selected:", Value)
		SelectedType = Value
	end,
})
RerollHeightBox:AddDivider()
RerollHeightBox:AddToggle("Height Roll", {
	Text = "Height Roll",
	Default = false,
	Tooltip = "Rolls until you get the height you selected",
	Callback = function(Value) end,
})
RerollHeightBox:AddDivider()

------------------------------ // Settings \\ ------------------------------
Library:OnUnload(function()
	Library.Unloaded = true
end)

local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu")

MenuGroup:AddButton("Unload", function()
	Library:Unload()
end)

MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {
	Default = "End",
	NoUI = true,
	Text = "Menu keybind",
})

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

	if rollingType and instanceName then
		if rollingType == "Weapon" then
			Library:Notify("Rolling For: " .. instanceName)
			Options["Select Weapon"]:SetValue(instanceName, true)
			Options["Weapon Roll"]:SetValue(true, true)
			SelectedWeapon = instanceName

			WeaponConnection = Player.Backpack.ChildAdded:Connect(function(NewWeapon)
				if NewWeapon.Name == instanceName then
					WeaponConnection:Disconnect()
					WeaponConnection = nil

					getgenv().rollingType = nil
					getgenv().instanceName = nil

					Library:Notify("Got Weapon: " .. instanceName .. " | " .. "Rejoining", 2.8)

					task.wait(3)

					queue_on_teleport(
						'loadstring(game:HttpGet("https://raw.githubusercontent.com/9zla/UntitledHub/main/main.lua"))()'
					)
					game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
					return
				else
					if Player.Character.RankSystem.Yen.Value < 3000 then
						RejoinAndRollback("Weapon", instanceName)
						WeaponConnection:Disconnect()
						WeaponConnection = nil
						return
					else
						WeaponReroll:FireServer()
					end
				end
			end)
			WeaponReroll:FireServer()
		elseif rollingType == "Trait" then
			Library:Notify("Rolling For: " .. instanceName)
			Options["Select Trait"]:SetValue(instanceName, true)
			Options["Trait Roll"]:SetValue(true, true)
			SelectedTrait = instanceName

			TraitConnection = Player.Backpack.Trait.ChildAdded:Connect(function(NewTrait)
				if NewTrait.Name == instanceName then
					TraitConnection:Disconnect()
					TraitConnection = nil

					getgenv().rollingType = nil
					getgenv().instanceName = nil

					Library:Notify("Got Trait: " .. instanceName .. " | " .. "Rejoining", 2.8)

					task.wait(3)

					queue_on_teleport(
						'loadstring(game:HttpGet("https://raw.githubusercontent.com/9zla/UntitledHub/main/main.lua"))()'
					)
					game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
					return
				else
					if Player.Character.RankSystem.Yen.Value < 3000 then
						RejoinAndRollback("Trait", instanceName)
						TraitConnection:Disconnect()
						TraitConnection = nil
						return
					else
						TraitReroll:FireServer()
					end
				end
			end)
			TraitReroll:FireServer()
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
	local EmoteArguments = { "BarouPack", "IsagiPack", "LockedtinesEmotepack", "ReoPack" }

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
	Library:Notify("Rollback Successful, Rejoining", 2.8)

	task.wait(3)

	local args = {
		[1] = "Right",
		[2] = "F\255",
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
	Library:Notify("Rejoining", 2.8)

	task.wait(3)

	queue_on_teleport('loadstring(game:HttpGet("https://raw.githubusercontent.com/9zla/UntitledHub/main/main.lua"))()')

	game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
end)

RejoinBox:AddDivider()
