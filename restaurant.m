classdef restaurant < handle & uniqueIDobj
    %% Properties -- general
    properties (SetObservable = true)
        UserData
    end

    properties (Access = private, Constant)
        allowedLogoFileTypes = [".png",".bmp",".jpg",".jpeg"]
    end
    
    %% Properties -- info
    properties (SetObservable = true)
        name (1,1) string

        logoImageFilename (1,1) string
    end

    %% Proeprties -- voting
    properties (Transient, SetObservable = true, SetAccess = private)
        nVotes (1,1) double = 0
    end

    properties (Transient, SetObservable = true)
        nVotesTemp (1,1) double {mustBeInteger} = 0
    end

    %% Methods -- constructor/destructor
    methods
        function obj = restaurant(opts)
            arguments
                opts.name = "New restaurant"
                opts.logoImageFilename = ""
            end

            % Store the user-defined properties.
            obj.name = opts.name;
            obj.logoImageFilename = opts.logoImageFilename;
        end
    end

    %% Methods -- set/get
    methods
        function set.nVotes(obj,newVal)
            obj.nVotes = max(newVal,0);
        end

        function set.logoImageFilename(obj,newVal)
            newVal = strtrim(newVal);
            if newVal == ""
                return
            end
            [~,~,ext] = fileparts(newVal);

            if ~ismember(ext,obj.allowedLogoFileTypes)
                error("restaurant:invalidLogoImageFileType",...
                "The logo image file extension ""%s"" is not allowed. The allowed extensions "+...
                "are:\n%s",ext,makeBulletedList(obj.allowedLogoFileTypes))
            end

            obj.logoImageFilename = newVal;
        end

        function set.name(obj,newVal)
            obj.name = strtrim(newVal);
        end
    end

    %% Methods -- voting
    methods
        function addVote(obj,nVotesAdd)
            arguments
                obj (1,1) restaurant
                nVotesAdd (1,1) double {mustBeInteger,mustBePositive} = 1
            end

            obj.nVotes = obj.nVotes + nVotesAdd;
        end

        function removeVote(obj,nVotesRemove)
            arguments
                obj (1,1) restaurant
                nVotesRemove (1,1) double {mustBeInteger,mustBePositive} = 1
            end

            obj.nVotes = obj.nVotes - nVotesRemove;
        end

        function countTempVotes(obj)
            obj.nVotes = obj.nVotes + obj.nVotesTemp;
            obj.nVotesTemp = 0;
        end

        function resetVotes(obj,opts)
            arguments
                obj
                opts.tempVotesOnly (1,1) logical = false
            end

            if ~opts.tempVotesOnly
                obj.nVotes = 0;
            end

            obj.nVotesTemp = 0;
        end
    end
end