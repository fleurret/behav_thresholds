function behavior_ablation_all(savedir, measure, abl, c)

% figure settings
f = figure();
f.Position = [0, 0, 500, 500];
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

conditions = conditions(~contains(conditions,'ACx'));

B = [];
N = [];

for i = 1:length(conditions)
    grp = D(strcmp(D.Condition, conditions(i)),:);
    b = nan(1, height(grp));
    n = nan(1, height(grp));
    
    % get behavioral and neural measures for each subject
    for j = 1:height(grp)
        switch measure
            case 'learningrate'
                b(j) = grp.Learning_rate(j,:);
            case 'bestthreshold'
                b(j) = grp.Best_threshold(j,:);
            case 'startingthreshold'
                b(j) = grp.Starting_threshold(j,:);
            case 'improvement'
                b(j) = ((grp.Best_threshold(j,:)-grp.Starting_threshold(j,:))./grp.Starting_threshold(j,:))*100;
        end
        
        switch abl
            case 'IC'
                n(j) = grp.IC_L_density(j,:) + grp.IC_R_density(j,:);
            case 'ACX'
                n(j) = grp.ACx_L_count(j,:) + grp.ACx_R_count(j,:);
        end
    end
    
    B = [B, b];
    N = [N, n];
    
    % plot
    scatter(ax, n, b,...
        'Marker', 'o',...
        'SizeData', 80,...
        'MarkerFaceColor', c(i,:),...
        'MarkerEdgeAlpha', 0)
end

% best fit
yf = B(~isnan(N));
xf = N(~isnan(N));

coefficients = polyfit(xf, yf, 1);
xFit = linspace(min(xf), max(xf), 1000);
yFit = polyval(coefficients , xFit);

hfit = line(ax,xFit,yFit, ...
    'Color', 'k', ...
    'LineWidth',3);

% axes
switch abl
    case 'IC'
        xlabel(ax, 'Total IC cell density (cells/mm^2)',...
            'FontSize',10,...
            'FontWeight', 'bold')
    case 'ACX'
        xlabel(ax, 'Total ACx cell count',...
            'FontSize',10,...
            'FontWeight', 'bold')
end

switch measure
    case 'learningrate'
        ylabel(ax, 'Learning rate (db re: 100% per day)',...
            'FontSize',10,...
            'FontWeight', 'bold')
    case 'bestthreshold'
        ylabel(ax, 'Best threshold (db re: 100%)',...
            'FontSize',10,...
            'FontWeight', 'bold')
    case 'startingthreshold'
        ylabel(ax, 'Starting threshold (db re:100%)',...
            'FontSize',10,...
            'FontWeight', 'bold')
    case 'improvement'
        ylabel(ax, 'Percent improvement',...
            'FontSize',10,...
            'FontWeight', 'bold')
end
        
% title([cellstr(conditions(i))])
        
% R and p values
[R,P] = corrcoef(xf,yf,'rows','complete');
r = R(2);
p = P(2);
str = sprintf('R = %s, p = %s \n', num2str(r), num2str(p));
T = text(max(xlim)*0.85, min(ylim)+0.2, str);
set(findobj(T),...
    'FontSize', 9,...
    'FontName', 'Arial',...
    'HorizontalAlignment', 'center');

% legend
legend(conditions,...
    'Location', 'northwest')
legend('boxoff')