---
--- Returns the short name of the game language.
--- @return string Short name
--- @author totalwarANGEL
function GetLanguage()
    local ShortLang = string.lower(XNetworkUbiCom.Tool_GetCurrentLanguageShortName());
    return (ShortLang == "de" and "de") or "en";
end