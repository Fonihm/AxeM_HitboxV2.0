-- ModuleScript: Settings
local Settings = {
	DEFAULTS = {
		Size = Vector3.new(6, 6, 6),
		Color = Color3.fromRGB(255, 0, 0),
		Visible = false,
		VisibleTransparency = 0.6,
		Anchored = true,
		PollRate = 0.01,
		Offset = Vector3.new(0, 0, 0),
		IgnoreList = {},
		AutoParent = workspace,
		TouchMode = "single", -- "single" | "cooldown" | "always"
		TouchCooldown = 1.0,
	}
}
return Settings