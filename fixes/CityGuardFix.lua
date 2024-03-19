GameCallback_OnTechnologyResearchedOriginal = GameCallback_OnTechnologyResearched
   function GameCallback_OnTechnologyResearched( _PlayerID, _TechnologyType )
       GameCallback_OnTechnologyResearchedOriginal( _PlayerID,_TechnologyType)
       if _TechnologyType == Technologies.T_TownGuard then
         Logic.SetTechnologyState(_PlayerID,Technologies.T_CityGuard, 3)
       end
   end
