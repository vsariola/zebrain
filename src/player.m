% This is a MATLAB port of the SoundBox player-small.js
% from https://github.com/mbitsnbites/soundbox/
% Ported by: Veikko Sariola, 2017
%
% Original copyright: (c) 2011-2013 Marcus Geelnard
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
samx = (0:1e5-1)/1e5;
% Precalculate oscillators into a table; this is much faster than
% using lambdas in matlab
% Oscillators: 1 = sine, 2 = square, 3 = triangle
oscPrecalc = [sin(samx*2*pi);(samx < .5)*2-1;1-abs(samx*4-2)] * 3;
getnotefreq = @(n) .00395 * 2^((n - 158) / 12);    

% Prepare song info
mNumSamples = 75e5;
rowLen = 6615;   

% Create work buffer (initially cleared)
mMixBuf = zeros(2,mNumSamples);
envs = zeros(7,mNumSamples);

for mCurrentCol = 1:7
    % Put performance critical items in local variables
    chnBuf = zeros(2,mNumSamples);
    instr = songdata{mCurrentCol};
    instrparams = instr{1}-160;       

    attack = instrparams(11)^2 * 4;
    release = instrparams(13)^2 * 16;        

    envelope = [(0:attack-1)/attack,ones(1,instrparams(12)^2 * 4),1-(0:release-1)/release];        
    numsamples = length(envelope);   
    
    c1 = cumsum(envelope .^ (2*instrparams(4)));
    c2 = cumsum(envelope .^ (2*instrparams(9)));

    % Clear note cache.
    noteCache = cell(1,256);

    % Patterns
    for p = 1:length(instr{2})
        cp = instr{2}(p)-160;  

        if cp            
            % Pattern rows
            pat = instr{3}{cp}-160;
            for rc = 1:length(pat)
                % Calculate start sample number for this row in the pattern
                rowStartSample = ((p-1) * 32 + mod(rc-1,32)) * rowLen;

                % Generate notes for this pattern row
                note = pat(rc);
                if note
                    if isempty(noteCache{note+1})                        
                        noteCache{note+1} = 80 * (oscPrecalc(instrparams(1)+1,floor(mod(getnotefreq(note + instrparams(3) * 2) * c1,1)*1e5+1)) * instrparams(2) + oscPrecalc(instrparams(5)+1,floor(mod(getnotefreq(note + instrparams(7) * 2) * (1 + .0008 * instrparams(8)) * c2,1)*1e5+1)) *  instrparams(6) + (6 * rand(1,numsamples) - 3) * instrparams(10)) .* envelope;
                    end

                    % Copy note from the note cache
                    noteBuf = noteCache{note+1};                           
                    range = rowStartSample+1:rowStartSample+numsamples;
                    chnBuf(1,range) = chnBuf(1,range)+noteBuf;   
                    envs(mCurrentCol,range) = envs(mCurrentCol,range)+envelope*(rc<32);                                                
                end                
            end
        end
    end

    % Put performance critical instrument properties in local variables
    oscLFO = instrparams(14)+1;
    lfoAmt = instrparams(15) / 512;
    lfoFreq = 2^(instrparams(16) - 9) / rowLen;
    fxLFO = instrparams(17);
    fxFreq = instrparams(19) / 162.3381;
    q = 1 - instrparams(20)*2 / 255;
    dist = instrparams(21) * 2e-5;
    drive = instrparams(22) / 16;
    panAmt = instrparams(23)/ 171;
    panFreq = 2*pi * 2^(instrparams(24) - 9) / rowLen;      

    % Clear effect state
    low = 0;
    band = 0;        
    filterActive = 0;    

    % Perform effects
    for kk = 1:2:mNumSamples*2

        % We only do effects if we have some sound input
        if filterActive || chnBuf(kk)                                                                         
            % State variable filter
            freq = fxFreq;
            if fxLFO
                freq = freq * (oscPrecalc(oscLFO,floor(mod(lfoFreq * kk,1)*1e5+1)) * lfoAmt + .5);
            end
            freq = 1.5 * sin(freq);
            low = low + freq * band;          
            band = band + freq * (q * (chnBuf(kk) - band) - low);
            tmpsample = low;               

            % Distortion
            if dist
                tmpsample = sin(.5*pi*min(max(tmpsample*dist,-1),1))/dist;                    
            end

            % Is the filter active (i.e. still audiable)?
            filterActive = tmpsample * tmpsample > 1e-5;

            % Panning
            t = sin(panFreq * kk) * panAmt + .5;
            chnBuf(kk) = drive * tmpsample * (1 - t);
            chnBuf(kk+1) = drive * tmpsample * t;    
        end
    end               

    dlyAmt = instrparams(25) / 85;
    dly = bitor(instrparams(26) * rowLen,1); % Must be an odd number

    % Perform delay. This could have been done in the previous
    % loop, but it was slower than doing a second loop
    for kk = dly:2:mNumSamples*2
        chnBuf(kk)=chnBuf(kk)+chnBuf(kk-dly+2) * dlyAmt;
        chnBuf(kk+1)=chnBuf(kk+1)+chnBuf(kk-dly+1) * dlyAmt;
    end         

    mMixBuf = mMixBuf + chnBuf;
end     

mMixBuf = mMixBuf/18e3;