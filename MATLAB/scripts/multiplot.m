clearvars
close all
%--------------------------------------------------------------------------
%ERP Plotter
%Version 0.1
%Author Simon Kojima
%Date 200905
%--------------------------------------------------------------------------
% %four class
% 
% [~,foldername] = fileparts(pwd);
% load(foldername)
% %load(strcat(foldername,'_Diff'))
% 
% dev = 4;
% 
% color = {'r','g','b','c'};
% 
% for l=1:4
%     if l == dev
%         type{l} = 'dev';
%     else
%         type{l} = 'std';
%     end
%     data{l} = EEG(epochs.att{dev}.dev{l},'type',type{l},'color',color{l},'legend',strcat('Responces to D',num2str(l)));
%     %data{l} = EEG(epochs.att{l}.dev{dev});
% end
% 
% figuretitle = sprintf('Attended to %d',dev);

%--------------------------------------------------------------------------
%3 class

[~,foldername] = fileparts(pwd);
load(foldername)
%load(strcat(foldername,'_Diff'))

dev = 3;

color = {'r','g','b'};

for l=1:3
    if l == dev
        type{l} = 'dev';
    else
        type{l} = 'std';
    end
    data{l} = EEG(epochs.att{dev}.dev{l},'type',type{l},'color',color{l},'legend',strcat('Responces to D',num2str(l)));
    %data{l} = EEG(epochs.att{l}.dev{dev});
end

figuretitle = sprintf('Attended to %d',dev);
%----------------------------------------------------------

ch = find(strcmpi(Label,'Cz')==1);
time = EpochTime;

preference.legendEnable = 0;
preference.titleEnable = 0;

preference.fontsize = 20;

config.fs = Fs;
config.chlabel = Label;

div = [3 3];
divch = [10 12 14 30 32 34 50 52 54];
divlocs = [1 2 3 4 5 6 7 8 9];

%devidx = zeros(1,4);
%devidx(dev) = 1;
%setting.findpeaks.pos = devidx;

eeg.linewidth.data = 2;
eeg.linewidth.axis = 2;
eeg.linewidth.other = 2;

eeg.ylabel = 'Potential (\muV)';
eeg.xlabel = 'Time (s)';

 ttest.enable = 1;
 ttest.alpha = 0.05;
 ttest.color = [0.7 0.7 0.7];
% 
 topo.enable = 1;
 topo.file = '64ch.ced';
 %topo.index = 'dev';%all
 topo.index = 1;
 topo.time = [0.2 0.25 0.3 0.35 0.4];
 topo.range = [-10 10];
 %topo.range = [-10 10];

%----------------------------------------------------------

for l = 1:length(data)
    if strcmpi(data{l}.gettype(),'dev')
        isdev(l) = 1;
    else
        isdev(l) = 0;
    end
end

devIndex = find(isdev==1);

tmp.color = {'#0072BD','#D95319','#EDB120','#7E2F8E','#77AC30',	'#4DBEEE','#A2142F'};
tmp.count = 0;
for l = 1:length(data)
    if data{l}.getcolor() == 0
        tmp.count = tmp.count + 1;
        data{l} = data{l}.setcolor(tmp.color{rem(tmp.count,length(tmp.color))});
    end
end
clear tmp;

if ~exist('setting','var') || ~isfield(setting.findpeaks,'pos')
    setting.findpeaks.pos = zeros(1,length(data));
elseif strcmpi(setting.findpeaks.pos,'dev')
    setting.findpeaks.pos = isdev;
end

if ~isfield(setting.findpeaks,'neg')
    setting.findpeaks.neg = zeros(1,length(data));
elseif strcmpi(setting.findpeaks.neg,'dev')
    setting.findpeaks.neg = isdev;
end

if ~exist('topo','var')
    topo.enable = false;
end

if topo.enable == true && strcmpi(topo.index,'dev')
    if ~isempty(devIndex)
        topo.index = devIndex;
        topo.idx_tmp = topo.index;
    else
        error('specify topo.index.')
    end
end

if topo.enable == true && isnumeric(topo.index) && numel(topo.index) == 1
    topo.idx_tmp = topo.index;
end

if topo.enable == true && (~isfield(topo,'index') || strcmpi(topo.index,'all'))
    topo.index = 'all';
    topo.windowmode = 'compile';
    topo.compilenum = numel(data);
end

if topo.enable == true && isnumeric(topo.index) && numel(topo.index) > 1
    topo.windowmode = 'compile';
    topo.compilenum = numel(topo.index);
end

if ~exist('eeg','var') || ~isfield(eeg,'linewidth') ||~isfield(eeg.linewidth,'data')
    eeg.linewidth.data = 1;
end
if ~isfield(eeg.linewidth,'axis')
    eeg.linewidth.axis = 1;
end
if ~isfield(eeg.linewidth,'other')
    eeg.linewidth.other = 1;
end
if ~exist('preference','var') || ~isfield(preference,'titleEnable')
    preference.titleEnable = 1;
end

if ~exist('preference','var') || ~isfield(preference,'legendEnable')
    preference.legendEnable = 0;
end

if ~exist('config','var') || ~isfield(config,'chlabel')
    warning("channel label config.chlabel doesn't set.")
    for l=1:data{1}.getNumch()
        config.chlabel{l} = 'Unknown';
    end
