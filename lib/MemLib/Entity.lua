--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
-- MemLib.Entity
-- author: RobbiTheFox
-- current maintainer: RobbiTheFox
-- Version: v1.0
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
if mcbPacker then
    mcbPacker.require("s5CommunityLib/Lib/MemLib/MemLib")
    mcbPacker.require("s5CommunityLib/Lib/MemLib/EntityType")
    mcbPacker.require("s5CommunityLib/Lib/MemLib/Util")
    mcbPacker.require("s5CommunityLib/Tables/EntityClasses")
else
	if not MemLib then Script.Load("maps\\user\\EMS\\tools\\s5CommunityLib\\lib\\MemLib\\MemLib.lua") end
	MemLib.Load("EntityType", "Util", "Tables/EntityClasses")
end
--------------------------------------------------------------------------------
MemLib.Entity = {}
--------------------------------------------------------------------------------
if CUtilMemory then

	--------------------------------------------------------------------------------
	---@param _EntityId integer
	---@return userdata|table
	function MemLib.Entity.GetMemory(_EntityId)
		assert(MemLib.Entity.IsValid(_EntityId), "MemLib.Entity.GetMemory: _EntityId invalid")
		return CUtilMemory.GetMemory(CUtilMemory.GetEntityAddress(_EntityId))
	end

elseif S5Hook then

	--------------------------------------------------------------------------------
	---@param _EntityId integer
	---@return userdata|table
	function MemLib.Entity.GetMemory(_EntityId)
		assert(MemLib.Entity.IsValid(_EntityId), "MemLib.Entity.GetMemory: _EntityId invalid")
		return S5Hook.GetEntityMem(_EntityId)
	end

else

	--------------------------------------------------------------------------------
	if mcbPacker then
		mcbPacker.require("s5CommunityLib/Lib/MemLib/Bit")
	end
	--------------------------------------------------------------------------------
	---@param _EntityId integer
	---@return userdata|table
	function MemLib.Entity.GetMemory(_EntityId)
		assert(MemLib.Entity.IsValid(_EntityId), "MemLib.Entity.GetMemory: _EntityId invalid")
		local lowBits = MemLib.Bit.And(_EntityId, 65535)
		local entityManager = MemLib.GetMemory(9008472)[0]
		return MemLib.GetMemory(entityManager[2 * lowBits + 5]:GetInt())
	end

end
--------------------------------------------------------------------------------
---@param _EntityId integer
---@return boolean
function MemLib.Entity.IsValid(_EntityId)
	return type(_EntityId) == "number" and not Logic.IsEntityDestroyed(_EntityId)
end
--------------------------------------------------------------------------------
---@param _AttachmentType integer
---@return boolean
function MemLib.Entity.AttachmentTypeIsValid(_AttachmentType)
	return type(_AttachmentType) == "number" and _AttachmentType >= 2 and _AttachmentType <= 73 and _AttachmentType ~= 50
end
--------------------------------------------------------------------------------
if CUtil then

	--------------------------------------------------------------------------------
	-- nil if entity has no such behavior
	---@param _EntityId integer
	---@param _Behavior integer
	---@return userdata|table?
	function MemLib.Entity.BehaviorGetMemory(_EntityId, _Behavior)
		local behaviorAddress = tonumber(CUtil.GetBehaviour(_EntityId, _Behavior), 16)
		if behaviorAddress ~= 0 then
			return MemLib.GetMemory(behaviorAddress)
		end
	end

else

	--------------------------------------------------------------------------------
	-- nil if entity has no such behavior
	---@param _EntityId integer
	---@param _Behavior integer
	---@return userdata|table?
	function MemLib.Entity.BehaviorGetMemory(_EntityId, _Behavior)
		local entityMemory = MemLib.Entity.GetMemory(_EntityId)
		local vectorStartMemory = entityMemory[31]
		local vectorEndMemory = entityMemory[32]
		local lastindex = (vectorEndMemory:GetInt() - vectorStartMemory:GetInt()) / 4 - 1
		for i = 0, lastindex do
			local behaviorMemory = vectorStartMemory[i]
			if behaviorMemory:GetInt() ~= 0 and behaviorMemory[0]:GetInt() == _Behavior then
				return behaviorMemory
			end
		end
	end
