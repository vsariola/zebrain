f = fopen('../data/styge');d = fread(f,'uint8=>uint8');fclose(f);
song = loadSoundBoxBin(d);
song.endPattern = song.endPattern + 4;
exportMat(song,'../src/loadsong.m');
rehash;