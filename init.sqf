		call compile preprocessFileLineNumbers "oo_patrol.sqf";

		sleep 2;

		_patrol = ["new", group toto] call OO_PATROL;
		["patrol", [position toto, 100]] spawn _patrol;

		_patrol2 = ["new", group tata] call OO_PATROL;
		["patrol", [position tata, 100]] spawn _patrol2;