end
--------------------------------------------------------------------------------
---@param _EntityId integer
---@param _EntityClass integer
---@return boolean
function MemLib.Entity.IsOfClass(_EntityId, _EntityClass)
    local entityClass = MemLib.Entity.GetClass(_EntityId)
    if entityClass == _EntityClass then
        return true
    end
    local entityClassChilds = EntityClassChilds[_EntityClass]
	if entityClassChilds then
		for i = 1, table.getn(entityClassChilds) do
			if MemLib.Entity.IsOfClass(_EntityId, entityClassChilds[i]) then
				return true
			end
		end
	end
    return false
end
--------------------------------------------------------------------------------
---@param _ResourceDoodadId integer
---@param _ResourceType integer
function MemLib.Entity.ResourceDoodadSetResourceType(_ResourceDoodadId, _ResourceType)
	assert(MemLib.Entity.GetClass(_ResourceDoodadId) == EntityClasses.CResourceDoodad, "MemLib.Util.ResourceDoodadSetResourceType: _ResourceDoodadId invalid")
	assert(MemLib.Util.ResourceTypeIsValid(_ResourceType), "MemLib.Util.ResourceDoodadSetResourceType: _ResourceType invalid")
	MemLib.Entity.GetMemory(_ResourceDoodadId)[66]:SetInt(_ResourceType)
end
--------------------------------------------------------------------------------
if CEntity then

	--------------------------------------------------------------------------------
	---@param _EntityId integer
	---@return integer
	function MemLib.Entity.GetClass(_EntityId)
		assert(MemLib.Entity.IsValid(_EntityId))
		return CUtil.GetEntityClass(_EntityId)
	end
	--------------------------------------------------------------------------------
	---@param _EntityId integer
	---@return table
	function MemLib.Entity.GetAttachedEntities(_EntityId)
		assert(MemLib.Entity.IsValid(_EntityId))
		return CEntity.GetAttachedEntities(_EntityId)
	end
	--------------------------------------------------------------------------------
	---@param _EntityId integer
	---@return table
	function MemLib.Entity.GetReversedAttachedEntities(_EntityId)
		assert(MemLib.Entity.IsValid(_EntityId))
		return CEntity.GetReversedAttachedEntities(_EntityId)
	end
	--------------------------------------------------------------------------------
	---@param _EntityId integer
	---@param _AttachmentType integer
	---@return integer
	function MemLib.Entity.LimitedAttachmentGetSlotAmount(_EntityId, _AttachmentType)
		assert(MemLib.Entity.IsValid(_EntityId))
		assert(MemLib.Entity.AttachmentTypeIsValid(_AttachmentType))
		return CEntity.GetAttachmentSlots(_EntityId, _AttachmentType)
	end
	--------------------------------------------------------------------------------
	---@param _EntityId integer
	---@param _AttachmentType integer
	---@param _Amount integer
	function MemLib.Entity.LimitedAttachmentSetSlotAmount(_EntityId, _AttachmentType, _Amount)
		assert(MemLib.Entity.IsValid(_EntityId))
		assert(MemLib.Entity.AttachmentTypeIsValid(_AttachmentType))
		assert(type(_Amount) == "number" and _Amount >= 0)
		CEntity.SetAttachmentSlots(_EntityId, _AttachmentType, _Amount)
	end

