classdef EPOCH < handle
    %EPOCH Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        range
        baseLineRange
        objeeg
        objeog
        trig
        nclass
        epochData
        eogEpochData
        averaged
        epochTime
        th
        numAll
        numAccepted
        accepted
    end
    
    methods
        function obj = EPOCH(objeeg)
            if isequal(class(objeeg),'DATA')
                obj.objeeg = objeeg;
            else
                error('Argument');
            end
        end
        
        function setRange(obj,range)
            if length(range) == 2
                obj.range = range;
            else
                error('Argument');
            end
        end
        
        function setEOGData(obj,eog)
           obj.objeog = eog; 
        end
        
        function setBaseLineRange(obj,range)
            if length(range) == 2
                obj.baseLineRange = range;
            else
                error('Argument');
            end
        end
        
        function setTrigger(obj,trignum,trigname)
            if length(trignum) == length(trigname)
                obj.trig.num = trignum;
                obj.trig.name = trigname;
                obj.nclass = length(trignum);
                
                r = obj.objeeg.getTriggerList();
                for l = 1:obj.nclass
                    for m = 1:size(r,2)
                        if r(1,m) == obj.trig.num(l)
                            obj.numAll(l) = r(2,m);
                        end
                    end
                    obj.accepted{l} = ones(1,obj.numAll(l));
                end
                
            else
                error('Argument');
            end
        end
        
        function setTh(obj,dtype,th,varargin)
            
            if istext(dtype)
                if strcmpi(dtype,'EEG')
                    epoch = obj.epochData;
                elseif strcmpi(dtype,'EOG')
                    epoch = obj.eogEpochData;
                else
                    error('Argument');
                end
            else
               error('Argument') ;
            end
            
            
            obj.th = th;
            
            
            for l = 1:obj.nclass
                r{l} = ones(1,obj.numAll(l));
                for m=1:size(epoch{l},3)
                    temp = squeeze(epoch{l}(:,:,m));
                    if min(temp(:)) < obj.th(1) || max(temp(:)) > obj.th(2)
                        r{l}(m) = 0;
                    end
                end
                obj.accepted{l} = obj.accepted{l} & r{l};
            end
            
        end
        
        function applyTh(obj)
                        
            for l=1:obj.nclass
                count = 0;
                for m=1:obj.numAll(l)
                    if obj.accepted{l}(m) == 1
                        count = count+1;
                        temp{l}(:,:,count) = obj.epochData{l}(:,:,m);
                    end
                end
                obj.numAccepted(l) = sum(obj.accepted{l});
            end
            
            obj.epochData = temp;
            
        end
        
        function averaging(obj)
            for l = 1:obj.nclass
                obj.averaged{l} = mean(obj.epochData{l},3);
            end
        end
        
        function start(obj)
            %obj.epochData = [];
            OriginalData = obj.objeeg.getData();
            TriggerData = obj.objeeg.getTrigger();
            Fs = obj.objeeg.getFs();
            obj.epochTime = obj.range(1):1/obj.objeeg.fs:obj.range(2);
            
            for l = 1:obj.nclass
                Count = 0;
                for m = 1:obj.objeeg.getLength()
                    if TriggerData(m) == obj.trig.num(l)
                        %if (m+floor(obj.range(1)*Fs) > 0) && (m+floor(obj.range(2)*Fs) <= obj.objeeg.getLength())
                            Count = Count + 1;
                            obj.epochData{l}(:,:,Count) = OriginalData(:,m+floor(obj.range(1)*Fs):(m+floor(obj.range(2)*Fs)));
                        %end
                    end
                end
            end
            
            if ~isempty(obj.objeog)
                
                OriginalData = obj.objeog.getData();
                TriggerData = obj.objeog.getTrigger();
                Fs = obj.objeog.getFs();
                %obj.epochTime = obj.range(1):1/obj.objeog.fs:obj.range(2);
                for l = 1:obj.nclass
                    Count = 0;
                    for m = 1:obj.objeog.getLength()
                        if TriggerData(m) == obj.trig.num(l)
                            %if (m+floor(obj.range(1)*Fs) > 0) && (m+floor(obj.range(2)*Fs) <= obj.objeeg.getLength())
                            Count = Count + 1;
                            obj.eogEpochData{l}(:,:,Count) = OriginalData(:,m+floor(obj.range(1)*Fs):(m+floor(obj.range(2)*Fs)));
                            %end
                        end
                    end
                end
            end
            
        end
        
        function fixBaseLine(obj)
            
            OriginalData = obj.objeeg.getData();
            TriggerData = obj.objeeg.getTrigger();
            Fs = obj.objeeg.getFs();
            
            temp = [];
            for l = 1:obj.nclass
                Count = 0;
                for m = 1:obj.objeeg.getLength()
                    
                    if TriggerData(m) == obj.trig.num(l)
                        if (m+floor(obj.baseLineRange(1)*Fs) > 0) && (m+floor(obj.baseLineRange(2)*Fs) <= obj.objeeg.getLength())
                            Count = Count + 1;
                            temp{l}(:,:,Count) = OriginalData(:,m+floor(obj.baseLineRange(1)*Fs):(m+floor(obj.baseLineRange(2)*Fs)));
                        end
                    end
                    
                end
                BaseLineData{l} = repmat(mean(temp{l},2),1,((obj.range(2)-obj.range(1))*Fs+1));
                obj.epochData{l} = obj.epochData{l} - BaseLineData{l};
            end
            
        end
        
        function r = getEpoch(obj)
            r = obj.epochData;
        end
        
        function r = getAveraged(obj)
            r = obj.averaged;
        end
        
        function r = getChIndex(obj,ch)
            ChLabel = obj.objeeg.getChLabel();
            if istext(ch)
                for l = 1:obj.objeeg.getNumChannel()
                    if isequal(ChLabel{l},ch)
                        r = l;
                    end
                end
            else
                error('Argument') ;
            end
        end
        
        function r = getTrigIndex(obj,trig)
            if istext(trig)
                for l = 1:obj.nclass()
                    if isequal(obj.trig.name{l},trig)
                        r = l;
                    end
                end
            else
                error('Argument') ;
            end
        end
        
        function r = getTime(obj)
            r = obj.epochTime;
        end
        
    end
    
end

