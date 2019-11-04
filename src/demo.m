function demo
    rng(0);

    song;                    
    player;
    audio = audioplayer(mMixBuf,44100);
    draw = @drawnow;
    sample = @()audio.currentSample;
    start_music = @()play(audio);
    fig = figure('WindowState','fullscreen', 'MenuBar', 'none', 'ToolBar', 'none','Pointer','custom','PointerShapeCData',nan(16,16));

    effects;
end