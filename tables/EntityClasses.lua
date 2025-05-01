EntityClasses = {
	CGLEEntity = tonumber("783E74", 16),
	    CAmbientSoundEntity = tonumber("78568C", 16),
	    CBuilding = tonumber("76EB94", 16),
	        CBridgeEntity = tonumber("77805C", 16),
	        CConstructionSite = tonumber("77003C", 16),
		CMovingEntity = tonumber("783F84", 16),
			CAnimal = tonumber("778F7C", 16),
			CEvadingEntity = tonumber("770A7C", 16),
				CSettler = tonumber("76E3CC", 16),
		CResourceDoodad = tonumber("76FEA4", 16),
}
EntityClassChilds = {
	[EntityClasses.CGLEEntity] = {
		EntityClasses.CAmbientSoundEntity,
		EntityClasses.CBuilding,
		EntityClasses.CMovingEntity,
		EntityClasses.CResourceDoodad,
	},
	[EntityClasses.CBuilding] = {
		EntityClasses.CBridgeEntity,
		EntityClasses.CConstructionSite,
	},
	[EntityClasses.CMovingEntity] = {
		EntityClasses.CAnimal,
		EntityClasses.CEvadingEntity,
	},
	[EntityClasses.CEvadingEntity] = {
		EntityClasses.CSettler,
	},
}