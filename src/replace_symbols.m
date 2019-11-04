function code = replace_symbols(code,symbols,newsymbols)
    for i = 1:length(symbols)
        pattern = ['(\W+)' symbols{i} '(?=\W)'];
        c = ['$1symbol' newsymbols{i}];
        code = regexprep(code,pattern,c);
    end
end