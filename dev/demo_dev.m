function demo_dev(varargin)
    global frame video sample

    close all;
    
    addpath('../src');

    parser = inputParser;
    parser.addParameter('start',0);
    parser.addParameter('cache',true);
    parser.addParameter('mute',false);
    parser.addParameter('capture',false);
    parser.addParameter('fps',60);
    parse(parser,varargin{:});
    
    if ~exist('output','dir')
        mkdir('output');
    end   
    
    if ~exist('output/songcache.mat','file') || ~parser.Results.cache
        loadsong;
        player;
        save('output/songcache.mat','mMixBuf','envs');
    else
        load('output/songcache.mat');
    end      
    
    start_time = parser.Results.start * 6615 * 32 / 44100;
    
    if parser.Results.capture
        start_sample = floor(start_time * 44100 + 1);
        audiowrite('output/audio.wav',mMixBuf(:,start_sample:end)'/32768,44100)
        frame = start_time * parser.Results.fps;
        video = VideoWriter('output/video.avi','Motion JPEG AVI');
        video.FrameRate = parser.Results.fps;
        video.Quality = 95;
        open(video);   
        sample = @()1;    
        draw=@capture_draw;
        start_music = @()0;
    else 
        draw = @drawnow;
        if ~parser.Results.mute
            a = audioplayer(mMixBuf/32768,44100);
            start_music = @()play(a,floor(start_time*44100+1));
            sample = @()a.currentSample;
        else
            start_music = @tic;
            sample = @()floor((start_time+toc)*44100+1);
        end
    end
    effects;
    
    if parser.Results.capture
        close(video);
    end
    rmpath('../src');
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