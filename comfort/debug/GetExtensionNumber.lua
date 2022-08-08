---
--- Returns the extension number. This function can be used to identify the
--- current expansion of the game.
--- @return number Extension Game extension
--- @author totalwarANGEL
function GetExtensionNumber()
    local Version = Framework.GetProgramVersion();
    local extensionNumber = tonumber(string.sub(Version, string.len(Version))) or 0;
    return extensionNumber;
end