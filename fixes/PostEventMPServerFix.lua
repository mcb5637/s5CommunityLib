
--- author:mcb		current maintainer:mcb		v0.1b
-- Automatischer fix für Hook PostEvent auf Kimichuras server.
-- Lenkt aufrufe auf Server API um, da Hook version geblockt wird.
PostEventMPServerFix = {}

function PostEventMPServerFix.Check() -- TODO triggerfix autoinit
	if PostEvent and CNetwork and PostEvent ~= PostEventMPServerFix.PostEventOverride then
		PostEvent = PostEventMPServerFix.PostEventOverride
	end
end

PostEventMPServerFix.PostEventOverride = {}
function PostEventMPServerFix.PostEventOverride.SerfExtractResource(eID, resourceType, posX, posY)
	SendEvent.SerfExtractResource(eID, resourceType, posX, posY);
end
function PostEventMPServerFix.PostEventOverride.SerfConstructBuilding(serf_eID, building_eID)
	SendEvent.SerfConstructBuilding(serf_eID, building_eID);
end
function PostEventMPServerFix.PostEventOverride.SerfRepairBuilding(serf_eID, building_eID)
	SendEvent.SerfRepairBuilding(serf_eID, building_eID);
end
function PostEventMPServerFix.PostEventOverride.HeroSniperAbility(heroId, targetId)
	SendEvent.HeroSnipeSettler(heroId, targetId);
end
function PostEventMPServerFix.PostEventOverride.HeroShurikenAbility(heroId, targetId)
	SendEvent.HeroShuriken(heroId, targetId);
end
function PostEventMPServerFix.PostEventOverride.HeroConvertSettlerAbility(heroId, targetId)
	SendEvent.HeroConvertSettler(heroId, targetId);
end
function PostEventMPServerFix.PostEventOverride.ThiefStealFrom(thiefId, buildingId)
	SendEvent.ThiefStealGoods(thiefId, buildingId);
end
function PostEventMPServerFix.PostEventOverride.ThiefCarryStolenStuffToHQ(thiefId, buildingId)
	SendEvent.ThiefSecureStolenGoods(thiefId, buildingId);
end
function PostEventMPServerFix.PostEventOverride.ThiefSabotage(thiefId, buildingId)
	SendEvent.ThiefSabotage(thiefId, buildingId);
end
function PostEventMPServerFix.PostEventOverride.ThiefDefuse(thiefId, kegId)
	SendEvent.ThiefDefuse(thiefId, kegId);
end
function PostEventMPServerFix.PostEventOverride.ScoutBinocular(scoutId, posX, posY)
	SendEvent.ScoutBinocular(scoutId, posX, posY);
end
function PostEventMPServerFix.PostEventOverride.ScoutPlaceTorch(scoutId, posX, posY)
	SendEvent.ScoutPlaceTorch(scoutId, posX, posY);
end
function PostEventMPServerFix.PostEventOverride.HeroPlaceBombAbility(heroId, posX, posY)
	SendEvent.HeroPlaceBomb(heroId, posX, posY);
end
function PostEventMPServerFix.PostEventOverride.LeaderBuySoldier(leaderId)
	SendEvent.BuySoldier(leaderId);
end
function PostEventMPServerFix.PostEventOverride.UpgradeBuilding(buildingId)
	SendEvent.UpgradeBuilding(buildingId);
end
function PostEventMPServerFix.PostEventOverride.CancelBuildingUpgrade(buildingId)
	SendEvent.CancelBuildingUpgrade(buildingId);
end
function PostEventMPServerFix.PostEventOverride.ExpellSettler(entityId)
	SendEvent.ExpelSettler(entityId);
end
function PostEventMPServerFix.PostEventOverride.BuySerf(buildingId)
	SendEvent.BuySerf(GetPlayer(buildingId), buildingId);
end
function PostEventMPServerFix.PostEventOverride.SellBuilding(buildingId)
	SendEvent.SellBuilding(GetPlayer(buildingId), buildingId);
end
function PostEventMPServerFix.PostEventOverride.FoundryConstructCannon(buildingId, entityType)
	SendEvent.BuyCannon(buildingId, entityType);
end
function PostEventMPServerFix.PostEventOverride.HeroPlaceCannonAbility(heroId, bottomType, topType, posX, posY)
	SendEvent.HeroPlaceCannon(heroId, bottomType, topType, posX, posY);
end
