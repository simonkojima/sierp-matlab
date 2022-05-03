%
%	siPlot
%
%	Author : Simon Kojima
%	Ver1.0 2021/08/31
%	Ver1.1 2021/09/02
%   Ver1.2 2021/09/22
%   Ver1.3 2021/10/13
%   Ver1.4 2021/12/8

classdef siPlot < handle
    
    properties
		data
		fig
		props
		etc
    end
    
    methods

        function obj = siPlot(div,varargin)
			obj.etc.div = div;
			obj.fig = figure('SizeChangedFcn',@resizeui);
			obj.props.axis = 'ij';
			for m = 1:div(1)*div(2)
				obj.data{m}.objs = [];
				obj.data{m}.epoch = [];
				obj.data{m}.opts = [];
				obj.data{m}.misc.ttest = [];
				obj.data{m}.misc.stim = [];
				obj.data{m}.misc.axis.x = [];
				obj.data{m}.misc.axis.y = [];
			end
			
			if length(varargin) > 0
				for m=1:2:length(varargin)
					obj.props.(varargin{m}) = varargin{m+1};
				end
			end

			function resizeui(jObject,event)
				%for m = 1:length(obj.data)
			%		subplot(obj.etc.div(1),obj.etc.div(2),m);
			%		obj.data{m}.misc.axis.y.YData = ylim();
			%		obj.data{m}.misc.axis.x.XData = xlim();
			%	end
			end
        end

        function legend(obj,loc,labels)
            N = length(obj.data{loc}.objs);
            plots = [];
            for n = 1:N
                plots = cat(2,plots,obj.data{loc}.objs{n});
            end
            legend(plots,labels)
        end

		function opt_lim(obj,loc,varargin)

			subplot(obj.etc.div(1),obj.etc.div(2),loc);

			tmp_max = [];
			tmp_min = [];

			for m = 1:length(obj.data{loc}.objs)
				for n = 1:length(obj.data{loc}.objs{m})
					y = obj.data{loc}.objs{m}(n).YData;
					tmp_max(length(tmp_max)+1) = max(y);
					tmp_min(length(tmp_min)+1) = min(y);
				end
			end

			rate = 1.05;
			
			if length(varargin) > 0
				rate = varargin{1};
			end

			tmp_max = max(tmp_max)*rate;
			tmp_min = min(tmp_min)*rate;
			
			ylim([tmp_min tmp_max]);

		end       

 
        function id = plot(obj,loc,epoch,time,varargin)
            obj.data{loc}.plt_mode = 'average';
			
			idx_opts = length(obj.data{loc}.opts)+1;
            obj.data{loc}.opts{idx_opts} = varargin;
            if length(varargin) > 0
                accepted_opts = ones(length(varargin),1);
                for m = 1:2:length(varargin)
                    if strcmpi(varargin{m},'plt_mode')
                        obj.data{loc}.plt_mode = varargin{m+1};
                        accepted_opts(m) = 0;
                        accepted_opts(m+1) = 0;
                    end
                end
                obj.data{loc}.opts{idx_opts} = varargin(logical(accepted_opts));
            end
            opts = obj.data{loc}.opts{idx_opts};
            epoch = squeeze(epoch);
            if ndims(epoch) > 2
                error("Dimentions of data must be less than 2.");
            end
            idx_epoch = length(obj.data{loc}.epoch)+1;
            obj.data{loc}.epoch{idx_epoch} = epoch;
            obj.data{loc}.time{idx_epoch} = time;
            
            figure(obj.fig);
            subplot(obj.etc.div(1),obj.etc.div(2),loc);
            hold on;
			
			if strcmpi(obj.props.axis,'ij')
				axis ij;
			end

            if strcmpi(obj.data{loc}.plt_mode,'average')
                idx = length(obj.data{loc}.objs)+1;
                obj.data{loc}.objs{idx} = plot(time,mean(epoch,2));
            elseif strcmpi(obj.data{loc}.plt_mode,'butterfly')
                idx = length(obj.data{loc}.objs)+1;
                obj.data{loc}.objs{idx} = plot(time,epoch,'color',[0.7 0.7 0.7]);
                idx = idx + 1;
                obj.data{loc}.objs{idx} = plot(time,mean(epoch,2));
			else
				error("Unrecognized plt_mode.");
            end
            
            id = idx;
            
            if length(opts) > 0
                for m = 1:2:length(opts)
					obj.change_props(obj.data{loc}.objs{idx},opts{m},opts{m+1});
                end
            end

			obj.opt_lim(loc);
            
        end
		
		function ttest(obj,loc,id_1,id_2,alpha,varargin)

			mode = 'mesh';
			opts = [];
                
			if length(obj.data{loc}.misc.ttest) > 0
				for m = length(obj.data{loc}.misc.ttest):-1:1
					if strcmpi(obj.data{loc}.misc.ttest{m}.mode,'line')
						height = obj.data{loc}.misc.ttest{m}.height;
						pos = obj.data{loc}.misc.ttest{m}.pos + height + 1;
						break
					elseif m == length(obj.data{loc}.misc.ttest)
						pos = 5;
						height = 5;
					end
				end
			else
				pos = 5;
				height = 5;
			end

			figure(obj.fig);
			subplot(obj.etc.div(1),obj.etc.div(2),loc);

			ids = [id_1(:);id_2(:)];
			tmp = obj.data{loc}.time(logical(ids));
			for m = 2:length(ids)
				if ~isequal(size(tmp{1}),size(tmp{m}))
					error("Number of Samples of all data must be same.");
				end
			end

			tmp_1 = [];
			tmp_2 = [];

			for m = 1:length(id_1)
				tmp_1 = [tmp_1 obj.data{loc}.epoch{id_1(m)}];
			end			

			for m = 1:length(id_2)
				tmp_2 = [tmp_2 obj.data{loc}.epoch{id_2(m)}];
			end

			[h,p,ci,stats] = ttest2(tmp_1,tmp_2,'Dim',2,'Alpha',alpha);
			
			range = [];

			if h(1) == 1
				range(1,1) = 1;
			end

			for m = 1:length(h)-1
				if h(m) == 0 && h(m+1) == 1
					range(size(range,1)+1,1) = m+1;
				end

				if h(m) == 1 && h(m+1) == 0
					range(size(range,1),2) = m;
				end
			end

			if h(end) == 1
				range(size(range,1),2) = length(h);
			end

			idx = length(obj.data{loc}.misc.ttest)+1;

			obj.data{loc}.misc.ttest{idx}.h = h;
			obj.data{loc}.misc.ttest{idx}.range = range;
            obj.data{loc}.misc.ttest{idx}.mode = mode;

			if length(varargin) > 0	
				is_opts = ones(length(varargin),1);
				for m = 1:2:length(varargin)
					if strcmpi(varargin{m},'mode')
						obj.data{loc}.misc.ttest{idx}.mode = varargin{m+1};
						mode = varargin{m+1};
						is_opts(m) = 0;
						is_opts(m+1) = 0;	
					elseif strcmpi(varargin{m},'height')
						obj.data{loc}.misc.ttest{idx}.height = varargin{m+1};
						height = varargin{m+1};
						is_opts(m) = 0;
						is_opts(m+1) = 0;
					elseif strcmpi(varargin{m},'pos')
						obj.data{loc}.misc.ttest{idx}.pos = varargin{m+1};
						pos = varargin{m+1};
						is_opts(m) = 0;
						is_opts(m+1) = 0;
					end
				end
				obj.data{loc}.misc.ttest{idx}.opts = varargin(logical(is_opts));
				opts = obj.data{loc}.misc.ttest{idx}.opts;
			end

			obj.data{loc}.misc.ttest{idx}.height = height;
			obj.data{loc}.misc.ttest{idx}.pos = pos;

			if strcmpi(mode,'mesh')
				tmp = ylim();
				y_1 = tmp(1);
				y_2 = tmp(2);
				color = [0.7 0.7 0.7];
			elseif strcmpi(mode,'line')
				if isempty(height) || isempty(pos)
					error("property 'height' and 'pos' must be set in 'line' mode.");
				end
				y = ylim();
				height_act = (y(2)-y(1))*height*0.01;
				pos_act = (y(2)-y(1))*pos*0.01;
				if strcmpi(obj.props.axis,'ij')
					y_1 = y(1) + pos_act;
					y_2 = y(1) + pos_act + height_act;
				else
					y_1 = y(2) - pos_act;
					y_2 = y(2) - (pos_act + height_act);
				end
				color = obj.get_color();
			else
				error(strcat("Unrecognized mode '",mode,''.'));
			end

			for m = 1:size(range,1)
				x_1 = obj.data{loc}.time{1}(range(m,1));
				x_2 = obj.data{loc}.time{1}(range(m,2));

				obj.data{loc}.misc.ttest{idx}.objs(m) = fill([x_1 x_1 x_2 x_2],[y_1 y_2 y_2 y_1],color);
				obj.data{loc}.misc.ttest{idx}.objs(m).EdgeColor = 'none';
				obj.data{loc}.misc.ttest{idx}.objs(m).FaceAlpha = 0.5;
			end

			if length(opts) > 0
				for m = 1:2:length(opts)
					obj.change_props(obj.data{loc}.misc.ttest{idx}.objs,opts{m},opts{m+1});
				end
			end

		end

		function plot_stim(obj,loc,range,varargin)
			
			figure(obj.fig);
			subplot(obj.etc.div(1),obj.etc.div(2),loc);

			idx = length(obj.data{loc}.misc.stim) + 1;

			opts = [];

			if length(obj.data{loc}.misc.stim) > 0
				height = obj.data{loc}.misc.stim{idx-1}.height;
				pos = obj.data{loc}.misc.stim{idx-1}.pos + height + 1;
			else
				pos = 5;
				height = 5;
			end

			if length(varargin) > 0	
				is_opts = ones(length(varargin),1);
				for m = 1:2:length(varargin)
					if strcmpi(varargin{m},'height')
						height = varargin{m+1};
						is_opts(m) = 0;
						is_opts(m+1) = 0;
					elseif strcmpi(varargin{m},'pos')
						pos = varargin{m+1};
						is_opts(m) = 0;
						is_opts(m+1) = 0;
					end
				end
				obj.data{loc}.misc.stim{idx}.opts = varargin(logical(is_opts));
				opts = obj.data{loc}.misc.stim{idx}.opts;
			end

			obj.data{loc}.misc.stim{idx}.height = height;
			obj.data{loc}.misc.stim{idx}.pos = pos;

			y = ylim();
			height_act = (y(2)-y(1))*height*0.01;
			pos_act = (y(2)-y(1))*pos*0.01;
			if strcmpi(obj.props.axis,'ij')
				y_1 = y(2) - pos_act;
				y_2 = y(2) - (pos_act + height_act);
			else
				y_1 = y(1) + pos_act;
				y_2 = y(1) + (pos_act + height_act);
			end

			color = obj.get_color();

			for m = 1:size(range,1)
				x_1 = range(m,1);
				x_2 = range(m,2);
				obj.data{loc}.misc.stim{idx}.objs(m) = fill([x_1 x_1 x_2 x_2],[y_1 y_2 y_2 y_1],color);
				obj.data{loc}.misc.stim{idx}.objs(m).EdgeColor = 'none';
				obj.data{loc}.misc.stim{idx}.objs(m).FaceAlpha = 0.5;
			end

			if length(opts) > 0
				for m = 1:2:length(opts)
					obj.change_props(obj.data{loc}.misc.stim{idx}.objs,opts{m},opts{m+1});
				end
			end

		end
		
		
		function change_props(obj,arg,field,val)
			for m = 1:length(arg)
				tmp = fieldnames(arg(m));
				for n = 1:length(tmp)
					if strcmpi(tmp{n},field)
						arg(m).(tmp{n}) = val;
						break
					elseif n == length(tmp)
						arg(m).(field) = val;
					end
				end
			end
		end
	
		function axis_x(obj,loc,varargin)
			figure(obj.fig);
			subplot(obj.etc.div(1),obj.etc.div(2),loc);
			obj.data{loc}.misc.axis.x = plot(xlim(), [0 0],'k');
			
			if length(varargin) > 0
				for m = 1:2:length(varargin)
					obj.change_props(obj.data{loc}.misc.axis.x,varargin{m},varargin{m+1});
				end
			end

			tmp = get(gca,'Children');
			children = [];
			for m = 2:length(tmp)
				children(m-1) = tmp(m);
			end
			children(length(children)+1) = tmp(1);
		
			set(gca,'Children',children);
		end

		function axis_y(obj,loc,varargin)
			figure(obj.fig);
			subplot(obj.etc.div(1),obj.etc.div(2),loc);
			obj.data{loc}.misc.axis.y = plot([0 0], ylim(),'k');

			if length(varargin) > 0
				for m=1:2:length(varargin)
					obj.change_props(obj.data{loc}.misc.axis.y,varargin{m},varargin{m+1});
				end
			end
			
			tmp = get(gca,'Children');
			children = [];
			for m = 2:length(tmp)
				children(m-1) = tmp(m);
			end
			children(length(children)+1) = tmp(1);

			set(gca,'Children',children);
		end

		function r = get_color(obj)
			persistent cnt;
			if isempty(cnt)
				cnt = 0;
			end

			color = [0 0.4470 0.7410;0.8500 0.3250 0.0980;0.9290 0.6940 0.1250;0.4940 0.1840 0.5560;0.4660 0.6740 0.1880;0.3010 0.7450 0.9330;0.6350 0.0780 0.1840];
			
			r = color(rem(cnt,size(color,1))+1,:);

			cnt = cnt + 1;
		end

    end
end

