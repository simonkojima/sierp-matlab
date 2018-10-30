 function J = SegmentationCost(x)
%
% CostFunction of Adaptive Segmentation
% Version : alpha 6
% Author : Simon Kojima
%

for i=1:2
    m{i} = mean(x{i},3);
end

W = 0;
for i=1:2
   for j=1:size(x{i},3) 
       W = W + (x{i}(:,:,j)-m{i})*(x{i}(:,:,j)-m{i})';
   end
end

J = (m{1}-m{2})'/W*(m{1}-m{2});
J = det(J);


