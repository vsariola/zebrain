axes(a1);
i = currentSample/song.rowLen;  
synkki = 1-(mod(-i,4)/4)^2;
i = i/100;                        
        
campos([(D+K*sin(W*i))*cos(i),(D+K*sin(W*i))*sin(i),0]);        
camlight(hLight,'HEADLIGHT');        
axes(a2);
axes(a3);   
set(hText,'Position',[i/10 0.5 0]);
set(hText,'String',num2str(i));
        
drawnow;