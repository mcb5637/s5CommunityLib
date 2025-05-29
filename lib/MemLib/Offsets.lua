--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
-- MemLib.LAU - large address unit
-- author: RobbiTheFox, Fritz98
-- current maintainer: RobbiTheFox
-- Version: v1.0
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
if mcbPacker then
    mcbPacker.require("s5CommunityLib/Lib/MemLib/MemLib")
    mcbPacker.require("s5CommunityLib/Lib/MemLib/LAU")
    mcbPacker.require("s5CommunityLib/Tables/Modifiers")
else
	if not MemLib then Script.Load("maps\\user\\EMS\\tools\\s5CommunityLib\\lib\\MemLib\\MemLib.lua") end
    MemLib.Load("LAU", "Tables/Modifiers")
end
--------------------------------------------------------------------------------
if XNetwork.Manager_IsNATReady then

    local settler = Logic.CreateEntity(Entities.CU_Sheep, 100, 100, 0, CNetwork and 17 or 8)
    local CSettlerVtp = Logic.GetEntityScriptingValue(settler, -50)
    local CSettlerVtpLAU = MemLib.LAU.ToTable(CSettlerVtp)

    local entity = Logic.CreateEntity(Entities.XD_Rock1, 100, 100, 0, 0)
    local CGLEEntityVtp = Logic.GetEntityScriptingValue(entity, -50)

    local dif = MemLib.LAU.ToNumber(CSettlerVtpLAU - CGLEEntityVtp)

    if dif == 92936 then -- Ubi HE

        MemLib.Internal.GameVersion = "UHE"
        MemLib.Offsets = {
            CGLGameLogic = {
                GlobalObject = MemLib.LAU.ToNumber(CSettlerVtpLAU + 3696012),
                PlayerManager = 9,
                TechManager = 12,
            },
            CGLEGameLogic = {
                GlobalObject = MemLib.LAU.ToNumber(CSettlerVtpLAU + 2193132),
                CGLELandscape = 9,
            },
            CGLEEntityManager = {
                GlobalObject = MemLib.LAU.ToNumber(CSettlerVtpLAU + 2188820),
            },
            CGLEEntitiesProps = {
                GlobalObject = MemLib.LAU.ToNumber(CSettlerVtpLAU + 2193136),
            },
            -- same as GE but vectors are only size 3, so everything is shifted -5
            CLogicProperties = {
                GlobalObject = MemLib.LAU.ToNumber(CSettlerVtpLAU + 3695992),
                STaxationLevelVectorStart = 8,
                WorkTimeBase = 69,
                WorkTimeThresholdWork = 70,
            },
            -- same as GE
            CPlayerAttractionProps = {
                GlobalObject = MemLib.LAU.ToNumber(CSettlerVtpLAU + 3734768),
                DistanceWorkplaceFarm = 6,
                DistanceWorkplaceResidence = 7,
            },
            DamageClassesHolder = {},
            CDamageClassesPropsMgr = {
                VectorStart = 3,
            },
            -- same as GE
            CGlobalsBaseEx = {
                GlobalObject = MemLib.LAU.ToNumber(CSettlerVtpLAU + 2079652),
                CPlayerColors = 22,
            },
            WidgetManager = {
                GlobalObject = MemLib.LAU.ToNumber(CSettlerVtpLAU + 3589360),
            },
            WidgetIDManager = {
                GlobalObject = 0,
            },
            CMain = {
                GlobalObject = MemLib.LAU.ToNumber(CSettlerVtpLAU + 2004732),
                CGLUEPropsMgr = 132,
            },
            CGLELandscape = {
                CGLETerrainHiRes = 6,
                CGLETerrainLowRes = 7,
                CTerrainVertexColors = 8,
            },
            Sector_Unknown1 = MemLib.LAU.ToNumber(CSettlerVtpLAU + 3407860),
            Sector_Unknown2 = MemLib.LAU.ToNumber(CSettlerVtpLAU + 2735608),
            Entity = {
                Attachments = 9,
                AttachedTos = 15,
                BehaviorVectorStart = 31,
                ScriptingValue = 50,
            },
            Settler = {
                SelfAddress = 64,
            },
            ResourceDoodad = {
                ResourceType = 66,
            },
            ResourceDoodadType = {
                ResourceEntityType = 38,
            },
            CGLETerrainHiRes = {
                DataVectorStart = 1,
                ArraySizeY = 7,
            },
            CGLETerrainLowRes = {
                DataVectorStart = 1,
                BridgeHeightVectorStart = 4,
                ArraySizeY = 9,
            },
            CPlayerStatus = {
                PlayerTechManager = 57,
                CPlayerAttractionHandler = 171,
            },
            CPlayerAttractionHandler = {
                PaydayStartTurn = 3,
            },
            CTerrainPropsMgr = {
                VectorStart = 4,
            },
            CGlueWaterPropsMgr = {
                VectorStart = 3,
            },
            TechManager = {
                VectorStart = 0,
            },
            PlayerTechManager = {
                TechVectorStart = 1,
                AutoResearchVectorStart = 4,
            },
            Modifiers = {
                [Modifiers.Exploration]	=  41,
                [Modifiers.Speed]		=  48,
                [Modifiers.Hitpoints]	=  55,
                [Modifiers.Damage]		=  62,
                [Modifiers.DamageBonus]	=  69,
                [Modifiers.MaxRange]	=  76,
                [Modifiers.MinRange]	=  83,
                [Modifiers.Armor]		=  90,
                [Modifiers.DodgeChance]	=  97,
                [Modifiers.GroupLimit]	= 104,
            },
        }
        --[[if mcbPacker then
            mcbPacker.require("s5CommunityLib/Lib/MemLib/Internal/UHE")
        else
            MemLib.Load("Lib/MemLib/Internal/UHE")
        end]]

    elseif dif == 92968 then -- Steam HE

        MemLib.Internal.GameVersion = "SHE"
        MemLib.Offsets = {}
        --[[if mcbPacker then
            mcbPacker.require("s5CommunityLib/Lib/MemLib/Internal/SHE")
        else
            MemLib.Load("Lib/MemLib/Internal/SHE")
        end]]

    else
        assert(false, "Unknown Game Version!")
    end

    Logic.DestroyEntity(entity)
    Logic.DestroyEntity(settler)

