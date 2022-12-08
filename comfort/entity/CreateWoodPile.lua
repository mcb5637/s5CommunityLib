--- author:???		current maintainer:RobbiTheFox
--- erstellt einen abbaubaren holzhaufen an einer position.
function CreateWoodPile(_posEntity, _resources)

	assert(type(_posEntity) == "string");

	assert(type(_resources) == "number");

	gvWoodPiles = gvWoodPiles or {

		JobID = StartSimpleJob("ControlWoodPiles"),

	};

	local pos = {}

	pos.X, pos.Y = Logic.GetEntityPosition(Logic.GetEntityIDByName(_posEntity))

	local pile_id = Logic.CreateEntity(Entities.XD_Rock3, pos.X, pos.Y, 0, 0);

	SetEntityName(pile_id, _posEntity .. "_WoodPile");

	local newE = ReplacingEntity(_posEntity, Entities.XD_ResourceTree);

	Logic.SetModelAndAnimSet(newE, Models.XD_SignalFire1);

	Logic.SetResourceDoodadGoodAmount(GetEntityId(_posEntity), _resources * 10);

	Logic.SetModelAndAnimSet(pile_id, Models.Effects_XF_ChopTree);

	table.insert(gvWoodPiles,
		{ ResourceEntity = _posEntity, PileEntity = _posEntity .. "_WoodPile", ResourceLimit = _resources * 9 });

end

function ControlWoodPiles()

	for i = table.getn(gvWoodPiles), 1, -1 do

		if Logic.GetResourceDoodadGoodAmount(GetEntityId(gvWoodPiles[i].ResourceEntity)) <= gvWoodPiles[i].ResourceLimit then

			DestroyWoodPile(gvWoodPiles[i], i);

		end

	end

end

function DestroyWoodPile(_piletable, _index)

	local pos = GetPosition(_piletable.ResourceEntity);

	DestroyEntity(_piletable.ResourceEntity);

	DestroyEntity(_piletable.PileEntity);

	Logic.CreateEffect(GGL_Effects.FXCrushBuilding, pos.X, pos.Y, 0);

	table.remove(gvWoodPiles, _index)

end

function ReplacingEntity(_Entity, _EntityType)

	local entityId = Logic.GetEntityIDByName(_Entity)

	local pos = {}

	pos.X, pos.Y = Logic.GetEntityPosition(entityId)

	local name = Logic.GetEntityName(entityId)

	local player = Logic.EntityGetPlayer(entityId)

	local orientation = Logic.GetEntityOrientation(entityId)

	local wasSelected = IsEntitySelected(_Entity)

	if wasSelected then

		GUI.DeselectEntity(entityId)

	end

	DestroyEntity(_Entity)

	local newEntityId = Logic.CreateEntity(_EntityType, pos.X, pos.Y, orientation, player)

	Logic.SetEntityName(newEntityId, name)

	if wasSelected then

		GUI.SelectEntity(newEntityId)

	end

	GroupSelection_EntityIDChanged(entityId, newEntityId)

	return newEntityId

end
