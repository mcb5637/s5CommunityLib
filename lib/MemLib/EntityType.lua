--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
-- MemLib.EntityType
-- author: RobbiTheFox
-- current maintainer: RobbiTheFox
-- Version: v1.0
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
if mcbPacker then
    mcbPacker.require("s5CommunityLib/Lib/MemLib/MemLib")
    mcbPacker.require("s5CommunityLib/Tables/Modifiers")
    mcbPacker.require("s5CommunityLib/Tables/AttachmentTypes")
else
	if not MemLib then Script.Load("maps\\user\\EMS\\tools\\s5CommunityLib\\lib\\MemLib\\MemLib.lua") end
	MemLib.Load("Tables/Modifiers", "Tables/AttachmentTypes")
end
--------------------------------------------------------------------------------
MemLib.EntityType = {}
--------------------------------------------------------------------------------
---@param _EntityType integer
---@return userdata
function MemLib.EntityType.GetMemory(_EntityType)
	assert(MemLib.EntityType.IsValid(_EntityType), "MemLib.EntityType.GetMemory: _EntityType invalid")
	return MemLib.GetMemory(MemLib.Offsets.CGLEEntitiesProps.GlobalObject)[0][7][_EntityType]
end
--------------------------------------------------------------------------------
---@param _EntityType integer
---@return boolean
function MemLib.EntityType.IsValid(_EntityType)
	local CGLEEntitiesProps = MemLib.GetMemory(MemLib.Offsets.CGLEEntitiesProps.GlobalObject)[0]
	return type(_EntityType) == "number" and _EntityType > 0 and _EntityType <= (CGLEEntitiesProps[8]:GetInt() - CGLEEntitiesProps[7]:GetInt()) / 4
end
--------------------------------------------------------------------------------
---@param _EntityType integer
---@return integer
function MemLib.EntityType.GetClass(_EntityType)
	return MemLib.EntityType.GetMemory(_EntityType)[0]:GetInt()
end
--------------------------------------------------------------------------------
-- returns nil if entity type has no such behavior
---@param _EntityType integer
---@param _BehaviorProps integer
---@return userdata?
function MemLib.EntityType.BehaviorGetMemory(_EntityType, _BehaviorProps)

	local entityTypeMemory = MemLib.EntityType.GetMemory(_EntityType)

	local vectorStartMemory = entityTypeMemory[26]
	local vectorEndMemory = entityTypeMemory[27]
	local lastindex = (vectorEndMemory:GetInt() - vectorStartMemory:GetInt()) / 4 - 1

	for i = 0, lastindex do

		local behaviorMemory = vectorStartMemory[i]

		if behaviorMemory:GetInt() ~= 0 and behaviorMemory[0]:GetInt() == _BehaviorProps then
			return behaviorMemory
		end
	end
end
--------------------------------------------------------------------------------
---@param _EntityType integer
---@return number?
function MemLib.EntityType.GetCamperRange(_EntityType)
	local camperBehaviorProps = MemLib.EntityType.BehaviorGetMemory(_EntityType, BehaviorProperties.CCamperBehaviorProperties)
	if camperBehaviorProps then
		return camperBehaviorProps[4]:GetFloat()
	end
end

--------------------------------------------------------------------------------
---@param _EntityType integer
---@return number
function MemLib.EntityType.GetMaxAttackRange(_EntityType)
	local battleBehaviorMemory = MemLib.EntityType.GetBattleBehaviorMemory(_EntityType)
	if battleBehaviorMemory then
		return battleBehaviorMemory[23]:GetFloat()
	end
	local autoCannonBehaviorMemory = MemLib.EntityType.BehaviorGetMemory(_EntityType, BehaviorProperties.CAutoCannonBehaviorProps)
	if autoCannonBehaviorMemory then
		return autoCannonBehaviorMemory[11]:GetFloat()
	end
	return 0
end
--------------------------------------------------------------------------------
---@param _EntityType integer
---@param _Range integer
function MemLib.EntityType.SetMaxAttackRange(_EntityType, _Range)
	local battleBehaviorMemory = MemLib.EntityType.GetBattleBehaviorMemory(_EntityType)
	if battleBehaviorMemory then
		battleBehaviorMemory[23]:SetFloat(_Range)
	end
	local autoCannonBehaviorMemory = MemLib.EntityType.BehaviorGetMemory(_EntityType, BehaviorProperties.CAutoCannonBehaviorProps)
	if autoCannonBehaviorMemory then
		autoCannonBehaviorMemory[11]:SetFloat(_Range)
	end
