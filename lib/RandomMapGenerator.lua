if mcbPacker then --mcbPacker.ignore
	mcbPacker.require("s5CommunityLib/comfort/other/S5HookLoader")
	mcbPacker.require("s5CommunityLib/comfort/math/Lerp")
	mcbPacker.require("s5CommunityLib/comfort/math/GetDistance")
	mcbPacker.require("s5CommunityLib/comfort/math/SimplexNoise")
	mcbPacker.require("s5CommunityLib/fixes/TriggerFix")
	mcbPacker.require("s5CommunityLib/tables/TerrainTypes")
	mcbPacker.require("s5CommunityLib/comfort/number/GetRandom")
end --mcbPacker.ignore


--- author:RobbiTheFox,mcb		current maintainer:RobbiTheFox		v1.0
-- Tool um zufällige Maps zu erzeugen.
-- 
-- - RandomMapGenerator.GenerateMap(generationData, generateAsLPJ, finishedCB)		Generiert eine map.
-- 																						generationData: Konfiguration für die Generierung.
-- 																						generateAsLPJ: Ob die Map sofort oder im hintergrund generiert werden soll.
-- 																						finishedCB: Wird nach beenden der generierung aufgerufen.
-- RandomMapGenerator.DefaultGeneratorData											Voreingestellte generierungsdaten.
-- RandomMapGenerator.DefaultGeneratorData.Seed										Seed für die Karte. (jeder Seed erzeugt immer dieselbe Karte).
-- RandomMapGenerator.DefaultGeneratorData.MaxPlayers								Azahl der Spieler.
-- RandomMapGenerator.StatusCallback(s)												Kann überschrieben werde, um Statusmeldungen anders zu verarbeiten.
-- 
-- Benötigt:
-- - S5Hook
-- - Lerp
-- - GetDistance
-- - SimplexNoise
-- - Trigger-Fix
-- - GetRandom
-- - TerrainTypes
RandomMapGenerator = {}

