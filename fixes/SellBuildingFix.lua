if mcbPacker then
	mcbPacker.require("s5CommunityLib/fixes/TriggerFix")
end

GUI_SellBuildingOrig = GUI.SellBuilding

function OverrideSellingBuilding()
	function GUI.SellBuilding(_id)
		GUI_SellBuildingOrig(_id)
		local _upgradecategory = Logic.GetUpgradeCategoryByBuildingType(Logic.GetEntityType(_id))
		if _upgradecategory ==  UpgradeCategories.Beautification05 then
			AddGold(-50)
			AddClay(-50)
			AddGold(150)
			AddStone(50)
		end
		if _upgradecategory ==  UpgradeCategories.Beautification07 then
			AddGold(-200)
			AddStone(-100)
			AddGold(150)
			AddWood(50)
		end
	end
end

AddMapStartAndSaveLoadedCallback(OverrideSellingBuilding)
