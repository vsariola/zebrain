function build(make_all)

    if nargin < 1
        make_all = false;
    end

    outputdir = '../build/';
    distdir = '../dist/';
    outputname = 'zebrain';

    if ~exist(outputdir,'dir')
        mkdir(outputdir);
    end

    generate_song;
    
    build_file('demo.m',[outputdir outputname]);
    outputfilep = [outputdir outputname '.p'];
    crunch([outputdir outputname '.min.m'],'output',outputfilep,'use_comma',false);   
    
    if ~exist(distdir,'dir')
        mkdir(distdir);
    end
    copyfile(outputfilep,distdir);
    
    if make_all
        dbgout = [outputdir outputname '_dbg'];
        build_file('demo_dbg.m',dbgout,true,true);   
        origdir = cd;
        cd(outputdir);
        pcode([outputname '_dbg.m'],'-inplace');
        cd(origdir);
        copyfile([dbgout '.p'],[distdir outputname '_dbg.p']);
        
        noiptout = [outputdir outputname '_noipt'];
        build_file('demo.m',noiptout,false);
        crunch([noiptout '.min.m'],'output',[noiptout '.p'],'use_comma',false);  
        copyfile([noiptout '.p'],distdir);        
        
        dbgout_noipt = [outputdir outputname '_dbg_noipt'];
        build_file('demo_dbg.m',dbgout_noipt,false,true);   
        origdir = cd;
        cd(outputdir);
        pcode([outputname '_dbg_noipt.m'],'-inplace');
        cd(origdir);
        copyfile([dbgout_noipt '.p'],[distdir outputname '_dbg_noipt.p']);
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

function build_file(input_file,output_file,use_ipt,debug)
    if nargin < 3
        use_ipt = true;
    end
    if nargin < 4
        debug = false;
    end
    
    playersrc = readfile('../src/player.m');
    
    effectssrc = readfile('../src/effects.m');
    if ~debug       
        effectssrc = strrep(effectssrc,'draw()','drawnow');
        effectssrc = strrep(effectssrc,'sample()','audio.currentSample;');
        effectssrc = strrep(effectssrc,'start_music()','play(audio)');
    end
    if ~use_ipt % patch the code to not use the image processing code, effectively negating commit #5e828d4
        effectssrc = strrep(effectssrc,'xx = load(''mristack'');','');
        effectssrc = strrep(effectssrc,'mri_scaled = smooth3(xx.mristack,''box'',5);','mri_scaled = double(interp3(yy,1));');
        effectssrc = strrep(effectssrc,'zoomer = @(a,b)mod(round(((0:255)-b)/a+b),256)+1;','zoomer = @(a,b)mod(round(((0:254)-b)/a+b),255)+1;');
        effectssrc = strrep(effectssrc,'[xgrid,~] = ndgrid(linspc(-3,3,256));','[xgrid,~] = ndgrid(linspc(-3,3,255));');
        effectssrc = strrep(effectssrc,'ind = 20*part/9 + 1;','ind = 52*(1-part/9) + 1;');
    end
    
    demom = readfile(input_file);      
    if ~debug
        demom = strrep(demom,'draw = @drawnow;','');
        demom = strrep(demom,'sample = @()audio.currentSample;','');
        demom = strrep(demom,'start_music = @()play(audio);','');  
    else
        demom = strrep(demom,'(''cache'',true)','(''cache'',false)'); % disable caching in the released debug script        
    end
    demom = [newline demom newline readfile('../src/camera_setup.m')];  
    
    songsrc = readfile('../src/song.m');
    
    if ~debug
        [sp,np] = find_symbols(playersrc,{},{'mMixBuf','envs'});   
        [se,ne] = find_symbols(effectssrc,{},{'mMixBuf','envs'});
        [sd,nd] = find_symbols(demom,{'songdata','demo','camera_setup','mMixBuf','envs'},[sp,se],max(length(np),length(ne)));
        demom = replace_symbols(demom,sd,nd);
        playersrc = replace_symbols(playersrc,[sp,sd],[np,nd]);
        effectssrc = replace_symbols(effectssrc,[se,sd],[ne,nd]);
        songsrc = replace_symbols(songsrc,[se,sd],[ne,nd]);        
    end
    demom = strrep(demom,'player;',playersrc);           
    demom = strrep(demom,'effects;',effectssrc);      

    demom_before_min = strrep(demom,'song;',songsrc);    
    outputfile = [output_file '.m'];    
    writefile(outputfile,demom_before_min);
    
    if ~debug
        demom = minify(demom);    
        demom = strrep(demom,'song;',songsrc); % songdata doesn't like minification so we put it there only after minifiers      
        outputfilemin = [output_file '.min.m'];
        writefile(outputfilemin,demom);
    end
end