RandomMapGenerator.DefaultGeneratorData = {
	BaseHeight = 1750, -- 1650
	Seed = 123467,
	Noise = {},
	TerrainHeights = {},
	MaxPlayers = 4,
	PlayerPositions = {},
	MinPlayerDistance = 1100,
	Resources = {
		{
			ResourceEntity = Entities.XD_VillageCenter,
			MinNoise = 0,
			MaxNoise = 8,
			MinDistance = 1000,
			CenterOffsetX = 0,
			CenterOffsetY = 0,
			Layers = {
				[1] = {MinDistance =  2000, MaxDistance =  4000, ResourceNum = 1, ResourceAmount = {8000} },--1
			--[2] = {MinDistance = 16000, MaxDistance = 20000, ResourceNum = 1, ResourceAmount = {8000} },
			},
		},
		{
			ResourceEntity = Entities.XD_ClayPit1,
			MinNoise = 0,
			MaxNoise = 8,
			MinDistance = 1000,
			CenterOffsetX = 300,
			CenterOffsetY = 200,
			Layers = {
				[1] = {MinDistance =  2000, MaxDistance =  4000, ResourceNum = 1, ResourceAmount = {8000} },--1
			--[2] = {MinDistance = 16000, MaxDistance = 20000, ResourceNum = 1, ResourceAmount = {8000} },
			},
		},
		{
			ResourceEntity = Entities.XD_StonePit1,
			MinNoise = 0,
			MaxNoise = 8,
			MinDistance = 1300,
			CenterOffsetX = 0,
			CenterOffsetY = 0,
			Layers = {
				[1] = {MinDistance = 5000, MaxDistance = 7000, ResourceNum = 1, ResourceAmount = {12000} },--1
			--[2] = {MinDistance = 5000, MaxDistance = 7000, ResourceNum = 0, ResourceAmount = {12000} },
			},
		},
		{
			ResourceEntity = Entities.XD_IronPit1,
			MinNoise = 0,
			MaxNoise = 8,
			MinDistance = 900,
			CenterOffsetX = 100,
			CenterOffsetY = 200,
			Layers = {
				[1] = {MinDistance =  8000, MaxDistance = 12000, ResourceNum = 1, ResourceAmount = {8000} },--1
			--[2] = {MinDistance = 21000, MaxDistance = 25000, ResourceNum = 1, ResourceAmount = {8000} },
			},
		},
		{
			ResourceEntity = Entities.XD_SulfurPit1,
			MinNoise = 0,
			MaxNoise = 8,
			MinDistance = 900,
			CenterOffsetX = 200,
			CenterOffsetY = 200,
			Layers = {
				[1] = {MinDistance = 20000, MaxDistance = 25000, ResourceNum = 1, ResourceAmount = {4000} },--1
			--[2] = {MinDistance = 20000, MaxDistance = 25000, ResourceNum = 0, ResourceAmount = {4000} },
			},
		},
		{
			ResourceEntity = Entities.XD_VillageCenter,
			MinNoise = 0,
			MaxNoise = 8,
			MinDistance = 1000,
			CenterOffsetX = 0,
			CenterOffsetY = 0,
			Layers = {
				[1] = {MinDistance =  2000, MaxDistance =  4000, ResourceNum = 2, ResourceAmount = {8000} },--1
			--[2] = {MinDistance = 16000, MaxDistance = 20000, ResourceNum = 1, ResourceAmount = {8000} },
			},
		},
		{
			ResourceEntity = Entities.XD_StonePit1,
			MinNoise = 0,
			MaxNoise = 8,
			MinDistance = 1300,
			CenterOffsetX = 0,
			CenterOffsetY = 0,
			Layers = {
				[1] = {MinDistance = 5000, MaxDistance = 7000, ResourceNum = 1, ResourceAmount = {12000} },--1
			--[2] = {MinDistance = 5000, MaxDistance = 7000, ResourceNum = 0, ResourceAmount = {12000} },
			},
		},
		{
			ResourceEntity = Entities.XD_IronPit1,
			MinNoise = 0,
			MaxNoise = 8,
			MinDistance = 900,
			CenterOffsetX = 100,
			CenterOffsetY = 200,
			Layers = {
				[1] = {MinDistance =  8000, MaxDistance = 12000, ResourceNum = 1, ResourceAmount = {8000} },--1
			--[2] = {MinDistance = 21000, MaxDistance = 25000, ResourceNum = 1, ResourceAmount = {8000} },
			},
		},
		{
			ResourceEntity = Entities.XD_SulfurPit1,
			MinNoise = 0,
			MaxNoise = 8,
			MinDistance = 900,
			CenterOffsetX = 200,
			CenterOffsetY = 200,
			Layers = {
				[1] = {MinDistance = 20000, MaxDistance = 25000, ResourceNum = 1, ResourceAmount = {4000} },--1
			--[2] = {MinDistance = 20000, MaxDistance = 25000, ResourceNum = 0, ResourceAmount = {4000} },
			},
		},
		{
			ResourceEntity = Entities.XD_Clay1,
			MinNoise = 8,
			MaxNoise = 20,
			MinDistance = 400,
			CenterOffsetX = 0,
			CenterOffsetY = 0,
			Layers = {
				[1] = {MinDistance =  2000, MaxDistance =  4000, ResourceNum = 2, ResourceAmount = {400} }, --2
			--[2] = {MinDistance =  8000, MaxDistance = 10000, ResourceNum = 2, ResourceAmount = {400} },
			--[3] = {MinDistance = 13000, MaxDistance = 15000, ResourceNum = 2, ResourceAmount = {400} },
			},
		},
		{
			ResourceEntity = Entities.XD_Stone1,
			MinNoise = 8,
			MaxNoise = 20,
			MinDistance = 500,
			CenterOffsetX = 0,
			CenterOffsetY = 0,
			Layers = {
				[1] = {MinDistance =  2000, MaxDistance =  4000, ResourceNum = 2, ResourceAmount = {400} }, --1
			--[2] = {MinDistance = 20000, MaxDistance = 25000, ResourceNum = 3, ResourceAmount = {400} },
			},
		},
		{
			ResourceEntity = Entities.XD_Iron1,
			MinNoise = 8,
			MaxNoise = 20,
			MinDistance = 400,
			CenterOffsetX = 0,
			CenterOffsetY = 0,
			Layers = {
				[1] = {MinDistance = 2000, MaxDistance = 4000, ResourceNum = 2, ResourceAmount = {400} }, --1
			--[2] = {MinDistance = 0, MaxDistance = 0, ResourceNum = 0, ResourceAmount = {400} },
			},
		},
		{
			ResourceEntity = Entities.XD_Sulfur1,
			MinNoise = 8,
			MaxNoise = 20,
			MinDistance = 400,
			CenterOffsetX = 0,
			CenterOffsetY = 0,
			Layers = {
				[1] = {MinDistance = 11000, MaxDistance = 14000, ResourceNum = 2, ResourceAmount = {400} }, --2
			--[2] = {MinDistance = 0, MaxDistance = 0, ResourceNum = 0, ResourceAmount = {400} },
			},
		},
	},
	TerrainTypes = { -- TODO define landscape sets
		Mountain={
			TerrainTypes.RockDark01B_AT,TerrainTypes.RockDark01B_AT,TerrainTypes.RockDark01B_AT,TerrainTypes.RockDark01B_AT,
			TerrainTypes.RockDark02_AT,TerrainTypes.RockDark02_AT,TerrainTypes.RockDark02_AT,
			TerrainTypes.RockDark03_AT,TerrainTypes.RockDark03_AT,
			TerrainTypes.EarthRocky01B_AT,
		},
		Rocky={TerrainTypes.EarthRocky01B_AT},
		Forest={TerrainTypes.EarthFir01_AT,
			TerrainTypes.EarthFir02_AT,
			TerrainTypes.EarthFir03_AT,
			TerrainTypes.EarthMoss01_AT,TerrainTypes.EarthMoss01_AT,TerrainTypes.EarthMoss01_AT,TerrainTypes.EarthMoss01_AT,
			TerrainTypes.EarthMoss02_AT,TerrainTypes.EarthMoss02_AT,TerrainTypes.EarthMoss02_AT,TerrainTypes.EarthMoss02_AT,
			TerrainTypes.GrassDark01B_AT,
			TerrainTypes.GrassDark02_AT,
			TerrainTypes.GrassDarkLeaf01B_CT,
			TerrainTypes.GrassDarkLeaf02_CT,
		},
		DarkMeadow={
			TerrainTypes.EarthDark01B_AT,
			TerrainTypes.GrassDark01B_AT,TerrainTypes.GrassDark01B_AT,TerrainTypes.GrassDark01B_AT,TerrainTypes.GrassDark01B_AT,TerrainTypes.GrassDark01B_AT,TerrainTypes.GrassDark01B_AT,
			TerrainTypes.GrassDark02_AT,TerrainTypes.GrassDark02_AT,TerrainTypes.GrassDark02_AT,TerrainTypes.GrassDark02_AT,
			TerrainTypes.GrassDarkLeaf01B_CT,
			TerrainTypes.GrassDarkLeaf02_CT,
		},
		BrightMeadow={
			TerrainTypes.EarthBrStones01B_AT,
			TerrainTypes.GrassBright01B_AT,TerrainTypes.GrassBright01B_AT,TerrainTypes.GrassBright01B_AT,TerrainTypes.GrassBright01B_AT,
			TerrainTypes.GrassBright02_AT,TerrainTypes.GrassBright02_AT,
			TerrainTypes.GrassBright03_AT,TerrainTypes.GrassBright03_AT,
		},
		BrightEarth={
			TerrainTypes.EarthBright01B_AT,TerrainTypes.EarthBright01B_AT,TerrainTypes.EarthBright01B_AT,TerrainTypes.EarthBright01B_AT,
			TerrainTypes.EarthBright02_AT,TerrainTypes.EarthBright02_AT,
			TerrainTypes.EarthBrStones01B_AT,TerrainTypes.EarthBrStones01B_AT,
		},
		River={
			TerrainTypes.EarthFir01_AT,
			TerrainTypes.EarthFir02_AT,TerrainTypes.EarthFir02_AT,
			TerrainTypes.EarthFir03_AT,TerrainTypes.EarthFir03_AT,
		},
		DarkEarth={
			TerrainTypes.EarthDark01B_AT,TerrainTypes.EarthDark01B_AT,TerrainTypes.EarthDark01B_AT,TerrainTypes.EarthDark01B_AT,
			TerrainTypes.EarthDark02_AT,TerrainTypes.EarthDark02_AT,
			TerrainTypes.EarthDark03_AT,TerrainTypes.EarthDark03_AT,
		}, -- lehm
		NorthSand={
			TerrainTypes.SandRockyNorth01_AT_HP,
			TerrainTypes.SandEarthNorth01_AT_HP,
		}, -- schwefel
		DarkMud={
			TerrainTypes.MudDark01B_AT,TerrainTypes.MudDark01B_AT,TerrainTypes.MudDark01B_AT,TerrainTypes.MudDark01B_AT,
			TerrainTypes.MudDark02B_AT,TerrainTypes.MudDark02B_AT,TerrainTypes.MudDark02B_AT,
			TerrainTypes.MudDark03_AT,TerrainTypes.MudDark03_AT,
			TerrainTypes.MudDark04_AT,TerrainTypes.MudDark04_AT,
			TerrainTypes.MudDark05_AT,TerrainTypes.MudDark05_AT,
		}, -- eisen
	},
	EntityArray={
		Rocky = {
			Entities.XD_Rock1,
			Entities.XD_Rock1,
			Entities.XD_Rock1,
			Entities.XD_Rock1,
			Entities.XD_Rock1,
			Entities.XD_Rock1,
			Entities.XD_Rock1,
			Entities.XD_Rock1,
			Entities.XD_Rock2,
			Entities.XD_Rock2,
			Entities.XD_Rock2,
			Entities.XD_Rock2,
			Entities.XD_Rock2,
			Entities.XD_Rock2,
			Entities.XD_Rock3,
			Entities.XD_Rock3,
			Entities.XD_Rock3,
			Entities.XD_Rock3,
			Entities.XD_Rock3,
			Entities.XD_Rock4,
			Entities.XD_Rock4,
			Entities.XD_Rock4,
			Entities.XD_Rock4,
			Entities.XD_Rock5,
			Entities.XD_Rock5,
			Entities.XD_Rock5,
			Entities.XD_Rock6,
			Entities.XD_Rock6,
			Entities.XD_Rock7
		},
		Forest = {
			Entities.XD_Bush1,
			Entities.XD_Bush4,
			Entities.XD_Fir1,
			Entities.XD_Fir1_small,
			Entities.XD_Fir1_small,
			Entities.XD_Fir2,
			Entities.XD_Fir2_small,
			Entities.XD_Fir2_small,
			Entities.XD_GreeneryBushHigh2,
			Entities.XD_GreeneryBushHigh3,
			Entities.XD_GreeneryBushHigh4,
			Entities.XD_Plant1,
			Entities.XD_Plant2,
			Entities.XD_Rock1,
			Entities.XD_RockGrass2,
			Entities.XD_Tree1,
			Entities.XD_Tree1_small,
			Entities.XD_Tree1_small,
			Entities.XD_Tree2,
			Entities.XD_Tree2_small,
			Entities.XD_Tree2_small,
			Entities.XD_Tree3,
			Entities.XD_Tree3_small,
			Entities.XD_Tree3_small
		},
		DarkMeadow = {
			Entities.XD_Bush2,
			Entities.XD_Bush3,
			Entities.XD_GreeneryVertical1,
			Entities.XD_GreeneryVertical1,
			Entities.XD_GreeneryVertical1,
			Entities.XD_GreeneryVertical1,
			Entities.XD_GreeneryVertical2,
			Entities.XD_GreeneryVertical2,
			Entities.XD_GreeneryVertical2,
			Entities.XD_GreeneryVertical2,
			Entities.XD_Plant1,
			Entities.XD_Plant2,
			Entities.XD_Plant3,
			Entities.XD_Plant4,
			Entities.XD_PlantDecalLarge1,
			Entities.XD_PlantDecalLarge2,
			Entities.XD_PlantDecalLarge5,
			Entities.XD_Rock1,
			Entities.XD_RockGrass2
		},
		BrightMeadow = {
			Entities.XD_Bush2,
			Entities.XD_Bush3,
			Entities.XD_Corn1,
			Entities.XD_GreeneryVertical1,
			Entities.XD_GreeneryVertical1,
			Entities.XD_GreeneryVertical1,
			Entities.XD_GreeneryVertical1,
			Entities.XD_GreeneryVertical2,
			Entities.XD_GreeneryVertical2,
			Entities.XD_GreeneryVertical2,
			Entities.XD_GreeneryVertical2,
			Entities.XD_Plant1,
			Entities.XD_Plant2,
			Entities.XD_Plant3,
			Entities.XD_Plant4,
			Entities.XD_PlantDecal1,
			Entities.XD_PlantDecal2,
			Entities.XD_PlantDecal4,
			Entities.XD_PlantDecalLarge1,
			Entities.XD_PlantDecalLarge2,
			Entities.XD_PlantDecalLarge5,
			Entities.XD_Rock1,
			Entities.XD_RockGrass2
		},
		ToDestroy = {
			Entities.XD_Rock3,
			Entities.XD_Rock4,
			Entities.XD_Rock5,
			Entities.XD_Rock6,
			Entities.XD_Rock7,
			Entities.XD_Fir1,
			Entities.XD_Fir1_small,
			Entities.XD_Fir2,
			Entities.XD_Fir2_small,
			Entities.XD_Tree1,
			Entities.XD_Tree1_small,
			Entities.XD_Tree2,
			Entities.XD_Tree2_small,
			Entities.XD_Tree3,
			Entities.XD_Tree3_small,
		}
	},
}

