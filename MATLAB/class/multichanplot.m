function varargout = multichanplot( data, winLen, varargin )
% MultiChanPlot. 
% Press left and right arrow to jump forward and back. Add shift to move by 1/10th of a window. 
% Press up and down to change the y-axis scale by 10%. Press 'c' to set the plotted channels. Press 
% 'y' to set the y-axis range. Press 'l' to set the window duration. Press 'p' to set a new current
% position. Press 'x' to delete all manually-marked intervals and reset pre-loaded intervals. Press 
% 'h' to open a help window with a list of commands. 
% Marking intervals: Press the left mouse button to start marking an interval, and the right mouse
% button to finish marking an interval. Clicking the left mouse button within a marked interval will
% cancel it. Ending a marked interval within an already  marked interval will concatenate the two
% intervals. Intervals can be set across different display windows (press left mouse button, then 
% left or right keys, then right mouse button). 
% Marked intervals which have been pre-loaded into the function will appear in a different color,
% but behave identically to manually marked intervals. 
%
% Usage:
% MultiChanPlot(data,winLen):                Displays a multiple-channel plot, where "data" is a time x channels
%                                            matrix and "winLen" is the duration of the shown window. 
% MultiChanPlot(...,'ylim',[ymin ymax]):     Sets the y-scale of each channel, where YL is a 2-element
%                                            vector. Default value is the minimum and maximum values of the 
%                                            input dataset.
% MultiChanPlot(...,'channels',c):           Selects which channels will be plotted. 
% MultiChanPlot(...,'srate',sr):             Sets the sampling rate of the input data. The "winLen"
%                                            variable will be interpreted as seconds. Default value is 1. 
% MultiChanPlot(...,'maskdata',m):           Provides an initial set of marked intervals, where m is a N x 1 
%                                            vector with the same length as the input data, with  non-zero
%                                            samples corresponding to marked intervals. 
% mask = MultiChanPlot(...)                  Setting an output variable will cause the marked segments to
%                                            be exported in the form of a Nx1 boolean vector. 
% 
% Written by Edden M. Gerber, lab of Leon Y. Deouell, Sep. 2013. 
% Please send bug reports and requsts to edden.gerber@gmail.com
%
% Inspired by EEGlab's eegplot function. 

%%  Handle input

data = data';
trig = [];
ch_label_all = {};
trig_color = [];
trig_color_list = ["#0072BD","#D95319","#EDB120","#7E2F8E","#77AC30","#4DBEEE","#A2142F","r","g","b","c","m","y","k"];

yLim = [min(data(:)) max(data(:))];
channels = 1:size(data,2);
N_ch = size(data,2);
srate = 1;
maskdata = [];
ch_label = {};
arg  = 1;
while arg <= size(varargin,2)
    switch varargin{arg}
        case 'ylim'
            yLim = varargin{arg+1};
            arg = arg + 2;
        case 'channels'
            channels = varargin{arg+1};
            N_ch = length(channels);
            arg = arg + 2;
        case 'srate'
            srate = varargin{arg+1};
            arg = arg + 2;
        case 'maskdata'
            maskdata = varargin{arg+1};
            arg = arg + 2;
        case 'chlabel'
            ch_label_all = varargin{arg+1};
            arg = arg + 2;
        case 'trig'
            trig = varargin{arg+1};
            arg = arg + 2;
    end
end

ch_label = reverse_label(ch_label_all(channels));

%% Initialize

h_fig = figure;
set(h_fig,'KeyPressFcn',@f_KeyPress);

L = size(data,1);
loc = 1;
yInterv = [];
yTotal = [];
nChan = [];
winLen = round(winLen * srate);
if winLen > L
  warning(['Window size set to more than the length of the data: setting it to maximum window size (' num2str(L/srate) ').']);
  winLen = L;
end
T = (1:L) / srate;

select_on = false;
curr_select = 0;
mask = zeros(L,1);

if ~isempty(maskdata)
    mask(~~maskdata) = 2;
end

