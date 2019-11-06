rng(0); % Initialize rng, so that demo is always the same

%------------------------------------
% Shorthands for often used functions
%------------------------------------
linspc = @linspace; %  handle to shorten linspace
interp = @(a,b,c)interp1(a,b,c,[],'extrap'); % handle to shorten interp1
make_axes = @()axes('position',[0,0,1,1],'Visible','off'); % short hand to make a fullscreen axes
make_patch = @(a,b,c,d,e,f,g,h)patch('faces',a,'vertices',b,'facevertexcdata',c,'facecolor',d,'edgecolor','k','parent',e,'specularexponent',5,'specularstrength',f,'linestyle',g,'Marker',h);                 
text_rands = rand(1,300);

%------------------------------
% Load and process the MRI-data
%------------------------------
% MRI-data is displayed in the background image and it's isosurface'
% vertices are the dots visible in the final scenes 
xx = load('mri');
yy = smooth3(squeeze(xx.D));
ww = isosurface(linspc(-1,1,128)*30,linspc(-1,1,128)*30,linspc(-1,1,27)*60,yy,5); % we find the isosurface of the MRI-data to make a head
head_vert = ww.vertices; % just a short hand for the vertices of the head
omega = randn(size(head_vert)); % the points start as a cloud, omega are the random coordinates in cloud
mri_scaled = double(interp3(yy,1));  % the volume data in the background

%--------------------------------------------------------------------
% Initialize axes1, which contains the background brain & light balls
%--------------------------------------------------------------------
axes1 = make_axes();

zoomer = @(a,b)mod(round(((0:254)-b)/a+b),255)+1; % zoomer is needed for the light balls in the background
[xgrid,~] = ndgrid(linspc(-3,3,255)); % the grid for the light balls in the background

xx = interp([0,130,255],[0,0,0,0;.4,.6,.7,.9;1,1,1,1],0:255);
colormap(xx(:,[1,2,3])); % teal colormap for the background
h_image = image(uint8(xgrid));    
axes1.Visible = 'off'; % image shows the axes, hide the axes again

%----------------------------------------------------------------------
% Initialize axes2, which contains the 3D scene:
% torus, point cloud, metaballs, lasers, wiggly line, fan, light source
%----------------------------------------------------------------------
axes2 = make_axes();

colormap(axes2,xx(:,[4,3,1])); % orange colormap for the objects

% Initialize torus
angle = linspc(0,1,10)'; % cu and cv are the torus uv vertex locations
angle2 = angle*0;
xx = [rand(9e2,1);angle;angle;angle2;angle2+1]*2*pi+1e-6; % u-coordinates
yy = [rand(9e2,1);angle2;angle2+1;angle;angle]*2*pi; % v-coordinates
ww = sin(-xx)*3.5; % colors

h_torus = make_patch(delaunay(xx,yy),[(cos(-xx)*3.5+5*sin(3*yy)+10).*cos(yy),(cos(-xx)*3.5+5*sin(3*yy)+10).*sin(yy),ww],ww(:)+6,'flat',axes2,.7,'-','.');

% Initialize point cloud
hold on; % scatter overwrites the patch without hold
h_points = scatter3(head_vert(:,1),head_vert(:,1),head_vert(:,1),1,'k.','Visible','off');

% Initialize metaballs
h_balls = make_patch([],[],[],'w',axes2,.7,'none','none');
h_balls.Visible = 'off';
metax = -4:.5:4;
[metaxx,metayy,metazz] = ndgrid(metax);

% Initialize fan
grp_fan = hgtransform('Parent',axes2);
xx = load('trimesh3d');
h_fan = make_patch(xx.tri,[xx.x,xx.y,xx.z]*3,1,[.9,.7,.4],grp_fan,1,'none','none');
h_fan.Visible = 'off';

% Initialize wiggly line
h_wiggly = line(0,0,0,'Color',[1,1,1,.5],'LineWidth',5);

% Initialize lasers
grp_laser = hgtransform('Parent',axes2);
angle = linspc(0,2*pi,64);
xx = [1;1;nan] .* cos(angle) * 50;
yy = [1;1;nan] .* sin(angle) * 50;
ww = [12+floor(rand(1,64)*5)*32;28+floor(rand(1,64)*5)*32;angle*nan]*50;
h_laser = arrayfun(@(a)line(xx(:)*a,yy(:)*a,ww(:),'Color',[1,1,1,.2],'Parent',grp_laser,'Clipping','off'),1.04 .^ (0:5));

