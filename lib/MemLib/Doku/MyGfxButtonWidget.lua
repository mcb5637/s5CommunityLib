MyWidgetConfig = {
	Class = WidgetClasses.CGfxButtonWidget,
	Name = "MyButton",
	Rectangle = {
		X = 40,
		Y = 40,
		W = 32,
		H = 32,
	},
	IsShown = true,
	ZPriority = 0,
	MotherID = "Normal",
	Group = 0,
	ForceToHandleMouseEventsFlag = false,
	ForceToNeverBeFoundFlag = false,
	ButtonHelper = {
		DisabledFlag = false,
		HighLightedFlag = false,
		ActionFunction = "LuaDebugger.Log(\"MyActionFunc\")",
		ShortCutString = {
			StringTableKey = "KeyBindings/ReserachTechnologies1",
			RawString = "",
		},
	},
	Materials = {
		[0] = {
			Texture = "data\\graphics\\textures\\gui\\b_civil_university.png",
			TextureCoordinates = {
				X = 0,
				Y = 0.3125,
				W = 0.25,
				H = 0.03125,
			},
			Color = {
				R = 255,
				G = 255,
				B = 255,
				A = 255,
			},
		},
		[1] = {
			Texture = "data\\graphics\\textures\\gui\\b_civil_university.png",
			TextureCoordinates = {
				X = 0.25,
				Y = 0.3125,
				W = 0.25,
				H = 0.03125,
			},
			Color = {
				R = 255,
				G = 255,
				B = 255,
				A = 255,
			},
		},
		[2] = {
			Texture = "data\\graphics\\textures\\gui\\b_civil_university.png",
			TextureCoordinates = {
				X = 0.5,
				Y = 0.3125,
				W = 0.25,
				H = 0.03125,
			},
			Color = {
				R = 255,
				G = 255,
				B = 255,
				A = 255,
			},
		},
		[3] = {
			Texture = "data\\graphics\\textures\\gui\\b_civil_university.png",
			TextureCoordinates = {
				X = 0.5,
				Y = 0.3125,
				W = 0.25,
				H = 0.03125,
			},
			Color = {
				R = 255,
				G = 255,
				B = 255,
				A = 255,
			},
		},
		[4] = {
			Texture = "data\\graphics\\textures\\gui\\b_civil_university.png",
			TextureCoordinates = {
				X = 0.75,
				Y = 0.3125,
				W = 0.25,
				H = 0.03125,
			},
			Color = {
				R = 255,
				G = 255,
				B = 255,
				A = 255,
			},
		},
	},
	ToolTipHelper = {
		ToolTipEnabledFlag = true,
		ToolTipString = {
			StringTableKey = "",
			RawString = "",
		},
		TargetWidget = "TooltipBottom",
		ControlTargetWidgetDisplayState = true,
		UpdateFunction = "LuaDebugger.Log(\"MyTooltipFunc\")",
	},
	UpdateFunction = "LuaDebugger.Log(\"MyUpdateFunc\")",
	UpdateManualFlag = true,
	IconMaterial = {
		Texture = "",
		TextureCoordinates = {
			X = 0,
			Y = 0,
			W = 0.25,
			H = 0.25,
		},
		Color = {
			R = 255,
			G = 255,
			B = 255,
			A = 0,
		},
	},
}