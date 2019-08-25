function demo  
    loadsong;                    
    [s,envs] = player(song);
    a = audioplayer(s/32768,44100);
    draw = @drawnow;
    sample = @()a.currentSample;
    start_music = @()play(a);
    mainloop
end