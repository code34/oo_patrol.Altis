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
		PRIVATE VARIABLE("array","enemyside");
		PRIVATE VARIABLE("array","waypoint");


		PUBLIC FUNCTION("array","constructor") {
			MEMBER("group", _this select 0);
			MEMBER("areasize", _this select 1);
			MEMBER("center", _this select 2);
			if(side (leader MEMBER("group", nil)) == west) then { _side = [east]; MEMBER("enemyside", _side);};
			if(side (leader MEMBER("group", nil)) == east) then { _side = [west]; MEMBER("enemyside", _side);};
			if(side (leader MEMBER("group", nil)) == resistance) then { _side = [west]; MEMBER("enemyside", _side);};
		};

		PUBLIC FUNCTION("string", "Scan") {
			private ["_areasize", "_cibles", "_enemyside", "_list", "_position"];

			_areasize = MEMBER("areasize", nil);
			_position = MEMBER("center", nil);
			_enemyside = MEMBER("enemyside", nil);

			_list = _position nearEntities [["Man"], _areasize];

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
			_cibles;
		};

		PUBLIC FUNCTION("array", "Move") {
			private ["_position", "_group", "_wp"];
			_position = _this;

			_group = MEMBER("group", nil);
			_group setBehaviour "AWARE";
			_group setCombatMode "RED";

			_wp = _group addWaypoint [_position, 0];
			_wp setWaypointPosition [_position, 0];
			_wp setWaypointType "DESTROY";
			_wp setWaypointVisible true;
			_wp setWaypointSpeed "LIMITED";
			_group setCurrentWaypoint _wp;
			MEMBER("waypoint", _wp);
		};

		PUBLIC FUNCTION("string", "GoalDistance") {
			leader (MEMBER("group", nil)) distance waypointPosition(MEMBER("waypoint", nil));
		};

		PUBLIC FUNCTION("string", "CheckMovement") {
			if(MEMBER("GoalDistance", "") > 25) then {
				true;
			} else {
				false;
			};
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
			DELETE_VARIABLE("enemyside");
			DELETE_VARIABLE("waypoint");
		};
	ENDCLASS;