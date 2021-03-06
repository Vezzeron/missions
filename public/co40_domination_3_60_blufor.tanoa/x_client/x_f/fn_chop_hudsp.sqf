// by Xeno
//#define __DEBUG__
#define THIS_FILE "fn_chop_hudsp.sqf"
#include "..\..\x_setup.sqf"

if (isDedicated) exitWith {};

private ["_chdispx", "_chdispx2"];

//private _helper_h = d_HeliHEmpty createVehicleLocal [0,0,0];
//_helper_h enableSimulation false;

disableSerialization;

#define __ui_forward "pics\ui_tankdir_forward_ca.paa"
#define __ui_back "pics\ui_tankdir_back_ca.paa"
#define __ui_left "pics\ui_tankdir_left_ca.paa"
#define __ui_right "pics\ui_tankdir_right_ca.paa"
#define __ui_tohigh "pics\ui_tankdir_turret_ca.paa"
#define __ui_ok "pics\ui_tankdir_tower_ca.paa"

private _distvstr = localize "STR_DOM_MISSIONSTRING_192";
private _typestr = localize "STR_DOM_MISSIONSTRING_193";
private _liftstr = localize "STR_DOM_MISSIONSTRING_194";
private _distgrstr = localize "STR_DOM_MISSIONSTRING_195";

#define __CTRL2(B) (_chdispx displayCtrl B)
#define __CTRL3(B) (_chdispx2 displayCtrl B)

