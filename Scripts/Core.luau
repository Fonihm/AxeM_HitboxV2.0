-- ModuleScript: AxeMHitbox (Server)
-- Author: AxeM_FoNi
-- Description:
--                             /\_/\  
--                            ( •.• )  AxeM
--  ---------------------------------------------------------------¬
--  ¦                       AxeM_Hitbox v2.0                       ¦
--  ¦              Modular High-Precision Hitbox System            ¦
--  ¦                                                              ¦
--  ¦  Parameters for creation (.new):                             ¦
--  ¦   - AnchorPart    : BasePart (Hitbox attachment center)      ¦
--  ¦   - Size          : Vector3 (Hitbox dimensions)              ¦
--  ¦   - Offset        : Vector3 (Position offset from center)    ¦
--  ¦   - Color         : Color3 (Visualization color)             ¦
--  ¦   - Visible       : boolean (Show/Hide box)                  ¦
--  ¦   - TouchMode     : "single" | "cooldown" | "always"         ¦
--  ¦   - TouchCooldown : Delay for "cooldown" mode (sec)          ¦
--  ¦   - OnModelTouched: Callback function (model, hitbox, part)  ¦
--  ¦   - IgnoreList    : {objects} (List of excluded objects)     ¦
--  ¦   - Debug         : boolean (Process logging)                ¦
--  ¦                                                              ¦
--  ¦  Methods (API):                                              ¦
--  ¦   :Enable() / :Disable() - Activity management               ¦
--  ¦   :SetSize(vec3), :SetOffset(vec3), :SetColor(rgb)           ¦
--  ¦   :SetVisible(bool), :SetTouchMode(mode)                     ¦
--  ¦   :AddIgnore(obj), :RemoveIgnore(obj), :ResetTouches()       ¦
--  ¦   :Destroy() - Full resource cleanup                         ¦
--  ¦                                                              ¦
--  L---------------------------------------------------------------
--[[

    USAGE EXAMPLE:

    local AxeM_Hitbox = require(path.to.AxeMHitbox)

    local hitbox = AxeM_Hitbox.new({                                
        AnchorPart = script.Parent,                                 
        Size = Vector3.new(4, 6, 4),                                     
        Visible = true,                                         
        TouchMode = "cooldown",                                     
        TouchCooldown = 0.5,                                          
        OnModelTouched = function(model, hb, part)                
            print("Hit registered on: " .. model.Name)            
        end                                                     
    })                                                          
    
    hitbox:Enable() 

--]]

-- ModuleScript: Core
local RunService = game:GetService("RunService")

local Settings = require(script.Parent.Settings)
local Utils = require(script.Parent.Utils)
local Visualizer = require(script.Parent.Visualizer)
local Processor = require(script.Parent.Processor)

local AxeMHitbox = {}
AxeMHitbox.__index = AxeMHitbox

function AxeMHitbox.new(params)
    params = params or {}
    local self = setmetatable({}, AxeMHitbox)
    local D = Settings.DEFAULTS

    self.Size = params.Size or D.Size
    self.Color = params.Color or D.Color
    self.Visible = (params.Visible ~= nil) and params.Visible or D.Visible
    self.VisibleTransparency = params.VisibleTransparency or D.VisibleTransparency
    self.Anchored = (params.Anchored ~= nil) and params.Anchored or D.Anchored
    self.PollRate = params.PollRate or D.PollRate
    self.Offset = params.Offset or D.Offset
    self.AutoParent = params.AutoParent or D.AutoParent
    self.TouchMode = params.TouchMode or D.TouchMode
    self.TouchCooldown = params.TouchCooldown or D.TouchCooldown
    self.OnModelTouched = params.OnModelTouched

    self.IgnoreList = {}
    if params.IgnoreList then
        for _, inst in ipairs(params.IgnoreList) do table.insert(self.IgnoreList, inst) end
    end

    -- PRE-CREATION OF PARAMETERS (Optimization)
    self._overlapParams = OverlapParams.new()
    self._overlapParams.FilterType = Enum.RaycastFilterType.Exclude
    self._overlapParams.MaxParts = 10 
    self:_updateIgnoreList() -- Sync the ignore list

    self.AnchorPart = params.AnchorPart
    assert(self.AnchorPart and self.AnchorPart:IsA("BasePart"), "AxeMHitbox: Check AnchorPart")

    self._touchedPlayers = {}
    self._enabled = false
    self._visual = Visualizer.create(self)

    return self
end

-- Internal method to update the filter
function AxeMHitbox:_updateIgnoreList()
    if self._overlapParams then
        self._overlapParams.FilterDescendantsInstances = self.IgnoreList
    end
end

function AxeMHitbox:_updateVisual()
    if not self._visual or not self.AnchorPart then return end
    self._visual.CFrame = self.AnchorPart.CFrame * CFrame.new(self.Offset)
    Visualizer.update(self._visual, self)
end

function AxeMHitbox:_markTouchedModel(model)
    if self.TouchMode == "single" then
        self._touchedPlayers[model] = true
    elseif self.TouchMode == "cooldown" then
        self._touchedPlayers[model] = tick() + (self.TouchCooldown or 0)
    end
end

function AxeMHitbox:_handleCandidatePart(part)
    local isValid, model = Processor.isValidTarget(self, part)
    if not isValid then return end

    if not Processor.canTouch(self, model) then return end

    self:_markTouchedModel(model)

    if self.OnModelTouched then
        -- Use an anonymous function for pcall to pass arguments
        local ok, result = pcall(function()
            return self.OnModelTouched(model, self, part)
        end)

        if ok and type(result) == "table" and result.Consume == false then
            self._touchedPlayers[model] = nil
        elseif not ok then
            warn("AxeMHitbox Error:", result)
        end
    end
end

function AxeMHitbox:Enable()
    if self._enabled then return end
    self._enabled = true
    self:_updateVisual()

    if self._visual then
        if self._touchConn then self._touchConn:Disconnect() end
        self._touchConn = self._visual.Touched:Connect(function(part)
            self:_handleCandidatePart(part)
        end)
    end

    local accum = 0
    self._hbConn = RunService.Heartbeat:Connect(function(dt)
        if not self._enabled then return end
        self:_updateVisual()

        accum = accum + dt
        if accum < self.PollRate then return end
        accum = accum - self.PollRate

        -- Pre-configured OverlapParams used here for optimization
        local cframe = self.AnchorPart.CFrame * CFrame.new(self.Offset)
        local parts = Utils.safeGetPartsInBox(cframe, self.Size, self._overlapParams)

        for _, p in ipairs(parts) do
            if p ~= self._visual then
                self:_handleCandidatePart(p)
            end
        end
    end)
end

function AxeMHitbox:Disable()
    if not self._enabled then return end
    self._enabled = false
    if self._touchConn then self._touchConn:Disconnect(); self._touchConn = nil end
    if self._hbConn then self._hbConn:Disconnect(); self._hbConn = nil end
    if self._visual then self._visual.Transparency = 1 end
end

function AxeMHitbox:Destroy()
    self:Disable()
    if self._visual then self._visual:Destroy(); self._visual = nil end
    self._touchedPlayers = {}
    self._overlapParams = nil
    setmetatable(self, nil)
end

-- Setters with parameter updates
function AxeMHitbox:SetSize(vec3) self.Size = vec3 self:_updateVisual() end

function AxeMHitbox:AddIgnore(instance) 
    table.insert(self.IgnoreList, instance) 
    self:_updateIgnoreList() 
end

function AxeMHitbox:ResetTouches(model) 
    if model then self._touchedPlayers[model] = nil else self._touchedPlayers = {} end 
end

return AxeMHitbox