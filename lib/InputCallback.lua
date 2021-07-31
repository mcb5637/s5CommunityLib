if mcbPacker then --mcbPacker.ignore
mcbPacker.require("s5CommunityLib/fixes/TriggerFix")
mcbPacker.require("s5CommunityLib/fixes/TriggerFixCppLogicExtension")
mcbPacker.require("s5CommunityLib/tables/MouseEvents")
end --mcbPacker.ignore

--- author:mcb		current maintainer:mcb		v1
-- InputCallbacks für mehr als eine funktion.
--
-- InputCallback.AddCallback(typ, cb)               fügt einen callback hinzu.
-- InputCallback.RemoveCallback(typ, cb)            entfernt einen callback.
-- typ ist jeweils:
-- InputCallback.TriggerType.KeyTrigger             aufgerufen, wenn ein key gedrückt oder losgelassen wird. (key, up).
-- InputCallback.TriggerType.CharTrigger            aufgerufen, wenn ein key (oder kombination) gedrückt wird, der zu einem char wird. (char).
-- InputCallback.TriggerType.MouseTrigger           aufgerufen, wenn die maus genutzt wird: (siehe CppLogic.UI.SetMouseTrigger).
--
-- Benötigt:
-- - TriggerFix
-- - CppLogic
-- - nicht Kimichuras dlls
InputCallback = {KeyTriggers = {}, CharTriggers = {}, MouseTriggers = {}}
InputCallback.TriggerType = {KeyTrigger="KeyTriggers", CharTrigger="CharTriggers", MouseTrigger="MouseTriggers"}

function InputCallback.AddHandlers()
    CppLogic.UI.SetMouseTrigger(function(id, x, y, a)
        for _,cb in ipairs(InputCallback.MouseTriggers) do
            xpcall(function()
                cb(id, x, y, a)
            end, TriggerFix.ShowErrorMessage)
        end
    end)
    CppLogic.UI.SetKeyTrigger(function(key, up)
        for _,cb in ipairs(InputCallback.KeyTriggers) do
            xpcall(function()
                cb(key, up)
            end, TriggerFix.ShowErrorMessage)
        end
    end)
    CppLogic.UI.SetCharTrigger(function(char)
        char = string.char(char)
        for _,cb in ipairs(InputCallback.CharTriggers) do
            xpcall(function()
                cb(char)
            end, TriggerFix.ShowErrorMessage)
        end
    end)
end

function InputCallback.AddCallback(typ, cb)
    assert(InputCallback[typ])
    table.insert(InputCallback[typ], cb)
end
function InputCallback.RemoveCallback(typ, cb)
    assert(InputCallback[typ])
    for i=table.getn(InputCallback[typ]), 1, -1 do
        if InputCallback[typ][i] == cb then
            table.remove(InputCallback[typ], i)
        end
    end
end

AddMapStartAndSaveLoadedCallback("InputCallback.AddHandlers")
