function [zscore,meanvec,stdvec] = Standardization(x)
%
% Standardize Feature Vector (Matrix)
% Version : 1
% Author : Simon Kojima
%
% x : DataNum x FeatureNum
%

zscore = (x - mean(x))./std(x);
meanvec = mean(x);
stdvec = std(x);