function RandomMapGenerator.GenerateMap(generationData, generateAsLPJ, finishedCB)
    Score.Player[0] = {buildings=0,all=0}
    
	SimplexNoise.seedP(generationData.Seed)
	math.randomseed(generationData.Seed)
	GvRandomseed = true -- prevent GetRandom from reseeding

	local mapsize = Logic.WorldGetSize()/100

	generationData.currentY = 0
	generationData.Steps = math.floor(1536 / mapsize) -- 1536 or 1540
	generationData.ReducePlayerDistance = 0
	generationData.currentFunc = 1
	generationData.currentPlayer = 1
	generationData.currentResource = {1,1,1,1}

	if generateAsLPJ then
		return StartSimpleLowPriorityJob("RandomMapGenerator.GeneratorJob", generationData, finishedCB)
	else
		while true do
			if RandomMapGenerator.GeneratorJob(generationData)==true then
				break
			end
		end
		if finishedCB then
			finishedCB()
		end
	end

end

function RandomMapGenerator.GeneratorJob(generationData, finishedCB)
	if generationData.currentFunc == 1 then
		if RandomMapGenerator.CalculateNoise(generationData)==true then
			generationData.currentFunc = 2
		end
		return 0.005
	elseif generationData.currentFunc == 2 then
		if RandomMapGenerator.ApplyNoise(generationData)==true then
			generationData.currentFunc = 3
		end
		return 0.005
	elseif generationData.currentFunc == 3 then
		if RandomMapGenerator.DrawTextures(generationData)==true then
			generationData.currentFunc = 4
		end
		return 0.005
	elseif generationData.currentFunc == 4 then
		if RandomMapGenerator.CreateEnvironment(generationData)==true then
			generationData.currentFunc = 5
		end
		return 0.005
	elseif generationData.currentFunc == 5 then
		if RandomMapGenerator.SetPlayerPosition(generationData, generationData.currentPlayer)==true then
			generationData.currentPlayer = generationData.currentPlayer + 1
			if generationData.currentPlayer>generationData.MaxPlayers then
				generationData.currentFunc = 6
			end
		end
		return 0.005
	elseif generationData.currentFunc == 6 then
		if RandomMapGenerator.CreateResource(generationData, generationData.currentResource[1], generationData.currentResource[2], generationData.currentResource[3], generationData.currentResource[4])==true then
			generationData.currentResource[1] = generationData.currentResource[1] + 1
			if generationData.currentResource[1] > generationData.Resources[generationData.currentResource[4]].Layers[generationData.currentResource[2]].ResourceNum then
				generationData.currentResource[1] = 1
				generationData.currentResource[2] = generationData.currentResource[2] + 1
			end
			if generationData.currentResource[2] > table.getn(generationData.Resources[generationData.currentResource[4]].Layers) then
				generationData.currentResource[2] = 1
				generationData.currentResource[3] = generationData.currentResource[3] + 1
			end
			if generationData.currentResource[3] > generationData.MaxPlayers then
				generationData.currentResource[3] = 1
				generationData.currentResource[4] = generationData.currentResource[4] + 1
			end
			if generationData.currentResource[4]>table.getn(generationData.Resources) then
				generationData.currentFunc = 7
			end
		end
		return 0.005
	elseif generationData.currentFunc == 7 then
		if RandomMapGenerator.CreatePlayers(generationData)==true then
			generationData.currentFunc = 8
		end
		return 0.005
	end

	local mapsize = Logic.WorldGetSize()/100
	Logic.UpdateBlocking(1, 1, mapsize - 1, mapsize - 1)
	GUI.RebuildMinimapTerrain()
	if finishedCB then
		finishedCB()
	end
	return true
