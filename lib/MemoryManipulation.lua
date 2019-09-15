if mcbPacker then --mcbPacker.ignore
mcbPacker.require("s5CommunityLib/comfort/table/KeyOf")
mcbPacker.require("s5CommunityLib/comfort/other/s5HookLoader")
mcbPacker.require("s5CommunityLib/comfort/entity/IsEntityOfType")
mcbPacker.require("s5CommunityLib/comfort/number/round")
mcbPacker.require("s5CommunityLib/tables/ArmorClasses")
mcbPacker.require("s5CommunityLib/comfort/table/CopyTable")
mcbPacker.require("comfort/framework2")
end --mcbPacker.ignore

--MemoryManipulation.ReadObj(S5Hook.GetEntityMem(132339))
--MemoryManipulation.ConvertToObjInfo("BehaviorList.GGL_CLimitedAttachmentBehavior.MaxAttachment", true)
--MemoryManipulation.SetSingleValue(65575, "BehaviorList.GGL_CLimitedAttachmentBehavior.Attachment1.Limit", 6)
--MemoryManipulation.ReadObj(MemoryManipulation.GetETypePointer(Entities.PU_Hero1a))
--MemoryManipulation.ReadObj(MemoryManipulation.GetPlayerStatusPointer(1))
--MemoryManipulation.ReadObj(MemoryManipulation.GetDamageModifierPointer(), nil, MemoryManipulation.ObjFieldInfo.DamageClassList)
--MemoryManipulation.ReadObj(MemoryManipulation.GetLogicPropertiesPointer())
--MemoryManipulation.ReadObj(MemoryManipulation.GetPlayerAttractionPropsPointer())
--MemoryManipulation.ReadObj(MemoryManipulation.GetTechnologyPointer(Technologies.GT_Architecture), nil, MemoryManipulation.ObjFieldInfo.Technology)
--MemoryManipulation.SetSingleValue(MemoryManipulation.GetETypePointer(Entities.PB_Residence1), "LogicProps.BlockingArea", {{{X=100,Y=100},{X=500,Y=500}}})

--- author:mcb		current maintainer:mcb		v0.1b
-- Gesammeltes Wissen über Siedler Objekte. Besteht aus verschiedenen Bereichen:
-- - LibFuncs: Einfachste Funktionen die Zugriff auf einen einzelnen Wert eines entities/annderen objektes geben.
-- - Spezielle Funktionen: Etwas kompliziertere Funktionen die meistens mehrere Werte gemeinsam ändern müssen.
-- - Hauptfunktionen: Grundlage für alles andere.
-- - ObjFieldInfo: Enthält alle notwendigen objekttypen/indizies und gibt ihnen strings als namen.
-- 		(das einzige was für eine andere Version angepasst werden muss).
-- - GetXXXPointer: Stellt Pointer auf bestimmte Objekte bereit.
-- Zur normalen verwendung muss nur LibFuncs und Spezielle Funktionen beachtet werden, der rest sollte nur für entwicklung verwendet werden.
-- (Natürlich nutzen LibFuncs und Spezielle Funktionen die anderen und sie müssen deswegen vorhanden sein, sie sollten aber nicht dikekt genutzt werden).
-- 
-- LibFuncs:
-- - MemoryManipulation.Get/SetLeaderExperience						Die Erfahrung eines Leaders.
-- - MemoryManipulation.Get/SetLeaderTroopHealth					Die gesundheit der Soldaten eines leaders (Alle aufaddiert, -1 -> noch nicht verwendet, voll).
-- - MemoryManipulation.Get/SetSettlerMovementSpeed					Die bewegungsgeschwidigkeit einer einheit (Scm/sec).
-- - MemoryManipulation.Get/SetSettlerRotationSpeed					Die rotationsgeschwindigkeit einer einheit (deg/sec).
-- - MemoryManipulation.GetLeaderOfSoldier							Der leader eines soldiers (kein set verfügbar).
-- - MemoryManipulation.GetBarracksAutoFillActive					Der autofill status einer Kaserne (Set über GUI).
-- - MemoryManipulation.Get/SetSoldierTypeOfLeaderType				Der typ der soldiers eines leaders.
-- - MemoryManipulation.Get/SetEntityTypeMaxRange					Die maximale Angriffsreichweite eines entitytyps (melee normalerweise 250).
-- - MemoryManipulation.Get/SetEntityScale							Der Skalierungsfaktor des entities.
-- - MemoryManipulation.Get/SetBuildingHeight						Die höhe eines Gebäudes (während bau ==bauvortschritt).
-- - MemoryManipulation.Get/SetSettlerOverheadWidget				Typ der Anzeige über dem settler (0->nur Name, 1->Name+Bar (auch für nicht Leader), 2->Worker,
-- 																		3->Name+Bar (nur Leader), 4->Nix).
-- - MemoryManipulation.Get/SetMovingEntityTargetPos				Die Zielposition, zu der ein Entity sich bewegt.
-- - MemoryManipulation.Get/SetEntityCamouflageRemaining			Die Zeit, die ein entity noch unsichtbar ist (nur standard-unsichtbarkeit, nicht Dieb).
-- - MemoryManipulation.GetEntityTimeToCamouflage					Die Zeit, die ein entity noch sichtbar ist (diebes-unsichtbarkeit, nicht standard).
-- - MemoryManipulation.Get/SetHeroResurrectionTime					Die Zeit, bis ein Held wiederbelebt wird.
-- - MemoryManipulation.Get/SetEntityLimitedLifespanRemainingSeconds	Die Zeit die ein LimitedLifespan entity noch lebt.
-- - MemoryManipulation.Get/SetEntityTypeLimitedLifespanSeconds		Die Zeit, die entities von diesem Typ leben.
-- - MemoryManipulation.Get/SetLeaderTypeUpkeepCost					Die Kosten die ein leader dieses Types jeden Zahltag kostet.
-- - MemoryManipulation.Get/SetEntityTypeMaxHealth					Die MaximalHP eines entitytypes.
-- - MemoryManipulation.Get/SetBuildingTypeKegEffectFactor			Der Schadens-Faktor der bei Diebes-Sabotagen verwendet wird.
-- - MemoryManipulation.Get/SetBuildingTypeAffectMotivation			Der Motivations-Effekt eines gebäudetypes (Set hat keine Wirkung auf bereits existierende Gebäude).
-- - MemoryManipulation.Get/SetEntityTypeSuspensionAnimation		Die suspended-animation eines entitytypes.
-- - MemoryManipulation.Get/SetLeaderTypeHealingPoints				Die HP die dieser entitytyp bei jeder regeneration dazuerhält.
-- - MemoryManipulation.Get/SetLeaderTypeHealingSeconds				Die Zeit zwischen Regenerationen dieses entitytypes.
-- - MemoryManipulation.Get/SetSettlerTypeDamageClass				Die Damageclass der autoattack eines entitytypes.
-- - MemoryManipulation.Get/SetSettlerTypeBattleWaitUntil			Die BattleWaitUntil der autoattack eines entitytypes.
-- - MemoryManipulation.Get/SetSettlerTypeMissChance				Die MissChance der autoattack eines entitytypes.
-- - MemoryManipulation.Get/SetSettlerTypeMaxRange					Die maximale reichweite der autoattack eines entitytypes.
-- - MemoryManipulation.Get/SetSettlerTypeMinRange					Die minimale reichweite der autoattacks eines entitytypes.
-- - MemoryManipulation.Get/SetLeaderTypeAutoAttackRange			Die reichweite in der leader dieses types automatisch angreifen.
-- - MemoryManipulation.Get/SetBuildingTypeNumOfAttractableSettlers	Die anzahl der VC-plätze die gebäude dieses types zur verfügung stellen (wird nicht von allen typen genutzt).
-- - MemoryManipulation.Get/SetThiefTypeTimeToSteal					Die zeit die ein dieb zum stehlen braucht.
-- - MemoryManipulation.Get/SetThiefTypeStealMax					Das Maximum, was ein dieb auf ein mal stiehlt.
-- - MemoryManipulation.Get/SetThiefTypeStealMin					Das Minimum, was ein dieb auf ein mal stiehlt.
-- - MemoryManipulation.Get/SetEntityTypeCamouflageDuration			Die dauer der tarnung (dauer bis aktivierung bei dieben) dieses types.
-- - MemoryManipulation.Get/SetEntityTypeCamouflageDiscoveryRange	Die reichweite, in der ein getartntes entity dieses types entdeckt wird.
-- - MemoryManipulation.Get/SetBuildingTypeDoorPos					Die relative position der tür eines entitytypes.
-- - MemoryManipulation.Get/SetWorkerTypeRefinerResourceType		Der resourcentyp der von veredlern dieses types abgeholt wird.
-- - MemoryManipulation.Get/SetWorkerTypeRefinerAmount				Die menge an resourcen die ein veredler dieses types abholt.
-- - MemoryManipulation.Get/SetBuildingTypeRefinerSupplier			Die entitycategory in dem arbeiter dieses gebäudes unveredlete rohstoffe abholen.
-- - MemoryManipulation.Get/SetBuildingTypeRefinerResourceType		Der resourcentyp den ein veredelungsgebäude dieses types produziert.
-- - MemoryManipulation.Get/SetBuildingTypeRefinerAmount			Die menge an resourcen die in einem veredelungsgebäude dieses types produziert wird.
-- - MemoryManipulation.Get/SetEntityTypeArmorClass					Die armorclass eines settlertypes oder buildingtypes.
-- - MemoryManipulation.Get/SetEntityTypeBlockingArea				Das blocking eines entitytypes, im Format {{pos1,pos2},{pos11,pos12}...} .
-- - MemoryManipulation.Get/SetBuildingTypeBuilderSlots				Die BuilderSlots eines entitytypes, im Format {{X,Y,r},{X,Y,r}...} .
-- - MemoryManipulation.Get/SetBlockingEntityTypeBuildBlock			Das BuildBlocking eines entitytypes, im Format {pos1,pos2}.
-- - MemoryManipulation.Get/SetEntityTypeModel						Das Model, das normalerweise für entities dieses types genutzt wird.
-- - MemoryManipulation.Get/SetEntityTypeCircularAttackDamage		Der Schaden den Helden dieses types mit einer CircularAttack verursachen.
-- - MemoryManipulation.GetSettlerCurrentAnimation					Die aktuelle Animation eines entities. (AnimateEntity zum setzen nutzen).
-- 
-- Spezielle Funktionen:
-- - MemoryManipulation.HasEntityBehavior(id, beh)					Testet ob ein entity ein spezielles behavior (gegeben über vtable) hat.
-- - MemoryManipulation.HasEntityTypeBehavior(ety, beh)				Testet ob ein entitytyp ein spezielles behaviorprops (gegeben über vtable) hat.
-- - MemoryManipulation.IsSoldier(id)								Gibt zurück ob ein entity ein soldier ist.
-- - MemoryManipulation.CostTableFromRead(r)						Erstellt ein normales CostTable von ausgelesenen Kosten.
-- - MemoryManipulation.CostTableToWritable(c, ignoreZeroes)		Erstellt zu schreibende Daten aus einem CostTable. (wenn ignoreZeroes gesetzt ist, werden nur Kosten~=0 geschrieben).
-- - MemoryManipulation.GetSettlerTypeCost(ty)						Gibt die Kosten für diesen Settler typ zurück (Leader oder soldier).
-- - MemoryManipulation.SetSettlerTypeCost(ty, c, ignoreZeroes)		Setzt die Kosten für diesen Settler typ.
-- - MemoryManipulation.GetEntityMaxRange(id)						Die maximale Angriffsreichweite eines entities (direkt vom entity oder vom typ, falls 0).
-- - MemoryManipulation.SetEntityTimeToCamouflage(id, sec)			Die Zeit, die ein entity noch sichtbar ist (diebes-unsichtbarkeit, nicht standard).
-- - MemoryManipulation.SetThiefStolenResourceInfo(id, rty, am)		Setzt Resourcentyp und Menge die ein Dieb bei sich trägt (Get über Logic).
-- - MemoryManipulation.ReanimateHero(id)							Belebt einen toten Helden wieder (ignoriert normalerweise nebenstehende Truppen).
-- - MemoryManipulation.GetBuildingTypeCost(ty)						Gibt die Kosten für den Bau eines Gebäudetypes zurück.
-- - MemoryManipulation.SetBuildingTypeCost(ty, c, ignoreZeroes)	Setzt die Kosten für den bau eines gebäudetypes.
-- - MemoryManipulation.GetBuildingTypeUpgradeCost(ty)				Die kosten um ein gebäude dieses types auf die nächste stufe auszubauen.
-- - MemoryManipulation.SetBuildingTypeUpgradeCost(ty, c, ignoreZeroes)		Setzt die Ausbaukosten (Logic.FillBuildingUpgradeCostsTable nicht aktualisiert).
-- - MemoryManipulation.SetHeroTypeAbilityRechargeTimeNeeded(typ, abilit, sec)	Setzt den cooldown einer heldenfähigkeit dieses entitytypes.
-- - MemoryManipulation.GetPlayerPaydayStarted(pl)					Gbt zurück, ob der Zahltag bei diesem Spieler gestartet ist.
-- - MemoryManipulation.SetPlayerPaydayProgress(pl, sec)			Setzt die Zeit bis zum nächsten Zahltag für einen Spieler (<0 für inaktiv).
-- - MemoryManipulation.SetPaydayFrequency(sec)						Setzt die Dauer zwischen den Zahltagen für alle Spieler.
-- - MemoryManipulation.SetLeaderMaxSoldiers(id, maxsol)			Setzt die maximale Soldatenzahl eines leaders.
-- - MemoryManipulation.SetBuidingMaxEaters(id, eaters)				Setzt die maximalen essensplätze einer Farm/Taverne.
-- - MemoryManipulation.SetBuildingMaxSleepers(id, sleepers)		Setzt die maximalen schlafplätze eines Wohnhauses.
-- - MemoryManipulation.GetEntityModel(id)							Gibt das im moment genutzte model eines entities zurück.
-- 
-- - MemoryManipulation.OnLeaveMap()								Muss beim verlassen der map aufgerufen werden (automatisch mit framework2).
-- - MemoryManipulation.OnLoadMap()									Muss beim starten der Map aufgerufen werden (automatisch mit s5HookLoader).
-- - MemoryManipulation.CreateLibFuncs()							Erstellt die LibFuncs, wird aus OnLoadMap aufgerufen, kann aber auch selbst aufgerufen werden.
-- 
-- Hauptfunktionen:
-- - MemoryManipulation.ReadObj(sv, objInfo, fieldInfo, readFilter)	Liest ein Objekt ein, sv ist ein pointer auf das objekt.
-- 																		objInfo (optional) Ist das table in das alles geschrieben wird (wird zurückgegeben).
-- 																		fieldInfo (optional) Dient zum überschreiben der ObjFieldInfo.
-- 																		readFilter (optional) Wenn gegeben, liest nur wenn der name in readFilter gegeben ist (true->alles).
-- - MemoryManipulation.WriteObj(sv, objInfo, fieldInfo)			Schreibt vorhandene werte in ein Objekt. (Parameter wie bei Read). Gibt zurück, ob irgendetwas geschrieben wurde.
-- - MemoryManipulation.ConvertToObjInfo(adr, val, objInfo)			Konvertiert einen String-pfad in die passende table-struktur.
-- - MemoryManipulation.GetSingleValue(sv, adr)						Liest einen einzelnen Wert von einem string-pfad. (Konvertiert entities zu pointern).
-- - MemoryManipulation.SetSingleValue(sv, adr, val)				Schreibt einen einzelnen Wert von einem String-pfad. (Konvertiert entities zu pointern).
-- - MemoryManipulation.ReadSingleBit(sv, off)						Liest ein int von sv[0] und extrahiert ein einzelnes bit.
-- - MemoryManipulation.WriteSingleBit(sv, off, b)					Ändert ein einzelnes bit an sv[0].
-- 
-- GetXXXPointer:
-- - MemoryManipulation.GetETypePointer(ety)						Gibt einen Pointer auf einen entitytyp zurück.
-- - MemoryManipulation.GetPlayerStatusPointer(player)				Gibt einen pointer auf das player-status objekt zurück.
-- - MemoryManipulation.GetDamageModifierPointer()					Gibt einen pointer auf das damage-modifier objekt zuück
-- 																		(vtable muss manuell mit MemoryManipulation.ObjFieldInfo.DamageClassList
-- 																		überschrieben werden).
-- - MemoryManipulation.GetLogicPropertiesPointer()					Gibt einen pointer auf das logic-props objekt zurück.
-- - MemoryManipulation.GetPlayerAttractionPropsPointer()			Gibt einen pointer auf das playerattractionprops objekt zurück.
-- - MemoryManipulation.GetTechnologyPointer(tid)					Gibt einen pointer auf eine technologie zurück
-- 																		(vtable muss manuell mit MemoryManipulation.ObjFieldInfo.Technology
-- 																		überschrieben werden).
-- 
-- Benötigt:
-- - S5Hook
-- - s5HookLoader
-- - framework2
-- - IsEntityOfType
-- - ArmorClasses
-- - round
-- - KeyOf
-- - CopyTable
MemoryManipulation = {}

MemoryManipulation.MemBackup = {BackupList={}}

function MemoryManipulation.MemBackup.CreateBackupOf(sv, size)
	local b = {}
	for i=1,size do
		b[i] = sv[i-1]:GetInt()
	end
	MemoryManipulation.MemBackup.BackupList[sv:GetInt()] = b
	return b
end

function MemoryManipulation.MemBackup.RestoreSingleBackup(sv, deleteBackup)
	local index = nil
	if type(sv)~="userdata" then
		index = sv
		sv = S5Hook.GetRawMem(sv)
	else
		index = sv:GetInt()
	end
	local b = MemoryManipulation.MemBackup.BackupList[index]
	if not b then
		return false
	end
	for i,v in ipairs(b) do
		sv[i-1]:SetInt(v)
	end
	if b.free then
		S5Hook.FreeMem(b.free)
	end
	if deleteBackup then
		MemoryManipulation.MemBackup.BackupList[index] = nil
	end
	return true
end

function MemoryManipulation.MemBackup.RestoreAll(deleteBackups)
	for sv, b in pairs(MemoryManipulation.MemBackup.BackupList) do
		MemoryManipulation.MemBackup.RestoreSingleBackup(sv)
	end
	if deleteBackups then
		MemoryManipulation.MemBackup.BackupList = {}
	end
end

MemoryManipulation.MemList = {}
function MemoryManipulation.MemList.init(sv, length)
	local s = CopyTable(MemoryManipulation.MemList)
	s.base = sv
	s.sv = sv[0]
	s.len = length/4
	local ep, bp = sv[1]:GetInt(), sv[0]:GetInt()
	S5Hook.SetPreciseFPU()
	s.num = (ep-bp)/length
	return s
