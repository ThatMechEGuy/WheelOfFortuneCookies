classdef restaurant < handle
    %% Properties -- general
    properties (SetObservable = true)
        UserData
    end
    
    %% Properties -- info
    properties (SetAccess = immutable)
        name (1,1) string

        logoImageFilename (1,1) string
    end

    %% Proeprties -- voting
    properties (SetObservable = true, SetAccess = private)
        nVotes (1,1) double = 0
    end

    properties (SetObservable = true)
        nVotesTemp (1,1) double {mustBeInteger} = 0
    end

    %% Methods -- constructor/destructor
    methods
        function obj = restaurant(opts)
            arguments
                opts.name = ""
            end

            % Store the user-defined properties.
            obj.name = opts.name;
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