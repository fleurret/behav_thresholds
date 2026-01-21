function pct_impr(pth, savedir, maxdays, c, fontface)

% PROCESS
% extract groups
groups = uigetfile_n_dir(pth, 'Select data directory');

% set figure size (in px)
f = figure();
f.Position = [0, 0, 500, 350];
ax = gca;

% change x values to log scale and offset
days = 1:maxdays;
xx = log10(days)+1;
xoffset = [0.985, 0.99, 1, 1.005, 1.01];

% access condition folders
for i = 1:length(groups)
    fn = fullfile(groups{i});

    % extract subjects
    subjects = dir(fn);
    subjects(~[subjects.isdir]) = [];
    subjects(ismember({subjects.name},{'.','..'})) = [];
    
    % create empty array to store data
    t = nan(1,maxdays);
    thresholds = nan(length(subjects),maxdays);
    
    % extract thresholds
    for subj = 1:length(subjects)
        spth = fullfile(subjects(subj).folder,subjects(subj).name);
        d = dir(fullfile(spth,'*.mat'));
        ffn = fullfile(d.folder,d.name);
        
        fprintf('Loading subject %s ...',subjects(subj).name)
        O = load(ffn);
        fprintf(' done\n')
        
        vals = O.output;
        for j = 1:length(vals)
             t(j) = ((vals(j).fitdata.threshold-vals(1).fitdata.threshold)/vals(1).fitdata.threshold)*100;
        end
        
        thresholds(subj,1:length(t)) = t;
    end
    
    m = mean(thresholds, 'omitnan');
    s = std(thresholds, 'omitnan')/sqrt(height(thresholds));
    
    % populate legend values
    [~, cond, ~] =  fileparts(groups(i));
    lv = append(cond,' (n = ', num2str(length(subjects)),')');
    C{i} = lv;
    
    % match color
    color = matchcolor(fn, c);
    
    % plot
    xi = xx*xoffset(i);
    
    % errorbar properties
    hold on
    e = errorbar(xi,m,s,...
        'Color', color,...
        'CapSize', 0,...
        'LineWidth', 2,...
        'LineStyle', 'none',...
        'Marker', 'o',...
        'MarkerFaceColor', color, ...
        'MarkerSize',8);
    alpha = 0.3;
    set([e.Bar, e.Line], 'ColorType', 'truecoloralpha', 'ColorData', [e.Line.ColorData(1:3); 255*alpha])
    uistack(e,'bottom');
    
    % fit line
    [fo,~] = fit(xi',m','poly1');
    bf = fo.p1 .*xi + fo.p2;
    f(i) = line(xi, bf,...
        'LineWidth',3,...
        'Color', color);
end

% GRAPH PROPERTIES
xlim([0.9, max(xi)+0.1])

% tick label, direction, line width, font size
set(ax, 'XTick', log10(1:10)+1,...
    'XTickLabel',days,...
    'TickDir','out',...
    'LineWidth',1.5,...
    'FontSize',12);

% set font
set(findobj(ax,'-property','FontName'),...
    'FontName',fontface)

% axes labels and title
xlabel(ax,'Perceptual training day',...
    'FontWeight','bold',...
    'FontSize', 12);
ylabel(ax,'Threshold improvement (%)',...
    'FontWeight','bold',...
    'FontSize', 12);

% legend
legend(flip(C),'Location','southwest','FontSize',12);
legend boxoff

% save
prompt = {'File name (no extension):'};
sfn = inputdlg(prompt, 'Save figure', [1 40]);
sffn = cell2mat(fullfile(savedir, append(sfn, '.svg')));
saveas(f,sffn)