end
function MemoryManipulation.MemList.initManually(sv, length, num)
	local s = CopyTable(MemoryManipulation.MemList)
	s.sv = sv
	s.len = length/4
	s.num = num
	return s
end
function MemoryManipulation.MemList:get(i)
	assert(i>=0 and i<self.num)
	return self.sv:Offset(i*self.len)
end
function MemoryManipulation.MemList:iterator()
	local i, count = -1, self.num
    return function()
        i = i + 1
        if i < count then
            return self:get(i)
        end
    end
end
function MemoryManipulation.MemList:override(newNum)
	assert(self.base)
	MemoryManipulation.MemBackup.RestoreSingleBackup(self.base, true) -- restore previous backup
	local b = MemoryManipulation.MemBackup.CreateBackupOf(self.base, 3)
	S5Hook.SetPreciseFPU()
	local newp = S5Hook.ReAllocMem(0, newNum*self.len*4)
	b.free = newp -- auto free on restore backup
	S5Hook.SetPreciseFPU()
	local ep = newp + newNum*self.len*4
	self.base[0]:SetInt(newp)
	self.base[1]:SetInt(ep)
	self.base[2]:SetInt(ep)
	self.num = newNum
	self.sv = self.base[0]
end

function MemoryManipulation.ReadObj(sv, objInfo, fieldInfo, readFilter)
	objInfo = objInfo or {}
	if not fieldInfo then
		fieldInfo = MemoryManipulation.ObjFieldInfo[sv[0]:GetInt()]
	end
	if not fieldInfo then
		return "todo"
	end
	assert(fieldInfo.hasNoVTable or fieldInfo.vtable==sv[0]:GetInt())
	for _,fi in ipairs(fieldInfo.fields) do
		if not readFilter or readFilter[fi.name]~=nil then
			--S5Hook.Log(fi.name)
			local sv2 = sv
			for _,i in ipairs(fi.index) do
				if sv2~=sv then
					sv2 = sv2[0]
				end
				sv2 = sv2:Offset(i)
			end
			local val = nil
			if fi.datatype==MemoryManipulation.DataType.Int then
				val = sv2[0]:GetInt()
			elseif fi.datatype==MemoryManipulation.DataType.Float then
				val = sv2[0]:GetFloat()
			elseif fi.datatype==MemoryManipulation.DataType.Bit then
				val = MemoryManipulation.ReadSingleBit(sv2, fi.bitOffset)
			elseif fi.datatype==MemoryManipulation.DataType.ObjectPointer then
				if sv2[0]:GetInt()>0 then
					val = MemoryManipulation.ReadObj(sv2[0], objInfo[fi.name] and objInfo[fi.name]~=true and objInfo[fi.name], MemoryManipulation.ObjFieldInfo[fi.vtableOverride], readFilter and readFilter[fi.name]~=true and readFilter[fi.name])
				end
			elseif fi.datatype==MemoryManipulation.DataType.ObjectPointerList then
				val = objInfo[fi.name]~=true and objInfo[fi.name] or {}
				local li = MemoryManipulation.MemList.init(sv2, 4)
				for sv3 in li:iterator() do
					if sv3[0]:GetInt()>0 then
						local vt = sv3[0][0]:GetInt()
						local vtn = MemoryManipulation.VTableNames[vt]
						--LuaDebugger.Log(vt..(KeyOf(vt, MemoryManipulation.ClassVTable) or "nil"))
						if (not readFilter or readFilter[fi.name][vtn]~=nil) and MemoryManipulation.ObjFieldInfo[vt] then
							val[vtn] = MemoryManipulation.ReadObj(sv3[0], val[vtn] and val[vtn]~=true and val[vtn], nil, readFilter and readFilter[fi.name]~=true and readFilter[fi.name][vtn]~=true and readFilter[fi.name][vtn])
						end
					end
				end
				objInfo[fi.name] = val
			elseif fi.datatype==MemoryManipulation.DataType.EmbeddedObject then
				val = MemoryManipulation.ReadObj(sv2, objInfo[fi.name] and objInfo[fi.name]~=true and objInfo[fi.name], MemoryManipulation.ObjFieldInfo[fi.vtableOverride], readFilter and readFilter[fi.name]~=true and readFilter[fi.name])
			elseif fi.datatype==MemoryManipulation.DataType.EmbeddedObjectList then
				val = objInfo[fi.name]~=true and objInfo[fi.name] or {}
				local i=1
				local li = MemoryManipulation.MemList.init(sv2, 4*fi.objectSize)
				for sv3 in li:iterator() do
					val[i] = MemoryManipulation.ReadObj(sv3, val[i], MemoryManipulation.ObjFieldInfo[fi.vtableOverride], readFilter and readFilter[fi.name]~=true and readFilter[fi.name])
					i=i+1
				end
				objInfo[fi.name] = val
			elseif fi.datatype==MemoryManipulation.DataType.ListOfInt then
				val = objInfo[fi.name]~=true and objInfo[fi.name] or {}
				local i=1
				local li = MemoryManipulation.MemList.init(sv2, 4)
				for sv3 in li:iterator() do
					val[i] = sv3[0]:GetInt()
					i=i+1
				end
				objInfo[fi.name] = val
			elseif fi.datatype==MemoryManipulation.DataType.String then
				if sv2[0]:GetInt()>0 then
					val = sv2[0]:GetString()
				end
			elseif fi.datatype==MemoryManipulation.DataType.DataPointerListSize then
				val = objInfo[fi.name]~=true and objInfo[fi.name] or {}
				local i=1
				local li = MemoryManipulation.MemList.initFromPointerAndSize(sv2, 4)
				for sv3 in li:iterator() do
					if sv3[0]:GetInt()>0 then
						val[i] = MemoryManipulation.ReadObj(sv3[0], val[i], MemoryManipulation.ObjFieldInfo[fi.vtableOverride], readFilter and readFilter[fi.name]~=true and readFilter[fi.name])
					end
					i=i+1
				end
				objInfo[fi.name] = val
			elseif fi.datatype==MemoryManipulation.DataType.EmbeddedFixedLengthFloats then
				val = objInfo[fi.name]~=true and objInfo[fi.name] or {}
				local i=1
				local li = MemoryManipulation.MemList.initManually(sv2, 4, fi.fixedLength)
				for sv3 in li:iterator() do
					val[i] = sv3[0]:GetFloat()
					i=i+1
				end
				objInfo[fi.name] = val
			elseif fi.datatype==MemoryManipulation.DataType.EmbeddedFixedLengthObjectPointers then
				val = objInfo[fi.name]~=true and objInfo[fi.name] or {}
				local i=1
				local li = MemoryManipulation.MemList.initManually(sv2, 4, fi.fixedLength)
				for sv3 in li:iterator() do
					val[i] = MemoryManipulation.ReadObj(sv3[0], val[i], MemoryManipulation.ObjFieldInfo[fi.vtableOverride], readFilter and readFilter[fi.name]~=true and readFilter[fi.name])
					i=i+1
				end
				objInfo[fi.name] = val
			elseif fi.datatype==nil then
				val = sv2
			end
			if fi.readConv then
				val = fi.readConv(val)
			end
			objInfo[fi.name] = val
		end
	end
	return objInfo
end

function MemoryManipulation.WriteObj(sv, objInfo, fieldInfo, noErrorOnCheck)
	local ret = false
	if not fieldInfo then
		fieldInfo = MemoryManipulation.ObjFieldInfo[sv[0]:GetInt()]
	end
	assert(fieldInfo.hasNoVTable or fieldInfo.vtable==sv[0]:GetInt())
	for _,fi in ipairs(fieldInfo.fields) do
		if objInfo[fi.name] then
			--S5Hook.Log(fi.name)
			local sv2 = sv
			for _,i in ipairs(fi.index) do
				if sv2~=sv then
					sv2 = sv2[0]
				end
				sv2 = sv2:Offset(i)
			end
			local noerr = true
			if noErrorOnCheck then
				if type(fi.check)=="function" then
					if not fi.check(objInfo[fi.name], sv) then
						noerr = false
					end
				end
				if type(fi.check)=="table" then
					if not KeyOf(objInfo[fi.name], fi.check) then
						noerr = false
					end
				end
				if type(fi.checkAll)=="function" then
					for k,v in pairs(objInfo[fi.name]) do
						if not fi.checkAll(k, v, sv) then
							noerr = false
						end
					end
				end
				if type(fi.checkAll)=="function" then
					for k,v in pairs(objInfo[fi.name]) do
						if not KeyOf(v, fi.checkAll) then
							noerr = false
						end
					end
				end
			else
				if type(fi.check)=="function" then
					assert(fi.check(objInfo[fi.name], sv))
				end
				if type(fi.check)=="table" then
					assert(KeyOf(objInfo[fi.name], fi.check))
				end
				if type(fi.checkAll)=="function" then
					for k,v in pairs(objInfo[fi.name]) do
						assert(fi.checkAll(k, v, sv))
					end
				end
				if type(fi.checkAll)=="function" then
					for k,v in pairs(objInfo[fi.name]) do
						assert(KeyOf(v, fi.checkAll))
					end
				end
			end
			if noerr then
				local val = objInfo[fi.name]
				if fi.writeConv then
					val = fi.writeConv(val)
				end
				if fi.datatype==MemoryManipulation.DataType.Int then
					sv2[0]:SetInt(val)
					ret = true
				elseif fi.datatype==MemoryManipulation.DataType.Float then
					sv2[0]:SetFloat(val)
					ret = true
				elseif fi.datatype==MemoryManipulation.DataType.Bit then
					MemoryManipulation.WriteSingleBit(sv2, fi.bitOffset, val)
					ret = true
				elseif fi.datatype==MemoryManipulation.DataType.ObjectPointer then
					if sv2[0]:GetInt()>0 then
						ret = MemoryManipulation.WriteObj(sv2[0], val, MemoryManipulation.ObjFieldInfo[fi.vtableOverride], noErrorOnCheck) or ret
					end
				elseif fi.datatype==MemoryManipulation.DataType.ObjectPointerList then
					local li = MemoryManipulation.MemList.init(sv2, 4)
					for sv3 in li:iterator() do
						if sv3[0]:GetInt()>0 then
							local vt = sv3[0][0]:GetInt()
							local vtn = MemoryManipulation.VTableNames[vt]
							if val[vtn] then
								ret = MemoryManipulation.WriteObj(sv3[0], val[vtn], nil, noErrorOnCheck) or ret
							end
						end
					end
				elseif fi.datatype==MemoryManipulation.DataType.EmbeddedObject then
					ret = MemoryManipulation.WriteObj(sv2, val, MemoryManipulation.ObjFieldInfo[fi.vtableOverride], noErrorOnCheck) or ret
				elseif fi.datatype==MemoryManipulation.DataType.ListOfInt then
					local li = MemoryManipulation.MemList.init(sv2, 4)
					li:override(table.getn(val))
					local i=1
					for sv3 in li:iterator() do
						sv3[0]:SetInt(val[i])
						i=i+1
					end
					ret = true
				elseif fi.datatype==MemoryManipulation.DataType.EmbeddedObjectList then
					local li = MemoryManipulation.MemList.init(sv2, 4*fi.objectSize)
					li:override(table.getn(val))
					local i=1
					for sv3 in li:iterator() do
						if val[i] then
							ret = MemoryManipulation.WriteObj(sv3, val[i], MemoryManipulation.ObjFieldInfo[fi.vtableOverride], noErrorOnCheck) or ret
						end
						i=i+1
					end
				elseif fi.datatype==MemoryManipulation.DataType.String then
					assert(false, "cannot write strings")
				elseif fi.datatype==MemoryManipulation.DataType.EmbeddedFixedLengthFloats then
					local li = MemoryManipulation.MemList.initManually(sv2, 4, fi.fixedLength)
					local i=1
					for sv3 in li:iterator() do
						if val[i] then
							sv3[0]:SetFloat(val[i])
							ret = true
						end
						i=i+1
					end
				elseif fi.datatype==MemoryManipulation.DataType.EmbeddedFixedLengthObjectPointers then
					local li = MemoryManipulation.MemList.initManually(sv2, 4, fi.fixedLength)
					local i=1
					for sv3 in li:iterator() do
						if val[i] then
							ret = MemoryManipulation.WriteObj(sv3[0], val[i], MemoryManipulation.ObjFieldInfo[fi.vtableOverride], noErrorOnCheck) or ret
						end
						i=i+1
					end
				end
			end
		end
	end
	return ret
end

function MemoryManipulation.ConvertToObjInfo(adr, val, objInfo)
	objInfo = objInfo or {}
	local t = objInfo
	local find, i = true, nil
	while true do
		if not string.find(adr, ".", nil, true) then
			t[adr] = val
			return objInfo, t, adr
		else
			i, i, find, adr = string.find(adr, "^([%w_]+)%.([%w_.]+)$")
			t[find] = t[find] or {}
			t = t[find]
		end
	end
end

function MemoryManipulation.GetSingleValue(sv, adr)
	if type(sv)=="string" then
		sv = GetID(sv)
	end
	if type(sv)=="number" then
		sv = S5Hook.GetEntityMem(sv)
	end
	local objInfo, t, n = nil, nil, nil
	if type(adr)=="table" then
		t,n={},{}
		for i,a in ipairs(adr) do
			objInfo, t[i], n[i] = MemoryManipulation.ConvertToObjInfo(a, true, objInfo)
		end
		MemoryManipulation.ReadObj(sv, objInfo, nil, objInfo)
		for i,a in ipairs(adr) do
			if t[i][n[i]]~=true then
				return t[i][n[i]]
			end
		end
		assert(false, "no valid adress found")
	else
		objInfo, t, n = MemoryManipulation.ConvertToObjInfo(adr, true)
		MemoryManipulation.ReadObj(sv, objInfo, nil, objInfo)
		assert(t[n]~=true, "no valid adress found")
		return t[n]
	end
end

function MemoryManipulation.SetSingleValue(sv, adr, val)
	if type(sv)=="string" then
		sv = GetID(sv)
	end
	if type(sv)=="number" then
		sv = S5Hook.GetEntityMem(sv)
	end
	local objInfo= nil
	if type(adr)=="table" then
		for i,a in ipairs(adr) do
			objInfo = MemoryManipulation.ConvertToObjInfo(a, val, objInfo)
		end
		assert(MemoryManipulation.WriteObj(sv, objInfo), "no valid adress found")
	else
		local objInfo = MemoryManipulation.ConvertToObjInfo(adr, val)
		assert(MemoryManipulation.WriteObj(sv, objInfo), "no valid adress found")
	end
end

function MemoryManipulation.ReadSingleBit(sv, off)
	local v = sv[0]:GetInt()
	v = bit32.band(1, bit32.rshift(v, off))
	return v
end

function MemoryManipulation.WriteSingleBit(sv, off, b)
	local v = sv[0]:GetInt()
	assert(b==1 or b==0)
	if MemoryManipulation.ReadSingleBit(sv, off)~=b then
		v = bit32.bxor(v, bit32.lshift(1, off)) -- swap it
	end
	sv[0]:SetInt(v)
end

function MemoryManipulation.HasEntityBehavior(id, beh)
	local vtn = MemoryManipulation.VTableNames[beh]
	assert(vtn)
	local objInfo, t, n = MemoryManipulation.ConvertToObjInfo("BehaviorList."..vtn..".BehaviorIndex", true)
	MemoryManipulation.ReadObj(S5Hook.GetEntityMem(id), objInfo, nil, objInfo)
	return t[n]~=true
end

function MemoryManipulation.HasEntityTypeBehavior(ety, beh)
	local vtn = MemoryManipulation.VTableNames[beh]
	assert(vtn)
	local objInfo, t, n = MemoryManipulation.ConvertToObjInfo("BehaviorProps."..vtn..".BehaviorIndex", true)
	MemoryManipulation.ReadObj(MemoryManipulation.GetETypePointer(ety), objInfo, nil, objInfo)
	return t[n]~=true
end

function MemoryManipulation.GetETypePointer(ety)
	return S5Hook.GetRawMem(9002416)[0][16]:Offset(ety*8)
end

function MemoryManipulation.GetPlayerStatusPointer(player)
	return S5Hook.GetRawMem(8758176)[0][10][player*2+1]
end

function MemoryManipulation.GetDamageModifierPointer()
	return S5Hook.GetRawMem(8758236)[0][2]
end

function MemoryManipulation.GetLogicPropertiesPointer()
	return S5Hook.GetRawMem(8758240)[0]
end

function MemoryManipulation.GetPlayerAttractionPropsPointer()
	return S5Hook.GetRawMem(8809088)[0]
end

function MemoryManipulation.GetTechnologyPointer(tid)
	return S5Hook.GetRawMem(8758176)[0][13][1][tid-1]
end

function MemoryManipulation.OnLeaveMap()
	MemoryManipulation.MemBackup.RestoreAll(true)
	S5Hook.ReloadEntities()
end

function MemoryManipulation.OnLoadMap()
	if not MemoryManipulation.LibFuncsCreated then
		MemoryManipulation.CreateLibFuncs()
	end
end

