function [Ht,Hnt] = CSP(Vt,Vnt)

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

%% Data Making
% 
% clear all
% load ./EpochData.mat
%     
% for i=1:size(Average.Data{1},3)
%     Vt(:,:,i) = Average.Data{1}(:,:,i);
% end
% 
% for i=1:size(Average.Data{2},3)
%     Vnt(:,:,i) = Average.Data{2}(:,:,i);
% end
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
% [lambda,index] = sort(diag(lambda),'descend');
% lambda = diag(lambda);
% Bc = Bc(:,index);

W = sqrt(inv(lambda))*Bc';

Sa = W*Ra*W';
Sb = W*Rb*W';

[U,S] = svd(Sa)

% [U,Pa] = eig(Sa);
% [Pa,index] = sort(diag(Pa),'descend');
% Pa = diag(Pa);
% U = U(:,index);
% 
Ht = (U(:,1)'*W)';
Hnt = (U(:,end)'*W)';

H = (U'*W)'

%Ha = P(1,:)';
%Hb = P(end,:)';

return
X{1} = [];
for i=1:size(Va,3)
    Z{1}(:,:,i) = Ha'*Va(:,:,i);
    temp = var(Z{1}(:,:,i),0,2)';
    X{1} = [X{1}; temp];
end

X{2} = [];
for i=1:size(Vb,3)
    Z{2}(:,:,i) = Hb'*Vb(:,:,i);
    temp = var(Z{2}(:,:,i),0,2)';
    X{2} = [X{2}; temp];
end

for i=1:2
   X{i} = X{i}./sum(X{i}); 
end

plot((1:length(X{1}))/length(X{1}),X{1},'bo');
hold on
plot((1:length(X{2}))/length(X{2}),X{2},'ro');
hold off
