 function J = Cost(x)
%
% CostFunction of Adaptive Segmentation
% Version : alpha 6
% Author : Simon Kojima
%

% clear all;
% load ./Data.mat

% load ./EpochData.mat
% E = Average.Data;
% E{1} = E{1}(:,:,:);
% E{2} = E{2}(:,:,:);
% E{1} = permute(E{1},[2 1 3]);
% E{2} = permute(E{2},[2 1 3]);
% 
% k=10;
% for i=1:k+1
%     switch i
%         case 1
%             T(1,1) = 0;
%         case k+1
%             T(i,1) = size(E{1},2);
%         otherwise
%             T(i,1) = ceil((i-1)*(size(E{1},2))./k);
%     end
% end
% 
% x = MakeVector(E,T);

for i=1:2
    m{i} = mean(x{i},3);
    %m{i} = mean(mean(x{i},3),2);
end

W = 0;
for i=1:2
   for j=1:size(x{i},3) 
       W = W + (x{i}(:,:,j)-m{i})*(x{i}(:,:,j)-m{i})';
   end
end

%W = diag(W);

J = (m{1}-m{2})'/W*(m{1}-m{2});
J = det(J);
%J = max(max(J));
%J = max(diag(J));
%J = norm(diag(J));
%J = sum(diag(J));
%J = sum(sum(J,2));

