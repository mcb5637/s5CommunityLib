-- ************************************************************************************************
-- 3d example gfx sets for WeatherExtensions by RobbiTheFox
-- v 1.0
-- 
-- D1: temperature {hot, warm, cold, freezing}
-- D2: humidity    {dry, wet}
-- D3: day time    {dawn, day, set, night}
-- 
-- ************************************************************************************************
-- init
-- ************************************************************************************************
function InitNormal3DExample()
	
	WeatherExtensions.Template_GetWeatherState = function(tid, hid)
		
		-- get temperature
		local tid = tid or WeatherExtensions.GetCurrElement(1).Id
		
		-- cold ?
		if tid == 3 then
			-- winter - no matter what
			return 3
		end
		
		-- get humidity
		local hid = hid or WeatherExtensions.GetCurrElement(2).Id
		
		-- wet ?
		if hid == 2 then
			-- rain
			return 2
		end
		
		-- summer
		return 1
	end
	
	WeatherExtensions.Template_GetNextWeatherState = function()
		
		local t1 = WeatherExtensions.GetTimeToNextElement(1)
		local t2 = WeatherExtensions.GetTimeToNextElement(2)
		
		if t1 <= t2 then
			
			return WeatherExtensions.Template_GetWeatherState( WeatherExtensions.GetNextElement(1).Id, WeatherExtensions.GetCurrElement(2).Id )
			
		end
		
		return WeatherExtensions.Template_GetWeatherState( WeatherExtensions.GetCurrElement(1).Id, WeatherExtensions.GetNextElement(2).Id )
	end
	
	WeatherExtensions.Template_GetTimeToNextWeatherState = function()
		
		local t1 = WeatherExtensions.GetTimeToNextElement(1)
		local t2 = WeatherExtensions.GetTimeToNextElement(2)
		
		return math.min(t1, t2)
	end

	WeatherExtensions.Template_GetElementDefault = function(_Dim, _Id, _Dur, _Gfx, _Fore, _Tran)
		return WeatherExtensions.GetElementDefault(_Dim, _Id, _Dur, _Gfx, _Fore, _Tran)
	end
end
-- ************************************************************************************************
-- comfort
-- ************************************************************************************************
function AddPeriodicHot(_Dur, _Index)
	AddTemperatureElement(1, _Dur, 1, 1, nil, nil, _Index)
end
function StartHot(_Dur)
	AddTemperatureElement(1, _Dur, 0, 1, nil, nil, _Index)
end
-- ************************************************************************************************
function AddPeriodicWarm(_Dur, _Index)
	AddTemperatureElement(2, _Dur, 1, 2, nil, nil, _Index)
end
function StartWarm(_Dur)
	AddTemperatureElement(2, _Dur, 0, 2, nil, nil, _Index)
end
-- ************************************************************************************************
function AddPeriodicCold(_Dur, _Index)
	AddTemperatureElement(3, _Dur, 1, 3, nil, nil, _Index)
end
function StartCold(_Dur)
	AddTemperatureElement(3, _Dur, 0, 3, nil, nil, _Index)
end
-- ************************************************************************************************
function AddTemperatureElement(_Id, _Dur, _Per, _Gfx, _Fore, _Tran, _Index)
	
	_Id = _Id or 1
	_Fore = _Fore or 15
	_Tran = _Tran or 30
	
	WeatherExtensions.AddElementToDimension(1, _Id, _Dur, _Per, _Gfx, _Fore, _Tran, _Index)
end
-- ************************************************************************************************
function AddPeriodicDry(_Dur, _Index)
	AddHumidityElement(1, _Dur, 1, 0, nil, nil, _Index)
end
function StartDry(_Dur)
	AddHumidityElement(1, _Dur, 0, 0, nil, nil, _Index)
end
-- ************************************************************************************************
function AddPeriodicWet(_Dur, _Index)
	AddHumidityElement(2, _Dur, 1, 3, nil, nil, _Index)
end
function StartWet(_Dur)
	AddHumidityElement(2, _Dur, 0, 3, nil, nil, _Index)
end
-- ************************************************************************************************
function AddHumidityElement(_Id, _Dur, _Per, _Gfx, _Fore, _Tran, _Index)
	
	_Id = _Id or 1
	--_Fore = _Fore or 15
	--_Tran = _Tran or 30
	
	WeatherExtensions.AddElementToDimension(2, _Id, _Dur, _Per, _Gfx, _Fore, _Tran, _Index)
