
linspc = @linspace;
interpolate = @(a,b,c)interp1(a,b,c,[],'extrap');
mri_data_for_iso = load('mri');
smoothed_mri = smooth3(squeeze(mri_data_for_iso.D));
head = isosurface(linspc(-1,1,128)*30,linspc(-1,1,128)*30,linspc(-1,1,27)*60,smoothed_mri,5);
headv = head.vertices;
omega = randn(size(headv));

% Init brain
mrist = double(interp3(smoothed_mri,1));
zoomer = @(zoom,x)mod(round(((0:254)-x)/zoom+x),255)+1;
% Init valopallot

xrange = linspc(-3,3,255);
[xgrid,~]=ndgrid(xrange);

create_axes=@()axes('position',[0,0,1,1],'Visible','off');        


axes1 = create_axes(); 

mymap = interpolate([0,130,255],[0,0,0,0;.4,.6,.7,.9;1,1,1,1],0:255);
colormap(mymap(:,[1,2,3]));
im = image(uint8(xgrid));    
axes1.Visible = 'off';

axes2 = create_axes();

colormap(axes2,mymap(:,[4,3,1]));

uu = linspc(0,1,10)';
vv = uu*0;
cu = [rand(9e2,1);uu;uu;vv;vv+1]*2*pi+1e-6;
cv = [rand(9e2,1);vv;vv+1;uu;uu]*2*pi;

comp = sin(-cu)*3.5;

makepatch = @(f,v,c,a,p,s,l,m)patch('faces',f,'vertices',v,'facevertexcdata',c,'facecolor',a,'edgecolor','k','parent',p,'specularexponent',5,'specularstrength',s,'linestyle',l,'Marker',m);                 
toruspatch = makepatch(delaunay(cu,cv),[(cos(-cu)*3.5+5*sin(3*cv)+10).*cos(cv),(cos(-cu)*3.5+5*sin(3*cv)+10).*sin(cv),comp],comp(:)+6,'flat',axes2,.7,'-','.');

hold on;
hscat = scatter3(headv(:,1),headv(:,1),headv(:,1),1,'k.','Visible','off');

metaballs = makepatch([],[],[],'w',axes2,.7,'none','none');
metaballs.Visible = 'off';
metax = -4:.5:4;
[metaxx,metayy,metazz] = ndgrid(metax);

hLight = light(axes2);
camera_setup;

% Init viivat
grp = hgtransform('Parent',axes2);
tdata = load('trimesh3d');
fanpatch = makepatch(tdata.tri,[tdata.x(:),tdata.y(:),tdata.z(:)]*3,1,[.9,.7,.4],grp,1,'none','none');
fanpatch.Visible = 'off';

hline = line(zeros(4000,1),zeros(4000,1),zeros(4000,1),'Color',[1,1,1,.5],'LineWidth',5);
hline.Visible = 'off';

linegroup = hgtransform('Parent',axes2);
angle = linspc(0,2*pi,100);
lx = [cos(angle);cos(angle);angle*nan]*50;
ly = [sin(angle);sin(angle);angle*nan]*50;
lz = [12+rand(size(angle))+floor(rand(size(angle))*5)*32;28+rand(size(angle))+floor(rand(size(angle))*5)*32;angle*nan]*50;
makeline = @(m)line(lx(:)*m,ly(:)*m,lz(:),'Color',[1,1,1,.2],'Parent',linegroup);
hbars = arrayfun(makeline,1.04 .^ (1:6));

axes3 = create_axes();            
[gridx,gridy] = ndgrid(-1:.01:1);   
alpha( image(axes3,zeros(size(gridx))),(gridx.^2+gridy.^2)/2);    
axes3.Visible = 'off'; 

axes4 = create_axes();
camera_setup;


