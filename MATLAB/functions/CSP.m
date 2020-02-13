dfunction [H] = CSP(Vt,Vnt)

%
% Common Spatial Pattern Filter
% Version : alpha 9
% Author : Simon Kojima
%
% function [Ht,Hnt] = CSP(Vt,Vnt)
%
% Vt    : Raw Datasets of Target Class      (NumChannel x NumSample x Trials)
% Vnt   : Raw Datasets of Non-TargetClass   (NumChannel x NumSample x Trials)
%
% From : Designing optimal spatial filters for single-trial EEG
% classification in a movement task (Johannes Mueller-Gerking)
% 

%% Making Normalized Covariance Matrices

for l=1:size(Vt,3)
    Ra(:,:,l) = (Vt(:,:,l)*Vt(:,:,l)')./trace(Vt(:,:,l)*Vt(:,:,l)');
end

for l=1:size(Vnt,3)
    Rb(:,:,l) = (Vnt(:,:,l)*Vnt(:,:,l)')./trace(Vnt(:,:,l)*Vnt(:,:,l)');
end

Ra = mean(Ra,3);
Rb = mean(Rb,3);

%%

% Rc = Ra + Rb;
% 
% [Bc,lambda] = eig(Rc);
% [lambda,ind]=sort(diag(lambda),'descend');
% Bc=Bc(:,ind);
% lambda = diag(lambda);
% 
% W = sqrt(inv(lambda))*Bc';
% 
% Sa = W*Ra*W';
% Sb = W*Rb*W';
% 
% [V,D] = eig(Sa,Sb);
% [D,ind]=sort(diag(D));
% V=V(:,ind);
% 
% H = V'*W;

%%

Rc = Ra + Rb;

[Bc,lambda] = eig(Rc);

W = sqrt(inv(lambda))*Bc';

Sa = W*Ra*W';
Sb = W*Rb*W';

[~,~,U] = svd(Sa);

H = U'*W;
% 
