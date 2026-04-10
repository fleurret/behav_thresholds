function plot_ablation(pth, savedir, abl, c, fontface)

% select .csv
D = readtable(pth);

% figure settings
f = figure();
f.Position = [0, 0, 400, 350];
hold on
ax = gca;
set(ax, 'TickDir', 'out',...
    'XTickLabelRotation', 0,...
    'TickLength', [0.02,0.02],...
    'LineWidth', 3);
set(findobj(ax,'-property','FontName'),...
    'FontName','Arial')

% separate by condition
conditions = unique(D.Condition);

% remove ibotenic/saline groups if looking at ACx
switch abl
    case 'ACX'
        conditions = conditions(contains(conditions,'rGFP'));
    case 'IC'
        conditions = conditions(~contains(conditions,'rGFP'));
end

groups = [1:length(conditions)];

for i = 1:length(conditions)
    grp = D(strcmp(D.Condition, conditions(i)),:);
    m = nan(1, 2);
    sem = nan(1, 2);
    
    % calculate means and sem
    m(1) = mean(grp.L_ablation, 'omitnan');
    m(2) = mean(grp.R_ablation, 'omitnan');
    sem(1) = std(grp.L_ablation, 'omitnan')/sqrt(height(grp));
    sem(2) = std(grp.R_ablation, 'omitnan')/sqrt(height(grp));
    
    x = [groups(i)*2-1, groups(i)*2];
    
    % plot means and SEM
    color = matchcolor(conditions(i), c);
    
    bar(ax, x-0.5, m,...
        'FaceColor', color,...
        'LineStyle', 'none')
    
    % errorbar properties
    errorbar(x-0.5, m , sem,...
        'Color', 'k',...
        'CapSize', 0,...
        'LineWidth', 2,...
        'LineStyle', 'none',...
        'Marker', 'none');
end

% ax labels
xticks([groups*2-1])
xticklabels(conditions)
xlabel(ax,'Group',...
    'FontWeight', 'bold')
ylabel(ax, append('% ablation'),...
    'FontWeight', 'bold')
set(findobj(ax,'-property','FontName'),...
    'FontName', fontface,...
    'FontSize', 12)

% save
prompt = {'File name (no extension):'};
sfn = inputdlg(prompt, 'Save figure', [1 40]);
sffn = cell2mat(fullfile(savedir, append(sfn, '.svg')));
saveas(f,sffn)