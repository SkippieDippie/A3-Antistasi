params ["_marker", "_unitCount", ["_vehicle", objNull]];

if(!(isNull _vehicle) && {(random 100) < (7.5 * tierWar)}) exitWith
{
    _vehicle lock 0;
    -1;
};

_fn_createLinePosition =
{
    params ["_startPos", "_dir", "_units"];

    private _result = [[_startPos, _dir]];
    private _subCounter = 0;
    private _distance = 3;
    private _position = [];
    for "_i" from 2 to _units do
    {
        _subCounter = _subCounter + 1;
        if(_subCounter > 3) then
        {
            _distance = _distance + 1;
            _subCounter = 1;
        };
        if(_subCounter == 1) then
        {
            _position = [_startPos, _distance, _dir] call BIS_fnc_relPos;
            _result pushBack [_position, _dir - 180];
        };
        if(_subCounter == 2) then
        {
            _position = [_startPos, _distance, _dir] call BIS_fnc_relPos;
            _position = [_position, 1, _dir + 90] call BIS_fnc_relPos;
            _result pushBack [_position, _dir - 180];
        };
        if(_subCounter == 3) then
        {
            _position = [_startPos, _distance, _dir] call BIS_fnc_relPos;
            _position = [_position, 1, _dir - 90] call BIS_fnc_relPos;
            _result pushBack [_position, _dir - 180];
        };
    };

    _result;
};


private _placements = [];
if(_unitCount < 3) then
{
    if(isNull _vehicle) then
    {
        //Not searching for a special place for small groups
        private _startParams = [_marker, "Vehicle"] call A3A_fnc_findSpawnPosition;
        if(_startParams isEqualType -1) then
        {
            _placements = -1;
        }
        else
        {
            _placements = [_startParams select 0, _startParams select 1, _unitCount] call _fn_createLinePosition;
        };
    }
    else
    {
        private _vehicleDir = getDir _vehicle;
        private _startPos = [getPos _vehicle, 5, _vehicleDir - 30] call BIS_fnc_relPos;
        _placements = [_startPos, _vehicleDir + 90, _unitCount] call _fn_createLinePosition;
    };
}
else
{
    private _building = objNull;
    if(_unitCount <= 4) then
    {
        _building = [_marker, "Group"] call A3A_fnc_findSpawnPosition;
    }
    else
    {
        _building = [_marker, "Squad"] call A3A_fnc_findSpawnPosition;
    };
    if(_building isEqualType -1) then
    {
        //No building found, try placing them in a vehicle slot
        private _startParams = [_marker, "Vehicle"] call A3A_fnc_findSpawnPosition;
        if(_startParams isEqualType -1) then
        {
            _placements = -1;
        }
        else
        {
            _placements = [_startParams select 0, _startParams select 1, _unitCount] call _fn_createLinePosition;
        };
    }
    else
    {
        //Building found
        _building = _building select 0;
        private _buildingPos = _building buildingPos -1;
        private _selected = [];
        for "_i" from 1 to _unitCount do
        {
            _selected = selectRandom _buildingPos;
            _placements pushBack [_selected, random 360];
            _buildingPos = _buildingPos - [_selected];
        };
    };
};

_placements;