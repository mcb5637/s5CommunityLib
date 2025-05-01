--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
-- MemLib.Settler
-- author: RobbiTheFox
-- current maintainer: RobbiTheFox
-- Version: v1.0
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
if mcbPacker then
    mcbPacker.require("s5CommunityLib/Lib/MemLib/MemLib")
    mcbPacker.require("s5CommunityLib/Lib/MemLib/Entity")
    mcbPacker.require("s5CommunityLib/Lib/MemLib/EntityType")
    mcbPacker.require("s5CommunityLib/Lib/MemLib/Util")
    mcbPacker.require("s5CommunityLib/Comfort/Table/Table")
    mcbPacker.require("s5CommunityLib/Tables/Behaviors")
    mcbPacker.require("s5CommunityLib/Tables/AttachmentTypes")
else
	if not MemLib then Script.Load("maps\\user\\EMS\\tools\\s5CommunityLib\\lib\\MemLib\\MemLib.lua") end
	MemLib.Load("Entity", "EntityType", "Util", "Comfort/Table/Table", "Tables/Behaviors", "Tables/AttachmentTypes")
end
--------------------------------------------------------------------------------
MemLib.Settler = {}
--------------------------------------------------------------------------------
---@param _SettlerId integer
---@return userdata|table
function MemLib.Settler.GetMemory(_SettlerId)
    assert(MemLib.Settler.IsValid(_SettlerId), "MemLib.Settler.GetMemory: _SettlerId invalid")
    return MemLib.Entity.GetMemory(_SettlerId)
end
--------------------------------------------------------------------------------
---@param _SettlerId integer
---@return boolean
function MemLib.Settler.IsValid(_SettlerId)
    return MemLib.Entity.IsValid(_SettlerId) and Logic.IsSettler(_SettlerId) == 1
end
--------------------------------------------------------------------------------
---@param _SettlerId integer
---@param _ExperienceClass integer
function MemLib.Settler.LeaderSetExperienceClass(_SettlerId, _ExperienceClass)
    assert(table.find(ExperienceClasses, _ExperienceClass), "MemLib.Settler.LeaderSetExperienceClass: _ExperienceClass invalid")
    -- assert(_LeaderId) not needed, this can safely be set for non leaders as well
	MemLib.Settler.GetMemory(_SettlerId)[131]:SetInt(_ExperienceClass)
end
--------------------------------------------------------------------------------
---@param _SettlerId integer
---@return boolean
function MemLib.Settler.ThiefCamouflage(_SettlerId)

	local thiefCamouflageBehavior = MemLib.Entity.BehaviorGetMemory(_SettlerId, Behaviors.CThiefCamouflageBehavior)

	if thiefCamouflageBehavior then
		MemLib.GetMemory(thiefCamouflageBehavior + 32)[0]:SetInt(15)
		MemLib.GetMemory(thiefCamouflageBehavior + 36)[0]:SetInt(0)
		return true
	end
    return false
end
--------------------------------------------------------------------------------
---@param _SettlerId integer
---@return boolean
function MemLib.Settler.ThiefDecamouflage(_SettlerId)

	local thiefCamouflageBehavior = MemLib.Entity.BehaviorGetMemory(_SettlerId, Behaviors.CThiefCamouflageBehavior)

	if thiefCamouflageBehavior then
		MemLib.GetMemory(thiefCamouflageBehavior + 32)[0]:SetInt(0)
		return true
	end
    return false
end
--------------------------------------------------------------------------------
---@param _SettlerId integer
---@param _Seconds integer
---@return boolean
function MemLib.Settler.ThiefDecamouflageForSeconds(_SettlerId, _Seconds)

	local thiefCamouflageBehavior = MemLib.Entity.BehaviorGetMemory(_SettlerId, Behaviors.CThiefCamouflageBehavior)

	if thiefCamouflageBehavior then
        assert(type(_Seconds) == "number" and _Seconds >= 0, "MemLib.Settler.ThiefDecamouflageForSeconds: _Seconds invalid")
		MemLib.GetMemory(thiefCamouflageBehavior + 32)[0]:SetInt(0)
		MemLib.GetMemory(thiefCamouflageBehavior + 36)[0]:SetInt(_Seconds)
		return true
	end
    return false
