		[] call compilefinal preprocessFileLineNumbers "oo_patrol.sqf";

		 _patrol = ["new", [group toto, 200, position toto]] call OO_PATROL;

		sleep 5;

		_position = ["RandomPos", ""] call _patrol;
		["Move", _position] call _patrol;

	


