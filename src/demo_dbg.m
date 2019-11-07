function demo_opt(varargin)
    global frame video sample

    outputdir = 'output/';    
    
    close all;
    
    parser = inputParser;
    parser.addParameter('start',[]);
    parser.addParameter('cache',true);
    parser.addParameter('mute',false);
    parser.addParameter('capture',false);
    parser.addParameter('fps',60);
    parser.addParameter('window','full');
    parse(parser,varargin{:});   
    
    cachefile = [outputdir,'songcache.mat'];
    
    if ~exist(cachefile,'file') || ~parser.Results.cache
        song;
        player;
        if parser.Results.cache
            if ~exist(outputdir,'dir')
                mkdir(outputdir);
            end   
            save(cachefile,'mMixBuf','envs');
        end
    else
        load(cachefile);
    end      
    
    if ~isempty(parser.Results.start)
        start_time = (parser.Results.start * 32 + 16) * 6615 / 44100;
    else
        start_time = 0;
    end
    
    if parser.Results.capture
        if ~exist(outputdir,'dir')
            mkdir(outputdir);
        end   
        audiofile =  [outputdir,'audio.wav'];
        videofile =  [outputdir,'video.avi'];
        start_sample = floor(start_time * 44100 + 1);
        audiowrite(audiofile,mMixBuf(:,start_sample:end)',44100)
        frame = start_time * parser.Results.fps;
        video = VideoWriter(videofile,'Motion JPEG AVI');
        video.FrameRate = parser.Results.fps;
        video.Quality = 95;
        open(video);   
        sample = @()1;    
        draw=@capture_draw;
        start_music = @()0;
    else 
        draw = @drawnow;
        if ~parser.Results.mute
            audio = audioplayer(mMixBuf,44100);
            start_music = @()play(audio,floor(start_time*44100+1));
            sample = @()audio.currentSample;
        else
            start_music = @tic;
            sample = @()floor((start_time+toc)*44100+1);
        end
    end
    
    if strcmp(parser.Results.window,'full')
        fig = figure('WindowState','fullscreen', 'MenuBar', 'none', 'ToolBar', 'none','Pointer','custom','PointerShapeCData',nan(16,16));
    else
        fig = figure('MenuBar', 'none', 'ToolBar', 'none');
    end
        
    effects;
    
    if parser.Results.capture
        close(video);
    end
end

function capture_draw()   
    global frame video sample
    frame = frame + 1;
    sample = @()max(frame*44100/60,1);
    drawnow();
    f = getframe(gcf);
    writeVideo(video,f);    
    disp(sample());    
end