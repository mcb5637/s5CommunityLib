if mcbPacker then --mcbPacker.ignore
mcbPacker.require("s5CommunityLib/fixes/TriggerFix")
mcbPacker.require("s5CommunityLib/fixes/TriggerFixCppLogicExtension")
end --mcbPacker.ignore


--- author:mcb		current maintainer:mcb		v1.0
-- 
-- Erlaubt die verwendung mehrerer S5Hook.SetNetEventTrigger gleichzeitig und vereinfacht das Lesen/Schreiben der Daten.
-- 
-- - CNetEventCallbacks.Add(eventid, func)			Fügt einen Callback hinzu.
-- - CNetEventCallbacks.Remove(eventid, func)		Entfernt eien Callback.
-- - CNetEventCallbacks.CNetEvents					Table mit allen bekannten CNetEvents.
-- 
-- Aufgerufen werden die Callbacks mit nur einem Parameter, einem table in dem alle Informationen stehen.
-- Informatonen hängen vom Eventtyp ab, und können in der Liste unten eingesehen werden.
-- Ein cb kann 2 werte zurückgeben: write, ignore.
-- wenn ignore gesetzt ist, wird das event danach ignoriert (im c++ code).
-- wenn write gesetzt ist, werden darin enthaltene werte zurück in das event geschrieben.
-- 
-- Liste der CNetEvents:
-- - CNetEventSubclass:									(prameter list)
-- 		CommandName							Optionen, dasselbe in Lua zu erreichen
-- 
-- - EGL::CNetEvent2Entities:							{EntityID1, EntityID2} (normalerweise ActorId, TargetId)
-- 		CommandEntityAttackEntity			Logic.GroupAttack
--		CommandSerfConstructBuilding		CppLogic.Entity.Settler.CommandSerfConstructBuilding
--		CommandSerfRepairBuilding			CppLogic.Entity.Settler.CommandSerfRepairBuilding
--		CommandEntityGuardEntity			Logic.GroupGuard
--		CommandHeroConvertSettler			CppLogic.Entity.Settler.CommandConvert
--		CommandThiefStealFrom				CppLogic.Entity.Settler.CommandStealFrom
--		CommandThiefCarryStolenStuffToHQ	CppLogic.Entity.Settler.CommandSecureGoods
--		CommandThiefSabotageBuilding		CppLogic.Entity.Settler.CommandSabotage
--		CommandThiefDefuseKeg				CppLogic.Entity.Settler.CommandDefuse
--		CommandHeroSnipeSettler				CppLogic.Entity.Settler.CommandSnipe
--		CommandHeroThrowShurikenAt			CppLogic.Entity.Settler.CommandShuriken
--		69688
--		69693
-- 
-- - GGL::CNetEventCannonCreator:						{EntityID, FoundationType, CannonType, Position, Orientation(rad)}
--		CommandHeroPlaceCannonAt			CppLogic.Entity.Settler.CommandPlaceCannon
-- 
-- - EGL::CNetEventEntityAndPos:						{EntityID, X, Y}
-- 		CommandHeroPlaceBombAt				CppLogic.Entity.Settler.CommandPlaceBomb
-- 		CommandEntityAttackPos				Logic.GroupAttackMove
-- 		CommandHeroSendHawkToPos			GUI.SendHawk/CppLogic.Entity.Settler.CommandSendHawk
-- 		CommandScoutUseBinocularsAt			CppLogic.Entity.Settler.CommandBinocular
-- 		CommandScoutPlaceTorchAtPos			CppLogic.Entity.Settler.CommandPlaceTorch
-- 
-- - EGL::CNetEventEntityAndPosArray:					{EntityID, Position, Orientation(rad)} (Position ist array of {X,Y})
-- 		CommandEntityMove					Logic.MoveSettler
-- 		CommandEntityPatrol					Logic.GroupPatrol + Logic.GroupAddPatrolPoint
-- 
-- - EGL::CNetEventEntityID:							{EntityID}
-- 		CommandBuildingStartUpgrade			GUI.UpgradeSingleBuilding/CppLogic.Entity.Building.StartUpgrade
-- 		CommandLeaderBuySoldier				CppLogic.Entity.Building.BarracksBuySoldierForLeader
-- 		CommandSettlerExpell				CppLogic.Entity.Settler.CommandExpell
-- 		CommandBuildingCancelResearch		GUI.CancelResearch/CppLogic.Entity.Building.CancelResearch
-- 		CommandMarketCancelTrade			GUI.CancelTransaction/CppLogic.Entity.Building.MarketCancelTrade
-- 		CommandBuildingCancelUpgrade		GUI.CancelBuildingUpgrade/CppLogic.Entity.Building.CancelUpgrade
-- 		CommandLeaderHoldPosition			Logic.GroupStand
-- 		CommandLeaderDefend					Logic.GroupDefend
-- 		CommandBattleSerfTurnToSerf			GUI.ChangeToSerf/CppLogic.Entity.Settler.CommandTurnBattleSerfToSerf
-- 		CommandSerfTurnToBattleSerf			GUI.ChangeToBattleSerf/CppLogic.Entity.Settler.CommandTurnSerfToBattleSerf
-- 		CommandHeroActivateCamouflage		GUI.SettlerCamouflage
-- 		CommandHeroActivateSummon			GUI.SettlerSummon/CppLogic.Entity.Settler.CommandSummon
-- 		CommandBuildingToggleOvertime		GUI.ToggleOvertimeAtBuilding/CppLogic.Entity.Building.ActivateOvertime/CppLogic.Entity.Building.DeactivateOvertime
-- 		CommandHeroAffectEntities			GUI.SettlerAffectUnitsInArea/CppLogic.Entity.Settler.CommandHeroAffectEntities
-- 		CommandHeroCircularAttack			GUI.SettlerCircularAttack/CppLogic.Entity.Settler.CommandCircularAttack
-- 		CommandHeroInflictFear				GUI.SettlerInflictFear/CppLogic.Entity.Settler.CommandInflictFear
-- 		CommandBarracksRecruitGroups		GUI.DeactivateAutoFillAtBarracks/CppLogic.Entity.Building.BarracksRecruitLeaders
-- 		CommandBarracksRecruitLeaderOnly	GUI.ActivateAutoFillAtBarracks/CppLogic.Entity.Building.BarracksRecruitGroups
-- 		CommandHeroMotivateWorkers			GUI.SettlerMotivateWorkers/CppLogic.Entity.Settler.CommandHeroMotivateWorkers
-- 		CommandScoutFindResources			GUI.ScoutPointToResources/CppLogic.Entity.Settler.CommandScoutFindResources
-- 		69648
-- 		69649
--		69651								Logic.LeaderGetOneSoldier
--		69652
--		69666
-- 
-- - GGL::CNetEventBuildingCreator:						{PlayerID, EntityType(is ucat), Position, Orientation(rad), Serf{id1,id2,...}} (crasht wenn Serf leer)
-- 		CommandPlaceBuilding				Logic.CreateConstructionSite + CppLogic.Entity.Settler.CommandSerfConstructBuilding
-- 
-- - EGL::CNetEventEntityIDAndPlayerID:					{PlayerID, EntityID}
-- 		CommandHQBuySerf					CppLogic.Entity.Building.HQBuySerf
-- 		CommandBuildingSell					CppLogic.Entity.Building.SellBuilding
-- 		69639
-- 
-- - EGL::CNetEventPlayerID:							{PlayerID}
-- 		CommandPlayerActivateAlarm			CppLogic.Logic.PlayerActivateAlarm
-- 		CommandPlayerDeactivateAlarm		CppLogic.Logic.PlayerDeactivateAlarm
-- 		69637
-- 		69645
-- 		69674
-- 		69675
-- 
-- - EGL::CNetEventIntegerAndPlayerID:					{PlayerID, Value}
-- 		PlayerUpgradeSettlerCategory		GUI.UpgradeSettlerCategory/CppLogic.Logic.PlayerUpgradeSettlerCategory
-- 		CommandPlayerSetTaxes				GUI.SetTaxLevel/CppLogic.Logic.PlayerSetTaxLevel
-- 		CommandWeathermachineChangeWeather	GUI.SetWeather/CppLogic.Logic.PlayerActivateWeatherMachine
-- 		CommandMonasteryBlessSettlerGroup	GUI.BlessByBlessCategory/CppLogic.Logic.PlayerBlessSettlers
-- 		69641
-- 
-- - EGL::CNetEventPlayerIDAndInteger:					{PlayerID, Value}
--  	CommandPlayerPayTribute				GUI.PayTribute
-- 
-- - EGL::CNetEvent2PlayerIDsAndInteger:				???
-- 		69671
-- 
-- - GGL::CNetEventEntityIDAndUpgradeCategory:			{EntityID, UpgradeCategory}
-- 		CommandBarracksBuyLeader			Logic.BarracksBuyLeader
-- 
-- - EGL::CNetEventEntityIDAndInteger:					{EntityID, Value}
-- 		CommandLeaderSetFormation			Logic.LeaderChangeFormationType
-- 		CommandBuildingSetCurrentMaxWorkers	Logic.SetCurrentMaxNumWorkersInBuilding
-- 		CommandFoundryBuildCannon			PostEvent.FoundryConstructCannon/CppLogic.Entity.Building.CommandFoundryBuildCannon
-- 
-- - GGL::CNetEventExtractResource:						{SerfID, ResourceType, Position}
-- 		CommandSerfExtractResource			CppLogic.Entity.Settler.CommandSerfExtract
-- 
-- - GGL::CNetEventTechnologyAndEntityID:				{EntityID, TechnologyType}
-- 		CommandBuildingStartResearch		GUI.StartResearch/CppLogic.Entity.Building.StartResearch
-- 
-- - GGL::CNetEventTransaction:							{MarketID, SellResource, BuyResource, BuyAmount}
-- 		CommandMarketStartTrade				GUI.StartTransaction/CppLogic.Entity.Building.MarketStartTrade
-- 
-- - GGL::CNetEventPlayerResourceDonation:				???
-- 		69691
-- 
-- - EGL::CNetEventEntityIDAndPlayerIDAndEntityType:	???
-- 		69692
-- 
-- - GGL::CNetEventEntityIDPlayerIDAndInteger:			???
-- 		69698
-- 
-- Benötigt:
-- - CppLoader
-- - TriggerFix
-- 
CNetEventCallbacks = {cbs = {}}

