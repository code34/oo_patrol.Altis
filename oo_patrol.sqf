
	/*
	Author: code34 nicolas_boiteux@yahoo.fr
	Copyright (C) 2014-2018 Nicolas BOITEUX

	CLASS OO_PATROL
	
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
		PRIVATE VARIABLE("bool","alert");
		PRIVATE VARIABLE("scalar","areasize");		
		PRIVATE VARIABLE("array","around");		
		PRIVATE VARIABLE("array","buildings");
		PRIVATE VARIABLE("bool","city");
		PRIVATE VARIABLE("bool","event");
		PRIVATE VARIABLE("group","group");
		PRIVATE VARIABLE("scalar","flank");
		PRIVATE VARIABLE("scalar","sizegroup");
		PRIVATE VARIABLE("object","target");
		PRIVATE VARIABLE("array","targets");

		PUBLIC FUNCTION("group","constructor") {
			DEBUG(#, "OO_PATROL::constructor")
			MEMBER("group", _this);
			MEMBER("areasize", 0);
			MEMBER("sizegroup", count (units _this));
			MEMBER("getBuildings", nil);
			MEMBER("alert", false);
			MEMBER("setFlank", nil);
			MEMBER("event", false);
		};

		PUBLIC FUNCTION("","getGroup") FUNC_GETVAR("group");
		PUBLIC FUNCTION("","getTarget") FUNC_GETVAR("target");

		PUBLIC FUNCTION("", "setFlank") {
			DEBUG(#, "OO_PATROL::setFlank")
			if(random 1 > 0.5) then {
				MEMBER("flank", 110);
			} else {
				MEMBER("flank", -110);
			};
		};

		/*
		Patrol around a position
		@position : position of patrol
		*/
		PUBLIC FUNCTION("array", "patrol") {
			DEBUG(#, "OO_PATROL::patrol")
			private _position = _this select 0;
			private _areasize = _this select 1;
			MEMBER("walk", _areasize);

			//while { !MEMBER("event", nil) } do {
				//if(MEMBER("city", nil)) then {
				//	MEMBER("walkInBuildings", nil);
				//} else {
				//	MEMBER("walk", _areasize);
				//};
				//sleep 0.1;
			//};
		};

		/*
		Attack targets around a position
		@position
		*/
		PUBLIC FUNCTION("array", "attack") {	
			DEBUG(#, "OO_PATROL::attack")
			private _position = _this;
			private _group = MEMBER("group", nil);

			MEMBER("setCombatMode", nil);
			while { count (units _group) > 0 } do {
				MEMBER("getTargets", _position);
				MEMBER("getNextTarget", nil);
				MEMBER("engageTarget", nil);
				sleep 0.1;
			};			
		};

		/*
		Retrieve buildings
		Parameters: _this : position array
		Return : array containing all positions in building
		*/
		PUBLIC FUNCTION("array", "getPositionsBuilding") {
			DEBUG(#, "OO_PATROL::getPositionsBuilding")
			private _positions = [];
			private _buildings = [];
			private _index = 0;
			
			if!(surfaceIsWater _this) then {
				_buildings = nearestObjects[_this,["House_F"], 50];
				sleep 0.5;			
				{
					_positions pushBack (_x buildingPos -1);
				}foreach _buildings;
			};
			_positions;
		};		


		PUBLIC FUNCTION("array", "getBuildings") {
			DEBUG(#, "OO_PATROL::getBuildings")
			private _position = _this;
			private _positions = MEMBER("getPositionsBuilding", _position);

			MEMBER("buildings", _positions);
			if(count _positions > 10) then {
				MEMBER("city", true);
			}else{
				MEMBER("city", false);
			};
		};

		PUBLIC FUNCTION("", "fireFlare") {
			DEBUG(#, "OO_PATROL::fireFlare")
			private _leader = leader MEMBER("group", nil);
			private _target = MEMBER("target", nil);

			if(_leader distance _target < 200) then {
				private _flare = "F_40mm_White" createvehicle ((_target) ModelToWorld [0,0,200]); 
				_flare setVelocity [0,0,-10];
			};
		};

		PUBLIC FUNCTION("", "engageTarget") {
			DEBUG(#, "OO_PATROL::engageTarget")
			private _target = MEMBER("target", nil);
			if(isNil "_target") exitWith {};

			private _isvehicle = !(_target isKindOf "MAN") ;
			private _isbuilding = if((nearestbuilding _target) distance _target < 10) then { true; } else { false; };
			private _isvisible = MEMBER("seeTarget", nil);
			private _needflare = if((date select 3 > 21) or (date select 3 <6)) then { true; } else {false;};

			if(_isvehicle) then {
				MEMBER("setMoveMode", nil);
				MEMBER("moveAround", 50);
				MEMBER("putMine", nil);
			} else {
				if(_isbuilding) then {
					//hint "movebuilding";
					if(_isvisible) then {
						MEMBER("doFire", nil);
					};
					MEMBER("setCombatMode", nil);
					//MEMBER("setMoveMode", nil);
					MEMBER("moveInto", nearestbuilding _target);
				} else {
					if((_needflare) and (random 1 > 0.5)) then { MEMBER("fireFlare", nil);};
					if(_isvisible) then {
						//hint format ["moveto %1", MEMBER("target", nil)];
						MEMBER("setCombatMode", nil);
						MEMBER("doFire", nil);
						MEMBER("moveToTarget", nil);
					} else {
						//hint format ["movearound %1", MEMBER("target", nil)];
						MEMBER("setCombatMode", nil);
						MEMBER("moveAround", 25);
					};
				};
			};
			if(random 1 > 0.9) then {
				MEMBER("callArtillery", MEMBER("target", nil));
			};
		};


		PUBLIC FUNCTION("", "getNextTarget") {
			DEBUG(#, "OO_PATROL::getNextTarget")		
			private _leader = leader MEMBER("group", nil);
			private _candidats = [];
			private _target = MEMBER("target", nil);
			private _oldtarget = objnull;
			private _array = [];
			private _index = 0;
			private _min = 100000;
			
			{
				_array = [_leader, _x];
				_index = floor (MEMBER("estimateTarget", _array));
				_candidats pushBack [_index, _x];
				sleep 0.0001;
			}foreach MEMBER("targets", nil);

			if(!isnil "_target") then {
				if(alive _target) then {
					_oldtarget = MEMBER("target", nil);
					_array = [_leader, _oldtarget];
					_index = floor (MEMBER("estimateTarget", _array));
					_candidats pushBack [_index, _oldtarget];
				};
			};

			{
				if((_x select 0) < _min) then {
					_target = _x select 1;
					_min = _x select 0;
				};
				sleep 0.0001;
			}foreach _candidats;

			if(_oldtarget != _target) then {
				MEMBER("target", _target);
				MEMBER("setFlank", nil);
			};
		};		

		PUBLIC FUNCTION("", "revealTarget") {
			DEBUG(#, "OO_PATROL::revealTarget")
			{
				leader MEMBER("group", nil) reveal [_x, 4];
				sleep 0.0001;
			}foreach units MEMBER("targets", nil);
		};		

		PUBLIC FUNCTION("array", "getTargets") {
			DEBUG(#, "OO_PATROL::getTargets")
			private _list = _this nearEntities [["Man"], 800];
			private _list2 = _this nearEntities [["Tank", "Air"], 800];
			sleep 1;
			{
				_list pushBack (crew _x);
				sleep 0.0001;
			}foreach _list2;

			sleep 0.5;
			{
				if(side _x != west) then {
					_list set [_foreachindex, -1];
				};
				sleep 0.0001;
			}foreach _list;
			_list = _list - [-1];
			MEMBER("targets", _list);
		};		

		PUBLIC FUNCTION("", "seeTarget") {
			DEBUG(#, "OO_PATROL::seeTarget")
			private _see = false;
			private _target =  MEMBER("target", nil);
			private _array = [];

			{
				if(alive _x) then {
					_array = [_x, _target];
					if(MEMBER("estimateTarget", _array) < 2) then {_see = true;};
				};
				sleep 0.0001;
			} foreach units MEMBER("group", nil);
			_see;
		};		

		PUBLIC FUNCTION("array", "estimateTarget") {		
			DEBUG(#, "OO_PATROL::estimateTarget")
			((_this select 0) getHideFrom (_this select 1)) distance (position (_this select 1));
		};

		PUBLIC FUNCTION("", "doFire") {
			DEBUG(#, "OO_PATROL::doFire")
			private _target = MEMBER("target", nil);
			private _skill = 0;
			{
				_skill = MEMBER("getSkill", (_x distance _target));
				_x setskill ["aimingAccuracy", _skill];
				_x setskill ["aimingShake", _skill];
				_x dotarget _target;
				_x dofire _target;
				_x setUnitPos "Middle";
				sleep 0.0001;
			}foreach units MEMBER("group", nil);
		};

		PUBLIC FUNCTION("scalar", "getSkill") {
			DEBUG(#, "OO_PATROL::getSkill")
			if(_this > 300) then {_this = 300};
			(wcskill * (1 - (_this / 300)));
		};

		// moveInto Buildings
		PUBLIC FUNCTION("object", "moveInto") {
			DEBUG(#, "OO_PATROL::moveInto")
			private _building = _this;
			private _positions = [];
			private _index = 0;

			while { format ["%1", _building buildingPos _index] != "[0,0,0]" } do {
				_positions pushBack (_building buildingPos _index);
				_index = _index + 1;
				sleep 0.0001;
			};

			{
				_x domove (selectRandom _positions);
				sleep 0.0001;
			}foreach units MEMBER("group", nil);
			sleep 30;
		};

		// move around target
		PUBLIC FUNCTION("", "moveToTarget") {
			DEBUG(#, "OO_PATROL::moveToTarget")
			private _position = position MEMBER("target", nil);
			MEMBER("moveTo", _position);
		};

		// move around target
		PUBLIC FUNCTION("scalar", "moveAround") {
			DEBUG(#, "OO_PATROL::moveAround")
			private _areasize = _this;
			private _target = MEMBER("target", nil);
			private _leader = leader MEMBER("group", nil);
			private _dir = [_leader, _target] call BIS_fnc_dirTo;

			_dir = _dir + MEMBER("flank", nil);
			if(_dir > 359) then {_dir = _dir - 360};
			if(_dir < 0) then {_dir = _dir + 360};

			private _position = [position _target, _areasize, _dir] call BIS_fnc_relPos;
			MEMBER("moveTo", _position);
		};

		// put mine
		PUBLIC FUNCTION("", "putMine") {
			DEBUG(#, "OO_PATROL::putMine")
			private _target = MEMBER("target", nil);
			private _leader = leader MEMBER("group", nil);

			if((_target distance _leader < 10) and (damage _target < 0.9)) then {
				createVehicle ["ATMine_Range_Ammo", position _target,[], 0, "can_collide"];
			};
		};		

		// moveTo position
		PUBLIC FUNCTION("array", "moveTo") {
			DEBUG(#, "OO_PATROL::moveTo")
			private _position = _this;
			private _group = MEMBER("group", nil);

			{
				_x domove _position;
				sleep 0.001;
			}foreach units _group;

			sleep 30;
		};		

		PUBLIC FUNCTION("", "isCompleteGroup") {
			DEBUG(#, "OO_PATROL::isCompleteGroup")
			private _count = MEMBER("sizegroup", nil);
			private _count2 = count units (MEMBER("group", nil));
			if( _count isEqualTo _count2) then { true; } else { false;};
		};

		PUBLIC FUNCTION("", "dropSmoke") {
			DEBUG(#, "OO_PATROL::dropSmoke")
			private _group = MEMBER("group", nil);
			private _round = ceil(random 3);
			private _smokeposition = [];
			private _smoke = "";

			for "_x" from 0 to _round step 1 do {
				_smokeposition = [position (leader _group), 2, random 359] call BIS_fnc_relPos;
				_smoke = createVehicle ["G_40mm_Smoke", _smokeposition, [], 0, "NONE"];
			};
		};

		PUBLIC FUNCTION("", "dropFlare") {
			DEBUG(#, "OO_PATROL::dropFlare")
			if((date select 3 < 4) or (date select 3 > 20)) then {

			};
		};		

		PUBLIC FUNCTION("", "setAlert") {
			DEBUG(#, "OO_PATROL::setAlert")
			MEMBER("alert", true);
		};

		PUBLIC FUNCTION("", "scanTargets") {
			DEBUG(#, "OO_PATROL::scanTargets")
			{
				if((leader MEMBER("group", nil)) knowsAbout _x > 0.40) then {
					MEMBER("setAlert", nil);
				};
				sleep 0.0001;
			}foreach MEMBER("targets", nil);
		};		

		// soldiers walk around the sector
		PUBLIC FUNCTION("scalar", "walk") {
			DEBUG(#, "OO_PATROL::walk")
			private _group = MEMBER("group", nil);
			private _leader = leader _group;
			private _areasize = _this;
			private _maxtime = 60;
			private _wp ="";
			private _counter = 0;

			MEMBER("setSafeMode", nil);
			
			private _formationtype = selectRandom ["COLUMN", "STAG COLUMN","WEDGE","ECH LEFT","ECH RIGHT","VEE","LINE","FILE","DIAMOND"];
			_group setFormation _formationtype;

			private _position = position _leader;
			
			while { (position _leader) distance _position < (_areasize/2.5) } do {
				_position = [_position, _areasize, random 359] call BIS_fnc_relPos;
				sleep 0.0001;
			};

			_wp = _group addWaypoint [_position, 10];
			_wp setWaypointPosition [_position, 10];
			_wp setWaypointType "GUARD";
			_wp setWaypointVisible true;
			_wp setWaypointSpeed "LIMITED";
			_wp setWaypointStatements ["true", "this setvariable ['complete', true]; false"];
			_group setCurrentWaypoint _wp;

			_counter = 0;
			while { _counter < _maxtime } do {
				_leader = leader _group;
				if(format["%1",  _leader getVariable "complete"] isEqualTo "true") then {
					_leader setvariable ['complete', false];
					_counter = _maxtime;
				};
				if(format["%1",  _leader getVariable "combat"] isEqualTo "true") then {
					if(random 1 > 0.8) then {MEMBER("dropSmoke", nil);};
					MEMBER("setAlert", nil);
					_counter = _maxtime;
				};
				MEMBER("scanTargets", nil);
				_counter = _counter + 1;
				sleep 1;
			};
			deletewaypoint _wp;
		};

		PUBLIC FUNCTION("", "walkInBuildings") {
			DEBUG(#, "OO_PATROL::walkInBuildings")
			private _group = MEMBER("group", nil);
			private _leader = leader _group;
			private _areasize = MEMBER("areasize", nil);
			private _maxtime = 300;
			private _counter = 0;

			MEMBER("setBuildingMode", nil);
			{
				_x domove (selectRandom MEMBER("buildings",nil));
				sleep 0.0001;
			}foreach units MEMBER("group", nil);

			while { _counter < _maxtime } do {
				_leader = leader _group;
				if(format["%1",  _leader getVariable "complete"] == "true") then {
					_leader setvariable ['complete', false];
					_counter = _maxtime;
				};
				if(format["%1",  _leader getVariable "combat"] == "true") then {
					if(random 1 > 0.8) then {MEMBER("dropSmoke", nil);};
					MEMBER("setAlert", nil);
					_counter = _maxtime;
				};
				MEMBER("scanTargets", nil);
				_counter = _counter + 1;
				sleep 1;
			};
		};		

		PUBLIC FUNCTION("", "setBuildingMode") {
			DEBUG(#, "OO_PATROL::setBuildingMode")
			MEMBER("group", nil) setBehaviour "SAFE";
			MEMBER("group", nil) setCombatMode "WHITE";
			MEMBER("group", nil) setSpeedMode "FULL";
			MEMBER("group", nil) allowFleeing 0.1;
		};

		PUBLIC FUNCTION("", "setMoveMode") {
			DEBUG(#, "OO_PATROL::setMoveMode")
			MEMBER("group", nil) setBehaviour "AWARE";
			MEMBER("group", nil) setCombatMode "RED";
			MEMBER("group", nil) setSpeedMode "FULL";
			MEMBER("group", nil) allowFleeing 0.1;
		};		

		PUBLIC FUNCTION("", "setSafeMode") {
			DEBUG(#, "OO_PATROL::setSafeMode")
			MEMBER("group", nil) setBehaviour "SAFE";
			MEMBER("group", nil) setCombatMode "GREEN";
			MEMBER("group", nil) setSpeedMode "NORMAL";
			MEMBER("group", nil) allowFleeing 0.1;
		};

		PUBLIC FUNCTION("", "setCombatMode") {
			DEBUG(#, "OO_PATROL::setCombatMode")
			MEMBER("group", nil) setBehaviour "COMBAT";
			MEMBER("group", nil) setCombatMode "RED";
			MEMBER("group", nil) setSpeedMode "FULL";
			MEMBER("group", nil) allowFleeing 0.1;
		};

		PUBLIC FUNCTION("","deconstructor") { 
			DEBUG(#, "OO_PATROL::deconstructor")
			DELETE_VARIABLE("alert");
			DELETE_VARIABLE("around");
			DELETE_VARIABLE("areasize");
			DELETE_VARIABLE("sizegroup");
			DELETE_VARIABLE("group");
			DELETE_VARIABLE("target");
			DELETE_VARIABLE("targets");
			DELETE_VARIABLE("buildings");
			DELETE_VARIABLE("city");
			DELETE_VARIABLE("flank");
		};
	ENDCLASS;