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

local function GetSubregionList(subregionOptions)
	if not subregionOptions then
		return
	end

	local subregions = {}
	for index, subregionData in ipairs(subregionOptions) do
		subregions[subregionData] = subregionData.type:gsub("^%l", strupper) .. " " .. index
	end

	return subregions
end

local function AddStateVisibilityOptions(stateGroup, state, stateOptions)
	local toggleVisibility = AceGUI:Create("CheckBox")
	toggleVisibility:SetRelativeWidth(0.33)
	toggleVisibility:SetLabel("Change Visibility")
	stateGroup:AddChild(toggleVisibility)

	local visibilityDropdown = AceGUI:Create("Dropdown")
	visibilityDropdown:SetLabel("Visibility")
	visibilityDropdown:SetRelativeWidth(0.67)
	visibilityDropdown:SetList(Constants.Visibility, Constants.VisibilitySorted)
	stateGroup:AddChild(visibilityDropdown)
end

local function AddStateGlowOptions(stateGroup, state, stateOptions, subregionOptions)
	local glowToggle = AceGUI:Create("CheckBox")
	glowToggle:SetRelativeWidth(0.33)
	glowToggle:SetLabel("Glow")
	stateGroup:AddChild(glowToggle)

	local glowRegionDropdown = AceGUI:Create("Dropdown")
	glowRegionDropdown:SetLabel("Subregion")
	glowRegionDropdown:SetRelativeWidth(0.33)
	glowRegionDropdown:SetList(GetSubregionList(subregionOptions))
	stateGroup:AddChild(glowRegionDropdown)

	local glowVisiblityDropdown = AceGUI:Create("Dropdown")
	glowVisiblityDropdown:SetLabel("Visibility")
	glowVisiblityDropdown:SetRelativeWidth(0.33)
	glowVisiblityDropdown:SetList(Constants.Visibility, Constants.VisibilitySorted)
	stateGroup:AddChild(glowVisiblityDropdown)
end

local function AddStateBorderOptions(stateGroup, state, stateOptions, subregionOptions)
	local borderToggle = AceGUI:Create("CheckBox")
	borderToggle:SetRelativeWidth(0.33)
	borderToggle:SetLabel("Border")
	stateGroup:AddChild(borderToggle)

	local borderRegionDropdown = AceGUI:Create("Dropdown")
	borderRegionDropdown:SetLabel("Subregion")
	borderRegionDropdown:SetRelativeWidth(0.33)
	borderRegionDropdown:SetList(GetSubregionList(subregionOptions))
	stateGroup:AddChild(borderRegionDropdown)

	local borderVisiblityDropdown = AceGUI:Create("Dropdown")
	borderVisiblityDropdown:SetLabel("Visibility")
	borderVisiblityDropdown:SetRelativeWidth(0.33)
	borderVisiblityDropdown:SetList(Constants.Visibility, Constants.VisibilitySorted)
	stateGroup:AddChild(borderVisiblityDropdown)
end

local function AddStateOptions(state, iconSettingsTabs, scrollFrame, iconConfig, isGlobal, isBuffBar)
	local stateOptions = iconConfig.stateOptions[state]
	local subregionOptions = iconConfig.subregionOptions

	local stateGroup = AceGUI:Create("InlineGroup")
	stateGroup:SetLayout("flow")
	stateGroup:SetFullWidth(true)
	stateGroup:SetTitle(Constants.States[state])
	scrollFrame:AddChild(stateGroup)

	AddStateVisibilityOptions(stateGroup, state, stateOptions)
	AddStateGlowOptions(stateGroup, state, stateOptions, subregionOptions["glow"])
	AddStateBorderOptions(stateGroup, state, stateOptions, subregionOptions["border"])

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
