--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
-- MemLib.Widget
-- author: RobbiTheFox
-- current maintainer: RobbiTheFox
-- Version: v1.0
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
-- C3DOnScreenInformationCustomWidget at 0x882F54
if mcbPacker then
    mcbPacker.require("s5CommunityLib/Lib/MemLib/MemLib")
    mcbPacker.require("s5CommunityLib/Tables/WidgetClasses")
else
	if not MemLib then Script.Load("maps\\user\\EMS\\tools\\s5CommunityLib\\lib\\MemLib\\MemLib.lua") end
	MemLib.Load("Tables/WidgetClasses")
end
--------------------------------------------------------------------------------
MemLib.Widget = {}
--------------------------------------------------------------------------------
---@param _Widget integer|string
---@return userdata|table
function MemLib.Widget.GetMemory(_Widget)
    _Widget = MemLib.Widget.GetId(_Widget)
    return MemLib.GetMemory(MemLib.Offsets.WidgetManager.GlobalObject)[0][2][_Widget]
end
--------------------------------------------------------------------------------
function MemLib.Widget.IsValid(_Widget)
    if type(_Widget) == "number" and _Widget > 0 then
        local widgetManagerMemory = MemLib.GetMemory(MemLib.Offsets.WidgetManager.GlobalObject)[0]
        MemLib.ArmPreciseFPU()
        MemLib.SetPreciseFPU()
        local lastWidgetId = widgetManagerMemory[3]:GetInt() - widgetManagerMemory[2]:GetInt()
        MemLib.DisarmPreciseFPU()
        if _Widget <= lastWidgetId then
            return true
        end
    end
    return XGUIEng.IsWidgetExisting(_Widget) == 1
end
--------------------------------------------------------------------------------
---@param _Widget integer|string
---@return integer
function MemLib.Widget.GetId(_Widget)
    if type(_Widget) == "string" then
        _Widget = XGUIEng.GetWidgetID(_Widget)
    end
    assert(MemLib.Widget.IsValid(_Widget))
    return _Widget
end
--------------------------------------------------------------------------------
---@param _Widget integer|string
---@return integer
function MemLib.Widget.GetClass(_Widget)
    return MemLib.Widget.GetMemory(_Widget)[0]:GetInt()
end
--------------------------------------------------------------------------------
---@param _Widget integer|string
---@param _WidgetClass integer
---@return boolean
function MemLib.Widget.IsOfClass(_Widget, _WidgetClass)
    local widgetClass = MemLib.Widget.GetClass(_Widget)
    if widgetClass == _WidgetClass then
        return true
    end
    local widgetClassChilds = WidgetClassChilds[_WidgetClass]
    if widgetClassChilds then
        for i = 1, table.getn(widgetClassChilds) do
            if MemLib.Widget.IsOfClass(_Widget, widgetClassChilds[i]) then
                return true
            end
        end
    end
    return false
end
--------------------------------------------------------------------------------
---@param _Widget integer|string
---@return string
function MemLib.Widget.ButtonGetActionFunction(_Widget)
    assert(MemLib.Widget.IsOfClass(_Widget, WidgetClasses.CButtonWidget))
    return MemLib.Internal.GetString(MemLib.Widget.GetMemory(_Widget):Offset(20))
end
--------------------------------------------------------------------------------
-- WIP
---@param _Widget integer|string
---@param _String string
function MemLib.Internal.ButtonSetActionFunction(_Widget, _String)
    assert(MemLib.Widget.IsOfClass(_Widget, WidgetClasses.CButtonWidget))
    assert(type(_String) == "string")
    MemLib.Internal.SetCLuaFunctionHelper(MemLib.Widget.GetMemory(_Widget):Offset(19), _String)
end
--------------------------------------------------------------------------------
if CWidget then

    --------------------------------------------------------------------------------
    ---@param _Widget integer|string
    ---@return number X
    ---@return number Y
    function MemLib.Widget.GetPosition(_Widget)
        _Widget = MemLib.Widget.GetId(_Widget)
        return CWidget.GetPosition(_Widget)
    end
    --------------------------------------------------------------------------------
    ---@param _Widget integer|string
    ---@param _X number
    ---@param _Y number
    function MemLib.Widget.SetPosition(_Widget, _X, _Y)
        assert(type(_X) == "number")
        assert(type(_Y) == "number")
        _Widget = MemLib.Widget.GetId(_Widget)
        CWidget.SetPosition(_Widget, _X, _Y)
    end
    --------------------------------------------------------------------------------
    ---@param _Widget integer|string
    ---@return number W
    ---@return number H
    function MemLib.Widget.GetSize(_Widget)
        _Widget = MemLib.Widget.GetId(_Widget)
        return CWidget.GetSize(_Widget)
    end
    --------------------------------------------------------------------------------
    ---@param _Widget integer|string
    ---@param _W number
    ---@param _H number
    function MemLib.Widget.SetSize(_Widget, _W, _H)
        assert(type(_W) == "number")
        assert(type(_H) == "number")
        _Widget = MemLib.Widget.GetId(_Widget)
        CWidget.SetSize(_Widget, _W, _H)
    end
    --------------------------------------------------------------------------------
    ---@param _Widget integer|string
    ---@param _Index integer
    ---@return number X
    ---@return number Y
    ---@return number W
    ---@return number H
    function MemLib.Widget.ButtonGetTextureCoords(_Widget, _Index)
        assert(MemLib.Widget.IsOfClass(_Widget, WidgetClasses.CButtonWidget))
        assert(type(_Index) == "number" and _Index >= 0 and _Index <= 4)
        _Widget = MemLib.Widget.GetId(_Widget)
        return CWidget.GetTextureOffsets(_Widget, _Index)
    end

