if mcbPacker then --mcbPacker.ignore
mcbPacker.require("s5CommunityLib/comfort/other/S5HookLoader")
mcbPacker.require("s5CommunityLib/fixes/TriggerFix")
end --mcbPacker.ignore

--- author:mcb		current maintainer:mcb		v3.2
-- Ermöglicht es, beliebige Lua-Ausdrücke auf allen verbundenen PCs zu parsen und synchron auszuführen.
-- Wird das Script im SP geladen, wird keines Synchronisierung durchgeführt.
-- 
-- MPSyncer.Init(player)								Aus der GameCallback_OnGameStart aufrufen, bei player werden Tribute zur Synchronisierung erstellt.
-- 
-- MPSyncer.ExecuteSynced(vname, ...)				Ruft die Virtuelle Funktion vname synchron auf allen PCs mit den übergebenen Argumenten arg auf.
-- 
-- MPSyncer.ExecuteUnsyncedAtSingle(pl, vname, ...)	Ruft die virtuelle Funktion vname auf dem PC von pl auf (nicht synchron, im sp immer eigener pc).
-- 
-- MPSyncer.ExecuteUnsyncedAtAll(vname, ...)			Ruft die virtuelle Funktion vname asynchron auf allen PCs auf.
-- 
-- MPSyncer.allConnected								Gibt an, ob schon alle PCs gestartet sind. Wenn nicht, sind keine synchronisierungen möglich.
-- 
-- MPSyncer.VirtualFuncs.Create(func, vname, ...)
-- 														Erstellt eine virtuelle Funktion vname, mit den virtuellen Argumenttypen arg,
-- 														die func mit den übergebenen Argumenten aufruft.
-- 
-- MPSyncer.VirtualFuncs.ArgumentTypeInt()			Gibt den Argumenttyp für Lua-number zurück.
-- MPSyncer.VirtualFuncs.ArgumentTypeString()		Gibt den Argumenttyp für Lua-string zurück.
-- MPSyncer.VirtualFuncs.ArgumentTypeSimpleTable()	Gibt den Argumenttyp für einfache Lua-tables zurück (tables die nur numbers/strings als key/value haben).
-- MPSyncer.VirtualFuncs.ArgumentTypeCheckedEntity()Gibt den Argumenttyp für ein Entity (id) zurück.
-- MPSyncer.VirtualFuncs.ArgumentTypeCheckedPlayer()Gibt den Argumenttyp für einen player zurück.
-- 
-- MPSyncer.VirtualFuncs.SetInsertNameAsParamForFunc(vname, paramnum)
-- 													Für die seltenen Fälle, das ArgumentTypeCheckedEntity und ArgumentTypeCheckedPlayer nicht ausreichen kann hiermit der name/die playerid des aufrufenden spielers (oder false) als beliebiger parameter eingesetzt werden.
-- 
-- MPSyncer.VirtualFuncs.PatchLuaFunc(fname, ...)
-- 														Schnelle Möglichkeit, eine Funktion zu synchronisieren. Ersetzt _G[fname] mit einer Funktion, die
-- 														automatisch Synchronisiert. arg sind die Argumenttypen number/string.
-- 
-- MPSyncer.AddChatRecievedCB(cb)					Speichert einen Callback, die beim erhalt einer normalen Chat-Message zusätzlich aufgerufen wird.
-- MPSyncer.RemoveChatRecievedCb(cb)					Entfernt eine Chat-Message Callback wieder.
-- 
-- MPSyncer.GetHost()								Gibt die playerid des hosts zurück. (immer GUI.GetPlayerID() in SP)
-- 
-- MPSyncer.IsMP()									Gibt zurück, ob die Map im MP-Modus gestartet ist. (false-SP, 2-UBI, 1-LAN, 3-Kimichuras)
-- 
-- Anmerkungen:
-- vname: Darf nur aus Buchstaben bestehen, keine Zahlen/Sonderzeichen.
-- patchLuaFunc: Die zu patchende Funktion muss über einen tablezugriff aus _G erreichbar sein, Außerdem darf der Funktionsname keine Zahlen/Sonderzeichen enthalten.
-- Positionen als Argumente: Eine Position p ist nur ein table mit X und Y Eintragen. Einfach p.X und p.Y als einzelne number-Argumente übertragen und in der Funktion mit p = {X=X, Y=Y} wieder zusammenbauen.
-- Entitys als Argumente: Die id als MPSyncer.VirtualFuncs.ArgumentTypeCheckedEntity (wenn dem entity ein befehl gegeben wird) oder MPSyncer.VirtualFuncs.ArgumentTypeInt (wenn es ein ziel ist) übertragen.
-- Aufruf Synchronisierter Funktionen: Die Synchronisierungs-Funktionen müssen immer aus einem asynchronen Status ausgeführt werden, sonst wird der Aufruf vervielfältigt (Notfalls per Vergleich mit GUI.GetPlayerID() sicherstellen).
-- MPSyncer.VirtualFuncs.ArgumentTypeCheckedEntity und MPSyncer.VirtualFuncs.ArgumentTypeCheckedPlayer: Hier wird geprüft, ob der aufrufende Spieler das entity/den spieler kontrollieren darf. Keine Fehlermeldung wenn entity destroyed ist.
-- 
-- Kimichuras Server:
-- executeSynced wird gespeichert, executeUnsyncedAtSingle und executeUnsyncedAtAll nicht.
-- Erkennung von Kimichuras server erfolgt über das vorhandensein von XNetworkWrapper, also bitte nicht selbst
-- XNetworkWrapper verwenden.
-- 
-- History-Edition:
-- Sollte theoretisch funktionieren, sofern nicht allzuviel an XNetwork und XNetworkUbiCom geändert wurde (kann ich nicht testen).
-- 
-- Beispiel 1:
-- 	Script:
-- 		function foo(s, n)
-- 			for i=1,n do
-- 				Message(s)
-- 			end
-- 		end
-- 	
-- 	FMA:
-- 		MPSyncer.Init(8)
-- 		MPSyncer.VirtualFuncs.PatchLuaFunc("foo", "string", "number")
-- 	
-- 	Aufruf:
-- 		foo("bar", 5)
-- 
-- Beispiel 2:
-- 	FMA:
-- 		MPSyncer.Init(8)
-- 		MPSyncer.VirtualFuncs.Create(function(s, n)
-- 				for i=1,n do
-- 				 		Message(s)
-- 			 	end
-- 			end, "foo", MPSyncer.VirtualFuncs.ArgumentTypeString(), MPSyncer.VirtualFuncs.ArgumentTypeInt())
-- 	
-- 	Aufruf:
-- 		MPSyncer.ExecuteSynced("foo", "bar", 5)
-- 
-- Beide Beispiele fürhren zum exakt selben Ergebniss. Nr1 ist einfacher für Anfänger und leichter in bestehende SP-Scripte einbaubar,
-- 		Nr2 ist deutlich Flexibler.
-- 
-- Benötigt:
-- - S5Hook (Logging)
-- - unpack-fix
-- 
MPSyncer = {nextTribute = 0, playerAck={}, warnings={}, connected={}, allConnected=false, whitelist={}, chatRecievedCbs={}, initCbs={}, NoJingleForTribute={}}
function MPSyncer.Init(player)
	if not MPSyncer.IsMP() then
		MPSyncer.allConnected = true
		for _,cb in ipairs(MPSyncer.initCbs) do
			cb()
		end
		MPSyncer.Log("sp dont need to wait for init, ready to play")
		return
	end
	MPSyncer.MPGame_ApplicationCallback_ReceivedChatMessage = MPGame_ApplicationCallback_ReceivedChatMessage
	MPGame_ApplicationCallback_ReceivedChatMessage = function(msgo, allied, sender)
		MPSyncer.Log("recieved message from "..sender.." to "..(allied==1 and "allied" or "all")..": "..msgo)
		local msg = msgo
		if MPSyncer.IsMP()==3 then -- remove name/color codes added by kimichuras server
			local _=nil
			_,_,msg = string.find(msg, "^"..UserTool_GetPlayerName(sender)..">  @color:255,255,255,255: (.*) @color:255,255,255,255: $")
		end
		local start = string.sub(msg, 1, 3)
		local en = string.sub(msg, 4)
		if start=="@sf" then
			MPSyncer.recievedFunc(en, sender)
		elseif start=="@af" then
			MPSyncer.recievedSingleFunc(en, sender)
		elseif start=="@sa" then
			MPSyncer.recievedAck(en, sender)
		elseif start=="@wa" then
			if not MPSyncer.warningRepeat then
				table.insert(MPSyncer.warnings, en)
				GUI.AddStaticNote(en)
				MPSyncer.Log("warning recieved: "..en)
			end
		elseif start=="@in" then
			MPSyncer.recievedInit(en)
		elseif start=="@st" then
			if not MPSyncer.allConnected then
				MPSyncer.allConnected = true
				for _,cb in ipairs(MPSyncer.initCbs) do
					cb()
				end
				MPSyncer.Log("player "..sender.." finished loading first, all connected, ready to play")
			end
		else -- normal message
			--MPSyncer.MPGame_ApplicationCallback_ReceivedChatMessage(msg, allied, sender)
			for _,cb in ipairs(MPSyncer.chatRecievedCbs) do
				cb(msgo, allied, sender)
			end
		end
	end
	MPSyncer.nextTribute = GUI.GetPlayerID()
	MPSyncer.player = player
	GameCallback_FulfillTribute = function() return 1 end
	if LuaDebugger.Log then
		XNetwork.Chat_SendMessageToAll("@waWarning: Player "..GUI.GetPlayerID().." ("..XNetwork.GameInformation_GetLogicPlayerUserName(GUI.GetPlayerID())..") startet this map with active Debugger!")
	end
	if MPSyncer.IsMP()==3 then -- kimichuras server
		CNetwork.SetNetworkHandler("MPSyncer_recieved_syncedCall", function(name, str)
			MPSyncer.Log("client mode: synced executing from Network "..str)
			MPSyncer.VirtualFuncs.execute(MPSyncer.VirtualFuncs.deserialize(str), name)
		end)
		MPSyncer.allConnected = true
		for _,cb in ipairs(MPSyncer.initCbs) do
			cb()
		end
		MPSyncer.Log("kimichuras server dont need to wait for init, ready to play")
		MPSyncer.AddChatRecievedCB(MPSyncer.MPGame_ApplicationCallback_ReceivedChatMessage)
	else
		XNetwork.Chat_SendMessageToAll("@in"..GUI.GetPlayerID())
		MPSyncer.AddChatRecievedCB(function(msg, allied, sender)
			local msg2, sound, feedbs = MPSyncer.FormatChatMsg(msg, sender)
			GUI.AddNote(msg2)
			if sound then
				Sound.PlayGUISound(sound, 0)
			end
			if feedbs then
				Sound.PlayFeedbackSound(feedbs, 0)
			end
		end)
		TributeJingleCondition = function()
			local tid = Event.GetTributeUniqueID()
			if MPSyncer.NoJingleForTribute[tid] then
				MPSyncer.NoJingleForTribute[tid] = nil
				return false
			end
			return Event.GetPlayerID()==GUI.GetPlayerID()
		end
		MPSyncer.Log("local initialization done, waiting for all players to load into game")
	end	
