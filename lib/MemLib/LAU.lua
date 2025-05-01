--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
-- MemLib.LAU - large address unit
-- author: RobbiTheFox, Fritz98
-- current maintainer: RobbiTheFox
-- Version: v1.0
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
if mcbPacker then
    mcbPacker.require("s5CommunityLib/Lib/MemLib/MemLib")
    mcbPacker.require("s5CommunityLib/fixes/metatable")
else
	if not MemLib then Script.Load("maps\\user\\EMS\\tools\\s5CommunityLib\\lib\\MemLib\\MemLib.lua") end
    if not metatable then Script.Load("maps\\user\\EMS\\tools\\s5CommunityLib\\fixes\\metatable.lua") end
end
--------------------------------------------------------------------------------
MemLib.LAU = {}
MemLib.LAU.mt = {}
--------------------------------------------------------------------------------
function MemLib.LAU.mt.__add(_A, _B)
    if type(_B) == "number" then
        _B = MemLib.LAU.ToTable(_B)
    end
    return MemLib.LAU.AddTable(_A, _B)
end
--------------------------------------------------------------------------------
function MemLib.LAU.mt.__sub(_A, _B)
    if type(_B) == "number" then
        _B = MemLib.LAU.ToTable(_B)
    end
    return MemLib.LAU.SubTable(_A, _B)
end
--------------------------------------------------------------------------------
function MemLib.LAU.mt.__div(_A, _Unused)
    local a, b = MemLib.LAU.DivTable4_Inplace(_A)
    return a, b
end
--------------------------------------------------------------------------------
MemLib.LAU.OctToBin = {
    ["0"] = {0, 0, 0},
    ["1"] = {0, 0, 1},
    ["2"] = {0, 1, 0},
    ["3"] = {0, 1, 1},
    ["4"] = {1, 0, 0},
    ["5"] = {1, 0, 1},
    ["6"] = {1, 1, 0},
    ["7"] = {1, 1, 1},
}
--------------------------------------------------------------------------------
---@param _Number integer
---@return table
function MemLib.LAU.ToTable(_Number)
    local NumberOctalString = string.format("%011o", _Number)
    local NumberBinaryTable = {}
    for i = 1, 11 do
        local BinCode = MemLib.LAU.OctToBin[string.sub(NumberOctalString, i, i)]
        for j = 1, 3 do
            NumberBinaryTable[(i - 1) * 3 + j] = BinCode[j]
        end
    end
    table.remove(NumberBinaryTable, 1)
    metatable.set(NumberBinaryTable, MemLib.LAU.mt)
    return NumberBinaryTable
end
--------------------------------------------------------------------------------
---@param _Table table
---@return table
function MemLib.LAU.CopyTable(_Table)
    local copy = {}
    for i = 1, 32 do
        copy[i] = _Table[i]
    end
    return copy
end
--------------------------------------------------------------------------------
---@param _Table table
---@return integer
function MemLib.LAU.ToNumber(_Table)
    if _Table[1] == 1 then
        local Table2C = MemLib.LAU.TwosComplement(_Table)
        return -(tonumber(table.concat(Table2C), 2))
    else
        return tonumber(table.concat(_Table), 2)
    end
end
--------------------------------------------------------------------------------
---@param _Table table
---@return integer
function MemLib.LAU.ToUnsigned(_Table)
    return tonumber(table.concat(_Table), 2)
end
--------------------------------------------------------------------------------
MemLib.LAU.PowerOf2s = {}
for i = 1, 32 do
    table.insert(MemLib.LAU.PowerOf2s, math.floor(math.pow(2, 32-i)))
end
MemLib.LAU.PowerOf2s[1] = -MemLib.LAU.PowerOf2s[1]
---@param _Table table
---@return integer
function MemLib.LAU.ToNumberWithPreciseFPU(_Table)
    MemLib.ArmPreciseFPU()
    MemLib.SetPreciseFPU()
    local Sum = 0
    for i = 1, 32 do
        if _Table[i] == 1 then
            Sum = Sum + MemLib.LAU.PowerOf2s[i]
        end
    end
    MemLib.DisarmPreciseFPU()
    return Sum