end
-- ************************************************************************************************
function AddPeriodicDawn(_Dur, _Index)
	AddDayTimeElement(1, _Dur, 1, 0, nil, nil, _Index)
end
function StartDawn(_Dur)
	AddDayTimeElement(1, _Dur, 0, 0, nil, nil, _Index)
end
-- ************************************************************************************************
function AddPeriodicDay(_Dur, _Index)
	AddDayTimeElement(2, _Dur, 1, 6, nil, nil, _Index)
end
function StartDay(_Dur)
	AddDayTimeElement(2, _Dur, 0, 6, nil, nil, _Index)
end
-- ************************************************************************************************
function AddPeriodicSunSet(_Dur, _Index)
	AddDayTimeElement(3, _Dur, 1, 12, nil, nil, _Index)
end
function StartSunSet(_Dur)
	AddDayTimeElement(3, _Dur, 0, 12, nil, nil, _Index)
end
-- ************************************************************************************************
function AddPeriodicNight(_Dur, _Index)
	AddDayTimeElement(4, _Dur, 1, 18, nil, nil, _Index)
end
function StartNight(_Dur)
	AddDayTimeElement(4, _Dur, 0, 18, nil, nil, _Index)
end
-- ************************************************************************************************
function AddDayTimeElement(_Id, _Dur, _Per, _Gfx, _Fore, _Tran, _Index)
	
	_Id = _Id or 1
	_Fore = _Fore or 15
	_Tran = _Tran or 30
	
	WeatherExtensions.AddElementToDimension(3, _Id, _Dur, _Per, _Gfx, _Fore, _Tran, _Index)
