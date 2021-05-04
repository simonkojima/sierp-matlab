classdef sieeg
    %EEG Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        data
        var
        epochs = []
    end
    
    methods
        %         function obj = EEG(data,type,time,color)
        %             obj.data = data;
        %             obj.type = type;
        %             obj.time = time;
        %             obj.color = color;
        %         end
        
        function obj = sieeg(data,varargin)
            obj.data = data;
            
            
            
            if ndims(data) == 3
                obj.epochs = obj.data;
                obj.data = mean(obj.data,3);
            end
            
            %odd = 1:2:length(varargin);
            
            %list = {'type','time','color'};
            
            for odd =1:2:length(varargin)
                %for l = 1:length(list)
                %if strcmpi(varargin{odd},list{l})
                obj.var.(varargin{odd}) = varargin{odd+1};
                %end
                %end
            end
            
        end
        
        function r = isepoch(obj)
            r = 0;
            if ~isempty(obj.epochs)
                r = 1;
            end
        end
        
        function r = getdata(obj)
            r = obj.data;
        end
        
        function r = getchdata(obj,ch)
            r = obj.data(ch,:);
        end
        
        function r = getchlabel(obj,ch)
            r = obj.var.label(ch);
        end
        
        function r = getchNdata(obj,ch,N)
            r = obj.data(ch,N);
        end
        
        function r = getNdata(obj,N)
            r = obj.data(:,N);
        end
        
        function r = getNumch(obj)
            r = size(obj.data,1);
        end
        
        function r = getcolor(obj)
            r=0;
            if isfield(obj.var,'color')
                r = obj.var.color;
            end
        end
        
        function obj = setcolor(obj,val)
            obj.var.color = val;
        end
        
        function r = gettype(obj)
            r=0;
            if isfield(obj.var,'type')
                r = obj.var.type;
            end
        end
        
        function r = getlegend(obj)
            r=0;
            if isfield(obj.var,'legend')
                r = obj.var.legend;
            end
        end
        
        function r = gettime(obj)
            r=0;
            if isfield(obj.var,'time')
                r = obj.var.time;
            end
        end
        
        function r = getepochs(obj)
            r = obj.epochs;
        end
        
        function r = getchepochs(obj,ch)
            r = squeeze(obj.epochs(ch,:,:))';
        end
        
        function r = getfs(obj)
           r = obj.var.fs; 
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

