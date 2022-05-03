%
%	Xdawn Filter
%
%	Author : Simon Kojima
%	Ver1.0 2021/09/14
%   Ver2.0 2021/11/17
%

function [filters, P] = Xdawn(n_components ,X, y,varargin)
    [n_channels, n_times, n_trials] = size(X);
    
    if ~isempty(varargin)
        classes = varargin{1};
    else
        classes = unique(y);
    end

    %classes
    
    Cx = [];
    for m = 1:n_trials
       Cx = cat(2,Cx,X(:,:,m));
    end
    Cx = cov(Cx');
    
    P = [];
    filters = [];
    for m = 1:length(classes)
        P_class = X(:,:,y==classes(m));
        P_class = mean(P_class,3);
        C = cov(P_class');
        
        [evecs, evals] = eig(C,Cx);
        evals = diag(evals);
        [evals,ind] = sort(evals,'descend');
        evecs = evecs(:,ind);
        evecs = evecs./repmat(vecnorm(evecs,2,1),n_channels,1);
        f_class = evecs(:,1:n_components);
        filters = cat(2,filters,f_class);
        P = cat(1,P,f_class'*P_class);
    end
end
