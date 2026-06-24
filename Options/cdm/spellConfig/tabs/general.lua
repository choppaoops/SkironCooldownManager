local SCM = select(2, ...)
local Options = SCM.Options
local CDMOptions = Options.CDM
local AceGUI = LibStub("AceGUI-3.0")

function CDMOptions.CreateGeneralTabSettings(iconSettingsTabs, iconSettings, scrollFrame, buttonFrame, buttonData, buttonConfig, anchorIndex, mode, isGlobal, isBuffBar)
	local options = SCM.db.profile.options

	if not isBuffBar then
		local desaturate, alwaysShow, showWhileInactive
		if buttonFrame.data.isBuffIcon or buttonData.isCustom then
			alwaysShow = AceGUI:Create("CheckBox")
			alwaysShow:SetLabel("Show Always")
			alwaysShow:SetRelativeWidth(0.5)
			alwaysShow:SetValue(buttonConfig.alwaysShow)
			alwaysShow:SetDisabled((not buttonData.isCustom and not options.hideBuffsWhenInactive) or buttonConfig.showWhileInactive)
			SCM.Utils.SetDisabledTooltip(alwaysShow, "Enable \"Disable 'Hide Inactive Auras'\" in Global Settings > General > Auras first or disable 'Show While Inactive'.")
			iconSettingsTabs:AddChild(alwaysShow)
			alwaysShow:SetCallback("OnValueChanged", function(self, event, value)
				buttonConfig.alwaysShow = value

				if desaturate then
					desaturate:SetDisabled(not value)
				end

				if showWhileInactive then
					showWhileInactive:SetDisabled(value)
				end

				CDMOptions.ApplyIconConfigUpdate(buttonFrame, buttonData, anchorIndex, mode, isGlobal, isBuffBar)
			end)
		end

		if buttonFrame.data.isBuffIcon then
			showWhileInactive = AceGUI:Create("CheckBox")
			showWhileInactive:SetLabel("Show While Inactive")
			showWhileInactive:SetRelativeWidth(0.5)
			showWhileInactive:SetValue(buttonConfig.showWhileInactive)
			showWhileInactive:SetDisabled(not options.hideBuffsWhenInactive or buttonConfig.alwaysShow)
			SCM.Utils.SetDisabledTooltip(showWhileInactive, "Enable \"Disable 'Hide Inactive Auras'\" in Global Settings > General > Auras first or disable 'Show Always'.")
			iconSettingsTabs:AddChild(showWhileInactive)
			showWhileInactive:SetCallback("OnValueChanged", function(self, event, value)
				buttonConfig.showWhileInactive = value
				CDMOptions.ApplyIconConfigUpdate(buttonFrame, buttonData, anchorIndex, mode, isGlobal, isBuffBar)

				if desaturate then
					desaturate:SetDisabled(not value)
				end

				if alwaysShow then
					alwaysShow:SetDisabled(value)
				end
			end)

			local hideWhileMounted = AceGUI:Create("CheckBox")
			hideWhileMounted:SetRelativeWidth(0.5)
			hideWhileMounted:SetValue(buttonConfig.hideWhileMounted)
			hideWhileMounted:SetLabel("Hilde While Mounted")
			hideWhileMounted:SetDisabled(not options.hideWhileMounted)
			hideWhileMounted:SetCallback("OnValueChanged", function(self, event, value)
				buttonConfig.hideWhileMounted = value or nil
				CDMOptions.ApplyIconConfigUpdate(buttonFrame, buttonData, anchorIndex, mode, isGlobal, isBuffBar)
			end)
			iconSettingsTabs:AddChild(hideWhileMounted)

			desaturate = AceGUI:Create("CheckBox")
			desaturate:SetLabel("Desaturate While Inactive")
			desaturate:SetRelativeWidth(0.5)
			desaturate:SetValue(buttonConfig.desaturate)
			desaturate:SetDisabled(not buttonConfig.alwaysShow and not buttonConfig.showWhileInactive)
			SCM.Utils.SetDisabledTooltip(desaturate, "Enable 'Show Always' first.")
			desaturate:SetCallback("OnValueChanged", function(self, event, value)
				buttonConfig.desaturate = value or nil
				CDMOptions.ApplyIconConfigUpdate(buttonFrame, buttonData, anchorIndex, mode, isGlobal, isBuffBar)
			end)
			iconSettingsTabs:AddChild(desaturate)
		elseif buttonData.iconType ~= "timer" then
			local hideWhileReady = AceGUI:Create("CheckBox")
			hideWhileReady:SetLabel("Hide While Ready")
			hideWhileReady:SetRelativeWidth(0.5)
			hideWhileReady:SetValue(buttonConfig.hideWhenNotOnCooldown)
			hideWhileReady:SetCallback("OnValueChanged", function(self, event, value)
				buttonConfig.hideWhenNotOnCooldown = value or nil
				CDMOptions.ApplyIconConfigUpdate(buttonFrame, buttonData, anchorIndex, mode, isGlobal, isBuffBar)
			end)
			iconSettingsTabs:AddChild(hideWhileReady)

			local expCooldownThing = AceGUI:Create("CheckBox")
			expCooldownThing:SetLabel("Experimental Cooldown Anchoring")
			expCooldownThing:SetRelativeWidth(0.5)
			expCooldownThing:SetValue(buttonConfig.expCooldownThing)
			expCooldownThing:SetCallback("OnValueChanged", function(self, event, value)
				buttonConfig.expCooldownThing = value or nil
				CDMOptions.ApplyIconConfigUpdate(buttonFrame, buttonData, anchorIndex, mode, isGlobal, isBuffBar)
			end)
			iconSettingsTabs:AddChild(expCooldownThing)

			if buttonData.isCustom then
				local showGCD = AceGUI:Create("CheckBox")
				showGCD:SetLabel("Show GCD")
				showGCD:SetRelativeWidth(0.5)
				showGCD:SetValue(buttonConfig.showGCD)
				showGCD:SetCallback("OnValueChanged", function(self, event, value)
					buttonConfig.showGCD = value or nil
					CDMOptions.ApplyIconConfigUpdate(buttonFrame, buttonData, anchorIndex, mode, isGlobal, isBuffBar)
				end)
				iconSettingsTabs:AddChild(showGCD)

				if buttonData.iconType == "item" then
					local showCraftQuality = AceGUI:Create("CheckBox")
					showCraftQuality:SetLabel("Show Craft Quality")
					showCraftQuality:SetRelativeWidth(0.5)
					showCraftQuality:SetValue(buttonConfig.showCraftQuality)
					showCraftQuality:SetCallback("OnValueChanged", function(self, event, value)
						buttonConfig.showCraftQuality = value or nil
						CDMOptions.ApplyIconConfigUpdate(buttonFrame, buttonData, anchorIndex, mode, isGlobal, isBuffBar)
					end)
					iconSettingsTabs:AddChild(showCraftQuality)

					local hideStackText = AceGUI:Create("CheckBox")
					hideStackText:SetLabel("Hide Count")
					hideStackText:SetRelativeWidth(0.5)
					hideStackText:SetValue(buttonConfig.hideStackText)
					hideStackText:SetCallback("OnValueChanged", function(self, event, value)
						buttonConfig.hideStackText = value or nil
						CDMOptions.ApplyIconConfigUpdate(buttonFrame, buttonData, anchorIndex, mode, isGlobal, isBuffBar)
					end)
					iconSettingsTabs:AddChild(hideStackText)
				elseif buttonData.iconType == "spell" then
					local showNotUsable = AceGUI:Create("CheckBox")
					showNotUsable:SetLabel("Show Not Usable")
					showNotUsable:SetRelativeWidth(0.5)
					showNotUsable:SetValue(buttonConfig.showNotUsable)
					showNotUsable:SetCallback("OnValueChanged", function(self, event, value)
						buttonConfig.showNotUsable = value or nil
						CDMOptions.ApplyIconConfigUpdate(buttonFrame, buttonData, anchorIndex, mode, isGlobal, isBuffBar)
					end)
					iconSettingsTabs:AddChild(showNotUsable)

					local showOutOfRange = AceGUI:Create("CheckBox")
					showOutOfRange:SetLabel("Show Out Of Range")
					showOutOfRange:SetRelativeWidth(0.5)
					showOutOfRange:SetValue(buttonConfig.showOutOfRange)
					showOutOfRange:SetCallback("OnValueChanged", function(self, event, value)
						buttonConfig.showOutOfRange = value
						C_Spell.EnableSpellRangeCheck(buttonData.spellID, value)
						CDMOptions.ApplyIconConfigUpdate(buttonFrame, buttonData, anchorIndex, mode, isGlobal, isBuffBar)
					end)
					iconSettingsTabs:AddChild(showOutOfRange)

					local forceShowCharges = AceGUI:Create("CheckBox")
					forceShowCharges:SetLabel("Force Show Charges")
					forceShowCharges:SetRelativeWidth(0.5)
					forceShowCharges:SetValue(buttonConfig.forceShowCharges)
					forceShowCharges:SetCallback("OnValueChanged", function(self, event, value)
						buttonConfig.forceShowCharges = value
						CDMOptions.ApplyIconConfigUpdate(buttonFrame, buttonData, anchorIndex, mode, isGlobal, isBuffBar)
					end)
					iconSettingsTabs:AddChild(forceShowCharges)
				end
			else
				local forceActiveSwipe = AceGUI:Create("CheckBox")
				forceActiveSwipe:SetLabel("Force Active Swipe")
				forceActiveSwipe:SetRelativeWidth(0.5)
				forceActiveSwipe:SetValue(buttonConfig.forceActiveSwipe)
				forceActiveSwipe:SetCallback("OnValueChanged", function(self, event, value)
					buttonConfig.forceActiveSwipe = value or nil
					CDMOptions.ApplyIconConfigUpdate(buttonFrame, buttonData, anchorIndex, mode, isGlobal, isBuffBar)
				end)
				iconSettingsTabs:AddChild(forceActiveSwipe)
			end
		end

		if buttonData.isCustom and (buttonData.iconType == "spell" or buttonData.iconType == "timer") then
			local castTimer = AceGUI:Create("Slider")
			castTimer:SetRelativeWidth(0.5)
			castTimer:SetSliderValues(0, 60, 0.1)
			castTimer:SetLabel("Timer Duration")
			castTimer:SetValue(buttonConfig.duration or 0)
			castTimer:SetCallback("OnValueChanged", function(_, _, value)
				buttonConfig.duration = value > 0 and value or nil
				CDMOptions.ApplyIconConfigUpdate(buttonFrame, buttonData, anchorIndex, mode, isGlobal, isBuffBar)
			end)

			iconSettingsTabs:AddChild(castTimer)
		end

		local hideCountdownNumbers = AceGUI:Create("CheckBox")
		hideCountdownNumbers:SetRelativeWidth(0.5)
		hideCountdownNumbers:SetValue(buttonConfig.hideCountdownNumbers)
		hideCountdownNumbers:SetLabel("Hide Timer Text")
		hideCountdownNumbers:SetCallback("OnValueChanged", function(self, event, value)
			buttonConfig.hideCountdownNumbers = value or nil
			CDMOptions.ApplyIconConfigUpdate(buttonFrame, buttonData, anchorIndex, mode, isGlobal, isBuffBar)
		end)
		iconSettingsTabs:AddChild(hideCountdownNumbers)
	else
		local customColor = AceGUI:Create("ColorPicker")
		customColor:SetRelativeWidth(0.5)
		customColor:SetLabel("Custom Color")
		customColor:SetHasAlpha(true)
		if buttonConfig.customColor then
			customColor:SetColor(buttonConfig.customColor.r, buttonConfig.customColor.g, buttonConfig.customColor.b, buttonConfig.customColor.a)
		end
		customColor:SetCallback("OnValueChanged", function(self, event, r, g, b, a)
			buttonConfig.customColor = { r = r, g = g, b = b, a = a }
			SCM:SkinBuffBars()
		end)
		iconSettingsTabs:AddChild(customColor)
	end
end
