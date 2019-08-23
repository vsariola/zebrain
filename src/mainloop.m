a = audioplayer(s/32768,44100);

DIA = 10;
A = 3.5;
K = 5;
W = 3;

mri_data_for_iso = load('mri');
mri_smoothed = smooth3(squeeze(mri_data_for_iso.D));
xx = linspace(-1,1,128)*30;
zz = linspace(-.4,.4,27)*30;
head = isosurface(xx,xx,zz,mri_smoothed,5);

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

figure('WindowState','fullscreen', 'MenuBar', 'none', 'ToolBar', 'none');

create_axes=@()axes('units','normalized','position',[0 0 1 1],'FontWeight','bold','color',[0,0,0],'visible','off');        


axes1 = create_axes(); 

colormap bone    
colormap(interp1(1:64,colormap,1:.1:64));

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


tri = delaunay(u,v);

x = (cos(-u)*A+K*sin(W*v)+DIA).*cos(v);
y = (cos(-u)*A+K*sin(W*v)+DIA).*sin(v);
z = sin(-u)*A;

makepatch = @(f,v)patch('faces',f,'vertices',v,'facevertexcdata',z(:),'facecolor',get(axes2,'DefaultSurfaceFaceColor'),'edgecolor',get(axes2,'DefaultSurfaceEdgeColor'),'parent',axes2,'SpecularExponent',25,'SpecularStrength',0.9,'LineStyle','none','Marker','.','MarkerSize',10);                 
mysurf = makepatch(tri,[x(:),y(:),z(:)]);

headcaps = patch(isocaps(xx,xx,zz,mri_smoothed, 5), 'FaceColor', 'k', 'EdgeColor', 'none','Visible','off');

axes2.Color = 'none';

xx = head.vertices(:,1)*Inf;
hold on;
hscat = scatter3(xx,xx,xx,50,'k.');


hLight = light(axes2);
camup(axes2,[1 0 1]);
daspect(axes2,[1 1 1]);        
camproj(axes2,'perspective')
camva(axes2,75);
camtarget(axes2,[5 5 1]);
credits = {'','bC! vs TPOLM:zebrain',[],[],'code:pestis','music:distance','4096b of MATLAB',[],[]};
hText = text(3,7,-1,'','FontSize',50);
axes3 = create_axes();            
[x,y] = ndgrid(-1:.01:1);
I=image(axes3,zeros(size(x)));    
axes3.Visible = 'off';
alphavalues = (x.^2+y.^2).^1.3/2;    
alpha(I,alphavalues);    

play(a)
sample = @()a.currentSample;

scene_counter = 0;
kick_was_active = 0;

part = 0;
pattern = 0;
while pattern < song.endPattern
    beat = sample()/song.rowLen;  
    pattern = beat / 32;
    prevpart = part;
    part = pattern / 4;
    i = beat/30;
    cx = cos(i)*127+127;
    cy = sin(i)*127+127;
    
    time = pi*pattern/34.5;
    fade = min(max(sin(time),0)^.3,mod(beat,128));
    h=xgrid+xgrid'*1i;
    for f=0:2
        z=0;
        for kind=1:4
            z=z+1./(h-.3*sin(time*kind)*exp(1i*kind+time+f));
        end
        h=h-3./z;
    end
    z = 256-sqrt(abs(z))*200;
    
    alphaBrain = mod(i,1);
    ind = mod(floor(i),20)+1;
    z = z+double(mrist(:,:,ind))*(1-alphaBrain)+double(mrist(:,:,ind+1))*alphaBrain;    
    zoom = envs(5:6,sample()).*[0.2;0.05]+1;
    for angle = 1:4      
        z = z+z(zoomer(zoom(1),cx),zoomer(zoom(2),cy),1);       
        zoom = sqrt(zoom);
    end
       
    image(axes1,tanh((z/80*fade+envs(1,sample()))/64)*640+envs(7,sample())*400);    
    axes1.Visible = 'off';

    kick_is_active = envs(5,sample()) > 0;
    kick_trigger = kick_is_active & ~kick_was_active;
    kick_was_active = kick_is_active;
   
    scene_counter = scene_counter + kick_trigger;
        
    angle = beat/100 + scene_counter + 1;                        

    campos(axes2,[(DIA+K*sin(W*angle))*cos(angle),(DIA+K*sin(W*angle))*sin(angle),0]);        
    camlight(hLight,'HEADLIGHT');                
    floored = floor(part+1);
    hText.String = credits{floored};
    hText.FontSize = (30+sin(scene_counter)*15);
    
    view_matrix = view(axes2);
    screen_z = view_matrix * [0;0;1;0];
    xy = screen_z(1:2)/screen_z(3);
    rot = -atan2d(xy(1),xy(2));     
    hText.Rotation = rot;
    bar = sin(pi*part)^2^.1;     
    linestyles = {'none','-'};
    if prevpart < 5 && part >= 5
        headcaps.Visible = 'on';
        alpha(headcaps,0.5);
    end
    if part > 6
        mysurf.Marker = 'none';
    end
    mysurf.LineStyle = linestyles{(part >= 1 && part < 5)+1};    
    facecolorsync = interp1([0,2,2.01,3.5,4,10],[0,0,1,1,0,0],part);
    alpha(mysurf,min((envs(5,sample())+0.5)*facecolorsync,1));

    time = max(part-3,0);
    blending = min(max(part-4,0),1);
    angle = omega*time;  
    hscat.XData = headv(:,1)*blending+(DIA+K*sin(W*angle)).*cos(angle).*(1-blending);
    hscat.YData = headv(:,2)*blending+(DIA+K*sin(W*angle)).*sin(angle).*(1-blending)+time*cos(omega2*time)*A.*(1-blending);
    hscat.ZData = headv(:,3)*blending+time*sin(omega2*time)*A.*(1-blending);    
    drawnow;
end

close all
