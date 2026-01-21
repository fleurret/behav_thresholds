function days_to_criterion(pth, savedir, c, fontface, sv)

% EMPTY TABLE
headers = {'Subject', 'Sex', 'Condition', 'Days_to_criterion', 'Highest_dprime'};
alldata = table('size',[1 5],...
    'variabletypes',["string","string","string","double","double"],...
    'variablenames',headers);

% PROCESS
% extract groups
groups = uigetfile_n_dir(pth, 'Select data directory');

% set figure size (in px)
f = figure();
f.Position = [0, 0, 500, 350];
ax = gca;
ax(1) = subplot(1,2,1);
hold on
ax(2) = subplot(1,2,2);
hold on

% access condition folders
for i = 1:length(groups)
    fn = fullfile(groups{i});
    
    % extract subjects
    subjects = dir(fn);
    subjects(~[subjects.isdir]) = [];
    subjects(ismember({subjects.name},{'.','..'})) = [];
    
    % populate legend values
    [~, cond, ~] =  fileparts(groups(i));
    lv = append(cond,' (n = ', num2str(length(subjects)),')');
    C{i} = lv;
    
    % match color
    color = matchcolor(fn, c);
    
    days = nan(1,length(subjects));
    dprimes = nan(1,length(subjects));
    
    % extract vals
    for subj = 1:length(subjects)
        spth = fullfile(subjects(subj).folder,subjects(subj).name);
        D = dir(fullfile(spth,'*.mat'));
        ffn = fullfile(D.folder,D.name);
        
        fprintf('Loading subject %s ...',subjects(subj).name)
        O = load(ffn);
        fprintf(' done\n')
        
        % temp table
        data = table('size',[1 5],...
            'variabletypes',["string","string","string","double","double"],...
            'variablenames',headers);
        
        vals = O.output;
        
        % how many days of shock training
        subjdays = length(vals);
        days(subj) = subjdays;
        
        % highest d' during the last 2 days
        last = [vals(subjdays).dprimemat(2), vals(subjdays-1).dprimemat(2)];
        
        if any(last < 2)
            warning('This subject did not reach dprime > 2 on the last 2 days in this file!')
        end
        
        highestd = max(last);
        dprimes(subj) = highestd;
        
%         % plot individual data for days of shock training
%         scatter(ax(1), i, subjdays,...
%             'Marker', 'o',...
%             'MarkerFaceColor', 'k',...
%             'MarkerFaceAlpha', 0.5,...
%             'MarkerEdgeAlpha', 0)
%         
%         % plot individual data for highest d'
%         scatter(ax(2), i, highestd,...
%             'Marker', 'o',...
%             'MarkerFaceColor', 'k',...
%             'MarkerFaceAlpha', 0.5,...
%             'MarkerEdgeAlpha', 0)
        
        % append to table
        data.Subject = subjects(subj).name;
        data.Sex = O.Session(1).Info.Sex;
        data.Condition = cond;
        data.Days_to_criterion = subjdays;
        data.Highest_dprime = highestd;
        
        alldata = [alldata; data];
    end
    
    % plot means
    b1 = bar(ax(1), i, mean(days),...
        'FaceColor', color,...
        'LineStyle', 'none',...
        'LineWidth', 1);
    uistack(b1,'bottom');
    errorbar(ax(1), i, mean(days), std(days)/sqrt(length(days)),...
        'Color', 'k',...
        'LineWidth', 2,...
        'LineStyle', 'none');
    
    b2 = bar(ax(2), i, mean(dprimes),...
        'FaceColor', color,...
        'LineStyle', 'none',...
        'LineWidth', 1);
    uistack(b2,'bottom');
    errorbar(ax(2), i, mean(dprimes), std(dprimes)/sqrt(length(dprimes)),...
        'Color', 'k',...
        'LineWidth', 2,...
        'LineStyle', 'none');
    
    
    % for legend
    hold on
    f2(i) = scatter(NaN, NaN,...
        'MarkerFaceColor', color,...
        'MarkerEdgeColor', color,...
        'Marker', 'square');
end

% GRAPH PROPERTIES
% tick label, direction, line width, font size
set(ax(1:2), 'TickDir','out',...
    'LineWidth',1.5,...
    'FontSize',12);

% set font
set(findobj(ax(1:2),'-property','FontName'),...
    'FontName',fontface)

% axes labels and title
xlabel(ax(1:2),'Group',...
    'FontWeight','bold',...
    'FontSize', 12);
ylabel(ax(1),'Days to criterion',...
    'FontWeight','bold',...
    'FontSize', 12);
ylabel(ax(2),'Highest d''',...
    'FontWeight','bold',...
    'FontSize', 12);

% legend
legend(f2, C,...
    'Location','northwest',...
    'FontSize',12);
legend boxoff

% save
prompt = {'Image file name (no extension):'};
sfn = inputdlg(prompt, 'Save figure', [1 40]);
sffn = cell2mat(fullfile(savedir, append(sfn, '.svg')));
fprintf('Saving figure...')
saveas(f,sffn)
fprintf(' done\n')

% delete first row of data table
alldata(1,:) = [];

% save file
if sv == 1
    prompt = {'Data file name (no extension):'};
    dfn = inputdlg(prompt, 'Save data', [1 40]);
    dffn = cell2mat(fullfile(savedir, append(dfn, '_output.csv')));
    fprintf('Saving csv file...')
    writetable(alldata,dffn)
end
fprintf(' done\n')