		[] call compilefinal preprocessFileLineNumbers "oo_patrol.sqf";

		_patrol = ["new", [group toto, 200, position toto]] call OO_PATROL;

		sleep 5;

		_position = ["StartPatrol", ""] call _patrol;



		
	


