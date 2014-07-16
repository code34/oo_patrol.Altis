	/*
	Author: code34 nicolas_boiteux@yahoo.fr
	Copyright (C) 2013 Nicolas BOITEUX

	CLASS OO_SOLDIER -  A simple Patrol script
	
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

	CLASS("OO_SOLDIER")

		PRIVATE VARIABLE("array","cibles");
		PRIVATE VARIABLE("group","group");
		PRIVATE VARIABLE("scalar","areasize");
		PRIVATE VARIABLE("array","center");
		PRIVATE VARIABLE("array","enemyside");
		PRIVATE VARIABLE("array","waypoint");
		PRIVATE VARIABLE("bool","patrol");

		PUBLIC FUNCTION("array","constructor") {
			MEMBER("group", _this select 0);
			MEMBER("areasize", _this select 1);
			MEMBER("center", _this select 2);
			if(side (leader MEMBER("group", nil)) == west) then { _side = [east]; MEMBER("enemyside", _side);};
			if(side (leader MEMBER("group", nil)) == east) then { _side = [west]; MEMBER("enemyside", _side);};
			if(side (leader MEMBER("group", nil)) == resistance) then { _side = [west]; MEMBER("enemyside", _side);};
			MEMBER("Scan", "");
		};

		PUBLIC FUNCTION("array", "SetTarget") {
			private["_unit", "_target];

			_unit = _this select 0;
			_target = _this select 1;

			_unit dotarget _target;
			_unit dofire _target;
		};

		PUBLIC FUNCTION("string", "Monitor") {
			private ["_unit", "_target"];
			{
				_unit = _x;
				{
					if(MEMBER("SeeTarget", [_unit, x])) then {
						MEMBER("SetTarget", [_unit, _x]);
					};
					sleep 0.01;
				} foreach MEMBER("cibles", nil);
				sleep 0.01;
			}foreach units MEMBER("group", nil);
		};

		PUBLIC FUNCTION("array", "SeeTarget") {
			private ["_target", "_leader", "_position", "_unit"];

			_unit = _this select 0;
			_target = _this select 1;

			_position = _unit getHideFrom _target;
			if(_position distance _target < 4) then {
				true;
			} else {
				false;
			};
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
			private ["_leader", "_oldposition", "_newposition"];
			_leader = leader (MEMBER("group", nil));
			_oldposition = position _leader;
			sleep 1;
			_newposition = position _leader;
			if(format["%1", _oldposition] == format["%1", _newposition]) then {
				false;
			} else {
				true;
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
			DELETE_VARIABLE("patrol");
			DELETE_VARIABLE("waypoint");
		};
	ENDCLASS;