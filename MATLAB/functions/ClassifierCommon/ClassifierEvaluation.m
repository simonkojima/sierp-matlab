function [MCC,F1,Accurecy,TP,TN,FP,FN] = ClassifierEvaluation(PredictedLabel,ActualLabel,PrintEnable)

TP = 0;
TN = 0;
FP = 0;
FN = 0;

for l=1:size(PredictedLabel)
    if PredictedLabel(l) == ActualLabel(l)
        if PredictedLabel(l) == 1
            TP = TP+1;
        elseif PredictedLabel(l) == 0
            TN = TN+1;
        end
    else
       if PredictedLabel(l) == 1
            FP = FP+1;
       elseif PredictedLabel(l) == 0
            FN = FN +1;
       end
    end
end

Precision = TP/(TP+FP);
Recall = TP/(TP+FN);

Accurecy = (TP+TN)./(TP+TN+FP+FN);
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
    fprintf('      Accurecy : %.0f%%\n',Accurecy*100);
    fprintf('      F1 Score : %.2f\n',F1);
    fprintf('           MCC : %.2f\n',MCC);
    %fprintf('Precision : %.2f%%\n',Precision*100);
    %fprintf('Recall : %.2f%%\n',Recall*100);
end