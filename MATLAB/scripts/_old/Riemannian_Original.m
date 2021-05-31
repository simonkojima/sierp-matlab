clearvars
close all

load ./EpochData.mat

%
% X <- C x N
% C : Ch
% N : Time
%

X = Average.Data;

% for l=1:2
%    for m = 1:size(X{l},3)
%        X{l}(:,:,m) = X{l}(:,:,m) - mean(X{l}(:,:,m),2);
%    end    
% end


P1 = mean(X{2},3);

Nc = size(X,2);
for l = 1:Nc
    [C,N,I] = size(X{l});
    for m = 1:I
        Xb{l}(:,:,m) = [P1; X{l}(:,:,m)];
    end
end

for l=1:Nc
    [C,N,I] = size(X{l});
    for m = 1:I
        Sb{l}(:,:,m) = (1/(N-1))*(Xb{l}(:,:,m)*Xb{l}(:,:,m)');
    end
end

% Geometric Mean M of K SPD matricies
% Sb = Ck

MaxIteration = 50;

for Class = 1:Nc
    K = size(Sb{Class},3);
    
    %Initialize M
    M{Class} = mean(Sb{Class},3);
    
    %tmp = M{Class}
    for It = 1:MaxIteration
        rM = root(M{Class}); % root M
        nrM = negroot(M{Class});    % negative root M.
        
        % Calculate sigma[ln(M^-1/2 * Ck * M^-1/2)]
        tmp = 0;
        for k = 1:K
            tmp = tmp + ln_spd(nrM*Sb{Class}(:,:,k)*nrM);
            %return
        end
        % Calculate Frobenius norm of sigma[ln(M^-1/2 * Ck * M^-1/2)]
        J = norm(tmp);
        
        M{Class} = rM*exp_spd((1./K)*tmp)*rM;
        
        fprintf("Iteration : %d, Cost : %d\n",It,J);
        
    end
    
    figure();
    image(M{Class},'CDataMapping','scaled')
    colorbar
    
end

function r = root(C)
[vec,lam] = eig(C);
lam = sqrt(diag(lam));
lam = diag(lam);
r = vec*lam*vec';
end

function r = negroot(C)
[vec,lam] = eig(C);
lam = inv(sqrt(lam));
r = vec*lam*vec';
end

function r = ln_spd(C)
[vec,lam] = eig(C);
lam = logm(lam);
r = vec*lam*vec';
end

function r = exp_spd(C)
[vec,lam] = eig(C);
lam = expm(lam);
r = vec*lam*vec';
end