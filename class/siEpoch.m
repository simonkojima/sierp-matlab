%
% siEpoch
%
% Author : Simon Kojima
% Ver1.0 2021/08/26
% Ver1.1 2021/09/14
% Ver1.2 2021/09/14

classdef siEpoch < handle
    
    properties
        data
		time
        trigs
		num
		props
		etc
    end
    
    methods

        function obj = siEpoch(sig,trig_num,range,baseline)
			obj.etc.trig_num = trig_num;
			obj.etc.range = range;
			obj.etc.baseline = baseline;
			obj.props = sig.props;
			obj.time = obj.etc.range(1):1/obj.props.fs:obj.etc.range(2);
            
            [~,trig_list] = sig.get_trig_list();
            idx = find(trig_list(:,2)==trig_num);
            obj.trigs = trig_list(idx,:);
            obj.trigs = cat(2,obj.trigs,zeros(size(obj.trigs,1),1));

			fields = fieldnames(sig.etc);
			for m = 1:length(fields)
				obj.props.(fields{m}) = getfield(sig.etc,fields{m});
			end

			obj.data = [];
			baseline_epoch = [];
			cnt = 0;
			for m = 1:length(trig_list)
				if trig_list(m,2) == trig_num
					cnt = cnt + 1;
					obj.data(:,:,cnt) = obj.cut_out(sig.data,trig_list(m,1),floor(obj.props.fs*range));
				end
			end
			obj.num.before_rej = cnt;
			obj.num.current = cnt;

			if ~isempty(obj.etc.baseline)
				baseline_epoch = [];
				cnt = 0;
				for m = 1:length(trig_list)
					if trig_list(m,2) == trig_num
						cnt = cnt + 1;
						baseline_epoch(:,:,cnt) = obj.cut_out(sig.data,trig_list(m,1),floor(obj.props.fs*baseline));
					end
				end
				for m = 1:obj.num.before_rej	
					obj.data(:,:,m) = obj.data(:,:,m) - mean(baseline_epoch(:,:,m),2);
				end
			end
        end
	
		function r = cut_out(obj,data,onset_N,range_N)
			%r = data(:,onset+(floor(obj.etc.range(1)*obj.props.fs):floor(obj.etc.range(2)*obj.props.fs)));
			r = data(:,onset_N+(range_N(1):range_N(2)));
		end
        
        function rej_th(obj,ch,th)
			accepted = ones(1,obj.num.current);

			ch_data = obj.data(ch,:,:);

            for m = 1:obj.num.current
               if min(min(ch_data(:,:,m))) < th(1) || max(max(ch_data(:,:,m))) > th(2)
                   accepted(m) = 0;
               end
            end
            
            idx = find(accepted == 0);
            trigs_ = obj.trigs;
            for m = 1:length(idx)
                tmp = 0;
                for n = 1:size(obj.trigs,1)
                    tmp = tmp + ~obj.trigs(n,3);
                    if tmp==idx(m)
                        trigs_(n,3) = 1;
                    end
                end
            end
            obj.trigs = trigs_;

			obj.data = obj.data(:,:,logical(accepted));

            if ~isfield(obj.etc,'reject')
                obj.etc.reject{1}.n_rej = sum(~accepted);
                obj.etc.reject{1}.ch = ch;
                obj.etc.reject{1}.th = th;
            else
                idx_rej = length(obj.etc.reject)+1;
                obj.etc.reject{idx_rej}.n_rej = sum(~accepted);
                obj.etc.reject{idx_rej}.ch = ch;
                obj.etc.reject{idx_rej}.th = th;
            end
			
			num_pre = obj.num.current;
            obj.num.current = size(obj.data,3);
            fprintf('Trigger No.%d, %d epochs out of %d were rejected.\n',obj.etc.trig_num,sum(~accepted),num_pre);
 
        end
    end
end

