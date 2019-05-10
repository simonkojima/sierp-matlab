function Variance = RetainedVariance(S,k)
%
%   Compute Retained Variance of PCA
%   Version : 3
%   Author : Simon Kojima
%

S = max(S)';
Variance = sum(S(1:k))./sum(S);
fprintf('PCA : %.2f%% of variance retained\n',Variance*100);

end