closeall = @() close('all');
closeall();

% Init brain
mri = load('mristack');
mri = mri.mristack;
zoomer = @(zoom,x)mod(round(((0:255)-x)/zoom+x),256)+1;
% Init valopallot

[xgrid,dummy]=ndgrid(linspace(-3,3,256));

N={'units','normalized','position',[0 0 1 1]};
N2={'visible','off'};
figure(N{:},'WindowState','fullscreen', 'MenuBar', 'none', 'ToolBar', 'none');

a1=axes(N{:},N2{:});        

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
mysurf = trisurf(tri,x,y,z,'LineWidth',2,'SpecularExponent',25,'SpecularStrength',0.9);                 

colormap bone    
colormap(interp1(1:64,colormap,1:.1:64));

hLight = light;
camup([1 0 1]);
daspect([1 1 1]);        
camproj('perspective')
camva(75);
camtarget([5 5 1]);

a2=axes(N{:},N2{:});            
[x,y] = ndgrid(-1:.01:1);
I=image(a2,zeros(size(x)));    
a2.Visible = 'off';
alphavalues = (x.^2+y.^2).^1.5/2.8284;    
alpha(I,alphavalues);    



a3=axes(N{:},N2{:});  
hText = text(0,0,'','FontSize',60,'FontWeight','bold');


a4=axes(N{:},N2{:}); 