end

function RandomMapGenerator.StatusCallback(s)
	GUI.ClearNotes()
	GUI.AddNote(s, 1)
end

function RandomMapGenerator.CalculateNoise(generationData)
	local freq = 8
	local mainNoise

	local mapsize = Logic.WorldGetSize()/100
	for x = 0, mapsize do
		if not generationData.Noise[x] then
			generationData.Noise[x] = {}
		end

		for y = generationData.currentY, math.min(generationData.currentY + generationData.Steps - 1, mapsize) do
			mainNoise = RandomMapGenerator.GetSimplexNoise(4, x, y, 0.5, 0.0095, -95, 105)
			generationData.Noise[x][y] = mainNoise
		end
	end

	RandomMapGenerator.StatusCallback("Calculating Noise: "..math.floor((generationData.currentY + generationData.Steps) / (mapsize / 100)).."%")

	generationData.currentY = generationData.currentY + generationData.Steps
	if generationData.currentY > mapsize then
		generationData.currentY = 0
		return true
	end
end

function RandomMapGenerator.GetSimplexNoise(num_octaves, x, y, persistence, scale, low, high)
	local maxAmp = 0
	local amp = 1
	local freq = scale
	local noise = 0

	--add successively smaller, higher-frequency terms
	for i = 1, num_octaves do
		noise = noise + SimplexNoise.Noise2D(SimplexNoise.perm[i], x * freq, y * freq) * amp--offset,
		maxAmp = maxAmp + amp
		amp = amp * persistence
		freq = freq * 2
	end

	--take the average value of the iterations
	noise = noise / maxAmp

	--normalize the result
	noise = noise * (high - low) / 2 + (high + low) / 2

	return noise -- * m_fractalBounding -- erledigt maxAmp für uns
end

function RandomMapGenerator.ApplyNoise(generationData)
	local noise
	local height

	local mapsize = Logic.WorldGetSize()/100

	for x = 0, Logic.WorldGetSize()/100 do
		if not generationData.TerrainHeights[x] then
			generationData.TerrainHeights[x] = {}
		end

		for y = generationData.currentY, math.min(generationData.currentY + generationData.Steps - 1, mapsize) do
			noise = generationData.Noise[x][y]

			if noise > 0 then
				noise = math.max(0, noise - 25) -- 30
			else
				noise = math.min(0, noise + 25)
			end

			height = math.max(noise * 35 + generationData.BaseHeight, 0)
			generationData.TerrainHeights[x][y] = height
			Logic.SetTerrainNodeHeight(x, y, height)
		end
	end
	
	RandomMapGenerator.StatusCallback("Setting Terrain Height: "..math.floor((generationData.currentY + generationData.Steps) / (mapsize / 100)).."%")
	
	generationData.currentY = generationData.currentY + generationData.Steps
	if generationData.currentY > mapsize then
		generationData.currentY = 0
		return true
	end
end