helpStr = {'Keyboard commands: ',...
                 '',...
                 'Left/right arrow              Jump one time window',...
                 'Shift+left/right arrow      Jump 1/10 time window',...
                 'Shift+Up/down arrow             Change y-axis scale by 10%',...
                 '''c''                                   Select channels to plot',...
                 '''y''                                   Set y-axis range',...
                 '''l''                                    Set window size',...
                 '''p''                                   Set new current position',...
                 '''x''                                   Reset all marked intervals',...
                 '''h''                                   Display command help',...
                 '',...
                 '',...
                 'Marking intervals: ',...
                 '',...
                 strcat('Press the left mouse button to start marking an interval, and the right mouse button ',...
                 ' to finish marking an interval. Clicking the left mouse button within a marked interval will cancel it. Ending ', ...
                 ' a marked interval within an already  marked interval will concatenate the two intervals. Intervals can be set ',...
                 ' across different display windows (press left mouse button, then left or right keys, then right mouse button). ',...
                 ' Marked intervals which have been pre-loaded into the function will appear in a different color, but behave ',...
                 ' identically to manually marked intervals. '),...
                 '',...
                 '',...
                 'Optional function input parameters:',...
                 '',...
                 '''ylim''                               Set y-axis for each channel',...
                 '''channels''                      Select subset of channels to display',...
                 '''srate''                             Set sampling rate',...
                 '''maskdata''                     Supply a vector of pre-set intervals',...
                 '',...
                 '',...
                 '',...
                 '',...
                 '',...
                 '',...
                 '',...
                 '',...
                 };
             
%%  Run

update_data;

plotfig;

waitfor(h_fig);

%% Output
if nargout > 0
    mask = mask(1:L);
    mask = ~~mask;
   varargout{1} = mask;
end

