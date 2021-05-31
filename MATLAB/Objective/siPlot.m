classdef siPlot < handle
    %PLOT Summary of this class goes here
    %Detailed explanation goes here
    
    properties (SetAccess = private)
        data
        fig
        var
        etc
    end
    
    methods
        function obj = siPlot(data,varargin)
            if isequal(class(data),'cell')
                if isequal(class(data{1}{1}),'sieeg')
                    obj.data = data;
                else
                    error("argument");
                end
            else
                error("Argument");
            end
            obj.var.fs = data{1}{1}.getfs();
            obj.var.time = data{1}{1}.gettime();
            %obj.var.numdata = length(obj.data);
            obj.var.div = [1 1];
            obj.var.drawnlocs = [];
            for odd =1:2:length(varargin)
                obj.var.(varargin{odd}) = varargin{odd+1};
            end
            obj.init();
            obj.fig = figure();
        end
        
        function init(obj)
           obj.setcf();
           obj.var.alllinewidth = 1;
           obj.var.fontsize = 10;
        end
        
        function setcf(obj)
            set(0, 'CurrentFigure', obj.fig)
        end
        
        function setalllinewidth(obj,linewidth) 
            obj.setcf();
            obj.var.alllinewidth = linewidth;
            for m = 1:length(obj.var.figs.eeg)
                for n = 1:length(obj.var.figs.eeg{m})
                    obj.etc{m}.linewidth = linewidth;
                    obj.var.figs.eeg{m}(n).LineWidth = linewidth;
                end
            end
        end
        
        function setallcolor(obj,color)
            obj.setcf();
            obj.var.allcolor = color;
            for m = 1:length(obj.var.figs.eeg)
                for n = 1:length(obj.var.figs.eeg{m})
                    obj.etc{m}.color = color;
                    obj.var.figs.eeg{m}(n).Color = color{n};
                end
            end
        end
        
        function setallstyle(obj,style)
            obj.setcf();
            obj.var.allstyle = style;
            for m = 1:length(obj.var.figs.eeg)
                for n = 1:length(obj.var.figs.eeg{m})
                    obj.etc{m}.style = style;
                    obj.var.figs.eeg{m}(n).LineStyle = style{n};
                end
            end
        end
        
        function plot(obj,idx,ch,loc)
            obj.setcf();
            %obj.var.figs.eeg{loc}=[];
            for m = 1:length(obj.data{idx})
                obj.var.figs.eeg{loc}(m) = plot(obj.var.time,obj.data{idx}{m}.getchdata(ch));
                hold on;
            end
            xlim([min(obj.var.time) max(obj.var.time)])
        end
        
        function setnegup(obj)
            obj.setcf();
            for m = 1:length(obj.var.drawnlocs)
                subplot(obj.var.div(1),obj.var.div(2),obj.var.drawnlocs(m));
                axis ij;
            end
        end
        
        function setallfontsize(obj,fontsize)
            obj.setcf();
            obj.var.fontsize = fontsize;
            for m = 1:length(obj.var.drawnlocs)
                subplot(obj.var.div(1),obj.var.div(2),obj.var.drawnlocs(m));
                set(gca,'FontSize',obj.var.fontsize);
            end
        end
        
        function setdiv(obj,div)
            obj.var.div = div;
        end
        
        function drawYaxis(obj,linewidth)
            obj.setcf();
            %plot([0 0], ylim,'k--','LineWidth',eeg.linewidth.axis)
            for m = 1:length(obj.var.drawnlocs)
                subplot(obj.var.div(1),obj.var.div(2),obj.var.drawnlocs(m));
                obj.var.figs.Yaxis{obj.var.drawnlocs(m)} = plot([0 0],ylim,'k','linewidth',linewidth);
            end
        end
        
        function drawXaxis(obj,linewidth)
            obj.setcf();
            %plot(xlim, [0 0],'k','LineWidth',eeg.linewidth.axis)
            for m = 1:length(obj.var.drawnlocs)
                subplot(obj.var.div(1),obj.var.div(2),obj.var.drawnlocs(m));
                obj.var.figs.Xaxis{obj.var.drawnlocs(m)} = plot(xlim,[0 0],'k','linewidth',linewidth);
            end
        end
        
        function clear(obj)
            obj.setcf();
            clf(obj.fig)
        end
        
        function deletesingleXaxis(obj,loc)
           delete(obj.var.figs.Xaxis{loc});
        end
        
        function deletesingleYaxis(obj,loc)
           delete(obj.var.figs.Yaxis{loc});
        end
        
        function deletesingleeeg(obj,loc)
            delete(obj.var.figs.eeg{loc});
        end
        
        function deletesinglettest(obj,loc)
            delete(obj.var.figs.ttest{loc});
        end
        
        function deleteXaxis(obj)
            for m = 1:length(obj.var.drawnlocs)
                obj.deletesingleXaxis(obj.var.drawnlocs(m))
            end
        end
        
        function deleteYaxis(obj)
            for m = 1:length(obj.var.drawnlocs)
                obj.deletesingleYaxis(obj.var.drawnlocs(m))
            end
        end
        
        function deleteaxis(obj)
           obj.deleteXaxis(); 
           obj.deleteYaxis(); 
        end
        
        function deletettest(obj)
            for m = 1:length(obj.var.drawnlocs)
                obj.deletesinglettest(obj.var.drawnlocs(m))
            end
        end
        
        function deleteeeg(obj)
            for m = 1:length(obj.var.drawnlocs)
                obj.deletesingleeeg(obj.var.drawnlocs(m))
            end
        end
        
        function replotdata(obj)
            for m = 1:length(obj.var.drawnlocs)
                obj.deletesingleeeg(obj.var.drawnlocs(m))
                %obj.plotdata(obj.etc{obj.var.drawnlocs(m)}.ch,obj.var.drawnlocs(m))
                subplot(obj.var.div(1),obj.var.div(2),obj.var.drawnlocs(m));
                obj.plot(obj.etc{obj.var.drawnlocs(m)}.dataidx,obj.etc{obj.var.drawnlocs(m)}.ch,obj.var.drawnlocs(m))
            end
        end
        
        function calcttest(obj,alpha)
            for m = 1:length(obj.data)
                for n = 1:obj.data{m}{1}.getNumch
                                                          
                    h = [];
                    p = [];
                    
                    t.dev=[];
                    t.std=[];
                    for x = 1:length(obj.data{m})
                        if strcmpi(obj.data{m}{x}.gettype,'dev')
                            t.dev = cat(1,t.dev,obj.data{m}{x}.getchepochs(n));
                        elseif strcmpi(obj.data{m}{x}.gettype,'std')
                            t.std = cat(1,t.std,obj.data{m}{x}.getchepochs(n));
                        end
                    end
                    
                    [h,p,ci,stats] = ttest2(t.dev,t.std,'Alpha',alpha);
                    
                    obj.var.ttest.h{m}{n} = h;
                    
                    idx_t = [];
                    for x=1:length(h)
                        if h(x) == 1
                            idx_t(length(idx_t)+1) = x;
                        end
                    end
                    range = [];
                    if ~isempty(idx_t)
                        range(1,1) = idx_t(1);
                        tmp= 0;
                        for x = 1:length(idx_t)-1
                            if (idx_t(x+1)-idx_t(x)) ~= 1
                                tmp = tmp+1;
                                range(tmp,2) = idx_t(x);
                                range(tmp+1,1) = idx_t(x+1);
                            end
                        end
                        range(end,2) = idx_t(end);
                    end
                    obj.var.ttest.range{m}{n} = range;
                end
            end
        end
        
        function ttest(obj,alpha,color)
           obj.calcttest(alpha);      
           for m = 1:length(obj.var.drawnlocs)
                obj.fillttest(obj.var.drawnlocs(m),color);
           end
           
        end
        
        function fillttest(obj,loc,color)
            obj.setcf();
            ch = obj.etc{loc}.ch;
            %h = obj.var.ttest.h{ch};
            subplot(obj.var.div(1),obj.var.div(2),loc);
                for n = 1:size(obj.var.ttest.range{obj.etc{loc}.dataidx}{ch},1)
                    range = obj.var.ttest.range{obj.etc{loc}.dataidx}{ch}(n,:);
                    x1 = obj.var.time(range(1));
                    x2 = obj.var.time(range(2));
                    tmp = ylim();
                    y1 = tmp(1);
                    y2 = tmp(2);
                    obj.var.figs.ttest{loc}(n) = fill([x1 x1 x2 x2],[y1 y2 y2 y1],color);
                    obj.var.figs.ttest{loc}(n).EdgeColor = color;
                    obj.var.figs.ttest{loc}(n).FaceAlpha = 0.5;
                    %fp = fill([x1 x1 x2 x2],[y1 y2 y2 y1],color);
                    %fp.EdgeColor = color;
                    %fp.FaceAlpha = 0.5;
                end
        end
        
        function plotdata(obj,idx,ch,loc)
            obj.setcf();
            %obj.clear();
            if length(obj.var.div) ~= 2
                error("set div properly by using 'setdiv.'");
            end
            %             for odd =1:2:length(varargin)
            %                 obj.var.(varargin{odd}){loc} = varargin{odd+1};
            %             end
            subplot(obj.var.div(1),obj.var.div(2),loc);
            obj.etc{obj.var.div(1)*obj.var.div(2)} = [];
            obj.var.drawnlocs(length(obj.var.drawnlocs)+1) = loc;
            obj.etc{loc}.ch = ch;
            obj.etc{loc}.dataidx = idx;
            obj.plot(idx,ch,loc);
            obj.etc{loc}.ylim = ylim();
        end
        
        function optylim(obj)
            obj.setcf();
            for m = 1:length(obj.var.drawnlocs)
                subplot(obj.var.div(1),obj.var.div(2),obj.var.drawnlocs(m));
                ylim(obj.etc{obj.var.drawnlocs(m)}.ylim);
            end
        end
        
        function title(obj)
            obj.setcf();
            for m = 1:length(obj.var.drawnlocs)
                subplot(obj.var.div(1),obj.var.div(2),obj.var.drawnlocs(m));
                title(obj.data{1}.getchlabel(obj.etc{obj.var.drawnlocs(m)}.ch));
            end
        end
        
        function xlabel(obj,label)
            for m = 1:length(obj.var.drawnlocs)
                subplot(obj.var.div(1),obj.var.div(2),obj.var.drawnlocs(m));
                xlabel(label); 
            end
        end
        
        function ylabel(obj,label)
            for m = 1:length(obj.var.drawnlocs)
                subplot(obj.var.div(1),obj.var.div(2),obj.var.drawnlocs(m));
                ylabel(label); 
            end
        end
        
        function legend(obj,loc)
            obj.setcf();
            subplot(obj.var.div(1),obj.var.div(2),loc);
            legends = {};
            for m = 1:length(obj.data{obj.get_dataidx(loc)})
                legends{length(legends)+1} = obj.data{obj.get_dataidx(loc)}{m}.getlegend();
            end
            legend(obj.var.figs.eeg{obj.var.drawnlocs(loc)},legends)
        end
        
        function r = get_dataidx(obj,loc)
            r = obj.etc{loc}.dataidx;
        end
        
    end
end

