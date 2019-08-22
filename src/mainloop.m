a = audioplayer(s/32768,44100);    

% Init brain
mri = load('mristack');
mri = mri.mristack;
zoomer = @(zoom,x)mod(round(((0:255)-x)/zoom+x),256)+1;
% Init valopallot

[xgrid,dummy]=ndgrid(linspace(-3,3,256));

figure('WindowState','fullscreen', 'MenuBar', 'none', 'ToolBar', 'none');

create_axes=@()axes('units','normalized','position',[0 0 1 1],'visible','off');        


axes1 = create_axes(); 

colormap bone    
colormap(interp1(1:64,colormap,1:.1:64));

axes2 = create_axes();

u = rand(9e2,1)*2*pi;
v = rand(9e2,1)*2*pi;
uu = linspace(0,2*pi,10)';
vv = uu*0;
u = [u;uu;uu;vv;vv+2*pi];
v = [v;vv;vv+2*pi;uu;uu];
D = 10;
A = 3.5;
K = 5;
W = 3;

tri = delaunay(u,v);

x = (cos(-u)*A+K*sin(W*v)+D).*cos(v);
y = (cos(-u)*A+K*sin(W*v)+D).*sin(v);
z = sin(-u)*A;

mysurf = patch('faces',tri,'vertices',[x(:),y(:),z(:)],'facevertexcdata',z(:),'facecolor',get(axes2,'DefaultSurfaceFaceColor'),'edgecolor',get(axes2,'DefaultSurfaceEdgeColor'),'parent',axes2,'LineWidth',2,'SpecularExponent',25,'SpecularStrength',0.9);                 

hLight = light(axes2);
camup(axes2,[1 0 1]);
daspect(axes2,[1 1 1]);        
camproj(axes2,'perspective')
camva(axes2,75);
camtarget(axes2,[5 5 2]);

credits = {'bC!xTPOLM','zebrain',[],[],'code:pestis','music:distance','size:4096b','platform:MATLAB',[]};

axes3 = create_axes();            
[x,y] = ndgrid(-1:.01:1);
I=image(axes3,zeros(size(x)));    
axes3.Visible = 'off';
alphavalues = (x.^2+y.^2).^1.3/2;    
alpha(I,alphavalues);    



axes4 = create_axes();  

hText = text(0,0,'','VerticalAlign','middle','HorizontalAlign','center','FontWeight','bold');


play(a)
sample = @()a.currentSample;

scene_counter = 0;
kick_was_active = 0;

pattern = 0;
while pattern < 33
    beat = sample()/song.rowLen;  
    pattern = beat / 32;
    part = pattern / 4;
    i = beat/30;
    cx = cos(i)*127+127;
    cy = sin(i)*127+127;
    
    t = i/10;
    h=xgrid+xgrid'*1i;
    for f=0:2
        z=0;
        for k=1:4
            z=z+1./(h-.3*sin(t*k)*exp(1i*k+t+f));
        end
        h=h-3./z;
    end
    z = 256-sqrt(abs(z))*200;
    
    alphaBrain = mod(i,1);
    ind = mod(floor(i),20)+1;
    z = z+double(mri(:,:,ind))*(1-alphaBrain)+double(mri(:,:,ind+1))*alphaBrain;    
    zoom = envs(5:6,sample()).*[0.2;0.05]+1;
    for j = 1:4      
        z = z+z(zoomer(zoom(1),cx),zoomer(zoom(2),cy),1);       
        zoom = sqrt(zoom);
    end
       
    image(axes1,tanh((z/80*min(i/10,1)+envs(1,sample()))/64)*640);    
    axes1.Visible = 'off';

    kick_is_active = envs(5,sample()) > 0;
    kick_trigger = kick_is_active & ~kick_was_active;
    kick_was_active = kick_is_active;
   
    scene_counter = scene_counter + kick_trigger;
    
    i = a.currentSample/song.rowLen;  
    synkki = 1-(mod(-i,4)/4)^2;   
    j = i/100 + scene_counter;                        

    campos(axes2,[(D+K*sin(W*j))*cos(j),(D+K*sin(W*j))*sin(j),0]);        
    camlight(hLight,'HEADLIGHT');                
    floored = floor(part+1);
    hText.String = credits{floored};
    bar = sin(pi*part)^2^.1;
    hText.Position = [sin(2*floored),sin(3*floored),0]*.2+.5;
    hText.FontSize = bar*69+0.1;
    hText.Rotation = (.9-bar)*99;
    mysurf.LineWidth= envs(3,sample())/10+1;
    alpha(mysurf,min(envs(5,sample())+(scene_counter>0)*0.5,1));
    drawnow;
end

close all
