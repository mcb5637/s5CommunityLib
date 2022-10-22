--- author:fritz_98		current maintainer:fritz_98		v1.0
--- berechnet die geschwindigkeit eines Entities.
---@param _Entity number|string
---@return number speed
GetEntityMovementSpeed = function (_Entity)
	if CppLogic then
		return CppLogic.Entity.GetSpeed(_Entity)
	end
	local EntityId = GetEntityId(_Entity)
    local EntityTypeName = Logic.GetEntityTypeName(Logic.GetEntityType(EntityId))
    local PlayerId = Logic.EntityGetPlayer(EntityId)
    local EntitySpeed = 0
    local SpeedProperties = EntityMoveSpeeds[EntityTypeName]
    if SpeedProperties then
        EntitySpeed = SpeedProperties.Base
        for i = 1, table.getn(SpeedProperties.Bonus) do
            if Logic.IsTechnologyResearched(PlayerId, Technologies[SpeedProperties.Bonus[i]]) == 1 then
                EntitySpeed = MoveSpeedBonus[SpeedProperties.Bonus[i]](EntitySpeed)
            end
        end
    end
    return EntitySpeed
end

EntityMoveSpeeds = {
    CU_AfraidAlchemist          = {
        Base    = 320,
        Bonus   = {}
    },
    CU_AfraidMasterBuilder      = {
        Base    = 320,
        Bonus   = {}
    },
    CU_AfraidMiner              = {
        Base    = 320,
        Bonus   = {}
    },
    CU_AfraidSawmillworker      = {
        Base    = 320,
        Bonus   = {}
    },
    CU_AfraidSerf               = {
        Base    = 320,
        Bonus   = {}
    },
    CU_AfraidSmith              = {
        Base    = 320,
        Bonus   = {}
    },
    CU_AfraidStonecutter        = {
        Base    = 320,
        Bonus   = {}
    },
    CU_AggressiveWolf           = {
        Base    = 500,
        Bonus   = {}
    },
    CU_AlchemistIdle            = {
        Base    = 320,
        Bonus   = {}
    },
    CU_AssistentLeoIdle         = {
        Base    = 320,
        Bonus   = {}
    },
    CU_BanditLeaderBow1         = {
        Base    = 340,
        Bonus   = {}
    },
    CU_BanditLeaderSword1       = {
        Base    = 360,
        Bonus   = {}
    },
    CU_BanditLeaderSword2       = {
        Base    = 360,
        Bonus   = {}
    },
    CU_Barbarian_Hero           = {
        Base    = 400,
        Bonus   = {}
    },
    CU_Barbarian_Hero_wolf      = {
        Base    = 360,
        Bonus   = {}
    },
    CU_Barbarian_LeaderClub1    = {
        Base    = 360,
        Bonus   = {}
    },
    CU_Barbarian_LeaderClub2    = {
        Base    = 360,
        Bonus   = {}
    },
    CU_BenedictineMonkIdle      = {
        Base    = 320,
        Bonus   = {}
    },
    CU_BishopIdle               = {
        Base    = 320,
        Bonus   = {}
    },
    CU_BishopOfCrawford         = {
        Base    = 320,
        Bonus   = {}
    },
    CU_BlackKnight              = {
        Base    = 400,
        Bonus   = {}
    },
    CU_BlackKnight_LeaderMace1  = {
        Base    = 360,
        Bonus   = {}
    },
    CU_BlackKnight_LeaderMace2  = {
        Base    = 360,
        Bonus   = {}
    },
    CU_CaptainIdle              = {
        Base    = 360,
        Bonus   = {}
    },
    CU_CavalryIdle              = {
        Base    = 480,
        Bonus   = {}
    },
    CU_ChiefIdle                = {
        Base    = 320,
        Bonus   = {}
    },
    CU_EngineerIdle             = {
        Base    = 320,
        Bonus   = {}
    },
    CU_Evil_LeaderBearman1      = {
        Base    = 360,
        Bonus   = {}
    },
    CU_Evil_LeaderSkirmisher1   = {
        Base    = 360,
        Bonus   = {}
    },
    CU_Evil_Queen               = {
        Base    = 400,
        Bonus   = {}
    },
    CU_FarmerIdle               = {
        Base    = 320,
        Bonus   = {}
    },
    CU_Garek                    = {
        Base    = 320,
        Bonus   = {}
    },
    CU_GCBlackKnight            = {
        Base    = 320,
        Bonus   = {}
    },
    CU_GCScholar                = {
        Base    = 320,
        Bonus   = {}
    },
    CU_Hermit                   = {
        Base    = 320,
        Bonus   = {}
    },
    CU_Johannes                 = {
        Base    = 320,
        Bonus   = {}
    },
    CU_Leonardo                 = {
        Base    = 320,
        Bonus   = {}
    },
    CU_Major01Idle              = {
        Base    = 320,
        Bonus   = {}
    },
    CU_Major02Idle              = {
        Base    = 320,
        Bonus   = {}
    },
    CU_Mary_de_Mortfichet       = {
        Base    = 400,
        Bonus   = {}
    },
    CU_MasterBuilder            = {
        Base    = 320,
        Bonus   = {}
    },
    CU_Merchant                 = {
        Base    = 320,
        Bonus   = {}
    },
    CU_MinerIdle                = {
        Base    = 320,
        Bonus   = {}
    },
    CU_NPC_Major_Barmecia       = {
        Base    = 320,
        Bonus   = {}
    },
    CU_NPC_Major_Cleycourt      = {
        Base    = 320,
        Bonus   = {}
    },
    CU_PoleArmIdle              = {
        Base    = 360,
        Bonus   = {}
    },
    CU_Princess                 = {
        Base    = 360,
        Bonus   = {}
    },
    CU_RegentDovbar             = {
        Base    = 360,
        Bonus   = {}
    },
    CU_ScoutIdle                = {
        Base    = 320,
        Bonus   = {}
    },
    CU_Serf                     = {
        Base    = 320,
        Bonus   = {}
    },
    CU_SettlerIdle              = {
        Base    = 320,
        Bonus   = {}
    },
    CU_Sheep                    = {
        Base    = 150,
        Bonus   = {}
    },
    CU_Sheep2                   = {
        Base    = 150,
        Bonus   = {}
    },
    CU_Sheep3                   = {
        Base    = 150,
        Bonus   = {}
    },
    CU_SmelterIdle              = {
        Base    = 320,
        Bonus   = {}
    },
    CU_Thief                    = {
        Base    = 400,
        Bonus   = {}
    },
    CU_Trader                   = {
        Base    = 320,
        Bonus   = {}
    },
    CU_VeteranCaptain           = {
        Base    = 400,
        Bonus   = {}
    },
    CU_VeteranLieutenant        = {
        Base    = 400,
        Bonus   = {}
    },
    CU_VeteranMajor             = {
        Base    = 400,
        Bonus   = {}
    },
    CU_Wanderer                 = {
        Base    = 320,
        Bonus   = {}
    },
    PU_Alchemist                = {
        Base    = 320,
        Bonus   = {
            "T_Shoes"
        }
    },
    PU_BattleSerf               = {
        Base    = 320,
        Bonus   = {}
    },
    PU_BrickMaker               = {
        Base    = 320,
        Bonus   = {
            "T_Shoes"
        }
    },
    PU_Coiner                   = {
        Base    = 320,
        Bonus   = {}
    },
    PU_Engineer                 = {
        Base    = 320,
        Bonus   = {
            "T_Shoes"
        }
    },
    PU_Farmer                   = {
        Base    = 320,
        Bonus   = {
            "T_Shoes"
        }
    },
    PU_Gunsmith                 = {
        Base    = 320,
        Bonus   = {
            "T_Shoes"
        }
    },
    PU_Hero1                    = {
        Base    = 400,
        Bonus   = {}
    },
    PU_Hero1_Hawk               = {
        Base    = 500,
        Bonus   = {}
    },
    PU_Hero10                   = {
        Base    = 400,
        Bonus   = {}
    },
    PU_Hero11                   = {
        Base    = 400,
        Bonus   = {}
    },
    PU_Hero1a                   = {
        Base    = 400,
        Bonus   = {}
    },
    PU_Hero1b                   = {
        Base    = 400,
        Bonus   = {}
    },
    PU_Hero1c                   = {
        Base    = 400,
        Bonus   = {}
    },
    PU_Hero2                    = {
        Base    = 400,
        Bonus   = {}
    },
    PU_Hero3                    = {
        Base    = 400,
        Bonus   = {}
    },
    PU_Hero4                    = {
        Base    = 400,
        Bonus   = {}
    },
    PU_Hero5                    = {
        Base    = 400,
        Bonus   = {}
    },
    PU_Hero5_Outlaw             = {
        Base    = 400,
        Bonus   = {}
    },
    PU_Hero6                    = {
        Base    = 400,
        Bonus   = {}
    },
    PU_LeaderBow1               = {
        Base    = 320,
        Bonus   = {
            "T_BetterTrainingArchery"
        }
    },
    PU_LeaderBow2               = {
        Base    = 320,
        Bonus   = {
            "T_BetterTrainingArchery"
        }
    },
    PU_LeaderBow3               = {
        Base    = 320,
        Bonus   = {
            "T_BetterTrainingArchery"
        }
    },
    PU_LeaderBow4               = {
        Base    = 320,
        Bonus   = {
            "T_BetterTrainingArchery"
        }
    },
    PU_LeaderCavalry1           = {
        Base    = 500,
        Bonus   = {
            "T_Shoeing"
        }
    },
    PU_LeaderCavalry2           = {
        Base    = 500,
        Bonus   = {
            "T_Shoeing"
        }
    },
    PU_LeaderHeavyCavalry1      = {
        Base    = 500,
        Bonus   = {
            "T_Shoeing"
        }
    },
    PU_LeaderHeavyCavalry2      = {
        Base    = 500,
        Bonus   = {
            "T_Shoeing"
        }
    },
    PU_LeaderPoleArm1           = {
        Base    = 360,
        Bonus   = {
            "T_BetterTrainingBarracks"
        }
    },
    PU_LeaderPoleArm2           = {
        Base    = 360,
        Bonus   = {
            "T_BetterTrainingBarracks"
        }
    },
    PU_LeaderPoleArm3           = {
        Base    = 360,
        Bonus   = {
            "T_BetterTrainingBarracks"
        }
    },
    PU_LeaderPoleArm4           = {
        Base    = 360,
        Bonus   = {
            "T_BetterTrainingBarracks"
        }
    },
    PU_LeaderSword1             = {
        Base    = 360,
        Bonus   = {
            "T_BetterTrainingBarracks"
        }
    },
    PU_LeaderSword2             = {
        Base    = 360,
        Bonus   = {
            "T_BetterTrainingBarracks"
        }
    },
    PU_LeaderSword3             = {
        Base    = 360,
        Bonus   = {
            "T_BetterTrainingBarracks"
        }
    },
    PU_LeaderSword4             = {
        Base    = 360,
        Bonus   = {
            "T_BetterTrainingBarracks"
        }
    },
    PU_LeaderRifle1             = {
        Base    = 320,
        Bonus   = {
            "T_BetterTrainingArchery"
        }
    },
    PU_LeaderRifle2             = {
        Base    = 320,
        Bonus   = {
            "T_BetterTrainingArchery"
        }
    },
    PU_MasterBuilder            = {
        Base    = 320,
        Bonus   = {
            "T_Shoes"
        }
    },
    PU_Miner                    = {
        Base    = 320,
        Bonus   = {
            "T_Shoes"
        }
    },
    PU_Priest                   = {
        Base    = 320,
        Bonus   = {
            "T_Shoes"
        }
    },
    PU_Sawmillworker            = {
        Base    = 320,
        Bonus   = {
            "T_Shoes"
        }
    },
    PU_Scholar                  = {
        Base    = 320,
        Bonus   = {
            "T_Shoes"
        }
    },
    PU_Scout                    = {
        Base    = 360,
        Bonus   = {}
    },
    PU_Serf                     = {
        Base    = 400,
        Bonus   = {
            "T_Shoes"
        }
    },
    PU_Smelter                  = {
        Base    = 320,
        Bonus   = {
            "T_Shoes"
        }
    },
    PU_Smith                    = {
        Base    = 320,
        Bonus   = {
            "T_Shoes"
        }
    },
    PU_Stonecutter              = {
        Base    = 320,
        Bonus   = {
            "T_Shoes"
        }
    },
    PU_TavernBarkeeper          = {
        Base    = 320,
        Bonus   = {
            "T_Shoes"
        }
    },
    PU_Thief                    = {
        Base    = 400,
        Bonus   = {}
    },
    PU_Trader                   = {
        Base    = 320,
        Bonus   = {
            "T_Shoes"
        }
    },
    PU_Travelling_Salesman      = {
        Base    = 320,
        Bonus   = {}
    },
    PU_Treasurer                = {
        Base    = 320,
        Bonus   = {
            "T_Shoes"
        }
    },
    PV_Cannon1                  = {
        Base    = 240,
        Bonus   = {}
    },
    PV_Cannon2                  = {
        Base    = 260,
        Bonus   = {}
    },
    PV_Cannon3                  = {
        Base    = 220,
        Bonus   = {}
    },
    PV_Cannon4                  = {
        Base    = 180,
        Bonus   = {}
    }
}

MoveSpeedBonus = {
    T_BetterTrainingArchery = function (_BaseMoveSpeed) return _BaseMoveSpeed + 40 end,
    T_BetterTrainingBarracks = function (_BaseMoveSpeed) return _BaseMoveSpeed + 30 end,
    T_Shoeing = function (_BaseMoveSpeed) return _BaseMoveSpeed + 50 end,
    T_Shoes = function (_BaseMoveSpeed) return _BaseMoveSpeed + 20 end
}