end

MPSyncer.FormatChatMsgDatabase = {
	["#01"] = {
		sound = Sounds.VoicesMentor_MP_TauntYes,
		sttk="VoicesMentor/MP_TauntYes",
	},
	["#02"] = {
		sound = Sounds.VoicesMentor_MP_TauntNo,
		sttk="VoicesMentor/MP_TauntNo",
	},
	["#03"] = {
		sound = Sounds.VoicesMentor_MP_TauntNow,
		sttk="VoicesMentor/MP_TauntNow",
	},
	["#04"] = {
		sound = Sounds.VoicesMentor_MP_TauntAttack,
		sttk="VoicesMentor/MP_TauntAttack",
	},
	["#05"] = {
		sound = Sounds.VoicesMentor_MP_TauntAttackArea,
		sttk="VoicesMentor/MP_TauntAttackArea",
	},
	["#06"] = {
		sound = Sounds.VoicesMentor_MP_TauntDefendArea,
		sttk="VoicesMentor/MP_TauntDefendArea",
	},
	["#07"] = {
		sound = Sounds.VoicesMentor_MP_TauntHelpMe,
		sttk="VoicesMentor/MP_TauntHelpMe",
	},
	["#08"] = {
		sound = Sounds.VoicesMentor_MP_TauntNeedClay,
		sttk="VoicesMentor/MP_TauntNeedClay",
	},
	["#09"] = {
		sound = Sounds.VoicesMentor_MP_TauntNeedGold,
		sttk="VoicesMentor/MP_TauntNeedGold",
	},
	["#10"] = {
		sound = Sounds.VoicesMentor_MP_TauntNeedIron,
		sttk="VoicesMentor/MP_TauntNeedIron",
	},
	["#11"] = {
		sound = Sounds.VoicesMentor_MP_TauntNeedStone,
		sttk="VoicesMentor/MP_TauntNeedStone",
	},
	["#12"] = {
		sound = Sounds.VoicesMentor_MP_TauntNeedSulfur,
		sttk="VoicesMentor/MP_TauntNeedSulfur",
	},
	["#13"] = {
		sound = Sounds.VoicesMentor_MP_TauntNeedWood,
		sttk="VoicesMentor/MP_TauntNeedWood",
	},
	["#14"] = {
		sound = Sounds.VoicesMentor_MP_TauntVeryGood,
		sttk="VoicesMentor/MP_TauntVeryGood",
	},
	["#15"] = {
		sound = Sounds.VoicesMentor_MP_TauntYouAreLame,
		sttk="VoicesMentor/MP_TauntYouAreLame",
	},
	["#16"] = {
		sound = Sounds.VoicesMentor_MP_TauntFunny01,
		sttk="VoicesMentor/MP_TauntFunny01",
	},
	["#17"] = {
		sound = Sounds.VoicesMentor_MP_TauntFunny02,
		sttk="VoicesMentor/MP_TauntFunny02",
	},
	["#18"] = {
		sound = Sounds.VoicesMentor_MP_TauntFunny03,
		sttk="VoicesMentor/MP_TauntFunny03",
	},
	["#19"] = {
		sound = Sounds.VoicesMentor_MP_TauntFunny04,
		sttk="VoicesMentor/MP_TauntFunny04",
	},
	["#20"] = {
		sound = Sounds.VoicesMentor_MP_TauntFunny05,
		sttk="VoicesMentor/MP_TauntFunny05",
	},
}
function MPSyncer.FormatChatMsg(msg, sender)
	local sound = Sounds.Misc_Chat
	if MPSyncer.FormatChatMsgDatabase[msg] then
		sound = MPSyncer.FormatChatMsgDatabase[msg].sound
		msg = MPSyncer.GetPlayerNameString(sender)..XGUIEng.GetStringTableText(MPSyncer.FormatChatMsgDatabase[msg].sttk)
		return msg, nil, sound
	end
	return msg, sound, nil
