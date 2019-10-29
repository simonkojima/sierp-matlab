classdef FILTER < handle
    %FILTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        fc
        type
        order
        downsampleRate
    end
    
    methods
        function obj = FILTER(type)
            if istext(type)
                obj.type = type;
            else
                error("Argument");
            end
        end
        
        function obj = setCutoff(obj,fc)
            obj.fc = fc;
        end
        
        function obj = setOrder(obj,n)
            obj.order = n;
        end
        
        function setRate(obj,n)
           obj.downsampleRate = n; 
        end
        
        function obj = apply(obj,objData)
            if isequal(class(objData),'DATA')
                if strcmpi(obj.type,'bandpass')
                    [B, A] = butter(obj.order, obj.fc/(objData.getFs()/2), obj.type);
                    data = filtfilt(B, A, objData.getData')';
                    objData.setData(data);
                elseif strcmpi(obj.type,'downsample')
                    data = objData.getData();
                    for l=1:objData.getNumChannel
                        temp(l,:) = decimate(data(l,:),obj.downsampleRate);
                    end
                    objData.setData(temp);
                    objData.setTriggerData(TriggerDownsample(objData.getTriggerData,obj.downsampleRate,0));
                    objData.setFs(objData.getFs()/obj.downsampleRate);
                end
            else
                error('Argument') ;
            end
        end
        
        function y = TriggerDownsample(x,r,phase)
            
            
            y=[];
            for l=1+phase:r:size(x,2)
                y(length(y)+1) = x(l);
                if l~= 1
                    if sum(x(l-r+1:l)) ~= 0 && x(l) == 0
                        y(length(y)) = sum(x(l-r:l-1));
                    end
                end
            end
            
            %TriggerList(x,0);
            %TriggerList(y,0);
            
        end
        
        
    end
end

