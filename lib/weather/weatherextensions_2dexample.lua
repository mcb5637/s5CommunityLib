-- ************************************************************************************************
-- night cycle gfx sets for WeatherExtensions by RobbiTheFox
-- v 1.0
-- ************************************************************************************************
-- comfort
-- ************************************************************************************************
function AddPeriodicDay(_Dur, _Index)
	AddDayTimeElement(1, _Dur, 1, 0, nil, nil, _Index)
end
function StartDay(_Dur)
	AddDayTimeElement(1, _Dur, 0, 0, nil, nil, _Index)
end
-- ************************************************************************************************
function AddPeriodicDawn(_Dur, _Index)
	AddDayTimeElement(2, _Dur, 1, 3, nil, nil, _Index)
end
function StartDawn(_Dur)
	AddDayTimeElement(2, _Dur, 0, 3, nil, nil, _Index)
end
-- ************************************************************************************************
function AddPeriodicNight(_Dur, _Index)
	AddDayTimeElement(3, _Dur, 1, 6, nil, nil, _Index)
end
function StartNight(_Dur)
	AddDayTimeElement(3, _Dur, 0, 6, nil, nil, _Index)
end
-- ************************************************************************************************
function AddDayTimeElement(_Id, _Dur, _Per, _Gfx, _Fore, _Tran, _Index)
	
	_Id = _Id or 1
	_Fore = _Fore or 15
	_Tran = _Tran or 30
	
	WeatherExtensions.AddElementToDimension(2, _Id, _Dur, _Per, _Gfx, _Fore, _Tran, _Index)
