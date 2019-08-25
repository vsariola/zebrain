function demo_capture
    global frame video sample s
    loadsong;                    
    if ~exist('songcache.mat','file')
        [s,envs] = player(song);
        save('songcache.mat','s','envs');
    else
        load('songcache.mat');
    end       
    mkdir('output');
    audiowrite('output/audio.wav',s'/32768,44100)
    frame = 1;
    video = VideoWriter('output/video.avi','Motion JPEG AVI');
    video.FrameRate = 60;
    video.Quality = 95;
    open(video);   
    sample = @()1;    
    draw=@my_drawnow;
    a = audioplayer(s/32768,44100);
    start_music = @()play(a);
    mainloop      
    close(video);      
end

function my_drawnow()   
    global frame video sample s
    frame = frame + 1;
    sample = @()min(max(frame*44100/60,1),size(s,2));
    drawnow();
    f = getframe(gcf);
    writeVideo(video,f);    
    disp(sample());    
end