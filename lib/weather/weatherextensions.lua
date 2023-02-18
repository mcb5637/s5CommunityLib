if mcbPacker then --mcbPacker.ignore
mcbPacker.require("s5CommunityLib/fixes/TriggerFix")
end --mcbPacker.ignore

-- ************************************************************************************************
-- Weather Extensions v 1.6
-- by RobbiTheFox
-- 
-- TODO:
-- weather callback example rain sound
-- 
-- ************************************************************************************************
WeatherExtensions = WeatherExtensions or {}
-- ************************************************************************************************
-- Init
-- params are optional
-- define the default gfx set
-- this can also be overwritten later
-- ************************************************************************************************
function WeatherExtensions.Init()
	
	-- overwrite functions
	WeatherExtensions.OverwriteC()
	WeatherExtensions.OverwriteOthers()
	
	-- initiate savegame loaded callback
	AddSaveLoadedCallback(WeatherExtensions.OnSaveGameLoaded)
	
	-- add an actual periodic weather
	-- starting a non periodic weather without this results in a crash! thx ubi
	WeatherExtensions.Logic_AddWeatherElement(1, 10, 1, 1, 5, 10)
	
	WeatherExtensions.GfxSets = {}
	WeatherExtensions.Dimensions = {}
	--WeatherExtensions.TransitionState = {} -- (init in .Start)
	WeatherExtensions.WeatherUpdateCounter = 0
	
	-- do not use display gfx sets yet
	Display.SetRenderUseGfxSets(0)
end
-- ************************************************************************************************
-- appends fix gfx settings
-- ************************************************************************************************
function WeatherExtensions.OnSaveGameLoaded()
	
	-- (re)overwrite c funtions
	WeatherExtensions.OverwriteC()