elseif CppLogic then

    --------------------------------------------------------------------------------
    ---@param _Widget integer|string
    ---@return number X
    ---@return number Y
    function MemLib.Widget.GetPosition(_Widget)
        local x, y = CppLogic.UI.WidgetGetPositionAndSize(_Widget)
        return x, y
    end
    --------------------------------------------------------------------------------
    ---@param _Widget integer|string
    ---@param _X number
    ---@param _Y number
    function MemLib.Widget.SetPosition(_Widget, _X, _Y)
        local _, _, w, h = CppLogic.UI.WidgetGetPositionAndSize(_Widget)
        CppLogic.UI.WidgetSetPositionAndSize(_Widget, _X, _Y, w, h)
    end
    --------------------------------------------------------------------------------
    ---@param _Widget integer|string
    ---@return number W
    ---@return number H
    function MemLib.Widget.GetSize(_Widget)
        local _, _, w, h = CppLogic.UI.WidgetGetPositionAndSize(_Widget)
        return w, h
    end
    --------------------------------------------------------------------------------
    ---@param _Widget integer|string
    ---@param _W number
    ---@param _H number
    function MemLib.Widget.SetSize(_Widget, _W, _H)
        local x, y = CppLogic.UI.WidgetGetPositionAndSize(_Widget)
        CppLogic.UI.WidgetSetPositionAndSize(_Widget, x, y, _W, _H)
    end
    --------------------------------------------------------------------------------
    ---@param _Widget integer|string
    ---@param _Index integer
    ---@return number X
    ---@return number Y
    ---@return number W
    ---@return number H
    function MemLib.Widget.ButtonGetTextureCoords(_Widget, _Index)
        return CppLogic.UI.WidgetMaterialGetTextureCoordinates(_Widget, _Index)
    end

else

    --------------------------------------------------------------------------------
    ---@param _Widget integer|string
    ---@return number X
    ---@return number Y
    function MemLib.Widget.GetPosition(_Widget)
        local widgetMemory = MemLib.Widget.GetMemory(_Widget)
        return widgetMemory[5]:GetFloat(), widgetMemory[6]:GetFloat()
    end
    --------------------------------------------------------------------------------
    ---@param _Widget integer|string
    ---@param _X number
    ---@param _Y number
    function MemLib.Widget.SetPosition(_Widget, _X, _Y)
        assert(type(_X) == "number")
        assert(type(_Y) == "number")
        local widgetMemory = MemLib.Widget.GetMemory(_Widget)
        widgetMemory[5]:SetFloat(_X)
        widgetMemory[6]:SetFloat(_Y)
    end
    --------------------------------------------------------------------------------
    ---@param _Widget integer|string
    ---@return number W
    ---@return number H
    function MemLib.Widget.GetSize(_Widget)
        local widgetMemory = MemLib.Widget.GetMemory(_Widget)
        return widgetMemory[7]:GetFloat(), widgetMemory[8]:GetFloat()
    end
    --------------------------------------------------------------------------------
    ---@param _Widget integer|string
    ---@param _W number
    ---@param _H number
    function MemLib.Widget.SetSize(_Widget, _W, _H)
        assert(type(_W) == "number")
        assert(type(_H) == "number")
        local widgetMemory = MemLib.Widget.GetMemory(_Widget)
        widgetMemory[7]:SetFloat(_W)
        widgetMemory[8]:SetFloat(_H)
    end
    --------------------------------------------------------------------------------
    ---@param _Widget integer|string
    ---@param _Index integer
    ---@return number X
    ---@return number Y
    ---@return number W
    ---@return number H
    function MemLib.Widget.ButtonGetTextureCoords(_Widget, _Index)
        assert(MemLib.Widget.IsOfClass(_Widget, WidgetClasses.CButtonWidget))
        assert(type(_Index) == "number" and _Index >= 0 and _Index <= 4)
        local widgetMemory = MemLib.Widget.GetMemory(_Widget)
        local offset = 56 + _Index * 10
        return widgetMemory[offset], widgetMemory[offset + 1], widgetMemory[offset + 2], widgetMemory[offset + 3]
    end

