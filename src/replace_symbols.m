function code = replace_symbols(code,symbols,new_symbols)
    code = [' ' code]; % Add whitespace because the regexp doesn't work on first line otherwise.
    for i = 1:length(symbols)
        pattern = ['(\W+)' symbols{i} '(?=\W)'];
        c = ['$1symbol' new_symbols{i}];
        code = regexprep(code,pattern,c);
    end
    code = regexprep(code,'(\W+)symbol(\w+)(?=\W)','$1$2');   
    code = strtrim(code);
end