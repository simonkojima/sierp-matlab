clearvars
%--------------------------------------------------------------------------
%   EEG to MAT File Converter
%   Author : Simon Kojima
%   Version : 4
%--------------------------------------------------------------------------

[Path,FolderName] = fileparts(pwd);
EEGFileName = strcat(Path,'/',FolderName,'/',FolderName,'_');

%--------------------------------------------------------------------------
idx = 0;
while 1
    idx = idx + 1;
    
    FileNumberString = num2str(idx);
    for m = 1:4-strlength(num2str(idx))
        FileNumberString = strcat(num2str(0),FileNumberString);
    end

    if exist(strcat(EEGFileName,FileNumberString,'.eeg')) ~= 2
        return
    end
    
    data = bva_loadeeg(strcat(EEGFileName,FileNumberString,'.vhdr'));
    eeg.data = double(data);
    
    trig = bva_readmarker(strcat(EEGFileName,FileNumberString,'.vmrk'));
    
    ConvertedTriggerData = zeros(1,size(eeg.data,2));
    
    for m=1:size(trig,2)
        ConvertedTriggerData(trig(2,m)) = trig(1,m);
    end
    
    eeg.trig = ConvertedTriggerData;
    
    [eeg.fs,eeg.label] = bva_readheader(strcat(EEGFileName,FileNumberString,'.vhdr'));
    
    eeg.time = 1/eeg.fs:1/eeg.fs:size(eeg.data,2)/eeg.fs;
    
    
    save(strcat(EEGFileName,FileNumberString,'.mat'),'eeg');
end