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

		PRIVATE VARIABLE("object","unit");
		PRIVATE VARIABLE("object","target");

		PUBLIC FUNCTION("array","constructor") {
			MEMBER("unit", _this select 0);
		};

		PUBLIC FUNCTION("array", "SetTarget") {
			MEMBER("target", _this select 0);
			MEMBER("unit", nil) dotarget (_this select 0);
			MEMBER("unit", nil) dofire (_this select 0);
		};

		PUBLIC FUNCTION("array", "SeeTarget") {
			private ["_target", "_position"];

			_target = _this select 0;

			_position = MEMBER("unit", nil) getHideFrom _target;
			if(_position distance _target < 4) then {
				true;
			} else {
				false;
			};
		};

		PUBLIC FUNCTION("array", "Move") {
			MEMBER("unit", nil) domove (_this select 0);
		};

		PUBLIC FUNCTION("", "IsMoving") {
			private ["_oldposition", "_newposition"];

			_oldposition = position MEMBER("unit", nil);
			sleep 1;
			_newposition = position MEMBER("unit", nil);

			if(format["%1", _oldposition] == format["%1", _newposition]) then {
				false;
			} else {
				true;
			};
		};

		PUBLIC FUNCTION("", "IsCover") {
			isHidden MEMBER("unit", nil);
		};


		PUBLIC FUNCTION("","deconstructor") { 
			DELETE_VARIABLE("target");
			DELETE_VARIABLE("unit");
		};
	ENDCLASS;