end
--------------------------------------------------------------------------------
---@param _EntityType integer
---@return number
function MemLib.EntityType.GetAOEDamageRange(_EntityType)
	local battleBehaviorMemory = MemLib.EntityType.GetBattleBehaviorMemory(_EntityType)
	if battleBehaviorMemory then
		return battleBehaviorMemory[16]:GetFloat()
	end
	local autoCannonBehaviorMemory = MemLib.EntityType.BehaviorGetMemory(_EntityType, BehaviorProperties.CAutoCannonBehaviorProps)
	if autoCannonBehaviorMemory then
		return autoCannonBehaviorMemory[15]:GetFloat()
	end
	return 0
end
--------------------------------------------------------------------------------
---@param _EntityType integer
---@param _Range integer
function MemLib.EntityType.SetAOEDamageRange(_EntityType, _Range)
	local battleBehaviorMemory = MemLib.EntityType.GetBattleBehaviorMemory(_EntityType)
	if battleBehaviorMemory then
		battleBehaviorMemory[16]:SetFloat(_Range)
	end
	local autoCannonBehaviorMemory = MemLib.EntityType.BehaviorGetMemory(_EntityType, BehaviorProperties.CAutoCannonBehaviorProps)
	if autoCannonBehaviorMemory then
		autoCannonBehaviorMemory[15]:SetFloat(_Range)
	end
end
--------------------------------------------------------------------------------
---@param _EntityType integer
---@return integer
function MemLib.EntityType.GetDamage(_EntityType)
	local battleBehaviorMemory = MemLib.EntityType.GetBattleBehaviorMemory(_EntityType) or MemLib.EntityType.BehaviorGetMemory(_EntityType, BehaviorProperties.CAutoCannonBehaviorProps)
	if battleBehaviorMemory then
		return battleBehaviorMemory[14]:GetInt()
	end
	return 0
end
--------------------------------------------------------------------------------
---@param _EntityType integer
---@param _Amount integer
function MemLib.EntityType.SetDamage(_EntityType, _Amount)
	local battleBehaviorMemory = MemLib.EntityType.GetBattleBehaviorMemory(_EntityType) or MemLib.EntityType.BehaviorGetMemory(_EntityType, BehaviorProperties.CAutoCannonBehaviorProps)
	if battleBehaviorMemory then
		battleBehaviorMemory[14]:SetInt(_Amount)
	end
end
--------------------------------------------------------------------------------
---@param _EntityType integer
---@return integer
function MemLib.EntityType.GetDamageClass(_EntityType)
	local battleBehaviorMemory = MemLib.EntityType.GetBattleBehaviorMemory(_EntityType) or MemLib.EntityType.BehaviorGetMemory(_EntityType, BehaviorProperties.CAutoCannonBehaviorProps)
	if battleBehaviorMemory then
		return battleBehaviorMemory[13]:GetInt()
	end
	return 0
end
--------------------------------------------------------------------------------
---@param _EntityType integer
---@param _DamageClass integer
function MemLib.EntityType.SetDamageClass(_EntityType, _DamageClass)
    assert(table.find(DamageClasses, _DamageClass))
	local battleBehaviorMemory = MemLib.EntityType.GetBattleBehaviorMemory(_EntityType) or MemLib.EntityType.BehaviorGetMemory(_EntityType, BehaviorProperties.CAutoCannonBehaviorProps)
	if battleBehaviorMemory then
		battleBehaviorMemory[13]:SetInt(_DamageClass)
	end
end
--------------------------------------------------------------------------------
---@param _EntityType integer
---@return userdata|table?
function MemLib.EntityType.GetBattleBehaviorMemory(_EntityType)
	local battleBehaviors = {
		BehaviorProperties.CLeaderBehaviorProps,
		BehaviorProperties.CSoldierBehaviorProps,
		BehaviorProperties.CSerfBattleBehaviorProps,
		BehaviorProperties.CBattleSerfBehaviorProps,
		BehaviorProperties.CBattleBehaviorProps,
	}
	for i = 1, 5 do
		local battleBehaviorMemory = MemLib.EntityType.BehaviorGetMemory(_EntityType, battleBehaviors[i])
		if battleBehaviorMemory then
			return battleBehaviorMemory
		end
	end
