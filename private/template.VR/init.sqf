call TFT_fnc_prepPhaseInit;

if isServer then {
	_curator = (createGroup sideLogic) createUnit ["ModuleCurator_F", [0,0,0], [], 0, "NONE"]; 
	_curator setVariable ["Addons", 3, true]; 
	_curator setVariable ["Owner", "#adminLogged", true];

	{ 
	  _x addCuratorEditableObjects [allUnits + vehicles, true]; 
	} forEach allCurators; 
	
	//all players
	private _allHCs = entities "HeadlessClient_F";
	private _allHPs = allPlayers - _allHCs;

	TFT_players = [];
	{
		TFT_players pushBackUnique (name _x);
	} forEach _allHPs;

	0 = [] execVM "log.sqf";
}

// fix for units losing their loadout when switching to Headless Client
["CAManBase", "Local", {
    params ["_entity", "_isLocal"];

    if (_isLocal) then {
        if ((uniform _entity) isEqualTo "") then {
            _entity setUnitLoadout (getUnitLoadout (typeOf _entity));
        };
    };
}] call CBA_fnc_addClassEventHandler;