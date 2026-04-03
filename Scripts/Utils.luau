-- ModuleScript: Utils
local Workspace = game:GetService("Workspace")
local Utils = {}

-- Safe search for parts in a box area
function Utils.safeGetPartsInBox(cframe, size, overlapParams)
    local ok, parts = pcall(function()
        return Workspace:GetPartBoundsInBox(cframe, size, overlapParams)
    end)
    return (ok and parts) or {}
end

-- Remove object from table by value
function Utils.tableRemoveValue(tbl, val)
    for i, v in ipairs(tbl) do
        if v == val then
            table.remove(tbl, i)
            return true
        end
    end
    return false
end

return Utils