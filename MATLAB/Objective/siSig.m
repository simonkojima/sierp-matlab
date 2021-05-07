classdef siSig < handle
    %EEG Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        eeg
        epochs = {};
        fs
        var
        etc
    end
    
    methods
        
        function obj = siSig()
            obj.eeg.data = [];
            obj.eeg.trig = [];
        end
        
        function obj = append_data(obj, eeg)
            obj.eeg.data = [obj.eeg.data eeg.data];
            obj.eeg.trig = [obj.eeg.trig eeg.trig];
            obj.fs = eeg.fs;
            if isfield(eeg,'label')
                obj.var.label = eeg.label;
            end
            obj.var.trig_idx = [];
        end
        
        function r = filter_func(obj,eeg,low,high,order)
            [B, A] = butter(order, [low high]/(obj.fs/2), 'bandpass');
            eeg.data = filtfilt(B, A, eeg.data')';
            obj.etc.filter.low = low;
            obj.etc.filter.high = high;
            obj.etc.filter.order = order;
            r = eeg;
        end
        
        function obj = filter(obj,low,high,order)
            obj.eeg = obj.filter_func(obj.eeg,low,high,order);            
        end
        
        function obj = epoch(obj,trig,range)
            cnt = 0;
            for m = 1:length(obj.eeg.trig)
                if obj.eeg.trig(m) == trig
                    cnt = cnt + 1;
                    epoch(:,:,cnt) = obj.epoch_func(obj.eeg.data,m,range);
                end
            end            
            idx = length(obj.epochs)+1;
            obj.epochs{idx}.data = epoch;
            obj.epochs{idx}.range = range;
            obj.epochs{idx}.trig = trig;
            obj.epochs{idx}.N.raw = sum(obj.eeg.trig == trig);
            obj.var.trig_idx = [obj.var.trig_idx [trig;idx]];
        end
        
        function obj = baseline(obj,trig,range)
            cnt = 0;
            for m = 1:length(obj.eeg.trig)
                if obj.eeg.trig(m) == trig
                    cnt = cnt + 1;
                    baseline(:,:,cnt) = obj.epoch_func(obj.eeg.data,m,range);
                end
            end
            
            idx = obj.trig2epochidx(trig);
            obj.epochs{idx}.baseline.data = baseline;
            obj.epochs{idx}.baseline.range = range;
            
            for m = 1:obj.epochs{idx}.N.raw
                obj.epochs{idx}.data(:,:,m) = obj.epochs{idx}.data(:,:,m) - mean(obj.epochs{idx}.baseline.data(:,:,m),2);
            end
            
        end
        
        function r = epoch_func(obj,data,ref_idx,range)
            r = data(:,ref_idx+floor(range(1)*obj.fs):(ref_idx+floor(range(2)*obj.fs)));
        end
        
        function obj = rej_th(obj,trig,ch_idx,min_uv,max_uv)
            acc = ones(1,obj.get_epoch_size(trig,3));
            
            idx = obj.trig2epochidx(trig);
            ch_data = obj.epochs{idx}.data(ch_idx,:,:);

            for m = 1:obj.get_epoch_size(trig,3)
               if min(min(ch_data(:,:,m))) < min_uv || max(max(ch_data(:,:,m))) > max_uv
                   acc(m) = 0;
               end
            end

            tmp = [];
            cnt = 0;
            for m = 1:obj.get_epoch_size(trig,3)
               if acc(m) == 1
                   cnt = cnt + 1;
                   tmp(:,:,cnt) = obj.epochs{idx}.data(:,:,m);
               end
            end

            obj.epochs{idx}.data = tmp;
            if ~isfield(obj.epochs{idx},'reject')
                obj.epochs{idx}.reject{1}.n_rej = sum(~acc);
                obj.epochs{idx}.reject{1}.ch = ch_idx;
            else
                idx_rej = length(obj.epochs{idx}.reject)+1;
                obj.epochs{idx}.reject{idx_rej}.n_rej = sum(~acc);
                obj.epochs{idx}.reject{idx_rej}.ch = ch_idx;
            end                      
            obj.epochs{idx}.N.current = obj.get_epoch_size(trig,3);
        end
        
        function r = get_epoch_size(obj,trig,dim)
            idx = obj.trig2epochidx(trig);
            if nargin == 2
                r = size(obj.epochs{idx}.data);
            elseif nargin == 3
                r = size(obj.epochs{idx}.data,dim);
            end
        end
        
        function obj = del_raw_eeg(obj)
            obj.eeg = [];
        end
        
        function r = trig2epochidx(obj,trig)
            r = obj.var.trig_idx(2,(obj.var.trig_idx(1,:) == trig));
        end
        
    end
end

