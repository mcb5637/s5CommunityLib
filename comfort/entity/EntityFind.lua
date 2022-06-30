mcbPacker.require("s5CommunityLib/fixes/TriggerFix")

--- author:mcb		current maintainer:mcb		v3.0b
--- dient zum iterieren über entities auf der map.
--- wenn CppLogic oder Kimichuras dlls vorhanden sind, empfehle ich diese zu verenden, da sie wesentlich schneller sind.
---
--- EntityFind.Iterator(...)							Erstellt einen Iterator, der mit einer for loop verwendet werden kann.  
--- EntityFind.GetEntities(...)							Erstellt ein table mit alen entities.  
---
--- EntityFind.Predicate.OfPlayer(pl)					Erstellt einen test, ob ein entity einem spieler gehört.  
--- EntityFind.Predicate.OfType(t)						Erstellt einen test, ob ein entity einen typ hat.
--- EntityFind.Predicate.InCircle(p, r)					Erstellt einen test, ob ein entity in einem gebiet ist.
---
--- Benötigt:  
--- - TriggerFix
EntityFind = {baseIdToId={}}

function EntityFind.OnCreated()
	local id = Event.GetEntityID()
	local base = id - math.floor(id/65536)*65536
	EntityFind.baseIdToId[base] = id
end
Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_CREATED, nil, "EntityFind.OnCreated", 1)

function EntityFind.Discover()
	local baseid = 1
	while not Logic.IsEntityDestroyed(baseid + 65536) do
		EntityFind.baseIdToId[baseid] = baseid + 65536
		baseid = baseid + 1
	end
end
EntityFind.Discover()

--- Iterator über entities.
--- nicht speichern, enthält upvalues
---@param ... fun(id:number):boolean
---@return fun():number
function EntityFind.Iterator(...)
	local base = 0
	local function pred(id)
		for _,f in ipairs(arg) do
			if not f(id) then
				return false
			end
		end
		return true
	end
	local function iter()
		base = base + 1
		local id = EntityFind.baseIdToId[base]
		if id == nil then
			return nil
		end
		if Logic.IsEntityDestroyed(id) then
			return iter()
		end
		if not pred(id) then
			return iter()
		end
		return id
	end
	return iter
end

--- table mit entities.
--- nicht speichern, enthält upvalues
---@param ... fun(id:number):boolean
---@return number[]
function EntityFind.GetEntities(...)
	local t = {}
---@diagnostic disable-next-line: param-type-mismatch
	for id in EntityFind.Iterator(unpack(arg)) do
		table.insert(t, id)
	end
	return t
end

EntityFind.Predicate = {}

---prüft auf einen spieler
---@param pl number
---@return fun(id:number):boolean
function EntityFind.Predicate.OfPlayer(pl)
	return function(id)
		return GetPlayer(id) == pl
	end
end

---prüft auf einen entitytyp
---@param t number
---@return fun(id:number):boolean
function EntityFind.Predicate.OfType(t)
	return function(id)
		return Logic.GetEntityType(id) == t
	end
end

---prüft auf ein gebiet
---@param p Position
---@param r number
---@return fun(id:number):boolean
function EntityFind.Predicate.InCircle(p, r)
	r = r * r
	return function(id)
		local e = GetPosition(id)
		return ((e.X - p.X)^2 + (e.Y - p.Y)^2) <= r
	end
end
