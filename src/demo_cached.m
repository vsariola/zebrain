function demo_cached(start_time,cache)
    if nargin < 1
        start_time = 0;
    end
    
    if nargin < 2
        cache = 1;
    end
    
    if ~exist('songcache.mat','file') || ~cache
        loadsong;
        tic;
        player
        toc;
        save('songcache.mat','mMixBuf','envs');
    else
        load('songcache.mat');
    end      
    draw = @drawnow;
    a = audioplayer(mMixBuf/32768,44100);
    start_music = @()play(a,start_time);
    sample = @()a.currentSample;
    mainloop   
end