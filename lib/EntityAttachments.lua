if mcbPacker then --mcbPacker.ignore
mcbPacker.require("s5CommunityLib/comfort/other/S5HookLoader")
end --mcbPacker.ignore

--- author:mcb		current maitainer:mcb		v0.1
-- Erlaubt es Entity-attachments zu lesen.
-- (Die eigentlichen attachments scheinen immer entgegengesetzt vom erwarteten zu sein. Z.B. wenn e1 e2 angreift, hat e2 die dazugehörigen attachments).
-- 
-- - EntityAttachments.ReadAttachmentsFromEntity(id)		Liest die Attachments eines entities.
-- Format: table[attachmenttype] = table of ids
-- - EntityAttachments.AttachmentTypes						Table aller bekannten attachment types.
-- 
-- Benötigt:
-- - S5Hook
EntityAttachments = {}

function EntityAttachments.ReadAttachmentsFromEntity(id)
	if type(id)=="string" then
		id = GetID(id)
	end -- TODO check if kimichuras dll variant is available and use it
	id = S5Hook.GetEntityMem(id)
	local data = {}
	local cache = {}
	EntityAttachments.RecursiveReadAttachments(id:Offset(9), data, cache, true)
	return data
end

function EntityAttachments.RecursiveReadAttachments(sv, data, cache, isStart)
	if cache[sv[0]:GetInt()] then
		return
	end
	cache[sv[0]:GetInt()] = true
	if not isStart then
		local atyp = sv[0][3]:GetInt()
		local aid = sv[0][4]:GetInt()
		if not data[atyp] then
			data[atyp] = {}
		end
		table.insert(data[atyp], aid)
	end
	EntityAttachments.RecursiveReadAttachments(sv[0], data, cache, false)
	EntityAttachments.RecursiveReadAttachments(sv[0]:Offset(1), data, cache, false)
	EntityAttachments.RecursiveReadAttachments(sv[0]:Offset(2), data, cache, false)
end

EntityAttachments.AttachmentTypes = {
	ENTITY_TO_BUILDING_IN = 9, -- walking in building?
	WALKING_SERF_TO_CONSTRUCTION_OR_REPAIRING_SITE = 18,
	SERF_TO_CONSTRUCTION_OR_REPAIRING_SITE = 19,
	ATTACH_CONSTRUCTION_SITE_TO_BUILDING = 20,
	WORKER_TO_FARM = 21, -- Happens every 10 seconds (redistribution of workers)
	WORKER_TO_RESIDENCE = 22, -- like WORKER_TO_FARM
	WORKER_TO_BUILDING = 23, -- Worker works in that building -- Also when worker switch to other building (e. g. when building is broken)
	MINE_TO_PIT = 24,
	LEADER_TO_SOLDIER = 31,
	ATTACKED = 32, -- ?? throwing punches?
	CAMP_TO_WORKER = 34,
	ATTACKING = 35, -- ??
	ATTACH_BUILDING_TO_SLOT = 36, -- only for mines, villagecenters
	ATTACK_2 = 37, -- attacker to target (run?) (movable entity? like chase serf)
	WORKER_TO_VILLAGE_CENTER_LEAVE = 38, -- either PB or XD
	BUILDING_TO_CONSTRUCTION_SITE = 39,
	SERF_TO_RESOURCE = 40,
	LEADER_TO_GUARD = 41, -- guard
	LEADER_OR_SOLDIER_TO_BUILDING = 42, -- leader in building, soldier at (?) building
	HERO_TO_HAWK = 45,
	CANNON_TO_FOUNDATION = 46, -- pilgrims cannon, pb_tower2, ...
	HERO_TO_FOUNDATION = 47, -- pilgrim to his cannon foundation
	WORKER_TO_ALARM_BUILDING = 48, -- ??
	ALARM_START = 49, -- ??
	COLLISION = 50,
	ATTACK_ = 51, -- attacker to target (run?) (far away?) -> 35 -> 32
	WORKER_TO_RESOURCE_DISTRIBUTOR = 52, -- mine, headquarter, ...?
	ENTITY_TO_BUILDING_OUT = 53, -- coming out of building, deleting event?
	SUMMONER_TO_SUMMONED_ENTITY = 54, -- scout script entity, ari bandits, varg wolfs...
	FOUNDATION_TO_CANNON = 55, -- pilgrims cannon, pb_tower2, ...
	FOUNDATION_TO_HERO = 56, -- cannon foundation to pilgrim
	BUILDING_TO_UPGRADE_SITE = 57,
	AURA_GIVER_TO_AURA_RECEIVER = 58, -- erec, helias, varg, drake, kerberos,
	HERO_TO_NPC = 59, -- merchant or npc with exclamation mark
	HERO_TO_FLEEING_ENTITY = 61, -- dario uses garbage ability.
	HELIAS_TO_CONVERT_ENTITY = 62,
	MERCHANT_TO_MERCENARY = 63,
	MASTER_BUILDER_TO_BRIDGE_SITE = 65,
	THIEF_TO_STEAL_BUILDING = 67,
	THIEF_TO_SECURE_GOODS = 68, -- thief to building
	KEG_TO_BUILDING = 69,
	THIEF_TO_KEG = 70,
	THIEF_TO_PLACE_KEG_AT_BUILDING = 72,
}