function RandomMapGenerator.GetBiomeKey(noise) -- this way, we can use the same biome logic for terrain and entities
	if noise > 35 then
		 return "Mountain"
	elseif noise > 30 then
		return "Rocky"
	elseif noise < -30 then
		return "River"
	else -- flacher Bereich
		noise = math.abs(noise)
		if noise > 16 then
			return "Forest"
		elseif noise > 12 then
			return "DarkMeadow"
		elseif noise > 3 then
			return "BrightMeadow"
		else
			return "BrightEarth"
		end
	end
end

function RandomMapGenerator.DrawTextures(generationData)
	local noise
	local mapSize = Logic.WorldGetSize()/100
	local mapCenter = mapSize / 2

	for x = 0, mapSize, 4 do
		for y = generationData.currentY, math.min(generationData.currentY + generationData.Steps*4 - 1, mapSize), 4 do
			if math.sqrt((x - mapCenter)^2 + (y - mapCenter)^2) < mapCenter then
				noise = generationData.Noise[x][y]
				RandomMapGenerator.SetRandomTexture(x, y, generationData.TerrainTypes[RandomMapGenerator.GetBiomeKey(noise)])
			end
		end
	end
	
	RandomMapGenerator.StatusCallback("Setting Terrain textures: "..math.floor((generationData.currentY + generationData.Steps) / (mapSize / 100)).."%")
	
	generationData.currentY = generationData.currentY + generationData.Steps*4
	if generationData.currentY > mapSize then
		generationData.currentY = 0
		return true
	end
end

function RandomMapGenerator.SetRandomTexture(nodeX, nodeY, textures)
	Logic.SetTerrainNodeType(nodeX, nodeY, textures[GetRandom(1, table.getn(textures))])
end

function RandomMapGenerator.CreateEnvironment(generationData)
	local noise
	local limit = Logic.WorldGetSize() - 100
	local center = Logic.WorldGetSize() / 2
	local centersq = center^2

	if generationData.currentY<=100 then
		generationData.currentY = 100
	end

	for x = 100, limit, 300 do
		local y = generationData.currentY
		if ((x - center)^2 + (y - center)^2) < centersq then
			noise = generationData.Noise[x/100][y/100]
			local entitytable = generationData.EntityArray[RandomMapGenerator.GetBiomeKey(noise)]
			if entitytable then
				RandomMapGenerator.CreateRandomEntity(x, y, entitytable)
			end
		end
	end
	
	RandomMapGenerator.StatusCallback("Createing Entities: "..math.floor((generationData.currentY + 300) / (limit / 100)).."%")
	
	generationData.currentY = generationData.currentY + 300
	if generationData.currentY > limit then
		generationData.currentY = 0
		return true
	end
end

function RandomMapGenerator.CreateRandomEntity(posX, posY, entities)
	Logic.CreateEntity(entities[GetRandom(1, table.getn(entities))], posX + GetRandom(-100, 100), posY + GetRandom(-100, 100), GetRandom(0, 360), 0)
end

function RandomMapGenerator.SetPlayerPosition(generationData, p)
	RandomMapGenerator.StatusCallback("Setting Player Positions: ".. math.floor((p - 1) / generationData.MaxPlayers * 100) .."%")
	
	local posX, posY
	local noise
	local limit = 50
	local size = Logic.WorldGetSize()/100
	local mapCenter = size * 50 -- = *100/2

	for n = 1, 50 do
		generationData.ReducePlayerDistance = generationData.ReducePlayerDistance + 1

		posX = GetRandom(limit, size - limit)
		posY = GetRandom(limit, size - limit)
		noise = math.abs(generationData.Noise[posX][posY])

		posX = posX * 100
		posY = posY * 100

		if (noise < 8 and not RandomMapGenerator.IsPlayerInArea(generationData, p, posX, posY, size * 35 - generationData.ReducePlayerDistance)) then
			if math.sqrt((posX - mapCenter)^2 + (posY - mapCenter)^2) < mapCenter - generationData.MinPlayerDistance then
				generationData.PlayerPositions[p] = {X = posX, Y = posY}
				return true
			end
		end
	end
end

function RandomMapGenerator.IsPlayerInArea(generationData, player, posX, posY, size)
	for p = 1, player - 1 do
		if math.sqrt((posX - generationData.PlayerPositions[p].X)^2 + (posY - generationData.PlayerPositions[p].Y)^2) <= size then
			return true
		end
	end
	return false
end

---params:
-- j : the current resource num
-- i : the current resource layer
-- p : the current player resources aree created for
-- r : the current resource type as number (1 - 8)
--
function RandomMapGenerator.CreateResource(generationData, j, i, p, r)
	local rr = 0.125
	local pp = rr / 4
	local ii = pp / table.getn(generationData.Resources[r].Layers)
	local jj = ii / math.max(generationData.Resources[r].Layers[i].ResourceNum, 1)
	local percent = math.floor(((r - 1) * rr + (p - 1) * pp + (i - 1) * ii + (j - 1) * jj) * 100)

	RandomMapGenerator.StatusCallback("Creating Resources: ".. percent .."%")

	local posX, posY
	local distance
	local noise

	local limitMin = 1000
	local size = Logic.WorldGetSize()
	local limitMax = size - limitMin
	local mapCenter = size/2
	local mapCenterDistance = mapCenter - limitMin

	local resourceAmount
	local success = 0

	if p == 0 then
		-- create neutral resources here
	else
		if generationData.Resources[r].Layers[i].ResourceNum == 0 then
			return true
		else

			for n = 1, 50 do
				distance = generationData.Resources[r].Layers[i].MaxDistance
				posX = math.min(math.max(generationData.PlayerPositions[p].X + GetRandom(-distance, distance), limitMin), limitMax)
				posY = math.min(math.max(generationData.PlayerPositions[p].Y + GetRandom(-distance, distance), limitMin), limitMax)
				noise = math.abs(generationData.Noise[math.floor(posX/100)][math.floor(posY/100)])

				if noise <= generationData.Resources[r].MaxNoise then
					if not RandomMapGenerator.IsPlayerEntityInArea(generationData, posX, posY, generationData.Resources[r].MinDistance) and not RandomMapGenerator.IsResourceInArea(generationData, posX, posY, generationData.Resources[r].MinDistance) then

						distance = math.sqrt((posX - generationData.PlayerPositions[p].X)^2 + (posY - generationData.PlayerPositions[p].Y)^2)

						if distance >= generationData.Resources[r].Layers[i].MinDistance and distance <= generationData.Resources[r].Layers[i].MaxDistance then
							if math.sqrt((posX - mapCenter)^2 + (posY - mapCenter)^2) < mapCenterDistance then
								resourceAmount = generationData.Resources[r].Layers[i].ResourceAmount[j] or generationData.Resources[r].Layers[i].ResourceAmount[1]
								RandomMapGenerator.CreateResourceEntity(generationData, generationData.Resources[r].ResourceEntity, posX, posY, resourceAmount, r)
								return true
							end
						end
					end
				end
			end
		end
	end
