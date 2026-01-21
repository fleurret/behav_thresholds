function pcorr_depths(pth, c)

% figure settings
f = figure();
f.Position = [0, 0, 800, 800];
hold on
ax = gca;
set(ax, 'TickDir', 'out',...
    'XLim', [-35 5],...
    'XTickLabelRotation', 0,...
    'TickLength', [0.02,0.02],...
    'LineWidth', 3);
set(findobj(ax,'-property','FontName'),...
    'FontName','Arial')
xoffset = [0.990,0.993,0.996,1,1.003,1.006,1.009];

% extract groups
conditions = uigetfile_n_dir(pth, 'Select data directory');

% how many subplots
ts = round(length(conditions)+1/2);

% for each subfolder
for i = 1:length(conditions)
    subjects = dir(cell2mat(conditions(i)));
    subjects(~[subjects.isdir]) = [];
    subjects(ismember({subjects.name},{'.','..'})) = [];
    [~, cond, ~] =  fileparts(conditions(i));
    
    maxdays = 10;
    ax(i) = subplot(ts,2,i);
    
    % extract output for each subject
    for subj = 1:length(subjects)
        spth = fullfile(subjects(subj).folder,subjects(subj).name);
        d = dir(fullfile(spth,'*.mat'));
        ffn = fullfile(d.folder,d.name);
        
        fprintf('Loading subject %s ...',subjects(subj).name)
        load(ffn)
        fprintf(' done\n')
        
        trialdata = [];
        
        % for each day
        for j = 1:length(output)
            trialdata = [trialdata; output(j).trialmat(:,1:3)];
        end
        
        % combine
        trialdata = round(trialdata);
        data_to_fit = [];
        depths = unique(trialdata(:,1));
        
        for k = 1:length(depths)
            df = trialdata(trialdata(:,1) == depths(k),:);
            
            data_to_fit(k,1) = depths(k);
            data_to_fit(k,2) = sum(df(:,2));
            data_to_fit(k,3) = sum(df(:,3));
        end
        
        % fit curve?
        options.dprimeThresh = 1;
        [options,results,zFA] = find_threshPC(data_to_fit,options);
        
        hold on
        
        % plot points
        %             for pts = 2:size(results.data,1)
        %                 scatter(ax(i), results.data(pts,1),results.data(pts,2)./results.data(pts,3),...
        %                     'SizeData', 10*(sqrt(10000./sum(results.data(:,3))*results.data(pts,3))),...
        %                     'Marker', 'o',...
        %                     'MarkerFaceColor', 'k',...
        %                     'MarkerFaceAlpha', 0.3,...
        %                     'MarkerEdgeAlpha', 0)
        %             end
        %
        % plot curve
        x = linspace(min(results.data(:,1)),max(results.data(:,1)),1000);
        fitValues = (1-results.Fit(3)-results.Fit(4))*arrayfun(@(x) results.options.sigmoidHandle(x,results.Fit(1),results.Fit(2)),x)+results.Fit(4);
        
        plot(ax(i), x, fitValues,...
            'Color', [0, 0, 0, 0.3])
    end
    
    title([cond])
    
end


% axes
xlabel(ax, 'AM Depth (dB re: 100%)',...
    'FontSize',10,...
    'FontWeight', 'bold')
ylabel(ax, 'd''',...
    'FontSize',10,...
    'FontWeight', 'bold')

title([cellstr(conditions(i))])