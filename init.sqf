		call compile preprocessFileLineNumbers "oo_patrol.sqf";

		sleep 2;

		_patrol = ["new", group toto] call OO_PATROL;
		["patrol", [position player, 100]] call _patrol;
