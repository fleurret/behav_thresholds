function shock_training_dprimes(pth, savedir, c, fontface)

% PROCESS
% extract groups
groups = uigetfile_n_dir(pth, 'Select data directory');

% set figure size (in px)
f = figure();
f.Position = [0, 0, 500, 350];
ax = gca;

% change x values to log scale and offset
xx = [1:15];
xoffset = [0.985, 0.99, 1, 1.005, 1.01];

% access condition folders
for i = 1:length(groups)
    fn = fullfile(groups{i});
    
    % match color
    color = matchcolor(fn, c);

    % extract subjects
    subjects = dir(fn);
    subjects(~[subjects.isdir]) = [];
    subjects(ismember({subjects.name},{'.','..'})) = [];

    % extract thresholds
    for subj = 1:length(subjects)
        spth = fullfile(subjects(subj).folder,subjects(subj).name);
        D = dir(fullfile(spth,'*.mat'));
        ffn = fullfile(D.folder,D.name);
        
        fprintf('Loading subject %s ...',subjects(subj).name)
        O = load(ffn);
        fprintf(' done\n')
        
        d = nan(1,15);
        vals = O.output;

        for j = 1:length(vals)
            if isempty(vals(j).dprimemat)
                continue
            else
                d(j) = vals(j).dprimemat(2);
            end
        end

        % plot individual trace
        xi = xx*xoffset(i);
        linecolor = [color, 0.5];
        
        hold on
        plot(xi, d,...
            'Marker', 'none',...
            'Color', linecolor,...
            'LineWidth', 1.5,...
            'LineStyle', '-')
    end
    
    % populate legend values
    [~, cond, ~] =  fileparts(groups(i));
    lv = append(cond,' (n = ', num2str(length(subjects)),')');
    C{i} = lv;
    
    % plot
    xi = xx*xoffset(i);
    
    % for legend
    hold on
    f2(i) = scatter(NaN, NaN,...
        'MarkerFaceColor', color,...
        'MarkerEdgeColor', color,...
        'Marker', 'square');
end

% GRAPH PROPERTIES
% tick label, direction, line width, font size
set(ax, 'TickDir','out',...
    'LineWidth',1.5,...
    'FontSize',12);

% set font
set(findobj(ax,'-property','FontName'),...
    'FontName',fontface)

% axes labels and title
xlabel(ax,'Shock training day',...
    'FontWeight','bold',...
    'FontSize', 12);
ylabel(ax,'d''',...
    'FontWeight','bold',...
    'FontSize', 12);

% legend
legend(f2, C,...
    'Location','southwest',...
    'FontSize',12);
legend boxoff

% save
prompt = {'File name (no extension):'};
sfn = inputdlg(prompt, 'Save figure', [1 40]);
sffn = cell2mat(fullfile(savedir, append(sfn, '.svg')));
saveas(f,sffn)
