
--- author:mcb		current maintainer:mcb		v1.0
--  technologiestaus
TechState = {allowed = 2,
	forbidden = 0,
	researched = 4,
	inProgress = 3,
	future = 5, -- fake, allowed, but not waiting
	waiting = 1, -- fake, all tech requirements have their tech requirements fullfilled or are researched
}
