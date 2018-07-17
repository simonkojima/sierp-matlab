function [MCC,F1,TP,TN,FP,FN] = ClassifierEvaluation(PredictedLabel,ActualLabel,PrintEnable)

TP = 0;
TN = 0;
FP = 0;
FN = 0;

for i=1:size(PredictedLabel)
    if PredictedLabel(i) == ActualLabel(i)
        if PredictedLabel(i) == 1
            TP = TP+1;
        elseif PredictedLabel(i) == 0
            TN = TN+1;
        end
    else
       if PredictedLabel(i) == 1
            FP = FP+1;
       elseif PredictedLabel(i) == 0
            FN = FN +1;
       end
    end
end

Precision = TP/(TP+FP);
Recall = TP/(TP+FN);

F1 = 2*(Precision*Recall)./(Precision+Recall);
MCC = (TP*TN-FP*FN)/sqrt((TP+FP)*(TP+FN)*(TN+FP)*(TN+FN));

if isinf(F1) || isnan(F1)
   F1 = 0; 
end

if isinf(MCC) || isnan(MCC)
   MCC = 0; 
end

if PrintEnable == 1
    fprintf('\n');
    fprintf(' True Positive : %.0f\n',TP);
    fprintf(' True Negative : %.0f\n',TN);
    fprintf('False Positive : %.0f\n',FP);
    fprintf('False Negative : %.0f\n',FN);
    fprintf('      F1 Score : %.2f\n',F1);
    fprintf('           MCC : %.2f\n',MCC);
    %fprintf('Precision : %.2f%%\n',Precision*100);
    %fprintf('Recall : %.2f%%\n',Recall*100);
end