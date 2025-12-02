function plot_ablation(savedir, abl, c)

% figure settings
f = figure();
f.Position = [0, 0, 800, 350];
hold on
ax = gca;
set(ax, 'TickDir', 'out',...
    'XTickLabelRotation', 0,...
    'TickLength', [0.02,0.02],...
    'LineWidth', 3);
set(findobj(ax,'-property','FontName'),...
    'FontName','Arial')

% find .csv
files = dir(savedir);
files(ismember({files.name},{'.','..'})) = [];
d = files(contains({files.name}, 'learning_rates and ihc.csv'));

if isempty(d)
    warning('learning_rates and ihc.csv not found!')
end

D = readtable(fullfile(d.folder, d.name));

% separate by condition
conditions = unique(D.Condition);

% remove ibotenic/saline groups if looking at ACx
if strcmp(abl, 'ACX')
    conditions = conditions(contains(conditions,'rGFP') | contains(conditions,  'rCre'));
end

groups = [1:length(conditions)];

for i = 1:length(conditions)
    grp = D(strcmp(D.Condition, conditions(i)),:);
    m = nan(1, 2);
    sem = nan(1, 2);
    
    % calculate means and sem
    switch abl
        case 'IC'
            m(1) = mean(grp.IC_L_density, 'omitnan');
            m(2) = mean(grp.IC_R_density, 'omitnan');
            sem(1) = std(grp.IC_L_density, 'omitnan')/sqrt(height(grp));
            sem(2) = std(grp.IC_R_density, 'omitnan')/sqrt(height(grp));
        case 'ACX'
            m(1) = mean(grp.ACx_L_density(:), 'omitnan');
            m(2) = mean(grp.ACx_R_density(:), 'omitnan');
            sem(1) = std(grp.ACx_L_density, 'omitnan')/sqrt(height(grp));
            sem(2) = std(grp.ACx_R_density, 'omitnan')/sqrt(height(grp));
    end
    
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
ylabel(ax, append(abl, ' cell density (cells/mm^2)'),...
    'FontSize', 10,...
    'FontWeight', 'bold')