function dprime_depths_days(savedir, c)

% figure settings
f = figure();
f.Position = [0, 0, 900, 500];
hold on
ax = gca;
set(ax, 'TickDir', 'out',...
    'XLim', [-35 5],...
    'XTickLabelRotation', 0,...
    'TickLength', [0.02,0.02],...
    'LineWidth', 3);
set(findobj(ax,'-property','FontName'),...
    'FontName','Arial')
xoffset = [0.94,0.96,0.98,1,1.02,1.04,1.06];

% find .csv
files = dir(savedir);
files(ismember({files.name},{'.','..'})) = [];
d = files(contains({files.name}, 'dprime_stats_output.csv'));

if isempty(d)
    warning('dprime_stats_output.csv not found!')
end

D = readtable(fullfile(d.folder, d.name));
D.Depth = round(D.Depth);

% separate by condition
conditions = unique(D.Condition);

for i = 1:length(conditions)
    cond = conditions(i);
    grp = D(strcmp(D.Condition, cond),:);
    
    days = unique(grp.Day);
    
    for k = 1:length(days)
        dd = grp(grp.Day == days(k),:);
        depths = unique(dd.Depth);
        
        dprimes = [];
        w = [];
        sem = [];
        
        for j = 1:length(depths)
            trialdata = dd(dd.Depth == depths(j),:);
            dprimes(j) = mean(trialdata.dprime);
            w(j) = height(trialdata);
            sem(j) = std(trialdata.dprime)/sqrt(height(trialdata));
        end
        
        [xfit,yfit,p_val,infl,slope] = fit_sigmoid(depths', dprimes, w);

        color = matchcolor(cond, c);
        
%         ax(k) = subplot(2,5,k);
%         subplot(ax(k))
%         hold on
        
        plot(xfit, yfit,...
            'Color', color,...
            'LineWidth', 1.5)
%         e1 = errorbar(depths, dprimes, sem,...
%             'Color', color,...
%             'CapSize', 0,...
%             'LineWidth', 2,...
%             'LineStyle', 'none',...
%             'Marker', 'o',...
%             'MarkerFaceColor', color, ...
%             'MarkerSize',6);
%         alpha = 0.3;
%         set([e1.Bar, e1.Line], 'ColorType', 'truecoloralpha', 'ColorData', [e1.Line.ColorData(1:3); 255*alpha])
%         uistack(e1,'bottom');
    end
end

% axes
xlabel(ax, 'AM Depth (dB re: 100%)',...
    'FontSize',10,...
    'FontWeight', 'bold')
ylabel(ax, 'd''',...
    'FontSize',10,...
    'FontWeight', 'bold')
xlim([-26 2])

% legend
for i = 1:length(conditions)
    L(i*2-1) = conditions(i);
    L(i*2) = {''};
end

legend(L,...
    'Location', 'northwest')
legend('boxoff')