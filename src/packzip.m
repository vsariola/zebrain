function packzip(mfile,moutfile)

copyfile(mfile,'q.m');
zip('input.zip','q.m');
delete('q.m');

code = 9;

header = 'f=fopen([mfilename ''.m'']);fseek(f,%d,0);k=fread(f);i=k==%d;k=k-circshift(i,1)*%d;k=k(~i);f=fopen(''w'',''w'');fwrite(f,k);fclose(f);unzip w;rehash;q;delete w;delete q.m\n%%';

header = sprintf(header,length(header)-3,code,code);

fin = fopen('input.zip');
d = fread(fin);
fclose(fin);
delete('input.zip');

k = [];
for i = d'
    if (i>=10 && i<=13) || i == code
        k = [k code i+code];
    else
        k = [k i];
    end   
end

fout = fopen(moutfile,'w');
fwrite(fout,header);
fwrite(fout,k);
fclose(fout);
