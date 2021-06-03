clearvars
% Linear Discriminant Analysis Classifier
% Version : alpha 1
% Author : Simon Kojima
%% Preferences

load ./TrainingDatasets.mat
load ./TestDatasets.mat

%% Training

for l=1:size(TrainingData.X,2)
    MdlLinear{l} = fitcdiscr(TrainingData.X{l},TrainingData.Y{l},'DiscrimType','pseudoLinear');
end

for l=1:2
    for m=1:size(TestData.X{l},2)
        Result{l}{m} = predict(MdlLinear{m},TestData.X{l}{m});
    end
end

%% Evaluation
Times = 1;
for l=1:size(TestData.Y{1},2)
    Res{m} = [];
end

for l=1:2
    for m=1:size(Result{l},2)
        for n=1:Times:size(Result{l}{m},1)
            if n+Times-1 > size(Result{l}{m},1)
                if sum(Result{l}{m}(n:end)) >= ceil(length(Result{l}{m}(n:end))./2)
                    Res{m}(length(Res{m})+1,1) = 1;
                else
                    Res{m}(length(Res{m})+1,1) = 0;
                end
            else
                if sum(Result{l}{m}(n:n+Times-1)) >= ceil(length(Result{l}{m}(n:n+Times-1))./2)
                    Res{m}(length(Res{m})+1,1) = 1;
                else
                    Res{m}(length(Res{m})+1,1) = 0;
                end
            end
        end
    end
end

for l=1:size(TestData.Y{1},2)
    Y{m} = [];
end

for l=1:2
    for m=1:size(TestData.Y{l},2)
        if l == 1
            Y{m} = [Y{m}; zeros(ceil(length(TestData.Y{l}{m})./Times),1)];
        else
            Y{m} = [Y{m}; ones(ceil(length(TestData.Y{l}{m})./Times),1)];
        end
    end
end

for l=1:size(TrainingData.X,2)
    [MCC(l),F1(l),Accuracy(l)] = ClassifierEvaluation(Res{l},Y{l},1);    
end

fprintf('\n');
fprintf(' Mean Accuracy : %.0f%%\n',mean(Accuracy)*100);
fprintf(' Mean F1 Score : %.2f\n',mean(F1));
fprintf('Mean MCC Score : %.2f\n',mean(MCC));
