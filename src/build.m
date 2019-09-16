function build(makeopt)

    if nargin < 1
        makeopt = false;
    end

    outputdir = '../build/';
    distdir = '../dist/';
    outputname = 'zebrain';

    if ~exist(outputdir,'dir')
        mkdir(outputdir);
    end

    generate_song;
    demom = readfile('demo.m');     
    demom = strrep(demom,'song;', 'songdata=tmpsong;');        
    demom = strrep(demom,'player;',readfile('../src/player.m'));        
    demom = strrep(demom,'effects;',readfile('../src/effects.m'));      
    demom = [newline demom newline readfile('../src/camera_setup.m')];        
    
    outputfile = [outputdir outputname '.m'];
    songdata = readfile('../src/song.m');    
    demom2 = strrep(demom,'tmpsong;',songdata(10:end-1));    
    writefile(outputfile,demom2);
    
    demom = strrep(demom,'draw = @drawnow;','');
    demom = strrep(demom,'sample = @()a.currentSample;','');
    demom = strrep(demom,'start_music = @()play(a);','');
    demom = strrep(demom,'draw()','drawnow');
    demom = strrep(demom,'sample()','a.currentSample;');
    demom = strrep(demom,'start_music()','play(a)');
    
    demom = minify(demom,{'song','endPattern','songData','mCurrentCol','player','gensync','demo','indexCell','indexArray','createNote','row','col','time','camera_setup'});    
    demom = strrep(demom,'tmpsong;',songdata(10:end-1));
    
    demom = demom(2:end);    
    
    outputfilemin = [outputdir outputname '.min.m'];
    writefile(outputfilemin,demom);
    
    outputfilep = [outputdir outputname '.p'];
    crunch(outputfilemin,'output',outputfilep,'use_comma',false);   
    
    if makeopt
        demooptm = readfile('demo_opt.m');     
        demooptm = strrep(demooptm,'song;', readfile('song.m'));        
        demooptm = strrep(demooptm,'player;',readfile('../src/player.m'));        
        demooptm = strrep(demooptm,'effects;',readfile('../src/effects.m'));      
        demooptm = [newline demooptm newline readfile('../src/camera_setup.m')];  
        demooptm = strrep(demooptm,'(''cache'',true)','(''cache'',false)'); 
        demooptm = minify(demooptm,{'song','endPattern','songData','mCurrentCol','player','gensync','demo','indexCell','indexArray','createNote','row','col','time','camera_setup'});    
        demooptm = strrep(demooptm,'perspective','p');
        demooptm = demooptm(2:end); 

        outputfileopt = [outputdir outputname '_opt.m'];
        writefile(outputfileopt,demooptm);
        origdir = cd;
        cd(outputdir);
        pcode([outputname '_opt'],'-inplace');
        cd(origdir);
        
        outputfilepopt = [outputdir outputname '_opt.p'];
        if ~exist(distdir,'dir')
            mkdir(distdir);
        end
        copyfile(outputfilep,distdir);
        copyfile(outputfilepopt,distdir)
    end

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
