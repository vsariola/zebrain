function demo  
    loadsong;                    
    [s,envs] = player(song);
    a = audioplayer(s/32768,44100);
    sample = @()a.currentSample;
    start_music = @()play(a);
    mainloop
end