end

function MPSyncer.GetPlayerNameString(pl)
	local r,g,b = GUI.GetPlayerColor(pl)
	return " @color:"..r..","..g..","..b.." "..UserTool_GetPlayerName(pl).." @color:255,255,255 > "
end

function MPSyncer.AddChatRecievedCB(cb)
	table.insert(MPSyncer.chatRecievedCbs, cb)
end

function MPSyncer.RemoveChatRecievedCb(cb)
	for i=table.getn(MPSyncer.chatRecievedCbs),1,-1 do
		if MPSyncer.chatRecievedCbs[i]==cb then
			table.remove(MPSyncer.chatRecievedCbs, i)
		end
	end
end

function MPSyncer.AddInitCB(cb)
	table.insert(MPSyncer.initCbs, cb)
	if MPSyncer.allConnected then
		cb()
	end
end

function MPSyncer.Log(txt)
	if LuaDebugger.Log then
		LuaDebugger.Log(txt)
	end
	if S5Hook then
		S5Hook.Log("MPSyncer: "..txt)
	end
	if CLogger then
		CLogger.Log("MPSyncer: "..txt)
	end
end

function MPSyncer.ExecuteSynced(f, ...)
	if not MPSyncer.IsMP() then
		--MPSyncer.VirtualFuncs.funcs[f].func(unpack(arg))
		f = MPSyncer.VirtualFuncs.serialize(f, unpack(arg))
		MPSyncer.Log("SP mode, direct executing: "..f)
		MPSyncer.VirtualFuncs.execute(MPSyncer.VirtualFuncs.deserialize(f))
		return
	end
	assert(MPSyncer.allConnected)
	if MPSyncer.IsMP()==3 then -- kimichuras modserver
		f = MPSyncer.VirtualFuncs.serialize(f, unpack(arg))
		assert(MPSyncer.VirtualFuncs.deserialize(f)) -- be sure, deserialisation is possible
		MPSyncer.Log("host mode: sended CNetwork call for "..f)
		CNetwork.SendCommand("MPSyncer_recieved_syncedCall", f)
		return
	end
	local cntxt = {}
	for i=1,XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer() do
		if XNetwork.GameInformation_IsHumanPlayerAttachedToPlayerID(i)==1 and Logic.PlayerGetLeftGameFlag(i)==0 then
			cntxt[i] = "needAck"
		end
	end
	local tId = MPSyncer.nextTribute
	MPSyncer.nextTribute = MPSyncer.nextTribute + 8
	MPSyncer.playerAck[tId] = cntxt
	f = MPSyncer.VirtualFuncs.serialize(f, unpack(arg))
	assert(MPSyncer.VirtualFuncs.deserialize(f)) -- be sure, deserialisation is possible
	MPSyncer.Log("host mode: sended tribute "..tId.." for call "..f)
	XNetwork.Chat_SendMessageToAll("@sf"..tId..":"..f)
