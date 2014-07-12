		[] call compilefinal preprocessFileLineNumbers "oo_patrol.sqf";

		 _patrol = ["new"] call OO_PDW;
		["SavePlayer", player] call _patrol;


