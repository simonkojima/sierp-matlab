classdef siTopo
    %TOPO Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        data
        fig
        var
        etc
    end
    
    methods
        function obj = siTopo(data,ced,range,varargin)
            if isequal(class(data),'cell')
                if isequal(class(data{1}{1}),'sieeg')
                    obj.data = data;
                else
                    error("argument");
                end
            else
                error("Argument");
            end
            obj.var.range = range;
            obj.var.ced = ced;
            obj.var.time = data{1}{1}.gettime();
            obj.var.numdata = length(obj.data);
            obj.var.div = [1 1];
            obj.var.drawnlocs = [];
            for odd =1:2:length(varargin)
                obj.var.(varargin{odd}) = varargin{odd+1};
            end
            obj.init();
            obj.fig = figure();
        end
        
        function win_plot(obj,idx_data,numdata,time,idx_subplot)
            if length(time) ~= 2
               fprintf("time should be 2 dimentional vector\n");
               return
            end
            [~,t_idx(1)] = min(abs(obj.var.time-time(1)));
            [~,t_idx(2)] = min(abs(obj.var.time-time(2)));
            
            t_idx = t_idx(1):t_idx(2);
            
            data = [];
            for m = 1:length(t_idx)
               data(:,:,m) =  obj.data{idx_data}{numdata}.getNdata(t_idx(m));
            end
            %t_idx
            %size(data)
            %size(mean(data,3))
            subplot(obj.var.div(1),obj.var.div(2),idx_subplot);
            cla
            topoplot(mean(data,3),obj.var.ced,'maplimits',obj.var.range,'whitebk','on');            
        end
        
        function plot(obj,idx_data,numdata,time,idx_subplot)
            subplot(obj.var.div(1),obj.var.div(2),idx_subplot);
            cla
            obj.func_plot(idx_data,numdata,time);
%             [~,I] = min(abs(obj.var.time-time));
%             topoplot(obj.data{idx_data}{numdata}.getNdata(I),obj.var.ced,'maplimits',obj.var.range,'whitebk','on');
        end
        
        function func_plot(obj,idx_data,numdata,time)
            [~,I] = min(abs(obj.var.time-time));
            topoplot(obj.data{idx_data}{numdata}.getNdata(I),obj.var.ced,'maplimits',obj.var.range,'whitebk','on');
        end
        
        function play(obj,idx_data,numdata,fps,duration)
            figure()
            time = obj.var.time(obj.var.time >= duration(1) & obj.var.time <= duration(2));
            for m = 1:length(time)
                title([num2str(time(m)*1000,'%03.02f'),'ms'])
                %topoplot(obj.data{idx_data}{numdata}.getNdata(time(m)),obj.var.ced,'maplimits',obj.var.range,'whitebk','on');
                obj.func_plot(idx_data,numdata,time(m));
                pause(1/fps)
                clf
            end
        end
        
        function init(obj)
           obj.setcf();
           obj.var.alllinewidth = 1;
           obj.var.fontsize = 10;
        end
        
        function setcf(obj)
            set(0, 'CurrentFigure', obj.fig)
        end

    end
end

