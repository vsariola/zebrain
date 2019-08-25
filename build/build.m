function build

    outputdir = 'output/';
    outputname = 'demo_singlefile';

    if ~exist(outputdir,'dir')
        mkdir(outputdir);
    end

    generateSong;
    songm = readfile('../src/loadsong.m');  
    demom = readfile('../src/demo.m');
    playerm = readfile('../src/player.m');     
    camerasetupm = readfile('../src/camera_setup.m');     
    demom = strrep(demom,'loadsong',songm);        
    demom = strrep(demom,'mainloop',readfile('../src/mainloop.m'));      
    demom = [demom newline playerm newline camerasetupm];    
    
    outputfilem = [outputdir outputname '_unminified.m'];
    writefile(outputfilem,demom);
    
    demom = minify(demom,{'endPattern','songData','mCurrentCol','player','gensync','demo','indexCell','indexArray','createNote','row','col','time'});

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
