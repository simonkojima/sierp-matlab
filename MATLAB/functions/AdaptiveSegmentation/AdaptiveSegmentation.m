function T = AdaptiveSegmentation(E,k)
%
% Adaptive Segmentation
% Version : alpha 8
% Author : Simon Kojima
%

%% Initialize T

for i=1:k+1
    switch i
        case 1
            T(1,1) = 0;
        case k+1
            T(i) = size(E{1},2);
        otherwise
            T(i) = ceil((i-1)*(size(E{1},2))./k);
    end
end

%%

while 1
    Tpre = T;
    for i=2:k
        Temp.Cost = [];
        Temp.Tr = [];
        Temp.Count = 0;
        fprintf('---');
       for r = T(i-1)+1:T(i+1)-1
           Tr = T;
           Tr(i) = r;
           Temp.Count = Temp.Count + 1;
           Temp.Cost(Temp.Count,:) = SegmentationCost(Segmentate(E,Tr));
           Temp.Tr(Temp.Count,:) = Tr;
       end
        [MaxCost,Index] = max(Temp.Cost);
        T = Temp.Tr(Index,:);
    end
    if Tpre == T
       break 
    end
end
fprintf('\n');