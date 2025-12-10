function ablation_corr(savedir, c)

% figure settings
f = figure();
f.Position = [0, 0, 800, 800];
hold on
ax = gca;
set(ax, 'TickDir', 'out',...
    'XTickLabelRotation', 0,...
    'TickLength', [0.02,0.02],...
    'LineWidth', 3,...
    'YDir','reverse');
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

% remove ibotenic/saline groups
conditions = conditions(contains(conditions,'rGFP') | contains(conditions,  'rCre'));

% how many subplots
ts = round(length(conditions)/2);

for i = 1:length(conditions)
    grp = D(strcmp(D.Condition, conditions(i)),:);
    b = nan(1, height(grp));
    n = nan(1, height(grp));
    
    % get cell densities for each subject
    for j = 1:height(grp)
        ic(j) = grp.IC_L_density(j,:) + grp.IC_R_density(j,:);
        acx(j) = grp.ACx_L_count(j,:) + grp.ACx_R_count(j,:);
    end
    
    % plot
    ax(i) = subplot(ts,2,i);
    scatter(ax(i), ic, acx,...
        'Marker', 'o',...
        'SizeData', 80,...
        'MarkerFaceColor', c(i,:),...
        'MarkerEdgeAlpha', 0)
    
    % best fit
    yf = ic(~isnan(ic));
    xf = acx(~isnan(ic));
    
    if isempty(yf)
        continue
    end
    
    coefficients = polyfit(xf, yf, 1);
    xFit = linspace(min(xf), max(xf), 1000);
    yFit = polyval(coefficients , xFit);
    
    hfit = line(ax(i),xFit,yFit, ...
        'Color', 'k', ...
        'LineWidth',3);
    
    % axes
    xlabel(ax(i), 'IC cell density (cells/mm^2)',...
        'FontSize',10,...
        'FontWeight', 'bold')
    ylabel(ax(i), 'ACx cell density (cells/mm^2)',...
        'FontSize',10,...
        'FontWeight', 'bold')
            
    title([cellstr(conditions(i))])
    
    % R and p values
    [R,P] = corrcoef(xf,yf,'rows','complete');
    r = R(2);
    p = P(2);
    str = sprintf('R = %s, p = %s \n', num2str(r), num2str(p));
    T = text(max(xlim)*0.85, max(ylim)-0.2, str);
    set(findobj(T),...
        'FontSize', 9,...
        'FontName', 'Arial',...
        'HorizontalAlignment', 'center');
end