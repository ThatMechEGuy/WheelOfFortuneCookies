classdef restaurant < handle & uniqueIDobj
    %% Properties -- general
    properties (SetObservable = true)
        UserData
    end
    
    %% Properties -- info
    properties (SetObservable = true)
        name (1,1) string {mustBeNonzeroLengthText} = "New restaurant"

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
                opts.name = ""
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