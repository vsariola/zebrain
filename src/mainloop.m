DIA = 10;
A = 3.5;
K = 5;
W = 3;
rng(0);

mri_data_for_iso = load('mri');
mri_smoothed = smooth3(squeeze(mri_data_for_iso.D));
xx = linspace(-1,1,128)*30;
zz = linspace(-.4,.4,27)*30;
head = isosurface(xx,xx,zz,mri_smoothed,5);
interpolate = @(x,v,xq)interp1(x,v,xq,[],'extrap');
headv = head.vertices;
omega = randn(size(headv,1),1)*2;
omega2 = randn(size(headv,1),1)*.5;

% Init brain
mrist = load('mristack');
mrist = mrist.mristack;
zoomer = @(zoom,x)mod(round(((0:255)-x)/zoom+x),256)+1;
% Init valopallot

xrange = linspace(-3,3,256);
[xgrid,dummy]=ndgrid(xrange);

fig = figure('WindowState','fullscreen', 'MenuBar', 'none', 'ToolBar', 'none');

create_axes=@()axes('units','normalized','position',[0 0 1 1],'FontWeight','bold','color',[0,0,0],'visible','off');        


axes1 = create_axes(); 

colormap bone    
colormap(interpolate(1:64,colormap,1:.1:64));

axes2 = create_axes();
axes2.XAxis.Color = [0 0 0];
axes2.YAxis.Color = [0 0 0];
axes2.ZAxis.Color = [0 0 0];
u = rand(9e2,1)*2*pi;
v = rand(9e2,1)*2*pi;
uu = linspace(0,2*pi,10)';
vv = uu*0;
u = [u;uu;uu;vv;vv+2*pi];
v = [v;vv;vv+2*pi;uu;uu];


triangles = delaunay(u,v);

grix = (cos(-u)*A+K*sin(W*v)+DIA).*cos(v);
gridy = (cos(-u)*A+K*sin(W*v)+DIA).*sin(v);
zz = sin(-u)*A;

makepatch = @(f,v,c,parent)patch('faces',f,'vertices',v,'facevertexcdata',c,'facecolor',get(axes2,'DefaultSurfaceFaceColor'),'edgecolor',get(axes2,'DefaultSurfaceEdgeColor'),'parent',parent,'SpecularExponent',25,'SpecularStrength',0.9,'LineStyle','-','Marker','.','MarkerSize',10);                 
mysurf = makepatch(triangles,[grix(:),gridy(:),zz(:)],zz(:),axes2);

axes2.Color = 'none';

xx = head.vertices(:,1)*Inf;
hold on;
hscat = scatter3(xx,xx,xx,50,'k.');


hLight = light(axes2);
camup(axes2,[1 0 1]);
daspect(axes2,[1 1 1]);        
camproj(axes2,'perspective')
camva(axes2,75);
camtarget(axes2,[8 0 1]);

credits = {'','bC!&TPOLM|Zebrain','','','','4096 bytes|MATLAB|Demosplash 2019','','code|pestis/bC!,music|distance/TPOLM',''};
hText = text(10,4,-1,'','VerticalAlign','middle','HorizontalAlign','center','FontName','Courier New');

% Init viivat
grp = hgtransform('Parent',axes2);
tdata = load('trimesh3d');
hline = makepatch(tdata.tri,[tdata.x(:),tdata.y(:),tdata.z(:)]*3,1,grp);
hline.FaceAlpha = 0.1;
hline.Marker = 'none';
hline.LineStyle = 'none';
hline.FaceColor = 'w';
hline.SpecularStrength = 0;
axes3 = create_axes();            
[grix,gridy] = ndgrid(-1:.01:1);
I=image(axes3,zeros(size(grix)));    
axes3.Visible = 'off';
alphavalues = (grix.^2+gridy.^2).^1.3/2;    
alpha(I,alphavalues);    



triggers = envs & ~[zeros(7,1),envs(:,1:(end-1))];
sum_triggers = cumsum(triggers,2);

start_music();
part = 0;
pattern = 0;
while pattern < song.endPattern
    beat = sample()/song.rowLen;  
    pattern = beat / 32;
    prevpart = part;
    part = pattern / 4;
    scene_counter = sum_triggers(5,sample());
    cx = cos(part)*127+127;
    cy = sin(part)*127+127;
    
    kerroin = interpolate([0,6,10],[1,1,2],part)^2;
    
    time = pi*pattern/34.5;
    fade = max(sin(time),0)^.3;
    h=xgrid+xgrid'*1i;
    for f=0:2
        zz=0;
        for kind=[1:3,5]
            zz=zz+1./(h-.3*sin(time*kind)*exp(1i*kind/kerroin+time+f-envs(5,sample())));
        end
        h=h-3./zz;
    end
    zz = 256-sqrt(abs(zz))*200;
    
    brain_index = -cos(pi*part/4)*9.9+11;
    alphaBrain = mod(brain_index,1);
    ind = floor(brain_index);
    zz = zz+double(mrist(:,:,ind))*(1-alphaBrain)+double(mrist(:,:,ind+1))*alphaBrain;    
    zoom = envs(6,sample()).*0.05+1;
    for angle = 1:4      
        zz = zz+zz(zoomer(zoom,cx),zoomer(zoom,cy),1);       
        zoom = sqrt(zoom);
    end
       
    image(axes1,tanh((zz/80*fade+envs(1,sample()))/64)*640+envs(7,sample())*400);    
    axes1.Visible = 'off';
    
    angle = beat/100 + scene_counter + 1;                        

    campos(axes2,[(DIA+K*sin(W*angle))*cos(angle),(DIA+K*sin(W*angle))*sin(angle),0]);        
    camlight(hLight,'HEADLIGHT');                
    floored = floor(part+1);
    str = credits{floored};
    indices = ((1:length(str))-1)/3;
    modded =  mod(beat,128);
    hText.String = split(str(indices > modded-105 & indices < modded),',');    
    
    view_matrix = view(axes2);
    screen_z = view_matrix * [0;0;1;0];
    xy = screen_z(1:2)/screen_z(3);
    rot = -atan2d(xy(1),xy(2));     
    hText.Rotation = rot;
    
    hText.FontSize = fig.Position(3)/50;
    
    bar = sin(pi*part)^2^.1;      
    facecolorsync = interpolate([0,2,2.01,3.5,4,10],[0,0,1,1,0,0],part);
    alpha(mysurf,min((envs(5,sample())+0.5)*facecolorsync,1));
    mysurf.EdgeAlpha = interpolate([0,1,1.5,4,5,10],[0,0,1,1,0,0],part);
    mulju = interpolate([0,5,6,9],[0,0,.5,.5],part);
    time = max(part-3,0);
    blending = min(max(part-4,0),1)^.2;
    angle = omega*time;  
    point_b = [(DIA+K*sin(W*angle)).*cos(angle),(DIA+K*sin(W*angle)).*sin(angle),time*sin(omega2*time)*A];
    blended = headv * blending + point_b * (1-blending);
    muljuttu = blended + mulju*sin(blended*sin(time+[.2,1.1,.3;.4,.3,.9;1.2,.5,.1])+[.3,.4,.5]*time);
    hscat.XData = muljuttu(:,1);
    hscat.YData = muljuttu(:,2); 
    hscat.ZData = muljuttu(:,3);
    drawnow();
    grp.Matrix =  makehgtform('zrotate',pattern)*makehgtform('translate',0,0,(part-7)*100);
end

close all
