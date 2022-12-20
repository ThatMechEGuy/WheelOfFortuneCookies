classdef (Abstract) uniqueIDobj < handle
    %% Properties
    properties (SetAccess = immutable, Hidden)
        % Unique identifer.
        uniqueID (1,1) double {mustBeReal,mustBeFinite}
    end

    %% Methods -- constructor/destructor
    methods
        function obj = uniqueIDobj(opts)
            % DESCRIPTION
            % Constructor for uniqueIDobj object.
            % 
            % SYNTAX
            % uniqueIDobj
            % uniqueIDobj(___,Name,Value)
            % obj = uniqueIDobj(___)
            %
            % NAME-VALUE PAIRS
            % uniqueID: Unique ID for the new object. Recommended to be a number between 0 and 1,
            %           inclusive, but can be any real, finite number. (default = rand)
            % 
            % OUTPUT VARIABLES
            % obj: Initialized uniqueIDobj object.

            arguments
                opts.uniqueID double {mustBeScalarOrEmpty} = []
            end

            % Reseed the random number generator. This makes it so random numbers to generate unique
            % IDs will always be unique, even after restarting MATLAB.
            rng('shuffle');

            % Create a unique ID if one wasn't specified.
            if isempty(opts.uniqueID)
                obj.uniqueID = rand;
            else
                obj.uniqueID = opts.uniqueID;
            end
        end
    end

    %% Methods -- overloaded operators
    methods
        function TF = eq(Obj1,Obj2)
            % DESCRIPTTION
            % Overloaded "==" operator for uniqueIDobj objects. Checks if two custom objects are the
            % same object. To be considered the same object, both objects must have the same
            % uniqueID and be of the same class.
            % 
            % SYNTAX
            % Obj1 == Obj2
            % eq(Obj1,Obj2)
            % Obj1.eq(Obj2)
            % TF = eq(___)
            % 
            % REQUIRED ARGUMENTS
            % Obj1     : Handle(s) of first object. Can be a scalar, vector, or array.
            % Obj2     : Handle(s) of second object. Can be a scalar, vector, or array.
            %
            % OUTPUT VARIABLES
            % TF: Logical array of the same size as the largest input indicating if the objects are
            %     equal.
            
            arguments
                Obj1
                Obj2
            end

            % If either input is empty, the MATLAB behavior is to return an empty logical array.
            % Recreate that behavior here and stop execution early.
            if isempty(Obj1) || isempty(Obj2)
                TF = false(0);
                return
            end
            
            % If at least one input is scalar, the comparisons can be done regardless of the size
            % of the other input. If neither input is scalar, some checks on the sizes of the
            % inputs must be performed.
            if ~(isscalar(Obj1) || isscalar(Obj2))
                % Make sure the arrays have the same number of dimensions (i.e., 2D vs. 3D).
                if numel(size(Obj1)) ~= numel(size(Obj2))
                    throwAsCaller(MException('uniqueIDobj:arrayDimensionMismatch',...
                        ['The two object arrays must have the same number of dimensions.\n\n',...
                        'Obj1 number of dimensions = %i, Obj2 number of dimensions = %i'],...
                        numel(size(Obj1)),numel(size(Obj2))))
                end
    
                % Make sure the arrays have the same size in all dimensions.
                if any(size(Obj1) ~= size(Obj2),'all')
                    % Build up strings with the array sizes.
                    sizeObj1Str = ['[',num2str(size(Obj1)),']'];
                    sizeObj2Str = ['[',num2str(size(Obj2)),']'];

                    throwAsCaller(MException('uniqueIDobj:arraySizeMismatch',...
                        ['The two object arrays must have the same size.\n\n',...
                        'Obj1 size = %s, Obj2 size = %s'],sizeObj1Str,sizeObj2Str))
                end
            end

            % Size the output array to have the same size as the largest output. This logic takes
            % advantage of the fact that if one of the inputs is non-scalar, the either input must
            % either be scalar or have the same size as the first input.
            if ~isscalar(Obj1)
                TF = false(size(Obj1));
            elseif ~isscalar(Obj2)
                TF = false(size(Obj2));
            else
                TF = false;
            end

            % To make this function more robust to varying input types, there is no assertion that
            % the inputs have to be uniqueIDobj objects. Instead, if either object is not a
            % uniqueIDobj object, simply stop the execution before actually doing the logical
            % comparison because it is impossible to be equal to objects of a different type (for
            % uniqueIDobj objects at least).
            if ~isa(Obj1,'uniqueIDobj') || ~isa(Obj2,'uniqueIDobj')
                return
            end

            % Only do the comparison if the objects being compared are of the same class (because
            % uniqueIDObj is an abstract superclass, it is possible for two different classes that
            % are derived from this class to reach this point of the comparison).
            if strcmp(class(Obj1),class(Obj2))
                % Deleted objects will not have the required uniqueID property (or any property).
                % Find the indices that correspond to non-deleted properties in both object arrays
                % and use these for the logical comparison.
                nonDeletedInds = find(isprop(Obj1,'uniqueID') & isprop(Obj2,'uniqueID'));
                
                % Compare! Make sure that the indices being used for the logical comparisons are
                % valid for each array. For example, consider a scalar object being compared with a
                % 1x3 object. The non-deleted indices would be [1 2 3]. The scalar object can only
                % be indexed up to 1, so its non-deleted indices would become [1 1 1]. The logic
                % below could be replaced with "if" statements, but I like this method better --
                % it's cleaner.
                TF(nonDeletedInds) = [Obj1(min(nonDeletedInds,numel(Obj1))).uniqueID] ==...
                    [Obj2(min(nonDeletedInds,numel(Obj2))).uniqueID];
            end
        end
    end
end