end
--------------------------------------------------------------------------------
-- adds _ChildWidget before _NextWidget or at the end if no _NextWidget
---@param _ContainerWidget string|integer
---@param _ChildWidget string|integer
---@param _NextWidget string|integer?
function MemLib.Widget.ContainerAddChild(_ContainerWidget, _ChildWidget, _NextWidget)
    assert(MemLib.Widget.GetClass(_ContainerWidget) == WidgetClasses.CContainerWidget)

    local containerWidgetMemory = MemLib.Widget.GetMemory(_ContainerWidget)
    local childWidgetAddress = MemLib.Widget.GetMemory(_ChildWidget):GetInt()

    local numberOfItems = containerWidgetMemory[19]:GetInt()
    local currentItem = containerWidgetMemory[18]
    local nextWidgetAddress = 0

    if _NextWidget then
        nextWidgetAddress = MemLib.Widget.GetMemory(_NextWidget):GetInt()
    else
        nextWidgetAddress = currentItem:GetInt()
    end

    for i = 1, math.max(numberOfItems, 1) do -- only so that emtpy lists get filled as well
        currentItem = currentItem[0]
        if currentItem[0]:GetInt() == nextWidgetAddress then

            local address = MemLib.Alloc(3 * 4)
            local memory = MemLib.GetMemory(address)

            memory[0]:SetInt(nextWidgetAddress)
            memory[1]:SetInt(currentItem:GetInt())
            memory[2]:SetInt(childWidgetAddress)

            currentItem[0][1]:SetInt(address)
            currentItem[0]:SetInt(address)

            containerWidgetMemory[19]:SetInt(numberOfItems + 1)
            break
        end
    end
end
--------------------------------------------------------------------------------
---@param _TexturePath string
---@return integer
function MemLib.Widget.TextureGetId(_TexturePath)

    local texturePath = string.gsub(_TexturePath, "data\\graphics\\textures\\gui\\", "")

    MemLib.Widget.Textures = MemLib.Widget.Textures or {}
    if MemLib.Widget.Textures[texturePath] then
        return MemLib.Widget.Textures[texturePath]
    end

    local textureManagerId = MemLib.GetMemory(8996020)[0]
    local vectorStartMemory = textureManagerId[3]
    local vectorStart = vectorStartMemory:GetInt()
    local vectorEnd = textureManagerId[4]:GetInt()

    MemLib.ArmPreciseFPU()
    MemLib.SetPreciseFPU()

    local lastIndex = (vectorEnd - vectorStart) / 4 - 2

    MemLib.DisarmPreciseFPU()


    for i = 2, lastIndex, 2 do

        local textureNameMemory = vectorStartMemory[i]

        if textureNameMemory:GetInt() <= 0 then
            break
        end

        textureNameMemory = textureNameMemory[0]

        local textureName = ""
        local j = 27

        while true do
            local byte = textureNameMemory:GetByte(j)
            if byte ~= 0 then
                textureName = textureName .. string.char(byte)
            else
                break
            end
            j = j + 1
        end

        if texturePath == textureName then
            i = i / 2
            MemLib.Widget.Textures[texturePath] = i
            return i
        end
    end

    return 0
end
--------------------------------------------------------------------------------
---@param _FontPath string
---@return integer
function MemLib.Widget.FontGetId(_FontPath)

    local fontPath = string.gsub(_FontPath, "data\\menu\\font\\", "")

    MemLib.Widget.Fonts = MemLib.Widget.Fonts or {}
    if MemLib.Widget.Fonts[fontPath] then
        return MemLib.Widget.Fonts[fontPath]
    end

    local fontManagerId = MemLib.GetMemory(8996488)[0]
    local vectorStartMemory = fontManagerId[3]
    local vectorStart = vectorStartMemory:GetInt()
    local vectorEnd = fontManagerId[4]:GetInt()

    MemLib.ArmPreciseFPU()
    MemLib.SetPreciseFPU()

    local lastIndex = (vectorEnd - vectorStart) / 4 - 2

    MemLib.DisarmPreciseFPU()


    for i = 2, lastIndex, 2 do

        local fontNameMemory = vectorStartMemory[i]

        if fontNameMemory:GetInt() <= 0 then
            break
        end

        fontNameMemory = fontNameMemory[0]

        local fontName = ""
        local j = 16

        while true do
            local byte = fontNameMemory:GetByte(j)
            if byte ~= 0 then
                fontName = fontName .. string.char(byte)
            else
                break
            end
            j = j + 1
        end

        if fontPath == fontName then
            i = i / 2
            MemLib.Widget.Fonts[fontPath] = i
            return i
        end
    end

    return 0
