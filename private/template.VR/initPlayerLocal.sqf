// Player fatigue never reaches 0, removes force walk
if (hasInterface) then {
_handle = [{
	if (ace_advanced_fatigue_anreserve < 100) then{ ace_advanced_fatigue_anreserve = 100; };
}, 1,[]] call CBA_fnc_addPerFrameHandler;
};
