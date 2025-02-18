function path = installationLocation
    % Returns the "installation" locaiton of the tool. The tool is not installed, but rather run
    % from a specific folder. The output of this funciton is the folder where all of the tool's
    % files are stored.
    %
    % This function is useful for finding/storing files in the tool's folder without needed to rely
    % on relative paths.
    % 
    % ━━━━  SYNTAX  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % path = installationLocation
    % 
    % ━━━━  OUTPUTS  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % path (string scalar)
    %    Path where the tool is located. For example, "C:\MyFolder\Tool".
    % 
    % ━━━━  MISCELLANEOUS  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % CREATED WITH  : MATLAB R2023b (Update 9)
    % HEADER VERSION: 2023.50

    arguments (Output)
        path (1,1) string
    end

    executionLocation = string(mfilename("fullpath"));
    path = executionLocation.extractBefore(...
        filesep + fullfile("+WheelOfFortuneCookies","+HelperFunctions"));
end