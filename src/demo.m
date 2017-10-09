function demo  
    loadsong;                    
    loadsync;
    s = player(song);
    y = gensync(sync,(1:length(s)/8)/song.rowLen*4);
    
    N={'units','normalized','position',[0 0 1 1]};
    figure(N{:});
    a1=axes(N{:});        
    a2=axes(N{:});        
    [x,y] = ndgrid(-2:.1:2);
    I=image(zeros(size(x)));
    set(a2,'visible','off');      
    alphavalues = (x.^2+y.^2)/99;    
        
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
        axes(a1);
        currentSample = a.CurrentSample;
        i = currentSample/song.rowLen;  
        synkki = 1-(mod(-i,4)/4)^2;
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
        axes(a2);
        alpha(I,alphavalues+1-i+rand(size(alphavalues))*synkki);
        drawnow;
    end
    
    close all;
end