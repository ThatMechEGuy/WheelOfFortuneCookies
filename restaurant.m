classdef restaurant < handle
    %% Properties -- info
    properties (SetAccess = immutable)
        name (1,1) string
    end

    %% Proeprties -- voting
    properties (SetObservable = true, SetAccess = private)
        nVotes (1,1) double = 0
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

        function obj.removeVote(obj,nVotesRemove)
            arguments
                obj (1,1) restaurant
                nVotesRemove (1,1) double {mustBeInteger,mustBePositive} = 1
            end

            obj.nVotes = obj.nVotes - nVotesRemove;
        end
    end
end