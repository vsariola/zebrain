i = currentSample/song.rowLen;  

if i < 320
    axes(a4);   
    
    i = i/30
    cx = cos(i)*127+127;
    cy = sin(i)*127+127;
    
    t = i/10;
    h=xgrid+xgrid'*1i;
    for f=0:2;
        z=0;
        for k=1:4;
            z=z+1./(h-.3*sin(t*k)*exp(1i*k+t+f));
        end;
        h=h-3./z;
    end;
    z = 256-sqrt(abs(z))*200;
    
    alphaBrain = mod(i,1);
    ind = mod(floor(i),20)+1;
    z = z+double(mri(:,:,ind))*(1-alphaBrain)+double(mri(:,:,ind+1))*alphaBrain;    
    zoom = envs(5:6,currentSample).*[0.2;0.05]+1;
    for j = 1:6        
        z = z+z(zoomer(zoom(1),cx),zoomer(zoom(2),cy),1);       
        zoom = sqrt(zoom);
    end
       

    image(tanh((z/128*min(i/10,1)+envs(1,currentSample))/64)*640);
    
else   
    axes(a1);

    synkki = 1-(mod(-i,4)/4)^2;
    i = i/100;                        

    campos([(D+K*sin(W*i))*cos(i),(D+K*sin(W*i))*sin(i),0]);        
    camlight(hLight,'HEADLIGHT');        
    axes(a2);
    axes(a3);   
    set(hText,'Position',[i/10+envs(1,currentSample),0.5,0]);
    set(hText,'String',num2str(i));
end
drawnow;