function CNetEventCallbacks.Add(eventid, func)
	if not CNetEventCallbacks.cbs[eventid] then
		CNetEventCallbacks.cbs[eventid] = {}
	end
	table.insert(CNetEventCallbacks.cbs[eventid], func)
end

function CNetEventCallbacks.Remove(eventid, func)
	for i=table.getn(CNetEventCallbacks.cbs[eventid]),1,-1 do
		if CNetEventCallbacks.cbs[eventid][i] == func then
			table.remove(CNetEventCallbacks.cbs[eventid], i)
		end
	end
end

function CNetEventCallbacks.DoCB(id, ev, writeback)
	local doWrite, ignore = false, false
	if CNetEventCallbacks.cbs.all then
		for _,cb in ipairs(CNetEventCallbacks.cbs.all) do
			local w, i = cb(id, ev)
			doWrite = doWrite or w
			ignore = ignore or i
		end
	end
	if CNetEventCallbacks.cbs[id] then
		for _,cb in ipairs(CNetEventCallbacks.cbs[id]) do
			local w, i = cb(ev)
			doWrite = doWrite or w
			ignore = ignore or i
		end
	end
	if ignore then
		return true
	end
	if doWrite then
		writeback(ev)
	end
end

AddMapStartAndSaveLoadedCallback(function()
	CppLogic.Logic.UICommands.SetCallback(CNetEventCallbacks.DoCB)
end)

