function [Ht,Hnt,H] = CSP(Vt,Vnt)

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

for i=1:size(Vt,3)
    Ra(:,:,i) = (Vt(:,:,i)*Vt(:,:,i)')./trace(Vt(:,:,i)*Vt(:,:,i)');
end

for i=1:size(Vnt,3)
    Rb(:,:,i) = (Vnt(:,:,i)*Vnt(:,:,i)')./trace(Vnt(:,:,i)*Vnt(:,:,i)');
end

Ra = mean(Ra,3);
Rb = mean(Rb,3);

%%

Rc = Ra + Rb;

[Bc,lambda] = eig(Rc);

W = sqrt(inv(lambda))*Bc';

Sa = W*Ra*W';
Sb = W*Rb*W';

[U,S] = svd(Sa);
Ht = (U(:,1)'*W)';
Hnt = (U(:,end)'*W)';

H = (U'*W)';

