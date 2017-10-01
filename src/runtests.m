
d = dir('../tests/*.wav');
%profile on;
tic;
for i = 1:length(d) 
    [tmp,name,ext] = fileparts(d(i).name);
    f = fopen(sprintf('../tests/%s',name));
    data = fread(f,'uint8=>uint8');
    fclose(f);
    song = loadSoundBoxBin(data);
    wavegen = player(song);
    wavegen = max(min(wavegen,32767),-32767);     
    wavegen = reshape(wavegen/32768,2,length(wavegen)/2)';        
    [waveload,fs,nbits] = wavread(sprintf('..\\tests\\%s',d(i).name));
    subplot(3,1,1);
    h1 = plot(wavegen);
    title(d(i).name);    
    subplot(3,1,2);
    h2 = plot(waveload);
    subplot(3,1,3);
    l = min(size(wavegen,1),size(waveload,1));
    diff = wavegen(1:l,:) - waveload(1:l,:);
    h3 = plot(diff);        
    if any(abs(diff) > 1e-3)
        disp('Warning: error is quite big for file %s',d(i).name);
    end
    drawnow
    toc;
    %profile viewer;
end