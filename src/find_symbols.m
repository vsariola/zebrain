function symbols = find_symbols(code,extrasymbols,extrareserved)
    if nargin < 2
        extrasymbols = {};
    end
    if nargin < 3
        extrareserved = {};
    end
    tokens = regexp(code,'([;\n]|for)\s*(\w+|(\[\s*\w+(\s*,\s*\w+)*\s*\]))\s*=','tokens');
    t2 = {};
    for i = 1:length(tokens)
        m = tokens{i}{2};
        if m(1) == '['
            m2 = regexp(m, '\w+', 'match');
            t2 = [t2 m2];
        else
            t2 = [t2 m];
        end
    end
    t2 = [t2 extrasymbols];
    reserved = [{'if','else','elseif','end','for','function','(',')'},extrareserved];
    t2 = t2(~ismember(t2,reserved));
    t2 = unique(t2);
    symbols = t2;
end