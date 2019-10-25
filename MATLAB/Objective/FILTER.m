classdef FILTER < handle
    %FILTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        fc
        type
        order
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
        
        function obj = apply(obj,objData)
            if isequal(class(objData),'DATA')
                [B, A] = butter(obj.order, obj.fc/(objData.getFs()/2), obj.type);
                data = filtfilt(B, A, objData.getData')';
                objData.setData(data);
            else
                error('Argument') ;
            end
        end
    end
end

