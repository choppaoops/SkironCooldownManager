local SCM = select(2, ...)
local Options = SCM.Options
local CDMOptions = Options.CDM

local iconTypeTabs = {
	all = {
		{ value = "general", text = "General" },
		{ value = "glow", text = "Glow" },
		{ value = "load", text = "Load Conditions" },
	},
	spell = {},
	item = {
		{ value = "items", text = "Items" },
	},
	timer = {},
	slot = {
		{ value = "filter", text = "Filter" },
	},
}
for iconType, options in pairs(iconTypeTabs) do
	if iconType ~= "all" then
		for i = #iconTypeTabs.all, 1, -1 do
			tinsert(options, 1, iconTypeTabs.all[i])
		end
	end
end

local function GetDefaultLoadRaceNames()
	local dualFactionRaces = {}
	local loadedRaces = {}
	local raceIDs = {}

	local sortedIDs = {}
	for raceID in pairs(SCM.Constants.Races) do
		sortedIDs[#sortedIDs + 1] = raceID
	end
	table.sort(sortedIDs)

	for i = 1, #sortedIDs do
		local raceID = sortedIDs[i]
		local raceInfo = C_CreatureInfo.GetRaceInfo(raceID)

		if raceInfo and not dualFactionRaces[raceInfo.raceName] then
			dualFactionRaces[raceInfo.raceName] = true
			loadedRaces[raceID] = raceInfo.raceName
			tinsert(raceIDs, raceID)
		end
	end

	table.sort(raceIDs, function(raceIDA, raceIDB)
		return loadedRaces[raceIDA] < loadedRaces[raceIDB]
	end)

	return loadedRaces, raceIDs
end

function CDMOptions.CreateSpellConfigTabs(buttonFrame, lastButtonFrame, anchorIndex, mode)
	local buttonData = buttonFrame.data
	local buttonConfig = buttonData.isCustom and SCM:GetConfigTableByID(buttonData.id, buttonData.iconType, isGlobal) or SCM:GetSpellConfigForGroup(buttonData.id, currentAnchorIndex)
	if not buttonConfig then
		lastButtonFrame = nil
		CDMOptions.ShowIconSettingsMessage("|TInterface\\common\\help-i:40:40:0:0|tThis icon could not be resolved for the current anchor.")
		return
	end

	buttonFrame:SetBackdropBorderColor(0, 1, 0, 1)

	if buttonConfig then
		local function ApplyIconConfigUpdate()
			if buttonFrame.data.isCustom then
				SCM:CreateAllCustomIcons(buttonData.iconType)
				SCM:ApplyAnchorGroupCDManagerConfig(anchorIndex, isGlobal)
				return
			end
			Options.ApplyModeConfigUpdate(anchorIndex, mode)
		end

		local iconSettingsTabs = AceGUI:Create("TabGroup")
		iconSettingsTabs:SetLayout("flow")
		iconSettingsTabs:SetFullWidth(true)
		iconSettingsTabs:SetTabs(isBuffBar and { { value = "general", text = "General" } } or iconTypeTabs[buttonData.iconType])
		iconSettingsTabs:SetCallback("OnGroupSelected", function(self, event, group)
			iconSettingsTabs:ReleaseChildren()

			if group == "general" then
			elseif group == "load" then
			elseif group == "glow" then
			elseif group == "state" then
			elseif group == "items" then
			elseif group == "filter" then
			end

			iconSettings:DoLayout()
			scrollFrame:DoLayout()
		end)
		iconSettingsTabs:SelectTab("general")
		iconSettings:AddChild(iconSettingsTabs)
		lastButtonFrame = buttonFrame

		iconSettings:DoLayout()
		scrollFrame:DoLayout()
	end
end