end
--------------------------------------------------------------------------------
---@param _EntityType integer
---@param _AttachmentType integer
---@return integer?
function MemLib.EntityType.LimitedAttachmentGetSlotAmount(_EntityType, _AttachmentType)
	local slotAmountMemory = MemLib.Internal.LimitedAttachmentGetSlotAmountMemory(_EntityType, _AttachmentType)
	if slotAmountMemory then
		return slotAmountMemory:GetInt()
	end
end
--------------------------------------------------------------------------------
---@param _EntityType integer
---@param _AttachmentType integer
---@param _Amount integer
function MemLib.EntityType.LimitedAttachmentSetSlotAmount(_EntityType, _AttachmentType, _Amount)
	local slotAmountMemory = MemLib.Internal.LimitedAttachmentGetSlotAmountMemory(_EntityType, _AttachmentType)
	if slotAmountMemory then
		return slotAmountMemory:SetInt(_Amount)
	end
end
--------------------------------------------------------------------------------
---@param _EntityType integer
---@param _AttachmentType integer
---@return userdata|table?
function MemLib.Internal.LimitedAttachmentGetSlotAmountMemory(_EntityType, _AttachmentType)
	local limitedAttachmentPropsMemory = MemLib.EntityType.BehaviorGetMemory(_EntityType, BehaviorProperties.CLimitedAttachmentBehaviorProperties)
	if limitedAttachmentPropsMemory then
		local vectorStartMemory = limitedAttachmentPropsMemory[5]
		local vectorEndMemory = limitedAttachmentPropsMemory[6]
		local lastIndex = (vectorEndMemory:GetInt() - vectorStartMemory:GetInt()) / 4 - 1

		for i = 0, lastIndex, 9 do
			local charAmount = vectorStartMemory[i + 5]:GetInt() - 1
			local charMemory = vectorStartMemory[i + 1][0]
			local attachmentName = ""
			for j = 0, charAmount do
				attachmentName = attachmentName .. string.char(charMemory:GetByte(j))
			end
			if AttachmentTypes[attachmentName] == _AttachmentType then
				return vectorStartMemory[i + 7]
			end
		end
	end
end
--------------------------------------------------------------------------------
---@param _TreeType integer
---@return integer
function MemLib.EntityType.TreeTypeGetResourceAmount(_TreeType)
	local entityTypeMemory = MemLib.EntityType.GetMemory(_TreeType)
	assert(entityTypeMemory[0]:GetInt() == EntityTypeClasses.CEntityProperties)
	return entityTypeMemory[39]:GetInt()
end
--------------------------------------------------------------------------------
---@param _EntityType integer
---@return boolean
function MemLib.EntityType.HasBlocking(_EntityType)
	local entityTypeMemory = MemLib.EntityType.GetMemory(_EntityType)
	local numBlockedPoints = entityTypeMemory[22]:GetInt()
	if numBlockedPoints > 0 then
		return true
	end
	local vectorStartAdress = entityTypeMemory[35]:GetInt()
	local vectorEndAddress = entityTypeMemory[36]:GetInt()
	return vectorEndAddress > vectorStartAdress
end
--------------------------------------------------------------------------------
function MemLib.EntityType.GetBlocking(_EntityType)
	local entityTypeMemory = MemLib.EntityType.GetMemory(_EntityType)
	local numBlockedPoints = entityTypeMemory[22]:GetInt()

	if numBlockedPoints > 0 then
		return numBlockedPoints
	end

	local vectorStartMemory = entityTypeMemory[35]
	local vectorEndMemory = entityTypeMemory[36]
	local blockingAreas = {}
	local lastindex = (vectorEndMemory:GetInt() - vectorStartMemory:GetInt()) / 4 - 1

	for i = 0, lastindex, 4 do
		table.insert(blockingAreas, { { X = vectorStartMemory[i]:GetFloat(), Y = vectorStartMemory[i + 1]:GetFloat() }, { X = vectorStartMemory[i + 2]:GetFloat(), Y = vectorStartMemory[i + 3]:GetFloat() } })
	end

	return blockingAreas
