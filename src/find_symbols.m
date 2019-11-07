function [symbols,new_symbols] = find_symbols(code,extrasymbols,extrareserved,offset)
    if nargin < 2
        extrasymbols = {};
    end
    if nargin < 3
        extrareserved = {};
    end
    if nargin < 4
        offset = 0;
    end
    tokens = regexp(code,'([;\n]|for)\s*(\w+|(\[\s*(\w+|~)(\s*,\s*(\w+|~))*\s*\]))\s*=','tokens');
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
    new_symbols = arrayfun(@get_symbol_for_num,(1:length(symbols))+offset,'UniformOutput',false);        
end


function ret = get_symbol_for_num(i)
    valids = [char(97:122) char(65:88)]; % a-z A-X, the variable
    % has to start with a letter. We don't need underscores and digits
    % because they can only be used when there is two or more letters
    % and if we hit two letters, it's unlikely we hit three
    
    n = length(valids);        
    ret = [];
    for j = 1:10
        if (i <= n)            
            ret = [valids(i) ret];    
            return;
        else
            c = mod(i-1,n);
            ret = [valids(c+1) ret];        
            i = (i -1- c)/n;               
        end
    end
end