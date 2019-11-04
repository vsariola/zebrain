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
    
    playersrc = readfile('../src/player.m');
    s1 = find_symbols(playersrc,{},{'mMixBuf','envs'});
    n1 = arrayfun(@getcode,1:length(s1),'UniformOutput',false);    
    
    effectssrc = readfile('../src/effects.m');
    effectssrc = strrep(effectssrc,'draw()','drawnow');
    effectssrc = strrep(effectssrc,'sample()','audio.currentSample;');
    effectssrc = strrep(effectssrc,'start_music()','play(audio)');
    s2 = find_symbols(effectssrc,{},{'mMixBuf','envs'});
    n2 = arrayfun(@getcode,1:length(s2),'UniformOutput',false);    
    
    demom = readfile('demo.m');     
    demom = strrep(demom,'song;', 'songdata=tmpsong;');              
    demom = strrep(demom,'draw = @drawnow;','');
    demom = strrep(demom,'sample = @()audio.currentSample;','');
    demom = strrep(demom,'start_music = @()play(audio);','');       
    demom = [newline demom newline readfile('../src/camera_setup.m')];            
    s3 = find_symbols(demom,{'demo','camera_setup','mMixBuf','envs'},[s1,s2]);
    n3 = arrayfun(@getcode,(1:length(s3))+max(length(n1),length(n2)),'UniformOutput',false);
    
    
    demom = replace_symbols(demom,s3,n3);
    demom = strrep(demom,'player;',replace_symbols(playersrc,[s1,s3],[n1,n3]));           
    demom = strrep(demom,'effects;',replace_symbols(effectssrc,[s2,s3],[n2,n3]));      
    songdata = readfile('../src/song.m');        
    
    outputfile = [outputdir outputname '.m'];    
    writefile(outputfile,demom);
           
    % s3 = find_symbols(demom,{'song','endPattern','songData','mCurrentCol','player','gensync','demo','indexCell','indexArray','createNote','row','col','time','camera_setup','xgrid'},[s1,s2]);   ´
    
    demom = minify(demom);              
    demom = strrep(demom,'tmpsong;',songdata(10:end-1));        
    demom = demom(2:end);    
    
    outputfilemin = [outputdir outputname '.min.m'];
    writefile(outputfilemin,demom);
    
    outputfilep = [outputdir outputname '.p'];
    crunch(outputfilemin,'output',outputfilep,'use_comma',false);   
    
    if ~exist(distdir,'dir')
        mkdir(distdir);
    end
    copyfile(outputfilep,distdir);
    
    if makeopt
        demooptm = readfile('demo_opt.m');     
        demooptm = strrep(demooptm,'song;', readfile('song.m'));        
        demooptm = strrep(demooptm,'player;',readfile('../src/player.m'));        
        demooptm = strrep(demooptm,'effects;',readfile('../src/effects.m'));      
        demooptm = [newline demooptm newline readfile('../src/camera_setup.m')];  
        demooptm = strrep(demooptm,'(''cache'',true)','(''cache'',false)'); 
        demooptm = minify(demooptm,[s1,s2,s3],[n1,n2,n3]);    
        demooptm = strrep(demooptm,'perspective','p');
        demooptm = demooptm(2:end); 

        outputfileopt = [outputdir outputname '_opt.m'];
        writefile(outputfileopt,demooptm);
        origdir = cd;
        cd(outputdir);
        pcode([outputname '_opt'],'-inplace');
        cd(origdir);
        
        outputfilepopt = [outputdir outputname '_opt.p'];        
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

function ret = getcode(i)
    valids = [char(97:122) char(65:88)]; % a-z A-X, the variable
    % has to start with a letter. We don't need underscores and digits
    % because they can only be used when there is two or more letters
    % and if we hit two letters, it's unlikely we hit three
    
    n = length(valids);        
    ret = [];
    for j = 1:10
        if (i <= n)            
            ret = [valids(i) ret];    
            return;
        else
            c = mod(i-1,n);
            ret = [valids(c+1) ret];        
            i = (i -1- c)/n;               
        end
    end
end