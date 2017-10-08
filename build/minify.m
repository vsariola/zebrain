function ret = minify(code,extrasymbols)
    tokens = regexp(code,'[;\n]\s*(\w+)[^=\n]*=','tokens');
    t2 = cell(1,length(tokens));
    for i = 1:length(tokens)
        t2{i} = tokens{i}{1};
    end
    t2 = unique(t2);
    reserved = {'if','else','elseif','end','for','function','(',')'};
    t2 = t2(~ismember(t2,reserved));
    t2 = [t2 extrasymbols];
    for i = 1:length(t2)
        pattern = ['(\W+)' t2{i} '(?=\W)'];
        c = ['$1' getcode(i)];
        code = regexprep(code,pattern,c);
    end
    ret = code;
end

function ret = getcode(i)
    minor = i;
    major = floor((minor-1)/26+1);
    minor = mod(minor-1,26)+1;
    ret = char(64+minor);
    if (major > 1)
        ret = [char(63+major) ret];
    end
end