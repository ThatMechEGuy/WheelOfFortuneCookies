function restaurants = loadFromFile(fileName)
    arguments (Input)
        fileName (1,1) string
    end

    arguments (Output)
        restaurants (1,:) WheelOfFortuneCookies.Restaurant.Restaurant
    end

    S = load(fileName);

    restaurants = WheelOfFortuneCookies.Restaurant.Restaurant.empty;

    fieldNames = string(fieldnames(S)).';
    for fieldName = fieldNames
        fieldValue = S.(fieldName);
        if isa(fieldValue,"WheelOfFortuneCookies.Restaurant.Restaurant")
            % We don't know how many restaurants will be there ahead of time. There also won't be
            % enough for the small speed penalty to be noticeable.
            restaurants = [restaurants,fieldValue(:)]; %#ok<AGROW>
        end
    end
end