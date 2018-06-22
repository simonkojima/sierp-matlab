function [U,S,V] = PCA(X)
%
%   Principle Component Analysis
%   Version : 3
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

[m,n] = size(X);
[U,S,V] = svd((X'*X)./m);

end