local SCM = select(2, ...)
local Options = SCM.Options

Options.CDM = {}
local CDMOptions = Options.CDM

local AceGUI = LibStub("AceGUI-3.0")
local Utils = SCM.Utils
local CustomIcons = SCM.CustomIcons
local Constants = SCM.Constants

SCM.MainTabs.CDM = { value = "CDM", text = "Cooldown Manager", order = 2, subgroups = {} }

function CDMOptions.ShowIconSettingsMessage(parentWidget, scrollFrame, message)
	parentWidget:SetTitle("")

	local label = AceGUI:Create("Label")
	label:SetRelativeWidth(1.0)
	label:SetHeight(24)
	label:SetJustifyH("CENTER")
	label:SetJustifyV("MIDDLE")
	label:SetText(message)
	label:SetFontObject("Game12Font")
	parentWidget:AddChild(label)

	parentWidget:DoLayout()
	scrollFrame:DoLayout()
end

local function CreateRowConfig(self, widget, parentWidget, scrollFrame, data, anchorIndex, mode, options, isProfileConfig)
	local rowTabsTbl = {}
	for i, row in ipairs(data.rowConfig) do
		tinsert(rowTabsTbl, { value = i, text = "Row " .. i })
	end

	local rowTabs = AceGUI:Create("TabGroup")
	rowTabs:SetLayout("flow")
	rowTabs:SetAutoAdjustHeight(false)
	rowTabs:SetFullWidth(true)
	rowTabs:SetHeight(280)
	rowTabs:SetTabs(rowTabsTbl)
	rowTabs:SetCallback("OnGroupSelected", function(self, event, rowIndex)
		SelectRow(self, widget, parentWidget, scrollFrame, data, anchorIndex, rowIndex, rowTabsTbl, mode, options, isProfileConfig)
	end)
	rowTabs:SelectTab(1)
	self:AddChild(rowTabs)
end

local function SelectAdvancedConfig(self, widget, parentWidget, scrollFrame, data, anchorIndex, configType, mode, options, isProfileConfig)
	self:ReleaseChildren()

	if configType == "rowConfig" then
		CreateRowConfig(self, widget, parentWidget, scrollFrame, data, anchorIndex, mode, options, isProfileConfig)
	elseif configType == "spellConfig" then
	end
end

