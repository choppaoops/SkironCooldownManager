if not buttonData.isCustom and buttonData.iconType == "spell" then
	local useCustomGlowColor = AceGUI:Create("CheckBox")
	useCustomGlowColor:SetLabel("Use Custom Glow Color")
	useCustomGlowColor:SetRelativeWidth(0.5)
	useCustomGlowColor:SetValue(buttonConfig.useCustomGlowColor)
	useCustomGlowColor:SetDisabled(not options.useCustomGlow)
	SCM.Utils.SetDisabledTooltip(useCustomGlowColor, "Enable 'Use Custom Glow' in Global Settings > Glow first.")
	useCustomGlowColor:SetCallback("OnValueChanged", function(self, event, value)
		buttonConfig.useCustomGlowColor = value or nil
		ApplyIconConfigUpdate()
	end)
	iconSettingsTabs:AddChild(useCustomGlowColor)

	local customGlowColor = AceGUI:Create("ColorPicker")
	customGlowColor:SetRelativeWidth(0.33)
	customGlowColor:SetLabel("Glow Color")
	customGlowColor:SetHasAlpha(true)
	customGlowColor:SetDisabled(not options.useCustomGlow)
	if buttonConfig.customGlowColor then
		customGlowColor:SetColor(unpack(buttonConfig.customGlowColor))
	end
	customGlowColor:SetCallback("OnValueChanged", function(self, event, r, g, b, a)
		buttonConfig.customGlowColor = { r, g, b, a }
	end)
	iconSettingsTabs:AddChild(customGlowColor)
end

if buttonData.iconType == "spell" or buttonData.iconType == "timer" then
	local glowWhileActive = AceGUI:Create("CheckBox")
	glowWhileActive:SetLabel("Glow While Active")
	glowWhileActive:SetRelativeWidth(0.5)
	glowWhileActive:SetValue(buttonConfig.glowWhileActive)
	glowWhileActive:SetDisabled(not options.useCustomGlow)
	SCM.Utils.SetDisabledTooltip(glowWhileActive, "Enable 'Use Custom Glow' in Global Settings > Glow first.")
	glowWhileActive:SetCallback("OnValueChanged", function(self, event, value)
		buttonConfig.glowWhileActive = value or nil
		ApplyIconConfigUpdate()
	end)
	iconSettingsTabs:AddChild(glowWhileActive)

	local glowWhileInactive = AceGUI:Create("CheckBox")
	glowWhileInactive:SetLabel("Glow While Inactive")
	glowWhileInactive:SetRelativeWidth(0.5)
	glowWhileInactive:SetValue(buttonConfig.glowWhileInactive)
	glowWhileInactive:SetDisabled(not options.useCustomGlow)
	SCM.Utils.SetDisabledTooltip(glowWhileInactive, "Enable 'Use Custom Glow' in Global Settings > Glow first.")
	glowWhileInactive:SetCallback("OnValueChanged", function(self, event, value)
		buttonConfig.glowWhileInactive = value or nil
		ApplyIconConfigUpdate()
	end)
	iconSettingsTabs:AddChild(glowWhileInactive)
end
