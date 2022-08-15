---
-- Provides function to replace placeholders in texts.
-- @sort=true
--

if mcbPacker then --mcbPacker.ignore
    mcbPacker.require("s5CommunityLib/comfort/table/GetLanguage")
end --mcbPacker.ignore

---
--- Replaces the placeholders in the message with their values.
--- @param _Message string Text to parse
--- @return string Text New text
function ReplacePlaceholders(_Message)
    return Internal_ReplacePlaceholders(_Message);
end

---
--- Removes the most common placeholders from the text.
--- @param _Message string Text to cleanse
--- @return string Text New text
function RemovePlaceholders(_Message)
    return Internal_RemoveFormattingPlaceholders(_Message);
end

---
--- Adds a Display name for the scriptname.
--- @param _ScriptName string        Script name of entiy
--- @param _DisplayName string|table Name to be replaced
function ReplacePlaceholders(_ScriptName, _DisplayName)
    gvPlaceholders.Data.NamedEntityNames[_ScriptName] = _DisplayName;
end

-- -------------------------------------------------------------------------- --

gvPlaceholders = {
    Data = {
        LastNpcId = 0,
        LastHeroId = 0,
        LastNpcName = nil,
        LastHeroName = nil,

        NamedEntityNames = {},
    },
};

GameCallback_OnGameStart_Orig_Placeholders = GameCallback_OnGameStart;
GameCallback_OnGameStart = function()
    GameCallback_OnGameStart_Orig_Placeholders();

    Message_Original_Placeholders = Message;
    Message = function(_Text)
        if type(_Text) == "table" then
            _Text = _Text[GetLanguage()];
        end
        Message(ReplacePlaceholders(_Text));
    end

    GameCallback_NPCInteraction_Orig_Placeholders = GameCallback_NPCInteraction;
    GameCallback_NPCInteraction = function(_NpcID, _HeroID)
        GameCallback_NPCInteraction_Orig_Placeholders(_NpcID, _HeroID);

        gvPlaceholders.Data.LastNpcId = _NpcID;
        gvPlaceholders.Data.LastHeroId = _HeroID;
        gvPlaceholders.Data.LastNpcName = Logic.GetEntityName(_NpcID);
        gvPlaceholders.Data.LastHeroName = Logic.GetEntityName(_HeroID);
    end
end

function Internal_ReplacePlaceholders(_Message)
    if type(_Message) == "table" then
        for k, v in pairs(_Message) do
            _Message[k] = Internal_ReplacePlaceholders(v);
        end

    elseif type(_Message) == "string" then
        -- Replace hero name
        local HeroName = "HERO_NAME_NOT_FOUND";
        if gvPlaceholders.Data.NamedEntityNames[gvPlaceholders.Data.LastHeroName] then
            HeroName = gvPlaceholders.Data.NamedEntityNames[gvPlaceholders.Data.LastHeroName];
            if type(HeroName) == "table" then
                HeroName = HeroName[GetLanguage()];
            end
        end
        _Message = string.gsub(_Message, "{hero}", HeroName);

        -- Replace npc name
        local NpcName = "NPC_NAME_NOT_FOUND"
        if gvPlaceholders.Data.NamedEntityNames[gvPlaceholders.Data.LastNpcName] then
            NpcName = gvPlaceholders.Data.NamedEntityNames[gvPlaceholders.Data.LastNpcName];
            if type(NpcName) == "table" then
                NpcName = NpcName[GetLanguage()];
            end
        end
        _Message = string.gsub(_Message, "{npc}", NpcName);

        -- Replace value placeholders
        _Message = Internal_ReplaceKeyValuePlaceholders(_Message);

        -- Replace basic placeholders last        
        _Message = string.gsub(_Message, "{cr}", " @cr ");
        _Message = string.gsub(_Message, "{nl}", " @cr ");
        _Message = string.gsub(_Message, "{ra}", " @ra ");
        _Message = string.gsub(_Message, "{center}", " @center ");
        _Message = string.gsub(_Message, "{red}", " @color:180,0,0 ");
        _Message = string.gsub(_Message, "{green}", " @color:0,180,0 ");
        _Message = string.gsub(_Message, "{blue}", " @color:0,0,180 ");
        _Message = string.gsub(_Message, "{yellow}", " @color:235,235,0 ");
        _Message = string.gsub(_Message, "{violet}", " @color:180,0,180 ");
        _Message = string.gsub(_Message, "{orange}", " @color:235,158,52 ");
        _Message = string.gsub(_Message, "{azure}", " @color:0,180,180 ");
        _Message = string.gsub(_Message, "{black}", " @color:40,40,40 ");
        _Message = string.gsub(_Message, "{white}", " @color:255,255,255 ");
        _Message = string.gsub(_Message, "{grey}", " @color:180,180,180 ");
        _Message = string.gsub(_Message, "{trans}", " @color:0,0,0,0 ");
        _Message = string.gsub(_Message, "{none}", " @color:0,0,0,0 ");
    end
    return _Message;
