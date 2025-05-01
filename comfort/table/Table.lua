-----------------------------------------------------------------------------------------------------------------------------------
-- table extensions
-- author: RobbiTheFox
-- current maintainer: RobbiTheFox
-- Version: v1.0
-----------------------------------------------------------------------------------------------------------------------------------

function table_init()

-- compares two tables
--
-- _checksimple can be set to true to save computation time, but can result in false positives, if _b contains more keys than _a
---@param _a table
---@param _b table
---@param _checksimple? boolean
---@return boolean
function table.isequal(_a, _b, _checksimple)
	if type(_a) ~= "table" then
		return _a == _b
	end
	for k, v in pairs(_a) do
		if type(v) == "table" then
			if not table.isequal(v, _b[k], _checksimple) then
				return false
			end
		else
			if _b[k] ~= v then
				return false
			end
		end
	end
	if _checksimple then
		return true
	end
	return table.isequal(_b, _a, true)
end
-----------------------------------------------------------------------------------------------------------------------------------
-- adds a unique value to _table
---@param _table table
---@param _value any
function table.addunique(_table, _value)
    for _, v in pairs(_table) do
        if table.isequal(v, _value) then
            return
        end
    end
    table.insert(_table, _value)
end
-----------------------------------------------------------------------------------------------------------------------------------
-- adds a unique value at the end of _table
---@param _table table
---@param _value any
function table.adduniquei(_table, _pos, _value)
	local value = _value or _pos
    for i = 1, table.getn(_table) do
        if table.isequal(_table[i], value) then
            return
        end
    end
    table.insert(_table, _pos, _value)
end
-----------------------------------------------------------------------------------------------------------------------------------
-- returns total amount of elemnts in _table
---@param _table table
---@return number
function table.getnumberofelements(_table)
	local n = 0
	for k, v in pairs(_table) do
		n = n + 1
	end
	return n
end
-----------------------------------------------------------------------------------------------------------------------------------
-- returns a random element of _table
--
-- set _async true in MP games, if the routine is called only client side, to not mess up math.random
---@param _table table
---@param _async? boolean
---@return any
function table.getrandomelement(_table, _async)
	local numberofelements = table.getnumberofelements(_table)
	local randomelement = _async and (math.random2(numberofelements)) or math.random(numberofelements)
	local n = 0
	for _, v in pairs(_table) do
		n = n + 1
		if n == randomelement then
			return v
		end
	end
end 
-----------------------------------------------------------------------------------------------------------------------------------
-- returns a random element with numeric key of _table
--
-- set _async true in MP games, if the routine is called only client side, to not mess up math.random
---@param _table table
---@param _async? boolean
---@return any
function table.getrandomelementi(_table, _async)
	return _table[_async and (math.random2(table.getn(_table))) or math.random(table.getn(_table))]
end
-----------------------------------------------------------------------------------------------------------------------------------
-- replace all occurances of an element in _table
---@param _table table
---@param _oldvalue any
---@param _newvalue any
function table.replace(_table, _oldvalue, _newvalue)
	for k, v in pairs(_table) do
		if v == _oldvalue then
			_table[k] = _newvalue
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------
-- replace all occurances of an element with numeric key in _table
---@param _table table
---@param _oldvalue any
---@param _newvalue any
function table.replacei(_table, _oldvalue, _newvalue)
	for i = 1, table.getn(_table) do
		if _table[i] == _oldvalue then
			_table[i] = _newvalue
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------
-- get a key assigned with _value in _table
---@param _table table
---@param _value any
---@return any|nil
function table.find(_table, _value)
	for k, v in pairs(_table) do
		if v == _value then
			return k
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------
-- get nth key assigned with _value in _table
---@param _table table
---@param _value any
---@return integer|nil
function table.findi(_table, _value, _n)
	_n = _n or 1
	local n = 1
	for i = 1, table.getn(_table) do
		if _table[i] == _value then
			if n == _n then
				return i
			else
				n = n + 1
			end
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------
-- copies a table including sub tables optional into _target
---@param _table table
---@param _target? table
---@return table
function table.copy(_table, _target)
	if type(_table) ~= "table" then
        return _table
    end
	_target = _target or {}
    for k, v in pairs(_table) do
        _target[k] = table.copy(v)
    end
    local metatable = getmetatable(_table)
    if metatable then
        setmetatable(_target, table.copy(metatable))
    end
	return _target
end
-----------------------------------------------------------------------------------------------------------------------------------
-- merges _table2 into _table1
--
-- table values dont get copied but are passed per reference
---@param _table1 table
---@param _table2 table
function table.merge(_table1, _table2)
	for k, v in pairs(_table2) do
		_table1[k] = v
	end
end
-----------------------------------------------------------------------------------------------------------------------------------
-- merges values of numeric keys from _table2 into _table1
--
-- table values dont get copied but are passed per reference
---@param _table1 table
---@param _table2 table
function table.mergei(_table1, _table2)
	for i = 1, table.getn(_table2) do
		_table1[i] = _table2[i]
	end
end
-----------------------------------------------------------------------------------------------------------------------------------
math.randomnumber = math.random()
-- works same as math.random but is only client side
---@param _Min? number
---@param _Max? number
---@return number
function math.random2(_Min, _Max)

    local systemtime = XGUIEng.GetSystemTime()
    math.randomnumber = math.randomnumber + (systemtime - math.floor(systemtime))
    math.randomnumber = math.randomnumber - math.floor(math.randomnumber)

    if not _Min then
        return math.randomnumber
    end

    local min = (_Max and _Min) or 1
    local max = _Max or _Min or 1

    return math.floor(math.randomnumber * (max + 1 - min) + min)
end

end

table_Mission_OnSaveGameLoaded = Mission_OnSaveGameLoaded
function Mission_OnSaveGameLoaded()
	table_Mission_OnSaveGameLoaded()
	table_init()
end
table_init()