end
-- ************************************************************************************************
function WeatherExtensions.OverwriteC()
	
	-- overrides:
	-- add weather states
	WeatherExtensions.Logic_AddWeatherElement = Logic.AddWeatherElement
	Logic.AddWeatherElement = function(_Wid, _Dur, _Per, _Gfx, _Fore, _Tran)
		WeatherExtensions.AddWeatherElement(_WId, _Dur, _Per, _Gfx, _Fore, _Tran)
	end
	
	-- get next weather state
	WeatherExtensions.Logic_GetNextWeatherState = Logic.GetNextWeatherState
	Logic.GetNextWeatherState = function()
		
		return WeatherExtensions.Template_GetNextWeatherState()
	end
	
	-- get time to next weather state
	WeatherExtensions.Logic_GetTimeToNextWeatherPeriod = Logic.GetTimeToNextWeatherPeriod
	Logic.GetTimeToNextWeatherPeriod = function()
		
		return WeatherExtensions.Template_GetTimeToNextWeatherState()
	end
	
	-- weather tower
	WeatherExtensions.GUI_SetWeather = GUI.SetWeather
	GUI.SetWeather = function(_Wid)
		WeatherExtensions.AddWeatherElement(_WId, 7*60, 0, _Wid, 0, 10)
	end
	
	-- display gfx sets
	WeatherExtensions.Display_GfxSetSetRainEffectStatus = Display.GfxSetSetRainEffectStatus
	Display.GfxSetSetRainEffectStatus = function(_Id, _Start, _End, _Rain)

		_Id    = _Id or 0
		_Rain  = _Rain or 0
		_Start = _Start or 0.0
		_End   = _End or 1.0
		
		WeatherExtensions.GfxSets[_Id] = WeatherExtensions.GfxSets[_Id] or WeatherExtensions.DefaultGfxSet()
		WeatherExtensions.GfxSets[_Id].Rain = _Rain
		WeatherExtensions.GfxSets[_Id].RainTran = Range(_Start,_End)
	end
	
	WeatherExtensions.Display_GfxSetSetSnowEffectStatus = Display.GfxSetSetSnowEffectStatus
	Display.GfxSetSetSnowEffectStatus = function(_Id, _Start, _End, _Snow)
		
		_Id    = _Id or 0
		_Snow  = _Snow or 0
		_Start = _Start or 0.0
		_End   = _End or 0.8
		
		WeatherExtensions.GfxSets[_Id] = WeatherExtensions.GfxSets[_Id] or WeatherExtensions.DefaultGfxSet()
		WeatherExtensions.GfxSets[_Id].Snow = _Snow
		WeatherExtensions.GfxSets[_Id].SnowTran = Range(_Start,_End)
	end
	
	WeatherExtensions.Display_GfxSetSetSnowStatus = Display.GfxSetSetSnowStatus
	Display.GfxSetSetSnowStatus = function(_Id, _Start, _End, _Ice)

		_Id    = _Id or 0
		_Ice   = _Ice or 0
		_Start = _Start or 0.0
		_End   = _End or 1.0
		
		WeatherExtensions.GfxSets[_Id] = WeatherExtensions.GfxSets[_Id] or WeatherExtensions.DefaultGfxSet()
		WeatherExtensions.GfxSets[_Id].Ice = _Ice
		WeatherExtensions.GfxSets[_Id].IceTran = Range(_Start,_End)
	end
	
	WeatherExtensions.Display_GfxSetSetFogParams = Display.GfxSetSetFogParams
	Display.GfxSetSetFogParams = function(_Id, _Start, _End, _State, _FogR,_FogG,_FogB, _DistMin,_DistMax)

		_Id   = _Id or 0
		_FogR = _FogR or 152
		_FogG = _FogG or 172
		_FogB = _FogB or 182
		_DistMin = _DistMin or 5000
		_DistMax = _DistMax or 28000
		_Start = _Start or 0.0
		_End   = _End or 1.0
		_State = _State or 1
			
		WeatherExtensions.GfxSets[_Id] = WeatherExtensions.GfxSets[_Id] or WeatherExtensions.DefaultGfxSet()
		WeatherExtensions.GfxSets[_Id].Fog  = Color(_FogR,_FogG,_FogB)
		WeatherExtensions.GfxSets[_Id].Dist = Range(_DistMin,_DistMax)
		WeatherExtensions.GfxSets[_Id].FogTran = Range(_Start,_End)
		WeatherExtensions.GfxSets[_Id].FogFlag = _State
	end
	
	WeatherExtensions.Display_GfxSetSetLightParams = Display.GfxSetSetLightParams
	Display.GfxSetSetLightParams = function(_Id, _Start, _End, _X, _Y, _Z, _AmbR,_AmbG,_AmbB, _DifR,_DifG,_DifB)

		_Id = _Id or 0
		_X  = _X or  40
		_Y  = _Y or -15
		_Z  = _Z or -50
		_AmbR = _AmbR or 120
		_AmbG = _AmbG or 110
		_AmbB = _AmbB or 110
		_DifR = _DifR or 205
		_DifG = _DifG or 204
		_DifB = _DifB or 180
		_Start = _Start or 0.0
		_End   = _End or 1.0
			
		WeatherExtensions.GfxSets[_Id] = WeatherExtensions.GfxSets[_Id] or WeatherExtensions.DefaultGfxSet()
		WeatherExtensions.GfxSets[_Id].Shad = Position(_X,_Y,_Z)
		WeatherExtensions.GfxSets[_Id].Amb = Color(_AmbR,_AmbG,_AmbB)
		WeatherExtensions.GfxSets[_Id].Dif = Color(_DifR,_DifG,_DifB)
		WeatherExtensions.GfxSets[_Id].LightTran = Range(_Start,_End)
	end
	
	WeatherExtensions.Display_GfxSetSetSkyBox = Display.GfxSetSetSkyBox
	Display.GfxSetSetSkyBox = function(_Id, _Start, _End, _Sky)

		_Id  = _Id or 0
		_Sky = _Sky or "YSkyBox02"
		_Start = _Start or 0.0
		_End   = _End or 1.0
		
		WeatherExtensions.GfxSets[_Id] = WeatherExtensions.GfxSets[_Id] or WeatherExtensions.DefaultGfxSet()
		WeatherExtensions.GfxSets[_Id].Sky = _Sky
		WeatherExtensions.GfxSets[_Id].SkyTran = Range(_Start,_End)
	end
end
-- ************************************************************************************************
function WeatherExtensions.OverwriteOthers()

	-- comfort used by AddPeriodicXXX and StartXXX
	AddWeatherElement = function(_Dur, _Wid, _Per, _Index)
		_Dur = math.max(_Dur, 5)
		_Wid = _Wid or 1
		_Per = _Per or 0
		WeatherExtensions.AddElementToDimension(1, _Wid, _Dur, _Per, _Wid, nil, nil, _Index)
	end
	
	AddPeriodicSummer = function(_Dur, _Index)
		AddWeatherElement(_Dur, 1, 1, _Index)
	end
	
	AddPeriodicRain = function(_Dur, _Index)
		AddWeatherElement(_Dur, 2, 1, _Index)
	end
	
	AddPeriodicWinter = function(_Dur, _Index)
		AddWeatherElement(_Dur, 3, 1, _Index)
	end
end
-- ************************************************************************************************
-- appends fix gfx settings
-- ************************************************************************************************
function WeatherExtensions.AppendDisplayGfxSet(_Id)
	
	Display.SetRenderUseGfxSets(0)
	local gfxset = WeatherExtensions.GetGfxSet(_Id)
	local shadow = WeatherExtensions.Template_GetShadows(_Id) or gfxset.Shad
	
	-- is there no way to set rain and snow effect !?
	Display.SetSnowStatus(gfxset.Ice)
	Display.SetFogColor(gfxset.Fog.R,gfxset.Fog.G,gfxset.Fog.B)
	Display.SetFogStartAndEnd(gfxset.Dist.Min,gfxset.Dist.Max)
	Display.SetGlobalLightAmbient(gfxset.Amb.R,gfxset.Amb.G,gfxset.Amb.B)
	Display.SetGlobalLightDiffuse(gfxset.Dif.R,gfxset.Dif.G,gfxset.Dif.B)
	Display.SetGlobalLightDirection(shadow.X, shadow.Y, shadow.Z)
