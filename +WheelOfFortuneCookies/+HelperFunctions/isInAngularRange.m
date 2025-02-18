function [isInRange,valueInRange] = isInAngularRange(angularRange,valuesToCheck,options)
    % Checks if values are within a specified angular range.
    % 
    % ━━━━  SYNTAX  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % isInAngularRange(angularRange,valuesToCheck)
    % isInAngularRange(___,Name,Value)
    % [isInRange,valueInRange] = isInAngularRange(___)
    % 
    % ━━━━  REQUIRED INPUTS  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % angularRange ((:,2) double)
    %    Limits of angular range. Must have 2 columns, where the first column is the lower magnitude
    %    of the two values. Each row is treated as a separate angular range. If the value is within
    %    any of the angular ranges, the output of this function will be true.
    % 
    %    The following validation functions also apply:
    %       • mustBeReal
    %       • mustBeFinite
    % ──────────────────────────────────────────────────────────────────────────────────────────────
    % valuesToCheck (double vector)
    %    Value(s) being checked.
    % 
    %    The following validation functions also apply:
    %       • mustBeReal
    %       • mustBeFinite
    % 
    % ━━━━  NAME-VALUE PAIR INPUTS (OPTIONAL)  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % inputInDegrees = false (logical scalar: true | false)
    %    When true, values are input in degrees. When false, values are input in radians.
    % ──────────────────────────────────────────────────────────────────────────────────────────────
    % outputInDegrees = false (logical scalar: true | false)
    %    When true, values are output in degrees. When false, values are output in radians.
    % 
    % ━━━━  OUTPUTS  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % isInRange (logical vector)
    %    Result of check. True if the check value is within the angular range.
    % ──────────────────────────────────────────────────────────────────────────────────────────────
    % valueInRange (double vector)
    %    Value of the check value(s) adjusted to be within the angular range.
    % 
    % ━━━━  MISCELLANEOUS  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % CREATED WITH  : MATLAB R2023b (Update 9)
    % HEADER VERSION: 2023.50
    
    arguments (Input)
        angularRange (:,2) double {mustBeReal,mustBeFinite}
        valuesToCheck (:,1) double {mustBeReal,mustBeFinite}
        options.inputInDegrees (1,1) logical = false
        options.outputInDegrees (1,1) logical = false
    end

    arguments (Output)
        isInRange (:,1) logical
        valueInRange (:,1) double
    end
    
    % Convert the inputs to radians.
    if options.inputInDegrees
        angularRange_rad = deg2rad(angularRange);
        valuesToCheck_rad = deg2rad(valuesToCheck);
    else
        angularRange_rad = angularRange;
        valuesToCheck_rad = valuesToCheck;
    end
    
    % Subtract the lower bound from all values.
    angularRange_rad(:,2) = angularRange_rad(:,2) - angularRange_rad(:,1);
    valuesToCheck_rad = valuesToCheck_rad - angularRange_rad(:,1);
    % For any values that are below zero or above 2*pi, make them between 0 and 2*pi.
    angularRange_rad(:,2) = wrapTo2Pi(angularRange_rad(:,2));
    valuesToCheck_rad = wrapTo2Pi(valuesToCheck_rad);
    
    % The value is within the range if the modified check value is less than or equal to the
    % modified end angle values.
    isInRange = valuesToCheck_rad <= angularRange_rad(:,2);
    % Return the check values so they are adjusted to be within the angular range of values
    % being checked.
    valueInRange_rad = valuesToCheck_rad + angularRange_rad(:,1);

    % Convert the output to the desired units.
    if options.outputInDegrees
        valueInRange = rad2deg(valueInRange_rad);
    else
        valueInRange = valueInRange_rad;
    end
end