% Initialize tree
tree = cell(1,3);
for ind = 2.^(0:6)
    tree = {[[randn(1,ind)*.1;tree{1}*.8+rand()*4],[randn(1,ind)*.1;tree{1}*.8+rand()*4]],[[randn(1,ind)*.1;tree{2}*.8+rand()*4],[randn(1,ind)*.1;tree{2}*.8+rand()*4-4]],[[randn(1,ind)*.1;tree{3}*.8+2],[randn(1,ind)*.1;tree{3}*.8+2]]};            
end
h_tree = line(0,0,0,'Color','k');

% Initialize light source and camera
h_light = light(axes2);
camera_setup;

%--------------------------------------------------------
% Initialize axes3, which contains alpha blended gradient
%--------------------------------------------------------
axes3 = make_axes();            
[xx,yy] = ndgrid(-1:.01:1);   
alpha(image(axes3,zeros(size(xx))),xx.^2/2+yy.^2/2);    
axes3.Visible = 'off'; % Image shows axes, must hide again

%----------------------------------------------------------------------
% Initialize axes4, which contains the texts
%----------------------------------------------------------------------
axes4 = make_axes();
texts = {'\___\zz\/z_\_z_z__\z_z_zzz.z~z\/\_·z/\zzz\z\-\/z\\z\z\zz.','__z__z\__z_z__.z_zz~z/_\/__\/z\´\_\\\z\','4096 bytesz|zMATLABz|zDemosplash 2019','.s$s,s$s,~¶§§§§§§§²~`§§§§P´~`§´','m/Bits''n''Bites~p01~Brothomstates~Kooma~Orange~CNCD~NoooN','___\¯¯¯¯¯¯¯¯¯¯¯\z¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯/___~__\zzz·:zcodez:·zz`zzzz·:zmusicz:·zzzz/__~\zz`zpestisz/zbC!zzzdistancez/zTPOLMz´zz/~\______zzzzzzz·:zasciiz:·zzzzzz_______/~/z:zzzzzzzapolloz/zbC!zzzzz:zz\~`-----/__________________\----´'};
text_times = [128,192;152,216;644,734;800,896;808,896;1016,1080];
text_times = reshape([text_times;text_times+4],6,[]);
h_text = arrayfun(@(x,y,z)text(x,y,z,'','horizontalAlign','center','fontweight','bold','fontname','Courier New','Color','w','interpreter','none'),[10,10,10,20,20,8],[4,4,4,60,60,.5],[4,-1,-1,30,-10,.5]);
h_text(4).Color = 'r'; % heart should be red
camera_setup;

%----------------------------------------------------------------------
% Main loop
%----------------------------------------------------------------------
sum_triggers = cumsum(envs & ~[zeros(7,1),envs(:,1:(end-1))],2);
start_music();
pattern = 0;
while pattern < 35
    % Sync variables, based on the current sample
    fig_width = fig.Position(3);
    cur_sample = sample();
    sync = @(a)envs(a,cur_sample);
    beat = max(cur_sample / 6615 - 32,1); 
    pattern = beat / 32;
    part = pattern / 4;
    
    % Light ball effect
    xx = xgrid + xgrid'*1i;
    for ind = 0:2
        ww = 0;
        for yy = [1:3,5]
            ww = ww + 1./(xx - .7*sin(pi*pattern/34.5*yy)*exp(1i*yy*(sum_triggers(5,cur_sample)*2+1)+ind));
        end
        xx = xx - 3./ww;
    end
    ww = 256 - sqrt(abs(ww))*200;
    
    % Background brain effect
    ind = 52*(1-part/9) + 1;
    alphaBrain = mod(ind,1);
    ind = floor(ind);
    ww = ww + max(mri_scaled(:,:,ind)*(1-alphaBrain)+mri_scaled(:,:,ind+1)*alphaBrain,interp([0,2,2.5,3,6,8],[0,0,1,1,0,0],part)*255);    
    yy = sync(6)*.1 + 1;
    for ind = 1:5
        ww = ww + ww(zoomer(yy,cos(part)*50+126),zoomer(yy+sync(7)*.3,sin(part*1.1)*50+126));       
        yy = sqrt(yy);
    end
       
    % Update image, containing light balls and brain
    h_image.CData = uint8(tanh((ww/80*interp([0,224,240,258,259,1024,1104,1120],[0,.6,0,0,1,1,0,0],beat)^.5 + sync(1))/64)*256); 

    % Move camera so it stays always inside the torus
    angle = beat/100 + sum_triggers(5,cur_sample) + 1;                        
    camera_position = (10+5*sin(3*angle)) * [cos(angle),sin(angle),0];
    campos(axes2,camera_position);        
    campos(axes4,camera_position); % The texts and the 3D scene have the same camera, even though the texts are always on top
    camlight(h_light,'HEADLIGHT'); % Update also the light source

    for ind = 1:6
        % Update text
        xx = texts{ind}; % string
        yy = xx ~= '~' & xx ~= 'z'; % yy = not_empty
        ww = interp(text_times(ind,:),[1,0,0,1],beat);
        offset = text_rands(1:length(xx))*.5;
        str_indices = yy & ww > (.5-offset);
        xx(str_indices) = randi([33,47],1,sum(str_indices));
        xx(yy & ww > (1-offset) | xx == 'z') = 32;
        h_text(ind).String = split(xx,'~');   
        h_text(ind).Rotation = interp([0,.3,.9,1.7,2,5.1,5.8,6.2],[37,-23,-35,-19,-21,34,25,37],mod(angle,2*pi)) + (ind==6)*25;
        h_text(ind).FontSize = fig_width/50;
        
        % Sync laser width to snare
        h_laser(ind).LineWidth = fig_width * (1+sync(7)*2) / 150;
    end
    
    % Update torus
    h_torus.FaceAlpha = interp([0,258,258.1,448,512,1280],[0,0,.8,.8,0,0],beat);
    h_torus.EdgeAlpha = interp([0,4,6,16,17,40],[0,0,1,1,0,0],pattern);
    h_torus.AmbientStrength = min(sync(5)+.5,1);
    h_torus.MarkerSize = fig_width/180;
    
    % Update point cloud
    time = part - 3;
    xx = min(max(part-4,0),1)^.2; % xx is the blending
    angle = omega(:,1)*2*time;  
    yy = head_vert * xx + [(10+5*sin(3*angle)).*cos(angle),(10+5*sin(3*angle)).*sin(angle),(time+sync(7)*.3)*sin(omega(:,2)/2*time)*3.5]*(1 - xx);
    xx = yy + interp([0,6,9],[0,0,3],part)*sin(yy*.5*sin(time+[.2,1.1,.3;.4,.3,.9;1.2,.5,.1])+[.3,.4,.5]*time);
    h_points.XData = xx(:,1);
    h_points.YData = xx(:,2); 
    h_points.ZData = xx(:,3);
    
    % Update wiggly line    
    if part>6 && part<8
        xx = linspc(-2,2,4000) + (part-7)*4;
        yy = sin([.5,.3,.4]*sin([2;3;4]*xx)) .* xx .* xx * 4;
        angle = sin([.7,.4,.3]*sin([5;6;4]*xx)) * 10;
        h_wiggly.XData = xx*15 + 10;    
        h_wiggly.YData = yy.*sin(angle) + 20;
        h_wiggly.ZData = yy.*cos(angle) + 7;
        h_wiggly.Visible = 'on';
    else
        h_wiggly.Visible = 'off';
    end      
          
    % Update tree    
    if part > 7.5
        xx = @(a)reshape([interp1(0:.1:.6,tree{a},tanh(linspc(0,1,50)+pattern-33),'spline');nan(1,128)],1,[]);
        h_tree.XData = xx(1) + 3;    
        h_tree.YData = xx(2);    
        h_tree.ZData = xx(3) - 3;    
        h_tree.LineWidth = fig_width/500;
    end   
   
    % Update metaballs
    if part>4 && part<6
        xx = sin(pi*(1:15)*part)*2;
        ww = zeros(size(metaxx));
        for ind = 1:5
            ww = ww + .2./sqrt((metaxx-xx(ind)).^4 + (metayy-xx(ind+5)).^4 + (metazz-xx(ind+10)).^4);
        end
        yy = [8,0,0] - camera_position;
        yy = yy*8/norm(yy) + camera_position;
        ww = isosurface(metax+yy(1),metax+yy(2),metax+yy(3)+(pattern-20).^3/2,ww,.18);
        h_balls.Vertices = ww.vertices;
        h_balls.Faces = ww.faces;   
        h_balls.FaceColor = [.9,.7,.4] - sync(7)*.4;
        h_balls.Visible = 'on';
    else
        h_balls.Visible = 'off';
    end
    
    % Only show point cloud after part 3
    if part > 3
        h_points.Visible = 'on';
        h_points.SizeData = fig_width/20;
    end
       
    % Hide torus when the fan enters
    if pattern > 17.1
        h_fan.Visible = 'on';
        h_torus.Visible = 'off';
    end
        
    % Hide lasers after part > 5.5
    if part > 5.5
        grp_laser.Visible = 'off';
    end
    
    grp_laser.Matrix = makehgtform('translate',0,0,(512-beat) * 50); % Move lasers with beat
    grp_fan.Matrix = makehgtform('yrotate',pi/2) * makehgtform('zrotate',pattern); % Rotate fan slowly
    h_fan.FaceAlpha = interp([0,5,5.5,7.34,7.4,9],[0,0,.4,.4,0,0],part); % Fade in and fade out fan
    
    % Finally, draw the scene
    draw();
end

close all
