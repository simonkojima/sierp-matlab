classdef DATA < handle
    
    properties (SetAccess = private)
        name
        path
        filename
        fs
        nch
        chLabel = 0
        data
        trigger
        dataLength
    end
    
    methods
        
        function obj = DATA()
%             if ischar(path)
%                 obj.path = path;
%             else
%                 error('Argument');
%             end
        end
        
        function obj = setPath(obj,path)
            if ischar(path)
                obj.path = path;
            else
                error('Argument');
            end
        end
        
        function concatenate(obj,objData)
            if isequal(class(objData),'DATA')
                if isequal(obj.chLabel,objData.chLabel)
                    if isequal(obj.fs,objData.fs)
                        % ch = ch
                        % fs = fs
                        obj.filename = "Concatenated";
                        temp.data = [obj.data objData.data];
                        temp.trigger = [obj.trigger objData.trigger];
                        
                        obj.data = temp.data;
                        obj.trigger = temp.trigger;
                        
                        obj.dataLength = length(obj.trigger);
                    else
                        error('Sampling Frequency Does Not Match.'); 
                    end
                elseif isequal(obj.chLabel,0)
                        % ch = ch
                        % fs = fs
                        obj.filename = "Concatenated";
                        temp.data = [obj.data objData.data];
                        temp.trigger = [obj.trigger objData.trigger];
                        
                        obj.data = temp.data;
                        obj.trigger = temp.trigger;
                        
                        obj.dataLength = length(obj.trigger);
                        
                        obj.fs = objData.fs;
                        obj.nch = objData.nch;
                        obj.chLabel = objData.chLabel;
                        
                else
                   error('Channel Arrangement Does Not Match.'); 
                end
            else    
                error('Argument');
            end
        end
        
        function loadMat(obj,filename)
            if istext(filename)
                filepath = strcat(obj.path,'/',filename);
                matfile = load(filepath);
                obj.data = matfile.Data;
                obj.fs = matfile.Fs;
                obj.trigger = matfile.Trigger;
                obj.dataLength = size(matfile.Data,2);
                obj.nch = size(matfile.Data,1);
                obj.chLabel = matfile.Label;
                obj.filename = filename;
            else
                error('Argument');
            end
            
        end
        
        function obj = setData(obj,data)
            obj.data = data;
        end
        
        function setTriggerData(obj,data)
           obj.trigger = data; 
        end
        
        function setFs(obj,fs)
           obj.fs = fs; 
        end
        
        function setName(obj,name)
           if istext(name)
               obj.name = name;
           else
              error('Argument') ;
           end
        end
        
        function setCh(obj,chnum)
            if isnumeric(chnum)
                count = 0;
                for l = 1:length(chnum)
                    count = count+1;
                    temp.data(count,:) = obj.data(chnum(l),:);
                    temp.chLabel{count} = obj.chLabel{chnum(l)};
                end
                obj.data = temp.data;
                obj.chLabel = temp.chLabel;
                obj.nch = length(chnum);
            else
                error('Argument');
            end
        end
        
        function r = getData(obj)
            r = obj.data;
        end
        
        function r = getTriggerData(obj)
            r = obj.trigger;
        end
        
        function r = getTrigger(obj)
            r = obj.trigger;
        end
        
        function r = getLength(obj)
            r =  obj.dataLength;
        end
        
        function r = getNumChannel(obj)
            r = obj.nch;
        end
        
        function r = getFs(obj)
            r = obj.fs;
        end
        
        function r = getTriggerList(obj)
            r = TriggerList(obj.trigger,0);
        end
        
        function r = getChLabel(obj)
           r = obj.chLabel; 
        end
               
        function TriggerCount =  TriggerList(Trigger,Time)
            
            if Time == 0
                Time = zeros(size(Trigger)) ;
            end
            
            TriggerList = [];
            count = 0;
            for l=1:length(Trigger)
                if Trigger(l) ~= 0
                    count = count + 1;
                    TriggerList(1,count) = Trigger(l);
                    TriggerList(2,count) = Time(l);
                end
            end
            clear count;
            
            Period = [];
            for l=1:length(TriggerList)-1
                Period(l) = TriggerList(2,l+1) - TriggerList(2,l);
            end
            
            TriggerCount = [];
            flag = 0;
            for l=1:size(TriggerList,2)
                if isempty(TriggerCount) == 1
                    TriggerCount(1,1) = TriggerList(1,l);
                    TriggerCount(2,1) = 1;
                else
                    
                    for m=1:size(TriggerCount,2)
                        if TriggerCount(1,m) == TriggerList(1,l)
                            TriggerCount(2,m) = TriggerCount(2,m) + 1;
                            flag = 0;
                            break;
                        else
                            flag = 1;
                        end
                    end
                end
                
                if flag == 1
                    index = size(TriggerCount,2)+1;
                    TriggerCount(1,index) = TriggerList(1,l);
                    TriggerCount(2,index) = 1;
                end
                
            end
            
            Temp = TriggerCount;
            
            if isempty(Temp)
                return
            end
            
            [B,I] = sort(Temp(1,:));
            TriggerCount = B;
            
            for l=1:length(TriggerCount)
                TriggerCount(2,l)  = Temp(2,I(l));
            end
            
            if Time ~= 0
                fprintf('Mean Period        : %.30f ms\n',mean(Period)*1000);
                fprintf('Standard Deviation : %.30f ms\n',std(Period)*1000);
            end
            
        end
        
    end
    
end
