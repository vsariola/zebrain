function demo  
    loadsong;                    
    loadsync;
    [s,envs] = player(song);
    a = audioplayer(s/32768,44100);    
    y = gensync(sync,(1:length(s)/8)/song.rowLen*4);
    
    initialize;    
    
    play(a)
    
    while isplaying(a) 
        currentSample = a.CurrentSample;
        mainloop
    end   
    
    finalize;
end