end
--------------------------------------------------------------------------------
---@param _A table
---@param _B table
---@return table
function MemLib.LAU.AddTable(_A, _B)
    local c = 0
    local Sum = {}
    for i = 32, 1, -1 do
        local Digit = _A[i] + _B[i] + c
        Sum[i] = math.mod(Digit, 2)
        c = math.floor(Digit / 2)
    end
    metatable.set(Sum, MemLib.LAU.mt)
    return Sum
end
--------------------------------------------------------------------------------
---@param _A table
---@return table
function MemLib.LAU.TwosComplement(_A)
    local Complement = {}
    for i = 1, 32 do
        Complement[i] = 1 - _A[i]
    end
    Complement = MemLib.LAU.AddTable(Complement, {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1})
    metatable.set(Complement, MemLib.LAU.mt)
    return Complement
end
--------------------------------------------------------------------------------
---@param _A table
---@param _B table
---@return table
function MemLib.LAU.SubTable(_A, _B)
    local result = MemLib.LAU.AddTable(_A, MemLib.LAU.TwosComplement(_B))
    metatable.set(result, MemLib.LAU.mt)
    return result
end
--------------------------------------------------------------------------------
---@param _A table
---@return table
---@return integer
function MemLib.LAU.DivTable4_Inplace(_A)
    local remainder = _A[32] + 2 * _A[31]
    for i = 32, 3, -1 do
        _A[i] = _A[i-2]
    end
    _A[2] = _A[1]
    return _A, remainder
end
--------------------------------------------------------------------------------
-- bit opertaions
--------------------------------------------------------------------------------
---@param _A table
---@param _B table
---@return table
function MemLib.LAU.And(_A, _B)
    local c = {}
    for i = 1, 32 do
        if _A[i] == 1 and _B[i] == 1 then
            c[i] = 1
        else
            c[i] = 0
        end
    end
    return c
end
--------------------------------------------------------------------------------
---@param _N table
---@param _A table
---@return table
function MemLib.LAU.LRotate(_N, _A)
    local b = {}
    for i = 1, 32 do
        local n = i + _N
        if n > 32 then
            n = n - 32
        end
        b[i] = _A[n]
    end
    return b
end
--------------------------------------------------------------------------------
---@param _N table
---@param _A table
---@return table
function MemLib.LAU.LShift(_N, _A)
    local b = {}
    for i = 1, 32 do
        b[i] = _A[i + _N] or 0
    end
    return b
end
--------------------------------------------------------------------------------
---@param _A table
---@return table
function MemLib.LAU.Not(_A)
    local b = {}
    for i = 1, 32 do
        b[i] = 1 - _A[i]
    end
    return b
end
--------------------------------------------------------------------------------
---@param _A table
---@param _B table
---@return table
function MemLib.LAU.Or(_A, _B)
    local c = {}
    for i = 1, 32 do
        if _A[i] == 1 or _B[i] == 1 then
            c[i] = 1
        else
            c[i] = 0
        end
    end
    return c
end
--------------------------------------------------------------------------------
---@param _N table
---@param _A table
---@return table
function MemLib.LAU.RRotate(_N, _A)
    local b = {}
    for i = 1, 32 do
        local n = i - _N
        if n < 1 then
            n = n + 32
        end
        b[i] = _A[n]
    end
    return b
end
--------------------------------------------------------------------------------
---@param _N table
---@param _A table
---@return table
function MemLib.LAU.RShift(_N, _A)
    local b = {}
    for i = 1, 32 do
        b[i] = _A[i - _N] or 0
    end
    return b
end
--------------------------------------------------------------------------------
---@param _A table
---@param _B table
---@return table
function MemLib.LAU.Xor(_A, _B)
    local c = {}
    for i = 1, 32 do
        if _A[i] ~= _B[i] then
            c[i] = 1
        else
            c[i] = 0
        end
    end
    return c
end
--------------------------------------------------------------------------------
MemLib.LAU.Mission_OnSaveGameLoaded = Mission_OnSaveGameLoaded
function Mission_OnSaveGameLoaded()
	MemLib.LAU.Mission_OnSaveGameLoaded()
    MemLib.LAU.OctToBin = {
        ["0"] = {0, 0, 0},
        ["1"] = {0, 0, 1},
        ["2"] = {0, 1, 0},
        ["3"] = {0, 1, 1},
        ["4"] = {1, 0, 0},
        ["5"] = {1, 0, 1},
        ["6"] = {1, 1, 0},
        ["7"] = {1, 1, 1},
    }
end