end
-- ************************************************************************************************
-- updates fog and light params of display gfx set while effect states remain unchanged
-- do not use manually
-- ************************************************************************************************
function WeatherExtensions.UpdateDisplayGfxSet(_Id, _GfxSet)
	
	local gfxset = WeatherExtensions.GetGfxSet(_Id)
	local shadow = WeatherExtensions.Template_GetShadows(_Id) or _GfxSet.Shad
	
	-- the transition params of light and fog have no beneficial effect here
	-- they are disabled and simulated instead, to prevent them from interfering with the skript
	-- all other transition params MUST be usdes normaly
	WeatherExtensions.Display_GfxSetSetRainEffectStatus(_Id, gfxset.RainTran.Min, gfxset.RainTran.Max, gfxset.Rain)
	WeatherExtensions.Display_GfxSetSetSnowEffectStatus(_Id, gfxset.SnowTran.Min, gfxset.SnowTran.Max, gfxset.Snow)
	WeatherExtensions.Display_GfxSetSetSnowStatus(_Id, gfxset.IceTran.Min, gfxset.IceTran.Max, gfxset.Ice)
	WeatherExtensions.Display_GfxSetSetFogParams(_Id, 0.0, 0.0, gfxset.FogFlag, _GfxSet.Fog.R,_GfxSet.Fog.G,_GfxSet.Fog.B, _GfxSet.Dist.Min,_GfxSet.Dist.Max)
	WeatherExtensions.Display_GfxSetSetLightParams(_Id, 0.0, 0.0, shadow.X, shadow.Y, shadow.Z,  _GfxSet.Amb.R,_GfxSet.Amb.G,_GfxSet.Amb.B, _GfxSet.Dif.R,_GfxSet.Dif.G,_GfxSet.Dif.B)
	WeatherExtensions.Display_GfxSetSetSkyBox(_Id, gfxset.SkyTran.Min, gfxset.SkyTran.Max, gfxset.Sky)
end
-- ************************************************************************************************
-- assigns gfx params to a gfx id
-- ************************************************************************************************
function WeatherExtensions.GfxSetSetAll(_Id, _Rain, _Snow, _Ice, _Fog, _Dist, _Shad, _Amb, _Dif, _Sky)
	
	local gfxset = WeatherExtensions.DefaultGfxSet(_Id, _Rain, _Snow, _Ice, _Fog, _Dist, _Shad, _Amb, _Dif, _Sky)
	WeatherExtensions.GfxSets[gfxset.Id] = gfxset
	
	return gfxset
end
-- ************************************************************************************************
function WeatherExtensions.GetGfxSet(_Id)
	
	local gfxset = WeatherExtensions.GfxSets[_Id]
	
	if type(gfxset) ~= "table" then
		Panic("WeatherExtensions.GetGfxSet: Tried to access WeatherExtensions.GfxSets[ ".._Id.." ] - not a table value! The default gfx set will be returned instead.", "WARNING", false)
		gfxset = WeatherExtensions.DefaultGfxSet()
	end
	
	return gfxset
end
-- ************************************************************************************************
-- complete with default gfx set data
-- ************************************************************************************************
function WeatherExtensions.DefaultGfxSet(_Id, _Rain, _Snow, _Ice, _Fog, _Dist, _Shad, _Amb, _Dif, _Sky)

	_Id = _Id or 0
	
	return {
		Id   = _Id,
		Rain = _Rain or 0,
		Snow = _Snow or 0,
		Ice  = _Ice  or 0,
		Fog  = _Fog  or Color(152,172,182),
		Dist = _Dist or Range(5000, 28000),
		Shad = _Shad or Position(40,-15,-50),
		Amb  = _Amb  or Color(120,110,110),
		Dif  = _Dif  or Color(205,204,180),
		Sky  = _Sky  or "YSkyBox02",
		RainTran = Range(0.0,1.0),
		SnowTran = Range(0.0,0.8),
		IceTran = Range(0.0,1.0),
		FogTran = Range(0.0,1.0),
		LightTran = Range(0.0,1.0),
		SkyTran = Range(0.0,1.0),
		FogFlag = 1,
	}
end
-- ************************************************************************************************
-- completes new dimension with defaults
-- WIP: this should be fine
-- ************************************************************************************************
function WeatherExtensions.GetDimensionDefault(_Dim)
	
	-- do not differentiate by default but leave it as an option for the mapper
	return {
		Queue		= {},
		Overrides	= {},
		--CurrIndex	= 1,	-- queue index (init in .Start)
		--PrevGfx	= 1,	-- prev gfx id (init in .Start)
		--CurrId	= 1,	-- state id (init in. Start)
		Counter		= 0,
		TransitionCounter	= 0,
		--SkipWeatherUpdades = true, -- set true if the dimension has no influence on the actual weather state
	}
