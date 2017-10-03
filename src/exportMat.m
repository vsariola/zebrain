% Copyright: (c) 2017 Veikko Sariola
%
% This software is provided 'as-is', without any express or implied
% warranty. In no event will the authors be held liable for any damages
% arising from the use of this software.
%
% Permission is granted to anyone to use this software for any purpose,
% including commercial applications, and to alter it and redistribute it
% freely, subject to the following restrictions:
%
% 1. The origin of this software must not be misrepresented; you must not
%    claim that you wrote the original software. If you use this software
%    in a product, an acknowledgment in the product documentation would be
%    appreciated but is not required.
%
% 2. Altered source versions must be plainly marked as such, and must not be
%    misrepresented as being the original software.
%
% 3. This notice may not be removed or altered from any source
%    distribution.
function exportMat(song,filename,exportEmptyChannels)
    if nargin < 3
        exportEmptyChannels = false;
    end

    f = fopen(filename,'w');
    % Basic song data
    fprintf(f,'song=struct;\n');
    fprintf(f,'song.rowLen=%d;\n',song.rowLen);
    fprintf(f,'song.patternLen=%d;\n',song.patternLen);
    fprintf(f,'song.endPattern=%d;\n',song.endPattern);  
    fprintf(f,'song.songData={');    
    first = true;
    for i = 1:length(song.songData)
        % Export all channels
        first = exportChannel(f,song.songData{i},exportEmptyChannels,first);
    end
    fprintf(f,'};\n');
	fclose(f);
end
 
function first = exportChannel(f,i,exportEmptyChannels,first)
    patterns = stripTrailingZeros(i{2});
    if isempty(patterns) && ~exportEmptyChannels
        % Don't export empty channels        
        return;
    end
    if ~first
        fprintf(f,',');
    end
    first = false;
    fprintf(f,'{');
    exportArray(f,i{1});
    fprintf(f,',');
    exportArray(f,stripTrailingZeros(patterns));
    fprintf(f,',');
    exportColumns(f,i{3});
    fprintf(f,'}');
end

function exportColumns(f,col)     
    isColEmpty = cellfun(@(x) isempty(stripTrailingZeros(x{1}))&&...
        isempty(stripTrailingZeros(x{2})),col);
    lastIndex = find(~isColEmpty,1,'last');
    fprintf(f,'{');
    for i = 1:lastIndex
        if i>1
            fprintf(f,',');
        end
        fprintf(f,'{');
        exportArray(f,stripTrailingZeros(col{i}{1}));
        fprintf(f,',');
        exportArray(f,stripTrailingZeros(col{i}{2}));
        fprintf(f,'}');
    end    
    fprintf(f,'}');      
end

function ret = stripTrailingZeros(array)	
    lastindex = find(array ~= 0,1,'last');
    ret = array(1:lastindex);
end

function exportArray(f,array)
    if isempty(array)
        fprintf(f,'[]');
        return;
    end
    if length(array) == 1
        fprintf(f,'%g',array);
        return;
    end
    fprintf(f,'[');
    for i = 1:length(array)
       if i>1
           fprintf(f,',');      
       end
       fprintf(f,'%g',array(i));      
    end
    fprintf(f,']');
end

    