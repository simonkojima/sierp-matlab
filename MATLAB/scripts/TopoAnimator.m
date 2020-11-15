clearvars
close all
%--------------------------------------------------------------------------
%ERP Topography Animator
%Version 0.1
%Author Simon Kojima
%Date 200905
%--------------------------------------------------------------------------
[~,foldername] = fileparts(pwd);
load(foldername)
%load(strcat(foldername,'_Diff'));

class = 4;

topolimits = [-5 5];
 
%for class = 1:4

step = 10;
frameRate = 5;

data{1} = EEG(epochs.att{class}.dev{1});
data{2} = EEG(epochs.att{class}.dev{2});
data{3} = EEG(epochs.att{class}.dev{3});
data{4} = EEG(epochs.att{class}.dev{4});

%filename = strcat(num2str(class),'_',num2str(class),'.avi');
filename = strcat(num2str(class),'.avi');

%mkdir tmp

I = 1:step:size(data{1}.getchdata(1),2);

outputVideo = VideoWriter(filename);
outputVideo.FrameRate = frameRate;
open(outputVideo)

figure('WindowState', 'maximized')

for l = 1:length(I)
    for m=1:length(data)
        subplot(1,length(data),m);
        topoplot(data{m}.getNdata(I(l)),'64ch.ced','maplimits',topolimits,'whitebk','on');
    end
    hold on
    %colorbar()
    title([num2str(EpochTime(I(l))*1000,'%03.02f'),'ms'])
    %fig = gcf;
    %fig.Position = [0 0 500 500];
    %print(strcat('./tmp/',num2str(l,'%04d'),'-djpeg'))
    %saveas(gcf,strcat('./tmp/',num2str(l,'%04d'),'.jpg'))
    %myFrame = getframe(gca);
    %size(myFrame.cdata)
    writeVideo(outputVideo,getframe(gcf))
    clf
end


% for l = 1:length(I)
%    img = imread(strcat('./tmp/',num2str(l,'%04d'),'.jpg'));
%    writeVideo(outputVideo,img)
% end

close(outputVideo)
close all
%rmdir tmp s
%end