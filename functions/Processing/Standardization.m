function zscore = Standardization(x);
%
% Standardize Feature Vector (Matrix)
% Version : 1
% Author : Simon Kojima
%
% x : DataNum x FeatureNum
%

for i=1:size(x,2)
    zscore(:,i) = (x(:,i) - mean(x(:,i)))./std(x(:,i));
end