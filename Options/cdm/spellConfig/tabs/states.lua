
local function AddStateOptions(stateType, iconSettingsTabs, iconSettings, scrollFrame, value, options, buttonConfig)
	buttonConfig.stateOptions = buttonConfig.stateOptions or {}
	buttonConfig.stateOptions[value] = buttonConfig.stateOptions[value] or {}

	SCM.Templates.AddGlowOptions(iconSettingsTabs, buttonConfig.stateOptions[value], iconSettings, scrollFrame)
end

local function CreateStateDropdown(iconSettingsTabs, iconSettings, scrollFrame, options, buttonConfig)
	local stateType = AceGUI:Create("Dropdown")
	stateType:SetRelativeWidth(0.5)
	stateType:SetLabel("State Type")
	stateType:SetList({
		["ready"] = "Ready",
		["cooldown"] = "On Cooldown",
		["active"] = "Active",
	})
	iconSettingsTabs:AddChild(stateType)

	stateType:SetCallback("OnValueChanged", function(_, _, value)
		AddStateOptions(stateType, iconSettingsTabs, iconSettings, scrollFrame, value, options, buttonConfig)
		iconSettingsTabs:DoLayout()
	end)
	stateType:SetValue("ready")
end


CreateStateDropdown(self, iconSettings, scrollFrame, options, buttonConfig)