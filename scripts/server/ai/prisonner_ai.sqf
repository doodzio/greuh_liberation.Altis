params [ "_unit" ];
private [ "_nearestfob", "_is_near_fob", "_is_near_blufor", "_grp", "_waypoint" ];
_is_near_fob = false;
_is_near_blufor = true;

if ( (_unit isKindOf "Man") && ( alive _unit ) && ((side _unit == EAST) || (side _unit == RESISTANCE)) ) then {

	if ( vehicle _unit != _unit ) then { deleteVehicle _unit };

	sleep (random 5);

	if ( alive _unit ) then {

		removeAllWeapons _unit;
		removeHeadgear _unit;
		removeBackpack _unit;
		_unit unassignItem "NVGoggles_OPFOR";
		_unit removeItem "NVGoggles_OPFOR";
		_unit unassignItem "NVGoggles_INDEP";
		_unit removeItem "NVGoggles_INDEP";
		_unit setUnitPos "UP";
		sleep 1;
		_unit disableAI "ANIM";
		_unit disableAI "MOVE";
		_unit playmove "AmovPercMstpSnonWnonDnon_AmovPercMstpSsurWnonDnon" ;
		sleep 2;
		_unit setCaptive true;

		waitUntil { sleep 1;
			!alive _unit || side group _unit == WEST
		};

		if ( alive _unit ) then {

			_unit playmove "AmovPercMstpSsurWnonDnon_AmovPercMstpSnonWnonDnon";
			sleep 2;
			_unit enableAI "ANIM";
			_unit enableAI "MOVE";
			_unit setCaptive false;

			waitUntil { sleep 2;

				_nearestfob = [ getpos _unit ] call F_getNearestFob;
				if ( count _nearestfob == 3) then {
					if ( ( _unit distance _nearestfob ) < 20 ) then {
						_is_near_fob = true;
					};
				};

				if ( [ getpos _unit, 150 , WEST ] call F_getUnitsCount == { ( typeof _x ) in ( all_ofpor_troops + all_resistance_troops ) } count (units group _unit) ) then {
					_is_near_blufor = false;
				};

				!alive _unit || !(_is_near_blufor) || (_is_near_fob && (vehicle _unit == _unit))
			};

			if (alive _unit) then {

				if ( _is_near_fob ) then {

					[_unit] joinSilent (createGroup WEST);
					_unit playmove "AmovPercMstpSnonWnonDnon_AmovPsitMstpSnonWnonDnon_ground";
					_unit disableAI "ANIM";
					_unit disableAI "MOVE";
					sleep 5;
					_unit switchmove "AidlPsitMstpSnonWnonDnon_ground00";
					removeVest _unit;

					[ [_unit] , "prisonner_remote_call" ] call BIS_fnc_MP;
					sleep 600;
					deleteVehicle _unit;

				} else {

					_unit setUnitPos "AUTO";
					[_unit] joinSilent (createGroup EAST);
					_grp = group _unit;

					while {(count (waypoints _grp)) != 0} do {deleteWaypoint ((waypoints _grp) select 0);};
					{_x doFollow leader _grp} foreach units _grp;

					_possible_sectors = (sectors_allSectors - blufor_sectors);
					if ( count _possible_sectors > 0 ) then {

						_possible_sectors = [ _possible_sectors , [getpos _unit, 5000] , { (markerPos _x) distance _input0 } , 'ASCEND' ] call BIS_fnc_sortBy;
						if ( count _possible_sectors > 0 ) then {
							_target_sector = _possible_sectors select 0;
							_waypoint = _grp addWaypoint [markerpos _target_sector, 300];
							_waypoint setWaypointType "MOVE";
							_waypoint setWaypointSpeed "FULL";
						};
					};
				};
			};
		};
	};
};