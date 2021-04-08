
--- GetRandom   mcb  1.0    (Original ???)
-- Gibt eine Pseudozufallszahl zwischen _min und _max zurück.
-- Ist _max nicht gesetzt, zwischen 1 und _min.
-- Wird ein numerisches table übergeben, wird ein pseudozufälliger Eintrag zurückgegeben.
--
-- Benötigt:
-- nix
function GetRandom(_min, _max)
	if type(_min)=="table" then
		return _min[GetRandom(table.getn(_min))]
	end
	if not _max then
		_max = _min
		_min = 1
	end
	if not GvRandomseed then
		GvRandomseed = true
		if XNetwork.Manager_DoesExist()==0 then
			local seed = XGUIEng.GetSystemTime()
			local str = Framework.GetSystemTimeDateString()
			for i=1, string.len(str) do
				seed = seed + string.byte(str, i, i)
			end
			math.randomseed(seed)
		end
	end
	assert(type(_min)=="number" and type(_max)=="number")
	return math.random(_min, _max)
end
