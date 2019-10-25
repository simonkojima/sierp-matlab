classdef PLOT < handle
    %PLOT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        objEpoch
    end
    
    methods
        function obj = PLOT(obj,objEpoch)
            if isequal(class(objData),'EPOCH')
                obj.objEpoch = objEpoch;
            else
               error("Argument") ;
            end
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