end

function RandomMapGenerator.IsPlayerEntityInArea(generationData, posX, posY, size)
	local distance = size + generationData.MinPlayerDistance
	for p = 1, generationData.MaxPlayers do
		if Logic.IsPlayerEntityInArea(p, posX, posY, distance) == 1 then
			return true
		elseif GetDistance({X=posX, Y=posY}, generationData.PlayerPositions[p]) <= distance then
			return true
		end
	end
	return false
end

function RandomMapGenerator.IsResourceInArea(generationData, posX, posY, size)
	for _,rdata in ipairs(generationData.Resources) do
		if Logic.GetEntitiesInArea(rdata.ResourceEntity, posX, posY, size + rdata.MinDistance, 1) >= 1 then
			return true
		end
	end
	return false
end

function RandomMapGenerator.CreateResourceEntity(generationData, entityType, posX, posY, amount, r)
	if RandomMapGenerator.TerrainArray[entityType] then
		local terrainarray = RandomMapGenerator.TerrainArray[entityType]
		
		local px = math.floor(posX / 100) + terrainarray.OffsetX
		local py = math.floor(posY / 100) + terrainarray.OffsetY
		local height
	
		local centerX = math.floor((posX + terrainarray.CenterOffsetX) / 100)
		local centerY = math.floor((posY + terrainarray.CenterOffsetY) / 100)
		local distance
		local minDistance = (terrainarray.MinDistance or generationData.Resources[r].MinDistance) / 100
		local maxDistance = minDistance + 5
	
		local lerpDivisor = maxDistance - minDistance
		local lerpFactor
		
		local size = Logic.WorldGetSize()/100
	
		for x = terrainarray.TerrainIterLow.X, terrainarray.TerrainIterHigh.X do -- 1, 16 -- FORMEL: -15 + offset, 15 + offset
			for y = terrainarray.TerrainIterLow.Y, terrainarray.TerrainIterHigh.Y do -- 1, 14
				if px + x >= 0 and px + x <= size and py + y >= 0 and py + y <= size then
					distance = math.sqrt((px + x - centerX)^2 + (py + y - centerY)^2)
	
					if distance <= maxDistance then -- IS IN MAX RANGE ?
						-- SET HEIGHT!
						if not terrainarray.TerrainHeights[x] then
							height = generationData.BaseHeight
						elseif not terrainarray.TerrainHeights[x][y] then
							height = generationData.BaseHeight
						else
							height = terrainarray.TerrainHeights[x][y] + generationData.BaseHeight
						end
	
						if distance >= minDistance then  -- IS OUT OF MIN RANGE ?
							-- LERP HEIGHT!
							lerpFactor = (distance - minDistance) / (lerpDivisor)
							height = height * (1 - lerpFactor) + lerpFactor * generationData.TerrainHeights[px + x][py + y]
						end
		
						Logic.SetTerrainNodeHeight( px + x, py + y, height )
					end
				end
			end
		end
	
		px = math.floor(posX / 400) * 4 - 8
		py = math.floor(posY / 400) * 4 - 8
	
		Logic.WaterSetAbsoluteHeight(px + terrainarray.WaterLow.X , py + terrainarray.WaterLow.Y, px + terrainarray.WaterHigh.X, py + terrainarray.WaterHigh.Y, 1000)
	
		local terrainlist = generationData.TerrainTypes[terrainarray.TerrainTypeTextureList]
		for x = 0, terrainarray.TerrainTypeHigh, 4 do
			for y = 0, terrainarray.TerrainTypeHigh, 4 do
				if math.sqrt((x-10)^2 + (y-10)^2) <= terrainarray.TerrainTypeCircleSq then
					RandomMapGenerator.SetRandomTexture(px+x, py+y, terrainlist)
				end
			end
		end
	
		RandomMapGenerator.DestroyUnwantedEntities(generationData, posX + terrainarray.RemoveEntities.X, posY + terrainarray.RemoveEntities.Y, terrainarray.RemoveEntities.r)
	
		local pit = Logic.CreateEntity(entityType, posX + terrainarray.PitOffsetX, posY + terrainarray.PitOffsetY, 0, 0)
		if not terrainarray.NoResource then
			Logic.SetResourceDoodadGoodAmount(pit, amount)
		end
	else
		local entity = Logic.CreateEntity(entityType, posX, posY, 0, 0)
		Logic.SetResourceDoodadGoodAmount(entity, amount)
	end
end

function RandomMapGenerator.DestroyUnwantedEntities(generationData, posX, posY, size)
	for id in CppLogic.Entity.EntityIterator(CppLogic.Entity.Predicates.OfPlayer(0), CppLogic.Entity.Predicates.InCircle(posX, posY, size)) do
		DestroyEntity(id)
	end
end

