function Vec = Vectorizer(Data)

for m = 1:size(Data,3)
    temp{m} = [];
    for n = 1:size(Data,1)
        temp{m} = [temp{m} Data(n,:,m)];
    end
end

Vec = [];
for m=1:size(Data,3)
   Vec = vertcat(Vec,temp{m});
end

end