end
-- ************************************************************************************************
-- normal
-- ************************************************************************************************
WeatherExtensions.SetupNormalWeatherGfxSet = SetupNormalWeatherGfxSet
SetupNormalWeatherGfxSet = function(g)
	
	-- day
	local f = 1
	g = g or 2
	local h = 0.5
	--WeatherExtensions.SetupNormalWeatherGfxSet()
	Display.GfxSetSetSkyBox(1, 0.0, 1.0, "YSkyBox02")
	Display.GfxSetSetRainEffectStatus(1, 0.0, 1.0, 0)
	Display.GfxSetSetSnowStatus(1, 0, 1.0, 0)
	Display.GfxSetSetSnowEffectStatus(1, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(1, 0.0, 1.0, 1, 152,172,182, 5000*g,28000*g)
	Display.GfxSetSetLightParams(1,  0.0, 1.0, 40, -15, -50,  120,110,110,  205,204,180)
	
	Display.GfxSetSetSkyBox(2, 0.0, 1.0, "YSkyBox04")
	Display.GfxSetSetRainEffectStatus(2, 0.0, 1.0, 1)
	Display.GfxSetSetSnowStatus(2, 0, 1.0, 0)
	Display.GfxSetSetSnowEffectStatus(2, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(2, 0.0, 1.0, 1, 102,132,142, 3000*g,8000*g)
	Display.GfxSetSetLightParams(2,  0.0, 1.0, 40, -15, -50,  120,110,110,  205,204,180)
	
	Display.GfxSetSetSkyBox(3, 0.0, 1.0, "YSkyBox01")
	Display.GfxSetSetRainEffectStatus(3, 0.0, 1.0, 0)
	Display.GfxSetSetSnowStatus(3, 0, 1.0, 1)
	Display.GfxSetSetSnowEffectStatus(3, 0.0, 0.8, 1)
	Display.GfxSetSetFogParams(3, 0.0, 1.0, 1, 152,172,182, 3000*g,11000*g)
	Display.GfxSetSetLightParams(3,  0.0, 1.0,  40, -15, -75,  116,144,164, 255,234,202)

	-- dawn
	f = 0.85
	Display.GfxSetSetSkyBox(4, 0.0, 1.0, "YSkyBox02")
	Display.GfxSetSetRainEffectStatus(4, 0.0, 1.0, 0)
	Display.GfxSetSetSnowStatus(4, 0, 1.0, 0)
	Display.GfxSetSetSnowEffectStatus(4, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(4, 0.0, 1.0, 1, 182*f,152*f,172*f, 5000*g,28000*g)
	Display.GfxSetSetLightParams(4,  0.0, 1.0, 40, -15, -50*h,  120*f,110*f,110*f,  205*f,180*f,204*f)
	
	f = 0.75
	Display.GfxSetSetSkyBox(5, 0.0, 1.0, "YSkyBox04")
	Display.GfxSetSetRainEffectStatus(5, 0.0, 1.0, 1)
	Display.GfxSetSetSnowStatus(5, 0, 1.0, 0)
	Display.GfxSetSetSnowEffectStatus(5, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(5, 0.0, 1.0, 1, 102*f,132*f,142*f, 3000*g,8000*g)
	Display.GfxSetSetLightParams(5,  0.0, 1.0, 40, -15, -50*h,  120*f,110*f,110*f,  205*f,180*f,204*f)
	
	f = 0.85
	Display.GfxSetSetSkyBox(6, 0.0, 1.0, "YSkyBox01")
	Display.GfxSetSetRainEffectStatus(6, 0.0, 1.0, 0)
	Display.GfxSetSetSnowStatus(6, 0, 1.0, 1)
	Display.GfxSetSetSnowEffectStatus(6, 0.0, 0.8, 1)
	Display.GfxSetSetFogParams(6, 0.0, 1.0, 1, 182*f,152*f,172*f, 3000*g,11000*g)
	Display.GfxSetSetLightParams(6,  0.0, 1.0,  40, -15, -75*h,  164*f,116*f,144*f, 255*f,202*f,234*f)
	
	-- night
	f = 0.65
	Display.GfxSetSetSkyBox(7, 0.0, 1.0, "YSkyBox02")
	Display.GfxSetSetRainEffectStatus(7, 0.0, 1.0, 0)
	Display.GfxSetSetSnowStatus(7, 0, 1.0, 0)
	Display.GfxSetSetSnowEffectStatus(7, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(7, 0.0, 1.0, 1, 152*f,172*f,182*f, 5000*g,28000*g)
	Display.GfxSetSetLightParams(7,  0.0, 1.0, 40, -15, -50,  110*f,110*f,120*f,  180*f,204*f,205*f)
	
	f = 0.6
	Display.GfxSetSetSkyBox(8, 0.0, 1.0, "YSkyBox04")
	Display.GfxSetSetRainEffectStatus(8, 0.0, 1.0, 1)
	Display.GfxSetSetSnowStatus(8, 0, 1.0, 0)
	Display.GfxSetSetSnowEffectStatus(8, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(8, 0.0, 1.0, 1, 102*f,132*f,142*f, 3000*g,8000*g)
	Display.GfxSetSetLightParams(8,  0.0, 1.0, 40, -15, -50,  110*f,110*f,120*f,  180*f,204*f,205*f)
	
	f = 0.6
	Display.GfxSetSetSkyBox(9, 0.0, 1.0, "YSkyBox01")
	Display.GfxSetSetRainEffectStatus(9, 0.0, 1.0, 0)
	Display.GfxSetSetSnowStatus(9, 0, 1.0, 1)
	Display.GfxSetSetSnowEffectStatus(9, 0.0, 0.8, 1)
	Display.GfxSetSetFogParams(9, 0.0, 1.0, 1, 152*f,172*f,182*f, 3000*g,11000*g)
	Display.GfxSetSetLightParams(9,  0.0, 1.0,  40, -15, -75,  116*f,144*f,164*f, 202*f,234*f,255*f)
end
-- ************************************************************************************************
-- evelance
-- ************************************************************************************************
WeatherExtensions.SetupEvelanceWeatherGfxSet = SetupEvelanceWeatherGfxSet
SetupEvelanceWeatherGfxSet = function(g)
	
	-- day
	local f = 1
	g = g or 2
	local h = 0.5
	--WeatherExtensions.SetupEvelanceWeatherGfxSet()
	Display.GfxSetSetSkyBox(1, 0.0, 1.0, "YSkyBox07")
	Display.GfxSetSetRainEffectStatus(1, 0.0, 1.0, 0)
	Display.GfxSetSetSnowStatus(1, 0, 1.0, 0)
	Display.GfxSetSetSnowEffectStatus(1, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(1, 0.0, 1.0, 1, 38,48,58, 4000*g,10500*g)
	Display.GfxSetSetLightParams(1,  0.0, 1.0, 40, -15, -50,  136,144,144, 128,104,72)
	
	Display.GfxSetSetSkyBox(2, 0.0, 1.0, "YSkyBox04")
	Display.GfxSetSetRainEffectStatus(2, 0.0, 1.0, 1)
	Display.GfxSetSetSnowStatus(2, 0, 1.0, 0)
	Display.GfxSetSetSnowEffectStatus(2, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(2, 0.0, 1.0, 1, 38,58,68, 4000*g,8000*g)
	Display.GfxSetSetLightParams(2,  0.0, 1.0, 40, -15, -50,  136,144,144, 128,104,72)
	
	Display.GfxSetSetSkyBox(3, 0.0, 1.0, "YSkyBox01")
	Display.GfxSetSetRainEffectStatus(3, 0.0, 1.0, 0)
	Display.GfxSetSetSnowStatus(3, 0, 1.0, 1)
	Display.GfxSetSetSnowEffectStatus(3, 0.0, 0.8, 1)
	Display.GfxSetSetFogParams(3, 0.0, 1.0, 1, 108,128,138, 2000*g,9500*g)
	Display.GfxSetSetLightParams(3,  0.0, 1.0, 40, -15, -50,  116,144,164, 255,234,202)
	
	-- dawn
	f = 0.85
	Display.GfxSetSetSkyBox(4, 0.0, 1.0, "YSkyBox07")
	Display.GfxSetSetRainEffectStatus(4, 0.0, 1.0, 0)
	Display.GfxSetSetSnowStatus(4, 0, 1.0, 0)
	Display.GfxSetSetSnowEffectStatus(4, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(4, 0.0, 1.0, 1, 58,38,48, 4000*g,10500*g)
	Display.GfxSetSetLightParams(4,  0.0, 1.0, 40, -15, -50*h,  136*f,144*f,144*f, 128*f,104*f,72*f)
	
	f = 0.75
	Display.GfxSetSetSkyBox(5, 0.0, 1.0, "YSkyBox04")
	Display.GfxSetSetRainEffectStatus(5, 0.0, 1.0, 1)
	Display.GfxSetSetSnowStatus(5, 0, 1.0, 0)
	Display.GfxSetSetSnowEffectStatus(5, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(5, 0.0, 1.0, 1, 38,58,68, 4000*g,8000*g)
	Display.GfxSetSetLightParams(5,  0.0, 1.0, 40, -15, -50*h,  136*f,144*f,144*f, 128*f,104*f,72*f)
	
	f = 0.85
	Display.GfxSetSetSkyBox(6, 0.0, 1.0, "YSkyBox01")
	Display.GfxSetSetRainEffectStatus(6, 0.0, 1.0, 0)
	Display.GfxSetSetSnowStatus(6, 0, 1.0, 1)
	Display.GfxSetSetSnowEffectStatus(6, 0.0, 0.8, 1)
	Display.GfxSetSetFogParams(6, 0.0, 1.0, 1, 138*f,108*f,128*f, 2000*g,9500*g)
	Display.GfxSetSetLightParams(6,  0.0, 1.0, 40, -15, -50*h,  164*f,116*f,144*f, 255*f,202*f,234*f)
	
	-- night
	f = 0.65
	Display.GfxSetSetSkyBox(7, 0.0, 1.0, "YSkyBox07")
	Display.GfxSetSetRainEffectStatus(7, 0.0, 1.0, 0)
	Display.GfxSetSetSnowStatus(7, 0, 1.0, 0)
	Display.GfxSetSetSnowEffectStatus(7, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(7, 0.0, 1.0, 1, 38,48,58, 4000*g,10500*g)
	Display.GfxSetSetLightParams(7,  0.0, 1.0, 40, -15, -50,  136*f,144*f,144*f, 72*f,104*f,128*f)
	
	f = 0.6
	Display.GfxSetSetSkyBox(8, 0.0, 1.0, "YSkyBox04")
	Display.GfxSetSetRainEffectStatus(8, 0.0, 1.0, 1)
	Display.GfxSetSetSnowStatus(8, 0, 1.0, 0)
	Display.GfxSetSetSnowEffectStatus(8, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(8, 0.0, 1.0, 1, 38,58,68, 4000*g,8000*g)
	Display.GfxSetSetLightParams(8,  0.0, 1.0, 40, -15, -50,  136*f,144*f,144*f, 72*f,104*f,128*f)
	
	f = 0.6
	Display.GfxSetSetSkyBox(9, 0.0, 1.0, "YSkyBox01")
	Display.GfxSetSetRainEffectStatus(9, 0.0, 1.0, 0)
	Display.GfxSetSetSnowStatus(9, 0, 1.0, 1)
	Display.GfxSetSetSnowEffectStatus(9, 0.0, 0.8, 1)
	Display.GfxSetSetFogParams(9, 0.0, 1.0, 1, 108*f,128*f,138*f, 2000*g,9500*g)
	Display.GfxSetSetLightParams(9,  0.0, 1.0, 40, -15, -50,  116*f,144*f,164*f, 202*f,234*f,255*f)
end
-- ************************************************************************************************
WeatherExtensions.SetupMediterraneanWeatherGfxSet = SetupMediterraneanWeatherGfxSet
SetupMediterraneanWeatherGfxSet = function(g)
	
	-- day
	local f = 1
	g = g or 2
	local h = 0.5
	--WeatherExtensions.SetupMediterraneanWeatherGfxSet()
	Display.GfxSetSetSkyBox(1, 0.0, 1.0, "YSkyBox03")
	Display.GfxSetSetRainEffectStatus(1, 0.0, 1.0, 0)
	Display.GfxSetSetSnowStatus(1, 0, 1.0, 0)
	Display.GfxSetSetSnowEffectStatus(1, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(1, 0.0, 1.0, 1, 152,172,182, 5000*g,28000*g)
	Display.GfxSetSetLightParams(1,  0.0, 1.0, 40, -15, -50,  120,110,110,  255,254,230)

	Display.GfxSetSetSkyBox(2, 0.0, 1.0, "YSkyBox04")
	Display.GfxSetSetRainEffectStatus(2, 0.0, 1.0, 1)
	Display.GfxSetSetSnowStatus(2, 0, 1.0, 0)
	Display.GfxSetSetSnowEffectStatus(2, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(2, 0.0, 1.0, 1, 102,132,142, 3500*g,9500*g)
	Display.GfxSetSetLightParams(2,  0.0, 1.0, 40, -15, -50,  120,110,110,  255,254,230)
	
	Display.GfxSetSetSkyBox(3, 0.0, 1.0, "YSkyBox01")
	Display.GfxSetSetRainEffectStatus(3, 0.0, 1.0, 0)
	Display.GfxSetSetSnowStatus(3, 0, 1.0, 1)
	Display.GfxSetSetSnowEffectStatus(3, 0.0, 0.8, 1)
	Display.GfxSetSetFogParams(3, 0.0, 1.0, 1, 152,172,182, 4000*g,12000*g)
	Display.GfxSetSetLightParams(3,  0.0, 1.0,  40, -15, -75,  100,110,110, 250,250,250)

	-- dawn
	f = 0.85
	Display.GfxSetSetSkyBox(4, 0.0, 1.0, "YSkyBox03")
	Display.GfxSetSetRainEffectStatus(4, 0.0, 1.0, 0)
	Display.GfxSetSetSnowStatus(4, 0, 1.0, 0)
	Display.GfxSetSetSnowEffectStatus(4, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(4, 0.0, 1.0, 1, 182*f,152*f,172*f, 5000*g,28000*g)
	Display.GfxSetSetLightParams(4,  0.0, 1.0, 40, -15, -50*h,  120*f,110*f,110*f,  255*f,230*f,254*f)

	f = 0.75
	Display.GfxSetSetSkyBox(5, 0.0, 1.0, "YSkyBox04")
	Display.GfxSetSetRainEffectStatus(5, 0.0, 1.0, 1)
	Display.GfxSetSetSnowStatus(5, 0, 1.0, 0)
	Display.GfxSetSetSnowEffectStatus(5, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(5, 0.0, 1.0, 1, 102*f,132*f,142*f, 3500*g,9500*g)
	Display.GfxSetSetLightParams(5,  0.0, 1.0, 40, -15, -50*h,  120*f,110*f,110*f,  255*f,254*f,230*f)
	
	f = 0.85
	Display.GfxSetSetSkyBox(6, 0.0, 1.0, "YSkyBox01")
	Display.GfxSetSetRainEffectStatus(6, 0.0, 1.0, 0)
	Display.GfxSetSetSnowStatus(6, 0, 1.0, 1)
	Display.GfxSetSetSnowEffectStatus(6, 0.0, 0.8, 1)
	Display.GfxSetSetFogParams(6, 0.0, 1.0, 1, 152*f,172*f,182*f, 4000*g,12000*g)
	Display.GfxSetSetLightParams(6,  0.0, 1.0,  40, -15, -75*h,  110*f,100*f,110*f, 260*f,240*f,250*f)

	-- night
	f = 0.65
	Display.GfxSetSetSkyBox(7, 0.0, 1.0, "YSkyBox03")
	Display.GfxSetSetRainEffectStatus(7, 0.0, 1.0, 0)
	Display.GfxSetSetSnowStatus(7, 0, 1.0, 0)
	Display.GfxSetSetSnowEffectStatus(7, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(7, 0.0, 1.0, 1, 152*f,172*f,182*f, 5000*g,28000*g)
	Display.GfxSetSetLightParams(7,  0.0, 1.0, 40, -15, -50,  110*f,110*f,120*f,  230*f,254*f,255*f)

	f = 0.6
	Display.GfxSetSetSkyBox(8, 0.0, 1.0, "YSkyBox04")
	Display.GfxSetSetRainEffectStatus(8, 0.0, 1.0, 1)
	Display.GfxSetSetSnowStatus(8, 0, 1.0, 0)
	Display.GfxSetSetSnowEffectStatus(8, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(8, 0.0, 1.0, 1, 102*f,132*f,142*f, 3500*g,9500*g)
	Display.GfxSetSetLightParams(8,  0.0, 1.0, 40, -15, -50,  110*f,110*f,120*f,  230*f,254*f,255*f)
	
	f = 0.6
	Display.GfxSetSetSkyBox(9, 0.0, 1.0, "YSkyBox01")
	Display.GfxSetSetRainEffectStatus(9, 0.0, 1.0, 0)
	Display.GfxSetSetSnowStatus(9, 0, 1.0, 1)
	Display.GfxSetSetSnowEffectStatus(9, 0.0, 0.8, 1)
	Display.GfxSetSetFogParams(9, 0.0, 1.0, 1, 152*f,172*f,182*f, 4000*g,12000*g)
	Display.GfxSetSetLightParams(9,  0.0, 1.0,  40, -15, -75,  100*f,110*f,110*f, 250*f,250*f,250*f)
end
-- ************************************************************************************************
WeatherExtensions.SetupHighlandWeatherGfxSet = SetupHighlandWeatherGfxSet
SetupHighlandWeatherGfxSet = function(g)
	
	-- day
	local f = 1
	g = g or 2
	local h = 0.5
	--WeatherExtensions.SetupHighlandWeatherGfxSet()
	Display.GfxSetSetSkyBox(1, 0.0, 1.0, "YSkyBox03")
	Display.GfxSetSetRainEffectStatus(1, 0.0, 1.0, 0)
	Display.GfxSetSetSnowStatus(1, 0, 1.0, 0)
	Display.GfxSetSetSnowEffectStatus(1, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(1, 0.0, 1.0, 1, 152,172,182, 5000*g,28000*g)
	Display.GfxSetSetLightParams(1,  0.0, 1.0, 40, -15, -50,  120,110,110,  255,254,230)

	Display.GfxSetSetSkyBox(2, 0.0, 1.0, "YSkyBox04")
	Display.GfxSetSetRainEffectStatus(2, 0.0, 1.0, 1)
	Display.GfxSetSetSnowStatus(2, 0, 1.0, 0)
	Display.GfxSetSetSnowEffectStatus(2, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(2, 0.0, 1.0, 1, 102,132,142, 3500*g,9500*g)
	Display.GfxSetSetLightParams(2,  0.0, 1.0, 40, -15, -50,  120,110,110,  255,254,230)
	
	Display.GfxSetSetSkyBox(3, 0.0, 1.0, "YSkyBox01")
	Display.GfxSetSetRainEffectStatus(3, 0.0, 1.0, 0)
	Display.GfxSetSetSnowStatus(3, 0, 1.0, 1)
	Display.GfxSetSetSnowEffectStatus(3, 0.0, 0.8, 1)
	Display.GfxSetSetFogParams(3, 0.0, 1.0, 1, 152,172,182, 4000*g,12000*g)
	Display.GfxSetSetLightParams(3,  0.0, 1.0,  40, -15, -75,  100,110,110, 250,250,250)

	-- dawn
	f = 0.85
	Display.GfxSetSetSkyBox(4, 0.0, 1.0, "YSkyBox03")
	Display.GfxSetSetRainEffectStatus(4, 0.0, 1.0, 0)
	Display.GfxSetSetSnowStatus(4, 0, 1.0, 0)
	Display.GfxSetSetSnowEffectStatus(4, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(4, 0.0, 1.0, 1, 182*f,152*f,172*f, 5000*g,28000*g)
	Display.GfxSetSetLightParams(4,  0.0, 1.0, 40, -15, -50*h,  120*f,110*f,110*f,  255*f,230*f,254*f)

	f = 0.75
	Display.GfxSetSetSkyBox(5, 0.0, 1.0, "YSkyBox04")
	Display.GfxSetSetRainEffectStatus(5, 0.0, 1.0, 1)
	Display.GfxSetSetSnowStatus(5, 0, 1.0, 0)
	Display.GfxSetSetSnowEffectStatus(5, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(5, 0.0, 1.0, 1, 102*f,132*f,142*f, 3500*g,9500*g)
	Display.GfxSetSetLightParams(5,  0.0, 1.0, 40, -15, -50*h,  120*f,110*f,110*f,  255*f,254*f,230*f)
	
	f = 0.85
	Display.GfxSetSetSkyBox(6, 0.0, 1.0, "YSkyBox01")
	Display.GfxSetSetRainEffectStatus(6, 0.0, 1.0, 0)
	Display.GfxSetSetSnowStatus(6, 0, 1.0, 1)
	Display.GfxSetSetSnowEffectStatus(6, 0.0, 0.8, 1)
	Display.GfxSetSetFogParams(6, 0.0, 1.0, 1, 152*f,172*f,182*f, 4000*g,12000*g)
	Display.GfxSetSetLightParams(6,  0.0, 1.0,  40, -15, -75*h,  110*f,100*f,110*f, 260*f,240*f,250*f)

	-- night
	f = 0.65
	Display.GfxSetSetSkyBox(7, 0.0, 1.0, "YSkyBox03")
	Display.GfxSetSetRainEffectStatus(7, 0.0, 1.0, 0)
	Display.GfxSetSetSnowStatus(7, 0, 1.0, 0)
	Display.GfxSetSetSnowEffectStatus(7, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(7, 0.0, 1.0, 1, 152*f,172*f,182*f, 5000*g,28000*g)
	Display.GfxSetSetLightParams(7,  0.0, 1.0, 40, -15, -50,  110*f,110*f,120*f,  230*f,254*f,255*f)

	f = 0.6
	Display.GfxSetSetSkyBox(8, 0.0, 1.0, "YSkyBox04")
	Display.GfxSetSetRainEffectStatus(8, 0.0, 1.0, 1)
	Display.GfxSetSetSnowStatus(8, 0, 1.0, 0)
	Display.GfxSetSetSnowEffectStatus(8, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(8, 0.0, 1.0, 1, 102*f,132*f,142*f, 3500*g,9500*g)
	Display.GfxSetSetLightParams(8,  0.0, 1.0, 40, -15, -50,  110*f,110*f,120*f,  230*f,254*f,255*f)
	
	f = 0.6
	Display.GfxSetSetSkyBox(9, 0.0, 1.0, "YSkyBox01")
	Display.GfxSetSetRainEffectStatus(9, 0.0, 1.0, 0)
	Display.GfxSetSetSnowStatus(9, 0, 1.0, 1)
	Display.GfxSetSetSnowEffectStatus(9, 0.0, 0.8, 1)
	Display.GfxSetSetFogParams(9, 0.0, 1.0, 1, 152*f,172*f,182*f, 4000*g,12000*g)
	Display.GfxSetSetLightParams(9,  0.0, 1.0,  40, -15, -75,  100*f,110*f,110*f, 250*f,250*f,250*f)end
-- ************************************************************************************************
WeatherExtensions.SetupMoorWeatherGfxSet = SetupMoorWeatherGfxSet
SetupMoorWeatherGfxSet = function(g)
	
	-- day
	local f = 1
	g = g or 2
	local h = 0.5
	--WeatherExtensions.SetupMoorWeatherGfxSet()
	Display.GfxSetSetSkyBox(1, 0.0, 1.0, "YSkyBox02")
	Display.GfxSetSetRainEffectStatus(1, 0.0, 1.0, 0)
	Display.GfxSetSetSnowStatus(1, 0, 1.0, 0)
	Display.GfxSetSetSnowEffectStatus(1, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(1, 0.0, 1.0, 1, 171,164,114, 4000*g,13000*g)
	Display.GfxSetSetLightParams(1,  0.0, 1.0, 40, -15, -36,  100,100,100,  185,164,142)

	Display.GfxSetSetSkyBox(2, 0.0, 1.0, "YSkyBox04")
	Display.GfxSetSetRainEffectStatus(2, 0.0, 1.0, 1)
	Display.GfxSetSetSnowStatus(2, 0, 1.0, 0)
	Display.GfxSetSetSnowEffectStatus(2, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(2, 0.0, 1.0, 1, 131,124,84, 2000*g,8000*g)
	Display.GfxSetSetLightParams(2,  0.0, 1.0, 40, -15, -50,  120,110,110,  205,204,180)

	Display.GfxSetSetSkyBox(3, 0.0, 1.0, "YSkyBox01")
	Display.GfxSetSetRainEffectStatus(3, 0.0, 1.0, 0)
	Display.GfxSetSetSnowStatus(3, 0, 1.0, 1)
	Display.GfxSetSetSnowEffectStatus(3, 0.0, 0.8, 1)
	Display.GfxSetSetFogParams(3, 0.0, 1.0, 1, 151,164,114, 5000*g,14000*g)
	Display.GfxSetSetLightParams(3,  0.0, 1.0,  40, -15, -75,  116,144,164, 255,234,202)
	
	-- dawn
	f = 0.85
	Display.GfxSetSetSkyBox(4, 0.0, 1.0, "YSkyBox02")
	Display.GfxSetSetRainEffectStatus(4, 0.0, 1.0, 0)
	Display.GfxSetSetSnowStatus(4, 0, 1.0, 0)
	Display.GfxSetSetSnowEffectStatus(4, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(4, 0.0, 1.0, 1, 164*f,171*f,114*f, 4000*g,13000*g)
	Display.GfxSetSetLightParams(4,  0.0, 1.0, 40, -15, -36*h,  100*f,100*f,100*f,  164*f,185*f,142*f)

	f = 0.75
	Display.GfxSetSetSkyBox(5, 0.0, 1.0, "YSkyBox04")
	Display.GfxSetSetRainEffectStatus(5, 0.0, 1.0, 1)
	Display.GfxSetSetSnowStatus(5, 0, 1.0, 0)
	Display.GfxSetSetSnowEffectStatus(5, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(5, 0.0, 1.0, 1, 124*f,131*f,84*f, 2000*g,8000*g)
	Display.GfxSetSetLightParams(5,  0.0, 1.0, 40, -15, -50*h,  110*f,120*f,110*f,  204*f,205*f,180*f)

	f = 0.85
	Display.GfxSetSetSkyBox(6, 0.0, 1.0, "YSkyBox01")
	Display.GfxSetSetRainEffectStatus(6, 0.0, 1.0, 0)
	Display.GfxSetSetSnowStatus(6, 0, 1.0, 1)
	Display.GfxSetSetSnowEffectStatus(6, 0.0, 0.8, 1)
	Display.GfxSetSetFogParams(6, 0.0, 1.0, 1, 164*f,151*f,114*f, 5000*g,14000*g)
	Display.GfxSetSetLightParams(6,  0.0, 1.0,  40, -15, -75*h,  164*f,144*f,116*f, 255*f,234*f,202*f)
	
	-- night
	f = 0.65
	Display.GfxSetSetSkyBox(7, 0.0, 1.0, "YSkyBox02")
	Display.GfxSetSetRainEffectStatus(7, 0.0, 1.0, 0)
	Display.GfxSetSetSnowStatus(7, 0, 1.0, 0)
	Display.GfxSetSetSnowEffectStatus(7, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(7, 0.0, 1.0, 1, 114*f,171*f,164*f, 4000*g,13000*g)
	Display.GfxSetSetLightParams(7,  0.0, 1.0, 40, -15, -36,  100*f,100*f,100*f,  142*f,164*f,185*f)

	f = 0.6
	Display.GfxSetSetSkyBox(8, 0.0, 1.0, "YSkyBox04")
	Display.GfxSetSetRainEffectStatus(8, 0.0, 1.0, 1)
	Display.GfxSetSetSnowStatus(8, 0, 1.0, 0)
	Display.GfxSetSetSnowEffectStatus(8, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(8, 0.0, 1.0, 1, 84*f,131*f,124*f, 2000*g,8000*g)
	Display.GfxSetSetLightParams(8,  0.0, 1.0, 40, -15, -50,  110*f,110*f,120*f,  180*f,204*f,205*f)

	f = 0.6
	Display.GfxSetSetSkyBox(9, 0.0, 1.0, "YSkyBox01")
	Display.GfxSetSetRainEffectStatus(9, 0.0, 1.0, 0)
	Display.GfxSetSetSnowStatus(9, 0, 1.0, 1)
	Display.GfxSetSetSnowEffectStatus(9, 0.0, 0.8, 1)
	Display.GfxSetSetFogParams(9, 0.0, 1.0, 1, 114*f,164*f,151*f, 5000*g,14000*g)
	Display.GfxSetSetLightParams(9,  0.0, 1.0,  40, -15, -75,  116*f,144*f,164*f, 202*f,234*f,255*f)
end
-- ************************************************************************************************
WeatherExtensions.SetupSteppeWeatherGfxSet = SetupSteppeWeatherGfxSet
SetupSteppeWeatherGfxSet = function(g)
	
	-- day
	local f = 1
	g = g or 2
	local h = 0.5
	--WeatherExtensions.SetupSteppeWeatherGfxSet()
	Display.GfxSetSetSkyBox(1, 0.0, 1.0, "YSkyBox03")
	Display.GfxSetSetRainEffectStatus(1, 0.0, 1.0, 0)
	Display.GfxSetSetSnowStatus(1, 0, 1.0, 0)
	Display.GfxSetSetSnowEffectStatus(1, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(1, 0.0, 1.0, 1, 170,172,172, 7000*g,16000*g)
	Display.GfxSetSetLightParams(1,  0.0, 1.0, 40, -15, -25,  167,167,209,  255,226,226)

	Display.GfxSetSetSkyBox(2, 0.0, 1.0, "YSkyBox04")
	Display.GfxSetSetRainEffectStatus(2, 0.0, 1.0, 1)
	Display.GfxSetSetSnowStatus(2, 0, 1.0, 0)
	Display.GfxSetSetSnowEffectStatus(2, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(2, 0.0, 1.0, 1, 102,132,142, 3500*g,9500*g)
	Display.GfxSetSetLightParams(2,  0.0, 1.0, 40, -15, -25,  120,110,110,  255,254,230)

	Display.GfxSetSetSkyBox(3, 0.0, 1.0, "YSkyBox01")
	Display.GfxSetSetRainEffectStatus(3, 0.0, 1.0, 0)
	Display.GfxSetSetSnowStatus(3, 0, 1.0, 1)
	Display.GfxSetSetSnowEffectStatus(3, 0.0, 0.8, 1)
	Display.GfxSetSetFogParams(3, 0.0, 1.0, 1, 152,172,182, 4000*g,12000*g)
	Display.GfxSetSetLightParams(3,  0.0, 1.0,  40, -15, -25,  100,110,110, 250,250,250)
	
	-- dawn
	f = 0.85
	Display.GfxSetSetSkyBox(4, 0.0, 1.0, "YSkyBox03")
	Display.GfxSetSetRainEffectStatus(4, 0.0, 1.0, 0)
	Display.GfxSetSetSnowStatus(4, 0, 1.0, 0)
	Display.GfxSetSetSnowEffectStatus(4, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(4, 0.0, 1.0, 1, 172*f,170*f,172*f, 7000*g,16000*g)
	Display.GfxSetSetLightParams(4,  0.0, 1.0, 40, -15, -25*h,  209*f,167*f,167*f,  255*f,226*f,226*f)

	f = 0.75
	Display.GfxSetSetSkyBox(5, 0.0, 1.0, "YSkyBox04")
	Display.GfxSetSetRainEffectStatus(5, 0.0, 1.0, 1)
	Display.GfxSetSetSnowStatus(5, 0, 1.0, 0)
	Display.GfxSetSetSnowEffectStatus(5, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(5, 0.0, 1.0, 1, 102*f,132*f,142*f, 3500*g,9500*g)
	Display.GfxSetSetLightParams(5,  0.0, 1.0, 40, -15, -25*h,  120*f,110*f,110*f,  255*f,254*f,230*f)

	f = 0.85
	Display.GfxSetSetSkyBox(6, 0.0, 1.0, "YSkyBox01")
	Display.GfxSetSetRainEffectStatus(6, 0.0, 1.0, 0)
	Display.GfxSetSetSnowStatus(6, 0, 1.0, 1)
	Display.GfxSetSetSnowEffectStatus(6, 0.0, 0.8, 1)
	Display.GfxSetSetFogParams(6, 0.0, 1.0, 1, 182*f,152*f,172*f, 4000*g,12000*g)
	Display.GfxSetSetLightParams(6,  0.0, 1.0,  40, -15, -25*h,  110*f,100*f,110*f, 260*f,240*f,250*f)
	
	-- night
	f = 0.65
	Display.GfxSetSetSkyBox(7, 0.0, 1.0, "YSkyBox03")
	Display.GfxSetSetRainEffectStatus(7, 0.0, 1.0, 0)
	Display.GfxSetSetSnowStatus(7, 0, 1.0, 0)
	Display.GfxSetSetSnowEffectStatus(7, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(7, 0.0, 1.0, 1, 170*f,172*f,172*f, 7000*g,16000*g)
	Display.GfxSetSetLightParams(7,  0.0, 1.0, 40, -15, -25,  167*f,167*f,209*f,  226*f,226*f,255*f)

	f = 0.6
	Display.GfxSetSetSkyBox(8, 0.0, 1.0, "YSkyBox04")
	Display.GfxSetSetRainEffectStatus(8, 0.0, 1.0, 1)
	Display.GfxSetSetSnowStatus(8, 0, 1.0, 0)
	Display.GfxSetSetSnowEffectStatus(8, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(8, 0.0, 1.0, 1, 102*f,132*f,142*f, 3500*g,9500*g)
	Display.GfxSetSetLightParams(8,  0.0, 1.0, 40, -15, -25,  110*f,110*f,120*f,  230*f,254*f,255*f)

	f = 0.6
	Display.GfxSetSetSkyBox(9, 0.0, 1.0, "YSkyBox01")
	Display.GfxSetSetRainEffectStatus(9, 0.0, 1.0, 0)
	Display.GfxSetSetSnowStatus(9, 0, 1.0, 1)
	Display.GfxSetSetSnowEffectStatus(9, 0.0, 0.8, 1)
	Display.GfxSetSetFogParams(9, 0.0, 1.0, 1, 152*f,172*f,182*f, 4000*g,12000*g)
	Display.GfxSetSetLightParams(9,  0.0, 1.0,  40, -15, -25,  100*f,110*f,110*f, 250*f,250*f,250*f)
end
