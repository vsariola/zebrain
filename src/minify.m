function ret = minify(code)    
    code = regexprep(code,'(\W+)symbol(\w+)(?=\W)','$1$2');
    code = regexprep(code,'([^%]+)[^\n]*','$1\n');
    code = regexprep(code,'\n',';');
    code = regexprep(code,'\s+',' ');
    for i = 1:3
        code = regexprep(code,'(\W)\s(\W)','$1$2');    
        code = regexprep(code,'(\w)\s(\W)','$1$2');    
        code = regexprep(code,'(\W)\s(\w)','$1$2');        
    end
    code = regexprep(code,';+',';');
    code = regexprep(code,'end;function','end\nfunction');    
    code = code(1:(end-1));
    ret = code;
end