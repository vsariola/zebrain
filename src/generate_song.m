function generate_song

    f = fopen('../data/song.bin');d = fread(f,'uint8=>uint8');fclose(f);
    song = loadSoundBoxBin(d);
    for i = 1:length(song.songData)
        if song.songData{i}{1}(1) == 3 % Third oscillator was removed, fourth oscillator is now third
            song.songData{i}{1}(1) = 2;
        end
        if song.songData{i}{1}(5) == 3 % Third oscillator was removed, fourth oscillator is now third
            song.songData{i}{1}(5) = 2;
        end
        song.songData{i}{1} = song.songData{i}{1}([1:13,16:28]);
        song.songData{i}{1} = round(song.songData{i}{1} ./ [1,3,2,1,1,3,2,1,1,3,1,1,2,1,3,1,1,1,2,2,2,2,3,1,3,1]);
        p = song.songData{i}{2};
        c = song.songData{i}{3}; 
        up = unique(p);
        usedPatterns = up(up > 0);
        l = 1:length(c);
        drop = ismember(l,usedPatterns);
        finalc = c(drop);
        mapping = zeros(1,length(c));
        mapping(l(drop))=1:length(finalc);
        zeromapping = [0 mapping];
        song.songData{i}{2} = zeromapping(p+1);
        song.songData{i}{3} = finalc;
    end
    song.endPattern = song.endPattern + 4;
    exportMat(song,'song.m');
    rehash;
end

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
    fprintf(f,'songdata={');    
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
        notes = stripTrailingZeros(col{i}{1});
        notes(notes > 0) = notes(notes > 0) - 98;
        exportArray(f,notes);               
    end    
    fprintf(f,'}');      
end

function ret = stripTrailingZeros(array)	
    lastindex = find(array ~= 0,1,'last');
    ret = array(1:lastindex);
end

