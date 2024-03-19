gvTypesToTrack = {}
PlayerUnits = {}
PoisonPos = {}
Giftreiter = {}
PoisonCounter = 1

function GetAllEntitiesOfPlayerOfType(_player, _type)
    local units = {}
    local n, first = Logic.GetPlayerEntities(_player, _type, 1)
    if n > 0 then
        local entity = first
        repeat
            table.insert(units, entity)
            entity = Logic.GetNextEntityOfPlayerOfType(entity)
        until entity == first
    end
    
    return units
end

for k,v in pairs(Entities) do
        if (string.find(k, "CU_", 1, true) or string.find(k, "PU_", 1, true) or string.find(k, "PV_",1,true)) and not string.find(k, "Soldier", 1, true) and not string.find(k, "Hawk",1,true) and not string.find(k,"Hero2_",1,true) then
            gvTypesToTrack[v] = true
        end
end
	
for type, _ in pairs(gvTypesToTrack) do
	for _playerID = 1, (CUtil and 16) or 8, 1 do
		local units = GetAllEntitiesOfPlayerOfType(_playerID, type);
		for i = 1,table.getn(units) do
			PlayerUnits[units[i]] = true;
		end
	end
end

function PXEntityCreated()
	local id = Event.GetEntityID()
	local type = Logic.GetEntityType(id)
	if gvTypesToTrack[type] then
		PlayerUnits[id] = true
	end
end

function PXEntityDestroied()
    local id = Event.GetEntityID()
    if PlayerUnits[id] then
       PlayerUnits[id] = nil
    end
end

EntityCreatedTrigger = Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_CREATED,nil,"PXEntityCreated",1,nil,nil)
EntityDestroiedTrigger = Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_DESTROYED,nil,"PXEntityDestroied",1,nil,nil)

function PoisenThrower()
	for j = table.getn(PoisonPos),1,-1 do
		local giftspot = PoisonPos[j]
		if giftspot.Dauer > 0 then
			if Logic.IsPlayerEntityInArea(1, giftspot.X, giftspot.Y, 600, 2) == 1 or Logic.IsPlayerEntityInArea(8, giftspot.X, giftspot.Y, 600, 2) == 1 then
				for id,_ in pairs(PlayerUnits) do
					if GetSimpleDistanceSquared(giftspot,GetPosition(id)) < 360000 then
						if Logic.IsLeader(id) == 1 then
							if bombriders[id] then
								bobmersHP[id] = bobmersHP[id] - (500*0.33)
								MakeVulnerable(id)
								SetHealth(id,math.floor(((bobmersHP[id]/500)*100)+0.5))
								MakeInvulnerable(id)
							else
								local soldiers = {Logic.GetSoldiersAttachedToLeader(id)}
								local dmg = (soldiers[1])*(Logic.GetEntityMaxHealth(soldiers[2])*0.33)+Logic.GetEntityMaxHealth(id)*0.33
								if soldiers[1] > 0 then
									local changedDmg
									for i = soldiers[1]+1,2,-1 do
										local currentHP = Logic.GetEntityHealth(soldiers[i])
										changedDmg = math.min(currentHP,dmg)
										Logic.HurtEntity(soldiers[i],changedDmg)
										dmg = dmg - changedDmg
										if dmg <= 0 then
											break;
										end
									end
								end
								Logic.HurtEntity(id,dmg)
							end
						else
							Logic.HurtEntity(id,Logic.GetEntityMaxHealth(id)*0.33)
						end
					end
				end
			end
			giftspot.Dauer = giftspot.Dauer - 1
		else
			table.remove(PoisonPos,j)
		end
	end
	for j = table.getn(Giftreiter),1,-1 do
		if IsAlive(Giftreiter[j].ID) then
			if Giftreiter[j].PoisonCounter <= 0 then
				local _x,_y = Logic.GetEntityPosition(Giftreiter[j].ID)
				table.insert(PoisonPos, {X=_x;Y=_y;Dauer=20})
				Logic.CreateEffect(GGL_Effects.FXKalaPoison,_x,_y,0)

				Giftreiter[j].PoisonCounter = 2
			else
				Giftreiter[j].PoisonCounter = PoisonCounter - 1
			end
		else
			table.remove(Giftreiter,j)
		end
	end
	return false
end

function GetSimpleDistanceSquared(_pos1,_pos2)
	return (_pos1.X - _pos2.X)^2 + (_pos1.Y - _pos2.Y)^2
end

PoisenReiterTriggerID = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND,nil,"PoisenThrower",1,nil,nil)
