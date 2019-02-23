
--- author:???,mcb		current maintainer:mcb		v2.0
-- Zieht Rohstoffe ab.
function SubFromPlayersResources( _id, _gold, _clay, _wood, _stone, _iron, _sulfur, _noMessage, _onlyCheck )
    if type(_id)=="table" then
		_onlyCheck = _clay
		_noMessage = _gold
		_gold = _id[ResourceType.Gold]
		_clay = _id[ResourceType.Clay]
		_wood = _id[ResourceType.Wood]
		_stone = _id[ResourceType.Stone]
		_iron = _id[ResourceType.Iron]
		_sulfur = _id[ResourceType.Sulfur]
		_id = GUI.GetPlayerID()
	end
	local goldmissing,claymissing,woodmissing,stonemissing,ironmissing,sulfurmissing = 0,0,0,0,0,0;
    _gold = _gold or 0
	_clay = _clay or 0
	_wood = _wood or 0
	_stone = _stone or 0
	_iron = _iron or 0
	_sulfur = _sulfur or 0
	if _gold > 0 then
        local gold = GetGold(_id);
        if (gold-_gold) < 0 then
            goldmissing = (_gold-gold);
			if not _noMessage then
				Message(string.format(XGUIEng.GetStringTableText("InGameMessages/GUI_NotEnoughMoney"), goldmissing))
				--Sound.PlayQueuedFeedbackSound(Sounds.VoicesMentor_INFO_NotEnoughGold_rnd_01,0);
				GUI.SendNotEnoughResourcesFeedbackEvent(ResourceType.Gold, goldmissing)
			end
        end
    end
    if _clay > 0 then
        local clay = GetClay(_id);
        if (clay-_clay) < 0 then
            claymissing = (_clay-clay);
			if not _noMessage then
				Message(string.format(XGUIEng.GetStringTableText("InGameMessages/GUI_NotEnoughClay"), claymissing))
				--Sound.PlayQueuedFeedbackSound(Sounds.VoicesMentor_INFO_NotEnoughClay_rnd_01,0);
				GUI.SendNotEnoughResourcesFeedbackEvent(ResourceType.Clay, claymissing)
			end
        end
    end
    if _wood > 0 then
        local wood = GetWood(_id);
        if (wood-_wood) < 0 then
            woodmissing = (_wood-wood);
			if not _noMessage then
				Message(string.format(XGUIEng.GetStringTableText("InGameMessages/GUI_NotEnoughWood"), woodmissing))
				--Sound.PlayQueuedFeedbackSound(Sounds.VoicesMentor_INFO_NotEnoughWood_rnd_01,0);
				GUI.SendNotEnoughResourcesFeedbackEvent(ResourceType.Wood, woodmissing)
			end
        end
    end
    if _stone > 0 then
        local stone = GetStone(_id);
        if (stone-_stone) < 0 then
            stonemissing = (_stone-stone);
			if not _noMessage then
				Message(string.format(XGUIEng.GetStringTableText("InGameMessages/GUI_NotEnoughStone"), stonemissing))
				--Sound.PlayQueuedFeedbackSound(Sounds.VoicesMentor_INFO_NotEnoughStone_rnd_01,0);
				GUI.SendNotEnoughResourcesFeedbackEvent(ResourceType.Stone, stonemissing)
			end
        end
    end
    if _iron > 0 then
        local iron = GetIron(_id);
        if (iron-_iron) < 0 then
            ironmissing = (_iron-iron);
			if not _noMessage then
				Message(string.format(XGUIEng.GetStringTableText("InGameMessages/GUI_NotEnoughIron"), ironmissing))
				--Sound.PlayQueuedFeedbackSound(Sounds.VoicesMentor_INFO_NotEnoughIron_rnd_01,0);
				GUI.SendNotEnoughResourcesFeedbackEvent(ResourceType.Iron, ironmissing)
			end
        end
    end
    if _sulfur > 0 then
        local sulfur = GetSulfur(_id);
        if (sulfur-_sulfur) < 0 then
            sulfurmissing = (_sulfur-sulfur);
			if not _noMessage then
				Message(string.format(XGUIEng.GetStringTableText("InGameMessages/GUI_NotEnoughSulfur"), sulfurmissing))
				--Sound.PlayQueuedFeedbackSound(Sounds.VoicesMentor_INFO_NotEnoughSulfur_rnd_01,0);
				GUI.SendNotEnoughResourcesFeedbackEvent(ResourceType.Sulfur, sulfurmissing)
			end
        end
    end
	if goldmissing==0 and claymissing==0 and woodmissing==0 and stonemissing==0 and ironmissing==0 and sulfurmissing==0 then
		if not _onlyCheck then
			AddGold(_id, -(_gold))
			AddClay(_id, -(_clay))
			AddWood(_id, -(_wood))
			AddStone(_id, -(_stone))
			AddIron(_id, -(_iron))
			AddSulfur(_id, -(_sulfur))
		end
        return true
	else
		return false,goldmissing,claymissing,woodmissing,stonemissing,ironmissing,sulfurmissing
	end
end
