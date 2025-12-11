function avg_threshold(pth, savedir, maxdays, yl, c, fontface)

% PROCESS

% extract groups
groups = uigetfile_n_dir(pth, 'Select data directory');

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
            t(j) = vals(j).fitdata.threshold;
        end
        
        thresholds(subj,1:length(t)) = t;
    end
    
    % calculate mean and standard error across days
    for j = 1:maxdays
        x = thresholds(1:subj,j);
        m = mean(x, 'omitnan');
        s = std(x, 'omitnan');
        s = s /(sqrt(maxdays));
        
        M(i,j) = m;
        S(i,j) = s;
    end
    
    % populate legend values
    [~, cond, ~] =  fileparts(groups(i));
    lv = append(cond,' (n = ', num2str(length(subjects)),')');
    C{i} = lv;
end

% PLOT

f = figure();

% set figure size (in px)
f.Position = [0, 0, 800, 350];

% change x values to log scale and offset
days = 1:maxdays;
xx = log10(days)+1;
xoffset = [0.99,1.01,1.03];

% set axes
ax = gca;

hold on

% plot data
for i = 1:length(groups)
    y = M(i,:);
    s = S(i,:);
    xi = xx*xoffset(i);
    
    % errorbar properties
    e = errorbar(xi,y,s,...
        'Color', c(i,:),...
        'CapSize', 0,...
        'LineWidth', 2,...
        'LineStyle', 'none',...
        'Marker', 'o',...
        'MarkerFaceColor', c(i,:), ...
        'MarkerSize',8);
    alpha = 0.3;
    set([e.Bar, e.Line], 'ColorType', 'truecoloralpha', 'ColorData', [e.Line.ColorData(1:3); 255*alpha])
    uistack(e,'bottom');
    
    % fit line
    [fo,~] = fit(xi',y','poly1');
    bf = fo.p1 .*xi + fo.p2;
    f(i) = line(xi, bf,...
        'LineWidth',3,...
        'Color',c(i,:));
end

% GRAPH PROPERTIES
xlim([0.9, max(xi)+0.1])

% tick label, direction, line width, font size
set(ax, 'XTick', log10(1:10)+1,...
    'XTickLabel',days,...
    'YLim',yl,...
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
ylabel(ax,'Threshold (dB re: 100%)',...
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
