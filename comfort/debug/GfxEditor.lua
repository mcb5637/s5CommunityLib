-- author: RobbiTheFox		current maintainer:RobbiTheFox		v1.0
GfxEditor = {
    Effect = {
	    Rain = 0,		-- U
		Snow = 0,		-- I
		Ice = 0,		-- O
	    SkyBox = 1,		-- P
    },
	Fog = {
		Min = 10000,	-- H
		R = 127,		-- J
		G = 127,		-- K
		B = 127,		-- L
		Max = 20000,	-- Ö
	},
	Dir = {
		X = 50,			-- W
		Y = 50,			-- E
		Z = 50,			-- R
	},
	Amb = {
		R = 127,		-- S
		G = 127,		-- D
		B = 127,		-- F
	},
	Dif = {
		R = 127,		-- X
		G = 127,		-- C
		B = 127,		-- V
	},
}

function GfxEditor.UpdateGfxSet()
	Display.GfxSetSetSkyBox(1, 0.0, 0.0, "YSkyBox0" .. GfxEditor.Effect.SkyBox)
	Display.GfxSetSetRainEffectStatus(1, 0.0, 0.0, GfxEditor.Effect.Rain)
	Display.GfxSetSetSnowStatus(1, 0.0, 0.0, GfxEditor.Effect.Ice)
	Display.GfxSetSetSnowEffectStatus(1, 0.0, 0.0, GfxEditor.Effect.Snow)
	Display.GfxSetSetFogParams(
		1,
		0.0,
		0.0,
		1,
		GfxEditor.Fog.R,
		GfxEditor.Fog.G,
		GfxEditor.Fog.B,
		GfxEditor.Fog.Min,
		GfxEditor.Fog.Max
	)
	Display.GfxSetSetLightParams(
		1,
		0.0,
		0.0,
		GfxEditor.Dir.X,
		GfxEditor.Dir.Y,
		GfxEditor.Dir.Z,
		GfxEditor.Amb.R,
		GfxEditor.Amb.G,
		GfxEditor.Amb.B,
		GfxEditor.Dif.R,
		GfxEditor.Dif.G,
		GfxEditor.Dif.B
	)

    GUI.ClearNotes()
    GUI.AddStaticNote(
        "@color:255,255,255,255 Press @color:255,204,51,255 Shift @color:255,255,255,255 to Increment, @color:255,204,51,255 Ctrl @color:255,255,255,255 to Decrement @cr " ..
        "@color:191,191,191,255 Light Direction: @color:255,255,255,255 @cr " ..
        "X: @color:255,204,51,255 " .. GfxEditor.Dir.X .. " @color:255,255,255,255 Modify with @color:255,204,51,255 W @color:255,255,255,255 @cr " ..
        "Y: @color:255,204,51,255 " .. GfxEditor.Dir.Y .. " @color:255,255,255,255 Modify with @color:255,204,51,255 E @color:255,255,255,255 @cr " ..
        "Z: @color:255,204,51,255 " .. GfxEditor.Dir.Z .. " @color:255,255,255,255 Modify with @color:255,204,51,255 R @color:255,255,255,255 @cr " ..
        "@color:191,191,191,255 Ambient Color: @color:255,255,255,255 @cr " ..
        "R: @color:255,204,51,255 " .. GfxEditor.Amb.R .. " @color:255,255,255,255 Modify with @color:255,204,51,255 S @color:255,255,255,255 @cr " ..
        "G: @color:255,204,51,255 " .. GfxEditor.Amb.G .. " @color:255,255,255,255 Modify with @color:255,204,51,255 D @color:255,255,255,255 @cr " ..
        "B: @color:255,204,51,255 " .. GfxEditor.Amb.B .. " @color:255,255,255,255 Modify with @color:255,204,51,255 F @color:255,255,255,255 @cr " ..
        "@color:191,191,191,255 Diffuse Color: @color:255,255,255,255 @cr " ..
        "R: @color:255,204,51,255 " .. GfxEditor.Dif.R .. " @color:255,255,255,255 Modify with @color:255,204,51,255 X @color:255,255,255,255 @cr " ..
        "G: @color:255,204,51,255 " .. GfxEditor.Dif.G .. " @color:255,255,255,255 Modify with @color:255,204,51,255 C @color:255,255,255,255 @cr " ..
        "B: @color:255,204,51,255 " .. GfxEditor.Dif.B .. " @color:255,255,255,255 Modify with @color:255,204,51,255 V @color:255,255,255,255 @cr " ..
        "@color:191,191,191,255 Effects: @color:255,255,255,255 @cr " ..
        "Rain: @color:255,204,51,255 " .. (GfxEditor.Effect.Rain == 1 and "On" or "Off") .. " @color:255,255,255,255 Toggle with @color:255,204,51,255 U @color:255,255,255,255 @cr " ..
        "Snow: @color:255,204,51,255 " .. (GfxEditor.Effect.Snow == 1 and "On" or "Off") .. " @color:255,255,255,255 Toggle with @color:255,204,51,255 I @color:255,255,255,255 @cr " ..
        "Ice: @color:255,204,51,255 " .. (GfxEditor.Effect.Ice == 1 and "On" or "Off") .. " @color:255,255,255,255 Toggle with @color:255,204,51,255 O @color:255,255,255,255 @cr " ..
        "SkyBox: @color:255,204,51,255 YSkyBox0" .. GfxEditor.Effect.SkyBox .. " @color:255,255,255,255 Modify with @color:255,204,51,255 P @color:255,255,255,255 @cr " ..
        "@color:191,191,191,255 Fog Distance: @color:255,255,255,255 @cr " ..
        "Min: @color:255,204,51,255 " .. GfxEditor.Fog.Min .. " @color:255,255,255,255 Modify with @color:255,204,51,255 H @color:255,255,255,255 @cr " ..
        "Max: @color:255,204,51,255 " .. GfxEditor.Fog.Max .. " @color:255,255,255,255 Modify with @color:255,204,51,255 Ö @color:255,255,255,255 @cr " ..
        "@color:191,191,191,255 Fog Color: @color:255,255,255,255 @cr " ..
        "R: @color:255,204,51,255 " .. GfxEditor.Fog.R .. " @color:255,255,255,255 Modify with @color:255,204,51,255 J @color:255,255,255,255 @cr " ..
        "G: @color:255,204,51,255 " .. GfxEditor.Fog.G .. " @color:255,255,255,255 Modify with @color:255,204,51,255 K @color:255,255,255,255 @cr " ..
        "B: @color:255,204,51,255 " .. GfxEditor.Fog.B .. " @color:255,255,255,255 Modify with @color:255,204,51,255 L @color:255,255,255,255 @cr "
    )