end

function MPSyncer.recievedFunc(f, sender)
	local st, en = string.find(f, "^%d+:")
	local id = string.sub(f, st, en-1)
	local toEval = string.sub(f, en+1)
	local func = MPSyncer.VirtualFuncs.deserialize(toEval, sender)
	local tid = tonumber(id)
	Logic.AddTribute(MPSyncer.player, tid, 0, 0, "syncer tribute, do not pay!", ResourceType.Gold, 0)
	Trigger.RequestTrigger(Events.LOGIC_EVENT_TRIBUTE_PAID, nil, function(trib, callback) -- custom trigger does not leave data in a global table
		if Event.GetTributeUniqueID()==trib then
			MPSyncer.Log("client mode: synced executing "..trib)
			MPSyncer.VirtualFuncs.execute(callback)
		end
	end, 1, nil, {tid, func})
	MPSyncer.Log((sender==GUI.GetPlayerID() and "host mode: " or "client mode: ").."recieved tribute "..id.." from "..sender.." for "..toEval)
	XNetwork.Chat_SendMessageToAll("@sa"..id)
end

function MPSyncer.recievedAck(a, sender)
	a = tonumber(a)
	if MPSyncer.playerAck[a] then
		MPSyncer.playerAck[a][sender] = "acked"
		MPSyncer.Log("host mode: ack recieved for "..a.." from "..sender)
		MPSyncer.checkAcks(a)
	else
		MPSyncer.Log("client mode: dropped ack for "..a.." from "..sender..", not for me")
	end
