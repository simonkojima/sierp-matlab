function f = FilteredVariance(H,S)
%
% Compute Filtered Variance
%
% Version : alpha 2
% Author : Simon Kojima
%
% function f = FilteredVariance(H,S)
%
% H : CSP Spatial Filter (NumFilterElements x NumSample)
% S : Datasets (NumSample x NumChannnel)
%
% From : Comparison of Performance of Different Feature Extraction Methods in Detection of P300
% ZAHRA AMINI, VAHID ABOOTALEBI, MOHAMMAD T. SADEGHI
%

f = log((var(H'*S))./sum(var(H'*S)));

end