end
--------------------------------------------------------------------------------
---@param _SettlerId integer
---@return integer? ResourceType
---@return integer? Amount
---@return integer? PlayerId
function MemLib.Settler.ThiefGetStolenResourceInfo(_SettlerId)

	local thiefBehavior = MemLib.Entity.BehaviorGetMemory(_SettlerId, Behaviors.CThiefBehavior)

	if thiefBehavior then
		return thiefBehavior[5]:GetInt(), thiefBehavior[4]:GetInt(), thiefBehavior[6]:GetInt()
	end
end
--------------------------------------------------------------------------------
---@param _SettlerId integer
---@param _ResourceType integer
---@param _Amount integer
---@param _PlayerId integer
---@return boolean
function MemLib.Settler.ThiefSetStolenResourceInfo(_SettlerId, _ResourceType, _Amount, _PlayerId)

	assert(MemLib.Player.IsValid(_PlayerId), "MemLib.Entity.ThiefSetStolenResourceInfo: _PlayerId invalid")
	assert(MemLib.Util.ResourceTypeIsValid(_ResourceType), "MemLib.Entity.ThiefSetStolenResourceInfo: _ResourceType invalid")
	assert(type(_Amount) == "number" and _Amount >= 0, "MemLib.Entity.ThiefSetStolenResourceInfo: _Amount must be >= 0")

	local thiefBehavior = MemLib.Entity.BehaviorGetMemory(_SettlerId, Behaviors.CThiefBehavior)

	if thiefBehavior then
		thiefBehavior[5]:SetInt(_ResourceType)
		thiefBehavior[4]:SetInt(_Amount)
		thiefBehavior[6]:SetInt(_PlayerId)
        return true
	end
    return false
end
--------------------------------------------------------------------------------
---@param _SettlerId integer
---@return boolean
function MemLib.Settler.ThiefClearStolenResourceInfo(_SettlerId)
	return MemLib.Settler.ThiefSetStolenResourceInfo(_SettlerId, 0, 0, 0)
end
--------------------------------------------------------------------------------
---@param _SettlerId integer
---@return userdata|table?
function MemLib.Settler.GetMovementBehaviorMemory(_SettlerId)

	local behaviors = {
		Behaviors.CLeaderMovement,
		Behaviors.CSettlerMovement,
		Behaviors.CSoldierMovement,
	}

	for _, behavior in ipairs(behaviors) do

		local movementBehaviorMemory = MemLib.Entity.BehaviorGetMemory(_SettlerId, behavior)

		if movementBehaviorMemory then
			return movementBehaviorMemory
		end
	end
end
--------------------------------------------------------------------------------
---@param _SettlerId integer
---@return number?
---@return number?
function MemLib.Settler.GetBaseMovementSpeed(_SettlerId)

	local movementBehaviorMemory = MemLib.Settler.GetMovementBehaviorMemory(_SettlerId)

	if movementBehaviorMemory then
		return movementBehaviorMemory[5]:GetFloat(), movementBehaviorMemory[7]:GetFloat()
	end
end
--------------------------------------------------------------------------------
---@param _SettlerId integer
---@return number
function MemLib.Settler.GetMovementSpeed(_SettlerId)
	return MemLib.Settler.GetMemory(_SettlerId)[89]:GetFloat()
end
--------------------------------------------------------------------------------
---@param _SettlerId integer
---@return integer
function MemLib.Settler.GetStamina(_SettlerId)
	local workerBehaviorMemory = MemLib.Entity.BehaviorGetMemory(_SettlerId, Behaviors.CWorkerBehavior)
	if workerBehaviorMemory then
		return workerBehaviorMemory[4]:GetInt()
	end
	return 0
end
--------------------------------------------------------------------------------
---@param _SettlerId integer
---@param _Stamina integer
function MemLib.Settler.SetStamina(_SettlerId, _Stamina)
	assert(type(_Stamina) == "number" and _Stamina >= 0)
	local workerBehaviorMemory = MemLib.Entity.BehaviorGetMemory(_SettlerId, Behaviors.CWorkerBehavior)
	if workerBehaviorMemory then
		workerBehaviorMemory[4]:SetInt(_Stamina)
	end
end
--------------------------------------------------------------------------------
---@param _SettlerId integer
---@return integer
function MemLib.Settler.GetMotivation(_SettlerId)
	assert(MemLib.Settler.IsValid(_SettlerId))
	return Logic.GetSettlersMotivation(_SettlerId)
