function sync = gensync(sync,time)
    if ~iscell(sync)
        return;
    end
    p = cellfun(@(x) gensync(x,time),sync(2:end),'UniformOutput',0);
    switch sync{1}                    
        case 1
             % Stepwise interpolation
             sync = interp1(p{1}(:,1),p{1}(:,2:end),time,'previous');
        case 2
             % Smooth interpolation
             sync = spline(p{1}(:,1),p{1}(:,2:end)',time);
        case 3        
             % Blending two curves
             o = ones(size(p,1),1);
             sync = o * (1-p{1}) .* p{2} + o * p{1} .* p{3};
        otherwise
             % Merging all curves
             sync = cell2mat(p);            
    end
end