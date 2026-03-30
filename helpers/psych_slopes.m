function psych_slopes(pth, c)

% PROCESS
% extract groups
groups = uigetfile_n_dir(pth, 'Select data directory');

% set figure size (in px)
f = figure();
f.Position = [0, 0, 500, 350];
ax = gca;
hold on

set(ax, 'TickDir', 'out',...
    'XTickLabelRotation', 0,...
    'TickLength', [0.02,0.02],...
    'LineWidth', 3);
set(findobj(ax,'-property','FontName'),...
    'FontName','Arial')
xoffset = [0.94,0.96,0.98,1,1.02,1.04,1.06];

for i = 1:length(groups)
    fn = fullfile(groups{i});
    color = matchcolor(fn, c);
    
    % extract subjects
    subjects = dir(fn);
    subjects(~[subjects.isdir]) = [];
    subjects(ismember({subjects.name},{'.','..'})) = [];

    slope = [];
    
    % extract slopes
    for subj = 1:length(subjects)
        spth = fullfile(subjects(subj).folder,subjects(subj).name);
        d = dir(fullfile(spth,'*.mat'));
        ffn = fullfile(d.folder,d.name);
        
        fprintf('Loading subject %s ...',subjects(subj).name)
        O = load(ffn);
        fprintf(' done\n')
        
        vals = O.output;
        
        for j = 1:length(vals)
            x =  vals(j).fitdata.fit_plot.x;
            y =  vals(j).fitdata.fit_plot.dprime;
            t = vals(j).fitdata.threshold;
            
            dydx = gradient(y) ./ gradient(x);
%             slope(subj,j) = vals(j).fitdata.slope;
            slope = [slope, interp1(x, dydx, t)];
            
            plot(x, y,...
                'Color', [color, 0.1],...
                'LineWidth', 1.5,...
                'LineStyle', '-');
        end
    end
    
    % calculate means
    x = i;
    y = mean(slope);
    sem = std(slope)/sqrt(length(slope));
    
    % plot
%     e1 = errorbar(x, y, sem,...
%         'Color', color,...
%         'CapSize', 0,...
%         'LineWidth', 2,...
%         'LineStyle', 'none',...
%         'Marker', 'o',...
%         'MarkerFaceColor', color, ...
%         'MarkerSize',6);
%     alpha = 0.3;
%     set([e1.Bar, e1.Line], 'ColorType', 'truecoloralpha', 'ColorData', [e1.Line.ColorData(1:3); 255*alpha])
%     uistack(e1,'bottom');
end

% axes
xlabel(ax, 'AM Depth (dB re: 100%)',...
    'FontSize',10,...
    'FontWeight', 'bold')
ylabel(ax, 'd''',...
    'FontSize',10,...
    'FontWeight', 'bold')

% legend
for i = 1:length(groups)
    L(i*2-1) = groups(i);
    L(i*2) = {''};
end

legend(L,...
    'Location', 'northwest')
legend('boxoff')