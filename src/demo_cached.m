function demo  
    loadsong;                    
    loadsync;
    if ~exist('songcache.mat','file')
        [s,envs] = player(song);
        save('songcache.mat','s','envs');
    else
        load('songcache.mat');
    end
    a = audioplayer(s/32768,44100);    
    y = gensync(sync,(1:length(s)/8)/song.rowLen*4);
    
    initialize;    
    
    play(a)
    
    while isplaying(a) 
        currentSample = a.CurrentSample;
        mainloop
    end   
    
    deinitialize;
end