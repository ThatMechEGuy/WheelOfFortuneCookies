function [TF,valInRange] = isInAngRange(angVals,checkVals,opts)
    % DESCRIPTION
    % Checks if values are within a specified angular range.
    % 
    % NOTE: This method is based off of the method presented in the link below [1]. The only
    % modifications were to make the function work with negative check angles and angular values
    % with a magnitude greater than one revolution.
    % 
    % SYNTAX
    % isInAngRange(angVals,checkVals)
    % isInAngRange(___,Name,Value)
    % [TF,valInRange] = isInAngRange(___)
    % 
    % REQUIRED ARGUMENTS
    % angVals  : Limits of angular range. Must have 2 columns, where the first column is the lower
    %            magnitude of the two values. Can have multiple rows.
    % checkVals: Value(s) being checked. Muse be a row or column vector.
    % 
    % NAME-VALUE PAIRS
    % inputInDegrees : true if values are input in degrees, false if values are input in radians.
    %                  (default = false)
    % outputInDegrees: true if values are output in degrees, false if values are output in radians.
    %                  (default = false)
    % 
    % OUTPUT VARIABLES
    % TF        : Result of check. True if the check value is within the angular range.
    % valInRange: Value of the check value(s) adjusted to be within the angular range.
    % 
    % SUPPORTING DOCUMENTS (WRITE-UPS, WEBSITES, ETC.)
    % [1] https://math.stackexchange.com/questions/1044905/simple-angle-between-two-angles-of-circle
    % 
    % CREATED WITH: MATLAB R2021b (Update 0)
    % 
    % CHANGELOG
    %{
    ================   20 JUL 2022   ================
    Nate Fulbright

    -Initial release.
    =================================================
    %}
    % HEADER VERSION: 10 JUN 2022
    
    arguments
        angVals (:,2) double {mustBeReal,mustBeFinite}
        checkVals (:,1) double {mustBeReal,mustBeFinite}
        opts.inputInDegrees (1,1) logical = false
        opts.outputInDegrees (1,1) logical = false
    end
    
    % Convert the inputs to radians.
    if opts.inputInDegrees
        angValsRad = deg2rad(angVals);
        checkValsRad = deg2rad(checkVals);
    else
        angValsRad = angVals;
        checkValsRad = checkVals;
    end
    
    % Subtract the lower bound from all values.
    angValsRad(:,2) = angValsRad(:,2) - angValsRad(:,1);
    checkValsRad = checkValsRad - angValsRad(:,1);
    % For any values that are below zero or above 2*pi, make them between 0 and 2*pi.
    angValsRad(:,2) = wrapTo2Pi(angValsRad(:,2));
    checkValsRad = wrapTo2Pi(checkValsRad);
    
    % The value is within the range if the modified check value is less than or equal to the
    % modified end angle values.
    TF = checkValsRad <= angValsRad(:,2);
    % Return the check values so they are adjusted to be within the angular range of values
    % being checked.
    valInRangeRad = checkValsRad + angValsRad(:,1);

    % Convert the output to the desired units.
    if opts.outputInDegrees
        valInRange = rad3deg(valInRangeRad);
    else
        valInRange = valInRangeRad;
    end
end