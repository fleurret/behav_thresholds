function plot_learning_rates(savedir, measure, c)

% figure settings
f = figure();
f.Position = [0, 0, 800, 350];
hold on
ax = gca;

% find .csv
files = dir(savedir);
files(ismember({files.name},{'.','..'})) = [];
d = files(contains({files.name}, 'learning_rates.csv'));

if isempty(d)
    warning('learning_rates.csv not found!')
end

D = readtable(fullfile(d.folder, d.name));

% separate by condition
conditions = reshape(unique(D.Condition), 2, 2);
x = 1:length(conditions);

for j = 1:height(conditions)
    subgroup = conditions(:,j);
    
    for i = 1:length(subgroup)
        grp = D(contains(D.Condition, subgroup(i)),:);
        
        switch measure
            case 'learningrate'
                m = mean(grp.Learning_rate);
                sem = std(grp.Learning_rate)/sqrt(height(grp));
            case 'bestthreshold'
                m = mean(grp.Best_threshold);
                sem = std(grp.Best_threshold)/sqrt(height(grp));
            case 'startingthreshold'
                m = mean(grp.Starting_threshold);
                sem = std(grp.Starting_threshold)/sqrt(height(grp));
            case 'improvement'
                pc = ((grp.Best_threshold-grp.Starting_threshold)./grp.Starting_threshold)*100;
                m = mean(pc);
                sem = std(pc)/sqrt(height(pc));
        end
        
        % plot means and SEM
        color = matchcolor(subgroup(i), c);
        
        ax(j) = subplot(1,2,j);
        hold on
        
        bar(ax(j), x(i), m,...
            'FaceColor', color,...
            'LineStyle', 'none')
        
        % errorbar properties
        errorbar(ax(j), x(i), m , sem,...
            'Color', 'k',...
            'CapSize', 0,...
            'LineWidth', 2,...
            'LineStyle', 'none',...
            'Marker', 'none');
    end
    
    % ax labels
    xticks([x])
    xticklabels(subgroup)
    xlabel(ax(j),'Group',...
        'FontSize',10,...
        'FontWeight', 'bold')
    ylim([round(min(ylim)/5)*5 0])
    ylabel(ax(j), measure,...
        'FontSize', 10,...
        'FontWeight', 'bold')
    set(ax(j), 'TickDir', 'out',...
        'XTickLabelRotation', 0,...
        'TickLength', [0.02,0.02],...
        'LineWidth', 3,...
        'YDir','reverse');
    set(findobj(ax(j),'-property','FontName'),...
        'FontName','Arial')
    linkaxes(ax, 'y')
end