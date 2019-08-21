function compress(inputfileparam,varargin)

SEVEN_ZIP = 'c:\Program Files\7-Zip\7z.exe';

invalid_bytes = 10:13;

filefinding = {'none','local','path'};

p = inputParser;
addRequired(p,'inputfileparam',@(x) exist(x,'file'));
addOptional(p,'outputfileparam','',@ischar);
addParamValue(p,'main','Z',@ischar);   
addParamValue(p,'code',9,@(x) ~any(invalid_bytes == x) && x >= 0 && x <= 255);   
addParamValue(p,'shift',9);   
addParamValue(p,'cleanbuild',true);   
parse(p,inputfileparam,varargin{:});

shift = p.Results.shift;
specials = [invalid_bytes p.Results.code];
if any(ismember(mod(specials+shift,256),specials))
    error('The shifted special bytes would overlap');
end

[inputpath,inputname,inputext] = fileparts(p.Results.inputfileparam);
if isempty(inputext)
    inputext = '.m';
end
inputfile = fullfile(inputpath,[inputname inputext]);

[outputpath,outputname,outputext] = fileparts(p.Results.outputfileparam);
if isempty(outputext)
    outputext = inputext;
end
if isempty(outputname)
    outputname = [inputname '_compressed'];
end
if isempty(outputpath)
    if isempty(inputpath)
        outputpath = 'output';
    else
        outputpath = [inputpath '/output'];
    end
end
outputfile = [outputpath '/' outputname '.m'];

if ~exist(outputpath,'dir')
    mkdir(outputpath);
end

mainfilename = sprintf('%s%s',p.Results.main,inputext);
mainfilepath = sprintf('%s/%s',outputpath,mainfilename);
mainzip = sprintf('%s/main.zip',outputpath);
copyfile(inputfile,mainfilepath);
a = cd();
cd(outputpath);
if exist('main.zip','file')
    delete('main.zip');
end
if exist(SEVEN_ZIP,'file')
    command = ['"' SEVEN_ZIP '" a -mx=9 -mtc=off main.zip "' sprintf('%s',mainfilename) '"'];
    system(command);
else
    zip('main.zip',sprintf('%s',mainfilename));
end
cd(a);
if p.Results.cleanbuild
    delete(mainfilepath);
end

header = 'k=fread(fopen([mfilename(''fullpath'') ''.m'']));k=k(%d:end)';

header = [header sprintf(';i=k==%d',p.Results.code)];

if shift > 0
    if any(specials+shift>255)
        header = [header sprintf(';s=mod(k-[i(2:end);0]*%d,256)',shift)];
    else
        header = [header sprintf(';s=k-[i(2:end);0]*%d',shift)];
    end
else
    if any(specials+shift<0)
        header = [header sprintf(';s=mod(k+[i(2:end);0]*%d,256)',-shift)];
    else
        header = [header sprintf(';s=k+[i(2:end);0]*%d',-shift)];
    end
end                          

header = [header ';d=[tempname 47];mkdir(d);t=[d 65]']; % d=.../, t=.../A
header = [header ';fwrite(fopen(t,''w''),s(~i));fclose all'];
header = [header sprintf(';unzip(t,d)')];
header = [header sprintf(';run([d %d]);rmdir(d,''s'')',uint8(p.Results.main))];
header = [header '%%'];

s = length(header)-3;
finalheader = '';
while s ~= length(finalheader)      
    s = s+1;
	finalheader = sprintf(header,s+1);    
end

fin = fopen(mainzip);
d = fread(fin);
fclose(fin);

if p.Results.cleanbuild
    delete(mainzip);
end
   
k = [];
for i = d'
    if ismember(i,specials)
        k = [k mod(i+shift,256) p.Results.code];
    else
        k = [k i];
    end   
end

fout = fopen(outputfile,'w');
fwrite(fout,finalheader);
fwrite(fout,k);
fclose(fout);
