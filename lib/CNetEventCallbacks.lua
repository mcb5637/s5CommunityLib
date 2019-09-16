if mcbPacker then --mcbPacker.ignore
mcbPacker.require("s5CommunityLib/fixes/TriggerFix")
mcbPacker.require("s5CommunityLib/comfort/other/S5HookLoader")
mcbPacker.require("s5CommunityLib/lib/MemoryManipulation")
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
-- Wenn Informationen im table geändert werden und einer der Callbacks true zurückgibt,
-- werden alle Infos zurück in das CNetEvent geschrieben.
-- (Einige wenige infos können nicht geschrieben werden: EventTypeId, PositionList und ListOfSerfs)
-- 
-- Liste der CNetEvents:
-- - CNetEventSubclass:									(prameter list)
-- 		CommandName							Optionen, dasselbe in Lua zu erreichen								Wann der callback aufgerufen wird (== im MP automatisch synchronisiert), leer => immer
-- 
-- - EGL::CNetEvent2Entities:							{EventTypeId, ActorId, TargetId}
-- 		CommandEntityAttackEntity			Logic.GroupAttack													Nur GUI
--		CommandSerfConstructBuilding		PostEvent.SerfConstructBuilding
--		CommandSerfRepairBuilding			PostEvent.SerfRepairBuilding
--		CommandEntityGuardEntity			Logic.GroupGuard													Nur GUI
--		CommandHeroConvertSettler			PostEvent.HeroConvertSettlerAbility
--		CommandThiefStealFrom				PostEvent.ThiefStealFrom
--		CommandThiefCarryStolenStuffToHQ	PostEvent.ThiefCarryStolenStuffToHQ
--		CommandThiefSabotageBuilding		PostEvent.ThiefSabotage
--		CommandThiefDefuseKeg				PostEvent.ThiefDefuse
--		CommandHeroSnipeSettler				PostEvent.HeroSniperAbility
--		CommandHeroThrowShurikenAt			PostEvent.HeroShurikenAbility
--		69688
--		69693
-- 
-- - GGL::CNetEventCannonCreator:						{EventTypeId, EntityId, BottomType, TopType, Position}
--		CommandHeroPlaceCannonAt			PostEvent.HeroPlaceCannonAbility
-- 
-- - EGL::CNetEventEntityAndPos:						{EventTypeId, EntityId, Position}
-- 		CommandHeroPlaceBombAt				PostEvent.HeroPlaceBombAbility
-- 		CommandEntityAttackPos				Logic.GroupAttackMove												Nur GUI
-- 		CommandHeroSendHawkToPos			GUI.SendHawk
-- 		CommandScoutUseBinocularsAt			PostEvent.ScoutBinocular
-- 		CommandScoutPlaceTorchAtPos			PostEvent.ScoutPlaceTorch
-- 
-- - EGL::CNetEventEntityAndPosArray:					{EventTypeId, EntityId, PositionList}
-- 		CommandEntityMove					Logic.MoveSettler													Nur GUI
-- 		CommandEntityPatrol					Logic.GroupAddPatrolPoint & Logic.GroupPatrol?						Nur GUI, nachdem letzte position gewählt
-- 
-- - EGL::CNetEventEntityID:							{EventTypeId, EntityId}
-- 		CommandBuildingStartUpgrade			GUI.UpgradeSingleBuilding
-- 		CommandLeaderBuySoldier				PostEvent.LeaderBuySoldier
-- 		CommandSettlerExpell				PostEvent.ExpellSettler
-- 		CommandBuildingCancelResearch		GUI.CancelResearch
-- 		CommandMarketCancelTrade			GUI.CancelTransaction
-- 		CommandBuildingCancelUpgrade		GUI.CancelBuildingUpgrade
-- 		CommandLeaderHoldPosition			Logic.GroupStand													Nur GUI
-- 		CommandLeaderDefend					Logic.GroupDefend													Nur GUI
-- 		CommandBattleSerfTurnToSerf			GUI.ChangeToSerf
-- 		CommandSerfTurnToBattleSerf			GUI.ChangeToBattleSerf
-- 		CommandHeroActivateCamouflage		GUI.SettlerCamouflage
-- 		CommandHeroActivateSummon			GUI.SettlerSummon
-- 		CommandBuildingToggleOvertime		GUI.ToggleOvertimeAtBuilding
-- 		CommandHeroAffectEntities			GUI.SettlerAffectUnitsInArea
-- 		CommandHeroCircularAttack			GUI.SettlerCircularAttack
-- 		CommandHeroInflictFear				GUI.SettlerInflictFear
-- 		CommandBarracksRecruitGroups		GUI.DeactivateAutoFillAtBarracks
-- 		CommandBarracksRecruitLeaderOnly	GUI.ActivateAutoFillAtBarracks
-- 		CommandHeroMotivateWorkers			GUI.SettlerMotivateWorkers
-- 		CommandScoutFindResources			GUI.ScoutPointToResources
-- 		69648
-- 		69649
--		69651
--		69652
--		69666
-- 
-- - GGL::CNetEventBuildingCreator:						{EventTypeId, PlayerId, UprgadeCategory, Position{X,Y,r}, ListOfSerfs}
-- 		CommandPlaceBuilding				Logic.CreateConstructionSite + PostEvent.SerfConstructBuilding		Nur GUI
-- 
-- - EGL::CNetEventEntityIDAndPlayerID:					{EventTypeId, PlayerId, EntityId}
-- 		CommandHQBuySerf					PostEvent.BuySerf
-- 		CommandBuildingSell					PostEvent.SellBuilding
-- 		69639
-- 
-- - EGL::CNetEventPlayerID:							{EventTypeId, PlayerId}
-- 		CommandPlayerActivateAlarm			?
-- 		CommandPlayerDeactivateAlarm		?
-- 		69637
-- 		69645
-- 		69674
-- 		69675
-- 
-- - EGL::CNetEventIntegerAndPlayerID:					{EventTypeId, PlayerId, Int}
-- 		PlayerUpgradeSettlerCategory		GUI.UpgradeSettlerCategory
-- 		CommandPlayerSetTaxes				GUI.SetTaxLevel
-- 		CommandWeathermachineChangeWeather	GUI.SetWeather ?
-- 		CommandMonasteryBlessSettlerGroup	GUI.BlessByBlessCategory
-- 		69641
-- 
-- - EGL::CNetEventPlayerIDAndInteger:					{EventTypeId, PlayerId, Int}
--  	CommandPlayerPayTribute				GUI.PayTribute
-- 
-- - EGL::CNetEvent2PlayerIDsAndInteger:				???
-- 		69671
-- 
-- - GGL::CNetEventEntityIDAndUpgradeCategory:			{EventTypeId, EntityId, UprgadeCategory}
-- 		CommandBarracksBuyLeader			Logic.BarracksBuyLeader												Nur GUI
-- 
-- - EGL::CNetEventEntityIDAndInteger:					{EventTypeId, EntityId, Int}
-- 		CommandLeaderSetFormation			Logic.LeaderChangeFormationType										Nur GUI
-- 		CommandBuildingSetCurrentMaxWorkers	Logic.SetCurrentMaxNumWorkersInBuilding								Nur GUI
-- 		CommandFoundryBuildCannon			PostEvent.FoundryConstructCannon
-- 
-- - GGL::CNetEventExtractResource:						{EventTypeId, EntityId, ResourceType, TargetPosition}
-- 		CommandSerfExtractResource			PostEvent.SerfExtractResource
-- 
-- - GGL::CNetEventTechnologyAndEntityID:				{EventTypeId, EntityId, Technology}
-- 		CommandBuildingStartResearch		GUI.StartResearch
-- 
-- - GGL::CNetEventTransaction:							{EventTypeId, EntityId, SellType, BuyType, BuyAmount}
-- 		CommandMarketStartTrade				GUI.StartTransaction
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
-- - S5Hook
-- - MemoryManipulation
-- - S5HookLoader
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

function CNetEventCallbacks.DoCB(sv, id)
	local read = MemoryManipulation.ReadObj(sv)
	if not read or read=="todo" then
		return
	end
	local doWrite = false
	if CNetEventCallbacks.cbs.all then
		for _,cb in ipairs(CNetEventCallbacks.cbs.all) do
			doWrite = doWrite or cb(read)
		end
	end
	if CNetEventCallbacks.cbs[id] then
		for _,cb in ipairs(CNetEventCallbacks.cbs[id]) do
			doWrite = doWrite or cb(read)
		end
	end
	if doWrite then
		MemoryManipulation.WriteObj(sv, read, nil, true)
	end
end

table.insert(S5HookLoader.cb, function()
	S5Hook.SetNetEventTrigger(CNetEventCallbacks.DoCB)
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