function learning_rates(pth, savedir, maxdays)

% PROCESS
% empty table
base = nan(1,5);
headers = {'Subject', 'Condition', 'Starting_threshold', 'Best_threshold', 'Learning_rate'};
alldata = array2table(base);
alldata.Properties.VariableNames = headers;

% extract groups
groups = dir(pth);
groups(~[groups.isdir]) = [];
groups(ismember({groups.name},{'.','..'})) = [];

% access condition folders
for i = 1:length(groups)
    cond = groups(i).name;
    fn = fullfile(pth,cond);

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
        
        output = [];
        fprintf('Loading subject %s ...',subjects(subj).name)
        load(ffn)
        fprintf(' done\n')
        
        for j = 1:length(output)
            t(j) = output(j).fitdata.threshold;
        end
        
        % calculate fit
        x = log10([1:maxdays]);
        
        % are there nans?
        if sum(isnan(t)) > 0
            x = x(~isnan(t));
            t = t(~isnan(t));
            warning('Threshold array has NaNs!')
        end
        
        [fo,~] = fit(x',t','poly1');
        
        D{1} = append(subjects(subj).name);
        D{2} = cond;
        D{3} = t(1);
        D{4} = min(t);
        D{5} = fo.p1;
        
        % append to table
        alldata = [alldata; D];
        clear D
    end
end

% SAVE
% remove first row
alldata(1,:) = [];
sf = fullfile(savedir,'learning_rates.csv');

fprintf('Saving file ...')
writetable(alldata,sf);
fprintf(' done\n')