function RandomMapGenerator.CreatePlayers(generationData)
	RandomMapGenerator.StatusCallback("Creating Players ...")

	local posX, posY
	local px, py
	local distance
	local minDistance = math.floor(generationData.MinPlayerDistance / 100) + 2
	local maxDistance = minDistance + 5
	local height
	local lerpDivisor = maxDistance - minDistance
	local lerpFactor

	local size = Logic.WorldGetSize()/100
	
	for p = 1, generationData.MaxPlayers do
		posX = generationData.PlayerPositions[p].X
		posY = generationData.PlayerPositions[p].Y

		RandomMapGenerator.DestroyUnwantedEntities(generationData, posX -100, posY, generationData.MinPlayerDistance)

		Logic.CreateEntity(Entities.PB_Headquarters1, posX, posY, 0, p)

		px = math.floor(posX / 100)
		py = math.floor(posY / 100)

		for x = -maxDistance -1, maxDistance - 1 do
			for y = -maxDistance, maxDistance do
				if px + x >= 0 and px + x <= size and py + y >= 0 and py + y <= size then
					distance = math.sqrt((px + x)^2 + (py + y)^2)

					if distance <= maxDistance then -- IS IN MAX RANGE ?

						if distance >= minDistance then  -- IS OUT OF MIN RANGE ?
							-- LERP HEIGHT!
							lerpFactor = (distance - minDistance) / (lerpDivisor)
							height = generationData.BaseHeight * (1 - lerpFactor) + lerpFactor * generationData.TerrainHeights[px + x][py + y]
					else
						-- BASE HEIGHT!
						height = generationData.BaseHeight
					end

					Logic.SetTerrainNodeHeight( px + x, py + y, height )
					end

				end
			end
		end

		for y = -300, 300, 200 do
			Logic.CreateEntity(Entities.PU_Serf, posX - 900, posY + y, 180, p)
		end
	end
	return true
end

