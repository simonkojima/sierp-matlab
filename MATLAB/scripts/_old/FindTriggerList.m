
TriggerList = [];

for i=1:size(Trigger,2)
    Flag = 0;
    for j=1:size(TriggerList,2)
        if Trigger(i) == TriggerList(j)
            Flag = 1;
        end
    end
    if Flag == 0
        TriggerList(size(TriggerList,2)+1) = Trigger(i);
    end
end

TriggerList