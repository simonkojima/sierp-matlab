clearvars

load './LowStream.mat'
Stream{1} = Average;

load './MidStream.mat'
Stream{2} = Average;

load './HighStream.mat'
Stream{3} = Average;

clear Average

SimulatingFile = '20190520_B41_Stream_0003_Processed.mat';
CorrectClass = 3;

TriggerSelect = [2 8 32];

EpochRange = [-0.1 0.5];
BaseLineRange = [-0.1 0.5];

SimulatingRange = [0 10];

StandardizeEnable = 0;
PCAEnable = 0;
RetainingVariance = 99;

%% Applying CSP

temp = [1 2 3 1 2];

for Deviant=1:size(Stream,2)
    H{Deviant} = CSP(Stream{Deviant}.Data{Deviant},cat(3,Stream{temp(Deviant+1)}.Data{Deviant},Stream{temp(Deviant+2)}.Data{Deviant}));
    
%     for l=1:size(H{Deviant},1)
%         H{Deviant}(l,:) = H{Deviant}(l,:)./(norm(H{Deviant}(l,:)));
%     end
    
    %H{Deviant} = [H{Deviant}(1,:);H{Deviant}(2,:);H{Deviant}(end-1,:);H{Deviant}(end,:)];
end

clear temp;

for Attended = 1:size(Stream,2)
    for Deviant = 1:size(Stream,2)
        Stream{Attended}.CSP{Deviant} = [];
        for l=1:size(Stream{Attended}.Data{Deviant},3)
            Stream{Attended}.CSP{Deviant} = cat(3,Stream{Attended}.CSP{Deviant},H{Deviant}*Stream{Attended}.Data{Deviant}(:,:,l));
        end
    end
end

%% Making Training Data

for Deviant=1:size(Stream,2)
    TrainingData.X{Deviant} = [];
    TrainingData.Y{Deviant} = [];
    for Attended=1:size(Stream,2)
        TrainingData.X{Deviant} = vertcat(TrainingData.X{Deviant},Vectorizer(Stream{Attended}.CSP{Deviant}));
        if Deviant == Attended
            TrainingData.Y{Deviant} = [TrainingData.Y{Deviant}; ones(size(Vectorizer(Stream{Attended}.CSP{Deviant}),1),1)];
        else
            TrainingData.Y{Deviant} = [TrainingData.Y{Deviant}; zeros(size(Vectorizer(Stream{Attended}.CSP{Deviant}),1),1)];
        end
    end
end

%% Standardize
if StandardizeEnable == 1
    for l=1:size(TrainingData.X,2)
        [TrainingData.X{l},Standardize{l}.meanvec,Standardize{l}.stdvec] = Standardization(TrainingData.X{l});
    end
end

%% Applying PCA

if PCAEnable == 1
    for l=1:size(TrainingData.X,2)
        [pca{l}.U,pca{l}.S,pca{l}.V] = PCA(TrainingData.X{l});
        pca{l}.k = DetDimension(pca{l}.S,RetainingVariance);
        TrainingData.X{l} = TrainingData.X{l}*pca{l}.U(:,1:pca{l}.k);
    end
end

%% Designing LDA

for Deviant=1:size(TrainingData.X,2)
    MdlLinear{Deviant} = fitcdiscr(TrainingData.X{Deviant},TrainingData.Y{Deviant},'DiscrimType','pseudolinear');
end

%% Simulating

load(SimulatingFile);

for l=1:size(Trigger,2)
    if Trigger(l) ~= 0
        FirstTrigger = l;
        break
    end
end

Count = 0;
for l=(FirstTrigger-Fs):SimulatingRange(2)*Fs:size(Data,2)
    
    IntervalData = Devide(Data,l,SimulatingRange,Fs);
    IntervalTrigger = Devide(Trigger,l,SimulatingRange,Fs);
    
    for m=1:length(TriggerSelect)
        EpochData{m} = Epoch(IntervalData,IntervalTrigger,EpochRange,TriggerSelect(m),Fs);
        BaseLineEpoch{m} = BaseLine(Epoch(IntervalData,IntervalTrigger,BaseLineRange,TriggerSelect(m),Fs),EpochRange,Fs);
        EpochData{m} = EpochData{m} - BaseLineEpoch{m};
    end
    
    for m=1:size(MdlLinear,2)
        if EpochData{m} ~= 0
            
            FilteredEpochData{m} = [];
            for n = 1:size(EpochData{m},3)
                FilteredEpochData{m} = cat(3,FilteredEpochData{m},H{m}*EpochData{m}(:,:,n));
            end

            FeatureVector = Vectorizer(FilteredEpochData{m});

            if StandardizeEnable == 1
                FeatureVector = (FeatureVector - Standardize{m}.meanvec)./Standardize{m}.stdvec;
            end
            
            if PCAEnable == 1
                FeatureVector = FeatureVector*pca{m}.U(:,1:pca{m}.k);
            end
            
            [Res{m} S{m}] = predict(MdlLinear{m},FeatureVector);
            
        else
            Res{m} = 0;
            S{m} = 0;
        end
    end
    
    NullCheck = 0;
    for m=1:3
        if sum(S{m}) == 0
            NullCheck = 1;
        end
    end
    
    if NullCheck == 0
    
    Count = Count + 1;
    %fprintf('\n');
    %fprintf('-%dth Section-\n',Count);
    %fprintf('\n');
    for m=1:size(Res,2)
        P{m} = mean(Res{m});
        %fprintf('Class %d : %f\n',m,P{m});
    end
    %fprintf('\n');
    
    %for m=1:size(P,2)
    
    Score(Count,:) = [mean(S{1}(:,2)) mean(S{2}(:,2)) mean(S{3}(:,2))];
    PScore(Count,:) = [P{1} P{2} P{3}];
    
    [M(Count,:),I(Count,:)] = max(mean(Score));
    end
    %end
    
    %break
end

%temp = sum(PScore,2);
% for l=1:length(I)
%     if temp(l) == 0
%         I(l) = 0;
%     end
% end

FalseCount = 0;
for l=1:length(I)
    if I(l) ~= CorrectClass
        FalseCount = FalseCount + 1;
    end
end

I

fprintf('Accuracy : %f%%\n',(1-FalseCount/length(I))*100);

% for l=1:size(MdlLinear,2)
%     mean(Result{l})
% end