end

function Internal_ReplaceKeyValuePlaceholders(_Message)
    local s, e = string.find(_Message, "{", 1);
    while (s) do
        local ss, ee      = string.find(_Message, "}", e+1);
        local Before      = (s <= 1 and "") or string.sub(_Message, 1, s-1);
        local After       = (ee and string.sub(_Message, ee+1)) or "";
        local Placeholder = string.sub(_Message, e+1, ss-1);

        if string.find(Placeholder, "color") then
            _Message = Before .. " @" .. Placeholder .. " " .. After;
        end
        if string.find(Placeholder, "val:") then
            local Value = _G[string.sub(Placeholder, string.find(Placeholder, ":")+1)];
            if type(Value) == "string" or type(Value) == "number" then
                _Message = Before .. Value .. After;
            end
        end
        if string.find(Placeholder, "name:") then
            local Value = string.sub(Placeholder, string.find(Placeholder, ":")+1);
            if Value and gvPlaceholders.Data.NamedEntityNames[Value] then
                _Message = Before .. gvPlaceholders.Data.NamedEntityNames[Value] .. After;
            end
        end
        s, e = string.find(_Message, "{", ee+1);
    end
    return _Message;
end

function Internal_RemoveFormattingPlaceholders(_Message)
    if type(_Message) == "table" then
        for k, v in pairs(_Message) do
            _Message[k] = Internal_RemoveFormattingPlaceholders(v);
        end
    elseif type(_Message) == "string" then
        _Message = string.gsub(_Message, "{ra}", "");
        _Message = string.gsub(_Message, "{cr}", "");
        _Message = string.gsub(_Message, "{center}", "");
        _Message = string.gsub(_Message, "{color:%d,%d,%d}", "");
        _Message = string.gsub(_Message, "{color:%d,%d,%d,%d}", "");
        _Message = string.gsub(_Message, "{red}", "");
        _Message = string.gsub(_Message, "{green}", "");
        _Message = string.gsub(_Message, "{blue}", "");
        _Message = string.gsub(_Message, "{yellow}", "");
        _Message = string.gsub(_Message, "{violet}", "");
        _Message = string.gsub(_Message, "{azure}", "");
        _Message = string.gsub(_Message, "{black}", "");
        _Message = string.gsub(_Message, "{white}", "");
        _Message = string.gsub(_Message, "{trans}", "");
        _Message = string.gsub(_Message, "{none}", "");
        _Message = string.gsub(_Message, "{grey}", "");

        _Message = string.gsub(_Message, "@color:%d,%d,%d", "");
        _Message = string.gsub(_Message, "@color:%d,%d,%d,%d", "");
        _Message = string.gsub(_Message, "@center", "");
        _Message = string.gsub(_Message, "@ra", "");
        _Message = string.gsub(_Message, "@cr", "");
    end
    return _Message;
end