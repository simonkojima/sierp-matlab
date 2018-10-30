function k = DetDimension(S,RetainingVariance)
%
%   Principle Component Analysis
%   Version : 2
%   Author : Simon Kojima
%

Svector = max(S)';

k = size(Svector,1);
for i=k:-1:1
    Variance = sum(Svector(1:i))./sum(Svector);
    if Variance*100 < RetainingVariance
        k = i+1;
       break; 
    end
end

end