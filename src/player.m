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
    getnotefreq = @(n) .003959503758 * 2^((n - 256) / 12);    

    % Prepare song info
    mNumSamples = 8334900;
    
    % Create work buffer (initially cleared)
    mMixBuf = zeros(2,mNumSamples);
    envBufs = zeros(7,mNumSamples);
    
    for mCurrentCol = 0:6   
        % Put performance critical items in local variables
        chnBuf = zeros(2,mNumSamples);
        instr = song{mCurrentCol+1};
        instrparams = instr{1};
        rowLen = 6615;
        patternLen = 32;    

        % Clear note cache.
        noteCache = {};

        % Patterns
        for p = 0:35
            cp = indexArray(instr{2},p+1);            
                       
            % Pattern rows
            for row = 0:(patternLen-1)       

                % Calculate start sample number for this row in the pattern
                rowStartSample = (p * patternLen + row) * rowLen;

                % Generate notes for this pattern row
                for col=0:3
                    note = indexArray(indexArray(instr{3},cp),row + col * patternLen+1);
                    if note
                        if isempty(indexArray(noteCache,note+1))
                            noiseVol = instrparams(10);
                            attack = instrparams(11)^2 * 4;
                            sustain = instrparams(12)^2 * 4;
                            release = instrparams(13)^2 * 4;        

                            envelope = [(0:attack-1)/attack,ones(1,sustain),1-(0:release-1)/release];
                            numsamples = length(envelope);
                            cumsumenv = cumsum(envelope.^2);

                            % Oscillator 1
                            if instrparams(4) % o1xenv
                                c1 = cumsumenv;
                            else
                                c1 = 1:numsamples;
                            end            
                            sample = oscPrecalc(instrparams(1)+1,floor(mod(getnotefreq(note + instrparams(3)) * c1,1)*44100+1)) * instrparams(2);

                            % Oscillator 2        
                            if instrparams(9) % o2xenv
                                c2 = cumsumenv;
                            else
                                c2 = 1:numsamples;
                            end      
                            sample = sample + oscPrecalc(instrparams(5)+1,floor(mod(getnotefreq(note + instrparams(7)) * (1 + .0008 * instrparams(8)) * c2,1)*44100+1)) *  instrparams(6);

                            % Noise oscillator
                            if noiseVol>0
                                sample = sample + (2 * rand(1,numsamples) - 1) * noiseVol;
                            end                          
                            
                            noteCache{note+1} = [80 * sample .* envelope;envelope];
                        end

                        % Copy note from the note cache
                        noteBuf = noteCache{note+1};                           
                        range = rowStartSample+1:rowStartSample+length(noteBuf);
                        chnBuf(1,range) = chnBuf(1,range)+noteBuf(1,:);   
                        envBufs(mCurrentCol+1,range) = envBufs(mCurrentCol+1,range)+noteBuf(2,:)*(col==0);                                                
                    end
                end
            end
        end

        % Put performance critical instrument properties in local variables
        oscLFO = instrparams(16)+1;
        lfoAmt = instrparams(17) / 512;
        lfoFreq = 2^(instrparams(18) - 9) / rowLen;
        fxLFO = instrparams(19);
        fxFreq = instrparams(21) * 43.23529 * pi / 44100;
        q = 1 - instrparams(22) / 255;
        dist = instrparams(23) * 1e-5;
        drive = instrparams(24) / 32;
        panAmt = instrparams(25) / 512;
        panFreq = 2*pi * 2^(instrparams(26) - 9) / rowLen;      

        % Clear effect state
        low = 0;
        band = 0;        
        filterActive = 0;    
        
        % Perform effects
        for kk = 1:2:mNumSamples

            % We only do effects if we have some sound input
            if filterActive || chnBuf(kk)                                                                         
                % State variable filter
                f = fxFreq;
                if fxLFO
                    f = f * (oscPrecalc(oscLFO,floor(mod(lfoFreq * kk,1)*44100+1)) * lfoAmt + 0.5);
                end
                f = 1.5 * sin(f);
                low = low + f * band;
                high = q * (chnBuf(kk) - band) - low; % Dry mono-sample comes in                
                band = band + f * high;
                tmpsample = low;               

                % Distortion
                if dist
                    tmpsample = sin(.5*pi*min(max(tmpsample*dist,-1),1))/dist;                    
                end

                % Drive
                tmpsample = tmpsample * drive;

                % Is the filter active (i.e. still audiable)?
                filterActive = tmpsample * tmpsample > 1e-5;

                % Panning
                t = sin(panFreq * kk) * panAmt + 0.5;
                chnBuf(kk) = tmpsample * (1 - t);
                chnBuf(kk+1) = tmpsample * t;    
            end
        end               
                
        dlyAmt = instrparams(27) / 255;
        dly = bitor(instrparams(28) * rowLen,1); % Must be an odd number
                
        % Perform delay. This could have been done in the previous
        % loop, but it was slower than doing a second loop
        for kk = dly:2:mNumSamples
            chnBuf(kk)=chnBuf(kk)+chnBuf(kk-dly+2) * dlyAmt;
            chnBuf(kk+1)=chnBuf(kk+1)+chnBuf(kk-dly+1) * dlyAmt;
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
end