%
%	Covariance Estimator based on Xdawn Filter
%
%	Author : Simon Kojima
%	Ver1.0 2021/09/14
%

function C = covariances_Xdawn(X, filters, P)

    [n_channels, n_times, n_trials] = size(X);
    [n_proto, n_times_P] = size(P);
    
    C = [];
    for m = 1:n_trials
       tmp = filters'*X(:,:,m);
       C(:,:,m) = cov(cat(1,P,tmp)');
    end

end
