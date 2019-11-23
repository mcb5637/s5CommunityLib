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
-- - S5Hook oder CEntity.dll
EntityAttachments = {}

function EntityAttachments.ReadAttachmentsFromEntity(id)
	if type(id)=="string" then
		id = GetID(id)
	end
	if CEntity and CEntity.GetAttachedEntities then
		return CEntity.GetAttachedEntities(id)
	end
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
	ATTACHMENT_SETTLER_SOURCE_PILE = 2;
	ATTACHMENT_SETTLER_DESTINATION_PILE = 3;
	ATTACHMENT_SETTLER_COLLECT_GOOD_RESOURCE = 4;
	ATTACHMENT_GATHERER_RESOURCE_DOODAD = 5;
	ATTACHMENT_SETTLER_EMPOLYING_BUILDING = 6;
	ATTACHMENT_SETTLER_TARGET_FIRE = 7;
	ATTACHMENT_CROP_FIELD = 8;
	ATTACHMENT_SETTLER_ENTERED_BUILDING = 9;
	ATTACHMENT_SETTLER_FIELD = 10;
	ATTACHMENT_SETTLER_RESOURCE_DOODAD = 11;
	ATTACHMENT_SETTLER_HARBOR = 12;
	ATTACHMENT_SETTLER_ENTITY_TO_DESTROY = 13;
	ATTACHMENT_SETTLER_TARGET_BUILDING = 14;
	ATTACHMENT_SETTLER_WORKPLACE = 15;
	ATTACHMENT_HUNTER_PREY = 16;
	ATTACHMENT_MILITIA_ENEMY = 17;
	ATTACHMENT_APPROACHING_SERF_CONSTRUCTION_SITE = 18;
	ATTACHMENT_SERF_CONSTRUCTION_SITE = 19;
	ATTACHMENT_CONSTRUCTION_SITE_BUILDING = 20;
	ATTACHMENT_WORKER_FARM = 21;
	ATTACHMENT_WORKER_RESIDENCE = 22;
	ATTACHMENT_WORKER_WORKPLACE = 23;
	ATTACHMENT_MINE_RESOURCE = 24;
	ATTACHMENT_MINE_LORRY = 25;
	ATTACHMENT_MINE_LORRY_STORE = 26;
	ATTACHMENT_CONSUMER_LORRY = 27;
	ATTACHMENT_MARKET_LORRY_STORE = 28;
	ATTACHMENT_SERF_MARKET = 29;
	ATTACHMENT_MARKET_MARKET = 30;
	ATTACHMENT_LEADER_SOLDIER = 31;
	ATTACHMENT_ATTACKER_TARGET = 32;
	ATTACHMENT_ATTACKED_DEAD = 33;
	ATTACHMENT_CAMP_SETTLER = 34;
	ATTACHMENT_ATTACKER_COMMAND_TARGET = 35;
	ATTACHMENT_BUILDING_BASE = 36;
	ATTACHMENT_FOLLOWER_FOLLOWED = 37;
	ATTACHMENT_WORKER_VILLAGE_CENTER = 38;
	ATTACHMENT_PLACEHOLDER_BUILDING_CONSTRUCTION_SITE = 39;
	ATTACHMENT_SERF_RESOURCE = 40;
	ATTACHMENT_GUARD_GUARDED = 41;
	ATTACHMENT_FIGHTER_BARRACKS = 42;
	ATTACHMENT_BOMBER_BOMB = 43;
	ATTACHMENT_SERF_BATTLE_SERF = 44;
	ATTACHMENT_HERO_HAWK = 45;
	ATTACHMENT_TOP_ENTITY_FOUNDATION = 46;
	ATTACHMENT_BUILDER_FOUNDATION = 47;
	ATTACHMENT_DEFENDER_BUILDING = 48;
	ATTACHMENT_APPROACHING_DEFENDER_BUILDING = 49;
	--[[ Missing ]]
	ATTACHMENT_LEADER_TARGET = 51;
	ATTACHMENT_WORKER_SUPPLIER = 52;
	ATTACHMENT_SETTLER_BUILDING_TO_LEAVE = 53;
	ATTACHMENT_SUMMONER_SUMMONED = 54;
	ATTACHMENT_FOUNDATION_TOP_ENTITY = 55;
	ATTACHMENT_FOUNDATION_BUILDER = 56;
	ATTACHMENT_BUILDING_UPGRADE_SITE = 57;
	ATTACHMENT_HERO_AFFECTED = 58;
	ATTACHMENT_HERO_NPC = 59;
	ATTACHMENT_CONVERTER_BUILDING = 60;
	ATTACHMENT_INFLICTOR_TERRORIZED = 61;
	ATTACHMENT_CONVERTER_SETTLER = 62;
	ATTACHMENT_MERCHANT_TRADER = 63;
	ATTACHMENT_BUILDER_BRIDGE = 64;
	ATTACHMENT_APPROACHING_BUILDER_BRIDGE = 65;
	ATTACHMENT_SCOUT_EXPLORATION = 66;
	ATTACHMENT_THIEF_TARGET_BUILDING = 67;
	ATTACHMENT_THIEF_SECURE_BUILDING = 68;
	ATTACHMENT_KEG_TARGET_BUILDING = 69;
	ATTACHMENT_ARMING_THIEF_KEG = 70;
	ATTACHMENT_DISARMING_THIEF_KEG = 71;
	ATTACHMENT_THIEF_KEG_TARGET = 72;
	ATTACHMENT_FIRE_BURNING_ENTITY = 73;
}