MemoryManipulation.ClassVTable = {
	-- main entities
	EGL_CGLEEntityProps = tonumber("76E47C", 16),
	EGL_CGLEEntity = tonumber("783E74", 16),
	
	GGL_CEntityProperties = tonumber("776FEC", 16),
	EGL_CMovingEntity = tonumber("783F84", 16),
	GGL_CEvadingEntity = tonumber("770A7C", 16),
	
	GGL_CGLSettlerProps = tonumber("76E498", 16),
	GGL_CSettler = tonumber("76E3CC", 16),
	
	GGL_CGLAnimalProps = tonumber("779074", 16),
	GGL_CAnimal = tonumber("778F7C", 16),
	
	EGL_CAmbientSoundEntity = tonumber("78568C", 16),
	
	GGL_CBuildBlockProperties = tonumber("76EB38", 16),
	
	GGL_CGLBuildingProps = tonumber("76EC78", 16),
	GGL_CBuilding = tonumber("76EB94", 16),
	
	GGL_CBridgeProperties = tonumber("778148", 16),
	GGL_CBridgeEntity = tonumber("77805C", 16),
	
	GGL_CResourceDoodadProperties = tonumber("76FF68", 16),
	GGL_CResourceDoodad = tonumber("76FEA4", 16),
	
	-- display
	ED_CDisplayEntityProps = tonumber("788840", 16),
	
	-- behaviors
	EGL_CGLEBehaviorProps = tonumber("772A2C", 16),
	GGL_CBehaviorWalkCommand = tonumber("7736A4", 16),
	EGL_GLEBehaviorMultiSubAnims = tonumber("785EEC", 16),
	
	GGL_CHeroBehaviorProps = tonumber("7767F4", 16),
	GGL_CHeroBehavior = tonumber("77677C", 16),
	
	GGL_CBattleBehaviorProps = tonumber("7731C0", 16),
	GGL_CBattleBehavior = tonumber("77313C", 16),
	GGL_CLeaderBehaviorProps = tonumber("775FA4", 16),
	GGL_CLeaderBehavior = tonumber("7761E0", 16),
	GGL_CSoldierBehaviorProps = tonumber("773D10", 16),
	GGL_CSoldierBehavior = tonumber("773CC8", 16),
	GGL_CSerfBattleBehaviorProps = tonumber("774B50", 16),
	GGL_CSerfBattleBehavior = tonumber("774A98", 16),
	GGL_CBattleSerfBehaviorProps = tonumber("77889C", 16),
	GGL_CBattleSerfBehavior = tonumber("7788C4", 16),
	
	GGL_CLimitedAttachmentBehaviorProperties = tonumber("775EB4", 16),
	GGL_CLimitedAttachmentBehavior = tonumber("775E84", 16),
	
	GGL_CGLAnimationBehaviorExProps = tonumber("776C48", 16),
	GGL_CGLBehaviorAnimationEx = tonumber("776B64", 16),
	
	GGL_CHeroAbilityProps = tonumber("773774", 16),
	GGL_CBombPlacerBehavior = tonumber("7783D8", 16),
	
	GGL_CCamouflageBehaviorProps = tonumber("7778D8", 16),
	GGL_CCamouflageBehavior = tonumber("7738F4", 16),
	GGL_CThiefCamouflageBehavior = tonumber("773934", 16),
	GD_CCamouflageBehaviorProps = tonumber("76AEA0", 16),
	
	GGL_CHeroHawkBehaviorProps = tonumber("77672C", 16),
	GGL_CHeroHawkBehavior = tonumber("7766F0", 16),
	
	GGL_CInflictFearAbilityProps = tonumber("776674", 16),
	GGL_CInflictFearAbility = tonumber("776638", 16),
	
	GGL_CCannonBuilderBehaviorProps = tonumber("777510", 16),
	GGL_CCannonBuilderBehavior = tonumber("7774D4", 16),
	
	GGL_CRangedEffectAbilityProps = tonumber("774E9C", 16),
	GGL_CRangedEffectAbility = tonumber("774E54", 16),
	
	GGL_CCircularAttackProps = tonumber("7774A0", 16),
	GGL_CCircularAttack = tonumber("777464", 16),
	
	GGL_CSummonBehaviorProps = tonumber("773C50", 16),
	GGL_CSummonBehavior = tonumber("773C10", 16),
	
	GGL_CConvertSettlerAbilityProps = tonumber("7772D0", 16),
	GGL_CConvertSettlerAbility = tonumber("777294", 16),
	
	GGL_CSniperAbilityProps = tonumber("7745E8", 16),
	GGL_CSniperAbility = tonumber("7745AC", 16),
	
	GGL_CMotivateWorkersAbilityProps = tonumber("775788", 16),
	GGL_CMotivateWorkersAbility = tonumber("77574C", 16),
	
	GGL_CShurikenAbilityProps = tonumber("7746B4", 16),
	GGL_CShurikenAbility = tonumber("774658", 16),
	
	EGL_CMovementBehaviorProps = tonumber("784938", 16),
	GGL_CBehaviorDefaultMovement = tonumber("7786AC", 16),
	GGL_CSettlerMovement = tonumber("77471C", 16),
	GGL_CLeaderMovement = tonumber("775ED4", 16),
	GGL_CSoldierMovement = tonumber("77438C", 16),
	
	GGL_CSentinelBehaviorProps = tonumber("774BAC", 16),
	GGL_CSentinelBehavior = tonumber("774B6C", 16),
	
	GGL_CWorkerBehaviorProps = tonumber("772B90", 16),
	GGL_CWorkerBehavior = tonumber("772B30", 16),
	
	GGL_CSerfBehaviorProps = tonumber("774A14", 16),
	GGL_CSerfBehavior = tonumber("774874", 16),
	
	GGL_CFormationBehaviorProperties = tonumber("776DE4", 16),
	GGL_CFormationBehavior = tonumber("776D60", 16),
	
	GGL_CCamperBehaviorProperties = tonumber("7777D4", 16),
	GGL_CCamperBehavior = tonumber("77777C", 16),
	
	GGL_CGLBehaviorPropsDying = tonumber("778634", 16),
	GGL_CGLBehaviorDying = tonumber("7785E4", 16),
	
	GGL_CBombBehaviorProperties = tonumber("7784A0", 16),
	GGL_CBombBehavior = tonumber("778468", 16),
	
	GGL_CKegBehaviorProperties = tonumber("776558", 16),
	GGL_CKegBehavior = tonumber("7764D8", 16),
	
	GGL_CThiefBehaviorProperties = tonumber("7739E0", 16),
	GGL_CThiefBehavior = tonumber("7739B0", 16),
	
	GGL_CAutoCannonBehaviorProps = tonumber("778CD4", 16),
	GGL_CAutoCannonBehavior = tonumber("778CF0", 16),
	
	GGL_CResourceRefinerBehaviorProperties = tonumber("774C24", 16),
	GGL_CResourceRefinerBehavior = tonumber("774BCC", 16),
	
	GGL_CAffectMotivationBehaviorProps = tonumber("7791D4", 16),
	GGL_CAffectMotivationBehavior = tonumber("77918C", 16),
	
	GGL_CLimitedLifespanBehaviorProps = tonumber("775DE4", 16),
	GGL_CLimitedLifespanBehavior = tonumber("775D9C", 16),
	
	GGL_CBarrackBehaviorProperties = tonumber("778B34", 16),
	GGL_CBarrackBehavior = tonumber("778A68", 16),
	
	-- CNetEvents
	BB_CEvent = tonumber("762114", 16),
	EGL_CNetEvent2Entities = tonumber("76DD60", 16),
	EGL_CNetEventEntityAndPos = tonumber("76DD50", 16),
	EGL_CNetEventEntityAndPosArray = tonumber("770704", 16),
	GGL_CNetEventExtractResource = tonumber("77061C", 16),
	GGL_CNetEventTransaction = tonumber("77062C", 16),
	
	EGL_CNetEventEntityID = tonumber("766C28", 16),
	GGL_CNetEventCannonCreator = tonumber("7705EC", 16),
	GGL_CNetEventEntityIDAndUpgradeCategory = tonumber("77060C", 16),
	EGL_CNetEventEntityIDAndInteger = tonumber("766C48", 16),
	GGL_CNetEventTechnologyAndEntityID = tonumber("7705FC", 16),
	
	EGL_CNetEventPlayerID = tonumber("766C18", 16),
	EGL_CNetEventIntegerAndPlayerID = tonumber("7705BC", 16),
	EGL_CNetEventPlayerIDAndInteger = tonumber("7705CC", 16),
	EGL_CNetEventEntityIDAndPlayerID = tonumber("766C38", 16),
	EGL_CNetEventEntityIDAndPlayerIDAndEntityType = tonumber("77057C", 16),
	GGL_CNetEventEntityIDPlayerIDAndInteger = tonumber("77064C", 16),
	GGL_CNetEventBuildingCreator = tonumber("770714", 16),
	
	EGL_CNetEvent2PlayerIDs = tonumber("7705AC", 16),
	EGL_CNetEvent2PlayerIDsAndInteger = tonumber("7705DC", 16),
	GGL_CNetEventPlayerResourceDonation = tonumber("77063C", 16),
	
	-- other stuff
	GGlue_CGlueEntityProps = tonumber("788824", 16),
	EGL_CGLEModelSet = tonumber("76E380", 16),
	
	GGL_CLogicProperties = tonumber("76EFCC", 16),
	GGL_CLogicProperties_SBuildingUpgradeCategory = tonumber("76EF10", 16),
	GGL_CLogicProperties_SSettlerUpgradeCategory = tonumber("76EF18", 16),
	GGL_CLogicProperties_STaxationLevel = tonumber("76EF20", 16),
	GGL_CLogicProperties_STradeResource = tonumber("76EF28", 16),
	GGL_CLogicProperties_SBlessCategory = tonumber("76EFC4", 16),
	
	GGL_CDamageClassProps = tonumber("788978", 16),
	
	-- player stuff
	GGL_CPlayerStatus = tonumber("76FA88", 16),
	
	GGL_CPlayerAttractionProps = tonumber("770834", 16),
	GGL_CPlayerAttractionHandler = tonumber("770868", 16),
	
	-- effects
	EGL_CEffect = tonumber("784B28", 16),
	EGL_CFlyingEffect = tonumber("7775E4", 16),
	GGL_CCannonBallEffect = tonumber("777690", 16),
	GGL_CArrowEffect = tonumber("778E24", 16),
}
MemoryManipulation.VTableNames = {}
for k,v in pairs(MemoryManipulation.ClassVTable) do
	MemoryManipulation.VTableNames[v] = k