end
-- ************************************************************************************************
function WeatherExtensions.GetDimension(_Dim)
	
	if type(_Dim) ~= "number" then
		Panic("WeatherExtensions.GetDimension: _Dim must be a number value!")
		return
	end
	
	local dimension = WeatherExtensions.Dimensions[_Dim]
	
	if type(dimension) ~= "table" then
		Panic("WeatherExtensions.GetDimension: Tried to access WeatherExtensions.Dimensions[ ".._Dim.." ] - not a table value!")
		return
	end
	
	return dimension
end
-- ************************************************************************************************
-- adds new element to dimension - params in sec
-- WIP: this should be fine - the mapper can do what he wants, but gets warned if he tries something stupid
-- ************************************************************************************************
function WeatherExtensions.AddElementToDimension(_Dim, _Id, _Dur, _Per, _Gfx, _Fore, _Tran, _Index)
	
	_Dim = _Dim or 1

	-- make shure, all dimensions from 0 to _Dim are existing
	-- it does not matter if they are empty, but they need to exist
	for i = 1, _Dim do
		
		-- create dimension if not yet existing
		if not WeatherExtensions.Dimensions[i] then
			WeatherExtensions.Dimensions[i] = WeatherExtensions.GetDimensionDefault(i)
			
			if i < _Dim then
				Panic("WeatherExtensions.AddElementToDimension: You may have created an empty dimension. This wont crash the game but can decrease performance. If you create dimensions in a 'wrong' order, you can ignore this message.", "WARNING", false)
			end
		end
	end
	
	local dimension = WeatherExtensions.GetDimension(_Dim)
	
	-- create element, auto complete with defaults
	local element = WeatherExtensions.Template_GetElementDefault(_Dim, _Id, _Dur, _Gfx, _Fore, _Tran)
	
	if _Per == 1 then
		
		local n = table.getn(dimension.Queue) + 1
		_Index = _Index or n
		table.insert(dimension.Queue, math.min(_Index, n), element)
	else
		
		-- the order is important:
		-- 1. save curr elements gfx
		dimension.PrevGfx = WeatherExtensions.GetCurrElement(_Dim).Gfx
		
		-- 2. insert new element
		table.insert(dimension.Overrides, 1, element)
		
		-- 3. initiate transition
		WeatherExtensions.TransitionUpdate(_Dim)
		
		-- this can be set if no actual weather update is nesseccary, for example a daytime change
		if not dimension.SkipWeatherUpdades then
			WeatherExtensions.WeatherUpdateCounter = 0
		end
	end
end
-- ************************************************************************************************
-- remove element
-- ************************************************************************************************
function WeatherExtensions.RemovePeriodicElementFromDimension(_Dim, _Index)
	WeatherExtensions.RemoveElementFromDimension(_Dim, 1, _Index)
end
-- ************************************************************************************************
function WeatherExtensions.RemoveNonPeriodicElementFromDimension(_Dim, _Index)
	WeatherExtensions.RemoveElementFromDimension(_Dim, 0, _Index)
end
-- ************************************************************************************************
function WeatherExtensions.RemoveElementFromDimension(_Dim, _Per, _Index)
	
	local dimension =  WeatherExtensions.GetDimension(_Dim)
	
	if _Per == 1 then
		
		-- save some data in case of a transition
		local index = dimension.CurrIndex
		local gfx = dimension.Queue[_Index].Gfx
		table.remove(dimension.Queue, _Index)
		
		if dimension.CurrIndex > table.getn(dimension.Queue) then
			dimension.CurrIndex = 1
		end
		
		-- use a saved value since .Index may have changed
		-- only transition if currently in periodic state
		if _Index == index and not dimension.Overrides[1] then
			
			-- manual counter reset
			dimension.Counter = 0
			
			if not dimension.SkipWeatherUpdades then
				WeatherExtensions.WeatherUpdateCounter = 0
			end
			
			-- initiate transition if delete current element
			PrevGfx = gfx
			WeatherExtensions.TransitionUpdate(_Dim)
		end
	else
		
		-- save some data in case of a transition
		local gfx = dimension.Overrides[_Index]
		
		-- only remove stuff that actually exists
		if gfx then
			
			table.remove(dimension.Overrides, _Index)
			
			if _Index == 1 then
				
				if not dimension.SkipWeatherUpdades then
					WeatherExtensions.WeatherUpdateCounter = 0
				end
				
				-- initiate transition if delete first overwrite element
				PrevGfx = gfx
				WeatherExtensions.TransitionUpdate(_Dim)
			end
		end
	end