end
--------------------------------------------------------------------------------
---@param _WidgetName string
---@return integer
function MemLib.Widget.GetHash(_WidgetName)

    if not _WidgetName or _WidgetName == "" then
        return 0
    end

    local hash = 0
    local F0000000 = MemLib.LAU.ToTable(4026531840)

    MemLib.ArmPreciseFPU()
    MemLib.SetPreciseFPU()

    for i = 1, string.len(_WidgetName) do

        local byte = string.byte(_WidgetName, i)
        MemLib.SetPreciseFPU()

        if byte >= 65 and byte <= 90 then
            byte = byte + 32
        end

        if byte == 47 then
            byte = 92
        end

        hash = hash * 16 + byte

        local esi = MemLib.LAU.ToTable(hash)
        local eax = MemLib.LAU.And(esi, F0000000)
        local ecx = MemLib.LAU.RShift(24, eax)
        ecx = MemLib.LAU.Xor(ecx, eax)
        esi = MemLib.LAU.Xor(esi, ecx)

        hash = MemLib.LAU.ToUnsigned(esi)
    end

    if hash ~= 0 then
        MemLib.SetPreciseFPU()
        local eax = hash
        hash = hash * 1989869568
        hash = MemLib.LAU.ToNumber(MemLib.LAU.ToTable(hash))
        eax = MemLib.Bit.RShift(16, eax)
        MemLib.SetPreciseFPU()
        eax = eax * 1812433253
        eax = MemLib.LAU.ToNumber(MemLib.LAU.ToTable(eax))
        MemLib.SetPreciseFPU()
        hash = eax - hash
        hash = MemLib.LAU.ToNumber(MemLib.LAU.ToTable(hash))
    else
        hash = 1
    end

    MemLib.DisarmPreciseFPU()
    return hash
end
--------------------------------------------------------------------------------
---@param _WidgetConfig table
---@return integer WidgetId
function MemLib.Widget.Create(_WidgetConfig)
    assert(type(_WidgetConfig) == "table")

    if XGUIEng.IsWidgetExisting(_WidgetConfig.Name) == 1 then
        return 0
    end

    -- get widget class
    local class = _WidgetConfig.Class
    local className
    for k, v in pairs(WidgetClasses) do
        if class == v then
            className = k
            break
        end
    end
    assert(type(className) == "string")

    -- following Order is imprtant:

    -- 1. add entry in WidgetManager
    local widgetManagerMemory = MemLib.GetMemory(MemLib.Offsets.WidgetManager.GlobalObject)[0]
    local vectorStartMemory = widgetManagerMemory[2]
    local vectorEndMemory = widgetManagerMemory[3]
    local vectorAllocMemory = widgetManagerMemory[4]
    local vectorEnd = vectorEndMemory:GetInt()

    if vectorAllocMemory:GetInt() <= vectorEnd then
        -- realloc vector to make room for new widget
    end

    -- 1.1 retrieve new widget id
    -- TODO: is it safe to assume, that no widgets were deleted?
    -- 1712 is the next free widgetId in vanilla
    local widgetId = 1700
    while vectorStartMemory[widgetId]:GetInt() ~= 0 do
        widgetId = widgetId + 1
    end
    _WidgetConfig.Id = widgetId

    -- 2. add entry in WidgetIDManager
    local widgetIdManagerMemory = MemLib.GetMemory(MemLib.Offsets.WidgetIDManager.GlobalObject)[0]

    local vectorStartMemory = widgetIdManagerMemory[3]
    local vectorEndMemory = widgetIdManagerMemory[4]
    local vectorAllocMemory = widgetIdManagerMemory[5]
    local vectorEnd = vectorEndMemory:GetInt()

    if vectorAllocMemory:GetInt() <= vectorEndMemory:GetInt() then
        -- realloc vector to make room for new widget
    end

    MemLib.ArmPreciseFPU()
    MemLib.SetPreciseFPU()

    if vectorEnd < widgetId * 8 then
        vectorEnd = vectorEnd + 8
    end

    MemLib.DisarmPreciseFPU()

    vectorEndMemory:SetInt(vectorEnd)

    local name = _WidgetConfig.Name
    local hash = MemLib.Widget.GetHash(name)
    vectorStartMemory[widgetId * 2 + 1]:SetInt(hash)

    local len = string.len(name)
    local address = MemLib.Alloc(len)
    vectorStartMemory[widgetId * 2]:SetInt(address)

    local widgetNameMemory = MemLib.GetMemory(address)[0]
    for i = 1, len do
        widgetNameMemory:SetByte(i - 1, string.byte(name, i))
    end

    -- 3. create widget
    local widgetManagerMemory = MemLib.GetMemory(MemLib.Offsets.WidgetManager.GlobalObject)[0]
    local vectorStartMemory = widgetManagerMemory[2]
    local vectorEndMemory = widgetManagerMemory[3]
    local vectorEnd = vectorEndMemory:GetInt()

    local widgetClassSize = {
        [WidgetClasses.CBaseWidget] = 56,
        [WidgetClasses.CStaticWidget] = 104,
        [WidgetClasses.CStaticTextWidget] = 292,
        [WidgetClasses.CProgressBarWidget] = 192,
        [WidgetClasses.CButtonWidget] = 576,
        [WidgetClasses.CGfxButtonWidget] = 696,
        [WidgetClasses.CTextButtonWidget] = 752,
        [WidgetClasses.CContainerWidget] = 80,
        [WidgetClasses.CProjectWidget] = 84,
        [WidgetClasses.CPureTooltipWidget] = 216,
        [WidgetClasses.CCustomWidget] = 172,
    }

    -- allocate widget itself
    local address = MemLib.Alloc(widgetClassSize[_WidgetConfig.Class])
    vectorStartMemory[widgetId]:SetInt(address)

    MemLib.ArmPreciseFPU()
    MemLib.SetPreciseFPU()

    -- only count up vector if nesseccary
    -- for some reason this vector is initially bigger than the one in WidgetNameManager
    -- still the "additional" widget are not valid
    if vectorEnd < widgetId * 4 then
        vectorEnd = vectorEnd + 4
    end

    MemLib.DisarmPreciseFPU()

    vectorEndMemory:SetInt(vectorEnd)

    -- apply widget config
    MemLib.Internal[className](MemLib.GetMemory(address), _WidgetConfig)
    MemLib.Widget.ContainerAddChild(_WidgetConfig.MotherID, widgetId, _WidgetConfig.NextWidget)

    return widgetId
