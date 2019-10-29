function y = TriggerDownsample(x,r,phase)


y=[];
for l=1+phase:r:size(x,2)
    flag = 0;
    y(length(y)+1) = x(l);
    if l~= 1
        if sum(x(l-r+1:l)) ~= 0 && x(l) == 0
            y(length(y)) = sum(x(l-r:l-1));
        end
    end
end

TriggerList(x,0);
TriggerList(y,0);

end
