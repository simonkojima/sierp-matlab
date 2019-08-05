clearvars
close all;

load './LowStream.mat'
Stream{1} = Average;

load './MidStream.mat'
Stream{2} = Average;

load './HighStream.mat'
Stream{3} = Average;

clear Average

DeviantSelection = 3;

StreamPlotColor  = {'r','g','b'};

%% Applying Spacial Filter

if exist('f.mat') == 0
    
    temp = [1 2 3 1 2];
    
    for l=1:size(Stream,2)
        data{l}{1} = Stream{l}.Data{l};
        data{l}{2} = cat(3,Stream{temp(l+1)}.Data{l},Stream{temp(l+2)}.Data{l});
    end
    
    for Deviant=1:size(Stream,2)
        f_{Deviant} = [];
        f{Deviant} = spatialfilter(data{Deviant},[1/3 2/3]);
        for l = 1:1
            f_{Deviant} = [f_{Deviant} f{Deviant}(:,l)];
        end
        %f{Deviant} = [f{Deviant}(:,1) f{Deviant}(:,2) f{Deviant}(:,3) f{Deviant}(:,4) f{Deviant}(:,5) f{Deviant}(:,6) f{Deviant}(:,7) f{Deviant}(:,8) f{Deviant}(:,9) f{Deviant}(:,10)];
    end
    
    f = f_;
    
    clear temp data f_;
    
    save('f.mat','f');
    
else
    load('f.mat')
end

for Attended = 1:size(Stream,2)
    for Deviant = 1:size(Stream,2)
        Stream{Attended}.F{Deviant} = [];
        for l=1:size(Stream{Attended}.Data{Deviant},3)
            Stream{Attended}.F{Deviant} = cat(3,Stream{Attended}.F{Deviant},f{Deviant}'*Stream{Attended}.Data{Deviant}(:,:,l));
        end
    end
end

%% Averaging

for Attended = 1:size(Stream,2)
    for Deviant = 1:size(Stream,2)
        Stream{Attended}.Average{Deviant} = [];
        Stream{Attended}.Average{Deviant} = mean(Stream{Attended}.F{Deviant},3);
    end
end

%% Plotting

figure();
hold on;

for l = 1:size(Stream,2)
    plot(EpochTime,mean(Stream{l}.F{DeviantSelection},3),StreamPlotColor{l});
end

axis ij

plot(xlim, [0 0], 'k','LineWidth',PlotLineWidth);
plot([0 0], ylim, 'k','LineWidth',PlotLineWidth);