end
-- ************************************************************************************************
-- completes new dimension element with defaults
-- ************************************************************************************************
function WeatherExtensions.GetElementDefault(_Dim, _Id, _Dur, _Gfx, _Fore, _Tran)

	-- do not differentiate by default but leave it as an option for the mapper
	local element = {}
	element.Id = _Id or 0
	element.Dur = _Dur or 420	-- 420s = 7min (WeatherTower)
	element.Gfx = _Gfx or 0
	element.Fore = _Fore or 5	-- s5 defaults
	element.Tran = _Tran or 10	-- s5 defaults

	-- convert sec to tick for HiResJob
	element.Tran = element.Tran * 10
	element.Fore = element.Fore * 10
	element.Dur  = element.Dur  * 10
	
	-- do no more checks, since the mapper cant break something here
	return element
end
-- ************************************************************************************************
-- ubi like
-- ************************************************************************************************
function WeatherExtensions.GetElementDefaultUbi(_Dim, _Id, _Dur, _Gfx, _Fore, _Tran)
	
	local element = WeatherExtensions.GetElementDefault(_Dim, _Id, _Dur, _Gfx, _Fore, _Tran)
	
	-- ubi: forerun gets added to duration, duration must be >= transition
	element.Dur = math.max(element.Dur + element.Fore, element.Tran)

	return element
end
-- ************************************************************************************************
-- returns the current and periodic element of given dimension
-- these are the same if no overwrite element is set
-- ************************************************************************************************
function WeatherExtensions.GetCurrElement(_Dim)
	
	local dimension = WeatherExtensions.GetDimension(_Dim)
	
	local overwriteelement	= dimension.Overrides[1]
	local periodicelement	= dimension.Queue[dimension.CurrIndex] or WeatherExtensions.Template_GetElementDefault()
	local currelement		= overwriteelement or periodicelement
	
	return currelement, periodicelement, overwriteelement
end
-- ************************************************************************************************
-- prepares .TransitionState for a transition in given dimension
-- note that transitions in transitions in the same dimension alongside a transition in another dimension are not 100% accurate anymore
-- there wont be visual glitches but its impossible to predict the exact outcome
-- this could be the case if the mapper starts a weather transition in the same time as the weathertower is activated and vice versa
-- ************************************************************************************************
function WeatherExtensions.TransitionUpdate(_Dim)
	
	WeatherExtensions.GetDimension(_Dim).TransitionCounter = 0
	local nd = table.getn(WeatherExtensions.Dimensions)
	
	local transitionstate = WeatherExtensions.GetTransitionState()
	
	-- look at the diagram to understand whats happening
	local jmax   = 2 ^ nd
	local jstep  = 2 ^ _Dim
	local offset = 2 ^ (_Dim-1)
	local kmax   = offset - 1 --2 ^ (_Dim-1) - 1
	
	-- do not overwrite the whole TransitionState, just the direction in which the dimension expands
	for j = 1, jmax, jstep do
		for k = 0, kmax do
			WeatherExtensions.TransitionState[j + k + offset] = transitionstate[j + k + offset]
		end
	end
end
-- ************************************************************************************************
-- creates a transitionstate based on current data
-- does not return WeatherExtensions.TransitionState !
-- ************************************************************************************************
function WeatherExtensions.GetTransitionState()
	
	local nd = table.getn(WeatherExtensions.Dimensions)
	
	local currelement = {}
	local transitionstate = {}
	
	local jmax   = 2 ^ nd

	-- get which gfx sets to use
	for i = 1, nd do
		
		local dimension = WeatherExtensions.GetDimension(i)
		currelement[i] = WeatherExtensions.GetCurrElement(i)
		
		-- look at the diagram to understand whats happening
		local jstep  = 2 ^ i
		local offset = 2 ^ (i-1)
		local kmax   = offset - 1 --2 ^ (i-1) - 1
		
		for j = 1, jmax, jstep do
			for k = 0, kmax do
			
				transitionstate[j + k]			= (transitionstate[j + k] or 0)			 + dimension.PrevGfx
				transitionstate[j + k + offset]	= (transitionstate[j + k + offset] or 0) + currelement[i].Gfx
			end
		end
	end
	
	-- get actual gfx set data
	for i = 1, table.getn(transitionstate) do
		transitionstate[i] = WeatherExtensions.CopyGfxSet(WeatherExtensions.GetGfxSet(transitionstate[i]))
	end
	
	-- calculate a complete transition state
	for i = 1, nd do
		
		local dimension = WeatherExtensions.GetDimension(i)
		
		-- linear lerp with limit
		local factor = math.min(dimension.TransitionCounter / currelement[i].Tran, 1)
		
		-- look at the diagram to understand whats happening
		--local amount = math.pow(2, nd-1) -- not optimized
		local jstep  = 2 ^ i
		local offset = 2 ^ (i-1)
		local kmax   = offset - 1 --2 ^ (i-1) - 1
		
		for j = 1, jmax, jstep do
			for k = 0, kmax do
				transitionstate[j + k] = WeatherExtensions.LerpGfxSet(transitionstate[j + k], transitionstate[j + k + offset], factor)
			end
		end
	end
	
	return transitionstate
