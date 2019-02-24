		call compile preprocessFileLineNumbers "oo_patrol.sqf";

		sleep 2;

		{
				private _patrol = ["new", _x] call OO_PATROL;
				["patrol", [position leader(_x), 100]] spawn _patrol;
		} forEach allGroups;
