
--- author:?		current maintainer:mcb		v1.0
-- Tribute erstellen & callback.
-- 
-- - local tribId = AddTribute{											Setzt das feld Tribute mit der id.
-- 		Spawn = {{Pos, LeaderType, Soldiers, RalleyPoint}},				Optional, Spawnt Truppen.
-- 		SpawnPlayer,													Optional, Player zum truppenspawnen, default gvMission.PlayerID.
-- 		Entities,														Optional, Alle entities hier drinn werden an gvMission.PlayerID übergeben.
-- 		Entity,															Optional, wird an gvMission.PlayerID übergeben.
-- 		Ralleypoint,													Optional, Gespawnte/Übergebene werden hierher bewegt.
-- 		Technologies,													Optional, alle techs die für gvMission.PlayerID erforscht werden.
-- 		Resources = {gold,clay,wood,stone,iron,sulfur},					Optional, gvMission.PlayerID bekommt diese res.
-- 		Callback = func(t),												Optional, wird bei bezahlen aufgerufen, t ist das an AddTribute übergebene table.
-- 		text,															Wird im Tributmenü angezeigt.
-- 		cost = {XXX=0, XXX=0},											Kosten zum Bezahlen. Key aus ResourceType = Anzahl. Muss mindestens ein rtyp enthalten (kann aber 0 sein).
-- 		pId,															Spieler der den Tribut bezahlen kann.
-- }
-- 
-- CreateATribute(_pId, _text, _cost, _callback)						Erstellt ein tribut table, muss noch per AddTribute hinzugefügt werden.
-- 
-- TODO: Fix SetupTributePaid, entferne zeug aus Data.
AddTribute = function( _tribute )
    assert( type( _tribute ) == "table", "Tribut muss ein Table sein" );
    assert( type( _tribute.text ) == "string", "Tribut.text muss ein String sein" );
    assert( type( _tribute.cost ) == "table", "Tribut.cost muss ein Table sein" );
    assert( type( _tribute.pId ) == "number", "Tribut.pId muss eine Nummer sein" );
    assert( not _tribute.Tribute , "Tribut.Tribute darf nicht vorbelegt sein");

	if MPSyncer then
		_tribute.Tribute = MPSyncer.GetNextScriptTributeID()
	else
	    uniqueTributeCounter = uniqueTributeCounter or 1;
	    _tribute.Tribute = uniqueTributeCounter;
	    uniqueTributeCounter = uniqueTributeCounter + 1;
    end

    local tResCost = {};
    for k, v in pairs( _tribute.cost ) do
        assert( ResourceType[k] );
        assert( type( v ) == "number" );
        table.insert( tResCost, ResourceType[k] );
        table.insert( tResCost, v );
    end

    Logic.AddTribute( _tribute.pId, _tribute.Tribute, 0, 0, _tribute.text, unpack( tResCost ) );
    SetupTributePaid( _tribute );
    return _tribute.Tribute;
end

CreateATribute = function(_pId, _text, _cost, _callback)
    local tribute =  {};
    tribute.pId = _pId;
    tribute.text = _text;
    tribute.cost = _cost;
    tribute.Callback = _callback;
    return tribute
end