end
-- ************************************************************************************************************************************************************************************************
--																									start
-- ************************************************************************************************************************************************************************************************
function WeatherExtensions.Start(...)
	
	local gfx = 0
	
	for i = 1, table.getn(WeatherExtensions.Dimensions) do
		
		local index = arg[i] or 1
		local dimension = WeatherExtensions.GetDimension(i)
		
		dimension.CurrIndex = math.max(math.min(index, table.getn(dimension.Queue)), 1)
		
		local element = WeatherExtensions.GetCurrElement(i)
		
		-- previous values are initiated as the current values at start
		dimension.PrevGfx   = element.Gfx
		dimension.CurrId    = element.Id
		
		gfx = gfx + dimension.PrevGfx
	end
	
	-- (re)set transition states
	-- do this after CurrIndex was initialized
	WeatherExtensions.TransitionState = WeatherExtensions.GetTransitionState()
	
	-- its important to update the previous display gfx set as well
	WeatherExtensions.CurrGfx = gfx
	WeatherExtensions.PrevGfx = gfx
	
	-- activate display gfx sets and start the actual job
	Display.SetRenderUseGfxSets(1)
	WeatherExtensions.JobId = StartSimpleHiResJob(WeatherExtensions.Job)
end
-- ************************************************************************************************
-- resume
-- ************************************************************************************************
function WeatherExtensions.WIP_Resume()
	
	if not WeatherExtensions.JobId then
		WeatherExtensions.Start()
	else
		WeatherExtensions.JobId = StartSimpleHiResJob(WeatherExtensions.Job)
	end
end
-- ************************************************************************************************
-- pause
-- ************************************************************************************************
function WeatherExtensions.WIP_Pause()
	
	EndJob(WeatherExtensions.JobId)
	WeatherExtensions.JobId = true
end
-- ************************************************************************************************
-- updates display gfx sets and weather
-- ************************************************************************************************
function WeatherExtensions.Job()
	
	-- amount of dimensions
	local nd = table.getn(WeatherExtensions.Dimensions)
	
	local currperiod  = {}
	local currelement = {}
	local prevgfx = {}
	local eid = {}
	
	local gfx = 0
	-- WIP: this becomes redundant if we update the shadows every tick
	local updategfxset = false
	local jmax   = 2 ^ nd
	
	-- for every dimension ...
	for i = 1, nd do
		
		local dimension = WeatherExtensions.GetDimension(i)
		
		currelement[i], currperiod[i] = WeatherExtensions.GetCurrElement(i)
		prevgfx[i] = dimension.PrevGfx
		
		local element = currelement[i]
		
		gfx = gfx + element.Gfx
		
		-- ... do transition if nesseccary
		if dimension.TransitionCounter < element.Tran then
			
			-- if forerun is over
			if dimension.TransitionCounter >= element.Fore and dimension.CurrId ~= element.Id then
				
				-- set current state and trigger event
				WeatherExtensions.Event_OnStateChanged(i, dimension.CurrId, element.Id)
				dimension.CurrId = element.Id
			end
			
			-- this is a 100% accurate linear lerp
			local factor = 1 / (element.Tran - dimension.TransitionCounter)
			
			dimension.TransitionCounter = dimension.TransitionCounter + 1
			updategfxset = true
			
			-- look at the diagram to understand whats happening
			local jstep  = 2 ^ i
			local offset = 2 ^ (i-1)
			local kmax   = offset - 1 --2 ^ (i-1) - 1
			
			for j = 1, jmax, jstep do
				for k = 0, kmax do
					WeatherExtensions.TransitionState[j + k] = WeatherExtensions.LerpGfxSet(WeatherExtensions.TransitionState[j + k], WeatherExtensions.TransitionState[j + k + offset], factor)
				end
			end
		end
	end
	
	-- save prev gfx set
	if gfx ~= WeatherExtensions.CurrGfx then
		
		-- set current display gfx and trigger event
		WeatherExtensions.PrevGfx = WeatherExtensions.CurrGfx
		WeatherExtensions.CurrGfx = gfx
		WeatherExtensions.Event_OnGfxChanged(WeatherExtensions.PrevGfx, WeatherExtensions.CurrGfx)
	end
	
	-- update current gfx set for color update
	if updategfxset then
		WeatherExtensions.UpdateDisplayGfxSet(WeatherExtensions.CurrGfx, WeatherExtensions.TransitionState[1])
		WeatherExtensions.UpdateDisplayGfxSet(WeatherExtensions.PrevGfx, WeatherExtensions.TransitionState[1])
	end
	
	WeatherExtensions.WeatherUpdateCounter = WeatherExtensions.WeatherUpdateCounter - 1
	
	-- update actual weather every 100 sec or on demand
	-- this is only nesseccary for the weather effects
	if WeatherExtensions.WeatherUpdateCounter <= 0 then
		
		-- reset weather update counter
		local id, fore, tran = WeatherExtensions.Template_GetWeatherStateAndTransition()
		fore = fore or 50
		tran = tran or 100
		WeatherExtensions.WeatherUpdateCounter = math.max(1000, tran)
		
		-- update actual weather
		WeatherExtensions.Logic_AddWeatherElement(id, WeatherExtensions.WeatherUpdateCounter/10, 0, gfx, fore/10, tran/10)
	end
	
	WeatherExtensions.Event_EveryTick()
	
	-- for every dimension again
	for i = 1, nd do
		
		local dimension = WeatherExtensions.GetDimension(i)

		-- count up progress
		dimension.Counter = dimension.Counter + 1
		
		-- initiate a weaterchange if current weather state has ran out
		if dimension.Counter >= currperiod[i].Dur then
			
			-- reset counter
			dimension.Counter = 0
			
			-- get next weather state
			dimension.CurrIndex = dimension.CurrIndex + 1
			
			if dimension.CurrIndex > table.getn(dimension.Queue) then
				dimension.CurrIndex = 1
			end
			
			-- update data if current weather is periodic
			if not dimension.Overrides[1] then
			
				-- save prev weather state for transition
				dimension.PrevGfx = currperiod[i].Gfx
				
				-- update actual weather in next tick
				if not dimension.SkipWeatherUpdades then
					WeatherExtensions.WeatherUpdateCounter = 0
				end
				
				-- initiate transition
				WeatherExtensions.TransitionUpdate(i)
			end
		end
		
		-- decrement all overrides
		for j = table.getn(dimension.Overrides), 1, -1 do

			local override = dimension.Overrides[j]
			override.Dur = override.Dur - 1
			
			-- remove override if its durarion has ran out
			if override.Dur <= 0 then
				
				-- if its the first element
				if j == 1 then
					
					if not dimension.SkipWeatherUpdades then
						WeatherExtensions.WeatherUpdateCounter = 0
					end
					
					-- initiate transition
					WeatherExtensions.TransitionUpdate(i)
				end
				
				table.remove(dimension.Overrides, j)
			end
		end
	end
