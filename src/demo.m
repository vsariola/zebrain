function demo
    song;                    
    player;
    a = audioplayer(mMixBuf,44100);
    draw = @drawnow;
    sample = @()a.currentSample;
    start_music = @()play(a);
    fig = figure('WindowState','fullscreen', 'MenuBar', 'none', 'ToolBar', 'none','Pointer','custom','PointerShapeCData',nan(16,16));

    effects;
end