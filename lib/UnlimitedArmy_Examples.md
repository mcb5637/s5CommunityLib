# Allgemein

- VS Code + lua plugin benutzen, alle felder/methoden sollen dokumentation haben
- eventuell werden @type annotationen für variablen benötigt

# Wegwerf-Armee

```lua
StartSimpleJob(function()
    if Counter.Tick2("attack_army", 100) then
        -- erstellt eine UA
        local ua = UnlimitedArmy:New{
			Player = 2,
			Area = 4000,
			AutoDestroyIfEmpty = true,
	        IgnoreFleeing = true,
		}

        -- spawnt truppen für die UA
		local p = GetPosition("SpawnPos")
		for i=1,10 do
			ua:CreateLeaderForArmy(Entities.PU_LeaderPoleArm4, 8, p, VERYHIGH_EXPERIENCE)
		end

        --lässt die UA angreifen
		ua:AddCommandAttackNearestTarget()
    end
end)
```

wenn alle truppen besiegt sind, räumt die UA sich selbst auf
wichtig dafür: das UA object nicht sonst irgendwo speichern, ansonsten bleibt die tote UA im speicher und kann nicht aufgeräumt werden

# Verteidiger mit Spawner

```lua
-- erstellt eine UA
local ua = UnlimitedArmy:New{
	Player = 2,
	Area = 4000,
	AutoDestroyIfEmpty = true,
	IgnoreFleeing = true,
}

-- erstellt einen spawn generator für die UA
UnlimitedArmySpawnGenerator:New(ua, {
	ArmySize = 10, -- zielgröße der ua
	LeaderDesc = {
        -- ein varg, wiederholt sich nicht
		{
			LeaderType = Entities.CU_Barbarian_Hero, SoldierNum = 0, SpawnNum = 1, Looped = false,
		},
        -- barbarenkrieger, wiederholt sich
		{
			LeaderType = Entities.CU_Barbarian_LeaderClub1, SoldierNum = 4, SpawnNum = 4, Looped = true,
		}
	},
	Generator = "Tower1", -- wen dieses entity tot ist, entfernt sich der spawner selbst
	Position = GetPosition("Tower1_Entry"),
	SpawnCounter = 100,
	SpawnLeaders = 4,
	FreeArea = 5000, -- wenn gegner zu nahe am generator sind, wird der spawn pausiert
	RefillSoldiers = true,
})

-- die UA bleibt beim generator und verteidigt ihn
ua:AddCommandDefend(GetPosition("Tower1_Entry"), 5000, true, 7500)
```


# Angreifer mit Spawner

```lua
local ua = UnlimitedArmy:New{
	Player = 2,
	Area = 4000,
	AutoDestroyIfEmpty = true,
	IgnoreFleeing = true,
}
UnlimitedArmySpawnGenerator:New(ua, {
	ArmySize = 10,
	LeaderDesc = {
		{
			LeaderType = Entities.CU_Barbarian_LeaderClub1, SoldierNum = 4, SpawnNum = 4, Looped = true,
		},
		{
			LeaderType = Entities.CU_BanditLeaderBow1, SoldierNum = 4, SpawnNum = 4, Looped = true,
		}
	},
	Generator = "Tower1",
	Position = GetPosition("Tower1_Entry"),
	SpawnCounter = 100,
	SpawnLeaders = 4,
	FreeArea = 5000,
	RefillSoldiers = true,
})

-- commands für die ua
ua:AddCommandWaitForSpawnerFull(true) -- warte bis die ua voll ist
ua:AddCommandSetSpawnerStatus(false, true) -- stelle spawner ab
ua:AddCommandMove(GetPosition("waypoint1"), true) -- setze move-ziel
ua:AddCommandWaitForIdle(true) -- warte bis die ua da ist (und kein gegner in reichweite)
ua:AddCommandMove(GetPosition("waypoint2"), true)
ua:AddCommandWaitForIdle(true)
ua:AddCommandMove(GetPosition("playerhq"), true)
ua:AddCommandWaitForIdle(true)
ua:AddCommandAttackNearestTarget(nil, true) -- greife alles an, was feindlich ist, command ist erst zuende, wenn die ua tot ist
ua:AddCommandMove(GetPosition("Tower1_Entry"), true) -- move zurück (ua ist leer, deswegen ist der move sofort fertig)
ua:AddCommandSetSpawnerStatus(true, true) -- stelle den spawner wieder an
-- alle commands sind looped, der nächste ist wieder AddCommandWaitForSpawnerFull
```

# Expeditionen


```lua
local ua = UnlimitedArmy:New{
	Player = 2,
	Area = 4000,
	AutoDestroyIfEmpty = true,
	IgnoreFleeing = true,
}
UnlimitedArmyRecruiter:New(ua, {
	ArmySize = 10,
	-- gebäude in denen gekauft wird
	Buildings = {GetID("barracks1"), GetID("archery1"), GetID("foundry")},
	-- was gekauft wird
	UCats = {
		{
			UCat = UpgradeCategories.LeaderSword, SpawnNum = 5, Looped = true,
		},
		{
			UCat = UpgradeCategories.LeaderBow, SpawnNum = 5, Looped = true,
		},
		{
			UCat = UpgradeCategories.Cannon4, SpawnNum = 1, Looped = true,
		}
	},
	ReorderAllowed = true, -- wenn ein gebäude voll ist, ucat nach hinten schieben
	ResCheat = true, -- keine resourcenkosten (dz platz ist aber trotzdem benötigt)
})
-- sammelt truppen in einer def army
-- wenn genug truppen angesammelt sind, schickt eine expedition los
ua:AddCommandRallypoint(function(ex, _, parent)
	-- aufgerufen, wenn eine expedition ausgesendet wird, um die commandqueue zu füllen
	-- ex ist die expedition, parent die rallypoint ua
	ex:AddCommandMove(GetPosition("mine_"..GetRandom(5))) -- bewege zu einer ziel pos
	ex:AddCommandWaitForIdle()
	ex:AddCommandMove(GetPosition("home_pos")) -- bewege zurück
	ex:AddCommandWaitForIdle()
	ex:AddCommandTransferTroops(parent) -- übrige truppen zurück zur rallypoint ua
end, 5, 1, true).Cmd = UnlimitedArmy.CreateCommandDefend(GetPosition("home_pos"), 5000, true, 7500)
-- command für die rallypoint ua (einzelner command, der jeden tick ausgeführt wird, keine volle queue)
```
