close all
clearvars
clc

FileName = '20181022_B35_0001.mat';

load(FileName);

TriggerList = [];
count = 0;
for l=1:length(Trigger)
   if Trigger(l) ~= 0
       count = count + 1;
       TriggerList(1,count) = Trigger(l);
       TriggerList(2,count) = Time(l);
   end
end
clear count;

Period = [];
for l=1:length(TriggerList)-1
  Period(l) = TriggerList(2,l+1) - TriggerList(2,l);
end

TriggerCount = [];
for l=1:size(TriggerList,2)
    if isempty(TriggerCount) == 1
        TriggerCount(1,1) = TriggerList(1,l);
        TriggerCount(2,1) = 1;
    end
        
    for m=1:size(TriggerCount,2)
       if TriggerCount(1,m) == TriggerList(1,l)
          TriggerCount(2,m) = TriggerCount(2,m) + 1;
          flag = 0;
          break;
       else
          flag = 1;
       end
    end
    
    if flag == 1
        index = size(TriggerCount,2)+1;
        TriggerCount(1,index) = TriggerList(1,l);
        TriggerCount(2,index) = 1;
    end
    
end

Temp = TriggerCount;

[B,I] = sort(Temp(1,:));
TriggerCount = B;

for l=1:length(TriggerCount)
   TriggerCount(2,l)  = Temp(2,I(l));
end

fprintf('Mean Period        : %.30f ms\n',mean(Period)*1000);
fprintf('Standard Deviation : %.30f ms\n',std(Period)*1000);

TriggerCount