end
--------------------------------------------------------------------------------
---@param _Memory userdata|table
---@param _WidgetConfig table
function MemLib.Internal.CBaseWidget(_Memory, _WidgetConfig)
    assert(type(_WidgetConfig) == "table")
    assert(type(_WidgetConfig.Class) == "number")
    assert(type(_WidgetConfig.Name) == "string")
    assert(type(_WidgetConfig.Id) == "number")
    assert(type(_WidgetConfig.Rectangle) == "table")
    assert(type(_WidgetConfig.Rectangle.X) == "number")
    assert(type(_WidgetConfig.Rectangle.Y) == "number")
    assert(type(_WidgetConfig.Rectangle.W) == "number")
    assert(type(_WidgetConfig.Rectangle.H) == "number")
    assert(type(_WidgetConfig.IsShown) == "boolean")
    assert(type(_WidgetConfig.MotherID) == "string" or type(_WidgetConfig.MotherID) == "number")
    assert(type(_WidgetConfig.Group) == "number")
    assert(type(_WidgetConfig.ForceToHandleMouseEventsFlag) == "boolean")
    assert(type(_WidgetConfig.ForceToNeverBeFoundFlag) == "boolean")

    _Memory[0]:SetInt(_WidgetConfig.Class) -- vtp WidgetClass
    _Memory[1]:SetInt(_WidgetConfig.Class - 12) -- ?
    _Memory[2]:SetInt(0) -- user variables
    _Memory[3]:SetInt(0)
    _Memory[4]:SetInt(_WidgetConfig.Id)
    _Memory[5]:SetFloat(_WidgetConfig.Rectangle.X)
    _Memory[6]:SetFloat(_WidgetConfig.Rectangle.Y)
    _Memory[7]:SetFloat(_WidgetConfig.Rectangle.W)
    _Memory[8]:SetFloat(_WidgetConfig.Rectangle.H)
    _Memory[9]:SetInt(_WidgetConfig.IsShown and 1 or 0)
    _Memory[10]:SetFloat(_WidgetConfig.ZPriority)
    _Memory[11]:SetInt(MemLib.Widget.GetId(_WidgetConfig.MotherID))
    _Memory[12]:SetInt(_WidgetConfig.Group)
    _Memory[13]:SetByte(0, _WidgetConfig.ForceToHandleMouseEventsFlag and 1 or 0)
    _Memory[13]:SetByte(1, _WidgetConfig.ForceToNeverBeFoundFlag and 1 or 0)
end
--------------------------------------------------------------------------------
---@param _Memory userdata|table
---@param _WidgetConfig table
function MemLib.Internal.CButtonWidget(_Memory, _WidgetConfig, _Vtp)
    assert(type(_WidgetConfig) == "table")
    assert(type(_WidgetConfig.ButtonHelper) == "table")
    assert(type(_WidgetConfig.ButtonHelper.DisabledFlag) == "boolean")
    assert(type(_WidgetConfig.ButtonHelper.HighLightedFlag) == "boolean")
    assert(type(_WidgetConfig.ButtonHelper.ActionFunction) == "string")
    assert(type(_WidgetConfig.Materials) == "table")

    MemLib.Internal.CBaseWidget(_Memory, _WidgetConfig)
    _Memory[14]:SetInt(_Vtp) -- ?
    _Memory[15]:SetInt(_Vtp - 20) -- ?
    _Memory[16]:SetInt(7866392) -- vtp CButtonHelper
    _Memory[17]:SetInt(0) -- state
    _Memory[18]:SetByte(0, _WidgetConfig.ButtonHelper.DisabledFlag and 1 or 0)
    _Memory[18]:SetByte(1, _WidgetConfig.ButtonHelper.HighLightedFlag and 1 or 0)
    MemLib.Internal.CLuaFunctionHelper(_Memory:Offset(19), _WidgetConfig.ButtonHelper.ActionFunction)
    MemLib.Internal.CSingleStringHandler(_Memory:Offset(39), _WidgetConfig.ButtonHelper.ShortCutString)
    MemLib.Internal.CMaterial(_Memory:Offset(54), _WidgetConfig.Materials[0])
    MemLib.Internal.CMaterial(_Memory:Offset(64), _WidgetConfig.Materials[1])
    MemLib.Internal.CMaterial(_Memory:Offset(74), _WidgetConfig.Materials[2])
    MemLib.Internal.CMaterial(_Memory:Offset(84), _WidgetConfig.Materials[3])
    MemLib.Internal.CMaterial(_Memory:Offset(94), _WidgetConfig.Materials[4])
    _Memory[104]:SetInt(5)
    MemLib.Internal.CToolTipHelper(_Memory:Offset(105), _WidgetConfig.ToolTipHelper)
