function dprime_depths(savedir, c)

% figure settings
f = figure();
f.Position = [0, 0, 500, 500];
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

% separate by condition
conditions = unique(D.Condition);

for i = 1:length(conditions)
    cond = conditions(i);
    grp = D(strcmp(D.Condition, cond),:);
    depths = unique(grp.Depth);
    
    Depths = [];
    dprimes = [];
    sem = [];
    N = [];

    % for each depth
    for j = 1:length(depths)
        ddata = grp(grp.Depth == depths(j),:);
        
        Depths = [Depths, depths(j)];
        dprimes = [dprimes, mean(ddata.dprime)];
        sem = [sem, std(ddata.dprime)/sqrt(height(ddata))];
        N = [N, sum(ddata.n_trials)];
    end
    
    % match color
    color = matchcolor(cond, c);
    
    % plot points
    scatter(Depths, dprimes,...
        'Marker', 'o',...
        'SizeData', sqrt(N)*5,...
        'MarkerFaceColor', color,...
        'MarkerFaceAlpha', 1,...
        'MarkerEdgeAlpha', 0)
    errorbar(Depths, dprimes, sem,...
        'Color', color,...
        'CapSize', 0,...
        'LineWidth', 1.5,...
        'LineStyle', 'none',...
        'Marker', 'none');
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