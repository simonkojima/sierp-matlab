clearvars
close all

% 3 class

[~,foldername] = fileparts(pwd);
load(foldername)
%load(strcat(foldername,'_Diff'))

dev = 1;

color = {'r','g','b'};

for l=1:3
    if l == dev
        type{l} = 'dev';
    else
        type{l} = 'std';
    end
    data{l} = EEG(epochs.att{dev}.dev{l},'type',type{l},'label',Label,'color',color{l},'legend',strcat('Responces to D',num2str(l)),'fs',Fs);
    %data{l} = EEG(epochs.att{l}.dev{dev});
end

figuretitle = sprintf('Attended to %d',dev);

ch = {'F3','Fz','F4','C3','Cz','C4','P3','Pz','P4'};

color = {'r','g','b'};
test = PLOT(data,EpochTime,'div',[3 3]);
test.subplot(1,1)
test.subplot(32,3)
test.ttest(0.05,[0.7 0.7 0.7]);
test.drawYaxis(2);
test.drawXaxis(2);
test.replotdata();
test.drawtitle();
test.setnegup();
test.setallcolor({'r','g','b'});
test.setalllinewidth(2);
test.setallfontsize(10);
%----------------------------------------------------------