end

function MPSyncer.checkAcks(id)
	local cntxt = MPSyncer.playerAck[id]
	for i=1,XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer() do
		if cntxt[i] == "needAck" then
			MPSyncer.Log("host mode: waiting for more acks to execute "..id)
			return
		end
	end
	MPSyncer.Log("host mode: started synced execution "..id)
	GUI.PayTribute(MPSyncer.player, id)
	MPSyncer.playerAck[id] = nil
end

function MPSyncer.recievedInit(player)
	local p = tonumber(player)
	MPSyncer.Log("init recieved from "..p)
	if p~=GUI.GetPlayerID() then
		MPSyncer.warningRepeat = true
		for _,s in ipairs(MPSyncer.warnings) do
			XNetwork.Chat_SendMessageToAll("@wa"..s)
		end
		MPSyncer.warningRepeat = nil
	end
	MPSyncer.connected[p] = true
	for i=1,XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer() do
		if XNetwork.GameInformation_IsHumanPlayerAttachedToPlayerID(i)==1 and not MPSyncer.connected[i] then
			return
		end
	end
	MPSyncer.Log("got all inits, sending start")
	XNetwork.Chat_SendMessageToAll("@st")
end

function MPSyncer.ExecuteUnsyncedAtSingle(pl, f, ...)
	if not MPSyncer.IsMP() then
		MPSyncer.Log("SP mode, direct executing")
		MPSyncer.VirtualFuncs.funcs[f].func(unpack(arg))
		return
	end
	assert(MPSyncer.allConnected)
	f = MPSyncer.VirtualFuncs.serialize(f, unpack(arg))
	assert(MPSyncer.VirtualFuncs.deserialize(f)) -- be sure, deserialisation is possible
	MPSyncer.Log("host mode: sended single call to machine "..pl.." "..f)
	XNetwork.Chat_SendMessageToAll("@af"..pl..":"..f)