end
-- ************************************************************************************************
-- utility
-- ************************************************************************************************
function WeatherExtensions.LerpGfxSet(_a, _b, _factor)
	
	return {
		Fog  = LerpTable(_a.Fog, _b.Fog, _factor),
		Dist = LerpTable(_a.Dist, _b.Dist, _factor),
		Amb  = LerpTable(_a.Amb, _b.Amb, _factor),
		Dif  = LerpTable(_a.Dif, _b.Dif, _factor),
		Shad = LerpTable(_a.Shad, _b.Shad, _factor),
	}
end
-- ************************************************************************************************
-- does only copy the nesseccary entries for manual transition calculation
-- ************************************************************************************************
function WeatherExtensions.CopyGfxSet(_a)
	
	return {
		Fog  = _a.Fog,
		Dist = _a.Dist,
		Amb  = _a.Amb,
		Dif  = _a.Dif,
		Shad = _a.Shad,
	}
end
-- ************************************************************************************************
function Panic(_text, _prefix, _break)
	
	_text = _text or "unknown error"
	_prefix = _prefix or "ERROR"
	_break = _break or true
	
	if LuaDebugger then
	
		LuaDebugger.Log(_prefix..": ".._text)
		
		if _break then
			LuaDebugger.Break()
		end
		
		return
	end
	
	if _break then
	
		assert(false, _prefix..": ".._text)
		return
	end
	
	GUI.AddNote(_prefix..": ".._text)
end
-- ************************************************************************************************
function Color(_R,_G,_B)
	return {R=_R, G=_G, B=_B}
end
-- ************************************************************************************************
function Range(_A, _B)
	return {Min=_A, Max=_B}
end
-- ************************************************************************************************
function Position(_X, _Y, _Z)
	return {X=_X, Y=_Y, Z=_Z}
end
-- ************************************************************************************************
function WeatherExtensions.Shadow(_Gfx)
	
	local gfxset = WeatherExtensions.GetGfxSet(_Gfx)
	return gfxset.Shad
end
-- ************************************************************************************************
function LerpTable(_a, _b, _factor)
	
	local out = {}
	for k,v in pairs(_a) do
		
		if type(v) == "table" then
			local sub = LerpTable(_a[k], _b[k], _factor)
			out[k] = sub
		elseif type(v) == "number" then
			out[k] = Lerp(_a[k], _b[k], _factor)
		else
			-- this way bools are possible too
			out[k] = (_factor > 0.5 and {_a[k]} or {_b[k]})[1]
		end
	end
	
	return out;
end
-- ************************************************************************************************
function Lerp(_a, _b, _factor)
	return _a + (_b - _a) * _factor
end
-- ************************************************************************************************************************************************************************************************
--																								comfort & safety
-- ************************************************************************************************************************************************************************************************
function WeatherExtensions.Event_OnStateChanged(_Dim, _OldId, _NewId)
	
	-- call template
	WeatherExtensions.Template_OnStateChanged(_Dim, _OldId, _NewId)
	
	-- call weather callback if found
	if WeatherCallbacks and WeatherCallbacks.OnStateChanged then
		WeatherCallbacks.OnStateChanged(_Dim, _OldId, _NewId)
	end