end
--------------------------------------------------------------------------------
---@param _SettlerId integer
---@return number
function MemLib.Settler.GetExperiencePoints(_SettlerId)
	return MemLib.Settler.GetMemory(_SettlerId)[85]:GetFloat()
end
--------------------------------------------------------------------------------
---@param _SettlerId integer
---@return number
function MemLib.Settler.GetExperienceLevel(_SettlerId)
	return MemLib.Settler.GetMemory(_SettlerId)[87]:GetFloat()
end
--------------------------------------------------------------------------------
---@param _SettlerId integer
---@return number
function MemLib.Settler.GetMovingSpeed(_SettlerId)
	return MemLib.Settler.GetMemory(_SettlerId)[89]:GetFloat()
end
--------------------------------------------------------------------------------
---@param _SettlerId integer
---@return number
function MemLib.Settler.GetDamage(_SettlerId)
	return MemLib.Settler.GetMemory(_SettlerId)[91]:GetFloat()
end
--------------------------------------------------------------------------------
---@param _SettlerId integer
---@return number
function MemLib.Settler.GetDodgeChance(_SettlerId)
	return MemLib.Settler.GetMemory(_SettlerId)[93]:GetFloat()
end
--------------------------------------------------------------------------------
---@param _SettlerId integer
---@return number
function MemLib.Settler.GetArmor(_SettlerId)
	return MemLib.Settler.GetMemory(_SettlerId)[97]:GetFloat()
end
--------------------------------------------------------------------------------
---@param _SettlerId integer
---@return number
function MemLib.Settler.GetMaxSoldiers(_SettlerId)
	return MemLib.Settler.GetMemory(_SettlerId)[101]:GetFloat()
end
--------------------------------------------------------------------------------
---@param _SettlerId integer
---@return number
function MemLib.Settler.GetDamageBonus(_SettlerId)
	return MemLib.Settler.GetMemory(_SettlerId)[103]:GetFloat()
end
--------------------------------------------------------------------------------
---@param _SettlerId integer
---@return number
function MemLib.Settler.GetExploration(_SettlerId)
	return MemLib.Settler.GetMemory(_SettlerId)[105]:GetFloat()
end
--------------------------------------------------------------------------------
---@param _SettlerId integer
---@return number
function MemLib.Settler.GetMaxAttackRange(_SettlerId)
	return MemLib.Settler.GetMemory(_SettlerId)[107]:GetFloat()
end
--------------------------------------------------------------------------------
---@param _SettlerId integer
---@return number
function MemLib.Settler.GetAutoAttackRange(_SettlerId)
	return MemLib.Settler.GetMemory(_SettlerId)[109]:GetFloat()
end
--------------------------------------------------------------------------------
---@param _SettlerId integer
---@return number
function MemLib.Settler.GetHealingPoints(_SettlerId)
	return MemLib.Settler.GetMemory(_SettlerId)[111]:GetFloat()
end
--------------------------------------------------------------------------------
---@param _SettlerId integer
---@return number
function MemLib.Settler.GetMissChance(_SettlerId)
	return MemLib.Settler.GetMemory(_SettlerId)[113]:GetFloat()
end
--------------------------------------------------------------------------------
---@param _SettlerId integer
---@param _ExperiencePoints integer
function MemLib.Settler.SetExperiencePoints(_SettlerId, _ExperiencePoints)
	MemLib.Settler.SetModifyableValue(_SettlerId, 0, _ExperiencePoints)
end
--------------------------------------------------------------------------------
---@param _SettlerId integer
---@param _ExperienceLevel integer
function MemLib.Settler.SetExperienceLevel(_SettlerId, _ExperienceLevel)
	MemLib.Settler.SetModifyableValue(_SettlerId, 1, _ExperienceLevel)
end
--------------------------------------------------------------------------------
---@param _SettlerId integer
---@param _MovingSpeed integer
function MemLib.Settler.SetMovingSpeed(_SettlerId, _MovingSpeed)
	MemLib.Settler.SetModifyableValue(_SettlerId, 2, _MovingSpeed)
end
--------------------------------------------------------------------------------
---@param _SettlerId integer
---@param _Damage integer
function MemLib.Settler.SetDamage(_SettlerId, _Damage)
	MemLib.Settler.SetModifyableValue(_SettlerId, 3, _Damage)
