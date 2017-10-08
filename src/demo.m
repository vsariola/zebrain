function demo  
    loadsong;                    
    loadsync;
    s = player(song);
    y = gensync(sync,(1:length(s)/8)/song.rowLen*4);
    
    N={'units','normalized','position',[0 0 1 1]};
    figure(N{:});
    axes(N{:});        
    
    w = reshape(s/32768,2,length(s)/2)';
    a = audioplayer(w,44100);
    play(a);
    
    l=-9:.1:9;[x,tmp]=ndgrid(l);
    while isplaying(a)
        a.CurrentSample        
        v = y(:,floor((a.CurrentSample-1)/4+1));
        h=x+x'*1i;
        for F=0:4;for K=0:3;F=F+1./(h-exp(1i*(K+v(1))));end;h=h-3./F;end;
        image(abs(F));
        drawnow;
    end
end