function demo  
    loadsong;                    
    loadsync;
    s = player(song);
    y = gensync(sync,(1:length(s)/8)/song.rowLen*4);
    
    N={'units','normalized','position',[0 0 1 1]};
    N2={'visible','off'};
    figure(N{:});
    a3=axes(N{:},N2{:});  
    hText = text(0,0,'','FontSize',60,'FontWeight','bold');
    
    a2=axes(N{:},N2{:});            
    [x,y] = ndgrid(-2:.1:2);
    I=image(zeros(size(x)));    
    set(gca,'visible','off');
    alphavalues = (x.^2+y.^2)/99;    
        
    a = audioplayer(s/32768,44100);
    play(a);
    
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
        
    a1=axes(N{:},N2{:});        
    tri = delaunay(u,v);
    x = (cos(-u)*A+K*sin(W*v)+D).*cos(v);
    y = (cos(-u)*A+K*sin(W*v)+D).*sin(v);
    z = sin(-u)*A;
    trisurf(tri,x,y,z,'LineWidth',2);                  
    colormap bone    
    hLight = camlight;
    camup([1 0 1]);
    daspect([1 1 1]);        
    camproj('perspective')
    camva(75);
    camtarget([5 5 1]);
    
    while isplaying(a) 
        axes(a1);
        currentSample = a.CurrentSample;
        i = currentSample/song.rowLen;  
        synkki = 1-(mod(-i,4)/4)^2;
        i = i/100;                        
        
        campos([(D+K*sin(W*i))*cos(i),(D+K*sin(W*i))*sin(i),0]);        
        camlight(hLight,'HEADLIGHT');        
        axes(a2);
        alpha(I,alphavalues+1-i+rand(size(alphavalues))*synkki);
        axes(a3);   
        hText.Position = [i/10 0.5 0];        
        hText.String = num2str(i);
        
        drawnow;
    end
    
    close all;
end