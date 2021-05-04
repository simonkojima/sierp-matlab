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
            %obj.var.fs = data{1}.getfs();
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
        
        function plot(obj,idx_data,numdata,idx_subplot,time)
            subplot(obj.var.div(1),obj.var.div(2),idx_subplot);
            [m,I] = min(abs(obj.var.time-time));
            topoplot(obj.data{idx_data}{numdata}.getNdata(I),obj.var.ced,'maplimits',obj.var.range,'whitebk','on');
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

