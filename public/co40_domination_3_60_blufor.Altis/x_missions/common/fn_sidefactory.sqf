// by Xeno
#define THIS_FILE "fn_sidefactory.sqf"
#include "..\..\x_setup.sqf"

if !(call d_fnc_checkSHC) exitWith {};

#ifdef __TT__
d_sm_points_blufor = 0;
d_sm_points_opfor = 0;
#endif


private _barray = [];
{
	if (isNil "_x") exitWith {false};
	if (!isNull _x) then {
		_barray pushBack _x;
#ifdef __TT__
		_x addEventHandler ["handleDamage", {_this call d_fnc_AddSMPoints}];
#endif
	};
	false
} count _this;

while {true} do {
	call d_fnc_mpcheck;
	if ({alive _x} count _barray == 0) exitWith {};
	sleep 5.321;
};

#ifndef __TT__
d_sm_winner = 2;
#else
if (d_sm_points_blufor > d_sm_points_opfor) then {
	d_sm_winner = 2;
} else {
	if (d_sm_points_opfor > d_sm_points_blufor) then {
		d_sm_winner = 1;
	} else {
		if (d_sm_points_opfor == d_sm_points_blufor) then {
			d_sm_winner = 123;
		};
	};
};
#endif
d_sm_resolved = true;
if (d_IS_HC_CLIENT) then {
	[missionNamespace, ["d_sm_winner", d_sm_winner]] remoteExecCall ["setVariable", 2];
	[missionNamespace, ["d_sm_resolved", true]] remoteExecCall ["setVariable", 2];
};