end

function MPSyncer.ExecuteUnsyncedAtAll(f, ...)
	if not MPSyncer.IsMP() then
		MPSyncer.Log("SP mode, direct executing")
		MPSyncer.VirtualFuncs.funcs[f].func(unpack(arg))
		return
	end
	assert(MPSyncer.allConnected)
	f = MPSyncer.VirtualFuncs.serialize(f, unpack(arg))
	assert(MPSyncer.VirtualFuncs.deserialize(f)) -- be sure, deserialisation is possible
	MPSyncer.Log("host mode: sended single call to machine all "..f)
	XNetwork.Chat_SendMessageToAll("@af-1:"..f)
end

function MPSyncer.recievedSingleFunc(f, sender)
	local st, en = string.find(f, "^%-?%d+:")
	local id = string.sub(f, st, en-1)
	local toEval = string.sub(f, en+1)
	if tonumber(id)~=GUI.GetPlayerID() and id~="-1" then
		MPSyncer.Log("client mode: dropped single call for "..id..", not for me")
		return
	end
	local func = MPSyncer.VirtualFuncs.deserialize(toEval, sender)
	MPSyncer.Log("client mode: executing single call "..toEval)
	MPSyncer.VirtualFuncs.execute(func)
end

function MPSyncer.IsMP()
	if XNetworkUbiCom.Manager_DoesExist()==1 and XNetwork.EXTENDED_GameInformation_GetHost then -- kimichuras server (better detection method?)
		return 3
	elseif XNetworkUbiCom.Manager_DoesExist()==1 then
		return 2
	elseif XNetwork.Manager_DoesExist()==1 then
		return 1
	else
		return false
	end
end

function MPSyncer.GetHost()
	local mpmode = MPSyncer.IsMP()
	if not mpmode then
		return GUI.GetPlayerID()
	end
	if mpmode == 3 then
		local hostname = XNetwork.EXTENDED_GameInformation_GetHost()
		for pl=1,XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer() do
			if XNetwork.GameInformation_GetLogicPlayerUserName(pl)==hostname then
				return pl
			end
		end
		return hostname
	end
	return XNetwork.GameInformation_GetPlayerIDByNetworkAddress(XNetwork.Host_UserInSession_GetHostNetworkAddress())
end

function MPSyncer.IsPlayerAllowedToManipulatePlayer(pl, name)
	if MPSyncer.IsMP()==3 then
		return CNetwork.isAllowedToManipulatePlayer(name, pl)
	else
		return name==pl
	end
end

function MPSyncer.IsPlayerAllowedToManipulateEntity(id, name)
	if IsDestroyed(id) then
		return
	end
	return MPSyncer.IsPlayerAllowedToManipulatePlayer(GetPlayer(id), name)
end

MPSyncer.VirtualFuncs = {funcs={}}

function MPSyncer.VirtualFuncs.Create(func, vname, ...)
	assert(string.find(vname, "^%w+$"))
	local pattern = "^"..vname.."%("
	local serializer = {}
	local deserializer = {}
	local check = {}
	for i,a in ipairs(arg) do
		pattern = pattern..a.pattern..", "
		table.insert(serializer, a.serialize)
		table.insert(deserializer, a.deserialize)
		check[i] = a.check
	end
	pattern = pattern.."%)$"
	local t = {pattern = pattern, serializer = serializer, deserializer = deserializer, checks = check, func = func}
	MPSyncer.VirtualFuncs.funcs[vname] = t
	return t
