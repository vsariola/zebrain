function demo
    loadsong;                    
    player;
    a = audioplayer(mMixBuf/32768,44100);
    draw = @drawnow;
    sample = @()a.currentSample;
    start_music = @()play(a);
    effects;
end