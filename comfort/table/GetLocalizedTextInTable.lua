if mcbPacker then --mcbPacker.ignore
    mcbPacker.require("s5CommunityLib/comfort/table/GetLanguage")
end --mcbPacker.ignore

---
--- Returns the localized text from the input.
--- @param _Text table Text to translate
--- @return string Text
--
function GetLocalizedTextInTable(_Text)
    if type(_Text) == "table" then
        return _Text[GetLanguage()] or " ERROR_TEXT_INVALID ";
    end
    return _Text;
end