end

function GfxEditor.Increment(_Key1, _Key2)
    GfxEditor.Modify(_Key1, _Key2, 1)
end
function GfxEditor.Decrement(_Key1, _Key2)
    GfxEditor.Modify(_Key1, _Key2, -1)
end
function GfxEditor.Modify(_Key1, _Key2, _Value)
    if _Key2 == "Min" or _Key2 == "Max" then
        _Value = _Value * 100
    end
    local value = GfxEditor[_Key1][_Key2] + _Value
    if _Key2 == "R" or _Key2 == "G" or _Key2 == "B" then
        value = math.max(value, 0)
        value = math.min(value, 255)
    end
    if _Key2 == "SkyBox" then
        value = math.max(value, 0)
        value = math.min(value, 7)
    end
    if _Key2 == "Min" or _Key2 == "Max" then
        value = math.max(value, 0)
    end
    GfxEditor[_Key1][_Key2] = value
    GfxEditor.UpdateGfxSet()
end
function GfxEditor.Toggle(_Key1, _Key2)
    GfxEditor[_Key1][_Key2] = 1 - GfxEditor[_Key1][_Key2]
    GfxEditor.UpdateGfxSet()
end

Input.KeyBindDown(Keys.U, "GfxEditor.Toggle(\"Effect\", \"Rain\")", 15)
Input.KeyBindDown(Keys.I, "GfxEditor.Toggle(\"Effect\", \"Snow\")", 15)
Input.KeyBindDown(Keys.O, "GfxEditor.Toggle(\"Effect\", \"Ice\")", 15)
Input.KeyBindDown(Keys.P + Keys.ModifierShift, "GfxEditor.Increment(\"Effect\", \"SkyBox\")", 15)
Input.KeyBindDown(Keys.P + Keys.ModifierControl, "GfxEditor.Decrement(\"Effect\", \"SkyBox\")", 15)

