--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
-- MemLib.SV
-- author: Kantelo, RobbiTheFox
-- current maintainer: RobbiTheFox
-- Version: v1.0
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
if mcbPacker then
    mcbPacker.require("s5CommunityLib/Lib/MemLib/MemLib")
    mcbPacker.require("s5CommunityLib/Lib/MemLib/LAU")
    mcbPacker.require("s5CommunityLib/Comfort/Number/IntFloatConversion")
else
	if not MemLib then Script.Load("maps\\user\\EMS\\tools\\s5CommunityLib\\lib\\MemLib\\MemLib.lua") end
	MemLib.Load("LAU", "Comfort/Number/IntFloatConversion")
end
--------------------------------------------------------------------------------
MemLib.SV = {}
MemLib.SV.FF = MemLib.LAU.ToTable(255)
--------------------------------------------------------------------------------
-- setup address entity
--------------------------------------------------------------------------------
function MemLib_SV_InitAddressEntity()
    if MemLib.SV.AddressEntity then
        Logic.DestroyEntity(MemLib.SV.AddressEntity)
    end
    MemLib.SV.AddressEntity = Logic.CreateEntity(Entities.CU_Sheep, 100, 100, 0, CNetwork and 17 or 8)
    function MemLib_SV_InitAddressEntityJob(_X, _Y)
        local entityAddress = Logic.GetEntityScriptingValue(MemLib.SV.AddressEntity, 67)
        if entityAddress < 1 then
            Display.SetRenderFogOfWar(0)
            Camera.ScrollSetLookAt(100, 100)
            return
        else
            local entityLargeAddress = MemLib.LAU.ToTable(entityAddress)
            MemLib.SV.AddressOffset = MemLib.LAU.ToNumber(entityLargeAddress + 232)
            Display.SetRenderFogOfWar(1)
            Camera.ScrollSetLookAt(_X, _Y)

            MemLib.FPU = nil
            MemLib.Load("FPU")

            return true
        end
    end
    Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN, nil, "MemLib_SV_InitAddressEntityJob", 1, nil, {Camera.ScrollGetLookAt()})
    Display.SetRenderFogOfWar(0)
    Camera.ScrollSetLookAt(100, 100)
end
--------------------------------------------------------------------------------
-- setup memory read/write
--------------------------------------------------------------------------------
---@param _Address integer
---@return integer
function MemLib.SV.AddressGetInt(_Address)

    MemLib.ArmPreciseFPU()
    MemLib.SetPreciseFPU()
    local offset = _Address - MemLib.SV.AddressOffset
    local alignedOffset, byteOffset = math.floor(offset / 4), math.mod(offset, 4)

    if byteOffset == 0 then
        local sv = Logic.GetEntityScriptingValue(MemLib.SV.AddressEntity, alignedOffset)
        MemLib.DisarmPreciseFPU()
        return sv
    else
        local alignedOffset1 = alignedOffset
        local alignedOffset2 = alignedOffset1 + 1

        if byteOffset < 0 then
            byteOffset = byteOffset + 4 -- 4 - (-byteOffset)
        end
        MemLib.DisarmPreciseFPU()

        local value1 = Logic.GetEntityScriptingValue(MemLib.SV.AddressEntity, alignedOffset1)
        local value2 = Logic.GetEntityScriptingValue(MemLib.SV.AddressEntity, alignedOffset2)

        value1 = MemLib.LAU.RShift(byteOffset * 8, MemLib.LAU.ToTable(value1))
        value2 = MemLib.LAU.LShift((4 - byteOffset) * 8, MemLib.LAU.ToTable(value2))
        return MemLib.LAU.ToNumberWithPreciseFPU(MemLib.LAU.Or(value1, value2))
    end
end
--------------------------------------------------------------------------------
---@param _Address integer
---@param _Value integer
function MemLib.SV.AddressSetInt(_Address, _Value)

    MemLib.ArmPreciseFPU()
    MemLib.SetPreciseFPU()
    local offset = _Address - MemLib.SV.AddressOffset
    local alignedOffset, byteOffset = math.floor(offset / 4), math.mod(offset, 4)

    if byteOffset == 0 then
        MemLib.DisarmPreciseFPU()
        Logic.SetEntityScriptingValue(MemLib.SV.AddressEntity, alignedOffset, _Value)
    else
        local alignedOffset1 = alignedOffset
        local alignedOffset2 = alignedOffset1 + 1
        if byteOffset < 0 then
            byteOffset = byteOffset + 4
        end
        MemLib.DisarmPreciseFPU()

        local orig1 = Logic.GetEntityScriptingValue(MemLib.SV.AddressEntity, alignedOffset1)
        local orig2 = Logic.GetEntityScriptingValue(MemLib.SV.AddressEntity, alignedOffset2)

        orig1, orig2 = MemLib.LAU.ToTable(orig1), MemLib.LAU.ToTable(orig2)
        orig1 = MemLib.LAU.LShift((4 - byteOffset) * 8, orig1)
        orig1 = MemLib.LAU.RShift((4 - byteOffset) * 8, orig1)
        orig2 = MemLib.LAU.RShift(byteOffset * 8, orig2)
        orig2 = MemLib.LAU.LShift(byteOffset * 8, orig2)

        local value = MemLib.LAU.ToTable(_Value)
        local value1 = MemLib.LAU.LShift(byteOffset * 8, value)
        local value2 = MemLib.LAU.RShift((4 - byteOffset) * 8, value)
        value1 = MemLib.LAU.Or(orig1, value1)
        value2 = MemLib.LAU.Or(orig2, value2)

        Logic.SetEntityScriptingValue(MemLib.SV.AddressEntity, alignedOffset1, MemLib.LAU.ToNumberWithPreciseFPU(value1))
        Logic.SetEntityScriptingValue(MemLib.SV.AddressEntity, alignedOffset2, MemLib.LAU.ToNumberWithPreciseFPU(value2))
    end