private _vec = vehicle player;
private _doexitit = false;
private _chophud_shown = false;
private _chophud2_shown = false;
while {d_player_in_vec} do {
	if (player == driver _vec) then {
		private _chopttype = _vec getVariable ["d_choppertype", -1];
		__TRACE_2("","_vec","_chopttype")
		if (_chopttype > -1) then {
			private _chop_welcome_scr = [_chopttype, _vec] spawn d_fnc_chopper_welcome2;
			sleep 0.321;
			waitUntil {scriptDone _chop_welcome_scr};
		};
		if (_chopttype in [0,1]) then {
			private _search_height = 0;
			private _lift_height = 0;
			private _possible_types = _vec getVariable ["d_lift_types", []];
			__TRACE_2("","_vec","_possible_types")
			if (_chopttype == 1) then {
				_search_height = 70;
				_lift_height = 50;
			} else {
				_search_height = 50;
				_lift_height = 50;
			};
			private _hudoff = true;

			private _sling_cam = objNull;
			private _pip_cam_on = false;
			private _prev_liftobj = objNull;

			while {d_player_in_vec && {alive player && {player == driver _vec}}} do {
				if (d_chophud_on && {!visibleMap}) then {
					if (isNil "_vec") then {_vec = vehicle player};
					_hudoff = false;
					private _liftobj = objNull;
					private _check_cond = false;
					
					if (_vec getVariable ["d_vec_attached", false]) then {
						// no need to check for nearest!
						_liftobj = _vec getVariable ["d_Attached_Vec", objNull];
						_check_cond = !isNull _liftobj;
					} else {
						private _nobjects = nearestObjects [_vec, ["LandVehicle", "Air"], _search_height];
						__TRACE_2("","_vec","_nobjects")
						
						if !(_nobjects isEqualTo []) then {
							private _dummy = _nobjects select 0;
							if (isNil "_vec") then {_vec = vehicle player};
							if (_dummy == _vec) then {
								if (count _nobjects > 1) then {_liftobj = _nobjects select 1};
							} else {
								_liftobj = _dummy;
							};
						};
						
						if (!isNull _liftobj) then {
							if (_liftobj isKindOf "CAManBase") then {
								_liftobj = objNull;
							} else {
								private _marp = _liftobj getVariable ["d_WreckMaxRepair", d_WreckMaxRepair];
								__TRACE_2("","_vec","_marp")
								private _liftobju = toUpper (typeOf _liftobj);
								__TRACE_2("","_vec","_liftobju")
								_check_cond = if (_chopttype == 1) then {
									(!isNull _liftobj && {_marp > 0 && {damage _liftobj >= 1 && {_liftobju in _possible_types}}})
								} else {
#ifndef __TT__
									(!isNull _liftobj && {(getPosATLVisual _vec) select 2 > 2.5 && {_liftobju in _possible_types}})
#else
									(!isNull _liftobj && {(getPosATLVisual _vec) select 2 > 2.5 && {_liftobju in _possible_types && {_liftobj getVariable ["d_side", d_player_side] == d_player_side}}})
#endif
								};
							};
						};
					};
					
					sleep 0.001;
					__TRACE_3("","_vec","_check_cond","_liftobj")
					
					if (_check_cond) then {
						if (!_chophud_shown) then {
							"d_chopper_lift_hud" cutRsc ["d_chopper_lift_hud", "PLAIN"];
							_chophud_shown = true;
							_chdispx = uiNamespace getVariable "d_chopper_lift_hud";
							__CTRL2(64440) ctrlSetText ([localize "STR_DOM_MISSIONSTRING_197", localize "STR_DOM_MISSIONSTRING_196"] select (_chopttype == 1));
						};
						
						if (_prev_liftobj != _liftobj) then {
							private _tofn = typeOf _liftobj;
							
							private _type_name = [_tofn, "CfgVehicles"] call d_fnc_GetDisplayName;
							__CTRL2(64438) ctrlSetText ([format [_liftstr, _type_name], format [_typestr, _type_name]] select !(_vec getVariable ["d_vec_attached", false]));

							private _picstat = getText (configFile>>"CfgVehicles">>_tofn>>"picture");
							private _picvcicons = getText (configFile>>"CfgVehicleIcons">>_picstat);
							__CTRL2(64439) ctrlSetText ([_picstat, _picvcicons] select (_picvcicons != ""));
							if (!isPiPEnabled) then {
								_prev_liftobj = _liftobj;
							};
						};

						if (isPipEnabled && {!_pip_cam_on || {_prev_liftobj != _liftobj}}) then {
							"d_RscPIP" cutText ["", "plain"];
							if (!isNull _sling_cam) then {
								_sling_cam cameraEffect ["terminate","back"];
								camDestroy _sling_cam;
							};
							//_helper_h attachTo [_liftobj, [0, 0, 0]];
							//_helper_h attachTo [_vec, [0, 4, -10]];
							private _cam_loc = _vec selectionPosition "slingcamera";
							if (_cam_loc isEqualTo [0,0,0]) then {
								_cam_loc = _vec selectionPosition "slingload0";
								if (_cam_loc isEqualTo [0,0,0]) then {
									_cam_loc = [0,0,-2.8];
								};
								_cam_loc = [_cam_loc select 0, (_cam_loc select 1) - 5, (_cam_loc select 2) - 0.1];
							} else {
								_cam_loc = [_cam_loc select 0, _cam_loc select 1, (_cam_loc select 2) - 0.2];
							};
							
							"d_RscPIP" cutRsc ["d_RscPIP", "PLAIN", 0, false];
							private _ctrlpip = (uiNamespace getVariable "d_RscPIP") displayCtrl 2300;
							private _poscpip = ctrlPosition _ctrlpip;
							_poscpip set [1, (_poscpip select 1) + 0.3];
							_ctrlpip ctrlSetPosition _poscpip;
							_ctrlpip ctrlSettext format ["#(argb,256,256,1)r2t(%1,1.0)", "d_choprendtar0"];
							_ctrlpip ctrlSettextcolor [1,1,1,1];
							_ctrlpip ctrlCommit 0;
							
							_sling_cam = "camera" camCreate (getPosATLVisual _vec);
							_sling_cam attachTo [_vec, _cam_loc];
							//_sling_cam camPreparetarget _helper_h;
							_sling_cam camPreparetarget _liftobj;
							_sling_cam camCommitprepared 0;
							_sling_cam camPrepareFOV 0.9;
							_sling_cam camCommit 2;
							_sling_cam cameraEffect ["internal", "back", "d_choprendtar0"];
							_pip_cam_on = true;
							_prev_liftobj = _liftobj;
						};
						
						if !(_vec getVariable ["d_vec_attached", false]) then {
							__CTRL2(64441) ctrlSetText format [_distvstr, round (_vec distance _liftobj)];
							private _liftobj_pos = getPosATLVisual _liftobj;
							private _pos_vec = getPosATLVisual _vec;
							private _nx = _liftobj_pos select 0; private _ny = _liftobj_pos select 1; private _px = _pos_vec select 0; private _py = _pos_vec select 1;
							if ((_px <= _nx + 10 && {_px >= _nx - 10}) && {(_py <= _ny + 10 && {_py >= _ny - 10})} && {(_pos_vec select 2 < _lift_height)}) then {
								__CTRL2(64448) ctrlSetText __ui_ok;
							} else {
								__CTRL2(64442) ctrlSetText (if ((getPosATLVisual _vec) select 2 >= _lift_height) then {localize "STR_DOM_MISSIONSTRING_198"} else {""});
								__CTRL2(64447) ctrlSetText __ui_tohigh;
								private _angle = _pos_vec getDir _liftobj_pos;
								/*private _angle = 0; private _a = ((_liftobj_pos select 0) - (_pos_vec select 0));private _b = ((_liftobj_pos select 1) - (_pos_vec select 1));
								if (_a != 0 || _b != 0) then {_angle = _a atan2 _b}; */
								
								private _dif = _angle - getDirVisual _vec;
								if (_dif < 0) then {_dif = 360 + _dif};
								if (_dif > 180) then {_dif = _dif - 360};
								_angle = _dif;
								__CTRL2(64444) ctrlSetText (["", __ui_forward] select (_angle >= -70 && {_angle <= 70}));
								__CTRL2(64446) ctrlSetText (["", __ui_right] select (_angle >= 20 && {_angle <= 160}));
								__CTRL2(64443) ctrlSetText (["", __ui_back] select (_angle <= -110 || {_angle >= 110}));
								__CTRL2(64445) ctrlSetText (["", __ui_left] select (_angle <= -20 && {_angle >= -160}));
								sleep 0.001;
							};
						} else {
							private _ddx1 = [round ((getPosASLVisual _liftobj) select 2), round ((getPosATLVisual _liftobj) select 2)] select (!surfaceIsWater (getPosASL _liftobj));
							__CTRL2(64441) ctrlSetText format [_distgrstr, _ddx1];
							__CTRL2(64442) ctrlSetText (localize "STR_DOM_MISSIONSTRING_199");
							sleep 0.001;
						};
					} else {
						if (_chophud_shown) then {
							"d_chopper_lift_hud" cutFadeOut 0;
							_chophud_shown = false;
						};
						if (!_chophud2_shown) then {
							"d_chopper_lift_hud2" cutRsc ["d_chopper_lift_hud2", "PLAIN"];
							_chophud2_shown = true;
						};
						_chdispx2 = uiNamespace getVariable "d_chopper_lift_hud2";
						__CTRL3(61422) ctrlSetText ([localize "STR_DOM_MISSIONSTRING_197", localize "STR_DOM_MISSIONSTRING_196"] select _chopttype);
						

						if (_pip_cam_on) then {
							"d_RscPIP" cutText ["", "plain"];
							_sling_cam cameraEffect ["terminate","back"];
							camDestroy _sling_cam;
							_sling_cam = objNull;
							//detach _helper_h;
							_pip_cam_on = false;
							_prev_liftobj = objNull;
						};

					};
				} else {
					if (!_hudoff) then {
						_hudoff = true;
						if (_chophud_shown) then {
							"d_chopper_lift_hud" cutFadeOut 0;
							_chophud_shown = false;
						};
						if (_chophud2_shown) then {
							"d_chopper_lift_hud2" cutFadeOut 0;
							_chophud2_shown = false;
						};
					};

					if (_pip_cam_on) then {
						"d_RscPIP" cutText ["","plain"];
						_sling_cam cameraEffect ["terminate","back"];
						camDestroy _sling_cam;
						_sling_cam = objNull;
						//detach _helper_h;
						_pip_cam_on = false;
						_prev_liftobj = objNull;
					};

				};
				sleep 0.231;
			};
			if (_chophud_shown) then {
				"d_chopper_lift_hud" cutFadeOut 0;
				_chophud_shown = false;
			};
			if (_chophud2_shown) then {
				"d_chopper_lift_hud2" cutFadeOut 0;
				_chophud2_shown = false;
			};

			if (_pip_cam_on) then {
				"d_RscPIP" cutText ["","plain"];
				_sling_cam cameraEffect ["terminate","back"];
				camDestroy _sling_cam;
				_sling_cam = objNull;
				//detach _helper_h;
				_pip_cam_on = false;
				_prev_liftobj = objNull;
			};
		} else {
			if (!_chophud2_shown) then {
				"d_chopper_lift_hud2" cutRsc ["d_chopper_lift_hud2", "PLAIN"];
				_chophud2_shown = true;
			};
			_chdispx2 = uiNamespace getVariable "d_chopper_lift_hud2";
			__CTRL3(61422) ctrlSetText (localize "STR_DOM_MISSIONSTRING_200");
			while {d_player_in_vec && {alive player && {player == driver _vec && {!(player getVariable ["xr_pluncon", false])}}}} do {
				sleep 0.421;
			};
			_doexitit = true;
			if (_chophud2_shown) then {
				"d_chopper_lift_hud2" cutFadeOut 0;
				_chophud2_shown = false;
			};
		};
	};
	if (_doexitit) exitWith {};
	sleep 0.432;
};

//deleteVehicle _helper_h;