end
--------------------------------------------------------------------------------
---@param _Memory userdata|table
---@param _WidgetConfig table
function MemLib.Internal.CGfxButtonWidget(_Memory, _WidgetConfig)
    assert(type(_WidgetConfig) == "table")
    assert(type(_WidgetConfig.UpdateManualFlag) == "boolean")

    MemLib.Internal.CButtonWidget(_Memory, _WidgetConfig, 7867576)
    MemLib.Internal.CMaterial(_Memory:Offset(146), _WidgetConfig.IconMaterial)
    MemLib.Internal.CLuaFunctionHelper(_Memory:Offset(156), _WidgetConfig.UpdateFunction)
    _Memory[176]:SetInt(_WidgetConfig.UpdateManualFlag and 1 or 0)
end
--------------------------------------------------------------------------------
---@param _Memory userdata|table
---@param _WidgetConfig table
function MemLib.Internal.CTextButtonWidget(_Memory, _WidgetConfig)
    assert(type(_WidgetConfig) == "table")
    assert(type(_WidgetConfig.UpdateManualFlag) == "boolean")

    MemLib.Internal.CButtonWidget(_Memory, _WidgetConfig, 7867800)
    MemLib.Internal.CWidgetStringHelper(_Memory:Offset(146), _WidgetConfig.StringHelper)
    MemLib.Internal.CLuaFunctionHelper(_Memory:Offset(170), _WidgetConfig.UpdateFunction)
    _Memory[190]:SetInt(_WidgetConfig.UpdateManualFlag and 1 or 0)
end
--------------------------------------------------------------------------------
---@param _Memory userdata|table
---@param _WidgetConfig table
function MemLib.Internal.CStaticWidget(_Memory, _WidgetConfig, _Vtp)
    assert(type(_WidgetConfig) == "table")

    MemLib.Internal.CBaseWidget(_Memory, _WidgetConfig)
    _Memory[14]:SetInt(_Vtp or 7868268) -- ?
    _Memory[15]:SetInt((_Vtp or 7868268) - 20) -- ?
    MemLib.Internal.CMaterial(_Memory:Offset(16), _WidgetConfig.BackgroundMaterial)
end
--------------------------------------------------------------------------------
function MemLib.Internal.CStaticTextWidget(_Memory, _WidgetConfig)
    assert(type(_WidgetConfig) == "table")
    assert(type(_WidgetConfig.UpdateManualFlag) == "boolean")
    --assert(type(_WidgetConfig.FirstLineToPrint) == "number")
    --assert(type(_WidgetConfig.NumberOfLinesToPrint) == "number")
    --assert(type(_WidgetConfig.LineDistanceFactor) == "number")

    MemLib.Internal.CStaticWidget(_Memory, _WidgetConfig, 7868108)
    _Memory[26]:SetInt(7868048)
    MemLib.Internal.CWidgetStringHelper(_Memory:Offset(27), _WidgetConfig.StringHelper)
    MemLib.Internal.CLuaFunctionHelper(_Memory:Offset(50), _WidgetConfig.UpdateFunction)
    _Memory[70]:SetInt(_WidgetConfig.UpdateManualFlag and 1 or 0)
    _Memory[71]:SetInt(_WidgetConfig.FirstLineToPrint or 0)
    _Memory[72]:SetInt(_WidgetConfig.NumberOfLinesToPrint or 0)
    _Memory[73]:SetFloat(_WidgetConfig.LineDistanceFactor or 0)
end
--------------------------------------------------------------------------------
function MemLib.Internal.CProgressBarWidget(_Memory, _WidgetConfig)
    MemLib.Internal.CStaticWidget(_Memory, _WidgetConfig, 7867400)
    MemLib.Internal.CLuaFunctionHelper(_Memory:Offset(26), _WidgetConfig.UpdateFunction)
    _Memory[46]:SetInt(_WidgetConfig.UpdateManualFlag and 1 or 0)
    _Memory[47]:SetFloat(_WidgetConfig.ProgressBarValue or 0)
    _Memory[48]:SetFloat(_WidgetConfig.ProgressBarLimit or 0)
end
--------------------------------------------------------------------------------
function MemLib.Internal.CContainerWidget(_Memory, _WidgetConfig)
    assert(type(_WidgetConfig) == "table")

    _Memory[14]:SetInt(7868724) -- vtp CWidgetListHandler
    _Memory[15]:SetInt(7868716) -- ?
    _Memory[16]:SetInt(7868724) -- vtp CWidgetListHandler again?
    MemLib.Internal.NewList(_Memory:Offset(17))

    -- create child widgets if existing
    if type(_WidgetConfig.SubWidgets) == "table" then
        for i = 1, table.getn(_WidgetConfig.SubWidgets) do
            MemLib.Widget.Create(_WidgetConfig.SubWidgets[i])
        end
    end
