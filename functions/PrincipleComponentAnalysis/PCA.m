function [U,S,V] = PCA(X)
%
%   Principle Component Analysis
%   Version : 4
%   Author : Simon Kojima
%
%   Example...
%
%   k = 30; 
%   [U,S] = PCA(X);
%   X = X*U(:,1:k);
%   RetainedVariance(S,k);
%
%   See also RetainedVariance

X = (X - mean(X))./var(X);
[U,S,V] = svd((X'*X)./size(X,1));

end