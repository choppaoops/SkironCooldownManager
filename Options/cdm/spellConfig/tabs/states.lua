local SCM = select(2, ...)
local Options = SCM.Options
local CDMOptions = Options.CDM
local Constants = SCM.Constants
local AceGUI = LibStub("AceGUI-3.0")

local function GetUnusedStates(iconConfig)
	local states, statesSorted = {}, {}

	for _, stateValue in ipairs(Constants.StatesSorted) do
		if not iconConfig.usedStates[stateValue] then
			states[stateValue] = Constants.States[stateValue]
			tinsert(statesSorted, stateValue)
		end
	end

	return states, statesSorted
end

local function AddStateVisibilityOptions(stateGroup, state, stateOptions)
	local showToggle = AceGUI:Create("CheckBox")
	showToggle:SetRelativeWidth(0.5)
	showToggle:SetLabel("Show Icon")
	stateGroup:AddChild(showToggle)

	local hideToggle = AceGUI:Create("CheckBox")
	hideToggle:SetRelativeWidth(0.5)
	hideToggle:SetLabel("Hide Icon")
	stateGroup:AddChild(hideToggle)
end

local function AddStateGlowOptions(stateGroup, state, stateOptions)
	local glowToggle = AceGUI:Create("CheckBox")
	glowToggle:SetRelativeWidth(0.5)
	glowToggle:SetLabel("Glow")
	stateGroup:AddChild(glowToggle)

	local glowRegionDropdown = AceGUI:Create("Dropdown")
	glowRegionDropdown:SetLabel("Subregion")
	glowRegionDropdown:SetRelativeWidth(0.5)
	stateGroup:AddChild(glowRegionDropdown)

	local glowVisiblityDropdown = AceGUI:Create("Dropdown")
	glowVisiblityDropdown:SetLabel("Visibility")
	glowVisiblityDropdown:SetRelativeWidth(0.33)
	stateGroup:AddChild(glowVisiblityDropdown)
end

local function AddStateBorderOptions(stateGroup, state, stateOptions)
	local borderToggle = AceGUI:Create("CheckBox")
	borderToggle:SetRelativeWidth(0.33)
	borderToggle:SetLabel("Border")
	stateGroup:AddChild(borderToggle)

	local borderRegionDropdown = AceGUI:Create("Dropdown")
	borderRegionDropdown:SetLabel("Subregion")
	borderRegionDropdown:SetRelativeWidth(0.33)
	stateGroup:AddChild(borderRegionDropdown)

	local borderVisiblityDropdown = AceGUI:Create("Dropdown")
	borderVisiblityDropdown:SetLabel("Visibility")
	borderVisiblityDropdown:SetRelativeWidth(0.33)
	stateGroup:AddChild(borderVisiblityDropdown)
end

local function AddStateOptions(state, iconSettingsTabs, scrollFrame, iconConfig, isGlobal, isBuffBar)
	local stateOptions = iconConfig.stateOptions[state]

	local stateGroup = AceGUI:Create("InlineGroup")
	stateGroup:SetLayout("flow")
	stateGroup:SetFullWidth(true)
	stateGroup:SetTitle(Constants.States[state])
	scrollFrame:AddChild(stateGroup)

	AddStateVisibilityOptions(stateGroup, state, stateOptions)
	AddStateGlowOptions(stateGroup, state, stateOptions)
	AddStateBorderOptions(stateGroup, state, stateOptions)

	local removeStateButton = AceGUI:Create("Button")
	removeStateButton:SetText("Remove")
	removeStateButton:SetRelativeWidth(1)
	removeStateButton:SetCallback("OnClick", function()
		iconConfig.usedStates[state] = nil
		iconConfig.stateOptions[state] = nil
		iconSettingsTabs:SelectByValue("state")
	end)
	stateGroup:AddChild(removeStateButton)
end

function CDMOptions.CreateStateTabSettings(iconSettingsTabs, iconSettings, parentScrollFrame, buttonFrame, buttonData, iconConfig, anchorIndex, mode, isGlobal, isBuffBar)
	if not isBuffBar then
		iconConfig.stateOptions = iconConfig.stateOptions or {}
		iconConfig.usedStates = iconConfig.usedStates or {}

		local rootGroup = AceGUI:Create("SimpleGroup")
		rootGroup:SetLayout("fill")
		rootGroup:SetFullWidth(true)
		rootGroup:SetFullHeight(true)
		iconSettingsTabs:AddChild(rootGroup)

		local scrollFrame = AceGUI:Create("ScrollFrame")
		scrollFrame:SetLayout("flow")
		scrollFrame:SetFullWidth(true)
		scrollFrame:SetFullHeight(true)
		rootGroup:AddChild(scrollFrame)

		local generalSettings = AceGUI:Create("InlineGroup")
		generalSettings:SetLayout("flow")
		generalSettings:SetFullWidth(true)
		scrollFrame:AddChild(generalSettings)

		local selectedState
		local stateDropdown = AceGUI:Create("Dropdown")
		stateDropdown:SetLabel("State")
		stateDropdown:SetRelativeWidth(0.75)
		generalSettings:AddChild(stateDropdown)

		local addStateButton = AceGUI:Create("Button")
		addStateButton:SetText("Add")
		addStateButton:SetRelativeWidth(0.2)
		generalSettings:AddChild(addStateButton)

		stateDropdown:SetList(GetUnusedStates(iconConfig))
		stateDropdown:SetValue(selectedState)
		addStateButton:SetDisabled(selectedState == nil)

		stateDropdown:SetCallback("OnValueChanged", function(_, _, value)
			selectedState = value
			addStateButton:SetDisabled(value == nil)
		end)

		for _, stateValue in ipairs(Constants.StatesSorted) do
			if iconConfig.usedStates[stateValue] then
				AddStateOptions(stateValue, iconSettingsTabs, scrollFrame, iconConfig, isGlobal, isBuffBar)
			end
		end

		addStateButton:SetCallback("OnClick", function()
			if not selectedState or iconConfig.usedStates[selectedState] then
				return
			end

			iconConfig.usedStates[selectedState] = true
			iconConfig.stateOptions[selectedState] = iconConfig.stateOptions[selectedState] or {}

			AddStateOptions(selectedState, iconSettingsTabs, scrollFrame, iconConfig, isGlobal, isBuffBar)
			iconSettingsTabs:DoLayout()

			selectedState = nil
			stateDropdown:SetValue(selectedState)
			stateDropdown:SetList(GetUnusedStates(iconConfig))
		end)
	end
end