end
--------------------------------------------------------------------------------
function MemLib.Internal.CProjectWidget(_Memory, _WidgetConfig)
    MemLib.Internal.CContainerWidget(_Memory, _WidgetConfig)
    _Memory[20]:SetInt(XGUIEng.GetWidgetID("InGame"))
end
--------------------------------------------------------------------------------
function MemLib.Internal.CPureTooltipWidget(_Memory, _WidgetConfig)
    assert(type(_WidgetConfig) == "table")

    MemLib.Internal.CBaseWidget(_Memory, _WidgetConfig)
    MemLib.Internal.CToolTipHelper(_Memory:Offset(14), _WidgetConfig.ToolTipHelper)
end
--------------------------------------------------------------------------------
---@param _Memory userdata|table
---@param _StringHelper table
function MemLib.Internal.CWidgetStringHelper(_Memory, _StringHelper)
    assert(type(_StringHelper) == "table")
    assert(type(_StringHelper.Font) == "string")
    assert(type(_StringHelper.StringFrameDistance) == "number")
    assert(type(_StringHelper.Color) == "table")
    assert(type(_StringHelper.Color.R) == "number")
    assert(type(_StringHelper.Color.G) == "number")
    assert(type(_StringHelper.Color.B) == "number")
    assert(type(_StringHelper.Color.A) == "number")

    _Memory[0]:SetInt(7867740) -- vtp CWidgetStringHelper
    _Memory[1]:SetInt(7869720) -- ?
    _Memory[2]:SetInt(7867148) -- vtp CFontIDHandler
    _Memory[3]:SetInt(MemLib.Widget.FontGetId(_StringHelper.Font))
    MemLib.Internal.CSingleStringHandler(_Memory:Offset(4), _StringHelper.String)
    _Memory[19]:SetFloat(_StringHelper.StringFrameDistance)
    _Memory[20]:SetInt(_StringHelper.Color.R)
    _Memory[21]:SetInt(_StringHelper.Color.G)
    _Memory[22]:SetInt(_StringHelper.Color.B)
    _Memory[23]:SetInt(_StringHelper.Color.A)
end
--------------------------------------------------------------------------------
---@param _Memory userdata|table
---@param _FunctionString string
function MemLib.Internal.CLuaFunctionHelper(_Memory, _FunctionString)
    _Memory[0]:SetInt(7866772) -- vtp CLuaFunctionHelper
    MemLib.Internal.NewString(_Memory:Offset(1), _FunctionString)
    _Memory[8]:SetInt(7891936) -- vtp CLuaFuncRefCommand
    _Memory[9]:SetInt(0)
    _Memory[10]:SetInt(1)
    _Memory[11]:SetInt(-2)

    _Memory[12]:SetInt(0) -- string
    _Memory[13]:SetInt(0)
    _Memory[14]:SetInt(0)
    _Memory[15]:SetInt(0)
    _Memory[16]:SetInt(0)
    _Memory[16]:SetInt(0)
    _Memory[17]:SetInt(15)

    _Memory[18]:SetInt(1)
end
--------------------------------------------------------------------------------
-- WIP! - it works but most likely results in a memory leak
---@param _Memory userdata|table
---@param _FunctionString string
function MemLib.Internal.SetCLuaFunctionHelper(_Memory, _FunctionString)
    _Memory[0]:SetInt(7866772) -- vtp CLuaFunctionHelper
    MemLib.Internal.SetString(_Memory:Offset(1), _FunctionString)
    _Memory[8]:SetInt(7891936) -- vtp CLuaFuncRefCommand
    _Memory[9]:SetInt(0)
    _Memory[10]:SetInt(1)
    _Memory[11]:SetInt(-2)

    MemLib.Internal.SetString(_Memory:Offset(1), _FunctionString)
    _Memory[13]:SetInt(0)
    _Memory[14]:SetInt(0)
    _Memory[15]:SetInt(0)
    _Memory[16]:SetInt(0)
    _Memory[16]:SetInt(0)
    _Memory[17]:SetInt(15)

    _Memory[18]:SetInt(1)
end
--------------------------------------------------------------------------------
---@param _Memory userdata|table
---@param _StringHandler table
function MemLib.Internal.CSingleStringHandler(_Memory, _StringHandler)
    assert(type(_StringHandler) == "table")

    _Memory[0]:SetInt(7866788) -- vtp CSingleStringHandler
    MemLib.Internal.NewString(_Memory:Offset(1), _StringHandler.StringTableKey)
    MemLib.Internal.NewString(_Memory:Offset(8), _StringHandler.RawString)
