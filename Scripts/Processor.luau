-- ModuleScript: Processor
local Processor = {}

-- Cooldown and mode checks
function Processor.canTouch(hitbox, model)
	local mode = hitbox.TouchMode
	local entry = hitbox._touchedPlayers[model]

	if mode == "always" then return true end
	if mode == "single" then return not entry end
	if mode == "cooldown" then
		if not entry then return true end
		return tick() >= entry
	end
	return true
end

function Processor.isValidTarget(hitbox, part)
	if not part or not part.Parent then return false end
	if part.Parent == workspace then return false end

	for _, v in ipairs(hitbox.IgnoreList) do
		if v == part or v == part.Parent then return false end
	end

	if part:FindFirstAncestorWhichIsA("Accessory") then return false end

	local model = part.Parent
	local humanoid = model:FindFirstChildOfClass("Humanoid")

	if not humanoid then return false end 

	if humanoid.Health <= 0 then return false end -- Disable if not needed

	return true, model
end

return Processor