end
-- ************************************************************************************************
function WeatherExtensions.Event_OnGfxChanged(_OldId, _NewId)
	
	-- call template
	WeatherExtensions.Template_OnGfxChanged(_OldId, _NewId)
	
	-- call weather callback if found
	if WeatherCallbacks and WeatherCallbacks.OnGfxIdChanged then
		WeatherCallbacks.OnGfxIdChanged(_OldId, _NewId)
	end
end
-- ************************************************************************************************
function WeatherExtensions.Event_EveryTick()
	WeatherExtensions.Template_EveryTick()
end
-- ************************************************************************************************
function WeatherExtensions.GetCurrentState(_Dim)
	
	local dimension = WeatherExtensions.GetDimension(_Dim)
	return dimension.CurrId
end
-- ************************************************************************************************
function WeatherExtensions.GetTimeToNextElement(_Dim)
	
	local _, periodicelement, overwriteelement = WeatherExtensions.GetCurrElement(_Dim)
	local dimension = WeatherExtensions.GetDimension(_Dim)
	
	if overwriteelement then
		
		-- non periodic is already counting down, just devide by 10 to get seconds from ticks
		return (overwriteelement.Dur) / 10
	end
	
	-- for periodic return duration - time it already ran, also devide by 10 to get seconds from ticks
	return (periodicelement.Dur - dimension.Counter) / 10
end
-- ************************************************************************************************
function WeatherExtensions.GetNextElement(_Dim)
	
	-- handle first dimension as default s5 weather
	local _, periodicelement, overwriteelement = WeatherExtensions.GetCurrElement(_Dim)
	local dimension = WeatherExtensions.GetDimension(_Dim)
	
	-- if weather is not periodic
	if overwriteelement then
		
		local duration = overwriteelement.Dur
		
		-- for all non periodic weathers exept the first
		for i = 2, table.getn(dimension.Overrides) do
			
			local override = dimension.Overrides[i]
			
			-- return the first which duration is longer than the current one
			if override.Dur > duration then
				return override
			end
		end
		
		-- decrease duration of current weather about duration of next periodicweathers down to 0
		local index = dimension.CurrIndex
		
		-- decreas the first periodicweathers duration by the time it already ran
		duration = duration - (periodicelement.Dur - dimension.Counter)
		
		while duration > 0 do
			
			index = index + 1
			
			if index > table.getn(dimension.Queue) then
				index = 1
			end
			
			periodicelement = dimension.Queue[index] or WeatherExtensions.Template_GetElementDefault(1, 1, nil, 1)
			duration = duration - periodicelement.Dur
		end
		
		-- the periodicelement that stands at duration <= 0 will be the next weather
		return periodicelement
	end
	
	-- if weather is periodic, get the next periodicelement
	local index = dimension.CurrIndex + 1
	
	if index > table.getn(dimension.Queue) then
		index = 1
	end
	
	local periodicelement = dimension.Queue[index] or WeatherExtensions.Template_GetElementDefault(1, 1, nil, 1)
	
	-- and return its id
	return periodicelement
end
-- ************************************************************************************************************************************************************************************************
--																							template functions
-- ************************************************************************************************************************************************************************************************
-- first dimension will be handled like s5 weather by default
-- overwrite these by your needs and likings
-- ************************************************************************************************
function WeatherExtensions.Template_GetNextWeatherState()
	
	-- handle first dimension as default s5 weather
	return WeatherExtensions.GetNextElement(1).Id
end
-- ************************************************************************************************
function WeatherExtensions.Template_GetTimeToNextWeatherState()
	
	-- handle first dimension as default s5 weather
	return WeatherExtensions.GetTimeToNextElement(1)
end
-- ************************************************************************************************
function WeatherExtensions.Template_GetWeatherStateAndTransition()
	
	-- handle first dimension as default s5 weather
	local element = WeatherExtensions.GetCurrElement(1)
	
	return element.Id, element.Fore, element.Tran
end
-- ************************************************************************************************
function WeatherExtensions.Template_GetShadows(_Gfx)
	return nil
end
-- ************************************************************************************************
function WeatherExtensions.Template_OnStateChanged(_Dim, _OldId, _NewId)
	return nil
end
-- ************************************************************************************************
function WeatherExtensions.Template_OnGfxChanged(_OldId, _NewId)
	return nil
end
-- ************************************************************************************************
function WeatherExtensions.Template_EveryTick()
	return nil
end
-- ************************************************************************************************
function WeatherExtensions.Template_GetElementDefault(_Dim, _Id, _Dur, _Gfx, _Fore, _Tran)
	
	-- ubi is default, use .GetElementDefault for more freedom
	return WeatherExtensions.GetElementDefault_Ubi(_Dim, _Id, _Dur, _Gfx, _Fore, _Tran)
end
-- ************************************************************************************************
WeatherExtensions.Init()