texts = {'\___\zz\/z_\_z_z__\z_z_zzz.z~z\/\_·z/\zzz\z\-\/z\\z\z\zz.','__z__z\__z_z__.z_zz~z/_\/__\/z\´\_\\\z\','4096 bytesz|zMATLABz|zDemosplash 2019','.s$s,s$s,~¶§§§§§§§²~`§§§§P´~`§´','m/Bits''n''Bites~p01~Brothomstates~Kooma~Orange~CNCD~NoooN','___\¯¯¯¯¯¯¯¯¯¯¯\z¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯/___~__\zzz·:zcodez:·zz`zzzz·:zmusicz:·zzzz/__~\zz`zpestisz/zbC!zzzdistancez/zTPOLMz´zz/~\______zzzzzzz·:zasciiz:·zzzzzz_______/~/z:zzzzzzzapolloz/zbC!zzzzz:zz\~`-----/__________________\----´'};
texttimes = [128,192;152,216;644,734;800,896;808,896;1016,1072];
texttimes = reshape([texttimes;texttimes+4],6,[]);
hTexts = arrayfun(@(x,y,z)text(x,y,z,'','horizontalAlign','center','fontweight','bold','fontname','Courier New','Color','w','interpreter','none'),[10,10,10,20,20,8],[4,4,4,60,60,.5],[4,-1,-1,30,-10,.5]);
hTexts(4).Color = 'r';
rands = rand(1,1000);

sum_triggers = cumsum(envs & ~[zeros(7,1),envs(:,1:(end-1))],2);

start_music();
pattern = 0;
while pattern < 35
    figwidth = fig.Position(3);
    cursample = sample();
    sync = @(c)envs(c,cursample);
    beat = cursample/6615;  
    pattern = beat / 32;
    part = pattern / 4;
    
    time = pi*pattern/34.5;
    h=xgrid+xgrid'*1i;
    for find=0:2
        comp=0;
        for kind=[1:3,5]
            comp=comp+1./(h-.7*sin(time*kind)*exp(1i*kind*(sum_triggers(5,cursample)*2+1)+find));
        end
        h=h-3./comp;
    end
    comp = 256-sqrt(abs(comp))*200;
    
    brain_index = 52*(1-part/9)+1;
    alphaBrain = mod(brain_index,1);
    ind = floor(brain_index);
    comp = comp+max(mrist(:,:,ind)*(1-alphaBrain)+mrist(:,:,ind+1)*alphaBrain,interpolate([0,2,2.5,3,6,8],[0,0,1,1,0,0],part)*255);    
    zoom = sync(6)*.1+1;
    for angle = 1:5     
        comp = comp+comp(zoomer(zoom,cos(part)*50+126),zoomer(zoom+sync(7)*.3,sin(part*1.1)*50+126));       
        zoom = sqrt(zoom);
    end
       
    im.CData = uint8(tanh((comp/80*interpolate([0,224,240,258,259,1024,1104,1120],[0,.6,0,0,1,1,0,0],beat)^.5+sync(1))/64)*256); 

    
    angle = beat/100 + sum_triggers(5,cursample) + 1;                        

    camera_position = [(10+5*sin(3*angle))*cos(angle),(10+5*sin(3*angle))*sin(angle),0];
    campos(axes2,camera_position);        
    campos(axes4,camera_position);
    camlight(hLight,'HEADLIGHT'); 

    for index = 1:6
        str = texts{index};
        not_empty = str ~= '~' & str ~= 'z';
        string_sync = interpolate(texttimes(index,:),[1,0,0,1],beat);
        offset = rands(1:length(str))*.5;
        str_indices = not_empty & string_sync>(.5-offset);
        str(str_indices) = randi([33,47],1,sum(str_indices));
        str(not_empty & string_sync>(1-offset) | str == 'z') = 32;
        hTexts(index).String = split(str,'~');   
        hTexts(index).Rotation = interpolate([0,.3,.9,1.7,2,5.1,5.8,6.2],[37,-23,-35,-19,-21,34,25,37],mod(angle,2*pi)) + (index==6)*25;
        hTexts(index).FontSize = figwidth/50;
        
        hbars(index).LineWidth = (figwidth*(1+sync(7)*2))/150;
    end
       
    toruspatch.FaceAlpha = interpolate([0,258,258.1,448,512,1280],[0,0,.8,.8,0,0],beat);
    toruspatch.EdgeAlpha = interpolate([0,4,6,16,17,40],[0,0,1,1,0,0],pattern);
    toruspatch.AmbientStrength = min(sync(5)+.5,1);
    toruspatch.MarkerSize = figwidth/180;
    time = part-3;
    blending = min(max(part-4,0),1)^.2;
    angle = omega(:,1)*2*time;  
    blended = headv * blending + [(10+5*sin(3*angle)).*cos(angle),(10+5*sin(3*angle)).*sin(angle),(time+sync(7)*.3)*sin(omega(:,2)/2*time)*3.5] * (1-blending);
    muljuttu = blended + interpolate([0,6,9],[0,0,3],part)*sin(blended*.5*sin(time+[.2,1.1,.3;.4,.3,.9;1.2,.5,.1])+[.3,.4,.5]*time);
    hscat.XData = muljuttu(:,1);
    hscat.YData = muljuttu(:,2); 
    hscat.ZData = muljuttu(:,3);
    
    linex = linspc(-2,2,4000) + (part-7)*4;
    liner = sin(.5*sin(linex*2)+.3*sin(linex*3)+.4*sin(linex*4)) .* linex .* linex * 4;
    lineangle = sin(.7*sin(linex*5)+.4*sin(linex*6)+.3*sin(linex*4))*10;
    hline.XData = linex*15+10;    
    hline.YData = liner .* sin(lineangle) + 20;
    hline.ZData = liner .* cos(lineangle) + 7;
          
    draw();
   
    if part>4 && part<6
        ballcenters = sin(pi*reshape(1:15,5,3)*part)*2;
        metavalue = zeros(size(metaxx));
        for i = 1:5
            metavalue= metavalue + .2./sqrt((metaxx-ballcenters(i,1)) .^ 4 + (metayy-ballcenters(i,2)) .^ 4 + (metazz-ballcenters(i,3)) .^ 4);
        end
        metapos = [8,0,0]-camera_position;
        metapos = metapos * 8 / norm(metapos) + camera_position;
        metafv = isosurface(metax+metapos(1),metax+metapos(2),metax+metapos(3)+(pattern-20).^3/2,metavalue,.18);
        metaballs.Vertices = metafv.vertices;
        metaballs.Faces = metafv.faces;   
        metaballs.FaceColor = [.9,.7,.4]-sync(7)*.4;
        metaballs.Visible = 'on';
    else
        metaballs.Visible = 'off';
    end
    if part>3
        hscat.Visible = 'on';
        hscat.SizeData = figwidth/20;
    end
       
    if part>6 && part<8
        hline.Visible = 'on';
    else
        hline.Visible = 'off';
    end
    
    if pattern>17.1
        fanpatch.Visible = 'on';
        toruspatch.Visible = 'off';
    end
        
    if part>5.5
        linegroup.Visible = 'off';
    end
    
    linegroup.Matrix = makehgtform('translate',0,0,(512-beat)*50);        

   
    fanpatch.FaceAlpha = interpolate([0,5,5.5,7.34,7.4,9],[0,0,.4,.4,0,0],part);
    grp.Matrix = makehgtform('yrotate',pi/2)*makehgtform('zrotate',pattern);    
end

close all
