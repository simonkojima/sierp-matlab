clearvars
close all
%--------------------------------------------------------------------------
%ERP Plotter
%Version 0.1
%Author Simon Kojima
%Date 200905
%--------------------------------------------------------------------------
%four class

[~,foldername] = fileparts(pwd);
load(foldername)
%load(strcat(foldername,'_Diff'))

dev = 4;

color = {'r','g','b','c'};

for l=1:4
    if l == dev
        type{l} = 'dev';
    else
        type{l} = 'std';
    end
    data{l} = EEG(epochs.att{dev}.dev{l},'type',type{l},'color',color{l},'legend',strcat('Responces to D',num2str(l)));
    %data{l} = EEG(epochs.att{l}.dev{dev});
end

figuretitle = sprintf('Attended to %d',dev);

%--------------------------------------------------------------------------
% 3 class

% [~,foldername] = fileparts(pwd);
% load(foldername)
% %load(strcat(foldername,'_Diff'))
% 
% dev = 1;
% 
% color = {'r','g','b'};
% 
% for l=1:3
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
%----------------------------------------------------------

% att = 3;
% 
% color = {'r','g','b'};
% 
% load('AttendedtoL')
% epochs.att{1}.std{1} = Average.Data{1};
% epochs.att{1}.std{2} = Average.Data{2};
% load('AttendedtoH')
% epochs.att{2}.std{1} = Average.Data{1};
% epochs.att{2}.std{2} = Average.Data{2};
% load('AttendedtoN')
% epochs.att{3}.std{1} = Average.Data{1};
% epochs.att{3}.std{2} = Average.Data{2};
% 
% legends{1} = 'Responses to Low';
% legends{2} = 'Responses to High';
% 
% for l=1:2
% %     if l == std
% %         type{l} = 'dev';
% %     else
% %         type{l} = 'std';
% %     end
%     %data{l} = EEG(epochs.att{dev}.dev{l},'type',type{l},'color',color{l},'legend',strcat('Responces to ',num2str(l)));
%     data{l} = EEG(epochs.att{att}.std{l},'color',color{l},'legend',legends{l});
%     %data{l} = EEG(epochs.att{l}.dev{dev});
% end
% 
% figuretitle = sprintf('Attended to %d',att);

%----------------------------------------------------------

% std = 1;
% 
% color = {'r','g','b'};
% 
% load('AttendedtoL')
% epochs.att{1}.std{1} = Average.Data{1};
% epochs.att{1}.std{2} = Average.Data{2};
% load('AttendedtoH')
% epochs.att{2}.std{1} = Average.Data{1};
% epochs.att{2}.std{2} = Average.Data{2};
% load('AttendedtoN')
% epochs.att{3}.std{1} = Average.Data{1};
% epochs.att{3}.std{2} = Average.Data{2};
% 
% legends{1} = 'Attended to Low';
% legends{2} = 'Attended to High';
% legends{3} = 'Attended to None';
% 
% for l=1:3
% %     if l == std
% %         type{l} = 'dev';
% %     else
% %         type{l} = 'std';
% %     end
%     %data{l} = EEG(epochs.att{dev}.dev{l},'type',type{l},'color',color{l},'legend',strcat('Responces to ',num2str(l)));
%     data{l} = EEG(epochs.att{l}.std{std},'color',color{l},'legend',legends{l});
%     %data{l} = EEG(epochs.att{l}.dev{dev});
% end
% 
% figuretitle = sprintf('Responces to %d',std);

%----------------------------------------------------------

ch = find(strcmpi(Label,'Fz')==1);
time = EpochTime;

preference.legendEnable = true;
preference.titleEnable = 0;

config.fs = Fs;
config.chlabel = Label;

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
 topo.index = 'dev';%all
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
hold on
if preference.titleEnable == true
    title(config.chlabel{ch}) ;
end
%----------------------------------------------------------
for l = 1:length(data)
    plot(time,data{l}.getchdata(ch),'k');