end
-- ************************************************************************************************
function SetupNormal3DExampleGfxSet()
	
	-- hot, dry, dawn
	local f = 0.85
	local id = 1
	Display.GfxSetSetSkyBox(id, 0.0, 1.0, "YSkyBox07")
	Display.GfxSetSetRainEffectStatus(id, 0.0, 1.0, 0)
	Display.GfxSetSetSnowStatus(id, 0, 1.0, 0)
	Display.GfxSetSetSnowEffectStatus(id, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(id, 0.0, 1.0, 1, 188*f,149*f,180*f, 7500,30500)
	Display.GfxSetSetLightParams(id,  0.0, 1.0, 40, 15, -25,  139*f,122*f,131*f,  206*f,186*f,195*f)
	-- warm, dry, dawn
	f = 0.85
	id = id + 1
	Display.GfxSetSetSkyBox(id, 0.0, 1.0, "YSkyBox02")
	Display.GfxSetSetRainEffectStatus(id, 0.0, 1.0, 0)
	Display.GfxSetSetSnowStatus(id, 0, 1.0, 0)
	Display.GfxSetSetSnowEffectStatus(id, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(id, 0.0, 1.0, 1, 182*f,152*f,172*f, 8500,47500)
	Display.GfxSetSetLightParams(id,  0.0, 1.0, 40, 15, -25,  120*f,110*f,110*f,  205*f,180*f,204*f)
	-- cold, dry, dawn
	f = 0.85
	id = id + 1
	Display.GfxSetSetSkyBox(id, 0.0, 1.0, "YSkyBox02")
	Display.GfxSetSetRainEffectStatus(id, 0.0, 1.0, 0)
	Display.GfxSetSetSnowStatus(id, 0, 1.0, 1)
	Display.GfxSetSetSnowEffectStatus(id, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(id, 0.0, 1.0, 1, 182*f,152*f,172*f, 7500,30000)
	Display.GfxSetSetLightParams(id,  0.0, 1.0,  40, 15, -15,  164*f,116*f,144*f, 255*f,202*f,234*f)
	
	-- hot, wet, dawn
	f = 0.75
	id = id + 1
	Display.GfxSetSetSkyBox(id, 0.0, 1.0, "YSkyBox04")
	Display.GfxSetSetRainEffectStatus(id, 0.0, 1.0, 1)
	Display.GfxSetSetSnowStatus(id, 0, 1.0, 0)
	Display.GfxSetSetSnowEffectStatus(id, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(id, 0.0, 1.0, 1, 188*f,149*f,180*f, 6000,22000)
	Display.GfxSetSetLightParams(id,  0.0, 1.0, 40, 15, -25,  139*f,122*f,131*f,  206*f,186*f,195*f)
	-- warm, wet, dawn
	f = 0.75
	id = id + 1
	Display.GfxSetSetSkyBox(id, 0.0, 1.0, "YSkyBox04")
	Display.GfxSetSetRainEffectStatus(id, 0.0, 1.0, 1)
	Display.GfxSetSetSnowStatus(id, 0, 1.0, 0)
	Display.GfxSetSetSnowEffectStatus(id, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(id, 0.0, 1.0, 1, 142*f,102*f,132*f, 6000,16000)
	Display.GfxSetSetLightParams(id,  0.0, 1.0, 40, 15, -25,  120*f,110*f,110*f,  205*f,180*f,204*f)
	-- cold, wet, dawn
	f = 0.75
	id = id + 1
	Display.GfxSetSetSkyBox(id, 0.0, 1.0, "YSkyBox01")
	Display.GfxSetSetRainEffectStatus(id, 0.0, 1.0, 0)
	Display.GfxSetSetSnowStatus(id, 0, 1.0, 1)
	Display.GfxSetSetSnowEffectStatus(id, 0.0, 0.8, 1)
	Display.GfxSetSetFogParams(id, 0.0, 1.0, 1, 182*f,152*f,172*f, 6000,22000)
	Display.GfxSetSetLightParams(id,  0.0, 1.0,  40, 15, -15,  164*f,116*f,144*f,  255*f,202*f,234*f)
	
	
	
	-- hot, dry, day
	id = id + 1
	Display.GfxSetSetSkyBox(id, 0.0, 1.0, "YSkyBox07")
	Display.GfxSetSetRainEffectStatus(id, 0.0, 1.0, 0)
	Display.GfxSetSetSnowStatus(id, 0, 1.0, 0)
	Display.GfxSetSetSnowEffectStatus(id, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(id, 0.0, 1.0, 1, 188,180,149, 9000,36000)
	Display.GfxSetSetLightParams(id,  0.0, 1.0, 40, -15, -50,  139,131,122,  206,195,186)
	-- warm, dry, day
	id = id + 1
	Display.GfxSetSetSkyBox(id, 0.0, 1.0, "YSkyBox02")
	Display.GfxSetSetRainEffectStatus(id, 0.0, 1.0, 0)
	Display.GfxSetSetSnowStatus(id, 0, 1.0, 0)
	Display.GfxSetSetSnowEffectStatus(id, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(id, 0.0, 1.0, 1, 152,172,182, 10000,56000)
	Display.GfxSetSetLightParams(id,  0.0, 1.0, 40, -15, -50,  120,110,110,  205,204,180)
	-- cold, dry, day
	id = id + 1
	Display.GfxSetSetSkyBox(id, 0.0, 1.0, "YSkyBox02")
	Display.GfxSetSetRainEffectStatus(id, 0.0, 1.0, 0)
	Display.GfxSetSetSnowStatus(id, 0, 1.0, 1)
	Display.GfxSetSetSnowEffectStatus(id, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(id, 0.0, 1.0, 1, 152,172,182, 9000,33000)
	Display.GfxSetSetLightParams(id,  0.0, 1.0,  40, -15, -25,  116,144,164, 255,234,202)
	
	-- hot, wet, day
	id = id + 1
	Display.GfxSetSetSkyBox(id, 0.0, 1.0, "YSkyBox04")
	Display.GfxSetSetRainEffectStatus(id, 0.0, 1.0, 1)
	Display.GfxSetSetSnowStatus(id, 0, 1.0, 0)
	Display.GfxSetSetSnowEffectStatus(id, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(id, 0.0, 1.0, 1, 149,180,188, 6000,22000)
	Display.GfxSetSetLightParams(id,  0.0, 1.0, 40, -15, -50,  122,131,139,  186,195,206)
	-- warm, wet, day
	id = id + 1
	Display.GfxSetSetSkyBox(id, 0.0, 1.0, "YSkyBox04")
	Display.GfxSetSetRainEffectStatus(id, 0.0, 1.0, 1)
	Display.GfxSetSetSnowStatus(id, 0, 1.0, 0)
	Display.GfxSetSetSnowEffectStatus(id, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(id, 0.0, 1.0, 1, 102,132,142, 6000,16000)
	Display.GfxSetSetLightParams(id,  0.0, 1.0, 40, -15, -50,  120,110,110,  205,204,180)
	-- cold, wet, day
	id = id + 1
	Display.GfxSetSetSkyBox(id, 0.0, 1.0, "YSkyBox01")
	Display.GfxSetSetRainEffectStatus(id, 0.0, 1.0, 0)
	Display.GfxSetSetSnowStatus(id, 0, 1.0, 1)
	Display.GfxSetSetSnowEffectStatus(id, 0.0, 0.8, 1)
	Display.GfxSetSetFogParams(id, 0.0, 1.0, 1, 152,172,182, 6000,22000)
	Display.GfxSetSetLightParams(id,  0.0, 1.0,  40, -15, -25,  116,144,164, 255,234,202)
	
	
	
	-- hot, dry, sun set
	f = 0.85
	id = id + 1
	Display.GfxSetSetSkyBox(id, 0.0, 1.0, "YSkyBox07")
	Display.GfxSetSetRainEffectStatus(id, 0.0, 1.0, 0)
	Display.GfxSetSetSnowStatus(id, 0, 1.0, 0)
	Display.GfxSetSetSnowEffectStatus(id, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(id, 0.0, 1.0, 1, 188*f,149*f,180*f, 7500,30500)
	Display.GfxSetSetLightParams(id,  0.0, 1.0, -40, -15, -25,  139*f,122*f,131*f,  206*f,186*f,195*f)
	-- warm, dry, sun set
	f = 0.85
	id = id + 1
	Display.GfxSetSetSkyBox(id, 0.0, 1.0, "YSkyBox02")
	Display.GfxSetSetRainEffectStatus(id, 0.0, 1.0, 0)
	Display.GfxSetSetSnowStatus(id, 0, 1.0, 0)
	Display.GfxSetSetSnowEffectStatus(id, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(id, 0.0, 1.0, 1, 182*f,152*f,172*f, 8500,47500)
	Display.GfxSetSetLightParams(id,  0.0, 1.0, -40, -15, -25,  120*f,110*f,110*f,  205*f,180*f,204*f)
	-- cold, dry, sun set
	f = 0.85
	id = id + 1
	Display.GfxSetSetSkyBox(id, 0.0, 1.0, "YSkyBox02")
	Display.GfxSetSetRainEffectStatus(id, 0.0, 1.0, 0)
	Display.GfxSetSetSnowStatus(id, 0, 1.0, 1)
	Display.GfxSetSetSnowEffectStatus(id, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(id, 0.0, 1.0, 1, 182*f,152*f,172*f, 7500,30000)
	Display.GfxSetSetLightParams(id,  0.0, 1.0,  -40, -15, -15,  164*f,116*f,144*f, 255*f,202*f,234*f)
	
	-- hot, wet, sun set
	f = 0.75
	id = id + 1
	Display.GfxSetSetSkyBox(id, 0.0, 1.0, "YSkyBox04")
	Display.GfxSetSetRainEffectStatus(id, 0.0, 1.0, 1)
	Display.GfxSetSetSnowStatus(id, 0, 1.0, 0)
	Display.GfxSetSetSnowEffectStatus(id, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(id, 0.0, 1.0, 1, 188*f,149*f,180*f, 6000,22000)
	Display.GfxSetSetLightParams(id,  0.0, 1.0, -40, -15, -25,  139*f,122*f,131*f,  206*f,186*f,195*f)
	-- warm, wet, sun set
	f = 0.75
	id = id + 1
	Display.GfxSetSetSkyBox(id, 0.0, 1.0, "YSkyBox04")
	Display.GfxSetSetRainEffectStatus(id, 0.0, 1.0, 1)
	Display.GfxSetSetSnowStatus(id, 0, 1.0, 0)
	Display.GfxSetSetSnowEffectStatus(id, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(id, 0.0, 1.0, 1, 142*f,102*f,132*f, 6000,16000)
	Display.GfxSetSetLightParams(id,  0.0, 1.0, -40, -15, -25,  120*f,110*f,110*f,  205*f,180*f,204*f)
	-- cold, wet, sun set
	f = 0.75
	id = id + 1
	Display.GfxSetSetSkyBox(id, 0.0, 1.0, "YSkyBox01")
	Display.GfxSetSetRainEffectStatus(id, 0.0, 1.0, 0)
	Display.GfxSetSetSnowStatus(id, 0, 1.0, 1)
	Display.GfxSetSetSnowEffectStatus(id, 0.0, 0.8, 1)
	Display.GfxSetSetFogParams(id, 0.0, 1.0, 1, 182*f,152*f,172*f, 6000,22000)
	Display.GfxSetSetLightParams(id,  0.0, 1.0,  -40, -15, -15,  164*f,116*f,144*f,  255*f,202*f,234*f)
	
	
	
	-- hot, dry, night
	f = 0.65
	id = id + 1
	Display.GfxSetSetSkyBox(id, 0.0, 1.0, "YSkyBox07")
	Display.GfxSetSetRainEffectStatus(id, 0.0, 1.0, 0)
	Display.GfxSetSetSnowStatus(id, 0, 1.0, 0)
	Display.GfxSetSetSnowEffectStatus(id, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(id, 0.0, 1.0, 1, 149*f,180*f,188*f, 9000*f,36000*f)
	Display.GfxSetSetLightParams(id,  0.0, 1.0, -40, 15, -100,  122*f,131*f,139*f,  186*f,195*f,206*f)
	-- warm, dry, night
	f = 0.65
	id = id + 1
	Display.GfxSetSetSkyBox(id, 0.0, 1.0, "YSkyBox02")
	Display.GfxSetSetRainEffectStatus(id, 0.0, 1.0, 0)
	Display.GfxSetSetSnowStatus(id, 0, 1.0, 0)
	Display.GfxSetSetSnowEffectStatus(id, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(id, 0.0, 1.0, 1, 152*f,172*f,182*f, 10000*f,56000*f)
	Display.GfxSetSetLightParams(id,  0.0, 1.0, -40, 15, -100,  110*f,110*f,120*f,  180*f,204*f,205*f)
	-- cold, dry, night
	f = 0.65
	id = id + 1
	Display.GfxSetSetSkyBox(id, 0.0, 1.0, "YSkyBox02")
	Display.GfxSetSetRainEffectStatus(id, 0.0, 1.0, 0)
	Display.GfxSetSetSnowStatus(id, 0, 1.0, 1)
	Display.GfxSetSetSnowEffectStatus(id, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(id, 0.0, 1.0, 1, 182*f,152*f,172*f, 9000*f,33000*f)
	Display.GfxSetSetLightParams(id,  0.0, 1.0,  -40, 15, -50,  116*f,144*f,164*f,  202*f,234*f,255*f)
	
	-- hot, wet, night
	f = 0.6
	id = id + 1
	Display.GfxSetSetSkyBox(id, 0.0, 1.0, "YSkyBox04")
	Display.GfxSetSetRainEffectStatus(id, 0.0, 1.0, 1)
	Display.GfxSetSetSnowStatus(id, 0, 1.0, 0)
	Display.GfxSetSetSnowEffectStatus(id, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(id, 0.0, 1.0, 1, 188*f,149*f,180*f, 6000*f,22000*f)
	Display.GfxSetSetLightParams(id,  0.0, 1.0, -40, 15, -100,  122*f,131*f,139*f,  186*f,195*f,206*f)
	-- warm, wet, night
	f = 0.6
	id = id + 1
	Display.GfxSetSetSkyBox(id, 0.0, 1.0, "YSkyBox04")
	Display.GfxSetSetRainEffectStatus(id, 0.0, 1.0, 1)
	Display.GfxSetSetSnowStatus(id, 0, 1.0, 0)
	Display.GfxSetSetSnowEffectStatus(id, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(id, 0.0, 1.0, 1, 142*f,102*f,132*f, 6000*f,16000*f)
	Display.GfxSetSetLightParams(id,  0.0, 1.0, -40, 15, -100,  110*f,110*f,120*f,  180*f,204*f,205*f)
	-- cold, wet, night
	f = 0.6
	id = id + 1
	Display.GfxSetSetSkyBox(id, 0.0, 1.0, "YSkyBox01")
	Display.GfxSetSetRainEffectStatus(id, 0.0, 1.0, 0)
	Display.GfxSetSetSnowStatus(id, 0, 1.0, 1)
	Display.GfxSetSetSnowEffectStatus(id, 0.0, 0.8, 1)
	Display.GfxSetSetFogParams(id, 0.0, 1.0, 1, 152*f,172*f,182*f, 6000*f,22000*f)
	Display.GfxSetSetLightParams(id,  0.0, 1.0,  -40, 15, -50,  116*f,144*f,164*f,  202*f,234*f,255*f)
	
end