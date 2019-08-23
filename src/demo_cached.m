function demo
    loadsong;                    
    if ~exist('songcache.mat','file')
        [s,envs] = player(song);
        save('songcache.mat','s','envs');
    else
        load('songcache.mat');
    end      
    a = audioplayer(s/32768,44100);
    sample = @()a.currentSample;
    mainloop   
end