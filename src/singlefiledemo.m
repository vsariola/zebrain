function s    
    N={'units','normalized','position',[0 0 1 1]};
    figure(N{:});
    axes(N{:});

    sD = {{[2,192,128,0,2,192,128,3,0,0,32,222,60,0,0,2,188,3,1,3,55,241,60,67,53,5,75,5] , [1,2,3,4,3,4] , {{123,0},{118,0},{[123 111],0},{[118 106],0}}},{[3,100,128,0,3,201,128,7,0,0,17,43,109,0,0,3,113,4,1,1,23,184,2,29,147,6,67,3] , [0,0,1,2,1,2] , { ...
            {[123,0,0,0,0,0,0,0,123,0,0,0,0,0,0,0,123,0,0,0,0,0,0,0,123,0,0,0,0,0,0,0,126,0,0,0,0,0,0,0,126,0,0,0,0,0,0,0,126,0,0,0,0,0,0,0,126,0,0,0,0,0,0,0,130,0,0,0,0,0,0,0,130,0,0,0,0,0,0,0,130,0,0,0,0,0,0,0,130],[]},...
            {[122,0,0,0,0,0,0,0,122,0,0,0,0,0,0,0,122,0,0,0,0,0,0,0,122,0,0,0,0,0,0,0,125,0,0,0,0,0,0,0,125,0,0,0,0,0,0,0,125,0,0,0,0,0,0,0,125,0,0,0,0,0,0,0,130,0,0,0,0,0,0,0,130,0,0,0,0,0,0,0,130,0,0,0,0,0,0,0,130],[]}...
        }},...
        {[0,192,99,1,0,80,99,0,0,3,4,0,66,0,0,0,19,4,1,2,86,241,18,195,37,4,0,0] , [0,0,1,1,1,1,1] , { ...
            {[147,0,0,0,147,0,0,0,147,0,0,0,147,0,0,0,147,0,0,0,147,0,0,0,147,0,0,0,147],[]} ...
        }},...
        {[2,146,140,0,2,224,128,3,0,0,84,0,95,0,0,3,179,5,1,2,62,135,11,15,150,3,157,6] , [0,0,0,0,1,2] , { ...
            {[147,0,145,0,147,0,0,0,0,0,0,0,0,0,0,0,135],[11,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,11,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,27,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,84]}, ...
            {[142,0,140,0,142,0,0,0,0,0,0,0,0,0,0,0,130],[11,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,11,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,27,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,84]}...
        }}};
            
    s = player();
    
    w = reshape(s/32768,2,length(s)/2)';
    a = audioplayer(w,44100);
    play(a);
    
    l=-9:.1:9;[x,y]=ndgrid(l);
    while isplaying(a)
        a.CurrentSample        
        h=x+x'*j;
        for F=0:4;for K=0:3;F=F+1./(h-exp(j*(K+a.CurrentSample/100000)));end;h=h-3./F;end;
        image(abs(F));
        drawnow;
    end
    
    function mMixBuf = player

    osc_sin = @(x) sin(x* 6.283184);
    osc_saw = @(x) 2 * mod(x,1) - 1;
    osc_square = @(x) (mod(x,1) < .5)*2-1;
    osc_tri = @(x) 1-abs(mod(x,1)*4-2);
    getnotefreq = @(n) .003959503758 * 2^((n - 128) / 12);
    mOscillators = {osc_sin,osc_square,osc_saw,osc_tri};        

    % Init iteration state variables
    mLastRow = 6;

    % Prepare song info
    mNumWords = 2963520;

    % Create work buffer (initially cleared)
    mMixBuf = zeros(1,mNumWords);

    for mCurrentCol = 0:3
        % Put performance critical items in local variables
        chnBuf = zeros(1,mNumWords);
        instr = sD{mCurrentCol+1};
        rowLen = 6615;
        patternLen = 32;

        % Clear effect state
        low = 0;
        band = 0;        
        filterActive = 0;

        % Clear note cache.
        noteCache = {};

        % Patterns
        for p = 0:mLastRow-1
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
                rowStartSample = (p * patternLen + row) * rowLen;

                % Generate notes for this pattern row
                for col=0:3
                    n = indexArray(indexCell(indexCell(instr{3},cp),1),row + col * patternLen+1);
                    if n
                        if isempty(indexCell(noteCache,n+1))
                            noteCache{n+1} = createNote(instr, n, rowLen);
                        end

                        % Copy note from the note cache
                        noteBuf = noteCache{n+1};
                        i = rowStartSample * 2+1;
                        for jt = 1:length(noteBuf)
                            chnBuf(i) = chnBuf(i)+noteBuf(jt);
                            i = i + 2;
                        end
                    end
                end

                % Perform effects for this pattern row
                for jt = 0:(rowLen-1)
                    % Dry mono-sample
                    k = (rowStartSample + jt) * 2;
                    rsample = chnBuf(k+1);

                    % We only do effects if we have some sound input
                    if rsample || filterActive
                        % State variable filter
                        f = fxFreq;
                        if fxLFO
                            f = f * (oscLFO(lfoFreq * k) * lfoAmt + 0.5);
                        end
                        f = 1.5 * sin(f);
                        low = low + f * band;
                        high = q * (rsample - band) - low;
                        band = band + f * high;
                        if fxFilter == 3
                            rsample = band;
                        elseif fxFilter == 1 
                            rsample = high;
                        else
                            rsample = low;
                        end

                        % Distortion
                        if dist>0
                            rsample = rsample * dist;
                            if rsample < 1
                                if rsample > -1
                                    rsample = osc_sin(rsample*.25);
                                else
                                    rsample = -1;
                                end
                            else
                                rsample = 1;
                            end                                    
                            rsample = rsample / dist;
                        end

                        % Drive
                        rsample = rsample * drive;

                        % Is the filter active (i.e. still audiable)?
                        filterActive = rsample * rsample > 1e-5;

                        % Panning
                        t = sin(panFreq * k) * panAmt + 0.5;
                        lsample = rsample * (1 - t);
                        rsample = rsample * t;
                    else
                        lsample = 0;
                    end

                    % Delay is always done, since it does not need sound input
                    if k >= dly
                        % Left channel = left + right[-p] * t
                        lsample = lsample+chnBuf(k-dly+2) * dlyAmt;

                        % Right channel = right + left[-p] * t
                        rsample = rsample+chnBuf(k-dly+1) * dlyAmt;
                    end

                    %  Store in stereo channel buffer (needed for the delay effect)
                    chnBuf(k+1) = floor(lsample);
                    chnBuf(k+2) = floor(rsample);

                    % ...and add to stereo mix buffer
                    mMixBuf(k+1) = floor(mMixBuf(k+1)+lsample);
                    mMixBuf(k+2) = floor(mMixBuf(k+2)+rsample);
                end
            end
        end        
    end
    
    function r=indexCell(a,n)
        r = [];
        if ~isempty(a) && n > 0 && length(a) >= n
            r=a{n};
        end
    end

    function r=indexArray(a,n)
        r = [];
        if ~isempty(a) && n > 0 && length(a) >= n
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
            if noiseVol
                sample = sample + (2 * rand - 1) * noiseVol;
            end

            % Add to (mono) channel buffer
            noteBuf(jj+1) = floor(80 * sample * e);       
            
            j2 = j2+1;
        end          
    end
    end
end