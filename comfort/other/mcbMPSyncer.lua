if mcbPacker then --mcbPacker.ignore
mcbPacker.require("s5CommunityLib/comfort/other/s5HookLoader")
mcbPacker.require("s5CommunityLib/fixes/mcbTrigger")
end --mcbPacker.ignore

--- author:mcb		current maintainer:mcb		v3.0b
-- Ermöglicht es, beliebige Lua-Ausdrücke auf allen verbundenen PCs zu parsen und synchron auszuführen.
-- Wird das Script im SP geladen, wird keines Synchronisierung durchgeführt.
-- 
-- mcbMPSyncer.init(player)								Aus der GameCallback_OnGameStart aufrufen, bei player werden Tribute zur Synchronisierung erstellt.
-- 
-- mcbMPSyncer.executeSynced(vname, ...)				Ruft die Virtuelle Funktion vname synchron auf allen PCs mit den übergebenen Argumenten arg auf.
-- 
-- mcbMPSyncer.executeUnsyncedAtSingle(pl, vname, ...)	Ruft die virtuelle Funktion vname auf dem PC von pl auf (nicht synchron, im sp immer eigener pc).
-- 
-- mcbMPSyncer.executeUnsyncedAtAll(vname, ...)			Ruft die virtuelle Funktion vname asynchron auf allen PCs auf.
-- 
-- mcbMPSyncer.allConnected								Gibt an, ob schon alle PCs gestartet sind. Wenn nicht, sind keine synchronisierungen möglich.
-- 
-- mcbMPSyncer.virtualFuncs.create(func, vname, ...)
-- 														Erstellt eine virtuelle Funktion vname, mit den virtuellen Argumenttypen arg,
-- 														die func mit den übergebenen Argumenten aufruft.
-- 
-- mcbMPSyncer.virtualFuncs.argumentTypeInt()			Gibt den Argumenttyp für Lua-number zurück.
-- mcbMPSyncer.virtualFuncs.argumentTypeString()		Gibt den Argumenttyp für Lua-string zurück.
-- mcbMPSyncer.virtualFuncs.argumentTypeSimpleTable()	Gibt den Argumenttyp für einfache Lua-tables zurück (tables die nur numbers/strings als key/value haben).
-- 
-- mcbMPSyncer.virtualFuncs.patchLuaFunc(fname, ...)
-- 														Schnelle Möglichkeit, eine Funktion zu synchronisieren. Ersetzt _G[fname] mit einer Funktion, die
-- 														automatisch Synchronisiert. arg sind die Argumenttypen number/string.
-- 
-- mcbMPSyncer.addChatRecievedCB(cb)					Speichert einen Callback, die beim erhalt einer normalen Chat-Message zusätzlich aufgerufen wird.
-- mcbMPSyncer.removeChatRecievedCb(cb)					Entfernt eine Chat-Message Callback wieder.
-- 
-- mcbMPSyncer.getHost()								Gibt die playerid des hosts zurück. (immer GUI.GetPlayerID() in SP)
-- 
-- mcbMPSyncer.isMP()									Gibt zurück, ob die Map im MP-Modus gestartet ist. (false-SP, 2-UBI, 1-LAN, 3-Kimichuras)
-- 
-- Anmerkungen:
-- vname: Darf nur aus Buchstaben bestehen, keine Zahlen/Sonderzeichen.
-- patchLuaFunc: Die zu patchende Funktion muss über einen tablezugriff aus _G erreichbar sein, Außerdem darf der Funktionsname keine Zahlen/Sonderzeichen enthalten.
-- Positionen als Argumente: Eine Position p ist nur ein table mit X und Y Eintragen. Einfach p.X und p.Y als einzelne number-Argumente übertragen und in der Funktion mit p = {X=X, Y=Y} wieder zusammenbauen.
-- Entitys als Argumente: Ich empfehle, die id als number zu übertragen.
-- Aufruf Synchronisierter Funktionen: Die Synchronisierungs-Funktionen müssen immer aus einem asynchronen Status ausgeführt werden, sonst wird der Aufruf vervielfältigt (Notfalls per Vergleich mit GUI.GetPlayerID() sicherstellen).
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
-- 		mcbMPSyncer.init(8)
-- 		mcbMPSyncer.virtualFuncs.patchLuaFunc("foo", "string", "number")
-- 	
-- 	Aufruf:
-- 		foo("bar", 5)
-- 
-- Beispiel 2:
-- 	FMA:
-- 		mcbMPSyncer.init(8)
-- 		mcbMPSyncer.virtualFuncs.create(function(s, n)
-- 				for i=1,n do
-- 				 		Message(s)
-- 			 	end
-- 			end, "foo", mcbMPSyncer.virtualFuncs.argumentTypeString(), mcbMPSyncer.virtualFuncs.argumentTypeInt())
-- 	
-- 	Aufruf:
-- 		mcbMPSyncer.executeSynced("foo", "bar", 5)
-- 
-- Beide Beispiele fürhren zum exakt selben Ergebniss. Nr1 ist einfacher für Anfänger und leichter in bestehende SP-Scripte einbaubar,
-- 		Nr2 ist deutlich Flexibler.
-- 
-- Benötigt:
-- - S5Hook (Logging)
-- - unpack-fix
-- 
mcbMPSyncer = {nextTribute = 0, playerAck={}, warnings={}, connected={}, allConnected=false, whitelist={}, chatRecievedCbs={}, initCbs={}}
function mcbMPSyncer.init(player)
	if not mcbMPSyncer.isMP() then
		mcbMPSyncer.allConnected = true
		for _,cb in ipairs(mcbMPSyncer.initCbs) do
			cb()
		end
		return
	end
	mcbMPSyncer.MPGame_ApplicationCallback_ReceivedChatMessage = MPGame_ApplicationCallback_ReceivedChatMessage
	MPGame_ApplicationCallback_ReceivedChatMessage = function(msgo, allied, sender)
		mcbMPSyncer.log("recieved message from "..sender.." to "..(allied==1 and "allied" or "all")..": "..msgo)
		local msg = msgo
		if mcbMPSyncer.isMP()==3 then -- remove name/color codes added by kimichuras server
			local _=nil
			_,_,msg = string.find(msg, "^"..UserTool_GetPlayerName(sender)..">  @color:255,255,255,255: (.*) @color:255,255,255,255: $")
		end
		local start = string.sub(msg, 1, 3)
		local en = string.sub(msg, 4)
		if start=="@sf" then
			mcbMPSyncer.recievedFunc(en, sender)
		elseif start=="@af" then
			mcbMPSyncer.recievedSingleFunc(en, sender)
		elseif start=="@sa" then
			mcbMPSyncer.recievedAck(en, sender)
		elseif start=="@wa" then
			if not mcbMPSyncer.warningRepeat then
				table.insert(mcbMPSyncer.warnings, en)
				GUI.AddStaticNote(en)
				mcbMPSyncer.log("warning recieved: "..en)
			end
		elseif start=="@in" then
			mcbMPSyncer.recievedInit(en)
		elseif start=="@st" then
			if not mcbMPSyncer.allConnected then
				mcbMPSyncer.allConnected = true
				for _,cb in ipairs(mcbMPSyncer.initCbs) do
					cb()
				end
				mcbMPSyncer.log("player "..sender.." finished loading first, all connected, ready to play")
			end
		else -- normal message
			--mcbMPSyncer.MPGame_ApplicationCallback_ReceivedChatMessage(msg, allied, sender)
			for _,cb in ipairs(mcbMPSyncer.chatRecievedCbs) do
				cb(msgo, allied, sender)
			end
		end
	end
	mcbMPSyncer.nextTribute = GUI.GetPlayerID()
	mcbMPSyncer.player = player
	GameCallback_FulfillTribute = function() return 1 end
	if LuaDebugger.Log then
		XNetwork.Chat_SendMessageToAll("@waWarning: Player "..GUI.GetPlayerID().." ("..XNetwork.GameInformation_GetLogicPlayerUserName(GUI.GetPlayerID())..") startet this map with active Debugger!")
	end
	if mcbMPSyncer.isMP()==3 then -- kimichuras server
		CNetwork.SetNetworkHandler("mcbMPSyncer_recieved_syncedCall", function(name, str)
			mcbMPSyncer.log("client mode: synced executing from Network "..str)
			mcbMPSyncer.virtualFuncs.execute(mcbMPSyncer.virtualFuncs.deserialize(str))
		end)
		mcbMPSyncer.allConnected = true
		for _,cb in ipairs(mcbMPSyncer.initCbs) do
			cb()
		end
		mcbMPSyncer.log("kimichuras server dont need to wait for init, ready to play")
		mcbMPSyncer.addChatRecievedCB(mcbMPSyncer.MPGame_ApplicationCallback_ReceivedChatMessage)
	else
		XNetwork.Chat_SendMessageToAll("@in"..GUI.GetPlayerID())
		mcbMPSyncer.addChatRecievedCB(function(msg, allied, sender)
			local msg2, sound, feedbs = mcbMPSyncer.formatChatMsg(msg, sender)
			GUI.AddNote(msg2)
			if sound then
				Sound.PlayGUISound(sound, 0)
			end
			if feedbs then
				Sound.PlayFeedbackSound(feedbs, 0)
			end
		end)
	end	
