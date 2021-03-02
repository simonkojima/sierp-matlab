classdef TOPO
    %TOPO Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        data
        fig
        var
        etc
    end
    
    methods
        function obj = TOPO(data,time,ced,range,varargin)
            if isequal(class(data),'EEG')
                obj.data{1} = data;
            elseif isequal(class(data),'cell')
                obj.data = data;
            else
                error("Argument") ;
            end
            obj.var.range = range;
            obj.var.ced = ced;
            %obj.var.fs = data{1}.getfs();
            obj.var.time = time;
            obj.var.numdata = length(obj.data);
            obj.var.div = [1 1];
            obj.var.drawnlocs = [];
            for odd =1:2:length(varargin)
                obj.var.(varargin{odd}) = varargin{odd+1};
            end
            obj.init();
            obj.fig = figure();
        end
        
        function plot(obj,idx,numdata,time)
            subplot(obj.var.div(1),obj.var.div(2),idx);
            [m,I] = min(abs(obj.var.time-time));
            topoplot(obj.data{numdata}.getNdata(I),obj.var.ced,'maplimits',obj.var.range,'whitebk','on');
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

