// by Xeno
#define THIS_FILE "fn_sideconvoy.sqf"
#include "..\..\x_setup.sqf"

if !(call d_fnc_checkSHC) exitWith {};

params ["_pos_start", "_pos_end", "_direction"];

#ifdef __TT__
d_sm_points_blufor = 0;
d_sm_points_opfor = 0;
#endif

if (d_with_ranked) then {d_sm_p_pos = nil};

d_confvdown = 0;
private _numconfv = count d_sm_convoy_vehicles;
private _newgroup = [d_side_enemy] call d_fnc_creategroup;
private _reta = [1, _pos_start, (d_sm_convoy_vehicles select 0), _newgroup, _direction] call d_fnc_makevgroup;
private _vehicles = _reta select 0;
private _onevec = _vehicles select 0;
_onevec lock true;
_onevec allowCrewInImmobile true;
private _nextpos = _onevec modeltoworld [0, -15, 0];
_nextpos set [2,0];
_onevec addEventHandler ["killed", {
	d_confvdown = d_confvdown + 1;
	(param [0]) removeAllEventHandlers "killed";
	{(param [0]) deleteVehicleCrew _x;false} count (crew (param [0]));
}];
#ifdef __TT__
_onevec addEventHandler ["handleDamage", {_this call d_fnc_AddSMPoints}];
#endif

d_x_sm_vec_rem_ar append _vehicles;
d_x_sm_rem_ar append (_reta select 1);
private _leader = leader _newgroup;
_leader setRank "LIEUTENANT";
_newgroup allowFleeing 0;
_newgroup setCombatMode "GREEN";
_newgroup setFormation "COLUMN";
_newgroup setSpeedMode "LIMITED";
sleep 1.933;
_vehicles = nil;
private _allSMVecs = [_onevec];
for "_i" from 1 to (_numconfv - 1) do {
	_reta = [1, _nextpos, (d_sm_convoy_vehicles select _i), _newgroup, _direction] call d_fnc_makevgroup;
	_vehicles = _reta select 0;
	_onevec = _vehicles select 0;
	_onevec lock true;
	_nextpos = _onevec modeltoworld [0, -9, 0];
	_nextpos set [2,0];
	_onevec addEventHandler ["killed", {
		d_confvdown = d_confvdown + 1;
		(param [0]) removeAllEventHandlers "killed";
		{(param [0]) deleteVehicleCrew _x;false} count (crew (param [0]));
	}];
#ifdef __TT__
	_onevec addEventHandler ["handleDamage", {_this call d_fnc_AddSMPoints}];
#endif
	_allSMVecs pushBack _onevec;
	d_x_sm_vec_rem_ar append _vehicles;
	d_x_sm_rem_ar append (_reta select 1);
	sleep 1.933;
	_vehicles = nil;
};

// TODO: Check if the convoy still defends itself because setWaypointForceBehaviour dsiabled AUTOCOMBAT
private _wp =_newgroup addWaypoint[_pos_start, 0];
_wp setWaypointBehaviour "SAFE";
_wp setWaypointSpeed "NORMAL";
_wp setwaypointtype "MOVE";
_wp setWaypointFormation "COLUMN";
_wp setWaypointTimeout [60,80,70];
_wp setWaypointForceBehaviour true;
_wp = _newgroup addWaypoint[_pos_end, 0];
_wp setWaypointBehaviour "SAFE";
_wp setWaypointSpeed "NORMAL";
_wp setwaypointtype "MOVE";
_wp setWaypointFormation "COLUMN";
_wp setWaypointForceBehaviour true;

sleep 20.123;

private _convoy_reached_dest = false;
private _endtime = time + 4800;

while {true} do {
	call d_fnc_mpcheck;
	if (d_confvdown == _numconfv || {{canMove _x} count _allSMVecs == 0}) exitWith {};
	if ((getPosATL (leader _newgroup)) distance2D _pos_end < 100) exitWith {
		_convoy_reached_dest = true;
	};
	if (d_with_ranked) then {
		[missionNamespace, ["d_sm_p_pos", getPosATL _leader]] remoteExecCall ["setVariable", [0, -2] select isDedicated];
	};
	if (time > _endtime) exitWith {_convoy_reached_dest = true};
	sleep 5.123;
};

d_sm_winner = if (_convoy_reached_dest) then {
	-300
} else {
#ifndef __TT__
	2
#else
	if (d_sm_points_blufor > d_sm_points_opfor) then {
		2
	} else {
		if (d_sm_points_opfor > d_sm_points_blufor) then {
			1
		} else {
			123
		};
	};
#endif
};

d_sm_resolved = true;
if (d_IS_HC_CLIENT) then {
	[missionNamespace, ["d_sm_winner", d_sm_winner]] remoteExecCall ["setVariable", 2];
	[missionNamespace, ["d_sm_resolved", true]] remoteExecCall ["setVariable", 2];
};