Input.KeyBindDown(Keys.H + Keys.ModifierShift, "GfxEditor.Increment(\"Fog\", \"Min\")", 15)
Input.KeyBindDown(Keys.H + Keys.ModifierControl, "GfxEditor.Decrement(\"Fog\", \"Min\")", 15)
Input.KeyBindDown(Keys.J + Keys.ModifierShift, "GfxEditor.Increment(\"Fog\", \"R\")", 15)
Input.KeyBindDown(Keys.J + Keys.ModifierControl, "GfxEditor.Decrement(\"Fog\", \"R\")", 15)
Input.KeyBindDown(Keys.K + Keys.ModifierShift, "GfxEditor.Increment(\"Fog\", \"G\")", 15)
Input.KeyBindDown(Keys.K + Keys.ModifierControl, "GfxEditor.Decrement(\"Fog\", \"G\")", 15)
Input.KeyBindDown(Keys.L + Keys.ModifierShift, "GfxEditor.Increment(\"Fog\", \"B\")", 15)
Input.KeyBindDown(Keys.L + Keys.ModifierControl, "GfxEditor.Decrement(\"Fog\", \"B\")", 15)
Input.KeyBindDown(Keys.OemTilde + Keys.ModifierShift, "GfxEditor.Increment(\"Fog\", \"Max\")", 15)
Input.KeyBindDown(Keys.OemTilde + Keys.ModifierControl, "GfxEditor.Decrement(\"Fog\", \"Max\")", 15)

Input.KeyBindDown(Keys.W + Keys.ModifierShift, "GfxEditor.Increment(\"Dir\", \"X\")", 15)
Input.KeyBindDown(Keys.W + Keys.ModifierControl, "GfxEditor.Decrement(\"Dir\", \"X\")", 15)
Input.KeyBindDown(Keys.E + Keys.ModifierShift, "GfxEditor.Increment(\"Dir\", \"Y\")", 15)
Input.KeyBindDown(Keys.E + Keys.ModifierControl, "GfxEditor.Decrement(\"Dir\", \"Y\")", 15)
Input.KeyBindDown(Keys.R + Keys.ModifierShift, "GfxEditor.Increment(\"Dir\", \"Z\")", 15)
Input.KeyBindDown(Keys.R + Keys.ModifierControl, "GfxEditor.Decrement(\"Dir\", \"Z\")", 15)

Input.KeyBindDown(Keys.S + Keys.ModifierShift, "GfxEditor.Increment(\"Amb\", \"R\")", 15)
Input.KeyBindDown(Keys.S + Keys.ModifierControl, "GfxEditor.Decrement(\"Amb\", \"R\")", 15)
Input.KeyBindDown(Keys.D + Keys.ModifierShift, "GfxEditor.Increment(\"Amb\", \"G\")", 15)
Input.KeyBindDown(Keys.D + Keys.ModifierControl, "GfxEditor.Decrement(\"Amb\", \"G\")", 15)
Input.KeyBindDown(Keys.F + Keys.ModifierShift, "GfxEditor.Increment(\"Amb\", \"B\")", 15)
Input.KeyBindDown(Keys.F + Keys.ModifierControl, "GfxEditor.Decrement(\"Amb\", \"B\")", 15)

Input.KeyBindDown(Keys.X + Keys.ModifierShift, "GfxEditor.Increment(\"Dif\", \"R\")", 15)
Input.KeyBindDown(Keys.X + Keys.ModifierControl, "GfxEditor.Decrement(\"Dif\", \"R\")", 15)
Input.KeyBindDown(Keys.C + Keys.ModifierShift, "GfxEditor.Increment(\"Dif\", \"G\")", 15)
Input.KeyBindDown(Keys.C + Keys.ModifierControl, "GfxEditor.Decrement(\"Dif\", \"G\")", 15)
Input.KeyBindDown(Keys.V + Keys.ModifierShift, "GfxEditor.Increment(\"Dif\", \"B\")", 15)
Input.KeyBindDown(Keys.V + Keys.ModifierControl, "GfxEditor.Decrement(\"Dif\", \"B\")", 15)

GfxEditor.UpdateGfxSet()