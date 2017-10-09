function demo  
    loadsong;                    
    loadsync;
    s = player(song);
    y = gensync(sync,(1:length(s)/8)/song.rowLen*4);
    
    N={'units','normalized','position',[0 0 1 1]};
    figure(N{:});
    axes(N{:});        
        
    a = audioplayer(s/32768,44100);
    play(a);
    
    u = rand(6e2,1)*2*pi;
    v = rand(6e2,1)*2*pi;
    uu = linspace(0,2*pi,10)';
    vv = uu*0;
    u = [u;uu;uu;vv;vv+2*pi];
    v = [v;vv;vv+2*pi;uu;uu];
    D = 10;
    A = 3.5;
    K = 5;
    W = 3;
        
    tri = delaunay(u,v);
       
    while isplaying(a)      
        currentSample = a.CurrentSample;
        i = currentSample/song.rowLen;        
        i = i/10;
        x = (cos(u)*A+K*sin(W*v)+D).*cos(v);
        y = (cos(u)*A+K*sin(W*v)+D).*sin(v);
        z = sin(u)*A;
        trisurf(tri,x,y,z,'FaceColor','interp','LineWidth',2);                  
        daspect([1 1 1]);        
        camproj('perspective')
        camva(75);
        camtarget([5 5 1]);
        camup([1 0 1]);
        campos([(D+K*sin(W*i))*cos(i),(D+K*sin(W*i))*sin(i),0]);
        colormap bone 
        drawnow;
    end
    
    close all;
end