end
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

%----------------------------------------------------------
% draw topography
if topo.enable == true
    topo.label = config.chlabel;
    drawtopoInother = 0;
    if ~isfield(topo,'range') || strcmpi(topo.range,'sameaseegplot')
        figure(f.eeg)
        topo.range = ylim();
    end
    if isfield(topo,'windowmode') && strcmpi(topo.windowmode,'compile')
        if ~isfield(topo,'compilenum')
            topo.compilenum = 5;
        end
    end
    if ~isfield(topo,'file')
        topo.file = strcat(num2str(data{topo.index}.getNumch),'ch.ced');
    end
    if ~isfield(topo,'time') || strcmpi(topo.time,'terminal')
        drawtopoInother = 1;
        topo.timeineeg = 0;
        topo.num = 0;
        while(1)
            if numel(topo.index) == 1
                if setting.findpeaks.pos(topo.index) == 1 && setting.findpeaks.neg(topo.index) == 1
                    
                    peaklocs = [pospeaklocs{topo.index} negpeaklocs{topo.index}];
                    [peaklocs,Idx] = sort(peaklocs);
                    topodata = data{topo.index}.getchNdata(ch,peaklocs);
                    fprintf(strcat('    time : amp(',Label{ch},')\n'))
                    fprintf('--------------------\n')
                    for l=1:length(peaklocs)
                        if isempty(find(pospeaklocs{topo.index} == peaklocs(l), 1))
                            fprintf('Neg')
                        else
                            fprintf('Pos')
                        end
                        fprintf('%5.0f ms : %- 3.3f\n',time(peaklocs(l))*1000,topodata(l))
                    end
                elseif setting.findpeaks.pos(topo.index) == 1
                    fprintf(strcat('    time : amp(',Label{ch},')\n'))
                    fprintf('-------------------\n')
                    topodata = data{topo.index}.getchNdata(ch,pospeaklocs{topo.index});
                    for l=1:length(pospeaklocs{topo.index})
                        fprintf('Pos')
                        fprintf('%5.0f ms : %- 3.3f\n',time(pospeaklocs{topo.index}(l))*1000,topodata(l))
                    end
                    
                elseif setting.findpeaks.neg(topo.index) == 1
                    fprintf(strcat('    time : amp(',Label{ch},')\n'))
                    fprintf('-------------------\n')
                    topodata = data{topo.index}.getchNdata(ch,negpeaklocs{topo.index});
                    for l=1:length(negpeaklocs{topo.index})
                        fprintf('Neg')
                        fprintf('%5.0f ms : %- 3.3f\n',time(negpeaklocs{topo.index}(l))*1000,topodata(l))
                    end
                end
            end
            
            if strcmpi(topo.range,'sameaseegplot')
                figure(f.eeg)
                topo.range = ylim();
            end
            
            s = input('Type time in ms. or just press Enter to exit.\n');
            if isempty(s)
                break
            end
            s = s/1000;
            [m,I] = min(abs(time-s));
            
            if ~isfield(topo,'windowmode') || strcmpi(topo.windowmode,'new')
                topo.figName = strcat('Topography(',num2str(time(I)*1000),'ms), ',figuretitle);
                drawnewtopo(topo,time,I,data,preference,ch);
            elseif strcmpi(topo.windowmode,'compile')
                if numel(topo.index) == 1
                    topo.figName = strcat('Topography',figuretitle);
                    topo.num = drawcompiledtopo(topo,time,I,data,preference,ch);
                elseif strcmpi(topo.index,'all')
                    topo.figName = strcat('Topography (',num2str(1000*s),'ms)');
                    for i=1:numel(data)
                        topo.idx_tmp = i;
                        topo.num = drawcompiledtopo(topo,time,I,data,preference,ch);
                    end
                elseif numel(topo.index) > 1
                    topo.figName = strcat('Topography (',num2str(1000*s),'ms)');
                    for i=1:numel(topo.index)
                        topo.idx_tmp = topo.index(i);
                        topo.num = drawcompiledtopo(topo,time,I,data,preference,ch);
                    end
                end
            end
            
            
        end
    elseif strcmpi(topo.time,'auto')
        [~,I] = max(abs(data{topo.index}.getchdata(ch)));
        topo.figName = strcat('Topography(',num2str(time(I)*1000),'ms), ',figuretitle);
    elseif strcmpi(topo.time,'all') % Topo Mode = ALL
        drawtopoInother = 1;
        topo.timeineeg = 0;
        %--------------------------------------------------------------------
        % topo for pos peaks
        if max(setting.findpeaks.pos) == 1
            topo.figName = strcat('Topography(Positive Peaks), ',figuretitle);
            f.('postopo') = figure('Name',topo.figName,'NumberTitle','off');
            hold on
            topo.colorbar = 0;
            for l = 1:length(pospeaklocs{topo.index})
                subplot(1,length(pospeaklocs{topo.index}),l)
                drawtopo(topo,time,pospeaklocs{topo.index}(l),data,preference,ch);
            end
        end
        %--------------------------------------------------------------------
        % topo for neg peaks
        if max(setting.findpeaks.neg) == 1
            topo.figName = strcat('Topography(Negative Peaks), ',figuretitle);
            f.('negtopo') = figure('Name',topo.figName,'NumberTitle','off');
            hold on
            topo.colorbar = 0;
            for l = 1:length(negpeaklocs{topo.index})
                subplot(1,length(negpeaklocs{topo.index}),l)
                drawtopo(topo,time,negpeaklocs{topo.index}(l),data,preference,ch);
            end
        end
    elseif strcmpi(topo.time,'range') % Topo Mode = RANGE
        drawtopoInother = 1;
        topo.timeineeg = 0;
        %--------------------------------------------------------------------
        % topo for pos peaks
        if max(setting.findpeaks.pos) == 1
            topo.figName = strcat('Topography(Positive Peaks), ',figuretitle);
            f.('postopo') = figure('Name',topo.figName,'NumberTitle','off');
            hold on
            topo.colorbar = 0;
            topoTimeIndex = find(time(pospeaklocs{topo.index})>= topo.timerange(1) & time(pospeaklocs{topo.index})<= topo.timerange(2));
            for l = 1:length(topoTimeIndex)
                subplot(1,length(topoTimeIndex),l)
                drawtopo(topo,time,pospeaklocs{topo.index}(topoTimeIndex(l)),data,preference,ch);
            end
        end
        %--------------------------------------------------------------------
        % topo for neg peaks
        if max(setting.findpeaks.neg) == 1
            topo.figName = strcat('Topography(Negative Peaks), ',figuretitle);
            f.('negtopo') = figure('Name',topo.figName,'NumberTitle','off');
            hold on
            topo.colorbar = 0;
            topoTimeIndex = find(time(negpeaklocs{topo.index})>= topo.timerange(1) & time(negpeaklocs{topo.index})<= topo.timerange(2));
            for l = 1:length(topoTimeIndex)
                subplot(1,length(topoTimeIndex),l)
                drawtopo(topo,time,negpeaklocs{topo.index}(topoTimeIndex(l)),data,preference,ch);
            end
        end
    else
        %--------------------------------------------------------------------
        % it topo.time is numeric
        drawtopoInother = 1;
        if ~isfield(topo,'timeformat') || strcmpi(topo.timeformat,'ms')
            topo.time = topo.time/1000;
        end
        
        if ~isfield(topo,'windowmode') || strcmpi(topo.windowmode,'new')
            drawtopoInother = 1;
            for l=1:length(topo.time)
                [m,I] = min(abs(time-topo.time(l)));
                topo.figName = strcat('Topography(',num2str(time(I)*1000),'ms), ',figuretitle);
                drawnewtopo(topo,time,I,data,preference,ch);
            end
        elseif strcmpi(topo.windowmode,'compile')
            topo.num = 0;
            
            if numel(topo.index) == 1
                topo.figName = strcat('Topography',figuretitle);
                for l=1:length(topo.time)
                    [m,I] = min(abs(time-topo.time(l)));
                    topo.num = drawcompiledtopo(topo,time,I,data,preference,ch);
                end
            elseif strcmpi(topo.index,'all')
                topo.timeineeg = 0;
                for l=1:length(topo.time)
                    [m,I] = min(abs(time-topo.time(l)));
                    topo.figName = strcat('Topography (',num2str(1000*time(I)),'ms)');
                    for i=1:numel(data)
                        topo.idx_tmp = i;
                        topo.num = drawcompiledtopo(topo,time,I,data,preference,ch);
                    end
                end
            elseif numel(topo.index) > 1
                topo.timeineeg = 0;
                for l=1:length(topo.time)               
                    [m,I] = min(abs(time-topo.time(l)));
                    topo.figName = strcat('Topography (',num2str(1000*time(I)),'ms)');
                    for i=1:numel(topo.index)
                        topo.idx_tmp = topo.index(i);
                        topo.num = drawcompiledtopo(topo,time,I,data,preference,ch);
                    end
                end
            end
            
        end
    end
    
    if drawtopoInother == 0
        
        f.('topo') = figure('Name',topo.figName,'NumberTitle','off');
        hold on
        
        drawtopo(topo,time,I,data,preference,ch);
        
    end
    
    if isfield(topo,'timeineeg') && topo.timeineeg == 1
        figure(f.eeg)
        plot([time(I) time(I)], ylim, strcat(data{devIndex}.getcolor(),'-'),'LineWidth',eeg.linewidth.other)
    end
