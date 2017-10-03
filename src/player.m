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

function mMixBuf = player(song)

    osc_sin = @(x) sin(x* 6.283184);
    osc_saw = @(x) 2 * mod(x,1) - 1;
    osc_square = @(x) (mod(x,1) < .5)*2-1;
    osc_tri = @(x) 1-abs(mod(x,1)*4-2);
    getnotefreq = @(n) .003959503758 * 2^((n - 128) / 12);
    mOscillators = {osc_sin,osc_square,osc_saw,osc_tri};    

    % Init iteration state variables
    mLastRow = song.endPattern - 2;

    % Prepare song info
    mNumWords = song.rowLen * song.patternLen * (mLastRow + 1) * 2;

    % Create work buffer (initially cleared)
    mMixBuf = zeros(1,mNumWords);

    for mCurrentCol = 0:length(song.songData)-1        
        % Put performance critical items in local variables
        chnBuf = zeros(1,mNumWords);
        instr = song.songData{mCurrentCol+1};
        rowLen = song.rowLen;
        patternLen = song.patternLen;

        % Clear effect state
        low = 0;
        band = 0;        
        filterActive = 0;
        lastSample = 0;

        % Clear note cache.
        noteCache = {};

        % Patterns
        for p = 0:mLastRow
            cp = indexArray(instr{2},p+1);            
           
            
            % Pattern rows
            for row = 0:(patternLen-1)
                % Execute effect command.                                
                cmdNo = indexArray(indexCell(indexCell(instr{3},cp),2),row+1);
                if cmdNo
                    instr{1}(cmdNo) = indexArray(instr{3}{cp}{2},row + patternLen+1);

                    % Clear the note cache since the instrument has changed
                    if cmdNo < 16
                        noteCache = {};
                    end
                end
                

                % Put performance critical instrument properties in local variables
                oscLFO = mOscillators{instr{1}(16)+1};
                lfoAmt = instr{1}(17) / 512;
                lfoFreq = 2^(instr{1}(18) - 9) / rowLen;
                fxLFO = instr{1}(19);
                fxFilter = instr{1}(20);
                fxFreq = instr{1}(21) * 43.23529 * 3.141592 / 44100;
                q = 1 - instr{1}(22) / 255;
                dist = instr{1}(23) * 1e-5;
                drive = instr{1}(24) / 32;
                panAmt = instr{1}(25) / 512;
                panFreq = 6.283184 * 2^(instr{1}(26) - 9) / rowLen;
                dlyAmt = instr{1}(27) / 255;
                dly = instr{1}(28) * rowLen;

                % Calculate start sample number for this row in the pattern
                rowStartSample = (p * uint32(patternLen) + uint32(row)) * uint32(rowLen);

                % Generate notes for this pattern row
                for col=0:3
                    n = indexArray(indexCell(indexCell(instr{3},cp),1),row + col * patternLen+1);
                    if n
                        if isempty(indexCell(noteCache,n+1))
                            noteCache{n+1} = createNote(instr, n, rowLen);
                        end

                        % Copy note from the note cache
                        noteBuf = noteCache{n+1};   
                        endSample = (rowStartSample+uint32(length(noteBuf)))*2-1;
                        range = rowStartSample*2+1:2:(rowStartSample+uint32(length(noteBuf)))*2-1;
                        chnBuf(range) = chnBuf(range)+noteBuf;
                        lastSample = max(lastSample,endSample);
                        %for j = 1:length(noteBuf)
                        %    chnBuf(rowStartSample*2+j*2-1) = chnBuf(...)+noteBuf(j);
                        %end
                    end
                end
                                                
                
                % Perform effects for this pattern row
                for k = rowStartSample * 2:2:(rowStartSample + rowLen-1) * 2

                    % We only do effects if we have some sound input
                    if ~filterActive && ~chnBuf(k+1)
                        if k > lastSample
                            break;
                        end
                        continue;
                    end
                        
                    % Dry mono-sample                        
                    tmpsample = chnBuf(k+1);                    
                    % State variable filter
                    f = fxFreq;
                    if fxLFO
                        f = f * (oscLFO(lfoFreq * double(k)) * lfoAmt + 0.5);
                    end
                    f = 1.5 * sin(f);
                    low = low + f * band;
                    high = q * (tmpsample - band) - low;
                    band = band + f * high;
                    if fxFilter == 3
                        tmpsample = band;
                    elseif fxFilter == 1 
                        tmpsample = high;
                    else
                        tmpsample = low;
                    end

                    % Distortion
                    if dist>0
                        tmpsample = tmpsample * dist;
                        if tmpsample < 1
                            if tmpsample > -1
                                tmpsample = osc_sin(tmpsample*.25);
                            else
                                tmpsample = -1;
                            end
                        else
                            tmpsample = 1;
                        end                                    
                        tmpsample = tmpsample / dist;
                    end

                    % Drive
                    tmpsample = tmpsample * drive;

                    % Is the filter active (i.e. still audiable)?
                    filterActive = tmpsample * tmpsample > 1e-5;

                    % Panning
                    t = sin(panFreq * double(k)) * panAmt + 0.5;
                    chnBuf(k+1) = tmpsample * (1 - t);
                    chnBuf(k+2) = tmpsample * t;                      
                end
                
                start = rowStartSample * 2;
                if (start < dly)
                    start = dly + mod(dly,2);
                end
                for k = start:2:(rowStartSample + rowLen-1) * 2
                    chnBuf(k+1)=floor(chnBuf(k+1)+chnBuf(k-dly+2) * dlyAmt);
                    chnBuf(k+2)=floor(chnBuf(k+2)+chnBuf(k-dly+1) * dlyAmt);
                end
            end
        end    
        
        mMixBuf = mMixBuf + chnBuf;
    end
    
    function r=indexCell(a,n)
        r = [];
        if ~isempty(a) && ~isempty(n) && n > 0 && length(a) >= n
            r=a{n};
        end
    end

    function r=indexArray(a,n)
        r = [];
        if ~isempty(a) && ~isempty(n) && n > 0 && length(a) >= n
            r=a(n);
        end
    end
        
    function noteBuf = createNote(instr,n,rowLen)
        osc1 = mOscillators{instr{1}(1)+1};
        o1vol = instr{1}(2);
        o1xenv = instr{1}(4);
        osc2 = mOscillators{instr{1}(5)+1};
        o2vol = instr{1}(6);
        o2xenv = instr{1}(9);
        noiseVol = instr{1}(10);
        attack = instr{1}(11)^2 * 4;
        sustain = instr{1}(12)^2 * 4;
        release = instr{1}(13)^2 * 4;
        releaseInv = 1 / release;
        arp = instr{1}(14);
        arpInterval = rowLen * 2^(2 - instr{1}(15));

        noteBuf = zeros(1,attack + sustain + release);

        c1 = 0;
        c2 = 0;

        % Generate one note (attack + sustain + release)
        j2 = 0;
        for jj = 0:attack + sustain + release-1
            if (j2 >= 0)
                arp = bitor(bitshift(arp,-8),bitand(arp,255)*16);
                j2 = j2 - arpInterval;

                % Calculate note frequencies for the oscillators
                o1t = getnotefreq(n + bitand(arp,15) + instr{1}(3) - 128);
                o2t = getnotefreq(n + bitand(arp,15) + instr{1}(7) - 128) * (1 + 0.0008 * instr{1}(8));
            end

            % Envelope
            e = 1;
            if jj < attack
                e = jj / attack;
            elseif jj >= attack + sustain
                e = e - (jj - attack - sustain) * releaseInv;
            end

            % Oscillator 1
            t = o1t;
            if o1xenv
                t = t * e * e;
            end
            c1 = c1 + t;
            sample = osc1(c1) * o1vol;

            % Oscillator 2
            t = o2t;
            if o2xenv
                t = t * e * e;
            end

            c2 = c2 + t;
            sample = sample + osc2(c2) * o2vol;

            % Noise oscillator
            if noiseVol>0
                sample = sample + (2 * rand - 1) * noiseVol;
            end

            % Add to (mono) channel buffer
            noteBuf(jj+1) = floor(80 * sample * e);       
            
            j2 = j2+1;
        end          
    end
end