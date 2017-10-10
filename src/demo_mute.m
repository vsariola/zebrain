function demo_mute
    loadsong;                    
    loadsync;    
    
    initialize;    
    
	maxTime = song.rowLen * song.patternLen * (song.endPattern + 1) / 44100;
    tic;
    while toc < maxTime
        currentSample = toc*44100;
        mainloop
    end   
    
    deinitialize;
end