end
--------------------------------------------------------------------------------
---@param _SettlerId integer
---@param _DodgeChance integer
function MemLib.Settler.SetDodgeChance(_SettlerId, _DodgeChance)
	MemLib.Settler.SetModifyableValue(_SettlerId, 4, _DodgeChance)
end
--------------------------------------------------------------------------------
---@param _SettlerId integer
---@param _Armor integer
function MemLib.Settler.SetArmor(_SettlerId, _Armor)
	MemLib.Settler.SetModifyableValue(_SettlerId, 6, _Armor)
end
--------------------------------------------------------------------------------
---@param _SettlerId integer
---@param _MaxSoldiers integer
function MemLib.Settler.SetMaxSoldiers(_SettlerId, _MaxSoldiers)
	MemLib.Entity.LimitedAttachmentSetSlotAmount(_SettlerId, 31, _MaxSoldiers)
end
--------------------------------------------------------------------------------
---@param _SettlerId integer
---@param _DamageBonus integer
function MemLib.Settler.SetDamageBonus(_SettlerId, _DamageBonus)
	MemLib.Settler.SetModifyableValue(_SettlerId, 9, _DamageBonus)
end
--------------------------------------------------------------------------------
---@param _SettlerId integer
---@param _Exploration integer
function MemLib.Settler.SetExploration(_SettlerId, _Exploration)
	MemLib.Settler.SetModifyableValue(_SettlerId, 10, _Exploration)
end
--------------------------------------------------------------------------------
---@param _SettlerId integer
---@param _MaxAttackRange integer
function MemLib.Settler.SetMaxAttackRange(_SettlerId, _MaxAttackRange)
	MemLib.Settler.SetModifyableValue(_SettlerId, 11, _MaxAttackRange)
end
--------------------------------------------------------------------------------
---@param _SettlerId integer
---@param _AutoAttackRange integer
function MemLib.Settler.SetAutoAttackRange(_SettlerId, _AutoAttackRange)
	MemLib.Settler.SetModifyableValue(_SettlerId, 12, _AutoAttackRange)
end
--------------------------------------------------------------------------------
---@param _SettlerId integer
---@param _HealingPoints integer
function MemLib.Settler.SetHealingPoints(_SettlerId, _HealingPoints)
	MemLib.Settler.SetModifyableValue(_SettlerId, 13, _HealingPoints)
end
--------------------------------------------------------------------------------
---@param _SettlerId integer
---@param _MissChance integer
function MemLib.Settler.SetMissChance(_SettlerId, _MissChance)
	MemLib.Settler.SetModifyableValue(_SettlerId, 14, _MissChance)
end
--------------------------------------------------------------------------------
---@param _SettlerId integer
---@param _Offset integer
---@param _Value number
function MemLib.Settler.SetModifyableValue(_SettlerId, _Offset, _Value)
	assert(type(_Offset) == "number" and _Offset >= 0 and _Offset <= 14)
	local settlerMemory = MemLib.Settler.GetMemory(_SettlerId)
	settlerMemory[80][_Offset]:SetInt(settlerMemory:Offset(114):GetInt())
	settlerMemory[84 + _Offset * 2]:SetInt(0)
	settlerMemory[85 + _Offset * 2]:SetFloat(_Value)
end
--------------------------------------------------------------------------------
---@param _SettlerId integer
function MemLib.Settler.ResetExperiencePoints(_SettlerId)
	MemLib.Settler.ResetModifyableValue(_SettlerId, 0)
end
--------------------------------------------------------------------------------
---@param _SettlerId integer
function MemLib.Settler.ResetExperienceLevel(_SettlerId)
	MemLib.Settler.ResetModifyableValue(_SettlerId, 1)
end
--------------------------------------------------------------------------------
---@param _SettlerId integer
function MemLib.Settler.ResetMovingSpeed(_SettlerId)
	MemLib.Settler.ResetModifyableValue(_SettlerId, 2)
end
--------------------------------------------------------------------------------
---@param _SettlerId integer
function MemLib.Settler.ResetDamage(_SettlerId)
	MemLib.Settler.ResetModifyableValue(_SettlerId, 3)
end
--------------------------------------------------------------------------------
---@param _SettlerId integer
function MemLib.Settler.ResetDodgeChance(_SettlerId)
	MemLib.Settler.ResetModifyableValue(_SettlerId, 4)
