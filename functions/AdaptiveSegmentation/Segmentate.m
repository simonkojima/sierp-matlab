function x = Segmentate(S,T)
%
% Make Vector
% Version : alpha 5
% Author : Simon Kojima
%
%

k = size(T,2)-1;

for i=1:size(S,2)
    for j=1:k
        x{i}(1:size(S{i},1),j,:) = sum(S{i}(1:size(S{i},1),T(j)+1:T(j+1),:),2)./(T(j+1)-T(j));
    end
end