%% Nested functions

    function update_data
        yInterv = yLim(2)-yLim(1);
        nChan = length(channels);
        yTotal = yInterv * nChan;
        plotfig;
    end

    function plotfig
        dataWin = data(loc:(loc+winLen-1),channels); %データ切り出し
        dataWin = bsxfun(@minus,dataWin,dataWin(1,:)); %切り出したデータの戦闘が0になるように補正
        
        yStart = (nChan:-1:1)*yInterv-(yInterv/2); % yInterv = ylimの範囲
        dataWin = bsxfun(@plus,dataWin,yStart);
        tWin = T(loc:(loc+winLen-1));
        maskWin1 = dataWin;
        maskWin2 = dataWin;
        maskWin1(~(mask(loc:(loc+winLen-1))==1),:) = nan;
        maskWin2(~(mask(loc:(loc+winLen-1))==2),:) = nan;
        
        hold off
        plot(tWin,dataWin);
        
        hold on
        plot(tWin,maskWin1,'y','linewidth',2);
        plot(tWin,maskWin2,'c','linewidth',2);
          
        if isempty(ch_label)
            set(gca,'ytick',yStart(end:-1:1),'yticklabel',channels(end:-1:1))
        else
            set(gca,'ytick',yStart(end:-1:1),'yticklabel',ch_label)
        end
        ylim([0 yTotal]);
        xlim([tWin(1) tWin(end)]);
        
        if ~isempty(trig)
            trigWin = trig(loc:(loc+winLen-1));
            for m =1:length(trigWin)
                if trigWin(m) ~= 0
                    color = find(trig_color == trigWin(m), 1);
                    if isempty(color)
                        trig_color(length(trig_color)+1) = trigWin(m);
                        color = length(trig_color);
                    end
                    plot([tWin(m) tWin(m)],ylim,'color',trig_color_list(color),'linewidth',0.5);
                    text(tWin(m)+winLen/srate*0.001,yTotal*1.01,strcat('S',num2str(trigWin(m))),'color',trig_color_list(color),'FontSize',12);
                end
            end
        end
        
        set(gca,'ButtonDownFcn',@f_ButtonDown);
        set(get(gca,'children'),'hittest','off');
        
    end

    function r = reverse_label(label)
        tmp = {};
        for m = length(label):-1:1
            tmp{length(tmp)+1} = label{m} ;
        end
        r = tmp;
    end

    function r = ch_idx_converter(idx_vec)
        tmp = size(data,2):-1:1;
        r = tmp(idx_vec);
        clear tmp;
        r = r(end:-1:1);
    end

    function f_KeyPress( hObject, eventdata, handles )
        %eventdata.Key
        switch eventdata.Key
            case 'rightarrow'
                if ~isempty(eventdata.Modifier) && strcmp(eventdata.Modifier{1},'shift');
                    loc = loc + ceil(winLen/10);
                else
                    loc = loc + winLen;
                end
                if loc > L-winLen+1
                    loc = L-winLen+1;
                end
                plotfig;
            case 'leftarrow'
                if ~isempty(eventdata.Modifier) && strcmp(eventdata.Modifier{1},'shift');
                    loc = loc - ceil(winLen/10);
                else
                    loc = loc - winLen;
                end
                if loc < 1
                    loc = 1;
                end
                plotfig;
            case 'downarrow'
                if ~isempty(eventdata.Modifier) && strcmp(eventdata.Modifier{1},'shift');
                    Y = yLim(2)-yLim(1);
                    yLim(1) = yLim(1) - Y*0.05;
                    yLim(2) = yLim(2) + Y*0.05;
                    update_data;
                    fprintf('ylim : %.1f\x03bcV %.1f\x03bcV\n',yLim(1),(yLim(2)));
                else
                    tmp = max(channels)+N_ch;
                    if tmp > size(data,2)
                        tmp = size(data,2);
                    end
                    channels = tmp-N_ch+1:tmp;
                    clear tmp;
                    ch_label = reverse_label(ch_label_all(channels));
                    update_data;
                end
            case 'uparrow'
                if ~isempty(eventdata.Modifier) && strcmp(eventdata.Modifier{1},'shift')
                    Y = yLim(2)-yLim(1);
                    yLim(1) = yLim(1) + Y*0.05;
                    yLim(2) = yLim(2) - Y*0.05;
                    update_data;
                    fprintf('ylim : %.1f\x03bcV %.1f\x03bcV\n',yLim(1),(yLim(2)));
                else
                    tmp = min(channels)-N_ch;
                    if tmp < 1
                       tmp = 1; 
                    end
                    channels = tmp:tmp+N_ch-1;
                    clear tmp;
                    ch_label = reverse_label(ch_label_all(channels));
                    update_data;
                end
            case 'y'
                in = inputdlg('enter new y limits (ymin ymax): ','y limits',1,strcat(num2str(yLim(1)),{' '},num2str(yLim(2))));
                if ~isempty(in)
                    yLim = str2num(char(in{1}));
                     update_data;
                end
            case 'c'
                in = inputdlg('enter new channel list vector: ','channels');
                if ~isempty(in)
                    channels = str2double(in{1});
                    channels  = floor(channels); % just in case somebody is fooling around with non-integers
                    update_data;
                end
            case 'l'
                in = inputdlg('enter new window length (in seconds if s.r. is set): ','window length',1,{num2str(winLen/srate)});
                if ~isempty(in)
                    winLen = str2double(in{1}) * srate;
                    winLen  = round(winLen);
                    if winLen < 2
                        winLen = 2;
                    end
                    if winLen > L
                      warning(['Window size set to more than the length of the data: setting it to maximum window size (' num2str(L/srate) ').']);
                      winLen = L;
                    end
                    data = data(1:L,:);
                    mask = mask(1:L);
                    L = size(data,1);
                    T = (1:L) / srate;
                    if loc > L-winLen+1; loc = L-winLen+1; end
                    if loc < 1; loc = 1; end;
                    update_data;
                end
            case 'p'
                in = inputdlg(['enter new current position (0 - ' num2str(L/srate) '): '],'New position',1,{num2str(loc/srate)});
                if ~isempty(in)
                    loc = str2double(in{1}) * srate;
                    loc  = round(loc);
                    if loc < 1; loc = 1;end;
                    if loc > (L - winLen); loc = L - winLen + 1;end;
                    update_data;
                end
            case 'x'
                button = questdlg('Reset marked intervals?','','Ok','Cancel','Ok');
                if strcmp(button,'Ok')
                    mask = zeros(L,1);
                    if ~isempty(maskdata)
                        mask(~~maskdata) = 2;
                    end
                    update_data;
                end
            case 'h'
                msgbox(helpStr,'MultiChanPlot Help','modal');
        end
    end

    function f_ButtonDown(varargin )
        currp = get(gca,'CurrentPoint');
        x = currp(1,1);
        x = round(x * srate);
        if x < 1; x = 1; end
        if x > L; x = L; end
        switch get(h_fig, 'SelectionType')
            case 'normal'
                mark_data(x,1);
            case 'alt'
                mark_data(x,2);
        end
        
    end

    function mark_data(x,button)
        if button==1
            if mask(x)
                x1 = find(~mask(x:-1:1),1,'first') - 2;
                if isempty(x1); x1 = x - 1; end;
                x2 = find(~mask(x:end),1,'first') - 2;
                if isempty(x2); x2 = L-x; end;
                mask((x-x1):(x+x2)) = false;
                update_data;
            else
                curr_select = x;
                select_on = true;
            end
        else
            if select_on
                mask(min(curr_select,x):max(curr_select,x)) = 1;
                select_on = false;
                update_data;
            end
        end
    end

end

