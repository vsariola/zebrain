function build

    outputdir = 'output/';
    outputname = 'demo_singlefile';

    if ~exist(outputdir,'dir')
        mkdir(outputdir);
    end

    generateSong;
    demom = readfile('../src/demo.m');     
    demom = strrep(demom,'loadsong;', readfile('../src/loadsong.m'));        
    demom = strrep(demom,'player;',readfile('../src/player.m'));        
    demom = strrep(demom,'effects;',readfile('../src/effects.m'));      
    demom = [newline demom newline readfile('../src/camera_setup.m')];        
    
    outputfilem = [outputdir outputname '_unminified.m'];
    writefile(outputfilem,demom);
    
    demom = strrep(demom,'draw = @drawnow;','');
    demom = strrep(demom,'sample = @()a.currentSample;','');
    demom = strrep(demom,'start_music = @()play(a);','');
    demom = strrep(demom,'draw()','drawnow');
    demom = strrep(demom,'sample()','a.currentSample;');
    demom = strrep(demom,'start_music()','play(a)');
    
    demom = minify(demom,{'song','endPattern','songData','mCurrentCol','player','gensync','demo','indexCell','indexArray','createNote','row','col','time','camera_setup'});    
    demom = demom(2:end);    
    
    outputfilem = [outputdir outputname '.m'];
    writefile(outputfilem,demom);
    outputfilec = [outputdir outputname '_compressed.m'];
    compress(outputfilem,outputfilec,'cleanBuild',false);    
    rehash
end

function writefile(filename,str)
    f = fopen(filename,'w');
    fwrite(f,str);
    fclose(f);
end

function str = readfile(filename)
    f = fopen(filename);
    str = fread(f,'char=>char')';
    fclose(f);
end
