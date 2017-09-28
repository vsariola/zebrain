outputdir = 'output/';
demofile = 'singlefiledemo';

if ~exist(outputdir,'dir')
    mkdir(outputdir);
end

pcode(demofile);
movefile(sprintf('%s.p',demofile),outputdir);
compress(sprintf('%ssinglefiledemo.p',outputdir),outputdir);

%delete(sprintf('%s%s.p',outputdir,demofile));