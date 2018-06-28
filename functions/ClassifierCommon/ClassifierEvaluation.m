function [FMScore,F1Score,TP,TN,FP,FN] = ClassifierEvaluation(PredictedLabel,ActualLabel,PrintEnable)

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

FMScore = sqrt((TP./(TP+FP)).*(TP./(TP+FN)));
F1Score = 2*(Precision*Recall)./(Precision+Recall);

if PrintEnable == 1
    fprintf('\nTrue Positive : %.0f\n',TP);
    fprintf('True Negative : %.0f\n',TN);
    fprintf('False Positive : %.0f\n',FP);
    fprintf('False Negative : %.0f\n',FN);
    fprintf('FM Score : %.2f\n',FMScore);
    %fprintf('Precision : %.2f%%\n',Precision*100);
    %fprintf('Recall : %.2f%%\n',Recall*100);
    %fprintf('F Score : %.2f%%\n',2*(Precision*Recall)./(Precision+Recall));
end