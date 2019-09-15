function camera_setup
    camup([.7,0,1]);
    daspect([1,1,1]);        
    camproj perspective
    camva(75);
    camtarget([8,.5,.5]);
end