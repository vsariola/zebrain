function demo  
    N={'units','normalized','position',[0 0 1 1]};
    figure(N{:});
    axes(N{:});
    
    loadsong;
            
    s = player(song);
    
    w = reshape(s/32768,2,length(s)/2)';
    a = audioplayer(w,44100);
    play(a);
    
    l=-9:.1:9;[x,~]=ndgrid(l);
    while isplaying(a)
        a.CurrentSample        
        h=x+x'*1i;
        for F=0:4;for K=0:3;F=F+1./(h-exp(1i*(K+a.CurrentSample/100000)));end;h=h-3./F;end;
        image(abs(F));
        drawnow;
    end
end