else

	--------------------------------------------------------------------------------
	---@param _EntityId integer
	---@return integer
	function MemLib.Entity.GetClass(_EntityId)
		return MemLib.Entity.GetMemory(_EntityId)[0]:GetInt()
	end
	--------------------------------------------------------------------------------
	---@param _EntityId integer
	---@return table
	function MemLib.Entity.GetAttachedEntities(_EntityId)
		return MemLib.Internal.GetAttachedEntities(_EntityId, 9)
	end
	--------------------------------------------------------------------------------
	---@param _EntityId integer
	---@return table
	function MemLib.Entity.GetReversedAttachedEntities(_EntityId)
		return MemLib.Internal.GetAttachedEntities(_EntityId, 15)
	end
	--------------------------------------------------------------------------------
	---@param _EntityId integer
	---@return table
	function MemLib.Internal.GetAttachedEntities(_EntityId, _Offset)
		assert(MemLib.Entity.IsValid(_EntityId))
		local attachments = {}
		local attachmentData = MemLib.Internal.MapGetNodes(MemLib.Entity.GetMemory(_EntityId)[_Offset], 2)
		for address, data in pairs(attachmentData) do
			local attachmentType = data[1]
			if MemLib.Entity.AttachmentTypeIsValid(attachmentType) and MemLib.Entity.IsValid(data[2]) then
				attachments[attachmentType] = attachments[attachmentType] or {}
				table.insert(attachments[attachmentType], data[2])
			end
		end
		return attachments
	end
	--------------------------------------------------------------------------------
	---@param _EntityId integer
	---@param _AttachmentType integer
	---@return integer
	function MemLib.Entity.LimitedAttachmentGetSlotAmount(_EntityId, _AttachmentType)
		assert(MemLib.Entity.IsValid(_EntityId))
		assert(MemLib.Entity.AttachmentTypeIsValid(_AttachmentType))
		local limitedAttachmentBehaviorMemory = MemLib.Entity.BehaviorGetMemory(_EntityId, Behaviors.CLimitedAttachmentBehavior)
		if limitedAttachmentBehaviorMemory then
			local attachmentData = MemLib.Internal.MapGetNodes(limitedAttachmentBehaviorMemory[6], 2)
			for address, data in pairs(attachmentData) do
				local attachmentType = data[1]
				if MemLib.Entity.AttachmentTypeIsValid(attachmentType) then
					return data[2]
				end
			end
		end
		return 0
	end
	--------------------------------------------------------------------------------
	---@param _EntityId integer
	---@param _AttachmentType integer
	---@param _Amount integer
	function MemLib.Entity.LimitedAttachmentSetSlotAmount(_EntityId, _AttachmentType, _Amount)
		assert(MemLib.Entity.IsValid(_EntityId))
		assert(MemLib.Entity.AttachmentTypeIsValid(_AttachmentType))
		assert(type(_Amount) == "number" and _Amount >= 0)
		local limitedAttachmentBehaviorMemory = MemLib.Entity.BehaviorGetMemory(_EntityId, Behaviors.CLimitedAttachmentBehavior)
		if limitedAttachmentBehaviorMemory then
			MemLib.Internal.MapNodeSetValue(limitedAttachmentBehaviorMemory[6], 3, _AttachmentType, 4, _Amount)
		end
	end

end
--------------------------------------------------------------------------------
if CUtil then

	--------------------------------------------------------------------------------
	---@param _ResourceEntityId integer
	function MemLib.Entity.ReplaceEntityWithResourceEntity(_ResourceEntityId)
		local entityTypeMemory = MemLib.EntityType.GetMemory(Logic.GetEntityType(_ResourceEntityId))
		assert(entityTypeMemory[0]:GetInt() == EntityTypeClasses.CEntityProperties)
		assert(MemLib.EntityType.IsValid(entityTypeMemory[38]:GetInt()))
		CUtil.ReplaceEntityWithResourceEntity(_ResourceEntityId)
	end

else

	--------------------------------------------------------------------------------
	---@param _ResourceEntityId integer
	function MemLib.Entity.ReplaceEntityWithResourceEntity(_ResourceEntityId)
		local entityTypeMemory = MemLib.EntityType.GetMemory(Logic.GetEntityType(_ResourceEntityId))
		assert(entityTypeMemory[0]:GetInt() == EntityTypeClasses.CEntityProperties)
		local resourceEntityType = entityTypeMemory[38]:GetInt()
		assert(MemLib.EntityType.IsValid(resourceEntityType))

		local x, y = Logic.GetEntityPosition(_ResourceEntityId)
		local r = Logic.GetEntityOrientation(_ResourceEntityId)
		local p = Logic.EntityGetPlayer(_ResourceEntityId)
		Logic.DestroyEntity(_ResourceEntityId)
		Logic.CreateEntity(resourceEntityType, x, y, r, p)
	end

end