CNetEventCallbacks.CNetEvents = {
	CommandEntityAttackEntity			= 69650,
	CommandSerfConstructBuilding		= 69655,
	CommandSerfRepairBuilding			= 69656,
	CommandEntityGuardEntity			= 69664,
	CommandHeroConvertSettler			= 69695,
	CommandThiefStealFrom				= 69699,
	CommandThiefCarryStolenStuffToHQ	= 69700,
	CommandThiefSabotageBuilding		= 69701,
	CommandThiefDefuseKeg				= 69702,
	CommandHeroSnipeSettler				= 69705,
	CommandHeroThrowShurikenAt			= 69708,
	CommandHeroPlaceCannonAt			= 69679,
	CommandHeroPlaceBombAt				= 69668,
	CommandEntityAttackPos				= 69663,
	CommandHeroSendHawkToPos			= 69676,
	CommandScoutUseBinocularsAt			= 69704,
	CommandScoutPlaceTorchAtPos			= 69706,
	CommandEntityMove					= 69634,
	CommandEntityPatrol					= 69669,
	CommandBuildingStartUpgrade			= 69640,
	CommandLeaderBuySoldier				= 69644,
	CommandSettlerExpell				= 69647,
	CommandBuildingCancelResearch		= 69659,
	CommandMarketCancelTrade			= 69661,
	CommandBuildingCancelUpgrade		= 69662,
	CommandLeaderHoldPosition			= 69665,
	CommandLeaderDefend					= 69667,
	CommandBattleSerfTurnToSerf			= 69677,
	CommandSerfTurnToBattleSerf			= 69678,
	CommandHeroActivateCamouflage		= 69682,
	CommandHeroActivateSummon			= 69685,
	CommandBuildingToggleOvertime		= 69683,
	CommandHeroAffectEntities			= 69689,
	CommandHeroCircularAttack			= 69690,
	CommandHeroInflictFear				= 69694,
	CommandBarracksRecruitGroups		= 69696,
	CommandBarracksRecruitLeaderOnly	= 69697,
	CommandHeroMotivateWorkers			= 69703,
	CommandScoutFindResources			= 69707,
	CommandPlaceBuilding				= 69635,
	CommandHQBuySerf					= 69636,
	CommandBuildingSell					= 69638,
	CommandPlayerActivateAlarm			= 69680,
	CommandPlayerDeactivateAlarm		= 69681,
	PlayerUpgradeSettlerCategory		= 69642,
	CommandPlayerSetTaxes				= 69646,
	CommandWeathermachineChangeWeather	= 69686,
	CommandMonasteryBlessSettlerGroup	= 69687,
	CommandPlayerPayTribute				= 69670,
	CommandBarracksBuyLeader			= 69643,
	CommandLeaderSetFormation			= 69653,
	CommandBuildingSetCurrentMaxWorkers	= 69672,
	CommandFoundryBuildCannon			= 69684,
	CommandSerfExtractResource			= 69657,
	CommandBuildingStartResearch		= 69658,
	CommandMarketStartTrade				= 69660,
}