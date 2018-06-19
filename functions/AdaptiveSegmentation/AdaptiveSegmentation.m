function [Data,T] = AdaptiveSegmentation(E,k)
%
% Adaptive Segmentation
% Version : alpha 8
% Author : Simon Kojima
%
%

% clear all;

% load ./EpochData.mat
% 
% Epoch.Data = Average.Data;
% E = Epoch.Data;
% E{1} = Epoch.Data{1}(:,:,:);
% E{2} = Epoch.Data{2}(:,:,:);

% t=0:0.01:2.5;
% A = sin(2*pi*t);
% C = 0.5*sin(2*pi*t);
% for i=1:length(A)
%    if A(i) < 0
%       A(i) = 0; 
%       C(i) = 0;
%    end
% end
% B = -A;
% D = -C;
% E{1}(:,:,1) = A;
% E{1}(:,:,2) = C;
% E{2}(:,:,1) = B;
% E{2}(:,:,2) = D;
% 
% k = 5;


%% Initialize T

for i=1:k+1
    switch i
        case 1
            T(1,1) = 0;
        case k+1
            T(i) = size(E{1},2);
        otherwise
            T(i) = ceil((i-1)*(size(E{1},2))./k);
    end
end

%%

Iteration = 0;
RoopNum = 0;
Tpre = zeros(size(T));
while 1
    Tpre = T;
    for i=2:k
        Temp.Cost = [];
        Temp.Tr = [];
        Temp.Count = 0;
        fprintf('---');
       for r = T(i-1)+1:T(i+1)-1
           Tr = T;
           Tr(i) = r;
           Temp.Count = Temp.Count + 1;
           %Temp.Cost(:,:,Temp.Count) = Cost(E,Tr); %For 3 Dimension Cost
           Temp.Cost(Temp.Count,:) = Cost(MakeVector(E,Tr));
           Temp.Tr(Temp.Count,:) = Tr;
       end
        [MaxCost,Index] = max(Temp.Cost);
        T = Temp.Tr(Index,:);
        %clear Temp;
    end
    if Tpre == T
       break 
    end
end
fprintf('\n');

Data = MakeVector(E,T);