% TriggerSelect = [1 5];
% PlotColor = {'b','r'};
PlotYRange = [0 0];
Channel = [32];
PlotDivision = [1 1];
PlotPosition = [1];
%Subtraction = 1;
%SubTrigger = [1 2];
%SubColor = ['g'];

for l=1:length(Channel)

figure('Name',Label{Channel(l)},'NumberTitle','off');

AdaptedYRange = [];
if sum(abs(PlotYRange)) == 0
    temp = [];
    for m=1:length(TriggerSelect)
        temp(m,:) = Average.Data{m}(Channel(l),:);
    end
    AdaptedYRange(1) = min(min(temp));
    AdaptedYRange(2) = max(max(temp));
end

flag = 0;
for m=1:length(TriggerSelect)
    if flag == 0
        for n=1:size(TTest.h,2)
            if sum(abs(PlotYRange)) ~= 0
                yrange = PlotYRange;
            else
                yrange(1) = AdaptedYRange(1);
                yrange(2) = AdaptedYRange(2);
            end
            if TTest.h(m,n) == 1
                rectangle('Position',[(n-1)/Fs+Range(1) yrange(1) 1/Fs (yrange(2)-yrange(1))],'FaceColor',FillingColor,'EdgeColor',FillingColor);
            end
            %return
            %clear yrange
        end
    end
    hold on
    plot(EpochTime,Average.Data{m}(Channel(l),:),PlotColor{m});
    flag = 1;
end


ylim(yrange);
xlim(Range);
ylabel({Label{Channel(l)},PlotYLabel});
%ylabel(Label{Channel(l)});
xlabel(PlotXLabel);
xticks(range(1):0.1:Range(2));
%xticklabels({'-100','0','100','200','300','400','500'});
xticklabels({'0','100','200','300','400','500','600','700','800','900','1000'});
axis ij

plot(xlim, [0 0], 'k');
plot([0 0], ylim, 'k');

set(gca,'FontSize',14)
end    

hold off