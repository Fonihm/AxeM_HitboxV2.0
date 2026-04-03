-- ModuleScript: Visualizer
local Visualizer = {}

function Visualizer.create(params)
	local visual = Instance.new("Part")
	visual.Name = "AxeMHitbox_Visual"
	visual.CastShadow = false
	visual.Massless = true
	visual.CanTouch = false
	visual.CanQuery = false
	visual.CanCollide = false
	
	Visualizer.update(visual, params)
	return visual
end

function Visualizer.update(part, params)
	if not part then return end
	part.Size = params.Size
	part.Color = params.Color
	part.Transparency = params.Visible and params.VisibleTransparency or 1
	part.Anchored = params.Anchored
	part.Parent = params.AutoParent
end

return Visualizer