end

function MPSyncer.VirtualFuncs.ArgumentTypeInt()
	return {pattern="(%-?%d+%.?%d*)", serialize=tostring, deserialize = tonumber}
end

function MPSyncer.VirtualFuncs.ArgumentTypeString()
	return {pattern = "\"(%w*)\"",
		serialize = function(s)
		return '"'..s..'"'
	end, deserialize = function(s)
		return s
	end}
end

function MPSyncer.VirtualFuncs.ArgumentTypeCheckedEntity()
	local t = MPSyncer.VirtualFuncs.ArgumentTypeInt()
	t.check = MPSyncer.IsPlayerAllowedToManipulateEntity
	return t
end

function MPSyncer.VirtualFuncs.ArgumentTypeCheckedPlayer()
	local t = MPSyncer.VirtualFuncs.ArgumentTypeInt()
	t.check = MPSyncer.IsPlayerAllowedToManipulatePlayer
	return t
end

function MPSyncer.VirtualFuncs.ArgumentTypeSimpleTable()
	return {pattern = "\{([%w%.%-%[%]\"=,]*)}",
		serialize = function(t)
		local s = "{"
		local function f(x)
			if type(x)=="string" then
				return '"'..x..'"'
			end
			return tostring(x)
		end
		for k,v in pairs(t) do
			s = s.."["..f(k).."]="..f(v)..","
		end
		return s.."}"
	end, deserialize = function(s)
		local t = {}
		local i = 1
		local function get()
			return string.sub(s,i,i)
		end
		local function next()
			i = i + 1
		end
		local function match(c)
			assert(get()==c)
			next()
		end
		local function parseString()
			match('"')
			local s = ""
			while true do
				local c = get()
				if c=='"' then
					next()
					return s
				end
				s = s..c
				next()
			end
		end
		local function parseNumber()
			local s = ""
			if get()=="-" then
				s = "-"
				next()
			end
			while true do
				local c = get()
				if c=="1" or c=="2" or c=="3" or c=="4" or c=="5" or c=="6" or c=="7" or c=="8" or c=="9" or c=="0" or c=="." then
					s = s..c
					next()
				else
					return tonumber(s)
				end
			end
		end
		local function parseMember()
			if get()=='"' then
				return parseString()
			else
				return parseNumber()
			end
		end
		local function parseKV()
			match("[")
			local k = parseMember()
			match("]")
			match("=")
			local v = parseMember()
			t[k] = v
		end
		while true do
			if get()=="" then
				return t
			end
			parseKV()
			match(",")
		end
	end}
end

function MPSyncer.VirtualFuncs.parse(vfunc, str)
	local t = {string.find(str, vfunc.pattern)}
	if not t[1] then
		return
	end
	local context = {func=vfunc.func, checks={}, insertNameAsParam=vfunc.insertNameAsParam}
	for i=1, table.getn(vfunc.deserializer) do
		local dsr, check = vfunc.deserializer[i], vfunc.checks[i]
		local ar = t[i+2]
		context[i] = dsr(ar)
		context.checks[i] = check
	end
	return context
end

function MPSyncer.VirtualFuncs.deserialize(string, sender)
	for vname, vfunc in pairs(MPSyncer.VirtualFuncs.funcs) do
		local r = MPSyncer.VirtualFuncs.parse(vfunc, string)
		if r then
			r.sender = sender
			r.string = string
			return r
		end
	end
end

function MPSyncer.VirtualFuncs.serialize(vname, ...)
	local vfunc = MPSyncer.VirtualFuncs.funcs[vname]
	local str = vname.."("
	for i=1, table.getn(vfunc.serializer) do
		local a = arg[i]
		local sr = vfunc.serializer[i]
		str = str..sr(a)..", "
	end
	str = str..")"
	return str
end

