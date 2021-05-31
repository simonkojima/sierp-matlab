clearvars

load ./LStd

LStd = Average.AllAveraged;

load ./HStd

HStd = Average.AllAveraged;

Std{1} = LStd;
Std{2} = LStd;
Std{3} = HStd;
Std{4} = HStd;


FileName{1} = 'AttendedtoLL';
FileName{2} = 'AttendedtoLH';
FileName{3} = 'AttendedtoHL';
FileName{4} = 'AttendedtoHH';

SaveFileName{1} = 'AttendedtoLL_Diff';
SaveFileName{2} = 'AttendedtoLH_Diff';
SaveFileName{3} = 'AttendedtoHL_Diff';
SaveFileName{4} = 'AttendedtoHH_Diff';

for m=1:numel(FileName)
    
    load(FileName{m});
    data = Average.Data;
   
    for n=1:numel(data)
        for k=1:size(data{n},3)
            if n == 1 || n == 2
                data{n}(:,:,k) = data{n}(:,:,k) - Std{m}{1};
            elseif n == 3 || n == 4
                 data{n}(:,:,k) = data{n}(:,:,k) - Std{m}{2};   
            end
            
        end
    end
    
    Average.Data = data;
    
    save(SaveFileName{m},'Average','EpochTime','Fs','Label');
    
end

clearvars

[~,FolderName] = fileparts(pwd);

load('AttendedtoLL_Diff');
epochs.att{1}.dev{1} = Average.Data{1};
epochs.att{1}.dev{2} = Average.Data{2};
epochs.att{1}.dev{3} = Average.Data{3};
epochs.att{1}.dev{4} = Average.Data{4};

% av.att{1}.dev{1} = Average.AllAveraged{1};
% av.att{1}.dev{2} = Average.AllAveraged{2};
% av.att{1}.dev{3} = Average.AllAveraged{3};
% av.att{1}.dev{4} = Average.AllAveraged{4};

load('AttendedtoLH_Diff');
epochs.att{2}.dev{1} = Average.Data{1};
epochs.att{2}.dev{2} = Average.Data{2};
epochs.att{2}.dev{3} = Average.Data{3};
epochs.att{2}.dev{4} = Average.Data{4};

% av.att{2}.dev{1} = Average.AllAveraged{1};
% av.att{2}.dev{2} = Average.AllAveraged{2};
% av.att{2}.dev{3} = Average.AllAveraged{3};
% av.att{2}.dev{4} = Average.AllAveraged{4};

load('AttendedtoHL_Diff');
epochs.att{3}.dev{1} = Average.Data{1};
epochs.att{3}.dev{2} = Average.Data{2};
epochs.att{3}.dev{3} = Average.Data{3};
epochs.att{3}.dev{4} = Average.Data{4};

% av.att{3}.dev{1} = Average.AllAveraged{1};
% av.att{3}.dev{2} = Average.AllAveraged{2};
% av.att{3}.dev{3} = Average.AllAveraged{3};
% av.att{3}.dev{4} = Average.AllAveraged{4};

load('AttendedtoHH_Diff');
epochs.att{4}.dev{1} = Average.Data{1};
epochs.att{4}.dev{2} = Average.Data{2};
epochs.att{4}.dev{3} = Average.Data{3};
epochs.att{4}.dev{4} = Average.Data{4};

% av.att{4}.dev{1} = Average.AllAveraged{1};
% av.att{4}.dev{2} = Average.AllAveraged{2};
% av.att{4}.dev{3} = Average.AllAveraged{3};
% av.att{4}.dev{4} = Average.AllAveraged{4};

save(strcat(FolderName,'_Diff'),'epochs','EpochTime','Fs','Label');
