function demo_cached(start_time,cache)
    if nargin < 1
        start_time = 0;
    end
    
    if nargin < 2
        cache = 1;
    end

    loadsong;                    
    if ~exist('songcache.mat','file') || ~cache
        [s,envs] = player(song);
        save('songcache.mat','s','envs');
    else
        load('songcache.mat');
    end      
    draw = @drawnow;
    a = audioplayer(s/32768,44100);
    start_music = @()play(a,start_time);
    sample = @()a.currentSample;
    mainloop   
end