function MPSyncer.VirtualFuncs.execute(context, name)
	local fnc = context.func
	if not name and context.sender then
		name = context.sender
	end
	if name then
		for i,p in ipairs(context) do
			if context.checks[i] then
				local c = context.checks[i](p, name)
				if not c then
					if c == false then
						local errmsg = "Check failed at player "..GUI.GetPlayerID().." for: "..context.string
						XNetwork.Chat_SendMessageToAll(errmsg)
						MPSyncer.Log(errmsg)
						return
					end
					MPSyncer.Log("Invalid Entity at player "..GUI.GetPlayerID().." for: "..context.string)
					return
				end
			end
		end
	end
	if context.insertNameAsParam then
		table.insert(context, context.insertNameAsParam, name or false)
	end
	if LuaDebugger.Log then
		fnc(unpack(context))
	else
		xpcall(function()
			fnc(unpack(context))
		end, function(e)
			local errmsg = "Lua Error at player "..GUI.GetPlayerID()..": "..e
			XNetwork.Chat_SendMessageToAll(errmsg)
			MPSyncer.Log(errmsg)
		end)
	end
end

function MPSyncer.VirtualFuncs.SetInsertNameAsParamForFunc(vname, paramnum)
	local vfunc = MPSyncer.VirtualFuncs.funcs[vname]
	vfunc.insertNameAsParam = paramnum
end

function MPSyncer.VirtualFuncs.PatchLuaFunc(fname, ...)
	if not MPSyncer.IsMP() then
		return
	end
	local f = _G[fname]
	assert(type(f)=="function")
	local vname = string.gsub(fname, "%.", "")
	vname = string.gsub(vname, "_", "")
	local varg = {}
	for _, atyp in ipairs(arg) do
		if atyp=="string" then
			table.insert(varg, MPSyncer.VirtualFuncs.ArgumentTypeString())
		elseif atyp=="number" then
			table.insert(varg, MPSyncer.VirtualFuncs.ArgumentTypeInt())
		elseif atyp=="entity" then
			table.insert(varg, MPSyncer.VirtualFuncs.ArgumentTypeCheckedEntity())
		elseif atyp=="player" then
			table.insert(varg, MPSyncer.VirtualFuncs.ArgumentTypeCheckedPlayer())
		end
	end
	MPSyncer.VirtualFuncs.Create(f, vname, unpack(varg))
	_G[fname] = function(...)
		MPSyncer.ExecuteSynced(vname, unpack(arg)) -- uses upvalue vname. never use this in SP!
	end
end

MPSyncer.VirtualFuncsWithReturn = {nextIndex=0, returnList={}, spFuncs={}}

function MPSyncer.VirtualFuncsWithReturn.Create(func, vname, argListCall, argListReturn)
	table.insert(argListCall, 1, MPSyncer.VirtualFuncs.ArgumentTypeInt())
	table.insert(argListCall, 1, MPSyncer.VirtualFuncs.ArgumentTypeInt())
	table.insert(argListReturn, 1, MPSyncer.VirtualFuncs.ArgumentTypeInt())
	MPSyncer.VirtualFuncs.Create(function(index, returnPlayer, ...)
		local r = {func(unpack(arg))}
		MPSyncer.ExecuteUnsyncedAtSingle(returnPlayer, vname.."Return", index, unpack(r))
	end, vname.."Call", unpack(argListCall))
	MPSyncer.VirtualFuncs.Create(function(index, ...)
		local rf = MPSyncer.VirtualFuncsWithReturn.returnList[index]
		rf(unpack(arg))
	end, vname.."Return", unpack(argListReturn))
	MPSyncer.VirtualFuncsWithReturn.spFuncs[vname] = func
end

function MPSyncer.VirtualFuncsWithReturn.CallUnsynced(pl, vname, returnFunc, ...)
	if not MPSyncer.IsMP() then
		MPSyncer.Log("SP mode, direct executing")
		returnFunc(MPSyncer.VirtualFuncsWithReturn.spFuncs[vname](unpack(arg)))
		return
	end
	local ind = MPSyncer.VirtualFuncsWithReturn.nextIndex
	MPSyncer.VirtualFuncsWithReturn.nextIndex = MPSyncer.VirtualFuncsWithReturn.nextIndex + 1
	MPSyncer.VirtualFuncsWithReturn.returnList[ind] = returnFunc
	MPSyncer.ExecuteUnsyncedAtSingle(pl, vname.."Call", ind, GUI.GetPlayerID(), unpack(arg))
end