end
--------------------------------------------------------------------------------
if CppLogic then

	--------------------------------------------------------------------------------
	---@param _EntityType integer
	---@return integer
	function MemLib.EntityType.GetMaxHealth(_EntityType)
		return CppLogic.EntityType.GetMaxHealth(_EntityType)
	end
	--------------------------------------------------------------------------------
	---@param _EntityType integer
	---@param _MaxHealth integer
	function MemLib.EntityType.SetMaxHealth(_EntityType, _MaxHealth)
		CppLogic.EntityType.SetMaxHealth(_EntityType, _MaxHealth)
	end
	--------------------------------------------------------------------------------
	---@param _EntityType integer
	---@return integer Points
	---@return integer Seconds
	function MemLib.EntityType.GetHealingPointsAndSeconds(_EntityType)
		return CppLogic.EntityType.Settler.LeaderTypeGetRegeneration(_EntityType)
	end
	--------------------------------------------------------------------------------
	---@param _EntityType integer
	---@param _Modifier integer
	---@return table
	function MemLib.EntityType.GetModifierTechnologies(_EntityType, _Modifier)

		local techs = {}
		local getters = {
			CppLogic.EntityType.GetExplorationModifierTechs,
			CppLogic.EntityType.Settler.GetSpeedModifierTechs,
			CppLogic.EntityType.Settler.GetDamageModifierTechs,
			CppLogic.EntityType.GetArmorModifierTechs,
			CppLogic.EntityType.Settler.GetMaxRangeModifierTechs,
		}
		local getter = getters[_Modifier]

		if getter then
			return getter(_EntityType)
		end

		return techs
	end

else

	--------------------------------------------------------------------------------
	---@param _EntityType integer
	---@return integer
	function MemLib.EntityType.GetMaxHealth(_EntityType)
		return MemLib.EntityType.GetMemory(_EntityType)[13]:GetInt()
	end
	--------------------------------------------------------------------------------
	---@param _EntityType integer
	---@param _MaxHealth integer
	function MemLib.EntityType.SetMaxHealth(_EntityType, _MaxHealth)
		MemLib.EntityType.GetMemory(_EntityType)[13]:SetInt(_MaxHealth)
	end
	--------------------------------------------------------------------------------
	---@param _EntityType integer
	---@return integer Points
	---@return integer Seconds
	function MemLib.EntityType.GetHealingPointsAndSeconds(_EntityType)

		local behaviors = {
			BehaviorProperties.CLeaderBehaviorProps,
			BehaviorProperties.CBattleSerfBehaviorProps,
		}

		for _, behavior in ipairs(behaviors) do

			local battleBehaviorMemory = MemLib.EntityType.BehaviorGetMemory(_EntityType, behavior)

			if battleBehaviorMemory then
				return battleBehaviorMemory[28]:GetInt(), battleBehaviorMemory[29]:GetInt()
			end
		end
		return 0, 0
	end
	--------------------------------------------------------------------------------
	---@param _EntityType integer
	---@param _Modifier integer
	---@return table
	function MemLib.EntityType.GetModifierTechnologies(_EntityType, _Modifier)

		local techs = {}
		local offsets = {
			[Modifiers.Exploration]	=  88,
			[Modifiers.Hitpoints]	=  93,
			[Modifiers.Speed]		=  98,
			[Modifiers.Damage]		= 103,
			[Modifiers.Armor]		= 108,
			[Modifiers.DodgeChance]	= 113,
			[Modifiers.MaxRange]	= 118,
			[Modifiers.MinRange]	= 123,
			[Modifiers.DamageBonus]	= 128,
			[Modifiers.GroupLimit]	= 133,
		}
		local offset = offsets[_Modifier]

		if offset then

			local entityTypeMemory = MemLib.EntityType.GetMemory(_EntityType)

			local vectorStartMemory = entityTypeMemory[offset]
			local vectorEndMemory = entityTypeMemory[offset + 1]
			local lastIndex = (vectorEndMemory:GetInt() - vectorStartMemory:GetInt()) / 4 - 1

			for i = 0, lastIndex do
				table.insert(techs, vectorStartMemory[i]:GetInt())
			end
		end

		return techs
	end

end