function exportArray(f,array)
    if isempty(array)
        fprintf(f,'''''');
        return;
    end
    fprintf(f,'''');
    for i = 1:length(array)
       fprintf(f,'%s',char(array(i)+160));      
    end
    fprintf(f,'''');
end

    
% This is a MATLAB port of the code to load SoundBox binaries
% from https://github.com/mbitsnbites/soundbox/
% Ported by: Veikko Sariola, 2017
%
% Original copyright: (c) 2011-2014 Marcus Geelnard
%
% The original file is part of SoundBox.
%
% SoundBox is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% SoundBox is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with SoundBox.  If not, see <http://www.gnu.org/licenses/>.
%
%/

function song = loadSoundBoxBin(arg)
    % Instrument property indices
    OSC1_WAVEFORM = 0;
    OSC1_VOL = 1;
    OSC1_SEMI = 2;
    OSC1_XENV = 3;

    OSC2_WAVEFORM = 4;
    OSC2_VOL = 5;
    OSC2_SEMI = 6;
    OSC2_DETUNE = 7;
    OSC2_XENV = 8;

    NOISE_VOL = 9;

    ENV_ATTACK = 10;
    ENV_SUSTAIN = 11;
    ENV_RELEASE = 12;

    ARP_CHORD = 13;
    ARP_SPEED = 14;

    LFO_WAVEFORM = 15;
    LFO_AMT = 16;
    LFO_FREQ = 17;
    LFO_FX_FREQ = 18;

    FX_FILTER = 19;
    FX_FREQ = 20;
    FX_RESONANCE = 21;
    FX_DIST = 22;
    FX_DRIVE = 23;
    FX_PAN_AMT = 24;
    FX_PAN_FREQ = 25;
    FX_DELAY_AMT = 26;
    FX_DELAY_TIME = 27;
    
    MAX_INSTR_INDEX = FX_DELAY_TIME;
       
    MAX_PATTERNS = 36;   

    if ischar(arg)
        f = fopen(arg);
        data = fread(f,'uint8=>uint8');
        fclose(f);
    else
        data = uint8(arg);    
    end

    song = struct;
    
    bin = CBinParser(data);

    signature = bin.getULONG();

    % Format version
    version = bin.getUBYTE();

    % Check if this is a SoundBox song
    if signature ~= 2020557395 || version < 1
        error('The supplied data does not have correct SoundBox signature or version');
    end
    
    if version < 11
        error('Importing versions older than 11 is not supported. Use SoundBox to re-export as a newer version');
    end
    
    if version > 12
        error('Currently supports binary versions v11 - v12.');
    end
    
    % Get compression method
    %  0: none
    %  1: RLE
    %  2: DEFLATE
    compressionMethod = bin.getUBYTE();

    % Unpack song data
    packedData = bin.getTail();
    switch compressionMethod
        case 1
            error('Unsupported compression method rle_decode (you have to port it yourself if you need it)');
            %unpackedData = rle_decode(packedData);
        case 2
            unpackedData = inflate(packedData);
        otherwise
            unpackedData = packedData;
    end
    bin = CBinParser(unpackedData);    

    % Row length
    song.rowLen = bin.getULONG();

    % Last pattern to play
    if (version >= 12)
        song.endPattern = bin.getUSHORT();
    else
        song.endPattern = bin.getUBYTE() + 2;
    end

    % Number of rows per pattern    
    song.patternLen = bin.getUBYTE();    

    % Number of channels    
    if (version >= 12)
        song.numChannels = bin.getUBYTE();
    else
        song.numChannels = 8;
    end

    % All instruments
    song.songData = {};
    for i=1:song.numChannels
        instr = cell(1,3);
        instr{1} = zeros(1,MAX_INSTR_INDEX);

        % Oscillator 1        
        instr{1}(OSC1_WAVEFORM+1) = bin.getUBYTE();
        instr{1}(OSC1_VOL+1) = bin.getUBYTE();
        instr{1}(OSC1_SEMI+1) = bin.getUBYTE();
        instr{1}(OSC1_XENV+1) = bin.getUBYTE();        

        % Oscillator 2        
        instr{1}(OSC2_WAVEFORM+1) = bin.getUBYTE();
        instr{1}(OSC2_VOL+1) = bin.getUBYTE();
        instr{1}(OSC2_SEMI+1) = bin.getUBYTE();
        instr{1}(OSC2_DETUNE+1) = bin.getUBYTE();
        instr{1}(OSC2_XENV+1) = bin.getUBYTE();        

        % Noise oscillator
        instr{1}(NOISE_VOL+1) = bin.getUBYTE();

        % Envelope        
        instr{1}(ENV_ATTACK+1) = bin.getUBYTE();
        instr{1}(ENV_SUSTAIN+1) = bin.getUBYTE();
        instr{1}(ENV_RELEASE+1) = bin.getUBYTE();        

        % Arpeggio        
        instr{1}(ARP_CHORD+1) = bin.getUBYTE();
        instr{1}(ARP_SPEED+1) = bin.getUBYTE();
     
        % LFO
        instr{1}(LFO_WAVEFORM+1) = bin.getUBYTE();
        instr{1}(LFO_AMT+1) = bin.getUBYTE();
        instr{1}(LFO_FREQ+1) = bin.getUBYTE();
        instr{1}(LFO_FX_FREQ+1) = bin.getUBYTE();

        % Effects
        instr{1}(FX_FILTER+1) = bin.getUBYTE();
        instr{1}(FX_FREQ+1) = bin.getUBYTE();
        instr{1}(FX_RESONANCE+1) = bin.getUBYTE();
        instr{1}(FX_DIST+1) = bin.getUBYTE();
        instr{1}(FX_DRIVE+1) = bin.getUBYTE();
        instr{1}(FX_PAN_AMT+1) = bin.getUBYTE();
        instr{1}(FX_PAN_FREQ+1) = bin.getUBYTE();
        instr{1}(FX_DELAY_AMT+1) = bin.getUBYTE();
        instr{1}(FX_DELAY_TIME+1) = bin.getUBYTE();
        

        % Patterns
        if version < 12
            song_rows = 128;
        else
            song_rows = song.endPattern + 1;
        end
        
        instr{2} = [];
        for j=1:song_rows
            instr{2}(j) = bin.getUBYTE();
        end

        % Columns      
        num_patterns = MAX_PATTERNS;        

        instr{3} = {};
        for j=0:(num_patterns-1)
            col = cell(1,2);
            col{1} = [];           
            for k=0:(song.patternLen * 4-1)
                col{1}(k+1) = bin.getUBYTE();
            end            
            col{2} = [];            
            for k=1:song.patternLen
                fxCmd = bin.getUBYTE();
                % We inserted two new commands in version 11
                if (version < 11 && fxCmd >= 14)
                    fxCmd = fixCmd+2;
                end
                col{2}(k) = fxCmd;
            end
            for k=1:song.patternLen
                col{2}(song.patternLen + k) = bin.getUBYTE();
            end
            instr{3}{j+1} = col;
        end        
                

        song.songData{i} = instr;
    end
end

function ret = CBinParser(d)
    mData = d;
    mPos = 1;

    function ret = getUBYTE()
        ret = double(mData(mPos));
        mPos = mPos + 1;
    end

    function ret = getUSHORT()
        ret = double(uint16(mData(mPos))+bitshift(uint16(mData(mPos+1)),8));
        mPos = mPos + 2;
    end

    function ret = getULONG()
        ret = double(uint32(mData(mPos))+...
            bitshift(uint32(mData(mPos+1)),8)+...
            bitshift(uint32(mData(mPos+2)),16)+...
            bitshift(uint32(mData(mPos+3)),24));
        mPos = mPos + 4;
    end

    function ret = getFloat()
        l = getULONG();
        if (l == 0); ret=0; return; end;
        s = bitand(l,hex2dec('80000000'));
        e = bitand(bitshift(l,-23),255);
        m = 1 + bitand(l,hex2dec('007fffff')) / hex2dec('00800000');  % Mantissa
        x = m * 2^(e - 127);
        if s
            ret = -x;
        else
            ret = x;
        end
        ret = double(ret);
    end

    function ret = getTail()
        ret = mData(mPos:end);
        mPos = length(mData)+1;
    end

    ret = struct(...
        'getUBYTE',@getUBYTE,...
        'getUSHORT',@getUSHORT,...
        'getULONG',@getULONG,...
        'getFloat',@getFloat,...
        'getTail',@getTail...
    );
end

function ret = inflate(Z)
    % Adapted from
    % https://se.mathworks.com/matlabcentral/fileexchange/8899-rapid-lossless-data-compression-of-numerical-or-string-variables
    import com.mathworks.mlwidgets.io.InterruptibleStreamCopier;
    a=java.io.ByteArrayInputStream(Z);
    inflater = java.util.zip.Inflater(true);
    b=java.util.zip.InflaterInputStream(a,inflater);
    isc = InterruptibleStreamCopier.getInterruptibleStreamCopier;
    c = java.io.ByteArrayOutputStream;
    isc.copyStream(b,c);
    ret=typecast(c.toByteArray,'uint8');
end