local function SelectAnchor(widget, parentWidget, anchorIndex, anchorTabsTbl, mode)
	widget:ReleaseChildren()

	SCM.activeAnchorSettings = anchorIndex
	local options = SCM.db.profile.options
	local isGlobal = mode == "global"
	local isBuffBar = mode == "buffbars"
	local isProfileConfig = false

	if options.showAnchorHighlight then
		for group, anchorFrame in pairs(SCM.anchorFrames) do
			local activeGroup = GetEffectiveAnchorGroup(anchorIndex, mode)
			if group == activeGroup then
				SetAnchorHighlight(anchorFrame, "active", { 0.34, 0.70, 0.91, 1 })
			else
				SetAnchorHighlight(anchorFrame, "default")
			end
		end
	end

	local sourceData = (isGlobal and SCM.globalAnchorConfig[anchorIndex]) or (isBuffBar and SCM.buffBarsAnchorConfig[anchorIndex]) or SCM.anchorConfig[anchorIndex]
	if not sourceData then
		return
	end

	local data = sourceData
	local function GetProfileAnchorConfig()
		local config
		if isBuffBar then
			options.buffBarsAnchorConfig = options.buffBarsAnchorConfig or {}
			config = options.buffBarsAnchorConfig[anchorIndex]
		else
			options.anchorConfig = options.anchorConfig or {}
			config = options.anchorConfig[anchorIndex]
		end

		if not config then
			config = CopyTable(data)
		end

		if isBuffBar then
			options.buffBarsAnchorConfig[anchorIndex] = config
		else
			options.anchorConfig[anchorIndex] = config
		end

		return config
	end

	if not isGlobal and sourceData.useGlobalProfileConfig then
		data = GetProfileAnchorConfig()
		isProfileConfig = true
	end

	local anchorName = data.anchorName
	if anchorTabsTbl[anchorIndex].text ~= anchorName then
		anchorTabsTbl[anchorIndex].text = anchorName or ("Anchor " .. anchorIndex)
		widget:SetTabs(anchorTabsTbl)
	end

	local scrollFrame = AceGUI:Create("ScrollFrame")
	scrollFrame:SetLayout("flow")
	widget:AddChild(scrollFrame)

	local anchorOptions = AceGUI:Create("InlineGroup")
	anchorOptions:SetLayout("flow")
	anchorOptions:SetFullWidth(true)
	anchorOptions:SetHeight(250)
	anchorOptions:SetTitle("Anchor Options")
	scrollFrame:AddChild(anchorOptions)

	local buttonGroup = AceGUI:Create("SimpleGroup")
	buttonGroup:SetFullWidth(true)
	buttonGroup:SetLayout("flow")
	anchorOptions:AddChild(buttonGroup)

	local anchorButtonWidth = isGlobal and 0.33 or 0.25
	local addAnchorButton = AceGUI:Create("Button")
	addAnchorButton:SetText("Add Anchor")
	addAnchorButton:SetRelativeWidth(anchorButtonWidth)
	addAnchorButton:SetDisabled(#anchorTabsTbl >= 15)
	addAnchorButton:SetCallback("OnClick", function()
		local nextIndex = (isGlobal and SCM:AddGlobalAnchor(anchorTabsTbl)) or (isBuffBar and SCM:AddBuffBarAnchor(anchorTabsTbl)) or SCM:AddAnchor(anchorTabsTbl)
		ApplyModeConfigUpdate(nextIndex, mode)
		widget:SetTabs(anchorTabsTbl)
		widget:SelectTab(nextIndex)
	end)
	buttonGroup:AddChild(addAnchorButton)

	local deleteAnchorButton = AceGUI:Create("Button")
	deleteAnchorButton:SetText("Delete Anchor")
	deleteAnchorButton:SetRelativeWidth(anchorButtonWidth)
	deleteAnchorButton:SetDisabled(((isGlobal or isBuffBar) and anchorIndex == 1) or (not isGlobal and not isBuffBar and anchorIndex <= 3))
	deleteAnchorButton:SetCallback("OnClick", function()
		if isGlobal then
			SCM:RemoveGlobalAnchor(anchorIndex, anchorTabsTbl)
		elseif isBuffBar then
			SCM:RemoveBuffBarAnchor(anchorIndex, anchorTabsTbl)
		else
			SCM:RemoveAnchor(anchorIndex, anchorTabsTbl)
		end
		widget:SetTabs(anchorTabsTbl)
		widget:SelectTab(#anchorTabsTbl)
	end)
	buttonGroup:AddChild(deleteAnchorButton)

	local renameAnchorButton = AceGUI:Create("Button")
	renameAnchorButton:SetText("Rename Anchor")
	renameAnchorButton:SetRelativeWidth(anchorButtonWidth)
	renameAnchorButton:SetDisabled(#anchorTabsTbl >= 15)
	renameAnchorButton:SetCallback("OnClick", function()
		StaticPopup_Show("SCM_RENAME_ANCHOR", nil, nil, {
			callback = function(anchorName)
				data.anchorName = anchorName
				anchorTabsTbl[anchorIndex].text = anchorName
				widget:SetTabs(anchorTabsTbl)
				widget:SelectTab(anchorIndex)
			end,
		})
	end)
	buttonGroup:AddChild(renameAnchorButton)

	if not isGlobal then
		local useGlobalProfileConfig = AceGUI:Create("CheckBox")
		useGlobalProfileConfig:SetLabel("Use Profile Config")
		useGlobalProfileConfig:SetRelativeWidth(anchorButtonWidth)
		useGlobalProfileConfig:SetValue(sourceData.useGlobalProfileConfig or false)
		useGlobalProfileConfig:SetCallback("OnValueChanged", function(_, _, value)
			sourceData.useGlobalProfileConfig = value
			if value then
				GetProfileAnchorConfig()
			end
			ApplyModeConfigUpdate(anchorIndex, mode)

			widget:SelectTab(anchorIndex)
		end)
		useGlobalProfileConfig:SetCallback("OnEnter", function(self)
			GameTooltip:SetOwner(self.frame, "ANCHOR_CURSOR")
			GameTooltip:SetText("Use Profile Config", nil, nil, nil, nil, true)
			GameTooltip:AddLine("This will use the anchor config for that anchor that is shared by all specs.", 1, 1, 1, true)
			GameTooltip:Show()
		end)
		useGlobalProfileConfig:SetCallback("OnLeave", function()
			GameTooltip:Hide()
		end)
		buttonGroup:AddChild(useGlobalProfileConfig)
	end

	local point = AceGUI:Create("Dropdown")
	point:SetRelativeWidth(isBuffBar and 0.25 or 0.33)
	point:SetLabel("Point")
	point:SetList(SCM.Constants.AnchorPoints)
	point:SetValue(data.anchor[1])
	point:SetCallback("OnValueChanged", function(self, event, value)
		data.anchor[1] = value
		ApplyModeConfigUpdate(anchorIndex, mode)
	end)
	anchorOptions:AddChild(point)

	local relativeTo = AceGUI:Create("EditBox")
	relativeTo:SetRelativeWidth(isBuffBar and 0.25 or 0.33)
	relativeTo:SetLabel("Anchor Frame")
	relativeTo:SetText(data.anchor[2])
	relativeTo:SetCallback("OnEnterPressed", function(self, event, text)
		data.anchor[2] = text
		ApplyModeConfigUpdate(anchorIndex, mode)
	end)
	anchorOptions:AddChild(relativeTo)

	local relativePoint = AceGUI:Create("Dropdown")
	relativePoint:SetRelativeWidth(isBuffBar and 0.25 or 0.33)
	relativePoint:SetLabel("Relative Point")
	relativePoint:SetList(SCM.Constants.AnchorPoints)
	relativePoint:SetValue(data.anchor[3])
	relativePoint:SetCallback("OnValueChanged", function(self, event, value)
		data.anchor[3] = value
		ApplyModeConfigUpdate(anchorIndex, mode)
	end)
	anchorOptions:AddChild(relativePoint)

	if isBuffBar then
		local matchAnchorWidth = AceGUI:Create("CheckBox")
		matchAnchorWidth:SetLabel("Match Parent Width")
		matchAnchorWidth:SetRelativeWidth(0.25)
		matchAnchorWidth:SetValue(data.matchAnchorWidth or false)
		matchAnchorWidth:SetCallback("OnValueChanged", function(_, _, value)
			data.matchAnchorWidth = value
			ApplyModeConfigUpdate(anchorIndex, mode)
			widget:SelectTab(anchorIndex)
		end)
		anchorOptions:AddChild(matchAnchorWidth)
	end

	local grow = AceGUI:Create("Dropdown")
	grow:SetRelativeWidth(0.25)
	grow:SetList(SCM.Constants.GrowthDirections)
	grow:SetLabel("Primary Growth")
	grow:SetValue(data.grow or "CENTERED")
	grow:SetCallback("OnValueChanged", function(self, event, value)
		data.grow = value
		ApplyModeConfigUpdate(anchorIndex, mode)
	end)
	anchorOptions:AddChild(grow)

	local secondaryGrow = AceGUI:Create("Dropdown")
	secondaryGrow:SetRelativeWidth(0.25)
	secondaryGrow:SetList(SCM.Constants.SecondaryGrowthDirections)
	secondaryGrow:SetLabel("Secondary Growth")
	secondaryGrow:SetValue(data.secondaryGrow or "DOWN")
	secondaryGrow:SetCallback("OnValueChanged", function(self, event, value)
		data.secondaryGrow = value
		ApplyModeConfigUpdate(anchorIndex, mode)
	end)
	anchorOptions:AddChild(secondaryGrow)

	local spacing = AceGUI:Create("Slider")
	spacing:SetRelativeWidth(0.25)
	spacing:SetSliderValues(-10, 50, 0.1)
	spacing:SetLabel("Spacing")
	spacing:SetValue(data.spacing or 0)
	spacing:SetCallback("OnValueChanged", function(self, event, value)
		data.spacing = value
		ApplyModeConfigUpdate(anchorIndex, mode)
	end)
	anchorOptions:AddChild(spacing)

	local frameStrata = AceGUI:Create("Dropdown")
	frameStrata:SetRelativeWidth(0.25)
	frameStrata:SetList(SCM.Constants.FrameStrata, SCM.Constants.FrameStrataSorted)
	frameStrata:SetLabel("Frame Strata")
	frameStrata:SetValue(data.frameStrata or "")
	frameStrata:SetCallback("OnValueChanged", function(self, event, value)
		data.frameStrata = value ~= "" and value or nil
		ApplyModeConfigUpdate(anchorIndex, mode)
	end)
	anchorOptions:AddChild(frameStrata)

	local xOffset = AceGUI:Create("Slider")
	xOffset:SetRelativeWidth(0.5)
	xOffset:SetSliderValues(-1000, 1000, 0.1)
	xOffset:SetLabel("X Offset")
	xOffset:SetValue(data.anchor[4])
	xOffset:SetCallback("OnValueChanged", function(self, event, value)
		data.anchor[4] = value
		ApplyModeConfigUpdate(anchorIndex, mode)
	end)
	anchorOptions:AddChild(xOffset)

	local yOffset = AceGUI:Create("Slider")
	yOffset:SetRelativeWidth(0.5)
	yOffset:SetSliderValues(-1000, 1000, 0.1)
	yOffset:SetLabel("Y Offset")
	yOffset:SetValue(data.anchor[5])
	yOffset:SetCallback("OnValueChanged", function(self, event, value)
		data.anchor[5] = value
		ApplyModeConfigUpdate(anchorIndex, mode)
	end)
	anchorOptions:AddChild(yOffset)

	local advancedConfigTabs = AceGUI:Create("TabGroup")
	advancedConfigTabs:SetLayout("flow")
	advancedConfigTabs:SetFullWidth(true)
	advancedConfigTabs:SetHeight(280)
	advancedConfigTabs:SetTabs({ { value = "rowConfig", text = "Row Config" }, { value = "spellConfig", text = "Spell Config" } })
	advancedConfigTabs:SetCallback("OnGroupSelected", function(self, _, configType)
		SelectAdvancedConfig(self, widget, parentWidget, scrollFrame, data, anchorIndex, configType, mode, options, isProfileConfig)
	end)
	advancedConfigTabs:SelectTab(1)
	anchorOptions:AddChild(advancedConfigTabs)

	scrollFrame:DoLayout()
	--scrollFrame:FixScroll()
	--scrollFrame:SetScroll(0)

	RunNextFrame(function()
		horizontalScrollFrame.scrollbar:ScrollToEnd()
		horizontalScrollFrame.scrollbar:ScrollToBegin()
	end)
end

local function CreateAnchorTabGroup(parent, frame, mode)
	parent:ReleaseChildren()

	local isGlobal = mode == "global"
	local isBuffBar = mode == "buffbars"

	local anchorTabs = AceGUI:Create("TabGroup")
	anchorTabs:SetLayout("fill")
	anchorTabs:SetFullWidth(true)
	anchorTabs:SetFullHeight(true)
	anchorTabs.frame:SetPoint("TOPLEFT", parent.frame, "TOPLEFT", 0, -30)
	anchorTabs.frame:SetPoint("BOTTOMRIGHT", parent.frame, "BOTTOMRIGHT", 0, -5)
	anchorTabs.frame:SetParent(parent.frame)
	anchorTabs.frame:Show()

	local sourceConfig = (isGlobal and SCM.globalAnchorConfig) or (isBuffBar and SCM.buffBarsAnchorConfig) or SCM.anchorConfig
	local anchorTabsTbl = {}
	for i, anchorConfig in ipairs(sourceConfig) do
		tinsert(anchorTabsTbl, { value = i, text = anchorConfig.anchorName or ("Anchor " .. i) })
	end

	anchorTabs:SetTabs(anchorTabsTbl)
	anchorTabs:SetCallback("OnGroupSelected", function(self, event, anchorIndex)
		SelectAnchor(self, parent, anchorIndex, anchorTabsTbl, mode)
	end)
	parent:AddChild(anchorTabs)
	anchorTabs:SelectTab(1)
end

local function GetCopyClassList()
	return SCM.Utils.GetClassList(false)
end

local function GetCopySpecList(classFileName)
	return SCM.Utils.GetSpecList(classFileName)
end

local function CreateCopyAnchorTab(widget, frame, modeTabs)
	widget:ReleaseChildren()

	local currentClass = SCM.currentClass
	local currentSpecID = SCM.currentSpecID
	-- Use the live player API so we don't depend on copyClassFileNameToID being pre-populated.
	local _, currentSpecName = C_SpecializationInfo.GetSpecializationInfo(C_SpecializationInfo.GetSpecialization())
	local targetSpecDisplay = currentSpecName or tostring(currentSpecID)

	-- Populate the class list (also seeds the classFileNameToID lookup used by GetCopySpecList).
	local classList = GetCopyClassList()

	local outerGroup = AceGUI:Create("SimpleGroup")
	outerGroup:SetFullWidth(true)
	outerGroup:SetLayout("flow")
	widget:AddChild(outerGroup)

	local targetLabel = AceGUI:Create("Label")
	targetLabel:SetFullWidth(true)
	targetLabel:SetText("|cFFAAAAAACopy Anchors To |r " .. (classList[currentClass] or currentClass) .. " - " .. targetSpecDisplay)
	targetLabel:SetJustifyH("CENTER")
	targetLabel:SetFont(STANDARD_TEXT_FONT, 15, "OUTLINE")
	outerGroup:AddChild(targetLabel)

	local infoLabel = AceGUI:Create("Label")
	infoLabel:SetFullWidth(true)
	infoLabel:SetText("This will only copy across anchors and their layout, spells / icons are not copied.")
	infoLabel:SetJustifyH("CENTER")
	infoLabel:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
	outerGroup:AddChild(infoLabel)

	local copyFromGroup = AceGUI:Create("InlineGroup")
	copyFromGroup:SetFullWidth(true)
	copyFromGroup:SetTitle("Copy From")
	copyFromGroup:SetLayout("flow")
	outerGroup:AddChild(copyFromGroup)

	local selectedClass = nil
	local selectedSpecID = nil
	local selectedSpecDisplay = nil

	local copyBtn

	local function RefreshCopyButton()
		if not copyBtn then
			return
		end
		local isSelf = selectedClass == currentClass and selectedSpecID == currentSpecID
		local isValid = selectedClass ~= nil and selectedSpecID ~= nil and not isSelf
		copyBtn:SetDisabled(not isValid)
		if isSelf then
			copyBtn:SetText("Cannot Copy to the Same Specialization")
		else
			copyBtn:SetText("Copy Anchors")
		end
	end

	local specDropdown = AceGUI:Create("Dropdown")
	specDropdown:SetRelativeWidth(0.5)
	specDropdown:SetLabel("Specialization")
	specDropdown:SetList({})
	specDropdown:SetDisabled(true)
	specDropdown.text:SetJustifyH("LEFT")

	local classDropdown = AceGUI:Create("Dropdown")
	classDropdown:SetRelativeWidth(0.5)
	classDropdown:SetLabel("Class")
	classDropdown:SetList(classList)
	classDropdown.text:SetJustifyH("LEFT")
	classDropdown:SetCallback("OnValueChanged", function(_, _, value)
		selectedClass = value
		selectedSpecID = nil
		selectedSpecDisplay = nil
		local specList = GetCopySpecList(value)
		specDropdown:SetList(specList)
		specDropdown:SetValue(nil)
		specDropdown:SetDisabled(false)
		specDropdown.text:SetJustifyH("LEFT")
		RefreshCopyButton()
	end)
	copyFromGroup:AddChild(classDropdown)

	specDropdown:SetCallback("OnValueChanged", function(_, _, value)
		selectedSpecID = value
		local specList = GetCopySpecList(selectedClass)
		selectedSpecDisplay = specList[value]
		RefreshCopyButton()
	end)
	copyFromGroup:AddChild(specDropdown)

	copyBtn = AceGUI:Create("Button")
	copyBtn:SetText("Copy Anchors")
	copyBtn:SetFullWidth(true)
	copyBtn:SetDisabled(true)
	copyBtn:SetCallback("OnClick", function()
		StaticPopup_Show("SCM_CONFIRM_COPY_ANCHORS", selectedSpecDisplay or tostring(selectedSpecID), targetSpecDisplay, {
			callback = function()
				SCM:CopyAnchorConfig(selectedClass, selectedSpecID)
				modeTabs:SelectTab("spec")
			end,
		})
	end)
	copyFromGroup:AddChild(copyBtn)
end

local function CDM(self, frame, group)
	local modeTabs = AceGUI:Create("TabGroup")
	modeTabs:SetLayout("fill")
	modeTabs:SetFullWidth(true)
	modeTabs:SetFullHeight(true)

	local tabs = {
		{ value = "spec", text = "|cFFFFFFFFSpecialization|r: Icons" },
		{ value = "buffbars", text = "|cFFFFFFFFSpecialization|r: Bars" },
		{ value = "global", text = "|cFFFFFFFFGlobal|r: Icons" },
		{ value = "copy", text = "|cFFFFFFFFCopy|r Anchors" },
	}

	modeTabs:SetTabs(tabs)
	modeTabs:SetCallback("OnGroupSelected", function(widget, event, mode)
		if mode == "copy" then
			CreateCopyAnchorTab(widget, frame, modeTabs)
		else
			CreateAnchorTabGroup(widget, frame, mode)
		end
	end)
	modeTabs:SelectTab("spec")
	self:AddChild(modeTabs)

	self.typeTab = modeTabs
end

SCM.MainTabs.CDM.callback = CDM