end


%----------------------------------------------------------
f.('eeg') = figure('Name',strcat('EEG (',config.chlabel{ch},'), ',figuretitle),'NumberTitle','off');
set(gcf, 'WindowState', 'maximized');
%for div---------------------------------------------------
for divrep = 1:length(divlocs)
    ch = divch(divrep);
%for div---------------------------------------------------

if preference.titleEnable == true
    title(config.chlabel{ch});
end
%----------------------------------------------------------
subplot(div(1),div(2),divlocs(divrep));
for l = 1:length(data)
    plot(time,data{l}.getchdata(ch),'k');
    hold on
end
set(gca,'FontSize',preference.fontsize);
%----------------------------------------------------------
if isfield(eeg,'yrange')
    if strcmpi(eeg.yrange,'auto')
        ylim('auto')
    else
        ylim(eeg.yrange);
    end
else
    ylim('auto')
end
xlim([time(1) time(end)])
%----------------------------------------------------------
%% ttest
for l = 1:length(data)
    ttest.available = 1;
    if ~data{l}.isepoch()
        ttest.available = 0;
    end
end

if ttest.available == 0
    fprintf("Can't apply ttest.\n")
end

if isfield(ttest,'enable') && ttest.enable == 1 && ttest.available == 1
    
    if ~isfield(config,'fs')
        error("sampling freq config.fs doesn't set.")
    end
    
    if ~isfield(ttest,'alpha')
        ttest.alpha = 0.05;
    end
    
    if ~isfield(ttest,'color')
        ttest.color = [0.7 0.7 0.7];
    end
    
    ttest.h = [];
    ttest.p = [];
    
    t.dev=[];
    t.std=[];
    for l = 1:length(data)
        if strcmpi(data{l}.gettype,'dev')
            t.dev = cat(1,t.dev,data{l}.getchepochs(ch));
        elseif strcmpi(data{l}.gettype,'std')
            t.std = cat(1,t.std,data{l}.getchepochs(ch));
        end
    end
    
    [h,p,ci,stats] = ttest2(t.dev,t.std,'Alpha',ttest.alpha);
    ttest.h(l,:) = h;
    ttest.p(l,:) = p;
    
    eegy = ylim();
    
    for m=1:length(time)
        if ttest.h(l,m) == 1
            %rectangle('Position',[(m-1)/Fs+Range(1) yrange(1) 1/Fs (yrange(2)-yrange(1))],'FaceColor',FillingColor,'EdgeColor',FillingColor,'LineStyle','none');
            rectangle('Position',[(m-1)/config.fs+time(1) eegy(1) 1/config.fs (eegy(2)-eegy(1))*0.998],'FaceColor',ttest.color,'EdgeColor',ttest.color,'LineStyle','none');
        end
    end
    
end
%----------------------------------------------------------
h=[];
for l = 1:length(data)
    h = [h plot(time,data{l}.getchdata(ch),'color',data{l}.getcolor(),'LineWidth',eeg.linewidth.data)];
end
%----------------------------------------------------------
if max(setting.findpeaks.pos) == 1
    for l =1:length(data)
        if setting.findpeaks.pos(l) == 1
            [~,pospeaklocs{l}] = findpeaks(data{l}.getchdata(ch));
            for m = 1:length(pospeaklocs{l})
                plot([time(pospeaklocs{l}(m)) time(pospeaklocs{l}(m))], ylim,'color',data{l}.getcolor(),'LineStyle','--','LineWidth',eeg.linewidth.other)
            end
        end
    end
end
%----------------------------------------------------------
if max(setting.findpeaks.neg) == 1
    for l =1:length(data)
        if setting.findpeaks.neg(l) == 1
            negpeaklocs{l} = islocalmin(data{l}.getchdata(ch));
            negpeaklocs{l} = find(negpeaklocs{l} == 1);
            for m = 1:length(negpeaklocs{l})
                plot([time(negpeaklocs{l}(m)) time(negpeaklocs{l}(m))], ylim,'color',data{l}.getcolor(),'linestyle',':','LineWidth',eeg.linewidth.other)
            end
        end
    end
end
%----------------------------------------------------------
if ~exist('eeg','var')
    eeg.inverted = true;
end

if ~isfield(eeg,'inverted') || eeg.inverted == true
    axis ij
end
if isfield(eeg,'xtickdir')
    set(gca,'tickdir',eeg.xtickdir)
end
if isfield(eeg,'xtick')
    xticks(eeg.xtick);
end
if isfield(eeg,'xticklabels')
    xticklabels(eeg.xticklabels);
end
if isfield(eeg,'ylabel')
    ylabel(eeg.ylabel);
end
if isfield(eeg,'xlabel')
    xlabel(eeg.xlabel);
end
plot(xlim, [0 0],'k','LineWidth',eeg.linewidth.axis)
plot([0 0], ylim,'k--','LineWidth',eeg.linewidth.axis)

%----------------------------------------------------------
if isfield(preference,'legendEnable') && preference.legendEnable == true
    figure(f.eeg)
    for l =1:length(data)
        leg{l} = data{l}.getlegend();
    end
    legend(h,leg)
end
%for div---------------------------------------------------
end
%for div---------------------------------------------------
%----------------------------------------------------------
