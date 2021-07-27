SVLib = {}

--Test auf HistoryEdition oder GoldEdition
if XNetwork.Manager_IsNATReady then
	SVLib.HistoryFlag =  1
else
	SVLib.HistoryFlag =  0
end

--Setzt ein Entity unsichtbar/sichtbar
function SVLib.SetInvisibility(_id,_flag)
	if _flag then
		if SVLib.HistoryFlag == 1 then
			Logic.SetEntityScriptingValue(_id, -26, 513)
		elseif SVLib.HistoryFlag == 0 then
			Logic.SetEntityScriptingValue(_id, -30, 513)
		end
	else
		if SVLib.HistoryFlag == 1 then
			Logic.SetEntityScriptingValue(_id, -26, 65793)
		elseif SVLib.HistoryFlag == 0 then
			Logic.SetEntityScriptingValue(_id, -30, 65793)
		end
	end
end

--Gibt zurück ob eine Entity unsichtbar ist
--return true/false
function SVLib.GetInvisibility(_id)
	if SVLib.HistoryFlag == 1 then
		if Logic.GetEntityScriptingValue(_id,-26) == 513 then
			return true
		else
			return false
		end
	elseif SVLib.HistoryFlag == 0 then
		if Logic.GetEntityScriptingValue(_id,-30) == 513 then
			return true
		else
			return false
		end
	end
end

--Setzt die Höhe von Gebäuden in %
function SVLib.SetHightOfBuilding(_id,_float)
	Logic.SetEntityScriptingValue(_id,18,Float2Int(_float))
end

--Gibt die Höhe von Gebäuden zurück in %
--return float
function SVLib.GetHightOfBuilding(_id)
	return Int2Float(Logic.GetEntityScriptingValue(_id,18))
end

--Gibt den Leader eines Soldiers im Trupp zurück
function SVLib.GetLeaderOfSoldier(_SoldierID)
	if SVLib.HistoryFlag == 1 then
		return Logic.GetEntityScriptingValue(_SoldierID, 66)
	elseif SVLib.HistoryFlag == 0 then
		return Logic.GetEntityScriptingValue(_SoldierID, 69)
	end
end

--Setzt die Leben einer Entity. Mehr als maximale HP möglich.
--Funktioniert durch Unverwundbarkeit durch
function SVLib.SetHPOfEntity(_id,_HPNumber)
	Logic.SetEntityScriptingValue(_id,-8,_HPNumber)
end

--Gibt die Leben einer Entity zurück
--return Ganzzahl
function SVLib.GetHPOfEntity(_id)
	return Logic.GetEntityScriptingValue(_id,-8)
end

--Setzt den Index in der Tasklist einer Entity
function SVLib.SetTaskSubIndexNumber(_id,_index)
	if SVLib.HistoryFlag == 1 then
		Logic.SetEntityScriptingValue(_id,-18,_index)
	elseif SVLib.HistoryFlag == 0 then
		Logic.SetEntityScriptingValue(_id,-21,_index)
	end
end

--Gibt den momentanen Index in der Tasklist einer Entity
--return Ganzzahl
function SVLib.GetTaskSubIndexNumber(_id)
	if SVLib.HistoryFlag == 1 then
		return Logic.GetEntityScriptingValue(_id,-18)
	elseif SVLib.HistoryFlag == 0 then
		return Logic.GetEntityScriptingValue(_id,-21)
	end
end

--Setzt die Größe einer Entity in % realtiv zur Normalgröße; Nur das Model, nicht da Blocking
function SVLib.SetEntitySize(_id,_float)
	if SVLib.HistoryFlag == 1 then
		Logic.SetEntityScriptingValue(_id,-29,Float2Int(_float))
	elseif SVLib.HistoryFlag == 0 then
		Logic.SetEntityScriptingValue(_id,-33,Float2Int(_float))
	end
end

--Gibt die Größe einer Entity in % relativ zur Normalgröße zurück
--return float
function SVLib.GetEntitySize(_id)
	if SVLib.HistoryFlag == 1 then
		return Int2Float(Logic.GetEntityScriptingValue(_id,-29))
	elseif SVLib.HistoryFlag == 0 then
		return Int2Float(Logic.GetEntityScriptingValue(_id,-33))
	end
end

--Setzt die Resource, die beim Abbauen erhalten wird (ResourceType = ResourceType.<Resourcenname>)
--Ja, man kann damit z.B. Taler oder Wetterenergie oder Glauben haken.
function SVLib.SetResourceType(_id,_ResourceType)
	Logic.SetEntityScriptingValue(_id,8,_ResourceType)
