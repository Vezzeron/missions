// by Xeno
//#define __DEBUG__
#define THIS_FILE "fn_artillery.sqf"
#include "..\..\x_setup.sqf"

if (isDedicated) exitWith {};

if (!alive player || {isNull objectParent player && {(getPos player) select 2 > 10} || {player getVariable ["xr_pluncon", false]}}) exitWith {
	d_commandingMenuIniting = false;
};

disableSerialization;

#ifndef __TT__
if !(d_ari_available) exitWith {
	[playerSide, "HQ"] sideChat (localize "STR_DOM_MISSIONSTRING_145");
	d_commandingMenuIniting = false;
};
#else
if (d_player_side == blufor && {!d_ari_available_w} || {d_player_side == opfor && {!d_ari_available_e}}) exitWith {
	[playerSide, "HQ"] sideChat (localize "STR_DOM_MISSIONSTRING_145");
	d_commandingMenuIniting = false;
};
#endif

if (d_with_ranked && {score player < (d_ranked_a select 2)}) exitWith {
	[playerSide, "HQ"] sideChat format [localize "STR_DOM_MISSIONSTRING_147", score player, d_ranked_a select 2];
	d_commandingMenuIniting = false;
};

#ifndef __TT__
if (d_ari_blocked) exitWith {
	[playerSide, "HQ"] sideChat (localize "STR_DOM_MISSIONSTRING_148");
	d_commandingMenuIniting = false;
};

d_ari_blocked = true; publicVariable "d_ari_blocked";
#else
private _dexit = false;
if (d_player_side == blufor) then {
	if (d_ari_blocked_w) exitWith {
		_dexit = true;
	};

	d_ari_blocked_w = true; publicVariable "d_ari_blocked_w";
} else {
	if (d_player_side == opfor) then {
		if (d_ari_blocked_e) exitWith {
			_dexit = true;
		};

		d_ari_blocked_e = true; publicVariable "d_ari_blocked_e";
	};
};
if (_dexit) exitWith {
	[playerSide, "HQ"] sideChat (localize "STR_DOM_MISSIONSTRING_148");
	d_commandingMenuIniting = false;
};
#endif

createDialog "d_ArtilleryDialog2";
d_commandingMenuIniting = false;

0 spawn {
	waitUntil {!isNil "d_arti_did_fire" || {!d_arti_dialog_open || {!alive player || {player getVariable ["xr_pluncon", false]}}}};

	if (!alive player || {player getVariable ["xr_pluncon", false]}) exitWith {
		if (d_arti_dialog_open) then {closeDialog 0};
#ifndef __TT__
		d_ari_blocked = false; publicVariable "d_ari_blocked";
#else
		if (d_player_side == blufor) then {
			d_ari_blocked_w = false; publicVariable "d_ari_blocked_w";
		} else {
			if (d_player_side == opfor) then {
				d_ari_blocked_e = false; publicVariable "d_ari_blocked_e";
			};
		};
#endif
	};

	if (isNil "d_arti_did_fire") then {
		[playerSide, "HQ"] sideChat (localize "STR_DOM_MISSIONSTRING_152");
	} else {
		d_arti_did_fire = nil;
	};

#ifndef __TT__
	d_ari_blocked = false; publicVariable "d_ari_blocked";
#else
	if (d_player_side == blufor) then {
		d_ari_blocked_w = false; publicVariable "d_ari_blocked_w";
	} else {
		if (d_player_side == opfor) then {
			d_ari_blocked_e = false; publicVariable "d_ari_blocked_e";
		};
	};
#endif
};