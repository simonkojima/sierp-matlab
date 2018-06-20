function normalize = Normalization(x)
%
% Normalize Feature Vector (Matrix)
% Version : 1
% Author : Simon Kojima
%
% x : DataNum x FeatureNum
%

for i=1:size(x,2)
    normalize(:,i) = (x(:,i) - min(x(:,i)))./(max(x(:,i))-min(x(:,i)));
end