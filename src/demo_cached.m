function demo  
    loadsong;                    
    loadsync;
    if ~exist('songcache.mat','file')
        [s,envs] = player(song);
        save('songcache.mat','s','envs');
    else
        load('songcache.mat');
    end            
    mainloop   
end