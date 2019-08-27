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

function [mMixBuf,envBufs] = player(song)

    samx = (0:44099)/44100;
    % Precalculate oscillators into a table; this is much faster than
    % using lambdas in matlab
    % Oscillators: 1 = sine, 2 = square, 3 = sawtooth, 4 = triangle
    oscPrecalc = [sin(samx*2*pi);(samx < .5)*2-1;1-abs(samx*4-2)];
    getnotefreq = @(n) .003959503758 * 2^((n - 128) / 12);    

    % Prepare song info
    mNumSamples = 8334900;
    
    % Create work buffer (initially cleared)
    mMixBuf = zeros(2,mNumSamples);
    envBufs = zeros(7,mNumSamples);
    
    for mCurrentCol = 0:6   
        % Put performance critical items in local variables
        chnBuf = zeros(2,mNumSamples);
        instr = song{mCurrentCol+1};
        rowLen = 6615;
        patternLen = 32;

        % Clear effect state
        low = 0;
        band = 0;        
        filterActive = 0;        

        % Clear note cache.
        noteCache = {};

        % Patterns
        for p = 0:35
            cp = indexArray(instr{2},p+1);            
                       
            % Pattern rows
            for row = 0:(patternLen-1)
                % Put performance critical instrument properties in local variables
                oscLFO = instr{1}(16)+1;
                lfoAmt = instr{1}(17) / 512;
                lfoFreq = 2^(instr{1}(18) - 9) / rowLen;
                fxLFO = instr{1}(19);
                fxFilter = instr{1}(20);
                fxFreq = instr{1}(21) * 43.23529 * pi / 44100;
                q = 1 - instr{1}(22) / 255;
                dist = instr{1}(23) * 1e-5;
                drive = instr{1}(24) / 32;
                panAmt = instr{1}(25) / 512;
                panFreq = 2*pi * 2^(instr{1}(26) - 9) / rowLen;
                dlyAmt = instr{1}(27) / 255;
                dly = bitor(instr{1}(28) * rowLen,1)-1; % Must be an even number

                % Calculate start sample number for this row in the pattern
                rowStartSample = (p * patternLen + row) * rowLen;

                % Generate notes for this pattern row
                for col=0:3
                    note = indexArray(indexArray(instr{3},cp),row + col * patternLen+1);
                    if note
                        if isempty(indexArray(noteCache,note+1))
                            noteCache{note+1} = createNote(instr, note);
                        end

                        % Copy note from the note cache
                        noteBuf = noteCache{note+1};                           
                        range = rowStartSample+1:rowStartSample+length(noteBuf);
                        chnBuf(1,range) = chnBuf(1,range)+noteBuf(1,:);   
                        envBufs(mCurrentCol+1,range) = envBufs(mCurrentCol+1,range)+noteBuf(2,:)*(col==0);                                                
                    end
                end
                                                
                
                % Perform effects for this pattern row
                for kk = rowStartSample * 2:2:(rowStartSample + rowLen-1) * 2

                    % We only do effects if we have some sound input
                    if filterActive || chnBuf(kk+1)                                              
                        
                        % Dry mono-sample                        
                        tmpsample = chnBuf(kk+1);                    
                        % State variable filter
                        f = fxFreq;
                        if fxLFO
                            f = f * (oscPrecalc(oscLFO,floor(mod(lfoFreq * kk,1)*44100+1)) * lfoAmt + 0.5);
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
                                    tmpsample = oscPrecalc(1,floor(mod(tmpsample*.25,1)*44100+1));
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
                        t = sin(panFreq * kk) * panAmt + 0.5;
                        chnBuf(kk+1) = tmpsample * (1 - t);
                        chnBuf(kk+2) = tmpsample * t;    
                    
                    end
                end
                
                start = max(rowStartSample * 2,dly);                
                
                % Perform delay. This could have been done in the previous
                % loop, but it was slower than doing a second loop
                for kk = start:2:(rowStartSample + rowLen-1) * 2
                    chnBuf(kk+1)=chnBuf(kk+1)+chnBuf(kk-dly+2) * dlyAmt;
                    chnBuf(kk+2)=chnBuf(kk+2)+chnBuf(kk-dly+1) * dlyAmt;
                end
            end
        end    
        
        mMixBuf = mMixBuf + chnBuf;
    end
    
    function ret=indexArray(a,n)
        ret = [];
        if ~isempty(a) && ~isempty(n) && n > 0 && length(a) >= n
            if iscell(a)
                ret=a{n};
            else
                ret=a(n);
            end
        end
    end
        
    function ret = createNote(instr,n)
        osc1 = instr{1}(1)+1;
        o1vol = instr{1}(2);
        o1xenv = instr{1}(4);
        osc2 = instr{1}(5)+1;
        o2vol = instr{1}(6);
        o2xenv = instr{1}(9);
        noiseVol = instr{1}(10);
        attack = instr{1}(11)^2 * 4;
        sustain = instr{1}(12)^2 * 4;
        release = instr{1}(13)^2 * 4;        

        % Generate one note (attack + sustain + release)
        o1t = getnotefreq(n + instr{1}(3) - 128);
        o2t = getnotefreq(n + instr{1}(7) - 128) * (1 + .0008 * instr{1}(8));
        
        envelope = [(0:attack-1)/attack,ones(1,sustain),1-(0:release-1)/release];
        numsamples = length(envelope);
        
        % Oscillator 1
        if o1xenv
        	c1 = cumsum(envelope.^2);
        else
            c1 = 1:numsamples;
        end            
        sample = oscPrecalc(osc1,floor(mod(o1t * c1,1)*44100+1)) * o1vol;

        % Oscillator 2        
        if o2xenv
        	c2 = cumsum(envelope.^2);
        else
            c2 = 1:numsamples;
        end      
        sample = sample + oscPrecalc(osc2,floor(mod(o2t * c2,1)*44100+1)) * o2vol;

        % Noise oscillator
        if noiseVol>0
            sample = sample + (2 * rand(1,numsamples) - 1) * noiseVol;
        end
        
        ret = [80 * sample .* envelope;envelope];
    end
end