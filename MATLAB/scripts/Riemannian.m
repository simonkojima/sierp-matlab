function M = Riemannian(X,prototype,MaxIteration)

%
% X <- C x N
% C : Ch
% N : Time
%


[~,~,K] = size(X);
for l = 1:K
    Sb(:,:,l) = covariance_p300(X(:,:,l),prototype);
end

%Initialize M
M = mean(Sb,3);

% nu = 1;
% tau = realmax;
% crit = realmax;

%tmp = M{Class}
for It = 1:MaxIteration
    rM = root(M); % root M
    nrM = negroot(M);    % negative root M.
    
    % Calculate sigma[ln(M^-1/2 * Ck * M^-1/2)]
    tmp = 0;
    for k = 1:K
        tmp = tmp + ln_spd(nrM*Sb(:,:,k)*nrM);
    end
    %Calculate Frobenius norm of sigma[ln(M^-1/2 * Ck * M^-1/2)]
    J = norm(tmp,'fro');
    M = rM*exp_spd((1./K)*tmp)*rM;
%     M = rM*exp_spd(nu*tmp)*rM;
    fprintf("Iteration : %d, Cost : %d\n",It,J);
    
%     h = nu * crit;
%     if h < tau
%        nu = 0.95 * nu;
%        tau = h;
%     else
%         nu = nu * 0.5;
%     end
    
end

% % Nc = size(X,2);
% % 
% % for l=1:Nc
% %     [C,N,I] = size(X{l});
% %     for m = 1:I
% %         Sb{l}(:,:,m) = covariance_p300(X{l}(:,:,m),prototype);
% %     end
% % end
% % 
% % % Geometric Mean M of K SPD matricies
% % % Sb = Ck
% % 
% % %MaxIteration = 50;
% % 
% % for Class = 1:Nc
% %     K = size(Sb{Class},3);
% %     
% %     %Initialize M
% %     M{Class} = mean(Sb{Class},3);
% %     
% %     %tmp = M{Class}
% %     for It = 1:MaxIteration
% %         rM = root(M{Class}); % root M
% %         nrM = negroot(M{Class});    % negative root M.
% %         
% %         % Calculate sigma[ln(M^-1/2 * Ck * M^-1/2)]
% %         tmp = 0;
% %         for k = 1:K
% %             tmp = tmp + ln_spd(nrM*Sb{Class}(:,:,k)*nrM);
% %             %return
% %         end
% %         % Calculate Frobenius norm of sigma[ln(M^-1/2 * Ck * M^-1/2)]
% %         J = norm(tmp);
% %         
% %         M{Class} = rM*exp_spd((1./K)*tmp)*rM;
% %         
% %         fprintf("Iteration : %d, Cost : %d\n",It,J);
% %         
% %     end
% %     
% % end

    function r = root(C)
        [vec,lam] = eig(C);
        lam = diag(diag(lam).^(0.5));
        %lam = diag(lam);
        r = vec*lam*vec';
    end

    function r = negroot(C)
        [vec,lam] = eig(C);
        lam = diag(diag(lam).^(-0.5));
        r = vec*lam*vec';
        %lam = inv(sqrt(lam));
        %r = vec*lam*vec';
    end

    function r = ln_spd(C)
        [vec,lam] = eig(C);
        %lam = logm(lam);
        lam = diag(log(diag(lam)));
        r = vec*lam*vec';
    end

    function r = exp_spd(C)
        [vec,lam] = eig(C);
        %lam = expm(lam);
        lam = diag(exp(diag(lam)));
        r = vec*lam*vec';
    end
end