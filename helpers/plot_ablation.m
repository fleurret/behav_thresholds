function plot_ablation(pth, savedir, abl, c)

% select .csv
d = uigetfile_n_dir(pth, 'Select file');

if ~contains(d, '.csv')
    warning('invalid file :(')
end

D = readtable(cell2mat(d));

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
    bar(ax, x, m,...
        'FaceColor', c(i,:),...
        'LineStyle', 'none')
    
    % errorbar properties
    errorbar(x, m , sem,...
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
    'FontSize',10,...
    'FontWeight', 'bold')
ylabel(ax, append('% ablation'),...
    'FontSize', 10,...
    'FontWeight', 'bold')