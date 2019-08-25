f = fopen('../data/demo_song');d = fread(f,'uint8=>uint8');fclose(f);
song = loadSoundBoxBin(d);
for i = 1:length(song.songData)
    if song.songData{i}{1}(1) == 3 % Third oscillator was removed, fourth oscillator is now third
        song.songData{i}{1}(1) = 2;
    end
    if song.songData{i}{1}(5) == 3 % Third oscillator was removed, fourth oscillator is now third
        song.songData{i}{1}(5) = 2;
    end
    p = song.songData{i}{2};
    c = song.songData{i}{3}; 
    up = unique(p);
    usedPatterns = up(up > 0);
    l = 1:length(c);
    drop = ismember(l,usedPatterns);
    finalc = c(drop);
    mapping = zeros(1,length(c));
    mapping(l(drop))=1:length(finalc);
    zeromapping = [0 mapping];
    song.songData{i}{2} = zeromapping(p+1);
    song.songData{i}{3} = finalc;
    if (any(mapping == 0)) 
       fprintf('On channel %d, found unused patterns: ',i);
       for j = 1:length(mapping)
           if (mapping(j) == 0)
               fprintf('%d ',j)
           end
       end
       fprintf('\n');
    end
end
song.endPattern = song.endPattern + 4;
exportMat(song,'../src/loadsong.m');
rehash;