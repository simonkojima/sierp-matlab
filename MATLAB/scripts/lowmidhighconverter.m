% %%-------------------------------------------------------------------------
% for m=1:3
%     epochs.att{1}.dev{m} = low{m};
% end
% 
% for m=1:3
%     epochs.att{2}.dev{m} = mid{m};
% end
% 
% for m=1:3
%     epochs.att{3}.dev{m} = high{m};
% end
%%-------------------------------------------------------------------------
for m=1:4
    epochs.att{1}.dev{m} = LL{m};
end

for m=1:4
    epochs.att{2}.dev{m} = LH{m};
end

for m=1:4
    epochs.att{3}.dev{m} = HL{m};
end

for m=1:4
    epochs.att{4}.dev{m} = HH{m};
end
%%-------------------------------------------------------------------------