end
--------------------------------------------------------------------------------
---@param _SettlerId integer
function MemLib.Settler.ResetArmor(_SettlerId)
	MemLib.Settler.ResetModifyableValue(_SettlerId, 6)
end
--------------------------------------------------------------------------------
---@param _SettlerId integer
function MemLib.Settler.ResetMaxSoldiers(_SettlerId)
	local maxSoldiers = MemLib.EntityType.LimitedAttachmentGetSlotAmount(Logic.GetEntityType(_SettlerId), AttachmentTypes.ATTACHMENT_LEADER_SOLDIER)
	assert(type(maxSoldiers) == "number")
	MemLib.Entity.LimitedAttachmentSetSlotAmount(_SettlerId, 31, maxSoldiers)
end
--------------------------------------------------------------------------------
---@param _SettlerId integer
function MemLib.Settler.ResetDamageBonus(_SettlerId)
	MemLib.Settler.ResetModifyableValue(_SettlerId, 9)
end
--------------------------------------------------------------------------------
---@param _SettlerId integer
function MemLib.Settler.ResetExploration(_SettlerId)
	MemLib.Settler.ResetModifyableValue(_SettlerId, 10)
end
--------------------------------------------------------------------------------
---@param _SettlerId integer
function MemLib.Settler.ResetMaxAttackRange(_SettlerId)
	MemLib.Settler.ResetModifyableValue(_SettlerId, 11)
end
--------------------------------------------------------------------------------
---@param _SettlerId integer
function MemLib.Settler.ResetAutoAttackRange(_SettlerId)
	MemLib.Settler.ResetModifyableValue(_SettlerId, 12)
end
--------------------------------------------------------------------------------
---@param _SettlerId integer
function MemLib.Settler.ResetHealingPoints(_SettlerId)
	MemLib.Settler.ResetModifyableValue(_SettlerId, 13)
end
--------------------------------------------------------------------------------
---@param _SettlerId integer
function MemLib.Settler.ResetMissChance(_SettlerId)
	MemLib.Settler.ResetModifyableValue(_SettlerId, 14)
end
--------------------------------------------------------------------------------
---@param _SettlerId integer
---@param _Offset integer
function MemLib.Settler.ResetModifyableValue(_SettlerId, _Offset)
	assert(type(_Offset) == "number" and _Offset >= 0 and _Offset <= 14)
	local settlerMemory = MemLib.Settler.GetMemory(_SettlerId)
	settlerMemory[80][_Offset]:SetInt(settlerMemory:Offset(84 + _Offset * 2):GetInt())
end
--------------------------------------------------------------------------------
if CEntity then

	--------------------------------------------------------------------------------
	---@param _SettlerId integer
	---@return integer
	function MemLib.Settler.GetStamina(_SettlerId)
		assert(MemLib.Settler.IsValid(_SettlerId))
		return CEntity.GetCurrentStamina(_SettlerId)
	end
	--------------------------------------------------------------------------------
	---@param _SettlerId integer
	---@param _Motivation number
	function MemLib.Settler.SetMotivation(_SettlerId, _Motivation)
		assert(MemLib.Settler.IsValid(_SettlerId))
		assert(type(_Motivation) == "number" and _Motivation >= 0)
		CEntity.SetMotivation(_SettlerId, _Motivation)
	end

elseif S5Hook then

	--------------------------------------------------------------------------------
	---@param _SettlerId integer
	---@param _Motivation number
	function MemLib.Settler.SetMotivation(_SettlerId, _Motivation)
		assert(MemLib.Settler.IsValid(_SettlerId))
		assert(type(_Motivation) == "number" and _Motivation >= 0)
		S5Hook.SetSettlerMotivation(_SettlerId, _Motivation)
	end

else

	--------------------------------------------------------------------------------
	---@param _SettlerId integer
	---@param _Motivation number
	function MemLib.Settler.SetMotivation(_SettlerId, _Motivation)
		assert(type(_Motivation) == "number" and _Motivation >= 0)
		local workerBehaviorMemory = MemLib.Entity.BehaviorGetMemory(_SettlerId, Behaviors.CWorkerBehavior)
		if workerBehaviorMemory then
			workerBehaviorMemory[6]:SetFloat(_Motivation)
		end
	end

end