function demo      
    song;                    
    player;
    audio = audioplayer(mMixBuf,44100);
    draw = @drawnow;
    sample = @()audio.currentSample;
    start_music = @()play(audio);rng(0); % Initialize rng, so that sound and demo are always the same       
    
    % fig is stored to get the size in pixels, to adjust all markers and
    % line widths to proper scale.
    fig = figure('WindowState','fullscreen', 'MenuBar', 'none', 'ToolBar', 'none','Pointer','custom','PointerShapeCData',nan(16,16));

    effects;
end