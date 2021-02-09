classdef PLOT < handle
    %PLOT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        data
        var
        etc
    end
    
    methods
        function obj = PLOT(data,time,varargin)
            if isequal(class(data),'EEG')
                obj.data{1} = data;
            elseif isequal(class(data),'cell')
                obj.data = data;
            else
                error("Argument") ;
            end
            obj.var.fs = data{1}.getfs();
            obj.var.time = time;
            obj.var.numdata = length(obj.data);
            obj.var.div = [1 1];
            obj.var.drawnlocs = [];
            for odd =1:2:length(varargin)
                obj.var.(varargin{odd}) = varargin{odd+1};
            end
            obj.init();
        end
        
        function init(obj)
           obj.var.alllinewidth = 1;
           obj.var.fontsize = 10;
        end
        
        function setalllinewidth(obj,linewidth)
            obj.var.alllinewidth = linewidth;
            for m = 1:length(obj.var.figs)
                for n = 1:length(obj.var.figs{m})
                    obj.etc{m}.linewidth = linewidth;
                    obj.var.figs{m}(n).LineWidth = linewidth;
                end
            end
        end
        
        function setallcolor(obj,color)
            obj.var.allcolor = color;
            for m = 1:length(obj.var.figs)
                for n = 1:length(obj.var.figs{m})
                    obj.etc{m}.color = color;
                    obj.var.figs{m}(n).Color = color{n};
                end
            end
        end
        
        function plot(obj,ch,loc)
            %obj.var.figs{loc}=[];
            for m = 1:obj.var.numdata
                obj.var.figs{loc}(m) = plot(obj.var.time,obj.data{m}.getchdata(ch));
                hold on;
            end
        end
        
        function setnegup(obj)
            for m = 1:length(obj.var.drawnlocs)
                subplot(obj.var.div(1),obj.var.div(2),obj.var.drawnlocs(m));
                axis ij;
            end
        end
        
        function setallfontsize(obj,fontsize)
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
            %plot([0 0], ylim,'k--','LineWidth',eeg.linewidth.axis)
            for m = 1:length(obj.var.drawnlocs)
                subplot(obj.var.div(1),obj.var.div(2),obj.var.drawnlocs(m));
                plot([0 0],ylim,'k--','linewidth',linewidth);
            end
        end
        
        function drawXaxis(obj,linewidth)
            %plot(xlim, [0 0],'k','LineWidth',eeg.linewidth.axis)
            for m = 1:length(obj.var.drawnlocs)
                subplot(obj.var.div(1),obj.var.div(2),obj.var.drawnlocs(m));
                plot(xlim,[0 0],'k','linewidth',linewidth);
            end
        end
        
        function deleteplot(obj,loc)
            delete(obj.var.figs{loc});
        end
        
        function replotdata(obj)
            for m = 1:length(obj.var.drawnlocs)
                obj.deleteplot(obj.var.drawnlocs(m))
                obj.subplot(obj.etc{obj.var.drawnlocs(m)}.ch,obj.var.drawnlocs(m))
            end
        end
        
        function calcttest(obj,alpha)
            for m = 1:obj.data{1}.getNumch
                h = [];
                p = [];
                
                t.dev=[];
                t.std=[];
                for l = 1:length(obj.data)
                    if strcmpi(obj.data{l}.gettype,'dev')
                        t.dev = cat(1,t.dev,obj.data{l}.getchepochs(m));
                    elseif strcmpi(obj.data{l}.gettype,'std')
                        t.std = cat(1,t.std,obj.data{l}.getchepochs(m));
                    end
                end
                
                [h,p,ci,stats] = ttest2(t.dev,t.std,'Alpha',alpha);
                
                obj.var.ttest{m} = h;
            end
        end
        
        function ttest(obj,alpha,color)
           obj.calcttest(alpha);
           for m = 1:length(obj.var.drawnlocs)
                obj.fillttest(obj.var.drawnlocs(m),color);
           end
           
        end
        
        function fillttest(obj,loc,color)
            ch = obj.etc{loc}.ch;
            h = obj.var.ttest{ch};
            subplot(obj.var.div(1),obj.var.div(2),loc);
            %fp = fill([x1 x1 x2 x2],[y1 y2 y2 y1],color);
            for m=1:length(obj.var.time)
                if h(m) == 1
%                     x1 = (m-1)/obj.var.fs+time(1);
%                     x2 = 1/obj.var.fs;
                    
                    x1 = obj.var.time(m);
                    x2 = obj.var.time(m)+1/obj.var.fs;
                    tmp = ylim();
                    y1 = tmp(1);
                    y2 = tmp(2);
                    
                    fp = fill([x1 x1 x2 x2],[y1 y2 y2 y1],color);
                    fp.EdgeColor = color;
                    fp.FaceAlpha = 0.1;
                end
            end
        end
        
        function subplot(obj,ch,loc)
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
            obj.plot(ch,loc);
        end
        
        function plotMono(ch,type)
            if istext(ch) && istext(type)
                if isequal(text,'average')
                    
                    %plot(objEpoch.getTime,)
                end
            else
                error("Argument");
            end
        end
    end
end