end

--Gibt den ResourcenTyp der Resource zurück
--return Ganzzahl
function SVLib.GetResourceType(_id)
	return Logic.GetEntityScriptingValue(_id,8)
end

--Setzt die Prozentanzahl welche in der Mitte der Gebäude-Entity sichtbar ist (Forschung, Ausbau, etc)
--float 0 <= _float <= 1
function SVLib.SetPercentageInBuilding(_id,_float)
	Logic.SetEntityScriptingValue(_id,20,Float2Int(_float))
end


--Gibt die Prozentanzeige in der Mitte des Gebäudes bzw. des Balkens unten in der GUI zurück
--return 0 <= float <= 1
function SVLib.GetPercentageAtBuilding(_id)
	return Int2Float(Logic.GetEntityScriptingValue(_id,20))
end

--Setzt die SpielerID einer Entity. Ändert NICHT die EntityID. Farbe der Entity wird nicht verändert, nur Lebensbalkenfarbe
-- _playerID PlayerID 0 <= int <= 8/16(Kimis Server)
-- mcb: verwenden auf eigene gefahr: listen im player object werden nicht aktualisiert, kann zu unvorhergesehenem verhalten führen!
function SVLib.SetPlayerID(_id,_playerID)
	if SVLib.HistoryFlag == 1 then
		return Logic.SetEntityScriptingValue(_id,-44,_playerID)
	else
		return Logic.SetEntityScriptingValue(_id,-52,_playerID)
	end
end

--Gibt den Spieler einer Entity zurück
--return PlayerID 0 <= int <= 8/16(Kimis Server)
function SVLib.GetPlayerID(_id)
	if SVLib.HistoryFlag == 1 then
		return Logic.GetEntityScriptingValue(_id,-44)
	else
		return Logic.GetEntityScriptingValue(_id,-52)
	end
end


--Utility Funktionen

---@diagnostic disable-next-line: lowercase-global
function qmod(a, b)
	return a - math.floor(a/b)*b
end

function Int2Float(num)
	if(num == 0) then
		return 0
	end

	local sign = 1

	if(num < 0) then
		num = 2147483648 + num
		sign = -1
	end

	local frac = qmod(num, 8388608)
	local headPart = (num-frac)/8388608
	local expNoSign = qmod(headPart, 256)
	local exp = expNoSign-127
	local fraction = 1
	local fp = 0.5
	local check = 4194304
	for i = 23, 0, -1 do
		if(frac - check) > 0 then
			fraction = fraction + fp
			frac = frac - check
		end
		check = check / 2
		fp = fp / 2
	end
	return fraction * math.pow(2, exp) * sign
end

---@diagnostic disable-next-line: lowercase-global
function bitsInt(num)
	local t={}
	while num>0 do
		local rest=qmod(num, 2)
		table.insert(t,1,rest)
		num=(num-rest)/2
	end
	table.remove(t, 1)
	return t
end

---@diagnostic disable-next-line: lowercase-global
function bitsFrac(num, t)
	for i = 1, 48 do
		num = num * 2
		if(num >= 1) then
			table.insert(t, 1)
			num = num - 1
		else
			table.insert(t, 0)
		end
		if(num == 0) then
			return t
		end
	end
	return t
end

function Float2Int(fval)
	if(fval == 0) then
		return 0
	end

	local signed = false
	if(fval < 0) then
		signed = true
		fval = fval * -1
	end
	local outval = 0;
	local bits
	local exp = 0
	if fval >= 1 then
		local intPart = math.floor(fval)
		local fracPart = fval - intPart
		bits = bitsInt(intPart)
		exp = table.getn(bits)
		bitsFrac(fracPart, bits)
	else
		bits = {}
		bitsFrac(fval, bits)
		while(bits[1] == 0) do
			exp = exp - 1
			table.remove(bits, 1)
		end
		exp = exp - 1
		table.remove(bits, 1)
	end

	local bitVal = 4194304
	local start = 1

	for bpos = start, 23 do
		local bit = bits[bpos]
		if(not bit) then
			break;
		end

		if(bit == 1) then
			outval = outval + bitVal
		end
		bitVal = bitVal / 2
	end

	outval = outval + (exp+127)*8388608

	if(signed) then
		outval = outval - 2147483648
	end

	return outval;
end