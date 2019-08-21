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
[x,y] = ndgrid(-1:.01:1);
I=image(axes2,zeros(size(x)));    
axes2.Visible = 'off';
alphavalues = (x.^2+y.^2).^1.5/2.8284;    
alpha(I,alphavalues);    



axes3 = create_axes();  
hText = text(0,0,'','FontSize',60,'FontWeight','bold');

play(a)
sample = @()a.currentSample;

beat = 0;
while beat < 320
    beat = sample()/song.rowLen;  
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
    for j = 1:6        
        z = z+z(zoomer(zoom(1),cx),zoomer(zoom(2),cy),1);       
        zoom = sqrt(zoom);
    end
       
    image(axes1,tanh((z/128*min(i/10,1)+envs(1,sample()))/64)*640);    
    axes1.Visible = 'off';
    drawnow;
end

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

newplot(axes1)
mysurf = patch('faces',tri,'vertices',[x(:),y(:),z(:)],'facevertexcdata',z(:),'facecolor',get(axes1,'DefaultSurfaceFaceColor'),'edgecolor',get(axes1,'DefaultSurfaceEdgeColor'),'parent',axes1,'LineWidth',2,'SpecularExponent',25,'SpecularStrength',0.9);                 

hLight = light(axes1);
camup(axes1,[1 0 1]);
daspect(axes1,[1 1 1]);        
camproj(axes1,'perspective')
camva(axes1,75);
camtarget(axes1,[5 5 1]);


credits = {'code:pestis','music:distance','bC!xTPOLM'};
while isplaying(a)
    i = a.currentSample/song.rowLen;  
    synkki = 1-(mod(-i,4)/4)^2;
    part = max(min(ceil((i - 319) / 32),3),1);
    i = i/100;                        

    campos(axes1,[(D+K*sin(W*i))*cos(i),(D+K*sin(W*i))*sin(i),0]);        
    camlight(hLight,'HEADLIGHT');            
    set(hText,'Position',[i/10+envs(5,sample()),0.5,0]);
    set(hText,'String',credits{part});
    drawnow;
end

close all
