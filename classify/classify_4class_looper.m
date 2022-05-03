clearvars

files{1} = ('20200914_B36_Stream_4class');
files{2} = ('20201001_B55_Stream_4class');
files{3} = ('20201008_B42_Stream_4class');
files{4} = ('20201015_B50_Stream_4class');
files{5} = ('20201029_B48_Stream_4class');
files{6} = ('20201112_B35_Stream_4class');
files{7} = ('20201119_B51_Stream_4class');

pass = pwd;

overall = [];
for m = 1:7
    folder = files{m};
    cd(strcat(pass,'\',folder))
    run classify_4class_10fold.m
    overall{m} = result;
end