end
MemoryManipulation.DataType = {Int=1, Float=2, Bit=3, String=4,
	ObjectPointer=11, EmbeddedObject=12, DataPointerListSize=13, EmbeddedFixedLengthObjectPointers=14,
	ObjectPointerList=21, EmbeddedObjectList=22,
	ListOfInt=31, EmbeddedFixedLengthFloats=32,
}
MemoryManipulation.ObjFieldInfo = {
	-- entities
	markerEntities=nil,
	[MemoryManipulation.ClassVTable.EGL_CGLEEntity] = {
		vtable = MemoryManipulation.ClassVTable.EGL_CGLEEntity,
		fields = {
			{name="EntityId", index={2}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="EntityType", index={4}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="ModelOverride", index={5}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a==0 or KeyOf(a, Models) end}, -- 0 for use entitytype model
			{name="PlayerId", index={6}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="Position", index={22}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="PositionWithRotation"},
			{name="Scale", index={25}, datatype=MemoryManipulation.DataType.Float},
			{name="DefaultBehavourFlag", index={27}, datatype=MemoryManipulation.DataType.Bit, bitOffset=0, check={1,0}}, -- ?
			{name="UserControlFlag", index={27}, datatype=MemoryManipulation.DataType.Bit, bitOffset=1, check={1,0}}, -- ?
			{name="UnattackableFlag", index={27}, datatype=MemoryManipulation.DataType.Bit, bitOffset=2, check={1,0}}, -- ?
			{name="SelectableFlag", index={28}, datatype=MemoryManipulation.DataType.Bit, bitOffset=0, check={1,0}},
			{name="UserControlFlag", index={28}, datatype=MemoryManipulation.DataType.Bit, bitOffset=1, check={1,0}}, -- ?
			{name="VisibleFlag", index={28}, datatype=MemoryManipulation.DataType.Bit, bitOffset=2, check={1,0}},
			{name="BehaviorList", index={31}, datatype=MemoryManipulation.DataType.ObjectPointerList},
			{name="CurrentState", index={34}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="EntityStateBehaviors", index={35}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="TaskListId", index={36}, datatype=MemoryManipulation.DataType.Int, check={}}, -- use logic to set
			{name="TaskIndex", index={37}, datatype=MemoryManipulation.DataType.Int, check={}}, -- where in the task list is the entity
			{name="CurrentHealth", index={50}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="ScriptName", index={51}, datatype=MemoryManipulation.DataType.String},
			{name="ScriptCommandLine", index={52}, datatype=MemoryManipulation.DataType.String}, -- i think this is script executed when the entity is created, used by mapeditor
			{name="Exploration", index={53}, datatype=MemoryManipulation.DataType.Float, check={}},
			{name="TaskListStart", index={54}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="InvulnerabilityAndSuspended", index={57}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="SuspensionTurn", index={58}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="ScriptingValue", index={59}, datatype=MemoryManipulation.DataType.Int, check={}}, -- no idea for what this is
			{name="StateChangeCounter", index={63}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="TaskListChangeCounter", index={64}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="NumberOfAuraEffects", index={65}, datatype=MemoryManipulation.DataType.Int, check={}},
		},
	},
	[MemoryManipulation.ClassVTable.EGL_CMovingEntity] = {
		vtable = MemoryManipulation.ClassVTable.EGL_CMovingEntity,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CGLEEntity},
		fields = {
			{name="TargetPosition", index={66}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="Position"},
			{name="TargetRotationValid", index={68}, datatype=MemoryManipulation.DataType.Bit, bitOffset=0, check={1,0}},
			{name="TargetRotation", index={69}, datatype=MemoryManipulation.DataType.Float, readConv=math.deg, writeConv=math.rad},
			{name="MovementState", index={70}, datatype=MemoryManipulation.DataType.Int, check={}}, -- ?
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CEvadingEntity] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CEvadingEntity,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CMovingEntity},
		fields = {
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CSettler] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CSettler,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CEvadingEntity},
		fields = {
			{name="TimeToWait", index={75}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="HeadIndex", index={76}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="HeadParams", index={77}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="ExperiencePoints", index={85}, datatype=MemoryManipulation.DataType.Float, check={}},
			{name="ExperienceLevel", index={85}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="MovingSpeed", index={89}, datatype=MemoryManipulation.DataType.Float, check={}},
			{name="Damage", index={91}, datatype=MemoryManipulation.DataType.Float, check={}},
			{name="Dodge", index={93}, datatype=MemoryManipulation.DataType.Float, check={}},
			{name="Motivation", index={95}, datatype=MemoryManipulation.DataType.Float, check={}},
			{name="Armor", index={97}, datatype=MemoryManipulation.DataType.Float, check={}},
			{name="CurrentAmountSoldiers", index={99}, datatype=MemoryManipulation.DataType.Float, check={}},
			{name="MaxAmountSoldiers", index={101}, datatype=MemoryManipulation.DataType.Float, check={}},
			{name="DamageBonus", index={103}, datatype=MemoryManipulation.DataType.Float, check={}},
			{name="ExplorationCache", index={105}, datatype=MemoryManipulation.DataType.Float, check={}},
			{name="MaxAttackRange", index={107}, datatype=MemoryManipulation.DataType.Float, check={}},
			{name="AutoAttackRange", index={109}, datatype=MemoryManipulation.DataType.Float, check={}},
			{name="HealingPoints", index={111}, datatype=MemoryManipulation.DataType.Float, check={}},
			{name="MissChance", index={113}, datatype=MemoryManipulation.DataType.Float, check={}},
			{name="Healthbar", index={115}, datatype=MemoryManipulation.DataType.Float, check={}},
			{name="SomeIntRegardingTaskLists", index={123}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="LeaderId", index={127}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="OverheadWidget", index={130}, datatype=MemoryManipulation.DataType.Int, check={0,1,2,3,4}},
			{name="ExperienceClass", index={131}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="BlessBuff", index={134}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="NPCMarker", index={135}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="LeaveBuildingTurn", index={136}, datatype=MemoryManipulation.DataType.Int, check={}},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CBuilding] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CBuilding,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CGLEEntity},
		fields = {
			{name="ApproachPosition", index={66}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="Position"},
			{name="LeavePosition", index={68}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="Position"},
			{name="IsActive", index={70}, datatype=MemoryManipulation.DataType.Bit, bitOffset=0, check={1,0}}, -- ?
			{name="IsRegistered", index={70}, datatype=MemoryManipulation.DataType.Bit, bitOffset=1, check={1,0}}, -- ?
			{name="IsUpgrading", index={70}, datatype=MemoryManipulation.DataType.Bit, bitOffset=2, check={1,0}}, -- ?
			{name="IsOvertimeActive", index={70}, datatype=MemoryManipulation.DataType.Bit, bitOffset=3, check={1,0}}, -- ?
			{name="HQAlarmActive", index={71}, datatype=MemoryManipulation.DataType.Bit, bitOffset=0, check={1,0}}, -- ?
			{name="MaxNumWorkers", index={72}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="CurrentTechnology", index={73}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="LatestAttackTurn", index={74}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="MostRecentDepartureTurn", index={75}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="BuildingHeight", index={76}, datatype=MemoryManipulation.DataType.Float}, -- also construction progress
			{name="Helathbar", index={77}, datatype=MemoryManipulation.DataType.Float}, -- also repair progress
			{name="UpgradeProgress", index={78}, datatype=MemoryManipulation.DataType.Float},
			{name="NumberOfRepairingSerfs", index={81}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="ConstructionSiteType", index={83}, datatype=MemoryManipulation.DataType.Int, check={}},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CBridgeEntity] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CBridgeEntity,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CBuilding},
		fields = {
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CResourceDoodad] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CResourceDoodad,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CGLEEntity},
		fields = {
			{name="ResourceType", index={66}, datatype=MemoryManipulation.DataType.Int, check=ResourceType},
			{name="ResourceAmount", index={67}, datatype=MemoryManipulation.DataType.Int},
			{name="ResourceAmountAdd", index={68}, datatype=MemoryManipulation.DataType.Int},
		},
	},
	[MemoryManipulation.ClassVTable.EGL_CAmbientSoundEntity] = {
		vtable = MemoryManipulation.ClassVTable.EGL_CAmbientSoundEntity,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CGLEEntity},
		fields = {
			{name="AmbientSoundType", index={67}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>0 and a <=22 end},
		},
	},
	-- entity props
	markerEntityProps=nil,
	[MemoryManipulation.ClassVTable.EGL_CGLEEntityProps] = {
		vtable = MemoryManipulation.ClassVTable.EGL_CGLEEntityProps,
		fields = {
			{name="Class", index={2}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="Categories", index={4}, datatype=MemoryManipulation.DataType.ListOfInt, checkAll=EntityCategories},
			{name="ApproachPos", index={7}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="Position"},
			{name="ApproachR", index={9}, datatype=MemoryManipulation.DataType.Float},
			{name="Race", index={10}, datatype=nil},
			{name="CanFloat", index={11}, datatype=MemoryManipulation.DataType.Bit, bitOffset=0, check={1,0}},
			{name="CanDrown", index={11}, datatype=MemoryManipulation.DataType.Bit, bitOffset=1, check={1,0}},
			{name="MapFileDontSave", index={11}, datatype=MemoryManipulation.DataType.Bit, bitOffset=2, check={1,0}},
			{name="DividesTwoSectors", index={11}, datatype=MemoryManipulation.DataType.Bit, bitOffset=3, check={1,0}},
			{name="ForceNoPlayer", index={12}, datatype=MemoryManipulation.DataType.Bit, bitOffset=0, check={1,0}},
			{name="AdjustWalkAnimSpeed", index={12}, datatype=MemoryManipulation.DataType.Bit, bitOffset=1, check={1,0}},
			{name="Visible", index={12}, datatype=MemoryManipulation.DataType.Bit, bitOffset=2, check={1,0}},
			{name="DoNotExecute", index={12}, datatype=MemoryManipulation.DataType.Bit, bitOffset=3, check={1,0}},
			{name="MaxHealth", index={13}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="Models", index={14}, datatype=MemoryManipulation.DataType.EmbeddedObject},
			{name="Exploration", index={19}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="ExperiencePoints", index={20}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="AccessCategory", index={21}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="NumBlockedPoints", index={22}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="SnapTolerance", index={23}, datatype=MemoryManipulation.DataType.Float},
			{name="DeleteWhenBuiltOn", index={24}, datatype=MemoryManipulation.DataType.Bit, bitOffset=0, check={1,0}},
			{name="NeedsPlayer", index={24}, datatype=MemoryManipulation.DataType.Bit, bitOffset=1, check={1,0}},
			{name="BlockingArea", index={35}, datatype=MemoryManipulation.DataType.EmbeddedObjectList, vtableOverride="AARectangle", objectSize=4},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CEntityProperties] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CEntityProperties,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CGLEEntityProps},
		fields = {
			{name="ResourceEntity", index={38}, datatype=MemoryManipulation.DataType.Int, check=Entities},
			{name="ResourceAmount", index={39}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="SummerEffect", index={40}, datatype=MemoryManipulation.DataType.Int, check=GGL_Effects},
			{name="WinterEffect", index={41}, datatype=MemoryManipulation.DataType.Int, check=GGL_Effects},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CGLSettlerProps] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CGLSettlerProps,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CGLEEntityProps},
		fields = {
			{name="HeadSet", index={38}, datatype=nil},
			{name="Hat", index={39}, datatype=nil},
			{name="Cost", index={40}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="costInfo"},
			{name="BuildFactor", index={58}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="RepairFactor", index={59}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="ArmorAmount", index={61}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="IdleTaskList", index={63}, datatype=MemoryManipulation.DataType.Int, check=TaskLists},
			{name="ArmorClass", index={60}, datatype=MemoryManipulation.DataType.Int, check=ArmorClasses},
			{name="DodgeChance", index={62}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="Upgrade", index={64}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="upgradeInfo"},
			{name="Convertible", index={85}, datatype=MemoryManipulation.DataType.Bit, bitOffset=1, check={1,0}},
			{name="Fearless", index={85}, datatype=MemoryManipulation.DataType.Bit, bitOffset=0, check={1,0}},
			{name="ModifyExploration", index={86}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="modifyEntityProps"},
			{name="ModifyHitpoints", index={91}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="modifyEntityProps"},
			{name="ModifySpeed", index={96}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="modifyEntityProps"},
			{name="ModifyDamage", index={101}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="modifyEntityProps"},
			{name="ModifyArmor", index={106}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="modifyEntityProps"},
			{name="ModifyDodge", index={111}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="modifyEntityProps"},
			{name="ModifyMaxRange", index={116}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="modifyEntityProps"},
			{name="ModifyMinRange", index={121}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="modifyEntityProps"},
			{name="ModifyDamageBonus", index={126}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="modifyEntityProps"},
			{name="ModifyGroupLimit", index={131}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="modifyEntityProps"},
			{name="AttractionSlots", index={136}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CGLAnimalProps] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CGLAnimalProps,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CGLEEntityProps},
		fields = {
			{name="DefaultTaskList", index={38}, datatype=MemoryManipulation.DataType.Int, check=TaskLists},
			{name="TerritoryRadius", index={39}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="WanderRangeMin", index={40}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="WanderRangeMax", index={41}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="ShyRange", index={42}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="MaxBuildingPollution", index={43}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="FleeTaskList", index={44}, datatype=MemoryManipulation.DataType.Int, check=TaskLists},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CBuildBlockProperties] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CBuildBlockProperties,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CGLEEntityProps},
		fields = {
			{name="BuildBlockArea", index={38}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="AARectangle"},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CResourceDoodadProperties] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CResourceDoodadProperties,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CBuildBlockProperties},
		fields = {
			{name="Radius", index={42}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="Center", index={43}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="Position"},
			{name="LineStart", index={45}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="Position"},
			{name="LineEnd", index={47}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="Position"},
			{name="ExtractTaskList", index={49}, datatype=MemoryManipulation.DataType.Int, check=TaskLists},
			{name="Model1", index={50}, datatype=MemoryManipulation.DataType.Int, check=Models},
			{name="Model2", index={51}, datatype=MemoryManipulation.DataType.Int, check=Models},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CGLBuildingProps] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CGLBuildingProps,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CBuildBlockProperties},
		fields = {
			{name="MaxWorkers", index={42}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="InitialMaxWorkers", index={43}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="NumberOfAttractableSettlers", index={44}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="Worker", index={45}, datatype=MemoryManipulation.DataType.Int, check=Entities},
			{name="DoorPos", index={46}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="Position"},
			{name="LeavePos", index={48}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="Position"},
			{name="ConstructionInfo", index={50}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="constructionInfo"},
			{name="BuildOn", index={76}, datatype=MemoryManipulation.DataType.ListOfInt, checkAll=Entities},
			{name="HideBase", index={79}, datatype=MemoryManipulation.DataType.Bit, bitOffset=0, check={1,0}},
			{name="CanBeSold", index={79}, datatype=MemoryManipulation.DataType.Bit, bitOffset=1, check={1,0}},
			{name="IsWall", index={79}, datatype=MemoryManipulation.DataType.Bit, bitOffset=2, check={1,0}},
			{name="Upgrade", index={80}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="upgradeInfo"},
			{name="UpgradeSite", index={101}, datatype=MemoryManipulation.DataType.Int, check=Entities},
			{name="ArmorClass", index={102}, datatype=MemoryManipulation.DataType.Int, check=ArmorClasses},
			{name="ArmorAmount", index={103}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="WorkTaskList", index={105}, datatype=MemoryManipulation.DataType.ListOfInt, checkAll=TaskLists},
			{name="MilitaryInfo", index={108}, datatype=nil},
			{name="CollapseTime", index={112}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="Convertible", index={113}, datatype=MemoryManipulation.DataType.Bit, bitOffset=0, check={1,0}},
			{name="ModifyExploration", index={114}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="modifyEntityProps"},
			{name="ModifyArmor", index={119}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="modifyEntityProps"},
			{name="KegEffectFactor", index={124}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CBridgeProperties] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CBridgeProperties,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CGLBuildingProps},
		fields = {
			{name="BridgeArea", index={126}, datatype=MemoryManipulation.DataType.EmbeddedObjectList, vtableOverride="AARectangle", objectSize=4},
			{name="Height", index={129}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="ConstructionModel0", index={130}, datatype=MemoryManipulation.DataType.Int, check=Models},
			{name="ConstructionModel1", index={131}, datatype=MemoryManipulation.DataType.Int, check=Models},
			{name="ConstructionModel2", index={132}, datatype=MemoryManipulation.DataType.Int, check=Models},
		},
	},
	-- entitytyp
	markerEntityType=nil,
	[MemoryManipulation.ClassVTable.GGlue_CGlueEntityProps] = {
		vtable = MemoryManipulation.ClassVTable.GGlue_CGlueEntityProps,
		fields = {
			{name="LogicProps", index={2}, datatype=MemoryManipulation.DataType.ObjectPointer},
			{name="DisplayProps", index={3}, datatype=MemoryManipulation.DataType.ObjectPointer},
			{name="BehaviorProps", index={5}, datatype=MemoryManipulation.DataType.ObjectPointerList},
		},
	},
	-- behavior props
	markerBehaviorProps=nil,
	[MemoryManipulation.ClassVTable.EGL_CGLEBehaviorProps] = {
		vtable = MemoryManipulation.ClassVTable.EGL_CGLEBehaviorProps,
		fields = {
			{name="BehaviorIndex", index={2}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="BehaviorClass", index={3}, datatype=MemoryManipulation.DataType.Int, check={}},
		},
	},
	[MemoryManipulation.ClassVTable.EGL_CMovementBehaviorProps] = {
		vtable = MemoryManipulation.ClassVTable.EGL_CMovementBehaviorProps,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CGLEBehaviorProps},
		fields = {
			{name="MovementSpeed", index={4}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="TurningSpeed", index={5}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end, readConv=math.deg, writeConv=math.rad},
			{name="MoveTaskList", index={6}, datatype=MemoryManipulation.DataType.Int, check=TaskLists},
			{name="MoveIdleAnim", index={7}, datatype=MemoryManipulation.DataType.Int, check=nil}, -- TODO needs check for valid animation
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CHeroAbilityProps] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CHeroAbilityProps,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CGLEBehaviorProps},
		fields = {
			{name="RechargeTimeSeconds", index={4}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CCamouflageBehaviorProps] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CCamouflageBehaviorProps,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CHeroAbilityProps},
		fields = {
			{name="DurationSeconds", index={5}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="DiscoveryRange", index={6}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CHeroHawkBehaviorProps] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CHeroHawkBehaviorProps,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CHeroAbilityProps},
		fields = {
			{name="HawkType", index={5}, datatype=MemoryManipulation.DataType.Int, check=Entities},
			{name="HawkMaxRange", index={6}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CInflictFearAbilityProps] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CInflictFearAbilityProps,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CHeroAbilityProps},
		fields = {
			{name="TaskList", index={5}, datatype=MemoryManipulation.DataType.Int, check=TaskLists},
			{name="Animation", index={6}, datatype=MemoryManipulation.DataType.Int, check=nil},
			{name="FlightDuration", index={7}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="Range", index={8}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="FlightRange", index={9}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CCannonBuilderBehaviorProps] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CCannonBuilderBehaviorProps,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CHeroAbilityProps},
		fields = {
			{name="TaskList", index={5}, datatype=MemoryManipulation.DataType.Int, check=TaskLists},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CRangedEffectAbilityProps] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CRangedEffectAbilityProps,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CHeroAbilityProps},
		fields = {
			{name="AffectsOwn", index={5}, datatype=MemoryManipulation.DataType.Bit, bitOffset=0, check={1,0}},
			{name="AffectsFriends", index={5}, datatype=MemoryManipulation.DataType.Bit, bitOffset=1, check={1,0}},
			{name="AffectsNeutrals", index={5}, datatype=MemoryManipulation.DataType.Bit, bitOffset=2, check={1,0}},
			{name="AffectsHostiles", index={5}, datatype=MemoryManipulation.DataType.Bit, bitOffset=3, check={1,0}},
			{name="AffectsMilitaryOnly", index={6}, datatype=MemoryManipulation.DataType.Bit, bitOffset=0, check={1,0}},
			{name="AffectsLongRangeOnly", index={6}, datatype=MemoryManipulation.DataType.Bit, bitOffset=1, check={1,0}},
			{name="Range", index={7}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="DurationSeconds", index={8}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="DamageFactor", index={9}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="ArmorFactor", index={10}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="HealthRecoveryFactor", index={11}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="Effect", index={12}, datatype=MemoryManipulation.DataType.Int, check=GGL_Effects},
			{name="HealEffect", index={13}, datatype=MemoryManipulation.DataType.Int, check=GGL_Effects},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CCircularAttackProps] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CCircularAttackProps,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CHeroAbilityProps},
		fields = {
			{name="TaskList", index={5}, datatype=MemoryManipulation.DataType.Int, check=TaskLists},
			{name="Animation", index={6}, datatype=MemoryManipulation.DataType.Int, check=nil},
			{name="DamageClass", index={7}, datatype=MemoryManipulation.DataType.Int, check=DamageClasses},
			{name="Damage", index={8}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="Range", index={9}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			-- 10 effect?
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CSummonBehaviorProps] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CSummonBehaviorProps,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CHeroAbilityProps},
		fields = {
			{name="SummonedEntityType", index={5}, datatype=MemoryManipulation.DataType.Int, check=Entities},
			{name="NumberOfSummonedEntities", index={6}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="SummonTaskList", index={7}, datatype=MemoryManipulation.DataType.Int, check=TaskLists},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CConvertSettlerAbilityProps] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CConvertSettlerAbilityProps,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CHeroAbilityProps},
		fields = {
			{name="ConversionTaskList", index={5}, datatype=MemoryManipulation.DataType.Int, check=TaskLists},
			{name="HPToMSFactor", index={6}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="ConversionStartRange", index={7}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="ConversionMaxRange", index={8}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CSniperAbilityProps] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CSniperAbilityProps,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CHeroAbilityProps},
		fields = {
			{name="TaskList", index={5}, datatype=MemoryManipulation.DataType.Int, check=TaskLists},
			{name="Animation", index={6}, datatype=MemoryManipulation.DataType.Int, check=nil},
			{name="Range", index={7}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="DamageFactor", index={8}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CMotivateWorkersAbilityProps] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CMotivateWorkersAbilityProps,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CHeroAbilityProps},
		fields = {
			{name="TaskList", index={5}, datatype=MemoryManipulation.DataType.Int, check=TaskLists},
			{name="Animation", index={6}, datatype=MemoryManipulation.DataType.Int, check=nil},
			{name="Range", index={7}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="WorkTimeBonus", index={8}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="Effect", index={9}, datatype=MemoryManipulation.DataType.Int, check=GGL_Effects},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CShurikenAbilityProps] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CShurikenAbilityProps,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CHeroAbilityProps},
		fields = {
			{name="TaskList", index={5}, datatype=MemoryManipulation.DataType.Int, check=TaskLists},
			{name="Animation", index={6}, datatype=MemoryManipulation.DataType.Int, check=nil},
			{name="Range", index={7}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="MaxArcDegree", index={8}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="NumberShuriken", index={9}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="ProjectileType", index={10}, datatype=MemoryManipulation.DataType.Int, check=GGL_Effects},
			{name="ProjectileOffsetHeight", index={11}, datatype=MemoryManipulation.DataType.Float, check=nil},
			{name="ProjectileOffsetFront", index={12}, datatype=MemoryManipulation.DataType.Float, check=nil},
			{name="ProjectileOffsetRight", index={13}, datatype=MemoryManipulation.DataType.Float, check=nil},
			{name="DamageClass", index={14}, datatype=MemoryManipulation.DataType.Int, check=DamageClasses},
			{name="DamageAmount", index={15}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CSentinelBehaviorProps] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CSentinelBehaviorProps,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CGLEBehaviorProps},
		fields = {
			{name="Range", index={4}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CGLAnimationBehaviorExProps] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CGLAnimationBehaviorExProps,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CGLEBehaviorProps},
		fields = {
			{name="SuspensionAnimation", index={4}, datatype=MemoryManipulation.DataType.Int, check=nil},
			{name="AnimSet", index={5}, datatype=MemoryManipulation.DataType.Int, check=nil},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CWorkerBehaviorProps] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CWorkerBehaviorProps,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CGLEBehaviorProps},
		fields = {
			{name="WorkTaskList", index={4}, datatype=MemoryManipulation.DataType.Int, check=TaskLists},
			{name="WorkIdleTaskList", index={5}, datatype=MemoryManipulation.DataType.Int, check=TaskLists},
			{name="WorkWaitUntil", index={7}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="EatTaskList", index={8}, datatype=MemoryManipulation.DataType.Int, check=TaskLists},
			{name="EatIdleTaskList", index={9}, datatype=MemoryManipulation.DataType.Int, check=TaskLists},
			{name="EatWait", index={10}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="RestTaskList", index={11}, datatype=MemoryManipulation.DataType.Int, check=TaskLists},
			{name="RestIdleTaskList", index={12}, datatype=MemoryManipulation.DataType.Int, check=TaskLists},
			{name="RestWait", index={13}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="LeaveTaskList", index={15}, datatype=MemoryManipulation.DataType.Int, check=TaskLists},
			{name="AmountResearched", index={16}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="WorkTimeChangeFarm", index={18}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="WorkTimeChangeResidence", index={19}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="WorkTimeChangeCamp", index={20}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="WorkTimeMaxCangeFarm", index={21}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="WorkTimeMaxChangeResidence", index={22}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="ExhaustedWorkMotivationMalus", index={23}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="TransportAmount", index={24}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="TransportModel", index={25}, datatype=MemoryManipulation.DataType.Int, check=Models},
			{name="TransportAnim", index={26}, datatype=MemoryManipulation.DataType.Int, check=nil},
			{name="ResourceToRefine", index={27}, datatype=MemoryManipulation.DataType.Int, check=ResourceType},
			{name="WorkTimeChangeWork", index={28}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CBattleBehaviorProps] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CBattleBehaviorProps,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CGLEBehaviorProps},
		fields = {
			{name="BattleTaskList", index={4}, datatype=MemoryManipulation.DataType.Int, check=TaskLists},
			{name="NormalAttackAnim1", index={5}, datatype=MemoryManipulation.DataType.Int, check=nil},
			{name="NormalAttackAnim2", index={6}, datatype=MemoryManipulation.DataType.Int, check=nil},
			{name="CounterAttackAnim", index={7}, datatype=MemoryManipulation.DataType.Int, check=nil},
			{name="FinishingMoveAnim", index={8}, datatype=MemoryManipulation.DataType.Int, check=nil},
			{name="MissAttackAnim", index={9}, datatype=MemoryManipulation.DataType.Int, check=nil},
			{name="BattleIdleAnim", index={10}, datatype=MemoryManipulation.DataType.Int, check=nil},
			{name="BattleWalkAnim", index={11}, datatype=MemoryManipulation.DataType.Int, check=nil},
			{name="HitAnim", index={12}, datatype=MemoryManipulation.DataType.Int, check=nil},
			{name="DamageClass", index={13}, datatype=MemoryManipulation.DataType.Int, check=DamageClasses},
			{name="DamageAmount", index={14}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="MaxDamageRandomBonus", index={15}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="DamageRange", index={16}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="ProjectileEffectID", index={17}, datatype=MemoryManipulation.DataType.Int, check=GGL_Effects},
			{name="ProjectileOffsetFront", index={18}, datatype=MemoryManipulation.DataType.Float},
			{name="ProjectileOffsetRight", index={19}, datatype=MemoryManipulation.DataType.Float},
			{name="ProjectileOffsetHeight", index={20}, datatype=MemoryManipulation.DataType.Float},
			{name="BattleWaitUntil", index={21}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="MissChance", index={22}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="MaxRange", index={23}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="MinRange", index={24}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CLeaderBehaviorProps] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CLeaderBehaviorProps,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CBattleBehaviorProps},
		fields = {
			{name="SoldierType", index={25}, datatype=MemoryManipulation.DataType.Int, check=Entities},
			{name="BarrackUpgradeCategory", index={26}, datatype=MemoryManipulation.DataType.Int, check=UpgradeCategories},
			{name="HomeRadius", index={27}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="HealingPoints", index={28}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="HealingSeconds", index={29}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="AutoAttackRange", index={30}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="UpkeepCosts", index={31}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CSoldierBehaviorProps] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CSoldierBehaviorProps,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CBattleBehaviorProps},
		fields = {
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CSerfBattleBehaviorProps] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CSerfBattleBehaviorProps,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CBattleBehaviorProps},
		fields = {
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CBattleSerfBehaviorProps] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CBattleSerfBehaviorProps,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CLeaderBehaviorProps},
		fields = {
			--{name="TurnIntoSerfTaskList", index={32}, datatype=MemoryManipulation.DataType.Int, check=TaskLists},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CSerfBehaviorProps] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CSerfBehaviorProps,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CGLEBehaviorProps},
		fields = {
			{name="ResourceSearchRadius", index={4}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="ApproachConbstructionSiteTaskList", index={5}, datatype=MemoryManipulation.DataType.Int, check=TaskLists},
			{name="TurnIntoBattleSerfTaskList", index={6}, datatype=MemoryManipulation.DataType.Int, check=TaskLists},
			{name="ExtractionInfo", index={8}, datatype=MemoryManipulation.DataType.EmbeddedObjectList, vtableOverride="ExtractionInfo", objectSize=3},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CLimitedAttachmentBehaviorProperties] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CLimitedAttachmentBehaviorProperties,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CGLEBehaviorProps},
		fields = {
			{name="Attachments", index={5}, datatype=MemoryManipulation.DataType.EmbeddedObjectList, vtableOverride="LimitedAttachmentProps", objectSize=9},
			--{name="Attachments", index={5}, datatype=nil},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CFormationBehaviorProperties] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CFormationBehaviorProperties,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CGLEBehaviorProps},
		fields = {
			{name="IdleAnims", index={5}, datatype=MemoryManipulation.DataType.EmbeddedObjectList, vtableOverride="IdleAnimProps", objectSize=2},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CCamperBehaviorProperties] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CCamperBehaviorProperties,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CGLEBehaviorProps},
		fields = {
			{name="Range", index={4}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CGLBehaviorPropsDying] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CGLBehaviorPropsDying,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CGLEBehaviorProps},
		fields = {
			{name="DyingTaskList", index={4}, datatype=MemoryManipulation.DataType.Int, check=TaskLists},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CHeroBehaviorProps] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CHeroBehaviorProps,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CGLEBehaviorProps},
		fields = {
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CBombBehaviorProperties] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CBombBehaviorProperties,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CGLEBehaviorProps},
		fields = {
			{name="Radius", index={4}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="Delay", index={5}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="Damage", index={6}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="ExplosionEffectID", index={7}, datatype=MemoryManipulation.DataType.Int, check=GGL_Effects},
			{name="AffectedEntityTypes", index={9}, datatype=MemoryManipulation.DataType.ListOfInt, checkAll=Entities},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CKegBehaviorProperties] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CKegBehaviorProperties,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CGLEBehaviorProps},
		fields = {
			{name="Radius", index={4}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="Damage", index={5}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="Delay", index={6}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="DamagePercent", index={7}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="ExplosionEffectID", index={8}, datatype=MemoryManipulation.DataType.Int, check=GGL_Effects},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CThiefBehaviorProperties] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CThiefBehaviorProperties,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CGLEBehaviorProps},
		fields = {
			{name="SecondsNeededToSteal", index={4}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="MinimumAmountToSteal", index={5}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="MaximumAmountToSteal", index={6}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="CarryingModelID", index={7}, datatype=MemoryManipulation.DataType.Int, check=Models},
			{name="StealGoodsTaskList", index={8}, datatype=MemoryManipulation.DataType.Int, check=TaskLists},
			{name="SecureGoodsTaskList", index={9}, datatype=MemoryManipulation.DataType.Int, check=TaskLists},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CAutoCannonBehaviorProps] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CAutoCannonBehaviorProps,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CGLEBehaviorProps},
		fields = {
			{name="NumberOfShots", index={4}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=-1 end},
			{name="RotationSpeed", index={5}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end, readConv=math.deg, writeConv=math.rad},
			{name="CannonBallEffectType", index={6}, datatype=MemoryManipulation.DataType.Int, check=GGL_Effects},
			{name="ReloadTime", index={10}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="MaxAttackRange", index={11}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end}, -- check autoattackrange and this
			{name="DamageClass", index={13}, datatype=MemoryManipulation.DataType.Int, check=DamageClasses},
			{name="DamageAmount", index={14}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="DamageRange", index={15}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="BattleTaskList", index={16}, datatype=MemoryManipulation.DataType.Int, check=TaskLists},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CResourceRefinerBehaviorProperties] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CResourceRefinerBehaviorProperties,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CGLEBehaviorProps},
		fields = {
			{name="ResourceType", index={4}, datatype=MemoryManipulation.DataType.Int, check=ResourceType},
			{name="InitialFactor", index={5}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="SupplierCategory", index={10}, datatype=MemoryManipulation.DataType.Int, check=nil},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CAffectMotivationBehaviorProps] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CAffectMotivationBehaviorProps,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CGLEBehaviorProps},
		fields = {
			{name="MotivationEffect", index={4}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CLimitedLifespanBehaviorProps] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CLimitedLifespanBehaviorProps,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CGLEBehaviorProps},
		fields = {
			{name="LifespanSeconds", index={4}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CBarrackBehaviorProperties] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CBarrackBehaviorProperties,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CGLEBehaviorProps},
		fields = {
			{name="TrainingTaskList1", index={4}, datatype=MemoryManipulation.DataType.Int, check=Tasklist},
			{name="TrainingTaskList2", index={5}, datatype=MemoryManipulation.DataType.Int, check=Tasklist},
			{name="TrainingTaskList3", index={6}, datatype=MemoryManipulation.DataType.Int, check=Tasklist},
			--{name="MaxTrainingNumber", index={7}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="LeaveTaskList", index={8}, datatype=MemoryManipulation.DataType.Int, check=Tasklist},
			{name="TrainingTime", index={9}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
		},
	},
	-- behaviors
	markerBehaviors=nil,
	["EGL_CGLEBehavior"] = {-- no vtable known
		fields = {
			{name="BehaviorIndex", index={1}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="EntityId", index={2}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="BehaviorProps", index={3}, datatype=MemoryManipulation.DataType.ObjectPointer},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CBehaviorDefaultMovement] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CBehaviorDefaultMovement,
		inheritsFrom = {"EGL_CGLEBehavior"},
		fields = {
			--{name="Counter", index={4}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="MovementSpeed", index={5}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="TurningSpeed", index={6}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end, readConv=math.deg, writeConv=math.rad},
			{name="SpeedFactor", index={7}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CSettlerMovement] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CSettlerMovement,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CBehaviorDefaultMovement},
		fields = {
			{name="PositionHiRes", index={9}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="PositionWithRotation"},
			{name="Position", index={12}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="PositionWithRotation"},
			{name="BlockingFlag", index={15}, datatype=MemoryManipulation.DataType.Bit, bitOffset=0, check={1,0}},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CLeaderMovement] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CLeaderMovement,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CBehaviorDefaultMovement},
		fields = {
			{name="MoveTaskList", index={8}, datatype=MemoryManipulation.DataType.Int, check=TaskLists},
			{name="NextWayPoint", index={9}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="PositionWithRotation"},
			{name="LastTurnPos", index={12}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="PositionWithRotation"},
			{name="IsPathingUsed", index={15}, datatype=MemoryManipulation.DataType.Bit, bitOffset=0, check={1,0}},
			{name="IsMoveFinished", index={15}, datatype=MemoryManipulation.DataType.Bit, bitOffset=1, check={1,0}},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CSoldierMovement] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CSoldierMovement,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CBehaviorDefaultMovement},
		fields = {
		},
	},
	["GGL_CHeroAbility"] = {-- no vtable known
		inheritsFrom = {"EGL_CGLEBehavior"},
		fields = {
			{name="AbilitySecondsCharged", index={5}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CCamouflageBehavior] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CCamouflageBehavior,
		inheritsFrom = {"GGL_CHeroAbility"},
		fields = {
			{name="InvisibilityRemaining", index={8}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CThiefCamouflageBehavior] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CThiefCamouflageBehavior,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CCamouflageBehavior},
		fields = {
			{name="TimeToInvisibility", index={9}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CHeroHawkBehavior] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CHeroHawkBehavior,
		inheritsFrom = {"GGL_CHeroAbility"},
		fields = {
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CInflictFearAbility] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CInflictFearAbility,
		inheritsFrom = {"GGL_CHeroAbility"},
		fields = {
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CBombPlacerBehavior] = { -- bomb entity hardcoded?
		vtable = MemoryManipulation.ClassVTable.GGL_CBombPlacerBehavior,
		inheritsFrom = {"GGL_CHeroAbility"},
		fields = {
			{name="StartPosition", index={6}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="Position"},
			{name="TargetPosition", index={8}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="Position"},
			{name="PlacedBomb", index={10}, datatype=MemoryManipulation.DataType.Bit, bitOffset=0, check={1,0}},
			-- 11 remaining turns?
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CCannonBuilderBehavior] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CCannonBuilderBehavior,
		inheritsFrom = {"GGL_CHeroAbility"},
		fields = {
			{name="StartPosition", index={7}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="Position"},
			{name="CannonType", index={9}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="FoundationType", index={10}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="PlacedCannon", index={11}, datatype=MemoryManipulation.DataType.Bit, bitOffset=0, check={1,0}},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CRangedEffectAbility] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CRangedEffectAbility,
		inheritsFrom = {"GGL_CHeroAbility"},
		fields = {
			{name="SecondsRemaining", index={7}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CCircularAttack] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CCircularAttack,
		inheritsFrom = {"GGL_CHeroAbility"},
		fields = {
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CSummonBehavior] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CSummonBehavior,
		inheritsFrom = {"GGL_CHeroAbility"},
		fields = {
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CConvertSettlerAbility] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CConvertSettlerAbility,
		inheritsFrom = {"GGL_CHeroAbility"},
		fields = {
			{name="TimeToConvert", index={7}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CSniperAbility] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CSniperAbility,
		inheritsFrom = {"GGL_CHeroAbility"},
		fields = {
			{name="TargetId", index={7}, datatype=MemoryManipulation.DataType.Int, check=IsValid},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CMotivateWorkersAbility] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CMotivateWorkersAbility,
		inheritsFrom = {"GGL_CHeroAbility"},
		fields = {
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CShurikenAbility] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CShurikenAbility,
		inheritsFrom = {"GGL_CHeroAbility"},
		fields = {
			{name="TargetId", index={7}, datatype=MemoryManipulation.DataType.Int, check=IsValid},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CSentinelBehavior] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CSentinelBehavior,
		inheritsFrom = {"EGL_CGLEBehavior"},
		fields = {
			{name="BehaviorProps2", index={4}, datatype=MemoryManipulation.DataType.ObjectPointer},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CGLBehaviorAnimationEx] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CGLBehaviorAnimationEx,
		inheritsFrom = {"EGL_CGLEBehavior"},
		fields = {
			{name="Animation", index={4}, datatype=MemoryManipulation.DataType.Int, check=nil},
			{name="AnimCategory", index={5}, datatype=MemoryManipulation.DataType.Int, check=nil},
			{name="SuspendedAnimation", index={6}, datatype=MemoryManipulation.DataType.Int, check=nil},
			{name="StartTurn", index={7}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="Duration", index={8}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="PlayBackwards", index={9}, datatype=MemoryManipulation.DataType.Bit, bitOffset=0, check={1,0}},
			{name="TurnToWaitFor", index={10}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="Speed", index={11}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			-- 19 animset?
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CBehaviorWalkCommand] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CBehaviorWalkCommand,
		inheritsFrom = {"EGL_CGLEBehavior"},
		fields = {
			{name="TargetPosition", index={4}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="Position"},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CWorkerBehavior] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CWorkerBehavior,
		inheritsFrom = {"EGL_CGLEBehavior"},
		fields = {
			{name="WorkTimeRemaining", index={4}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="TargetWorkTime", index={5}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="Motivation", index={6}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="BehaviorProps2", index={7}, datatype=MemoryManipulation.DataType.ObjectPointer},
			{name="CycleIndex", index={8}, datatype=MemoryManipulation.DataType.Int, check={0,1,2}},
			{name="TimesWorked", index={9}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="TimesNoWork", index={10}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="TimesNoFood", index={11}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="TimesNoRest", index={12}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="TimesNoPay", index={13}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="JoblessSinceTurn", index={14}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="CouldConsumeResource", index={15}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="IsLeaving", index={16}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="TransportAmount", index={17}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CBattleBehavior] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CBattleBehavior,
		inheritsFrom = {"EGL_CGLEBehavior"},
		fields = {
			{name="SuccessDistance", index={4}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="FailureDistance", index={5}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="TimeOutTime", index={6}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="StartTurn", index={7}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="TargetPosition", index={8}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="Position"},
			{name="StartFollowing", index={10}, datatype=MemoryManipulation.DataType.Bit, bitOffset=0, check={1,0}},
			{name="StopFollowing", index={10}, datatype=MemoryManipulation.DataType.Bit, bitOffset=1, check={1,0}},
			{name="FollowStatus", index={11}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="LatestHitTurn", index={12}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="LatestAttackerID", index={14}, datatype=MemoryManipulation.DataType.Int, check=IsValid},
			{name="BattleStatus", index={15}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="NoMoveNecessary", index={16}, datatype=MemoryManipulation.DataType.Bit, bitOffset=0, check={1,0}},
			{name="NormalRangeCheckNecessary", index={16}, datatype=MemoryManipulation.DataType.Bit, bitOffset=1, check={1,0}},
			{name="Command", index={17}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="AttackMoveTarget", index={18}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="Position"},
			{name="MilliSecondsToWait", index={21}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="MSToPlayHitAnimation", index={22}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="HitPlayed", index={23}, datatype=MemoryManipulation.DataType.Int, check=nil},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CLeaderBehavior] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CLeaderBehavior,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CBattleBehavior},
		fields = {
			{name="TroopHealthCurrent", index={27}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="TroopHealthPerSoldier", index={28}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="TerritoryCenter", index={29}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="Position"},
			{name="TerritoryCenterRange", index={31}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="Experience", index={32}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="PatrolPoints", index={34}, datatype=MemoryManipulation.DataType.EmbeddedObjectList, vtableOverride="Position", objectSize=2},
			{name="DefendOrientation", index={38}, datatype=MemoryManipulation.DataType.Float, readConv=math.deg, writeConv=math.rad},
			{name="TrainingStartTurn", index={39}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="SecondsSinceHPRefresh", index={41}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="NudgeCount", index={42}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="FormationType", index={43}, datatype=MemoryManipulation.DataType.Int, check=nil},
			{name="StartBattlePosition", index={44}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="Position"},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CSoldierBehavior] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CSoldierBehavior,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CBattleBehavior},
		fields = {
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CSerfBattleBehavior] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CSerfBattleBehavior,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CBattleBehavior},
		fields = {
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CBattleSerfBehavior] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CBattleSerfBehavior,
		inheritsFrom = {MemoryManipulation.ClassVTable.GGL_CLeaderBehavior},
		fields = {
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CSerfBehavior] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CSerfBehavior,
		inheritsFrom = {"EGL_CGLEBehavior"},
		fields = {
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CLimitedAttachmentBehavior] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CLimitedAttachmentBehavior,
		inheritsFrom = {"EGL_CGLEBehavior"},
		fields = {
			{name="Attachment1", index={6,0}, datatype=MemoryManipulation.DataType.ObjectPointer, vtableOverride="LimitedAttachment"},
			--{name="test", index={0}, datatype=nil},
			-- TODO figure out, how more than 1 attachment type works
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CFormationBehavior] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CFormationBehavior,
		inheritsFrom = {"EGL_CGLEBehavior"},
		fields = {
			{name="AnimStartTurn", index={4}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="AnimDuration", index={5}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CCamperBehavior] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CCamperBehavior,
		inheritsFrom = {"EGL_CGLEBehavior"},
		fields = {-- TODO fields, inheritance not working again
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CGLBehaviorDying] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CGLBehaviorDying,
		inheritsFrom = {"EGL_CGLEBehavior"},
		fields = {
			{name="BehaviorProps2", index={4}, datatype=MemoryManipulation.DataType.ObjectPointer},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CHeroBehavior] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CHeroBehavior,
		inheritsFrom = {"EGL_CGLEBehavior"},
		fields = {
			{name="BehaviorProps2", index={4}, datatype=MemoryManipulation.DataType.ObjectPointer},
			{name="ResurrectionTimePassed", index={5}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="SpawnTurn", index={6}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="FriendNear", index={7}, datatype=MemoryManipulation.DataType.Bit, bitOffset=0, check={1,0}},
			{name="EnemyNear", index={7}, datatype=MemoryManipulation.DataType.Bit, bitOffset=1, check={1,0}},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CBombBehavior] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CBombBehavior,
		inheritsFrom = {"EGL_CGLEBehavior"},
		fields = {
			{name="TimeToExplode", index={4}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end, readConv=function(a) return a/10 end, writeConv=function(a) return a*10 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CKegBehavior] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CKegBehavior,
		inheritsFrom = {"EGL_CGLEBehavior"},
		fields = {
			{name="TimeToExplode", index={5}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end, readConv=function(a) return a/10 end, writeConv=function(a) return a*10 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CThiefBehavior] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CThiefBehavior,
		inheritsFrom = {"EGL_CGLEBehavior"},
		fields = {
			{name="Amount", index={4}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="ResourceType", index={5}, datatype=MemoryManipulation.DataType.Int, check=ResourceType},
			{name="StolenFromPlayer", index={6}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 and a<9 end},
			{name="TimeToSteal", index={7}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end, readConv=function(a) return a/10 end, writeConv=function(a) return a*10 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CAutoCannonBehavior] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CAutoCannonBehavior,
		inheritsFrom = {"EGL_CGLEBehavior"},
		fields = {
			{name="BehaviorProps2", index={4}, datatype=MemoryManipulation.DataType.ObjectPointer},
			{name="ShotsLeft", index={10}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=-1 end},
			-- there are a lot of 0s and stuff i can't make sense of, but shotsleft is probably the most important anyway
			-- 8 seems to be some sort of attack time counter
			-- 9 is 275 at least on pilgrims cannon
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CResourceRefinerBehavior] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CResourceRefinerBehavior,
		inheritsFrom = {"EGL_CGLEBehavior"},
		fields = {
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CAffectMotivationBehavior] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CAffectMotivationBehavior,
		inheritsFrom = {"EGL_CGLEBehavior"},
		fields = {
			{name="BehaviorProps2", index={4}, datatype=MemoryManipulation.DataType.ObjectPointer},
			-- 5 player?
			-- 6 building finished?
			-- 7 random value?
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CLimitedLifespanBehavior] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CLimitedLifespanBehavior,
		inheritsFrom = {"EGL_CGLEBehavior"},
		fields = {
			{name="BehaviorProps2", index={4}, datatype=MemoryManipulation.DataType.ObjectPointer},
			{name="RemainingLifespanSeconds", index={5}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CBarrackBehavior] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CBarrackBehavior,
		inheritsFrom = {"EGL_CGLEBehavior"},
		fields = {
			{name="AutoFillActive", index={4}, datatype=MemoryManipulation.DataType.Bit, bitOffset=0, check={0,1}},
		},
	},
	[MemoryManipulation.ClassVTable.EGL_GLEBehaviorMultiSubAnims] = {
		vtable = MemoryManipulation.ClassVTable.EGL_GLEBehaviorMultiSubAnims,
		inheritsFrom = {"EGL_CGLEBehavior"},
		fields = {
			{name="LastUpdateTurn", index={5}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="AnimSlot0", index={6}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="BehMultiSubAnimsSlot"},
			{name="AnimSlot1", index={11}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="BehMultiSubAnimsSlot"},
			{name="AnimSlot2", index={16}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="BehMultiSubAnimsSlot"},
			{name="AnimSlot3", index={21}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="BehMultiSubAnimsSlot"},
		},
	},
	-- display props
	markerDisplayProps=nil,
	[MemoryManipulation.ClassVTable.ED_CDisplayEntityProps] = {
		vtable = MemoryManipulation.ClassVTable.ED_CDisplayEntityProps,
		fields = {
			{name="DisplayClass", index={1}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="Model", index={2}, datatype=MemoryManipulation.DataType.Int, check=Models},
			{name="Model2", index={3}, datatype=MemoryManipulation.DataType.Int, check=Models},
			{name="Model3", index={4}, datatype=MemoryManipulation.DataType.Int, check=Models},
			{name="Model4", index={5}, datatype=MemoryManipulation.DataType.Int, check=Models},
			{name="DrawPlayerColor", index={6}, datatype=MemoryManipulation.DataType.Bit, bitOffset=0, check={1,0}},
			{name="CastShadow", index={6}, datatype=MemoryManipulation.DataType.Bit, bitOffset=1, check={1,0}},
			{name="RenderInFoW", index={6}, datatype=MemoryManipulation.DataType.Bit, bitOffset=2, check={1,0}},
			{name="HighQualityOnly", index={6}, datatype=MemoryManipulation.DataType.Bit, bitOffset=3, check={1,0}},
			{name="MapEditor_Rotateable", index={7}, datatype=MemoryManipulation.DataType.Bit, bitOffset=0, check={1,0}},
			{name="MapEditor_Placeable", index={7}, datatype=MemoryManipulation.DataType.Bit, bitOffset=1, check={1,0}},
			{name="AnimList", index={9}, datatype=MemoryManipulation.DataType.ListOfInt, checkAll=nil},
		},
	},
	-- player status
	markerPlayerStatus = nil,
	[MemoryManipulation.ClassVTable.GGL_CPlayerStatus] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CPlayerStatus,
		fields = {
			{name="t", index={0}, datatype=nil},
			{name="PlayerID", index={1}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="PlayerAttractionHandler", index={197}, datatype=MemoryManipulation.DataType.ObjectPointer},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CPlayerAttractionHandler] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CPlayerAttractionHandler,
		fields = {
			{name="t", index={0}, datatype=nil},
			{name="PaydayStarted", index={2}, datatype=MemoryManipulation.DataType.Bit, bitOffset=0, check={1,0}},
			{name="PaydayStartTick", index={3}, datatype=MemoryManipulation.DataType.Int},
			-- 8 list of all player entities?
			-- 12 list of all player hqs?
			-- 16 list of all player vcs?
			-- 20 list of all player buildings (workplaces)?
			-- 24 list of all residences?
			-- 28 list of all farms?
			-- 36 empty list?
			-- 40 another list of buildings?
			-- 48 list of all settlers with lifetime?
			-- 52 list of all leaders?
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CPlayerAttractionProps] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CPlayerAttractionProps,
		fields = {
			{name="AttractionFrequency", index={1}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="PaydayFrequency", index={2}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="EntityTypeBanTime", index={3}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="ReAttachWorkerFrequency", index={4}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="PlayerMoneyDispo", index={5}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="MaximumDistanceWorkerToFarm", index={6}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="MaximumDistanceWorkerToResidence", index={7}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
		},
	},
	-- CNetEvents
	markerCNetEvents=nil,
	[MemoryManipulation.ClassVTable.BB_CEvent] = {
		vtable = MemoryManipulation.ClassVTable.BB_CEvent,
		fields = {
			{name="EventTypeId", index={1}, datatype=MemoryManipulation.DataType.Int, check={}},
		},
	},
	[MemoryManipulation.ClassVTable.EGL_CNetEvent2Entities] = {
		vtable = MemoryManipulation.ClassVTable.EGL_CNetEvent2Entities,
		inheritsFrom = {MemoryManipulation.ClassVTable.BB_CEvent},
		fields = {
			{name="ActorId", index={2}, datatype=MemoryManipulation.DataType.Int, check=IsValid},
			{name="TargetId", index={3}, datatype=MemoryManipulation.DataType.Int, check=IsValid},
		},
	},
	[MemoryManipulation.ClassVTable.EGL_CNetEventEntityAndPos] = {
		vtable = MemoryManipulation.ClassVTable.EGL_CNetEventEntityAndPos,
		inheritsFrom = {MemoryManipulation.ClassVTable.BB_CEvent},
		fields = {
			{name="EntityId", index={2}, datatype=MemoryManipulation.DataType.Int, check=IsValid},
			{name="Position", index={3}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="Position"},
		},
	},
	[MemoryManipulation.ClassVTable.EGL_CNetEventEntityAndPosArray] = {
		vtable = MemoryManipulation.ClassVTable.EGL_CNetEventEntityAndPosArray,
		inheritsFrom = {MemoryManipulation.ClassVTable.BB_CEvent},
		fields = {
			{name="EntityId", index={2}, datatype=MemoryManipulation.DataType.Int, check=IsValid},
			{name="PositionList", index={4}, datatype=MemoryManipulation.DataType.EmbeddedObjectList, vtableOverride="Position", objectSize=2, check={}},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CNetEventExtractResource] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CNetEventExtractResource,
		inheritsFrom = {MemoryManipulation.ClassVTable.BB_CEvent},
		fields = {
			{name="EntityId", index={2}, datatype=MemoryManipulation.DataType.Int, check=IsValid},
			{name="ResourceType", index={3}, datatype=MemoryManipulation.DataType.Int, check=ResourceType},
			{name="TargetPosition", index={4}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="Position"},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CNetEventTransaction] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CNetEventTransaction,
		inheritsFrom = {MemoryManipulation.ClassVTable.BB_CEvent},
		fields = {
			{name="EntityId", index={2}, datatype=MemoryManipulation.DataType.Int, check=IsValid},
			{name="SellType", index={3}, datatype=MemoryManipulation.DataType.Int, check=ResourceType},
			{name="BuyType", index={4}, datatype=MemoryManipulation.DataType.Int, check=ResourceType},
			{name="BuyAmount", index={5}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
		},
	},
	[MemoryManipulation.ClassVTable.EGL_CNetEventEntityID] = {
		vtable = MemoryManipulation.ClassVTable.EGL_CNetEventEntityID,
		inheritsFrom = {MemoryManipulation.ClassVTable.BB_CEvent},
		fields = {
			{name="EntityId", index={2}, datatype=MemoryManipulation.DataType.Int, check=IsValid},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CNetEventCannonCreator] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CNetEventCannonCreator,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CNetEventEntityID},
		fields = {
			{name="BottomType", index={3}, datatype=MemoryManipulation.DataType.Int, check=Entities},
			{name="TopType", index={4}, datatype=MemoryManipulation.DataType.Int, check=Entities},
			{name="Position", index={5}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="Position"},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CNetEventEntityIDAndUpgradeCategory] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CNetEventEntityIDAndUpgradeCategory,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CNetEventEntityID},
		fields = {
			{name="UprgadeCategory", index={3}, datatype=MemoryManipulation.DataType.Int, check=UpgradeCategories},
		},
	},
	[MemoryManipulation.ClassVTable.EGL_CNetEventEntityIDAndInteger] = {
		vtable = MemoryManipulation.ClassVTable.EGL_CNetEventEntityIDAndInteger,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CNetEventEntityID},
		fields = {
			{name="Int", index={3}, datatype=MemoryManipulation.DataType.Int},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CNetEventTechnologyAndEntityID] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CNetEventTechnologyAndEntityID,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CNetEventEntityID},
		fields = {
			{name="Technology", index={3}, datatype=MemoryManipulation.DataType.Int, check=Technologies},
		},
	},
	[MemoryManipulation.ClassVTable.EGL_CNetEventPlayerID] = {
		vtable = MemoryManipulation.ClassVTable.EGL_CNetEventPlayerID,
		inheritsFrom = {MemoryManipulation.ClassVTable.BB_CEvent},
		fields = {
			{name="PlayerId", index={2}, datatype=MemoryManipulation.DataType.Int, check={1,2,3,4,5,6,8}},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CNetEventBuildingCreator] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CNetEventBuildingCreator,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CNetEventPlayerID},
		fields = {
			{name="UprgadeCategory", index={3}, datatype=MemoryManipulation.DataType.Int, check=UpgradeCategories},
			{name="Position", index={4}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="PositionWithRotation"},
			{name="ListOfSerfs", index={8}, datatype=MemoryManipulation.DataType.ListOfInt, check={}},
		},
	},
	[MemoryManipulation.ClassVTable.EGL_CNetEventIntegerAndPlayerID] = {
		vtable = MemoryManipulation.ClassVTable.EGL_CNetEventIntegerAndPlayerID,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CNetEventPlayerID},
		fields = {
			{name="Int", index={3}, datatype=MemoryManipulation.DataType.Int},
		},
	},
	[MemoryManipulation.ClassVTable.EGL_CNetEventPlayerIDAndInteger] = {
		vtable = MemoryManipulation.ClassVTable.EGL_CNetEventPlayerIDAndInteger,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CNetEventPlayerID},
		fields = {
			{name="Int", index={3}, datatype=MemoryManipulation.DataType.Int},
		},
	},
	[MemoryManipulation.ClassVTable.EGL_CNetEventEntityIDAndPlayerID] = {
		vtable = MemoryManipulation.ClassVTable.EGL_CNetEventEntityIDAndPlayerID,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CNetEventPlayerID},
		fields = {
			{name="EntityId", index={3}, datatype=MemoryManipulation.DataType.Int, check=IsValid},
		},
	},
	[MemoryManipulation.ClassVTable.EGL_CNetEventEntityIDAndPlayerIDAndEntityType] = {
		vtable = MemoryManipulation.ClassVTable.EGL_CNetEventEntityIDAndPlayerIDAndEntityType,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CNetEventEntityIDAndPlayerID},
		fields = {
			--{name="EntityType", index={4}, datatype=MemoryManipulation.DataType.Int, check=IsValid},?
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CNetEventEntityIDPlayerIDAndInteger] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CNetEventEntityIDPlayerIDAndInteger,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CNetEventEntityIDAndPlayerID},
		fields = {
			--{name="Int", index={4}, datatype=MemoryManipulation.DataType.Int},?
		},
	},
	-- effects
	markerEffects=nil,
	[MemoryManipulation.ClassVTable.EGL_CEffect] = {
		vtable = MemoryManipulation.ClassVTable.EGL_CEffect,
		fields = {
			--{name="", index={1}, datatype=MemoryManipulation.DataType.Int}, vtable? 784B0C EGL::IEffectDisplay
			--{name="", index={2}, datatype=MemoryManipulation.DataType.Int}, vtable? 784AE4 EGL::TGLEAttachable<class EGL::CEffect,class EGL::CEffectAttachmentProxy>
			--{name="", index={3}, datatype=MemoryManipulation.DataType.Int}, 599981640
			--{name="", index={4}, datatype=MemoryManipulation.DataType.Int}, 893374368
			--{name="", index={5}, datatype=MemoryManipulation.DataType.Int}, 0
			--{name="", index={6}, datatype=MemoryManipulation.DataType.Int}, 0
			--{name="", index={7}, datatype=MemoryManipulation.DataType.Int}, 893375408
			--{name="", index={8}, datatype=MemoryManipulation.DataType.Int}, 0
			--{name="", index={9}, datatype=MemoryManipulation.DataType.Int}, 0
			--{name="", index={10}, datatype=MemoryManipulation.DataType.Int}, 893374208
			--{name="", index={11}, datatype=MemoryManipulation.DataType.Int}, 0
			--{name="", index={12}, datatype=MemoryManipulation.DataType.Int}, 0
			--{name="", index={13}, datatype=MemoryManipulation.DataType.Int}, 893374648
			--{name="", index={14}, datatype=MemoryManipulation.DataType.Int}, 0
			--{name="", index={15}, datatype=MemoryManipulation.DataType.Int}, 0
			{name="Position", index={16}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="Position"},
			{name="SpawnedTurn", index={18}, datatype=MemoryManipulation.DataType.Int, check={}},
			--{name="", index={19}, datatype=MemoryManipulation.DataType.Int}, -1
			{name="EffectType", index={20}, datatype=MemoryManipulation.DataType.Int, check={}},
			--{name="", index={21}, datatype=MemoryManipulation.DataType.Int}, 1 player?
			--{name="", index={22}, datatype=MemoryManipulation.DataType.Int}, 1 player?
			{name="EffectID", index={23}, datatype=MemoryManipulation.DataType.Int, check={}},
			--{name="", index={30}, datatype=MemoryManipulation.DataType.Int}, vtable? 76AF54 GD::CBuildingBehavior
		},
	},
	[MemoryManipulation.ClassVTable.EGL_CFlyingEffect] = {
		vtable = MemoryManipulation.ClassVTable.EGL_CFlyingEffect,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CEffect},
		fields = {
			{name="SpawnedTurnAgain", index={30}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="GravityFactor", index={31}, datatype=MemoryManipulation.DataType.Float, check={}},
			{name="StartPosition", index={34}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="Position"},
			{name="TargetPosition", index={36}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="Position"},
			{name="CurrentPosition", index={38}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="Position"},
			{name="NextPosition", index={40}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="Position"},
			{name="StrangeFloat", index={43}, datatype=MemoryManipulation.DataType.Float, check=nil},
			{name="AttackerID", index={47}, datatype=MemoryManipulation.DataType.Int, check={}},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CArrowEffect] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CArrowEffect,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CFlyingEffect},
		fields = {
			{name="TargetID", index={48}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="DamageAmount", index={49}, datatype=MemoryManipulation.DataType.Int, check={}},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CCannonBallEffect] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CCannonBallEffect,
		inheritsFrom = {MemoryManipulation.ClassVTable.EGL_CFlyingEffect},
		fields = {
			{name="DamageAmount", index={50}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="AoERange", index={51}, datatype=MemoryManipulation.DataType.Float, check={}},
			{name="SourcePlayer", index={53}, datatype=MemoryManipulation.DataType.Int, check=nil}, --??
		},
	},
	-- misc stuff (embedded objects, helper tables...)
	markerMiscStuff=nil,
	["Technology"] = {
		hasNoVTable = true,
		fields = {
			{name="t", index={0}}, -- 0 techcategory
			{name="TimeToResearch", index={1}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="ResourceCosts", index={3}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="costInfo"},
			{name="RequiredTecConditions", index={21}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="TecConditions", index={23}, datatype=MemoryManipulation.DataType.EmbeddedObjectList, objectSize=2, vtableOverride="TechnologyReqTechnology"},
			{name="RequiredEntityConditions", index={26}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="EntityConditions", index={28}, datatype=MemoryManipulation.DataType.EmbeddedObjectList, objectSize=2, vtableOverride="TechnologyReqBuilding"},
		},
	},
	["TechnologyReqBuilding"] = {
		hasNoVTable = true,
		fields = {
			{name="EntityType", index={0}, datatype=MemoryManipulation.DataType.Int, check=Entities},
			{name="Amount", index={1}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
		},
	},
	["TechnologyReqTechnology"] = {
		hasNoVTable = true,
		fields = {
			{name="TecType", index={0}, datatype=MemoryManipulation.DataType.Int, check=Entities},
			{name="TecCategoryType", index={1}, datatype=MemoryManipulation.DataType.Int, check=nil},
		},
	},
	["DamageClassList"] = {
		hasNoVTable = true,
		fields = {
			{name="DamageClasses", index={1}, datatype=MemoryManipulation.DataType.EmbeddedFixedLengthObjectPointers, fixedLength=7},
			-- there is a damageclass 0, nowhere defined, possibly to avoid errors when entitytype damageclass not set
			-- i avoid giving access to it because i'm not sure about that and it simplifies code by correcting lua/c indexing ;)
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CDamageClassProps] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CDamageClassProps,
		fields = {
			{name="BonusVsArmorClass", index={1}, datatype=MemoryManipulation.DataType.EmbeddedFixedLengthFloats, fixedLength=7},
			-- there is no armorclass 0, but this spot is filled by the vtable (which convieniently fixes lua/c indexing)
		},
	},
	[MemoryManipulation.ClassVTable.EGL_CGLEModelSet] = {
		vtable = MemoryManipulation.ClassVTable.EGL_CGLEModelSet,
		fields = {
			{name="ModelList", index={2}, datatype=MemoryManipulation.DataType.ListOfInt, checkAll=Models},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CLogicProperties] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CLogicProperties,
		fields = {
			{name="t", index={0}, datatype=nil},
			{name="CompensationOnBuildingSale", index={1}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="BuildingUpgrades", index={3}, datatype=MemoryManipulation.DataType.EmbeddedObjectList, objectSize=4},
			{name="SettlerUpgrades", index={7}, datatype=MemoryManipulation.DataType.EmbeddedObjectList, objectSize=3},
			{name="TaxationLevels", index={11}, datatype=MemoryManipulation.DataType.EmbeddedObjectList, objectSize=3},
			{name="TradeResources", index={15}, datatype=MemoryManipulation.DataType.EmbeddedObjectList, objectSize=8},
			{name="BlessCategories", index={19}, datatype=MemoryManipulation.DataType.EmbeddedObjectList, objectSize=7},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CLogicProperties_SBuildingUpgradeCategory] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CLogicProperties_SBuildingUpgradeCategory,
		fields = {
			{name="Category", index={1}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="FirstBuilding", index={2}, datatype=MemoryManipulation.DataType.Int, check={}},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CLogicProperties_SSettlerUpgradeCategory] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CLogicProperties_SSettlerUpgradeCategory,
		fields = {
			{name="Category", index={1}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="FirstSettler", index={2}, datatype=MemoryManipulation.DataType.Int, check={}},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CLogicProperties_STaxationLevel] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CLogicProperties_STaxationLevel,
		fields = {
			{name="RegularTax", index={1}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="MotivationChange", index={2}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CLogicProperties_STradeResource] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CLogicProperties_STradeResource,
		fields = {
			{name="ResourceType", index={1}, datatype=MemoryManipulation.DataType.Int, check=ResourceType},
			{name="BasePrice", index={2}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="MinPrice", index={3}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="MaxPrice", index={4}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="Inflation", index={5}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="Deflation", index={6}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="WorkAmount", index={7}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
		},
	},
	[MemoryManipulation.ClassVTable.GGL_CLogicProperties_SBlessCategory] = {
		vtable = MemoryManipulation.ClassVTable.GGL_CLogicProperties_SBlessCategory,
		fields = {
			{name="Name", index={1}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="RequiredFaith", index={2}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="EntityTypes", index={4}, datatype=MemoryManipulation.DataType.ListOfInt, checkAll=Entities},
		},
	},
	costInfo = {
		hasNoVTable = true,
		fields = {
			{name="Gold", index={1}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="GoldRaw", index={2}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="Silver", index={3}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="SilverRaw", index={4}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="Stone", index={5}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="StoneRaw", index={6}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="Iron", index={7}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="IronRaw", index={8}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="Sulfur", index={9}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="SulfurRaw", index={10}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="Clay", index={11}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="ClayRaw", index={12}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="Wood", index={13}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="WoodRaw", index={14}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="WeatherEnergy", index={15}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="Knowledge", index={16}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="Faith", index={17}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
		}
	},
	upgradeInfo = {
		hasNoVTable = true,
		fields = {
			{name="Time", index={0}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="Cost", index={1}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="costInfo"},
			{name="Type", index={19}, datatype=MemoryManipulation.DataType.Int, check=Entities},
			{name="Category", index={20}, datatype=MemoryManipulation.DataType.Int, check=UpgradeCategories},
		}
	},
	constructionInfo = {
		hasNoVTable = true,
		fields = {
			{name="BuilderSlot", index={2}, datatype=MemoryManipulation.DataType.EmbeddedObjectList, vtableOverride="PositionWithRotation", objectSize=3},
			{name="Time", index={5}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="Cost", index={6}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="costInfo"},
			{name="ConstructionSite", index={24}, datatype=MemoryManipulation.DataType.Int, check=Entities},
		}
	},
	AARectangle = {
		hasNoVTable = true,
		fields = {
			{name=1, index={0}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="Position"},
			{name=2, index={2}, datatype=MemoryManipulation.DataType.EmbeddedObject, vtableOverride="Position"},
		}
	},
	modifyEntityProps = {
		hasNoVTable = true,
		fields = {
			{name="MysteriousInt", index={0}, datatype=MemoryManipulation.DataType.Int, check={}},
			{name="TechList", index={2}, datatype=MemoryManipulation.DataType.ListOfInt, checkAll=Technologies},
		},
	},
	Position = {
		hasNoVTable = true,
		fields = {
			{name="X", index={0}, datatype=MemoryManipulation.DataType.Float},
			{name="Y", index={1}, datatype=MemoryManipulation.DataType.Float},
		}
	},
	PositionWithRotation = {
		hasNoVTable = true,
		inheritsFrom = {"Position"},
		fields = {
			{name="r", index={2}, datatype=MemoryManipulation.DataType.Float, readConv=math.deg, writeConv=math.rad},
		}
	},
	ExtractionInfo = {
		hasNoVTable = true,
		fields = {
			{name="ResourceEntityType", index={0}, datatype=MemoryManipulation.DataType.Int, check=Entities},
			{name="Delay", index={1}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
			{name="Amount", index={2}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
		}
	},
	LimitedAttachmentProps = {
		hasNoVTable = true,
		fields = {
			{name="Type", index={1}, datatype=MemoryManipulation.DataType.String},
			--{name="AttachmentType", index={6}, datatype=MemoryManipulation.DataType.Int, check=nil},
			{name="Limit", index={7}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
		}
	},
	LimitedAttachment = {
		hasNoVTable = true,
		fields = {
			{name="AttachmentType", index={3}, datatype=MemoryManipulation.DataType.Int},
			{name="Limit", index={4}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="IsActive", index={5}, datatype=MemoryManipulation.DataType.Int, check=nil},
			{name="AttachmentInfo", index={6}, datatype=MemoryManipulation.DataType.Int, check=nil},
		}
	},
	IdleAnimProps = {
		hasNoVTable = true,
		fields = {
			{name="AnimID", index={0}, datatype=MemoryManipulation.DataType.Int, check=nil},
			{name="Frequency", index={1}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
		}
	},
	BehMultiSubAnimsSlot = {
		hasNoVTable = true,
		fields = {
			{name="Active", index={0}, datatype=MemoryManipulation.DataType.Bit, bitOffset=0, check={1,0}},
			{name="PlayBackwards", index={0}, datatype=MemoryManipulation.DataType.Bit, bitOffset=1, check={1,0}},
			{name="IsLooped", index={0}, datatype=MemoryManipulation.DataType.Bit, bitOffset=2, check={1,0}},
			{name="AnimID", index={1}, datatype=MemoryManipulation.DataType.Int, check=nil},
			{name="StartTurn", index={2}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="Duration", index={3}, datatype=MemoryManipulation.DataType.Int, check=function(a) return a>=0 end},
			{name="Speed", index={5}, datatype=MemoryManipulation.DataType.Float, check=function(a) return a>=0 end},
		}
	},
}

do
	local function applyInheritance(of, name)
		if of.inheritsFrom and not of.inheritanceDone then
			for _,c in ipairs(of.inheritsFrom) do
				applyInheritance(MemoryManipulation.ObjFieldInfo[c], c)
				for _,f in ipairs(MemoryManipulation.ObjFieldInfo[c].fields) do
					table.insert(of.fields, f)
				end
				MemoryManipulation.ObjFieldInfo[c].SubClassList = MemoryManipulation.ObjFieldInfo[c].SubClassList or {}
				table.insert(MemoryManipulation.ObjFieldInfo[c].SubClassList, name)
			end
		end
		of.inheritanceDone=true
	end
	for n,o in pairs(MemoryManipulation.ObjFieldInfo) do
		applyInheritance(o, n)
	end
end

table.insert(framework2.map.endCallback, MemoryManipulation.OnLeaveMap)
table.insert(s5HookLoader.cb, 1, MemoryManipulation.OnLoadMap)

function MemoryManipulation.CostTableToWritable(c, ignoreZeroes)
	local w = {}
	for rty, name in pairs{
		[ResourceType.Gold] = "Gold",
		[ResourceType.Stone] = "Stone",
		[ResourceType.Iron] = "Iron",
		[ResourceType.Sulfur] = "Sulfur",
		[ResourceType.Clay] = "Clay",
		[ResourceType.Wood] = "Wood",
	} do
		if not (ignoreZeroes and c[rty]<=0) then
			w[name] = c[rty]
		end
	end
	return w
end

function MemoryManipulation.CostTableFromRead(r)
	local c = {}
	for _,rty in pairs(ResourceType) do
		c[rty] = 0
	end
	for rty, name in pairs{
		[ResourceType.Gold] = "Gold",
		[ResourceType.Stone] = "Stone",
		[ResourceType.Iron] = "Iron",
		[ResourceType.Sulfur] = "Sulfur",
		[ResourceType.Clay] = "Clay",
		[ResourceType.Wood] = "Wood",
	} do
		c[rty] = r[name]
	end
	return c
end

function MemoryManipulation.IsSoldier(id)
	return MemoryManipulation.HasEntityBehavior(id, MemoryManipulation.ClassVTable.GGL_CSoldierBehavior)
end

function MemoryManipulation.GetSettlerTypeCost(ty)
	local c = MemoryManipulation.GetSingleValue(MemoryManipulation.GetETypePointer(ty), "LogicProps.Cost")
	return MemoryManipulation.CostTableFromRead(c)
end

function MemoryManipulation.SetSettlerTypeCost(ty, c, ignoreZeroes)
	c = MemoryManipulation.CostTableToWritable(c, ignoreZeroes)
	MemoryManipulation.SetSingleValue(MemoryManipulation.GetETypePointer(ty), "LogicProps.Cost", c)
end

function MemoryManipulation.GetBuildingTypeCost(ty)
	local c = MemoryManipulation.GetSingleValue(MemoryManipulation.GetETypePointer(ty), "LogicProps.ConstructionInfo.Cost")
	return MemoryManipulation.CostTableFromRead(c)
end

function MemoryManipulation.SetBuildingTypeCost(ty, c, ignoreZeroes)
	c = MemoryManipulation.CostTableToWritable(c, ignoreZeroes)
	MemoryManipulation.SetSingleValue(MemoryManipulation.GetETypePointer(ty), "LogicProps.ConstructionInfo.Cost", c)
end

function MemoryManipulation.GetBuildingTypeUpgradeCost(ty)
	local c = MemoryManipulation.GetSingleValue(MemoryManipulation.GetETypePointer(ty), "LogicProps.Upgrade.Cost")
	return MemoryManipulation.CostTableFromRead(c)
end

function MemoryManipulation.SetBuildingTypeUpgradeCost(ty, c, ignoreZeroes)
	c = MemoryManipulation.CostTableToWritable(c, ignoreZeroes)
	MemoryManipulation.SetSingleValue(MemoryManipulation.GetETypePointer(ty), "LogicProps.Upgrade.Cost", c)
end

function MemoryManipulation.GetEntityMaxRange(id)
	assert(IsValid(id))
	local r = MemoryManipulation.GetSingleValue(id, "MaxAttackRange")
	if r > 0 then
		return r
	end
	return MemoryManipulation.GetEntityTypeMaxRange(Logic.GetEntityType(id))
end

function MemoryManipulation.SetEntityTimeToCamouflage(id, sec)
	if type(id)=="string" then
		id = GetID(id)
	end
	local w = MemoryManipulation.ConvertToObjInfo("BehaviorList.GGL_CThiefCamouflageBehavior.TimeToInvisibility", sec)
	MemoryManipulation.ConvertToObjInfo("BehaviorList.GGL_CThiefCamouflageBehavior.InvisibilityRemaining", (sec==0) and 15 or 0, w)
	assert(MemoryManipulation.WriteObj(S5Hook.GetEntityMem(id), w))
end

function MemoryManipulation.SetThiefStolenResourceInfo(id, rty, am)
	if type(id)=="string" then
		id = GetID(id)
	end
	if rty==0 then
		am = 0
	end
	local w = MemoryManipulation.ConvertToObjInfo("BehaviorList.GGL_CThiefBehavior.Amount", am)
	MemoryManipulation.ConvertToObjInfo("BehaviorList.GGL_CThiefBehavior.ResourceType", rty, w)
	assert(MemoryManipulation.WriteObj(S5Hook.GetEntityMem(id), w))
	if rty==0 then
		Logic.SetModelAndAnimSet(id, Models.PU_Thief)
	else
		Logic.SetModelAndAnimSet(id, Models.PU_ThiefCarry)
	end
end

function MemoryManipulation.ReanimateHero(id)
	if type(id)=="string" then
		id = GetID(id)
	end
	assert(Logic.IsHero(id)==1 and IsDead(id))
	local w = MemoryManipulation.ConvertToObjInfo("BehaviorList.GGL_CHeroBehavior.ResurrectionTimePassed", 10000)
	MemoryManipulation.ConvertToObjInfo("BehaviorList.GGL_CHeroBehavior.FriendNear", 1, w)
	MemoryManipulation.ConvertToObjInfo("BehaviorList.GGL_CHeroBehavior.EnemyNearif", 0, w)
	assert(MemoryManipulation.WriteObj(S5Hook.GetEntityMem(id), w))
end

function MemoryManipulation.GetDamageModifier(damageclass, armorclass)
	local t = MemoryManipulation.ReadObj(MemoryManipulation.GetDamageModifierPointer(), nil, MemoryManipulation.ObjFieldInfo.DamageClassList)
	return t.DamageClasses[damageclass].BonusVsArmorClass[armorclass]
end

function MemoryManipulation.SetDamageModifier(damageclass, armorclass, factor)
	local t = MemoryManipulation.ReadObj(MemoryManipulation.GetDamageModifierPointer(), nil, MemoryManipulation.ObjFieldInfo.DamageClassList)
	t.DamageClasses[damageclass].BonusVsArmorClass[armorclass] = factor
	return MemoryManipulation.WriteObj(MemoryManipulation.GetDamageModifierPointer(), t, MemoryManipulation.ObjFieldInfo.DamageClassList)
end

function MemoryManipulation.SetHeroTypeAbilityRechargeTimeNeeded(typ, abilit, sec)
	local t = {
		[Abilities.AbilityBuildCannon] = "GGL_CCannonBuilderBehaviorProps",
		[Abilities.AbilityCamouflage] = "GGL_CCamouflageBehaviorProps",
		[Abilities.AbilityCircularAttack] = "GGL_CCircularAttackProps",
		[Abilities.AbilityConvertSettlers] = "GGL_CConvertSettlerAbilityProps",
		[Abilities.AbilityInflictFear] = "GGL_CInflictFearAbilityProps",
		[Abilities.AbilityMotivateWorkers] = "GGL_CMotivateWorkersAbilityProps",
		[Abilities.AbilityPlaceBomb] = "GGL_CHeroAbilityProps",
		--[Abilities.AbilityPlaceKeg] = "",
		[Abilities.AbilityRangedEffect] = "GGL_CRangedEffectAbilityProps",
		--[Abilities.AbilityScoutBinoculars] = "",
		--[Abilities.AbilityScoutFindResources] = "",
		--[Abilities.AbilityScoutTorches] = "",
		[Abilities.AbilitySendHawk] = "GGL_CHeroHawkBehaviorProps",
		[Abilities.AbilityShuriken] = "GGL_CShurikenAbilityProps",
		[Abilities.AbilitySniper] = "GGL_CSniperAbilityProps",
		[Abilities.AbilitySummon] = "GGL_CSummonBehaviorProps",
	}
	local adr = "."..t[abilit]..".RechargeTimeSeconds"
	MemoryManipulation.SetSingleValue(MemoryManipulation.GetETypePointer(typ), adr, sec)
end

function MemoryManipulation.GetPlayerPaydayStarted(pl)
	return MemoryManipulation.GetSingleValue(MemoryManipulation.GetPlayerStatusPointer(pl), "PlayerAttractionHandler.PaydayStarted")
end

function MemoryManipulation.SetPlayerPaydayProgress(pl, sec)
	local w = MemoryManipulation.ConvertToObjInfo("PlayerAttractionHandler.PaydayStartTick", Logic.GetCurrentTurn()-sec*10)
	MemoryManipulation.ConvertToObjInfo("PlayerAttractionHandler.PaydayStarted", (sec<0) and 0 or 1, w)
	assert(MemoryManipulation.WriteObj(MemoryManipulation.GetPlayerStatusPointer(pl), w))
end

function MemoryManipulation.SetPaydayFrequency(sec)
	MemoryManipulation.SetSingleValue(MemoryManipulation.GetPlayerAttractionPropsPointer(), "PaydayFrequency", sec)
end

function MemoryManipulation.SetLeaderMaxSoldiers(id, maxsol)
	assert(MemoryManipulation.GetSingleValue(id, "BehaviorList.GGL_CLimitedAttachmentBehavior.BehaviorProps.Attachments")[1].Type=="ATTACHMENT_LEADER_SOLDIER")
	MemoryManipulation.SetSingleValue(id, "BehaviorList.GGL_CLimitedAttachmentBehavior.Attachment1.Limit", maxsol)
end

function MemoryManipulation.SetBuidingMaxEaters(id, eaters)
	assert(MemoryManipulation.GetSingleValue(id, "BehaviorList.GGL_CLimitedAttachmentBehavior.BehaviorProps.Attachments")[1].Type=="ATTACHMENT_WORKER_FARM")
	MemoryManipulation.SetSingleValue(id, "BehaviorList.GGL_CLimitedAttachmentBehavior.Attachment1.Limit", eaters)
end

function MemoryManipulation.SetBuildingMaxSleepers(id, sleepers)
	assert(MemoryManipulation.GetSingleValue(id, "BehaviorList.GGL_CLimitedAttachmentBehavior.BehaviorProps.Attachments")[1].Type=="ATTACHMENT_WORKER_RESIDENCE")
	MemoryManipulation.SetSingleValue(id, "BehaviorList.GGL_CLimitedAttachmentBehavior.Attachment1.Limit", sleepers)
end

function MemoryManipulation.GetEntityModel(id)
	local mod = MemoryManipulation.GetSingleValue(id, "ModelOverride")
	if mod > 0 then
		return mod
	end
	return MemoryManipulation.GetEntityTypeModel(Logic.GetEntityType(id))
end

function MemoryManipulation.GetClassAndAllSubClassesAsTable(class, r)
	r = r or {}
	if type(class)=="table" then
		for _,c in ipairs(class) do
			MemoryManipulation.GetClassAndAllSubClassesAsTable(c, r)
		end
		return r
	end
	table.insert(r, class)
	local function f(c)
		if MemoryManipulation.ObjFieldInfo[c].SubClassList then
			for _, subc in ipairs(MemoryManipulation.ObjFieldInfo[c].SubClassList) do
				table.insert(r, KeyOf(subc, MemoryManipulation.ClassVTable))
				f(subc)
			end
		end
	end
	f(MemoryManipulation.ClassVTable[class])
	return r
end

function MemoryManipulation.GetClassAndSubClassesAsStringFromTable(pre, t, post)
	local r = nil
	for _,c in ipairs(t) do
		if r==nil then
			r = "{"
		else
			r = r..", "
		end
		r = r..pre..c..post
	end
	return r.."}"
end

function MemoryManipulation.GetClassAndAllSubClassesAsString(pre, class, post)
	return MemoryManipulation.GetClassAndSubClassesAsStringFromTable(pre, MemoryManipulation.GetClassAndAllSubClassesAsTable(class), post)
end

-- lib funcs
MemoryManipulation.LibFuncBase = {Entity=1, EntityType=2}

MemoryManipulation.GetLeaderExperience = {LibFuncBase=MemoryManipulation.LibFuncBase.Entity, path='"BehaviorList.GGL_CLeaderBehavior.Experience"', check="\tassert(Logic.IsLeader(id)==1)\n"}
MemoryManipulation.SetLeaderExperience = MemoryManipulation.GetLeaderExperience
MemoryManipulation.GetLeaderTroopHealth = {LibFuncBase=MemoryManipulation.LibFuncBase.Entity, path='"BehaviorList.GGL_CLeaderBehavior.TroopHealthCurrent"', check="\tassert(Logic.IsLeader(id)==1)\n"}
MemoryManipulation.SetLeaderTroopHealth = MemoryManipulation.GetLeaderTroopHealth
MemoryManipulation.GetSettlerMovementSpeed = {LibFuncBase=MemoryManipulation.LibFuncBase.Entity, path='{"BehaviorList.GGL_CLeaderMovement.MovementSpeed", "BehaviorList.GGL_CSettlerMovement.MovementSpeed", "BehaviorList.GGL_CSoldierMovement.MovementSpeed"}', check="\tassert(Logic.IsSettler(id)==1)\n"}
MemoryManipulation.SetSettlerMovementSpeed = MemoryManipulation.GetSettlerMovementSpeed
MemoryManipulation.GetSettlerRotationSpeed = {LibFuncBase=MemoryManipulation.LibFuncBase.Entity, path='{"BehaviorList.GGL_CLeaderMovement.TurningSpeed", "BehaviorList.GGL_CSettlerMovement.TurningSpeed", "BehaviorList.GGL_CSoldierMovement.TurningSpeed"}', check="\tassert(Logic.IsSettler(id)==1)\n"}
MemoryManipulation.SetSettlerRotationSpeed = MemoryManipulation.GetSettlerRotationSpeed
MemoryManipulation.GetLeaderOfSoldier = {LibFuncBase=MemoryManipulation.LibFuncBase.Entity, path='"LeaderId"', check="\tassert(MemoryManipulation.IsSoldier(id))\n"}
MemoryManipulation.GetMovementCheckBlockingFlag = {LibFuncBase=MemoryManipulation.LibFuncBase.Entity, path='"BehaviorList.GGL_CSettlerMovement.BlockingFlag"', check="\tassert(Logic.IsSettler(id)==1)\n"}
MemoryManipulation.SetMovementCheckBlockingFlag = MemoryManipulation.GetMovementCheckBlockingFlag
MemoryManipulation.GetBarracksAutoFillActive = {LibFuncBase=MemoryManipulation.LibFuncBase.Entity, path='"BehaviorList.GGL_CBarrackBehavior.AutoFillActive"', check="\tassert(Logic.IsBuilding(id)==1)\n"}
MemoryManipulation.GetSoldierTypeOfLeaderType = {LibFuncBase=MemoryManipulation.LibFuncBase.EntityType, path='"BehaviorProps.GGL_CLeaderBehaviorProps.SoldierType"'}
MemoryManipulation.SetSoldierTypeOfLeaderType = MemoryManipulation.GetSoldierTypeOfLeaderType
MemoryManipulation.GetEntityTypeMaxRange = {LibFuncBase=MemoryManipulation.LibFuncBase.EntityType, path=MemoryManipulation.GetClassAndAllSubClassesAsString('"BehaviorProps.', "GGL_CBattleBehaviorProps", '.MaxRange"')}
MemoryManipulation.SetEntityTypeMaxRange = MemoryManipulation.GetEntityTypeMaxRange
MemoryManipulation.GetEntityScale = {LibFuncBase=MemoryManipulation.LibFuncBase.Entity, path='"Scale"', check="\tassert(IsValid(id))\n"}
MemoryManipulation.SetEntityScale = MemoryManipulation.GetEntityScale
MemoryManipulation.GetBuildingHeight = {LibFuncBase=MemoryManipulation.LibFuncBase.Entity, path='"BuildingHeight"', check="\tassert(Logic.IsBuilding(id)==1)\n"}
MemoryManipulation.SetBuildingHeight = MemoryManipulation.GetBuildingHeight
MemoryManipulation.GetSettlerOverheadWidget = {LibFuncBase=MemoryManipulation.LibFuncBase.Entity, path='"OverheadWidget"', check="\tassert(Logic.IsSettler(id)==1)\n"}
MemoryManipulation.SetSettlerOverheadWidget = MemoryManipulation.GetSettlerOverheadWidget
MemoryManipulation.GetMovingEntityTargetPos = {LibFuncBase=MemoryManipulation.LibFuncBase.Entity, path='"TargetPosition"'}
MemoryManipulation.SetMovingEntityTargetPos = MemoryManipulation.GetMovingEntityTargetPos
MemoryManipulation.GetEntityCamouflageRemaining = {LibFuncBase=MemoryManipulation.LibFuncBase.Entity, path='"BehaviorList.GGL_CCamouflageBehavior.InvisibilityRemaining"', check="\tassert(Logic.IsLeader(id)==1)\n"}
MemoryManipulation.SetEntityCamouflageRemaining = MemoryManipulation.GetEntityCamouflageRemaining
MemoryManipulation.GetEntityTimeToCamouflage = {LibFuncBase=MemoryManipulation.LibFuncBase.Entity, path='"BehaviorList.GGL_CThiefCamouflageBehavior.TimeToInvisibility"', check="\tassert(Logic.IsLeader(id)==1)\n"}
MemoryManipulation.GetHeroResurrectionTime = {LibFuncBase=MemoryManipulation.LibFuncBase.Entity, path='"BehaviorList.GGL_CHeroBehavior.ResurrectionTimePassed"', check="\tassert(Logic.IsHero(id)==1)\n"}
MemoryManipulation.SetHeroResurrectionTime = MemoryManipulation.GetHeroResurrectionTime
MemoryManipulation.GetEntityLimitedLifespanRemainingSeconds = {LibFuncBase=MemoryManipulation.LibFuncBase.Entity, path='"BehaviorList.GGL_CLimitedLifespanBehavior.RemainingLifespanSeconds"'}
MemoryManipulation.SetEntityLimitedLifespanRemainingSeconds = MemoryManipulation.GetEntityLimitedLifespanRemainingSeconds
MemoryManipulation.GetEntityTypeLimitedLifespanSeconds = {LibFuncBase=MemoryManipulation.LibFuncBase.EntityType, path='"BehaviorProps.GGL_CLimitedLifespanBehaviorProps.LifespanSeconds"'}
MemoryManipulation.SetEntityTypeLimitedLifespanSeconds = MemoryManipulation.GetEntityTypeLimitedLifespanSeconds
MemoryManipulation.GetLeaderTypeUpkeepCost = {LibFuncBase=MemoryManipulation.LibFuncBase.EntityType, path='"BehaviorProps.GGL_CLeaderBehaviorProps.UpkeepCosts"'}
MemoryManipulation.SetLeaderTypeUpkeepCost = MemoryManipulation.GetLeaderTypeUpkeepCost
MemoryManipulation.GetEntityTypeMaxHealth = {LibFuncBase=MemoryManipulation.LibFuncBase.EntityType, path='"LogicProps.MaxHealth"'}
MemoryManipulation.SetEntityTypeMaxHealth = MemoryManipulation.GetEntityTypeMaxHealth
MemoryManipulation.GetBuildingTypeKegEffectFactor = {LibFuncBase=MemoryManipulation.LibFuncBase.EntityType, path='"KegEffectFactor"'}
MemoryManipulation.SetBuildingTypeKegEffectFactor = MemoryManipulation.GetBuildingTypeKegEffectFactor
MemoryManipulation.GetBuildingTypeAffectMotivation = {LibFuncBase=MemoryManipulation.LibFuncBase.EntityType, path='"BehaviorProps.GGL_CAffectMotivationBehaviorProps.MotivationEffect"'}
MemoryManipulation.SetBuildingTypeAffectMotivation = MemoryManipulation.GetBuildingTypeAffectMotivation
MemoryManipulation.GetEntityTypeSuspensionAnimation = {LibFuncBase=MemoryManipulation.LibFuncBase.EntityType, path='"BehaviorProps.GGL_CGLAnimationBehaviorExProps.SuspensionAnimation"'}
MemoryManipulation.SetEntityTypeSuspensionAnimation = MemoryManipulation.GetEntityTypeSuspensionAnimation
MemoryManipulation.GetLeaderTypeHealingPoints = {LibFuncBase=MemoryManipulation.LibFuncBase.EntityType, path=MemoryManipulation.GetClassAndAllSubClassesAsString('"BehaviorProps.', "GGL_CLeaderBehaviorProps", '.HealingPoints"')}
MemoryManipulation.SetLeaderTypeHealingPoints = MemoryManipulation.GetLeaderTypeHealingPoints
MemoryManipulation.GetLeaderTypeHealingSeconds = {LibFuncBase=MemoryManipulation.LibFuncBase.EntityType, path=MemoryManipulation.GetClassAndAllSubClassesAsString('"BehaviorProps.', "GGL_CLeaderBehaviorProps", '.HealingSeconds"')}
MemoryManipulation.SetLeaderTypeHealingSeconds = MemoryManipulation.GetLeaderTypeHealingSeconds
MemoryManipulation.GetSettlerTypeDamageClass = {LibFuncBase=MemoryManipulation.LibFuncBase.EntityType, path=MemoryManipulation.GetClassAndAllSubClassesAsString('"BehaviorProps.', {"GGL_CBattleBehaviorProps", "GGL_CAutoCannonBehaviorProps"}, '.DamageClass"')}
MemoryManipulation.SetSettlerTypeDamageClass = MemoryManipulation.GetSettlerTypeDamageClass
MemoryManipulation.GetSettlerTypeBattleWaitUntil = {LibFuncBase=MemoryManipulation.LibFuncBase.EntityType, path=MemoryManipulation.GetClassAndAllSubClassesAsString('"BehaviorProps.', "GGL_CBattleBehaviorProps", '.BattleWaitUntil"')}
MemoryManipulation.SetSettlerTypeBattleWaitUntil = MemoryManipulation.GetSettlerTypeBattleWaitUntil
MemoryManipulation.GetSettlerTypeMissChance = {LibFuncBase=MemoryManipulation.LibFuncBase.EntityType, path=MemoryManipulation.GetClassAndAllSubClassesAsString('"BehaviorProps.', "GGL_CBattleBehaviorProps", '.MissChance"')}
MemoryManipulation.SetSettlerTypeMissChance = MemoryManipulation.GetSettlerTypeMissChance
MemoryManipulation.GetSettlerTypeMaxRange = {LibFuncBase=MemoryManipulation.LibFuncBase.EntityType, path=MemoryManipulation.GetClassAndAllSubClassesAsString('"BehaviorProps.', "GGL_CBattleBehaviorProps", '.MaxRange"')}
MemoryManipulation.SetSettlerTypeMaxRange = MemoryManipulation.GetSettlerTypeMaxRange
MemoryManipulation.GetSettlerTypeMinRange = {LibFuncBase=MemoryManipulation.LibFuncBase.EntityType, path=MemoryManipulation.GetClassAndAllSubClassesAsString('"BehaviorProps.', "GGL_CBattleBehaviorProps", '.MinRange"')}
MemoryManipulation.SetSettlerTypeMinRange = MemoryManipulation.GetSettlerTypeMinRange
MemoryManipulation.GetLeaderTypeAutoAttackRange = {LibFuncBase=MemoryManipulation.LibFuncBase.EntityType, path=MemoryManipulation.GetClassAndAllSubClassesAsString('"BehaviorProps.', "GGL_CLeaderBehaviorProps", '.AutoAttackRange"')}
MemoryManipulation.SetLeaderTypeAutoAttackRange = MemoryManipulation.GetLeaderTypeAutoAttackRange
MemoryManipulation.GetBuildingTypeNumOfAttractableSettlers = {LibFuncBase=MemoryManipulation.LibFuncBase.EntityType, path='"LogicProps.NumberOfAttractableSettlers"'}
MemoryManipulation.SetBuildingTypeNumOfAttractableSettlers = MemoryManipulation.GetBuildingTypeNumOfAttractableSettlers
MemoryManipulation.GetThiefTypeTimeToSteal = {LibFuncBase=MemoryManipulation.LibFuncBase.EntityType, path='"BehaviorProps.GGL_CThiefBehaviorProperties.SecondsNeededToSteal"'}
MemoryManipulation.SetThiefTypeTimeToSteal = MemoryManipulation.GetThiefTypeTimeToSteal
MemoryManipulation.GetThiefTypeStealMax = {LibFuncBase=MemoryManipulation.LibFuncBase.EntityType, path='"BehaviorProps.GGL_CThiefBehaviorProperties.MaximumAmountToSteal"'}
MemoryManipulation.SetThiefTypeStealMax = MemoryManipulation.GetThiefTypeStealMax
MemoryManipulation.GetThiefTypeStealMin = {LibFuncBase=MemoryManipulation.LibFuncBase.EntityType, path='"BehaviorProps.GGL_CThiefBehaviorProperties.MinimumAmountToSteal"'}
MemoryManipulation.SetThiefTypeStealMin = MemoryManipulation.GetThiefTypeStealMin
MemoryManipulation.GetEntityTypeCamouflageDuration = {LibFuncBase=MemoryManipulation.LibFuncBase.EntityType, path='"BehaviorProps.GGL_CCamouflageBehaviorProps.DurationSeconds"'}
MemoryManipulation.SetEntityTypeCamouflageDuration = MemoryManipulation.GetEntityTypeCamouflageDuration
MemoryManipulation.GetEntityTypeCamouflageDiscoveryRange = {LibFuncBase=MemoryManipulation.LibFuncBase.EntityType, path='"BehaviorProps.GGL_CCamouflageBehaviorProps.DiscoveryRange"'}
MemoryManipulation.SetEntityTypeCamouflageDiscoveryRange = MemoryManipulation.GetEntityTypeCamouflageDiscoveryRange
MemoryManipulation.GetBuildingTypeDoorPos = {LibFuncBase=MemoryManipulation.LibFuncBase.EntityType, path='"LogicProps.DoorPos"'}
MemoryManipulation.SetBuildingTypeDoorPos = MemoryManipulation.GetBuildingTypeDoorPos
MemoryManipulation.GetWorkerTypeRefinerResourceType = {LibFuncBase=MemoryManipulation.LibFuncBase.EntityType, path='"BehaviorProps.GGL_CWorkerBehaviorProps.ResourceToRefine"'}
MemoryManipulation.SetWorkerTypeRefinerResourceType = MemoryManipulation.GetWorkerTypeRefinerResourceType
MemoryManipulation.GetWorkerTypeRefinerAmount = {LibFuncBase=MemoryManipulation.LibFuncBase.EntityType, path='"BehaviorProps.GGL_CWorkerBehaviorProps.TransportAmount"'}
MemoryManipulation.SetWorkerTypeRefinerAmount = MemoryManipulation.GetWorkerTypeRefinerAmount
MemoryManipulation.GetBuildingTypeRefinerSupplier = {LibFuncBase=MemoryManipulation.LibFuncBase.EntityType, path='"BehaviorProps.GGL_CResourceRefinerBehaviorProperties.SupplierCategory"'}
MemoryManipulation.SetBuildingTypeRefinerSupplier = MemoryManipulation.GetBuildingTypeRefinerSupplier
MemoryManipulation.GetBuildingTypeRefinerResourceType = {LibFuncBase=MemoryManipulation.LibFuncBase.EntityType, path='"BehaviorProps.GGL_CResourceRefinerBehaviorProperties.ResourceType"'}
MemoryManipulation.SetBuildingTypeRefinerResourceType = MemoryManipulation.GetBuildingTypeRefinerResourceType
MemoryManipulation.GetBuildingTypeRefinerAmount = {LibFuncBase=MemoryManipulation.LibFuncBase.EntityType, path='"BehaviorProps.GGL_CResourceRefinerBehaviorProperties.InitialFactor"'}
MemoryManipulation.SetBuildingTypeRefinerAmount = MemoryManipulation.GetBuildingTypeRefinerAmount
MemoryManipulation.GetEntityTypeArmorClass = {LibFuncBase=MemoryManipulation.LibFuncBase.EntityType, path='"LogicProps.ArmorClass"'}
MemoryManipulation.SetEntityTypeArmorClass = MemoryManipulation.GetEntityTypeArmorClass
MemoryManipulation.GetEntityTypeBlockingArea = {LibFuncBase=MemoryManipulation.LibFuncBase.EntityType, path='"LogicProps.BlockingArea"'}
MemoryManipulation.SetEntityTypeBlockingArea = MemoryManipulation.GetEntityTypeBlockingArea
MemoryManipulation.GetBuildingTypeBuilderSlots = {LibFuncBase=MemoryManipulation.LibFuncBase.EntityType, path='"LogicProps.ConstructionInfo.BuilderSlot"'}
MemoryManipulation.SetBuildingTypeBuilderSlots = MemoryManipulation.GetBuildingTypeBuilderSlots
MemoryManipulation.GetBlockingEntityTypeBuildBlock = {LibFuncBase=MemoryManipulation.LibFuncBase.EntityType, path='"LogicProps.BuildBlockArea"'}
MemoryManipulation.SetBlockingEntityTypeBuildBlock = MemoryManipulation.GetBlockingEntityTypeBuildBlock
MemoryManipulation.GetEntityTypeModel = {LibFuncBase=MemoryManipulation.LibFuncBase.EntityType, path='"DisplayProps.Model"'}
MemoryManipulation.SetEntityTypeModel = MemoryManipulation.GetEntityTypeModel
MemoryManipulation.GetEntityTypeCircularAttackDamage = {LibFuncBase=MemoryManipulation.LibFuncBase.EntityType, path='"BehaviorProps.GGL_CCircularAttackProps.Damage"'}
MemoryManipulation.SetEntityTypeCircularAttackDamage = MemoryManipulation.GetEntityTypeCircularAttackDamage
MemoryManipulation.GetSettlerCurrentAnimation = {LibFuncBase=MemoryManipulation.LibFuncBase.Entity, path='"BehaviorList.GGL_CGLBehaviorAnimationEx.Animation"', check="\tassert(Logic.IsSettler(id)==1)\n"}


function MemoryManipulation.CreateLibFuncs()
	local tocompile = ""
	for name, desc in pairs(MemoryManipulation) do
		if type(desc)=="table" and desc.LibFuncBase then
			local st = string.sub(name, 1, 3)
			if desc.LibFuncBase==MemoryManipulation.LibFuncBase.Entity then
				if st=="Get" then
					tocompile = tocompile..("function MemoryManipulation."..name.."(id)\n\tid = GetID(id)\n"..(desc.check or "").."\treturn MemoryManipulation.GetSingleValue(id, "..desc.path..")\nend\n")
				end
				if st=="Set" then
					tocompile = tocompile..("function MemoryManipulation."..name.."(id, val)\n\tid = GetID(id)\n"..(desc.check or "").."\tMemoryManipulation.SetSingleValue(id, "..desc.path..", val)\nend\n")
				end
			elseif desc.LibFuncBase==MemoryManipulation.LibFuncBase.EntityType then
				if st=="Get" then
					tocompile = tocompile..("function MemoryManipulation."..name.."(typ)\n"..(desc.check or "").."\treturn MemoryManipulation.GetSingleValue(MemoryManipulation.GetETypePointer(typ), "..desc.path..")\nend\n")
				end
				if st=="Set" then
					tocompile = tocompile..("function MemoryManipulation."..name.."(typ, val)\n"..(desc.check or "").."\tMemoryManipulation.SetSingleValue(MemoryManipulation.GetETypePointer(typ), "..desc.path..", val)\nend\n")
				end
			end
		end
	end
	--LuaDebugger.Log(tocompile)
	local comp = S5Hook.Eval(tocompile) -- upvalues dont work, but simply compiling it does ;)
	assert(type(comp)=="function", comp)
	comp()
	MemoryManipulation.LibFuncsCreated = true
end