end
--------------------------------------------------------------------------------
---@param _Address integer
---@return integer
function MemLib.SV.AddressGetByte(_Address)

    MemLib.ArmPreciseFPU()
    MemLib.SetPreciseFPU()
    local offset = _Address - MemLib.SV.AddressOffset
    local alignedOffset, byteOffset = math.floor(offset / 4), math.mod(offset, 4)

    if byteOffset < 0 then
        byteOffset = byteOffset + 4
    end
    MemLib.DisarmPreciseFPU()

    local value = Logic.GetEntityScriptingValue(MemLib.SV.AddressEntity, alignedOffset)
    value = MemLib.LAU.RShift(byteOffset * 8, MemLib.LAU.ToTable(value))
    return MemLib.LAU.ToNumberWithPreciseFPU(MemLib.LAU.And(value, MemLib.SV.FF))
end
--------------------------------------------------------------------------------
---@param _Address integer
---@param _Value integer
function MemLib.SV.AddressSetByte(_Address, _Value)

    MemLib.ArmPreciseFPU()
    MemLib.SetPreciseFPU()
    local offset = _Address - MemLib.SV.AddressOffset
    local alignedOffset, byteOffset = math.floor(offset / 4), math.mod(offset, 4)

    if byteOffset < 0 then
        byteOffset = byteOffset + 4
    end
    MemLib.DisarmPreciseFPU()

    local orig = Logic.GetEntityScriptingValue(MemLib.SV.AddressEntity, alignedOffset)

    local mask = MemLib.LAU.Not(MemLib.LAU.LShift(byteOffset * 8, MemLib.SV.FF))
    orig = MemLib.LAU.And(MemLib.LAU.ToTable(orig), mask)
    local value = MemLib.LAU.LShift(byteOffset * 8, MemLib.LAU.And(MemLib.LAU.ToTable(_Value), MemLib.SV.FF))
    value = MemLib.LAU.Or(orig, value)

    Logic.SetEntityScriptingValue(MemLib.SV.AddressEntity, alignedOffset, MemLib.LAU.ToNumberWithPreciseFPU(value))
end
--------------------------------------------------------------------------------
-- setup userdata
--------------------------------------------------------------------------------
MemLib.SV.mt = {}
--------------------------------------------------------------------------------
function MemLib.SV.mt.__index(_Table, _Key)
    if type(_Key) == "number" then
        local address = _Table:GetInt()
        MemLib.ArmPreciseFPU()
        MemLib.SetPreciseFPU()
        address = address + (_Key * 4)
        MemLib.DisarmPreciseFPU()
        return MemLib.SV.New(nil, address)
    end
end
--------------------------------------------------------------------------------
---@param _Value integer?
---@param _Address integer?
---@return table
function MemLib.SV.New(_Value, _Address)

    local userdata = {
        Address = _Address,
        Value = _Value,
    }
    metatable.set(userdata, MemLib.SV.mt)

    function userdata:GetInt()
        return self.Value and self.Value or MemLib.SV.AddressGetInt(self.Address)
    end

    function userdata:SetInt(_Value)
        if self.Address then
            MemLib.SV.AddressSetInt(self.Address, _Value)
        end
    end

    function userdata:GetFloat()
        return Int2Float(self:GetInt())
    end

    function userdata:SetFloat(_Value)
        self:SetInt(Float2Int(_Value))
    end

    function userdata:GetByte(_Offset)
        _Offset = _Offset or 0

        MemLib.ArmPreciseFPU()
        MemLib.SetPreciseFPU()
        local value
        if self.Address then
            value = MemLib.SV.AddressGetByte(self.Address + _Offset)
        else
            value = self.Value + _Offset
        end
        MemLib.DisarmPreciseFPU()

        return value
    end

    function userdata:SetByte(_Offset, _Value)
        if self.Address then
            _Offset = _Offset or 0
            MemLib.ArmPreciseFPU()
            MemLib.SetPreciseFPU()
            MemLib.SV.AddressSetByte(self.Address + _Offset, _Value)
            MemLib.DisarmPreciseFPU()
        end
    end

    function userdata:Offset(_Offset)
        MemLib.ArmPreciseFPU()
        MemLib.SetPreciseFPU()
        local value = (self.Address or self.Value) + _Offset * 4
        MemLib.DisarmPreciseFPU()
        return MemLib.SV.New(value)
    end

    return userdata
end
--------------------------------------------------------------------------------
MemLib.SV.Mission_OnSaveGameLoaded = Mission_OnSaveGameLoaded
function Mission_OnSaveGameLoaded()
	MemLib.SV.Mission_OnSaveGameLoaded()
	MemLib_SV_InitAddressEntity()
end
MemLib_SV_InitAddressEntity()