else -- GE

    MemLib.Internal.GameVersion = "GE"
    MemLib.Offsets = {
        CGLGameLogic = {
            GlobalObject = tonumber("85A3A0", 16),
            PlayerManager = 10,
            TechManager = 13,
        },
        CGLEGameLogic = {
            GlobalObject = tonumber("895DAC", 16),
            CGLELandscape = 9,
        },
        CGLEEntityManager = {
            GlobalObject = tonumber("897558", 16),
        },
        CGLEEntitiesProps = {
            GlobalObject = tonumber("895DB0", 16),
        },
        CLogicProperties = {
            GlobalObject = tonumber("85A3E0", 16),
            STaxationLevelVectorStart = 11,
            WorkTimeBase = 74,
            WorkTimeThresholdWork = 75,
        },
        CPlayerAttractionProps = {
            GlobalObject = tonumber("866A80", 16),
            DistanceWorkplaceFarm = 6,
            DistanceWorkplaceResidence = 7,
        },
        DamageClassesHolder = {
            GlobalObject = tonumber("85A3DC", 16),
            VectorStart = 2,
        },
        CGlobalsBaseEx = {
            GlobalObject = tonumber("857E8C", 16),
            CPlayerColors = 22,
        },
        WidgetManager = {
            GlobalObject = tonumber("8945CC", 16),
        },
        WidgetIDManager = {
            GlobalObject = tonumber("8945C8", 16),
        },
        CMain = {
            GlobalObject = tonumber("84EF60", 16),
            CGLUEPropsMgr = 150,
        },
        CGLELandscape = {
            GlobalObject = tonumber("898B84", 16),
            CGLETerrainHiRes = 7,
            CGLETerrainLowRes = 8,
            CTerrainVertexColors = 9,
        },
        Sector_Unknown1 = tonumber("9D756C", 16),
        Sector_Unknown2 = tonumber("93755C", 16),
        Entity = {
            Attachments = 9,
            AttachedTos = 15,
            BehaviorVectorStart = 31,
            ScriptingValue = 58,
        },
        Settler = {
            SelfAddress = 67,
        },
        ResourceDoodad = {
            ResourceType = 66,
        },
        ResourceDoodadType = {
            ResourceEntityType = 38,
        },
        CGLETerrainHiRes = {
            DataVectorStart = 2,
            ArraySizeY = 8,
        },
        CGLETerrainLowRes = {
            DataVectorStart = 2,
            BridgeHeightVectorStart = 6,
            ArraySizeY = 11,
        },
        CPlayerStatus = {
            PlayerTechManager = 59,
            CPlayerAttractionHandler = 197,
        },
        CPlayerAttractionHandler = {
            PaydayStartTurn = 3,
        },
        CTerrainPropsMgr = {
            VectorStart = 5,
        },
        CGlueWaterPropsMgr = {
            VectorStart = 4,
        },
        TechManager = {
            VectorStart = 1,
        },
        PlayerTechManager = {
            TechVectorStart = 2,
            AutoResearchVectorStart = 6,
        },
        Modifiers = {
            [Modifiers.Exploration]	=  48,
            [Modifiers.Speed]		=  56,
            [Modifiers.Hitpoints]	=  64,
            [Modifiers.Damage]		=  72,
            [Modifiers.DamageBonus]	=  80,
            [Modifiers.MaxRange]	=  88,
            [Modifiers.MinRange]	=  96,
            [Modifiers.Armor]		= 104,
            [Modifiers.DodgeChance]	= 112,
            [Modifiers.GroupLimit]	= 120,
        },
    }
    --[[if mcbPacker then
        mcbPacker.require("s5CommunityLib/Lib/MemLib/Internal/GE")
    else
        MemLib.Load("Lib/MemLib/Internal/GE")
    end]]

end