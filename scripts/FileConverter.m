close all
clearvars
%--------------------------------------------------------------------------
%   EEG to MAT File Converter
%   Author : Simon Kojima
%   Version : 3
%--------------------------------------------------------------------------
%   Settings

EEGFileName = '20181213_B32_Stream_';
FileNumber = 6;

%--------------------------------------------------------------------------

for l=1:FileNumber
   
    FileNumberString = num2str(l);
    
    for j=1:4-strlength(FileNumberString)
        FileNumberString = strcat(num2str(0),FileNumberString);
    end
    
    Data = bva_loadeeg(strcat(strcat(EEGFileName,FileNumberString),'.vhdr'));
    Trigger = bva_readmarker(strcat(strcat(EEGFileName,FileNumberString),'.vmrk'));
    [Fs Label] = bva_readheader(strcat(strcat(EEGFileName,FileNumberString),'.vhdr'));
    
    ConvertedData.data = double(Data);

    [Row Column] = size(Data);

    ConvertedTriggerData = zeros(1,Column);
    
    [Row Column] = size(Trigger);
    
    for j=1:Column
        ConvertedTriggerData(Trigger(2,j)) = Trigger(1,j);
    end
    
    ConvertedData.trig = ConvertedTriggerData;
    
    Data = ConvertedData.data;
    Trigger = ConvertedData.trig;
    
    [Row Column] = size(Data);
    
    %Time = 0:1/Fs:(Column-1)/Fs;
    Time = 1/Fs:1/Fs:Column/Fs;
    
    save(strcat(strcat(EEGFileName,FileNumberString),'.mat'),'Data','Trigger','Time','Fs','Label');
    
end

clearvars
fprintf('Completed !!\n');
