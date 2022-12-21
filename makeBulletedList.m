function bulletedList = makeBulletedList(list,prefix)
    arguments
        list {mustBeA(list,["string","cell"])}
        prefix (1,1) string = "• "
    end

    % This will automatically convert cell array to string array
    listWithPrefix = strcat("\n",prefix,list);
    bulletedList = sprintf(strjoin(listWithPrefix,""));
    % Remove the leading newline.
    bulletedList = eraseBetween(bulletedList,1,1);

    % Cell array of character vectors, so output should also be cell array.
    if iscell(list)
        bulletedList = char(bulletedList);
    end
end