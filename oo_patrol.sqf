	/*
	Author: code34 nicolas_boiteux@yahoo.fr
	Copyright (C) 2013 Nicolas BOITEUX

	CLASS OO_PATROL -  A simple Patrol script
	
	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.
	
	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.
	
	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>. 
	*/

	#include "oop.h"

	CLASS("OO_PATROL")

		PRIVATE VARIABLE("group","group");
		PRIVATE VARIABLE("scalar","areasize");
		PRIVATE VARIABLE("array","center");
		PRIVATE VARIABLE("string","enemyside");


		PUBLIC FUNCTION("array","constructor") {
			MEMBER("group", _this select 0);
			MEMBER("areasize", _this select 1);
			MEMBER("center", _this select 2);
			if(side (leader MEMBER("group", nil)) == west) then { MEMBER("enemyside", east);};
			if(side (leader MEMBER("group", nil)) == east) then { MEMBER("enemyside", west);};
			if(side (leader MEMBER("group", nil)) == resistance) then { MEMBER("enemyside", west);};
		};

		PUBLIC FUNCTION("string", "Scan") {
			private ["_position", "_list", "_cibles"];

			_position = position (leader MEMBER("group", nil));
			_list = _position nearEntities [["Man"], MEMBER("areasize", nil)];
			if(count _list > 0) then {
				_cibles = [];
				{
					if(side _x in _enemyside) then {
						_cibles = _cibles + [_x];
					} else {
						_list = _list - [_x];
					};
					sleep 0.1;
				}foreach _list;
			};
		};

		PUBLIC FUNCTION("array", "Move") {
			private ["_position", "_group", "_wp"];
			_position = _this;

			_group = MEMBER("group", nil);
			_group setBehaviour "AWARE";
			_group setCombatMode "RED";

			_wp = _group addWaypoint [_position, 25];
			_wp setWaypointPosition [_position, 25];
			_wp setWaypointType "DESTROY";
			_wp setWaypointVisible true;
			_wp setWaypointSpeed "LIMITED";
			_group setCurrentWaypoint _wp;
		};

		PUBLIC FUNCTION("string", "RandomPos") {
			private ["_areasize", "_newx", "_newy", "_position"];

			_position = MEMBER("center", nil);
			_areasize = MEMBER("areasize", nil);

			if(random 1 > 0.5) then {
				_newx = (_position select 0) + ((random _areasize) * -1 );
				_newy = (_position select 1) + ((random _areasize) * -1 );
			} else {
				_newx = (_position select 0) + (random _areasize);
				_newy = (_position select 1) + (random _areasize);
			};
			[_newx, _newy];
		};

		PUBLIC FUNCTION("","deconstructor") { 
			DELETE_VARIABLE("group");
			DELETE_VARIABLE("areasize");
			DELETE_VARIABLE("center");
			DELETE_VARIABLE("marker");
			DELETE_VARIABLE("enemyside");
		};
	ENDCLASS;