function build

    outputdir = '../build/';
    outputname = 'zebrain';

    if ~exist(outputdir,'dir')
        mkdir(outputdir);
    end

    generate_song;
    demom = readfile('demo.m');     
    demom = strrep(demom,'song;', readfile('song.m'));        
    demom = strrep(demom,'player;',readfile('../src/player.m'));        
    demom = strrep(demom,'effects;',readfile('../src/effects.m'));      
    demom = [newline demom newline readfile('../src/camera_setup.m')];        
    
    outputfile = [outputdir outputname '.m'];
    writefile(outputfile,demom);
    
    demom = strrep(demom,'draw = @drawnow;','');
    demom = strrep(demom,'sample = @()a.currentSample;','');
    demom = strrep(demom,'start_music = @()play(a);','');
    demom = strrep(demom,'draw()','drawnow');
    demom = strrep(demom,'sample()','a.currentSample;');
    demom = strrep(demom,'start_music()','play(a)');
    
    demom = minify(demom,{'song','endPattern','songData','mCurrentCol','player','gensync','demo','indexCell','indexArray','createNote','row','col','time','camera_setup'});    
    demom = demom(2:end);    
    
    outputfilemin = [outputdir outputname '.min.m'];
    writefile(outputfilemin,demom);
    
    outputfilep = [outputdir outputname '.p'];
    crunch(outputfilemin,'output',outputfilep);   
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