end

mcbMPSyncer.formatChatMsgDatabase = {
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
function mcbMPSyncer.formatChatMsg(msg, sender)
	local sound = Sounds.Misc_Chat
	if mcbMPSyncer.formatChatMsgDatabase[msg] then
		sound = mcbMPSyncer.formatChatMsgDatabase[msg].sound
		msg = mcbMPSyncer.getPlayerNameString(sender)..XGUIEng.GetStringTableText(mcbMPSyncer.formatChatMsgDatabase[msg].sttk)
		return msg, nil, sound
	end
	return msg, sound, nil
end

function mcbMPSyncer.getPlayerNameString(pl)
	local r,g,b = GUI.GetPlayerColor(pl)
	return " @color:"..r..","..g..","..b.." "..UserTool_GetPlayerName(pl).." @color:255,255,255 > "
end

function mcbMPSyncer.addChatRecievedCB(cb)
	table.insert(mcbMPSyncer.chatRecievedCbs, cb)
end

function mcbMPSyncer.removeChatRecievedCb(cb)
	for i=table.getn(mcbMPSyncer.chatRecievedCbs),1,-1 do
		if mcbMPSyncer.chatRecievedCbs[i]==cb then
			table.remove(mcbMPSyncer.chatRecievedCbs, i)
		end
	end
end

function mcbMPSyncer.addInitCB(cb)
	table.insert(mcbMPSyncer.initCbs, cb)
	if mcbMPSyncer.allConnected then
		cb()
	end
end

function mcbMPSyncer.log(txt)
	if LuaDebugger.Log then
		LuaDebugger.Log(txt)
	end
	if S5Hook then
		S5Hook.Log("mcbMPSyncer: "..txt)
	end
end

function mcbMPSyncer.executeSynced(f, ...)
	if not mcbMPSyncer.isMP() then
		mcbMPSyncer.log("SP mode, direct executing")
		mcbMPSyncer.virtualFuncs.funcs[f].func(unpack(arg))
		return
	end
	assert(mcbMPSyncer.allConnected)
	if mcbMPSyncer.isMP()==3 then -- kimichuras modserver
		f = mcbMPSyncer.virtualFuncs.serialize(f, unpack(arg))
		assert(mcbMPSyncer.virtualFuncs.deserialize(f)) -- be sure, deserialisation is possible
		mcbMPSyncer.log("host mode: sended CNetwork call for "..f)
		CNetwork.send_command("mcbMPSyncer_recieved_syncedCall", f)
		return
	end
	local cntxt = {}
	for i=1,XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer() do
		if XNetwork.GameInformation_IsHumanPlayerAttachedToPlayerID(i)==1 and Logic.PlayerGetLeftGameFlag(i)==0 then
			cntxt[i] = "needAck"
		end
	end
	local tId = mcbMPSyncer.nextTribute
	mcbMPSyncer.nextTribute = mcbMPSyncer.nextTribute + 8
	mcbMPSyncer.playerAck[tId] = cntxt
	f = mcbMPSyncer.virtualFuncs.serialize(f, unpack(arg))
	assert(mcbMPSyncer.virtualFuncs.deserialize(f)) -- be sure, deserialisation is possible
	mcbMPSyncer.log("host mode: sended tribute "..tId.." for call "..f)
	XNetwork.Chat_SendMessageToAll("@sf"..tId..":"..f)
end

function mcbMPSyncer.recievedFunc(f, sender)
	local st, en = string.find(f, "^%d+:")
	local id = string.sub(f, st, en-1)
	local toEval = string.sub(f, en+1)
	local func = mcbMPSyncer.virtualFuncs.deserialize(toEval)
	local trib = {
		Tribute = tonumber(id),
		pId = mcbMPSyncer.player,
		func = func,
		Callback = function(t)
			mcbMPSyncer.log("client mode: synced executing "..t.Tribute)
			--t.func()
			mcbMPSyncer.virtualFuncs.execute(t.func)
		end,
	}
	Logic.AddTribute(mcbMPSyncer.player, trib.Tribute, 0, 0, "", ResourceType.Gold, 0)
	SetupTributePaid(trib)
	mcbMPSyncer.log((sender==GUI.GetPlayerID() and "host mode: " or "client mode: ").."recieved tribute "..id.." from "..sender.." for "..toEval)
	XNetwork.Chat_SendMessageToAll("@sa"..id)
end

function mcbMPSyncer.recievedAck(a, sender)
	a = tonumber(a)
	if mcbMPSyncer.playerAck[a] then
		mcbMPSyncer.playerAck[a][sender] = "acked"
		mcbMPSyncer.log("host mode: ack recieved for "..a.." from "..sender)
		mcbMPSyncer.checkAcks(a)
	else
		mcbMPSyncer.log("client mode: dropped ack for "..a.." from "..sender..", not for me")
	end
end

function mcbMPSyncer.checkAcks(id)
	local cntxt = mcbMPSyncer.playerAck[id]
	for i=1,XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer() do
		if cntxt[i] == "needAck" then
			mcbMPSyncer.log("host mode: waiting for more acks to execute "..id)
			return
		end
	end
	mcbMPSyncer.log("host mode: started synced execution "..id)
	GUI.PayTribute(mcbMPSyncer.player, id)
	mcbMPSyncer.playerAck[id] = nil
end

function mcbMPSyncer.recievedInit(player)
	local p = tonumber(player)
	mcbMPSyncer.log("init recieved from "..p)
	if p~=GUI.GetPlayerID() then
		mcbMPSyncer.warningRepeat = true
		for _,s in ipairs(mcbMPSyncer.warnings) do
			XNetwork.Chat_SendMessageToAll("@wa"..s)
		end
		mcbMPSyncer.warningRepeat = nil
	end
	mcbMPSyncer.connected[p] = true
	for i=1,XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer() do
		if XNetwork.GameInformation_IsHumanPlayerAttachedToPlayerID(i)==1 and not mcbMPSyncer.connected[i] then
			return
		end
	end
	mcbMPSyncer.log("got all inits, sending start")
	XNetwork.Chat_SendMessageToAll("@st")
end

function mcbMPSyncer.executeUnsyncedAtSingle(pl, f, ...)
	if not mcbMPSyncer.isMP() then
		mcbMPSyncer.log("SP mode, direct executing")
		mcbMPSyncer.virtualFuncs.funcs[f].func(unpack(arg))
		return
	end
	assert(mcbMPSyncer.allConnected)
	f = mcbMPSyncer.virtualFuncs.serialize(f, unpack(arg))
	assert(mcbMPSyncer.virtualFuncs.deserialize(f)) -- be sure, deserialisation is possible
	mcbMPSyncer.log("host mode: sended single call to machine "..pl.." "..f)
	XNetwork.Chat_SendMessageToAll("@af"..pl..":"..f)
end

function mcbMPSyncer.executeUnsyncedAtAll(f, ...)
	if not mcbMPSyncer.isMP() then
		mcbMPSyncer.log("SP mode, direct executing")
		mcbMPSyncer.virtualFuncs.funcs[f].func(unpack(arg))
		return
	end
	assert(mcbMPSyncer.allConnected)
	f = mcbMPSyncer.virtualFuncs.serialize(f, unpack(arg))
	assert(mcbMPSyncer.virtualFuncs.deserialize(f)) -- be sure, deserialisation is possible
	mcbMPSyncer.log("host mode: sended single call to machine all "..f)
	XNetwork.Chat_SendMessageToAll("@af-1:"..f)
end

function mcbMPSyncer.recievedSingleFunc(f, sender)
	local st, en = string.find(f, "^%-?%d+:")
	local id = string.sub(f, st, en-1)
	local toEval = string.sub(f, en+1)
	if tonumber(id)~=GUI.GetPlayerID() and id~="-1" then
		mcbMPSyncer.log("client mode: dropped single call for "..id..", not for me")
		return
	end
	local func = mcbMPSyncer.virtualFuncs.deserialize(toEval)
	mcbMPSyncer.log("client mode: executing single call "..toEval)
	mcbMPSyncer.virtualFuncs.execute(func)
end

function mcbMPSyncer.isMP()
	if XNetworkUbiCom.Manager_DoesExist()==1 and XNetworkWrapper then -- kimichuras server (better detection method?)
		return 3
	elseif XNetworkUbiCom.Manager_DoesExist()==1 then
		return 2
	elseif XNetwork.Manager_DoesExist()==1 then
		return 1
	else
		return false
	end
end

function mcbMPSyncer.getHost()
	local mpmode = mcbMPSyncer.isMP()
	if not mpmode then
		return GUI.GetPlayerID()
	end
	if mpmode == 3 then
		local hostname = CNetwork.GameInformation_GetHost()
		for pl=1,XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer() do
			if XNetwork.GameInformation_GetLogicPlayerUserName(pl)==hostname then
				return pl
			end
		end
		return hostname
	end
	return XNetwork.GameInformation_GetPlayerIDByNetworkAddress(XNetwork.Host_UserInSession_GetHostNetworkAddress())
end

mcbMPSyncer.virtualFuncs = {funcs={}}

function mcbMPSyncer.virtualFuncs.create(func, vname, ...)
	assert(string.find(vname, "^%w+$"))
	local pattern = "^"..vname.."%("
	local serializer = {}
	local deserializer = {}
	for i,a in ipairs(arg) do
		pattern = pattern..a.pattern..", "
		table.insert(serializer, a.serialize)
		table.insert(deserializer, a.deserialize)
	end
	pattern = pattern.."%)$"
	local t = {pattern = pattern, serializer = serializer, deserializer = deserializer, func = func}
	mcbMPSyncer.virtualFuncs.funcs[vname] = t
	return t
end

function mcbMPSyncer.virtualFuncs.argumentTypeInt()
	return {pattern="(%-?%d+%.?%d*)", serialize=tostring, deserialize = tonumber}
end

function mcbMPSyncer.virtualFuncs.argumentTypeString()
	return {pattern = "\"(%w*)\"",
		serialize = function(s)
		return '"'..s..'"'
	end, deserialize = function(s)
		return s
	end}
end

function mcbMPSyncer.virtualFuncs.argumentTypeSimpleTable()
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

function mcbMPSyncer.virtualFuncs.parse(vfunc, str)
	local t = {string.find(str, vfunc.pattern)}
	if not t[1] then
		return
	end
	local context = {vfunc.func}
	for i=1, table.getn(vfunc.deserializer) do
		local dsr = vfunc.deserializer[i]
		local ar = t[i+2]
		context[i+1] = dsr(ar)
	end
	return context
end

function mcbMPSyncer.virtualFuncs.deserialize(string)
	for vname, vfunc in pairs(mcbMPSyncer.virtualFuncs.funcs) do
		local r = mcbMPSyncer.virtualFuncs.parse(vfunc, string)
		if r then
			return r
		end
	end
end

function mcbMPSyncer.virtualFuncs.serialize(vname, ...)
	local vfunc = mcbMPSyncer.virtualFuncs.funcs[vname]
	local str = vname.."("
	for i=1, table.getn(vfunc.serializer) do
		local a = arg[i]
		local sr = vfunc.serializer[i]
		str = str..sr(a)..", "
	end
	str = str..")"
	return str
end

function mcbMPSyncer.virtualFuncs.execute(context)
	local fnc = table.remove(context, 1)
	if LuaDebugger.Log then
		fnc(unpack(context))
	else
		xpcall(function()
			fnc(unpack(context))
		end, function(e)
			XNetwork.Chat_SendMessageToAll("Lua Error at player "..GUI.GetPlayerID()..": "..e)
		end)
	end
end

function mcbMPSyncer.virtualFuncs.patchLuaFunc(fname, ...)
	if not mcbMPSyncer.isMP() then
		return
	end
	local f = _G[fname]
	assert(type(f)=="function")
	local vname = string.gsub(fname, "%.", "")
	vname = string.gsub(vname, "_", "")
	local varg = {}
	for _, atyp in ipairs(arg) do
		if atyp=="string" then
			table.insert(varg, mcbMPSyncer.virtualFuncs.argumentTypeString())
		elseif atyp=="number" then
			table.insert(varg, mcbMPSyncer.virtualFuncs.argumentTypeInt())
		end
	end
	mcbMPSyncer.virtualFuncs.create(f, vname, unpack(varg))
	_G[fname] = function(...)
		mcbMPSyncer.executeSynced(vname, unpack(arg)) -- uses upvalue vname. never use this in SP!
	end
end

function mcbMPSyncer.virtualFuncs.debug_createEval()
	mcbMPSyncer.virtualFuncs.create(function(s)
		S5Hook.Eval(s)()
	end, "Eval", {pattern = "\"(.*)\"",		-- . is greedy, takes as much as possible.
		serialize = function(s)
			return '"'..s..'"'
		end, deserialize = function(s)
			return s
		end
	})
end

mcbMPSyncer.virtualFuncsWithReturn = {nextIndex=0, returnList={}, spFuncs={}}

function mcbMPSyncer.virtualFuncsWithReturn.create(func, vname, argListCall, argListReturn)
	table.insert(argListCall, 1, mcbMPSyncer.virtualFuncs.argumentTypeInt())
	table.insert(argListCall, 1, mcbMPSyncer.virtualFuncs.argumentTypeInt())
	table.insert(argListReturn, 1, mcbMPSyncer.virtualFuncs.argumentTypeInt())
	mcbMPSyncer.virtualFuncs.create(function(index, returnPlayer, ...)
		local r = {func(unpack(arg))}
		mcbMPSyncer.executeUnsyncedAtSingle(returnPlayer, vname.."Return", index, unpack(r))
	end, vname.."Call", unpack(argListCall))
	mcbMPSyncer.virtualFuncs.create(function(index, ...)
		local rf = mcbMPSyncer.virtualFuncsWithReturn.returnList[index]
		rf(unpack(arg))
	end, vname.."Return", unpack(argListReturn))
	mcbMPSyncer.virtualFuncsWithReturn.spFuncs[vname] = func
end

function mcbMPSyncer.virtualFuncsWithReturn.callUnsynced(pl, vname, returnFunc, ...)
	if not mcbMPSyncer.isMP() then
		mcbMPSyncer.log("SP mode, direct executing")
		returnFunc(mcbMPSyncer.virtualFuncsWithReturn.spFuncs[vname](unpack(arg)))
		return
	end
	local ind = mcbMPSyncer.virtualFuncsWithReturn.nextIndex
	mcbMPSyncer.virtualFuncsWithReturn.nextIndex = mcbMPSyncer.virtualFuncsWithReturn.nextIndex + 1
	mcbMPSyncer.virtualFuncsWithReturn.returnList[ind] = returnFunc
	mcbMPSyncer.executeUnsyncedAtSingle(pl, vname.."Call", ind, GUI.GetPlayerID(), unpack(arg))
end
