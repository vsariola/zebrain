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
    demom = strrep(demom,'loadsong;',songm);
    demom = [demom char(10) playerm];

    outputfilem = [outputdir outputname '.m'];
    writefile(outputfilem,demom);
    pcode(outputfilem);
    outputfilep = [outputname '.p'];    
    movefile(outputfilep,outputdir);
    delete(outputfilem);
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