end
%----------------------------------------------------------
% if isfield(preference,'legendEnable') && preference.legendEnable == true
%     figure(f.eeg)
%     for l =1:length(data)
%         leg{l} = data{l}.getlegend();
%     end
%     legend(h,leg)
% end




%----------------------------------------------------------
%----------------------------------------------------------
% function
%----------------------------------------------------------
%----------------------------------------------------------



function drawnewtopo(topo,time,I,data,preference,ch)
f.('topo') = figure('Name',topo.figName,'NumberTitle','off');
hold on
drawtopo(topo,time,I,data,preference,ch);
end

function num = drawcompiledtopo(topo,time,I,data,preference,ch)
topo.colorbar = 0;
if topo.num == 0
    f.('topo') = figure('Name',topo.figName,'NumberTitle','off');
    hold on
end
topo.num = topo.num + 1;
subplot(1,topo.compilenum,topo.num)
drawtopo(topo,time,I,data,preference,ch);
if topo.num == topo.compilenum
    topo.num = 0;
end
num = topo.num;
end

function drawtopo(topo,time,I,data,preference,ch)

if preference.titleEnable == true
    if numel(topo.index) == 1
        title({strcat(num2str(time(I)*1000),'ms'),strcat(num2str(data{topo.idx_tmp}.getchNdata(ch,I),3),'\muV (',topo.label{ch},')')});
    elseif numel(topo.index) > 1 && preference.legendEnable
        title({data{topo.idx_tmp}.getlegend,strcat(num2str(data{topo.idx_tmp}.getchNdata(ch,I),3),'\muV (',topo.label{ch},')')});
    elseif numel(topo.index) > 1 &&  preference.legendEnable == false
        title({strcat('Data#',num2str(topo.idx_tmp)),strcat(num2str(data{topo.idx_tmp}.getchNdata(ch,I),3),'\muV (',topo.label{ch},')')});
    end
end

topoplot(data{topo.idx_tmp}.getNdata(I),topo.file,'maplimits',topo.range,'whitebk','on');
if isfield(topo,'colorbar') && topo.colorbar == true
    colorbar()
end

end