end
--------------------------------------------------------------------------------
---@param _Memory userdata|table
---@param _Material table
function MemLib.Internal.CMaterial(_Memory, _Material)
    assert(type(_Material.Texture) == "string")
    assert(type(_Material.TextureCoordinates) == "table")
    assert(type(_Material.TextureCoordinates.X) == "number")
    assert(type(_Material.TextureCoordinates.Y) == "number")
    assert(type(_Material.TextureCoordinates.W) == "number")
    assert(type(_Material.TextureCoordinates.H) == "number")
    assert(type(_Material.Color) == "table")
    assert(type(_Material.Color.R) == "number")
    assert(type(_Material.Color.G) == "number")
    assert(type(_Material.Color.B) == "number")
    assert(type(_Material.Color.A) == "number")

    _Memory[0]:SetInt(7866512) -- vtp CMaterial
    _Memory[1]:SetInt(MemLib.Widget.TextureGetId(_Material.Texture))
    _Memory[2]:SetFloat(_Material.TextureCoordinates.X)
    _Memory[3]:SetFloat(_Material.TextureCoordinates.Y)
    _Memory[4]:SetFloat(_Material.TextureCoordinates.W)
    _Memory[5]:SetFloat(_Material.TextureCoordinates.H)
    _Memory[6]:SetInt(_Material.Color.R)
    _Memory[7]:SetInt(_Material.Color.G)
    _Memory[8]:SetInt(_Material.Color.B)
    _Memory[9]:SetInt(_Material.Color.A)
end
--------------------------------------------------------------------------------
---@param _Memory userdata|table
---@param _ToolTipHelper table
function MemLib.Internal.CToolTipHelper(_Memory, _ToolTipHelper)
    assert(type(_ToolTipHelper) == "table")
    assert(type(_ToolTipHelper.TargetWidget) == "string" or type(_ToolTipHelper.TargetWidget) == "number")
    assert(type(_ToolTipHelper.ToolTipEnabledFlag) == "boolean")
    assert(type(_ToolTipHelper.ControlTargetWidgetDisplayState) == "boolean")

    _Memory[0]:SetInt(7867184) -- vtp CToolTipHelper
    _Memory[1]:SetInt(7867176) -- ?
    _Memory[2]:SetInt(_ToolTipHelper.ToolTipEnabledFlag and 1 or 0)
    MemLib.Internal.CSingleStringHandler(_Memory:Offset(3), _ToolTipHelper.ToolTipString)
    _Memory[18]:SetInt(MemLib.Widget.GetId(_ToolTipHelper.TargetWidget))
    _Memory[19]:SetInt(_ToolTipHelper.ControlTargetWidgetDisplayState and 1 or 0)
    MemLib.Internal.CLuaFunctionHelper(_Memory:Offset(20), _ToolTipHelper.UpdateFunction)
    _Memory[40]:SetInt(1) -- IsTooltipShown
end
--------------------------------------------------------------------------------
---@param _Memory userdata|table
---@param _String string
function MemLib.Internal.NewString(_Memory, _String)
    assert(type(_String) == "string")

    _Memory[0]:SetInt(0)
    local n = string.len(_String)
    local memory
    if n > 16 then
        local address = MemLib.Alloc(n)
        _Memory[1]:SetInt(address)
        _Memory[5]:SetInt(n - 1)
        memory = _Memory[1][0]
    else
        _Memory[5]:SetInt(n - 1)
        _Memory[6]:SetInt(15)
        memory = _Memory[1]
    end
    for i = 1, n do
        memory:SetByte(i - 1, string.byte(_String, i))
    end
end
--------------------------------------------------------------------------------
-- assumes, that this string is already existing!
---@param _Memory userdata|table
---@param _String string
function MemLib.Internal.SetString(_Memory, _String)
    assert(type(_String) == "string")

    local n = string.len(_String)
    local oldN = _Memory[5]:GetInt()
    local allocated = _Memory[6]:GetInt() + 1
    local memory
    if n > 16 then
        local address = _Memory[1]:GetInt()
        if allocated <= 16 then
            address = MemLib.Alloc(n)
            _Memory[6]:SetInt(n - 1)
        else
            if n > allocated then
                address = MemLib.ReAlloc(address, n)
                _Memory[6]:SetInt(n - 1)
            end
        end
        memory = _Memory[1][0]
    elseif allocated > 16 then
        memory = _Memory[1][0]
    else
        _Memory[6]:SetInt(15)
        memory = _Memory[1]
    end
    for i = 1, n do
        memory:SetByte(i - 1, string.byte(_String, i))
    end
    for i = n + 1, oldN do
        memory:SetByte(i - 1, 0)
    end
    _Memory[5]:SetInt(n - 1)
end
--------------------------------------------------------------------------------
function MemLib.Internal.GetString(_Memory)
    local n = _Memory[5]:GetInt()
    local memory = _Memory[1]
    if n > 15 then
        memory = memory[0]
    end
    local char = ""
    for i = 0, n do
        char = char .. string.char(memory:GetByte(i))
    end
    return char
end
--------------------------------------------------------------------------------
-- size in int
---@param _Memory userdata|table
---@param _ItemSize integer?
function MemLib.Internal.NewList(_Memory, _ItemSize)
    _ItemSize = _ItemSize or 4
    assert(type(_ItemSize) == "number" and _ItemSize > 0)
    local address = MemLib.Alloc((2 + _ItemSize) * 4)

    _Memory[0]:SetInt(0)
    _Memory[1]:SetInt(address)
    _Memory[2]:SetInt(0)

    local memory = MemLib.GetMemory(address)
    memory[0]:SetInt(address)
    memory[1]:SetInt(address)
    memory[2]:SetInt(0)
end