RandomMapGenerator.TerrainArray = {}
RandomMapGenerator.TerrainArray[Entities.XD_ClayPit1] = {
	OffsetX = -6,
	OffsetY = -6,
	PitOffsetX = 25,
	PitOffsetY = 50,
	CenterOffsetX = 300,
	CenterOffsetY = 200,
	TerrainIterLow = {X=-7,Y=-8},
	TerrainIterHigh = {X=23,Y=22},
	WaterLow = {X=4,Y=4},
	WaterHigh ={X=12,Y=12},
	TerrainTypeHigh = 24,
	TerrainTypeCircleSq = 12,
	TerrainTypeTextureList = "DarkEarth",
	RemoveEntities = {X=300,Y=200,r=950},
	TerrainHeights = {
		{-3, -14, -24, -32, -34, -33, -35, -40, -43, -34, -21, -9, 0, 0 },
		{-13, -29, -47, -62, -72, -76, -88, -95, -90, -64, -33, -11, 0, 0 },
		{-23, -63, -102, -135, -162, -183, -201, -204, -182, -125, -62, -18, 0, 0 },
		{-45, -105, -180, -257, -294, -377, -377, -377, -292, -214, -90, -28, -1, 0 },
		{-59, -140, -249, -346, -372, -377, -377, -377, -360, -269, -105, -26, -6, 0 },
		{-58, -150, -263, -355, -377, -377, -377, -377, -361, -268, -125, -39, -9, 0 },
		{-58, -150, -266, -358, -377, -377, -377, -377, -363, -266, -134, -46, -14, 0 },
		{-58, -145, -263, -360, -377, -377, -377, -377, -357, -265, -140, -52, -14, 0 },
		{-50, -130, -254, -358, -377, -377, -377, -377, -363, -267, -137, -52, -17, 0 },
		{-43, -115, -226, -314, -353, -355, -351, -345, -303, -232, -132, -56, -16, 0 },
		{-38, -92, -167, -233, -271, -267, -262, -249, -218, -165, -97, -40, -12, 0 },
		{-21, -51, -95, -124, -125, -131, -133, -127, -111, -82, -49, -20, -6, 0 },
		{-9, -16, -32, -43, -39, -44, -47, -47, -39, -28, -18, -10, -2, 0 },
		{-2, -2, -3, -5, -5, -8, -9, -12, -6, -4, -3, -1, 0, 0 },
		{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
		{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
	}
}
RandomMapGenerator.TerrainArray[Entities.XD_StonePit1] = {
	OffsetX = -7,
	OffsetY = -11,
	PitOffsetX = -100,
	PitOffsetY = -100,
	CenterOffsetX = 0,
	CenterOffsetY = 0,
	TerrainIterLow = {X=-9,Y=-5},
	TerrainIterHigh = {X=21,Y=25},
	WaterLow = {X=0,Y=0},
	WaterHigh ={X=1,Y=1},
	TerrainTypeHigh = 24,
	TerrainTypeCircleSq = 12,
	TerrainTypeTextureList = "Rocky",
	RemoveEntities = {X=0,Y=0,r=850},
	MinDistance = 1000,
	TerrainHeights = {
		{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 25, 49, 45, 24, 5, 0 },
		{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, -7, -18, -12, 0, 5, 57, 93, 116, 99, 57, 31, 0 },
		{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -4, -36, -50, -48, 0, 29, 139, 180, 165, 116, 74, 53, 0 },
		{0, 0, 0, 0, 0, 0, 0, 0, -3, -6, -11, -33, -76, -97, -101, -126, 51, 204, 288, 245, 162, 89, 77, 0 },
		{0, 0, 0, 0, 0, 0, -1, -4, -9, -22, -39, -64, -116, -141, -126, -126, 50, 246, 363, 355, 327, 144, 108, 0 },
		{0, 0, 0, 0, 0, 0, -14, -18, -26, -45, -60, -82, -161, -131, -126, -126, 46, 321, 440, 399, 322, 192, 103, 0 },
		{0, 0, 0, 0, -2, -17, -39, -45, -54, -71, -89, -103, -112, -126, -126, -110, 17, 400, 452, 422, 330, 212, 104, 0 },
		{0, 0, 0, -1, -4, -31, -71, -126, -92, -96, -104, -107, -117, -126, -126, -51, 162, 459, 465, 436, 340, 216, 107, 0 },
		{0, 0, 0, -1, -3, -20, -109, -126, -126, -117, -104, -112, -126, -126, -107, 30, 326, 478, 465, 420, 320, 205, 103, 0 },
		{0, 0, 0, -1, -3, -17, -112, -126, -126, -126, -126, -126, -126, -124, -57, 153, 416, 482, 465, 395, 284, 176, 93, 0 },
		{0, 0, 0, -1, -9, -39, -106, -126, -126, -126, -126, -126, -126, -65, 101, 336, 457, 482, 477, 382, 248, 122, 83, 0 },
		{0, 0, 0, 1, 2, -29, -88, -126, -126, -126, -126, -124, -77, 78, 279, 439, 480, 483, 475, 367, 229, 111, 49, 0 },
		{0, 2, 8, 34, 53, 41, -12, -126, -126, -126, -75, 8, 101, 237, 415, 478, 484, 481, 446, 355, 226, 121, 53, 0 },
		{7, 30, 54, 94, 142, 165, 179, 92, -36, -13, 94, 207, 331, 439, 481, 482, 482, 468, 420, 333, 219, 133, 75, 0 },
		{17, 61, 99, 148, 216, 273, 311, 290, 270, 196, 322, 424, 485, 485, 485, 481, 465, 431, 379, 300, 159, 115, 83, 0 },
		{15, 63, 111, 157, 227, 291, 364, 399, 429, 448, 485, 485, 485, 485, 483, 442, 410, 364, 283, 50, 59, 63, 57, 0 },
		{2, 36, 101, 149, 178, 232, 295, 367, 441, 479, 485, 482, 468, 441, 414, 355, 311, 274, 173, 67, 3, 0, 0, 0 },
		{0, 10, 60, 97, 99, 96, 168, 272, 338, 387, 415, 412, 390, 345, 291, 229, 194, 165, 131, 70, 16, 0, 0, 0 },
		{0, 0, 2, 32, 42, 61, 119, 206, 264, 288, 320, 314, 278, 228, 178, 93, 75, 74, 72, 49, 17, 0, 0, 0 },
		{0, 0, 0, 2, 11, 40, 107, 176, 190, 200, 226, 213, 131, 116, 106, 47, 22, 15, 16, 10, 0, 0, 0, 0 },
		{0, 0, 0, 0, 0, 25, 74, 104, 108, 121, 151, 122, 68, 76, 91, 46, 0, 0, 0, 0, 0, 0, 0, 0 },
		{0, 0, 0, 0, 0, 0, 0, 0, 44, 64, 94, 80, 33, 40, 68, 34, 0, 0, 0, 0, 0, 0, 0, 0 },
		{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
	}
}
RandomMapGenerator.TerrainArray[Entities.XD_IronPit1] = {
	OffsetX = -6,
	OffsetY = -5,
	PitOffsetX = -75,
	PitOffsetY = 50,
	CenterOffsetX = 100,
	CenterOffsetY = 200,
	TerrainIterLow = {X=-8,Y=-8},
	TerrainIterHigh = {X=20,Y=20},
	WaterLow = {X=4,Y=4},
	WaterHigh ={X=12,Y=12},
	TerrainTypeHigh = 20,
	TerrainTypeCircleSq = 8,
	TerrainTypeTextureList = "DarkMud",
	RemoveEntities = {X=100,Y=200,r=900},
	TerrainHeights = {
		{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
		{0, 0, -5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
		{0, -2, -2, -2, -2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
		{0, -8, -14, -24, -46, -44, -49, -25, 0, 0, 0, 0, 0, 0, 0 },
		{0, -23, -58, -106, -172, -180, -153, -74, 0, 0, 0, 0, 0, 0, 0 },
		{-4, -32, -103, -337, -327, -375, -264, -114, 0, 0, 0, 0, 0, 0, 0 },
		{-5, -36, -109, -308, -357, -412, -296, -122, 0, 0, 0, 0, 0, 0, 0 },
		{-1, -24, -89, -182, -246, -268, -219, -70, 0, 0, 0, 0, 0, 0, 0 },
		{0, -4, -40, -85, -109, -107, -64, 0, 0, 0, 0, 0, 0, 0, 0,},
		{0, 0, 0, -2, -4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
		{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
		{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
		{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
	}
}
RandomMapGenerator.TerrainArray[Entities.XD_SulfurPit1] = {
	OffsetX = -6,
	OffsetY = -5,
	PitOffsetX = -25,
	PitOffsetY = -50,
	CenterOffsetX = 200,
	CenterOffsetY = 200,
	TerrainIterLow = {X=-7,Y=-8},
	TerrainIterHigh = {X=21,Y=20},
	WaterLow = {X=4,Y=4},
	WaterHigh ={X=12,Y=12},
	TerrainTypeHigh = 20,
	TerrainTypeCircleSq = 8,
	TerrainTypeTextureList = "NorthSand",
	RemoveEntities = {X=200,Y=200,r=900},
	TerrainHeights = {
		{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
		{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
		{0, -2, -2, -2, -2, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
		{0, -8, -14, -24, -46, -44, -49, -25, 0, 0, 0, 0, 0, 0 },
		{0, -23, -58, -106, -172, -180, -153, -74, 0, 0, 0, 0, 0, 0 },
		{-4, -32, -103, -337, -327, -375, -264, -114, 0, 0, 0, 0, 0, 0 },
		{-5, -36, -109, -308, -357, -412, -296, -122, 0, 0, 0, 0, 0, 0 },
		{-1, -24, -89, -182, -246, -268, -219, -70, 0, 0, 0, 0, 0, 0 },
		{0, -4, -40, -85, -109, -107, -64, 0, 0, 0, 0, 0, 0, 0 },
		{0, 0, 0, -2, -4, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
		{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
		{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
		{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
	}
}
RandomMapGenerator.TerrainArray[Entities.XD_VillageCenter] = {
	OffsetX = 0,
	OffsetY = 0,
	PitOffsetX = 0,
	PitOffsetY = 0,
	CenterOffsetX = 0,
	CenterOffsetY = 0,
	TerrainIterLow = {X=-9,Y=-5},
	TerrainIterHigh = {X=21,Y=25},
	WaterLow = {X=0,Y=0},
	WaterHigh ={X=1,Y=1},
	TerrainTypeHigh = 0,
	TerrainTypeCircleSq = -1,
	TerrainTypeTextureList = "Rocky",
	RemoveEntities = {X=0,Y=0,r=850},
	MinDistance = 1000,
	NoResource = true,
	TerrainHeights = {
		{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
		{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
		{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
		{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
		{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
		{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
		{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
		{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
		{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
		{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
		{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
		{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
		{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
		{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
		{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
		{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
		{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
		{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
		{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
		{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
		{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
		{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
		{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
	}
}