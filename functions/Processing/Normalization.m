function [normalize,minvec,maxvec] = Normalization(x)
%
% Normalize Feature Vector (Matrix)
% Version : 1
% Author : Simon Kojima
%
% x : DataNum x FeatureNum
%

for i=1:size(x,2)
    normalize = (x - min(x))./(max(x)-min(x));
end

minvec = min(x);
maxvec = max(x);