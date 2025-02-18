classdef Restaurant < handle
    %% Properties -- general
    properties (SetObservable = true, AbortSet = true)
        UserData
    end

    properties (Access = private, Constant)
        ALLOWED_LOGO_FILE_TYPES (1,:) string = [".png",".bmp",".jpg",".jpeg"]
    end
    
    %% Properties -- info
    properties (SetAccess = private)
        logoImage (:,:,3) uint8
    end

    properties (SetObservable = true, AbortSet = true)
        name (1,1) string {mustBeNonzeroLengthText} = "New Restaurant"
    end

    %% Proeprties -- voting
    properties (Transient, SetObservable = true, AbortSet = true, SetAccess = private)
        nVotes (1,1) double {mustBeInteger,mustBeNonnegative} = 0
    end

    properties (Transient, SetObservable = true)
        nVotesTemp (1,1) double {mustBeInteger,mustBeNonnegative} = 0
    end

    %% Methods -- constructor/destructor
    methods
        function obj = Restaurant(options)
            arguments (Input)
                options.name (1,1) string {mustBeNonzeroLengthText} = "New Restaurant"
                options.logoImageFilename string {mustBeScalarOrEmpty,mustBeNonzeroLengthText} = ...
                    string.empty
            end

            arguments (Output)
                obj (1,1) WheelOfFortuneCookies.Restaurant.Restaurant
            end

            obj.name = options.name;
            
            obj.loadLogoImage(options.logoImageFilename);
        end
    end

    %% Methods -- set/get
    methods
        % ━━━━━━━━━━━━━━━━━━━━━━━━  nVotes  ━━━━━━━━━━━━━━━━━━━━━━━━
        function set.nVotes(obj,newVal)
            obj.nVotes = max(newVal,0);
        end
        % ━━━━━━━━━━━━━━━━━━━━━━━━  nVotes  ━━━━━━━━━━━━━━━━━━━━━━━━

        % ━━━━━━━━━━━━━━━━━━━━━━━━━  name  ━━━━━━━━━━━━━━━━━━━━━━━━━
        function set.name(obj,newVal)
            obj.name = strtrim(newVal);
        end
        % ━━━━━━━━━━━━━━━━━━━━━━━━━  name  ━━━━━━━━━━━━━━━━━━━━━━━━━
    end

    %% Methods -- logo image
    methods
        function loadLogoImage(obj,logoImageFileName)
            arguments (Input)
                obj (1,1) WheelOfFortuneCookies.Restaurant.Restaurant
                logoImageFileName string {mustBeScalarOrEmpty,mustBeNonzeroLengthText}
            end

            if isempty(logoImageFileName)
                return
            end

            obj.logoImage = imread(logoImageFileName);
        end
    end

    %% Methods -- voting
    methods
        function addVote(obj,nVotesToAdd)
            arguments (Input)
                obj (1,1) WheelOfFortuneCookies.Restaurant.Restaurant
                nVotesToAdd (1,1) double {mustBeInteger,mustBePositive} = 1
            end

            obj.nVotes = obj.nVotes + nVotesToAdd;
        end

        function removeVote(obj,nVotesToRemove)
            arguments (Input)
                obj (1,1) WheelOfFortuneCookies.Restaurant.Restaurant
                nVotesToRemove (1,1) double {mustBeInteger,mustBePositive} = 1
            end

            obj.nVotes = obj.nVotes - nVotesToRemove;
        end

        function countTempVotes(obj)
            arguments (Input)
                obj (1,1) WheelOfFortuneCookies.Restaurant.Restaurant
            end

            obj.nVotes = obj.nVotes + obj.nVotesTemp;
            obj.nVotesTemp = 0;
        end

        function resetVotes(obj,options)
            arguments
                obj (1,1) WheelOfFortuneCookies.Restaurant.Restaurant
                options.resetTempVotesOnly (1,1) logical = false
            end

            if ~options.resetTempVotesOnly
                obj.nVotes = 0;
            end

            obj.nVotesTemp = 0;
        end
    end
end